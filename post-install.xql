xquery version "3.0";

declare namespace repo      = "http://exist-db.org/xquery/repo";
declare namespace tei       = "http://www.tei-c.org/ns/1.0";

import module namespace xmldb      = "http://exist-db.org/xquery/xmldb";
import module namespace sm         = "http://exist-db.org/xquery/securitymanager";
import module namespace exrest = "http://exquery.org/ns/restxq/exist";

(: The following external variables are set by the repo:deploy function :)
(: the target collection into which the app is deployed :)
declare variable $target external;

declare variable $adminGrp          := "svsalAdmin";
declare variable $data-collection   := concat($target, "/data");
declare variable $adminfiles        := ($target || '/admin.html',
                                        $target || '/build.xml',
                                        $target || '/collection.xconf',
                                        $target || '/controller.xql',
                                        $target || '/createLists.html',
                                        $target || '/error-handler.xql',
                                        $target || '/expath-pkg.xml',
                                        $target || '/post-install.xql',
                                        $target || '/pre-install.xql',
                                        $target || '/reindex.xql',
                                        $target || '/renderTheRest.html',
                                        $target || '/webdata-admin.xql');


(: TODO add more modules here when necessary :)
declare variable $restModules := 
    ('xmldb://db/apps/salamanca/modules/api/v1/texts.xqm', 
     'xmldb://db/apps/salamanca/modules/api/api.xqm');


(: Define files and folders with special permissions :)
let $chmod  := 
    for $file in $adminfiles
        let $GR := sm:chgrp($file, $adminGrp)
        return  
            if ($file eq $target || '/admin.html') then
                sm:chmod($file, "rw-rwS---")
            else if ($file = ($target || '/controller.xql',
                              $target || '/error-handler.xql')) then
                sm:chmod($file, "rwxrwxr-x")
            else if (ends-with($file, '.xql')) then
                sm:chmod($file, "rwxrwx---")
            else
                sm:chmod($file, "rw-rw----")

(: Make sure RestXQ modules/functions are registered - the RestXQ servlet isn't very reliable in this regard... :)
let $registerRest :=
    for $rm in $restModules return
        (exrest:deregister-module(xs:anyURI($rm)),
         exrest:register-module(xs:anyURI($rm)))

(:let $chmod-cache := sm:chmod($target || 'services/lod/temp/cache', "rwxrwxrwx"):)

(: Run index :)
let $index-app-status := xmldb:reindex($data-collection)
return $index-app-status

(: Render all works :)
(:
for $work in collection($data-collection)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph")]]
    let $success := render:renderWork(node(), map{}, $work/@xml:id)
:)
