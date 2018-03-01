xquery version "3.0";

declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";
import module namespace config      = "http://salamanca/config"          at "modules/config.xqm";
import module namespace console    = "http://exist-db.org/xquery/console";

declare option output:media-type "application/rdf+xml";
declare option output:indent "yes";

let $resourceId    := request:get-parameter('resourceId', 'W0013')

let $rid :=     if (starts-with($resourceId, "authors.")) then
                        substring-after($resourceId, "authors.")
                    else if (starts-with($resourceId, "works.")) then
                        substring-after($resourceId, "works.")
                    else
                        $resourceId

let $debug := console:log("Requesting " || $config:apiserver || '/lod/extract.xql?format=rdf&amp;configuration=' || $config:apiserver || '/lod/createConfig.xql?resourceId=' || $rid || ' ...')

let $rdf   :=  doc($config:apiserver || '/lod/extract.xql?format=rdf&amp;configuration=' || $config:apiserver        || '/lod/createConfig.xql?resourceId=' || $rid)
(: let $debug := console:log("Resulting $rdf := " || $rdf || '.' ) :)

let $save := admin:saveFile($rid, $rid || '.rdf', $rdf, 'rdf')
return <output><status>Saved at {$save}</status><data>{$rdf}</data></output>