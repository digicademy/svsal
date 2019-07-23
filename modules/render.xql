xquery version "3.1";

module namespace render            = "http://salamanca/render";
declare namespace exist            = "http://exist.sourceforge.net/NS/exist";
declare namespace output           = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";
import module namespace request    = "http://exist-db.org/xquery/request";
import module namespace templates  = "http://exist-db.org/xquery/templates";
import module namespace xmldb      = "http://exist-db.org/xquery/xmldb";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace config     = "http://salamanca/config" at "config.xqm";
import module namespace app        = "http://salamanca/app"    at "app.xql";
import module namespace functx     = "http://www.functx.com";
import module namespace transform  = "http://exist-db.org/xquery/transform";
import module namespace sal-util    = "http://salamanca/sal-util" at "sal-util.xql";
import module namespace i18n      = "http://exist-db.org/xquery/i18n"        at "i18n.xql";

(:declare option exist:serialize       "method=html5 media-type=text/html indent=no";:)

(: *Work* rendering functions and settings :)

(: TODO: some of the functions here are also used by non-work entity rendering procedures (such as WP snippet rendering)
         - these should eventually have there own rendering functions/modules at some point :)

(: SETTINGS :)

(: the max. amount of characters to be shown in a note teaser :)
declare variable $render:noteTruncLimit := 40;

declare variable $render:teaserTruncLimit := 45;

declare variable $render:basicElemNames := ('p', 'head', 'note', 'item', 'cell', 'label', 'signed', 'lg', 'titlePage');

(:
declare variable $render:chars :=
    if (doc-available($config:tei-meta-root || '/specialchars.xml')) then
        map:merge(
            for $c in doc($config:tei-meta-root || '/specialchars.xml')/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:charDecl/tei:char return 
                map:entry($c/@xml:id/string(), $c)
        )
    else ();:)


(: "Nodetrail" (crumbtrail/citetrail/passagetrail) administrator function :)
declare function render:getNodetrail($targetWorkId as xs:string, $targetNode as node(), $mode as xs:string, $fragmentIds as map()?) {
    (: (1) get the trail ID for the current node :)
    let $currentNode := 
        (: no recursion here, makes single ID for the current node :)
        if ($mode eq 'crumbtrail') then
            let $class := render:dispatch($targetNode, 'class')
            return
                if ($class) then
                    <a class="{$class}" href="{render:mkUrlWhileRendering($targetWorkId, $targetNode, $fragmentIds)}">{render:dispatch($targetNode, 'title')}</a>
                else 
                    <a href="{render:mkUrlWhileRendering($targetWorkId, $targetNode, $fragmentIds)}">{render:dispatch($targetNode, 'title')}</a>
        (:else if ($mode eq 'passagetrail' and render:isPassagetrailNode($targetNode)) then
            render:dispatch($targetNode, $mode):)
        else if ($mode eq 'citetrail') then
            render:dispatch($targetNode, $mode)
        else if ($mode eq 'passagetrail') then
            (: not all nodes that are to be indexed get an *individual* passagetrail, so that we can already apply a filter here: :)
            if (render:isPassagetrailNode($targetNode)) then
                render:dispatch($targetNode, $mode)
            else () (: all other nodes inherit passagetrail from their nearest passagetrail ancestor (see below) :)
        else 
            (: neither html nor numeric mode :) 
            render:dispatch($targetNode, 'title')
    
    (: (2) get related element's (e.g., ancestor's) trail, if required, and glue it together with the current trail ID 
            - HERE is the RECURSION :)
    (: (a) trail of related element: :)
    let $trailPrefix := 
        if ($mode = ('citetrail', 'crumbtrail')) then
            if ($targetNode/ancestor::*[render:getCitableParent($targetNode)]) then
                render:getNodetrail($targetWorkId, render:getCitableParent($targetNode), $mode, $fragmentIds)
            else ()
        else if ($mode eq 'passagetrail') then (: similar to crumbtrail/citetrail, but we need to target the nearest *passagetrail* ancestor, not the nearest index node ancestor :)
            (: TODO: outsource this to a render:getPassagetrailParent($node as node()) function, analogous to render:getCitableParent() :)
            if ($targetNode/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:text[not(@type eq 'work_volume')])]) then
                if ($targetNode[self::tei:pb]) then 
                    if ($targetNode/ancestor::tei:front|$targetNode/ancestor::tei:back|$targetNode/ancestor::tei:text[1][@type = "work_volume"]) then
                        (: within front, back, and single volumes, prepend front's or volume's trail ID for avoiding multiple identical IDs in the same work :)
                        render:getNodetrail($targetWorkId,  ($targetNode/ancestor::tei:front|$targetNode/ancestor::tei:back|$targetNode/ancestor::tei:text[1][@type = "work_volume"])[last()], $mode, $fragmentIds)
                    else ()
                else if ($targetNode[self::tei:pb]) then ()
                else if ($targetNode[self::tei:note or self::tei:milestone]) then
                    (: citable parents of notes and milestones should not be p :)
                    render:getNodetrail($targetWorkId, $targetNode/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:p)][1], $mode, $fragmentIds)
                else 
                    (: === for all other node types, get parent node's trail (deep recursion) === :)
                    render:getNodetrail($targetWorkId, $targetNode/ancestor::*[render:isPassagetrailNode(.)][1], $mode, $fragmentIds)
            else ()
        else ()
    (: (b) get connector MARKER :)
    let $connector :=
        if ($currentNode and $trailPrefix) then
            if ($mode eq 'crumbtrail') then ' » ' 
            else if ($mode eq 'citetrail') then '.' 
            else if ($mode eq 'passagetrail') then ' '
            else ()
        else ()
    (: (c) put it all together and out :)
    (:let $debug := 
        if ($config:debug = ('trace', 'info') and $mode eq 'citetrail') then 
            util:log('warn', 'Making citetrail of type ' || $mode || ' for element tei:' || local-name($targetNode) || '; $currentNode: ' 
            || string-join(($currentNode), ' ') || ', $trailPrefix:' || string-join(($trailPrefix), ' ') || '.') 
        else ():)
    let $trail :=
        if ($connector) then
             if ($mode eq 'crumbtrail') then ($trailPrefix, $connector, $currentNode)
             else if ($mode eq 'citetrail') then $trailPrefix || $connector || $currentNode
             else if ($mode eq 'passagetrail') then $trailPrefix || $connector || $currentNode
             else ()
        else if ($currentNode) then $currentNode
        else () (:error(xs:QName('render:getNodetrail'), 'Could not make individual nodetrail for element ' || local-name($currentNode)):)
    return $trail
};

(: Gets the citable crumbtrail/citetrail (not passagetrail!) parent :)
declare function render:getCitableParent($node as node()) as node()? {
    if ($node/self::tei:milestone or $node/self::tei:note) then
        (: notes and milestones must not have p as their citableParent :)
        $node/ancestor::*[render:isIndexNode(.) and not(self::tei:p)][1]
    else if ($node/self::tei:pb) then
        if ($node/ancestor::tei:front|$node/ancestor::tei:back|$node/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")]) then
            (: within front, back, and single volumes, citable parent resolves to one of those elements for avoiding collisions with identically named pb in other parts :)
            ($node/ancestor::tei:front|$node/ancestor::tei:back|$node/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")])[last()]
        else () (: TODO: this makes "ordinary" pb appear outside of any structural hierarchy - is this correct? :)
    else $node/ancestor::*[render:isIndexNode(.)][1]
};

(:
~ Determines which nodes serve for "passagetrail" production.
:)
declare function render:isPassagetrailNode($node as element()) as xs:boolean {
    boolean(
        render:isIndexNode($node) and
        (
            $node/self::tei:text[@type eq 'work_volume'] or
            $node/self::tei:div[$config:citationLabels(@type)?('isCiteRef')] or
            $node/self::tei:milestone[$config:citationLabels(@unit)?('isCiteRef')] or
            $node/self::tei:pb[not(@sameAs or @corresp)] or
            $node[$config:citationLabels(local-name(.))?('isCiteRef') and not(ancestor::tei:note)]
        )
    )
};

(:
~ Determines which nodes to make HTML teasers for (subset of //*[render:isIndexNode(.)] excluding low-level elements). 
    Should mostly be used together with render:makeHTMLSummaryTitle()
:)
declare function render:isCitableWithTeaserHTML($node as node()) as xs:boolean {
    boolean(
        render:isIndexNode($node) and
        (
            not(
                $node/self::tei:pb or
                $node/self::tei:text[not(@type eq 'work_volume')] or
                $node/self::tei:milestone[@type eq 'other'] or
                $node/self::tei:note or
                $node/self::tei:head or
                $node/self::tei:back or
                $node/self::tei:front or
                $node/self::tei:titlePage or
                $node/self::tei:item or
                $node/self::tei:list[not(@type = ('dict'))] or
                $node/self::tei:p or
                $node/self::tei:signed or
                $node/self::tei:label or
                $node/self::tei:lg
            )
        )
    )
};

(:
~ Determines whether a node should have a citation anchor, without an additional teaser.
:)
declare function render:isBasicCitableHTML($node as node()) as xs:boolean {
    boolean(
        render:isIndexNode($node) 
        and not(render:isCitableWithTeaserHTML($node)) (:complement of //*[render:isCitableWithTeaserHTML()]:)
        and local-name($node) = $render:basicElemNames
        and not($node/ancestor::tei:titlePage)
    )
};

(:declare function render:isSphinxSnippetRoot($node as node()) as xs:boolean {
    boolean(
        render:isIndexNode($node)
        and ...
    )
};:)


(:
~ (The set of nodes that should have a crumbtrail is equal to the set of nodes that should have a citetrail.)
:)
declare function render:isIndexNode($node as node()) as xs:boolean {
    typeswitch($node)
        case element() return
            (: any element type relevant for citetrail creation must be included in one of the following functions: :)
            boolean(render:isNamedCitetrailNode($node) or render:isUnnamedCitetrailNode($node))
        default return 
            false()
};

(:
~ Determines whether a node is a specific citetrail element, i.e. one that is specially prefixed in citetrails.
:)
declare function render:isNamedCitetrailNode($node as element()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:milestone or
            $node/self::tei:pb[not(@sameAs or @corresp)] or (: are pb/@sameAs|@corresp needed anywhere? :)
            $node/self::tei:note or
            $node/self::tei:head or
            $node/self::tei:back or
            $node/self::tei:front or
            $node/self::tei:titlePage or
            $node/self::tei:div[@type ne "work_part"] or (: TODO: included temporarily for div label experiment :)
            $node/self::tei:item[ancestor::tei:list[1][@type = ('dict', 'index', 'summaries')]] or
            $node/self::tei:list[@type = ('dict')] or
            $node/self::tei:text[@type eq 'work_volume']
        )
    )
};

(:
~ Determines whether a node is a 'generic' citetrail element, i.e. one that isn't specially prefixed in citetrails.
:)
declare function render:isUnnamedCitetrailNode($node as element()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
           (:$node/self::tei:text[not(ancestor::tei:text)] or:) (: we won't produce any trail ID for this, but we need it as a recursion anchor :)
           (:$node/self::tei:div[@type ne "work_part"] or:) (: TODO: commented out for div label experiment :)
           $node/self::tei:p[not(ancestor::tei:note|ancestor::tei:item)] or
           $node/self::tei:signed or
           $node/self::tei:label[not(ancestor::tei:lg|ancestor::tei:note|ancestor::tei:item|ancestor::tei:p)] or (: labels, contrarily to headings, are simply counted :)
           $node/self::tei:lg[not(ancestor::tei:lg|ancestor::tei:note|ancestor::tei:item|ancestor::tei:p)] or (: count only top-level lg, not single stanzas :)
           $node/self::tei:list[not(@type = ('dict'))] or
           $node/self::tei:item[not(ancestor::tei:list[1][@type = ('dict', 'index', 'summaries')]|ancestor::tei:note|ancestor::tei:item)]
        )
    )
};

(: debug: :)
declare function render:preparePaginationHTML($work as element(tei:TEI), $lang as xs:string?, $fragmentIds as map()?) as element(ul) {
    let $workId := $work/@xml:id
    return 
        <ul id="later" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1">{
            for $pb in $work//tei:text//tei:pb[render:isIndexNode(.) and not(@sameAs or @corresp)] return
                let $fragment := $fragmentIds($pb/@xml:id/string()) (:$pb/sal:fragment:)
                let $url      := 'work.html?wid=' || $workId || '&amp;frag=' || $fragment || '#' || concat('pageNo_', $pb/@n)
                return 
                    <li role="presentation"><a role="menuitem" tabindex="-1" href="{$url}">{normalize-space($pb/sal:title)}</a></li>
        }</ul>
};


declare function render:mkUrlWhileRendering($targetWorkId as xs:string, $targetNode as node(), $fragmentIds as map()) {
    let $targetNodeId := string($targetNode/@xml:id)
    let $viewerPage   :=      
        if (substring($targetWorkId, 1, 2) eq 'W0') then
            'work.html?wid='
        else if (substring($targetWorkId, 1, 2) eq 'L0') then
            'lemma.html?lid='
        else if (substring($targetWorkId, 1, 2) eq 'A0') then
            'author.html?aid='
        else if (substring($targetWorkId, 1, 2) eq 'WP') then
            'workingPaper.html?wpid='
        else
            'index.html?wid='
    let $targetNodeHTMLAnchor :=    
        if (contains($targetNodeId, '-pb-')) then
            concat('pageNo_', $targetNodeId)
        else $targetNodeId
    let $frag := $fragmentIds($targetNodeId)
    return concat($viewerPage, $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeHTMLAnchor)
};


declare function render:getFragmentFile ($targetWorkId as xs:string, $targetNodeId as xs:string) {
    doc($config:index-root || '/' || $targetWorkId || '_nodeIndex.xml')//sal:node[@n = $targetNodeId][1]/sal:fragment/text()
};


(:
~  Creates a teaser string of limited length (defined in $config:chars_summary) from a given node.
~  @param mode: must be one of 'orig', 'edit' (default)
:)
declare function render:teaserString($node as element(), $mode as xs:string?) as xs:string {
    let $thisMode := if ($mode = ('orig', 'edit')) then $mode else 'edit'
    let $string := normalize-space(string-join(render:dispatch($node, $thisMode)))
    return 
        if (string-length($string) gt $config:chars_summary) then
            concat('&#34;', normalize-space(substring($string, 1, $config:chars_summary)), '…', '&#34;')
        else
            concat('&#34;', $string, '&#34;')
};

(: ####++++ HTML Helper Functions ++++####:)

(: modes: "record" for generic citations in catalogue records; "reading-full", "reading-passage" - only relevant for access date :)
declare function render:HTMLmakeCitationReference($wid as xs:string, $fileDesc as element(tei:fileDesc), $mode as xs:string, $node as element()?) as element(span) {
    let $author := $fileDesc/tei:titleStmt/tei:author/tei:persName/tei:surname/text()
    let $title := $fileDesc/tei:titleStmt/tei:title[@type eq 'short']/text()
    let $digitalYear := substring($fileDesc/tei:publicationStmt/tei:date[@type eq 'digitizedEd']/@when[1]/string(), 1, 4)
    let $originalYear := 
        if ($fileDesc/tei:sourceDesc//tei:date[@type eq 'thisEd']) then
            $fileDesc/tei:sourceDesc//tei:date[@type eq 'thisEd']/@when
        else $fileDesc/tei:sourceDesc//tei:date[@type eq 'firstEd']/@when
    let $editors :=
        string-join(for $ed in $fileDesc/tei:seriesStmt/tei:editor/tei:persName 
                        order by $ed/tei:surname
                        return app:rotateFormatName($ed), ' &amp; ')
    let $link := $fileDesc/tei:publicationStmt//tei:idno[@xml:id eq 'urlid']/text()
    (:let $METDate := adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT1H')) (\: choosing MET as default timezone, rather than client's timezone, for now :\)
    let $date := i18n:convertDate(substring(string($METDate),1,10), $lang, 'verbose')
    let $timezone := 'MET'
    let $accessed :=
        if ($mode = ('reading-full', 'reading-passage')) then
            <span>(<i18n:text key="accessedDate">Accessed</i18n:text>{' ' || $date || ' (' || $timezone || ')'})</span> (\: TODO :\)
        else ():)
    let $passagetrail := 
        if ($mode eq 'reading-passage' and $node) then
            render:getNodetrail($wid, $node, 'passagetrail', ())
        else ()
    let $content := 
        <span class="cite-rec">{$author || ', ' || $title || ' (' || $digitalYear || ' [' || $originalYear || '])'|| ', '}
            <i18n:text key="inLow">in</i18n:text>{': '}<i18n:text key="editionSeries">The School of Salamanca. A Digital Collection of Sources</i18n:text>
            {', '}<i18n:text key="editedByAbbrLow">ed. by</i18n:text>{' ' || $editors || ' <'}<a href="{$link}">{$link}</a>
            {'>' || (if ($passagetrail) then ', ' || $passagetrail else ())}
            <!--{' ' || $accessed}-->
        </span>
        (: TODO: access date after link, not after and passagetrail...  :)
    return $content
};

(:
~ Recursively creates a TOC list (of lists...) for a sequence of nodes.
:)
declare function render:HTMLgenerateTocFromDiv($nodes as element()*, $wid as xs:string) as element(ul)* {
    for $node in $nodes/(tei:div[@type="work_part"]/tei:div[render:isIndexNode(.)]
                         |tei:div[not(@type="work_part")][render:isIndexNode(.)]
                         |*/tei:milestone[@unit ne 'other'][render:isIndexNode(.)]) return
        let $fragTrail := render:getNodetrail($wid, $node, 'citetrail', ())
        let $fragId := $config:idserver || '/texts/' || $wid || ':' || $fragTrail || '?format=html'
        let $section := $node/@xml:id/string()
        let $i18nKey := 
            if (render:dispatch($node, 'class')) then render:dispatch($node, 'class')
            else 'tei-generic'
        let $label := ('[', <i18n:text key="{$i18nKey}"/>, ']')
        let $titleString := render:dispatch($node, 'title')
        let $titleAtt := '[i18n(' || $i18nKey || ')] ' || $titleString
(:        let $titleElems := render:HTMLmakeTOCTitle($node):)
        (: title="{$title}" :)
        return 
            <ul>
                <li>
                    <a class="hideMe" href="{$fragId}" title="{$titleAtt}">
                        {($label, ' ', $titleString)}
                        <span class="jstree-anchor hideMe pull-right">{render:HTMLgetPagesFromDiv($node)}</span>
                    </a>
                    {render:HTMLgenerateTocFromDiv($node, $wid)}
                </li>
            </ul>
};

declare function render:HTMLmakeTOCTitle($node as node()) as item()* {
    let $i18nKey := 
        (: every div or milestone type with a citation label should have an entry in i18n files: :)
        if ($node/self::tei:div) then
            if ($config:citationLabels($node/@type/string())?('full')) then 'tei-div-' || $node/@type 
            else 'tei-generic'
        else if ($node/self::tei:milestone) then
            if ($config:citationLabels($node/@unit/string())?('full')) then 'tei-ms-' || $node/@unit
            else 'tei-generic'
        else ()
    let $divLabel := ('[', <i18n:text key="{$i18nKey}"/>, ']')
    let $titleString := render:dispatch($node, 'title')
    return
        ($divLabel, ' ', $titleString)
};

declare function render:HTMLgetPagesFromDiv($div) {
    let $firstpage :=   
        if ($div[@type='work_volume'] | $div[@type = 'work_monograph']) then ($div//tei:pb[not(@sameAs or @corresp)])[1]/@n/string() 
        else ($div/preceding::tei:pb[not(@sameAs or @corresp)])[last()]/@n/string()
    let $lastpage := if ($div//tei:pb[not(@sameAs or @corresp)]) then ($div//tei:pb[not(@sameAs or @corresp)])[last()]/@n/string() else ()
    return
        if ($firstpage ne '' or $lastpage ne '') then 
            concat(' ', string-join(($firstpage, $lastpage), ' - ')) 
        else ()
};


(:
~ From a given fragment root, searches for ancestors that occur above the fragmentation level and renders them (non-recursively)
    such that they can be re-included into a fragment's HTML.
:)
(: TODO: currently, this merely creates a "Vol. X" teaser at the beginning of volumes - this means that fragmentation depth cannot go below (front|body|back)/* ! :)
declare function render:excludedAncestorHTML($fragmentRoot as element()) {
    (: determine whether fragment is first structural element of volume :)
    if ($fragmentRoot[ancestor-or-self::tei:text[@type eq 'work_volume'] 
                      and not(preceding::*[self::tei:div or self::tei:titlePage] 
                              intersect ancestor-or-self::tei:text[@type eq 'work_volume']//*[self::tei:div or self::tei:titlePage])]) then
        let $delimiter := 
            if ($fragmentRoot/ancestor-or-self::tei:text[@type='work_volume']/preceding::tei:text[@type='work_volume']) then 
                <hr/> 
            else ()
        let $sumTitle := render:makeHTMLSummaryTitle($fragmentRoot/ancestor-or-self::tei:text[@type eq 'work_volume'])
        return ($delimiter, $sumTitle)
    else ()        
    
    (: functionality for generic ancestor teaser creation - needs debugging; what about ancestor headings (tei:head?) (TODO) :)
    (:if (not($fragmentRoot/preceding-sibling::*)) then
        let $ancestorTeasers :=
            for $a in $fragmentRoot/ancestor::*[render:isCitableWithTeaserHTML(.) and not(preceding-sibling::*
                                                                                          or self::tei:text[@type eq 'work_volume'])] return
                render:makeHTMLSummaryTitle($a) (\: TODO: wrong order? :\)
        let $volTeaser :=
            (\: if fragment is first structural element of volume, also make a "Vol." teaser :\)
            if ($fragmentRoot[ancestor-or-self::tei:text[@type eq 'work_volume'] 
                              and not(preceding::*[self::tei:div or self::tei:titlePage] 
                                      intersect ancestor-or-self::tei:text[@type eq 'work_volume']//*[self::tei:div or self::tei:titlePage])]) then
                let $delimiter := 
                    if ($fragmentRoot/ancestor-or-self::tei:text[@type='work_volume']/preceding::tei:text[@type='work_volume']) then 
                        <hr/> 
                    else ()
                let $sumTitle := render:makeHTMLSummaryTitle($fragmentRoot/ancestor-or-self::tei:text[@type eq 'work_volume'])
                return ($delimiter, $sumTitle)
            else ()
        return ($volTeaser, $ancestorTeasers)
    else ():)
};


declare function render:makeHTMLSummaryTitle($node as element()) as element(div) {
    let $toolbox := render:HTMLSectionToolbox($node)
    let $teaser := render:HTMLSectionTeaser($node)
    let $sumTitle :=
        <div class="summary_title">
            {$toolbox}
            {if ($node/self::tei:text[@type='work_volume']) then <b>{$teaser}</b> else $teaser (: make volume teasers bold :)}
        </div>
    return $sumTitle
};


(:
~ Creates a teaser for a certain type of structural element (i.e., certain div, milestone, list[@type='dict'], and item[parent::list/@type='dict'])
:)
declare function render:HTMLSectionTeaser($node as element()) {
    let $identifier := $node/@xml:id/string()
    let $fullTitle := render:dispatch($node, 'html-title')
    return 
        <span class="sal-section-teaser">{
            if (string-length($fullTitle) gt $render:teaserTruncLimit) then
                (<a data-toggle="collapse" data-target="{('#restOfString' || $identifier)}">
                    {substring($fullTitle,1,$render:teaserTruncLimit) || '…'} 
                    <i class="fa fa-angle-double-down"/>
                </a>,
                <span class="collapse" id="{('restOfString' || $identifier)}">
                    {$fullTitle}
                </span>)
            else $fullTitle
            
        }</span>
        
};

declare function render:HTMLSectionToolbox($node as element()) as element(div) {
    let $id := $node/@xml:id/string()
    let $class := 
        if (render:isHTMLMarginal($node)) then 
            'sal-toolbox-marginal' 
        (:else if (render:isCitableWithTeaserHTML($node)) then
            'sal-toolbox-teaser':)
        else 'sal-toolbox'
    return
        <div class="{$class}">
            <a id="{$id}" href="{('#' || $id)}" data-rel="popover">
                <i class="fas fa-link messengers" title="i18n(openToolbox)"/>
            </a>
            <div class="sal-toolbox-body">
                <a class="sal-tb-btn" href="{render:makeCitetrailURI($node)}">
                    <span class="messengers fas fa-link" title="i18n(linkPass)"/>
                </a>
                <div class="sal-tb-btn dropdown">
                    <button type="button" class="btn btn-link dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        <span class="messengers fas fa-feather-alt" title="i18n(citePass)"/>
                    </button>
                    <span class="dropdown-menu">
                        <span class="sal-cite-toggle">
                            <span style="font-weight:bold;">Proposed citation:</span><br/>
                            <input type="text" value="abc def ghi" class="sal-cite-text"></input>
                            <button onclick="citeToggle(this);">Copy</button>
                        </span>
                    </span>
                </div>
                <a class="sal-tb-btn updateHiliteBox" href="#" style="display:none;"> 
                    <span class="glyphicon glyphicon-refresh"/>
                </a>
            </div>
        </div>
(:    
    Further buttons:
    - <span class="glyphicon glyphicon-print text-muted"/> 
:)
};

declare function render:makePassagetrailBox($node as element()) {
    ()
};

(:
~ For a node, make a full-blown URI including the citetrail of the node
:)
declare function render:makeCitetrailURI($node as element()) {
    let $citetrail := render:getNodetrail($node/ancestor::tei:TEI, $node, 'citetrail', ())
    let $workId := $node/ancestor::tei:TEI/@xml:id
    return
        $config:idserver || '/texts/' || $workId || ':' || $citetrail
};


declare function render:classableString($str as xs:string) as xs:string? {
    replace($str, '[,: ]', '')
};

(: ####====---- End Helper Functions ----====#### :)




(: ####====---- RENDERING FUNCTIONS ----====#### :)

(: #### HTML Util Functions ####:)

declare function render:createHTMLFragment($workId as xs:string, $fragmentRoot as element(), $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) as element(div) {
    (:let $serializationParams :=
        <output:serialization-parameters>
            <output:method value="html"/>
            <output:indent value="no"/>
        </output:serialization-parameters>
    
    let $fragment :=:)
        (: SvSalPage: main area (id/class page in order to identify page-able content :)
        <div class="row" xml:space="preserve">
            <div class="col-md-12">
                <div id="SvSalPages">
                    <div class="SvSalPage">                
                        {
                        if ($fragmentRoot[not(preceding-sibling::*) and not((ancestor::body|ancestor::back) and preceding::front/*)]) then
                            render:excludedAncestorHTML($fragmentRoot)
                        else ()    
                        }
                        {render:dispatch($fragmentRoot, 'html')}
                    </div>
                </div>
            </div>
            {render:createPaginationLinks($workId, $fragmentIndex, $prevId, $nextId) (: finally, add pagination links :)}
        </div>
        (: the rest (to the right, in col-md-12) is filled by _spans_ of class marginal, possessing
             a negative right margin (this happens in eXist's work.html template) :)
    (:return 
        serialize($fragment, $serializationParams):)
};

declare function render:makeFragmentId($index as xs:integer, $xmlId as xs:string) as xs:string {
    format-number($index, '0000') || '_' || $xmlId
};

declare function render:createPaginationLinks($workId as xs:string, $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) {
    let $prevLink :=
        if ($prevId) then
            let $link := 'work.html?wid=' || $workId || '&amp;frag=' || render:makeFragmentId($fragmentIndex - 1, $prevId)
            return
                (<a class="previous" href="{$link}">prev</a>, ' | ')
        else ()
    let $top := <a class="top" href="work.html?wid={$workId}">top</a>
    let $nextLink :=
        if ($nextId) then
            let $link := 'work.html?wid=' || $workId || '&amp;frag=' || render:makeFragmentId($fragmentIndex + 1, $nextId)
            return 
                (' | ', <a class="next" href="{$link}">next</a>)
        else ()
    return
        <div id="SvSalPagination">
            {($prevLink, $top, $nextLink)}
        </div>
};

(:
~ Determines the type of list in which an element (item, list, head, ...) occurs.
:)
declare function render:determineListType($node as element()) as xs:string? {
    if ($node[self::tei:list and @type]) then $node/@type
    else if ($node/ancestor::tei:list[@type]) then $node/ancestor::tei:list[@type][1]/@type
    else () (: fall back to simple? :)
};


declare function render:resolveCanvasID($pb as element(tei:pb)) as xs:string {
    let $facs := normalize-space($pb/@facs/string())
    return
        if (matches($facs, '^facs:W[0-9]{4}-[A-z]-[0-9]{4}$')) then 
            let $index := string(count($pb/preceding::tei:pb[not(@sameAs) and substring(@facs, 1, 12) eq substring($facs, 1, 12)]) + 1)
            return $config:imageserver || '/iiif/presentation/' || sal-util:convertVolumeID(substring($facs,6,7)) || '/canvas/p' || $index
        else if (matches($facs, '^facs:W[0-9]{4}-[0-9]{4}$')) then
            let $index := string(count($pb/preceding::tei:pb[not(@sameAs)]) + 1)
            return $config:imageserver || '/iiif/presentation/' || substring($facs,6,5) || '/canvas/p' || $index
        else error(xs:QName('render:resolveCanvasID'), 'Unknown pb/@facs value')
};


declare function render:resolveFacsURI($facsTargets as xs:string) as xs:string {
    let $facs := (tokenize($facsTargets, ' '))[1]
    let $iiifRenderParams := '/full/full/0/default.jpg'
    let $singleVolRegex := 'facs:(W[0-9]{4})\-([0-9]{4})'
    let $multiVolRegex := 'facs:(W[0-9]{4})\-([A-z])\-([0-9]{4})'
    return
        if (matches($facs, $singleVolRegex)) then (: single-volume work, e.g.: facs:W0017-0005 :)
            let $workId := replace($facs, $singleVolRegex, '$1')
            let $facsId := replace($facs, $singleVolRegex, '$2')
            return 
                $config:imageserver || '/iiif/image/' || $workId || '!' || $workId || '-' || $facsId || $iiifRenderParams
        else if (matches($facs, $multiVolRegex)) then (: volume of a multi-volume work, e.g.: facs:W0013-A-0007 :)
            let $workId := replace($facs, $multiVolRegex, '$1')
            let $volId := replace($facs, $multiVolRegex, '$2')
            let $facsId := replace($facs, $multiVolRegex, '$3')
            return $config:imageserver || '/iiif/image/' || $workId || '!' || $volId || '!' || $workId 
                        || '-' || $volId || '-' || $facsId || $iiifRenderParams
        else error(xs:QName('render:pb'), 'Illegal facs ID (pb/@facs): ' || $facs)
};

(:
~ Renders a marginal element (currently all tei:note as well as label[@place eq 'margin']; head[@place eq 'margin'] are treated as ordinary head)
:)
declare function render:makeMarginalHTML($node as element()) as element(div) {
    let $label := if ($node/@n) then <span class="note-label">{$node/@n || ' '}</span> else ()
    let $content :=
        if ($node/tei:p) then 
            render:passthru($node, 'html')
        else
            <span class="note-paragraph">{render:passthru($node, 'html')}</span>
    (: determine string-length of complete note text, so as to see whether note needs to be truncated: :)
    let $noteLength := 
        string-length((if ($label) then $node/@n || ' ' else ()) || normalize-space(string-join(render:dispatch($node, 'edit'), '')))
    let $toolbox := render:HTMLSectionToolbox($node)
    return
        <div class="marginal container" id="{$node/@xml:id}">
            {$toolbox}
            <div class="marginal-body">{
                if ($noteLength gt $render:noteTruncLimit) then
                    let $id := 'collapse-' || $node/@xml:id
                    return
                        <a role="button" class="collapsed note-teaser" data-toggle="collapse" href="{('#' || $id)}" 
                           aria-expanded="false" aria-controls="{$id}">    
                            <p class="collapse" id="{$id}" aria-expanded="false">
                                {$label}
                                {' '}
                                {$content}
                            </p>
                        </a>
                else 
                    $content
            }</div>
        </div>
};


(:
~ Transforms a $node into an HTML link anchor (a[@href]), dispatching all its content ((render:dispatch())) and, if required,
    preventing tei:pb from occurring within the link.
:)
declare function render:transformToHTMLLink($node as element(), $uri as xs:string) {
    if (not($node/tei:pb)) then
        <a href="{$uri}" target="_blank">{render:passthru($node, 'html')}</a>
    else
        (: make an anchor for the preceding part, then render the pb, then "continue" the anchor :)
        (: TODO: ATM, this works only if pb occurs at the direct child level, and only with the first pb :)
        let $before :=
            <a href="{$uri}" target="_blank">
                {for $n in $node/tei:pb[1]/preceding-sibling::node() return render:dispatch($n, 'html')}
            </a>
        let $break := render:dispatch($node/tei:pb[1], 'html')
        let $after :=
            <a href="{$uri}" target="_blank">
                {for $n in $node/tei:pb[1]/following-sibling::node() return render:dispatch($n, 'html')}
            </a>
        return
            ($before, $break, $after)
};

(: TODO: render:makeCitetrailURI() requires actual node :)
declare function render:resolveURI($node as element(), $targets as xs:string) {
    let $currentWork := $node/ancestor-or-self::tei:TEI
    let $target := (tokenize($targets, ' '))[1]
    let $prefixDef := $currentWork//tei:prefixDef
    let $workScheme := '(work:(W[A-z0-9.:_\-]+))?#(.*)'
    let $facsScheme := 'facs:((W[0-9]+)[A-z0-9.:#_\-]+)'
    let $genericScheme := '(\S+):([A-z0-9.:#_\-]+)'
    return
        if (starts-with($target, '#') and $currentWork//*[@xml:id eq substring($target, 2)]) then
            (: target is some node within the current work :)
            render:makeCitetrailURI($currentWork//*[@xml:id eq substring($target, 2)])
        else if (matches($target, $workScheme)) then
            (: target is something like "work:W...#..." :)
            let $targetWorkId :=
                if (replace($target, $workScheme, '$2')) then (: Target is a link containing a work id :)
                    replace($target, $workScheme, '$2')
                else $currentWork/@xml:id/string() (: Target is just a link to a fragment anchor, so targetWorkId = currentWork :)
            let $anchorId := replace($target, $workScheme, '$3')
            return 
                if ($anchorId) then render:makeCitetrailURI($node) else ()
        else if (matches($target, $facsScheme)) then (: Target is a facs string :)
            (: Target does not contain "#", or is not a "work:..." url: :)
            let $targetWorkId :=
                if (replace($target, $facsScheme, '$2')) then (: extract work id from facs string :)
                    replace($target, $facsScheme, '$2')
                else $currentWork/@xml:id/string()
            let $anchorId := replace($target, $facsScheme, '$1') (: extract facs string :)
            return
                render:makeCitetrailURI($node)
        else if (matches($target, $genericScheme)) then 
            (: Use the general replacement mechanism as defined by the prefixDef in works-general.xml: :)
            let $prefix := replace($target, $genericScheme, '$1')
            let $value := replace($target, $genericScheme, '$2')
            return 
                if ($prefixDef[@ident eq $prefix]) then
                    for $p in $prefixDef[@ident eq $prefix][matches($value, @matchPattern)] return
                        replace($value, $p/@matchPattern, $p/@replacementPattern)
                else replace($target, $genericScheme, '$0') (: regex-group(0) :)
        else $target    
};    


declare function render:isHTMLMarginal($node as node()) as xs:boolean {
    boolean($node[(self::tei:note or self::tei:label) and @place eq 'margin'])
};

declare function render:isHTMLHeading($node as node()) as xs:boolean {
    boolean($node[self::tei:head])
};



(: ####====---- TEI Node Rendering Typeswitch Functions ----====#### :)

(:  MODES: 
~   - 'orig', 'edit': plain text
~   - 'snippets-orig', 'snippets-edit': plain text for Sphinx snippets
~   - 'title': title of a node (only for nodes that represent sections)
~   - 'passagetrail': passagetrail ID of a node (only for nodes that represent passagetrail sections)
~   - 'citetrail': citetrail ID of a node (only for nodes that represent citetrail/crumbtrail sections)
~   - 'crumbtrail': crumbtrail ID of a node (only for nodes that represent citetrail/crumbtrail sections)
~   - 'class': i18n class of a node, usually to be used by HTML-/RDF-related functionalities for generating verbose labels when displaying section titles 
~   - 'html': HTML snippet for the reading view
~   - 'html-title': a full version of the title, for toggling of teasers in the reading view (often simply falls back to 'title', see above)
:)

(: $mode can be "orig", "edit" (both being plain text modes), "html" or, even more sophisticated, "work" :)
declare function render:dispatch($node as node(), $mode as xs:string) {
    let $rendering :=
        typeswitch($node)
        (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
            case text()                     return render:textNode($node, $mode)
            case element(tei:g)             return render:g($node, $mode)
            case element(tei:lb)            return render:lb($node, $mode)
            case element(tei:pb)            return render:pb($node, $mode)
            case element(tei:cb)            return render:cb($node, $mode)
    
            case element(tei:head)          return render:head($node, $mode) (: snippets: passthru :)
            case element(tei:p)             return render:p($node, $mode)
            case element(tei:note)          return render:note($node, $mode)
            case element(tei:div)           return render:div($node, $mode)
            case element(tei:milestone)     return render:milestone($node, $mode)
            
            case element(tei:choice)        return render:choice($node, $mode)
            case element(tei:abbr)          return render:abbr($node, $mode)
            case element(tei:orig)          return render:orig($node, $mode)
            case element(tei:sic)           return render:sic($node, $mode)
            case element(tei:expan)         return render:expan($node, $mode)
            case element(tei:reg)           return render:reg($node, $mode)
            case element(tei:corr)          return render:corr($node, $mode)
            
            case element(tei:persName)      return render:persName($node, $mode)
            case element(tei:placeName)     return render:placeName($node, $mode)
            case element(tei:docAuthor)     return render:docAuthor($node, $mode)
            case element(tei:orgName)       return render:orgName($node, $mode)
            case element(tei:pubPlace)      return render:pubPlace($node, $mode)
            case element(tei:publisher)     return render:publisher($node, $mode)
            case element(tei:title)         return render:title($node, $mode)
            case element(tei:term)          return render:term($node, $mode)
            case element(tei:bibl)          return render:bibl($node, $mode)
    
            case element(tei:hi)            return render:hi($node, $mode) 
            case element(tei:emph)          return render:emph($node, $mode)
            case element(tei:ref)           return render:ref($node, $mode) 
            case element(tei:quote)         return render:quote($node, $mode)
            case element(tei:soCalled)      return render:soCalled($node, $mode)
    
            case element(tei:list)          return render:list($node, $mode)
            case element(tei:item)          return render:item($node, $mode)
            case element(tei:gloss)         return render:gloss($node, $mode)
            case element(tei:eg)            return render:eg($node, $mode)
    
            case element(tei:birth)         return render:birth($node, $mode) 
            case element(tei:death)         return render:death($node, $mode)
    
            case element(tei:lg)            return render:lg($node, $mode)
            case element(tei:l)             return render:l($node, $mode)
            
            case element(tei:signed)        return render:signed($node, $mode) 
            
            case element(tei:titlePage)     return render:titlePage($node, $mode)
            case element(tei:titlePart)     return render:titlePart($node, $mode)
            case element(tei:docTitle)      return render:docTitle($node, $mode)
            case element(tei:docDate)       return render:docDate($node, $mode)
            case element(tei:byline)        return render:byline($node, $mode)
            case element(tei:imprimatur)    return render:imprimatur($node, $mode)
            case element(tei:docImprint)    return render:docImprint($node, $mode)
            
            case element(tei:label)         return render:label($node, $mode)
            case element(tei:argument)      return render:argument($node, $mode)
            
            case element(tei:damage)        return render:damage($node, $mode)
            case element(tei:gap)           return render:gap($node, $mode)
            case element(tei:supplied)      return render:supplied($node, $mode)
            case element(tei:unclear)       return render:unclear($node, $mode)
            case element(tei:del)           return render:del($node, $mode)
            case element(tei:space)         return render:space($node, $mode)
            
            case element(tei:figure)        return render:figure($node, $mode)
            
            case element(tei:text)          return render:text($node, $mode) 
            case element(tei:front)         return render:front($node, $mode) 
            case element(tei:body)          return render:body($node, $mode)
            case element(tei:back)          return render:back($node, $mode)
    
            case element(tei:table)         return render:table($node, $mode)
            case element(tei:row)           return render:row($node, $mode)
            case element(tei:cell)          return render:cell($node, $mode)
            
            case element(tei:foreign)       return render:foreign($node, $mode)
            case element(tei:date)          return render:date($node, $mode)
            case element(tei:cit)           return render:cit($node, $mode)
            case element(tei:author)        return render:author($node, $mode)
            case element(tei:docEdition)    return render:docEdition($node, $mode)
            
            case element(tei:TEI)           return render:passthru($node, $mode)
            case element(tei:group)         return render:passthru($node, $mode)
            
            case element(tei:figDesc)       return ()
            case element(tei:teiHeader)     return ()
            case element(tei:fw)            return ()
            case element()                  return error(xs:QName('render:dispatch'), 'Unkown element: ' || local-name($node) || '.')
            case comment()                  return ()
            case processing-instruction()   return ()
    
            default return render:passthru($node, $mode)
    return
        if ($mode eq 'html' and render:isCitableWithTeaserHTML($node)) then
            let $citationAnchor := render:makeHTMLSummaryTitle($node)
            let $debug := if ($config:debug = ("trace", "info")) then util:log('warn', 'Processing *[render:isCitableWithTeaserHTML(.)], local-name(): ' || local-name($node) || ', xml:id: ' || $node/@xml:id) else ()
            return ($citationAnchor, $rendering)
        else if ($mode eq 'html' and render:isBasicCitableHTML($node)) then 
            (: toolboxes need to be on the sibling axis with the text body they refer to... :)
            if (render:isHTMLMarginal($node) or render:isHTMLHeading($node) or $node/self::tei:titlePage) then 
                $rendering
            else 
                let $toolbox := render:HTMLSectionToolbox($node)
                return
                    <div class="hauptText">
                        {$toolbox}
                        <div class="hauptText-body">{$rendering}</div>
                    </div>
        else 
            $rendering
};



(: ####++++ Element functions (ordered alphabetically) ++++#### :)


declare function render:abbr($node as element(tei:abbr), $mode) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
            
        case 'snippets-edit' return
            if (not($node/preceding-sibling::tei:expan|$node/following-sibling::tei:expan)) then
                render:passthru($node, $mode)
            else ()
            
        case 'class' return ()
        
        default return
            render:origElem($node, $mode)
};


declare function render:argument($node as element(tei:argument), $mode as xs:string) {
    switch($mode)
        case 'class' return 
            'tei-' || local-name($node)
        
        default return
            render:passthru($node, $mode)
};


declare function render:author($node as element(tei:author), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:back($node as element(tei:back), $mode as xs:string) {
    switch($mode)
        case 'title' return
            ()
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            'backmatter'
            
        case 'passagetrail' return
            $config:citationLabels(local-name($node))?('abbr')
        
        default return
            render:passthru($node, $mode)
};

declare function render:bibl($node as element(tei:bibl), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'snippets-orig' return
            render:passthru($node, $mode)
            
        case 'edit' return
            if ($node/@sortKey) then
                (render:passthru($node, $mode), ' [', replace(string($node/@sortKey), '_', ', '), ']')
            else
                render:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@sortKey) then
                replace(string($node/@sortKey), '_', ', ')
            else
                render:passthru($node, $mode)
        
        case 'html' return
            if ($node/@sortKey) then 
                <span class="{local-name($node) || ' hi_', render:classableString($node/@sortKey)}">{render:passthru($node, $mode)}</span>
            else <span>{render:passthru($node, $mode)}</span>
        
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:birth($node as element(tei:birth), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else ()
};


declare function render:body($node as element(tei:body), $mode as xs:string) {
    switch($mode)
        case 'class' return
            'tei-' || local-name($node)
        
        default return
            render:passthru($node, $mode) 
};

declare function render:byline($node as element(tei:byline), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="tp-paragraph">
                {render:passthru($node, $mode)}
            </span>
        
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};

declare function render:cb($node as element(tei:cb), $mode as xs:string) {
    switch($mode)
        case 'orig' 
        case 'edit'
        case 'snippets-orig'
        case 'snippets-edit' 
        case 'html' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        case 'class' return ()
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render:cell($node as element(tei:cell), $mode) {
    switch($mode)
        case 'html' return 
            if ($node/@role eq 'label') then 
                <td class="table-label">{render:passthru($node, $mode)}</td>
            else <td>{render:passthru($node, $mode)}</td>
        
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:choice($node as element(tei:choice), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (: HTML: Editorial interventions: Don't hide original stuff where we have no modern alternative, otherwise
             put it in an "orignal" class span which we make invisible by default.
             Put our own edits in spans of class "edited" and add another class to indicate what type of edit has happened :)
            render:passthru($node, $mode)
        
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:cit($node as element(tei:cit), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:corr($node as element(tei:corr), $mode) {
    switch($mode)
        case 'snippets-orig' return 
            ()
            
        case 'snippets-edit' return
            render:passthru($node, $mode)
        
        default return
            render:editElem($node, $mode)
};


declare function render:damage($node as element(tei:damage), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:date($node as element(tei:date), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};


declare function render:death($node as element(tei:death), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else ()
};


declare function render:del($node as element(tei:del), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/tei:supplied) then
                render:passthru($node, $mode)
            else error(xs:QName('render:del'), 'Unexpected content in tei:del')
        
        default return 
            render:passthru($node, $mode)
};


declare function render:div($node as element(tei:div), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    string($node/@n)
                else if ($node/(tei:head|tei:label)) then
                    render:teaserString(($node/(tei:head|tei:label))[1], 'edit')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@type)) then
                    string($node/@n)
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    render:teaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
        
        case 'html-title' return
            if (not($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) and $node/(tei:head|tei:label)) then
                (: for expanded titles, we need the full version, not just the teaser :)
                normalize-space(string-join(render:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''))
            else render:div($node, 'title')
        
        case 'html' return
            render:passthru($node, $mode)
        
        case 'class' return
            'tei-div-' || $node/@type
        
        case 'citetrail' return
            if (render:isNamedCitetrailNode($node)) then
                (: use abbreviated form of @type (without dot), possibly followed by position :)
                (: TODO: div label experiment (delete the following block if this isn't deemed plausible) :)
                let $abbr := $config:citationLabels($node/@type)?('abbr')
                let $prefix :=
                    if ($abbr) then 
                        lower-case(if (contains($abbr, '.')) then substring-before($config:citationLabels($node/@type)?('abbr'), '.') else $abbr)
                    else 'div' (: divs for which we haven't defined an abbr. :)
                let $position :=
                    if (count($node/parent::*[self::tei:body or render:isIndexNode(.)]/tei:div[$config:citationLabels(@type)?('abbr') eq $config:citationLabels($node/@type)?('abbr')]) gt 1) then
                        string(count($node/preceding-sibling::tei:div[$config:citationLabels(@type)?('abbr') eq $config:citationLabels($node/@type)?('abbr')]) + 1)
                    else ()
                return $prefix || $position
            else if (render:isUnnamedCitetrailNode($node)) then 
                string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
            else ()
        
        case 'passagetrail' return
            if (render:isPassagetrailNode($node)) then
                let $prefix := lower-case($config:citationLabels($node/@type)?('abbr')) (: TODO: upper-casing with first element of passagetrail ? :)
                return 
                    if ($node/@type = ('lecture', 'gloss')) then (: TODO: 'lemma'? :)
                        (: special cases: with these types, we provide a short teaser string instead of a numeric value :)
                        let $teaser := '"' || normalize-space(substring(substring-after(render:div($node, 'title'), '"'),1,15)) || '…"'
                        return $prefix || ' ' || $teaser
                    else
                        let $position := 
                            if ($node/@n[matches(., '^[0-9\[\]]+$')]) then $node/@n (:replace($node/@n, '[\[\]]', '') ? :)
                            else if ($node/ancestor::*[render:isPassagetrailNode(.)]) then
                                (: using the none-copy version here for sparing memory: :)
                                if (count($node/ancestor::*[render:isPassagetrailNode(.)][1]//tei:div[@type eq $node/@type and render:isPassagetrailNode(.)]) gt 1) then 
                                    string(count($node/ancestor::*[render:isPassagetrailNode(.)][1]//tei:div[@type eq $node/@type and render:isPassagetrailNode(.)]
                                                 intersect $node/preceding::tei:div[@type eq $node/@type and render:isPassagetrailNode(.)]) + 1)
                                else ()
                            else if (count($node/parent::*/tei:div[@type eq $node/@type]) gt 1) then 
                                string(count($node/preceding-sibling::tei:div[@type eq $node/@type]) + 1)
                            else ()
                        return
                            $prefix || (if ($position) then ' ' || $position else ())
            else ()
        
        case 'orig' return
             ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case 'edit' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                (concat($config:nl, '[ *', string($node/@n), '* ]'), $config:nl, render:passthru($node, $mode), $config:nl)
                (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case 'snippets-orig' return 
            render:passthru($node, $mode)
            
        case 'snippets-edit' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                concat(' ', string($node/@n), ' ', render:passthru($node, $mode))
                (: or this?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else render:passthru($node, $mode)
        
        default return
            render:passthru($node, $mode)
};

declare function render:docAuthor($node as element(tei:docAuthor), $mode as xs:string) {
    switch($mode)
        case 'html' return
            render:name($node, $mode)
        default return 
            render:passthru($node, $mode)
};

declare function render:docDate($node as element(tei:docDate), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};

declare function render:docEdition($node as element(tei:docEdition), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};

declare function render:docImprint($node as element(tei:docImprint), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="tp-paragraph">
                {render:passthru($node, $mode)}
            </span>
        default return
            render:passthru($node, $mode)
};

declare function render:docTitle($node as element(tei:docTitle), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};

declare function render:editElem($node as element(), $mode as xs:string) {
    switch($mode)
        case "orig" return ()
        case "edit" return
            render:passthru($node, $mode)
            
        case 'html' return
            let $origString := string-join(render:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), 'orig'), '')
            return
                <span class="messengers edited {local-name($node)}" title="{$origString}">
                    {string-join(render:passthru($node, $mode), '')}
                </span>
        
        default return
            render:passthru($node, $mode)
};

declare function render:eg($node as element(tei:eg), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else 
        render:passthru($node, $mode)
};


declare function render:emph($node as element(tei:emph), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    
    else
        render:passthru($node, $mode)
};


declare function render:expan($node as element(tei:expan), $mode) {
    switch($mode)
        case 'snippets-orig' return 
            ()
        case 'snippets-edit' return
            render:passthru($node, $mode)
        default return
            render:editElem($node, $mode)
};


declare function render:figure($node as element(tei:figure), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@type eq 'ornament') then
                <hr class="ornament"/>
            else ()
            
        default return ()
};


declare function render:foreign($node as element(tei:foreign), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="foreign-lang">{render:passthru($node, $mode)}</span>
            
        default return 
            render:passthru($node, $mode)
};


declare function render:front($node as element(tei:front), $mode as xs:string) {
    switch ($mode)
        case 'title' return
            ()
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            'frontmatter'
            
        case 'passagetrail' return
            $config:citationLabels(local-name($node))?('abbr')
            
        default return
            render:passthru($node, $mode)
};


declare function render:g($node as element(tei:g), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'snippets-orig' return
            let $glyph := $node/ancestor::tei:TEI/tei:teiHeader/tei:encodingDesc/tei:charDecl/tei:char[@xml:id = substring(string($node/@ref), 2)] (: remove leading '#' :)
            return if ($glyph/tei:mapping[@type = 'precomposed']) then
                    string($glyph/tei:mapping[@type = 'precomposed'])
                else if ($glyph/tei:mapping[@type = 'composed']) then
                    string($glyph/tei:mapping[@type = 'composed'])
                else if ($glyph/tei:mapping[@type = 'standardized']) then
                    string($glyph/tei:mapping[@type = 'standardized'])
                else
                    render:passthru($node, $mode)
        
        case 'edit' return
            let $glyph := $node/ancestor::tei:TEI//tei:char[@xml:id = substring(string($node/@ref), 2)]
            return
                if ($glyph/tei:mapping[@type = 'standardized']) then
                    string($glyph/tei:mapping[@type = 'standardized'])
                else
                    render:passthru($node, $mode)
        
        case 'html' return
            let $thisString := 
                if ($node/text()) then 
                    xs:string($node/text())
                else error(xs:QName('render:g'), 'Found tei:g without text content') (: ensure correct character markup :)
            let $charCode := substring($node/@ref,2)
            let $char := $node/ancestor::tei:TEI/tei:teiHeader/tei:encodingDesc/tei:charDecl/tei:char[@xml:id eq $charCode]
            let $test := (: make sure that the char reference is correct :)
                if (not($char)) then 
                    error(xs:QName('render:g'), 'g/@ref is invalid, the char code does not exist): ', $charCode)
                else ()
            let $precomposedString := 
                if ($char/tei:mapping[@type='precomposed']/text()) then 
                    string($char/tei:mapping[@type='precomposed']/text())
                else ()
            let $composedString := 
                if ($char/tei:mapping[@type='composed']/text()) then
                    string($char/tei:mapping[@type='composed']/text())
                else ()
            let $originalGlyph := if ($composedString) then $composedString else $precomposedString
                (: composed strings are preferable since some precomposed chars are displayed oddly in certain contexts 
                    (e.g. chare0303 in bold headings) :)
            return 
                (: Depending on the context or content of the g element, there are several possible cases: :)
                (: 1. if g occurs within choice, we can simply take an original character since any expansion should be handled through the choice mechanism :)
                if ($node/ancestor::tei:choice) then
                    $originalGlyph
                (: 2. g occurs outside of choice: :)
                else
                    let $test := 
                        if (string-length($originalGlyph) eq 0) then 
                            error(xs:QName('render:g'), 'No correct mapping available for char: ', $node/@ref)
                        else ()
                    return
                        (: a) g has been used for resolving abbreviations (in early texts W0004, W0013 and W0015) -> treat it like choice elements :)
                        (:if (not(($precomposedString and $thisString eq $precomposedString) or ($composedString and $thisString eq $composedString))
                            and not($charCode = ('char017f', 'char0292'))):)
                        if (not($thisString = ($precomposedString, $composedString)) and not($charCode = ('char017f', 'char0292'))) then
                            (<span class="original glyph unsichtbar" title="{$thisString}">{$originalGlyph}</span>,
                            <span class="edited glyph" title="{$originalGlyph}">{$thisString}</span>)
                        (: b) most common case: g simply marks a special character -> pass it through (except for the very frequent "long s" and "long z", 
                                which are to be normalized :)
                        else if ($charCode = ('char017f', 'char0292')) then
                            (: long s and z shall be switchable in constituted mode to their standardized versions, but due to their high frequency 
                            we refrain from colourful highlighting (.simple-char). In case colour highlighting is desirable, simply remove .simple-char :)
                            let $standardizedGlyph := string($char/tei:mapping[@type='standardized']/text())
                            return 
                                (<span class="original glyph unsichtbar simple-char" title="{$standardizedGlyph}">{$originalGlyph}</span>,
                                <span class="edited glyph simple-char" title="{$originalGlyph}">{$standardizedGlyph}</span>)
                        else 
                            (: all other simple characters :)
                            render:passthru($node, $mode)
                        
        default return (: also 'snippets-edit' :)
            render:passthru($node, $mode)
};


declare function render:gap($node as element(tei:gap), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/ancestor::tei:damage) then
                <span title="?" class="gap"/>
            else ()
        default return ()
};


declare function render:gloss($node as element(tei:gloss), $mode as xs:string) {
    switch($mode)
        case 'class' return ()
        
        default return
            render:passthru($node, $mode)
};

(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function render:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
        case 'html-title' return
            normalize-space(string-join(render:dispatch($node, 'edit')))
        
        case 'html' return
            (: list[not(@type eq 'dict')]/head are handled in render:list() :)
            if ($node/parent::tei:list[not(@type eq 'dict')]) then 
                () 
            (: within notes: :)
            else if ($node/parent::tei:lg) then 
                <h5 class="poem-head">{render:passthru($node, $mode)}</h5>
            (: usual headings: :)
            else 
                let $toolbox := render:HTMLSectionToolbox($node)
                return
                    <h3>
                        {$toolbox}
                        <span class="heading-text">{render:passthru($node, $mode)}</span>
                    </h3>
            
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            'heading' ||
            (if (count($node/parent::*/tei:head) gt 1) then          
                (: we have several headings on this level of the document ... :)
                string(count($node/preceding-sibling::tei:head) + 1)
             else ())
        
        case 'orig'
        case 'edit' return
            (render:passthru($node, $mode), $config:nl)
        
        default return 
            render:passthru($node, $mode)
};

declare function render:hi($node as element(tei:hi), $mode as xs:string) {
    switch($mode)
        case "orig"
        case "edit" return
            render:passthru($node, $mode)
            
        case 'html' return
            let $styles := distinct-values(tokenize($node/@rendition, ' '))
            (: names of elements that have their own, specific text alignment 
                (where hi/@rendition alignment is to be omitted) :)
            let $specificAlignElems := ('head', 'signed', 'titlePage') (: TODO: add more names here when necessary :)
            let $cssStyles := 
                for $s in $styles return
                    if ($s eq '#b') then 'font-weight:bold;'
                    else if ($s eq '#it') then 'font-style:italic;'
                    else if ($s eq '#rt') then 'font-style: normal;'
                    else if ($s eq '#l-indent') then 'display:block;margin-left:4em;'
                    (: centering and right-alignment apply only in certain contexts :)
                    else if ($s eq '#r-center'
                             and not($node/ancestor::*[local-name(.) = $specificAlignElems])
                             and not($node/ancestor::*[local-name(.) = $render:basicElemNames][1]//text()[not(ancestor::tei:hi[contains(@rendition, '#r-center')])])
                         ) then
                             (: workaround for suppressing trailing centerings at the end of paragraphs :)
                         'display:block;text-align:center;'
                    else if ($s eq '#right' 
                             and not($node/ancestor::*[local-name(.) = $specificAlignElems])
                             and not($node/ancestor::tei:item)) then 
                        'display:block;text-align: right;'
                    else if ($s eq '#sc') then 'font-variant:small-caps;'
                    else if ($s eq '#spc') then 'letter-spacing:2px;'
                    else if ($s eq '#sub') then 'vertical-align:sub;font-size:.83em;'
                    else if ($s eq '#sup') then 'vertical-align:super;font-size: .83em;'
                    else ()
            let $classnames := if ('#initCaps' = $styles) then 'initialCaps' else ()
            return
                element {'span'} {
                    if (string-join($cssStyles, ' ')) then attribute {'style'} {string-join($cssStyles, ' ')} else (),
                    if (string-join($classnames, ' ')) then attribute {'class'} {string-join($classnames, ' ')} else (),
                    render:passthru($node, $mode)
                }
            
        default return 
            render:passthru($node, $mode)
};

declare function render:imprimatur($node as element(tei:imprimatur), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="tp-paragraph">
                {render:passthru($node, $mode)}
            </span>
        default return
            render:passthru($node, $mode)
};

declare function render:item($node as element(tei:item), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/parent::tei:list/@type='dict' and $node//tei:term[1][@key]) then
                    (: TODO: collision with div/@type='lemma'? :)
                    let $positionStr := 
                        if (count($node/parent::tei:list/tei:item[.//tei:term[1]/@key eq $node//tei:term[1]/@key]) gt 1) then
                             ' - ' || 
                             string(count($node/preceding::tei:item[tei:term[1]/@key eq $node//tei:term[1]/@key] 
                                          intersect $node/ancestor::tei:div[1]//tei:item[tei:term[1]/@key eq $node//tei:term[1]/@key]) + 1)
                        else ()
                    return
                        '"' || $node//tei:term[1]/@key || $positionStr || '"'
                else if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                else if ($node/(tei:head|tei:label)) then
                    render:teaserString(($node/(tei:head|tei:label))[1], 'edit')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$'))) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    render:teaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
        
        case 'html-title' return
            if (not($node/parent::tei:list/@type='dict' and $node//tei:term[1][@key])
                and not($node/@n and not(matches($node/@n, '^[0-9\[\]]+$')))
                and $node/(tei:head|tei:label)) 
                then normalize-space(string-join(render:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''))
            else render:dispatch($node, 'title')
                
        case 'html' return
            (: tei:item should be handled exclusively in render:list :)
            error()
            (:switch(render:determineListType($node))
                case 'simple' return
                    (' ', render:passthru($node, $mode), ' ')
                case 'index' 
                case 'summaries' return
                    <li class="list-index-item">{render:passthru($node, $mode)}</li>
                default return
                    <li>{render:passthru($node, $mode)}</li>:)
                
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            (: "entryX" where X is the section title (render:item($node, 'title')) in capitals, use only for items in indexes and dictionary :)
            if($node/ancestor::tei:list/@type = ('dict', 'index')) then
                let $title := upper-case(replace(render:item($node, 'title'), '[^a-zA-Z0-9]', ''))
                let $position :=
                    if ($title) then
                        let $siblings := $node/parent::tei:list/tei:item[upper-case(replace(render:item(., 'title'), '[^a-zA-Z0-9]', '')) eq $title]
                        return
                            if (count($siblings) gt 0) then 
                                string(count($node/preceding-sibling::tei:item intersect $siblings) + 1)
                            else ()
                    else if (count($node/parent::tei:list/tei:item) gt 0) then 
                        string(count($node/preceding-sibling::tei:item) + 1)
                    else ()
                return 'entry' || $title || $position
            else string(count($node/preceding-sibling::tei:item) + 1) (: TODO: we could also use render:isUnnamedCitetrailNode() for this :)
        
        case 'passagetrail' return
            ()
        
        case 'orig'
        case 'edit' return
            let $leader :=  if ($node/parent::tei:list/@type = "numbered") then
                                '#' || $config:nbsp
                            else if ($node/parent::tei:list/@type = "simple") then
                                $config:nbsp
                            else
                                '-' || $config:nbsp
            return ($leader, render:passthru($node, $mode), $config:nl)
       
        default return
            render:passthru($node, $mode)
};


declare function render:l($node as element(tei:l), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (render:passthru($node, $mode),<br/>)
        
        default return render:passthru($node, $mode)
};


declare function render:label($node as element(tei:label), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
            
        case 'html-title' return
            normalize-space(string-join(render:dispatch($node, 'edit')))
            
        case 'html' return
            switch($node/@place)
                case 'margin' return
                    render:makeMarginalHTML($node)
                case 'inline' return
                    <span class="label-inline">
                        {render:passthru($node, $mode)}
                    </span>
                default return render:passthru($node, $mode)
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            if (render:isUnnamedCitetrailNode($node)) then 
                string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
            else ()
            
        default return
            render:passthru($node, $mode)
};


declare function render:lb($node as element(tei:lb), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit'
        case 'snippets-orig'
        case 'snippets-edit' 
        case 'html' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
    
        (: INACTIVE (lb aren't relevant for sal:index): :)
        (:case 'citetrail' return
            (\: "pXlineY" where X is page and Y line number :\)
            concat('l',          
                if (matches($node/@n, '[A-Za-z0-9]')) then (\: this is obsolete since usage of lb/@n is deprecated: :\)
                    replace(substring-after($node/@n, '_'), '[^a-zA-Z0-9]', '')
                (\: TODO: make this dependent on whether the ancestor is a marginal:  :\)
                else string(count($node/preceding::tei:lb intersect $node/preceding::tei:pb[1]/following::tei:lb) + 1)
        ):)
        
        default return () 
};

declare function render:list($node as element(tei:list), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                else if ($node/(tei:head|tei:label)) then
                    render:teaserString(($node/(tei:head|tei:label))[1], 'edit')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@type)) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    render:teaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
        
        case 'html-title' return
            if (not($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) and $node/(tei:head|tei:label)) then
                normalize-space(string-join(render:dispatch(($node/(tei:head|tei:label))[1], 'edit')))
            else render:dispatch($node, 'title')
        
        case 'html' return
            (: available list types: "dict", "ordered", "simple", "bulleted", "gloss", "index", or "summaries" :)
            (: In html, lists must contain nothing but <li>s, so we have to move headings before the list 
               (inside a html <section>/<figure> with the actual list) and nest everything else (sub-lists) in <li>s. :)
            switch(render:determineListType($node))
                (: tei:item are actually handled here, not in render:item, due to the tight coupling of their layout to tei:list :)
                case 'ordered' return (: enumerated/ordered list :)
                    <section id="{$node/@xml:id}">
                        {for $head in $node/tei:head return <h4>{render:passthru($head, $mode)}</h4>}
                        <ol>
                            {for $child in $node/*[not(self::tei:head)] return 
                                <li>{render:passthru($child, $mode)}</li>}
                        </ol>
                    </section>
                case 'simple' return (: make no list in html terms at all :)
                    <section id="{$node/@xml:id}">
                        {for $head in $node/tei:head return <h4 class="inlist-head">{render:passthru($head, $mode)}</h4>}
                        {for $child in $node/*[not(self::tei:head)] return
                            if ($child//list) then render:passthru($child, $mode)
                            else (' ', <span class="inline-item">{render:passthru($child, $mode)}</span>, ' ')}
                    </section>
                case 'index'
                case 'summaries' return (: unordered list :)
                    let $content := 
                        <div class="list-index" id="{$node/@xml:id}">
                            {for $head in $node/tei:head return <h4 class="list-index-head">{render:passthru($head, $mode)}</h4>}
                            <ul style="list-style-type:circle;">
                                {for $child in $node/*[not(self::tei:head)] return 
                                    <li class="list-index-item">{render:passthru($child, $mode)}</li>}
                            </ul>
                        </div>
                    return
                        (:if (not($node/ancestor::tei:list)) then
                            <section>{$content}</section>
                        else :)
                        $content
                default return (: put an unordered list (and captions) in a figure environment (why?) of class @type :)
                    <div class="list-default" id="{$node/@xml:id}">
                        {for $head in $node/tei:head return <h4 class="list-default-head">{render:passthru($head, $mode)}</h4>}
                        <ul style="list-style-type:circle;">
                             {for $child in $node/*[not(self::tei:head)] return 
                                <li class="list-default-item">{render:passthru($child, $mode)}</li>}
                        </ul>
                    </div>
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'passagetrail' return
            ()
        
        case 'citetrail' return
            (: dictionaries, indices and summaries get their type prepended to their number :)
            if(render:isNamedCitetrailNode($node)) then
                let $currentSection := sal-util:copy($node/(ancestor::tei:div|ancestor::tei:body|ancestor::tei:front|ancestor::tei:back)[last()])
                let $currentNode := $currentSection//tei:list[@xml:id eq $node/@xml:id]
                return
                  concat(
                      $currentNode/@type, 
                      string(
                          count($currentNode/preceding::tei:list[@type eq $currentNode/@type]
                                intersect $currentSection//tei:list[@type eq $currentNode/@type]
                          ) + 1)
                     )
                (: without on-the-fly copying: :)
                (:concat(
                    $node/@type, 
                    string(
                        count($node/preceding::tei:list[@type eq $node/@type]
                              intersect $node/(ancestor::tei:div|ancestor::tei:body|ancestor::tei:front|ancestor::tei:back)[last()]//tei:list[@type eq $node/@type]
                        ) + 1)
                   ):)
            (: other types of lists are simply counted :)
            else if (render:isUnnamedCitetrailNode($node)) then 
                string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
            else ()
                (: OLD VERSION:
                string(count($node/preceding-sibling::tei:p|
                             ($node/preceding::tei:list[not(@type = ('dict', 'index', 'summaries'))] 
                              intersect $node/(ancestor::tei:div|ancestor::tei:body|ancestor::tei:front|ancestor::tei:back)[last()]//tei:list)) + 1):)
        case 'orig' return
            ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case 'edit' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                (concat($config:nl, ' [*', string($node/@n), '*]', $config:nl), render:passthru($node, $mode), $config:nl)
                (: or this?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case 'snippets-edit'
        case 'snippets-orig' return
            render:passthru($node, $mode)
        
        default return
            ($config:nl, render:passthru($node, $mode), $config:nl)
};

declare function render:lg($node as element(tei:lg), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            if (render:isUnnamedCitetrailNode($node)) then 
                string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
            else ()
        
        case 'html' return
            <span class="poem">{render:passthru($node, $mode)}</span>
            
        default return
            render:passthru($node, $mode)
};

declare function render:milestone($node as element(tei:milestone), $mode as xs:string) {
    switch($mode)
        case 'title' 
        case 'html-title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                (: purely numeric section titles: :)
                else if ($node/@n and matches($node/@n, '^[0-9\[\]]+$') and $node/@unit) then
                    $node/@n/string()
                (: use @unit to derive a title: :)
                else if (matches($node/@n, '^\[?[0-9]+\]?$') and $node/@unit[. ne 'number']) then
                    $config:citationLabels(@unit)?('abbr') || ' ' || @n
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    render:teaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
            (: TODO: bring i18n labels somehow into html-title... :)
            
        case 'html' return
            let $inlineText := if ($node/@rendition eq '#dagger') then <sup>†</sup> else '*'
            return
                $inlineText
        
        case 'class' return
            'tei-ms-' || $node/@unit
            
        case 'citetrail' return
            (: "XY" where X is the unit and Y is the anchor or the number of milestones where this occurs :)
            let $currentSection := sal-util:copy(render:getCitableParent($node))
            let $currentNode := $currentSection//tei:milestone[@xml:id eq $node/@xml:id]
            return
                if ($node/@n[matches(., '[a-zA-Z0-9]')]) then 
                    let $similarMs :=
                        $currentSection//tei:milestone[@unit eq $currentNode/@unit 
                                                       and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]
                    let $position :=
                        if (count($similarMs) gt 1) then
                            (: put 'N' between @n and position, so as to avoid collisions :)
                            'N' || string(count($currentNode/preceding::tei:milestone intersect $similarMs) + 1)
                        else ()
                    return $currentNode/@unit || upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', '')) || $position
                else $currentNode/@unit || string(count($currentNode/preceding::tei:milestone[@unit eq $node/@unit] intersect $currentSection//tei:milestone[@unit eq $currentNode/@unit]) + 1)
                (: without on-the-fly copying - outdated code: :)
                (:if ($node/@n[matches(., '[a-zA-Z0-9]')]) then 
                    let $similarMs :=
                        $node/ancestor::*[render:getCitableParent($node)][1]//tei:milestone[@unit eq $node/@unit 
                                                                  and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))]
                    let $position :=
                        if (count($similarMs) gt 1) then
                            
                            string(count($node/preceding::tei:milestone intersect $similarMs) + 1) (\: TODO: performance issues? :\)
                        else ()
                    return $node/@unit || upper-case(replace($node/@n, '[^a-zA-Z0-9]', '')) || $position
                else $node/@unit || string(count($node/preceding::tei:milestone[@unit eq $node/@unit] intersect $node/ancestor::tei:div[1]//tei:milestone[@unit eq $node/@unit]) + 1):)
        
        
        case 'passagetrail' return
            if (render:isPassagetrailNode($node)) then
                (: TODO: ATM milestone/@unit = ('article', 'section') resolves to the same abbrs as div/@type = ('article', 'section') :)
                (: TODO: if @n is numeric, always resolve to 'num.' ? :)
                let $prefix := lower-case($config:citationLabels($node/@unit)?('abbr'))
                let $num := 
                    if ($node/@n[matches(., '^[0-9\[\]]+$')]) then $node/@n (:replace($node/@n, '[\[\]]', '') ? :)
                    else 
                        let $currentSection := sal-util:copy($node/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:p)][1])
                        let $currentNode := $currentSection//tei:milestone[@xml:id eq $node/@xml:id]
                        let $position := count($currentSection//tei:milestone[@unit eq $currentNode/@unit and render:isPassagetrailNode(.)]
                                               intersect $currentNode/preceding::tei:milestone[@unit eq $currentNode/@unit and render:isPassagetrailNode(.)]) + 1
                        return string($position)
                        (: without on-the-fly copying: :)
                        (:let $position := count($node/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:p)][1]//tei:milestone[@unit eq $node/@unit and render:isPassagetrailNode(.)]
                                               intersect $node/preceding::tei:milestone[@unit eq $node/@unit and render:isPassagetrailNode(.)]) + 1
                        return string($position):)
                return
                    $prefix || ' ' || $num
            else ()
        
        case 'orig' return
            if ($node/@rendition = '#dagger') then '†'
            else if ($node/@rendition = '#asterisk') then '*'
            else '[*]'
        
        case 'edit' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                concat('[', string($node/@n), ']')
            else if ($node/@n and matches($node/@n, '^[0-9\[\]]+$')) then
                concat('[',  $config:citationLabels($node/@unit)?('abbr'), ' ', string($node/@n), ']')
                (: TODO: remove normalization parentheses '[', ']' here (and elsewhere?) :)
            else '[*]'
            
        default return () (: also for snippets-orig, snippets-edit :)
};

declare function render:name($node as element(*), $mode as xs:string) {
    switch($mode)
        case 'orig' return
            render:passthru($node, $mode)
        
        case 'edit' return
            if ($node/(@key|@ref)) then
                (render:passthru($node, $mode), ' [', string-join(($node/@key, $node/@ref), '/'), ']')
            else
                render:passthru($node, $mode)
        
        case 'html' return
            let $hiliteName := if ($node/@ref) then 'hi_' || render:classableString((tokenize($node/@ref, ' '))[1]) else ()
            let $dictLemma := 
                if ($node[self::tei:term and ancestor::tei:list[@type='dict'] and not(preceding-sibling::tei:term)]) then
                    'dictLemma'
                else ()
            return 
                (: as long as any link would lead nowhere, omit linking and simply grasp the content: :)
                <span class="{normalize-space(string-join((local-name($node),$hiliteName,$dictLemma), ' '))}">
                    {render:passthru($node, $mode)}
                </span>
                (: as soon as links have actual targets, execute something like the following: :)
                (:let $resolvedURI := render:resolveURI($node, @ref)
                return
                    if ($node/@ref and substring($resolvedURI,1,5) = ('http:', '/exis')) then
                        render:transformToHTMLLink($node, $resolvedURI)
                    else 
                        {render:passthru($node, $mode)}:)
                (: 
                <xsl:choose>
                    <xsl:when test="@ref and substring(sal:resolveURI(current(), @ref)[1],1, 5) = ('http:', '/exis') ">
                        <xsl:choose>
                            <xsl:when test="not(./pb)"> <!-\- The entity does not contain a pagebreak intervention - no problem then -\->
                                <xsl:element name="a">
                                    <xsl:attribute name="href" select="sal:resolveURI(current(), @ref)"/>
                                    <xsl:attribute name="target">_blank</xsl:attribute>
                                    <xsl:apply-templates/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>             <!-\- Otherwise, make an anchor for the preceding part, then render the pb, then "continue" the anchor -\->
                                <xsl:element name="a">
                                    <xsl:attribute name="href" select="sal:resolveURI(current(), @ref)"/>
                                    <xsl:attribute name="target">_blank</xsl:attribute>
                                    <xsl:apply-templates select="./pb/preceding-sibling::node()"/>
                                </xsl:element>
                                <xsl:apply-templates select="./pb"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href" select="sal:resolveURI(current(), @ref)"/>
                                    <xsl:attribute name="target">_blank</xsl:attribute>
                                    <xsl:apply-templates select="./pb/following-sibling::node()"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
                :)
        
        default return
            render:passthru($node, $mode)
};


declare function render:note($node as element(tei:note), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                let $currentSection := sal-util:copy($node/ancestor::tei:div[1])
                let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]
                return
                    if ($node/@n) then
                        let $noteNumber :=
                            if (count($currentSection//tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($currentNode/@n))]) gt 1) then
                                ' (' || 
                                string(count($currentNode/preceding::tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($currentNode/@n))] 
                                             intersect $currentSection//tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($currentNode/@n))])
                                       + 1) 
                                || ')'
                            else ()
                        return '&#34;' || normalize-space($currentNode/@n) || '&#34;' || $noteNumber
                    else string(count($currentNode/preceding::tei:note intersect $currentSection//tei:note) + 1)
                    (: without on-the-fly copying: :)
                    (:if ($node/@n) then
                        let $noteNumber :=
                            if (count($node/ancestor::tei:div[1]//tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($node/@n))]) gt 1) then
                                ' (' || 
                                string(count($node/preceding::tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($node/@n))] 
                                             intersect $node/ancestor::tei:div[1]//tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($node/@n))])
                                       + 1) 
                                || ')'
                            else ()
                        return '&#34;' || normalize-space($node/@n) || '&#34;' || $noteNumber
                    else string(count($node/preceding::tei:note intersect $node/ancestor::tei:div[1]//tei:note) + 1):)
            )
        
        case 'html-title' return ()
        
        case 'html' return
            render:makeMarginalHTML($node)
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            (: "nX" where X is the anchor used (if it is alphanumeric) and "nXY" where Y is the number of times that X occurs inside the current div
                (important: nodes are citetrail children of div (not of p) and are counted as such) :)
            let $currentSection := sal-util:copy($node/ancestor::tei:div[1])
            let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]
            let $noteLabel :=
                string(  
                    if (matches($currentNode/@n, '^[A-Za-z0-9\[\]]+$')) then
                        if (count($currentSection//tei:note[upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]) gt 1) then
                            concat(
                                upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', '')),
                                string(
                                    count($currentSection//tei:note[upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]
                                          intersect $currentNode/preceding::tei:note[upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))])
                                    + 1)
                            )
                        else upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))
                    else count($currentNode/preceding::tei:note intersect $currentSection//tei:note) + 1
                )
            return 'n' || $noteLabel
            (: without on-the-fly copying: :)
            (:concat('n',  
                if (matches($node/@n, '^[A-Za-z0-9\[\]]+$')) then
                    if (count($node/ancestor::tei:div[1]//tei:note[upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))]) gt 1) then
                        concat(
                            upper-case(replace($node/@n, '[^a-zA-Z0-9]', '')),
                            string(
                                count($node/ancestor::tei:div[1]//tei:note[upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))]
                                      intersect $node/preceding::tei:note[upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))])
                                + 1)
                        )
                    else upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))
                else count($node/preceding::tei:note intersect $node/ancestor::tei:div[1]//tei:note) + 1
            ):)
        
        case 'passagetrail' return
            if (render:isPassagetrailNode($node)) then
                (: passagetrail parents of note are div, not p :)
                let $currentSection := sal-util:copy($node/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:p)][1])
                let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]
                let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $label := 
                    if ($node/@n) then '"' || $node/@n || '"' (: TODO: what if there are several notes with the same @n in a div :)
                    else string(count($currentSection//tei:note
                                      intersect $currentNode/preceding::tei:note) + 1)
                return $prefix || ' ' || $label
                (: without on-the-fly copying: :)
                (:let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $label := 
                    if ($node/@n) then '"' || $node/@n || '"' (\: TODO: what if there are several notes with the same @n in a div :\)
                    else string(count($node/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:p)][1]//tei:note
                                      intersect $node/preceding::tei:note) + 1) (\: TODO: this can be insanely expensive wrt performance... :\)
                return $prefix || ' ' || $label:)
            else ()
            
        case 'orig'
        case 'edit' return
            ($config:nl, '        {', render:passthru($node, $mode), '}', $config:nl)
        
        default return
            render:passthru($node, $mode)
};

declare function render:orgName($node as element(tei:orgName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig'
        case 'snippets-edit' return
            render:passthru($node, $mode)
        default return
            render:name($node, $mode)
};

declare function render:orig($node as element(tei:orig), $mode) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        case 'snippets-edit' return
            if (not($node/preceding-sibling::tei:reg|$node/following-sibling::tei:reg)) then
                render:passthru($node, $mode)
            else ()
        default return
            render:origElem($node, $mode)
};


declare function render:origElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'orig' return
            render:passthru($node, $mode)
        
        case 'edit' return
            if (not($node/(preceding-sibling::tei:expan|preceding-sibling::tei:reg|preceding-sibling::tei:corr|following-sibling::tei:expan|following-sibling::tei:reg|following-sibling::tei:corr))) then
                render:passthru($node, $mode)
            else ()
            
        case 'html' return
            if (not($node/parent::tei:choice)) then
                render:passthru($node, $mode)
            else 
                let $editString := string-join(render:dispatch($node/parent::tei:choice/(tei:expan|tei:reg|tei:corr), 'edit'), '')
                return
                    <span class="original {local-name($node)} unsichtbar" title="{$editString}">
                        {string-join(render:passthru($node, $mode), '')}
                    </span>
        
        default return
            render:passthru($node, $mode)
};


declare function render:p($node as element(tei:p), $mode as xs:string) {
    switch($mode)
        case 'title' 
        case 'html-title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            if (render:isUnnamedCitetrailNode($node)) then 
                string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
            else ()
        
        case 'passagetrail' return
            if (render:isPassagetrailNode($node)) then
                let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $teaser := '"' || normalize-space(substring(substring-after(render:p($node, 'title'), '"'),1,15)) || '…"'(: short teaser :)
                return $prefix || ' ' || $teaser
            else ()
        
        case 'orig'
        case 'edit' return
            if ($node/ancestor::tei:note) then
                if ($node/following-sibling::tei:p) then
                    (render:passthru($node, $mode), $config:nl)
                else
                    render:passthru($node, $mode)
            else
                ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case 'html' return
            (: special cases :)
            if ($node/ancestor::tei:note) then
                <span class="note-paragraph">
                    {render:passthru($node, $mode)}
                </span>
            else if ($node/ancestor::tei:item) then
                <span class="item-paragraph">
                    {render:passthru($node, $mode)}
                </span>
            else if ($node/ancestor::tei:titlePage) then
                <span class="tp-paragraph">
                    {render:passthru($node, $mode)}
                </span>
            (: main text: :)
            else if ($node/ancestor::item[not(ancestor::list/@type = ('dict', 'index'))]) then
                <p id="{$node/@xml:id}">
                    {render:passthru($node, $mode)}
                </p>
            else
                render:passthru($node, $mode)
        
        case 'snippets-orig'
        case 'snippets-edit' return
            for $subnode in $node/node() where (local-name($subnode) ne 'note') return render:dispatch($subnode, $mode)
        
        default return
            render:passthru($node, $mode)
};


declare function render:passthru($nodes as node()*, $mode as xs:string) as item()* {
    for $node in $nodes/node() return render:dispatch($node, $mode)
};


declare function render:pb($node as element(tei:pb), $mode as xs:string) {
    switch($mode)
        case 'title'
        case 'html-title' return
            normalize-space(
                (: any pb with @sameAs and @corresp probably won't even get reached, since they typically have note ancestors :)
                if ($node/@sameAs) then
                    concat('[pb_sameAs_', $node/@sameAs, ']')
                else if ($node/@corresp) then
                    concat('[pb_corresp_', $node/@corresp, ']')
                else
                    (: not prepending 'Vol. ' prefix here :)
                    if (contains($node/@n, 'fol.')) then 
                        $node/@n
                    else
                        'p. ' || $node/@n
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            (: "pagX" where X is page number :)
            concat('p',
                if (matches($node/@n, '[\[\]A-Za-z0-9]') 
                    and not($node/preceding::tei:pb[ancestor::tei:text[1] intersect $node/ancestor::tei:text[1]
                                                    and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))]
                            )
                   ) then
                    upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))
                else substring($node/@facs, 6)
            )
            (: TODO: are collisions possible, esp. if pb's crumb does not inherit from the specific section (titlePage|div)? 
               -> for example, with repetitive page numbers in the appendix 
                (ideally, such collisions should be resolved in TEI markup, but one never knows...) :)
        
        case 'html' return
            if (render:isIndexNode($node)) then 
                let $inlineBreak :=
                    if ($node[@type eq 'blank']) then (: blank pages - make a typographic line break :)
                        <br/>
                    else if ($node[preceding::tei:pb 
                                   and preceding-sibling::node()[descendant-or-self::text()[not(normalize-space() eq '')]]                                                                                
                                   and following-sibling::node()[descendant-or-self::text()[not(normalize-space() eq '')]]]) then
                        (: mark page break by means of '|', but not at the beginning or end of structural sections :)
                        if ($node/@break eq 'no') then '|' else ' | '
                    else ()
                let $link :=
                    if ($node[@n]) then
                        let $pageAnchor := 'pageNo_' || (if ($node/@xml:id) then $node/@xml:id/string() else generate-id($node))
                        let $title := if (contains($node/@n, 'fol.')) then 'View image of ' || $node/@n else 'View image of p. ' || $node/@n
                        return
                            <div class="pageNumbers">
                                <a href="{render:resolveFacsURI($node/@facs)}">
                                    <i class="fas fa-book-open facs-icon"/>
                                    {' '}
                                    <span class="pageNo messengers" data-canvas="{render:resolveCanvasID($node)}"
                                        data-sal-id="{render:makeCitetrailURI($node)}" id="{$pageAnchor}" title="{$title}">
                                        {render:pb($node, 'html-title')}
                                    </span>
                                </a>
                            </div>
                    else ()
                return ($inlineBreak, $link)
            else ()
                    
        case 'passagetrail' return
            if (contains($node/@n, 'fol.')) then $node/@n
            else 'p. ' || $node/@n
        
        case 'orig'
        case 'edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        case 'snippets-orig'
        case 'snippets-edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        (: pb nodes are excellent candidates for tracing the speed/performance of document processing, 
            since they are equally distributed throughout a document :)
        case 'debug' return
            util:log('warn', '[RENDER] Processing tei:pb node ' || $node/@xml:id)
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};


declare function render:persName($node as element(tei:persName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key and $node/@ref) then
                string($node/@key) || ' [' || string($node/@ref) || ']'
            else if ($node/@key) then
                string($node/@key)
            else if ($node/@ref) then
                '[' || string($node/@ref) || ']'
            else
                render:passthru($node, $mode)
        
        case 'html' return
            render:name($node, $mode)
        
        case 'class' return ()
        
        default return
            render:name($node, $mode)
};

declare function render:placeName($node as element(tei:placeName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                render:passthru($node, $mode)
        case 'html' return
            render:name($node, $mode)
        case 'class' return ()
        default return
            render:name($node, $mode)
};

(: Same as render:persName() :)
declare function render:publisher($node as element(tei:publisher), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key and $node/@ref) then
                string($node/@key) || ' [' || string($node/@ref) || ']'
            else if ($node/@key) then
                string($node/@key)
            else if ($node/@ref) then
                '[' || string($node/@ref) || ']'
            else
                render:passthru($node, $mode)
        
        case 'html' return
            render:name($node, $mode)
        
        default return
            render:name($node, $mode)
};

(: Same as render:placeName() :)
declare function render:pubPlace($node as element(tei:pubPlace), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                render:passthru($node, $mode)
        case 'html' return
            render:name($node, $mode)
        default return
            render:name($node, $mode)
};

declare function render:quote($node as element(tei:quote), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit' return
            ('"', render:passthru($node, $mode), '"')
        
        case 'snippets-edit'
        case 'snippets-orig' return
            render:passthru($node, $mode)
            
        case 'html' return
            <span class="quote">
                {render:passthru($node, $mode)}
            </span>
        
        default return
            ('"', render:passthru($node, $mode), '"')
};

declare function render:ref($node as element(tei:ref), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@type eq 'note-anchor') then
                () (: omit note references :)
            else if ($node/@target) then
                let $resolvedUri := render:resolveURI($node, $node/@target) (: TODO: verify that this works :)
                return render:transformToHTMLLink($node, $resolvedUri)
            else render:passthru($node, $mode)
        
        default return
            render:passthru($node, $mode)
};


declare function render:reg($node as element(tei:reg), $mode) {
    switch($mode)
        case 'snippets-orig' return 
            ()
        case 'snippets-edit' return
            render:passthru($node, $mode)
        default return
            render:editElem($node, $mode)
};

declare function render:row($node as element(tei:row), $mode) {
    switch($mode)
        case 'html' return 
            <tr>{render:passthru($node, $mode)}</tr>
        
        default return
            render:passthru($node, $mode)
};

declare function render:sic($node as element(tei:sic), $mode) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        case 'snippets-edit' return
            if (not($node/preceding-sibling::tei:corr|$node/following-sibling::tei:corr)) then
                render:passthru($node, $mode)
            else ()
        default return
            render:origElem($node, $mode)
};

declare function render:signed($node as element(tei:signed), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            if (render:isUnnamedCitetrailNode($node)) then 
                string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
            else ()
            
        case 'snippets-orig'
        case 'snippets-edit' return
            for $subnode in $node/node() where (local-name($subnode) ne 'note') return render:dispatch($subnode, $mode)
            
        case 'html' return
            <div class="hauptText">
                <div class="signed">
                    {render:passthru($node, $mode)}
                </div>
            </div>
            
        default return
            render:passthru($node, $mode)
};


declare function render:soCalled($node as element(tei:soCalled), $mode as xs:string) {
    if ($mode=("orig", "edit")) then
        ("'", render:passthru($node, $mode), "'")
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else
        ("'", render:passthru($node, $mode), "'")
};

declare function render:space($node as element(tei:space), $mode as xs:string) {
    if ($node/@dim eq 'horizontal' or @rendition eq '#h-gap') then ' ' else ()
};


declare function render:supplied($node as element(tei:supplied), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (<span class="original unsichtbar" title="{string($node)}">{'[' || string-join(render:passthru($node,$mode)) || ']'}</span>,
            <span class="edited" title="{concat('[', string($node), ']')}">{render:passthru($node,$mode)}</span>)
            
        default return
            render:passthru($node, $mode)
};


declare function render:table($node as element(tei:table), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <table>{render:passthru($node, $mode)}</table>
            
        default return render:passthru($node, $mode)
};

(: FIXME: In the following, work mode functionality has to be added - also paying attention to intervening pagebreak marginal divs :)
declare function render:term($node as element(tei:term), $mode as xs:string) {
    switch($mode)
        case 'orig' 
        case 'snippets-orig' return
            render:passthru($node, $mode)
        
        case 'edit' return
            if ($node/@key) then
                (render:passthru($node, $mode), ' [', string($node/@key), ']')
            else
                render:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                render:passthru($node, $mode)
        
        case 'html' return
            render:name($node, $mode)
        
        default return
            render:passthru($node, $mode)
};

declare function render:text($node as element(tei:text), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@type eq 'work_volume') then
                    $node/@n/string()
                (: tei:text with solely technical information: :)
                else if ($node/@xml:id eq 'completeWork') then
                    '[complete work]'
                else if (matches($node/@xml:id, 'work_part_[a-z]')) then
                    '[process-technical part: ' || substring(string($node/@xml:id), 11, 1) || ']'
                else ()
            )
        case 'html-title' return
            if ($node/@type eq 'work_volume') then
                'Vol.' || $node/@n/string()
            else ()
        
        case 'html' return
            if (render:isCitableWithTeaserHTML($node)) then
                let $delimiter := 
                    if ($node/@type eq 'work_volume' and $node/preceding::tei:text[@type eq 'work_volume']) 
                        then <hr/> 
                    else ()
                return ($delimiter, render:passthru($node, $mode))
            else render:passthru($node, $mode)
        
        case 'class' return
            if ($node/@type eq 'work_volume') then 'tei-text-' || $node/@type
            else if ($node/@xml:id eq 'completeWork') then 'tei-text-' || $node/@xml:id
            else if (matches($node/@xml:id, 'work_part_[a-z]')) then 'elem-text-' || $node/@xml:id
            else 'tei-text'
        
        case 'citetrail' return
            (: "volX" where X is the current volume number, don't use it at all for monographs :)
            if ($node/@type eq 'work_volume') then
               concat('vol', count($node/preceding::tei:text[@type eq 'work_volume']) + 1)
            else ()
        
        case 'passagetrail' return
            if (render:isPassagetrailNode($node)) then
                'vol. ' || $node/@n
            else ()
        
        default return
            render:passthru($node, $mode)
};

declare function render:textNode($node as node(), $mode as xs:string) {
    switch($mode)
        case "orig"
        case "edit" return
            let $leadingSpace   := if (matches($node, '^\s+')) then ' ' else ()
            let $trailingSpace  := if (matches($node, '\s+$')) then ' ' else ()
            return concat($leadingSpace, 
                          normalize-space(replace($node, '&#x0a;', ' ')),
                          $trailingSpace)
        
        case 'html'
        case 'snippets-orig' 
        case 'snippets-edit' return 
(:            let $debug := util:log('warn', 'Processing textNode: ' || $node) return:)
            $node
        
        default return 
            $node
};

declare function render:title($node as element(tei:title), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            render:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                render:passthru($node, $mode)
        
        case 'html' return
            render:name($node, $mode)
        
        default return
            render:name($node, $mode)
};

declare function render:titlePage($node as element(tei:titlePage), $mode as xs:string) {
    switch($mode)
        case 'title' return
            (:normalize-space(
                let $volumeString := 
                    if ($node/ancestor::tei:text[@type='work_volume']) then 
                        concat('Vol. ', $node/ancestor::tei:text[@type='work_volume']/@n, ', ') 
                    else ()
                let $volumeCount :=
                    if (count($node/ancestor::tei:text[@type='work_volume']//tei:titlePage) gt 1) then 
                        string(count($node/preceding-sibling::tei:titlePage)+1) || ', '
                    else ()
                return $volumeCount || $volumeString
            ):)
            ()
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            'titlepage'
        
        case 'passagetrail' return
            $config:citationLabels(local-name($node))?('abbr')
        
        case 'html' return
            let $toolbox := render:HTMLSectionToolbox($node)
            (: distinguishing first and subsequent titlePage(s) for rendering them differently :)
            let $class := if ($node[not(preceding-sibling::tei:titlePage)]) then 'titlePage' else 'sec-titlePage'
            return
                <div class="{$class}">
                    {$toolbox}
                    <div class="titlePage-body">
                        {render:passthru($node, $mode)}
                    </div>
                </div>
        
        default return
            render:passthru($node, $mode)
};

declare function render:titlePart($node as element(tei:titlePart), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            (: "titlePage.X" where X is the number of parts where this occurs :)
            concat('titlepage.', string(count($node/preceding-sibling::tei:titlePart) + 1))
        
        case 'html' return
            if ($node/@type eq 'main') then
                <h1>{render:passthru($node, $mode)}</h1>
            else render:passthru($node, $mode)
            
        default return 
            render:passthru($node, $mode)
};


declare function render:unclear($node as element(tei:unclear), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (: TODO i18n title :)
            if ($node//text()) then
                <span title="unclear" class="sal-unclear-text">{render:passthru($node, $mode)}</span>
            else <span title="unclear" class="sal-unclear"/>
            
        default return 
            render:passthru($node, $mode)
};


(: TODO: still undefined: titlePage descendants: titlePart, docTitle, ...; choice, l; author fields: state etc. :)

(: TODO - Html:
    * add line- and column breaks in diplomatic view? (problem: infinite scrolling has to comply with the current viewmode as well!)
    * make marginal summary headings expandable/collapsible like we handle notes that are too long
    * make bibls, ref span across (page-)breaks (like persName/placeName/... already do)
    * teasers: break text at word boundaries
    * what happens to notes that intervene in a <hi> passage or similar? (font-style/weight and -size should already be fixed by css...)
:)

