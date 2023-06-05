xquery version "3.1";

import module   namespace   config  = "https://www.salamanca.school/xquery/config" at "modules/config.xqm";
import module   namespace   iiif    = "https://www.salamanca.school/xquery/iiif"   at "modules/iiif.xqm";
import module   namespace   console = "http://exist-db.org/xquery/console";
declare         namespace   output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare         namespace   request = "http://exist-db.org/xquery/request";
declare          namespace response = "http://exist-db.org/xquery/response";

declare option output:method "json";
declare option output:media-type "application/json";

let $facsDomain := $config:imageserver

let $canvasId           := request:get-parameter('canvasId', $facsDomain || '/iiif/presentation/W0015/canvas/p1')
let $header-addition    := response:set-header("Access-Control-Allow-Origin", "*")
let $debug              := if ($config:debug = ("trace", "info")) then console:log("iiif resolver running, requested canvasId '" || $canvasId || "'.") else ()

return iiif:getPageId($canvasId)
