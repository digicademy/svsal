xquery version "3.1";

(: ####++++----

    This query serves as a gateway for the HTML-based admin interface (admin.html), dispatching requests for the 
    creation of webdata (html, snippets, rdf, etc.) to xquery functions in the admin.xqm module.
    For possible webdata modes/formats, see $output.

----++++#### :)

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei                = "http://www.tei-c.org/ns/1.0";

import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace util        = "http://exist-db.org/xquery/util";

import module namespace config      = "https://www.salamanca.school/xquery/config"      at "modules/config.xqm";
import module namespace upload      = "https://www.salamanca.school/xquery/upload"      at "modules/upload.xql";
import module namespace admin       = "https://www.salamanca.school/xquery/admin"       at "modules/admin.xqm";
import module namespace txt         = "https://www.salamanca.school/factory/works/txt"  at "modules/factory/works/txt.xqm";
import module namespace nlp         = "https://www.salamanca.school/factory/works/nlp"  at "modules/factory/works/nlp.xqm";

declare option exist:timeout "166400000"; (: in miliseconds, 25.000.000 ~ 7h, 43.000.000 ~ 12h :)
declare option exist:output-size-limit "5000000"; (: max number of nodes in memory :)

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";

declare variable $snippetLength  := 1200;

let $start-time := util:system-time()

let $mode   := request:get-parameter('mode',    'html') (: for Sphinx, but actually used? :)
let $wid-param := request:get-parameter('wid', '')  (: New: support multiple work IDs :)
let $rid    := if ($wid-param != '') then $wid-param else request:get-parameter('rid', '')  (: Support both wid and rid for backwards compatibility :)
let $batch-mode := request:get-parameter('batch', 'false') = 'true'  (: New: batch mode for JSON output :)
let $format := request:get-parameter('format',     '')
(: let$model := map{} :)

(: Parse work IDs - support comma-separated list or 'all' :)
let $work-ids := 
    if (contains($rid, ',')) then
        tokenize($rid, ',')[normalize-space(.) != '']
    else if ($rid = 'all') then
        collection($config:tei-works-root)//tei:TEI/@xml:id/string()
    else if ($rid != '') then
        $rid
    else
        ()

let $checkIndex :=
    (: if work rendering (HTML, snippet, RDF) is requested, we need to make sure that there is an index file :)
    if (not($batch-mode) and starts-with($rid, 'W0') and not($format = ('index', 'iiif', 'crumbtrails', 'details', 'pdf_upload','pdf_create', 'routing', 'all'))) then
        if (doc-available($config:index-root || '/' || $rid || '_nodeIndex.xml')) then ()
        else error(xs:QName('webdata-admin.xql'), 'There is no index file.')
    else ()

(: Helper function to process a single work :)
let $process-single-work := function($work-id as xs:string) as item()* {
    try {
        let $debug := console:log("[WEBDATA-ADMIN] Processing work " || $work-id || " for format " || $format)
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
                    admin:sphinx-out($work-id, $mode)
                case 'rdf' return
                    admin:createRDF($work-id)
                case 'nlp' return
                    admin:createNLP($work-id)
                case 'tei-corpus' return
                    admin:createTeiCorpus('admin')
                case 'iiif' return
                    admin:createIIIF($work-id)
                case 'txt-corpus' return
                    admin:createTxtCorpus('admin')
                case 'stats' return
                    <pre>{fn:serialize(admin:createStats("*"), map{"method":"json", "indent": true(), "encoding":"utf-8"})}</pre>
                case 'routing' return
                    switch($work-id)
                        case 'all' return
                            admin:createRoutes()
                        default return
                            admin:createRoutes($work-id)
                case 'all' return 
                    (: all formats (except iiif and rdf) for a single work :)
                    let $debug := console:log("Rendering all formats for " || $work-id || " ...")
                    return
                    <div>
                        <div><h2>Index</h2>
                        {admin:createNodeIndex($work-id)}
                        </div>
                        <div><h2>Crumbtrails</h2>
                        {admin:createCrumbtrails($work-id)}
                        </div>
                        <div><h2>PDF</h2>
                        {admin:createPdf($work-id)}
                        </div>
                        <div><h2>HTML</h2>
                        {admin:renderHTML($work-id)}
                        </div>
                        <div><h2>Details</h2>
                        {admin:createDetails($work-id)}
                        </div>
                        <div><h2>Search Snippets</h2>
                        {admin:sphinx-out($work-id, $mode)}
                        </div>
                        <div><h2>NLP CSV</h2>
                        {admin:createNLP($work-id)}
                        </div>
                        <div><h2>Routes</h2>
                        {admin:createRoutes($work-id)}
                        </div>
                        <div><h2>Stats</h2>
                        {fn:serialize(admin:createStats($work-id), map{"method":"json", "indent": true(), "encoding":"utf-8"})}
                        </div>
                    </div>
                default return 
                    ()
        return 
            if ($batch-mode) then
                map {
                    "work": $work-id,
                    "status": "success",
                    "format": $format
                }
            else
                $result
    } catch * {
        let $error-msg := $err:code || ": " || $err:description
        let $debug := util:log('error', '[WEBDATA-ADMIN] Error processing work ' || $work-id || ': ' || $error-msg)
        return
            if ($batch-mode) then
                map {
                    "work": $work-id,
                    "status": "error",
                    "message": $error-msg
                }
            else
                <div class="error">Error processing work {$work-id}: {$error-msg}</div>
    }
}

(: Process works - either batch mode (multiple works) or single work mode :)
let $results := 
    if ($batch-mode and count($work-ids) > 0) then
        for $work-id in $work-ids
        return $process-single-work($work-id)
    else if (count($work-ids) > 0) then
        $process-single-work($work-ids[1])
    else
        (: Legacy support for original $rid parameter without work IDs :)
        switch($format)
            case 'tei-corpus' return
                admin:createTeiCorpus('admin')
            case 'txt-corpus' return
                admin:createTxtCorpus('admin')
            case 'stats' return
                <pre>{fn:serialize(admin:createStats("*"), map{"method":"json", "indent": true(), "encoding":"utf-8"})}</pre>
            case 'routing' return
                admin:createRoutes()
            default return 
                ()

let $output := 
    if ($batch-mode) then
        $results
    else
        $results

let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000
let $runtimeString := 
    if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " seconds"
    else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " minutes"
    else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " hours"

let $debug := 
    if ($format) then 
        util:log('info', '[WEBDATA-ADMIN] Rendered "' || $format || '" for resource "' || $rid || '" in ' || $runtimeString || '.') 
    else ()

let $title := 
    if (not($rid)) then 
        'Webdata Output for Format "' || $format || '"'
    else 'Webdata Output for Resource(s): "' || $rid || '"; Format: "' || $format || '"'

(: Set HTTP status code for batch mode :)
let $http-status := 
    if ($batch-mode) then
        if (every $r in $results satisfies $r?status = 'success') then 200
        else if (some $r in $results satisfies $r?status = 'success') then 207  (: Multi-Status :)
        else 500
    else
        200

let $_ := 
    if ($batch-mode) then
        response:set-status-code($http-status)
    else ()

return 
    if ($batch-mode) then (
        response:set-header('Content-Type', 'application/json'),
        fn:serialize(
            map {
                "results": array { $results },
                "total": count($work-ids),
                "successful": count($results[?status = 'success']),
                "failed": count($results[?status = 'error']),
                "runtime": $runtimeString
            },
            map {"method": "json", "indent": true()}
        )
    )
    else
        <html>
            <head>
                <title>Webdata for {$rid}/{$format} - The School of Salamanca</title>
                <style>{'.section-title {display:none;}
                         .sal-cite-toggle {display:none !important;}
                         .sal-toolbox-body {display:none !important;}'}</style>
            </head>
            <body>
                <h1>{$title}</h1>
                {$output}
            </body>
        </html>
