xquery version "3.0" encoding "UTF-8";

(: ####++++----

    Additional API endpoints (search, codesharing, etc.).

 ----++++#### :)

module namespace addv1 = "http://api.salamanca.school/v1/texts";

declare namespace sal = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace http = "http://expath.org/ns/http-client";
import module namespace console     = "http://exist-db.org/xquery/console";

import module namespace config = "http://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace api = "http://www.salamanca.school/xquery/api" at "../api.xqm";
import module namespace codesharing = "http://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";

(: RESTXQ FUNCTIONS :)

(: Search :)

(: TODO add more / url path units query params if necessary :)
declare
%rest:GET
%rest:path("/v1/search/{$path1}/{$path2}")
%rest:query-param("q", "{$q}", "")
%rest:header-param("X-Forwarded-Host", "{$host}", "")
function addv1:search($path1, $path2, $q, $host) {
    api:redirect-with-303($api:proto || 'search.' || api:getDomain($host) || '/' || $trail || '/' || $trail2 || '?q=' || $q)
};


(: Codesharing :)

declare
%rest:GET
%rest:path("/v1/codesharing/protocol")
function addv1:codesharingProtocol() {
    (: directly forwards to codesharing_protocol.xhtml :)
    api:deliverHTML(
        doc($config:app-root || '/services/codesharing/codesharing_protocol.xhtml')
    ) 
};

declare
%rest:GET
%rest:path("/v1/codesharing")
%rest:query-param("verb", "{$verb}", "")
%rest:query-param("elementName", "{$elementName}", "")
%rest:query-param("attributeName", "{$attributeName}", "")
%rest:query-param("attributeValue", "{$attributeValue}", "")
%rest:query-param("documentType", "{$documentType}", "")
%rest:query-param("wrapped", "{$wrapped}", "")
%rest:query-param("namespace", "{$namespace}", "")
%rest:header-param("X-Forwarded-Host", "{$host}", "")
function addv1:codesharing($verb, $elementName, $attributeName, $attributeValue, $documentType, $wrapped, $namespace, $host) {
    (: redirect to codesharing service :)
    let $paramStr := 
        string-join(
            (
                (if ($verb) then 'verb=' || $verb else ()),
                (if ($elementName) then 'elementName=' || $elementName else ()),
                (if ($attributeName) then 'attributeName=' || $attributeName else ()),
                (if ($attributeValue) then 'attributeValue=' || $attributeValue  else ()),
                (if ($documentType) then 'documentType=' || $documentType else ()),
                (if ($wrapped) then 'wrapped=' || $wrapped else ()),
                (if ($namespace) then 'namespace=' || $namespace else ())
            ),
            '&amp;'
        )
    let $url := $api:proto || 'www.' || api:getDomain($host) || '/codesharing/' || (if ($paramStr) then '?' || $paramStr else ())
    return
        api:redirect-with-303($url)
}; 


(: VoID ttl :)

declare 
%rest:GET
%rest:path("/v1/void.ttl")
function addv1:voidttl1() {
    api:deliverTurtleBinary(
        util:binary-doc($config:app-root || '/void.ttl'),
        'void.ttl'
    )
};

declare 
%rest:GET
%rest:path("/void.ttl")
function addv1:voidttl2() {
    api:deliverTurtleBinary(
        util:binary-doc($config:app-root || '/void.ttl'),
        'void.ttl'
    )
};



