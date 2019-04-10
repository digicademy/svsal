xquery version "3.0";

import module namespace app       = "http://salamanca/app"                       at "app.xql";
import module namespace config    = "http://salamanca/config"                    at "config.xqm";
import module namespace i18n      = "http://exist-db.org/xquery/i18n/templates"  at "i18n-templates.xql";
import module namespace iiif      = "http://salamanca/iiif"                      at "iiif.xql";
import module namespace rdf       = "http://salamanca/rdf"                       at "rdf.xql";
import module namespace render    = "http://salamanca/render"                    at "render.xql";
import module namespace net       = "http://salamanca/net"                       at "net.xql";
import module namespace sphinx    = "http://salamanca/sphinx"                    at "sphinx.xql";
import module namespace stats     = "http://salamanca/stats"                     at "stats.xql";
import module namespace functx    = "http://www.functx.com"                      at "/db/system/repo/functx-1.0/functx/functx.xql";
import module namespace templates = "http://exist-db.org/xquery/templates" ;
import module namespace request   = "http://exist-db.org/xquery/request";
import module namespace console   = "http://exist-db.org/xquery/console";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option exist:timeout "1800000"; (: 30 min :)

declare option output:method "html5";
declare option output:media-type "text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT := $config:app-root
}

let $lookup := function($functionName as xs:string, $arity as xs:int) {
    try {
        function-lookup(xs:QName($functionName), $arity)
    } catch * {
        ()
    }
}

let $content := request:get-data()

return
    templates:apply($content, $lookup, (), $config)