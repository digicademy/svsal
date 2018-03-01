xquery version "3.0";

module namespace net                = "http://salamanca/net";
import module namespace request     = "http://exist-db.org/xquery/request";
import module namespace response    = "http://exist-db.org/xquery/response";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace util        = "http://exist-db.org/xquery/util";
import module namespace config      = "http://salamanca/config"                 at "config.xqm";

declare       namespace exist       = "http://exist.sourceforge.net/NS/exist";
declare       namespace tei         = "http://www.tei-c.org/ns/1.0";
declare       namespace sal         = "http://salamanca.adwmainz.de";

declare variable $net:cache-control       := "no";

(: TODO: Letsencrypt mgmt is done via apache proxy and jetty as of now, so we should remove it here ... :)
declare variable $net:responseToken             := "Bn-fSXmMYzA3uXu0Otpc5aNyWBzzK4OWgvQ0-iccAKk";
declare variable $net:plainDomainChallenge      := "Aty4HlCj17eaeym8tAzbdIaXHHFgRkiEIIHzHUa2pcc";
declare variable $net:apiDomainChallenge        := "ZHVv4BGzgjM5esX9Rsyt549W9xdIgN3TTe-JrndiDwc";
declare variable $net:dataDomainChallenge       := "AQRtdEnG79M6FIYzEqEj7N_t-ow_KO3Kw6AUFLcHExY";
declare variable $net:filesDomainChallenge      := "RNQsVpou2gbJ6faH3q6Xz2nlQ_FUnnMQLkV7gsXk860";
declare variable $net:idDomainChallenge         := "GdAax0gfCZ0wcVozfyqFJxBo_uLDEPtscJh2LeVh_Hc";
declare variable $net:softwareDomainChallenge   := "RvCq7udo5LWFJLWWNHCIDcuWg7pmogEEvrAPOPYSQyU";
declare variable $net:teiDomainChallenge        := "0rwL8uTxZK46MP7ooYBULIiE87kud_Mc70BA4-uagiM";
declare variable $net:wwwDomainChallenge        := "uNNFAgKCPbYYGjwsHo8EGd-zfFtYxVbd10az8BKmC_s";
declare variable $net:plainDomainToken          := $net:plainDomainChallenge    || "." || $net:responseToken;
declare variable $net:apiDomainToken            := $net:apiDomainChallenge      || "." || $net:responseToken;
declare variable $net:dataDomainToken           := $net:dataDomainChallenge     || "." || $net:responseToken;
declare variable $net:idDomainToken             := $net:idDomainChallenge       || "." || $net:responseToken;
declare variable $net:softwareDomainToken       := $net:softwareDomainChallenge || "." || $net:responseToken;
declare variable $net:filesDomainToken          := $net:filesDomainChallenge    || "." || $net:responseToken;
declare variable $net:teiDomainToken            := $net:teiDomainChallenge      || "." || $net:responseToken;
declare variable $net:wwwDomainToken            := $net:wwwDomainChallenge      || "." || $net:responseToken;

declare variable $net:forwardedForServername    := request:get-header('X-Forwarded-Host');
declare variable $net:servedContentTypes        := (
                                                    'text/html',
                                                    'text/plain',
                                                    'application/tei+xml',
                                                    'application/xhtml+xml',
                                                    'application/rdf+xml',
                                                    'application/json',
                                                    'application/pdf',
                                                    'image/jpeg',
                                                    'image/png',
                                                    'image/tiff'
                                                    );
(:declare variable $net:requestedContentTypes     := tokenize(request:get-header('Accept'), '[,\s;]+');:)
declare variable $net:requestedContentTypes     := tokenize(request:get-header('Accept'), '[, ]+');

declare variable $net:errorhandler := if (($config:instanceMode = "staging") or ($config:debug = "trace")) then ()
                       else
                            <error-handler>
                                <forward url="{$config:app-root}/en/error-page.html" method="get"/>
                                <forward url="{$config:app-root}/modules/view.xql"/>
                            </error-handler>;

(: Todo: Clean lang parameters when they arrive. It's there but I'm not sure it's working... :)
declare function net:inject-requestParameter($injectParameter as xs:string*, $injectValue as xs:string*) as xs:string* {
    if (not($injectParameter)) then
        for $p in request:get-parameter-names() return
            if (not($p = "lang" and request:get-parameter($p, ()) = ('', 'de', 'en', 'es'))) then
                $p || "=" || request:get-parameter($p, ())
            else ()
    else
        let $preliminaryList := for $p in request:get-parameter-names() return
                                    if ($p = $injectParameter and not($injectParameter = 'lang')) then
                                        $injectParameter || "=" || $injectValue
                                    else if (not($p = "lang" and request:get-parameter($p, ()) = ('', 'de', 'en', 'es'))) then
                                        $p || "=" || request:get-parameter($p, ())
                                    else ()
        return if (not($injectParameter || "=" || $injectValue = $preliminaryList)) then
                    (if (not($injectParameter = 'lang')) then $injectParameter || "=" || $injectValue else (), $preliminaryList)
               else
                    $preliminaryList
};

(:  Approach based on Joe Wicentowski's suggestion of handling redirection in separate queries
    (and much else in local convenience functions). However, the main code below does not (yet)
    use these convenience functions to the fullest possible extent. (That's a todo.) :)
(: declare function net:redirectResponse(){
    let $path               := request:get-parameter('path', '')
    let $status             := request:get-parameter('statusCode', 303)
    return
        (
            response:set-status-code($status), response:set-header('Location', $path)
        )
};
:)
declare function net:redirect-with-301($absolute-path) {  (: Moved permanently :)
    (response:set-status-code(301), response:set-header('Location', $absolute-path))
(:  net:forward('../services/30x.xql',
        (net:add-parameter('path', $absolute-path),
         net:add-parameter('statusCode', '301')),
        $net-vars
        )
:)
};
declare function net:redirect-with-307($absolute-path) {  (: Temporary redirect :)
    (response:set-status-code(307), response:set-header('Location', $absolute-path))
(:    net:forward('../services/30x.xql',
        (net:add-parameter('path', $absolute-path),
         net:add-parameter('statusCode', '307')),
        $net-vars
        )
:)
};
declare function net:redirect-with-303($absolute-path) {  (: See other :)
    (response:set-header('Location', $absolute-path), response:set-status-code(303), text {''})
(:    net:forward('../services/30x.xql', $net-vars,
        (net:add-parameter('path', $absolute-path),
         net:add-parameter('statusCode', '303'))       
        )
:)
};
declare function net:redirect-with-404($absolute-path) {  (: 404 :)
    (response:set-status-code(404), 
    <error-handler>
        <forward url="{$config:app-root}/en/index.html" method="get"/>
        <forward url="{$config:app-root}/modules/view.xql"/>
    </error-handler>)
};
declare function net:add-parameter($name as xs:string, $value as xs:string) as element(exist:add-parameter) {
    <add-parameter xmlns="http://exist.sourceforge.net/NS/exist" name="{$name}" value="{$value}"/>
};
declare function net:forward($relative-path as xs:string, $net-vars as map(*)) {
    net:forward($relative-path, $net-vars, ())
};
declare function net:forward($relative-path as xs:string, $net-vars as map(*), $attribs as element(exist:add-parameter)*) {
    let $absolute-path := concat($net-vars('controller'), '/', $relative-path)
(:    let $absolute-path := concat($net-vars('root'), $net-vars('controller'), '/', $relative-path):)
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$absolute-path}">
                {$attribs}
            </forward>
            <cache-control cache="{$net:cache-control}"/>
            {$net:errorhandler}
        </dispatch>
    };
declare function net:redirect($absolute-path as xs:string, $net-vars as map(*)) { (: implicit temporary redirect (302) :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$absolute-path}"/>
        <cache-control cache="{$net:cache-control}"/>
        {$net:errorhandler}
    </dispatch>
};
declare function net:ignore() {
    <ignore xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="{$net:cache-control}"/>
    </ignore>
};

declare function net:findNode($ctsId as xs:string?){
    let $reqResource  := tokenize($ctsId, '/')[last()]
    let $work         := tokenize(tokenize($reqResource, ':')[1], '\.')[2]   (: group.work:pass.age :)
    let $passage      := tokenize($reqResource, ':')[2]
    let $nodeId       := if ($passage) then
                            let $nodeIndex := doc($config:data-root || '/' || $work || '_nodeIndex.xml')
                            return $nodeIndex//sal:node[sal:citetrail eq $passage][1]/@n[1]
                         else
                            "completeWork" 
    let $work         := util:expand(doc($config:tei-works-root || '/' || $work || '.xml')//tei:TEI)
    let $node         := $work//tei:*[@xml:id eq $nodeId]
    let $debug        := if ($config:debug = "trace") then console:log('findNode returns ' || count($node) || ' node(s): ' || $work/@xml:id || '//*[@xml:id=' || $nodeId || '] (cts/id was "' || $ctsId || '").') else ()
    return $node
};

(: From https://github.com/golang/gddo/blob/master/httputil/negotiate.go :)
(: NegotiateContentType returns the best offered content type for the request's
   Accept header. If two offers match with equal weight, then the more specific
   offer is preferred.  For example, text/* trumps */*. If two offers match
   with equal weight and specificity, then the offer earlier in the list is
   preferred. If no offers match, then defaultOffer is returned. :)
(: This is Golang: 

func NegotiateContentType(r *http.Request, offers []string, defaultOffer string) string {
	bestOffer  := defaultOffer
	bestQ      := -1.0
	bestWild   := 3
	specs      := header.ParseAccept(r.Header, "Accept")
	for _, offer := range offers {
		for _, spec := range specs {
			switch {
			case spec.Q == 0.0:
				// ignore
			case spec.Q < bestQ:
				// better match found
			case spec.Value == "*/*":
				if spec.Q > bestQ || bestWild > 2 {
					bestQ = spec.Q
					bestWild = 2
					bestOffer = offer
				}
			case strings.HasSuffix(spec.Value, "/*"):
				if strings.HasPrefix(offer, spec.Value[:len(spec.Value)-1]) &&
					(spec.Q > bestQ || bestWild > 1) {
					bestQ = spec.Q
					bestWild = 1
					bestOffer = offer
				}
			default:
				if spec.Value == offer &&
					(spec.Q > bestQ || bestWild > 0) {
					bestQ = spec.Q
					bestWild = 0
					bestOffer = offer
				}
			}
		}
	}
	return bestOffer
}
:)
declare function net:negotiateContentType($offers as xs:string*, $defaultOffer as xs:string) as xs:string {
    let $bestOffer      := $defaultOffer
    let $bestQ          := -1.0
    let $bestWild       := 3
    let $returnOffer    := local:negotiateCTSub($offers, $bestOffer, $bestQ, $bestWild)
    return $returnOffer
};

declare function local:negotiateCTSub($offers as xs:string*, $bestOffer as xs:string, $bestQ as xs:double, $bestWild as xs:integer) as xs:string {
    let $offer      := $offers[1]
(:let $debug      := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. -- Current offer type: " || $offer || ".") else ():)
(:    let $newOffer   := for $spec in tokenize(replace(request:get-header('Accept'), ' ', ''), ','):)
    let $newOffer   := for $spec in $net:requestedContentTypes
(:let $debug := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. ---- Current accepted type: " || $spec || ".") else ():)

                                let $Q      :=  if (string(number(substring-after($spec, ';q='))) != 'NaN') then
                                                    number(substring-after($spec, ';q='))
                                                else
                                                    1.0 
                                let $value  := if (contains($spec, ';')) then
                                                    substring-before($spec, ';')
                                               else
                                                    $spec
                                return
                                            if ($Q lt $bestQ) then ()           (: previous match had stronger weight :)
                                     else   if (starts-with($spec, '*/*')) then                 (: least specific - let $bestWild := 2  :)
                                                if ($bestWild gt 2) then
                                                    let $newBestWild   := 2
                                                    let $newBestQ      := $Q
                                                    let $newBestOffer  := $offer
                                                    return ($newBestOffer, $newBestQ, $newBestWild)
                                                else ()
                                     else   if (ends-with($value, '/*')) then                   (: medium specific - let $bestWild := 1  :)
                                               if (substring-before($offer, '/') = substring($value, 1, string-length($value) - 2) and $bestWild gt 1) then
                                                   let $newBestWild   := 1
                                                   let $newBestQ      := $Q
                                                   let $newBestOffer  := $offer
                                                   return ($newBestOffer, $newBestQ, $newBestWild)
                                               else ()
                                     else
                                            if ($offer = $value and ($Q gt $bestQ or $bestWild gt 0)) then    (: perfectly specific match - let $bestWild := 0 :)
                                                let $newBestWild   := 0
                                                let $newBestQ      := $Q
                                                let $newBestOffer  := $offer
(:let $debug := if ($config:debug = ("trace", "info")) then console:log("content negotiation recursion. ---- NewOffer: " || $newBestOffer || ',' || $newBestQ || ',' || $newBestWild || ".") else ():)
                                                return ($newBestOffer, $newBestQ, $newBestWild)
                                            else ()
    let $returnOffer  :=  if (count($offers) gt 1) then
                                if ($newOffer[1]) then
                                    local:negotiateCTSub(subsequence($offers, 2), $newOffer[1], $newOffer[2], $newOffer[3])
                                else
                                    local:negotiateCTSub(subsequence($offers, 2), $bestOffer, $bestQ, $bestWild)
                          else
                                if ($newOffer[1]) then $newOffer[1] else $bestOffer
    return $returnOffer
};


(: TODO: Letsencrypt mgmt is done via apache proxy and jetty as of now, so we should remove it here ... :)
declare function net:acmeExchange($net-vars){
    let $ret := util:declare-option("exist:serialize", "method=text media-type=text/plain")
    return
             if ($net:forwardedForServername = "salamanca.school"           and $net-vars('resource') = $net:plainDomainChallenge) then
                text{$net:plainDomainToken}
        else if ($net:forwardedForServername = "www.salamanca.school"       and $net-vars('resource') = $net:wwwDomainChallenge) then
                text{$net:wwwDomainToken}
        else if ($net:forwardedForServername = "data.salamanca.school"      and $net-vars('resource') = $net:dataDomainChallenge) then
                text{$net:dataDomainToken}
        else if ($net:forwardedForServername = "files.salamanca.school"     and $net-vars('resource') = $net:filesDomainChallenge) then
                text{$net:filesDomainToken}
        else if ($net:forwardedForServername = "id.salamanca.school"        and $net-vars('resource') = $net:idDomainChallenge) then
                text{$net:idDomainToken}
        else if ($net:forwardedForServername = "api.salamanca.school"       and $net-vars('resource') = $net:apiDomainChallenge) then
                text{$net:apiDomainToken}
        else if ($net:forwardedForServername = "software.salamanca.school"  and $net-vars('resource') = $net:softwareDomainChallenge) then
                text{$net:softwareDomainToken}
        else if ($net:forwardedForServername = "tei.salamanca.school"       and $net-vars('resource') = $net:teiDomainChallenge) then
                text{$net:teiDomainToken}
        else ()
};


(: Sitemap stuff ... :)
declare function local:getDbDocumentIds($collections as xs:string*) as xs:string* {
    for $collection in $collections
        let $collType := switch ($collection)
                            case 'authors'          return 'author_article'
                            case 'lemmata'          return 'lemma_article'
(:                            case 'news'             return local:blogEntries():)
                            case 'workingPapers'    return 'working_paper'
                            case 'works'            return ("work_multivolume", "work_monograph")
                            case 'workDetails'      return ("work_multivolume", "work_monograph")
                            default return ()
        return for $document in collection($config:tei-root)//tei:TEI[tei:text/@type = $collType]
                    return $document/@xml:id
};

declare function local:getDbWebpageRel($documentIds as xs:string*) as xs:string* {
(:    let $debug          := if ($config:debug = "trace") then console:log("Creating relative urls for " || string-join($documentIds, ', ') || ".") else ():)
    for $documentId in $documentIds
(:        let $viewports := switch (doc($config:data-root || '/' || $documentId || '.xml')/tei:TEI/tei:text[1]/@type):)
        let $viewports := switch (collection($config:tei-root)/tei:TEI[@xml:id=$documentId]/tei:text[1]/@type)
                            case 'author_article'   return 'author.html?aid='
                            case 'lemma_article'    return 'lemma.html?lid='
                            case 'working_paper'    return 'workingPaper.html?wpid='
                            case 'work_monograph'   return ('work.html?wid=', 'workDetails.html?wid=')
                            case 'work_multivolume' return ('work.html?wid=', 'workDetails.html?wid=')
                            default return ()
        for $viewport in $viewports
            return concat($viewport, $documentId)
};

declare function local:getDbWebpageAbs($documentIds as xs:string*, $language as xs:string) as xs:string* {
(:    let $debug          := if ($config:debug = "trace") then console:log("Creating absolute urls for " || string-join($documentIds, ', ') || ' (' || $language || ").") else ():)
    for $document in $documentIds
        return for $webpage in local:getDbWebpageRel($document)
            return concat($config:webserver, '/', $language, '/', $webpage)
};

declare function local:getUrlList($language as xs:string) as element(url)* {
    let $debug          := if ($config:debug = "trace") then console:log("Building list of urls for " || $language || "...") else ()
    for $id in  local:getDbDocumentIds($config:databaseEntries)
        return for $url in local:getDbWebpageAbs($id, $language)
                    return
                        <url xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{
                            element loc {$url}
                (:            if(exists($lastmod)) then element lastmod {$lastmod} else ():)
                        }</url>
}; 

declare function local:localizedSitemap($lang as xs:string) as element(urlset) {
    let $debug          := if ($config:debug = "trace") then console:log("Creating sitemap for " || $lang || "...") else ()
    return
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {for $pagename in $config:standardEntries return 
                <url>
                    <loc>{$config:webserver || '/' || $lang || '/' || $pagename || '.html'}</loc>
                </url>
            }
            {
                    local:getUrlList($lang)
            }
        </urlset>
};

declare function local:sitemapIndex($fileNames as xs:string*) as element(sitemapindex) {
    let $debug          := if ($config:debug = "trace") then console:log("Creating sitemapindex...") else ()
    return
        <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            {for $fileName in $fileNames
                return  <sitemap>{
                            element loc {$config:webserver || '/' || $fileName}
    (:                        if(exists($lastmod)) then element lastmod {$lastmod} else ():)
                        }</sitemap>
            }
        </sitemapindex>
};

declare function net:sitemapResponse($net-vars as map(*)) {
    let $resource           := $net-vars('resource')
    let $language           := for $lang in $config:languages
                                    return if ($resource = concat('sitemap_', $lang, '.xml')) then $lang else () 
(:    let $compression        :=  if(ends-with($resource, 'zip')) then 'zip' else $net:defaultCompression:)
    let $properFileNames    :=  for $lang in $config:languages
                                    return concat('sitemap_', $lang, '.xml' (: , '.', $compression :) )
    let $ret := util:declare-option("exist:serialize", "method=xml media-type=application/xml indent=yes omit-xml-declaration=no encoding=utf-8")

    (:
        If the exact name of a sitemap was given in the request, return a "good" sitemap,
        otherwise return an index of actual sitemap files.
    :)
    return
        if($properFileNames = $resource) then
    (:        response:stream-binary(local:getSetSitemap($resource), local:getMimeType($compression), $resource):)
            let $sitemap := local:localizedSitemap($language) 
            let $debug   := if ($config:debug = ("info", "trace")) then console:log("Returning sitemap_" || $language || " with " || count($sitemap/*) || " entries ...") else ()
            return $sitemap
        else
            let $sitemapIndex := local:sitemapIndex($properFileNames) 
            let $debug   := if ($config:debug = ("info", "trace")) then console:log("Returning sitemapIndex with " || count($sitemapIndex/*) || " maps ...") else ()
            return $sitemapIndex
};

