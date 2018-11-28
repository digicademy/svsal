xquery version "3.1";

module namespace net                = "http://salamanca/net";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace functx      = "http://www.functx.com";
import module namespace request     = "http://exist-db.org/xquery/request";
import module namespace response    = "http://exist-db.org/xquery/response";
import module namespace util        = "http://exist-db.org/xquery/util";
import module namespace config      = "http://salamanca/config"                 at "config.xqm";
import module namespace export      = "http://salamanca/export"                 at "export.xql";
import module namespace render      = "http://salamanca/render"                 at "render.xql";

declare       namespace exist       = "http://exist.sourceforge.net/NS/exist";
declare       namespace output      = "http://www.w3.org/2010/xslt-xquery-serialization";
declare       namespace rdf         = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare       namespace rdfs        = "http://www.w3.org/2000/01/rdf-schema#";
declare       namespace tei         = "http://www.tei-c.org/ns/1.0";
declare       namespace sal         = "http://salamanca.adwmainz.de";

declare variable $net:cache-control       := "no";

declare variable $net:forwardedForServername    := request:get-header('X-Forwarded-Host');
declare variable $net:servedContentTypes        := (
                                                    'text/html',
                                                    'text/plain',
                                                    'application/tei+xml',
                                                    'application/xhtml+xml',
                                                    'application/rdf+xml',
                                                    'application/json',
                                                    'application/pdf',
                                                    'image/jpeg',
                                                    'image/png',
                                                    'image/tiff'
                                                    );
(:declare variable $net:requestedContentTypes     := tokenize(request:get-header('Accept'), '[,\s;]+');:)
declare variable $net:requestedContentTypes     := tokenize(request:get-header('Accept'), '[, ]+');

declare variable $net:errorhandler := if (($config:instanceMode = "staging") or ($config:debug = "trace")) then ()
                       else
                            <error-handler>
                                <forward url="{$config:app-root}/en/error-page.html" method="get"/>
                                <forward url="{$config:app-root}/modules/view.xql"/>
                            </error-handler>;

declare function net:findNode($ctsId as xs:string?) {
    let $reqResource  := tokenize($ctsId, '/')[last()]
    let $reqWork      := tokenize(tokenize($reqResource, ':')[1], '\.')[1]   (: work:pass.age :)
    let $reqPassage   := tokenize($reqResource, ':')[2]
    let $nodeId       := if ($reqPassage) then
                            let $nodeIndex := doc($config:data-root || '/' || replace($reqWork, 'w0', 'W0') || '_nodeIndex.xml')
                            return $nodeIndex//sal:node[sal:citetrail eq $reqPassage][1]/@n[1]
                         else
                            "completeWork" 
    let $work         := util:expand(doc($config:tei-works-root || '/' || replace($reqWork, 'w0', 'W0') || '.xml')//tei:TEI)
    let $node         := $work//tei:*[@xml:id eq $nodeId]
    let $debug        := if ($config:debug = "trace") then console:log('findNode returns ' || count($node) || ' node(s): ' || $work/@xml:id || '//*[@xml:id=' || $nodeId || '] (cts/id was "' || $ctsId || '").') else ()
    return $node
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
    (response:set-status-code(307), response:set-header('Location', $absolute-path))
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
}
:)
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

                                let $Q      :=  if (string(number(substring-after($spec, ';q='))) != 'NaN') then
                                                    number(substring-after($spec, ';q='))
                                                else
                                                    1.0 
                                let $value  := if (contains($spec, ';')) then
                                                    substring-before($spec, ';')
                                               else
                                                    $spec
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
    let $returnOffer  :=  if (count($offers) gt 1) then
                                if ($newOffer[1]) then
                                    local:negotiateCTSub(subsequence($offers, 2), $newOffer[1], $newOffer[2], $newOffer[3])
                                else
                                    local:negotiateCTSub(subsequence($offers, 2), $bestOffer, $bestQ, $bestWild)
                          else
                                if ($newOffer[1]) then $newOffer[1] else $bestOffer
    return $returnOffer
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
(:        let $viewports := switch (doc($config:data-root || '/' || $documentId || '.xml')/tei:TEI/tei:text[1]/@type):)
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
(:    let $compression        :=  if(ends-with($resource, 'zip')) then 'zip' else $net:defaultCompression:)
    let $properFileNames    :=  for $lang in $config:languages
                                    return concat('sitemap_', $lang, '.xml' (: , '.', $compression :) )
    let $ret := util:declare-option("exist:serialize", "method=xml media-type=application/xml indent=yes omit-xml-declaration=no encoding=utf-8")

    (:
        If the exact name of a sitemap was given in the request, return a "good" sitemap,
        otherwise return an index of actual sitemap files.
    :)
    return
        if($properFileNames = $resource) then
    (:        response:stream-binary(local:getSetSitemap($resource), local:getMimeType($compression), $resource):)
            let $sitemap := local:localizedSitemap($language) 
            let $debug   := if ($config:debug = ("info", "trace")) then console:log("Returning sitemap_" || $language || " with " || count($sitemap/*) || " entries ...") else ()
            return $sitemap
        else
            let $sitemapIndex := local:sitemapIndex($properFileNames) 
            let $debug   := if ($config:debug = ("info", "trace")) then console:log("Returning sitemapIndex with " || count($sitemapIndex/*) || " maps ...") else ()
            return $sitemapIndex
};



(: Deliver data in one or another format ... :)
declare function net:deliverTEI($pathComponents as xs:string*, $netVars as map()* ) {
    (: Todo:
        - clean up work/passage identification
    :)
    let $reqResource    := $pathComponents[last()]
    return if (matches($reqResource, '[ALW]\d{4}\.xml')) then

        let $reqWork        := tokenize(tokenize($reqResource, ':')[1], '\.')[1]
        let $dummy          := (util:declare-option("output:method", "xml"),
                                util:declare-option("output:media-type", "application/tei+xml"),
                                util:declare-option("output:indent", "yes"),
                                util:declare-option("output:expand-xincludes", "yes")
                                )
        let $debug2         :=  if ($config:debug = "trace") then console:log("Serializing options: method:" || util:get-option('output:method') ||
                                                                                                 ', media-type:' || util:get-option('output:media-type') ||
                                                                                                 ', indent:'     || util:get-option('output:indent') ||
                                                                                                 ', expand-xi:'  || util:get-option('output:expand-xincludes') ||
                                                                                                 '.')
                                else ()
    
        let $doc            :=  if (doc-available($config:tei-works-root || '/' || replace($reqWork, "w0", "W0") || '.xml')) then
                                    let $dummy := response:set-header("Content-Disposition", 'attachment; filename="' || $reqResource || '.tei.xml"')
                                    return util:expand(doc($config:tei-works-root || '/' || replace($reqWork, "w0", "W0") || '.xml')/tei:TEI)

(:
Maybe use this, which is from #DG's controller logic (at tei.serverdomain) I think:
                                 let $docPath := for $subroot in $config:tei-sub-roots return 
                                     if (doc-available($subroot || '/' || $exist:resource)) then $subroot || '/' || $exist:resource else ()
                                 let $doc        := if (count($docPath) eq 1) then
                                                         let $unexpanded := doc($docPath)
                                                         let $expanded   := util:expand(doc($docPath)/tei:TEI)
                                                         return $expanded
[#AW]
:)

                                else
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$netVars('controller')}/error-page.html" method="get"/>
                                        <view>
                                            <forward url="/modules/view.xql">
                                                <set-attribute name="lang"              value="{$netVars('lang')}"/>
                                                <set-attribute name="$exist:resource"   value="{$netVars('resource')}"/>
                                                <set-attribute name="$exist:prefix"     value="{$netVars('prefix')}"/>
                                                <set-attribute name="$exist:controller" value="{$netVars('controller')}"/>
                                            </forward>
                                        </view>
                                        {config:errorhandler($netVars)}
                                    </dispatch>
        let $debug3         :=  if ($config:debug = "trace") then console:log("deliver doc: " || $reqResource || " -> " || $reqWork || '.xml' || ".")
                                else ()
        return
            $doc
    else if (matches($reqResource, 'W\d{4}(_Vol\d\d)?_teiHeader.xml')) then 
        let $workId := substring-before($reqResource, '_teiHeader.xml')
        return export:WRKteiHeader($workId, 'metadata')
    else if ($reqResource eq 'sal-tei-corpus.zip') then
        let $pathToZip := $config:files-root || '/sal-tei-corpus.zip'
        return if (util:binary-doc-available($pathToZip)) then response:stream-binary(util:binary-doc($pathToZip), 'application/octet-stream', 'sal-tei-corpus.zip') else ()
    else ()
};

declare function net:deliverTXT($pathComponents as xs:string*) {
    let $reqResource    := $pathComponents[last()]
    let $reqWork        := tokenize(tokenize($reqResource, ':')[1], '\.')[1]
    let $reqVersion     := if (tokenize(tokenize($reqResource, ':')[1], '\.')[2]) then tokenize(tokenize($reqResource, ':')[1], '\.')[2]
                           else "edit"
    let $node           := net:findNode($reqResource)
    let $dummy          := (util:declare-option("output:method", "text"),
                            util:declare-option("output:media-type", "text/plain"))
    let $debug2         := if ($config:debug = "trace") then console:log("Serializing options: method:" || util:get-option('output:method') ||
                                                                                        ', media-type:' || util:get-option('output:media-type') ||
                                                                                        '.') else ()
    let $dummy          := response:set-header("Content-Disposition", 'attachment; filename="' || replace($reqWork, 'w0', 'W0') || '.' || $reqVersion || '.txt"')
    return render:dispatch($node, $reqVersion)
};

declare function net:deliverIIIF($path as xs:string, $netVars) {
    let $reqResource    := tokenize(tokenize($path, '/iiif/')[last()], '/')[1]
    let $iiif-paras     := string-join(subsequence(tokenize(tokenize($path, '/iiif/')[last()], '/'), 2), '/')
    let $work           := tokenize(tokenize($reqResource, ':')[1], '\.')[1]   (: work[.edition]:pass.age :)
    let $passage        := tokenize($reqResource, ':')[2]
    let $entityPath     := concat($work, if ($passage) then concat('#', $passage) else ())
    let $debug2         := if ($config:debug = "trace") then console:log("Load metadata from " || $config:rdf-root || '/' || replace($work, 'w0', 'W0') || '.rdf' || " ...") else ()
    let $metadata       := doc($config:rdf-root || '/' || replace($work, 'w0', 'W0') || '.rdf')
    let $debug3         := if ($config:debug = "trace") then console:log("Retrieving $metadata//rdf:Description[@rdf:about = '" || replace($reqResource, 'w0', 'W0') || "']/rdfs:seeAlso/@rdf:resource/string()") else ()
    let $debug4         := if ($config:debug = "trace") then console:log("This gives " || count($metadata//rdf:Description[@rdf:about = replace($reqResource, 'w0', 'W0')]/rdfs:seeAlso/@rdf:resource) || " urls in total.") else ()

    let $images         := for $url in $metadata//rdf:Description[@rdf:about = replace($reqResource, 'w0', 'W0')]/rdfs:seeAlso/@rdf:resource/string()
                            where matches($url, "\.(jpg|jpeg|png|tif|tiff)$")
                            return $url
    let $debug5         := if ($config:debug = "trace") then console:log("Of these, " || count($images) || " are images.") else ()
    let $image          := $images[1]
    let $debug5         := if ($config:debug = "trace") then console:log("The target image being " || $image || ".") else ()
    let $prefix         := "facs." || $config:serverdomain || "/iiif/"
    let $filename       := tokenize($image, '/')[last()]
    let $debug          := if ($config:debug = ("trace")) then console:log("filename = " || $filename) else ()
    let $fullpathname   := if (matches($filename, '\-[A-Z]\-')) then
                                    concat(string-join((replace($work, 'w0', 'W0'), substring(string-join(functx:get-matches($filename, '-[A-Z]-'), ''), 2, 1), functx:substring-before-last($filename, '.')), '%C2%A7'), '/', $iiif-paras)
                            else
                                    concat(string-join((replace($work, 'w0', 'W0'), functx:substring-before-last($filename, '.')), '%C2%A7'), '/', $iiif-paras)

    let $resolvedURI    := concat($prefix, $fullpathname)
    let $debug5         := if ($config:debug = ("trace", "info")) then console:log("redirecting to " || $resolvedURI) else ()

    return net:redirect($resolvedURI, $netVars)
};

declare function net:deliverRDF($pathComponents as xs:string*, $netVars as map()*) {
    let $reqResource    := $pathComponents[last()]
    let $reqWork        := tokenize(tokenize($reqResource, ':')[1], '\.')[1]
    return  if (replace($reqWork, 'w0', 'W0') || '.rdf' = xmldb:get-child-resources($config:rdf-root) and not("nocache" = request:get-parameter-names())) then
                let $debug          := if ($config:debug = ("trace", "info")) then console:log("Loading " || replace($reqWork, 'w0', 'W0') || " ...") else ()
                let $dummy          := response:set-header("Content-Disposition", 'attachment; filename="' || replace($reqWork, 'w0', 'W0') || '.rdf.xml"')
                return doc( $config:rdf-root || '/' || replace($reqWork, 'w0', 'W0') || '.rdf')
            else
                let $debug          := if ($config:debug = ("trace", "info")) then console:log("Generating rdf for " || replace($reqWork, 'w0', 'W0') || " ...") else ()
                let $path           := '/services/lod/extract.xql'
                let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/xtriples/createConfig.xql?resourceId=' || replace($reqWork, 'w0', 'W0') || '&amp;format=' || $config:lodFormat}"/>,
                                        <exist:add-parameter name="format"          value="{$config:lodFormat}"/>)
                let $dummy          := response:set-header("Content-Disposition", 'attachment; filename="' || $reqWork || '.rdf.xml"')
                return net:forward($path, $netVars, $parameters)
};

declare function net:deliverHTML($pathComponents as xs:string*, $netVars as map()*) {
    let $reqResource  := $pathComponents[last()-1] || "/" || $pathComponents[last()]
    return if (starts-with(lower-case($reqResource), 'texts/w0') or starts-with(lower-case($reqResource), 'authors/a0')) then
        let $reqWork      := tokenize(tokenize(tokenize($reqResource, ':')[1], '/')[2], '\.')[1]
        let $reqVersion   := if (tokenize(tokenize($reqResource, ':')[1], '\.')[2]) then
                                tokenize(tokenize($reqResource, ':')[1], '\.')[2]
                             else
                                "edit"
        let $reqPassage   := tokenize($reqResource, ':')[2]
        let $debug2       := if ($config:debug = ("trace")) then console:log("Load metadata from " || $config:rdf-root || '/' || replace($reqWork, 'w0', 'W0') || '.rdf' || " ...") else ()
        let $metadata     := doc($config:rdf-root || '/' || replace($reqWork, 'w0', 'W0') || '.rdf')
        let $debug3       := if ($config:debug = ("trace")) then console:log("Retrieving $metadata//rdf:Description[@rdf:about eq '" || replace($reqResource, 'w0', 'W0') || "']/rdfs:seeAlso[1]/@rdf:resource[contains(., '.html')]") else ()
        let $resolvedPath := string(($metadata//rdf:Description[@rdf:about eq replace($reqResource, 'w0', 'W0')]/rdfs:seeAlso[1]/@rdf:resource[contains(., ".html")])[1])
        let $debug4       := if ($config:debug = ("trace")) then console:log("Found path: " || $resolvedPath || " ...") else ()

        (: The pathname that has been saved contains 0 or exactly one parameter for the target html fragment,
           but it may or may not contain a hash value. We have to mix in other parameters (mode, search expression or viewer state) before the hash. :)
        let $pathname     := if (contains($resolvedPath, '?')) then
                                substring-before($resolvedPath, '?')
                             else if (contains($resolvedPath, '#')) then
                                substring-before($resolvedPath, '#')
                             else
                                $resolvedPath
        let $hash         := if (contains($resolvedPath, '#')) then concat('#', substring-after($resolvedPath, '#')) else ()
        let $fragParam    := if (contains($resolvedPath, '?')) then
                                if (contains(substring-after($resolvedPath, '?'), '#')) then
                                    substring-before(substring-after($resolvedPath, '?'), '#')
                                else
                                    substring-after($resolvedPath, '?')
                             else ()
        let $updParams    := if ($reqVersion = "orig") then array:append($netVars('params'), "mode=orig") else $netVars('params')
        let $parameters   := concat(if ($fragParam or $updParams) then "?" else (), string-join(($fragParam, string-join($updParams, "&amp;")), "&amp;"))


        let $debug5       := if ($config:debug = ("trace", "info")) then console:log("Redirecting to " || $pathname || $parameters || $hash || " ...") else ()
        return net:redirect-with-303($pathname || $parameters || $hash )
     else
        let $debug2       := if ($config:debug = ("trace", "info")) then console:log("Html is acceptable, but bad input. Redirect (404) to error webpage ...") else ()
        return net:redirect-with-404($config:webserver || '/' || 'error-page.html')
};

declare function net:deliverJPG($pathComponents as xs:string*, $netVars as map()*) {
        let $reqResource  := $pathComponents[last()]
        let $reqWork      := tokenize(tokenize($reqResource, ':')[1], '\.')[1]
        let $passage      := tokenize($reqResource, ':')[2]
        let $metadata     := doc($config:rdf-root || '/' || replace($reqWork, 'w0', 'W0') || '.rdf')
        let $debug2       := if ($config:debug = "trace") then console:log("Retrieving $metadata//rdf:Description[@rdf:about = " || $reqResource || "]/rdfs:seeAlso/@rdf:resource/string()") else ()
        let $resolvedPaths := for $url in $metadata//rdf:Description[@rdf:about = $reqResource]/rdfs:seeAlso/@rdf:resource/string()
                              where matches($url, "\.(jpg|jpeg|png|tif|tiff)$")
                              return $url
        let $resolvedPath := $resolvedPaths[1]
        let $debug3       := if ($config:debug = ("trace", "info")) then console:log("Redirecting to " || $resolvedPath || " ...") else ()
        return net:redirect-with-303($resolvedPath)
};
