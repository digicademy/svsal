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

(:declare option exist:serialize       "method=html5 media-type=text/html indent=no";:)

(: *Work* rendering functions and settings :)

(: TODO: some of the functions here are also used by non-work entity rendering procedures (such as WP snippet rendering)
         - these should eventually have there own rendering functions/modules at some point :)

(: SETTINGS :)

(: the max. amount of characters to be shown in a note teaser :)
declare variable $render:noteTruncLimit := 35;

declare variable $render:teaserTruncLimit := 45;
(:
declare variable $render:chars :=
    if (doc-available($config:tei-meta-root || '/specialchars.xml')) then
        map:merge(
            for $c in doc($config:tei-meta-root || '/specialchars.xml')/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:charDecl/tei:char return 
                map:entry($c/@xml:id/string(), $c)
        )
    else ();:)


(: Crumbtrail/citetrail/passagetrail administrator function :)
declare function render:getNodetrail($targetWork as node()*, $targetNode as node(), $mode as xs:string, $fragmentIds as map()) {
    (: (1) get the trail ID for the current node :)
    let $currentNode := 
        (: no recursion here, makes single ID for the current node :)
        if ($mode eq 'crumbtrail') then
            let $class := render:dispatch($targetNode, 'class')
            return
                if ($class) then
                    <a class="{$class}" href="{render:mkUrlWhileRendering($targetWork, $targetNode, $fragmentIds)}">{render:dispatch($targetNode, 'title')}</a>
                else 
                    <a href="{render:mkUrlWhileRendering($targetWork, $targetNode, $fragmentIds)}">{render:dispatch($targetNode, 'title')}</a>
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
                render:getNodetrail($targetWork, render:getCitableParent($targetNode), $mode, $fragmentIds)
            else ()
        else if ($mode eq 'passagetrail') then (: similar to crumbtrail/citetrail, but we need to target the nearest *passagetrail* ancestor, not the nearest index node ancestor :)
            (: TODO: outsource this to a render:getPassagetrailParent($node as node()) function, analogous to render:getCitableParent() :)
            if ($targetNode/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:text[not(@type eq 'work_volume')])]) then
                if ($targetNode[self::tei:pb]) then 
                    if ($targetNode/ancestor::tei:front|$targetNode/ancestor::tei:back|$targetNode/ancestor::tei:text[1][@type = "work_volume"]) then
                        (: within front, back, and single volumes, prepend front's or volume's trail ID for avoiding multiple identical IDs in the same work :)
                        render:getNodetrail($targetWork,  ($targetNode/ancestor::tei:front|$targetNode/ancestor::tei:back|$targetNode/ancestor::tei:text[1][@type = "work_volume"])[last()], $mode, $fragmentIds)
                    else ()
                else if ($targetNode[self::tei:pb]) then ()
                else if ($targetNode[self::tei:note or self::tei:milestone]) then
                    (: citable parents of notes and milestones should not be p :)
                    render:getNodetrail($targetWork, $targetNode/ancestor::*[render:isPassagetrailNode(.) and not(self::tei:p)][1], $mode, $fragmentIds)
                else 
                    (: === for all other node types, get parent node's trail (deep recursion) === :)
                    render:getNodetrail($targetWork, $targetNode/ancestor::*[render:isPassagetrailNode(.)][1], $mode, $fragmentIds)
            else ()
        else ()
    (: (b) get connector MARKER :)
    let $connector :=
        if (count($currentNode) gt 0 and count($trailPrefix) gt 0) then
            if ($mode eq 'crumbtrail') then ' » ' 
            else if ($mode eq 'citetrail') then '.' 
            else if ($mode eq 'passagetrail') then ' '
            else ()
        else ()
    (: (c) put it all together and out :)
    let $trail :=
        if ($mode eq 'crumbtrail') then ($trailPrefix, $connector, $currentNode)
        else if ($mode eq 'citetrail') then $trailPrefix || $connector || $currentNode
        else if ($mode eq 'passagetrail') then $trailPrefix || $connector || $currentNode
        else ()
        
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

declare function render:isPassagetrailNode($node as element()) as xs:boolean {
    boolean(
        $node/@xml:id and
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
~ (The set of nodes that should have a crumbtrail is equal to the set of nodes that should have a citetrail.)
:)
declare function render:isIndexNode($node as element()) as xs:boolean {
    (: any element type relevant for citetrail creation must be included in one of the following functions: :)
    render:isNamedCitetrailNode($node) or render:isUnnamedCitetrailNode($node)
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
            $node/self::tei:list[@type = ('dict', 'index', 'summaries')] or
            $node/self::tei:text[not(@xml:id = 'completeWork' or @type = "work_part")]
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
           $node/self::tei:text[not(ancestor::tei:text)] or (: we won't produce any trail ID for this, but we need it as a recursion anchor :)
           (:$node/self::tei:div[@type ne "work_part"] or:) (: TODO: commented out for div label experiment :)
           $node/self::tei:p[not(ancestor::tei:note|ancestor::tei:item)] or
           $node/self::tei:signed or
           $node/self::tei:label[not(ancestor::tei:lg|ancestor::tei:note|ancestor::tei:item|ancestor::tei:p)] or (: labels, contrarily to headings, are simply counted :)
           $node/self::tei:lg[not(ancestor::tei:lg|ancestor::tei:note|ancestor::tei:item|ancestor::tei:p)] or (: count only top-level lg, not single stanzas :)
           $node/self::tei:list[not(@type = ('dict', 'index', 'summaries'))] or
           $node/self::tei:item[not(ancestor::tei:list[1][@type = ('dict', 'index', 'summaries')]|ancestor::tei:note|ancestor::tei:item)]
        )
    )
};

(: currently not in use: :)
(:declare function render:mkAnchor ($targetWork as node()*, $targetNode as node()) {
    let $targetWorkId := string($targetWork/tei:TEI/@xml:id)
    let $targetNodeId := string($targetNode/@xml:id)
    return <a href="{render:mkUrl($targetWork, $targetNode)}">{render:sectionTitle($targetWork, $targetNode)}</a>    
};:)


declare function render:mkUrlWhileRendering($targetWork as node(), $targetNode as node(), $fragmentIds as map()) {
    let $targetWorkId := string($targetWork/@xml:id)
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


(:
~ From a given fragment root, searches for ancestors that occur above the fragmentation level and renders them (non-recursively)
    such that they can be re-included into a fragment's HTML.
:)
(: TODO: should this reside rather in render:[ELEMENT] functions? :)
declare function render:excludedAncestorHTML($fragmentRoot as element()) {
    for $node in $fragmentRoot/ancestor::*[render:isIndexNode(.)] return
        let $delimiter := 
            if ($node/self::tei:text[@type='work_volume'] and $node/preceding::tei:text[@type='work_volume']) then 
                <hr/> 
            else ()
        let $summaryTitle :=
            <div class="summary_title">
                {render:HTMLSectionToolbox($node)}
                {' '}
                <b>{render:dispatch($node, 'html-title')}</b>
            </div>
        return ($delimiter, $summaryTitle)
};

declare function render:HTMLsectionTeaser($node as element()) {
    let $identifier := $node/@xml:id/string()
    let $fullTitle := render:dispatch($node, 'html-title')
    return 
        if (string-length($fullTitle) gt $render:teaserTruncLimit) then
            (<a data-toggle="collapse" data-target="{('#restOfString' || $identifier)}">
                {substring($fullTitle,1,$render:teaserTruncLimit) || '…'} 
                <i class="fa fa-angle-double-down"/>
            </a>,
            <div class="collapse" id="{('restOfString' || $identifier)}">
                {$fullTitle}
            </div>)
        else $fullTitle
};

declare function render:HTMLSectionToolbox($node as element()) as element(span) {
    let $id := $node/@xml:id/string()
    let $dataContent := 
        '&lt;div&gt;' ||
            '&lt;a href=&#34;' || render:getHTMLSectionId($node) || '&#34;&gt;' || 
                '&lt;span class=&#34;messengers glyphicon glyphicon-link&#34; title=&#34;go to/link this textarea&#34;/&gt;' || 
            '&lt;/a&gt;' || 
            '  ' || 
            '&lt;a class=&#34;updateHiliteBox&#34; href=&#34;#34;&gt;'  || 
                '&lt;span class=&#34;glyphicon glyphicon-refresh&#34;/&gt;' || 
            '&lt;/a&gt;' || 
            '  ' || 
            '&lt;span class=&#34;glyphicon glyphicon-print text-muted&#34;/&gt;' || 
        '&lt;/div&gt;'
    return
        <span>
            <a id="{$id}" href="{('#' || $id)}" data-rel="popover" data-content="{$dataContent}">
                <i class="far fa-hand-point-right messengers" title="Open toolbox for this textarea"/>
            </a>
        </span>
};

(:declare function render:resolveURI($node as element(), $target as xs:string) {
    let $workId := $node/ancestor::tei:TEI/@xml:id
    let $prefixDef := $node/ancestor::tei:TEI//tei:prefixDef
    
};:)

declare function render:getHTMLSectionId($node as element()) {
    let $citetrail := render:dispatch($node, 'citetrail')
    let $workId := $node/ancestor::tei:TEI/@xml:id
    return
        $config:idserver || '/texts/' || $workId || ':' || $citetrail
};


declare function render:classableString($str as xs:string) as xs:string? {
    replace($str, '[,: ]', '')
};

(: ####====---- End Helper Functions ----====#### :)




(: ####====---- RENDERING FUNCTIONS ----====#### :)

declare function render:createHTMLFragment($workId as xs:string, $fragmentRoot as element(), $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) as element(div) {
    <div class="row" xml:space="preserve">
        <div class="col-md-12">
            <div id="SvSalPages">
                <div class="SvSalPage">                 <!-- main area (id/class page in order to identify page-able content -->
                    {
                    (: TODO: this seems to work only for a titlePage or first div within the front of a text[@type eq 'work_volume'],
                        but what about other (body|back) ancestors excluded by a higher $fragmentationDepth? :)
                    if ($fragmentRoot[not(preceding-sibling::*) and not((ancestor::body|ancestor::back) and preceding::front/*)]) then
                        render:excludedAncestorHTML($fragmentRoot)
                    else ()    
                    }
                    {render:dispatch($fragmentRoot, 'html')}
                </div>
            </div>                                      <!-- the rest (to the right) is filled by _spans_ with class marginal, possessing
                                                             a negative right margin (this happens in eXist's work.html template) -->
        </div>
        {render:createPaginationLinks($workId, $fragmentIndex, $prevId, $nextId)}    <!-- finally, add pagination links --> 
    </div>
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
    else if (ancestor::tei:list[@type]) then ancestor::tei:list[@type][1]/@type
    else ()
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
:)

(: $mode can be "orig", "edit" (both being plain text modes), "html" or, even more sophisticated, "work" :)
declare function render:dispatch($node as node(), $mode as xs:string) {
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
        
        case element(tei:persName)      return render:name($node, $mode)
        case element(tei:placeName)     return render:name($node, $mode)
        case element(tei:orgName)       return render:name($node, $mode)
        case element(tei:title)         return render:name($node, $mode)
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
        
        case element(tei:figure)        return render:figure($node, $mode)
        
        case element(tei:text)          return render:text($node, $mode) 
        case element(tei:front)         return render:front($node, $mode) 
        case element(tei:body)          return render:body($node, $mode)
        case element(tei:back)          return render:back($node, $mode)

        case element(tei:table)         return render:table($node, $mode)
        case element(tei:row)           return render:row($node, $mode)
        case element(tei:cell)           return render:cell($node, $mode)

        case element(tei:figDesc)       return ()
        case element(tei:teiHeader)     return ()
        case element(tei:fw)            return ()
        case comment()                  return ()
        case processing-instruction()   return ()

        default return render:passthru($node, $mode)
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
        default return
            render:origElem($node, $mode)
};

declare function render:argument($node as element(tei:argument), $mode as xs:string) {
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
                <span class="{local-name($node) || ' hi_', render:classableString(@sortKey)}">{render:passthru($node, $mode)}</span>
            else <span>{render:passthru($node, $mode)}</span>
        
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
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render:cell($node as element(tei:cell), $mode) {
    switch($mode)
        case 'html' return 
            if ($node/@role eq 'label') then 
                <td class="table-label">{render:passthru($node, $mode)}</td>
            else <td>{render:passthru($node, $mode)}</td>
        
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
    render:passthru($node, $mode)
};


declare function render:death($node as element(tei:death), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else ()
};

declare function render:div($node as element(tei:div), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '&#34;' || string($node/@n) || '&#34;'
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
                (: for expanded titles, we need the full version, not just the teaser :)
                normalize-space(string-join(render:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''))
            else render:div($node, 'title')
        
        case 'class' return
            'tei-div-' || $node/@type
        
        case 'citetrail' return
            if (render:isNamedCitetrailNode($node)) then
                (: use abbreviated form of @type (without dot), possibly followed by position :)
                (: TODO: div label experiment (delete the following block if this isn't deemed plausible) :)
                let $prefix :=
                    if ($config:citationLabels($node/@type)?('abbr')) then 
                        lower-case(substring-before($config:citationLabels($node/@type)?('abbr'), '.'))
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

declare function render:docDate($node as element(tei:docDate), $mode as xs:string) {
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
    render:passthru($node, $mode)
};

declare function render:editElem($node as element(), $mode as xs:string) {
    switch($mode)
        case "orig" return ()
        case "edit" return
            render:passthru($node, $mode)
            
        case 'html' return
            let $origString := string-join(render:dispatch($node/parent::choice/(abbr|orig|sic), 'orig'), '')
            return
                <span class="messengers edited {local-name($node)}" title="{$origString}">
                    {render:passthru($node, $mode)}
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


declare function render:figure($node as element(tei:figure), $mode) {
    switch($mode)
        case 'html' return
            if ($node/@type eq 'ornament') then
                <hr class="ornament"/>
            else ()
            
        default return ()
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
    switch ($mode)
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
            return  if ($glyph/tei:mapping[@type = 'standardized']) then
                        string($glyph/tei:mapping[@type = 'standardized'])
                    else
                        render:passthru($node, $mode)
        
        case 'html' return
            let $thisString := xs:string($node/text())
            let $charCode := substring($node/@ref,2)
            let $char := $node/ancestor::tei:TEI/tei:teiHeader/tei:encodingDesc/tei:charDecl/tei:char[@xml:id eq $charCode]
            let $test := (: make sure that the char reference is correct :)
                if (not($char)) then 
                    error(xs:QName('render:g'), 'g/@ref is invalid, the char code does not exist): ', $charCode)
                else ()
            return 
                (: Depending on the context or content of the g element, there are several possible cases: :)
                (: 1. if g occurs within choice, it must be a "simple" character since the larger context has already been edited -> pass it through :)
                if ($node/ancestor::tei:choice) then
                    $thisString
                (: 2. g occurs outside of choice: :)
                else
                    let $precomposedString := string($char/tei:mapping[@type='precomposed']/text())
                    let $composedString := string($char/tei:mapping[@type='composed']/text())
                    let $originalGlyph :=
                        if ($precomposedString) then $precomposedString (: TODO: does this work? (in xslt: disable-output-escaping="yes") :)
                        else $composedString
                    let $test := 
                        if (string-length($originalGlyph) eq 0) then 
                            error(xs:QName('render:g'), 'No correct mapping available for char: ', $node/@ref)
                        else ()
                    return
                        (: a) g has been used for resolving abbreviations (in early texts W0004, W0013 and W0015) -> treat it like choice elements :)
                        if (not($thisString = ($precomposedString, $composedString)) and not($charCode) = ('char017f', 'char0292')) then
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
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else
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
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            concat(
                'heading', 
                (if (count($node/(parent::tei:back|parent::tei:div[@type ne "work_part"]|parent::tei:front|parent::tei:list|parent::tei:titlePart)/tei:head) gt 1) then          
                    (: we have several headings on this level of the document ... :)
                    string(count($node/preceding-sibling::tei:head) + 1)
                 else ())
            )
        
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
            let $specificAlignElems := ('head', 'signed') (: TODO: add more names here when necessary :)
            let $cssStyles := 
                for $s in $styles return
                    if ($s eq '#b') then 'font-weight:bold;'
                    else if ($s eq '#it') then 'font-style:italic;'
                    else if ($s eq '#rt') then 'font-style: normal;'
                    else if ($s eq '#l-indent') then 'display:block;margin-left:4em;'
                    (: centering and right-alignment apply only in certain contexts :)
                    else if ($s eq '#r-center'
                             and not($node/ancestor::*[local-name(.) = $specificAlignElems])
                             and not($node/following-sibling::node()[descendant-or-self::text()[not(normalize-space() eq '')]]
                                     and $node/ancestor::tei:p[1][.//text()[not(ancestor::tei:hi[contains(@rendition, '#r-center')])]])
                         ) then
                             (: workaround for suppressing trailing centerings at the end of paragraphs :)
                         'display:block;text-align:center;'
                    else if ($s eq '#right' and not($node/ancestor::*[local-name(.) = $specificAlignElems])) then 
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
        case 'title' 
        case 'html-title' return
            normalize-space(
                if ($node/parent::tei:list/@type='dict' and $node//tei:term[1][@key]) then
                    (: TODO: collision with div/@type='lemma'? :)
                    concat(
                        '&#34;',
                            concat(
                                $node//tei:term[1]/@key,
                                if (count($node/parent::tei:list/tei:item[.//tei:term[1]/@key eq $node//tei:term[1]/@key]) gt 1) then
                                    concat(
                                        ' - ', 
                                        count($node/preceding::tei:item[tei:term[1]/@key eq $node//tei:term[1]/@key] 
                                              intersect $node/ancestor::tei:div[1]//tei:item[tei:term[1]/@key eq $node//tei:term[1]/@key]) 
                                        + 1)
                                else ()
                            ),
                        '&#34;'
                    )
                else if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '&#34;' || string($node/@n) || '&#34;'
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
           <span class="label-inline">
               {render:passthru($node, $mode)}
           </span>
           
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
        case 'title' 
        case 'html-title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '&#34;' || string($node/@n) || '&#34;'
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
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'passagetrail' return
            ()
        
        case 'citetrail' return
            (: dictionaries, indices and summaries get their type prepended to their number :)
            if($node/@type = ('dict', 'index', 'summaries')) then
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
        case "orig" return
            ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case "edit" return
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
                    '&#34;' || string($node/@n) || '&#34;'
                (: purely numeric section titles: :)
                else if ($node/@n and matches($node/@n, '^[0-9\[\]]+$') and $node/@unit) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    render:teaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
            (: TODO: bring i18n labels somehow into html-title... :)
            
        case 'class' return
            'tei-milestone-' || $node/@unit
            
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
    if ($mode = "orig") then
        render:passthru($node, $mode)
    
    else if ($mode = "edit") then
        if ($node/(@key|@ref)) then
            (render:passthru($node, $mode), ' [', string-join(($node/@key, $node/@ref), '/'), ']')
        else
            render:passthru($node, $mode)
    
    else
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
            render:name($mode, $node)
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
                        {render:passthru($node, $mode)}
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
                <div class="hauptText">
                    {render:HTMLSectionToolbox($node)}
                    {' '}
                    {render:passthru($node, $mode)}
                </div>
        
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
                    (: prepend volume prefix? :)
                    let $volumeString := ()
                        (:if ($node/ancestor::tei:text[@type='work_volume']) then 
                            concat('Vol. ', $node/ancestor::tei:text[@type='work_volume']/@n, ', ') 
                        else ():)
                    return if (contains($node/@n, 'fol.')) then $volumeString || $node/@n
                    else $volumeString || 'p. ' || $node/@n
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            (: "pX" where X is page number :)
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
            (: not(@sameAs or @corresp) should be checked upstream (render:isIndexNode()) :)
            let $inlineBreak :=
                if ($node[@type eq 'blank']) then (: blank pages - make a typographic line break :)
                    <br/>
                else if ($node[preceding::pb 
                               and preceding-sibling::node()[descendant-or-self::text()[not(normalize-space() eq '')]]                                                                                
                               and following-sibling::node()[descendant-or-self::text()[not(normalize-space() eq '')]]]) then
                    (: mark page break through pipe, but not at the beginning or end of structural sections :)
                    if ($node/@break eq 'no') then '|' else ' | '
                else ()
            let $link :=
                if ($node[@n]) then
                    let $pageAnchor := 'pageNo_' || (if ($node/@xml:id) then $node/@xml:id/string() else generate-id($node))
                    let $title := if (contains($node/@n, 'fol.')) then 'View image of ' || $node/@n else 'View image of p. ' || $node/@n
                    let $text := if (contains($node/@n, 'fol.')) then $node/@n else 'p. ' || $node/@n
                    return
                        <div class="pageNumbers">
                           <a href="{render:resolveFacsURI($node/@facs)}">
                               <i class="fas fa-book-open facs-icon"/>
                               {' '}
                               <span class="pageNo messengers" data-canvas="{render:resolveCanvasID($node)}"
                                   data-sal-id="{render:getHTMLSectionId($node)}" id="{$pageAnchor}" title="{$title}">
                                   {$text}
                               </span>
                           </a>
                        </div>
                else ()
            return ($inlineBreak, $link)
                    
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

declare function render:resolveCanvasID($pb as element(tei:pb)) as xs:string {
    let $facs := $pb/@facs/string()
    return
        if (matches($facs, '^facs:W[0-9]{4}-[A-z]-[0-9]{4}$')) then 
            let $index := string(count($node/preceding::pb[not(@sameAs) and substring(./@facs, 1, 12) eq substring($facs, 1, 12)]) + 1)
            return $config:imageserver || '/iiif/presentation/' || sal-util:convertVolumeID(substring($facs,6,7)) || '/canvas/p' || $index
        else if (matches($facs, '^facs:W[0-9]{4}-[0-9]{4}$')) then
            let $index := string(count($node/preceding::pb[not(@sameAs)]) + 1)
            return $config:imageserver || '/iiif/presentation/' || substring($facs,6,5) || '/canvas/p' || $index
        else error(xs:QName('render:resolveCanvasID'), 'Unknown pb/@facs value')
};

declare function render:resolveFacsURI($facs as attribute()) as xs:string {
    let $iiifRenderParams := '/full/full/0/default.jpg'
    return
        if (matches($facs, 'facs:(W[0-9]{{4}})\-([0-9]{{4}})')) then (: single-volume work, e.g.: facs:W0017-0005 :)
            let $workId := replace($facs, 'facs:(W[0-9]{{4}})\-([0-9]{{4}})', '$1')
            let $facsId := replace($facs, 'facs:(W[0-9]{{4}})\-([0-9]{{4}})', '$2')
            return 
                $config:imageserver || '/iiif/image/' || $workId || '!' || $workId || '-' || $facsId || $iiifRenderParams
        else if (matches($facs, 'facs:(W[0-9]{{4}})\-([A-z])\-([0-9]{{4}})')) then (: volume of a multi-volume work, e.g.: facs:W0013-A-0007 :)
            let $workId := replace($facs, 'facs:(W[0-9]{{4}})\-([A-z])\-([0-9]{{4}})', '$1')
            let $volId := replace($facs, 'facs:(W[0-9]{{4}})\-([A-z])\-([0-9]{{4}})', '$2')
            let $facsId := replace($facs, 'facs:(W[0-9]{{4}})\-([A-z])\-([0-9]{{4}})', '$3')
            return $config:imageserver || '/iiif/image/' || $workId || '!' || $volId || '!' || $workId 
                        || '-' || $volId || '-' || $facsId || $iiifRenderParams
        else error(xs:QName('render:pb'), 'Illegal facs ID (pb/@facs): ' || $facs)

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
        default return
            render:name($mode, $node)
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
        default return
            render:name($mode, $node)
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
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else
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


declare function render:supplied($node as element(tei:supplied), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (<span class="original unsichtbar" title="{string($node)}">{'[' || $node/text() || ']'}</span>,
            <span class="edited" title="{concat('[', string($node), ']')}">{$node/text()}</span>)
            
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
        
        case "edit" return
            if ($node/@key) then
                (render:passthru($node, $mode), ' [', string($node/@key), ']')
            else
                render:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                render:passthru($node, $mode)
        
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
        
        case 'snippets-orig' 
        case 'snippets-edit' return 
            $node
        
        default return ()
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
        default return
            render:name($mode, $node)
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
            (: distinguishing first and subsequent titlePage(s) for rendering them differently :)
            if ($node[not(preceding::titlePage)]) then
                <div class="titlePage">
                    {render:passthru($node, $mode)}
                </div>
            else
                <div class="sec-titlePage">
                    {render:passthru($node, $mode)}
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


(: TODO: still undefined: titlePage descendants: titlePart, docTitle, ...; choice, l; author fields: state etc. :)

