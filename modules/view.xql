xquery version "3.0";

declare namespace exist           = "http://exist.sourceforge.net/NS/exist";
declare namespace output          = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace console   = "http://exist-db.org/xquery/console";
import module namespace request   = "http://exist-db.org/xquery/request";
import module namespace templates = "http://exist-db.org/xquery/html-templating" ;
import module namespace lib       = "http://exist-db.org/xquery/html-templating/lib";

import module namespace app       = "http://www.salamanca.school/xquery/app"                       at "xmldb:exist:///db/apps/salamanca/modules/app.xqm";
import module namespace config    = "http://www.salamanca.school/xquery/config"                    at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace gui       = "http://www.salamanca.school/xquery/gui"                       at "xmldb:exist:///db/apps/salamanca/modules/gui.xqm";
import module namespace i18n      = "http://exist-db.org/xquery/i18n/templates"                    at "xmldb:exist:///db/apps/salamanca/modules/i18n-templates.xqm";
import module namespace iiif      = "http://www.salamanca.school/xquery/iiif"                      at "xmldb:exist:///db/apps/salamanca/modules/iiif.xqm";
import module namespace net       = "http://www.salamanca.school/xquery/net"                       at "xmldb:exist:///db/apps/salamanca/modules/net.xqm";
import module namespace sphinx    = "http://www.salamanca.school/xquery/sphinx"                    at "xmldb:exist:///db/apps/salamanca/modules/sphinx.xqm";


declare option exist:timeout "1800000"; (: 30 min :)

declare option output:method "html";
declare option output:html-version "5";
declare option output:media-type "text/html";

let $config := map {
    $templates:CONFIG_APP_ROOT: $config:app-root
}

(:
 : We have to provide a lookup function to templates:apply to help it
 : find functions in the imported application modules. The templates
 : module cannot see the application modules, but the inline function
 : below does see them.
 :)
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
