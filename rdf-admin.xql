xquery version "3.0";

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";
import module namespace config      = "http://salamanca/config"          at "modules/config.xqm";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace util        = "http://exist-db.org/xquery/util";
import module namespace xmldb       = "http://exist-db.org/xquery/xmldb";
import module namespace sal-util    = "http://salamanca/sal-util" at "sal-util.xql";

declare option exist:timeout "25000000"; (: ~7 h :)

declare option output:media-type "text/html";
declare option output:indent "yes";

let $start-time := util:system-time()

let $resourceId := request:get-parameter('resourceId', '')

let $rid        :=  if (starts-with($resourceId, "authors/")) then
                        substring-after($resourceId, "authors/")
                    else if (starts-with($resourceId, "texts/")) then
                        substring-after($resourceId, "texts/")
                    else
                        $resourceId

(: for published works, rdf rendering is only permitted if there is an index file that is newer than the TEI source :)
let $indexPath := $config:index-root || '/' || $rid || '_nodeIndex.xml'
let $currentIndexAvailable := boolean(doc-available($indexPath)
                                      and xmldb:last-modified($config:index-root, $rid || '_nodeIndex.xml') = max((xmldb:last-modified($config:index-root, $rid || '_nodeIndex.xml'), xmldb:last-modified($config:tei-works-root, $rid || '.xml'))))
return
    if ((sal-util:WRKvalidateId($rid) eq 2 and $currentIndexAvailable) or sal-util:WRKvalidateId($rid) = 1) then
        let $debug := console:log("Requesting " || $config:apiserver || '/v1/xtriples/extract.xql?format=rdf&amp;configuration=' || $config:apiserver || '/v1/xtriples/createConfig.xql?resourceId=' || $rid || ' ...')
        let $rdf   :=  doc($config:apiserver || '/v1/xtriples/extract.xql?format=rdf&amp;configuration=' || $config:apiserver        || '/v1/xtriples/createConfig.xql?resourceId=' || $rid)
        (: let $debug := console:log("Resulting $rdf := " || $rdf || '.' ) :)
        let $runtime-ms    := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
        let $runtimeString := if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
                              else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
                              else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
        let $log  := util:log('warn', 'Extracted RDF for ' || $resourceId || ' in ' || $runtimeString)
        let $save := admin:saveFile($rid, $rid || '.rdf', $rdf, 'rdf')
        return 
            <output>
                <status>Extracted RDF in {$runtimeString} and saved at {$save}</status>
                <data>{$rdf}</data>
            </output>
    else 
        <output>
           <status>Could not extract RDF for {$rid}, since there is either no TEI source available, or for a published work there is no current index data 
                available (need to create/update HTML first?)</status>
        </output>
               