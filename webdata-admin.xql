xquery version "3.0";

declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace admin       = "http://salamanca/admin"           at "modules/admin.xql";

declare option exist:timeout "20800000"; (: 6 h :)

declare option output:media-type "text/html";
declare option output:method "xhtml";
declare option output:indent "no";

let $mode   := request:get-parameter('mode',    'html')
let $wid    := request:get-parameter('wid',     '')

let $output :=  admin:createNodeIndex(<div/>, map{'dummy':= 'dummy'}, $wid)
return 
<html>
<head>
<title>Webdata Administration - The School of Salamanca</title>
</head>
<body>
{$output}
</body>
</html>
