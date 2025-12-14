xquery version "3.1";


(: ####++++----

    General API functions and variables for utility and delivery, and some RestXQ functions for 
    redirects (e.g., from "id." URIs to more specific API modules).

 ----++++#### :)


module namespace api = "https://www.salamanca.school/xquery/api";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace http        = "http://expath.org/ns/http-client";
import module namespace util        = "http://exist-db.org/xquery/util";
import module namespace rest        = "http://exquery.org/ns/restxq";

import module namespace config = "https://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";


(: CONFIG VARIABLES :)
(: some of these variables occur in similar form in config.xqm, but need to be "duplicated" here 
 since RestXQ does not get along well with the request module (which is required by config.xqm) :)

declare variable $api:proto := 'https://';

declare variable $api:servedContentTypes := (
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

declare variable $api:jsonOutputParams :=
    <output:serialization-parameters>
        <output:method value="json"/>
    </output:serialization-parameters>;
    
declare variable $api:teiOutputParams :=
    <output:serialization-parameters>
        <output:method value="xml"/>
        <output:indent value="no"/>
        <output:media-type value="application/tei+xml"/>
    </output:serialization-parameters>;
    
declare variable $api:rdfOutputParams :=
    <output:serialization-parameters>
        <output:method value="xml"/>
        <output:indent value="yes"/>
        <output:media-type value="application/rdf+xml"/>
    </output:serialization-parameters>;
    
declare variable $api:txtOutputParams :=
    <output:serialization-parameters>
        <output:method value="text"/>
        <output:media-type value="text/plain"/>
    </output:serialization-parameters>;
    
declare variable $api:txtBinaryOutputParams :=
    <output:serialization-parameters>
        <output:method value="binary"/>
        <output:media-type value="text/plain"/>
    </output:serialization-parameters>;
    
declare variable $api:turtleBinaryOutputParams :=
    <output:serialization-parameters>
        <output:method value="binary"/>
        <output:media-type value="text/turtle"/>
    </output:serialization-parameters>;
    
declare variable $api:zipOutputParams :=
    <output:serialization-parameters>
        <output:media-type value="application/zip"/>
        <output:method value="binary"/>
    </output:serialization-parameters>;


(: REST RESPONSE FUNCTIONS :)

(: Content Wrappers :)

declare function api:deliverTEI($content, $name as xs:string?) {
(:  let $filename := if ($name) then $name else $content/@xml:id/string()
    let $filename := translate($filename, ':.', '_-') || '.xml'
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
:)
    let $contentDisposition := 'inline'
    return
        <rest:response>
            {$api:teiOutputParams}
            <http:response status="200">    
                <http:header name="Content-Type" value="application/tei+xml; charset=utf-8"/>
                <http:header name="Content-Disposition" value="{$contentDisposition}"/>
            </http:response>
        </rest:response>,
        $content
};

declare function api:deliverRDF($content, $name as xs:string) {
(:  let $filename := translate($name, ':.', '_-') || '.rdf'
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
:)
    let $contentDisposition := 'inline'
    return
        <rest:response>
            {$api:teiOutputParams}
            <http:response status="200">    
                <http:header name="Content-Type" value="application/rdf+xml; charset=utf-8"/>
                <http:header name="Content-Disposition" value="{$contentDisposition}"/>
            </http:response>
        </rest:response>,
        $content
};

declare function api:deliverTXT($content as xs:string?, $name as xs:string) {
(:  let $filename := translate($name, ':.', '_-') || '.txt'
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
:)
    let $contentDisposition := 'inline'
    return
        <rest:response>
            {$api:txtOutputParams}
            <http:response status="200">    
                <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
                <http:header name="Content-Disposition" value="{$contentDisposition}"/>
            </http:response>
        </rest:response>,
        $content
};

declare function api:deliverTXTBinary($content as xs:base64Binary?, $name as xs:string) {
    let $filename := translate($name, ':.', '_-') || '.txt'
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
    return
        <rest:response>
            {$api:txtBinaryOutputParams}
            <http:response status="200">    
                <http:header name="Content-Type" value="text/plain; charset=utf-8"/>
                <http:header name="Content-Disposition" value="{$contentDisposition}"/>
            </http:response>
        </rest:response>,
        $content
};

declare function api:deliverTurtleBinary($content as xs:base64Binary?, $filename as xs:string) {
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
    return
        <rest:response>
            {$api:turtleBinaryOutputParams}
            <http:response status="200">    
                <http:header name="Content-Type" value="text/turtle; charset=utf-8"/>
                <http:header name="Content-Disposition" value="{$contentDisposition}"/>
            </http:response>
        </rest:response>,
        $content
};

declare function api:deliverHTML($content) {
        <rest:response>
            <http:response status="200">
                <output:media-type value="text/html"/>
                <output:method value="html"/>
            </http:response>
        </rest:response>,
        $content 
};

declare function api:deliverZIP($content as xs:base64Binary?, $name as xs:string) {
    let $filename := $name || '.zip'
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
    return
        <rest:response>
            {$api:zipOutputParams}
            <http:response status="200">
                <http:header name="Content-Type" value="application/zip"/>
                <http:header name="Content-Disposition" value="{$contentDisposition}"/>
            </http:response>
        </rest:response>,
        $content
};

declare function api:deliverJson($content as map()) {
    <rest:response>
        {$api:jsonOutputParams}
        <http:response status="200">
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    $content
};


(: Redirects :)

declare function api:redirect-with-303($absoluteUrl as xs:string) {
    <rest:response>
        <http:response status="303">
            <http:header name="Location" value="{$absoluteUrl}"/>
        </http:response>
    </rest:response>
};


(: Errors :)

declare function api:error404NotFound() {
    <rest:response>
        {$api:jsonOutputParams}
        <http:response status="404">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    map {
        'error': map {
            'title': 'The School of Salamanca: API',
            'status': 404,
            'message': 'Resource not found.'
        }
    }
};

declare function api:error404NotYetAvailable() {
    <rest:response>
        {$api:jsonOutputParams}
        <http:response status="404">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    map {
        'error': map {
            'title': 'The School of Salamanca: API',
            'status': 404,
            'message': 'Resource not yet available.'
        }
    }
};

declare function api:error400BadResource($uri as xs:string*) {
    <rest:response>
        {$api:jsonOutputParams}
        <http:response status="400">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    map {
        'error': map {
            'title': 'The School of Salamanca: API',
            'status': 400,
            'message': 'Bad request: Something has been wrong with the request.',
            'resource': string-join($uri, '; ')
        }
    }
};

declare function api:error405MethodNotSupported($method as xs:string?) {
    <rest:response>
        {$api:jsonOutputParams}
        <http:response status="405">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    map {
        'error': map {
            'title': 'The School of Salamanca: API',
            'status': 405,
            'message': 'Bad request: Method ' || (if ($method) then upper-case($method) || ' ' else ()) || 'not supported.'
        }
    }
};


(: RESTXQ FUNCTIONS for redirecting requests with "id." URLs to current API endpoints. :)

(:
(Note: redirecting "id." URLs is necessary since the "normal" XQueryUrlRewrite servlet (in eXist 4.1 and above) doesn't accept 
URLs containing colons, so that all "id." URLs are forwarded not to controller.xql but to the RestXQ servlet, 
ending up here.)
:)


declare 
%rest:GET
%rest:path("texts/{$rid}")
%rest:query-param("format", "{$format}", "")
%rest:query-param("mode", "{$mode}", "")
%rest:query-param("q", "{$q}", "")
%rest:query-param("lang", "{$lang}", "en")
%rest:query-param("viewer", "{$viewer}", "")
%rest:query-param("frag", "{$frag}", "")
%rest:query-param("canvas", "{$canvas}", "")
%rest:header-param("X-Forwarded-Host", "{$host}", "id.salamanca.school")
%rest:header-param("X-Forwarded-For", "{$remote_ip}", "")
%rest:header-param("Accept", "{$accept}", "text/html")
%output:indent("no")
function api:redirectTextsResource1($rid, $host, $remote_ip, $accept, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    let $format := if ($format) then $format else api:getFormatFromContentTypes(tokenize($accept, '[, ]+'), 'text/html')
    let $paramStr := api:concatDocQueryParams($format, $mode, $q, $lang, $viewer, $frag, $canvas)
    let $log := if ($config:debug = ('info', 'trace')) then 
                util:log('info', '[API] (unversioned) Request: id: "texts/' || $rid || '" ; remote_ip: "' || $remote_ip || '" ; format: "' || $format || '".')
            else ()
    let $debug1 := if ($config:debug = ("info", "trace")) then
                console:log("[API] api.xqm (unversioned api) requested: " || $host || ", " || $rid || ".")
            else ()
    return
        api:redirect-with-303($api:proto || 'api.' || api:getDomain($host) || '/' || $config:currentApiVersion || 
            '/texts/' || $rid || (if ($paramStr) then '?' || $paramStr else ''))
};


declare 
%rest:GET
%rest:path("works.{$rid}")
%rest:query-param("format", "{$format}", "")
%rest:query-param("mode", "{$mode}", "")
%rest:query-param("q", "{$q}", "")
%rest:query-param("lang", "{$lang}", "en")
%rest:query-param("viewer", "{$viewer}", "")
%rest:query-param("frag", "{$frag}", "")
%rest:query-param("canvas", "{$canvas}", "")
%rest:header-param("X-Forwarded-Host", "{$host}", "id.salamanca.school")
%rest:header-param("Accept", "{$accept}", "text/html")
%output:indent("no")
function api:redirectTextsResourceLegacy1($rid, $host, $accept, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    let $format := if ($format) then $format else api:getFormatFromContentTypes(tokenize($accept, '[, ]+'), 'text/html')
    let $paramStr := api:concatDocQueryParams($format, $mode, $q, $lang, $viewer, $frag, $canvas)
    return
        api:redirect-with-303($api:proto || 'api.' || api:getDomain($host) || '/' || $config:currentApiVersion || 
            '/texts/' || $rid || (if ($paramStr) then '?' || $paramStr else ''))
};


declare 
%rest:GET
%rest:path("texts")
%rest:query-param("format", "{$format}", "")
%rest:query-param("lang", "{$lang}", "en")
%rest:header-param("X-Forwarded-Host", "{$host}", "id.salamanca.school")
%rest:header-param("Accept", "{$accept}", "text/html")
%output:indent("no")
function api:redirectTexts1($rid, $host, $accept, $format, $lang) {
    let $format := if ($format) then $format else api:getFormatFromContentTypes(tokenize($accept, '[, ]+'), 'text/html')
    let $paramStr := api:concatCorpusQueryParams($format, $lang)
    return
        api:redirect-with-303($api:proto || 'api.' || api:getDomain($host) || '/' || $config:currentApiVersion || 
                '/texts' || (if ($paramStr) then '?' || $paramStr else ''))
};

(: TODO add authors and concepts endpoints here when available :)


(: Default handlers for underspecified, and (some) malformed requests :)

declare
%rest:GET
function api:defaultGet() {
    api:error400BadResource((rest:base-uri(), rest:uri()))
};

(: Currently unsupported methods: :)
declare
%rest:DELETE
function api:defaultDelete() {
    api:error405MethodNotSupported('delete')
};

declare
%rest:HEAD
function api:defaultHead() {
    api:error405MethodNotSupported('head')
};

declare
%rest:OPTIONS
function api:defaultOptions() {
    api:error405MethodNotSupported('options')
};

declare
%rest:POST
function api:defaultPost() {
    api:error405MethodNotSupported('post')
};

declare
%rest:PUT
function api:defaultPut() {
    api:error405MethodNotSupported('put')
};


(: UTILITY FUNCTIONS :)

declare function api:concatDocQueryParams($format as xs:string?, $mode as xs:string?, $q as xs:string?, $lang as xs:string?,
                                          $viewer as xs:string?, $frag as xs:string?, $canvas as xs:string?) as xs:string? {
    let $pairs := map {
        'format': $format,
        'mode': $mode,
        'q': $q,
        'lang': $lang,
        'viewer': $viewer,
        'frag': $frag,
        'canvas': $canvas
    }                                  
    return 
        string-join(
            (for $key in map:keys($pairs) return 
                if (map:get($pairs, $key)) then 
                    $key || '=' || map:get($pairs, $key) 
                else ()), 
        '&amp;')
};

declare function api:concatCorpusQueryParams($format as xs:string?, $lang as xs:string?) as xs:string? {
    let $pairs := map {
        'format': $format,
        'lang': $lang
    }                                  
    return 
        string-join(
            (for $key in map:keys($pairs) return 
                if (map:get($pairs, $key)) then 
                    $key || '=' || map:get($pairs, $key) 
                else ()), 
        '&amp;')                                 
};


declare function api:getDomain($xForwardedHost as xs:string) as xs:string? {
    if (substring-before($xForwardedHost, ".") = ('id', 'api')) then 
        substring-after($xForwardedHost, ".")
    else 
        $xForwardedHost
};



(: CONTENT NEGOTIATION :)

declare function api:getFormatFromContentTypes($requestedContentTypes as xs:string*, $defaultType as xs:string) {
    let $contentType := api:negotiateContentType($requestedContentTypes, $api:servedContentTypes, $defaultType)
    let $debug := if ($config:debug = 'trace') then
                    util:log('info', '[API] determined content type: ' || $contentType)
                  else ()
    return 
        switch ($contentType)
            case 'application/tei+xml'
            case 'application/xml'
            case 'text/xml'            return 'tei'
            case 'text/plain'          return 'txt'
            case 'application/rdf+xml' return 'rdf'
            case 'image/jpeg'          return 'jpg'
            case 'application/ld+json' return 'iiif'
            default                    return 'html'
};

declare function api:negotiateContentType($requestedContentTypes as xs:string*, 
                                          $offers as xs:string*, 
                                          $defaultOffer as xs:string) as xs:string {
    let $bestOffer      := $defaultOffer
    let $bestQ          := -1.0
    let $bestWild       := 3
    let $returnOffer    := api:negotiateCTSub($requestedContentTypes, $offers, $bestOffer, $bestQ, $bestWild)
    return $returnOffer
};

declare %private function api:negotiateCTSub($requestedContentTypes as xs:string*, $offers as xs:string*, $bestOffer as xs:string, $bestQ as xs:double, $bestWild as xs:integer) as xs:string {
    let $offer := $offers[1]
    (: let $debug      := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. -- Current offer type: " || $offer || ".") else ():)
    (: let $newOffer   := for $spec in tokenize(replace(request:get-header('Accept'), ' ', ''), ','):)
    let $newOffer := 
        for $spec in $requestedContentTypes
            (:let $debug := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. ---- Current accepted type: " || $spec || ".") else ():)
            let $Q      :=  
                if (string(number(substring-after($spec, ';q='))) != 'NaN') then
                    number(substring-after($spec, ';q='))
                else 1.0 
            let $value  := normalize-space(tokenize($spec, ';')[1])
            return
                if ($Q lt $bestQ) then ()           (: previous match had stronger weight :)
                else if (starts-with($spec, '*/*')) then                 (: least specific - let $bestWild := 2  :)
                    if ($bestWild gt 2) then
                        let $newBestWild   := 2
                        let $newBestQ      := $Q
                        let $newBestOffer  := $offer
                        return ($newBestOffer, $newBestQ, $newBestWild)
                    else ()
                else if (ends-with($value, '/*')) then                   (: medium specific - let $bestWild := 1  :)
                    if (substring-before($offer, '/') = substring($value, 1, string-length($value) - 2) and $bestWild gt 1) then
                        let $newBestWild   := 1
                        let $newBestQ      := $Q
                        let $newBestOffer  := $offer
                        return ($newBestOffer, $newBestQ, $newBestWild)
                    else ()
                else if ($offer = $value and ($Q gt $bestQ or $bestWild gt 0)) then    (: perfectly specific match - let $bestWild := 0 :)
                    let $newBestWild   := 0
                    let $newBestQ      := $Q
                    let $newBestOffer  := $offer
                    (:let $debug := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. ---- NewOffer: " || $newBestOffer || ',' || $newBestQ || ',' || $newBestWild || ".") else ():)
                    return ($newBestOffer, $newBestQ, $newBestWild)
                else ()
    let $returnOffer :=  
        if (count($offers) gt 1) then
            if ($newOffer[1]) then
                api:negotiateCTSub($requestedContentTypes, subsequence($offers, 2), $newOffer[1], $newOffer[2], $newOffer[3])
            else
                api:negotiateCTSub($requestedContentTypes, subsequence($offers, 2), $bestOffer, $bestQ, $bestWild)
        else
            if ($newOffer[1]) then $newOffer[1] else $bestOffer
    return $returnOffer
};


(: *** Todo:
   ***  - API landing page / default return values (depending on formats)? - currently simply redirecting to www.s.s
   ***  - Add 'meta' endpoint with json-ld, (mets/mods) (or extend "texts" endpoint in this regard)
   ***  - Implement collections/lists of resources and their filters (e.g. `/texts?q=lex` resulting in a list of texts) - but which format(s)?
   ***  - Make JSON-LD / DTS the fundamental output format (encapsulate html/xml in a json field) and diverge only when explicitly asked to do so (really?)
:)
