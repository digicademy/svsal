xquery version "3.0";


(: ####++++----

    General API functions and variables for utility and delivery, and some RestXQ functions for 
    redirects (e.g., from "id." URIs to more specific API modules).

 ----++++#### :)


module namespace api = "http://www.salamanca.school/xquery/api";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace http = "http://expath.org/ns/http-client";

import module namespace config = "http://www.salamanca.school/xquery/config" at "../modules/config.xqm";


(: CONFIG VARIABLES :)
(: some of these variables occur in similar form in config.xqm, but need to be "duplicated" here 
 since RestXQ does not get along well with the request module (which is required by config.xqm) :)

declare variable $api:proto := 'https://';

declare variable $api:jsonOutputParams :=
    <output:serialization-parameters>
        <output:method>json</output:method>
    </output:serialization-parameters>;
    
declare variable $api:teiOutputParams :=
    <output:serialization-parameters>
        <output:method value="xml"/>
        <output:indent value="no"/>
        <output:media-type value="application/tei+xml"/>
    </output:serialization-parameters>;
    
declare variable $api:txtOutputParams :=
    <output:serialization-parameters>
        <output:method>text</output:method>
    </output:serialization-parameters>;
    
declare variable $api:zipOutputParams :=
    <output:serialization-parameters>
        <output:media-type value="application/zip"/>
        <output:method value="binary"/>
    </output:serialization-parameters>;


(: REST RESPONSE FUNCTIONS :)

(: Content Wrappers :)

declare function api:deliverTEI($content, $name as xs:string?) {
    let $filename := if ($name) then $name else $content/@xml:id/string()
    let $filename := translate($filename, ':.', '_-') || '.xml'
    let $contentDisposition := 'attachment; filename="' || $filename || '"'
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
        <http:response status="404">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    serialize(
        map {
            'error': map {
                'status': 404,
                'message': 'Resource not found.'
            }
        }, 
        $api:jsonOutputParams)
};

declare function api:error404NotYetAvailable() {
    <rest:response>
        <http:response status="404">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    serialize(
        map {
            'error': map {
                'status': 404,
                'message': 'Resource not yet available.'
            }
        }, 
        $api:jsonOutputParams)
};

declare function api:error400BadResource() {
    <rest:response>
        <http:response status="400">
            <http:header name="Content-Language" value="en"/>
            <http:header name="Content-Type" value="application/json; charset=utf-8"/>
        </http:response>
    </rest:response>,
    serialize(
        map {
            'error': map {
                'status': 400,
                'message': 'Resource identifier syntax is invalid, must be of the form: work_id[:passage_id]'
            }
        }, 
        $api:jsonOutputParams)
};



(: RESTXQ FUNCTIONS for redirecting requests with "id." URLs to current API endpoints. :)

(:
(Note: redirecting "id." URLs is necessary since the "normal" XQueryUrlRewrite servlet (in eXist 4.1 and above) doesn't accept 
URLs containing colons, so that all "id." URLs are forwarded not to controller.xql but to the RestXQ servlet, 
ending up here.)
:)


declare 
%rest:GET
%rest:path("/texts/{$rid}")
%rest:query-param("format", "{$format}", "html")
%rest:query-param("mode", "{$mode}", "")
%rest:query-param("q", "{$q}", "")
%rest:query-param("lang", "{$lang}", "en")
%rest:query-param("viewer", "{$viewer}", "")
%rest:query-param("frag", "{$frag}", "")
%rest:query-param("canvas", "{$canvas}", "")
%rest:header-param("X-Forwarded-Host", "{$host}")
%output:indent("no")
function api:redirectIdTextsDocRequest($rid, $host, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    api:redirect-with-303($api:proto || 'api.' || api:getDomain($host) || '/' || $config:currentApiVersion || 
                            '/texts/' || $rid 
                            || api:getQueryParams($format, $mode, $q, $lang, $viewer, $frag, $canvas))
};


declare 
%rest:GET
%rest:path("/works.{$rid}")
%rest:query-param("format", "{$format}", "html")
%rest:query-param("mode", "{$mode}", "")
%rest:query-param("q", "{$q}", "")
%rest:query-param("lang", "{$lang}", "en")
%rest:query-param("viewer", "{$viewer}", "")
%rest:query-param("frag", "{$frag}", "")
%rest:query-param("canvas", "{$canvas}", "")
%rest:header-param("X-Forwarded-Host", "{$host}")
%output:indent("no")
function api:redirectIdTextsDocRequestLegacy($rid, $host, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    api:redirect-with-303($api:proto || 'api.' || api:getDomain($host) || '/' || $config:currentApiVersion || 
                            '/texts/' || $rid || api:getQueryParams($format, $mode, $q, $lang, $viewer, $frag, $canvas))
};


declare 
%rest:GET
%rest:path("/texts")
%rest:query-param("format", "{$format}", "html")
%rest:query-param("lang", "{$lang}", "en")
%rest:header-param("X-Forwarded-Host", "{$host}")
%output:indent("no")
function api:redirectIdTextsCorpusRequest($rid, $host, $format, $lang) {
    api:redirect-with-303($api:proto || 'api.' || api:getDomain($host) || '/' || $config:currentApiVersion || 
                            '/texts')
};

(: TODO: content type via Accept header :)


(: TODO add authors and concepts endpoints here when available :)



(: UTILITY FUNCTIONS :)

declare function api:getQueryParams($format as xs:string?, $mode as xs:string?, $q as xs:string?, $lang as xs:string?,
                                      $viewer as xs:string?, $frag as xs:string?, $canvas as xs:string?) {
    () (: TODO :)                                      
};

declare function api:getDomain($xForwardedHost as xs:string) as xs:string? {
    if (substring-before($xForwardedHost, ".") = 'id') then 
        substring-after($xForwardedHost, ".")
    else 
        $xForwardedHost
};

