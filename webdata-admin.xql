xquery version "3.0";

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";

declare option exist:timeout "20800000"; (: 6 h :)

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";

declare variable $snippetLength  := 1200;

let $mode   := request:get-parameter('mode',    'html') (: for Sphinx, but actually used? :)
let $wid    := request:get-parameter('wid',     '')
let $format := request:get-parameter('format',     '')

(: TODO: check for current node index here :)
let $output :=
    switch($format)
        case 'index' return 
            admin:createNodeIndex(<div/>, map{'dummy':= 'dummy'}, $wid)
        case 'snippets' return 
            admin:sphinx-out(<div/>, map{ 'dummy':= 'dummy'}, $wid, $mode)
        case 'tei-corpus' return
            admin:createTeiCorpus('admin')
        case 'txt-corpus' return
            admin:createTxtCorpus('admin') 
            
        default return 
            ()

return 
    <html>
        <head>
            <title>Webdata Administration - The School of Salamanca</title>
        </head>
        <body>
            <h1>Generated Webdata Output for Work(s): {$wid}</h1>
            {$output}
        </body>
    </html>
