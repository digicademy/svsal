xquery version "3.1";

(: ####++++----

    Admin functions, mostly related to the creation of webdata formats (html, iiif, snippets, etc.).
    Tightly coupled with modules in factory/*.

    ----++++#### :)
 
module namespace admin              = "https://www.salamanca.school/xquery/admin";

declare namespace tei               = "http://www.tei-c.org/ns/1.0";
declare namespace sal               = "http://salamanca.adwmainz.de";

declare namespace array             = "http://www.w3.org/2005/xpath-functions/array";
declare namespace compression       = "http://exist-db.org/xquery/compression";
declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace file              = "http://exist-db.org/xquery/file";
declare namespace map               = "http://www.w3.org/2005/xpath-functions/map";
declare namespace output            = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request           = "http://exist-db.org/xquery/request";
declare namespace sm                = "http://exist-db.org/xquery/securitymanager";
declare namespace util              = "http://exist-db.org/xquery/util";
declare namespace xi                = "http://www.w3.org/2001/XInclude";
declare namespace xmldb             = "http://exist-db.org/xquery/xmldb";

import module namespace bin         = "http://expath.org/ns/binary";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace functx      = "http://www.functx.com";
import module namespace templates   = "http://exist-db.org/xquery/html-templating";
import module namespace lib         = "http://exist-db.org/xquery/html-templating/lib";

import module namespace app         = "https://www.salamanca.school/xquery/app"           at "xmldb:exist:///db/apps/salamanca/modules/app.xqm";
import module namespace config      = "https://www.salamanca.school/xquery/config"        at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace i18n        = "http://exist-db.org/xquery/i18n"                   at "xmldb:exist:///db/apps/salamanca/modules/i18n.xqm";
import module namespace net         = "https://www.salamanca.school/xquery/net"           at "xmldb:exist:///db/apps/salamanca/modules/net.xqm";
import module namespace render-app  = "https://www.salamanca.school/xquery/render-app"    at "xmldb:exist:///db/apps/salamanca/modules/render-app.xqm";
import module namespace sphinx      = "https://www.salamanca.school/xquery/sphinx"        at "xmldb:exist:///db/apps/salamanca/modules/sphinx.xqm";
import module namespace sutil       = "https://www.salamanca.school/xquery/sutil"         at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";
import module namespace stats       = "https://www.salamanca.school/factory/works/stats"  at "xmldb:exist:///db/apps/salamanca/modules/factory/works/stats.xqm";
import module namespace index       = "https://www.salamanca.school/factory/works/index"  at "xmldb:exist:///db/apps/salamanca/modules/factory/works/index.xqm";
import module namespace crumb       = "https://www.salamanca.school/factory/works/crumb"  at "xmldb:exist:///db/apps/salamanca/modules/factory/works/crumb.xqm";
import module namespace html        = "https://www.salamanca.school/factory/works/html"   at "xmldb:exist:///db/apps/salamanca/modules/factory/works/html.xqm";
import module namespace txt         = "https://www.salamanca.school/factory/works/txt"    at "xmldb:exist:///db/apps/salamanca/modules/factory/works/txt.xqm";
import module namespace iiif        = "https://www.salamanca.school/factory/works/iiif"   at "xmldb:exist:///db/apps/salamanca/modules/factory/works/iiif.xqm";

declare option exist:timeout "166400000"; (: in miliseconds, 25.000.000 ~ 7h, 43.000.000 ~ 12h :)
declare option exist:output-size-limit "5000000"; (: max number of nodes in memory :)

(:
~ TODO: 
~    - HTML rendering and creation of snippets is currently not working for authors and lemmata, although 
~      the "ancient" infrastructure is still there (see renderTheRest.html and admin:renderAuthorLemma(), etc.).
~      Ideally, this infrastructure would be refactored in the way the creation of work data works: the webdata-admin.xql
~      forwards requests for the creation of data to the admin.xqm module, which then lets dedicated modules in factory/authors/* 
~      create the data.
:)

declare
    %templates:wrap
    %templates:default("sort", "surname")
function admin:loadListOfWorks($node as node(), $model as map(*), $sort as xs:string) as map(*) {
    let $coll := (collection($config:tei-works-root)//tei:TEI[.//tei:text/@type = ("work_monograph", "work_multivolume")]/tei:teiHeader)
    let $result := 
        for $item in $coll
            let $wid := $item/parent::tei:TEI/@xml:id/string()
            let $author := sutil:formatName($item//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)
            let $titleShort := $item//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
            let $parent := $item//tei:notesStmt/tei:relatedItem[@type eq "work_multivolume"]/@target/string()
            order by $wid ascending
            return 
                map {'wid': $wid,
                     'author': $author,
                     'titleShort': $titleShort,
                     'parent': $parent}
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] loaded " || count($result) || " works.") else ()
    return map { 'listOfWorks': $result }     
};

declare function admin:workCount($node as node(), $model as map (*), $lang as xs:string?) {
    count($model("listOfWorks"))
};

(: #### UTIL FUNCTIONS for informing the admin about current status of a webdata resources (node index, HTML, snippets, etc.) :)

declare function admin:needsPdf($targetWorkId as xs:string) as xs:boolean {
    let $workModTime := xmldb:last-modified($config:tei-works-root, $targetWorkId || '.xml')
    return
        if ($targetWorkId || ".pdf" = xmldb:get-child-resources($config:pdf-root)) then
            let $renderModTime := xmldb:last-modified($config:pdf-root, $targetWorkId || ".pdf")
            return
                if ($renderModTime lt $workModTime) then
                    true()
                else
                    false()
        else
            true()
};

declare function admin:needsPdfDatei($node as node(), $model as map(*)) {
    let $currentWorkId := $model('currentWork')?('wid')
let $currentDoc := doc($config:tei-works-root|| "/" ||$currentWorkId ||".xml")

  
  let $isMultiWorkVolume as  node() :=$currentDoc//tei:TEI//tei:text

let $target_1 := $currentDoc//tei:relatedItem/@target
let $target_2 := for $target in $target_1 return substring-after($target, "work:") 


    return 
       
          if ($isMultiWorkVolume/@type="work_multivolume")
                           then
<td> 
               {            for $target in $target_2 
                              return
          
                          if (admin:needsPdf($target)) then 
      
                     <a title="Source from: {string(xmldb:last-modified($config:tei-works-root, $target || '.xml'))}{if (xmldb:get-child-resources($config:pdf-root) = $target || ".pdf") then concat(', rendered on: ', xmldb:last-modified($config:pdf-root, $target || ".pdf")) else ()}"><b> Create PDF for <a href="webdata-admin.xql?rid={$target}&amp;format=pdf_create">{$target}!</a><br/></b></a>
 
                         else if(not(admin:needsPdf($target)))  then  <i title="Source from: {string(xmldb:last-modified($config:tei-works-root, $target || '.xml'))}, rendered on: {xmldb:last-modified($config:pdf-root, $target || ".pdf")}">PDF for {$target} created.<small><a href="webdata-admin.xql?rid={$target}&amp;format=pdf_create">Create PDF anyway!</a></small> <br/> </i>
   else() }
</td>
      else if (not($isMultiWorkVolume/@type="work_multivolume")) then


                                 if  (admin:needsPdf($currentWorkId)) then

            <td title="Source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}{if (xmldb:get-child-resources($config:pdf-root) = $currentWorkId || ".pdf") then concat(', rendered on: ', xmldb:last-modified($config:pdf-root, $currentWorkId || ".pdf")) else ()}">
<a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=pdf_create"><b>Create PDF NOW!</b></a>
<br/> or
<br/>
<form enctype="multipart/form-data" method="post" action="webdata-admin.xql?rid={$currentWorkId}&amp;format=pdf_upload">
<p>Upload PDF File</p>
<input type="file"  name="FileUpload"/>
<input type="submit">Submit your PDF</input>
</form>
<br/>
</td>
        else 
            <td title="Source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}, rendered on: {xmldb:last-modified($config:pdf-root, $currentWorkId || ".pdf")}">The PDF was already uploaded or created. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=pdf_create">Create PDF anyway!</a></small></td>

else<td>error !</td>

};

declare function admin:needsIndex($targetWorkId as xs:string) as xs:boolean {
    let $workModTime := xmldb:last-modified($config:tei-works-root, $targetWorkId || '.xml')
    return
        if ($targetWorkId || "_nodeIndex.xml" = xmldb:get-child-resources($config:index-root)) then
            let $renderModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
            return if ($renderModTime lt $workModTime) then true() else false()
        else
            true()
};

declare function admin:needsIndexString($node as node(), $model as map(*)) {
    let $currentWorkId := $model('currentWork')?('wid')
    return 
        if (admin:needsIndex($currentWorkId)) then
            <td title="{if (xmldb:get-child-resources($config:index-root) = $currentWorkId || "_nodeIndex.xml") then concat('Index created on: ', xmldb:last-modified($config:index-root, $currentWorkId || "_nodeIndex.xml"), ", ") else ()}source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=index"><b>Create Node Index NOW!</b></a></td>
        else
            <td title="Index created on: {xmldb:last-modified($config:index-root, $currentWorkId || "_nodeIndex.xml")}, source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}">Node indexing unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=index">Create Node Index anyway!</a></small></td>
};

declare function admin:needsCrumb($targetWorkId as xs:string) as xs:boolean {
    let $workModTime := xmldb:last-modified($config:tei-works-root, $targetWorkId || '.xml')
    return
        if ($targetWorkId || "_crumbtrails.xml" = xmldb:get-child-resources($config:crumb-root)) then
            let $renderModTime := xmldb:last-modified($config:crumb-root, $targetWorkId || "_crumbtrails.xml")
            return
                if ($renderModTime lt $workModTime) then
                    true()
                else
                    false()
        else
            true()
};

declare function admin:needsCrumbtrails($node as node(), $model as map(*)) {
    let $currentWorkId := $model('currentWork')?('wid')
    return
        if (admin:needsCrumb($currentWorkId)) then 
            <td
                title="Source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}{
                        if (xmldb:get-child-resources($config:crumb-root) = $currentWorkId || "_crumbtrails.xml") then
                            concat(', rendered on: ', xmldb:last-modified($config:crumb-root, $currentWorkId || "_crumbtrails.xml"))
                        else
                            ()
                  }"><a
                    href="webdata-admin.xql?rid={$currentWorkId}&amp;format=crumbtrails"><b>Create Crumbtrails NOW!</b></a></td>
            
        else
            <td
                title="Source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}, rendered on: {xmldb:last-modified($config:crumb-root, $currentWorkId || "_crumbtrails.xml")}">Creating Crumbtrails unnecessary. <small><a  href="webdata-admin.xql?rid={$currentWorkId}&amp;format=crumbtrails">Create it anyway!</a></small></td>
};

declare function admin:needsTeiCorpusZip($node as node(), $model as map(*)) {
    let $worksModTime := max(for $work in xmldb:get-child-resources($config:tei-works-root) return xmldb:last-modified($config:tei-works-root, $work))    
    let $needsCorpusZip := 
        if (util:binary-doc-available($config:corpus-zip-root || '/sal-tei-corpus.zip')) then
            let $resourceModTime := xmldb:last-modified($config:corpus-zip-root, 'sal-tei-corpus.zip')
            return $resourceModTime lt $worksModTime
        else true()
    return 
        if ($needsCorpusZip) then
            <td title="Most current source from: {string($worksModTime)}"><a href="webdata-admin.xql?format=tei-corpus"><b>Create TEI corpus NOW!</b></a></td>
        else
            <td title="{concat('TEI corpus created on: ', string(xmldb:last-modified($config:corpus-zip-root, 'sal-tei-corpus.zip')), ', most current source from: ', string($worksModTime), '.')}">Creating TEI corpus unnecessary. <small><a href="webdata-admin.xql?format=tei-corpus">Create TEI corpus zip anyway!</a></small></td>
};

declare function admin:needsTxtCorpusZip($node as node(), $model as map(*)) {
    if (xmldb:collection-available($config:txt-root)) then
        let $worksModTime := max(for $work in xmldb:get-child-resources($config:txt-root) return xmldb:last-modified($config:txt-root, $work))    
        let $needsCorpusZip := 
            if (util:binary-doc-available($config:corpus-zip-root || '/sal-txt-corpus.zip')) then
                let $resourceModTime := xmldb:last-modified($config:corpus-zip-root, 'sal-txt-corpus.zip')
                return $resourceModTime lt $worksModTime
            else true()
        return 
            if ($needsCorpusZip) then
                <td title="Most current source from: {string($worksModTime)}"><a href="webdata-admin.xql?format=txt-corpus"><b>Create TXT corpus NOW!</b></a></td>
            else
                <td title="{concat('TXT corpus created on: ', string(xmldb:last-modified($config:corpus-zip-root, 'sal-txt-corpus.zip')), ', most current source from: ', string($worksModTime), '.')}">Creating TXT corpus unnecessary. <small><a href="webdata-admin.xql?format=txt-corpus">Create TXT corpus zip anyway!</a></small></td>
    else <td title="No txt sources available so far!"><a href="webdata-admin.xql?format=txt-corpus"><b>Create TXT corpus NOW!</b></a></td>
};

declare function admin:needsStats($node as node(), $model as map(*)) {
    let $worksModTime := max(for $work in xmldb:get-child-resources($config:tei-works-root) return xmldb:last-modified($config:tei-works-root, $work))    
    let $needsStats := 
        if (util:binary-doc-available($config:stats-root || '/corpus-stats.json')) then
            let $resourceModTime := xmldb:last-modified($config:stats-root, 'corpus-stats.json')
            return $resourceModTime lt $worksModTime
        else true()
    return 
        if ($needsStats) then
            <td title="Most current source from: {string($worksModTime)}"><a href="webdata-admin.xql?format=stats"><b>Create corpus stats NOW!</b></a></td>
        else
            <td title="{concat('Stats created on: ', string(xmldb:last-modified($config:stats-root, 'corpus-stats.json')), ', most current source from: ', string($worksModTime), '.')}">Creating corpus stats unnecessary. <small><a href="webdata-admin.xql?format=stats">Create corpus stats anyway!</a></small></td>
};

declare function admin:authorString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentAuthorId  := $model('currentAuthor')/@xml:id/string()
    return 
        <td><a href="author.html?aid={$currentAuthorId}">{$currentAuthorId} - {app:AUTname($node, $model)}</a></td>
};

declare function admin:authorMakeHTML($node as node(), $model as map(*)) {
    let $currentAuthorId := $model('currentAuthor')/@xml:id/string()
    return 
        if (admin:needsHTML($currentAuthorId)) then
            <td title="source from: {string(xmldb:last-modified($config:tei-authors-root, $currentAuthorId || '.xml'))}{if (xmldb:collection-available($config:temp) and xmldb:get-child-resources($config:temp) = $currentAuthorId || ".html") then concat(', rendered on: ', xmldb:last-modified($config:temp, $currentAuthorId || ".html")) else ()}"><a href="renderTheRest.html?aid={$currentAuthorId}"><b>Render NOW!</b></a></td>
        else
            <td title="source from: {string(xmldb:last-modified($config:tei-authors-root, $currentAuthorId || '.xml'))}, Rendered on: {xmldb:last-modified($config:temp, $currentAuthorId || '.html')}">Rendering unnecessary. <small><a href="renderTheRest.html?aid={$currentAuthorId}">Render anyway!</a></small></td>
};

declare function admin:lemmaString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentLemmaId  := string($model('currentLemma')/@xml:id)
    return <td><a href="lemma.html?lid={$currentLemmaId}">{$currentLemmaId} - {app:LEMtitle($node, $model)}</a></td>
};

declare function admin:lemmaMakeHTML($node as node(), $model as map(*)) {
    let $currentLemmaId := string($model('currentLemma')/@xml:id)
    return 
        if (admin:needsHTML($currentLemmaId)) then
            <td title="source from: {string(xmldb:last-modified($config:tei-lemmata-root, $currentLemmaId || '.xml'))}{if (xmldb:collection-available($config:temp) and xmldb:get-child-resources($config:temp) = $currentLemmaId || ".html") then concat(', rendered on: ', xmldb:last-modified($config:temp, $currentLemmaId || ".html")) else ()}"><a href="renderTheRest.html?lid={$currentLemmaId}"><b>Render NOW!</b></a></td>
        else
            <td title="source from: {string(xmldb:last-modified($config:tei-lemmata-root, $currentLemmaId || '.xml'))}, Rendered on: {xmldb:last-modified($config:temp, $currentLemmaId || ".html")}">Rendering unnecessary. <small><a href="renderTheRest.html?lid={$currentLemmaId}">Render anyway!</a></small></td>
};
           
declare function admin:WPString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentWPId  := string($model('currentWp')/@xml:id)
    return <td><a href="workingPaper.html?wpid={$currentWPId}">{$currentWPId} - {app:WPtitle($node, $model)}</a></td>
};

declare function admin:needsHTML($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
            else ()
    let $workModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    return
        if (substring($targetWorkId,1,2) eq "W0") then
            if ($targetWorkId || "_nodeIndex.xml" = xmldb:get-child-resources($config:index-root)
                and xmldb:collection-available($config:html-root || '/' || $targetWorkId)) then
                let $indexModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
                let $htmlModTime := 
                    max(for $file in xmldb:get-child-resources($config:html-root || '/' || $targetWorkId) return 
                            xmldb:last-modified($config:html-root || '/' || $targetWorkId, $file))
                return if ($htmlModTime lt $workModTime or $htmlModTime lt $indexModTime) then true() else false()
            else
                true()
        else if (substring($targetWorkId,1,2) = ("A0", "L0", "WP")) then
            (: TODO: in the future, this should point to the directory where author/lemma/... HTML will be stored... :)
            if (not(xmldb:collection-available($config:data-root))) then
                true()
            else if ($targetWorkId || ".html" = xmldb:get-child-resources($config:data-root)) then
                let $renderModTime := xmldb:last-modified($config:data-root, $targetWorkId || ".html")
                return if ($renderModTime lt $workModTime) then true() else false()
            else true()
        else true()
};

declare function admin:needsHTMLString($node as node(), $model as map(*)) {
    let $currentWorkId := $model('currentWork')?('wid')
    return 
        if (admin:needsHTML($currentWorkId)) then
            <td title="{if (xmldb:collection-available($config:html-root || "/" || $currentWorkId) and not(empty(collection($config:html-root || "/" || $currentWorkId)))) then concat('HTML created on: ', max(for $d in collection($config:html-root || "/" || $currentWorkId) return xmldb:last-modified($config:html-root || "/" || $currentWorkId, util:document-name($d))), ", ") else ()}source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=html"><b>Render HTML (&amp; TXT) NOW!</b></a></td>
        else
            <td title="HTML created on {max(for $d in collection($config:html-root || "/" || $currentWorkId) return xmldb:last-modified($config:html-root || "/" || $currentWorkId, util:document-name($d)))}, source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}">Rendering unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=html">Render HTML (&amp; TXT) anyway!</a></small></td>
};

declare function admin:needsDetails($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
            else ()
    let $workModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    return
        if (substring($targetWorkId,1,2) eq "W0") then
            if (xmldb:collection-available($config:html-root || '/' || $targetWorkId) and
                $targetWorkId || "_details.html" = xmldb:get-child-resources($config:html-root || '/' || $targetWorkId)
               ) then
                let $indexModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
                let $htmlModTime := xmldb:last-modified($config:html-root || '/' || $targetWorkId, $targetWorkId || "_details.html")
                return if ($htmlModTime lt $workModTime or $htmlModTime lt $indexModTime) then true() else false()
            else
                true()
        else if (substring($targetWorkId,1,2) = ("A0", "L0", "WP")) then
            (: TODO: in the future, this should point to the directory where author/lemma/... HTML will be stored... :)
            if (not(xmldb:collection-available($config:data-root))) then
                true()
            else if ($targetWorkId || ".html" = xmldb:get-child-resources($config:html-root || '/' || $targetWorkId)) then
                let $renderModTime := xmldb:last-modified($config:data-root, $targetWorkId || ".html")
                return if ($renderModTime lt $workModTime) then true() else false()
            else true()
        else true()
};

declare function admin:needsDetailsString($node as node(), $model as map(*)) {
    let $currentWorkId         := $model('currentWork')?('wid')
    let $detailFileCollection  := concat($config:html-root,  '/', $currentWorkId)
    let $detailFilePath        := concat($detailFileCollection, '/', $currentWorkId, '_details.html')
    return
        if (admin:needsDetails($currentWorkId)) then
            <td title="{if (xmldb:collection-available($detailFileCollection) and doc-available($detailFilePath)) then concat('Details created on: ', string(xmldb:last-modified($detailFileCollection, $currentWorkId || '_details.html')), ", ") else ()}source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=details"><b>Render Details NOW!</b></a></td>
        else
            <td title="HTML created on {string(xmldb:last-modified($detailFileCollection, $currentWorkId || '_details.html'))}, source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}">Rendering unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=details">Render Details anyway!</a></small></td>
};

declare function admin:workString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentWorkId  := $model('currentWork')?('wid')
    let $author := <span>{$model('currentWork')?('author')}</span>
    let $titleShort := $model('currentWork')?('titleShort')
    return 
        <td>
            <a href="{$config:idserver}/texts/{$currentWorkId}">{$currentWorkId}: {$author} - {$titleShort}</a>
            <br/>
            <a style="font-weight:bold;" href="{$config:webserver}/webdata-admin.xql?rid={$currentWorkId}&amp;format=all">Create EVERYTHING except IIIF and RDF (safest option)</a>
        </td>
};

declare function admin:needsSphinxSnippets($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
                                    else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
(:    let $newestSnippet := max(for $file in xmldb:get-child-resources($config:snippets-root || '/' || $targetWorkId) return xmldb:last-modified($config:snippets-root || '/' || $targetWorkId, $file)):)

    return if (xmldb:collection-available($config:snippets-root || '/' || $targetWorkId)) then
                let $snippetsModTime := max(for $file in xmldb:get-child-resources($config:snippets-root || '/' || $targetWorkId) return xmldb:last-modified($config:snippets-root || '/' || $targetWorkId, $file))
                return 
                    if (starts-with(upper-case($targetWorkId), 'W0')) then
                        let $indexModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
                        return 
                            if ($snippetsModTime lt $targetWorkModTime or $snippetsModTime lt $indexModTime) then true() else false()
                    else if ($snippetsModTime lt $targetWorkModTime) then true() 
                    else false()
        else
            true()
};

declare function admin:needsSphinxSnippetsString($node as node(), $model as map(*)) {
    let $currentWorkId := max((string($model('currentWork')?('wid')), string($model('currentAuthor')/@xml:id), string($model('currentLemma')/@xml:id), string($model('currentWp')/@xml:id)))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentWorkId, '.xml'))) then $subcollection
                                    else ()
    return if (admin:needsSphinxSnippets($currentWorkId)) then
                <td title="{concat(if (xmldb:collection-available($config:snippets-root || '/' || $currentWorkId)) then concat('Snippets created on: ', max(for $file in xmldb:get-child-resources($config:snippets-root || '/' || $currentWorkId) return string(xmldb:last-modified($config:snippets-root || '/' || $currentWorkId, $file))), ', ') else (), 'Source from: ', string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml')), '.')}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=snippets"><b>Create snippets NOW!</b></a></td>
            else
                <td title="{concat('Snippets created on: ', max(for $file in xmldb:get-child-resources($config:snippets-root || '/' || $currentWorkId) return string(xmldb:last-modified($config:snippets-root || '/' || $currentWorkId, $file))), ', Source from: ', string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml')), '.')}">Creating snippets unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=snippets">Create snippets anyway!</a></small></td>
};

declare function admin:needsRDF($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
            else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    let $subcollection := 
        if (starts-with(upper-case($targetWorkId), 'W')) then $config:rdf-works-root
        else if (starts-with(upper-case($targetWorkId), 'A')) then $config:rdf-authors-root
        else if (starts-with(upper-case($targetWorkId), 'L')) then $config:rdf-lemmata-root
        else ()
    return    
        if (doc-available($subcollection || '/' || $targetWorkId || '.rdf')) then
            let $rdfModTime := xmldb:last-modified($subcollection, $targetWorkId || '.rdf')
            return 
                if (starts-with(upper-case($targetWorkId), 'W0')) then
                    let $indexModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
                    return 
                        if ($rdfModTime lt $targetWorkModTime or $rdfModTime lt $indexModTime) then true() else false()
                else if ($rdfModTime lt $targetWorkModTime) then true() 
                else false()
        else true()
};

declare function admin:needsRDFString($node as node(), $model as map(*)) {
    let $currentWorkId := max((string($model('currentWork')?('wid')), string($model('currentAuthor')/@xml:id), string($model('currentLemma')/@xml:id), string($model('currentWp')/@xml:id)))
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $currentWorkId, '.xml'))) then $subcollection
            else ()
    let $rdfSubcollection := 
        if (starts-with(upper-case($currentWorkId), 'W')) then $config:rdf-works-root
        else if (starts-with(upper-case($currentWorkId), 'A')) then $config:rdf-authors-root
        else if (starts-with(upper-case($currentWorkId), 'L')) then $config:rdf-lemmata-root
        else ()
    return 
        if (admin:needsRDF($currentWorkId)) then
            <td title="{concat(if (doc-available($rdfSubcollection || '/' || $currentWorkId || '.rdf')) then concat('RDF created on: ', string(xmldb:last-modified($rdfSubcollection, $currentWorkId || '.rdf')), ', ') else (), 'Source from: ', string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml')), '.')}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=rdf"><b>Create RDF NOW!</b></a></td>
        else
            <td title="{concat('RDF created on: ', string(xmldb:last-modified($rdfSubcollection, $currentWorkId || '.rdf')), ', Source from: ', string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml')), '.')}">Creating RDF unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=rdf">Create RDF anyway!</a></small></td>
};

declare function admin:needsIIIFResource($targetWorkId as xs:string) as xs:boolean {
    let $targetWorkModTime := xmldb:last-modified($config:tei-works-root, $targetWorkId || '.xml')

    return if (util:binary-doc-available($config:iiif-root || '/' || $targetWorkId || '.json')) then
                let $resourceModTime := xmldb:last-modified($config:iiif-root, $targetWorkId || '.json')
                return if ($resourceModTime lt $targetWorkModTime) then true() else false()
        else
            true()
};

declare function admin:needsIIIFResourceString($node as node(), $model as map(*)) {
    let $currentWorkId := $model('currentWork')?('wid')
    return if (admin:needsIIIFResource($currentWorkId)) then
                <td title="source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=iiif"><b>Create IIIF resource NOW!</b></a></td>
            else
                <td title="{concat('IIIF resource created on: ', string(xmldb:last-modified($config:iiif-root, $currentWorkId || '.json')), ', Source from: ', string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml')), '.')}">Creating IIIF resource unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=iiif">Create IIIF resource anyway!</a></small></td>
};

declare function admin:needsRoutingResource($targetWorkId as xs:string) as xs:boolean {
    let $targetWorkModTime := xmldb:last-modified($config:tei-works-root, $targetWorkId || '.xml')
    return if (util:binary-doc-available($config:routes-root || '/' || $targetWorkId || '_routes.json')) then
                let $resourceModTime := xmldb:last-modified($config:routes-root, $targetWorkId || '_routes.json')
                return if ($resourceModTime lt $targetWorkModTime) then true() else false()
        else
            true()
};

declare function admin:needsRoutingString($node as node(), $model as map(*)) {
    let $currentWorkId := $model('currentWork')?('wid')
    return if (admin:needsRoutingResource($currentWorkId)) then
                <td title="source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=routing"><b>Create Routing table NOW!</b></a></td>
           else
                <td title="{concat('Routing resource created on: ', string(xmldb:last-modified($config:routes-root, $currentWorkId || '-routes.json')), ', Source from: ', string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml')), '.')}">Creating Routing resource unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=routing">Create Routing resource anyway!</a></small></td>
};


(: #### DATABASE UTIL FUNCTIONS #### :)

declare function admin:cleanCollection ($wid as xs:string, $collection as xs:string) {
    let $collectionName := 
        if ($collection = "html") then
            $config:html-root || "/" || $wid
        else if ($collection = "data") then
            $config:data-root || "/"
        else if ($collection = "snippets") then
            $config:snippets-root || "/" || $wid
        else if ($collection eq "txt") then
            $config:txt-root || "/" || $wid
        else
            $config:data-root || "/trash/"
    let $create-parent-status :=    
        if ($collection = "html"    and not(xmldb:collection-available($config:html-root))) then
            xmldb:create-collection($config:webdata-root, "html")
        else if ($collection = "txt"    and not(xmldb:collection-available($config:txt-root))) then
            xmldb:create-collection($config:webdata-root, "txt")
        else if ($collection = "snippets" and not(xmldb:collection-available($config:snippets-root))) then
            xmldb:create-collection($config:webdata-root, "snippets")
        else ()
    let $create-collection-status := 
        if ($collection = "html" and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:html-root, $wid)
        else if ($collection = "txt" and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:txt-root, $wid)
        else if ($collection = "snippets" and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:snippets-root, $wid)
        else ()
    let $chown-collection-status := sm:chown(xs:anyURI($collectionName), 'sal')
    let $chgrp-collection-status := sm:chgrp(xs:anyURI($collectionName), 'svsal')
    let $chmod-collection-status := sm:chmod(xs:anyURI($collectionName), 'rwxrwxr-x')
    let $remove-status := 
        if (count(xmldb:get-child-resources($collectionName))) then
            for $file in xmldb:get-child-resources($collectionName) return xmldb:remove($collectionName, $file)
        else ()
    return $remove-status
};

declare function admin:saveFile($workId as xs:string, $fileName as xs:string, $content as item(), $collection as xs:string?) {
    let $wid := tokenize($workId, "_")[1]
    let $collectionName :=
             if ($collection eq "html")         then $config:html-root     || "/" || $wid
        else if ($collection eq "txt")          then $config:txt-root      || "/" || $wid
        else if ($collection eq "snippets")     then $config:snippets-root || "/" || $wid
        else if ($collection eq "pdf")          then $config:pdf-root      || "/"
        else if ($collection eq "index")        then $config:index-root    || "/"
        else if ($collection eq "crumbtrails")  then $config:crumb-root    || "/"
        else if ($collection eq "iiif")         then $config:iiif-root     || "/"
        else if ($collection eq "data")         then $config:data-root     || "/"
        else if ($collection eq "stats")        then $config:stats-root    || "/"
        else if ($collection eq "rdf" and starts-with(upper-case($wid), "W0")) then $config:rdf-works-root   || "/"
        else if ($collection eq "rdf" and starts-with(upper-case($wid), "A0")) then $config:rdf-authors-root || "/"
        else if ($collection eq "rdf" and starts-with(upper-case($wid), "L0")) then $config:rdf-lemmata-root || "/"
        else $config:data-root || "/trash/"
    let $create-parent-status :=
             if ($collection eq "html"      and not(xmldb:collection-available($config:html-root)))     then
            xmldb:create-collection($config:webdata-root, "html")
        else if ($collection eq "txt"       and not(xmldb:collection-available($config:txt-root)))      then
            xmldb:create-collection($config:webdata-root, "txt")
        else if ($collection eq "snippets"  and not(xmldb:collection-available($config:snippets-root))) then
            xmldb:create-collection($config:webdata-root, "snippets")
        else if ($collection eq "index"     and not(xmldb:collection-available($config:index-root)))    then
            xmldb:create-collection($config:webdata-root, "index")
        else if ($collection eq "iiif"      and not(xmldb:collection-available($config:iiif-root)))     then
            xmldb:create-collection($config:webdata-root, "iiif")
        else if ($collection eq "pdf"       and not(xmldb:collection-available($config:pdf-root)))      then
            xmldb:create-collection($config:webdata-root, "pdf")
        else if ($collection eq "rdf"       and not(xmldb:collection-available($config:rdf-root)))      then
            xmldb:create-collection($config:webdata-root, "rdf")
        else if ($collection eq"stats"      and not(xmldb:collection-available($config:stats-root)))    then
            xmldb:create-collection($config:webdata-root, "stats")
        (: TODO: rdf subroots (works/authors)? but these should already ship with the svsal-webdata package :)
        else ()
    let $create-collection-status :=
             if ($collection eq "html"     and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:html-root, $wid)
        else if ($collection eq "txt"      and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:txt-root, $wid)
        else if ($collection eq "snippets" and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:snippets-root, $wid)
        else ()
    let $chown-collection-status := sm:chown(xs:anyURI($collectionName), 'sal')
    let $chgrp-collection-status := sm:chgrp(xs:anyURI($collectionName), 'svsal')
    let $chmod-collection-status := sm:chmod(xs:anyURI($collectionName), 'rwxrwxr-x')
    let $remove-status :=
        if (exists($content) and ($fileName = xmldb:get-child-resources($collectionName))) then
            xmldb:remove($collectionName, $fileName)
        else ()
    let $store-status :=
        if (exists($content)) then
            xmldb:store($collectionName, $fileName, $content)
        else ()
    return $store-status
};

declare function admin:saveTextFile($workId as xs:string, $fileName as xs:string, $content as xs:string, $collection as xs:string?) {
    let $wid := tokenize($workId, "_")[1]
    let $collectionName := 
             if ($collection eq "html")      then $config:html-root     || "/" || $wid
        else if ($collection eq "details")   then $config:html-root     || "/" || $wid
        else if ($collection eq "txt")       then $config:txt-root      || "/" || $wid
        else if ($collection eq "snippets")  then $config:snippets-root || "/" || $wid
        else if ($collection eq "workslist") then $config:html-root     || "/"
        else if ($collection eq "index")     then $config:index-root    || "/"
        else if ($collection eq "iiif")      then $config:iiif-root     || "/"
        else if ($collection eq "routes")    then $config:routes-root   || "/"
        else if ($collection eq "data")      then $config:data-root     || "/"
        else if ($collection eq "stats")     then $config:stats-root    || "/"
        else if ($collection eq "rdf" and starts-with(upper-case($wid), 'W0')) then $config:rdf-works-root || "/"
        else if ($collection eq "rdf" and starts-with(upper-case($wid), 'A0')) then $config:rdf-authors-root || "/"
        else if ($collection eq "rdf" and starts-with(upper-case($wid), 'L0')) then $config:rdf-lemmata-root || "/"
        else $config:data-root || "/trash/"
    let $create-parent-status     :=      
             if ($collection eq "html"      and not(xmldb:collection-available($config:html-root)))     then
            xmldb:create-collection($config:webdata-root, "html")
        else if ($collection eq "details"   and not(xmldb:collection-available($config:html-root)))     then
            xmldb:create-collection($config:webdata-root, "html")
        else if ($collection eq "workslist" and not(xmldb:collection-available($config:html-root)))     then
            xmldb:create-collection($config:webdata-root, "html")
        else if ($collection eq "txt"       and not(xmldb:collection-available($config:txt-root)))      then
            xmldb:create-collection($config:webdata-root, "txt")
        else if ($collection eq "snippets"  and not(xmldb:collection-available($config:snippets-root))) then
            xmldb:create-collection($config:webdata-root, "snippets")
        else if ($collection eq "index"     and not(xmldb:collection-available($config:index-root)))    then
            xmldb:create-collection($config:webdata-root, "index")
        else if ($collection eq "iiif"      and not(xmldb:collection-available($config:iiif-root)))     then
            xmldb:create-collection($config:webdata-root, "iiif")
        else if ($collection eq "routes"    and not(xmldb:collection-available($config:routes-root)))   then
            xmldb:create-collection($config:webdata-root, "routes")
        else if ($collection eq "rdf"       and not(xmldb:collection-available($config:rdf-root)))      then
            xmldb:create-collection($config:webdata-root, "rdf")
        else if ($collection eq "stats"     and not(xmldb:collection-available($config:stats-root)))    then
            xmldb:create-collection($config:webdata-root, "stats")
        (: TODO: rdf subroots (works/authors)? but these should already ship with the svsal-webdata package :)
        else ()
    let $create-collection-status :=      
             if ($collection eq "html"     and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:html-root, $wid)
        else if ($collection eq "details"  and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:html-root, $wid)
        else if ($collection eq "txt"      and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:txt-root, $wid)
        else if ($collection eq "snippets" and not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:snippets-root, $wid)
        else ()
    let $chown-collection-status := sm:chown(xs:anyURI($collectionName), 'sal')
    let $chgrp-collection-status := sm:chgrp(xs:anyURI($collectionName), 'svsal')
    let $chmod-collection-status := sm:chmod(xs:anyURI($collectionName), 'rwxrwxr-x')
    let $remove-status := 
        if ($content and ($fileName = xmldb:get-child-resources($collectionName))) then
            xmldb:remove($collectionName, $fileName)
        else ()
    let $store-status := 
        if (true()) then
            xmldb:store($collectionName, $fileName, $content, "text/plain")
        else ()
    return $store-status
};

declare function admin:exportXMLFile($filename as xs:string, $content as item(), $collection as xs:string?) {
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "data")      then $fsRoot
        else if ($collection eq "html")      then $fsRoot
        else                                      $fsRoot || "trash/"
    let $method :=
          if ($collection eq "html") then "html"
        else                              "xml"

    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if ($content and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize($content, $pathname, map{"method":$method, "indent": true(), "encoding":"utf-8"})
    return if ($store-status) then $pathname else ()
};

declare function admin:exportXMLFile($wid as xs:string, $filename as xs:string, $content as item(), $collection as xs:string?) {
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "html")        then $fsRoot || $wid || "/html/"
        else if ($collection eq "snippets")    then $fsRoot || $wid || "/snippets/"
        else if ($collection eq "workslist")   then $fsRoot || $wid || "/"
        else if ($collection eq "index")       then $fsRoot || $wid || "/"
        else if ($collection eq "crumbtrails") then $fsRoot || $wid || "/"
        else if ($collection eq "rdf")         then $fsRoot || $wid || "/"
        else                                        $fsRoot || "trash/"
    let $method :=
          if ($collection = ("html", "workslist")) then "html"
        else                                            "xml"

    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if ($content and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize($content, $pathname, map{"method":$method, "indent": true(), "encoding":"utf-8"})
    return  if ($store-status) then $pathname else ()
};

declare function admin:exportBinaryFile($filename as xs:string, $content as xs:string, $collection as xs:string?) {
    let $fsRoot := $config:export-folder
    let $collectionname :=
             if ($collection eq "data")      then $fsRoot
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if ($content and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize-binary(bin:encode-string($content), $pathname)    (: eXist-db also has util:base64-encode(xs:string) :)
    return  if ($store-status) then $pathname else ()
};

declare function admin:exportBinaryFile($workId as xs:string, $filename as xs:string, $content as xs:string, $collection as xs:string?) {
    let $wid := tokenize($workId, "_")[1]
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "html")      then $fsRoot || $wid || "/html/"
        else if ($collection eq "details")   then $fsRoot || $wid || "/html/"
        else if ($collection eq "txt")       then $fsRoot || $wid || "/text/"
        else if ($collection eq "pdf")       then $fsRoot || $wid || "/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if ($content and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize-binary(bin:encode-string($content), $pathname)    (: eXist-db also has util:base64-encode(xs:string) :)
    return  if ($store-status) then $pathname else ()
};

declare function admin:exportBinaryStream($workId as xs:string, $filename as xs:string, $content as xs:string, $collection as xs:string?) {
    let $wid := tokenize($workId, "_")[1]
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "pdf")       then $fsRoot || $wid || "/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if ($content and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize-binary($content, $pathname)    (: eXist-db also has util:base64-encode(xs:string) :)
    return  if ($store-status) then $pathname else ()
};

declare function admin:exportJSONFile($filename as xs:string, $content as item()*, $collection as xs:string?) {
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "workslist") then $fsRoot
        else if ($collection eq "stats")     then $fsRoot
        else if ($collection eq "data")      then $fsRoot || "data/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if (count($content) gt 0 and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize-binary(bin:encode-string(fn:serialize($content, map{"method":"json", "indent": true(), "encoding":"utf-8"})), $pathname)
    return if ($store-status) then $pathname else ()
};

declare function admin:exportJSONFile($wid as xs:string, $filename as xs:string, $content as item()*, $collection as xs:string?) {
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "iiif")      then $fsRoot || $wid || "/"
        else if ($collection eq "stats")     then $fsRoot || $wid || "/"
        else if ($collection eq "routing")   then $fsRoot || $wid || "/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error("http://salamanca.school/error/NoWritableFolder", "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if (count($content) gt 0 and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize-binary(bin:encode-string(fn:serialize($content, map{"method":"json", "indent": true(), "encoding":"utf-8"})), $pathname)
    return  if ($store-status) then $pathname else ()
};

declare function admin:buildFacets ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Building facets for list view (version with Javascript)...") else ()
    let $result := for $l in ("de", "en", "es")
                    let $content      := app:WRKfinalFacets($node, $model, $l)
                    let $filename     := 'works_' || $l || '.json'
                    let $debug        := console:log("[ADMIN] Saving (Js) " || $l || " facets file in the database...")
                    let $storeStatus  := admin:saveTextFile("dummy", $filename, fn:serialize($content, map{"method":"json", "indent": true(), "encoding":"utf-8"}), "workslist")
                    let $debug        := console:log("[ADMIN] Exporting (Js) " || $l || " facets json file...")
                    let $exportStatus := admin:exportJSONFile($filename, $content, 'workslist')
                    return <div>Saved {$l} works list to {$storeStatus} and exported it to {$exportStatus}.</div>
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] finalFacets (Js) done!") else ()
    return $result
};

declare function admin:buildFacetsNoJs ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Building facets for list view (versions without Javascript)...") else ()
    let $facets := map { "surname" :    map { "de" : app:WRKcreateListSurname($node, $model, 'de'),
                                              "en" : app:WRKcreateListSurname($node, $model, 'en'),
                                              "es" : app:WRKcreateListSurname($node, $model, 'es')
                                            },
                         "title" :      map { "de" : app:WRKcreateListTitle($node, $model, 'de'),
                                              "en" : app:WRKcreateListTitle($node, $model, 'en'),
                                              "es" : app:WRKcreateListTitle($node, $model, 'es')
                                            },
                         "year" :       map { "de" : app:WRKcreateListYear($node, $model, 'de'),
                                              "en" : app:WRKcreateListYear($node, $model, 'en'),
                                              "es" : app:WRKcreateListYear($node, $model, 'es')
                                            },
                         "place" :      map { "de" : app:WRKcreateListPlace($node, $model, 'de'),
                                              "en" : app:WRKcreateListPlace($node, $model, 'en'),
                                              "es" : app:WRKcreateListPlace($node, $model, 'es')
                                            }
                       }
    let $result := for $l in ("de", "en", "es")
                        let $facets := map {    "surname"   : app:WRKcreateListSurname($node, $model, $l),
                                                "title"     : app:WRKcreateListTitle($node, $model, $l),
                                                "year"      : app:WRKcreateListYear($node, $model, $l),
                                                "place"     : app:WRKcreateListPlace($node, $model, $l)
                                           }
                        return map:for-each($facets, function ($k, $v) {
                             let $filename     := 'worksNoJs_' || $l || '_' || $k || '.html'
                             let $debug        := console:log("[ADMIN] Saving (NoJs) " || $l || "_" || $k || " facets file in the database...")
                             let $storeStatus  := admin:saveTextFile("dummy", $filename, fn:serialize($v, map{"method":"json", "indent": true(), "encoding":"utf-8"}), "workslist")
                             let $debug        := console:log("[ADMIN] Exporting (NoJs) " || $l || "_" || $k || " facets json file...")
                             let $exportStatus := admin:exportJSONFile($filename, fn:serialize($v, map{"method":"json", "indent": true(), "encoding":"utf-8"}), "workslist")
                             return <div>Saved {$l}_{$k} works list to {$storeStatus} and exported it to {$exportStatus}.</div>
                          })
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] finalFacets (No Js) done!") else ()
    return $result
};

declare function admin:exportFileWRK ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Exporting finalFacets (Js)...") else ()
    let $fileNameDe         :=  'works_de.json'
    let $fileNameEn         :=  'works_en.json'
    let $fileNameEs         :=  'works_es.json'
    let $contentDe          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'de'), ", ") || "]") (: app:WRKfinalFacets returns a sequence of strings, one per work in the collection :)
    let $contentEn          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'en'), ", ") || "]")
    let $contentEs          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'es'), ", ") || "]")
    let $store :=  (admin:exportJSONFile($fileNameDe, $contentDe, 'workslist'),
                    admin:exportJSONFile($fileNameEn, $contentEn, 'workslist'),
                    admin:exportJSONFile($fileNameEs, $contentEs, 'workslist'))
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of works exported to filesystem ({serialize($store)})!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open works.html</a>
        </span>   
};

declare function admin:saveFileWRK ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Saving finalFacets (Js)...") else ()
    let $create-collection  :=  if (not(xmldb:collection-available($config:data-root))) then xmldb:create-collection($config:app-root, "data") else ()
    let $fileNameDe         :=  'works_de.xml'
    let $fileNameEn         :=  'works_en.xml'
    let $fileNameEs         :=  'works_es.xml'
    let $contentDe          := <sal>{app:WRKfinalFacets($node, $model, 'de')}</sal>
    let $contentEn          := <sal>{app:WRKfinalFacets($node, $model, 'en')}</sal>
    let $contentEs          := <sal>{app:WRKfinalFacets($node, $model, 'es')}</sal> 
    let $store              :=  (xmldb:store($config:data-root, $fileNameDe, $contentDe),
                                 xmldb:store($config:data-root, $fileNameEn, $contentEn),
                                 xmldb:store($config:data-root, $fileNameEs, $contentEs))
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of works saved to exist-db ({serialize($store)})!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open works.html</a>
        </span>   
};

declare function admin:exportFileWRKnoJs ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Exporting finalFacets (noJS)...") else ()
    let $fileNameDeSn := 'worksNoJs_de_surname.html'
    let $fileNameEnSn := 'worksNoJs_en_surname.html'
    let $fileNameEsSn := 'worksNoJs_es_surname.html'
    let $contentDeSn  := <div>{app:WRKcreateListSurname($node, $model, 'de')}</div>   
    let $contentEnSn  := <div>{app:WRKcreateListSurname($node, $model, 'en')}</div>
    let $contentEsSn  := <div>{app:WRKcreateListSurname($node, $model, 'es')}</div> 
    let $fileNameDeTi :=  'worksNoJs_de_title.html'
    let $fileNameEnTi :=  'worksNoJs_en_title.html'
    let $fileNameEsTi :=  'worksNoJs_es_title.html'
    let $contentDeTi  := <div>{app:WRKcreateListTitle($node, $model, 'de')}</div>   
    let $contentEnTi  := <div>{app:WRKcreateListTitle($node, $model, 'en')}</div>
    let $contentEsTi  := <div>{app:WRKcreateListTitle($node, $model, 'es')}</div>                                
    let $fileNameDeYe :=  'worksNoJs_de_year.html'
    let $fileNameEnYe :=  'worksNoJs_en_year.html'
    let $fileNameEsYe :=  'worksNoJs_es_year.html'
    let $contentDeYe  := <div>{app:WRKcreateListYear($node, $model, 'de')}</div>   
    let $contentEnYe  := <div>{app:WRKcreateListYear($node, $model, 'en')}</div>
    let $contentEsYe  := <div>{app:WRKcreateListYear($node, $model, 'es')}</div>  
    let $fileNameDePl :=  'worksNoJs_de_place.html'
    let $fileNameEnPl :=  'worksNoJs_en_place.html'
    let $fileNameEsPl :=  'worksNoJs_es_place.html'
    let $contentDePl  := <div>{app:WRKcreateListPlace($node, $model, 'de')}</div>   
    let $contentEnPl  := <div>{app:WRKcreateListPlace($node, $model, 'en')}</div>
    let $contentEsPl  := <div>{app:WRKcreateListPlace($node, $model, 'es')}</div>
    let $store :=  
        (admin:exportXMLFile($fileNameDeSn, $contentDeSn, "html"), admin:exportXMLFile($fileNameEnSn, $contentEnSn, "html"), admin:exportXMLFile($fileNameEsSn, $contentEsSn, "html"),
         admin:exportXMLFile($fileNameDeTi, $contentDeTi, "html"), admin:exportXMLFile($fileNameEnTi, $contentEnTi, "html"), admin:exportXMLFile($fileNameEsTi, $contentEsTi, "html"),
         admin:exportXMLFile($fileNameDeYe, $contentDeYe, "html"), admin:exportXMLFile($fileNameEnYe, $contentEnYe, "html"), admin:exportXMLFile($fileNameEsYe, $contentEsYe, "html"),
         admin:exportXMLFile($fileNameDePl, $contentDePl, "html"), admin:exportXMLFile($fileNameEnPl, $contentEnPl, "html"), admin:exportXMLFile($fileNameEsPl, $contentEsPl, "html")
        )
    return      
        <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Noscript-files exported to filesystem ({serialize($store)})!</p>
};

declare function admin:saveFileWRKnoJs ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Saving finalFacets (noJS)...") else ()
    let $create-collection  :=  
        if (not(xmldb:collection-available($config:data-root))) then 
            xmldb:create-collection(util:collection-name($config:data-root), $config:data-root) 
        else ()
    let $fileNameDeSn :=  'worksNoJs_de_surname.xml'
    let $fileNameEnSn :=  'worksNoJs_en_surname.xml'
    let $fileNameEsSn :=  'worksNoJs_es_surname.xml'
    let $contentDeSn  := <sal>{app:WRKcreateListSurname($node, $model, 'de')}</sal>   
    let $contentEnSn  := <sal>{app:WRKcreateListSurname($node, $model, 'en')}</sal>
    let $contentEsSn  := <sal>{app:WRKcreateListSurname($node, $model, 'es')}</sal> 
    let $fileNameDeTi :=  'worksNoJs_de_title.xml'
    let $fileNameEnTi :=  'worksNoJs_en_title.xml'
    let $fileNameEsTi :=  'worksNoJs_es_title.xml'
    let $contentDeTi  := <sal>{app:WRKcreateListTitle($node, $model, 'de')}</sal>   
    let $contentEnTi  := <sal>{app:WRKcreateListTitle($node, $model, 'en')}</sal>
    let $contentEsTi  := <sal>{app:WRKcreateListTitle($node, $model, 'es')}</sal>                                
    let $fileNameDeYe :=  'worksNoJs_de_year.xml'
    let $fileNameEnYe :=  'worksNoJs_en_year.xml'
    let $fileNameEsYe :=  'worksNoJs_es_year.xml'
    let $contentDeYe  := <sal>{app:WRKcreateListYear($node, $model, 'de')}</sal>   
    let $contentEnYe  := <sal>{app:WRKcreateListYear($node, $model, 'en')}</sal>
    let $contentEsYe  := <sal>{app:WRKcreateListYear($node, $model, 'es')}</sal>  
    let $fileNameDePl :=  'worksNoJs_de_place.xml'
    let $fileNameEnPl :=  'worksNoJs_en_place.xml'
    let $fileNameEsPl :=  'worksNoJs_es_place.xml'
    let $contentDePl  := <sal>{app:WRKcreateListPlace($node, $model, 'de')}</sal>   
    let $contentEnPl  := <sal>{app:WRKcreateListPlace($node, $model, 'en')}</sal>
    let $contentEsPl  := <sal>{app:WRKcreateListPlace($node, $model, 'es')}</sal>
    let $store :=  
        (xmldb:store($config:data-root, $fileNameDeSn, $contentDeSn), xmldb:store($config:data-root, $fileNameEnSn, $contentEnSn), xmldb:store($config:data-root, $fileNameEsSn, $contentEsSn),
         xmldb:store($config:data-root, $fileNameDeTi, $contentDeTi), xmldb:store($config:data-root, $fileNameEnTi, $contentEnTi), xmldb:store($config:data-root, $fileNameEsTi, $contentEsTi),
         xmldb:store($config:data-root, $fileNameDeYe, $contentDeYe), xmldb:store($config:data-root, $fileNameEnYe, $contentEnYe), xmldb:store($config:data-root, $fileNameEsYe, $contentEsYe),
         xmldb:store($config:data-root, $fileNameDePl, $contentDePl), xmldb:store($config:data-root, $fileNameEnPl, $contentEnPl), xmldb:store($config:data-root, $fileNameEsPl, $contentEsPl))
    return      
        <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Noscript-files saved to eXist-db ({serialize($store)})!</p>

};

(:declare %templates:wrap function admin:saveEditors($node as node()?, $model as map(*)?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Storing finalFacets...") else ()
    let $create-collection  :=  
        if (not(xmldb:collection-available($config:data-root))) then 
            xmldb:create-collection($config:app-root, "data") 
        else ()
    let $fileName := 'editors.xml'
    let $content :=  
        <sal>{
            ()
        }</sal>
    let $store := xmldb:store($config:data-root, $fileName, $content)
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of works saved!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open works.html</a>
        </span> 
};:)


(: #### RENDERING ADMINISTRATION FUNCTIONS #### :)

declare %templates:wrap function admin:renderAuthorLemma($node as node(), $model as map(*), $aid as xs:string*, $lid as xs:string*, $lang as xs:string*) {
    let $request            :=  request:get-parameter('aid', '')
    let $switchType         :=  if ($request) then $aid else $lid
    let $switchLabel1       :=  if ($request) then 'author.html' else 'lemma.html'
    let $switchLabel2       :=  if ($request) then '?aid=' else '?lid='
    let $create-collection  :=  if (not(xmldb:collection-available($config:temp))) then xmldb:create-collection($config:app-root, "temp") else ()
    let $fileMain           :=  $switchType || '.html'
    let $fileCited          :=  $switchType || '_cited.html'
    let $fileLemma          :=  $switchType || '_lemmata.html'
    let $filePersons        :=  $switchType || '_persons.html'
    let $filePlaces         :=  $switchType || '_places.html'
    let $main :=  
        if ($request) then 
            <div>
               { render-app:dispatch(doc($config:tei-authors-root || "/" || $aid || ".xml")//tei:body, "work", ())
               }
            </div>  
        else 
            <div>
                { render-app:dispatch(doc($config:tei-lemmata-root || "/" || $lid || ".xml")//tei:body, "work", ())
                }
            </div>  
    let $cited :=  
        <div>
            {app:cited($node, $model, $lang, $aid, $lid)}
        </div>
    let $lemmata :=  
        <div>
            {app:lemmata($node, $model, $lang, $aid, $lid)}
        </div>                                       
    let $persons :=  
        <div>
            {app:persons($node, $model, $aid, $lid)}
        </div>   
    let $places :=  
        <div>
            {app:places($node, $model, $aid, $lid)}
        </div>                              
    let $store :=  
        (xmldb:store($config:data-root, $fileMain, $main),
         xmldb:store($config:data-root, $filePersons, $persons), 
         xmldb:store($config:data-root, $fileCited,   $cited),
         xmldb:store($config:data-root, $fileLemma,   $lemmata),
         xmldb:store($config:data-root, $filePlaces,  $places))     
    return  
        <p class="lead">{$config:data-root||'/'||$switchType||'.html created'}
            <a href="{($switchLabel1||$switchLabel2||$switchType)}">&#32;&#32;
                <span class="glyphicon glyphicon-play" aria-hidden="true"></span>
            </a>
        </p>
};

(:
~ Creates HTML fragments and TXT datasets for works and stores them in the database.
:)
declare %templates:wrap function admin:renderWork($workId as xs:string*) as element(div) {
    let $start-time := util:system-time()
    let $wid := if ($workId) then $workId else request:get-parameter('wid', '*')
    
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering " || $wid || " (HTML and TXT).") else ()
    
    (: define the works to be fragmented: :)
    let $todo := 
        if ($wid = '*') then
            collection($config:tei-works-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph")]]
        else
            collection($config:tei-works-root)//tei:TEI[@xml:id = distinct-values($wid)][.//tei:text[@type = ("work_multivolume", "work_monograph")]]

    (: for each requested work: create fragments, insert them into the transformation, and produce some diagnostic info :)
    let $createData := 
        for $work-raw in $todo
            let $workId := $work-raw/@xml:id
        
            let $cleanStatus := admin:cleanCollection($workId, "html")
            
            (: (1) HTML :)
            
            let $start-time-a := util:system-time()
            let $htmlData := html:makeHTMLData($work-raw)
            let $htmlDataOld := html:makeHTMLDataOld($work-raw)
            (: Keep track of how long this work did take :)
            let $runtime-ms-a := ((util:system-time() - $start-time-a) div xs:dayTimeDuration('PT1S'))  * 1000
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Html files created. Saving...") else ()
            
            (: store data :)
            let $saveToc     := admin:saveFile($workId, $workId || "_toc.html", $htmlData('toc'), "html")
            let $exportToc   := admin:exportXMLFile($workId, $workId || "_toc.html", $htmlData('toc'), "html")
            let $savePages   := (
                admin:saveFile($workId, $workId || "_pages_de.html", $htmlDataOld('pagination_de'), "html"),
                admin:saveFile($workId, $workId || "_pages_en.html", $htmlDataOld('pagination_en'), "html"),
                admin:saveFile($workId, $workId || "_pages_es.html", $htmlDataOld('pagination_es'), "html")
                )
            let $exportPages := admin:exportXMLFile($workId, $workId || "_pages.html", $htmlData('pagination'), "html")
            let $exportFragments :=
                for $fragment in $htmlData('fragments') return
                    let $fileName := $fragment('number') || '_' || $fragment('tei_id') || '.html'
                    let $storeStatus := if ($fragment('html')) then admin:exportBinaryFile($workId, $fileName, $fragment('html'), 'html') else ()
                    return 
                        (: generate some HTML output to be shown in report :)
                        <div>
                            <h3>Fragment (new) {$fragment('index')}:</h3>
                            <h3>{$fragment('number')}: &lt;{$fragment('tei_name') || ' xml:id=&quot;' || $fragment('tei_id') 
                                 || '&quot;&gt;'} (Level {$fragment('tei_level')})</h3>
                            <div style="margin-left:4em;">
                                <div style="border:'3px solid black';background-color:'grey';">
                                    <code>{$wid}/{$fileName}:<br/>
                                        target xml:id={$fragment('tei_id')} <br/>
                                        prev xml:id={$fragment('prev')} <br/>
                                        next xml:id={$fragment('next')} <br/>
                                    </code>
                                </div>
                            </div>
                        </div>
            let $saveFragments :=
                for $fragmentOld in $htmlDataOld('fragments') return
                    let $fileName := $fragmentOld('number') || '_' || $fragmentOld('tei_id') || '.html'
                    let $storeStatusOld := if ($fragmentOld('html')) then admin:saveFile($workId, $fileName, $fragmentOld('html'), 'html') else ()
                    return 
                        (: generate some HTML output to be shown in report :)
                        <div>
                            <h3>Fragment (old) {$fragmentOld('index')}:</h3>
                            <h3>{$fragmentOld('number')}: &lt;{$fragmentOld('tei_name') || ' xml:id=&quot;' || $fragmentOld('tei_id') 
                                 || '&quot;&gt;'} (Level {$fragmentOld('tei_level')})</h3>
                            <div style="margin-left:4em;">
                                <div style="border:'3px solid black';background-color:'grey';">
                                    <code>{$wid}/{$fileName}:<br/>
                                        target xml:id={$fragmentOld('tei_id')} <br/>
                                        prev xml:id={$fragmentOld('prev')} <br/>
                                        next xml:id={$fragmentOld('next')} <br/>
                                    </code>
                                </div>
                            </div>
                        </div>

            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Html files saved. Cont'ing with plaintext files...") else ()
            
            (: (2) TXT :)
            
            let $txt-start-time := util:system-time()
            let $plainTextEdit       := txt:makeTXTData($work-raw, 'edit')
            let $txtEditExportStatus := admin:exportBinaryFile($workId, $workId || "_edit.txt", $plainTextEdit, "txt")
            let $txtEditSaveStatus   := admin:saveTextFile($workId, $workId || "_edit.txt", $plainTextEdit, "txt")
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Plain text (edit) file created and stored.") else ()
            let $plainTextOrig       := txt:makeTXTData($work-raw, 'orig')
            let $txtOrigEXportStatus := admin:exportBinaryFile($workId, $workId || "_orig.txt", $plainTextOrig, "txt")
            let $txtOrigSaveStatus   := admin:saveTextFile($workId, $workId || "_orig.txt", $plainTextOrig, "txt")
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Plain text (orig) file created and stored.") else ()
            let $txt-end-time := ((util:system-time() - $txt-start-time) div xs:dayTimeDuration('PT1S'))
            
            (: HTML & TXT Reporting :)
            
            return 
                <div>
                     <p><a href='{$config:idserver}/texts/{$workId}'>{string($workId)}</a>, Fragmentation depth: <code>{$htmlData('fragmentation_depth')}</code></p>
                     {if (count($htmlData('missed_elements'))) then <p>{count($htmlData('missed_elements'))} missed elements:<br/>
                        {for $e in $htmlData('missed_elements') return <code>{local-name($e) || '(' || string($e/@xml:id) || '); '}</code>}</p>
                      else ()}
                     {if (count($htmlData('unidentified_elements'))) then <p>{count($htmlData('unidentified_elements'))} gathered, but (due to missing @xml:id) unprocessable elements:<br/>
                        {for $e in $htmlData('unidentified_elements') return <code>{local-name($e)}</code>}</p>
                      else ()}
                     <p>{count($htmlData('tei_fragment_roots'))} gathered elements {if (count($htmlData('tei_fragment_roots'))) then 'of the following types: ' || <br/> else ()}
                        <code>{distinct-values(for $i in $htmlData('tei_fragment_roots') return local-name($i) || '(' || count($htmlData('tei_fragment_roots')[local-name(.) = local-name($i)]) || ')')}</code></p>
                     <p>Computing time (HTML): {      
                          if ($runtime-ms-a < (1000 * 60))      then format-number($runtime-ms-a div 1000, '#.##') || ' sec.'
                          else if ($runtime-ms-a < (1000 * 60 * 60)) then format-number($runtime-ms-a div (1000 * 60), '#.##') || ' min.'
                          else                                            format-number($runtime-ms-a div (1000 * 60 * 60), '#.##') || ' h.'
                        }
                     </p>
                     <p>Computing time (TXT: orig and edit): {$txt-end-time} seconds.</p>
                     {if ($config:debug = 'trace') then $exportFragments else ()}
                     {if ($config:debug = 'trace') then $saveFragments else ()}
               </div>

    
    (: (3) UPDATE TEI & TXT CORPORA :)
    
    (: (re-)create txt and xml corpus zips :)
(:  let $corpus-start-time := util:system-time()
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Corpus packages created and stored.") else ()
    let $createTeiCorpus := admin:createTeiCorpus(encode-for-uri($workId))
    let $createTxtCorpus := admin:createTxtCorpus(encode-for-uri($workId))
    let $corpus-end-time := ((util:system-time() - $corpus-start-time) div xs:dayTimeDuration('PT1S'))
:)    
    let $runtime-ms-raw       := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000 
    let $runtime-ms :=
        if ($runtime-ms-raw < (1000 * 60)) then format-number($runtime-ms-raw div 1000, "#.##") || " Sek."
        else if ($runtime-ms-raw < (1000 * 60 * 60)) then format-number($runtime-ms-raw div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms-raw div (1000 * 60 * 60), "#.##") || " Std."
    
    
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Done rendering HTML and TXT for " || $wid || ".") else ()
    let $debug := util:log('info', '[ADMIN] Created HTML for work ' || $wid || ' in ' || $runtime-ms || ' ms.')
    return 
        <div>
            <h2>HTML &amp; TXT Rendering</h2>
            <p>To render: {count($todo)} work(s); total computing time:
                {$runtime-ms}
            </p>
            <!--<p>Created TEI and TXT corpora in {$corpus-end-time} seconds.</p>-->
            <!--<p>/db/apps/salamanca/data reindiziert in {$index-end-time} Sekunden.</p>-->
            <hr/>
            {$createData}
        </div>
};

(:
 @param $processId: can be any string and serves only for avoiding conflicts with parallel corpus building routines
:)
declare function admin:createTeiCorpus($processId as xs:string) {
    let $corpusCollection := if (not(xmldb:collection-available($config:corpus-zip-root))) then xmldb:create-collection($config:webdata-root, 'corpus-zip') else ()
    (: Create temporary collection to be zipped :)
    let $checkTempRoot := if (not(xmldb:collection-available($config:temp-root))) then xmldb:create-collection($config:data-root, 'temp') else ()
    let $tempCollection := $config:temp-root || '/tei-corpus-temp-' || $processId
    let $removeStatus := if (xmldb:collection-available($tempCollection)) then xmldb:remove($tempCollection) else ()
    let $zipTmp := xmldb:create-collection($config:temp-root, 'tei-corpus-temp-' || $processId)  
    (: Get TEI data, expand them and store them in the temporary collection :)
    let $serializationOpts := 'method=xml expand-xincludes=yes omit-xml-declaration=no indent=yes encoding=UTF-8 media-type=application/tei+xml' 
    let $works := 
        for $reqWork in collection($config:tei-works-root)/tei:TEI/@xml:id[string-length(.) eq 5]/string()
            return if (doc-available($config:tei-works-root || '/' || $reqWork || '.xml')) then
                let $expanded := util:expand(doc($config:tei-works-root || '/' || $reqWork || '.xml')/tei:TEI, $serializationOpts) 
                let $store := xmldb:store-as-binary($tempCollection, $expanded/@xml:id || '.xml', $expanded)
                return $expanded
            else ()
    (: Create a zip archive from the temporary collection and store it :)
    let $zip := compression:zip(xs:anyURI($tempCollection), false())
    (: Clean the database from temporary files/collections :)
    let $removeStatus2 := for $work in $works return xmldb:remove($tempCollection, $work/@xml:id || '.xml')
    let $removeStatus3 := if (xmldb:collection-available($tempCollection)) then xmldb:remove($tempCollection) else ()
    let $filepath := $config:corpus-zip-root  || '/sal-tei-corpus.zip'
    let $filepath := $config:corpus-zip-root  || '/sal-tei-corpus.zip'
    let $removeStatus4 := 
        if (file:exists($filepath)) then
            xmldb:remove($filepath)
        else ()
    let $save   := xmldb:store-as-binary($config:corpus-zip-root , 'sal-tei-corpus.zip', $zip)
    let $export := admin:exportBinaryFile('sal-tei-corpus.zip', $zip, 'data')
    let $debug  := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] TEI corpus zip done (" || serialize($save) || "/" || serialize($export) || ").") else ()
    return
        <div>
            <h2>TEI Corpus</h2>
            <div>
                <p>
                    Created tei corpus zip file
                    {if ($save) then concat(" and saved it at ", $save) else ()}
                    {if ($export) then concat(" and exported it to the filesystem at ", $export) else ()}
                    .
                </p>    
                { if (not($save)) then <p style="color:red">TEI Corpus zip file could not be saved!</p> else () }
                { if (not($export)) then <p style="color:red">TEI Corpus zip file could not be exported!</p> else () }
            </div>
        </div>
};

(:
 @param $processId: can be any string and serves only for avoiding conflicts with parallel corpus building routines
:)
declare function admin:createTxtCorpus($processId as xs:string) {
    let $tempCollection := $config:temp-root || '/txt-corpus-temp-' || $processId
    let $corpusCollection := if (not(xmldb:collection-available($config:corpus-zip-root))) then xmldb:create-collection($config:webdata-root, 'corpus-zip') else ()
    let $checkTempRoot := if (not(xmldb:collection-available($config:temp-root))) then xmldb:create-collection($config:data-root, 'temp') else ()
    (: Create temporary collection to be zipped :)
    let $removeStatus := if (xmldb:collection-available($tempCollection)) then xmldb:remove($tempCollection) else ()
    let $zipTmp := xmldb:create-collection($config:temp-root, 'txt-corpus-temp-' || $processId)  
    (: Get TXT data (or if they aren't available, render them officially) and store them in the temporary collection :)
    let $storeWorks := 
        for $wid in collection($config:tei-works-root)/tei:TEI/@xml:id[string-length(.) eq 5 and app:WRKisPublished(<dummy/>,map{},.)]/string()
            return 
                let $renderOrig := 
                    if (util:binary-doc-available($config:txt-root || '/' || $wid || '/' || $wid || '_orig.txt')) then ()
                    else 
                        let $tei := util:expand(doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI)
                        let $debug := if ($config:debug = ("trace", "info")) then console:log('[ADMIN] Rendering txt version of work: ' || $config:tei-works-root || '/' || $wid || '.xml') else ()
                        let $origTxt := string-join(txt:dispatch($tei, 'orig'), '')
                        let $debug := if ($config:debug = ("trace", "info")) then console:log('[ADMIN] Rendered ' || $wid || ', string length: ' || string-length($origTxt)) else ()
                        return admin:saveFile($wid, $wid || "_orig.txt", $origTxt, "txt")
                let $storeOrig := xmldb:store-as-binary($tempCollection, $wid || '_orig.txt', util:binary-doc($config:txt-root || '/' || $wid || '/' || $wid || '_orig.txt'))
                let $renderEdit := 
                    if (util:binary-doc-available($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt')) then ()
                    else 
                        let $tei := util:expand(doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI)
                        let $editTxt := string-join(txt:dispatch($tei, 'edit'), '')
                        return admin:saveFile($wid, $wid || "_edit.txt", $editTxt, "txt")
                let $storeEdit := xmldb:store-as-binary($tempCollection, $wid || '_edit.txt', util:binary-doc($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt'))
                return ()
    (: Create a zip archive from the temporary collection and store it :)    
    let $zip := compression:zip(xs:anyURI($tempCollection), false())
    (: Clean the database from temporary files/collections :)
    let $removeStatus2 := for $file in xmldb:get-child-resources($tempCollection) return xmldb:remove($tempCollection, $file)
    let $removeStatus3 := if (xmldb:collection-available($tempCollection)) then xmldb:remove($tempCollection) else ()
    let $filepath := $config:corpus-zip-root  || '/sal-txt-corpus.zip'
    let $removeStatus4 := 
        if (file:exists($filepath)) then
            xmldb:remove($filepath)
        else ()
    let $save   := xmldb:store-as-binary($config:corpus-zip-root , 'sal-txt-corpus.zip', $zip)
    let $export := admin:exportBinaryFile('sal-txt-corpus.zip', $zip, 'data')
    let $debug  := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] TXT corpus zip done (" || serialize($save) || "/" || serialize($export) || ").") else ()
    return
        <div>
            <h2>TXT Corpus</h2>
            <div>
                <p>
                    Created txt corpus zip file
                    {if ($save) then concat(" and saved it at ", $save) else ()}
                    {if ($export) then concat(" and exported it to the filesystem at ", $export) else ()}
                    .
                </p>    
                { if (not($save)) then <p style="color:red">TXT Corpus zip file could not be saved!</p> else () }
                { if (not($export)) then <p style="color:red">TXT Corpus zip file could not be exported!</p> else () }
            </div>
        </div>
};

(: Generate fragments for sphinx' indexer to grok :)
(: NOTE: the largest part of the snippets creation takes place here, not in factory/*,
         since it applies to different types of texts (works, working papers) at once :)
declare function admin:sphinx-out($wid as xs:string*, $mode as xs:string?) {

    let $start-time := util:system-time()
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering sphinx snippets for " || $wid || ".") else ()

    (: Which works are to be indexed? :)
    let $todo := 
        if ($wid = '*') then
            collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "author_article", "lemma_article", "working_paper")]]
        else
            collection($config:tei-root)//tei:TEI[@xml:id = distinct-values($wid)]
    let $expanded := 
        for $work-raw in $todo
            let $cleanStatus := admin:cleanCollection($work-raw/@xml:id, "snippets")
            return util:expand($work-raw)

    (: which parts of those works constitute a fragment that is to count as a hit? :)
    let $nodes := 
        for $w in $expanded return
            if (starts-with($w/@xml:id, 'W0')) then
                (: works :)
                $w/tei:text//*[index:isBasicNode(.)]
            else if (starts-with($w/@xml:id, 'WP')) then
                (: working papers :)
                $w//tei:profileDesc//(tei:p|tei:keywords)
            else () (: TODO: authors, lemmata, etc. :)
    let $hits := 
        for $hit at $index in $nodes
            (: for each fragment, populate our sphinx fields and attributes :)
            let $work              := $hit/ancestor-or-self::tei:TEI
            let $work_id           := xs:string($work/@xml:id)
            let $nodeType := 
                if (starts-with($work_id, 'W0')) then 'work' 
                else if (starts-with($work_id, 'WP')) then 'wp' 
                else if (starts-with($work_id, 'A')) then 'author'
                else if (starts-with($work_id, 'L')) then 'lemma'
                else ()
            
            (: NOTE: The following extraction of information from TEI is supposed to work for works AND working papers, atm.
               Perhaps it would be better to separate logic for different types of texts in the future (TODO) :)
            let $work_type         := xs:string($work/tei:text/@type)
            let $teiHeader         := $work/tei:teiHeader
            let $work_author_name := sutil:formatName($teiHeader//tei:titleStmt//tei:author//tei:persName)
            let $work_author_id   := string-join($teiHeader//tei:titleStmt//tei:author//tei:persName/@ref, " ")
            let $work_title :=   
                if ($teiHeader//tei:titleStmt/tei:title[@type="short"] and not($work//tei:text[@type = "working_paper"])) then
                    $teiHeader//tei:titleStmt/tei:title[@type="short"]/text()
                else if ($teiHeader//tei:titleStmt/tei:title[@type="main"]) then
                    $teiHeader//tei:titleStmt/tei:title[@type="main"]/text()
                else $teiHeader//tei:titleStmt/tei:title[1]/text()
            let $work_year :=    
                if ($teiHeader//tei:sourceDesc//tei:date[@type = "summaryThisEd"]) then
                    xs:string($teiHeader//tei:sourceDesc//tei:date[@type = "summaryThisEd"])
                else if  ($teiHeader//tei:sourceDesc//tei:date[@type = "thisEd"]) then
                    xs:string($teiHeader//tei:sourceDesc//tei:date[@type = "thisEd"])
                else if  ($teiHeader//tei:sourceDesc//tei:date[@type = "summaryFirstEd"]) then
                    xs:string($teiHeader//tei:sourceDesc//tei:date[@type = "summaryFirstEd"])
                else if  ($teiHeader//tei:sourceDesc//tei:date[@type = "firstEd"]) then
                    xs:string($teiHeader//tei:sourceDesc//tei:date[@type = "firstEd"])
                else if  ($teiHeader//tei:date[@type ="digitizedEd"]) then
                    xs:string($teiHeader//tei:date[@type = "digitizedEd"])
                else ()
            let $hit_type := local-name($hit)
            let $hit_id := xs:string($hit/@xml:id)
            let $hit_citeID := if ($nodeType eq 'work') then sutil:getNodetrail($work_id, $hit, 'citeID') else ()
(:                doc($config:index-root || '/' || $work_id || '_nodeIndex.xml')//sal:node[@n = $hit_id]/@citeID/string() :)
            let $hit_language := xs:string($hit/ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang)
            let $hit_fragment := 
                if ($hit_id and xmldb:collection-available($config:html-root || '/' || $work_id)) then
                    sutil:getFragmentID($work_id, $hit_id)
                else ()
            let $hit_fragment_number := 
                if ($hit_fragment) then
                    xs:int(substring($hit_fragment, 1, 4))
                else ()
            let $hit_path := 
                if ($hit_fragment) then
                    $config:webserver || "/html/" || $work_id || "/" || $hit_fragment || ".html"
                else
                    "#No fragment discoverable!"
            let $hit_url :=      
                if ($hit_fragment and $nodeType eq 'work') then
                    $config:idserver || "/texts/"   || $work_id || ':' || $hit_citeID
                else if ($nodeType eq 'author') then
                    $config:idserver || "/authors/" || $work_id
                else if ($nodeType eq 'lemma') then
                    $config:idserver || "/lemmata/" || $work_id
                else if ($nodeType eq 'wp') then
                    $config:webserver || "/workingPaper.html?wpid=" || $work_id
                else
                    "#No fragment discoverable!"
            let $nodeIndex         := doc($config:index-root || "/" || $work_id || "_nodeIndex.xml")
            let $nodeCrumbtrails   := doc($config:crumb-root || "/" || $work_id || "_crumbtrails.xml")
            let $hit_label         := string($nodeIndex//sal:node[@n eq $hit_id]/@label)
            let $hit_crumbtrail    := xmldb:encode(fn:serialize($nodeCrumbtrails//sal:nodecrumb[@xml:id eq $hit_id]/sal:crumbtrail/node(), map{"method":"xhtml", "escape-uri-attributes":false(), "omit-xml-declaration":true() }))

            (: Here we define the to-be-indexed content! :)
            let $hit_content_orig := 
                if ($hit_id) then
                    if ($nodeType eq 'work') then
                        normalize-space(string-join(txt:dispatch($hit, 'snippets-orig'), ''))
                    else normalize-space(string-join(render-app:dispatch($hit, 'snippets-orig', ()), ''))
                else
                    'There is no xml:id in the ' || $hit_type || ' hit!'
            let $hit_content_edit := 
                if ($hit_id) then
                    if ($nodeType eq 'work') then
                        normalize-space(string-join(txt:dispatch($hit, 'snippets-edit'), ''))
                    else normalize-space(string-join(render-app:dispatch($hit, 'snippets-edit', ()), ''))
                else
                    'There is no xml:id in the ' || $hit_type || ' hit!'
            
            (: Now build a sphinx "row" for the fragment :)
            let $sphinx_id    := xs:long(substring($work_id, functx:index-of-string-first($work_id, "0"))) * 1000000 + ( (string-to-codepoints(substring($work_id, 1, 1)) + string-to-codepoints(substring($work_id, 2, 1))) * 10000 ) + $index
            let $html_snippet :=
                <sphinx:document id="{$sphinx_id}">
                    <div>
                        <h3>Hit
                            <sphinx_docid>{$sphinx_id}</sphinx_docid>
                            in <sphinx_work_type>{$work_type}</sphinx_work_type>{$config:nbsp}<sphinx_work>{$work_id}</sphinx_work>:<br/>
                            <sphinx_author>{$work_author_name}</sphinx_author>
                            {if ($work_author_id) then " (" || <sphinx_authorid>{$work_author_id}</sphinx_authorid> || ")" else ()},
                            <sphinx_title>{$work_title}</sphinx_title>
                            (<sphinx_year>{$work_year}</sphinx_year>)
                        </h3>
                        <h4>Label: {$hit_label}</h4>
                        <div>Crumbtrail: {$hit_crumbtrail}</div>
                        <h4>Hit
                            language: &quot;<sphinx_hit_language>{$hit_language}</sphinx_hit_language>&quot;,
                            node type: &lt;<sphinx_hit_type>{$hit_type}</sphinx_hit_type>&gt;,
                            node xml:id: &quot;<sphinx_hit_id>{$hit_id}</sphinx_hit_id>&quot;
                        </h4>
                        <p>
                            <em><sphinx_description_orig>{$hit_content_orig}</sphinx_description_orig></em>
                        </p>
                        <p>
                            <em><sphinx_description_edit>{$hit_content_edit}</sphinx_description_edit></em>
                        </p>
                        <p>
                            find it in fragment number {$hit_fragment_number} here: <a href="{$hit_path}"><sphinx_html_path>{$hit_path}</sphinx_html_path></a><br/>
                            or here: <a href="{$hit_url}"><sphinx_fragment_path>{$hit_url}</sphinx_fragment_path></a>
                        </p>
                        <hr/>
                    </div>
                </sphinx:document>

            let $sphinx_snippet :=
                <sphinx:document id="{$sphinx_id}" xml:space="preserve">
                    <sphinx_docid>{$sphinx_id}</sphinx_docid>
                    <sphinx_work>{$work_id}</sphinx_work>
                    <sphinx_work_type>{$work_type}</sphinx_work_type>
                    <sphinx_author>{$work_author_name}</sphinx_author>
                    <sphinx_authorid>{$work_author_id}</sphinx_authorid>
                    <sphinx_title>{$work_title}</sphinx_title>
                    <sphinx_year>{$work_year}</sphinx_year>
                    <sphinx_hit_language>{$hit_language}</sphinx_hit_language>
                    <sphinx_hit_type>{$hit_type}</sphinx_hit_type>
                    <sphinx_hit_id>{$hit_id}</sphinx_hit_id>
                    <sphinx_hit_label>{$hit_label}</sphinx_hit_label>
                    <sphinx_hit_crumbtrail>{$hit_crumbtrail}</sphinx_hit_crumbtrail>
                    <sphinx_description_orig>{$hit_content_orig}</sphinx_description_orig>
                    <sphinx_description_edit>{$hit_content_edit}</sphinx_description_edit>
                    <sphinx_html_path>{$hit_path}</sphinx_html_path>
                    <sphinx_fragment_path>{$hit_url}</sphinx_fragment_path>
                    <sphinx_fragment_number>{$hit_fragment_number}</sphinx_fragment_number>
                </sphinx:document>

            let $fileName := format-number($index, "00000") || "_" || $hit_id || ".snippet.xml"
            let $exportStatus := if ($hit_id) then admin:exportXMLFile($work_id, $fileName, $sphinx_snippet, "snippets") else ()
            let $storeStatus  := if ($hit_id) then admin:saveFile($work_id, $fileName, $sphinx_snippet, "snippets") else ()

            order by $work_id ascending
            return 
                if ($mode = "html") then
                    $html_snippet
                else if ($mode = "sphinx") then
                    $sphinx_snippet
                else ()

(: Now return statistics, schema and the whole document-set :)
    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Done rendering sphinx snippets for " || $wid || ".") else ()
    return 
        if ($mode = "html") then
            <div>
                <h2>Sphinx Snippets</h2>
                <div>
                    <sphinx:docset>
                        <p>
                            Zu indizieren: {count($todo)} Werk(e); {count($hits)} Fragmente generiert; gesamte Rechenzeit:
                            {if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
                             else if ($runtime-ms < (1000 * 60 * 60)) then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
                             else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
                            }
                        </p>
                        {if ($config:debug = ("trace")) then $hits else ()}
                    </sphinx:docset>
                </div>
            </div>
        else if ($mode = "sphinx") then
            <sphinx:docset>
                {$sphinx:schema}
                {$hits}
            </sphinx:docset>
        else
            <div>
                <h2>Sphinx Snippets</h2>
                <div>
                    <p>Called with unknown mode &quot;{$mode}&quot; (as httpget parameter).</p>
                </div>
            </div>
};

(:
~ Creates nodes index for works
:)
declare function admin:createNodeIndex($wid as xs:string*) {
    let $debug := if ($config:debug = ("trace", "info")) then
        let $d := console:log("[ADMIN] Creating node index for " || $wid || ".")
        return util:log("info", "[ADMIN] Creating node index for " || $wid || ".")
    else
        ()

    let $start-time := util:system-time()
    
    (: define the works to be indexed: :)
    let $teiRoots := 
        if ($wid = '*') then
            collection($config:tei-works-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph")]]
        else
            collection($config:tei-works-root)//tei:TEI[@xml:id = distinct-values($wid)]

    (: for each requested work, create an individual index :)
    let $indexResults :=
        for $tei in $teiRoots return
            let $start-time-a := util:system-time()
            let $wid := string($tei/@xml:id)
            let $indexing := index:makeNodeIndex($tei)
            let $index := $indexing('index')
            let $fragmentationDepth := $indexing('fragmentation_depth')
            let $missed-elements := $indexing('missed_elements')
            let $unidentified-elements := $indexing('unidentified_elements')

            (: save final index file :)
            let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Saving index file ...") else ()
            let $indexSaveStatus   := admin:saveFile($wid, $wid || "_nodeIndex.xml", $index, "index")
            let $indexExportStatus := admin:exportXMLFile($wid, $wid || "_nodeIndex.xml", $index, "index")
            let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Node index of "  || $wid || " successfully created and saved/exported (to " || $indexSaveStatus || "; " || $indexExportStatus || ").") else ()
            let $debug := if ($config:debug = ("info")) then console:log("[ADMIN] Node index of "  || $wid || " successfully created.") else ()

            (: Reporting... :)
            let $runtime-ms-a := ((util:system-time() - $start-time-a) div xs:dayTimeDuration('PT1S'))  * 1000
            (: render and store the work's plain text :)
            return 
                <div>
                     <h4>{$wid}</h4>
                     <p>Fragmentation depth: <code>{$fragmentationDepth}</code></p>
                     {if (count($missed-elements)) then <p>{count($missed-elements)} missed elements:<br/>
                        {for $e in $missed-elements return <code>{local-name($e) || "(" || string($e/@xml:id) || "); "}</code>}</p>
                      else ()}
                     {if (count($unidentified-elements)) then <p>{count($unidentified-elements)} gathered, but (due to missing @xml:id) unprocessable elements:<br/>
                        {for $e in $unidentified-elements return <code>{local-name($e)}</code>}</p>
                      else ()}
                     <p>{count($index//sal:node)} gathered index elements {if ($indexing('target_set_count') gt 0) then "of the following types: " || <br/> else ()}
                        <code>{for $t in distinct-values($index//sal:node/@type/string()) return $t || "(" || count($index//sal:node[@type eq $t]) || ")"}</code></p>
                     <p>Computing time: {      
                          if ($runtime-ms-a < (1000 * 60)) then format-number($runtime-ms-a div 1000, "#.##") || " Sek."
                          else if ($runtime-ms-a < (1000 * 60 * 60)) then format-number($runtime-ms-a div (1000 * 60), "#.##") || " Min."
                          else format-number($runtime-ms-a div (1000 * 60 * 60), "#.##") || " Std."
                        }
                     </p>
               </div>
    let $runtime-ms-raw := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000 
    let $runtime-ms :=
        if ($runtime-ms-raw < (1000 * 60)) then format-number($runtime-ms-raw div 1000, "#.##") || " Sek."
        else if ($runtime-ms-raw < (1000 * 60 * 60)) then format-number($runtime-ms-raw div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms-raw div (1000 * 60 * 60), "#.##") || " Std."
    let $debug := if ($config:debug = ("trace", "info")) then util:log("info", "[ADMIN] Finished node indexing for " || $wid || " in " || $runtime-ms || ".") else ()
    
    return 
        <div>
            <h4>Node Indexing</h4>
            {$indexResults}
        </div>
};

declare function admin:uploadPdf($rid as xs:string) {
    let $PdfInput := request:get-uploaded-file-name('FileUpload')
    let $content  := request:get-uploaded-file-data('FileUpload')
    return
        if ($rid eq substring-before($PdfInput, ".pdf")) then
            <div>            
                {xmldb:store($config:pdf-root, $PdfInput, $content) }
                <p>Pdf successfully uploaded.</p>    <!-- here strangely replaced by "false", even if it is indeed uploaded. -->
                <hr/>
            </div>
        else if (fn:empty( request:get-uploaded-file-data('FileUpload'))) then (:no used here, as there is already a bugMessage iin the file  304ab2dcd6db8af278089eb4d27c6b980f3ec6554bcac5d1a29f5009a22723b9 in eXist-db/data/blob :)
            <results>
                <message>There is not input PDF file. Please upload the PDF before submitting it.</message>
            </results>
        else
            <results>
                <message>The PDF {$PdfInput} of the work {$rid} could not be uploaded. The file does not correspond to the work. Did you try to upload the PDF for the work {$rid} ?</message>
            </results>
};

declare function admin:createPdf($rid as xs:string){
    let $pdf-start-time           := util:system-time()
    let $doctotransform as node() := doc($config:tei-works-root || '/'|| $rid || '.xml')//tei:TEI
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Creating pdf from " || $rid || " ...") else ()
    let $debug := if ($config:debug = "trace") then console:log("[PDF-" || $rid ||"] Transforming into XSL-FO...") else ()
    let $doctransformed2          := transform:transform($doctotransform, "xmldb:exist:///db/apps/salamanca/modules/factory/works/pdf/generic_template.xsl", ())
    (:let $storexslfo := xmldb:store($config:xsl-fo-root ,$rid || '_xsl-fo.xml', $doctransformed2) :)

    (:let $xsl-fo-document as document-node() := doc($config:xsl-fo-root || '/'|| $rid || '_xsl-fo.xml') :)
    let $debug := if ($config:debug = "trace") then console:log("[PDF-" || $rid ||"] Transforming from XSL-FO to PDF...") else ()                         
    let $media-type as xs:string  := 'application/pdf'
    let $renderedxslfo            := xslfo:render($doctransformed2, $media-type, ())

    let $savedPdfFile             := xmldb:store($config:pdf-root, $rid || '.pdf', $renderedxslfo)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Stored pdf from " || $rid || " at " || $savedPdfFile || ".") else ()   
    let $exportedPdfFile          := admin:exportBinaryStream($rid, $rid || '.pdf', $renderedxslfo, 'pdf')
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Exported pdf from " || $rid || " to " || $exportedPdfFile || ".") else ()   

    let $pdf-end-time := util:system-time() 
    let $runtime-pdf := ((util:system-time() - $pdf-start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    return
        if ($doctransformed2)   (:(doc-available($config:xsl-fo-root || '/'|| $rid || '_xsl-fo.xml')) :)   then
            <div>
                {$savedPdfFile} 
                <p> The transformation from XML to PDF was successfull and the file is stored in the pdf collection.
                    Duration: {if ($runtime-pdf < (1000 * 60)) then format-number($runtime-pdf div 1000, "#.##") || " Sec."
                               else if ($runtime-pdf < (1000 * 60 * 60)) then format-number($runtime-pdf div (1000 * 60), "#.##") || " Min."
                               else format-number($runtime-pdf div (1000 * 60 * 60), "#.##") || " Hrs."
                              }
                </p>
            </div>
        else ()
};


declare function admin:createCrumbtrails($wid as xs:string){
   let $debug := if ($config:debug = ("trace", "info")) then
        let $d := console:log("[ADMIN] Creating Crumbtrails  for " || $wid || ".")
        return util:log("warn", "[ADMIN] Creating Crumbtrails for " || $wid || ".")
    else ()

    let $start-time := util:system-time()

    (: define the works to be indexed: :)
    let $teiRoots :=  if ($wid = '*') then
                          collection($config:tei-works-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph")]]
                      else
                          collection($config:tei-works-root)//tei:TEI[@xml:id = distinct-values($wid)]

    (: for each requested work, create an individual crumbtrails :)
    let $crumbResults :=
        for $tei in $teiRoots return
            let $start-time-a          := util:system-time()
            let $wid                   := string($tei/@xml:id)
            let $crumbing              := crumb:createCrumbNode($tei)
            let $crumb                 := $crumbing('crumbtrails')
            let $fragmentationDepth    := $crumbing('fragmentation_depth')
            let $missed-elements       := $crumbing('missed_elements')
            let $unidentified-elements := $crumbing('unidentified_elements')

            (: save final crumb file :)
            let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Saving Crumbtrails ...") else ()
            let $crumbSaveStatus := admin:saveFile($wid, $wid || "_crumbtrails.xml", $crumb, "crumbtrails")
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Crumbtrails of "  || $wid || " successfully saved.") else ()

            let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Exporting Crumbtrails ...") else ()
            let $crumbExportStatus := admin:exportXMLFile($wid, $wid || "_crumbtrails.xml", $crumb, "crumbtrails")
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Crumbtrails of "  || $wid || " successfully exported.") else ()

            (: Reporting... :)
            let $runtime-ms-a := ((util:system-time() - $start-time-a) div xs:dayTimeDuration('PT1S'))  * 1000
            return 
                <div>
                     <h4>{$wid}</h4>
                     <p>Fragmentation depth: <code>{$fragmentationDepth}</code></p>
                     {if (count($missed-elements)) then <p>{count($missed-elements)} missed elements:<br/>
                        {for $e in $missed-elements return <code>{local-name($e) || "(" || string($e/@xml:id) || "); "}</code>}</p>
                      else ()}
                     {if (count($unidentified-elements)) then <p>{count($unidentified-elements)} gathered, but (due to missing @xml:id) unprocessable elements:<br/>
                        {for $e in $unidentified-elements return <code>{local-name($e)}</code>}</p>
                      else ()}
                     <p>{count($crumb//sal:nodecrumb)} gathered crumbtrails elements {if ($crumbing('target_set_count') gt 0) then "of the following types: " || <br/> else ()}
                        <code>{for $t in distinct-values($crumb//sal:nodecrumb/@type/string()) return $t || "(" || count($crumb//sal:nodecrumb[@type eq $t]) || ")"}</code>
                     </p>
                     <p>{
                        (: If we have an index file, we can do a quick quality check :)
                        if (doc-available($config:index-root || "/" || $wid || "_nodeIndex.xml")) then 
                            let $index        := doc($config:index-root || "/" || $wid || "_nodeIndex.xml")/sal:index
                            let $types_index  := map:merge(for $t in distinct-values($index//sal:node/@type/string()) return
                                                                map:entry($t, $index//sal:node[@type eq $t]/@n/string()))
                            let $types_crumb  := map:merge(for $t in distinct-values($crumb//sal:nodecrumb/@type/string()) return
                                                        map:entry($t, $crumb//sal:nodecrumb[@type eq $t]/@xml:id/string()))
                            return if (deep-equal($types_crumb, $types_index)) then
                                "The crumb and the index are consistent."  (: comparing here the maps without loop :)
                            else
                                "The crumb and the index are NOT consistent: please check again the missing nodes!"
                        else
                            "We don't have an index file for this work yet, so cannot do a quality check. " ||
                            "Better have an up-to-date index file before creating crumbtrails..."
                     }</p>

                     <p>Computing time: {      
                          if ($runtime-ms-a < (1000 * 60)) then format-number($runtime-ms-a div 1000, "#.##") || " Sek."
                          else if ($runtime-ms-a < (1000 * 60 * 60)) then format-number($runtime-ms-a div (1000 * 60), "#.##") || " Min."
                          else format-number($runtime-ms-a div (1000 * 60 * 60), "#.##") || " Std."
                     }</p>
               </div>

    (: Time counting :)
    let $runtime-ms-raw := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000 
    let $runtime-ms :=
        if ($runtime-ms-raw < (1000 * 60)) then format-number($runtime-ms-raw div 1000, "#.##") || " Sek."
        else if ($runtime-ms-raw < (1000 * 60 * 60)) then format-number($runtime-ms-raw div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms-raw div (1000 * 60 * 60), "#.##") || " Std."
    let $debug := if ($config:debug = ("trace", "info")) then util:log("warn", "[ADMIN] Finished node crumbing for " || $wid || " in " || $runtime-ms || ".") else ()
    
    return 
        <div>
            <h4>Node Crumbtrails</h4>
            {$crumbResults}
        </div>

};

(:
~ Creates routing information; saves, exports and posts them to caddy.
:)
declare function admin:createRoutes() {
    for $i in collection($config:tei-works-root)//tei:TEI[descendant::tei:text/@type = ('work_multivolume', 'monograph')]
    return admin:createRoutes($i/@xml:id/string())
};

declare function admin:createRoutes($wid as xs:string) {
    let $start-time := util:system-time()
    let $debug := console:log("[ADMIN] Routing: Creating routing ...")
    let $index                  := if (doc-available($config:index-root || "/" || $wid || "_nodeIndex.xml")) then doc($config:index-root || "/" || $wid || "_nodeIndex.xml")/sal:index else ()
    let $crumbtrails            := if (doc-available($config:crumb-root || "/" || $wid || "_crumbtrails.xml")) then doc($config:crumb-root || "/" || $wid || "_crumbtrails.xml")/sal:crumb else ()
    let $routingWork            := admin:buildRoutingInfoWork($wid, $crumbtrails)
    let $routingNodes           := array{fn:for-each($index//sal:node, function($k) {admin:buildRoutingInfoNode($wid, $k, $crumbtrails)} )}
    let $routingVolumeDetails   :=  if ($index) then
                                        array{fn:for-each($index//sal:node[@subtype = "work_volume"], function($k) {admin:buildRoutingInfoDetails($wid || '_' || $k/@n)} )}
                                    else
                                        let $volumes := doc($config:tei-works-root || '/' || $wid || '.xml')//xi:include[contains(@href, '_Vol')]/@href/string()
                                        return array{fn:for-each($volumes, function($k) {admin:buildRoutingInfoDetails(tokenize($k, '\.')[1])} )}
    let $routingWorkDetails     := array{ admin:buildRoutingInfoDetails($wid) }
    let $routingTable           := array:join( ( $routingWork, $routingNodes, $routingVolumeDetails, $routingWorkDetails ) )

    let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Routing: Joint routing table: " || substring(serialize($routingTable, map{"method":"json", "indent": false(), "encoding":"utf-8"}), 1, 500) || " ...") else ()

    (: save routing table in database :)
    let $routingSaveStatus  :=  if ($routingTable instance of array(*) and array:size($routingTable) > 0) then
                                    admin:saveTextFile($wid, $wid || '_routes.json', fn:serialize($routingTable, map{"method":"json", "indent": true(), "encoding":"utf-8"}), 'routes')
                                else ()
    let $debug := if ($config:debug = ("info", "trace")) then console:log("[ADMIN] Routing: Table saved as " || $routingSaveStatus || ".") else ()

    (: export routing table to filesystem :)
    let $debug := console:log("[ADMIN] Routing: Exporting routing file with " || array:size($routingTable) || " entries...")
    let $routingExportStatus    := admin:exportJSONFile($wid, $wid || "_routes.json", $routingTable, "routing")
    let $debug := if ($routingExportStatus) then
                        console:log("[ADMIN] Routing: Routing table successfully exported to " || $routingExportStatus || ".")
                    else
                        console:log("[ADMIN] Routing: There has been a problem saving routing table to " || $routingExportStatus || ".")

    (: post routing table to caddy :)
    let $entriesBefore          := let $rt := net:getRoutingTable()
                                   return
                                        if (count($rt) > 0) then array:size($rt)
                                        else 0
    let $addedEntries           := if (string-length($config:caddyAPI) > 0 and array:size($routingTable) > 0) then
                                        let $debug := console:log("[ADMIN] Routing: live routing table contains " || $entriesBefore || " entries, now posting " || array:size($routingTable) || " additional ones...")
                                        return net:postRoutingTable($routingTable)
                                    else
                                        let $debug := console:log("[ADMIN] Routing: WARNING!! - No nodes routing info to post ($config:caddyAPI = " || $config:caddyAPI || ", array:size($routingTable) = " || array:size($routingTable) || ").")
                                        return 0
    let $routingTableAfter      := net:getRoutingTable()
    let $debug := if ($config:debug = ('trace')) then console:log("[ADMIN] Routing: Routing table: " || serialize($routingTableAfter)) else ()
    let $entriesAfter           := if ($routingTableAfter instance of array(xs:string)) then array:size($routingTableAfter) else 0
    let $debug :=   if ($addedEntries > 0 and $entriesBefore + $addedEntries = $entriesAfter) then
                        console:log("[ADMIN] Routing done: Routing table successfully posted, live routing table now contains " || $entriesBefore || "+" || $addedEntries || "=" || $entriesAfter || " entries.")
                    else if ($addedEntries > 0) then 
                        console:log("[ADMIN] Routing done: WARNING! Routing table posted, but something seems to be wrong with the numbers: " || $entriesBefore || " $entriesBefore + " || $addedEntries || " $addedEntries != " || $entriesAfter || " $entriesAfter. Maybe relevant entries had been in the routing table before and had to be deleted?")
                    else
                        console:log("[ADMIN] Routing done: WARNING!! - No entries posted. Live routing table contains " || $entriesAfter || " .")
    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    let $runtimeString := 
        if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
        else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."

    return
        <div>
            <h2>Routing information</h2>
            <p>Created {array:size($routingTable)} routing entries for {$wid}, saved at {$routingSaveStatus} and exported to {$routingExportStatus}.<br/>
               Posted to caddy server: {$entriesBefore} + {$addedEntries} = {$entriesAfter} routing entries now.</p>
            <p>It all took {$runtimeString}.</p>
        </div>
};

declare function admin:buildRoutingInfoNode($wid as xs:string, $item as element(sal:node), $crumbtrails as element(sal:crumb)) {
    let $crumb := $crumbtrails//sal:nodecrumb[@xml:id eq $item/@n]//a[last()]/@href/string()
    let $value := map {
                    "input" :   concat("/texts/", $wid, ":", $item/@citeID/string()),
                    "outputs" : array { ( $crumb, 'yes' ) }
                  }
(:    let $debug := console:log("[ADMIN] routing entry: " || serialize($value, map{"method":"json"}) || "."):)
    return $value
};

declare function admin:buildRoutingInfoWork($wid as xs:string, $crumbtrails as element(sal:crumb)*) {
    let $firstCrumb  := if (($crumbtrails//a[1])[1]/@href) then ($crumbtrails//a[1])[1]/@href/string() else ""
    let $value := array {
                            ( map {
                                    "input" :   concat("/texts/", $wid ),
                                    "outputs" : array { ( $firstCrumb, 'yes' ) }
                                  }
                            )
                        }
(:    let $debug := console:log("[ADMIN] routing entry: " || serialize($value, map{"method":"json"}) || "."):)
    return $value
};

declare function admin:buildRoutingInfoDetails($id) {
    let $inputID := if (contains($id, 'ol')) then
                        tokenize($id, '_')[1] || ':vol' || xs:string(number(substring(tokenize($id, '_')[2], 4)))
                    else
                        $id
    let $debug := if ($config:debug = "trace") then console:log('$id: ' || $id || ', $inputID: ' || $inputID || '.') else ()
    return
        map {
              "input" :   concat("/texts/", $inputID, '_details' ),
              "outputs" : array { ( concat(tokenize($id, '_')[1], '/html/', $id, '_details.html'), 'yes' ) }
        }
};

(:
~ Creates RDF information.
:)
declare function admin:createRDF($rid as xs:string) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering RDF for " || $rid || ".") else ()
    let $rid :=  
        if (starts-with($rid, "authors/")) then
            substring-after($rid, "authors/")
        else if (starts-with($rid, "texts/")) then
            substring-after($rid, "texts/")
        else $rid
    let $start-time := util:system-time()
    (:  let $xtriplesUrl :=
        $config:webserver || '/xtriples/extract.xql?format=rdf&amp;configuration='
        || $config:webserver || '/xtriples/createConfig.xql?resourceId=' || $rid :)
    let $xtriplesUrl :=
           'https://c100-101.cloud.gwdg.de/exist/apps/salamanca/services/lod/extract.xql?format=rdf&amp;configuration='
        || 'https://c100-101.cloud.gwdg.de/exist/apps/salamanca/services/lod/createConfig.xql?resourceId=' || $rid
    let $debug := 
        if ($config:debug = ("info", "trace")) then
            let $d := console:log("[Admin] Requesting " || $xtriplesUrl || " ...")
            return util:log("info", "Requesting " || $xtriplesUrl || ' ...')
        else ()
    let $rdf := 
        (: if this throws an "XML Parsing Error: no root element found", this might be due to the any23 service not being available
         - check it via "curl -X POST http://localhost:8880/any23/any23/rdfxml", for example:)
        doc($xtriplesUrl)
    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    let $runtimeString := 
        if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
        else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
    let $log    := util:log('info', 'Extracted RDF for ' || $rid || ' in ' || $runtimeString)
    let $export := admin:exportXMLFile($rid, $rid || '.rdf', $rdf, 'rdf')
    let $save   := admin:saveFile($rid, $rid || '.rdf', $rdf, 'rdf')
    let $debug  := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Done rendering RDF for " || $rid || ".") else ()
    return 
        <div>
            <h2>RDF Extraction</h2>
            <p>Extracted RDF in {$runtimeString} and saved at {$save}</p>
            <div style="margin-left:5em;">{if ($config:debug = ("trace")) then $rdf else ()}</div>
        </div>
};

(:
~ Creates and stores a IIIF manifest/collection for work $wid.
:)
declare function admin:createIIIF($wid as xs:string) {
    let $start-time := util:system-time()
    let $debug := 
        if ($config:debug eq 'trace') then
            util:log("info", "Creation of IIIF resource requested, work id: " || $wid || ".")
        else ()
    let $resource := iiif:createResource($wid)
    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    let $runtimeString := 
        if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
        else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
    let $log    := util:log('info', 'Extracted IIIF for ' || $wid || ' in ' || $runtimeString)
    let $store  := if ($resource instance of map(*) and map:size($resource) > 0) then admin:saveTextFile($wid, $wid || '.json', fn:serialize($resource, map{"method":"json", "indent": true(), "encoding":"utf-8"}), 'iiif') else ()
    let $export := if ($resource instance of map(*) and map:size($resource) > 0) then admin:exportJSONFile($wid, $wid || '.json', $resource, 'iiif') else ()
    return $resource
};

declare function admin:StripLBs($input as xs:string) {
    normalize-space(replace($input, '&#10;', ' '))
};

(: 
~ Creates and stores work details for catalog page(s).
:)
declare function admin:createDetails($wid as xs:string) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering Details for " || $wid || ".") else ()
    let $start-time := util:system-time()
    let $todo := 
        if ($wid = '*') then
            collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "work_volume")]]
        else
            collection($config:tei-root)//tei:TEI[@xml:id = distinct-values($wid)]
    let $expanded :=  for $work-raw in $todo return util:expand($work-raw)

    let $process_loop := for $work in $expanded

        let $id        := $work/@xml:id/string()
        let $public_id := if ($work//tei:text[@type = ("work_multivolume", "work_monograph")]) then
                              $id
                          else
                              tokenize($id, '_')[1] || ':vol' || $work//tei:text[@type = "work_volume"]/@n/string()

        let $teiHeader := $work//tei:teiHeader

        (: we don't have iiif manifests for volumes, only for multivols and monographs :)
        let $iiif_file      := if ($work//tei:text[@type = ("work_multivolume", "work_monograph")]) then
                                  $config:iiif-root || '/' || $id || '.json'
                               else
                                  let $mulivol_id := $teiHeader//tei:notesStmt/tei:relatedItem[@type eq 'work_multivolume']/@target/tokenize(., ':')[2]
                                  return $config:iiif-root || '/' || $mulivol_id || '.json'
        let $iiif           := json-doc($iiif_file)

        let $volume_names   := for $v in $teiHeader//tei:notesStmt/tei:relatedItem[@type eq 'work_volume'] return $v/@target/tokenize(., ':')[2]
        let $debug          := if (count($volume_names)>0) then console:log('[Details] $volume_names: ' || string-join($volume_names, ', ')) else ()
        let $volumes        := for $f in $volume_names return if (doc-available($config:tei-root || '/works/' || $f || '.xml')) then map:entry($f, doc($config:tei-root || '/works/' || $f || '.xml')) else ()
        let $volumes        := map:merge($volumes)
        (: let $debug := console:log('$volumes: ' || serialize($volumes, map {"method":"json", "media-type":"application/json"})) :)

        let $volumes_list := for $key in map:keys($volumes) order by $key
                                let $filtered_array := array:filter($iiif?members, function($m) {contains(map:get($m, '@id'), $key) })
                                let $vol_thumbnail  := if (array:size($filtered_array) gt 0) then
                                                          $filtered_array(1)?thumbnail
                                                       else
                                                          let $debug := console:log("[Details] No iiif information for " || $wid || "/" || $key || " found.")
                                                          return ()
                                (: let $debug := console:log('$vol_thumbnail: ' || serialize($vol_thumbnail, map {"method":"json", "media-type":"application/json"})) :)
                                (: let $debug := console:log('$iiif-vol?thumbnail?@id: ' || serialize(map:get($vol_thumbnail, '@id'), map {"method":"json", "media-type":"application/json"})) :)
                                let $teiHeader := map:get($volumes, $key)//tei:teiHeader
                                let $isFirstEd := not($teiHeader//tei:sourceDesc//tei:imprint/(tei:date[@type eq "thisEd"] | tei:pubPlace[@role eq "thisEd"] | tei:publisher[@n eq "thisEd"]))
                                return map {
                                    "key" :                     $key,
                                    "id" :                      tokenize($key, '_')[1] || ':vol' || map:get($volumes, $key)//tei:text/@n/string(),
                                    "uri" :                     $config:idserver || '/texts/' ||
                                                                    $teiHeader//tei:notesStmt/tei:relatedItem[@type eq 'work_multivolume']/@target/tokenize(., ':')[2] ||
                                                                    ':vol' || map:get($volumes, $key)//tei:text/@n/string(),
                                    "series_num" :              $teiHeader//tei:seriesStmt/tei:biblScope[@unit eq 'volume']/@n/string(),
                                    "parent_work" :             $teiHeader//tei:notesStmt/tei:relatedItem[@type eq 'work_multivolume']/@target/tokenize(., ':')[2],
                                    "num" :                     map:get($volumes, $key)//tei:text/@n/string(),
                                    "author_short" :            string-join($teiHeader//tei:titleStmt/tei:author/tei:persName/tei:surname, '/'),
                                    "author_full" :             admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:author/tei:persName/string(), '/')),
                                    "title_short" :             $teiHeader//tei:titleStmt/tei:title[@type eq 'short']/string(),
                                    "title_full" :              admin:StripLBs($teiHeader//tei:titleStmt/tei:title[@type eq 'main']/string()),
                                    "place" :                   if (not($isFirstEd)) then
                                                                    string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:pubPlace[@role eq "thisEd"] return $p/string(), ', ')
                                                                else
                                                                    string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:pubPlace return $p/string(), ', '),
                                    "printer_short" :           if (not($isFirstEd)) then
                                                                    string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher[@n eq "thisEd"] return ($p//tei:surname)[1]/string(), ', ')
                                                                else
                                                                    string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher return ($p//tei:surname)[1]/string(), ', '),
                                    "printer_full" :            if (not($isFirstEd)) then
                                                                    admin:StripLBs(string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher[@n eq "thisEd"] return $p//string(), ', '))
                                                                else
                                                                    admin:StripLBs(string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher return $p//string(), ', ')),
                                    "year" :                    if (not($isFirstEd)) then
                                                                    $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'thisEd']/@when/string()
                                                                else
                                                                    $teiHeader//tei:sourceDesc//tei:imprint/tei:date/@when/string(),
                                    "src_publication_period" :  $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'summaryFirstEd']/string(),
                                    "language" :                string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n eq 'main']/string(), ', ') ||
                                                (if ($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']) then
                                                    ' (' || string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']/string(), ', ') || ')'
                                                else ()),
                                    "thumbnail" :               if (array:size($filtered_array) gt 0) then map:get($vol_thumbnail, '@id') else (),
                                    "schol_ed" :                admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#scholarly')]/string(), ' / ')),
                                    "tech_ed" :                 admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#technical')]/string(), ' / ')),
                                    "el_publication_date" :     $teiHeader//tei:editionStmt//tei:date[@type eq 'digitizedEd']/@when/string()[1],
                                    "hold_library" :            $teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/string(),
                                    "hold_idno" :               $teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno/string(),
                                    "status" :                  $teiHeader/tei:revisionDesc/@status/string()
                                }

        let $vol_strings    := for $v in $volumes_list return '$' || string(map:get($v, 'key')) || ' := dict ' ||
                                        string-join(for $k in map:keys($v) return '"' || $k || '" "' || string(map:get($v, $k)) || '"', ' ')

        let $isFirstEd      := not($teiHeader//tei:sourceDesc//tei:imprint/(tei:date[@type eq "thisEd"] | tei:pubPlace[@role eq "thisEd"] | tei:publisher[@n eq "thisEd"]))
        let $work_info      := map {
            "id" :                      $public_id,
            "uri" :                     $config:idserver || '/texts/' || $public_id,
            "series_num" :              $teiHeader//tei:seriesStmt/tei:biblScope[@unit eq 'volume']/@n/string(),
            "author_short" :            string-join($teiHeader//tei:titleStmt/tei:author/tei:persName/tei:surname, '/'),
            "author_full" :             admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:author/tei:persName/string(), '/')),
            "title_short" :             $teiHeader//tei:titleStmt/tei:title[@type eq 'short']/string(),
            "title_full" :              admin:StripLBs($teiHeader//tei:titleStmt/tei:title[@type eq 'main']/string()),
            "place" :                   if (not($isFirstEd)) then
                                            string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:pubPlace[@role eq "thisEd"] return $p/string(), ', ')
                                        else
                                            string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:pubPlace return $p/string(), ', '),
            "printer_short" :           if (not($isFirstEd)) then
                                            string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher[@n eq "thisEd"] return string-join($p//tei:surname, ' &amp; '), ', ')
                                        else
                                            string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher return string-join($p//tei:surname, ' &amp; '), ', '),
            "printer_full" :            if (not($isFirstEd)) then
                                            admin:StripLBs(string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher[@n eq "thisEd"] return string-join($p, ' &amp; '), ', '))
                                        else
                                            admin:StripLBs(string-join(for $p in $teiHeader//tei:sourceDesc//tei:imprint/tei:publisher return string-join($p, ' &amp; '), ', ')),
            "year" :                    if (not($isFirstEd)) then
                                            $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'thisEd']/@when/string()
                                        else
                                            $teiHeader//tei:sourceDesc//tei:imprint/tei:date[not(@type = 'summaryFirstEd')]/@when/string(),
            "src_publication_period" :  $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'summaryFirstEd']/string(),
            "language" :                string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n eq 'main']/string(), ', ') ||
                                            (if ($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']) then
                                                ' (' || string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']/string(), ', ') || ')'
                                            else ()),
            "thumbnail" :               if ("thumbnail" = map:keys($iiif)) then
                                            map:get($iiif?thumbnail, '@id')
                                        else if ("members" = map:keys($iiif) and "thumbnail" = map:keys($iiif?members(1))) then
                                            map:get($iiif?members(1)?thumbnail, '@id')
                                        else (),
            "schol_ed" :                admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#scholarly')]/string(), ' / ')),
            "tech_ed" :                 admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#technical')]/string(), ' / ')),
            "el_publication_date" :     $teiHeader//tei:editionStmt//tei:date[@type eq 'digitizedEd']/@when/string()[1],
            "hold_library" :            $teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/string(),
            "hold_idno" :               $teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno/string(),
            "status" :                  $teiHeader/tei:revisionDesc/@status/string(),
            "number_of_volumes" :       count(map:keys($volumes)),
            "volumes":                  $volumes_list
        }

        let $debug := if ($config:debug = "trace") then console:log($work_info) else ()

        let $vol_keys := for $v in $volumes_list return concat('$', map:get($v, 'key')) 
        let $volumes_string := '{{ $Volumes := dict "number" ' || xs:string(map:get($work_info, 'number_of_volumes')) ||
                                                    ' "volumes" (list ' || string-join($vol_keys, ' ') || ') }}'
        let $work_string := '{{ $work_info := dict ' ||
                                string-join(for $key in map:keys($work_info) return
                                                if ($key ne 'volumes') then
                                                    '"' || $key || '" "' || string-join(map:get($work_info, $key), " ") || '"'
                                                else (), ' ') ||
                            (if (count(map:keys($volumes))>0) then ' "volumes" $Volumes' else ()) ||
                            ' }}'
        let $include_string := '{{ include "../../../resources/templates/template_details.html" $work_info }}'

        let $work_result := concat(if (count($vol_strings) > 0) then '{{ ' || string-join($vol_strings, ' }}&#10;{{ ') || ' }}&#10;' || $volumes_string || '&#10;&#10;' else (), $work_string, '&#10;&#10;', $include_string, '&#10;')

        let $save   := admin:saveTextFile($id, $id || '_details.html', $work_result, 'details')
        let $export := admin:exportBinaryFile($id, $id || '_details.html', $work_result, 'details')

        let $debug := if ($config:debug = ("info", "trace")) then console:log("[Details] Going into recursion for volume details...") else ()
        let $recursion := for $v in map:keys($volumes)
                            let $debug := console:log("[Details] Rendering details for volume " || $v || "...")
                            return admin:createDetails($v)
        return ($id, $save, $export)
    let $debug := if ($config:debug = "bla") then console:log("[ADMIN] Done rendering Details.")
                  else if ($config:debug = ("info", "trace")) then console:log("[ADMIN] Done rendering Details. (Saved/exported to " || string-join(for $v in $process_loop return string-join($v, ','), '; ') || ").")
                  else ()
    return $process_loop
};

(: 
~ Creates and stores statistics.
:)
declare function admin:createStats() {
    let $log  := if ($config:debug = ('info', 'trace')) then util:log('info', '[ADMIN] Starting to extract stats...') else ()
    let $debug := console:log('[ADMIN] Starting to extract stats...')
    let $start-time := util:system-time()
    let $params := 
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="json"/>
        </output:serialization-parameters>
    (: corpus stats :)
    let $corpusStats := stats:makeCorpusStats()
    let $save        := admin:saveFile('dummy', 'corpus-stats.json', serialize($corpusStats, $params), 'stats')
    let $export      := admin:exportJSONFile('corpus-stats.json', $corpusStats, 'stats')
    let $debug := console:log('[ADMIN] Done creating corpus stats. Saved and exported to ' || $save || ' and ' || $export || '.')
    let $log := if ($config:debug = ('info', 'trace')) then util:log('info', '[ADMIN] Done creating corpus stats. Saved and exported to ' || $save || ' and ' || $export || '.') else ()

    (: single work stats:)
    let $debug := console:log('[ADMIN] Creating with single work stats...')
    let $processSingleWorks :=
        for $wid in sutil:getPublishedWorkIds() order by $wid return
            let $log := if ($config:debug = 'trace') then util:log('info', '[ADMIN] Creating single work stats for ' || $wid || '...') else ()
            let $workStats := stats:makeWorkStats($wid)
            let $saveSingle   := admin:saveFile('dummy', $wid || '-stats.json', serialize($workStats, $params), 'stats')
            let $exportSingle := admin:exportJSONFile($wid, $wid || '-stats.json', $workStats, 'stats')
            let $log := if ($config:debug = 'trace') then util:log('info', '[ADMIN] Done creating single work stats for ' || $wid || '. Saved and exported to ' || $saveSingle || ' and ' || $exportSingle || '.') else ()
            return $workStats
    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    let $runtimeString :=
        if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
        else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
    let $log  := util:log('info', '[ADMIN] Extracted corpus and works stats in ' || $runtimeString || '.')
    let $debug := console:log('Extracted corpus and works stats in ' || $runtimeString || '.')
    return $corpusStats
};
