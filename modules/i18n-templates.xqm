module namespace intl="http://exist-db.org/xquery/i18n/templates";

(:~
 : i18n template functions. Integrates the i18n library module. Called from the templating framework.
 :)
import module namespace templates   = "http://exist-db.org/xquery/html-templating";
import module namespace config      = "http://www.salamanca.school/xquery/config"   at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace i18n        = "http://exist-db.org/xquery/i18n"             at "xmldb:exist:///db/apps/salamanca/modules/i18n.xqm";

(:~
 : Template function: calls i18n:process on the child nodes of $node.
 : Template parameters:
 :      lang=de Language selection
 :      catalogues=relative path    Path to the i18n catalogue XML files inside database
 :)
declare function intl:translate($node as node(), $model as map(*), $lang as xs:string?, $catalogues as xs:string?) {
    let $cpath :=
        (: if path to catalogues is relative, resolve it relative to the app root :)
        if (starts-with($catalogues, "/")) then
            $catalogues
        else
            concat($config:app-root, "/", $catalogues)
    let $process := templates:process($node/*, $model)
    let $translated :=
        i18n:process($process, $lang, $cpath, ())
    return
        element { node-name($node) } {
            $node/@*,
            $translated
        }
};