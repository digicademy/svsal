xquery version "3.0";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace console = "http://exist-db.org/xquery/console";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:media-type "application/xml";
declare option output:indent "no";
(:declare option exist:serialize "method=xml media-type=application/xml indent=no";:)

let $resourceId         :=  request:get-parameter('resourceId', '')





And my 301.xq is:







let $output :=
    <xtriples>
       {$rawConfiguration//configuration}
       {$collection}
    </xtriples>
(:    let $dbg := console:log(serialize($output)):)

return $output
