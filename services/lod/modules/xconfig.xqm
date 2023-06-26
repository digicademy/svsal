xquery version "3.0";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace xconfig = "http://xtriples.spatialhumanities.de/config";

declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace system        = "http://exist-db.org/xquery/system";
declare namespace repo          = "http://exist-db.org/xquery/repo";
declare namespace expath        = "http://expath.org/ns/pkg";

import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace templates   = "http://exist-db.org/xquery/html-templating";
import module namespace lib         = "http://exist-db.org/xquery/html-templating/lib";

import module namespace config = "https://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";

(: default service locations
declare variable $xconfig:xtriplesWebserviceURL := "http://xtriples.spatialhumanities.de/";
declare variable $xconfig:any23WebserviceURL := "http://any23-vm.apache.org/";
:)

(: --- SvSal customizations: service locations, debugging level etc. --- :)
declare variable $xconfig:xtriplesWebserviceURL     := $config:lodServer;
declare variable $xconfig:any23WebserviceURL        := "http://localhost:8880/any23/any23/";
declare variable $xconfig:debug                     := "info"; (: possible values: trace, info, none :)
declare variable $xconfig:logfile                   := "xTriples.log";

(: Configure Servers :)
declare variable $xconfig:proto          := if (request:get-header('X-Forwarded-Proto') = "https") then "https" else request:get-scheme();
declare variable $xconfig:subdomains     := ("www", "blog", "facs", "search", "data", "api", "tei", "id", "files", "ldf", "software");

declare variable $xconfig:serverdomain := 
    if ($config:instanceMode = "fakeprod") then
        $config:defaultProdserver
    else if (substring-before(request:get-header('X-Forwarded-Host'), ".") = $xconfig:subdomains)
        then substring-after(request:get-header('X-Forwarded-Host'), ".")
    else if(request:get-header('X-Forwarded-Host'))
        then request:get-header('X-Forwarded-Host')
    else if(substring-before(request:get-server-name(), ".") = $xconfig:subdomains)
        then substring-after(request:get-server-name(), ".")
    else
        let $alert := if ($xconfig:debug = "trace") then console:log("Warning! Dynamic $xconfig:serverdomain is uncertain, using servername " || request:get-server-name() || ".") else ()
        return request:get-server-name()
    ;
declare variable $xconfig:idserver       := $xconfig:proto || "://id."     || $xconfig:serverdomain;
(:
declare variable $xconfig:teiserver      := $xconfig:proto || "://tei."     || $xconfig:serverdomain;
declare variable $xconfig:webserver      := $xconfig:proto || "://www."     || $xconfig:serverdomain;
declare variable $xconfig:imageserver    := $xconfig:proto || "://facs."     || $xconfig:serverdomain;
:)
(: --- SvSal customizations end --- :)

declare variable $xconfig:redeferWebserviceURL      := "http://rhizomik.net/redefer-services/";
declare variable $xconfig:redeferWebserviceRulesURL := "http://rhizomik.net:8080/html/redefer/rdf2svg/showgraph.jrule";

(: 
    Determine the application root collection from the current module load path.
:)
declare variable $xconfig:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $xconfig:repo-descriptor := doc(concat($xconfig:app-root, "/repo.xml"))/repo:meta;
declare variable $xconfig:expath-descriptor := doc(concat($xconfig:app-root, "/expath-pkg.xml"))/expath:package;

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function xconfig:resolve($relPath as xs:string) {
    if (starts-with($xconfig:app-root, "/db")) then
        doc(concat($xconfig:app-root, "/", $relPath))
    else
        doc(concat("file://", $xconfig:app-root, "/", $relPath))
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function xconfig:repo-descriptor() as element(repo:meta) {
    $xconfig:repo-descriptor
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function xconfig:expath-descriptor() as element(expath:package) {
    $xconfig:expath-descriptor
};

declare %templates:wrap function xconfig:app-title($node as node(), $model as map(*)) as text() {
    $xconfig:expath-descriptor/expath:title/text()
};

declare function xconfig:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$xconfig:repo-descriptor/repo:description/text()}"/>,
    for $author in $xconfig:repo-descriptor/repo:author
    return
        <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function xconfig:app-info($node as node(), $model as map(*)) {
    let $expath := xconfig:expath-descriptor()
    let $repo := xconfig:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$xconfig:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
            <tr>
                <td>Controller:</td>
                <td>{ request:get-attribute("$exist:controller") }</td>
            </tr>
        </table>
};
