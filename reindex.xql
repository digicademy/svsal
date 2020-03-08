xquery version "3.0";

import module   namespace   config  = "http://www.salamanca.school/xquery/config"   at "modules/config.xqm";
declare         namespace   exist   = "http://exist.sourceforge.net/NS/exist";
declare         namespace   util    = "http://exist-db.org/xquery/util";
declare         namespace   xmldb   = "http://exist-db.org/xquery/xmldb";
declare         option      exist:serialize "method=xhtml media-type=text/html indent=yes";

let $data-collection := ($config:data-root,
                         $config:app-root || '/temp/cache',
                         $config:app-root || '/services/lod/temp/cache',
                         $config:tei-root,
                         $config:webdata-root)

(: let $login := xmldb:login($config:app-root, $cred:adminUsername, $cred:adminPassword) :)
let $start-time := util:system-time()
let $reindex := for $coll in $data-collection
                    return xmldb:reindex($coll)
let $runtime := ((util:system-time() - $start-time)
                        div xs:dayTimeDuration('PT1S')) (:  * 1000 :) 

return
<html>
    <head>
       <title>Reindex</title>
    </head>
    <body>
    <h1>Reindex</h1>
    <p>The index for {$data-collection} was updated in 
                 {$runtime} seconds.</p>
    <a href="index.html">svsal Home</a>
    </body>
</html>