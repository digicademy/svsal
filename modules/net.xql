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
import module namespace sal-util    = "http://salamanca/sal-util" at "sal-util.xql";

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

(:declare function net:findNode($ctsId as xs:string?) {
    let $reqResource  := tokenize($ctsId, '/')[last()]
    let $reqWork      := tokenize(tokenize($reqResource, ':')[1], '\.')[1]   (\: work:pass.age :\)
    let $reqPassage   := tokenize($reqResource, ':')[2]
    let $nodeId       := if ($reqPassage) then
                            let $nodeIndex := doc($config:index-root || '/' || replace($reqWork, 'w0', 'W0') || '_nodeIndex.xml')
                            return $nodeIndex//sal:node[sal:citetrail eq $reqPassage][1]/@n[1]
                         else
                            "completeWork" 
    let $work         := util:expand(doc($config:tei-works-root || '/' || replace($reqWork, 'w0', 'W0') || '.xml')//tei:TEI)
    let $node         := $work//tei:*[@xml:id eq $nodeId]
    let $debug        := if ($config:debug = "trace") then console:log('findNode returns ' || count($node) || ' node(s): ' || $work/@xml:id || '//*[@xml:id=' || $nodeId || '] (cts/id was "' || $ctsId || '").') else ()
    return $node
};:)

declare function net:findNode($requestData as map()) {
    let $nodeId :=    
        if ($requestData('passage') ne ('')) then
            let $nodeIndex := doc($config:index-root || '/' || $requestData('work_id') || '_nodeIndex.xml')
            let $id := $nodeIndex//sal:node[sal:citetrail eq $requestData('passage')][1]/@n[1]
            return if ($id) then $id else 'completeWork'
        else 'completeWork' (: if no specific node has been found, return (or if work hasn't been rendered yet), return complete text :)
    return
        let $work := util:expand(doc($config:tei-works-root || '/' || $requestData('work_id') || '.xml')/tei:TEI)
        let $node := $work//tei:*[@xml:id eq $nodeId]
        let $debug := if ($config:debug = "trace") then console:log('findNode: found ' || count($node) || ' node(s): ' || $work/@xml:id || '//*[@xml:id=' 
                                                                    || $nodeId || '] (cts/id was "' || $requestData('mainResource') || ':' || $requestData('passage') || '").') else ()
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

declare function net:APIdeliverTEI($requestData as map(), $netVars as map()*) {
    if (matches($requestData('tei_id'), '^W\d{4}')) then 
        let $serialization  := 
            (util:declare-option("output:method", "xml"),
             util:declare-option("output:media-type", "application/tei+xml"),
             util:declare-option("output:indent", "yes"),
             util:declare-option("output:expand-xincludes", "yes"))
        let $debug :=   
            if ($config:debug = "trace") then console:log("Serializing options: method:" || util:get-option('output:method') ||
                ', media-type:' || util:get-option('output:media-type') ||
                ', indent:'     || util:get-option('output:indent') ||
                ', expand-xi:'  || util:get-option('output:expand-xincludes') ||
                '.') 
            else ()
        let $doc := 
            if ($requestData('mode') eq 'meta') then
                let $debug :=  if ($config:debug = "trace") then console:log("[API] teiHeader export for " || $requestData("tei_id") || ".") else ()
                return export:WRKgetTeiHeader($requestData('tei_id'), 'metadata', ())
            else if ($requestData('passage') and not(matches($requestData('passage'), '^vol\d$'))) then (: volumes are handled below :)
                let $debug :=  if ($config:debug = "trace") then console:log("[API] teiHeader export for passage " || $requestData("tei_id") || ":" || $requestData('passage') || ".") else ()
                return export:WRKgetTeiPassage($requestData("work_id"), $requestData("passage"))
            else 
                let $debug :=  if ($config:debug = "trace") then console:log("[API] TEI doc export for " || $requestData('tei_id') || ".") else ()
                return util:expand(doc($config:tei-works-root || '/' || $requestData('tei_id') || '.xml')/tei:TEI)
        let $filename := 
            if ($requestData('mode') eq 'meta') then $requestData('tei_id') || '_teiHeader.xml'
            else if ($requestData('passage')) then $requestData('work_id') || '_' || $requestData('passage') || '_tei.xml'
            else $requestData('tei_id') || '_tei.xml'
        let $response := response:set-header("Content-Disposition", 'attachment; filename="' || $filename || '"')
        return $doc
    else if ($requestData('tei_id') eq '*' and util:binary-doc-available($config:corpus-zip-root || '/sal-tei-corpus.zip')) then
        let $debug      := if ($config:debug = "trace") then console:log("[API] TEI corpus export.") else ()
        let $corpusPath := $config:corpus-zip-root || '/sal-tei-corpus.zip'
        let $response   := response:set-header("Content-Disposition", 'attachment; filename="sal-tei-corpus.zip"')
        return response:stream-binary(util:binary-doc($corpusPath), 'application/zip', 'sal-tei-corpus.zip')
    else net:error(404, $netVars, ())
};

declare function net:APIdeliverTXT($requestData as map(), $netVars as map()*) {
    if (matches($requestData('tei_id'), '^W\d{4}')) then 
        let $mode := if ($requestData('mode')) then $requestData('mode') else 'edit'
        let $node := net:findNode($requestData)
        let $serialize := (util:declare-option("output:method", "text"),
                           util:declare-option("output:media-type", "text/plain"))
        let $debug := 
            if ($config:debug = "trace") then 
                console:log("[API] Serializing options: method:" || util:get-option('output:method') ||
                            ', media-type:' || util:get-option('output:media-type') ||
                            '.') 
            else ()
        let $verboseMode := if ($mode eq 'edit') then 'constituted' else 'diplomatic' 
        let $filename := 
            (if (not(starts-with($requestData('passage'), 'vol'))) then $requestData('tei_id') else $requestData('work_id'))
             || (if ($requestData('passage')) then '_' || $requestData('passage') else ()) 
             || '_' || $verboseMode || '.txt'
        let $response := response:set-header('Content-Disposition', 'attachment; filename="' || $filename || '"')
        return 
            if ($node) then 
                (: if full work is requested and the text is already available, we fetch it directly without render:dispatch :)
                if ($requestData('passage') eq '' and not(contains($requestData('tei_id'), '_Vol')) and util:binary-doc-available($config:txt-root || '/' || $requestData('work_id') || '/' || $requestData('work_id') || '_' || $mode || '.txt')) then
                    response:stream-binary(util:binary-doc($config:txt-root || '/' || $requestData('work_id') || '/' || $requestData('work_id') || '_' || $mode || '.txt'), 'text/plain')
                else render:dispatch($node, $mode)
            else net:error(404, $netVars, 'Resource could not be found.')
    else if ($requestData('tei_id') eq '*' and util:binary-doc-available($config:corpus-zip-root || '/sal-txt-corpus.zip')) then
        let $debug      := if ($config:debug = "trace") then console:log("[API] TXT corpus export.") else ()
        let $corpusPath := $config:corpus-zip-root || '/sal-txt-corpus.zip'
        let $response   := response:set-header("Content-Disposition", 'attachment; filename="sal-txt-corpus.zip"')
        return response:stream-binary(util:binary-doc($corpusPath), 'application/zip', 'sal-txt-corpus.zip')
    else net:error(404, $netVars, 'Resource could not be found.')
};

declare function net:APIdeliverRDF($requestData as map(), $netVars as map()*) {
    if (starts-with($requestData('work_id'), 'W0')) then 
        if (doc-available($config:rdf-works-root || '/' || $requestData('work_id') || '.rdf')) then
            let $headers1 := response:set-header('Content-Disposition', 'attachment; filename="' || $requestData('work_id') || '.rdf"')
            let $header2 := response:set-header('Content-Type', 'application/rdf+xml')
            return doc($config:rdf-works-root || '/' || $requestData('work_id') || '.rdf')
        (: TODO: if there only is a teiHeader, we can also render rdf on-the-fly; however, the following returns almost empty RDF :)
        (:else if (sal-util:WRKvalidateId($requestData('work_id')) eq 1) then
            let $debug := if ($config:debug = ("trace", "info")) then console:log("Generating rdf for " || $requestData('work_id') || " ...") else ()
            let $path := '/services/lod/extract.xql'
            let $parameters := 
                (<exist:add-parameter name="configuration" value="{$config:apiserver || '/xtriples/createConfig.xql?resourceId=' || $requestData('work_id') || '&amp;format=' || $config:lodFormat}"/>)
            let $headers1 := response:set-header("Content-Disposition", 'attachment; filename="' || $requestData('work_id') || '.rdf"')
            let $header2 := response:set-header('Content-Type', 'application/rdf+xml')
            return net:forward($path, $netVars, $parameters):)
        else if (sal-util:WRKvalidateId($requestData('work_id')) ge 0) then net:error(404, $netVars, 'resource-not-yet-available')
        else net:error(404, $netVars, 'Could not find rdf resource') (: not automatically creating rdf here if not available, since this might slow down the server inacceptably :)
    else if ($requestData('work_id') eq '*') then (: rdf of all works doesn't exist atm, redirect to HTML work overview - or rather return error? :)
        let $debug := console:log("DEBUG MESSAGE")
        return net:redirect-with-307($config:webserver || '/works.html')
    else net:error(404, $netVars, 'Invalid rdf request.')
};

declare function net:APIdeliverJPG($requestData as map(), $netVars as map()*) {
    if (starts-with($requestData('work_id'), 'W0')) then 
        let $reqResource := 'texts/' || $requestData('work_id') || ':' || $requestData('passage')
        let $resolvedPath := 
            doc($config:rdf-works-root || '/' || $requestData('work_id') || '.rdf')
                /rdf:RDF/rdf:Description[lower-case(@rdf:about) eq lower-case($reqResource)
                                         and contains(rdfs:seeAlso/@rdf:resource, '.jpg')][1]/rdfs:seeAlso/@rdf:resource
        return 
            if ($resolvedPath) then
                net:redirect-with-303($resolvedPath)
            else 
                net:error(404, $netVars, 'Could not find jpg resource.')
    
    else 
        let $debug := util:log('warn', '[NET] jpg 3') return
        net:error(404, $netVars, 'Invalid jpg request.')
};

declare function net:APIdeliverTextsHTML($requestData as map(), $netVars as map()*) {
    if ($requestData('work_id') eq '*') then (: forward to works list, regardless of parameters or hashes :)
        let $langPath := if ($requestData('lang')) then $requestData('lang') || '/' else ()
        let $pathname     := $config:webserver || '/' || $langPath || 'works.html'
        let $debug       := if ($config:debug = ("trace", "info")) then console:log("[API] request for all works (HTML), redirecting to " || $pathname || " ...") else ()
        return net:redirect-with-303($pathname)
    else if ($requestData('work_status') = (1,2) 
             (: no passage, or passage is volume (of published work, passage_status=1, or unpublished work, Passage_status=-1) :)
             and (not($requestData('passage')) or (matches($requestData('passage'), '^vol\d$') and $requestData('passage_status') eq 1))
             and $requestData('viewer') eq 'all') then
        let $viewerUri := $config:webserver || '/viewer.html?wid=' || $requestData('tei_id')
        return net:redirect-with-303($viewerUri)
    else if ($requestData('work_status') eq 2 and $requestData('passage_status') = (1)) then (: full text available and passage not invalid :)
        if (matches($requestData('work_id'), '^W\d{4}$')) then
            let $debug := if ($config:debug = ("trace")) then console:log("Load metadata from " || $config:rdf-works-root || '/' || $requestData('work_id') || '.rdf' || " ...") else ()
            let $metadata := doc($config:rdf-works-root || '/' || $requestData('work_id') || '.rdf')
            let $resourcePath := (: with legacy resource ids, we need to append a "vol" passage :)
                if (contains($requestData('tei_id'), '_Vol') and not($requestData('passage'))) then 
                    $requestData('work_id') || ':vol' || substring($requestData('tei_id'), string-length($requestData('tei_id')))
                else $requestData('work_id') || (if ($requestData('passage')) then ':' || $requestData('passage') else ())
            let $debug := if ($config:debug = ("trace")) then console:log("Retrieving $metadata//rdf:Description[@rdf:about eq 'texts/" || $resourcePath || "']/rdfs:seeAlso[@rdf:resource[contains(., '.html')]][1]/@rdf:resource") else ()
            let $resolvedPath := 
                if ($requestData('mode') eq 'meta') then
                    $config:webserver || '/workDetails.html?wid=' || $requestData('tei_id')
                else if ($requestData('frag') and not($requestData('passage'))) then 
                    (: prov. solution for frag params: if there only is a fragment id for a work, simply redirect to the fragment - if we have a passage, ignore it :)
                    $config:webserver || '/work.html?wid=' || $requestData('work_id') || '&amp;frag=' || replace($requestData('frag'), 'w0', 'W0')
                else
                    try {
                        string($metadata//rdf:Description[lower-case(@rdf:about/string()) eq lower-case('texts/' || $resourcePath)]/rdfs:seeAlso[@rdf:resource[contains(., ".html")]][1]/@rdf:resource)
                        } 
                    catch err:FORG0006 {
                        let $debug := console:log('[API] err:FORG0006: could not resolve path ' || $resourcePath || ' in RDF for wid=' || $requestData('work_id'))
                        return $config:webserver || '/work.html?wid=' || $resourcePath
                    }
            let $debug := if ($config:debug = ("trace")) then console:log("Found path: " || $resolvedPath || " ...") else ()
            (: The pathname that has been saved contains 0 or exactly one parameter for the target html fragment,
               but it may or may not contain a hash value. We have to mix in other parameters (mode, search expression or viewer state) before the hash. :)
            let $pathname := (: get everything before params or hash :)
                if (contains($resolvedPath, '?')) then
                    substring-before($resolvedPath, '?')
                else if (contains($resolvedPath, '#')) then
                    substring-before($resolvedPath, '#')
                else $resolvedPath
            let $hash := if (contains($resolvedPath, '#')) then concat('#', substring-after($resolvedPath, '#')) else ()
            let $fragParam :=
                if (contains($resolvedPath, '?')) then
                    if (contains(substring-after($resolvedPath, '?'), '#')) then
                        substring-before(substring-after($resolvedPath, '?'), '#')
                    else substring-after($resolvedPath, '?')
                else ()
            (: TODO: cut original frag param out :)
            let $updParams := (: cut redundant format=html and illegal (?) frag params out :)
                if ($requestData('mode') eq 'orig' and not($netVars('paramap')?('mode') eq 'orig')) then 
                    array:append([$netVars('params')[not(. eq 'format=html' or starts-with(., 'frag'))]], 'mode=orig') 
                else [$netVars('params')[not(. eq 'format=html' or starts-with(., 'frag'))]]
            let $parameters := concat(if ($fragParam or $updParams) then "?" else (), string-join(($fragParam, string-join($updParams?*, "&amp;")), "&amp;"))
            let $debug := if ($config:debug = ("trace", "info")) then console:log("Redirecting to " || $pathname || $parameters || $hash || " ...") else ()
            return net:redirect-with-303($pathname || $parameters || $hash )
        else
            let $debug := if ($config:debug = ("trace", "info")) then console:log("Html is acceptable, but bad input. Redirect (404) to error webpage ...") else ()
            return net:error(404, $netVars, ())
    else if ($requestData('work_status') eq 1) then net:redirect-with-303($config:webserver || '/workDetails.html?wid=' || $requestData('tei_id')) (: only work details available :)
    else if ($requestData('work_status') eq 0) then net:error(404, $netVars, 'work-not-yet-available') (: work id is valid, but there are no data :)
    else net:error(404, $netVars, '')
};

declare function net:deliverTextsHTML($netVars as map()*) {
    let $wid := sal-util:normalizeId($netVars('paramap')?('wid'))
    let $validation := sal-util:WRKvalidateId($wid)
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
    let $wid := sal-util:normalizeId($netVars('paramap')?('wid'))
    let $validation := sal-util:WRKvalidateId($wid)
    return
        switch($validation)
            case 2
            case 1 return net:forward-to-html(substring($netVars('path'), 4), $netVars)
            case 0 return net:error(404, $netVars, 'work-not-yet-available')
            default return net:error(404, $netVars, ())
};

declare function net:deliverAuthorsHTML($netVars as map()*) {
    let $validation := sal-util:AUTvalidateId($netVars('paramap')?('aid'))
    let $debug := util:log('warn', 'Author id validation: ' || string($validation) || ' ; aid=' || $netVars('paramap')?('aid'))
    return
        if ($validation eq 1) then () (: TODO author article is available :)
        else if ($validation eq 0) then net:error(404, $netVars, 'author-not-yet-available')
        else net:error(404, $netVars, ())
};

declare function net:deliverConceptsHTML($netVars as map()*) {
    let $validation := sal-util:LEMvalidateId($netVars('paramap')?('lid'))
    return
        if ($validation eq 1) then () (: TODO dict. entry is available :)
        else if ($validation eq 0) then net:error(404, $netVars, 'lemma-not-yet-available')
        else net:error(404, $netVars, ())
};

declare function net:deliverWorkingPapersHTML($netVars as map()*) {
    let $validation := sal-util:WPvalidateId($netVars('paramap')?('wpid'))
    return
        if ($validation eq 1) then net:forward-to-html(substring($netVars('path'), 4), $netVars)
        else if ($validation eq 0) then net:error(404, $netVars, 'workingpaper-not-yet-available')
        else net:error(404, $netVars, ())
};

(: TODO::)

declare function net:APIdeliverIIIF($requestData as map()*, $netVars as map()*) {
(:    let $reqResource    := tokenize(tokenize($path, '/iiif/')[last()], '/')[1]:)
    let $resource := $requestData('tei_id')
    
    let $iiif-paras     := string-join(subsequence(tokenize(tokenize($path, '/iiif/')[last()], '/'), 2), '/')
    let $work           := tokenize(tokenize($reqResource, ':')[1], '\.')[1]   (: work[.edition]:pass.age :)
    let $passage        := tokenize($reqResource, ':')[2]
    let $entityPath     := concat($work, if ($passage) then concat('#', $passage) else ())
    let $debug2         := if ($config:debug = "trace") then console:log("Load metadata from " || $config:rdf-works-root || '/' || replace($work, 'w0', 'W0') || '.rdf' || " ...") else ()
    let $metadata       := doc($config:rdf-works-root || '/' || sal-util:normalizeId($work) || '.rdf')
    let $debug3         := if ($config:debug = "trace") then console:log("Retrieving $metadata//rdf:Description[@rdf:about = '" || replace($reqResource, 'w0', 'W0') || "']/rdfs:seeAlso/@rdf:resource/string()") else ()
    let $debug4         := if ($config:debug = "trace") then console:log("This gives " || count($metadata//rdf:Description[@rdf:about = replace($reqResource, 'w0', 'W0')]/rdfs:seeAlso/@rdf:resource) || " urls in total.") else ()
    let $images         := 
        for $url in $metadata//rdf:Description[@rdf:about = replace($reqResource, 'w0', 'W0')]/rdfs:seeAlso/@rdf:resource/string()
            where matches($url, "\.(jpg|jpeg|png|tif|tiff)$")
            return $url
    let $debug5         := if ($config:debug = "trace") then console:log("Of these, " || count($images) || " are images.") else ()
    let $image          := $images[1]
    let $debug5         := if ($config:debug = "trace") then console:log("The target image being " || $image || ".") else ()
    let $prefix         := "facs." || $config:serverdomain || "/iiif/"
    let $filename       := tokenize($image, '/')[last()]
    let $debug          := if ($config:debug = ("trace")) then console:log("filename = " || $filename) else ()
    let $fullpathname   := 
        if (matches($filename, '\-[A-Z]\-')) then
            concat(string-join((replace($work, 'w0', 'W0'), substring(string-join(functx:get-matches($filename, '-[A-Z]-'), ''), 2, 1), functx:substring-before-last($filename, '.')), '%C2%A7'), '/', $iiif-paras)
        else concat(string-join((replace($work, 'w0', 'W0'), functx:substring-before-last($filename, '.')), '%C2%A7'), '/', $iiif-paras)
    let $resolvedURI := concat($prefix, $fullpathname)
    let $debug5 := if ($config:debug = ("trace", "info")) then console:log("redirecting to " || $resolvedURI) else ()

    return net:redirect($resolvedURI, $netVars)
};

(:
declare function net:deliverIIIF($requestData as map(), $netVars as map()*) {

    
    
(/:    let $iiif-paras     := string-join(subsequence(tokenize(tokenize($path, '/iiif/')[last()], '/'), 2), '/') (\: sth like W0004/manifest or collection/W0013 :\):/)
    if ($requestData('resource'))
    
    let $resolvedURI    := concat($prefix, $fullpathname)
    let $debug5         := if ($config:debug = ("trace", "info")) then console:log("redirecting to " || $resolvedURI) else ()

    return net:redirect($resolvedURI, $netVars)
};
:)



(:~
: Workhorse of api.../texts: a basic filter and validator for API request arguments (i.e., URL paths and parameters). 
~:)
declare function net:APIparseTextsRequest($path as xs:string?, $netVars as map()*) as map()? {
    (: normalize path (i.e., amount and order of separators) :)
    let $normalizedPath := replace(replace(replace(replace(lower-case($path), '^/+', ''), '/+$', ''), ':+$', ''), ':+', ':')
    let $debug := if ($config:debug = ('trace')) then console:log('[API] request at: .../texts/' || $path || '. Normalized path: ' || $normalizedPath) else ()
    return
        if (count(tokenize($normalizedPath, '/')) gt 1 or count(tokenize($normalizedPath, ':')) gt 2)
            then 
                let $debug := if ($config:debug = ('trace')) then console:log('[API] invalid resource requested; normalized resource was: ', $normalizedPath) else ()
                return map:entry('is_well_formed', false())
        else
            (: (1) get components :)
            let $resource :=
                if ($normalizedPath eq '') then ''
                else 
                    let $resourceToken := tokenize(tokenize($normalizedPath, ':')[1], '\.')[1]
                    return
                        if (not($resourceToken)) then ''
                        else if (matches($resourceToken, '^w\d{4}(_vol\d{2})?$')) then 
                            translate($resourceToken, 'wv', 'WV')
                        else '-1'
            let $passage := 
                if (count(tokenize($normalizedPath, ':')) le 1) then ''
                else (: count(tokenize($normalizedPath, ':')) eq 2 (validated above) :) 
                    if (tokenize($normalizedPath, ':')[2]) then tokenize($normalizedPath, ':')[2]
                    else ''
            let $teiId := (: the actual TEI document's id (derived from the combination of resource and passage), but only if it exists :)
                if ($resource ne '-1') then 
                    if ($resource eq '') then '*' (: all tei datasets :)
                    else if (matches($passage, '^vol\d')) then (: some volume :)
                        let $volStatus := sal-util:WRKvalidateId($resource || '_Vol0' || substring($passage,4,1))
                        return
                            if ($volStatus ge 1) then (: a tei dataset is available :)
                                $resource || '_Vol0' || substring($passage,4,1)
                            else string($volStatus) (: 0 or -1 :)
                    else $resource (: already checked whether available :)
                else '-1'
            (: (2) validate components :)
            let $teiStatus := if (starts-with($teiId, 'W')) then sal-util:WRKvalidateId($teiId) else ()
            let $workId := (: the overarching work's main id, not distinguishing between volumes :)
                if ($resource != ('0', '-1')) then 
                    if ($teiId eq '*') then '*'
                    else replace($resource, '_Vol\d\d$', '')
                else '0'
            let $workStatus := 
                if ($workId = $teiId) then $teiStatus 
                else if (starts-with($workId, 'W')) then sal-util:WRKvalidateId($workId)
                else ()
            let $passageStatus := (: 1 = passage valid & existing ; 0 = not existing ; -1 = no dataset found for $wid ; empty = no passage :)
                (: special case: passage is volume of work not yet published: valid :)
                if (matches(lower-case($passage), '^vol\d$') and $workStatus eq 1 and $teiStatus eq 1) then 1
                else if ($passage) then
                    if ($teiStatus eq 2 and doc-available($config:index-root || '/' || $workId || '_nodeIndex.xml')) then 
                        let $nodeIndex := doc($config:index-root || '/' || $workId || '_nodeIndex.xml')
                        let $debug := if ($config:debug = ('trace')) then console:log('[API] checking node index for ' || $nodeIndex//@work[1]) else ()
                        return 
                            if ($nodeIndex//sal:citetrail[lower-case(./text()) eq $passage]) then 1
                            else 0
                    else -1
                else 1
            (: (3) get and filter params :)
            let $params :=
                let $format := $netVars('format') (: or net:format() :)
                let $validParams := $config:apiFormats($format)
                (:  filter out all invalid params and remove duplicates (first value wins) :)
                let $params0 := map:merge(for $p in $netVars('params') return if (($p, substring-before($p, '=')) = $validParams) then map:entry(substring-before($p, '='), substring-after($p, '=')) else ())
                let $mode :=
                    if (tokenize(tokenize($normalizedPath, ':')[1], '\.')[2] = ('orig', 'edit') and 'mode=' || tokenize(tokenize($normalizedPath, ':')[1], '\.')[2] = $validParams) then 
                        tokenize(tokenize($normalizedPath, ':')[1], '\.')[2]
                    else if (request:get-parameter('mode', '')[1] and ('mode', 'mode=' || request:get-parameter('mode', '')[1]) = $validParams) then request:get-parameter('mode', '')[1]
                    else ()
                return map:merge((map:entry('mode', $mode), map:entry('format', $format), $params0))
            (: (4) general validation and output :)
            let $requestValidation := (: -1 (meaningless request) has priority over 0 (not (yet) available) :)
                if (($teiStatus, $workStatus, $passageStatus) = -1) then -1
                else if (($teiStatus, $workStatus, $passageStatus) = 0) then 0
                else 1
            let $isWellFormed := (: if a request is clearly malformed, we deliver this info to downstream functions :) 
                if ($passage and not($resource)) then false()
                (: add further cases of malformedness here :)
                else true()
            let $resourceData := 
                map {'validation': $requestValidation, 
                     'is_well_formed': $isWellFormed,
                     'resource': $resource,
                     'tei_id': $teiId,
                     'work_id': $workId,
                     'passage': $passage,
                     'tei_status': $teiStatus,
                     'work_status': $workStatus,
                     'passage_status': $passageStatus}
            let $requestData := map:merge(($resourceData, $params))
            let $debug := if ($config:debug = ('trace')) then util:log('warn', '[API] request data: ' || string-join((for $k in map:keys($requestData) return $k || '=' || map:get($requestData, $k)), ' ; ') || '.') else ()
            return $requestData
            (:  open questions / TODO:
                    - how to deal with illegal params: ignore or error? (currently ignored)
                    - fragments (how to best access/validate them here?)
                    - matrix params?
            :)
};

