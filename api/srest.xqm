xquery version "3.0";


(: ####++++----

    General SvSal RestXQ functions that don't fit into the more specific REST endpoint modules.

 ----++++#### :)


module namespace srest              = "http://www.salamanca.school/xquery/srest";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

import module namespace rest = "http://exquery.org/ns/restxq";

(:
RestXQ functions for redirecting requests with "id." URLs to current API endpoints.

(Redirecting "id." URLs is necessary since the "normal" XQueryUrlRewrite servlet (in eXist 4.1 and above) doesn't accept 
URLs containing colons, so that all "id." URLs are forwarded not to controller.xql but to the RestXQ servlet, 
ending up here.)
:)

declare 
%rest:GET
%rest:path("/texts")
function srest:redirectIdTextsRequest($rid) {
    (:net:redirect-with-303($config:apiserver || '/' || $config:currentApiVersion || '/texts/' || $rid):)
    <helloWorld/>
};
(:
declare 
%rest:GET
%rest:path("/works.{$rid}")
function srest:redirectIdTextsRequestLegacy($rid) {
    net:redirect-with-303($config:apiserver || '/' || $config:currentApiVersion || '/texts/' || $rid)
};
:)
(: the following endpoints aren't available yet, they are here for the sake of completeness :)
(:
declare 
%rest:GET
%rest:path("/authors/{$rid}")
function srest:redirectIdAuthorsRequest($rid) {
    net:redirect-with-303($config:apiserver || '/' || $config:currentApiVersion || '/authors/' || $rid)
};

declare 
%rest:GET
%rest:path("/concepts/{$rid}")
function srest:redirectIdConceptsRequests($rid) {
    net:redirect-with-303($config:apiserver || '/' || $config:currentApiVersion || '/concepts/' || $rid)
};
:)