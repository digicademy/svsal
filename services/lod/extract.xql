xquery version "3.0";

(:~
 : XTriples
 :
 : A generic webservice to extract rdf statements from XML resources
 :
 : @author Torsten Schrade
 : @email Torsten.Schrade@adwmainz.de
 : @author Andreas Wagner
 : @email andreas.wagner@em.uni-frankfurt.de
 : @version 1.3.1 
 : @licence MIT
 :
 : Main module containing the webservice
:)

(: TODO:
	- Join: Schon vorhandene RDF Daten ohne den Umweg über XML hereinschneiden
	- Output -> Post to Sesame server, Store in eXist, Store in filesystem
:)

(: !!! SvSal Changes:
		- Change pattern in xtriples:expressionSanityCheck in order to allow doc()
		- Add some debugging routines
		- Add Caching!
		- Allow empty subjects/self-references (i.e. fix any23 output! )
		- Fix mime types for different output formats
		- Allow subject, predicate and object expressions to begin with either "/" or "(".
		  Only in the former case $currentResource/$externalResource is prefixed.
   !!!
:)

(: ########## PROLOGUE ############################################################################# :)

import module namespace functx  = "http://www.functx.com";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace config  = "http://xtriples.spatialhumanities.de/config" at "modules/config.xqm";

(: ### SVSAL modules and namespaces ### :)
declare namespace http		  = "http://expath.org/ns/http-client";
declare namespace httpclient	= "http://exist-db.org/xquery/httpclient";
declare namespace request	   = "http://exist-db.org/xquery/request";
declare namespace response	  = "http://exist-db.org/xquery/response";
declare namespace xmldb		 = "http://exist-db.org/xquery/xmldb";
declare namespace util		  = "http://exist-db.org/xquery/util";
declare namespace sm			= "http://exist-db.org/xquery/securitymanager";
declare namespace transform	 = "http://exist-db.org/xquery/transform";
declare namespace sal		   = "http://salamanca.adwmainz.de";
(: ### End SVSAL modules and namespaces ### :)

declare namespace xtriples = "http://xtriples.spatialhumanities.de/";

declare variable $setConfiguration  := xtriples:getConfiguration();
declare variable $setFormat         := xtriples:getFormat();
declare variable $retrievedDocuments := map { };

(: ########## SVSAL FUNCTIONS ###################################################################### :)

(:
	better: build it as we go... in
		- xtriples:expressionBasedAttributeResolver
		- xtriples:extractSubjects
		- xtriples:extractPredicate
		- xtriples:extractObjects
			if (contains($finalExpression/$subjectExpression/$predicateExpression/$objectExpression, 'doc(')) then
					let $tempURI := util:eval(matches($expression, "doc\(.*\)"))
					return replace($expression, "doc\(.*\)", cachedDoc($tempURI))
				)

	in
		- xtriples:expressionBasedUriResolver:
			- make it return a doc, not a string
			- if uri then
				if not cached then
				else 
		- declare function cachedDoc($URI as xs:string, externalDocuments as map(*)) as xs:document {
			return  if (not($externalDocuments(hash($URI)))) then
						let $exDoc := if (doc-available($URI)) then doc($URI) else ""
						let $externalDocuments := map:entry(hash($URI), $exDoc)
						return $exDoc
					else $externalDocuments(hash($URI)) 
		  };
:)
declare variable $tmp-collection-path := $config:app-root || '/temp/cache';

(:~
 : Get resources from the web by PND and store the result in a cache object with the current date. 
 : If the date does match with today's date then the result will be taken from the cache; otherwise the external resource will be queried.
 :
 : @author Peter Stadler 
 : @param $resource the external resource (wikipedia|adb|dnb|beacon)
 : @param $gnd the PND number
 : @param $lang the language variable (de|en). If no language is specified, the default (German) resource is grabbed and served
 : @param $useCache use cached version or force a reload of the external resource
 : @return node
 :)
declare function local:grabExternalDoc($uri as xs:string) as node()? {  (: as element(httpclient:response)? :) 
	let $lease	  := 
		try	 { 'P1D' cast as xs:dayTimeDuration }
		catch * { xs:dayTimeDuration('P1D'),
				  local:logToFile('error',
								  string-join(('xtriples:grabExternalDoc', $err:code, $err:description, 'lease-duration is not of type xs:dayTimeDuration'), ' ;; ')
								 )
				}
	let $url       := $uri
(:		switch($resource)
		case 'wikipedia' return replace(wega-util:beacon-map($gnd, $docType)('wikipedia')[1], 'dewiki', $lang || 'wiki')
		case 'dnb' return concat(config:get-option($resource), $gnd, '/about/rdf')
		default return doc($resource)
:)
	let $fileName  := encode-for-uri($uri)
	let $today     := current-date()

    let $debug1 :=  local:log (
							"extract.xql: local:grabExternalDoc: retrieve $url=" ||
							$url  ||
							", save as $retrievedDocuments(" ||
							$url ||
							").",
							"trace"
						  )

	let $response   := local:cache-doc($url, local:http-get#1, xs:anyURI($url), $lease)
	return 
        if ($response//httpclient:response/@statusCode eq '200') then
            let $debug2 :=  local:log (
							"extract.xql: local:grabExternalDoc: got a (successfully cached) doc: " ||
							substring(serialize($response), 1, 400) ||
							"...",
							"trace"
						  )

            return $response//httpclient:response/httpclient:body/*[1]
        else ()
};

(:~
 : A caching function for documents (XML and binary)
 :
 : @author Peter Stadler
 : @param $docURI the database URI of the document
 : @param $callBack a function to create the document content when the document is outdated or not available
 : @param $lease an xs:dayTimeDuration value of how long the cache should persist, e.g. P999D (= 999 days)
 : @return the cached document
 :)
declare function local:cache-doc($docURI as xs:string, $callback as function() as item(), $callback-params as item()*, $lease as xs:dayTimeDuration?) {

    let $currentDateTimeOfFile :=
            if ($retrievedDocuments($docURI)) then
            let $debug1 :=  local:log (
							"extract.xql: local:cache-doc: Cache date of " ||
							$docURI  ||
							" is " || xs:dateTime($retrievedDocuments($docURI)("date")),
							"trace"
						  )
                return xs:dateTime($retrievedDocuments($docURI)("date"))
            else ()

	let $updateNecessary := 
	   (: Aktualisierung entweder bei geänderter Datenbank oder bei veraltetem Cache :) 
	   (: config:eXistDbWasUpdatedAfterwards($currentDateTimeOfFile) or :)
        if (($currentDateTimeOfFile + $lease) lt current-dateTime()) then
            let $debug1 :=  local:log (
							"extract.xql: local:cache-doc: cache too old (" ||
							$currentDateTimeOfFile  ||
							" vs current-dateTime = " ||
                         current-dateTime() || ").",
							"trace"
						  )
            return true() 
	   (: oder bei nicht vorhandener Datei oder nicht vorhandenem $lease:)
		else if (empty($currentDateTimeOfFile)) then
            let $debug1 :=  local:log (
							"extract.xql: local:cache-doc: empty $currentDateTimeOfFile.",
							"trace"
						  )
            return true()
        else false()

	return
	   if($updateNecessary) then (

            let $debug1 :=  local:log (
							"extract.xql: local:cache-doc: need to update cached version of " ||
							$docURI  ||
							", calling callback ...",
							"trace"
						  )

			 let $content	:= 
					 if (count($callback-params) eq 0) then $callback()
				else if (count($callback-params) eq 1) then $callback($callback-params)
				else if (count($callback-params) eq 3) then $callback($callback-params[1], $callback-params[2], $callback-params[3])
				else if (count($callback-params) eq 2) then $callback($callback-params[1], $callback-params[2])
				else										error(xs:QName('sal:error'), 'Too many arguments to function callback')

            let $mime-type  := if      ($content//httpclient:header[@name="Content-Type"]/@value) then
                                        $content//httpclient:header[@name="Content-Type"]/@value[1]
                               else if ($content//httpclient:body/@mimetype) then
                                        $content//httpclient:body/@mimetype[1]
                               else
                                        local:guess-mimeType-from-suffix(functx:substring-after-last($docURI, '.'))[1]
            
            let $retrievedDocuments := map:put($retrievedDocuments, $docURI, map { "date" : current-dateTime(), "data" : $content })
(:            let $debug1 := console:log($retrievedDocuments):)
            let $logMessage := concat('xtriples:cache-doc(): remembered document ', $docURI)
            let $logToFile  := local:logToFile('info', $logMessage)
            let $debug1 :=  local:log (
							"extract.xql: local:cache-doc: remembered document " ||
							$docURI  ||
							", with date " || $retrievedDocuments($docURI)("date") || ": " ||
                         serialize($retrievedDocuments($docURI)),
							"trace"
						  )

			return $retrievedDocuments($docURI)("data")
        )
        else if (not(empty($retrievedDocuments($docURI)))) then
(:		 else if (util:binary-doc-available($docURI)) then:)
            let $debug2 :=  local:log (
							"extract.xql: local:cache-doc: no need to update, delivering $docURI=" ||
							$docURI  ||
							".",
							"trace"
						  )
			return $retrievedDocuments($docURI)("data")
		else ()
};

(:~
 : Helper function for local:grabExternalDoc()
 :
 : @author Peter Stadler 
 : @param $url the URL as xs:anyURI
 : @return element wega:externalResource, a wrapper around httpclient:response
 :)
declare function local:http-get($url as xs:anyURI) as element(xtriples:externalDoc) {

let $debug1 :=  local:log (
							"extract.xql: local:http-get: retrieving $url=" ||
							$url  ||
							"...",
							"trace"
						  )

(:	let $req		:= <http:request href="{$url}" method="get" timeout="60"><http:header name="Connection" value="close"/></http:request>:)
(:	let $req		:= <http:request xmlns="http://expath.org/ns/http-client" href="{$url}" method="GET" timeout="60"></http:request>:)
	let $response   := 
(:		try	 { http:send-request($req) }:)
		try	 { httpclient:get($url,true(), <headers/>) }
		catch * {
let $debug2 :=  local:log (
							"extract.xql: local:http-get: error retrieving $url=" ||
							$url ||
							", " ||
							$err:code ||
							$err:description ||
							".",
							"error"
						  )

					return local:logToFile('warn', string-join(('xtriples:http-get', $err:code, $err:description, 'URL: ' || $url), ' ;; '))
				}
   (:let $response := 
		if($response/httpclient:body[matches(@mimetype,"text/html")]) then wega:changeNamespace($response,'http://www.w3.org/1999/xhtml', 'http://exist-db.org/xquery/httpclient')
		else $response:)
(:	let $statusCode := $response[1]/data(@status):)
	let $statusCode := $response[1]/@statusCode

let $debug2 :=  local:log (
							"extract.xql: local:http-get: response status=" ||
							$statusCode ||
							", count($response)=" ||
							count($response) ||
							", response[1]=" ||
							substring(serialize($response[1]), 1, 1200) ||
							"..." ||
							", response[2]=" ||
							substring(serialize($response[2]), 1, 400) ||
							"...",
							"trace"
						  )

	return
		<xtriples:externalDoc date="{current-date()}">
			<httpclient:response statusCode="{$statusCode}">
				<httpclient:headers>{
					for $header in $response[1]/http:header
					return element httpclient:header {$header/@*}
				}</httpclient:headers>
				<httpclient:body mimetype="{$response[1]/httpclient:body/@mimetype}">
					{$response[1]/httpclient:body/*}
				</httpclient:body>
			</httpclient:response>
		</xtriples:externalDoc>
};

(:~
 : Helper function for guessing a mime-type from a file extension
 : (Should be expanded to read in $exist.home$/mime-types.xml)
 :
 : @author Peter Stadler 
 : @param $suffix the file extension
 : @return the mime-type
 :)
declare function local:guess-mimeType-from-suffix($suffix as xs:string) as xs:string? {
	switch($suffix)
		case 'xml'  return 'application/xml'
		case 'jpg'  return 'image/jpeg'
		case 'png'  return 'image/png'
		case 'txt'  return 'text/plain'
		case 'rdf'  return 'application/rdf+xml'
		case 'json' return 'application/text+json'
		default	 return error(xs:QName('sal:error'), 'unknown file suffix "' || $suffix || '"')
};

(:~
 : Store some XML content as file in the db
 : (shortcut for the more generic 4arity version)
 : 
 : @author Peter Stadler
 : @param $collection the collection to put the file in. If empty, the content will be stored in tmp  
 : @param $fileName the filename of the to be created resource with filename extension
 : @param $contents the content to store. Must be a node 
 : @return Returns the path to the newly created resource, empty sequence otherwise
 :)
declare function local:store-file($collection as xs:string?, $fileName as xs:string, $contents as item()) as xs:string? {
	local:store-file($collection, $fileName, $contents, 'application/xml')
};

(:~
 : Store some content as file in the db
 : (helper function for local:grabExternalDoc())
 : 
 : @author Peter Stadler
 : @param $collection the collection to put the file in. If empty, the content will be stored in tmp  
 : @param $fileName the filename of the to be created resource with filename extension
 : @param $contents the content to store. Either a node, an xs:string, a Java file object or an xs:anyURI 
 : @return Returns the path to the newly created resource, empty sequence otherwise
 :)
declare function local:store-file($collection as xs:string?, $fileName as xs:string, $contents as item(), $mime-type as xs:string) as xs:string? {
	let $collection := 
		if (empty($collection) or ($collection eq '')) then $tmp-collection-path
		else $collection
    let $login := xmldb:login($collection, "sal", "DSvS:EdQueWij-pS")
    let $createCollection := 
		for $coll in tokenize($collection, '/')
			let $parentColl := substring-before($collection, $coll)
			return 
				if (xmldb:collection-available($parentColl || '/' || $coll)) then ''
				else
					if (sm:has-access($parentColl, 'rwx')) then
						xmldb:create-collection($parentColl, $coll)
					else ''
	let $result :=
		try	 {
				  if (sm:has-access($collection, 'rwx')) then

                    let $debug1 :=  local:log (
							"extract.xql:storeFile storing " ||
							$mime-type ||
							": " ||
							substring(serialize($contents), 1, 4000) ||
							" ... at " ||
							$collection || "/" || $fileName ||
							".",
							"trace"
						)

                     return try {
(:						      xmldb:store($collection, $fileName, item { $contents//httpclient:response/httpclient:body/*[1] , $mime-type):)
						      xmldb:store($collection, $fileName, $contents , $mime-type)
                     }
                     catch * {
                           let $debug3 :=  local:log (
                            							"extract.xql:storeFile error: " ||
                            							$err:code ||
                            							$err:description ||
                            							".",
                            							"trace"
                            						  )
            				  return local:logToFile('error', string-join(('local:store-file', $err:code, $err:description), ' ;; '))
                     }

(:						return xmldb:store($collection, $fileName, $contents, $mime-type):)
				  else
                     let $debug2 :=  local:log (
                        						"extract.xql:storeFile error: insufficient privileges.",
                        						"trace"
                        					  )
					   return ""
				}
		catch * {
                let $debug3 :=  local:log (
                							"extract.xql:storeFile error: " ||
                							$err:code ||
                							$err:description ||
                							".",
                							"trace"
                						  )
				  return local:logToFile('error', string-join(('local:store-file', $err:code, $err:description), ' ;; '))
				}

let $debug4 := for $file at $index in $result
					return local:log (
							"extract.xql:storeFile[" || $index || "]: " ||
							$result[$index] ||
							". Stored content=" ||
							substring(serialize(doc($result[$index])), 1, 4000) ||
							"...",
							"trace"
						  )

	return $result
};

declare function local:log($message as xs:string, $priority as xs:string?) {
	let $prio := if ($priority) then $priority else "trace"
	return try  {
					let $consoleOutput :=   if ($config:debug = "trace" or $prio = ("info", "warn", "error")) then
												console:log($message)
											else ()
					let $fileOutput	:= local:logToFile($prio, $message)
					return true()
				}
			catch *
				{
					($err:code, $err:description)
				}
};

(:~
 : Write log message to log file
 :
 : @author Peter Stadler
 : @param $priority to be used by util:log-app:  'error', 'warn', 'debug', 'info', 'trace'
 : @param $message to write
 : @return 
:)
declare function local:logToFile($priority as xs:string, $message as xs:string) {
	let $file	:= $config:logfile
(:  let $message := concat($message, ' (rev. ', config:getCurrentSvnRev(), ')') :)
	return  (
				let $log := util:log-app($priority, $file, $message)
				return if ($config:debug = "trace" or $priority = ('error', 'warn')) then
					util:log-system-out($message)
				else ()
			)
};



(: ########## CONFIGURATION FUNCTIONS ############################################################## :)



(: retrieves the XTriples configuration from GET or POST :)
declare function xtriples:getConfiguration() {

	(: checks GET/POST for a configuration sent with the configuration parameter :)
	let $submittedConfiguration := request:get-parameter("configuration", "")
	(: checks the request body for a configuration :)
	let $submittedConfigurationPOSTBody := request:get-data()

	let $setConfiguration :=
		(: case 1 - URI to a configuration file was sent - GET request :)
		if (substring($submittedConfiguration, 1, 4) = "http") then 
			fn:doc(xs:anyURI($submittedConfiguration))
		(: case 2 - nothing submitted with a configuration parameter, use request body - direct POST request :)
		else if ($submittedConfiguration = "") then
			if ($submittedConfigurationPOSTBody) then
				$submittedConfigurationPOSTBody
			(: if no configuration could be retrieved to this point use a standard config that issues an error :)
			else
				fn:doc("configuration.xml")
		(: case 3 - full configuration sent with the configuration parameter - form style POST request :)
		else util:parse($submittedConfiguration)

	return $setConfiguration
};

(: gets and sets the return format :)
declare function xtriples:getFormat() {

	let $HEADER := request:get-header("format")
	let $GET := request:get-parameter("format", "rdf")
	let $setFormat :=
		if ($HEADER != "") then $HEADER
		else $GET

	return $setFormat
};



(: ########## SANITIZATION FUNCTIONS ################################################################ :)



(: safety filter for XPATH/XQuery expressions - dissallows executions from dangerous/not needed function namespaces :)
declare function xtriples:expressionSanityCheck($expression as xs:string) as xs:boolean {

(:  let $pattern := "((fn:.*\(.*\))|(doc*\(.*\))|(collection*\(.*\))|(v:.*\(.*\))|(backups:.*\(.*\))|(compression:.*\(.*\))|(contentextraction:.*\(.*\))|(counter:.*\(.*\))|(cqlparser:.*\(.*\))|(datetime:.*\(.*\))|(examples:.*\(.*\))|(exi:.*\(.*\))|(file:.*\(.*\))|(httpclient:.*\(.*\))|(image:.*\(.*\))|(inspection:.*\(.*\))|(jindi:.*\(.*\))|(kwic:.*\(.*\))|(lucene:.*\(.*\))|(mail:.*\(.*\))|(math:.*\(.*\))|(ngram:.*\(.*\))|(repo:.*\(.*\))|(request:.*\(.*\))|(response:.*\(.*\))|(scheduler:.*\(.*\))|(securitymanager:.*\(.*\))|(sequences:.*\(.*\))|(session:.*\(.*\))|(sort:.*\(.*\))|(sql:.*\(.*\))|(system:.*\(.*\))|(testing:.*\(.*\))|(text:.*\(.*\))|(transform:.*\(.*\))|(util:.*\(.*\))|(validation:.*\(.*\))|(xmldb:.*\(.*\))|(xmldiff:.*\(.*\))|(xqdoc:.*\(.*\))|(xslfo:.*\(.*\))|(config:.*\(.*\))|(docbook:.*\(.*\))|(app:.*\(.*\))|(dash:.*\(.*\))|(service:.*\(.*\))|(login-helper:.*\(.*\))|(packages:.*\(.*\))|(service:.*\(.*\))|(usermanager:.*\(.*\))|(demo:.*\(.*\))|(cex:.*\(.*\))|(ex:.*\(.*\))|(apputil:.*\(.*\))|(site:.*\(.*\))|(pretty:.*\(.*\))|(date:.*\(.*\))|(tei2:.*\(.*\))|(dbutil:.*\(.*\))|(docs:.*\(.*\))|(dq:.*\(.*\))|(review:.*\(.*\))|(epub:.*\(.*\))|(l18n:.*\(.*\))|(intl:.*\(.*\))|(restxq:.*\(.*\))|(tmpl:.*\(.*\))|(templates:.*\(.*\))|(trigger:.*\(.*\))|(jsjson:.*\(.*\))|(xqdoc:.*\(.*\)))":)
	let $pattern := "((fn:.*\(.*\))|(collection*\(.*\))|(v:.*\(.*\))|(backups:.*\(.*\))|(compression:.*\(.*\))|(contentextraction:.*\(.*\))|(counter:.*\(.*\))|(cqlparser:.*\(.*\))|(datetime:.*\(.*\))|(examples:.*\(.*\))|(exi:.*\(.*\))|(file:.*\(.*\))|(httpclient:.*\(.*\))|(image:.*\(.*\))|(inspection:.*\(.*\))|(jindi:.*\(.*\))|(kwic:.*\(.*\))|(lucene:.*\(.*\))|(mail:.*\(.*\))|(math:.*\(.*\))|(ngram:.*\(.*\))|(repo:.*\(.*\))|(request:.*\(.*\))|(response:.*\(.*\))|(scheduler:.*\(.*\))|(securitymanager:.*\(.*\))|(sequences:.*\(.*\))|(session:.*\(.*\))|(sort:.*\(.*\))|(sql:.*\(.*\))|(system:.*\(.*\))|(testing:.*\(.*\))|(text:.*\(.*\))|(transform:.*\(.*\))|(util:.*\(.*\))|(validation:.*\(.*\))|(xmldb:.*\(.*\))|(xmldiff:.*\(.*\))|(xqdoc:.*\(.*\))|(xslfo:.*\(.*\))|(config:.*\(.*\))|(docbook:.*\(.*\))|(app:.*\(.*\))|(dash:.*\(.*\))|(service:.*\(.*\))|(login-helper:.*\(.*\))|(packages:.*\(.*\))|(service:.*\(.*\))|(usermanager:.*\(.*\))|(demo:.*\(.*\))|(cex:.*\(.*\))|(ex:.*\(.*\))|(apputil:.*\(.*\))|(site:.*\(.*\))|(pretty:.*\(.*\))|(date:.*\(.*\))|(tei2:.*\(.*\))|(dbutil:.*\(.*\))|(docs:.*\(.*\))|(dq:.*\(.*\))|(review:.*\(.*\))|(epub:.*\(.*\))|(l18n:.*\(.*\))|(intl:.*\(.*\))|(restxq:.*\(.*\))|(tmpl:.*\(.*\))|(templates:.*\(.*\))|(trigger:.*\(.*\))|(jsjson:.*\(.*\))|(xqdoc:.*\(.*\)))"
	let $check := matches($expression, $pattern)

	return (not($check))
};



(: ########## EXPRESSION EVALUATION FUNCTIONS ######################################################## :)



(: evaluates expressions in curly braces within URI strings :)
declare function xtriples:expressionBasedUriResolver($uri as xs:string, $currentResource as node(), $repeatIndex as xs:integer) as xs:string {

	let $expression := concat('$currentResource', substring-after(substring-before($uri, "}"), "{"))
	let $finalExpression := 
		if (matches($expression, "\$repeatIndex")) then replace($expression, "\$repeatIndex", $repeatIndex) 
		else $expression

	let $reallyFinalExpression :=   if (contains($finalExpression, "doc('http")) then

let $debug1 :=  local:log (
							"extract.xql: xtriples:expressionBasedUriResolver: to be replaced: $finalExpression=" ||
							$finalExpression  ||
							", $reallyFinalExpression=" ||
							replace(
								$finalExpression,
								"(fn:)?doc\(",
								"local:grabExternalDoc("
							) ||
							".",
							"trace"
						  )

										return replace($finalExpression, "(fn:)?doc\(", "local:grabExternalDoc(")
									else
										$finalExpression
let $debug2 :=  if ($reallyFinalExpression ne $finalExpression) then local:log (
							"extract.xql: xtriples:expressionBasedUriResolver: $finalExpression=" ||
							$finalExpression  ||
							", $reallyFinalExpression=" ||
							$reallyFinalExpression  ||
							".",
							"trace"
						  )
				else ()

	let $result := 
		if (xtriples:expressionSanityCheck($reallyFinalExpression) = true()) then
			try { 
				util:eval($reallyFinalExpression) 
			} catch * { $err:description } 
		else ""

	let $uriWithSubstitution := if ($result) then replace($uri, "\{.*\}", $result) else ""

	return $uriWithSubstitution
}; 

(: evaluates expressions in curly braces within attribute values (prepend, append, repeat) :)
declare function xtriples:expressionBasedAttributeResolver($currentResource as node(), $attributeValue as xs:string*, $repeatIndex as xs:integer, $resourceIndex as xs:integer) as xs:string* {

	let $expression := substring-after(substring-before($attributeValue, "}"), "{")
	let $expressionSubstitution := 
		if (matches($expression, "\$resourceIndex")) then replace($expression, "\$resourceIndex", $resourceIndex) 
		else $expression
	let $finalExpression := 
		if (matches($expressionSubstitution, "\$repeatIndex")) then replace($expressionSubstitution, "\$repeatIndex", $repeatIndex) 
		else $expressionSubstitution

	let $reallyFinalExpression :=   replace($finalExpression, "(^|\W)(fn:)?doc\(", "$1local:grabExternalDoc(")
    let $debug1 :=  if ($reallyFinalExpression ne $finalExpression) then local:log (
							"extract.xql: xtriples:expressionBasedAttributeResolver: $finalExpression=" ||
							$finalExpression  ||
							", $reallyFinalExpression=" ||
							$reallyFinalExpression  ||
							".",
							"trace"
						  )
				else ()


	let $result := 
		if ($reallyFinalExpression and xtriples:expressionSanityCheck($reallyFinalExpression)) then 
			try {
				replace($attributeValue, "\{.*\}", util:eval(concat("$currentResource", $reallyFinalExpression))) 
			} catch * { $err:description }
		else $attributeValue

	return $result
};

(: evaluates expressions in curly braces within a document string and retrieves the document :)
declare function xtriples:expressionBasedResourceResolver($collection as node()*, $resource as node()*) as item()* {

	let $collectionContent := if (fn:doc-available($collection/@uri)) then fn:doc($collection/@uri) else ""

	let $resourcesURI          := string($resource/@uri)
	let $resourcesExpression   := concat('$collectionContent', substring-after(substring-before($resourcesURI, "}"), "{"))
	let $resourcesNodes        := if (xtriples:expressionSanityCheck($resourcesExpression) = true()) then 
		try { util:eval($resourcesExpression) } catch * { $err:description } 
		else $resourcesExpression

	let $resources := 
		for $resource at $index in $resourcesNodes
			return 
				if ($resource instance of element()) then
					$resource
				else
					element {"resource"} {
						attribute {"uri"} {replace($resourcesURI, "\{.*\}", $resource)}
					}
	return $resources
};



(: ########## RESOURCE / COLLECTION FUNCTIONS ############################################################# :)



(: gets all resources for a collection, possibly expression based :)
declare function xtriples:getResources($collection as node()*) as item()* {

	let $resources := 
		for $resource in $collection/resource
		return
			if (matches($resource/@uri, "\{.*\}")) then 
				xtriples:expressionBasedResourceResolver($collection, $resource)
			else $resource

	return $resources
};



(: ########## EXTRACTION FUNCTIONS ######################################################################### :)



(:
Separate relatively similar functions are used for subject, predicate and object extraction.
This keeps the query simpler even if it repeats some code. At the same time it opens up the possibility 
to treat statement part extractions different in future versions (as it is already the case with subject/object 
vs predicate extraction routines.
:)

(: extracts subject statements from the current resource :)
declare function xtriples:extractSubjects($currentResource as node(), $statement as node()*, $repeatIndex as xs:integer, $resourceIndex as xs:integer) as item()* {

	let $externalResource := 
		if (exists($statement/subject/@resource)) then
			if (starts-with($statement/subject/@resource, "http")) then
				local:grabExternalDoc(xtriples:expressionBasedUriResolver($statement/subject/@resource, $currentResource, $repeatIndex))
			else if (fn:doc-available(xtriples:expressionBasedUriResolver($statement/subject/@resource, $currentResource, $repeatIndex))) then 
				fn:doc(xtriples:expressionBasedUriResolver($statement/subject/@resource, $currentResource, $repeatIndex)) 
			else ""
		else ""

let $debug1 :=  if ($statement/subject/@resource) then 
					local:log (
								"extract.xql" ||
								(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                            (if ($statement/subject/@debug) then " (This statement is configured to be debugged with a $statement/subject/@debug attribute)" else "") ||
								": xtriples:extractSubjects: external resource: '" ||
								$statement/subject/@resource/string() ||
								"' gives " ||
								count($externalResource) ||
								" node(s): " ||
								substring(serialize($externalResource), 1, 100) ||
								"...",
								(if ($statement/subject/@debug) then "info" else "trace")
							  )
				else ()

	let $subjectExpressionConcatenation := 
	   if (starts-with(string($statement/subject), '/') and $externalResource) then
			concat("$externalResource", string($statement/subject))
	   else if (starts-with(string($statement/subject), '/')) then
			concat("$currentResource", string($statement/subject))
	   else
		   string($statement/subject)

	let $subjectExpression := 
		if (matches($subjectExpressionConcatenation, "\$repeatIndex")) then
			replace($subjectExpressionConcatenation, "\$repeatIndex", $repeatIndex)
		else
			$subjectExpressionConcatenation

           let $debug2 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/subject/@debug) then " (This statement is configured to be debugged with a $statement/subject/@debug attribute)" else "") ||
							": xtriples:extractSubjects: before util:eval('" ||
							$subjectExpression ||
							"') ...",
							(if ($statement/subject/@debug) then "info" else "trace")
						  )

	let $subjectNodes :=	if (xtriples:expressionSanityCheck($subjectExpression)) then 
								try {
										util:eval($subjectExpression)
									}
								catch * { $err:description } 
							else $subjectExpression

    let $debug3 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/subject/@debug) then " (This statement is configured to be debugged with a $statement/subject/@debug attribute)" else "") ||
							": xtriples:extractSubjects: ... evaluated to " ||
							count($subjectNodes) ||
							" subjects.",
							(if ($statement/subject/@debug) then "info" else "trace")
						  )

	let $subjects := 
		for $subjectValue in $subjectNodes
		return functx:copy-attributes(<subject>{string($subjectValue)}</subject>, $statement/subject)

	return $subjects
};

(: extracts predicate statements from the current resource :)
declare function xtriples:extractPredicate($currentResource as node(), $statement as node()*, $repeatIndex as xs:integer, $resourceIndex as xs:integer) as item()* {

	let $externalResource := 
		if (exists($statement/predicate/@resource)) then
			if (starts-with($statement/predicate/@resource, "http")) then
				local:grabExternalDoc(xtriples:expressionBasedUriResolver($statement/predicate/@resource, $currentResource, $repeatIndex))
			else if (fn:doc-available(xtriples:expressionBasedUriResolver($statement/predicate/@resource, $currentResource, $repeatIndex))) then 
				fn:doc(xtriples:expressionBasedUriResolver($statement/predicate/@resource, $currentResource, $repeatIndex)) 
			else ""
		else ""

    let $debug1 :=  if ($statement/predicate/@resource) then 
					local:log (
								"extract.xql" ||
								(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                             (if ($statement/predicate/@debug) then " (This statement is configured to be debugged with a $statement/predicate/@debug attribute)" else "") ||
								": xtriples:extractPredicate: external resource: '" ||
								$statement/predicate/@resource/string() ||
								"' gives " ||
								count($externalResource) ||
								" node(s): " ||
								substring(serialize($externalResource), 1, 100) ||
								"...",
								(if ($statement/predicate/@debug) then "info" else "trace")
							  )
				else ()

	let $predicateExpressionConcatenation := 
	   if (starts-with(string($statement/predicate), '/') and $externalResource) then
			concat("$externalResource", string($statement/predicate))
	   else if (starts-with(string($statement/predicate), '/')) then
			concat("$currentResource", string($statement/predicate))
	   else
		   string($statement/predicate)

	let $predicateExpression := 
		if (matches($predicateExpressionConcatenation, "\$repeatIndex")) then
			replace($predicateExpressionConcatenation, "\$repeatIndex", $repeatIndex)
		else
			$predicateExpressionConcatenation

    let $debug2 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/predicate/@debug) then " (This statement is configured to be debugged with a $statement/predicate/@debug attribute)" else "") ||
							": xtriples:extractPredicate: before util:eval('" ||
							$predicateExpression ||
							"') ...",
							(if ($statement/predicate/@debug) then "info" else "trace")
						  )

	let $predicateValue := if (xtriples:expressionSanityCheck($predicateExpression)) then 
		                      try { string(util:eval($predicateExpression)) } catch * { $err:description } 
    		                else $predicateExpression

    let $debug3 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/predicate/@debug) then " (This statement is configured to be debugged with a $statement/predicate/@debug attribute)" else "") ||
							": xtriples:extractPredicate: ... evaluated to '" ||
							$predicateValue ||
							"'.",
							(if ($statement/predicate/@debug) then "info" else "trace")
						  )

	let $predicate := <predicate prefix="{$statement/predicate/@prefix}">{string($predicateValue)}</predicate>

	return $predicate
};

(: extracts object statements from the current resource :)
declare function xtriples:extractObjects($currentResource as node(), $statement as node()*, $repeatIndex as xs:integer, $resourceIndex as xs:integer) as item()* {

	let $externalResource := 
		if ($statement/object/@resource) then
			if (starts-with($statement/object/@resource, "http")) then
				local:grabExternalDoc(xtriples:expressionBasedUriResolver($statement/object/@resource, $currentResource, $repeatIndex))
			else if (fn:doc-available(xtriples:expressionBasedUriResolver($statement/object/@resource, $currentResource, $repeatIndex))) then 
				fn:doc(xtriples:expressionBasedUriResolver($statement/object/@resource, $currentResource, $repeatIndex)) 
			else ()
		else ()

    let $debug1 :=  if ($statement/object/@resource) then 
					local:log (
								"extract.xql" ||
								(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                             (if ($statement/object/@debug) then " (This statement is configured to be debugged with a $statement/object/@debug attribute)" else "") ||
								": xtriples:extractObjects: external resource: '" ||
								$statement/object/@resource/string() ||
								"' gives " ||
								count($externalResource) ||
								" node(s): " ||
								substring(serialize($externalResource), 1, 100) ||
								"...",
								(if ($statement/object/@debug) then "info" else "trace")
							  )
				else ()

	let $objectExpressionConcatenation := 
	   if (starts-with(string($statement/object), '/') and $externalResource) then
			concat("$externalResource", string($statement/object))
	   else if (starts-with(string($statement/object), '/')) then
			concat("$currentResource", string($statement/object))
	   else
		   string($statement/object)

	let $objectExpression := replace($objectExpressionConcatenation, "\$repeatIndex", $repeatIndex)

    let $debug2 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/object/@debug) then " (This statement is configured to be debugged with a $statement/object/@debug attribute)" else "") ||
							": xtriples:extractObjects: before util:eval('" ||
							$objectExpression ||
							"') ...",
							(if ($statement/object/@debug) then "info" else "trace")
						  )

	let $objectNodes := if (xtriples:expressionSanityCheck($objectExpression)) then 
							try { 
									util:eval($objectExpression)
								}
							catch * { $err:description }
						else $objectExpression

    let $debug3 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/object/@debug) then " (This statement is configured to be debugged with a $statement/object/@debug attribute)" else "") ||
							": xtriples:extractObjects: ... evaluated to " ||
							count($objectNodes) ||
							" objects.",
							(if ($statement/object/@debug) then "info" else "trace")
						  )

	let $objects :=
		for $objectValue in $objectNodes
		  return functx:copy-attributes(<object>{string($objectValue)}</object>, $statement/object)

	return $objects
};

(: XTriples core function - evaluates all configured statements for the current resource :)
declare function xtriples:extractTriples($currentResource as node(), $resourceIndex as xs:integer, $configuration as node()*) as item()* {

	(: set the content of the current resource :)
	let $currentResource := 
		(: it can be a resource tag with an URI :)
		if (xs:anyURI($currentResource/@uri) and fn:doc-available($currentResource/@uri)) then 
			local:grabExternalDoc($currentResource/@uri)
		(: or a resource tag with children :)
		else if ($currentResource/*) then 
			$currentResource/*
		else fn:doc("errors.xml")//error[@type='resource_no_content']

	(: start statement pattern extraction :)
	for $statement in $configuration//triples/*

		let $repeat := 
			if ($statement/@repeat) then
				xs:integer(xtriples:expressionBasedAttributeResolver($currentResource, $statement/@repeat, 1, $resourceIndex))
			else 1

    let $debug1 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, ')') else ()) ||
                         (if ($statement/@debug) then " (This statement is configured to be debugged with a $statement/@debug attribute)" else "") ||
							": xtriples:extractTriples $repeat=" ||
							$repeat ||
							".",
							(if ($statement/@debug) then "info" else "trace")
						  )

		for $repeatIndex in (1 to $repeat)

			(: if a condition expression is given in the current statement, evaluate it :)
			let $condition := 
				if (exists($statement/condition)) then 
					if (xtriples:expressionSanityCheck(string($statement/condition)) = true()) then
						try { util:eval(concat('$currentResource', string($statement/condition))) } catch * { $err:description }
					else true()
				else true()

			(: n possible subjects per statement declaration :)
			let $subjects := 
				if (substring($statement/subject, 1, 1) = ('/', '(')) then 
					xtriples:extractSubjects($currentResource, $statement, $repeatIndex, $resourceIndex)
				else $statement/subject

			(: 1 predicate per statement declaration :)
			let $predicate := 
				if (substring($statement/predicate, 1, 1) = ('/', '(')) then 
					xtriples:extractPredicate($currentResource, $statement, $repeatIndex, $resourceIndex) 
				else <predicate prefix="{$statement/predicate/@prefix}">{string($statement/predicate)}</predicate>

			(: n possible objects per statement declaration :)
			let $objects := 
				if (substring($statement/object, 1, 1) = ('/', '(')) then
					xtriples:extractObjects($currentResource, $statement, $repeatIndex, $resourceIndex)
				else $statement/object

            let $debug2 :=  local:log (
							"extract.xql" ||
							(if ($statement/@n) then concat(' (', $statement/@n, '/', $repeatIndex, ')') else ()) ||
                         (if ($statement/@debug) then " (This statement is configured to be debugged with a $statement/@debug attribute)" else "") ||
							": xtriples:extractTriples has " ||
							count($subjects) ||
							" subjects, predicate " ||
							string($predicate) ||
							" and " ||
							count($objects) ||
							" objects.",
							(if ($statement/@debug) then "info" else "trace")
						  )


			(: build statements - but only if the condition expression returned any value - boolean, string, node set etc. :)
			let $statements := 
				if ($condition) then 
					for $subject in $subjects
						let $subjectReturn :=
							for $object in $objects

								let $subjectPrepend := xtriples:expressionBasedAttributeResolver($currentResource, $subject/@prepend, $repeatIndex, $resourceIndex)
								let $subjectAppend  := xtriples:expressionBasedAttributeResolver($currentResource, $subject/@append, $repeatIndex, $resourceIndex)

								let $predicatePrepend := xtriples:expressionBasedAttributeResolver($currentResource, $predicate/@prepend, $repeatIndex, $resourceIndex)
								let $predicateAppend  := xtriples:expressionBasedAttributeResolver($currentResource, $predicate/@append, $repeatIndex, $resourceIndex)

								let $objectPrepend := xtriples:expressionBasedAttributeResolver($currentResource, $object/@prepend, $repeatIndex, $resourceIndex)
								let $objectAppend  := xtriples:expressionBasedAttributeResolver($currentResource, $object/@append, $repeatIndex, $resourceIndex)

								let $objectReturn := 
									if ($object = "") then "<>" 
									else <statement>{(
										functx:remove-attributes(functx:copy-attributes(<subject>{concat($subjectPrepend, $subject, $subjectAppend)}</subject>, $subject), ('append', 'prepend')),
										functx:remove-attributes(functx:copy-attributes(<predicate>{concat($predicatePrepend, $predicate, $predicateAppend)}</predicate>, $predicate), ('append', 'prepend')),
										functx:remove-attributes(functx:copy-attributes(<object>{concat($objectPrepend, $object, $objectAppend)}</object>, $object), ('append', 'prepend'))
									)}</statement>
							return $objectReturn
					return $subjectReturn
				else ""

	return $statements
};



(: ########## FORMAT FUNCTIONS #################################################################################### :)



(: internal/intermediate XTriples RDF format, one RDF node per XTriples statement - will later be condensed by the any23 webservice to "real" RDF :)
declare function xtriples:generateRDFTriples($xtriples as node()*) as item()* {

	for $statement in $xtriples//statements/statement

		let $subjectType := $statement/subject/@type
		let $subjectPrefix := $statement/subject/@prefix
		let $subjectUri := $xtriples//vocabularies/vocabulary[@prefix=$subjectPrefix]/@uri
		let $subjectValue := $statement/subject

		let $predicatePrefix := $statement/predicate/@prefix
		let $predicateUri := $xtriples//vocabularies/vocabulary[@prefix=$predicatePrefix]/@uri
		let $predicateValue := $statement/predicate

		let $objectType := $statement/object/@type
		let $objectPrefix := $statement/object/@prefix
		let $objectUri := $xtriples//vocabularies/vocabulary[@prefix=$objectPrefix]/@uri
		let $objectValue := $statement/object/text()

		(: rdf triple construction using computed constructors with qualified names; builds single rdf triples which are later combined by any23 webservice :)
		let $triple := 
			(: outer RDF tag :)
			element {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:Description")} {
			(: either is a blank node, then gets rdf:nodeID attribute :)
			(if ($subjectType = 'bnode') then 
				attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:nodeID")} { $subjectValue }
			(: or is a URI, then gets rdf:about attribute :)
			else
				attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:about")} { concat($subjectUri, $subjectValue) }),
				(: predicate = inner element of the RDF tag :)
				element {QName($predicateUri, concat($predicatePrefix, ":", $predicateValue))} {
				(: object uri; set rdf:resource as attribute to predicate :)
				if ($objectType = 'uri') then 
					attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:resource")} { 
						if ($objectPrefix) then concat($objectUri, $objectValue) else $objectValue 
					}
				(: object blank node; set rdf:nodeIFD as attribute to predicate :)
				else if ($objectType = 'bnode') then
					attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:nodeID")} { $objectValue }
				(: typed object literals; append rdf:datatype as attribute and set value as text node :)
				else if ($statement/object/@datatype) then
					(attribute {QName("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:datatype")} { concat("http://www.w3.org/2001/XMLSchema#", $statement/object/@datatype) }, $objectValue)
				(: language tagged object literals; append rdf:datatype as attribute and set value as text node :)
				else if ($statement/object/@lang) then
					(attribute {"xml:lang"} { $statement/object/@lang }, $objectValue)
				(: plain object literals; set value as text node :)
				else
					$objectValue
			}
		}

		return
			$triple
};

(: gets the internal RDF format :)
declare function xtriples:getRDFTriples($xtriples as node()*, $vocabularies as node()*) as item()* {
	let $rdfTriples := <rdftriples>{$vocabularies}{xtriples:generateRDFTriples($xtriples)}</rdftriples>
	return $rdfTriples
};

(: gets the internal RDF format and sends it to any23 for further transformation :)
declare function xtriples:getRDF($xtriples as node()*, $vocabularies as node()*) as item()* {
	(: internal RDF format :)
    let $rdfstylesheet := doc("rdf.xsl")
    let $rdfTriples    := xtriples:getRDFTriples($xtriples, $vocabularies)
    let $rdfInternal   := transform:transform($rdfTriples, $rdfstylesheet, ())

    (: official RDF format via any23 :)
    let $headers := <headers><header name="Content-Type" value="application/rdf+xml; charset=UTF-8"/></headers>

    let $POST_request := httpclient:post(xs:anyURI(concat($config:any23WebserviceURL, "rdfxml")), $rdfInternal, false(), $headers)
    let $rdfBad := $POST_request//httpclient:body/*

	(: clean self-references broken by any23 service :)
    let $parameters    := <parameters>
                            <param name="idServer"            value="{$config:idserver}"/>
                          </parameters>
	let $rdfstylesheet2 := doc("rdf-cleanSelfReferences.xsl")
	let $rdf := transform:transform($rdfBad, $rdfstylesheet2, $parameters)

	return $rdf
};

(: gets ntriples format from any23 by sending in extracted RDF :)
declare function xtriples:getNTRIPLES($rdf as node()*) as item()* {

	(: url encoded ntriples :)
	let $headers := <headers><header name="Content-Type" value="application/rdf+xml; charset=UTF-8"/></headers>
	let $POST_request := httpclient:post(xs:anyURI(concat($config:any23WebserviceURL, "nt")), $rdf, false(), $headers)
	let $ntriples := util:unescape-uri(replace(string($POST_request//httpclient:body), '%00', ''), "UTF-8")

	return replace($ntriples, 'http://any23.org/tmp/', '')
};

(: gets turtle format from any23 by sending in extracted RDF :)
declare function xtriples:getTURTLE($rdf as node()*) as item()* {

	(: eXist returns base64Binary turtle :)
	let $headers := <headers><header name="Content-Type" value="application/rdf+xml; charset=UTF-8"/></headers>
	let $POST_request := httpclient:post(xs:anyURI(concat($config:any23WebserviceURL, "turtle")), $rdf, false(), $headers)
	let $turtle := util:binary-to-string(xs:base64Binary($POST_request//httpclient:body), "UTF-8")

	return replace($turtle, 'http://any23.org/tmp/', '')
};

(: gets nquads format from any23 by sending in extracted RDF :)
declare function xtriples:getNQUADS($rdf as node()*) as item()* {

	(: eXist returns base64Binary nquads :)
	let $headers := <headers><header name="Content-Type" value="application/rdf+xml; charset=UTF-8"/></headers>
	let $POST_request := httpclient:post(xs:anyURI(concat($config:any23WebserviceURL, "nq")), $rdf, false(), $headers)
	let $nquads := util:binary-to-string(xs:base64Binary($POST_request//httpclient:body), "UTF-8")

	return replace($nquads, 'http://any23.org/tmp/', '')
};

(: gets json format from any23 by sending in extracted RDF :)
declare function xtriples:getJSON($rdf as node()*) as item()* {

	(: eXist returns base64Binary json :)
	let $headers := <headers><header name="Content-Type" value="application/rdf+xml; charset=UTF-8"/></headers>
	let $POST_request := httpclient:post(xs:anyURI(concat($config:any23WebserviceURL, "json")), $rdf, false(), $headers)
	let $json := util:binary-to-string(xs:base64Binary($POST_request//httpclient:body), "UTF-8")

	return replace($json, 'http://any23.org/tmp/', '')
};

(: gets trix format from any23 by sending in extracted RDF :)
declare function xtriples:getTRIX($rdf as node()*) as item()* {

	(: eXist returns base64Binary json :)
	let $headers := <headers><header name="Content-Type" value="application/rdf+xml; charset=UTF-8"/></headers>
	let $POST_request := httpclient:post(xs:anyURI(concat($config:any23WebserviceURL, "trix")), $rdf, false(), $headers)
	let $trix := $POST_request//httpclient:body/*

	return replace($trix, 'http://any23.org/tmp/', '')
};

(: gets svg format from rhizomik webservice by temporarily storing the extracted RDF and pointing the redefer to the temporary file :)
declare function xtriples:getSVG($rdf as node()*) as item()* {

	(: svg format with temporary file :)
	let $filename := concat(util:uuid(), ".xml")
	let $store := xmldb:store($config:app-root || "/temp/", $filename, $rdf)
	let $svgHeaders := 
		<headers>
			<header name="format" value="RDF/XML"/>
			<header name="mode" value="svg" />
			<headers name="rules" value="{$config:redeferWebserviceRulesURL}" />
		</headers>
	
	let $GET_request := httpclient:get(xs:anyURI(concat($config:redeferWebserviceURL, "render?rdf=", $config:xtriplesWebserviceURL, "temp/", $filename, "&amp;format=RDF/XML&amp;mode=svg&amp;rules=", $config:redeferWebserviceRulesURL)), false(), $svgHeaders)
	let $svg := $GET_request//httpclient:body/*
	let $delete := xmldb:remove("/db/apps/xtriples/temp/", $filename)

	return $svg
};



(: ########## MAIN QUERY BODY ############################################################################################### :)



(: set basic vars :)
let $collections := $setConfiguration/xtriples/collection
let $configuration := $setConfiguration/xtriples/configuration
let $vocabularies := $configuration/vocabularies

(: dynamic namespace declaration for all configured vocabularies :)
let $namespaces := 
	if ($configuration/vocabularies/*) then
		for $namespace in $configuration/vocabularies/*
		return util:declare-namespace($namespace/@prefix, $namespace/@uri)
	else ""

(: extract triples from collections :)
let $extraction := 

	for $collection in $collections

		let $maxResources :=
			if ($collection/@max > 0) then
				$collection/@max
			else 0

		let $resources := xtriples:getResources($collection)

		let $triples :=
			for $resource at $resourceIndex in $resources
				let $currentResource :=
					if (name($resource) = 'resource') then
						$resource
					else <resource>{$resource}</resource>
			return
				if ($maxResources > 0 and $resourceIndex <= $maxResources) 
				then
					<statements>{xtriples:extractTriples($currentResource, $resourceIndex, $configuration)}</statements>
				else if ($maxResources = 0)
				then
					<statements>{xtriples:extractTriples($currentResource, $resourceIndex, $configuration)}</statements>
				else ""

	return <result>{(functx:copy-attributes(<collection>{$resources}</collection>, $collection),<triples>{$triples}</triples>)}</result>

(: construct internal result format :)
let $xtriples := 
	<xtriples>
		<configuration>
			{$vocabularies}
			<triples>{$extraction//triples/*}</triples>
		</configuration>
		{$extraction//collection}
	</xtriples>

(: transform and return result :)
return (
	if ($setFormat = "xtriples") then
		$xtriples
	else if ($setFormat = "rdftriples") then

       let $debug1 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return xtriples:getRDFTriples($xtriples, $vocabularies)
	else if ($setFormat = "ntriples") then (

       let $debug2 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return    response:set-header("Content-Type", "application/n-triples; charset=UTF-8"),
		          response:stream(xtriples:getNTRIPLES(xtriples:getRDF($xtriples, $vocabularies)), "method=text")
		)
	else if ($setFormat = "turtle") then (

       let $debug3 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return    response:set-header("Content-Type", "text/turtle; charset=UTF-8"),
		          response:stream(xtriples:getTURTLE(xtriples:getRDF($xtriples, $vocabularies)), "method=text")
		)
	else if ($setFormat = "nquads") then (

       let $debug4 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return    response:set-header("Content-Type", "application/n-quads; charset=UTF-8"),
                 response:stream(xtriples:getNQUADS(xtriples:getRDF($xtriples, $vocabularies)), "method=text")
		)
	else if ($setFormat = "json") then (

       let $debug5 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return    response:set-header("Content-Type", "application/json; charset=UTF-8"),
		          response:stream(xtriples:getJSON(xtriples:getRDF($xtriples, $vocabularies)), "method=text")
		)
	else if ($setFormat = "trix") then (

       let $debug6 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return    response:set-header("Content-Type", "application/trix; charset=UTF-8"),
		          xtriples:getTRIX(xtriples:getRDF($xtriples, $vocabularies))
		)
	else if ($setFormat = "svg") then
		(: response:set-header("Content-Type", "image/svg+xml; charset=UTF-8"), :)

       let $debug7 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )

		return    xtriples:getSVG(xtriples:getRDF($xtriples, $vocabularies))
	else 
       let $debug8 :=  local:log (
							"extract.xql: output in " || $setFormat  || ".",
							"trace"
						  )


		return    xtriples:getRDF($xtriples, $vocabularies)
)