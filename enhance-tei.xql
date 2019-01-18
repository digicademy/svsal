xquery version "3.1";

import module   namespace   config       = "http://salamanca/config" at "modules/config.xqm";
import module   namespace   console     = "http://exist-db.org/xquery/console";
declare             namespace   output       = "http://www.w3.org/2010/xslt-xquery-serialization";
declare             namespace   request     = "http://exist-db.org/xquery/request";
declare             namespace   sal             = "http://salamanca.adwmainz.de";
declare             namespace   tei             = "http://www.tei-c.org/ns/1.0";
declare             namespace   util            = "http://exist-db.org/xquery/util";

declare option output:method "xml";

declare function local:copy($input as item()*, $salNodes as node()) as item()* {
for $node in $input
   return 
      typeswitch($node)
        case element()
           return
              element {name($node)} {

                (: copy all the attributes :)
                for $att in $node/@*
                    return
                        (: if we are dealing with an xml:id attribute, and this also occurs in the _nodeIndex file, pull in more attributes from there :)
                        if (name($att) = "xml:id" and $salNodes//sal:node[@n eq $att]) then
                            let $sn := $salNodes//sal:node[@n eq $att]
                            return (
                                attribute title {$sn/sal:title/text()},
                                if ($sn/sal:crumbtrail/a[last()]/@href) then attribute web {$sn/sal:crumbtrail/a[last()]/@href} else (),
                                attribute citableParent {$sn/sal:citableParent/text()},
                                attribute citetrail {$sn/sal:citetrail},
                                $att
                            )
                        else
                            attribute {name($att)} {$att}
                ,
                (: output all the child elements of this element recursively :)
                for $child in $node
                   return local:copy($child/node(), $salNodes)

              }
        (: otherwise pass it through.  Used for text(), comments, and PIs :)
        default return $node
};

let $wid           :=  request:get-parameter('wid', '')
let $debug       := if ($config:debug = ("trace", "info")) then console:log("tei enricher running, requested work " || $wid || ".") else ()

let $origTEI      := util:expand(doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI)
let $salNodesF := doc($config:data-root || '/' || $wid || '_nodeIndex.xml')/sal:index

let $output     := local:copy($origTEI, $salNodesF)

return $output