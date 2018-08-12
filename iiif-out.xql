xquery version "3.1";

import module   namespace   config  = "http://salamanca/config" at "modules/config.xqm";
import module   namespace   iiif    = "http://salamanca/iiif"   at "modules/iiif.xql";
import module   namespace   console = "http://exist-db.org/xquery/console";
declare         namespace   output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare         namespace   request = "http://exist-db.org/xquery/request";
declare         namespace   response = "http://exist-db.org/xquery/response";
declare         namespace   tei     = "http://www.tei-c.org/ns/1.0";

declare option output:method "json";
declare option output:media-type "application/json";

let $wid                := request:get-parameter('wid', '')
let $header-addition   := response:set-header("Access-Control-Allow-Origin", "*")
let $debug              := if ($config:debug = ("trace", "info")) then console:log("iiif handler running, requested work: '" || $wid || "'.") else ()
let $iiif-resource := iiif:fetchResource($wid)

return $iiif-resource
