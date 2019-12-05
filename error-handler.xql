xquery version "3.1";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace session = "http://exist-db.org/xquery/session";
import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace util    = "http://exist-db.org/xquery/util";
import module namespace functx  = "http://www.functx.com";
import module namespace config  = "http://www.salamanca.school/xquery/config"     at "modules/config.xqm";
import module namespace net     = "http://www.salamanca.school/xquery/net"        at "modules/net.xql";
import module namespace app     = "http://www.salamanca.school/xquery/app"        at "modules/app.xql";
import module namespace iiif    = "http://www.salamanca.school/xquery/iiif"       at "modules/iiif.xql";
import module namespace i18n      = "http://exist-db.org/xquery/i18n"        at "i18n.xql";
import module namespace gui    = "http://www.salamanca.school/xquery/gui"                    at "modules/gui.xqm";

declare       namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare       namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare       namespace rdf     = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare       namespace rdfs    = "http://www.w3.org/2000/01/rdf-schema#";
declare       namespace tei     = "http://www.tei-c.org/ns/1.0";
declare       namespace sal     = "http://salamanca.adwmainz.de";


declare option output:method "html5";
declare option output:media-type "text/html";

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
declare function local:resolve-attr($node as node()) as node()? {
        if(starts-with($node, 'resources/')) then 
            attribute { node-name($node) } {
              $config:webserver || '/' || $node
            }
        else $node
};

let $existPath := substring-after(request:get-attribute('javax.servlet.error.request_uri'), '/apps/salamanca')
let $lang := net:lang($existPath)
let $debug:= console:log('Server-side error handler (error-handler.xql): Request URI: ' || request:get-attribute('javax.servlet.error.request_uri') 
                         || '. Determined exist:path: ' || $existPath || ' ; language: ' || $lang || '. Server-side error message' 
                         || request:get-attribute('javax.servlet.error.message') || '.')
let $dummyMap := map:new()
let $html-in :=
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head xmlns:i18n="http://exist-db.org/xquery/i18n" data-template="i18n:translate" data-template-catalogues="data/i18n">
            <meta charset="UTF-8"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <meta name="author" content=""/>
            {gui:metaDescription(<meta/>, $dummyMap, $lang, (), (), ())}
            {gui:metaTitle(<title/>, $dummyMap, $lang, (), (), ())}
            {gui:canonicalUrl(<link/>, $dummyMap, $lang, (), (), ())}
            {gui:hreflangUrl(<link/>, $dummyMap, $lang, (), (), ())}
            
            <!-- ==== CSS ==== -->
            <link rel="stylesheet" type="text/css" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
            <link rel="stylesheet" type="text/css" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"/>
            <link rel="stylesheet" type="text/css" href="resources/css/backTop.css"/> 
            <link rel="stylesheet" type="text/css" href="resources/css/style_default.css"/>
            
            <!-- ==== favIcon ==== -->
            <link rel="apple-touch-icon" sizes="57x57" href="resources/favicons/apple-touch-icon-57x57.png"/>
            <link rel="apple-touch-icon" sizes="60x60" href="resources/favicons/apple-touch-icon-60x60.png"/>
            <link rel="apple-touch-icon" sizes="72x72" href="resources/favicons/apple-touch-icon-72x72.png"/>
            <link rel="apple-touch-icon" sizes="76x76" href="resources/favicons/apple-touch-icon-76x76.png"/>
            <link rel="apple-touch-icon" sizes="114x114" href="resources/favicons/apple-touch-icon-114x114.png"/>
            <link rel="apple-touch-icon" sizes="120x120" href="resources/favicons/apple-touch-icon-120x120.png"/>
            <link rel="apple-touch-icon" sizes="144x144" href="resources/favicons/apple-touch-icon-144x144.png"/>
            <link rel="apple-touch-icon" sizes="152x152" href="resources/favicons/apple-touch-icon-152x152.png"/>
            <link rel="apple-touch-icon" sizes="180x180" href="resources/favicons/apple-touch-icon-180x180.png"/>
            <link rel="icon" type="image/png" href="resources/favicons/favicon-32x32.png" sizes="32x32"/>
            <link rel="icon" type="image/png" href="resources/favicons/favicon-194x194.png" sizes="194x194"/>
            <link rel="icon" type="image/png" href="resources/favicons/favicon-96x96.png" sizes="96x96"/>
            <link rel="icon" type="image/png" href="resources/favicons/android-chrome-192x192.png" sizes="192x192"/>
            <link rel="icon" type="image/png" href="resources/favicons/favicon-16x16.png" sizes="16x16"/>
            <link rel="manifest" href="resources/favicons/manifest.json"/>
            <meta name="msapplication-TileColor" content="#ffffff"/>
            <meta name="msapplication-TileImage" content="resources/favicons/mstile-144x144.png"/>
            <meta name="theme-color" content="#ffffff"/>
        </head>
        <body id="body">
            <div id="wrap">
                <div>
                    <div>
                        <h1 class="error-title">{request:get-attribute('javax.servlet.error.status_code')}</h1>
                        <h2 class="error-title"><i18n:text key="pageNotFound">This is not the page you were looking for...</i18n:text></h2>
                        <p class="error-paragraph"><i18n:text key="bugMessage">In case you found a bug in our website, please let us know at</i18n:text>{' '}<a href="mailto:info.salamanca@adwmainz.de">info.salamanca@adwmainz.de</a></p>
                        {app:serverErrorMessage(<div/>, $dummyMap)}
                    </div>
                </div>
                <div class="navbar navbar-default navbar-fixed-top" role="navigation">
                    <div class="container">
                        {gui:logo(<a/>, $dummyMap, $lang)}
                        {gui:header(<div/>, $dummyMap, $lang, (), (), (), (), ())}
                    </div>
                </div>
                
                <!-- ==== Core JavaScript ==== -->
                <script type="text/javascript" src="//code.jquery.com/jquery-1.11.3.min.js"/>
                <script async="async" type="text/javascript" src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"/>
                
                <!-- ==== jQuery Back to top ==== -->
                <a id="backTop"/>
                
                <div id="push"/>
            </div>
            <h2/>
            <div id="footer">
                <div class="container">
                    {gui:footer (<div/>, $dummyMap, $lang)}
                </div>
            </div>
            
        </body>
    </html>

let $html-out := i18n:process(local:resolve($html-in), $lang, '/db/apps/salamanca/data/i18n', 'en')

return $html-out
