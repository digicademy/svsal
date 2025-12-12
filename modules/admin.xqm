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
declare namespace zip               = "http://expath.org/ns/zip";

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
import module namespace nlp         = "https://www.salamanca.school/factory/works/nlp"    at "xmldb:exist:///db/apps/salamanca/modules/factory/works/nlp.xqm";

declare option exist:timeout "166400000"; (: in miliseconds, 25.000.000 ~ 7h, 43.000.000 ~ 12h :)
declare option exist:output-size-limit "5000000"; (: max number of nodes in memory :)

(:
~ TODO: 
~    - HTML rendering and creation of snippets is currently not working for authors and lemmata, although 
~      the "ancient" infrastructure is still there (see render-the-rest.html and admin:renderAuthorLemma(), etc.).
~      Ideally, this infrastructure would be refactored in the way the creation of work data works: the webdata-admin.xql
~      forwards requests for the creation of data to the admin.xqm module, which then lets dedicated modules in factory/authors/* 
~      create the data.
:)

declare
    %templates:wrap
function admin:loadListOfWorks($node as node(), $model as map(*)) as map(*) {
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

declare function admin:workCount($node as node(), $model as map (*)) {
    count($model("listOfWorks"))
};

declare
    %templates:wrap
function admin:loadListOfLemmata($node as node(), $model as map(*)) as map(*) {
    let $coll := (collection($config:tei-lemmata-root)//tei:TEI[.//tei:text/@type = "lemma_article"]/tei:teiHeader)
    let $result := 
        for $item in $coll
            let $lid := $item/parent::tei:TEI/@xml:id/string()
            let $author := string-join($item//tei:titleStmt/tei:author//tei:surname, '/')
            let $titleShort := $item//tei:titleStmt/tei:title[@type = 'short']/string()
            order by $lid ascending
            return 
                map {'lid': $lid,
                     'author': $author,
                     'titleShort': $titleShort}
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] loaded " || count($result) || " lemmata.") else ()
    return map { 'listOfLemmata': $result }     
};

declare function admin:lemmataCount($node as node(), $model as map (*)) {
    count($model("listOfLemmata"))
};

declare
    %templates:wrap
function admin:loadListOfWorkingpapers($node as node(), $model as map(*)) as map(*) {
    let $coll := (collection($config:tei-workingpapers-root)//tei:TEI[.//tei:text/@type = "working_paper"]/tei:teiHeader)
    let $result := 
        for $item in $coll
            let $wpid := $item/parent::tei:TEI/@xml:id/string()
            let $author := string-join($item//tei:titleStmt/tei:author//tei:surname, '/')
            let $titleShort := $item//tei:titleStmt/tei:title[@type = 'short']/string()
            order by $wpid ascending
            return 
                map {'wpid': $wpid,
                     'author': $author,
                     'titleShort': $titleShort}
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] loaded " || count($result) || " working papers.") else ()
    return map { 'listOfWorkingpapers': $result }     
};

declare function admin:WPsCount($node as node(), $model as map (*)) {
    count($model("listOfWorkingpapers"))
};


(: #### UTIL FUNCTIONS for listing resources as links to their actual webpage :)


declare function admin:workString($node as node(), $model as map(*)) {
    let $currentWorkId  := $model('currentWork')?('wid')
    let $author := <span>{$model('currentWork')?('author')}</span>
    let $titleShort := $model('currentWork')?('titleShort')
    return 
        <td>
            <a href="{$config:idserver}/texts/{$currentWorkId}">{$currentWorkId}: {$author} - {$titleShort}</a>
            <br/>
            <a style="font-weight:bold;" href="webdata-admin.xql?rid={$currentWorkId}&amp;format=all">Create EVERYTHING except IIIF and RDF (safest option)</a>
        </td>
};

declare function admin:lemmaString($node as node(), $model as map(*)) {
    let $currentLemmaId  := $model('currentLemma')?('lid')
    let $author := <span>{$model('currentLemma')?('author')}</span>
    let $titleShort := $model('currentLemma')?('titleShort')
    return <td><a href="lemma.html?lid={$currentLemmaId}">{$currentLemmaId}: {$author} - {$titleShort}</a></td>
};

declare function admin:WPString($node as node(), $model as map(*)) {
    let $currentWPId  := $model('currentWP')?('wpid')
    let $author := <span>{$model('currentWP')?('author')}</span>
    let $titleShort := $model('currentWP')?('titleShort')
    return <td><a href="workingpaper.html?wpid={$currentWPId}">{$currentWPId}: {$author} - {$titleShort}</a></td>
};


(: #### UTIL FUNCTIONS for informing the admin about current status of a webdata resources (node index, HTML, snippets, etc.)
         The 'needs...String()' functions generate html that can be displayed on the admin page, usually with an html anchor triggering the generating function;
         the 'needs...' functions without '...String' at the end are boolean functions called by the '...String' ones that indicate whether the respective data for the resource needs to be created/updated 
:)


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
    let $currentWorkId := max(($model('currentWork')?('wid'), $model('currentLemma')?('lid')))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentWorkId, '.xml'))) then $subcollection
                                    else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForIndexing := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentWorkId, '.xml'))//tei:TEI[@xml:id eq $currentWorkId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForIndexing := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentWorkId, '.xml'))/id($currentWorkId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                            true()
                         else false()
    return 
        if (not($readyForIndexing)) then
            <td>Not ready yet</td>
        else if (admin:needsIndex($currentWorkId)) then
            <td title="{if (xmldb:get-child-resources($config:index-root) = $currentWorkId || "_nodeIndex.xml") then concat('Index created on: ', xmldb:last-modified($config:index-root, $currentWorkId || "_nodeIndex.xml"), ", ") else ()}source from: {string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=index"><b>Create Node Index NOW!</b></a></td>
        else
            <td title="Index created on: {xmldb:last-modified($config:index-root, $currentWorkId || "_nodeIndex.xml")}, source from: {string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml'))}">Node indexing unnecessary. <small><a href="webdata-admin.xql?rid={$currentWorkId}&amp;format=index">Create Node Index anyway!</a></small></td>
};

declare function admin:needsCrumbtrail($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
                                    else ()
    let $workModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
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

declare function admin:needsCrumbtrailString($node as node(), $model as map(*)) {
    let $currentWorkId := max(($model('currentWork')?('wid'), $model('currentLemma')?('lid')))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentWorkId, '.xml'))) then $subcollection
                                    else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForCrumbtrail := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentWorkId, '.xml'))//tei:TEI[@xml:id eq $currentWorkId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForCrumbtrail := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentWorkId, '.xml'))/id($currentWorkId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                            true()
                         else false()
    return
        if (not($readyForCrumbtrail)) then
            <td>Not ready yet</td>
        else if (admin:needsCrumbtrail($currentWorkId)) then 
            <td
                title="Source from: {string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml'))}{
                        if (xmldb:get-child-resources($config:crumb-root) = $currentWorkId || "_crumbtrails.xml") then
                            concat(', rendered on: ', xmldb:last-modified($config:crumb-root, $currentWorkId || "_crumbtrails.xml"))
                        else
                            ()
                  }"><a
                    href="webdata-admin.xql?rid={$currentWorkId}&amp;format=crumbtrails"><b>Create Crumbtrails NOW!</b></a></td>
            
        else
            <td
                title="Source from: {string(xmldb:last-modified($targetSubcollection, $currentWorkId || '.xml'))}, rendered on: {xmldb:last-modified($config:crumb-root, $currentWorkId || "_crumbtrails.xml")}">Creating Crumbtrails unnecessary. <small><a  href="webdata-admin.xql?rid={$currentWorkId}&amp;format=crumbtrails">Create it anyway!</a></small></td>
};

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

declare function admin:needsPdfString($node as node(), $model as map(*)) {
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentLemma')?('lid')), string($model('currentWP')?('wpid'))))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForPDF := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))//tei:TEI[@xml:id eq $currentResourceId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForPDF := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))/id($currentResourceId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                                true()
                             else false()

    let $currentDoc := doc($targetSubcollection || "/" || $currentResourceId ||".xml")
    let $isMultiWorkVolume as node() := $currentDoc//tei:TEI//tei:text
    let $target_1 := $currentDoc//tei:relatedItem/@target
    let $target_2 := for $target in $target_1 return substring-after($target, "work:") 

    return 
          if (not($readyForPDF)) then
            <td>Not ready yet</td>
          else if ($isMultiWorkVolume/@type="work_multivolume") then
            <td> 
                {for $target in $target_2 
                  return
                    if (admin:needsPdf($target)) then 
                        <a title="Source from: {string(xmldb:last-modified($targetSubcollection, $target || '.xml'))}{if (xmldb:get-child-resources($config:pdf-root) = $target || ".pdf") then concat(', rendered on: ', xmldb:last-modified($config:pdf-root, $target || ".pdf")) else ()}"><b> Create PDF for <a href="webdata-admin.xql?rid={$target}&amp;format=pdf_create">{$target}!</a><br/></b></a>
                    else if(not(admin:needsPdf($target))) then
                        <i title="Source from: {string(xmldb:last-modified($targetSubcollection, $target || '.xml'))}, rendered on: {xmldb:last-modified($config:pdf-root, $target || ".pdf")}">PDF for {$target} created.<small><a href="webdata-admin.xql?rid={$target}&amp;format=pdf_create">Create PDF anyway!</a></small> <br/> </i>
                    else ()
                }
            </td>
          else
            if (admin:needsPdf($currentResourceId)) then
                <td title="Source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}{if (xmldb:get-child-resources($config:pdf-root) = $currentResourceId || ".pdf") then concat(', rendered on: ', xmldb:last-modified($config:pdf-root, $currentResourceId || ".pdf")) else ()}">
                    <a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=pdf_create"><b>Create PDF NOW!</b></a>
                    <br/> or
                    <br/>
                    <form enctype="multipart/form-data" method="post" action="webdata-admin.xql?rid={$currentResourceId}&amp;format=pdf_upload">
                      <p>Upload PDF File</p>
                      <input type="file"  name="FileUpload"/>
                      <input type="submit">Submit your PDF</input>
                    </form>
                    <br/>
                </td>
            else 
                <td title="Source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}, rendered on: {xmldb:last-modified($config:pdf-root, $currentResourceId || ".pdf")}">
                    The PDF was already uploaded or created.
                    <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=pdf_create">Create PDF anyway!</a></small>
                </td>
};

declare function admin:authorMakeHTML($node as node(), $model as map(*)) {
    let $currentAuthorId := $model('currentAuthor')/@xml:id/string()
    return 
        if (admin:needsHTML($currentAuthorId)) then
            <td title="source from: {string(xmldb:last-modified($config:tei-authors-root, $currentAuthorId || '.xml'))}{if (xmldb:collection-available($config:temp) and xmldb:get-child-resources($config:temp) = $currentAuthorId || ".html") then concat(', rendered on: ', xmldb:last-modified($config:temp, $currentAuthorId || ".html")) else ()}"><a href="render-the-rest.html?aid={$currentAuthorId}"><b>Render NOW!</b></a></td>
        else
            <td title="source from: {string(xmldb:last-modified($config:tei-authors-root, $currentAuthorId || '.xml'))}, Rendered on: {xmldb:last-modified($config:temp, $currentAuthorId || '.html')}">Rendering unnecessary. <small><a href="render-the-rest.html?aid={$currentAuthorId}">Render anyway!</a></small></td>
};

declare function admin:lemmaMakeHTML($node as node(), $model as map(*)) {
    let $currentLemmaId := string($model('currentLemma')/@xml:id)
    return 
        if (admin:needsHTML($currentLemmaId)) then
            <td title="source from: {string(xmldb:last-modified($config:tei-lemmata-root, $currentLemmaId || '.xml'))}{if (xmldb:collection-available($config:temp) and xmldb:get-child-resources($config:temp) = $currentLemmaId || ".html") then concat(', rendered on: ', xmldb:last-modified($config:temp, $currentLemmaId || ".html")) else ()}"><a href="render-the-rest.html?lid={$currentLemmaId}"><b>Render NOW!</b></a></td>
        else
            <td title="source from: {string(xmldb:last-modified($config:tei-lemmata-root, $currentLemmaId || '.xml'))}, Rendered on: {xmldb:last-modified($config:temp, $currentLemmaId || ".html")}">Rendering unnecessary. <small><a href="render-the-rest.html?lid={$currentLemmaId}">Render anyway!</a></small></td>
};
           
declare function admin:needsHTML($targetResourceId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetResourceId, '.xml'))) then $subcollection
            else ()
    let $xmlModTime := xmldb:last-modified($targetSubcollection, $targetResourceId || '.xml')
    return
        if (substring($targetResourceId,1,2) eq "W0") then
            if ($targetResourceId || "_nodeIndex.xml" = xmldb:get-child-resources($config:index-root)
                and xmldb:collection-available($config:html-root || '/' || $targetResourceId)
                and count(xmldb:get-child-resources($config:html-root || '/' || $targetResourceId)) gt 0
               ) then
                let $indexModTime := xmldb:last-modified($config:index-root, $targetResourceId || "_nodeIndex.xml")
                let $htmlModTime := xmldb:last-modified($config:html-root || '/' || $targetResourceId, xmldb:get-child-resources($config:html-root || '/' || $targetResourceId)[1])
                return if ($htmlModTime lt $xmlModTime or $htmlModTime lt $indexModTime) then true() else false()
            else
                true()
        else if (substring($targetResourceId,1,2) = ("A0", "L0", "WP")) then
            (: TODO: in the future, this should point to the directory where author/lemma/... HTML will be stored... :)
            if (not(xmldb:collection-available($config:html-root || '/' || $targetResourceId))) then
                true()
            else if (xmldb:collection-available($config:html-root || '/' || $targetResourceId)
                      and "00001_completeWork.html" = xmldb:get-child-resources($config:html-root || '/' || $targetResourceId)
                     ) then
                let $htmlModTime := xmldb:last-modified($config:html-root || '/' || $targetResourceId, "00001_completeWork.html")
                return if ($htmlModTime lt $xmlModTime) then true() else false()
            else true()
        else true()
};

declare function admin:needsHTMLString($node as node(), $model as map(*)) {
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentLemma')?('lid')), string($model('currentWP')?('wpid'))))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForHtml := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))//tei:TEI[@xml:id eq $currentResourceId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForHtml := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))/id($currentResourceId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                            true()
                         else false()
    return
        if (not($readyForHtml)) then
            <td>Not ready yet</td>
        else if (admin:needsHTML($currentResourceId)) then
            <td title="{if (xmldb:collection-available($config:html-root || "/" || $currentResourceId) and count(xmldb:get-child-resources($config:html-root || '/' || $currentResourceId)) gt 0) then
 concat('HTML created on: ', string(xmldb:last-modified($config:html-root || '/' || $currentResourceId, xmldb:get-child-resources($config:html-root || '/' || $currentResourceId)[1])), ', ')
 else ()}
                        {if (doc-available($config:index-root || '/' || $currentResourceId || '_nodeIndex.xml')) then
                            concat('index created on: ', string(xmldb:last-modified($config:index-root, $currentResourceId || "_nodeIndex.xml")), ', ')
                        else ()}
source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=html"><b>Render HTML (&amp; TXT) NOW!</b></a></td>
        else
            <td title="HTML created on {string(xmldb:last-modified($config:html-root || '/' || $currentResourceId, xmldb:get-child-resources($config:html-root || '/' || $currentResourceId)[1]))},
                       index created on {string(xmldb:last-modified($config:index-root, $currentResourceId || "_nodeIndex.xml"))},
                       source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}">Rendering unnecessary. <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=html">Render HTML (&amp; TXT) anyway!</a></small></td>
};

declare function admin:needsDetails($targetResourceId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetResourceId, '.xml'))) then $subcollection
            else ()
    let $xmlModTime := xmldb:last-modified($targetSubcollection, $targetResourceId || '.xml')
    return
        if (substring($targetResourceId,1,2) eq "W0") then
            if (xmldb:collection-available($config:html-root || '/' || $targetResourceId) and
                $targetResourceId || "_details.html" = xmldb:get-child-resources($config:html-root || '/' || $targetResourceId)
               ) then
                let $indexModTime := xmldb:last-modified($config:index-root, $targetResourceId || "_nodeIndex.xml")
                let $htmlModTime := xmldb:last-modified($config:html-root || '/' || $targetResourceId, $targetResourceId || "_details.html")
                return if ($htmlModTime lt $xmlModTime or $htmlModTime lt $indexModTime) then true() else false()
            else
                true()
        else if (substring($targetResourceId,1,2) = ("A0", "L0", "WP")) then
            (: TODO: in the future, this should point to the directory where author/lemma/... HTML will be stored... :)
            if (not(xmldb:collection-available($config:html-root || '/' || $targetResourceId))) then
                true()
            else if (xmldb:collection-available($config:html-root || '/' || $targetResourceId) and
                      $targetResourceId || "_details.html" = xmldb:get-child-resources($config:html-root || '/' || $targetResourceId)
                     ) then
                let $htmlModTime := xmldb:last-modified($config:html-root || '/' || $targetResourceId, $targetResourceId || "_details.html")
                return if ($htmlModTime lt $xmlModTime) then true() else false()
            else true()
        else true()
};

declare function admin:needsDetailsString($node as node(), $model as map(*)) {
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentLemma')?('lid')), string($model('currentWP')?('wpid'))))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()
    let $detailFileCollection  := concat($config:html-root,  '/', $currentResourceId)
    let $detailFilePath        := concat($detailFileCollection, '/', $currentResourceId, '_details.html')
    return
        if (admin:needsDetails($currentResourceId)) then
            <td title="{if (xmldb:collection-available($detailFileCollection) and doc-available($detailFilePath)) then concat('Details created on: ', string(xmldb:last-modified($detailFileCollection, $currentResourceId || '_details.html')), ", ") else ()}source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=details"><b>Render Details NOW!</b></a></td>
        else
            <td title="HTML created on {string(xmldb:last-modified($detailFileCollection, $currentResourceId || '_details.html'))}, source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}">Rendering unnecessary. <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=details">Render Details anyway!</a></small></td>
};

declare function admin:needsSnippets($targetResourceId as xs:string) as xs:boolean {
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $targetResourceId, '.xml'))) then $subcollection
                                    else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetResourceId || '.xml')
(:    let $newestSnippet := max(for $file in xmldb:get-child-resources($config:snippets-root || '/' || $targetWorkId) return xmldb:last-modified($config:snippets-root || '/' || $targetWorkId, $file)):)

    return if (xmldb:collection-available($config:snippets-root || '/' || $targetResourceId)
                and count(xmldb:get-child-resources($config:snippets-root || '/' || $targetResourceId)) gt 0
               ) then
                let $snippetsModTime := xmldb:last-modified($config:snippets-root || '/' || $targetResourceId, xmldb:get-child-resources($config:snippets-root || '/' || $targetResourceId)[1])
                return 
                    if (starts-with(upper-case($targetResourceId), 'W0')) then
                        let $indexModTime := xmldb:last-modified($config:index-root, $targetResourceId || "_nodeIndex.xml")
                        return 
                            if ($snippetsModTime lt $targetWorkModTime or $snippetsModTime lt $indexModTime) then true() else false()
                    else if ($snippetsModTime lt $targetWorkModTime) then true() 
                    else false()
        else
            true()
};

declare function admin:needsSnippetsString($node as node(), $model as map(*)) {
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentLemma')?('lid')), string($model('currentWP')?('wpid'))))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForSnippets := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))//tei:TEI[@xml:id eq $currentResourceId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForSnippets := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))/id($currentResourceId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                                true()
                             else false()

    return
            if (not($readyForSnippets)) then
                <td>Not ready yet</td>
            else if (admin:needsSnippets($currentResourceId)) then
                <td title="{concat(if (xmldb:collection-available($config:snippets-root || '/' || $currentResourceId) and count(xmldb:get-child-resources($config:snippets-root || '/' || $currentResourceId)) gt 0) then concat('Snippets created on: ', xmldb:last-modified($config:snippets-root || '/' || $currentResourceId, xmldb:get-child-resources($config:snippets-root || '/' || $currentResourceId)[1]), ', ') else (), 'Source from: ', string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml')), '.')}"><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=snippets"><b>Create snippets NOW!</b></a></td>
            else
                <td title="{concat('Snippets created on: ', xmldb:last-modified($config:snippets-root || '/' || $currentResourceId, xmldb:get-child-resources($config:snippets-root || '/' || $currentResourceId)[1]), ', Source from: ', string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml')), '.')}">Creating snippets unnecessary. <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=snippets">Create snippets anyway!</a></small></td>
};

declare function admin:needsNLP($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
            else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    let $subcollection := $config:nlp-root
    return    
        if (util:binary-doc-available($subcollection || '/' || $targetWorkId || '.csv')) then
            let $csvModTime := xmldb:last-modified($subcollection, $targetWorkId || '.csv')
            return 
                if (starts-with(upper-case($targetWorkId), 'W0')) then
                    let $indexModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
                    return 
                        if ($csvModTime lt $targetWorkModTime or $csvModTime lt $indexModTime) then true() else false()
                else if ($csvModTime lt $targetWorkModTime) then true() 
                else false()
        else true()
};

declare function admin:needsNLPString ($node as node(), $model as map(*)) {
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentLemma')?('lid')), string($model('currentWP')?('wpid'))))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForNLP := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))//tei:TEI[@xml:id eq $currentResourceId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForNLP := if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))/id($currentResourceId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                            true()
                        else false()
    return
        if (not($readyForNLP)) then
            <td>Not ready yet</td>
        else if (admin:needsNLP($currentResourceId)) then
            <td title="{if (util:binary-doc-available($config:nlp-root || "/" || $currentResourceId || '.csv')) then
                            concat('NLP CSV created on: ', string(xmldb:last-modified($config:nlp-root, $config:nlp-root || "/" || $currentResourceId || '.csv')), ', ')
                        else ()}
                        {if (doc-available($config:index-root || '/' || $currentResourceId || '_nodeIndex.xml')) then
                            concat('index created on: ', string(xmldb:last-modified($config:index-root, $currentResourceId || "_nodeIndex.xml")), ', ')
                        else ()}
                        source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=nlp"><b>Render NLP (CSV) NOW!</b></a></td>
        else
            <td title="NLP created on {string(xmldb:last-modified($config:nlp-root, $currentResourceId || ".csv"))},
                       index created on {string(xmldb:last-modified($config:index-root, $currentResourceId || "_nodeIndex.xml"))},
                       source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}">Rendering unnecessary. <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=nlp">Render NLP (CSV) anyway!</a></small></td>
};

declare function admin:needsStats($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
            else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    let $subcollection := $config:nlp-root
    return    
        if (util:binary-doc-available($subcollection || '/' || $targetWorkId || '.json')) then
            let $jsonModTime := xmldb:last-modified($subcollection, $targetWorkId || '.json')
            return 
                if (starts-with(upper-case($targetWorkId), 'W0')) then
                    let $indexModTime := xmldb:last-modified($config:index-root, $targetWorkId || "_nodeIndex.xml")
                    return 
                        if ($jsonModTime lt $targetWorkModTime or $jsonModTime lt $indexModTime) then true() else false()
                else if ($jsonModTime lt $targetWorkModTime) then true() 
                else false()
        else true()
};

declare function admin:needsStatsString ($node as node(), $model as map(*)) {
    <td>
        &amp;nbsp;
    </td>
};

declare function admin:needsRoutingResource($targetResourceId as xs:string) as xs:boolean {
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $targetResourceId, '.xml'))) then $subcollection
                                    else ()
    let $targetWorkModTime := xmldb:last-modified($targetSubcollection, $targetResourceId || '.xml')
    return if (util:binary-doc-available($config:routes-root || '/' || $targetResourceId || '_routes.json')) then
                let $resourceModTime := xmldb:last-modified($config:routes-root, $targetResourceId || '_routes.json')
                return if ($resourceModTime lt $targetWorkModTime) then true() else false()
        else
            true()
};

declare function admin:needsRoutingString($node as node(), $model as map(*)) {
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentLemma')?('lid')), string($model('currentWP')?('wpid'))))
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()
    return if (admin:needsRoutingResource($currentResourceId)) then
                <td title="source from: {string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml'))}"><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=routing"><b>Create Routing table NOW!</b></a></td>
           else
                <td title="{concat('Routing resource created on: ', string(xmldb:last-modified($config:routes-root, $currentResourceId || '_routes.json')), ', Source from: ', string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml')), '.')}">Creating Routing resource unnecessary. <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=routing">Create Routing resource anyway!</a></small></td>
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
    let $currentResourceId := max((string($model('currentWork')?('wid')), string($model('currentAuthor')/@xml:id), string($model('currentLemma')/@xml:id), string($model('currentWp')/@xml:id)))
    let $targetSubcollection := 
        for $subcollection in $config:tei-sub-roots return 
            if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
            else ()
    let $rdfSubcollection := 
        if (starts-with(upper-case($currentResourceId), 'W')) then $config:rdf-works-root
        else if (starts-with(upper-case($currentResourceId), 'A')) then $config:rdf-authors-root
        else if (starts-with(upper-case($currentResourceId), 'L')) then $config:rdf-lemmata-root
        else ()
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $readyForRDF :=  if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))//tei:TEI[@xml:id eq $currentResourceId]/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then:)
    let $readyForRDF :=  if ($targetSubcollection and doc(concat($targetSubcollection, '/', $currentResourceId, '.xml'))/id($currentResourceId)/tei:teiHeader/tei:revisionDesc/@status = ("f_enriched", "g_enriched_approved", "h_revised", "i_revised_approved")) then
                            true()
                         else false()

    return 
        if (not($readyForRDF)) then
            <td>Not ready yet</td>
        else if (admin:needsRDF($currentResourceId)) then
            <td title="{concat(if (doc-available($rdfSubcollection || '/' || $currentResourceId || '.rdf')) then concat('RDF created on: ', string(xmldb:last-modified($rdfSubcollection, $currentResourceId || '.rdf')), ', ') else (), 'Source from: ', string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml')), '.')}"><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=rdf"><b>Create RDF NOW!</b></a></td>
        else
            <td title="{concat('RDF created on: ', string(xmldb:last-modified($rdfSubcollection, $currentResourceId || '.rdf')), ', Source from: ', string(xmldb:last-modified($targetSubcollection, $currentResourceId || '.xml')), '.')}">Creating RDF unnecessary. <small><a href="webdata-admin.xql?rid={$currentResourceId}&amp;format=rdf">Create RDF anyway!</a></small></td>
};

declare function admin:needsTeiCorpusZipString($node as node(), $model as map(*)) {
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

declare function admin:needsTxtCorpusZipString($node as node(), $model as map(*)) {
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

declare function admin:needsCorpusStatsString($node as node(), $model as map(*)) {
    let $worksModTime := max(for $work in xmldb:get-child-resources($config:tei-works-root) return xmldb:last-modified($config:tei-works-root, $work))    
    let $needsCorpusStats := 
        if (util:binary-doc-available($config:stats-root || '/corpus-stats.json')) then
            let $resourceModTime := xmldb:last-modified($config:stats-root, 'corpus-stats.json')
            return $resourceModTime lt $worksModTime
        else true()
    return 
        if ($needsCorpusStats) then
            <td title="Most current source from: {string($worksModTime)}"><a href="webdata-admin.xql?format=stats"><b>Create corpus stats NOW!</b></a></td>
        else
            <td title="{concat('Stats created on: ', string(xmldb:last-modified($config:stats-root, 'corpus-stats.json')), ', most current source from: ', string($worksModTime), '.')}">Creating corpus stats unnecessary. <small><a href="webdata-admin.xql?format=stats">Create corpus stats anyway!</a></small></td>
};


(: #### DATABASE UTIL FUNCTIONS #### :)

declare function admin:cleanCollection ($wid as xs:string, $collection as xs:string) {
    let $collectionName := 
        if ($collection eq "html")             then $config:html-root || "/" || $wid
        else if ($collection eq "details")     then $config:html-root || "/" || $wid
        else if ($collection eq "snippets")    then $config:snippets-root || "/" || $wid
        else if ($collection eq "txt")         then $config:txt-root || "/" || $wid
        else if ($collection eq "iiif")        then $config:iiif-root
        else if ($collection eq "workslist")   then $config:data-root
        else if ($collection eq "lemmalist")   then $config:data-root
        else if ($collection eq "index")       then $config:index-root
        else if ($collection eq "crumbtrails") then $config:crumb-root
        else if ($collection eq "rdf")         then $config:rdf-works-root
        else if ($collection eq "nlp")         then $config:nlp-root
        else if ($collection eq "routing")     then $config:routes-root
        else if ($collection eq "stats")       then $config:stats-root
        else if ($collection eq "data")        then $config:data-root
        else                                        $config:data-root || "/trash/"
    let $pattern :=
             if ($collection eq "html")        then "\.html$"
        else if ($collection eq "details")     then $wid || ".*_details\.html$"
        else if ($collection eq "snippets")    then "\.snippet\.xml$"
        else if ($collection eq "index")       then $wid || "_nodeIndex\.xml"
        else if ($collection eq "text")        then ".txt"
        else if ($collection eq "crumbtrails") then $wid || "_crumbtrails\.xml"
        else if ($collection eq "rdf")         then $wid || "\.rdf"
        else if ($collection eq "nlp")         then $wid || "\.csv"
        else if ($collection eq "iiif")        then $wid || "(_Vol[0-9]+)?(_iiif_.*)?.json"
        else if ($collection eq "stats")       then $wid || "-stats\.json"
        else if ($collection eq "xsl-fo")         then $wid || ".*\.fo"
        else if ($collection eq "pdf")         then $wid || ".*\.pdf"
        else if ($collection eq "routing")     then $wid || "_routes\.json"
        else                                        "dontmatch"
    let $debug := console:log("[Admin] Cleaning " || $collectionName || " collection (db).")
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
        else if (not(xmldb:collection-available($collectionName))) then
            xmldb:create-collection($config:webdata-root, tokenize($collectionName, "/")[last()])
        else ()
    let $chown-collection-status := sm:chown(xs:anyURI($collectionName), 'sal')
    let $chgrp-collection-status := sm:chgrp(xs:anyURI($collectionName), 'svsal')
    let $chmod-collection-status := sm:chmod(xs:anyURI($collectionName), 'rwxrwxr-x')
    let $remove-status := 
        if (count(xmldb:get-child-resources($collectionName))) then
            for $file in xmldb:get-child-resources($collectionName)
            return if (matches(tokenize($file, '/')[last()], $pattern)) then
                let $debug := if ($collection = ("snippets", "html") and not(xs:int(translate(substring(tokenize($file, '/')[last()], 1, 5), 'WLP', '')) mod 250 = 0)) then ()
                              else
                              console:log("[Admin] Remove file: " || $collectionName || "/" || $file || " from database...")
                return xmldb:remove($collectionName, $file)
        else
                true()
        else ()
    return $remove-status
};

declare function admin:cleanDirectory($wid as xs:string, $collection as xs:string) {
    let $fsRoot := $config:export-folder
    let $collectionname := 
             if ($collection eq "html")        then $fsRoot || $wid || "/html/"
        else if ($collection eq "details")     then $fsRoot || $wid || "/html/"
        else if ($collection eq "snippets")    then $fsRoot || $wid || "/snippets/"
        else if ($collection eq "workslist")   then $fsRoot || $wid || "/"
        else if ($collection eq "index")       then $fsRoot || $wid || "/"
        else if ($collection eq "crumbtrails") then $fsRoot || $wid || "/"
        else if ($collection eq "rdf")         then $fsRoot || $wid || "/"
        else if ($collection eq "nlp")         then $fsRoot || $wid || "/"
        else if ($collection eq "routing")     then $fsRoot || $wid || "/"
        else                                        $fsRoot || "trash/"
    let $pattern :=
             if ($collection eq "html")        then "*.html" (: [^_].html  | _toc.html :)
        else if ($collection eq "details")     then $wid || "*_details.html"
        else if ($collection eq "snippets")    then "*.snippet.xml"
        else if ($collection eq "index")       then $wid || "_nodeIndex.xml"
        else if ($collection eq "text")        then $wid || "*.txt"
        else if ($collection eq "crumbtrails") then $wid || "_crumbtrails.xml"
        else if ($collection eq "rdf")         then $wid || ".rdf"
        else if ($collection eq "nlp")         then $wid || ".csv"
        else if ($collection eq "iiif")        then $wid || "*_iiif_*.json" (: $wid || ".json" | $wid || "_Vol*.json" :)
        else if ($collection eq "stats")       then $wid || "-stats.json"
        else if ($collection eq "xsl-fo")         then $wid || "*.xsl-fo.xml"
        else if ($collection eq "pdf")         then $wid || "*.pdf"
        else if ($collection eq "routing")     then $wid || "_routes.json"
        else                                        ""
    let $debug := console:log("[Admin] Cleaning " || $collectionname || " directory (fs).")
    let $create-parent-status :=
        if (not(file:exists($collectionname) and file:is-directory($collectionname))) then
            file:mkdirs($collectionname)
        else true()
    let $remove-status := for $file in file:directory-list($collectionname, $pattern)/file:file
        let $filename  := $collectionname || $file/@name/string() 
        let $debug :=  if ($collection = ("snippets", "html") and not(xs:int(translate(substring($file/@name, 1, 5), 'WLP', '')) mod 250 = 0)) then ()
                       else
                           console:log("[Admin] Remove file: " || $filename || " from filesystem...")
        return file:delete($filename)

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
        else if ($collection eq "nlp")          then $config:nlp-root      || "/"
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
        else if ($collection eq "nlp"       and not(xmldb:collection-available($config:nlp-root)))      then
            xmldb:create-collection($config:webdata-root, "nlp")
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
 else if ($collection eq "lemmalist") then $config:html-root     || "/"
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
    else if ($collection eq "lemmalist" and not(xmldb:collection-available($config:html-root)))     then
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
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
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
        else if ($collection eq "details")     then $fsRoot || $wid || "/html/"
        else if ($collection eq "snippets")    then $fsRoot || $wid || "/snippets/"
        else if ($collection eq "workslist")   then $fsRoot || $wid || "/"
 else if ($collection eq "lemmalist")   then $fsRoot || $wid || "/"
        else if ($collection eq "index")       then $fsRoot || $wid || "/"
        else if ($collection eq "crumbtrails") then $fsRoot || $wid || "/"
        else if ($collection eq "rdf")         then $fsRoot || $wid || "/"
        else if ($collection eq "routing")      then $fsRoot || $wid || "/"
        else                                        $fsRoot || "trash/"
    let $method :=
          if ($collection = ("html", "workslist")) then "html"
else if ($collection = ("html", "lemmalist")) then "html"
        else                                            "xml"

    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if ($content and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
    let $store-status := file:serialize($content, $pathname, map{"method":$method, "indent": true(), "encoding": "utf-8"})
    return  if ($store-status) then $pathname else ()
};

declare function admin:exportBase64File($filename as xs:string, $content as xs:string, $collection as xs:string?) {
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
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
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
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
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
        else if ($collection eq "nlp")       then $fsRoot || $wid || "/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
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
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
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
        else if ($collection eq "lemmalist") then $fsRoot
        else if ($collection eq "stats")     then $fsRoot
        else if ($collection eq "data")      then $fsRoot || "data/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
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
             if ($collection eq "iiif")      then $fsRoot || tokenize($wid, '_')[1] || "/"
        else if ($collection eq "stats")     then $fsRoot || tokenize($wid, '_')[1] || "/"
        else if ($collection eq "routing")   then $fsRoot || tokenize($wid, '_')[1] || "/"
        else                                      $fsRoot || "trash/"
    let $collectionStatus :=
        if (not(file:exists($collectionname))) then
            file:mkdirs($collectionname)
        else if (file:is-writeable($collectionname) and file:is-directory($collectionname)) then
            true()
        else
            error(QName("http://salamanca.school/error", "NoWritableFolder"), "Error: " || $collectionname || " is not a writable folder in filesystem.") 
    let $pathname := $collectionname || $filename
    let $remove-status := 
        if (count($content) gt 0 and file:exists($pathname)) then
            file:delete($pathname)
        else true()
    let $user := string(sm:id()//sm:real/sm:username)
    (: let $umask := sm:set-umask($user, 2) :)
     let $debug        := if($collection eq 'lemmalist') then console:log("Contents in buildDic: " || $content ) else () 
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

 (:declare function admin:buildFacetsNoJs ($node as node(), $model as map (*), $lang as xs:string?) {
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
}; :)


(:Categories : title, status, WIP, monoMultiUrl, name, sortName, nameFacet :)


declare function admin:buildDictList ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Building lemma facets for list view (version with Javascript)...") else ()
    let $result := for $l in ( "en")
                    let $content      := app:LEMfinalFacets($node, $model, $l)
                    let $filename     := 'dictionary_' || $l || '.json'
                    let $debug        := console:log("[ADMIN] Saving (Js) " || $l || " facets file in the database...")
                    let $storeStatus  := admin:saveTextFile("dummy", $filename, fn:serialize($content, map{"method":"json", "indent": true(), "encoding":"utf-8"}), "lemmalist")
                    let $debug        := console:log("[ADMIN] Exporting (Js) " || $l || " facets json file...")
                    let $exportStatus := admin:exportJSONFile($filename, $content, 'lemmalist')
                    return <div>Saved {$l} works list to {$storeStatus} and exported it to {$exportStatus}.</div>
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] LEmma finalFacets (Js) done!") else ()
    return $result
};

(: No noJS function needed, MAH 6.08.2025 :)
declare function admin:buildDictListNoJs ($node as node(), $model as map (*)) {
    <div><p>The function admin:buildDictList() remains to be written...</p></div>
};

declare function admin:exportFileWRK ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Exporting finalFacets (Js)...") else ()
 (:   let $fileNameDe         :=  'works_de.json' :)
    let $fileNameEn         :=  'works_en.json'
 (:   let $fileNameEs         :=  'works_es.json' :)
  (:  let $contentDe          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'de'), ", ") || "]") admin:exportJSONFile($fileNameDe, $contentDe, 'workslist'), :) (: app:WRKfinalFacets returns a sequence of strings, one per work in the collection :)
    let $contentEn          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'en'), ", ") || "]")
  (:  let $contentEs          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'es'), ", ") || "]")    admin:exportJSONFile($fileNameEs, $contentEs, 'workslist'):)
    let $store :=  (
                    admin:exportJSONFile($fileNameEn, $contentEn, 'workslist')
                  )
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of works exported to filesystem ({serialize($store)})!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open works.html</a>
        </span>   
};

declare function admin:exportFileLEM ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Exporting lemma list (Js)...") else ()
 (:   let $fileNameDe         :=  'works_de.json' :)
    let $fileNameEn         :=  'dictionary_en.json'
 (:   let $fileNameEs         :=  'works_es.json' :)
  (:  let $contentDe          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'de'), ", ") || "]") admin:exportJSONFile($fileNameDe, $contentDe, 'workslist'), :) (: app:WRKfinalFacets returns a sequence of strings, one per work in the collection :)
    let $contentEn          := fn:parse-json("[" || string-join(app:LEMfinalFacets($node, $model, 'en'), ", ") || "]")
  (:  let $contentEs          := fn:parse-json("[" || string-join(app:WRKfinalFacets($node, $model, 'es'), ", ") || "]")    admin:exportJSONFile($fileNameEs, $contentEs, 'workslist'):)
    let $store :=  (
                    admin:exportJSONFile($fileNameEn, $contentEn, 'lemmalist')
                  )
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of lemma exported to filesystem ({serialize($store)})!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open dictionary.html</a>
        </span>   
};

declare function admin:saveFileWRK ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Saving finalFacets (Js)...") else ()
    let $create-collection  :=  if (not(xmldb:collection-available($config:data-root))) then xmldb:create-collection($config:app-root, "data") else ()
   (: let $fileNameDe         :=  'works_de.xml' :)
    let $fileNameEn         :=  'works_en.xml'
 (:   let $fileNameEs         :=  'works_es.xml' :)
   (: let $contentDe          := <sal>{app:WRKfinalFacets($node, $model, 'de')}</sal>  xmldb:store($config:data-root, $fileNameDe, $contentDe),:)
    let $contentEn          := <sal>{app:WRKfinalFacets($node, $model, 'en')}</sal>
(:    let $contentEs          := <sal>{app:WRKfinalFacets($node, $model, 'es')}</sal> xmldb:store($config:data-root, $fileNameEs, $contentEs) :)
    let $store              :=  (
                                 xmldb:store($config:data-root, $fileNameEn, $contentEn)
                                 )
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of works saved to exist-db ({serialize($store)})!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open works.html</a>
        </span>   
};

declare function admin:saveFileLEM ($node as node(), $model as map (*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Saving lemma list (Js)...") else ()
    let $create-collection  :=  if (not(xmldb:collection-available($config:data-root))) then xmldb:create-collection($config:app-root, "data") else ()
   (: let $fileNameDe         :=  'works_de.xml' :)
    let $fileNameEn         :=  'dictionary_test_en.xml'
 (:   let $fileNameEs         :=  'works_es.xml' :)
   (: let $contentDe          := <sal>{app:WRKfinalFacets($node, $model, 'de')}</sal>  xmldb:store($config:data-root, $fileNameDe, $contentDe),:)
    let $contentEn          := <sal>{app:LEMfinalFacets($node, $model, 'en')}</sal>
(:    let $contentEs          := <sal>{app:WRKfinalFacets($node, $model, 'es')}</sal> xmldb:store($config:data-root, $fileNameEs, $contentEs) :)
    let $store              :=  (
                                 xmldb:store($config:data-root, $fileNameEn, $contentEn)
                                 )
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of lemma saved to exist-db ({serialize($store)})!</p>
            <br/><br/>
            <a href="dictionary.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open dictionary.html</a>
        </span>   
};

(:declare function admin:exportFileWRKnoJs ($node as node(), $model as map (*), $lang as xs:string?) {
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

}; :)

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
declare %templates:wrap function admin:renderHTML($id as xs:string*) as element(div) {
    let $start-time := util:system-time()
    let $resourceId := if ($id) then $id else request:get-parameter('rid', '*')

    (: define the works to be fragmented: :)
    let $todo := 
        if ($resourceId = '*') then
            collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "lemma_article")]]
        else
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          collection($config:tei-root)//tei:TEI[@xml:id = distinct-values($resourceId)][.//tei:text[@type = ("work_multivolume", "work_monograph", "lemma_article")]]:)
            collection($config:tei-root)/id(distinct-values($resourceId))[.//tei:text[@type = ("work_multivolume", "work_monograph", "lemma_article")]]

    (: for each requested resource: create fragments, insert them into the transformation, and produce some diagnostic info :)
    let $createData := 
        for $work-raw in $todo

            let $rid := $work-raw/ancestor-or-self::tei:TEI/@xml:id/string()
            let $text-type := ($work-raw/tei:text/@type/string())[1]

            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering HTML (and TXT) for " || $text-type || " " || $rid || ".") else ()
            let $start-time-work := util:system-time()
        
            let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                            if (doc-available(concat($subcollection, '/', $rid, '.xml'))) then $subcollection
                                            else ()

            (: (1) HTML :)

            let $start-time-a := util:system-time()
            let $htmlData     := html:makeHTMLData($work-raw)
            let $htmlDataOld  := html:makeHTMLDataOld($work-raw)

            (: Keep track of how long this work did take :)
            let $runtime-ms-a := ((util:system-time() - $start-time-a) div xs:dayTimeDuration('PT1S'))  * 1000
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Html files created. Saving...") else ()

            (: store data :)
            let $cleanCollectionStatus := admin:cleanCollection($rid, "html")
            let $cleanDirectoryStatus := admin:cleanDirectory($rid, "html")
            
            let $saveToc     := admin:saveFile($rid, $rid || "_toc.html", $htmlData('toc'), "html")
            let $exportToc   := admin:exportXMLFile($rid, $rid || "_toc.html", $htmlData('toc'), "html")
            let $savePages   := (
                admin:saveFile($rid, $rid || "_pages_de.html", $htmlDataOld('pagination_de'), "html"),
                admin:saveFile($rid, $rid || "_pages_en.html", $htmlDataOld('pagination_en'), "html"),
                admin:saveFile($rid, $rid || "_pages_es.html", $htmlDataOld('pagination_es'), "html")
                )
            let $exportPages := admin:exportXMLFile($rid, $rid || "_pages.html", $htmlData('pagination'), "html")
            let $exportFragments :=
                for $fragment in $htmlData('fragments') return
                    let $fileName := $fragment('number') || '_' || $fragment('tei_id') || '.html'
                    let $storeStatus := if ($fragment('html')) then admin:exportBinaryFile($rid, $fileName, $fragment('html'), 'html') else ()
                    return 
                        (: generate some HTML output to be shown in report :)
                        <div>
                            <h3>Fragment (new) {$fragment('index')}:</h3>
                            <h3>{$fragment('number')}: &lt;{$fragment('tei_name') || ' xml:id=&quot;' || $fragment('tei_id') 
                                 || '&quot;&gt;'} (Level {$fragment('tei_level')})</h3>
                            <div style="margin-left:4em;">
                                <div style="border:'3px solid black';background-color:'grey';">
                                    <code>{$rid}/{$fileName}:<br/>
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
                    let $storeStatusOld := if ($fragmentOld('html')) then admin:saveFile($rid, $fileName, $fragmentOld('html'), 'html') else ()
                    return 
                        (: generate some HTML output to be shown in report :)
                        <div>
                            <h3>Fragment (old) {$fragmentOld('index')}:</h3>
                            <h3>{$fragmentOld('number')}: &lt;{$fragmentOld('tei_name') || ' xml:id=&quot;' || $fragmentOld('tei_id') 
                                 || '&quot;&gt;'} (Level {$fragmentOld('tei_level')})</h3>
                            <div style="margin-left:4em;">
                                <div style="border:'3px solid black';background-color:'grey';">
                                    <code>{$rid}/{$fileName}:<br/>
                                        target xml:id={$fragmentOld('tei_id')} <br/>
                                        prev xml:id={$fragmentOld('prev')} <br/>
                                        next xml:id={$fragmentOld('next')} <br/>
                                    </code>
                                </div>
                            </div>
                        </div>

            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Html files saved. Cont'ing with plaintext files...") else ()
            
            (: (2) TXT :)
            
            let $txt-start-time      := util:system-time()
            let $plainTextEdit       := txt:makeTXTData($work-raw, 'edit')
            let $txtEditExportStatus := admin:exportBinaryFile($rid, $rid || "_edit.txt", $plainTextEdit, "txt")
            let $txtEditSaveStatus   := admin:saveTextFile($rid, $rid || "_edit.txt", $plainTextEdit, "txt")
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Plain text (edit) file created and stored.") else ()
            let $plainTextOrig       := txt:makeTXTData($work-raw, 'orig')
            let $txtOrigEXportStatus := admin:exportBinaryFile($rid, $rid || "_orig.txt", $plainTextOrig, "txt")
            let $txtOrigSaveStatus   := admin:saveTextFile($rid, $rid || "_orig.txt", $plainTextOrig, "txt")
            let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Plain text (orig) file created and stored.") else ()
            let $txt-end-time        := ((util:system-time() - $txt-start-time) div xs:dayTimeDuration('PT1S'))
            
            (: HTML & TXT Reporting :)
            
            return 
                <div>
                     <p><a href='{$config:idserver}/texts/{$rid}'>{string($rid)}</a>, Fragmentation depth: <code>{$htmlData('fragmentation_depth')}</code></p>
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


    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Done rendering HTML and TXT for " || $resourceId || ".") else ()
    let $debug := util:log('info', '[ADMIN] Created HTML for work ' || $resourceId || ' in ' || $runtime-ms || ' ms.')
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
    let $debug := console:log("[Admin] admin:createTeiCorpus: Building TEI XML corpus ...")

    (: make sure corpus directory exists :)
    let $corpusCollection := if (not(xmldb:collection-available($config:corpus-zip-root))) then xmldb:create-collection($config:webdata-root, 'corpus-zip') else ()

    (: Get TEI data, expand them and store them in the temporary collection :)
    let $serializationOpts := map { "method": "xml", "encoding": "UTF-8" , "expand-xincludes": true(), "omit-xml-declaration": false(), "ident": false()}
    let $entries := 
        for $reqWork in collection($config:tei-works-root)/tei:TEI/@xml:id[string-length(.) eq 5]/string()
            return if (doc-available($config:tei-works-root || '/' || $reqWork || '.xml') and sutil:WRKvalidateId($reqWork) eq 2) then
                let $expanded := util:expand(doc($config:tei-works-root || '/' || $reqWork || '.xml')/tei:TEI) 
                return <entry name="{$reqWork || '.xml'}" type="xml" method="deflate">{serialize($expanded, $serializationOpts)}</entry>
            else ()
    (: let $debug   := console:log("[Admin] admin:createTxtCorpus: $entries are: " || serialize($entries, map { "method": "xml" }) || ".") :)
    let $debug   := console:log("[Admin] admin:createTeiCorpus: $entries contains " || xs:string(count($entries)) || " entries.")

    (: Create a zip archive from the temporary collection and store it :)    
    let $zip    := compression:zip($entries, false())
    let $debug  := console:log("[Admin] admin:createTeiCorpus: $zip has length: " || xs:string(string-length(util:binary-to-string($zip))) || ".")
    let $save   := xmldb:store($config:corpus-zip-root, 'sal-tei-corpus.zip', $zip)
    let $debug  := console:log("[Admin] admin:createTeiCorpus: $zip saved to: " || $save || ".")
    let $export := admin:exportBase64File('sal-tei-corpus.zip', $zip, 'data')
    let $debug  := console:log("[Admin] admin:createTeiCorpus: $zip exported to: " || $export || ".")
    let $debug  := console:log("[Admin] admin:createTeiCorpus: resource " || $save || " has approx. " || xs:string(xmldb:size($config:corpus-zip-root, "sal-tei-corpus.zip")) || " bytes.")

    (: Log/output :)
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
    let $debug := console:log("[Admin] admin:createTxtCorpus: Building plaintext corpus ...")

    (: make sure corpus directory exists :)
    let $corpusCollection := if (not(xmldb:collection-available($config:corpus-zip-root))) then xmldb:create-collection($config:webdata-root, 'corpus-zip') else ()

    (: Get TXT data (or if they aren't available, render them officially) and store them in the temporary collection :)
    let $entries := 
        for $wid in collection($config:tei-works-root)/tei:TEI/@xml:id[string-length(.) eq 5][sutil:WRKvalidateId(./string()) eq 2]/string()
            return 
                let $orig := 
                    if (util:binary-doc-available($config:txt-root || '/' || $wid || '/' || $wid || '_orig.txt')) then
                        util:binary-to-string(util:binary-doc($config:txt-root || '/' || $wid || '/' || $wid || '_orig.txt'))
                    else 
                        let $tei := util:expand(doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI)
                        let $debug := if ($config:debug = ("trace", "info")) then console:log('[ADMIN] Rendering txt version of work: ' || $config:tei-works-root || '/' || $wid || '.xml') else ()
                        let $origTxt := string-join(txt:dispatch($tei, 'orig'), '')
                        let $debug := if ($config:debug = ("trace", "info")) then console:log('[ADMIN] Rendered ' || $wid || ', string length: ' || string-length($origTxt)) else ()
                        let $saveOrig := admin:saveFile($wid, $wid || "_orig.txt", $origTxt, "txt")
                        let $exportOrig := admin:exportBinaryFile($wid || "_orig.txt", $origTxt, "/data/" || $wid || "/text/" )
                        return $origTxt
                let $edit := 
                    if (util:binary-doc-available($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt')) then
                        util:binary-to-string(util:binary-doc($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt'))
                    else 
                        let $tei := util:expand(doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI)
                        let $editTxt := string-join(txt:dispatch($tei, 'edit'), '')
                        let $saveEdit := admin:saveFile($wid, $wid || "_edit.txt", $editTxt, "txt")
                        let $exportEdit := admin:exportBinaryFile($wid || "_edit.txt", $editTxt, "/data/" || $wid || "/text/" )
                        return $editTxt
                return (<entry name="{$wid || '_orig.txt'}" type="text" method="deflate">{$orig}</entry>,
                        <entry name="{$wid || '_edit.txt'}" type="text" method="deflate">{$edit}</entry>)
    (: let $debug   := console:log("[Admin] admin:createTxtCorpus: $entries are: " || serialize($entries, map { "method": "xml" }) || ".") :)
    let $debug   := console:log("[Admin] admin:createTxtCorpus: $entries contains " || xs:string(count($entries)) || " entries.")

    (: Create a zip archive from the temporary collection and store it :)    
    let $zip    := compression:zip($entries, false())
    let $debug  := console:log("[Admin] admin:createTxtCorpus: $zip has length: " || xs:string(string-length(util:binary-to-string($zip))) || ".")
    let $save   := xmldb:store($config:corpus-zip-root, 'sal-txt-corpus.zip', $zip)
    let $debug  := console:log("[Admin] admin:createTxtCorpus: $zip saved to: " || $save || ".")
    let $export := admin:exportBase64File('sal-txt-corpus.zip', $zip, 'data')
    let $debug  := console:log("[Admin] admin:createTxtCorpus: $zip exported to: " || $export || ".")
    let $debug  := console:log("[Admin] admin:createTxtCorpus: resource " || $save || " has approx. " || xs:string(xmldb:size($config:corpus-zip-root, "sal-txt-corpus.zip")) || " bytes.")

    (: Log/output :)
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
(: NOTE: the largest part of the snippets creation takes place here, not in factory,
         since it applies to different types of texts (works, working papers) at once :)
declare function admin:sphinx-out($wid as xs:string*, $mode as xs:string?) {

    let $start-time := util:system-time()
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering sphinx snippets for " || $wid || ".") else ()

    (: Which works are to be indexed? :)
    let $todo := 
        if ($wid = '*') then
            collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "author_article", "lemma_article", "working_paper")]]
        else
            collection($config:tei-root)/id(distinct-values($wid))
    let $expanded := 
        for $work-raw in $todo
            let $cleanCollectionStatus := admin:cleanCollection($work-raw/@xml:id, "snippets")
            let $cleanDirectoryStatus  := admin:cleanDirectory($work-raw/@xml:id, "snippets")
            return util:expand($work-raw)

    (: which parts of those works constitute a fragment that is to count as a hit?:
       - In works and lemmata, all index:isBasicNode nodes;
       - in Working Papers, all paragraphs and keywords in tei:profileDesc
    :)
    let $nodes :=
        for $w in $expanded return
            if (starts-with($w/@xml:id, 'W0') or starts-with($w/@xml:id, 'L0')) then
                (: works and lemmata :)
                $w/tei:text//*[index:isBasicNode(.)]
            else if (starts-with($w/@xml:id, 'WP')) then
                (: working papers :)
                $w//tei:profileDesc//(tei:p|tei:keywords)
            else () (: TODO: authors etc. :)
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
                else if  ($teiHeader//tei:publicationStmt/tei:date[@type = "digitizedEd"]) then
                    xs:string($teiHeader//tei:publicationStmt/tei:date[@type = "digitizedEd"][1])
                else ()
            let $hit_type := local-name($hit)
            let $hit_id := xs:string($hit/@xml:id)
            let $hit_citeID := if ($nodeType eq 'work') then sutil:getNodetrail($work_id, $hit, 'citeID') else ()
            let $hit_language := xs:string($hit/ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang)
            let $hit_fragment := 
                if ($hit_id and xmldb:collection-available($config:html-root || '/' || $work_id)) then
                    sutil:getFragmentID($work_id, $hit_id)
                else ()
            let $hit_fragment_number := 
                if ($hit_fragment) then
                    xs:int(substring($hit_fragment, 1, 4))
                else ()
            
            let $hit_path :=  (: modify here to have the relative path :) 
                if ($hit_fragment) then
                    $config:webserver || "/data/" || $work_id || "/html/" || $hit_fragment || ".html"
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
                    $config:webserver || "/workingpaper.html?wpid=" || $work_id
                else
                    "#No fragment discoverable!"
            let $nodeIndex         := doc($config:index-root || "/" || $work_id || "_nodeIndex.xml")
            (: let $nodeCrumbtrails   := doc($config:crumb-root || "/" || $work_id || "_crumbtrails.xml") :)
            let $hit_label         := string($nodeIndex//sal:node[@n eq $hit_id]/@label)
            (: Currently we create the crumbtrail in the indexing step and just retrieve it here. Could be optimized...
               Also, currently the crumbtrail consists of fragment-type html links, not of PID-style ones. This could also be improved...
            :)
            let $crumbtrail := string($nodeIndex//sal:node[@n eq $hit_id]/@crumbtrail)

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
                    if ($nodeType = ('work', 'lemma')) then
                        normalize-space(string-join(txt:dispatch($hit, 'snippets-edit'), ''))
                    else normalize-space(string-join(render-app:dispatch($hit, 'snippets-edit', ()), ''))
                else
                    'There is no xml:id in the ' || $hit_type || ' hit!'
            
            (: Now build a sphinx "row" for the fragment :)
            (: let $sphinx_id    := xs:long(substring($work_id, functx:index-of-string-first($work_id, "0"))) * 1000000 + ( (string-to-codepoints(substring($work_id, 1, 1)) + string-to-codepoints(substring($work_id, 2, 1))) * 10000 ) + $index :)
            let $sphinx_id    := xs:long(substring($work_id, 2)) * 100000000 + $index
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
                        <div>Crumbtrail: {$crumbtrail}</div>
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
                    <sphinx_hit_crumbtrail>{$crumbtrail}</sphinx_hit_crumbtrail>
                    <sphinx_description_orig>{$hit_content_orig}</sphinx_description_orig>
                    <sphinx_description_edit>{$hit_content_edit}</sphinx_description_edit>
                    <sphinx_html_path>{$hit_path}</sphinx_html_path>
                    <sphinx_fragment_path>{$hit_url}</sphinx_fragment_path>
                    <sphinx_fragment_number>{$hit_fragment_number}</sphinx_fragment_number>
                </sphinx:document>

            (: Save final snippet file :)
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
            collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "lemma_article")]]
        else
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          collection($config:tei-root)//tei:TEI[@xml:id = distinct-values($wid)]:)
            collection($config:tei-root)/id(distinct-values($wid))

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

            let $debug := if ($config:debug = ("info")) then console:log("[ADMIN] There are "  || count($tei//tei:ref[@xml:id])|| " refs with xml:id in this work.") else ()

            (: save final index file :)
            let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Saving index file ...") else ()

            let $cleanCollectionStatus := admin:cleanCollection($wid, "index")
            let $cleanDirectoryStatus := admin:cleanDirectory($wid, "index")
            
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
                <message>The PDF {$PdfInput} of the work {$rid} could not be uploaded. </message>
            </results>
};


declare function admin:createPdf($rid as xs:string){
    let $pdf-start-time           := util:system-time()
    let $doctotransform as node() := doc($config:tei-works-root || '/'|| $rid || '.xml')//tei:TEI

    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Creating pdf from " || $rid || " ...") else ()
    let $debug := if ($config:debug = ("trace", "info") )then console:log("[PDF-" || $rid ||"] Transforming into XSL-FO...") else ()

let $doctransformed2          := transform:transform($doctotransform, "xmldb:exist:///db/apps/salamanca/modules/factory/works/pdf/generic_template.xsl", ())

    let $debug := if ($config:debug = ("trace", "info") )then console:log("[PDF-" || $rid ||"] FO OK..") else ()

let $fo-config :=
  <parameters>
    <fop-config>xmldb:exist:///db/apps/salamanca/resources/config/fop.xconf</fop-config>
  </parameters>
   let $storexslfo := xslfo:render(
    $doctransformed2,
    "application/pdf",
    $fo-config
)

    let $debug := if ($config:debug = ("trace", "info") ) then console:log("[PDF-" || $rid ||"] Transforming from XSL-FO to PDF...") else ()                         
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
                          collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "lemma_article")]]
                      else
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:                        collection($config:tei-root)//tei:TEI[@xml:id = distinct-values($wid)]:)
                          collection($config:tei-root)/id(distinct-values($wid))

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

            let $cleanCollectionStatus := admin:cleanCollection($wid, "crumbtrails")
            let $cleanDirectoryStatus := admin:cleanDirectory($wid, "crumbtrails")

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
    for $i in collection($config:tei-root)//tei:TEI[descendant::tei:text/@type = ('work_multivolume', 'work_monograph', 'lemma_article')]
    return admin:createRoutes($i/@xml:id/string())
};

declare function admin:createRoutes($wid as xs:string) {
    let $start-time := util:system-time()
    let $debug := console:log("[ADMIN] Routing: Creating routing for " || $wid || " ...")
    let $index                  := if (doc-available($config:index-root || "/" || $wid || "_nodeIndex.xml")) then doc($config:index-root || "/" || $wid || "_nodeIndex.xml")/sal:index else ()
    let $routingWork            := admin:buildRoutingInfoWork($wid)
    let $routingWorkDetails     := array{ admin:buildRoutingInfoDetails($wid) }
    let $routingNodes           := if ($index) then
                                        array{fn:for-each($index//sal:node, function($k) {admin:buildRoutingInfoNode($wid, $k)} )}
                                   else ()
    let $routingVolumeDetails   := if ($index) then
                                        array{fn:for-each($index//sal:node[@subtype = "work_volume"], function($k) {admin:buildRoutingInfoDetails($wid || ':' || $k/@citeID)} )}
                                   else if (doc-available($config:tei-works-root || '/' || $wid || '.xml')) then
                                        let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Routing: creating routing details info for volumes, resolving xincludes...") else ()
                                        let $volumes := doc($config:tei-works-root || '/' || $wid || '.xml')//xi:include[contains(@href, '_Vol')]/@href/substring-before(translate(., 'V', 'v'), '.xml')
                                        return array{fn:for-each($volumes, function($k) {
                                                                                            let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Routing: creating routing details info for volume " || $k || "/" || $wid || ':vol' || xs:int(tokenize($k, 'vol')[2]) || " ...") else ()
                                                                                            return admin:buildRoutingInfoDetails($wid || ':vol' || xs:int(tokenize($k, 'vol')[2]))
                                                                                        }
                                                    )}
                                   else
                                        let $debug := console:log("[ADMIN] Problem in creating volume routing for " || $wid || "?: Neither index nor a file'" || $config:tei-works-root || '/' || $wid || ".xml' could be found.")
                                        return ()
    let $routingTable           := array:join( ( $routingWork, $routingNodes, $routingVolumeDetails, $routingWorkDetails ) )

    let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Routing: Joint routing table: " || substring(serialize($routingTable, map{"method":"json", "indent": false(), "encoding":"utf-8"}), 1, 500) || " ...") else ()

    (: save routing table :)
    let $cleanCollectionStatus := admin:cleanCollection($wid, "routing")
    let $cleanDirectoryStatus := admin:cleanDirectory($wid, "routing")

    let $routingSaveStatus  :=  if ($routingTable instance of array(*) and array:size($routingTable) > 0) then
                                    admin:saveTextFile($wid, $wid || '_routes.json', fn:serialize($routingTable, map{"method":"json", "indent": true(), "encoding":"utf-8"}), 'routes')
                                else ()
    let $debug := if ($config:debug = ("info", "trace")) then console:log("[ADMIN] Routing: Table saved as " || $routingSaveStatus || ".") else ()

    let $debug := console:log("[ADMIN] Routing: Exporting routing file with " || array:size($routingTable) || " entries...")
    let $routingExportStatus := admin:exportJSONFile($wid, $wid || "_routes.json", $routingTable, "routing")

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

declare function admin:buildRoutingInfoNode($wid as xs:string, $item as element(sal:node)) {
    let $textTypePath := if (starts-with($wid, 'W')) then
                            '/texts/'
                         else if (starts-with($wid, 'L')) then
                            '/lemmata/'
                         else
                            ''
    let $filepath := $wid || "/html/" || $item/@fragment/string() || ".html"
    let $hash := "#" || $item/@n/string()
    let $value := map {
                    "input" :   concat($textTypePath, $wid, ":", $item/@citeID/string()),
                    "outputs" : array { ( $filepath, $hash ) }
                  }
    return $value
};

declare function admin:buildRoutingInfoWork($resourceId as xs:string) {
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return
                                    if (doc-available(concat($subcollection, '/', $resourceId, '.xml'))) then
                                        $subcollection
                                    else ()
    let $text_type :=      if (starts-with($resourceId, "L0")) then "lemmata"
                      else if (starts-with($resourceId, "WP0")) then "workingpapers"
                      else "texts"
    let $anchor :=  if ($text_type eq 'texts') then
                            let $index := if (doc-available($config:index-root || "/" || $resourceId || "_nodeIndex.xml")) then
                                            doc($config:index-root || "/" || $resourceId || "_nodeIndex.xml")/sal:index
                                          else ()
                            return
                                if ($index) then
                                    tokenize($resourceId, '_')[1] || '/html/' || $index/sal:node[1]/@fragment/string() || ".html#" || $index/sal:node[1]/@n/string()
                                else
                                    let $debug := console:log("[ADMIN] admin:buildRoutingInfoWork: No index for work " || $resourceId || ". Possibly the work is only available as image facsimiles. We let work id resolve to catalogue view.")
                                    let $log := util:log("warn", "[ADMIN] admin:buildRoutingInfoWork: No index for work " || $resourceId || ". Possibly the work is only available as image facsimiles. We let work id resolve to catalogue view.")
                                    return tokenize($resourceId, '_')[1] || '/html/' || $resourceId || '_details.html'
                    else if ($text_type eq 'workingpapers') then
                        tokenize($resourceId, '_')[1] || '/html/' || $resourceId || '_details.html'
                    else if ($text_type eq 'lemma_article') then
                        tokenize($resourceId, '_')[1] || '/html/00001_completeWork.html'
                    else  if (contains($resourceId, ':')) then
                        let $id := tokenize($resourceId, ':')[1]
                        return concat( $id, '/html/', $id, '_Vol', format-integer(xs:int(substring-after(tokenize($resourceId, ':')[2], 'vol')), '00'), '_details.html')
                    else
                        tokenize($resourceId, '_')[1] || '/html/' || $resourceId || '_details.html'

    let $filepath := tokenize($anchor, '#')[1]
    let $fragmentHash := tokenize($anchor, '#')[2]
    let $hash := if (string-length($fragmentHash) gt 0) then '#' || $fragmentHash else ''

    let $value := array {
                            ( map {
                                    "input" :   "/" || $text_type || "/" || $resourceId,
                                    "outputs" : array { ( $filepath, $hash ) }
                                  }
                            )
                        }
    return $value
};

declare function admin:buildRoutingInfoDetails($id) {
    let $text_type :=      if (starts-with($id, "L0")) then "lemmata"
                      else if (starts-with($id, "WP0")) then "workingpapers"
                      else "texts"
    (: let $debug := if ($config:debug = "trace") then console:log('$id: ' || $id || ' (type ' || $text_type || ').') else () :)
    let $output :=  if (contains($id, ':')) then
                        let $wid := tokenize($id, ':')[1]
                        return concat( $wid, '/html/', $wid, '_Vol', format-integer(xs:int(substring-after(tokenize($id, ':')[2], 'vol')), '00'), '_details.html')
                    else 
                concat( $id, '/html/', $id, '_details.html') 
    return
        (: During routing, we have a replacement that moves an eventual 
           'mode=details' parameter out of the url query parameters
           and into the path (as a '_details' suffix).
           So the actual id ←→ html routing has to operate on a
           'id.salamanca.school/*/*_details' input value. 
        :)
        map {
              "input" :   "/" || $text_type || "/" || $id || '_details',
              "outputs" : array { ( $output, '' ) }
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
           if ($config:instanceMode eq "dockernet") then
        'http://existdb:8080/exist/apps/salamanca/services/lod/extract.xql?format=rdf&amp;configuration='
        || 'http://existdb:8080/exist/apps/salamanca/services/lod/createConfig.xql?resourceId=' || $rid
    else
           'http://www.salamanca.school:8080/exist/apps/salamanca/services/lod/extract.xql?format=rdf&amp;configuration='
        || 'http://www.salamanca.school:8080/exist/apps/salamanca/services/lod/createConfig.xql?resourceId=' || $rid
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

    let $cleanCollectionStatus := admin:cleanCollection($rid, "rdf")
    let $cleanDirectoryStatus  := admin:cleanDirectory($rid, "rdf")
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
~ Creates NLP information
:)
declare function admin:createNLP($rid as xs:string) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering NLP CSV for " || $rid || ".") else ()
    let $rid :=
        if (starts-with($rid, "authors/")) then
            substring-after($rid, "authors/")
        else if (starts-with($rid, "texts/")) then
            substring-after($rid, "texts/")
        else $rid
    let $start-time := util:system-time()

    let $mode       := 'nonotes' (: edit, snippets-edit, nonotest, [nlp, ner, plain, ...] :)
    let $lang       := '*'
    let $collection := util:expand(collection($config:tei-works-root)/id($rid)/self::tei:TEI)//tei:text
    let $textnodes  := $collection//tei:*[not(ancestor::tei:note)][not(ancestor::xi:fallback)][index:isMainNode(.)]
    let $csv        := nlp:createCSV($textnodes, $mode, $lang)

    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    let $runtimeString := 
        if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
        else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
    let $log    := util:log('info', 'Extracted NLP CSV for ' || $rid || ' in ' || $runtimeString)

    let $cleanCollectionStatus := admin:cleanCollection($rid, "nlp")
    let $cleanDirectoryStatus  := admin:cleanDirectory($rid, "nlp")
    let $export := admin:exportBinaryFile($rid, $rid || '.csv', $csv, 'nlp')
    let $save   := admin:saveFile($rid, $rid || '.csv', $csv, 'nlp')

    let $debug  := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Done rendering NLP CSV for " || $rid || ".") else ()
    return 
        <div>
            <h2>NLP Extraction</h2>
            <p>Extracted NLP CSV in {$runtimeString} and saved at {$save}</p>
            <div style="margin-left:5em;">{if ($config:debug = ("trace")) then $csv else ()}</div>
        </div>
};
 
(:
~ Creates and stores a IIIF manifest/collection for work $wid.
:)
declare function admin:createIIIF($wid as xs:string) {
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $target-work := util:expand(collection($config:tei-root)//tei:TEI[@xml:id = $wid]):)
    let $target-work := util:expand(collection($config:tei-root)/id($wid))

    let $todo := if ($target-work/tei:text/@type = "work_multivolume") then
            distinct-values(($wid, for $vol in $target-work//tei:text[@type = "work_volume"] return $wid || "_" || $vol/@xml:id/string()))
        else
            $wid

    let $debug := 
        if ($config:debug = ('info', 'trace')) then
            let $dbg := console:log("[ADMIN] iiif: Creation of IIIF resources requested, work id(s): " || string-join($todo, ', ') || ".")
            return util:log("info", "Creation of IIIF resources requested, work id(s): " || string-join($todo, ', ') || ".")
        else ()

    let $reports :=
        for $r in $todo
            let $start-time := util:system-time()
    
            let $resource := iiif:createResource($r)
        
            let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
            let $runtimeString := 
                if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
                else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
                else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
            let $timing := 'Extracted IIIF for ' || $r || ' in ' || $runtimeString
            let $log    := util:log('info', $timing)
        
            let $store  := if ($resource instance of map(*) and map:size($resource) > 0) then
 let $cleanCollectionStatus := admin:cleanCollection($r, "iiif")
                    return admin:saveTextFile($r, $r || '.json', fn:serialize($resource, map{"method":"json", "indent": true(), "encoding":"utf-8"}), 'iiif')
 else ()
            let $export := if ($resource instance of map(*) and map:size($resource) > 0) then
 let $cleanDirectoryStatus := admin:cleanDirectory($r, "iiif")
                    return admin:exportJSONFile($r, $r || '.json', $resource, 'iiif')
 else ()
        
            return 
                <p>
                    {$timing}<br/>
                    iiif Manifest stored in {$store}.<br/>
                    iiif Manifest exported to {$export}.
                </p>
    return <div>{$reports}</div> 
};

declare function admin:StripLBs($input as xs:string) {
    normalize-space(replace($input, '&#10;', ' '))
};

(: 
~ Creates and stores overview page for catalog page(s) or for working paper view.
:)
declare function admin:createDetails($currentResourceId as xs:string) {
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[ADMIN] Rendering Details for " || $currentResourceId || ".") else ()
    let $start-time := util:system-time()

    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $currentResourceId, '.xml'))) then $subcollection
                                    else ()

    let $wid := $currentResourceId
    let $todo := 
        if ($wid = '*') then
            collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "work_volume", "lemma_article", "working_paper")]]
        else
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          collection($targetSubcollection)//tei:TEI[@xml:id = distinct-values($wid)]:)
            collection($targetSubcollection)/id(distinct-values($wid))
    let $expanded :=  for $resource-raw in $todo return util:expand($resource-raw)

    let $process_loop := for $resource in $expanded

        let $id        := $resource/@xml:id/string()

        let $exportXml := admin:exportXMLFile($id, $id || '.xml', $resource, 'index')
        let $exportLog := console:log("[ADMIN] Exported '" || $id || ".xml' with " || xs:string(count($resource//tei:*)) || " nodes to " || $exportXml || ".")

        let $public_id := if ($resource//tei:text[@type = ("work_multivolume", "work_monograph", "lemma_article", "working_paper")]) then
                              $id
                          else
                              tokenize($id, '_')[1] || ':vol' || $resource//tei:text[@type = "work_volume"]/@n/string()
        let $text_type := $resource//tei:text/@type/string()
        let $teiHeader := $resource//tei:teiHeader

        let $volume_names   := for $v in $teiHeader//tei:notesStmt/tei:relatedItem[@type eq 'work_volume'] return $v/@target/tokenize(., ':')[2]
        let $debug          := if (count($volume_names)>0) then console:log('[Details] $volume_names: ' || string-join($volume_names, ', ')) else ()
        let $volumes        := for $f in $volume_names return if (doc-available($config:tei-root || '/works/' || $f || '.xml')) then map:entry($f, doc($config:tei-root || '/works/' || $f || '.xml')) else ()
        let $volumes        := map:merge($volumes)
   (:  let $debug := console:log('$volumes: ' || serialize($volumes, map {"method":"json", "media-type":"application/json"}))  :)
    
        let $volumes_list := for $key in map:keys($volumes) order by $key
                                let $iiif_file      := $config:iiif-root || '/' || $key || '.json'
                                let $iiif            := if (util:binary-doc-available($iiif_file)) then json-doc($iiif_file) else map{}
                                let $vol_thumbnail  := if (count(map:keys($iiif)) gt 0 and "thumbnail" = map:keys($iiif)) then
                                                            $iiif?thumbnail
                                                        else
                                                            let $debug := console:log("[Details] No iiif information for " || $wid || "/" || $key || " found.")
                                                            return ()
                                 let $debug := console:log('$vol_thumbnail: ' || serialize($vol_thumbnail, map {"method":"json", "media-type":"application/json"})) 
                                 let $debug := console:log('$iiif-vol?thumbnail?@id: ' || serialize(map:get($vol_thumbnail, '@id'), map {"method":"json", "media-type":"application/json"})) 
                                let $teiHeader := map:get($volumes, $key)//tei:teiHeader
                                let $isFirstEd := not($teiHeader//tei:sourceDesc//tei:imprint/(tei:date[@type eq "thisEd"] | tei:pubPlace[@role eq "thisEd"] | tei:publisher[@n eq "thisEd"]))
                                 let $debug := console:log("thumbnail : " || map:get($vol_thumbnail, '@id'))
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
                                                                    string-join($teiHeader//tei:sourceDesc//tei:imprint/tei:publisher[@n eq "thisEd"]/tei:persName/tei:surname, '/')
                                                                else
                                                                    string-join($teiHeader//tei:sourceDesc//tei:imprint/tei:publisher/tei:persName/tei:surname, '/'),
                                    "printer_full" :            if (not($isFirstEd)) then
                                                                    admin:StripLBs(string-join($teiHeader//tei:sourceDesc//tei:imprint/tei:publisher[@n eq "thisEd"]/tei:persName/string(), '/'))
                                                                else
                                                                    admin:StripLBs(string-join($teiHeader//tei:sourceDesc//tei:imprint/tei:publisher/tei:persName/string(), '/')),
                                    "year" :                    if ($isFirstEd) then
                                                                     $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'firstEd']/@when/string()
                                                                else
 $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'thisEd']/@when/string(),                                                                
                                    "src_publication_period" :  $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'summaryFirstEd']/string(),
                                    "language" :                string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n eq 'main']/string(), ', ') ||
                                                                (if ($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']) then
                                                                    ' (' || string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']/string(), ', ') || ')'
                                                                else ()),
                                    "thumbnail" :               map:get($vol_thumbnail, '@id'),
                                    "schol_ed" :                admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#scholarly')]/string(), ' / ')),
                                    "tech_ed" :                 admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#technical')]/string(), ' / ')),
                                    "el_publication_date" :     if ($teiHeader//tei:editionStmt//tei:date[@type eq 'digitizedEd']/@when) then
                                                                    $teiHeader//tei:editionStmt//tei:date[@type eq 'digitizedEd']/@when/string()[1]
else if ($teiHeader//tei:editionStmt//tei:date[@type eq 'summaryDigitizedEd']/@when) then $teiHeader//tei:editionStmt//tei:date[@type eq 'summaryDigitizedEd']/@when/string()[1]
                                                                else
                                                                    'in prep.',
                                    "hold_library" :            normalize-space(string-join($teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/string(), ' | ')),
                                    "hold_idno" :               normalize-space(string-join($teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno/string(), ' ')),
                                    "status" :                  $teiHeader/tei:revisionDesc/@status/string()
                              

                                }

        let $dbg := for $v in $volumes_list return
                        if (count(map:get($v, 'key')) gt 1) then
                            console:log("[ADMIN] Problem! More than one key value in a volume_string key: " || string-join(map:get($v, 'key'), ', '))
                        else ()
                                            
        let $vol_strings    := for $v in $volumes_list return '$' || string(map:get($v, 'key')) || ' := dict ' ||
                                        string-join(for $k in map:keys($v) return '"' || $k || '" "' || string-join(map:get($v, $k), ', ') || '"', ' ')

        let $iiif_file      := $config:iiif-root || '/' || $id || '.json'
        let $iiif           := if (util:binary-doc-available($iiif_file)) then json-doc($iiif_file) else map{}
        let $thumbnail_id   := if (count(map:keys($iiif)) gt 0 and "thumbnail" = map:keys($iiif)) then
                                    map:get($iiif?thumbnail, '@id') 
                               else if (count($volumes_list) gt 0) then
                                    let $debug := console:log("[Details] No iiif information for " || $wid || " found, looking in volumes...")
                                    return (for $v at $pos in $volumes_list return $v?thumbnail)[1]
                               else
                                    let $debug := console:log("[Details] No iiif information for " || $wid || " found.")
                                    return ()

        let $isFirstEd      := not($teiHeader//tei:sourceDesc//tei:imprint/(tei:date[@type eq "thisEd"] | tei:pubPlace[@role eq "thisEd"] | tei:publisher[@n eq "thisEd"]))
        let $work_info      := map {
            "id" :                      $public_id,
            "uri" :                     $config:idserver || '/texts/' || $public_id,
            "series_num" :              $teiHeader//tei:seriesStmt/tei:biblScope[@unit eq 'volume']/@n/string(),
            "author_short" :            string-join($teiHeader//tei:titleStmt/tei:author/tei:persName/tei:surname, '/'),
            "author_full" :             admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:author/tei:persName/string(), '/')),
            "title_short" :             $teiHeader//tei:titleStmt/tei:title[@type eq 'short']/string(),
            "title_full" :              admin:StripLBs($teiHeader//tei:titleStmt/tei:title[@type eq 'main']/string()),
            "abstract" :                normalize-space($teiHeader/tei:profileDesc/tei:abstract/string()),
            "keywords" :                string-join(for $kw in $teiHeader/tei:profileDesc//tei:keywords/tei:term return normalize-space($kw), '; '),
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
                                        else if ($teiHeader//tei:sourceDesc//tei:imprint/tei:date) then
                                            $teiHeader//tei:sourceDesc//tei:imprint/tei:date[not(@type = 'summaryFirstEd')]/@when/string()
                                        else if ($teiHeader//tei:publicationStmt/tei:date) then
                                            $teiHeader//tei:publicationStmt/tei:date/@when/string()
                                        else (),
            "src_publication_period" :  $teiHeader//tei:sourceDesc//tei:imprint/tei:date[@type eq 'summaryFirstEd']/string(),
            "language" :                if ($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n eq 'main']) then 
                                            string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n eq 'main']/string(), ', ') ||
                                                (if ($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']) then
                                                    ' (' || string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language[@n ne 'main']/string(), ', ') || ')'
                                                 else ()
                                            )
                                         else
                                            string-join($teiHeader/tei:profileDesc/tei:langUsage/tei:language/string(), ', '),
            "thumbnail" :               $thumbnail_id,
            "schol_ed" :                admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#scholarly')]/string(), ' / ')),
            "tech_ed" :                 admin:StripLBs(string-join($teiHeader//tei:titleStmt/tei:editor[contains(@role, '#technical')]/string(), ' / ')),
                 "el_publication_date" :     if ($teiHeader//tei:editionStmt//tei:date[@type eq 'digitizedEd']/@when) then
                                                                    $teiHeader//tei:editionStmt//tei:date[@type eq 'digitizedEd']/@when/string()[1]
else if ($teiHeader//tei:editionStmt//tei:date[@type eq 'summaryDigitizedEd']/@when) then $teiHeader//tei:editionStmt//tei:date[@type eq 'summaryDigitizedEd']/@when/string()[1]
                                                                else
                                                                    'in prep.',
                                 
                                    "type": if ($teiHeader//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched'
                                          )) then "Facsimiles"
else if ($teiHeader//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched', 
                                           'g_enriched_approved',
                                           'h_revised'
                                          ) and contains($teiHeader//tei:encodingDesc/tei:editorialDecl/tei:p/@xml:id, 'AEW'))  then "Automatically Edited Work"
                            else if ($teiHeader//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched', 
                                           'g_enriched_approved',
                                           'h_revised'
                                          ) and contains($teiHeader//tei:encodingDesc/tei:editorialDecl/tei:p/@xml:id, 'RW'))  then "Reference Work"
else 'Edited Work',
       "hold_library" :            if (count($volumes_list) gt 0 and not($teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository)) then
                                            'check individual volumes'
                                        else
                                            normalize-space(string-join($teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/string(), ' | ')),
            "hold_idno" :               normalize-space(string-join($teiHeader//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno/string(), ' ')),
            "urn" :                     $teiHeader//tei:sourceDesc//tei:ref[@type eq 'url'][starts-with(./text(), 'urn:')]/string(),
            "pdfurl" :                  $teiHeader//tei:sourceDesc//tei:ref[@type eq 'url'][ends-with(./text(), '.pdf')]/string(),
            "image_filename" :          tokenize($resource//tei:text//tei:titlePage//tei:graphic/@url[ends-with(., '.png')], '/')[last()],
            "status" :                  $teiHeader/tei:revisionDesc/@status/string(),
            "number_of_volumes" :       count(map:keys($volumes)),
            "volumes":                  $volumes_list
        }

        let $debug := if ($config:debug = "trace") then console:log($work_info) else ()

        let $vol_keys := for $v in $volumes_list return concat('$', map:get($v, 'key')) 
        let $volumes_string := '{{ $Volumes := dict "number" ' || xs:string(map:get($work_info, 'number_of_volumes')) ||
                                                    ' "volumes" (list ' || string-join($vol_keys, ' ') || ') }}'
        let $work_string := if ("working_paper" = $text_type) then
                                    '{{ $map := dict "id" "' || $public_id ||
                                                    '" "title" "' || $work_info?title_full ||
                                                    '" "author" "' || $work_info?author_full ||
                                                    '" "abstract" "' || $work_info?abstract ||
                                                    '" "keywords" "' || $work_info?keywords ||
                                                    '" "language" "' || $work_info?language ||
                                                    '" "year" "' || $work_info?year ||
                                                    '" "serialnumber" "' || $work_info?title_short ||
                                                    '" "urn" "' || $work_info?urn ||
                                                    '" "pdfurl" "' || $work_info?pdfurl ||
                                                    '" "image_filename" "' || $work_info?image_filename ||
                                    '" }}'
                            else
                                    '{{ $work_info := dict ' ||
                                        string-join(for $key in map:keys($work_info) return
                                                        if ($key ne 'volumes') then
                                                            '"' || $key || '" "' || string-join(map:get($work_info, $key), " ") || '"'
                                                        else (), ' ') ||
                                        (if (count(map:keys($volumes)) gt 0) then ' "volumes" $Volumes' else ()) ||
                                    ' }}'
        let $include_string := if ("working_paper" = $text_type) then
                                    '{{- include "/resources/templates/template-workingpaper.html" $map }}'
                               else
                                    '{{- include "../../../resources/templates/template-details.html" $work_info }}'

        let $work_result := concat(
                                     (if (count($vol_strings) gt 0) then
                                         '{{ ' || string-join($vol_strings, ' }}&#10;{{ ') || ' }}&#10;' || $volumes_string || '&#10;&#10;'
                                      else ()
                                     ),
                                     $work_string, '&#10;&#10;', $include_string, '&#10;'
                            )

        let $save   := admin:saveTextFile($id, $id || '_details.html', $work_result, 'details')
        let $export := admin:exportBinaryFile($id, $id || '_details.html', $work_result, 'details')

        let $debug := if ($config:debug = ("info", "trace")) then console:log("[Details] Going into recursion for volume details...") else ()
        let $recursion := for $v in map:keys($volumes)
                            let $debug := console:log("[Details] Rendering details for volume " || $v || "...")
                            return admin:createDetails($v)
        return ($id, $save, $export)
    let $debug := if ($config:debug = "bla") then
                    console:log("[ADMIN] Done rendering Details.")
                  else if ($config:debug = ("info", "trace")) then
                    console:log("[ADMIN] Done rendering Details. (Saved/exported to " || string-join(for $v in $process_loop return string-join($v, ','), '; ') || ").")
                  else ()
    return $process_loop
};

(: 
~ Creates and stores statistics.
:)
declare function admin:createStats($rid as xs:string) {
    let $wid := if ($rid eq "") then "*" else $rid

    let $start-time := util:system-time()

    let $debug := console:log("[ADMIN] Stats: Creating stats for " || $wid || " ...")
    let $log  := if ($config:debug = ('info', 'trace')) then util:log('info', "[ADMIN] Stats: Creating stats for " || $wid || " ...") else ()

    let $params := 
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="json"/>
        </output:serialization-parameters>

    (: corpus stats :)
    let $result := if ($wid eq "*") then
        let $debug := console:log('[ADMIN] Create corpus stats...')
        let $corpusStats := stats:makeCorpusStats()

        let $save        := admin:saveFile('dummy', 'corpus-stats.json', serialize($corpusStats, $params), 'stats')
        let $export      := admin:exportJSONFile('corpus-stats.json', $corpusStats, 'stats')

        let $debug := console:log('[ADMIN] Done creating corpus stats. Saved and exported to ' || $save || ' and ' || $export || '.')
        let $log := if ($config:debug = ('info', 'trace')) then util:log('info', '[ADMIN] Done creating corpus stats. Saved and exported to ' || $save || ' and ' || $export || '.') else ()

        (: single work stats:)
        let $debug := console:log('[ADMIN] Creating all single work stats...')
        let $allSingleWorksStats :=
            for $id in sutil:getPublishedWorkIds() order by $id return
                let $log := if ($config:debug = 'trace') then util:log('info', '[ADMIN] Creating single work stats for ' || $id || '...') else ()
                let $workStats := stats:makeWorkStats($id)
    
                let $cleanCollectionStatus := admin:cleanCollection($id, "stats")
                let $cleanDirectoryStatus := admin:cleanDirectory($id, "stats")
    
                let $saveSingle   := admin:saveFile('dummy', $id || '-stats.json', serialize($workStats, $params), 'stats')
                let $exportSingle := admin:exportJSONFile($id, $id || '-stats.json', $workStats, 'stats')
                let $log := if ($config:debug = 'trace') then util:log('info', '[ADMIN] Done creating single work stats for ' || $id || '. Saved and exported to ' || $saveSingle || ' and ' || $exportSingle || '.') else ()
                return $workStats
        return ($corpusStats, $allSingleWorksStats)
    else
        if ($wid = sutil:getPublishedWorkIds()) then
            let $log := if ($config:debug = ('info', 'trace')) then util:log('info', '[ADMIN] Creating single work stats for ' || $wid || '...') else ()
            let $workStats := stats:makeWorkStats($wid)

            let $cleanCollectionStatus := admin:cleanCollection($wid, "stats")
            let $cleanDirectoryStatus := admin:cleanDirectory($wid, "stats")

            let $saveSingle   := admin:saveFile('dummy', $wid || '-stats.json', serialize($workStats, $params), 'stats')
            let $exportSingle := admin:exportJSONFile($wid, $wid || '-stats.json', $workStats, 'stats')
            let $log := if ($config:debug = 'trace') then util:log('info', '[ADMIN] Done creating single work stats for ' || $wid || '. Saved and exported to ' || $saveSingle || ' and ' || $exportSingle || '.') else ()
            return $workStats
        else
            ("Problem: wid " || $wid || " was not in the list of published WorkIDs.")

    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000
    let $runtimeString :=
        if ($runtime-ms < (1000 * 60)) then format-number($runtime-ms div 1000, "#.##") || " Sek."
        else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
        else format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
    let $log  := util:log('info', '[ADMIN] Extracted corpus and works stats in ' || $runtimeString || '.')
    let $debug := console:log('Extracted corpus and works stats in ' || $runtimeString || '.')
    return $result
};
