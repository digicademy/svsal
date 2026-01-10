xquery version "3.1";

(: ####++++----

    Simplified batch derivative generation endpoint for CI/CD.
    JSON-only output with comprehensive error handling.

----++++#### :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace config = "https://www.salamanca.school/xquery/config" at "modules/config.xqm";
import module namespace admin = "https://www.salamanca.school/xquery/admin" at "modules/admin.xqm";
import module namespace upload = "https://www.salamanca.school/xquery/upload" at "modules/upload.xql";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace util = "http://exist-db.org/xquery/util";

declare option output:method "json";
declare option output:media-type "application/json";

(:~
 : Batch derivative generation endpoint for CI/CD.
 : Simplified interface with JSON-only output.
 : 
 : Parameters:
 :   works - Comma-separated work IDs or "all"
 :   formats - Comma-separated formats (html,txt,pdf,rdf,iiif,index,crumbtrails,details,snippets,nlp,routing) or "all"
 :
 : Returns: {"results": [...], "summary": {...}}
 :)

let $start-time := util:system-time()

let $works-param := request:get-parameter('works', '')
let $formats-param := request:get-parameter('formats', 'all')

let $work-ids := 
    if ($works-param = 'all') then
        collection($config:tei-works-root)//tei:TEI/@xml:id/string()
    else if ($works-param != '') then
        tokenize($works-param, ',')[normalize-space(.) != '']
    else
        ()

let $formats := 
    if ($formats-param = 'all') then
        ('index', 'crumbtrails', 'html', 'details', 'snippets', 'nlp', 'routing')
    else
        tokenize($formats-param, ',')[normalize-space(.) != '']

let $debug := console:log("[WEBDATA-BATCH] Processing " || count($work-ids) || " work(s) with " || count($formats) || " format(s)")

(: Process each work with each format :)
let $results := 
    for $work-id in $work-ids
    return
        map {
            "work": $work-id,
            "formats": array {
                for $format in $formats
                return
                    try {
                        let $debug := console:log("[WEBDATA-BATCH] Generating " || $format || " for " || $work-id)
                        let $result := 
                            switch($format)
                                case 'index' return 
                                    admin:createNodeIndex($work-id)
                                case 'pdf_upload' return
                                    upload:uploadPdf($work-id)  
                                case 'pdf_create' return
                                    admin:createPdf($work-id)
                                case 'crumbtrails' return
                                    admin:createCrumbtrails($work-id) 
                                case 'html' return
                                    admin:renderHTML($work-id)
                                case 'details' return
                                    admin:createDetails($work-id)
                                case 'snippets' return 
                                    admin:sphinx-out($work-id, 'html')
                                case 'rdf' return
                                    admin:createRDF($work-id)
                                case 'nlp' return
                                    admin:createNLP($work-id)
                                case 'iiif' return
                                    admin:createIIIF($work-id)
                                case 'routing' return
                                    admin:createRoutes($work-id)
                                default return 
                                    error(xs:QName('webdata-batch'), 'Unknown format: ' || $format)
                        return
                            map {
                                "format": $format,
                                "status": "success"
                            }
                    } catch * {
                        let $error-msg := $err:code || ": " || $err:description
                        let $debug := util:log('error', '[WEBDATA-BATCH] Error generating ' || $format || ' for ' || $work-id || ': ' || $error-msg)
                        return
                            map {
                                "format": $format,
                                "status": "error",
                                "message": $error-msg
                            }
                    }
            }
        }

let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000
let $runtimeString := 
    if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " seconds"
    else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " minutes"
    else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " hours"

(: Count successes and failures :)
let $total-operations := count($work-ids) * count($formats)
let $successful-operations := count(
    for $result in $results
    for $format-result in $result?formats?*
    where $format-result?status = 'success'
    return 1
)
let $failed-operations := $total-operations - $successful-operations

(: Determine HTTP status code :)
let $http-status := 
    if ($failed-operations = 0) then 200
    else if ($successful-operations > 0) then 207  (: Multi-Status :)
    else 500

let $_ := response:set-status-code($http-status)

let $debug := console:log("[WEBDATA-BATCH] Completed in " || $runtimeString || " with status " || $http-status)

return map {
    "results": array { $results },
    "summary": map {
        "totalWorks": count($work-ids),
        "totalOperations": $total-operations,
        "successful": $successful-operations,
        "failed": $failed-operations,
        "formats": array { $formats },
        "runtime": $runtimeString
    },
    "timestamp": current-dateTime()
}
