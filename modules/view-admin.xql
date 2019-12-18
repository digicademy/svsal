xquery version "3.0";

import module namespace app       = "http://www.salamanca.school/xquery/app"                       at "app.xqm";
import module namespace config    = "http://www.salamanca.school/xquery/config"                    at "config.xqm";
import module namespace gui    = "http://www.salamanca.school/xquery/gui"                    at "gui.xqm";
import module namespace i18n      = "http://exist-db.org/xquery/i18n/templates"  at "i18n-templates.xqm";
import module namespace iiif      = "http://www.salamanca.school/xquery/iiif"                      at "iiif.xqm";
import module namespace net       = "http://www.salamanca.school/xquery/net"                       at "net.xqm";
import module namespace sphinx    = "http://www.salamanca.school/xquery/sphinx"                    at "sphinx.xqm";
import module namespace functx    = "http://www.functx.com"                      at "/db/system/repo/functx-1.0/functx/functx.xql";
import module namespace templates = "http://exist-db.org/xquery/templates" ;
import module namespace request   = "http://exist-db.org/xquery/request";
import module namespace console   = "http://exist-db.org/xquery/console";

import module namespace admin     = "http://www.salamanca.school/xquery/admin"                     at "admin.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "html5";
declare option output:media-type "text/html";
declare option exist:timeout "43200000"; (: 12 h :)


let $config := map {
    $templates:CONFIG_APP_ROOT: $config:app-root
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