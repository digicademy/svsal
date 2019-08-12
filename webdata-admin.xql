xquery version "3.0";

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin" at "modules/admin.xql";
import module namespace config    = "http://salamanca/config" at "config.xqm";

declare option exist:timeout "20800000"; (: 6 h :)

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";

declare variable $snippetLength  := 1200;

let $mode   := request:get-parameter('mode',    'html') (: for Sphinx, but actually used? :)
let $rid    := request:get-parameter('rid',     '')
let $format := request:get-parameter('format',     '')

let $checkIndex :=
    (: if work rendering (HTML, snippet, RDF) is requested, we need to make sure that there is an index file :)
    if (starts-with($rid, 'W0') and $format != ('index', 'all')) then
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
        case 'txt-corpus' return
            admin:createTxtCorpus('admin')
        case 'all' return
            (admin:createNodeIndex($rid),
            admin:renderWork($rid),
            admin:sphinx-out($rid, $mode),
            admin:createRDF($rid))
        default return 
            ()
        (: TODO: iiif-admin :)

return 
    <html>
        <head>
            <title>Webdata Administration - The School of Salamanca</title>
            <style>{'.section-title {display:none;}
                     .sal-cite-toggle {display:none !important;}
                     .sal-toolbox-body {display:none !important;}'}</style>
        </head>
        <body>
            <h1>Webdata Output for Resource(s): {$rid}</h1>
            {$output}
        </body>
    </html>
