xquery version "3.1";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace session = "http://exist-db.org/xquery/session";
import module namespace xmldb   = "http://exist-db.org/xquery/xmldb";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace util    = "http://exist-db.org/xquery/util";
import module namespace functx  = "http://www.functx.com";
import module namespace config  = "http://salamanca/config"     at "modules/config.xqm";
import module namespace net     = "http://salamanca/net"        at "modules/net.xql";
import module namespace render  = "http://salamanca/render"     at "modules/render.xql";
import module namespace iiif    = "http://salamanca/iiif"       at "modules/iiif.xql";
import module namespace export  = "http://salamanca/export"     at "modules/export.xql";

declare       namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare       namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare       namespace rdf     = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare       namespace rdfs    = "http://www.w3.org/2000/01/rdf-schema#";
declare       namespace tei     = "http://www.tei-c.org/ns/1.0";
declare       namespace sal     = "http://salamanca.adwmainz.de";

declare option output:method        "xml";
declare option output:media-type    "application/xml";
declare option output:indent        "yes";
declare option output:omit-xml-declaration "no";
declare option output:encoding      "utf-8";

(: *** Todo: - Content negotiate X-Forwarded-Host={serverdomain} without subdomain
   ***       - Why are no hashes handled? Some are needed but lost. (http://bla.com/bla/bla.html?bla<#THISHERE!>)
   ***       - Error Handling and Logging:
   ***          - Copy logging method from services/lod/extract.xql
   ***          - Handle all "else ()" and error <dispatch>es: Print error, request info to log, redirect to homepage, give error message
   ***       - Sanitize/check all input (parameters)
   ***       - See more below, at API functions
   ***       - Content negotiate underspecified X-Forwarded-Host = {serverdomain} ...
:)

(: Get request, session and context information :)
declare variable $exist:path        external;
declare variable $exist:resource    external;
declare variable $exist:controller  external;
declare variable $exist:prefix      external;
declare variable $exist:root        external;

(: Set session information :)
let $lang               :=  net:lang($exist:path)
let $netVars            :=  map  {
                                    "path"          : $exist:path,
                                    "resource"      : $exist:resource,
                                    "controller"    : $exist:controller,
                                    "prefix"        : $exist:prefix,
                                    "root"          : $exist:root,
                                    "lang"          : $lang,
                                    "accept"        : $net:requestedContentTypes,
                                    "params"        : ( for $p in request:get-parameter-names() return lower-case($p) || "="  || lower-case(request:get-parameter($p, ())) )
                                 }
let $parameterString    :=  if (count(request:get-parameter-names())) then
                                "?" || string-join($netVars('params'), '&amp;')
                            else ()




(: Print request context for debugging :)
let $debug              :=  if ($config:debug = "trace") then
                                console:log("Request at '" || request:get-header('X-Forwarded-Host') || "' for " || request:get-effective-uri() || "&#x0d; " ||
                                            "HEADERS (" || count(request:get-header-names()) || "): "    || string-join(for $h in request:get-header-names()    return $h || ": " || request:get-header($h), ' ')    || "&#x0d; " ||
                                            "ATTRIBUTES (" || count(request:attribute-names()) || "): " || string-join(for $a in request:attribute-names()     return $a || ": " || request:get-attribute($a), ' ') || "&#x0d; " ||
                                            "PARAMETERS (" || count($netVars('params')) ||"): " || string-join($netVars('params'), '&amp;') ||
                                            "ACCEPT (" || count($netVars('accept')) || "): " || string-join($netVars('accept'), '.') ||
                                            "$lang: " || $lang || "."
                                           )
                            else ()



(: Here comes the actual routing ... :)
return


    (: *** Redirects for special resources (robots.txt, sitemap, void.ttl; specified by resource name *** :)
    if (lower-case($exist:resource) = "robots.txt") then
        let $debug          := if ($config:debug = "trace") then console:log("Robots.txt requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        let $parameters     := <exist:add-parameter name="Cache-Control" value="max-age=3600, must-revalidate"/>
        return net:forward("/robots.txt", $netVars, $parameters)
    else if (matches(lower-case($exist:path), '^/sitemap(_index)?.xml$') or
             matches(lower-case($exist:path), '^/sitemap_(en|de|es).xml(.(gz|zip))?$')) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Sitemap requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        return net:sitemapResponse($netVars)
    else if ($exist:resource = "void.ttl") then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("VoID.ttl requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        return net:forward("void.ttl", $netVars)


    (: *** We have an underspecified request with (almost) empty path -> redirect this to the homepage *** :)
    else if (request:get-header('X-Forwarded-Host') = ("", "www." || $config:serverdomain) and
             lower-case($exist:path) = ("", "/", "/en", "/es", "/de", "/en/", "/es/", "/de/") ) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Homepage requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        let $absolutePath   := concat( $config:proto, "://", if ($net:forwardedForServername) then $net:forwardedForServername else "www." || $config:serverdomain, '/', $lang, '/index.html',
                                       if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                       string-join(net:inject-requestParameter('', ''), '&amp;')
                                     )
        return net:redirect($absolutePath, $netVars)


    (: *** API (X-Forwarded-Host='api.{serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "api." || $config:serverdomain) then
        let $debug := if ($config:debug = ("trace", "info")) then console:log("API requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        (: We have the following API areas, accessible by path component:
            1. /v1/tei/     works: ✔ passages: 🛇
            2. /v1/txt/     works: ✔ passages:
            3. /v1/rdf/     works: ✔ passages:
            4. /v1/html/    works:   passages:
            5. /v1/iiif/    works:   pages:

            a. Search (/v1/search) ✔           (Forwards to opensphinxsearch.)
            b. CodeSharing (/v1/codesharing) ✔ (To expose TEI tag usage.             See https://api.{$config:serverdomain}/codesharing/codesharing.html or https://mapoflondon.uvic.ca/BLOG10.htm) 
            c. XTriples (/v1/xtriples) ✔       (Extract rdf from xml with xtriples.  See https://api.{$config:serverdomain}/v1/xtriples/xtriples.html    or http://xtriples.spatialhumanities.de/index.html)

            TODO: - Clean up and *systematically* offer only https://api.{$serverdomain}/{version}/{function}/{resource}
                    and perhaps (!) the same at https://{function}.{$serverdomain}/{resource}
                    (Should we better refactor this into higher-level cases instead of cases under api.{$config:serverdomain} and then again all the subdomains at another place?)
                  - Add application/pdf, application/json, text/html, tei-simple?
                  - Handle image requests: If image/* is the preferred data type and resource refers to a node of type "pb" and we have a seeAlso that ends in jpg, tiff or png (?),
                    then forward to there ...
        :)
        let $pathComponents := tokenize(lower-case($exist:path), "/")
        let $debug := if ($config:debug = ("trace")) then console:log("$pathComponents: " || string-join($pathComponents, "; ") || ".") else ()
        let $debug := if ($config:debug = ("trace")) then console:log("This translates to API version " || $pathComponents[2] || ", endpoint " || $pathComponents[3] || ".") else ()

        return if ($pathComponents[3] = $config:apiEndpoints($pathComponents[2])) then  (: Check if we support the requested endpoint/version :)
            switch($pathComponents[3])
            case "tei" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("TEI/XML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                return net:deliverTEI($pathComponents, $netVars)
            case "txt" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("TXT requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                return net:deliverTXT($pathComponents)
            case "rdf" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("RDF requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                return net:deliverRDF($pathComponents, $netVars)
            case "html" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                return net:deliverHTML($pathComponents, $netVars)
            case "iiif" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("iiif requested: " || $net:forwardedForServername || $exist:path || $parameterString || " ...") else ()
                return net:deliverIIIF($exist:path, $netVars)
            case "search" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("Search requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                let $absolutePath  := concat($config:searchserver, '/', substring-after($exist:path, '/search/'))
                return net:redirect($absolutePath, $netVars)
            case "codesharing" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("Codesharing requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                let $parameters    := <exist:add-parameter name="outputType" value="html"/>
                return
                    if ($pathComponents[last()] = 'codesharing_protocol.xhtml') then
                            net:forward('/services/codesharing/codesharing_protocol.xhtml', $netVars)      (: Protocol description html file. :)
                    else
                            net:forward('/services/codesharing/codesharing.xql', $netVars, $parameters)    (: Main service HTML page.  :)
            case "xtriples" return
                let $debug         := if ($config:debug = ("trace", "info")) then console:log("XTriples requested: " || $net:forwardedForServername || $exist:path || $parameterString || " ...") else ()
                return
                    if (tokenize($pathComponents[last()], '\?')[1] = ("extract.xql", "createconfig.xql", "xtriples.html", "changelog.html", "documentation.html", "examples.html")) then
                        let $debug := if ($config:debug = ("trace", "info")) then console:log("Forward to: /services/lod/" || tokenize($exist:path, "/")[last()]  || ".") else ()
                        return net:forward('/services/lod/' || tokenize($exist:path, "/")[last()], $netVars)
                    else ()
            default return ()
        else ()


    (: *** Entity resolver (X-Forwarded-Host = 'id.{$config:serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "id." || $config:serverdomain) then
        let $debug1                  := if ($config:debug = ("trace", "info")) then console:log("Id requested: " || $net:forwardedForServername || $exist:path || $parameterString || ". (" || net:negotiateContentType($net:servedContentTypes, '') || ')') else ()
        (: For determining the content type, the file extension has the highest priority, only then comes content negotiation based on HTTP Accept Header. :)
        let $fileExtension := tokenize($netVars('resource'), '\.')[last()]
        let $debug1 := if ($config:debug = ("trace")) then console:log("Determining content type by file extension '" || $fileExtension || "'...") else ()
        return switch ($fileExtension)
            case 'xml' return
                let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/tei/" || replace($netVars('resource'), '.xml', '') || "'.") else ()
                return net:redirect-with-303($config:apiserver || "/v1/tei/" || replace($netVars('resource'), '.xml', ''))
            case 'txt' return
                let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/txt/" || replace($netVars('resource'), '.txt', '') || "'.") else ()
                return net:redirect-with-303($config:apiserver || "/v1/txt/" || replace($netVars('resource'), '.txt', ''))
            case 'rdf' return
                let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/rdf/" || replace($netVars('resource'), '.rdf', '') || "'.") else ()
                return net:redirect-with-303($config:apiserver || "/v1/rdf/" || replace($netVars('resource'), '.rdf', ''))
            case 'html' return
                let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/html/" || replace($netVars('resource'), '.html', '') || "'.") else ()
                return net:redirect-with-303($config:apiserver || "/v1/html/" || replace($netVars('resource'), '.html', ''))
            case 'jpg' return
                let $debug1 := if ($config:debug = ("trace")) then console:log("Deliver jpg according to request for '" || $netVars('resource') || "'.") else ()
                let $pathComponents := tokenize(lower-case($exist:path), "/")
                return net:deliverJPG($pathComponents, $netVars)
            case 'json' return
                let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/iif/" || replace($netVars('resource'), '.json', '') || "'.") else ()
                return net:redirect-with-303($config:apiserver || "/v1/iiif/" || replace($netVars('resource'), '.json', ''))
            default return
                let $contentType := net:negotiateContentType($net:servedContentTypes, 'text/html')
                let $debug1 := if ($config:debug = ("trace")) then console:log("Content type '" || $contentType || "' determines endpoint...") else ()
                return switch ($contentType)
                    case 'application/tei+xml'
                    case 'application/xml'
                    case 'text/xml' return
                        let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/tei/" || $netVars('resource') || "'.") else ()
                        return net:redirect-with-303($config:apiserver || "/v1/tei/" || $netVars('resource'))
                    case 'text/plain' return
                        let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/txt/" || $netVars('resource') || "'.") else ()
                        return net:redirect-with-303($config:apiserver || "/v1/txt/" || $netVars('resource'))
                    case 'application/rdf+xml' return
                        let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/rdf/" || $netVars('resource') || "'.") else ()
                        return net:redirect-with-303($config:apiserver || "/v1/rdf/" || $netVars('resource'))
                    case 'image/jpeg' return
                        let $debug1 := if ($config:debug = ("trace")) then console:log("Deliver jpg according to request for '" || $netVars('resource') || "'.") else ()
                        let $pathComponents := tokenize(lower-case($exist:path), "/")
                        return net:deliverJPG($pathComponents, $netVars)
                    case 'application/ld+json' return
                        let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/iif/" || $netVars('resource') || "'.") else ()
                        return net:redirect-with-303($config:apiserver || "/v1/iiif/" || $netVars('resource'))
                    default return
                        let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1/html/" || $netVars('resource') || "'.") else ()
                        return net:redirect($config:apiserver || "/v1/html/" || $netVars('resource'), $netVars)


    (: *** Date service (X-Forwarded-Host = 'data.{$config:serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "data." || $config:serverdomain) then
        let $debug                  := if ($config:debug = ("trace", "info")) then console:log("Data requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return net:redirect-with-307($config:apiserver || "/v1/rdf/" || $netVars('path'))


    (: *** TEI file service (X-Forwarded-Host = 'tei.{$config:serverdomain}') *** :)
    (: *** #AW: Ideally we would do a 307-redirection to api.s.s/v1/tei/* for this section and move the logic to net:deliverTEI. Will do this next. *** :)
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
                                    let $expanded   := util:expand(doc($docPath)/tei:TEI)
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
                                        {config:errorhandler($netVars)}
                                    </dispatch>
            let $debug3     := if ($config:debug = "trace") then console:log ("deliver doc: " || $doc/name() || "/@xml:id=" || $doc/@xml:id || ".") else ()
            return
                $doc
        else if (matches($exist:resource, 'W\d{4}(_Vol\d\d)?_teiHeader.xml')) then 
            let $workId := substring-before($exist:resource, '_teiHeader.xml')
            return export:WRKteiHeader($workId, 'metadata')
        else if ($exist:resource eq 'sal-tei-corpus.zip') then
            let $debug      := if ($config:debug = "trace") then console:log ("TEI/XML corpus download requested: " || $net:forwardedForServername || $exist:path || ".") else ()
            let $pathToZip := $config:files-root || '/sal-tei-corpus.zip'
            return if (util:binary-doc-available($pathToZip)) then response:stream-binary(util:binary-doc($pathToZip), 'application/octet-stream', 'sal-tei-corpus.zip') else ()
        else ()


    (: *** Iiif Presentation API URI resolver *** :)
    (: *** #AW: Ideally we would do a 307-redirection to api.s.s/v1/iiif/* for this section and move the logic to net:deliverIIIF, but I'm afraid ATM to open this can of worms. *** :)
    else if (request:get-header('X-Forwarded-Host') = "facs." || $config:serverdomain) then
        let $debug1 :=  if ($config:debug = ("trace", "info")) then console:log('Iiif presentation resource requested: ' || $net:forwardedForServername || $exist:path || $parameterString || '...') else ()
        (: determine requested resource type and do some sanitizing :)
        let $mode :=    if (matches($exist:path, '^/?collection/W\d{4}$')) then 'collection'
                        else if (matches($exist:path, '^/?W\d{4}(_Vol\d{2})?/manifest$')) then 'manifest'
                        else if (matches($exist:path, 'W\d{4}(_Vol\d{2})?/canvas/p\d{1,5}$')) then 'canvas'
                        else ()
        let $workId :=  if ($mode eq 'collection') then tokenize($exist:path, '/')[last()]
                        else if ($mode eq 'manifest') then substring-after(substring-before($exist:path, '/manifest'), '/')
                        else if ($mode eq 'canvas') then substring-after(substring-before($exist:path, '/canvas/'), '/')
                        else ()
        let $canvas :=  if ($mode eq 'canvas') then substring-after($exist:path, '/canvas/') else ()
        let $resolvedURI   :=  $config:webserver || '/iiif-out.xql?wid=' || $workId || (if ($canvas) then concat('&amp;canvas=', $canvas) else ())
        (: redirect in a way that URI (i.e., iiif @id) remains the same and only output of iiif-out.xql is shown :)
        return net:redirect-with-303($resolvedURI)



    (: *** The rest is html and defaults and miscellaneous stuff... :)
    (: If the request is for an xql file, strip/bypass language selection logic :)
    else if (ends-with($exist:resource, ".xql")) then
        let $finalPath1     := replace($exist:path, '/de/', '/')
        let $finalPath2     := replace($finalPath1, '/en/', '/')
        let $finalPath3     := replace($finalPath2, '/es/', '/')
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("XQL requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath3 || '?' || string-join($netVars('params'), '&amp;') || ".") else ()
        return net:forward($finalPath3, $netVars)

    (: If the request is for a file download, forward to resources/files/... :)
    else if (starts-with($exist:path, "/files/") or request:get-header('X-Forwarded-Host') = "files." || $config:serverdomain) then
        let $prelimPath    := if (starts-with($exist:path, "/files/")) then substring($exist:path, 7) else $exist:path
        let $finalPath     := (: $config:resources-root :) "/resources/files" || $prelimPath
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("File download requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath || '?' || string-join($netVars('params'), '&amp;') || ".") else ()
        return net:forward($finalPath, $netVars)

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
                {config:errorhandler($netVars)}
            </dispatch>

    (: If there is no language path component, redirect to a version of the site where there is one :)
    else if (ends-with($exist:resource, ".html")) then
        let $absolutePath   := concat('/', $lang, $exist:path,
                                        if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                        string-join(net:inject-requestParameter('', ''), '&amp;'))
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $absolutePath || "...") else ()
        return net:redirect($absolutePath, $netVars)

    (: Relative path requests from sub-collections are redirected there :)
    else if (contains($exist:path, "/resources/")) then
        let $debug := if ($config:debug = "trace") then console:log("Resource requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return if (contains(lower-case($exist:resource), "favicon")) then
                    if ($config:instanceMode = "testing") then
                        net:forward("/resources/favicons/" || replace($exist:resource, "favicon", "favicon_red"), $netVars)
                    else
                        net:forward("/resources/favicons/" || $exist:resource, $netVars)
               else
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller}/resources/{substring-after($exist:path, '/resources/')}">
                            <set-header name="Expires" value="{format-dateTime(dateTime(current-date(), util:system-time()) + xs:dayTimeDuration('P7D'), 'EEE, d MMM yyyy HH:mm:ss Z' )}"/>
                        </forward>
                        {config:errorhandler($netVars)}
                    </dispatch>

    (: Unspecific hostname :)
    else if (request:get-header('X-Forwarded-Host') = $config:serverdomain) then
        let $debug      := if ($config:debug = "trace") then console:log("Underspecified request at base domain (" || $exist:path || $parameterString || ") ...") else ()
        return
            if (count(functx:value-intersect($net:requestedContentTypes, ('text/html','application/xhtml+xml')))) then
                net:redirect-with-303($config:webserver || $exist:path || $parameterString)
            else if (count(functx:value-intersect($net:requestedContentTypes, ('application/rdf+xml','application/xml','*/*')))) then
                net:redirect-with-303($config:apiserver || $exist:path || $parameterString)
            else ()

    (: Manage exist-db shared resources :)
    else if (contains($exist:path, "/$shared/")) then
        let $debug := if ($config:debug = "trace") then console:log("Shared resource requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
                    <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
                </forward>
                {config:errorhandler($netVars)}
            </dispatch>



    (: Fallback when nothing else fits :)
    else
        let $debug          :=  if ($config:debug = ("trace", "info")) then console:log("Page not found: " || $net:forwardedForServername || $exist:path || $parameterString || "."
                                    || " Absolute path:" || concat($config:proto, "://", $net:forwardedForServername, '/', $lang, '/index.html',
                                    if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                    string-join(net:inject-requestParameter('', ''), '&amp;'))
                                    )
                                else ()

        let $absolutePath   := concat($config:proto, "://", $net:forwardedForServername, '/', $lang, '/index.html',
                                    if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                    string-join(net:inject-requestParameter('', ''), '&amp;'))
        return net:redirect($absolutePath, $netVars)


