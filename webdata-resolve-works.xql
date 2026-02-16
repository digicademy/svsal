xquery version "3.1";

(: ####++++----

    Work resolution endpoint for CI/CD automation.
    Resolves file paths to work IDs including XInclude parent detection.

----++++#### :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace resolver = "https://www.salamanca.school/xquery/resolver" 
    at "modules/work-resolver.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace config = "https://www.salamanca.school/xquery/config" at "modules/config.xqm";

declare option output:method "json";
declare option output:media-type "application/json";

(:~
 : Resolves file paths to work IDs for CI/CD automation.
 : 
 : Parameters:
 :   files - Comma-separated list of changed file paths
 :   format - Output format: "json" (default) or "csv"
 :
 : Example: webdata-resolve-works.xql?files=works/W0066_Vol_02.xml,works/W0013.xml&format=json
 :
 : Returns: {"works": ["W0066", "W0013"], "resolved": {"W0066_Vol_02": ["W0066"], "W0013": ["W0013"]}, "count": 2}
 :)

let $files := tokenize(request:get-parameter('files', ''), ',')
let $format := request:get-parameter('format', 'json')

let $debug := if ($config:debug = ("trace", "info")) then 
    console:log("[RESOLVE-WORKS] Processing " || count($files[normalize-space(.) != '']) || " file(s): " || string-join($files[normalize-space(.) != ''], ', '))
else ()

let $resolved-map := map:merge(
    for $file in $files[normalize-space(.) != '']
    let $direct-id := resolver:extract-work-id($file)
    let $parent-ids := resolver:find-parent-works($direct-id)
    let $all-ids := distinct-values(($direct-id, $parent-ids))
    return map:entry($file, array { $all-ids })
)

let $all-work-ids := distinct-values(
    for $file in map:keys($resolved-map)
    for $work in map:get($resolved-map, $file)?*
    return $work
)

let $debug := if ($config:debug = ("trace", "info")) then 
    console:log("[RESOLVE-WORKS] Resolved to " || count($all-work-ids) || " work ID(s): " || string-join($all-work-ids, ', '))
else ()

return
    if ($format = 'csv') then (
        response:set-header('Content-Type', 'text/plain'),
        string-join($all-work-ids, ',')
    )
    else 
        map {
            "works": array { $all-work-ids },
            "resolved": $resolved-map,
            "count": count($all-work-ids)
        }
