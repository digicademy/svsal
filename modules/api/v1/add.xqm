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

import module namespace api = "http://www.salamanca.school/xquery/api" at "../api.xqm";


(: RESTXQ FUNCTIONS :)

(: TODO add more / url path units query params if necessary :)
declare
%rest:GET
%rest:path("/v1/search/{$path1}/{$path2}")
%rest:query-param("q", "{$q}", "")
%rest:header-param("X-Forwarded-Host", "{$host}", "")
function addv1:search($path1, $path2, $q, $host) {
    api:redirect-with-303($api:proto || 'search.' || api:getDomain($host) || '/' || $trail || '/' || $trail2 || '?q=' || $q)
};

