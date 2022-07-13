xquery version "3.1";

(: ####++++----

    Module for util functions that are of a general nature and used by multiple other modules.
    Bundling such functions here shall prevent interdependencies between larger and more specific modules.

    ----++++#### :)

module namespace sutil = "http://www.salamanca.school/xquery/sutil";

declare namespace tei           = "http://www.tei-c.org/ns/1.0";
declare namespace sal           = "http://salamanca.adwmainz.de";

declare namespace exist         = "http://exist.sourceforge.net/NS/exist";
declare namespace util          = "http://exist-db.org/xquery/util";

import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace templates   = "http://exist-db.org/xquery/html-templating";
import module namespace lib         = "http://exist-db.org/xquery/html-templating/lib";

import module namespace config  = "http://www.salamanca.school/xquery/config"    at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace i18n    = "http://exist-db.org/xquery/i18n"              at "xmldb:exist:///db/apps/salamanca/modules/i18n.xqm";

declare option exist:timeout "166400000"; (: in miliseconds, 25.000.000 ~ 7h, 43.000.000 ~ 12h :)


(:
~ Makes a copy of a node tree, to be used for making copies of subtrees on-the-fly for not having to process the whole document
    (supposed to increase speed especially where "intersect" statements are applied).
:)
declare function sutil:copy($node as element()) as node() {
    (:element {node-name($node)}
    {$node/@*,
        for $child in $node/node()
             return if ($child instance of element()) then 
                sutil:copy($child)
             else $child
    }:)
    (:util:deep-copy($node):)
    (: this seems to be the fastest option: :)
    let $xsl :=
        <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            <xsl:template match="@*|node()">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
              </xsl:template>
          </xsl:stylesheet>
    return
        transform:transform($node, $xsl, ())
};


(: Normalizes work, author, lemma, news, and working paper ids (and returns everything else as-is :)
declare function sutil:normalizeId($id as xs:string?) as xs:string? {
    if (contains($id, '_vol') or        contains($id, '_VOL')) then
 translate($id, 'wvLO', 'WVlo')
        else if (string-length($id) eq 5 and substring($id, 1, 1) = ('w', 'l', 'a', 'n')) then (: work, lemma, author, news :)
        upper-case($id)
        else if (matches($id, '^[wW][pP]\d{4}$')) then upper-case($id)                              (: working papers :)
        else $id
};
(: replaced the following with the above for performance reasons on 2021-04-28 ...
declare function sutil:normalizeId($id as xs:string?) as xs:string? {
    if ($id) then
        if      (matches($id, '^[wW]\d{4}(_[vV][oO][lL]\d{2})?$')) then translate($id, 'wvLO', 'WVlo')
        else if (matches($id, '^[lLaAnN]\d{4}$')) then upper-case($id) (: lemma, author, news :)
        else if (matches($id, '^[wW][pP]\d{4}$')) then upper-case($id)
        else $id
    else ()
};
:)

(: validate work/author/... IDs :)

declare function sutil:AUTexists($aid as xs:string?) as xs:boolean {
    if ($aid) then boolean(doc($config:tei-meta-root || '/' || 'sources-list.xml')/tei:TEI/tei:text//tei:author[lower-case(substring-after(@ref, 'author:')) eq lower-case($aid)])
    else false()
};

(: 1 = valid & available; 0 = valid, but not yet available; -1 = not valid :)
declare function sutil:AUTvalidateId($aid as xs:string?) as xs:integer {
    if ($aid and matches($aid, '^[aA]\d{4}$')) then
        (: TODO: additional condition when author articles are available - currently this will always resolve to -1 :)
        if (sutil:AUTexists(sutil:normalizeId($aid))) then 0
        else -1
    else -1    
};

declare function sutil:LEMexists($lid as xs:string?) as xs:boolean {
    (: TODO when we have a list of lemma ids :)
    let $result :=
    if ($lid = ("L0998")) then
            doc-available($config:tei-lemmata-root || '/' || $lid || '.xml')
        else
            false()
    return $result
};

(: 1 = valid & available; 0 = valid, but not yet available; -1 = not valid :)
declare function sutil:LEMvalidateId($lid as xs:string?) as xs:integer {
    if ($lid and matches($lid, '^[lL]\d{4}$')) then
        (: TODO: additional conditions when lemmata/entries are available - currently this will always resolve to -1 :)
        if (sutil:LEMexists(sutil:normalizeId($lid))) then 1
        else -1
    else -1    
};

(: 1 = WP is published ; 0 = WP not yet available (not yet defined) ; -1 = WP does not exist :)
declare function sutil:WPvalidateId($wpid as xs:string?) as xs:integer {
    if ($wpid and matches($wpid, '^[wW][pP]\d{4}$') and sutil:WPisPublished($wpid)) then 1
    else -1
};

declare function sutil:WPisPublished($wpid as xs:string?) as xs:boolean {
    boolean($wpid and doc-available($config:tei-workingpapers-root || '/' || upper-case($wpid) || '.xml')) 
};

declare function sutil:WRKexists($wid as xs:string?) as xs:boolean {
    if ($wid) then boolean(doc($config:tei-meta-root || '/' || 'sources-list.xml')/tei:TEI/tei:text//tei:bibl/@corresp[lower-case(substring-after(., 'work:')) eq lower-case($wid)])
    else false()
};

(: 2 = valid, full data available; 1 = valid, but only metadata available; 0 = valid, but not yet available; -1 = not valid :)
declare function sutil:WRKvalidateId($wid as xs:string?) as xs:integer {
(:    let $debug := if ($config:debug = ("info", "trace")) then console:log("sutil:WRKvalidateId for work " || $wid || ".") else ()
    return :)
    if ($wid) then
(: replaced the following with the above for performance reasons on 2021-04-28 ...
    if ($wid and matches($wid, '^[wW]\d{4}(_Vol\d{2})?$')) then
:)
        if (sutil:WRKisPublished($wid)) then 2
        else if (doc-available($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')) then 1
        else if (sutil:WRKexists($wid)) then 0
        else -1
    else -1    
};

declare function sutil:WRKisPublished($wid as xs:string) as xs:boolean {
    let $workId := sutil:normalizeId($wid)
    let $status :=  if (doc-available($config:tei-works-root || '/' || $workId || '.xml')) then 
                        doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:teiHeader/tei:revisionDesc/@status/string()
                    else 'no_status'
    let $publishedStatus := ('g_enriched_approved', 'h_revised', 'h_temporarily_suspended', 'i_revised_approved', 'z_final')
    return $status = $publishedStatus
};

(: 1 = valid & existing ; 0 = not existing ; -1 = no dataset found for $wid :)
(:declare function sutil:WRKvalidatePassageId($wid as xs:string?, $passage as xs:string?) as xs:integer {
    if ($wid and matches($wid, '^[wW]\d{4}(_Vol\d{2})?$')) then
        if (sutil:WRKisPublished($wid)) then 2
        else if (doc-available($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')) then 1
        else if (sutil:WRKexists($wid)) then 0
        else -1
    else -1    
};:)

(: concepts? :)



(:
~ For a volume ID of the form "W0013-A" or "W0096-B", return a matching ID of the form "W0013_Vol01" or "W0096_Vol02";
~ currently covers volume numbers up to "10", or "J"
:)
declare function sutil:convertVolumeID($volId as xs:string) as xs:string {
    let $volChar := substring($volId, 7, 1)
    let $workId := substring($volId, 1, 5)
    let $volInfix := '_Vol'
    let $volN :=
        switch($volChar)
            case 'A' return '01'
            case 'B' return '02'
            case 'C' return '03'
            case 'D' return '04'
            case 'E' return '05'
            case 'F' return '06'
            case 'G' return '07'
            case 'H' return '08'
            case 'I' return '09'
            case 'J' return '10'
            default return error(xs:QName('sutil:convertVolumeID'), 'Error: volume number not supported')
    return $workId || $volInfix || $volN
};

declare function sutil:convertNumericVolumeID($volId as xs:string) as xs:string? {
    if (matches($volId, '^[Ww]\d{4}$')) then upper-case($volId)
    else if (matches($volId, 'W\d{4}:vol\d{1,2}$')) then $volId
    else if (matches($volId, '^[Ww]\d{4}_[Vv][Oo][Ll]\d{2}$')) then
        let $mainN := substring($volId, 2, 4)
        let $volN := if (substring($volId, 10,1) eq '0') then substring($volId, 11) else substring($volId, 10)
        return 'W' || $mainN || ':vol' || $volN
    else ()
};


declare function sutil:getNodeIndexValue($wid as xs:string, $node as element()) {
    if (doc-available($config:index-root || '/' || $wid || '.xml')) then
        ()
    else ()
};

declare function sutil:getFragmentID($targetWorkId as xs:string, $targetNodeId as xs:string) as xs:string? {
    doc($config:index-root || '/' || $targetWorkId || '_nodeIndex.xml')//sal:node[@n = $targetNodeId][1]/@fragment/string()
};

declare function sutil:getNodetrail($wid as xs:string, $node as element(), $mode as xs:string) {
(:
    let $debug := console:log("sutil:getNodetrail(" || $wid || ", " || serialize($node) || ", " || $mode || ")")
    return
:)
    if (doc-available($config:index-root || '/' || $wid || '_nodeIndex.xml')) then
        let $idx := doc($config:index-root || '/' || $wid || '_nodeIndex.xml')
        return if ($idx//sal:node[@n eq $node/@xml:id]) then
            switch ($mode)
                case "citeID"
                    return doc($config:index-root || '/' || $wid || '_nodeIndex.xml')//sal:node[@n eq $node/@xml:id]/@citeID/string()
                case "crumbtrail"
                    return doc($config:index-root || '/' || $wid || '_nodeIndex.xml')//sal:node[@n eq $node/@xml:id]/sal:crumbtrail
                case "label"
                    return doc($config:index-root || '/' || $wid || '_nodeIndex.xml')//sal:node[@n eq $node/@xml:id]/@label/string()
                default
                    return util:log('error', '[sutil] calling sutil:getNodetrail with unknown mode: ' || $mode)
        else
            util:log('error', '[sutil] calling sutil:getNodetrail(' || $wid || ', ' || $mode || ') but found no indexed node for node: ' || serialize($node))
    else
        util:log('error', '[sutil] calling sutil:getNodetrail(' || $wid || ', ' || $mode || ') but no index file available.')
};

(:
For a resource (work or volume) id, returns the url to the resource's iiif resource.
:)
declare function sutil:getIiifUrl($workId as xs:string) as xs:string? {
    if (doc-available($config:tei-works-root || '/' || $workId || '.xml')) then
        let $workType := doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:text/@type
        return
            if ($workType eq 'work_multivolume') then (: iiif collection :)
                $config:iiifPresentationServer || 'collection/' || $workId
            else (: iiif manifest :)
                $config:iiifPresentationServer || $workId || '/manifest'
    else ()
};

declare function sutil:getPublishedWorkIds() as xs:string* {
    collection($config:tei-works-root)/tei:TEI[./tei:text/@type = ('work_monograph', 'work_multivolume') 
                                               and sutil:WRKisPublished(@xml:id)]/@xml:id/string()
};


(:~
 : ========================================================================================================================
 : Title for Browser-Tab for SingleView Work, -Lemma, -Working Paper, -Authors, -News
 :)
 (:Name wird zusammengesetzt, Nachname, Vorname:)
declare function sutil:formatName($persName as element()*) as xs:string? {
    let $return-string := 
        for $pers in $persName return
            if ($pers/@key) then
                normalize-space(xs:string($pers/@key))
            else if ($pers/tei:surname and $pers/tei:forename) then
                normalize-space(concat($pers/tei:surname, ', ', $pers/tei:forename, ' ', $pers/tei:nameLink, if ($pers/tei:addName) then ('&amp;nbsp;(&amp;lt;' || $pers/tei:addName || '&amp;gt;)') else ()))
            else if ($pers) then
                normalize-space(xs:string($pers))
            else 
                normalize-space($pers/text())
    return (string-join($return-string, ' &amp; '))
};


(: 
~ Combines title, author name, and publish details of a work. 
:)
declare %templates:wrap
    function sutil:WRKcombined($node as node()?, $model as map(*)?, $wid as xs:string?) {
        let $path           :=  doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")//tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr
        let $author         :=  string-join($path//tei:author/tei:persName/tei:surname, ', ')
        let $title          :=  $path//tei:title[@type = 'short']
        let $thisEd         :=  $path//tei:pubPlace[@role = 'thisEd']
        let $firstEd        :=  $path//tei:pubPlace[@role = 'firstEd']
        let $publisher :=  
            if ($thisEd) then
                $path//tei:imprint/tei:publisher[@n = 'thisEd']/tei:persName[1]/tei:surname
            else
                $path//tei:imprint/tei:publisher[@n = 'firstEd']/tei:persName[1]/tei:surname
        let $place :=  
            if ($thisEd) then
                $thisEd
            else
                $firstEd
        let $year :=  
            if ($thisEd) then 
                $path//tei:date[@type = 'thisEd']/@when/string() 
            else
                $path//tei:date[@type = 'firstEd']/@when/string()
        let $pubDetails     :=  $place || '&#32;'||": " || $publisher || ", " || $year
            return ($author||':  '||$title||'. '||$pubDetails||'.') 
};  


(:
~ For a $citeID and a $workId, fetches the matching node from the respective TEI dataset.
:)
declare function sutil:getTeiNodeFromCiteID($workId as xs:string, $citeID as xs:string?) as element()? {
    let $nodeId :=    
        if ($citeID) then
            doc($config:index-root || '/' || sutil:normalizeId($workId) || '_nodeIndex.xml')//sal:node[@citeID eq $citeID][1]/@n[1]/string()
            else
        'completeWork'
    return
        util:expand(doc($config:tei-works-root || '/' || sutil:normalizeId($workId) || '.xml')/tei:TEI)//tei:*[@xml:id eq $nodeId]
};

(:
~ For exporting, fetch the matching node from the respective TEI dataset (don't expand XIncludes).
:)
declare function sutil:extractTeiNodeFromCiteID($workId as xs:string, $citeID as xs:string?) as element()? {
    let $nodeId := 
        if ($citeID) then
            doc($config:index-root || '/' || sutil:normalizeId($workId) || '_nodeIndex.xml')//sal:node[@citeID eq $citeID][1]/@n[1]/string()
        else
            'completeWork'
    return
(:      doc($config:tei-works-root || '/' || sutil:normalizeId($workId) || '.xml')//tei:*[@xml:id eq $nodeId] :)
 doc($config:tei-works-root || '/' || sutil:normalizeId($workId) || '.xml')/id($nodeId)
};

(: Modes for generating citation recommendations: 
    - "record" for generic citations in catalogue records 
    - "reading-full" for generic citations in reading view; access date has to be appended elsewhere
    - "reading-passage" for fine-granular citations in reading view, including passagetrail - this yields two <span>s, 
        between the two of which the acces date has to be inserted (e.g., by means of JS)
:)
declare function sutil:HTMLmakeCitationReference($wid as xs:string, $fileDesc as element(tei:fileDesc), $mode as xs:string, $node as element()?) as element(span)+ {
    let $author := $fileDesc/tei:titleStmt/tei:author/tei:persName/tei:surname/text()
    let $title := $fileDesc/tei:titleStmt/tei:title[@type eq 'short']/text()
    let $digitalYear := substring($fileDesc/tei:publicationStmt/tei:date[@type = ('digitizedEd', 'summaryDigitizedEd')]/@when/string()[1], 1, 4)
    let $originalYear := 
        if ($fileDesc/tei:sourceDesc//tei:date[@type eq 'thisEd']) then
            $fileDesc/tei:sourceDesc//tei:date[@type eq 'thisEd']/@when
        else $fileDesc/tei:sourceDesc//tei:date[@type eq 'firstEd']/@when
    (:let $editors :=
        string-join(for $ed in $fileDesc/tei:seriesStmt/tei:editor/tei:persName 
                        order by $ed/tei:surname
                        return app:rotateFormatName($ed), ' &amp; '):)
    let $citeID :=
        if ($mode eq 'reading-passage' and $node) then
            sutil:getNodetrail($wid, $node, 'citeID')
        else ()
    let $citeIDStr := if ($citeID) then ':' || $citeID else ()
    let $link := $config:idserver || '/texts/' || $wid || $citeIDStr || (if ($mode eq 'reading-passage') then '?format=html' else ())
    let $label := 
        if ($mode eq 'reading-passage' and $node) then
            let $passage := sutil:getNodetrail($wid, $node, 'label')
            return 
                if ($passage) then <span class="cite-rec-trail">{$passage || ', '}</span> else ()
        else ()
    let $body := 
        <span class="cite-rec-body">{$author || ', ' || $title || ' (' || $digitalYear || ' [' || $originalYear || '])'|| ', '}
            {$label}
            <i18n:text key="inLow">in</i18n:text>{': '}<i18n:text key="editionSeries">The School of Salamanca. A Digital Collection of Sources</i18n:text>
            {' <'}
            <a href="{$link}">{$link}</a>
            {'>'}
        </span>
(:   including editors (before link): {', '}<i18n:text key="editedByAbbrLow">ed. by</i18n:text>{' ' || $editors || ' <'}     :)
    return ($body)
};
