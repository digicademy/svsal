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

let $lang :=
    (:  Priorities: 1. ?lang
                    2. /lang/
                    3. Browser setting/Accept-Language
                    4. default language
        We refrain from using session attributes (hard to track, hard to change, cf. https://discuss.neos.io/t/how-to-implement-automatic-language-detection/416/6)
    :)
                    if (request:get-parameter-names() = 'lang') then
                        if (request:get-parameter('lang', 'dummy-default-value') = ('de', 'en', 'es')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 1a: lang parameter-name and valid value present.") else ()
                            return request:get-parameter('lang', 'dummy-default-value')
                        else
                            let $debug :=  if ($config:debug = "trace") then console:log("case 1b: lang parameter-name but invalid value present.") else ()
                            return if (matches($exist:path, '/(de|en|es)/')) then
                                        if (contains($exist:path, '/de/')) then
                                            let $debug :=  if ($config:debug = "trace") then console:log("case 2a: 'de' path component present.") else ()
                                            return 'de'
                                        else if (contains($exist:path, '/en/')) then
                                            let $debug :=  if ($config:debug = "trace") then console:log("case 2b: 'en' path component present.") else ()
                                            return 'en'
                                        else
                                            let $debug :=  if ($config:debug = "trace") then console:log("case 2c: 'es' path component present.") else ()
                                            return 'es'
                                    else if (request:get-header('Accept-Language')) then
                                            if (substring(request:get-header('lang'),1,2) = 'de') then
                                                let $debug := if ($config:debug = "trace") then console:log("case 3a: 'de' Accept-Language request header present.") else ()
                                                return 'de'
                                            else if (substring(request:get-header('lang'),1,2) = 'en') then
                                                let $debug := if ($config:debug = "trace") then console:log("case 3b: 'en' Accept-Language request header present.") else ()
                                                return 'en'
                                            else if (substring(request:get-header('lang'),1,2) = 'es') then
                                                let $debug := if ($config:debug = "trace") then console:log("case 3c: 'es' Accept-Language request header present.") else ()
                                                return 'es'
                                            else
                                                let $debug := if ($config:debug = "trace") then console:log("case 3d: unknown Accept-Language request header present.") else ()
                                                return $config:defaultLang
                                    else
                                        let $debug := if ($config:debug = "trace") then console:log("case 4: Language could not be detected. Using default language (" || $config:defaultLang || ").") else ()
                                        return $config:defaultLang

                    else if (matches($exist:path, '/(de|en|es)/')) then
                        if (contains($exist:path, '/de/')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 2a: 'de' path component present.") else ()
                            return 'de'
                        else if (contains($exist:path, '/en/')) then
                            let $debug :=  if ($config:debug = "trace") then console:log("case 2b: 'en' path component present.") else ()
                            return 'en'
                        else
                            let $debug :=  if ($config:debug = "trace") then console:log("case 2c: 'es' path component present.") else ()
                            return 'es'
                    else if (request:get-header('Accept-Language')) then
                            if (substring(request:get-header('Accept-Language'),1,2) = 'de') then
                                let $debug := if ($config:debug = "trace") then console:log("case 3a: 'de' Accept-Language request header present.") else ()
                                return 'de'
                            else if (substring(request:get-header('Accept-Language'),1,2) = 'en') then
                                let $debug := if ($config:debug = "trace") then console:log("case 3b: 'en' Accept-Language request header present.") else ()
                                return 'en'
                            else if (substring(request:get-header('Accept-Language'),1,2) = 'es') then
                                let $debug := if ($config:debug = "trace") then console:log("case 3c: 'es' Accept-Language request header present.") else ()
                                return 'es'
                            else
                                let $debug := if ($config:debug = "trace") then console:log("case 3d: unknown Accept-Language request header (" || request:get-header('Accept-Language') || ") present.") else ()
                                return $config:defaultLang
                    else
                        let $debug := if ($config:debug = "trace") then console:log("case 4: Language could not be detected. Using default language (" || $config:defaultLang || ").") else ()
                        return $config:defaultLang


let $netVars           := map  {
                                    "path"          : $exist:path,
                                    "resource"      : $exist:resource,
                                    "controller"    : $exist:controller,
                                    "prefix"        : $exist:prefix,
                                    "root"          : $exist:root,
                                    "lang"          : lower-case($lang),
                                    "accept"        : $net:requestedContentTypes,
                                    "params"        : ( for $p in request:get-parameter-names() return lower-case($p) || "="  || lower-case(request:get-parameter($p, ())) )
                                }

let $parameterString    :=  if (count(request:get-parameter-names())) then
                                "?" || string-join($netVars('params'), '&amp;')
                            else ()



(: Print request context for debugging :)
let $debug :=  if ($config:debug = "trace") then
                        console:log("Request at '" || request:get-header('X-Forwarded-Host') || "' for " || request:get-effective-uri() || "&#x0d; " ||
                                    "HEADERS (" || count(request:get-header-names()) || "): "    || string-join(for $h in request:get-header-names()    return $h || ": " || request:get-header($h), ' ')    || "&#x0d; " ||
                                    "ATTRIBUTES (" || count(request:attribute-names()) || "): " || string-join(for $a in request:attribute-names()     return $a || ": " || request:get-attribute($a), ' ') || "&#x0d; " ||
                                    "PARAMETERS (" || count($netVars('params')) ||"): " || string-join($netVars('params'), '&amp;') ||
                                    "ACCEPT (" || count($netVars('accept')) || "): " || string-join($netVars('accept'), '.') ||
                                    "$lang: " || $lang || "."
                                   )
                else ()

return

    (: *** Redirects for special resources (favicons, robots.txt, sitemap; specified by resource name *** :)
    if (lower-case($exist:resource) = "favicon.ico") then
        let $debug          := if ($config:debug = "trace") then console:log("Favicon requested: " || $net:forwardedForServername || $exist:path || ".") else ()
        return net:forward("/resources/favicons/favicon.ico", $netVars)
    else if (lower-case($exist:resource) = "robots.txt") then
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


    (: *** We have an underspecified request with (almost) empty path -> redirect this to homepage *** :)
    else if (request:get-header('X-Forwarded-Host') = ("", "www." || $config:serverdomain) and
             lower-case($exist:path) = ("", "/", "/en", "/es", "/de", "/en/", "/es/", "/de/") ) then
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Homepage requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        let $absolutePath   := concat( $config:proto, "://", if ($net:forwardedForServername) then $net:forwardedForServername else "www." || $config:serverdomain, '/', $lang, '/index.html',
                                       if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                       string-join(net:inject-requestParameter('', ''), '&amp;')
                                     )
        return net:redirect($absolutePath, $netVars)


    (: *** API functions (X-Forwarded-Host='api.{serverdomain}') *** :)
    else if (request:get-header('X-Forwarded-Host') = "api." || $config:serverdomain) then
        let $debug := if ($config:debug = ("trace", "info")) then console:log("API requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        (: We have the following API areas, accessible by path component:

            1. /v1/tei/     works: ✔ passages: 🛇
            2. /v1/txt/     works: ✔ passages:
            3. /v1/rdf/     works: ✔ passages:
            4. /v1/html/    works:    passages:
            5. /v1/iiif/    works:    pages:

            a. Search (/v1/search) ✔         (Forwards to opensphinxsearch.)
            b. CodeSharing (/v1/codesharing) ✔ (To expose TEI tag usage.             See https://api.{$config:serverdomain}/codesharing/codesharing.html or https://mapoflondon.uvic.ca/BLOG10.htm) 
            c. XTriples (/v1/xtriples) ✔      (Extract rdf from xml with xtriples.  See https://api.{$config:serverdomain}/lod/xtriples.html            or http://xtriples.spatialhumanities.de/index.html)

            TODO: - Clean up and *systematically* offer only https://api.{$serverdomain}/{version}/{function}/{resource}
                    and perhaps (!) the same at https://{function}.{$serverdomain}/{resource}
                    (Should we better refactor this into higher-level cases instead of cases under api.{$config:serverdomain} and then again all the subdomains at another place?)
                  - Also switch based on mime-type, not only $exist:path? As an example, see "4. txt" below.
                  - Add application/pdf, application/json, text/html, tei-simple?

        :)
        let $pathComponents := tokenize(lower-case($exist:path), "/")
        let $debug := if ($config:debug = ("trace")) then console:log("$pathComponents: " || string-join($pathComponents, "; ") || ".") else ()
        let $debug := if ($config:debug = ("trace")) then console:log("This translates to API version " || $pathComponents[2] || ", endpoint " || $pathComponents[3] || ".") else ()
        

        return if ($pathComponents[3] = $config:apiEndpoints($pathComponents[2])) then
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
            case "html" return ()
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
                    if ($pathComponents[last()] = ("extract.xql", "createConfig.xql", "xtriples.html", "changelog.html", "documentation.html", "examples.html")) then
                        net:forward('/services/lod/' || $pathComponents[last()], $netVars)
                    else ()
            default return ()

        else ()
(: === End API functions === :)


(: === Iiif Presentation API URI resolver === :)
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
        return net:forward('iiif-out.xql', $net-vars, $parameters)

        
        
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
(: LOD 1. We have a request for a specific resource and a *.rdf filename :)
        if (ends-with($exist:path, '.rdf')) then
            let $debug          := if ($config:debug = ("trace", "info")) then console:log("LOD requested (Case 1): " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
            let $resourceId     := substring-after(substring-before($exist:resource, '.rdf'), '.')
            return  if ($resourceId || '.rdf' = xmldb:get-child-resources($config:rdf-root) and not("nocache" = request:get-parameter-names())) then
                        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Loading " || $resourceId || " ...") else ()
                        return net:forward('../../..' || $config:rdf-root || '/' || $resourceId || '.rdf', $netVars)
                    else
                        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Generating rdf for " || $resourceId || " ...") else ()
                        let $path           := '/services/lod/extract.xql'
                        let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/createConfig.xql?resourceId=' || $resourceId || '&amp;format=' || $config:lodFormat}"/>,
                                                <exist:add-parameter name="format"          value="{$config:lodFormat}"/>)
                        return net:forward($path, $netVars, $parameters)

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
                                return net:forward($extractPath, $netVars, $parameters)
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
                                return net:forward($extractPath, $netVars, $parameters)
                        case "/authors"
                        case "/authors/"
                        case "/persons"
                        case "/persons/"
                            return
                                let $debug          := if ($config:debug = "trace") then console:log("4b1b. rdf list of authors") else ()
                                let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/svsal-xtriples-personslist.xml'}"/>,
                                                        <exist:add-parameter name="format"          value="{$format}"/>)
                                return net:forward($extractPath, $netVars, $parameters)
                        default
                            return
                                let $resourceId     := tokenize($exist:resource, '\.')[1]
                                let $debug          := if ($config:debug = "trace") then console:log("4b2. rdf data of a single resource (" || $resourceId || ")") else ()
                                return
                                    if ($exist:resource || '.rdf' = xmldb:get-child-resources($config:app-root || $config:rdf-root)) then
                                        let $debug          := if ($config:debug = "trace") then console:log("Loading " || $resourceId || ".rdf ...") else ()
                                        return net:forward($config:rdf-root || '/' || $exist:resource || '.rdf', $netVars)
                                    else
                                        let $debug          := if ($config:debug = ("trace", "info")) then console:log("Generating rdf for " || $resourceId || " ...") else ()
                                        let $parameters     := (<exist:add-parameter name="configuration"   value="{$config:apiserver || '/lod/createConfig.xql?resourceId=' || $resourceId || '&amp;format=' || $config:lodFormat}"/>,
                                                                <exist:add-parameter name="format"          value="{$format}"/>)
                                        return net:forward($extractPath, $netVars, $parameters)

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
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("XQL requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath3 || '?' || string-join($netVars('params'), '&amp;') || ".") else ()
        return net:forward($finalPath3, $netVars)

    (: If the request is for a file download, forward to resources/files/... :)
    else if (starts-with($exist:path, "/files/") or request:get-header('X-Forwarded-Host') = "files." || $config:serverdomain) then
        let $prelimPath    := if (starts-with($exist:path, "/files/")) then substring($exist:path, 7) else $exist:path
        let $finalPath     := (: $config:resources-root :) "/resources/files" || $prelimPath
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("File download requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $finalPath || '?' || string-join($netVars('params'), '&amp;') || ".") else ()
        return net:forward($finalPath, $netVars)

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
                                        {config:errorhandler($netVars)}
                                    </dispatch>
            let $debug3     := if ($config:debug = "trace") then console:log ("deliver doc: " || $doc/name() || "/@xml:id=" || $doc/@xml:id || ".") else ()
            return
                $doc
        else if (matches($exist:resource, 'W\d{4}_teiHeader.xml')) then 
            let $workId := substring-before($exist:resource, '_teiHeader.xml')
            return export:WRKteiHeader($workId, 'metadata')
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
                {config:errorhandler($netVars)}
            </dispatch>

    (: If there is no language path component, redirect to a version of the site where there is one :)
    else if (ends-with($exist:resource, ".html")) then
        let $absolutePath   := concat('/', $lang, $exist:path,
                                        if (count(net:inject-requestParameter('', '')) gt 0) then '?' else (),
                                        string-join(net:inject-requestParameter('', ''), '&amp;'))
        let $debug          := if ($config:debug = ("trace", "info")) then console:log("HTML requested: " || $net:forwardedForServername || $exist:path || $parameterString || ", redirecting to " || $absolutePath || "...") else ()
        return net:redirect($absolutePath, $netVars)

    else if (contains($exist:path, "/$shared/")) then
        let $debug := if ($config:debug = "trace") then console:log("Shared resource requested: " || $net:forwardedForServername || $exist:path || $parameterString || ".") else ()
        return
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
                    <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
                </forward>
                {config:errorhandler($netVars)}
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
                {config:errorhandler($netVars)}
            </dispatch>


    else
 (:       let $debug := if ($config:debug = ("trace", "info")) then console:log (concat("Ignoring ", request:get-header('X-Forwarded-Host'), $exist:path, $parameterString, '.')) else ()
        return
            <ignore xmlns="http://exist.sourceforge.net/NS/exist">
                <cache-control cache="yes"/>
            </ignore> :)
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


