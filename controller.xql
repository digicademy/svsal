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

(: *** Todo (especially in api):
   ***  - API landing page / default return values (depending on formats)? - currently simply redirecting to www.s.s
   ***  - Add 'meta' endpoint with json-ld, (mets/mods)
   ***  - Add iiif endpoints (not really working atm)
   ***  - Add passage identifiers to filenames on downloads (see deliverTXT, e.g.)
   ***  - Why are no hashes handled? Some are needed but lost. (http://bla.com/bla/bla.html?bla<#THISHERE!>)
   ***  - Implement collections/lists of resources and their filters (e.g. `/texts?q=lex` resulting in a list of texts) - but which format(s)?
   ***  - Make JSON-LD the fundamental output format (encapsulate html/xml in a json field) and diverge only when explicitly asked to do so (really?)
   ***  - Content negotiate X-Forwarded-Host={serverdomain} without subdomain
:)

(: Get request, session and context information :)
declare variable $exist:path        external;
declare variable $exist:resource    external;
declare variable $exist:controller  external;
declare variable $exist:prefix      external;
declare variable $exist:root        external;

(: Set session information :)
let $lang               :=  net:lang($exist:path)

(:
   For determining the content type, the format url parameter has the highest priority,
   only then comes content negotiation based on HTTP Accept Header (and we do not use file extensions).
   If no (valid) format is given, the format resolves to 'html'
:)

let $netVars :=  
    map  {
        "path"          : $exist:path,
        "resource"      : $exist:resource,
        "controller"    : $exist:controller,
        "prefix"        : $exist:prefix,
        "root"          : $exist:root,
        "lang"          : $lang,
        "accept"        : $net:requestedContentTypes,
        "params"        : ( for $p in request:get-parameter-names() return lower-case($p) || "="  || replace(lower-case(request:get-parameter($p, ())[1]), 'w0', 'W0' )),
        "paramap"       : map:merge(for $p in request:get-parameter-names() return map:entry(lower-case($p), replace(lower-case(request:get-parameter($p, ())[1]), 'w0', 'W0' )))
    } (: if there are several params of the same type, the value of the first one wins :)
let $parameterString    :=  
    if (count(request:get-parameter-names())) then
        "?" || string-join($netVars('params'), '&amp;')
    else ()



(: Print request context for debugging :)
let $debug :=  
    if ($config:debug = "trace") then
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
    else if ($exist:resource = "favicon.ico") then
        (:let $debug := if ($config:debug = "trace") then util:log("warn", "Favicon requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        return :)
        if ($config:instanceMode = "testing") then
            net:forward("/resources/favicons/" || replace($exist:resource, "favicon", "favicon_red"), $netVars)
        else
            net:forward("/resources/favicons/" || $exist:resource, $netVars)


    (: *** We have an underspecified request with (almost) empty path -> redirect this to the homepage *** :)
    else if (request:get-header('X-Forwarded-Host') = ("", "www." || $config:serverdomain) and
             lower-case($exist:path) = ("", "/", "/en", "/es", "/de", "/en/", "/es/", "/de/") ) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Homepage requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        let $absolutePath   := 
            concat( $config:proto, "://", if ($net:forwardedForServername) then $net:forwardedForServername else "www." || $config:serverdomain, '/', $lang, '/index.html',
               if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
               string-join(net:inject-requestParameter('', ''), '&amp;')
            )
        return net:redirect($absolutePath, $netVars)


    (: *** API (X-Forwarded-Host='api.{serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "api." || $config:serverdomain) then
        let $debug := if ($config:debug = ("trace", "info")) then console:log("[API] request at: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        (: We have the following API areas, accessible by path component:
            1. /v1/texts
            a. /v1/search       (Forwards to opensphinxsearch.)
            b. /v1/codesharing  (To expose TEI tag usage.             See https://api.{$config:serverdomain}/codesharing/codesharing.html or https://mapoflondon.uvic.ca/BLOG10.htm) 
            c. /v1/xtriples     (Extract rdf from xml with xtriples.  See https://api.{$config:serverdomain}/v1/xtriples/xtriples.html    or http://xtriples.spatialhumanities.de/index.html)
        :)
        let $netVars :=  map:put($netVars, 'format', net:format())
        let $pathComponents := tokenize(lower-case($exist:path), "/")  (: Since $exist:path starts with a slash, $pathComponents[1] is an empty string :)
        let $debug := if ($config:debug = ("trace")) then console:log("[API] This translates to API version " || $pathComponents[2] || ", endpoint " || $pathComponents[3] || ".") else ()
        return if ($pathComponents[3] = $config:apiEndpoints($pathComponents[2])) then  (: Check if we support the requested endpoint/version :)
            switch($pathComponents[3])
                case "texts" return
                    let $path := substring-after($exist:path, '/texts/')
                    let $textsRequest := net:APIparseTextsRequest($path, $netVars) 
                    return
                        if (not($textsRequest('is_well_formed'))) then net:error(400, $netVars, ())
                        else 
                            if ($textsRequest('validation') eq 1) then (: fully valid request :)
                                switch ($textsRequest('format')) 
                                    case 'html' return net:APIdeliverTextsHTML($textsRequest, $netVars)
                                    case 'rdf'  return net:APIdeliverRDF($textsRequest, $netVars)
                                    case 'tei'  return net:APIdeliverTEI($textsRequest,$netVars)
                                    case 'txt'  return net:APIdeliverTXT($textsRequest,$netVars)
                                    case 'jpg'  return net:APIdeliverJPG($textsRequest, $netVars)
                                    case 'iiif' return net:APIdeliverIIIF($textsRequest, $netVars) 
                                    (: TODO: case 'application/ld+json': deliver iiif ? :)
                                    default return net:APIdeliverTextsHTML($textsRequest, $netVars)
                            else if ($textsRequest('validation') eq 0) then (: one or more resource(s) not yet available :)
                                if ($textsRequest('format') eq 'html') then net:APIdeliverTextsHTML($textsRequest, $netVars)
                                else net:error(404, $netVars, ()) (: resource(s) not found :)
                            else net:error(404, $netVars, ()) (: well-formed, but invalid resource(s) requested :)
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
                        else net:error(404, $netVars, ())
                case "stats" return
                    let $debug         := if ($config:debug = ("trace", "info")) then console:log("Stats requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
                    return net:APIdeliverStats($netVars)
                default return net:error(404, $netVars, ())
            else if ($pathComponents[3]) then net:error(404, $netVars, ()) (: or 400, 405? :)
            else net:redirect-with-303($config:webserver)


    (: *** Entity resolver (X-Forwarded-Host = 'id.{$config:serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "id." || $config:serverdomain) then
        let $debug1 := if ($config:debug = ("trace", "info")) then console:log("Id requested: " || $net:forwardedForServername || $exist:path || $parameterString || ". (" || net:negotiateContentType($net:servedContentTypes, '') || ')') else ()
        let $debug1 := if ($config:debug = ("trace")) then console:log("Redirect (303) to '" || $config:apiserver || "/v1" || $exist:path || $parameterString || "'.") else ()
        return 
            if (matches($exist:path, '(/texts|/concepts/|/authors)')) then 
                net:redirect-with-303($config:apiserver || "/v1" || $exist:path || $parameterString)
            else if (matches($exist:path, '/works\.')) then 
                net:redirect-with-303($config:apiserver || "/v1" || replace($exist:path, '/works\.', '/texts/') || $parameterString)
            else net:error(404, $netVars, ())

    (: *** TEI file service (X-Forwarded-Host = 'tei.{$config:serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "tei." || $config:serverdomain) then
        let $reqText      := tokenize($exist:path, '/')[last()]
        let $debug        := if ($config:debug = ("trace", "info")) then console:log("TEI for " || $reqText || " requested: " || $net:forwardedForServername || '/' || $reqText || $parameterString || ".") else ()
        let $updParams    := array:append([$netVars('params')], "format=tei")
        let $parameters   := concat("?", string-join($updParams?*, "&amp;"))
        return 
            if (starts-with(lower-case($reqText), 'w0')) then 
                let $debug        := if ($config:debug = ("trace", "info")) then console:log("redirect to tei api: " || $config:apiserver || "/v1/texts/" || replace($reqText, '.xml', '') || $parameters || ".") else ()
                return net:redirect($config:apiserver || "/v1/texts/" || replace($reqText, '.xml', '') || $parameters, $netVars)
            else if (not($reqText)) then 
                let $debug        := if ($config:debug = ("trace", "info")) then console:log("redirect to tei api: " || $config:apiserver || "/v1/texts" || $parameters || ".") else ()
                return net:redirect($config:apiserver || "/v1/texts" || $parameters, $netVars)
            else net:error(404, $netVars, ())


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
        let $parameters :=  if ($canvas) then (net:add-parameter('wid', $workId), net:add-parameter('canvas', $canvas)) 
                            else net:add-parameter('wid', $workId)
        return net:forward('iiif-out.xql', $netVars, $parameters)


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
        return 
            if ($exist:resource = ('saltei.rng', 'saltei.xml', 'SvSal_txt.rng', 'SvSal_txt.xml', 'specialchars.xml', 'works-general.xml', 'saltei-author.xml', 'saltei-author.rng', 'SvSal_author.xml', 'SvSal_author.rng')) then
                let $resource :=    if ($exist:resource eq 'SvSal_txt.rng') then 'saltei.rng' 
                                    else if ($exist:resource eq 'SvSal_txt.xml') then 'saltei.xml' 
                                    else if ($exist:resource eq 'SvSal_author.xml') then 'saltei-author.xml'
                                    else if ($exist:resource eq 'SvSal_author.rng') then 'saltei-author.rng'
                                    else $exist:resource
                let $finalPath     := '/meta/' || $resource
                let $debug          := if ($config:debug = ("trace", "info")) then console:log("File download requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to directory: " || $finalPath || '?' || string-join($netVars('params'), '&amp;') || ".") else ()
                return net:forward-to-tei($finalPath, $netVars, ())
            else
                let $finalPath     := "/resources/files" || $prelimPath
                let $debug          := if ($config:debug = ("trace", "info")) then console:log("File download requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath || '?' || string-join($netVars('params'), '&amp;') || ".") else ()
                return net:forward($finalPath, $netVars)

    (: HTML files should have a path component - we parse that and put view.xql in control :)
    else if (ends-with($exist:resource, ".html") and substring($exist:path, 1, 4) = ("/de/", "/en/", "/es/")) then
        let $debug := if ($config:debug = "info")  then console:log ("[CONTROLLER] HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        let $debug := if ($config:debug = "trace") then console:log ("[CONTROLLER] HTML requested, translating language path component to a request attribute - $exist:path: " || $exist:path || ", redirect to: " || $exist:controller || substring($exist:path, 4) || ", parameters: [" || string-join(net:inject-requestParameter((), ()), "&amp;") || "], attributes: [].") else ()
        (: For now, we don't use net:forward here since we need a nested view/forwarding. :)
        let $resource := lower-case($exist:resource)
        return
            if ($resource eq 'author.html') then net:deliverAuthorsHTML($netVars)
            else if ($resource eq 'lemma.html') then net:deliverConceptsHTML($netVars)
            else if ($resource eq 'work.html') then net:deliverTextsHTML($netVars)
            else if ($resource eq 'workingpaper.html') then net:deliverWorkingPapersHTML($netVars)
            else if ($resource eq 'workdetails.html') then net:deliverWorkDetailsHTML($netVars)
            else  (: if ($resource = xmldb:get-child-resources($config:app-root)) then :)
                let $viewModule := 
                    switch ($resource) (: cases need to be lower-cased :)
                        case "admin.html"
                        case "corpus-admin.html"
                        case "createlists.html"
                        case "iiif-admin.html"
                        case "rendertherest.html"
                        case "render.html"
                        case "error-page.html"
                        case "sphinx-admin.html" return "view-admin.xql"
                        default return "view.xql"
                let $debug := if ($config:debug = "trace") then console:log ("[CONTROLLER] Dispatching " || $resource || " to view module " || $viewModule || ".") else ()
                return
                    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                        <forward url="{$exist:controller || substring($exist:path, 4)}"/>
                        <view>
                            <!-- pass the results through view.xql -->
                            <forward url="{$exist:controller}/modules/{$viewModule}">
                                <set-attribute name="lang"              value="{$lang}"/>
                                <set-attribute name="$exist:resource"   value="{$exist:resource}"/>
                                <set-attribute name="$exist:prefix"     value="{$exist:prefix}"/>
                                <set-attribute name="$exist:controller" value="{$exist:controller}"/>
                            </forward>
                        </view>
                        {config:errorhandler($netVars)}
                    </dispatch>
(:            else net:error(404, $netVars, ()):)

    (: If there is no language path component, redirect to a version of the site where there is one :)
    else if (ends-with($exist:resource, ".html")) then
        let $absolutePath   := concat($config:proto, '://', $net:forwardedForServername, '/', $lang, $exist:path,
                                        if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                        string-join(net:inject-requestParameter('', ''), '&amp;'))
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $absolutePath || "...") else ()
        return net:redirect($absolutePath, $netVars)

    (: Relative path requests from sub-collections are redirected there :)
    else if (contains($exist:path, "/resources/")) then
        let $debug := if ($config:debug = "trace") then console:log("Resource requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
(:        let $debug := if ($config:debug = "trace") then util:log("warn", "Favicon requested: " || $net:forwardedForServername || $exist:path || ".") else ():)
        return 
            if (contains(lower-case($exist:resource), "favicon")) then
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
        let $debug := if ($config:debug = "trace") then console:log("Underspecified request at base domain (" || $exist:path || $parameterString || ") ...") else ()
        return
            if (count(functx:value-intersect($net:requestedContentTypes, ('text/html','application/xhtml+xml')))) then
                net:redirect-with-303($config:webserver || $exist:path || $parameterString)
            else if (count(functx:value-intersect($net:requestedContentTypes, ('application/rdf+xml','application/xml','*/*')))) then
                net:redirect-with-303($config:apiserver || $exist:path || $parameterString)
            else net:error(400, $netVars, ())

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
        let $debug :=  
            if ($config:debug = ("trace", "info")) then console:log("Page not found: " || $net:forwardedForServername || $exist:path || $parameterString || "."
                || " Absolute path:" || concat($config:proto, "://", $net:forwardedForServername, '/', $lang, '/index.html',
                if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                string-join(net:inject-requestParameter('', ''), '&amp;'))
                )
            else ()

        let $absolutePath   := 
            concat($config:proto, "://", $net:forwardedForServername, '/', $lang, '/index.html',
                if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                string-join(net:inject-requestParameter('', ''), '&amp;'))
(:        return net:redirect($absolutePath, $netVars):)
        return net:error(404, $netVars, ())
