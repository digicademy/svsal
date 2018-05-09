xquery version "3.0";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace session = "http://exist-db.org/xquery/session";
import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace util    = "http://exist-db.org/xquery/util";
import module namespace functx  = "http://www.functx.com";
import module namespace config  = "http://salamanca/config" at "modules/config.xqm";
import module namespace net     = "http://salamanca/net"    at "modules/net.xql";
import module namespace render  = "http://salamanca/render" at "modules/render.xql";

declare       namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare       namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare       namespace rdf     = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare       namespace rdfs    = "http://www.w3.org/2000/01/rdf-schema#";
declare       namespace tei     = "http://www.tei-c.org/ns/1.0";
declare       namespace sal     = "http://salamanca.adwmainz.de";

declare option output:method "xml";
declare option output:media-type "application/xml";
declare option output:indent "yes";
declare option output:omit-xml-declaration "no";
declare option output:encoding "utf-8";

(: *** Todo: - Content negotiate X-Forwarded-Host={serverdomain} without subdomain
   ***       - Why are no hashes handled? Some are needed but lost. (http://bla.com/bla/bla.html?bla<#THISHERE!>)
   ***       - Error Handling and Logging:
   ***          - Copy logging method from services/lod/extract.xql
   ***          - Handle all "else ()" and error <dispatch>es: Print error, request info to log, redirect to homepage, give error message
   ***       - Sanitize/check all input (parameters)
   ***       - Refactor and test language selection
   ***       - See at API functions
   *** :)

(: Get request, session and context information :)
declare variable $exist:path        external;
declare variable $exist:resource    external;
declare variable $exist:controller  external;
declare variable $exist:prefix      external;
declare variable $exist:root        external;

let $lang                     :=
(:
                    if (net:request:get-parameter-names($net-vars) = ('en', 'de', 'es')) then
                        let $pathLang :=      if ('de' = net:request:get-parameter-names($net-vars)) then 'de'
                                         else if ('es' = net:request:get-parameter-names($net-vars)) then 'es'
                                         else if ('en' = net:request:get-parameter-names($net-vars)) then 'en'
                                         else $config:defaultLang
                        let $set := request:set-attribute('lang', $pathLang)
                        return $pathLang
:)
                    if (request:get-parameter-names() = 'lang') then
                        if (request:get-parameter('lang', 'dummy-default-value') = ('de', 'en', 'es')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 1a: lang parameter-name and valid value present.") else ()
                            let $set := request:set-attribute('lang', request:get-parameter('lang', $config:defaultLang))
                            return request:get-parameter('lang', $config:defaultLang)
                        else
                            let $debug :=  if ($config:debug = "trace") then console:log("case 1b: lang parameter-name but invalid value present.") else ()
                            let $set := request:set-attribute('lang', $config:defaultLang)
                            return $config:defaultLang
                    else if (matches($exist:path, '/(de|en|es)/')) then
                        if (contains($exist:path, '/de/')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 2a: 'de' path component present.") else ()
                            let $set := request:set-attribute('lang', 'de')
                            return 'de'
                        else if (contains($exist:path, '/en/')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 2b: 'en' path component present.") else ()
                            let $set := request:set-attribute('lang', 'en')
                            return 'en'
                        else if (contains($exist:path, '/es')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 2c: 'es' path component present.") else ()
                            let $set := request:set-attribute('lang', 'es')
                            return 'es'
                        else ()
                    else if(exists(session:get-attribute('lang'))) then
                        if (session:get-attribute('lang') = ('de', 'en', 'es')) then
                            let $debug2 :=  if ($config:debug = "trace") then console:log("case 3a: lang session attribute and valid value present.") else ()
                            let $set := request:set-attribute('lang', session:get-attribute('lang'))
                            return session:get-attribute('lang')
                        else
                            let $debug2 :=  if ($config:debug = "trace") then console:log("case 3b: lang session attribute but invalid value present.") else ()
                            let $set := request:set-attribute('lang', $config:defaultLang)
                            return $config:defaultLang
                    else if(request:get-header('Accept-Language')) then
                        let $debug2 :=  if ($config:debug = "trace") then console:log("case 4: Accept-Language request header present.") else ()
                        let $headerLang :=      if (substring(request:get-header('lang'),1,2) = 'de') then 'de'
                                                else if (substring(request:get-header('lang'),1,2) = 'es') then 'es'
                                                else if (substring(request:get-header('lang'),1,2) = 'en') then 'en'
                                                else $config:defaultLang
                        let $set := request:set-attribute('lang', $headerLang)
                        return $headerLang
                    else
                        let $debug2 :=  if ($config:debug = "trace") then console:log("case 5: set default language.") else ()
                        let $set := request:set-attribute('lang', $config:defaultLang)
                        return $config:defaultLang

let $net-vars       := map {
                            'path'          : $exist:path,
                            'resource'      : $exist:resource,
                            'controller'    : $exist:controller,
                            'prefix'        : $exist:prefix,
                            'root'          : $exist:root,
                            'lang'          : $lang,
                            'accept'        : $net:requestedContentTypes,
                            'params'        : (for $p in request:get-parameter-names() return $p || "="  || request:get-parameter($p, ()) (:, tokenize($exist:path, '/') :) )
                           }
let $parameterString := if (count(request:get-parameter-names())) then
                                "?" || string-join($net-vars('params'), '&amp;')
                        else ()



(: Print request context for debugging :)
let $debug :=  if ($config:debug = "trace") then
                        console:log("Request at '" || request:get-header('X-Forwarded-Host') || "' for " || request:get-effective-uri() || "&#x0d; " ||
                                    "HEADERS (" || count(request:get-header-names()) || "): "    || string-join(for $h in request:get-header-names()    return $h || ": " || request:get-header($h), ' ')    || "&#x0d; " ||
                                    "ATTRIBUTES (" || count(request:attribute-names()) || "): " || string-join(for $a in request:attribute-names()     return $a || ": " || request:get-attribute($a), ' ') || "&#x0d; " ||
                                    "PARAMETERS (" || count($net-vars('params')) ||"): " || string-join($net-vars('params'), '&amp;') ||
                                    "ACCEPT (" || count($net-vars('accept')) || "): " || string-join($net-vars('accept'), ',')
                                   )
                else ()
let $debug2 :=  if ($config:debug = "trace") then
                        console:log("$lang: " || $lang || ".")
                else ()
(: *** TODO: reflect variables defined above...
   *** :)

let $errorhandler := if (($config:instanceMode = "staging") or ($config:debug = "trace")) then ()
                       else
                            <error-handler>
                                <forward url="{$exist:controller}/en/error-page.html" method="get"/>
                                <forward url="{$exist:controller}/modules/view.xql"/>
                            </error-handler>

return
(: *** AW: Warum ist das auskommentiert? War ich das selbst? (Suchmaschinen greifen auf servername/.well-known/void zu.)
   *** :)
(:  else if (ends-with($exist:path, "/.well-known/void")) then
        net:redirect("../void.ttl", $net-vars)
:)

    (: *** Redirects for special resources (favicons, robots.txt, sitemap; specified by name *** :)
    if ($exist:resource = "favicon.ico") then
        let $debug          := if ($config:debug = "trace") then console:log("Favicon requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        return net:forward("/resources/favicons/favicon.ico", $net-vars)
    else if ($exist:resource = "robots.txt") then
        let $debug          := if ($config:debug = "trace") then console:log("Robots.txt requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        let $parameters     := <exist:add-parameter name="Cache-Control" value="max-age=3600, must-revalidate"/>
        return net:forward("/robots.txt", $net-vars, $parameters)
    else if (matches($exist:path, '^/sitemap(_index)?.xml$') or
             matches($exist:path, '^/sitemap_(en|de|es).xml(.(gz|zip))?$')) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Sitemap requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        return net:sitemapResponse($net-vars)

    (: Pass all requests to admin HTML files through view-admin.xql, which handles HTML templating and is aware of admin credentials/routines :)
(: *** AW: Brauchen wir das noch? Wir haben keine vertraulichen Credentials mehr und die Berechtigungen kann man doch durch die "File"-Berechtigungen auf admin.xql
   ***     und den html-Dateien regeln.
   *** :)
    else if (matches($exist:resource, "(admin.html)|(admin-svn.html)|(render.html)|(renderTheRest.html)|(createLists.html)|(sphinx-admin.xql)|(rdf-admin.xql)|(iiif-admin.xql)")) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Admin page requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        (: For now, we don't use net:forward here since we need a nested view/forwarding. :)
        return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <view>
                    <forward url="{$exist:controller}/modules/view-admin.xql">
                        <set-attribute name="$exist:prefix" value="{$exist:prefix}"/>
                        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                    </forward>
                </view>
                {$errorhandler}
            </dispatch>

    (: We have a request with (almost) empty path to unqualified domain name or {serverdomain} -> redirect to homepage :)
    else if (request:get-header('X-Forwarded-Host') = ("", "www." || $config:serverdomain) and $exist:path = ("", "/", "/en", "/es", "/de", "/en/", "/es/", "/de/") ) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Homepage requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        let $absolutePath   := concat($config:proto, "://", if ($net:forwardedForServername) then $net:forwardedForServername else "www." || $config:serverdomain, '/', $lang, '/index.html',
                                        if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                        string-join(net:inject-requestParameter('', ''), '&amp;')
                                     )
        return net:redirect($absolutePath, $net-vars)


(: === API functions (X-Forwarded-Host='api.{serverdomain}') === :)
(: We have the following API areas, accessible by path component:
   1. Search (/search) (Forwards to opensphinxsearch.)
   2. CodeSharing (/codesharing) (To expose TEI tag usage. See https://api.{$config:serverdomain}/codesharing/codesharing.html or https://mapoflondon.uvic.ca/BLOG10.htm) 
   3. lod (/lod) (Extract rdf from xml with xtriples.      See https://api.{$config:serverdomain}/lod/xtriples.html            or http://xtriples.spatialhumanities.de/index.html)
      (*** AW: Where does this differ from data.{$config:serverdomain}? Do we need both? ***)
   4. text/plain          export (/txt) (As of now, only for works)
   5. application/tei+xml export (/tei) (As of now, only for works)
   6. iiif (Transform salamanca ids into info.json addresses (/iiif)
:)
(: *** TODO: - Clean up and *systematically* offer only https://api.{$serverdomain}/{function}/{resource} and/equal to https://{function}.{$serverdomain}/{resource}
   ***         (Should we better refactor this into higher-level cases instead of cases under api.{$config:serverdomain} and then again all the subdomains at another place?)
   ***       - Also switch based on mime-type, not only $exist:path? As an example, see "4. txt" below.
   ***       - Add application/pdf, application/json, text/html, tei-simple?
   *** :)

    else if (request:get-header('X-Forwarded-Host') = "api." || $config:serverdomain and (
                                                                                                contains($exist:path, "/search/")
                                                                                             or contains($exist:path, "/codesharing/")
                                                                                             or contains($exist:path, "/lod/")
                                                                                             or contains($exist:path, "/txt/")
                                                                                             or contains($exist:path, "/tei/")
                                                                                             or contains($exist:path, "/iiif/"))
                                                                                          ) then

        if (starts-with($exist:path, "/search/")) then
            let $debug1         := if ($config:debug = ("trace", "info")) then console:log("Search requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $absolutePath   := concat($config:searchserver, '/', substring-after($exist:path, '/search/'))
            return net:redirect($absolutePath, $net-vars)

        else if (starts-with($exist:path, "/codesharing/")) then
            let $debug1         := if ($config:debug = ("trace", "info")) then console:log("Codesharing requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $parameters     := <exist:add-parameter name="outputType" value="html"/>
            return
                   if (ends-with($exist:resource, 'index.html') or
                       ends-with($exist:resource, 'codesharing.html') or
                       ends-with($exist:resource, 'codesharing.htm') or
                       ends-with($exist:resource, 'codesharing.xhtml')) then                        (: Main service HTML page.  :)
                           net:forward('/services/codesharing/codesharing.xql', $net-vars, $parameters)
              else if (ends-with($exist:resource, 'codesharing_protocol.xhtml')) then               (: Protocol description html file. :)
                           net:forward('/services/codesharing/codesharing_protocol.xhtml', $net-vars)
              else                                                                                  (: All other cases. This means that e.g. '/codesharing.xml', '/codesharing.xql' or even '/codesharing/' will work. :)
                           net:forward('/services/codesharing/codesharing.xql', $net-vars)

        else if (starts-with($exist:path, "/lod/")) then
            let $debug1         := if ($config:debug = ("trace", "info")) then console:log("XTriples requested: " || $net:forwardedForServername || $exist:path || $parameterString || " ...") else ()
            return
                if ($exist:path = ("/lod/extract.xql", "/lod/createConfig.xql", "/lod/xtriples.html", "/lod/changelog.html", "/lod/documentation.html", "/lod/examples.html")) then
                    net:forward('/services' || $exist:path, $net-vars)
                else ()

        else if (starts-with($exist:path, "/txt/") or net:negotiateContentType($net:servedContentTypes, '') = 'text/plain') then
            let $debug1         := if ($config:debug = ("trace", "info")) then console:log("TXT requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $reqResource    := replace(tokenize($exist:path, '/')[last()], '\|', '/')
            let $reqWork        := tokenize($exist:path, ':')[1]
            let $node           := net:findNode($reqResource)
            let $dummy          := (util:declare-option("output:method", "text"),
                                    util:declare-option("output:media-type", "text/plain"))
            let $debug2         := if ($config:debug = "trace") then console:log("Serializing options: method:" || util:get-option('output:method') ||
                                                                                                ', media-type:' || util:get-option('output:media-type') ||
                                                                                                '.') else ()
            return  if (contains($reqWork, '.orig')) then
                        render:dispatch($node, 'orig')
                    else
                        render:dispatch($node, 'edit')

        else if (starts-with($exist:path, "/xml/") or net:negotiateContentType($net:servedContentTypes, '') = ('application/tei+xml', 'text/xml')) then
            let $debug1         := if ($config:debug = ("trace", "info")) then console:log ("TEI/XML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $reqResource    := tokenize($exist:path, '/')[last()]
            let $reqWork        := tokenize(tokenize($reqResource, ':')[1], '\.')[2]
            let $dummy          := (util:declare-option("output:method", "xml"),
                                    util:declare-option("output:media-type", "application/tei+xml"),
                                    util:declare-option("output:indent", "yes"),
                                    util:declare-option("output:expand-xincludes", "yes")
                                   )
            let $debug2         := if ($config:debug = "trace") then console:log("Serializing options: method:" || util:get-option('output:method') ||
                                                                                            ', media-type:' || util:get-option('output:media-type') ||
                                                                                            ', indent:'     || util:get-option('output:indent') ||
                                                                                            ', expand-xi:'  || util:get-option('output:expand-xincludes') ||
                                                                                            '.') else ()
            let $doc            := if (doc-available($config:tei-works-root || '/' || $reqWork || '.xml')) then
                                     util:expand(doc($config:tei-works-root || '/' || $reqWork || '.xml')/tei:TEI)
                                   else
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/en/error-page.html" method="get"/>
                                        <view>
                                            <forward url="{$exist:controller}/modules/view.xql">
                                                <set-attribute name="lang"              value="{$lang}"/>
                                                <set-attribute name="$exist:resource"   value="{$exist:resource}"/>
                                                <set-attribute name="$exist:prefix"     value="{$exist:prefix}"/>
                                                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                                            </forward>
                                        </view>
                                        {$errorhandler}
                                    </dispatch>
            let $debug3         := if ($config:debug = "trace") then console:log ("deliver doc: " || $reqResource || " -> " || $reqWork || '.xml' || ".") else ()
            return
                $doc

        else if (starts-with($exist:path, "/iiif/")) then
            let $debug1         := if ($config:debug = ("trace", "info")) then console:log("iiif requested: " || $net:forwardedForServername || $exist:path || $parameterString || " ...") else ()
            let $reqResource    := tokenize(tokenize($exist:path, '/iiif/')[last()], '/')[1]
            let $iiif-paras     := string-join(subsequence(tokenize(tokenize($exist:path, '/iiif/')[last()], '/'), 2), '/')
            let $work           := tokenize(tokenize($reqResource, ':')[1], '\.')[2]   (: group.work[.edition]:pass.age :)
            let $passage        := tokenize($reqResource, ':')[2]
            let $entityPath     := concat($work, if ($passage) then concat('#', $passage) else ())
            let $debug2         := if ($config:debug = "trace") then console:log("Load metadata from " || $config:rdf-root || '/' || $work || '.rdf' || " ...") else ()
            let $metadata       := doc($config:rdf-root || '/' || $work || '.rdf')
            let $debug3         := if ($config:debug = "trace") then console:log("Retrieving $metadata//rdf:Description[@rdf:about = '']/rdfs:seeAlso[1]/@rdf:resource[contains(., '.html')]") else ()

            let $images         := for $url in $metadata//rdf:Description[@rdf:about = 'http://id.' || $config:serverdomain || '/' || $reqResource]/rdfs:seeAlso/@rdf:resource/string()
                                   where matches($url, "\.(jpg|jpeg|png|tif|tiff)$")
                                   return $url
            let $image          := $images[1]
            let $prefix         := "facs." || $config:serverdomain || "/iiif/"
            let $filename       := tokenize($image, '/')[last()]
            let $debug4         := if ($config:debug = ("trace")) then console:log("filename = " || $filename) else ()
            let $fullpathname   := if (matches($filename, '\-[A-Z]\-')) then
                                         concat(string-join(($work, substring(string-join(functx:get-matches($filename, '-[A-Z]-'), ''), 2, 1), functx:substring-before-last($filename, '.')), '%C2%A7'), '/', $iiif-paras)
                                    else
                                         concat(string-join(($work, functx:substring-before-last($filename, '.')), '%C2%A7'), '/', $iiif-paras)

            let $resolvedURI    := concat($prefix, $fullpathname)
            let $debug5         := if ($config:debug = ("trace", "info")) then console:log("redirecting to " || $resolvedURI) else ()

            return net:redirect($resolvedURI, $net-vars)

        else ()
(: === End API functions === :)


(: === Entity resolver (X-Forwarded-Host = 'id.{$config:serverdomain}') === :)
(:     303-Redirects:
    If html is the preferred data type, we look up the entity at data.{$config:serverdomain}, retrieve the
        rdfs:seeAlso value and forward to there ...
    If rdf is the preferred data type, we forward to data.{$config:serverdomain}/works.W0004 or data.{$config:serverdomain}/authors.A0099
    If image/* is the preferred data type
        and resource refers to a node of type "pb",
            and we have a seeAlso that ends in jpg, tiff or png (?) then forward to there ...
:)
    else if (request:get-header('X-Forwarded-Host') = "id." || $config:serverdomain) then
        let $debug1                  := if ($config:debug = ("trace", "info")) then console:log("Id requested: " || $net:forwardedForServername || $exist:path || $parameterString || ". (" || net:negotiateContentType($net:servedContentTypes, '') || ')') else ()

        return
            if (net:negotiateContentType($net:servedContentTypes, '') = ('text/html', 'application/xhtml+xml')) then
                if (starts-with($exist:resource, 'works.W0') or starts-with($exist:resource, 'authors.A0')) then
                    let $reqResource  := tokenize($exist:path, '/')[last()]
                    let $work         := tokenize(tokenize($reqResource, ':')[1], '\.')[2]   (: group.work:pass.age :)
                    let $passage      := tokenize($reqResource, ':')[2]
                    let $entityPath   := concat($work, if ($passage) then concat('#', $passage) else ())
                    let $debug2       := if ($config:debug = ("trace", "info")) then console:log("Html is acceptable. Load metadata from " || $config:rdf-root || '/' || $work || '.rdf' || " ...") else ()
                    let $metadata     := doc($config:rdf-root || '/' || $work || '.rdf')
                    let $debug3       := if ($config:debug = ("trace", "info")) then console:log("Retrieving $metadata//rdf:Description[@rdf:about = $reqResource]/rdfs:seeAlso[1]/@rdf:resource[contains(., '.html')]") else ()
                    let $resolvedPath := string(($metadata//*[@rdf:about eq $reqResource]/rdfs:seeAlso[1]/@rdf:resource[contains(., ".html")])[1])
                    let $pathname     := if (contains($resolvedPath, '?')) then
                                            substring-before($resolvedPath, '?')
                                         else if (contains($resolvedPath, '#')) then
                                            substring-before($resolvedPath, '#')
                                         else
                                            $resolvedPath
                    let $searchexp    := if (contains($resolvedPath, '?')) then
                                            if (contains(substring-after($resolvedPath, '?'), '#')) then
                                                substring-before(substring-after($resolvedPath, '?'), '#')
                                            else
                                                substring-after($resolvedPath, '?')
                                         else ()
                    let $params       := substring-after($parameterString, "?")
                    let $newsearchexp := concat(if ($params or $searchexp) then "?" else (), string-join(($searchexp, $params), "&amp;"))
                    let $hash         := if (contains($resolvedPath, '#')) then concat('#', substring-after($resolvedPath, '#')) else ()
                    let $debug4       := if ($config:debug = ("trace", "info")) then console:log("Redirecting to " || $pathname || $newsearchexp || $hash || " ...") else ()
                    return net:redirect-with-303($pathname || $newsearchexp || $hash )
                 else
                    let $debug2       := if ($config:debug = ("trace", "info")) then console:log("Html is acceptable, but bad input. Redirect (303) to error webpage ...") else ()
                    return net:redirect-with-404($config:webserver || '/' || 'error-page.html')
            else if (net:negotiateContentType($net:servedContentTypes, '') = ('application/rdf+xml', 'application/xml')) then
                if (starts-with($exist:resource, 'works.W') or starts-with($exist:resource, 'authors.A')) then
                    let $reqResource  := tokenize($exist:path, '/')[last()]
                    let $work         := tokenize(tokenize($reqResource, ':')[1], '\.')[2]   (: group.work:pass.age :)
                    let $passage      := tokenize($reqResource, ':')[2]
                    let $resolvedPath := concat($work, if ($passage) then concat('#', $config:idserver || '/' || $reqResource) else ()) (: Todo: Check how to address the necessary node(s) ... :)
(: *** AW: Are we doing the right thing here? It should be data.{$config:serverdomain}/works.W0004 (and that should be handled there)... :)
                    let $debug2       := if ($config:debug = ("trace", "info")) then console:log("Rdf is acceptable - redirect (303) to " || $config:dataserver || '/' || $resolvedPath || " ...") else ()
                    return net:redirect-with-303($config:dataserver || '/' || $resolvedPath)
                 else
                    let $debug2       := if ($config:debug = ("trace", "info")) then console:log("Rdf is acceptable, but we have bad input somehow. Redirect (303) to error webpage ...") else ()
                    return net:redirect-with-404($config:webserver || '/' || 'error-page.html')
            else if (starts-with(net:negotiateContentType($net:servedContentTypes, ''), 'image/')) then
                    let $reqResource  := tokenize($exist:path, '/')[last()]
                    let $work         := tokenize(tokenize($reqResource, ':')[1], '\.')[2]   (: group.work:pass.age :)
                    let $passage      := tokenize($reqResource, ':')[2]
                    let $metadata     := doc($config:rdf-root || '/' || $work || '.rdf')
                    let $debug2       := if ($config:debug = "trace") then console:log("Retrieving $metadata//rdf:Description[@rdf:about = $reqResource]/rdfs:seeAlso/@rdf:resource/string()") else ()
                    let $resolvedPaths := for $url in $metadata//rdf:Description[@rdf:about = $reqResource]/rdfs:seeAlso/@rdf:resource/string()
                                          where matches($url, "\.(jpg|jpeg|png|tif|tiff)$")
                                          return $url
                    let $resolvedPath := $resolvedPaths[1]
                    let $debug3       := if ($config:debug = ("trace", "info")) then console:log("Redirecting to " || $resolvedPath || " ...") else ()
                    return net:redirect-with-303($resolvedPath)
            else
                    let $debug2       := if ($config:debug = ("trace", "info")) then console:log("No meaningful Accept header.") else ()
                    return net:redirect-with-404($config:webserver || '/' || 'error-page.html')

    
    (: data request :)
(: *** AW: I suggest to remove all non-data (i.e. html and xml) stuff from this X-forwarded-Host. *** :)
    else if (request:get-header('X-Forwarded-Host') = "data." || $config:serverdomain) then
        let $debug                  := if ($config:debug = ("trace", "info")) then console:log("Data requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return
(: Cases:

    0. void.ttl
    1. *.rdf                                                OK
    2. *.html           -> www.{serverdomain}                          OK
    3. *.xml            -> tei.{serverdomain}                          OK,   But what about other xml files -> software.{serverdomain}/rest
     4. content negotiate
        4a. Accept-Header: html
            4a1. list of resources
                4a1a. www list of works
                4a1b. www list of authors/persons
            4a2. single resource
                4a2a. www work
                4a2b. www author
        4b. Accept-header: rdf
            4b1. list of resources
                4b1a. rdf list of works
                4b1b. rdf list of authors/persons
            4b2. single resource
                4b2a. rdf work
                4b2b. rdf author

:)

(: LOD 0. We have a request for Metadata (Data about the dataset) :)
        if ($exist:resource = "void.ttl") then
            net:forward("void.ttl", $net-vars)
(: LOD 1. We have a request for a specific resource and a *.rdf filename :)
        else if (ends-with($exist:path, '.rdf')) then
            let $debug          := if ($config:debug = ("trace", "info")) then console:log("LOD requested (Case 1): " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $resourceId     := substring-after(substring-before($exist:resource, '.rdf'), '.')
            return  if ($resourceId || '.rdf' = xmldb:get-child-resources($config:rdf-root) and not("nocache" = request:get-parameter-names())) then
                        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Loading " || $resourceId || " ...") else ()
                        return net:forward('../../..' || $config:rdf-root || '/' || $resourceId || '.rdf', $net-vars)
                    else
                        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Generating rdf for " || $resourceId || " ...") else ()
                        let $path           := '/services/lod/extract.xql'
                        let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/createConfig.xql?resourceId=' || $resourceId || '&amp;format=' || $config:lodFormat}"/>,
                                                <exist:add-parameter name="format"          value="{$config:lodFormat}"/>)
                        return net:forward($path, $net-vars, $parameters)

(: LOD 2. We have a request for a specific resource, but a *.html filename :)
        else if ((contains($exist:path, '/authors/') or contains($exist:path, '/works/')) and ends-with($exist:resource, '.html')) then
            let $debug        := if ($config:debug = ("trace", "info")) then console:log("LOD requested (Case 2): " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $workOrAuthor := if (contains($exist:path, '/authors/')) then
                                    '/author.html?aid='
                                 else if (contains($exist:path, '/works/')) then
                                    '/work.html?wid='
                                 else ()
            let $resolvedPath := $config:webserver || $workOrAuthor || substring-before($exist:resource, '.htm')
            let $debug        := if ($config:debug = "trace") then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
            return net:redirect-with-303($resolvedPath)


(: LOD 3. We have a request for a data xml file :)
        else if ((contains($exist:path, '/authors/') or contains($exist:path, '/works/')) and ends-with($exist:path, '.xml')) then
            let $debug        := if ($config:debug = ("trace", "info")) then console:log("LOD requested (Case 3): " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $resolvedPath := $config:teiserver || '/' || $exist:resource
            let $debug        := if ($config:debug = ("trace", "info")) then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
            return net:redirect-with-303($resolvedPath)

(: LOD 4. We have a request for a specific resource, but have to content negotiate :)
        else
            let $debug := if ($config:debug = ("trace", "info")) then console:log("LOD requested (Case 4): " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            return
                if (count(functx:value-intersect($net:requestedContentTypes, ('text/html','application/xhtml+xml')))) then     (: Todo: Make it aware of weighted preferences. :)
                    let $debug := if ($config:debug = "trace") then console:log("4a. html is acceptable.") else ()
                    return switch ($exist:path)
                        case "/works"
                        case "/works/"
                            return
                                let $debug        := if ($config:debug = "trace") then console:log("4a1a. html list of works") else ()
                                let $resolvedPath := $config:webserver || "/" || $lang || "/works.html"
                                let $debug        := if ($config:debug = "trace") then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
                                return net:redirect-with-303($resolvedPath)
                        case "/authors"
                        case "/authors/"
                        case "/persons"
                        case "/persons/"
                            return
                                let $debug        := if ($config:debug = "trace") then console:log("4a1b. html list of authors") else ()
                                let $resolvedPath := $config:webserver || "/" || $lang || "/authors.html"
                                let $debug        := if ($config:debug = "trace") then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
                                return net:redirect-with-303($resolvedPath)
                        default
                            return
                                let $workOrAuthor := if (contains($exist:path, '/works/') or starts-with($exist:resource, 'W0') or starts-with($exist:resource, 'works.')) then
                                                        let $debug := if ($config:debug = "trace") then console:log("4a2a. html view of single work") else ()
                                                        return '/work.html?wid='
                                                     else if (contains($exist:path, '/authors/') or starts-with($exist:resource, 'A0') or starts-with($exist:resource, 'authors.')) then
                                                        let $debug := if ($config:debug = "trace") then console:log("4a2b. html view of single author") else ()
                                                        return '/author.html?aid='
                                                     else
                                                        let $debug := if ($config:debug = "trace") then console:log("4a2c. bad input") else ()
                                                        return '/index.html'
                                let $resourceId   := if (contains($exist:resource, 'works.') or contains($exist:resource, 'authors.')) then
                                                        tokenize($exist:resource, '\.')[2]
                                                     else
                                                        $exist:resource
                                let $resolvedPath := $config:webserver || "/" || $lang || $workOrAuthor || $resourceId
                                let $debug        := if ($config:debug = "trace") then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
                                return net:redirect-with-303($resolvedPath)

                else if (count(functx:value-intersect($net:requestedContentTypes, ('application/rdf+xml','application/xml','*/*')))) then
                    let $debug          := if ($config:debug = "trace") then console:log("4b. rdf is acceptable.") else ()
                    let $extractPath    := '/services/lod/extract.xql'
                    let $format         := request:get-parameter('format', $config:lodFormat)
                    return switch ($exist:path)
                        case "/works"
                        case "/works/"
                            return
                                let $debug          := if ($config:debug = "trace") then console:log("4b1a. rdf list of works") else ()
                                let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/svsal-xtriples-workslist.xml'}"/>,
                                                        <exist:add-parameter name="format"          value="{$format}"/>)
                                return net:forward($extractPath, $net-vars, $parameters)
                       case "/authors"
                        case "/authors/"
                        case "/persons"
                        case "/persons/"
                            return
                                let $debug        := if ($config:debug = "trace") then console:log("4a1b. html list of authors") else ()
                                let $resolvedPath := $config:webserver || "/authors.html"
                                let $debug        := if ($config:debug = "trace") then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
                                return net:redirect-with-303($resolvedPath)
                        default
                            return
                                let $workOrAuthor := if (contains($exist:path, '/works/') or starts-with($exist:resource, 'W0')) then
                                                        let $debug := if ($config:debug = "trace") then console:log("4a2a. html view of single work") else ()
                                                        return '/work.html?wid='
                                                     else if (contains($exist:path, '/authors/') or starts-with($exist:resource, 'A0')) then
                                                        let $debug := if ($config:debug = "trace") then console:log("4a2b. html view of single author") else ()
                                                        return '/author.html?aid='
                                                     else
                                                        let $debug := if ($config:debug = "trace") then console:log("4a2c. bad input") else ()
                                                        return '/index.html'
                                let $resolvedPath := $config:webserver || $workOrAuthor || tokenize($exist:resource, '\.')[1]
                                let $debug        := if ($config:debug = "trace") then console:log("Redirecting (303) to " || $resolvedPath || " ...") else ()
                                return net:redirect-with-303($resolvedPath)

                else if (count(functx:value-intersect($net:requestedContentTypes, ('application/rdf+xml','application/xml','*/*')))) then
                    let $debug          := if ($config:debug = "trace") then console:log("4b. rdf is acceptable.") else ()
                    let $extractPath    := '/services/lod/extract.xql'
                    let $format         := request:get-parameter('format', $config:lodFormat)
                    return switch ($exist:path)
                        case "/works"
                        case "/works/"
                            return
                                let $debug          := if ($config:debug = "trace") then console:log("4b1a. rdf list of works") else ()
                                let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/svsal-xtriples-workslist.xml'}"/>,
                                                        <exist:add-parameter name="format"          value="{$format}"/>)
                                return net:forward($extractPath, $net-vars, $parameters)
                        case "/authors"
                        case "/authors/"
                        case "/persons"
                        case "/persons/"
                            return
                                let $debug          := if ($config:debug = "trace") then console:log("4b1b. rdf list of authors") else ()
                                let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/svsal-xtriples-personslist.xml'}"/>,
                                                        <exist:add-parameter name="format"          value="{$format}"/>)
                                return net:forward($extractPath, $net-vars, $parameters)
                        default
                            return
                                let $resourceId     := tokenize($exist:resource, '\.')[1]
                                let $debug          := if ($config:debug = "trace") then console:log("4b2. rdf data of a single resource (" || $resourceId || ")") else ()
                                return
                                    if ($exist:resource || '.rdf' = xmldb:get-child-resources($config:app-root || $config:rdf-root)) then
                                        let $debug          := if ($config:debug = "trace") then console:log("Loading " || $resourceId || ".rdf ...") else ()
                                        return net:forward($config:rdf-root || '/' || $exist:resource || '.rdf', $net-vars)
                                    else
                                        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Generating rdf for " || $resourceId || " ...") else ()
                                        let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/createConfig.xql?resourceId=' || $resourceId || '&amp;format=' || $config:lodFormat}"/>,
                                                                <exist:add-parameter name="format"          value="{$format}"/>)
                                        return net:forward($extractPath, $net-vars, $parameters)

                    else () (: under data.{serverdomain}, we don't care about any other acceptable content types ... :)

(: === End Machine Readable Data Interface (LOD) === :)




(: Todo: content negotiate X-Forwarded-Host = {serverdomain} ... :)
    else if (request:get-header('X-Forwarded-Host') = $config:serverdomain) then
        let $debug      := if ($config:debug = "trace") then console:log("Underspecified request at base domain (" || $exist:path || $parameterString || ") ...") else ()
        return
            if (count(functx:value-intersect($net:requestedContentTypes, ('text/html','application/xhtml+xml')))) then
                net:redirect-with-303($config:webserver || $exist:path || $parameterString)
            else if (count(functx:value-intersect($net:requestedContentTypes, ('application/rdf+xml','application/xml','*/*')))) then
                net:redirect-with-303($config:apiserver || $exist:path || $parameterString)
            else ()



    (: If the request is for an xql file, strip/bypass language selection logic :)
    else if (ends-with($exist:resource, ".xql")) then
        let $finalPath1     := replace($exist:path, '/de/', '/')
        let $finalPath2     := replace($finalPath1, '/en/', '/')
        let $finalPath3     := replace($finalPath2, '/es/', '/')
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("XQL requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath3 || '?' || string-join($net-vars('params'), '&amp;') || ".") else ()
        return net:forward($finalPath3, $net-vars)

    (: If the request is for a file download, forward to resources/files/... :)
    else if (starts-with($exist:path, "/files/") or request:get-header('X-Forwarded-Host') = "files." || $config:serverdomain) then
        let $prelimPath    := if (starts-with($exist:path, "/files/")) then substring($exist:path, 7) else $exist:path
        let $finalPath     := (: $config:resources-root :) "/resources/files" || $prelimPath
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("File download requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath || '?' || string-join($net-vars('params'), '&amp;') || ".") else ()
        return net:forward($finalPath, $net-vars)

    (: All requests to TEI XML files to the data directory :)
    else if (request:get-header('X-Forwarded-Host') = "tei." || $config:serverdomain) then
        if (matches($exist:resource, '[ALW]\d{4}\.xml')) then
            let $debug      := if ($config:debug = "trace") then console:log ("TEI/XML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $doExpand   := (util:declare-option("output:method", "xml"),
                                util:declare-option("output:media-type", "application/tei+xml"),
                                util:declare-option("output:indent", "no"),
                                util:declare-option("output:expand-xincludes", "yes")
                                )
            let $debug2     := if ($config:debug = "trace") then console:log("Serializing options: method:" || util:get-option('output:method') ||
                                                                                            ', media-type:' || util:get-option('output:media-type') ||
                                                                                            ', indent:'     || util:get-option('output:indent') ||
                                                                                            ', expand-xincludes:'  || util:get-option('output:expand-xincludes') ||
                                                                                            '.') else ()
            
            let $docPath := for $subroot in $config:tei-sub-roots return 
                if (doc-available($subroot || '/' || $exist:resource)) then $subroot || '/' || $exist:resource else ()
            let $doc        := if (count($docPath) eq 1) then
                                    let $unexpanded := doc($docPath)
    (:                                let $debug       := console:log("unexpanded: " || substring(serialize($unexpanded), 1, 4000)):)
                                    let $expanded   := util:expand(doc($docPath)/tei:TEI)
    (:                                let $debug       := console:log("expanded: " || substring(serialize($expanded), 1, 4000)):)
                                    return $expanded
                               else
                                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                                        <forward url="{$exist:controller}/en/error-page.html" method="get"/>
                                        <view>
                                            <!-- pass the results through view.xql -->
                                                  <forward url="{$exist:controller}/modules/view.xql">
                                                <set-attribute name="lang"              value="{$lang}"/>
                                                <set-attribute name="$exist:resource"   value="{$exist:resource}"/>
                                                <set-attribute name="$exist:prefix"     value="{$exist:prefix}"/>
                                                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                                            </forward>
                                        </view>
                                        {$errorhandler}
                                    </dispatch>
            let $debug3     := if ($config:debug = "trace") then console:log ("deliver doc: " || $doc/name() || "/@xml:id=" || $doc/@xml:id || ".") else ()
            return
                $doc
        else if ($exist:resource eq 'sal-tei-corpus.zip') then
            let $debug      := if ($config:debug = "trace") then console:log ("TEI/XML corpus download requested: " || $net:forwardedForServername || $exist:path || ".") else ()
            let $pathToZip := $config:files-root || '/sal-tei-corpus.zip'
            return if (util:binary-doc-available($pathToZip)) then response:stream-binary(util:binary-doc($pathToZip), 'application/octet-stream', 'sal-tei-corpus.zip') else ()
            
        else ()

    (: HTML files should hava a path component - we parse that and put view.xql in control :)
    else if (ends-with($exist:resource, ".html") and substring($exist:path, 1, 4) = ("/de/", "/en/", "/es/")) then
        let $debug          := if ($config:debug = "info")  then console:log ("HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        let $debug          := if ($config:debug = "trace") then console:log ("HTML requested, translating language path component to a request attribute - $exist:path: " || $exist:path || ", redirect to: " || $exist:controller || substring($exist:path, 4) || ", parameters: [" || string-join(net:inject-requestParameter((), ()), "&amp;") || "], attributes: [].") else ()
        (: For now, we don't use net:forward here since we need a nested view/forwarding. :)
        return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller || substring($exist:path, 4)}"/>
                <view>
                    <!-- pass the results through view.xql -->
                    <forward url="{$exist:controller}/modules/view.xql">
                        <set-attribute name="lang"              value="{$lang}"/>
                        <set-attribute name="$exist:resource"   value="{$exist:resource}"/>
                        <set-attribute name="$exist:prefix"     value="{$exist:prefix}"/>
                        <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                    </forward>
                </view>
                {$errorhandler}
            </dispatch>

    (: If there is no language path component, redirect to a version of the site where there is one :)
    else if (ends-with($exist:resource, ".html")) then
        let $absolutePath   := concat('/', $lang, $exist:path,
                                        if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                        string-join(net:inject-requestParameter('', ''), '&amp;'))
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $absolutePath || "...") else ()
        return net:redirect($absolutePath, $net-vars)

    else if (contains($exist:path, "/$shared/")) then
        let $debug := if ($config:debug = "trace") then console:log("Shared resource requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
                    <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
                </forward>
                {$errorhandler}
            </dispatch>

    (: Relative path requests from sub-collections are redirected there :)
    else if (contains($exist:path, "/resources/")) then
        let $debug := if ($config:debug = "trace") then console:log("Resource requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/resources/{substring-after($exist:path, '/resources/')}">
<!--                <set-header name="Cache-Control" value="max-age=432000, must-revalidate"/> -->
                    <set-header name="Expires" value="{format-dateTime(dateTime(current-date(), util:system-time()) + xs:dayTimeDuration('P7D'), 'EEE, d MMM yyyy HH:mm:ss Z' )}"/>
                </forward>
                {$errorhandler}
            </dispatch>


    else
 (:       let $debug := if ($config:debug = ("trace", "info")) then console:log (concat("Ignoring ", request:get-header('X-Forwarded-Host'), $exist:path, $parameterString, '.')) else ()
        return
            <ignore xmlns="http://exist.sourceforge.net/NS/exist">
                <cache-control cache="yes"/>
            </ignore> :)
         let $debug          := if ($config:debug = ("trace", "info")) then console:log("Page not found: " || $net:forwardedForServername || $exist:path || $parameterString || "."

        || " Absolute path:" || concat($config:proto, "://", $net:forwardedForServername, '/', $lang, '/index.html',
                                    if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                    string-join(net:inject-requestParameter('', ''), '&amp;'))

                                    ) else ()

        let $absolutePath   := concat($config:proto, "://", $net:forwardedForServername, '/', $lang, '/index.html',
                                    if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                    string-join(net:inject-requestParameter('', ''), '&amp;'))
        return net:redirect($absolutePath, $net-vars)


