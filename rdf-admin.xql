xquery version "3.0";

declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";
import module namespace config      = "http://salamanca/config"          at "modules/config.xqm";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace util = "http://exist-db.org/xquery/util";

declare option output:media-type "application/rdf+xml";
declare option output:indent "yes";

let $start-time       := util:system-time()

let $resourceId    := request:get-parameter('resourceId', 'W0013')

let $rid :=     if (starts-with($resourceId, "authors/")) then
                        substring-after($resourceId, "authors/")
                    else if (starts-with($resourceId, "texts/")) then
                        substring-after($resourceId, "texts/")
                    else
                        $resourceId

let $debug := console:log("Requesting " || $config:apiserver || '/v1/xtriples/extract.xql?format=rdf&amp;configuration=' || $config:apiserver || '/v1/xtriples/createConfig.xql?resourceId=' || $rid || ' ...')

let $rdf   :=  doc($config:apiserver || '/v1/xtriples/extract.xql?format=rdf&amp;configuration=' || $config:apiserver        || '/v1/xtriples/createConfig.xql?resourceId=' || $rid)
(: let $debug := console:log("Resulting $rdf := " || $rdf || '.' ) :)

let $runtime-ms       := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
let $runtimeString := if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
                      else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
                      else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."

let $log := util:log('warn', 'Extracted RDF for ' || $resourceId || ' in ' || $runtimeString)

let $save := admin:saveFile($rid, $rid || '.rdf', $rdf, 'rdf')

return <output>
           <status>Extracted RDF in {$runtimeString} and saved at {$save}</status>
           <data>{$rdf}</data>
       </output>