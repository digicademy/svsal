xquery version "3.1";

(: ####++++----

    This query serves as a gateway for the HTML-based admin interface (admin.html), dispatching requests for the 
    creation of webdata (html, snippets, rdf, etc.) to xquery functions in the admin.xqm module.
    For possible webdata modes/formats, see $output.

----++++#### :)

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://www.salamanca.school/xquery/admin" at "modules/admin.xqm";
import module namespace config    = "http://www.salamanca.school/xquery/config" at "config.xqm";
import module namespace util        = "http://exist-db.org/xquery/util";

declare option exist:timeout "43200000"; (: 12 h :)

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";

declare variable $snippetLength  := 1200;

let $start-time := util:system-time()

let $mode   := request:get-parameter('mode',    'html') (: for Sphinx, but actually used? :)
let $rid    := request:get-parameter('rid',     '')
let $format := request:get-parameter('format',     '')

let $checkIndex :=
    (: if work rendering (HTML, snippet, RDF) is requested, we need to make sure that there is an index file :)
    if (starts-with($rid, 'W0') and not($format = ('index', 'iiif', 'all'))) then
        if (doc-available($config:index-root || '/' || $rid || '_nodeIndex.xml')) then ()
        else error(xs:QName('webdata-admin.xql'), 'There is no index file.')
    else ()

let $output :=
    switch($format)
        case 'index' return 
            admin:createNodeIndex($rid)
        case 'html' return
            admin:renderWork($rid)
        case 'snippets' return 
            admin:sphinx-out($rid, $mode)
        case 'rdf' return
            admin:createRDF($rid)
        case 'tei-corpus' return
            admin:createTeiCorpus('admin')
        case 'iiif' return
            admin:createIIIF($rid)
        case 'txt-corpus' return
            admin:createTxtCorpus('admin')
        case 'all' return 
            (: all formats (except iiif) for a single work :)
            (admin:createNodeIndex($rid),
            admin:renderWork($rid),
            admin:sphinx-out($rid, $mode),
            admin:createRDF($rid))
            (: omitting iiif here :)
        case 'stats' return
            admin:createStats()
        default return 
            ()

let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000
let $runtimeString := 
    if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " seconds"
    else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " minutes"
    else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " hours"

let $debug := 
    if ($format) then 
        util:log('warn', '[WEBDATA-ADMIN] Rendered format "' || $format || '" for resource "' || $rid || '" in ' || $runtimeString || '.') 
    else ()

let $title := 
    if (not($rid)) then 
        'Webdata Output for Format "' || $format || '"'
    else 'Webdata Output for Resource(s): "' || $rid || '"; Format: "' || $format || '"'

return 
    <html>
        <head>
            <title>Webdata Administration - The School of Salamanca</title>
            <style>{'.section-title {display:none;}
                     .sal-cite-toggle {display:none !important;}
                     .sal-toolbox-body {display:none !important;}'}</style>
        </head>
        <body>
            <h1>{$title}</h1>
            {$output}
        </body>
    </html>
