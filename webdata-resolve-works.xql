xquery version "3.1";

(: ####++++----

    Work Resolution Endpoint

    This endpoint accepts TEI file paths and returns work IDs that need regeneration.
    Handles XInclude parent detection for multivolume works.

    Parameters:
    - files: Comma-separated list of file paths or multiple file parameters
    - format: Output format (json, csv, text) - defaults to json

    Example calls:
    - /webdata-resolve-works.xql?files=works/W0013.xml
    - /webdata-resolve-works.xql?files=works/W0013.xml,works/W0066_Vol_02.xml
    - /webdata-resolve-works.xql?files=works/W0013.xml&format=csv

----++++#### :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";

import module namespace console = "http://exist-db.org/xquery/console";
import module namespace config = "https://www.salamanca.school/xquery/config" at "modules/config.xqm";
import module namespace resolver = "https://www.salamanca.school/xquery/resolver" at "modules/work-resolver.xqm";

declare option output:method "text";
declare option output:media-type "text/plain";

(: Helper function to set HTTP status code and message :)
declare function local:error-response($status-code as xs:integer, $message as xs:string) {
    let $set-status := response:set-status-code($status-code)
    let $log := console:log("[WEBDATA-RESOLVE-WORKS] Error " || $status-code || ": " || $message)
    return $message
};

(: Helper function to format output based on format parameter :)
declare function local:format-output($work-ids as xs:string*, $format as xs:string) {
    switch($format)
        case "csv" return
            let $set-type := response:set-header("Content-Type", "text/csv")
            return string-join($work-ids, ",")
        case "text" return
            let $set-type := response:set-header("Content-Type", "text/plain")
            return string-join($work-ids, "&#10;")
        case "json" return
            let $set-type := response:set-header("Content-Type", "application/json")
            let $json := '{"works": [' ||
                         string-join(
                             for $id in $work-ids
                             return '"' || $id || '"',
                             ", "
                         ) ||
                         ']}'
            return $json
        default return
            let $set-type := response:set-header("Content-Type", "application/json")
            let $json := '{"works": [' ||
                         string-join(
                             for $id in $work-ids
                             return '"' || $id || '"',
                             ", "
                         ) ||
                         ']}'
            return $json
};

(: Main execution :)
let $start-time := util:system-time()

(: Get file parameters - support both comma-separated and multiple parameters :)
let $files-param := request:get-parameter("files", ())
let $files :=
    if (empty($files-param)) then
        ()
    else if (count($files-param) > 1) then
        (: Multiple file parameters :)
        $files-param
    else
        (: Single parameter, possibly comma-separated :)
        for $file in tokenize($files-param, ',')
        return normalize-space($file)

(: Get format parameter :)
let $format := request:get-parameter("format", "json")

(: Validate parameters :)
let $validation :=
    if (empty($files) or $files = "") then
        local:error-response(400, "Error: 'files' parameter is required")
    else if (not($format = ("json", "csv", "text"))) then
        local:error-response(400, "Error: 'format' parameter must be one of: json, csv, text")
    else
        ()

return
    if ($validation) then
        $validation
    else
        try {
            (: Resolve work IDs from file paths :)
            let $debug := if ($config:debug = "trace") then
                console:log("[WEBDATA-RESOLVE-WORKS] Received files: " || string-join($files, ", "))
            else ()

            let $work-ids := resolver:resolve-work-ids($files)

            (: Set success status :)
            let $set-status := response:set-status-code(200)

            (: Log the operation :)
            let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000
            let $log := console:log(
                "[WEBDATA-RESOLVE-WORKS] Resolved " || count($files) || " file(s) to " ||
                count($work-ids) || " work ID(s) in " || format-number($runtime-ms, "#.##") || "ms"
            )

            (: Format and return output :)
            return
                if (empty($work-ids)) then
                    (: No work IDs found - return empty result :)
                    local:format-output((), $format)
                else
                    local:format-output($work-ids, $format)

        } catch * {
            (: Handle unexpected errors :)
            let $error-msg := "Internal error: " || $err:description
            let $log := console:log("[WEBDATA-RESOLVE-WORKS] Error: " || $err:description || " at " || $err:module || ":" || $err:line-number)
            return local:error-response(500, $error-msg)
        }
