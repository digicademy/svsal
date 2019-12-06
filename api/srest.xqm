xquery version "3.0";


(: ####++++----

    SvSal config and utility module for working with RestXQ: includes RestXQ functions that don't fit into the 
    more specific REST endpoint modules, and provides general utility functions and config variables 
    for processing requests through RestXQ.

 ----++++#### :)


module namespace srest = "http://www.salamanca.school/xquery/srest";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace http = "http://expath.org/ns/http-client";


(: CONFIG VARIABLES :)
(: some of these variables occur in similar form in config.xqm, but need to be "duplicated" here 
 since RestXQ does not get along well with the request module (which is required by config.xqm) :)

declare variable $srest:proto := 'https://';
declare variable $srest:currentApiVersion := 'v1';

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
function srest:redirectIdTextsDocRequest($rid, $host, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    srest:redirect-with-303($srest:proto || 'api.' || srest:getDomain($host) || '/' || $srest:currentApiVersion || 
                            '/texts/' || $rid 
                            || srest:getQueryParams($format, $mode, $q, $lang, $viewer, $frag, $canvas))
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
function srest:redirectIdTextsDocRequestLegacy($rid, $host, $format, $mode, $q, $lang, $viewer, $frag, $canvas) {
    srest:redirect-with-303($srest:proto || 'api.' || srest:getDomain($host) || '/' || $srest:currentApiVersion || 
                            '/texts/' || $rid || srest:getQueryParams($format, $mode, $q, $lang, $viewer, $frag, $canvas))
};


declare 
%rest:GET
%rest:path("/texts")
%rest:query-param("format", "{$format}", "html")
%rest:query-param("lang", "{$lang}", "en")
%rest:header-param("X-Forwarded-Host", "{$host}")
function srest:redirectIdTextsCorpusRequest($rid, $host, $format, $lang) {
    srest:redirect-with-303($srest:proto || 'api.' || srest:getDomain($host) || '/' || $srest:currentApiVersion || 
                            '/texts')
};


(: TODO add authors and concepts endpoints here when available :)



(: UTILITY FUNCTIONS :)

declare function srest:getQueryParams($format as xs:string?, $mode as xs:string?, $q as xs:string?, $lang as xs:string?,
                                      $viewer as xs:string?, $frag as xs:string?, $canvas as xs:string?) {
    () (: TODO :)                                      
};

declare function srest:getDomain($xForwardedHost as xs:string) as xs:string? {
    if (substring-before($xForwardedHost, ".") = 'id') then 
        substring-after($xForwardedHost, ".")
    else 
        $xForwardedHost
};

declare function srest:redirect-with-303($url) {
    <rest:response>
        <http:response status="303">
            <http:header name="Location" value="{$url}"/>
        </http:response>
    </rest:response>
};
