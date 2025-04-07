xquery version "3.1";

(: ####++++----

    This query serves as a gateway for the HTML-based admin interface (admin.html), dispatching requests for the 
    creation of webdata (html, snippets, rdf, etc.) to xquery functions in the admin.xqm module.
    For possible webdata modes/formats, see $output.

----++++#### :)

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";

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
let $rid    := request:get-parameter('rid',     '')
let $format := request:get-parameter('format',     '')
(: let$model := map{} :)

let $checkIndex :=
    (: if work rendering (HTML, snippet, RDF) is requested, we need to make sure that there is an index file :)
    if (starts-with($rid, 'W0') and not($format = ('index', 'iiif', 'crumbtrails', 'details', 'pdf_upload','pdf_create', 'routing', 'all'))) then

        if (doc-available($config:index-root || '/' || $rid || '_nodeIndex.xml')) then ()
        else error(xs:QName('webdata-admin.xql'), 'There is no index file.')
    else ()

let $output :=
    switch($format)
        case 'index' return 
            admin:createNodeIndex($rid)
        case 'pdf_upload' return
            upload:uploadPdf($rid)  
        case 'pdf_create' return
            admin:createPdf($rid)
        case 'crumbtrails' return
            admin:createCrumbtrails($rid) 
        case 'html' return
            admin:renderHTML($rid)
        case 'details' return
            admin:createDetails($rid)
        case 'snippets' return 
            admin:sphinx-out($rid, $mode)
        case 'rdf' return
            admin:createRDF($rid)
        case 'nlp' return
            admin:createNLP($rid)
        case 'tei-corpus' return
            admin:createTeiCorpus('admin')
        case 'iiif' return
            admin:createIIIF($rid)
        case 'txt-corpus' return
            admin:createTxtCorpus('admin')
        case 'stats' return
            <pre>{fn:serialize(admin:createStats("*"), map{"method":"json", "indent": true(), "encoding":"utf-8"})}</pre>
        case 'routing' return
            switch($rid)
                case 'all' return
                    admin:createRoutes()
                default return
                    admin:createRoutes($rid)
        case 'all' return 
            (: all formats (except iiif and rdf) for a single work :)
            let $debug := console:log("Rendering all formats for " || $rid || " ...")
            return
            <div>
                <div><h2>Index</h2>
                {admin:createNodeIndex($rid)}
                </div>
                <div><h2>Crumbtrails</h2>
                {admin:createCrumbtrails($rid)}
                </div>
                <div><h2>PDF</h2>
                {admin:createPdf($rid)}
                </div>
                <div><h2>HTML</h2>
                {admin:renderHTML($rid)}
                </div>
                <div><h2>Details</h2>
                {admin:createDetails($rid)}
                </div>
                <div><h2>Search Snippets</h2>
                {admin:sphinx-out($rid, $mode)}
                </div>
                <div><h2>NLP CSV</h2>
                {admin:createNLP($rid)}
                </div>
                <div><h2>Routes</h2>
                {admin:createRoutes($rid)}
                </div>
                <div><h2>Stats</h2>
                {fn:serialize(admin:createStats($rid), map{"method":"json", "indent": true(), "encoding":"utf-8"})}
                </div>
            </div>
        default return 
            ()

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

return 
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
