xquery version "3.1";

(: ####++++----

    Query for (de)registering restxq functions on demand (useful for development and debugging).

----++++#### :)

declare namespace exist        = "http://exist.sourceforge.net/NS/exist";
import module namespace util   = "http://exist-db.org/xquery/util";
import module namespace exrest = "http://exquery.org/ns/restxq/exist";

(: TODO add more modules here when necessary :)
let $restModules := 
    ('xmldb:exist:///db/apps/salamanca/modules/api/v1/texts.xqm',
     'xmldb:exist:///db/apps/salamanca/modules/api/v1/add.xqm',
     'xmldb:exist:///db/apps/salamanca/modules/api/api.xqm')

return 
    <rest:registry>
    {for $rm in $restModules return
        (exrest:deregister-module(xs:anyURI($rm)),
         exrest:register-module(xs:anyURI($rm)))}
    </rest:registry>
    