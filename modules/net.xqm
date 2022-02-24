xquery version "3.1";


(: ####++++----

    General functions and variables for serving responses to web requests.

 ----++++#### :)


module namespace net                = "http://www.salamanca.school/xquery/net";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace functx      = "http://www.functx.com";
import module namespace hc          = "http://expath.org/ns/http-client";
import module namespace request     = "http://exist-db.org/xquery/request";
import module namespace response    = "http://exist-db.org/xquery/response";
import module namespace util        = "http://exist-db.org/xquery/util";

import module namespace config      = "http://www.salamanca.school/xquery/config"                 at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace export      = "http://www.salamanca.school/xquery/export"                 at "xmldb:exist:///db/apps/salamanca/modules/export.xqm";
import module namespace sutil    = "http://www.salamanca.school/xquery/sutil" at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";
import module namespace txt        = "https://www.salamanca.school/factory/works/txt" at "xmldb:exist:///db/apps/salamanca/modules/factory/works/txt.xqm";

declare       namespace exist       = "http://exist.sourceforge.net/NS/exist";
declare       namespace output      = "http://www.w3.org/2010/xslt-xquery-serialization";
declare       namespace rdf         = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare       namespace rdfs        = "http://www.w3.org/2000/01/rdf-schema#";
declare       namespace tei         = "http://www.tei-c.org/ns/1.0";
declare       namespace sal         = "http://salamanca.adwmainz.de";

declare variable $net:cache-control       := "no";

declare variable $net:forwardedForServername    := request:get-header('X-Forwarded-Host');
declare variable $net:servedContentTypes        := (
                                                    'application/tei+xml',
                                                    'application/xhtml+xml',
                                                    'application/rdf+xml',
                                                    'application/json',
                                                    'application/pdf',
                                                    'application/xml',
                                                    'application/zip',
                                                    'image/jpeg',
                                                    'image/png',
                                                    'image/tiff',
                                                    'text/html',
                                                    'text/plain',
                                                    'text/xml'
                                                    );
(:declare variable $net:requestedContentTypes     := tokenize(request:get-header('Accept'), '[,\s;]+');:)
declare variable $net:requestedContentTypes     := tokenize(request:get-header('Accept'), '[, ]+');

declare variable $net:errorhandler := 
    if (($config:instanceMode = "staging") or ($config:debug = "trace")) then ()
    else
        <error-handler>
            <forward url="{$config:app-root}/en/error-page.html" method="get"/>
            <forward url="{$config:app-root}/modules/view.xql"/>
        </error-handler>;


(: Todo: Clean lang parameters when they arrive. It's there but I'm not sure it's working... :)
declare function net:inject-requestParameter($injectParameter as xs:string*, $injectValue as xs:string*) as xs:string* {
    if (not($injectParameter)) then
        for $p in request:get-parameter-names() return
            if (not($p = "lang" and request:get-parameter($p, ()) = ('', 'de', 'en', 'es'))) then
                $p || "=" || request:get-parameter($p, ())
            else ()
    else
        let $preliminaryList := for $p in request:get-parameter-names() return
                                    if ($p = $injectParameter and not($injectParameter = 'lang')) then
                                        $injectParameter || "=" || $injectValue
                                    else if (not($p = "lang" and request:get-parameter($p, ()) = ('', 'de', 'en', 'es'))) then
                                        $p || "=" || request:get-parameter($p, ())
                                    else ()
        return if (not($injectParameter || "=" || $injectValue = $preliminaryList)) then
                    (if (not($injectParameter = 'lang')) then $injectParameter || "=" || $injectValue else (), $preliminaryList)
               else
                    $preliminaryList
};


(: Set language for the connection ... :)
declare function net:lang($existPath as xs:string) as xs:string {
    (:  Priorities: 1. ?lang
                    2. /lang/
                    3. Browser setting/Accept-Language
                    4. default language
        We refrain from using session attributes (hard to track, hard to change, cf. https://discuss.neos.io/t/how-to-implement-automatic-language-detection/416/6)
    :)
                    if (request:get-parameter-names() = 'lang') then
                        if (request:get-parameter('lang', 'dummy-default-value') = ('de', 'en', 'es')) then
(:                            let $debug :=  if ($config:debug = "trace") then console:log("case 1a: lang parameter-name and valid value present.") else ():)
                            request:get-parameter('lang', 'dummy-default-value')
                        else
                            let $debug :=  if ($config:debug = "trace") then console:log("case 1b: lang parameter-name but invalid value present.") else ()
                            return if (matches($existPath, '/(de|en|es)/')) then
                                        if (contains($existPath, '/de/')) then
(:                                            let $debug :=  if ($config:debug = "trace") then console:log("case 2a: 'de' path component present.") else ():)
                                            'de'
                                        else if (contains($existPath, '/en/')) then
(:                                            let $debug :=  if ($config:debug = "trace") then console:log("case 2b: 'en' path component present.") else ():)
                                            'en'
                                        else
(:                                            let $debug :=  if ($config:debug = "trace") then console:log("case 2c: 'es' path component present.") else ():)
                                            'es'
                                    else if (request:get-header('Accept-Language')) then
                                            if (substring(request:get-header('lang'),1,2) = 'de') then
(:                                                let $debug := if ($config:debug = "trace") then console:log("case 3a: 'de' Accept-Language request header present.") else ():)
                                                'de'
                                            else if (substring(request:get-header('lang'),1,2) = 'en') then
(:                                                let $debug := if ($config:debug = "trace") then console:log("case 3b: 'en' Accept-Language request header present.") else ():)
                                                'en'
                                            else if (substring(request:get-header('lang'),1,2) = 'es') then
(:                                                let $debug := if ($config:debug = "trace") then console:log("case 3c: 'es' Accept-Language request header present.") else ():)
                                                'es'
                                            else
(:                                                let $debug := if ($config:debug = "trace") then console:log("case 3d: unknown Accept-Language request header present.") else ():)
                                                $config:defaultLang
                                    else
(:                                        let $debug := if ($config:debug = "trace") then console:log("case 4: Language could not be detected. Using default language (" || $config:defaultLang || ").") else ():)
                                        $config:defaultLang

                    else if (matches($existPath, '/(de|en|es)/')) then
                        if (contains($existPath, '/de/')) then
(:                            let $debug :=  if ($config:debug = "trace") then console:log("case 2a: 'de' path component present.") else ():)
                            'de'
                        else if (contains($existPath, '/en/')) then
(:                            let $debug :=  if ($config:debug = "trace") then console:log("case 2b: 'en' path component present.") else ():)
                            'en'
                        else
(:                            let $debug :=  if ($config:debug = "trace") then console:log("case 2c: 'es' path component present.") else ():)
                            'es'
                    else if (request:get-header('Accept-Language')) then
                            if (substring(request:get-header('Accept-Language'),1,2) = 'de') then
(:                                let $debug := if ($config:debug = "trace") then console:log("case 3a: 'de' Accept-Language request header present.") else ():)
                                'de'
                            else if (substring(request:get-header('Accept-Language'),1,2) = 'en') then
(:                                let $debug := if ($config:debug = "trace") then console:log("case 3b: 'en' Accept-Language request header present.") else ():)
                                'en'
                            else if (substring(request:get-header('Accept-Language'),1,2) = 'es') then
(:                                let $debug := if ($config:debug = "trace") then console:log("case 3c: 'es' Accept-Language request header present.") else ():)
                                'es'
                            else
(:                                let $debug := if ($config:debug = "trace") then console:log("case 3d: unknown Accept-Language request header (" || request:get-header('Accept-Language') || ") present.") else ():)
                                $config:defaultLang
                    else
(:                        let $debug := if ($config:debug = "trace") then console:log("case 4: Language could not be detected. Using default language (" || $config:defaultLang || ").") else ():)
                        $config:defaultLang
};

(: For determining the content type, the format url parameter has the highest priority,
   only then comes content negotiation based on HTTP Accept Header (and we do not use file extensions).
   If no (valid) format is given, the format resolves to 'html' :)
declare function net:format() as xs:string {
    if (lower-case(request:get-parameter("format", "")) = map:keys($config:apiFormats)) then 
        let $debug := if ($config:debug = ('trace', 'info')) then console:log('Format requested by parameter: format=' || lower-case(request:get-parameter("format", "")) || '.') else ()
        return lower-case(request:get-parameter("format", ""))
    else 
        let $contentType := net:negotiateContentType($net:servedContentTypes, 'text/html')
        let $debug := if ($config:debug = ('trace')) then console:log('Format determined by content type "' || $contentType || '".') else ()
        return switch ($contentType)
            case 'application/tei+xml'
            case 'application/xml'
            case 'text/xml'            return 'tei'
            case 'text/plain'          return 'txt'
            case 'application/rdf+xml' return 'rdf'
            case 'image/jpeg'          return 'jpg' (: better 'img', for keeping it more generic ? :)
            case 'application/ld+json' return 'iiif'
            default                    return 'html'
};


(: Diverse redirection/forwarding functions ... :)
(:  Approach based on Joe Wicentowski's suggestion of handling redirection in separate queries
    (and much else in local convenience functions). However, the main code below does not (yet)
    use these convenience functions to the fullest possible extent. (That's a todo.) :)
(: declare function net:redirectResponse(){
    let $path               := request:get-parameter('path', '')
    let $status             := request:get-parameter('statusCode', 303)
    return
        (
            response:set-status-code($status), response:set-header('Location', $path)
        )
};
:)
declare function net:redirect-with-301($absolute-path) {  (: Moved permanently :)
    (response:set-status-code(301), response:set-header('Location', $absolute-path))
};
declare function net:redirect-with-307($absolute-path) {  (: Temporary redirect :)
    (response:set-status-code(307), response:set-header('Location', $absolute-path), text {''})
};
declare function net:redirect-with-303($absolute-path) {  (: See other :)
    (response:set-status-code(303), response:set-header('Location', $absolute-path), text {''})
};
declare function net:redirect-with-404($absolute-path) {  (: 404 :)
    (response:set-status-code(404), 
    <error-handler> 
        <forward url="{$config:app-root}/error-page.html" method="get"/>
        <forward url="{$config:app-root}/modules/view.xql"/>
    </error-handler>)
};

(:
Generates an HTML error response by setting a $statusCode and forwarding to an error page.
If $errorType is one of: 
 - 'work-not-yet-available',
 - 'author-not-yet-available',
 - 'lemma-not-yet-available',
 - 'workingpaper-not-yet-available',
 an appropriate error message shall be displayed (downstream) to the user.
:)
declare function net:error($statusCode as xs:integer, $netVars as map(*), $errorType as xs:string?) {
    response:set-status-code($statusCode),
    net:error-page($statusCode, $netVars, $errorType)
};

declare function net:error-page($statusCode as xs:integer, $netVars as map(*), $errorType as xs:string?) as element(exist:dispatch) {
    (: using just the error-handler for simply triggering an application-side error page does not work here as expected 
       but instead creates a *server-side* error, so that we rather dispatch/forward to the error page for now (but how to get the error message then?) :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$netVars('controller') || '/error-page.html'}"/>
        <view>
            <forward url="{$netVars('controller')}/modules/view-error.xql">
                <set-attribute name="lang"             value="{$netVars('lang')}"/>
                <set-attribute name="exist:resource"   value="{$netVars('resource')}"/>
                <set-attribute name="exist:prefix"     value="{$netVars('prefix')}"/>
                <set-attribute name="exist:controller" value="{$netVars('controller')}"/>
                <set-attribute name="status-code"      value="{xs:string($statusCode)}"/>
                <set-attribute name="error-type"      value="{$errorType}"/>
                <cache-control cache="{$net:cache-control}"/>
            </forward>
        </view>
    </dispatch>
    (: 
    <error-handler> 
            <forward url="{$netVars('controller')}/error-page.html" method="get">
                <set-attribute name="status-code" value="{xs:string($statusCode)}"/>
            </forward>
            <forward url="{$netVars('controller')}/modules/view-error.xql">
                <set-attribute name="status-code" value="{xs:string($statusCode)}"/>
            </forward>
        </error-handler>
    :)
};


declare function net:redirect-with-400($absolute-path) {  (: 400 :)
    (response:set-status-code(400), 
    <error-handler>
        <forward url="{$config:app-root}/error-page.html" method="get"/>
        <forward url="{$config:app-root}/modules/view.xql"/>
    </error-handler>)
};
declare function net:add-parameter($name as xs:string, $value as xs:string) as element(exist:add-parameter) {
    <add-parameter xmlns="http://exist.sourceforge.net/NS/exist" name="{$name}" value="{$value}"/>
};
declare function net:forward($relative-path as xs:string, $netVars as map(*)) {
    net:forward($relative-path, $netVars, ())
};
declare function net:forward($relative-path as xs:string, $netVars as map(*), $attribs as element(exist:add-parameter)*) {
    let $absolute-path := concat($netVars('controller'), '/', $relative-path)
(:    let $absolute-path := concat($netVars('root'), $netVars('controller'), '/', $relative-path):)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path}">
                {$attribs}
            </forward>
            <cache-control cache="{$net:cache-control}"/>
            {$net:errorhandler}
        </dispatch>
};

(: kind of similar to net:forward, but with standard attribute settings and different view/path handling :)
declare function net:forward-to-html($relative-path as xs:string, $netVars as map(*)) {
    let $absolute-path := $netVars('controller') || $relative-path
(:    let $absolute-path := concat($netVars('root'), $netVars('controller'), '/', $relative-path):)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path}"/>
            <view>
                <forward url="{$netVars('controller')}/modules/view.xql">
                    <set-attribute name="lang"              value="{$netVars('lang')}"/>
                    <set-attribute name="$exist:resource"   value="{$netVars('resource')}"/>
                    <set-attribute name="$exist:prefix"     value="{$netVars('prefix')}"/>
                    <set-attribute name="$exist:controller" value="{$netVars('controller')}"/>
                </forward>
            </view>
            <cache-control cache="{$net:cache-control}"/>
            {config:errorhandler($netVars)}
        </dispatch>
(:    {for $param in map:keys($netVars('paramap')) return 
           <add-parameter xmlns="http://exist.sourceforge.net/NS/exist" name="{$param}" value="{$netVars('paramap')?($param)}"/>}    :)
};

declare function net:forward-to-webdata($relative-path as xs:string, $netVars as map(*), $attribs as element(exist:add-parameter)*) {
    let $absolute-path := concat($netVars('controller'), '/../salamanca-webdata/', $relative-path)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path}" absolute="no">
                {$attribs}
            </forward>
            <cache-control cache="{$net:cache-control}"/>
            {$net:errorhandler}
        </dispatch>
    };
declare function net:forward-to-tei($relative-path as xs:string, $netVars as map(*), $attribs as element(exist:add-parameter)*) {
    let $absolute-path := concat($netVars('controller'), '/../salamanca-tei/', $relative-path)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path}" absolute="no">
                {$attribs}
            </forward>
            <cache-control cache="{$net:cache-control}"/>
            {$net:errorhandler}
        </dispatch>
    };
declare function net:redirect($absolute-path as xs:string, $netVars as map(*)) { (: implicit temporary redirect (302) :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$absolute-path}"/>
        <cache-control cache="{$net:cache-control}"/>
        {$net:errorhandler}
    </dispatch>
};
declare function net:ignore() {
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="{$net:cache-control}"/>
    </ignore>
};



(: Content negotiation ... :)
(: From https://github.com/golang/gddo/blob/master/httputil/negotiate.go :)
(: NegotiateContentType returns the best offered content type for the request's
   Accept header. If two offers match with equal weight, then the more specific
   offer is preferred.  For example, text/* trumps */*. If two offers match
   with equal weight and specificity, then the offer earlier in the list is
   preferred. If no offers match, then defaultOffer is returned. :)
(: This is Golang: 

func NegotiateContentType(r *http.Request, offers []string, defaultOffer string) string {
	bestOffer  := defaultOffer
	bestQ      := -1.0
	bestWild   := 3
	specs      := header.ParseAccept(r.Header, "Accept")
	for _, offer := range offers {
		for _, spec := range specs {
			switch {
			case spec.Q == 0.0:
				// ignore
			case spec.Q < bestQ:
				// better match found
			case spec.Value == "*/*":
				if spec.Q > bestQ || bestWild > 2 {
					bestQ = spec.Q
					bestWild = 2
					bestOffer = offer
				}
			case strings.HasSuffix(spec.Value, "/*"):
				if strings.HasPrefix(offer, spec.Value[:len(spec.Value)-1]) &&
					(spec.Q > bestQ || bestWild > 1) {
					bestQ = spec.Q
					bestWild = 1
					bestOffer = offer
				}
			default:
				if spec.Value == offer &&
					(spec.Q > bestQ || bestWild > 0) {
					bestQ = spec.Q
					bestWild = 0
					bestOffer = offer
				}
			}
		}
	}
	return bestOffer
}:)

declare function net:negotiateContentType($offers as xs:string*, $defaultOffer as xs:string) as xs:string {
    let $bestOffer      := $defaultOffer
    let $bestQ          := -1.0
    let $bestWild       := 3
    let $returnOffer    := local:negotiateCTSub($offers, $bestOffer, $bestQ, $bestWild)
    return $returnOffer
};

declare function local:negotiateCTSub($offers as xs:string*, $bestOffer as xs:string, $bestQ as xs:double, $bestWild as xs:integer) as xs:string {
    let $offer      := $offers[1]
(:let $debug      := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. -- Current offer type: " || $offer || ".") else ():)
(:    let $newOffer   := for $spec in tokenize(replace(request:get-header('Accept'), ' ', ''), ','):)
    let $newOffer   := for $spec in $net:requestedContentTypes
(:let $debug := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. ---- Current accepted type: " || $spec || ".") else ():)
        let $Q      :=  
            if (string(number(substring-after($spec, ';q='))) != 'NaN') then
                number(substring-after($spec, ';q='))
            else 1.0 
        let $value  := normalize-space(tokenize($spec, ';')[1])
        return
            if ($Q lt $bestQ) then ()           (: previous match had stronger weight :)
            else   if (starts-with($spec, '*/*')) then                 (: least specific - let $bestWild := 2  :)
                if ($bestWild gt 2) then
                    let $newBestWild   := 2
                    let $newBestQ      := $Q
                    let $newBestOffer  := $offer
                    return ($newBestOffer, $newBestQ, $newBestWild)
                else ()
            else   if (ends-with($value, '/*')) then                   (: medium specific - let $bestWild := 1  :)
                if (substring-before($offer, '/') = substring($value, 1, string-length($value) - 2) and $bestWild gt 1) then
                    let $newBestWild   := 1
                    let $newBestQ      := $Q
                    let $newBestOffer  := $offer
                    return ($newBestOffer, $newBestQ, $newBestWild)
                else ()
            else
                if ($offer = $value and ($Q gt $bestQ or $bestWild gt 0)) then    (: perfectly specific match - let $bestWild := 0 :)
                    let $newBestWild   := 0
                    let $newBestQ      := $Q
                    let $newBestOffer  := $offer
(:let $debug := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. ---- NewOffer: " || $newBestOffer || ',' || $newBestQ || ',' || $newBestWild || ".") else ():)
                    return ($newBestOffer, $newBestQ, $newBestWild)
                else ()
    let $returnOffer  :=  
        if (count($offers) gt 1) then
            if ($newOffer[1]) then
                local:negotiateCTSub(subsequence($offers, 2), $newOffer[1], $newOffer[2], $newOffer[3])
            else
                local:negotiateCTSub(subsequence($offers, 2), $bestOffer, $bestQ, $bestWild)
        else
            if ($newOffer[1]) then $newOffer[1] else $bestOffer
    return $returnOffer
};



(: Interact with caddy server :)
declare function net:getRoutingTable() {
    fn:json-doc($config:caddyRoutes)
};

declare function net:deleteRoutingTable() as xs:boolean {
    let $request    := <hc:request method="delete" http-version="1.0"></hc:request>
    let $resp       := hc:send-request($request, $config:caddyRoutes)
    let $debug      := if ($resp/@status ne "200") then console:log("[ADMIN] WARNING proplematic caddy response (when trying to delete routing table): " || fn:serialize($resp) ) else ()
    return if ($resp/@status eq "200") then true() else false()
};

declare function net:postRoutingTable($routes as array(*)) as xs:boolean {
    if (array:size($routes) = 0) then
        true()
    else
        let $request    := 
            <hc:request method="post" http-version="1.0">
                <hc:body method="text" media-type="application/json"></hc:body>
            </hc:request>
    
        let $resp       := hc:send-request($request, $config:caddyRoutes || "/...", fn:serialize($routes, map{"method":"json", "indent": true(), "encoding":"utf-8"}))
        let $debug      := if ($resp/@status ne "200") then console:log("[ADMIN] WARNING proplematic caddy response (when trying to post to routing table): " || fn:serialize($resp, map{"method": "text"}) ) else ()
        return if ($resp/@status eq "200") then true() else false()
};

declare function net:cleanRoutingTable($wid as xs:string) as xs:boolean {
    let $routingTable   := net:getRoutingTable()
    let $cleanedRT      := array:filter($routingTable, function ($i) { substring($i?input, 0, 13) ne "/texts/" || $wid })
    let $deleteStatus   := net:deleteRoutingTable()
    return if (array:size($cleanedRT) > 0) then net:postRoutingTable($cleanedRT) else true()
};

declare function net:isInRoutingTable($src as xs:string, $dest as item()) as xs:boolean {
    let $routingTable := net:getRoutingTable()
    return if (count($routingTable) > 0 and array:size($routingTable) > 0) then
        array:size(array:filter($routingTable, function($m) {$m?input eq $src } )) > 0
    else
        false()
};



(: Sitemap stuff ... :)
declare function local:getDbDocumentIds($collections as xs:string*) as xs:string* {
    for $collection in $collections
        let $collType := switch ($collection)
                            case 'authors'          return 'author_article'
                            case 'lemmata'          return 'lemma_article'
(:                            case 'news'             return local:blogEntries():)
                            case 'workingPapers'    return 'working_paper'
                            case 'works'            return ("work_multivolume", "work_monograph")
                            case 'workDetails'      return ("work_multivolume", "work_monograph")
                            default return ()
        return for $document in collection($config:tei-root)//tei:TEI[tei:text/@type = $collType]
                    return $document/@xml:id
};

declare function local:getDbWebpageRel($documentIds as xs:string*) as xs:string* {
(:    let $debug          := if ($config:debug = "trace") then console:log("Creating relative urls for " || string-join($documentIds, ', ') || ".") else ():)
    for $documentId in $documentIds
        let $viewports := switch (collection($config:tei-root)/tei:TEI[@xml:id=$documentId]/tei:text[1]/@type)
                            case 'author_article'   return 'author.html?aid='
                            case 'lemma_article'    return 'lemma.html?lid='
                            case 'working_paper'    return 'workingPaper.html?wpid='
                            case 'work_monograph'   return ('work.html?wid=', 'workDetails.html?wid=')
                            case 'work_multivolume' return ('work.html?wid=', 'workDetails.html?wid=')
                            default return ()
        for $viewport in $viewports
            return concat($viewport, $documentId)
};

declare function local:getDbWebpageAbs($documentIds as xs:string*, $language as xs:string) as xs:string* {
(:    let $debug          := if ($config:debug = "trace") then console:log("Creating absolute urls for " || string-join($documentIds, ', ') || ' (' || $language || ").") else ():)
    for $document in $documentIds
        return for $webpage in local:getDbWebpageRel($document)
            return concat($config:webserver, '/', $language, '/', $webpage)
};

declare function local:getUrlList($language as xs:string) as element(url)* {
    let $debug          := if ($config:debug = "trace") then console:log("Building list of urls for " || $language || "...") else ()
    for $id in  local:getDbDocumentIds($config:databaseEntries)
        return for $url in local:getDbWebpageAbs($id, $language)
                    return
                        <url xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{
                            element loc {$url}
                (:            if(exists($lastmod)) then element lastmod {$lastmod} else ():)
                        }</url>
}; 

declare function local:localizedSitemap($lang as xs:string) as element(urlset) {
    let $debug          := if ($config:debug = "trace") then console:log("Creating sitemap for " || $lang || "...") else ()
    return
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {for $pagename in $config:standardEntries return 
                <url>
                    <loc>{$config:webserver || '/' || $lang || '/' || $pagename || '.html'}</loc>
                </url>
            }
            {
                    local:getUrlList($lang)
            }
        </urlset>
};

declare function local:sitemapIndex($fileNames as xs:string*) as element(sitemapindex) {
    let $debug          := if ($config:debug = "trace") then console:log("Creating sitemapindex...") else ()
    return
        <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {for $fileName in $fileNames
                return  <sitemap>{
                            element loc {$config:webserver || '/' || $fileName}
    (:                        if(exists($lastmod)) then element lastmod {$lastmod} else ():)
                        }</sitemap>
            }
        </sitemapindex>
};

declare function net:sitemapResponse($netVars as map(*)) {
    let $resource           := $netVars('resource')
    let $language           := for $lang in $config:languages
                                    return if ($resource = concat('sitemap_', $lang, '.xml')) then $lang else () 
    let $properFileNames    :=  for $lang in $config:languages
                                    return concat('sitemap_', $lang, '.xml' (: , '.', $compression :) )
    let $ret := util:declare-option("exist:serialize", "method=xml media-type=application/xml indent=yes omit-xml-declaration=no encoding=utf-8")

    (:
        If the exact name of a sitemap was given in the request, return a "good" sitemap,
        otherwise return an index of actual sitemap files.
    :)
    return
        if($properFileNames = $resource) then
            let $sitemap := local:localizedSitemap($language) 
            let $debug   := if ($config:debug = ("info", "trace")) then console:log("Returning sitemap_" || $language || " with " || count($sitemap/*) || " entries ...") else ()
            return $sitemap
        else
            let $sitemapIndex := local:sitemapIndex($properFileNames) 
            let $debug   := if ($config:debug = ("info", "trace")) then console:log("Returning sitemapIndex with " || count($sitemapIndex/*) || " maps ...") else ()
            return $sitemapIndex
};


declare function net:deliverTextsHTML($netVars as map()*) {
    let $wid := sutil:normalizeId($netVars('paramap')?('wid'))
    let $validation := sutil:WRKvalidateId($wid)
(:    let $debug := if ($config:debug = "trace") then util:log("warn", "HTML request for work :" || $wid || " ; " || "validation result: " || string($validation)) else ():)
    return
        if ($validation eq 2) then (: full text available :)
            net:forward-to-html(substring($netVars('path'), 4), $netVars)
        else if ($validation eq 1) then 
            net:redirect-with-303($config:webserver || '/workDetails.html?wid=' || $wid) (: only work details available :)
        else if ($validation eq 0) then 
            net:error(404, $netVars, 'work-not-yet-available') (: work id is valid, but there are no data :)
        else 
            net:error(404, $netVars, '')
};

declare function net:deliverWorkDetailsHTML($netVars as map(*)) {
    let $wid := sutil:normalizeId($netVars('paramap')?('wid'))
    let $validation := sutil:WRKvalidateId($wid)
    return
        switch($validation)
            case 2
            case 1 return net:forward-to-html(substring($netVars('path'), 4), $netVars)
            case 0 return net:error(404, $netVars, 'work-not-yet-available')
            default return net:error(404, $netVars, ())
};

declare function net:deliverAuthorsHTML($netVars as map()*) {
    let $validation := sutil:AUTvalidateId($netVars('paramap')?('aid'))
    let $debug := util:log('warn', 'Author id validation: ' || string($validation) || ' ; aid=' || $netVars('paramap')?('aid'))
    return
        if ($validation eq 1) then () (: TODO author article is available :)
        else if ($validation eq 0) then net:error(404, $netVars, 'author-not-yet-available')
        else net:error(404, $netVars, ())
};

declare function net:deliverConceptsHTML($netVars as map()*) {
    let $validation := sutil:LEMvalidateId($netVars('paramap')?('lid'))
    return
        if ($validation eq 1) then () (: TODO dict. entry is available :)
        else if ($validation eq 0) then net:error(404, $netVars, 'lemma-not-yet-available')
        else net:error(404, $netVars, ())
};

declare function net:deliverWorkingPapersHTML($netVars as map()*) {
    let $validation := sutil:WPvalidateId($netVars('paramap')?('wpid'))
    return
        if ($validation eq 1) then net:forward-to-html(substring($netVars('path'), 4), $netVars)
        else if ($validation eq 0) then net:error(404, $netVars, 'workingpaper-not-yet-available')
        else net:error(404, $netVars, ())
};
