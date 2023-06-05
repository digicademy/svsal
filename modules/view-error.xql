xquery version "3.0" encoding "UTF-8";

declare namespace exist  = "http://exist.sourceforge.net/NS/exist";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace xhtml  = "http://www.w3.org/1999/xhtml";

import module namespace console   = "http://exist-db.org/xquery/console";
import module namespace request   = "http://exist-db.org/xquery/request";
import module namespace templates = "http://exist-db.org/xquery/html-templating";
import module namespace lib       = "http://exist-db.org/xquery/html-templating/lib";

import module namespace app       = "https://www.salamanca.school/xquery/app"                        at "xmldb:exist:///db/apps/salamanca/modules/app.xqm";
import module namespace config    = "https://www.salamanca.school/xquery/config"                     at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace gui       = "https://www.salamanca.school/xquery/gui"                        at "xmldb:exist:///db/apps/salamanca/modules/gui.xqm";
import module namespace iiif      = "https://www.salamanca.school/xquery/iiif"                       at "xmldb:exist:///db/apps/salamanca/modules/iiif.xqm";
import module namespace i18n      = "http://exist-db.org/xquery/i18n/templates"                     at "xmldb:exist:///db/apps/salamanca/modules/i18n-templates.xqm";
import module namespace net       = "https://www.salamanca.school/xquery/net"                        at "xmldb:exist:///db/apps/salamanca/modules/net.xqm";
import module namespace sphinx    = "https://www.salamanca.school/xquery/sphinx"                     at "xmldb:exist:///db/apps/salamanca/modules/sphinx.xqm";


declare option exist:timeout "1800000"; (: 30 min :)

declare option output:method "html";
declare option output:html-version "5";
declare option output:media-type "text/html";

(:~
~ Resolves (copies or transforms) an html (doc/element/..., but not attribute) node.
~:)
declare function local:resolve($node as node()) as node()? {
    typeswitch ($node)
        case document-node() return
            for $child in $node/node() return local:resolve($child)
        case element() return
            element {node-name($node)} {
                for $attr in $node/@* return local:resolve-attr($attr),
                for $child in $node/node() return local:resolve($child)
            }
        case comment() return ()
        default return 
            $node
};

(:~
~ Resolves (copies or transforms) an html attribute node.
~:)
declare function local:resolve-attr($node as node()) as node()? {
    if(starts-with($node, 'resources/')) then 
        attribute { node-name($node) } {
          $config:webserver || '/' || $node
        }
    else $node
};

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

let $processed := templates:apply($content, $lookup, (), $config)

let $debug:= console:log('Application-side error handler (view-error.xql): Request URI: ' || request:get-uri() 
                            || '. Effective URI: ' || request:get-effective-uri() || ' . Context path: ' || request:get-context-path() 
                            || ' . Language: ' || request:get-attribute('lang') || '. Error message: ' || request:get-attribute('error-message') || '.')

return local:resolve($processed)
    