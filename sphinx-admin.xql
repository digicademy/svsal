xquery version "3.0";

declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";
declare variable $snippetLength  := 1200;

let $mode   := request:get-parameter('mode',    'html')
let $wid    := request:get-parameter('wid',     'W0013')

let $output :=  admin:sphinx-out(<div/>, map{ 'dummy':= 'dummy'}, $wid, $mode)
return $output
