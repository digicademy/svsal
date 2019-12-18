xquery version "3.1";

module namespace html              = "https://www.salamanca.school/factory/works/html";
declare namespace exist            = "http://exist.sourceforge.net/NS/exist";
declare namespace output           = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";
declare namespace i18n             = 'http://exist-db.org/xquery/i18n';
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace config     = "http://www.salamanca.school/xquery/config" at "../../modules/config.xqm";
import module namespace app        = "http://www.salamanca.school/xquery/app"    at "../../modules/app.xql";
import module namespace sutil   = "http://www.salamanca.school/xquery/sutil" at "../../modules/sutil.xql";
import module namespace index      = "https://www.salamanca.school/factory/works/index"    at "index.xqm";
import module namespace txt        = "https://www.salamanca.school/factory/works/txt" at "txt.xqm";


(: ####++++----  

    Utility functions for transforming TEI nodes to html.
   
   ----++++#### :)



(: SETTINGS :)

(: the max. amount of characters to be shown in a note teaser :)
declare variable $html:noteTruncLimit := 33;
(: the max. amount of characters to be shown in a title teaser :)
declare variable $html:titleTruncLimit := 15;

declare variable $html:basicElemNames := ('p', 'head', 'note', 'item', 'cell', 'label', 'signed', 'lg', 'titlePage');



(: HTML UTIL FUNCTIONS :)

(:
~ Determines which nodes to make HTML teasers for (subset of //*[index:isIndexNode(.)] excluding low-level elements). 
    Should mostly be used together with html:makeSummaryTitle()
:)
declare function html:isCitableWithTeaser($node as node()) as xs:boolean {
    boolean(
        not(index:isBasicNode($node)) and
        (
            (index:isStructuralNode($node) and $node[self::tei:div or self::tei:text]) or
            index:isAnchorNode($node)
            (: TODO: lists here? :)
        ) and
        html:dispatch($node, 'html-title') (: if there is no title, we won't make a teaser :)
    )
};


declare function html:preparePagination($work as element(tei:TEI), $lang as xs:string?, $fragmentIds as map()?) as element(ul) {
    let $workId := $work/@xml:id
    return 
        <ul id="later" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1">{
            for $pb in $work//tei:text//tei:pb[index:isIndexNode(.) and not(@sameAs or @corresp)] return
                let $fragment := $fragmentIds($pb/@xml:id/string()) (:$pb/sal:fragment:)
                let $url      := 'work.html?wid=' || $workId || '&amp;frag=' || $fragment || '#' || concat('pageNo_', $pb/@n)
                return 
                    <li role="presentation"><a role="menuitem" tabindex="-1" href="{$url}">{normalize-space($pb/sal:title)}</a></li>
        }</ul>
};


(:
~ Recursively creates a TOC list (of lists...) for a sequence of nodes.
:)
declare function html:generateTocFromDiv($nodes as element()*, $wid as xs:string) as element(ul)* {
    for $node in $nodes/(tei:div[@type="work_part"]/tei:div[index:isIndexNode(.)]
                         |tei:div[not(@type="work_part")][index:isIndexNode(.)]
                         |*/tei:milestone[@unit ne 'other'][index:isIndexNode(.)]) return
        let $fragTrail := sutil:getNodetrail($wid, $node, 'citetrail')        
        let $fragId := $config:idserver || '/texts/' || $wid || ':' || $fragTrail || '?format=html'
        let $section := $node/@xml:id/string()
        let $i18nKey := 
            if (index:dispatch($node, 'class')) then index:dispatch($node, 'class')
            else 'tei-generic'
        let $label := ('[', <i18n:text key="{$i18nKey}"/>, ']')
        let $titleString := index:dispatch($node, 'title')
        let $titleAtt := '[i18n(' || $i18nKey || ')] ' || $titleString
(:        let $titleElems := html:makeTOCTitle($node):)
        (: title="{$title}" :)
        return 
            <ul>
                <li>
                    <a class="hideMe" href="{$fragId}" title="{$titleAtt}">
                        {($label, ' ', $titleString)}
                        <span class="jstree-anchor hideMe pull-right">{html:getPagesFromDiv($node)}</span>
                    </a>
                    {html:generateTocFromDiv($node, $wid)}
                </li>
            </ul>
};

declare function html:makeTOCTitle($node as node()) as item()* {
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
    let $titleString := index:dispatch($node, 'title')
    return
        ($divLabel, ' ', $titleString)
};

declare function html:getPagesFromDiv($div) {
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
declare function html:makeAncestorTeasers($fragmentRoot as element()) {
    (: determine whether fragment is first structural element of volume :)
    if ($fragmentRoot[ancestor-or-self::tei:text[@type eq 'work_volume'] 
                      and not(preceding::*[self::tei:div or self::tei:titlePage] 
                              intersect ancestor-or-self::tei:text[@type eq 'work_volume']//*[self::tei:div or self::tei:titlePage])]) then
        let $delimiter := 
            if ($fragmentRoot/ancestor-or-self::tei:text[@type='work_volume']/preceding::tei:text[@type='work_volume']) then 
                <hr/> 
            else ()
        let $sumTitle := html:makeSummaryTitle($fragmentRoot/ancestor-or-self::tei:text[@type eq 'work_volume'])
        return ($delimiter, $sumTitle)
    else ()        
    
    (: functionality for generic ancestor teaser creation - needs debugging; what about ancestor headings (tei:head?) (TODO) :)
    (:if (not($fragmentRoot/preceding-sibling::*)) then
        let $ancestorTeasers :=
            for $a in $fragmentRoot/ancestor::*[html:isCitableWithTeaser(.) and not(preceding-sibling::*
                                                                                          or self::tei:text[@type eq 'work_volume'])] return
                html:makeSummaryTitle($a) (\: TODO: wrong order? :\)
        let $volTeaser :=
            (\: if fragment is first structural element of volume, also make a "Vol." teaser :\)
            if ($fragmentRoot[ancestor-or-self::tei:text[@type eq 'work_volume'] 
                              and not(preceding::*[self::tei:div or self::tei:titlePage] 
                                      intersect ancestor-or-self::tei:text[@type eq 'work_volume']//*[self::tei:div or self::tei:titlePage])]) then
                let $delimiter := 
                    if ($fragmentRoot/ancestor-or-self::tei:text[@type='work_volume']/preceding::tei:text[@type='work_volume']) then 
                        <hr/> 
                    else ()
                let $sumTitle := html:makeSummaryTitle($fragmentRoot/ancestor-or-self::tei:text[@type eq 'work_volume'])
                return ($delimiter, $sumTitle)
            else ()
        return ($volTeaser, $ancestorTeasers)
    else ():)
};

(:
~ Creates a section title, which appears to the left of the main area.
:)
declare function html:makeSummaryTitle($node as element()) as element(div) {
    let $toolbox := html:makeSectionToolbox($node)
    let $fullTitle := 
        <span class="section-title-text">{
            if ($node/self::tei:text[@type='work_volume']) then <b>{html:dispatch($node, 'html-title')}</b>
            else html:dispatch($node, 'html-title')
        }</span>
    (: make anchors according to the amount of structural ancestors so that JS knows what to highlight: :)
    let $levels := count($node/ancestor::*[index:isStructuralNode(.)])
    let $levelAnchors := for $l in (1 to $levels) return <a style="display:none;" class="div-l-{$l}"/>
    return
        <div class="section-title container" id="{$node/@xml:id}">
            {$toolbox}
            <div class="section-title-body">{
                if (string-length(string($fullTitle)) gt $html:titleTruncLimit) then
                    let $id := 'collapse-' || $node/@xml:id
                    return
                        <a role="button" class="collapsed title-teaser" data-toggle="collapse" href="{('#' || $id)}" 
                           aria-expanded="false" aria-controls="{$id}">    
                            <p class="collapse" id="{$id}" aria-expanded="false">
                                {$fullTitle}
                            </p>
                        </a>
                else 
                    $fullTitle
            }</div>
            {$levelAnchors}
        </div>
};


(:
~ Renders a marginal element (currently all tei:note as well as label[@place eq 'margin']; head[@place eq 'margin'] are treated as ordinary head)
:)
declare function html:makeMarginal($node as element()) as element(div) {
    let $label := if ($node/@n) then <span class="note-label">{$node/@n || ' '}</span> else ()
    let $content :=
        if ($node/tei:p) then 
            html:passthru($node, 'html')
        else
            <span class="note-paragraph">{html:passthru($node, 'html')}</span>
    (: determine string-length of complete note text, so as to see whether note needs to be truncated: :)
    let $noteLength := 
        string-length((if ($label) then $node/@n || ' ' else ()) || normalize-space(replace(string-join(txt:dispatch($node, 'edit'), ''), '\[.*?\]', '')))
    let $toolbox := html:makeSectionToolbox($node)
    return
        <div class="marginal container" id="{$node/@xml:id}">
            {$toolbox}
            <div class="marginal-body">{
                if ($noteLength gt $html:noteTruncLimit) then
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
~ Creates a toolbox including export and link buttons. Should be placed as preceding sibling of the element that
~ it refers to for JS (highlighting etc.) to work correctly. 
:)
declare function html:makeSectionToolbox($node as element()) as element(div) {
    let $id := $node/@xml:id/string()
    let $wid := $node/ancestor::tei:TEI/@xml:id
    let $fileDesc := $node/ancestor::tei:TEI/tei:teiHeader/tei:fileDesc
    let $class := 
        if (index:isMarginalNode($node)) then 
            'sal-toolbox-marginal' 
        else if (html:isCitableWithTeaser($node)) then
            'sal-toolbox-title'
        else 'sal-toolbox'
    let $i18nSuffix := (: Suffix for determining what kind of description to display :) 
        if ($class eq 'sal-toolbox-title' or $node/self::tei:titlePage) then 'Sect' 
        else if ($class eq 'sal-toolbox') then 'Para' 
        else 'Note'
    let $citetrailBaseUrl := html:makeCitetrailURI($node)
    return
        <div class="{$class}">
            <a id="{$id}" href="#" data-rel="popover" class="sal-tb-a"><!-- href="{('#' || $id)}" -->
                <i class="fas fa-hand-point-right messengers" title="{concat('i18n(openToolbox', $i18nSuffix, ')')}"/>
            </a>
            <div class="sal-toolbox-body">
                <div class="sal-tb-btn" title="{concat('i18n(link', $i18nSuffix, ')')}">
                    <button onclick="copyLink(this); return false;" class="messengers">
                        <i class="fas fa-link"/>{' '}<i18n:text key="copyLink"/>
                    </button>
                    <span class="cite-link" style="display:none;">{$citetrailBaseUrl || '?format=html'}</span>
                </div>
                <div class="sal-tb-btn" title="{concat('i18n(cite', $i18nSuffix, ')')}">
                    <button onclick="copyCitRef(this); return false;" class="messengers">
                        <i class="fas fa-feather-alt"/>{' '}<i18n:text key="copyCit"/>
                    </button>
                    <span class="sal-cite-rec" style="display:none">
                        {app:HTMLmakeCitationReference($wid, $fileDesc, 'reading-passage', $node)}
                    </span>
                </div>
                <div class="sal-tb-btn dropdown" title="{concat('i18n(txtExp', $i18nSuffix, ')')}">
                    <button class="dropdown-toggle messengers" data-toggle="dropdown">
                        <i class="fas fa-align-left" title="i18n(txtExpPass)"/>{' '}<i18n:text key="txtExpShort"/>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="{$citetrailBaseUrl || '?format=txt&amp;mode=edit'}"><i class="messengers fas fa-align-left" title="i18n(downloadTXTEdit)"/>{' '}<i18n:text key="constitutedLower">constituted</i18n:text></a></li>
                        <li><a href="{$citetrailBaseUrl || '?format=txt&amp;mode=orig'}"><i class="messengers fas fa-align-left" title="i18n(downloadTXTOrig)"/>{' '}<i18n:text key="diplomaticLower">diplomatic</i18n:text></a></li>
                    </ul>
                </div>
                <div class="sal-tb-btn" title="{concat('i18n(teiExp', $i18nSuffix, ')')}">
                    <button class="messengers" onclick="window.location.href = '{$citetrailBaseUrl || '?format=tei'}'">
                        <i class="fas fa-file-code" />{' '}<i18n:text key="teiExpShort"/>
                    </button>
                </div>
                <div class="sal-tb-btn" style="display:none;">
                    <a class="updateHiliteBox" href="#"> 
                        <i class="glyphicon glyphicon-refresh"/>
                    </a>
                </div>
            </div>
        </div>
};

declare function html:makePagination($node as node()?, $model as map(*)?, $wid as xs:string?, $lang as xs:string?) {
    let $workId :=  
        if ($wid) then 
            if (contains($wid, '_')) then substring-before(sutil:normalizeId($wid), '_') 
            else sutil:normalizeId($wid)
        else substring-before($model('currentWorkId'), '_')
    return 
        <ul id="later" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1">{
            for $pb in doc($config:index-root || '/' || $workId || '_nodeIndex.xml')//sal:node[@type='pb'][not(starts-with(sal:title, 'sameAs') or starts-with(sal:title, 'corresp'))]
                let $fragment := $pb/sal:fragment
                let $url      := $config:idserver || '/texts/' || $workId || ':' || $pb/sal:citetrail/text() 
                (:'work.html?wid=' || $workId || '&amp;frag=' || $fragment || '#' || concat('pageNo_', $pb/@n):)
                return 
                    <li role="presentation"><a role="menuitem" tabindex="-1" href="{$url}">{normalize-space($pb/sal:title)}</a></li>
        }</ul>
};


declare function html:makeClassableString($str as xs:string) as xs:string? {
    replace($str, '[,: ]', '')
};


declare function html:createFragment($workId as xs:string, $fragmentRoot as element(), $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) as element(div) {
    (: SvSalPage: main area (id/class page in order to identify page-able content :)
    <div class="row" xml:space="preserve">
        <div class="col-md-12">
            <div id="SvSalPages">
                <div class="SvSalPage">                
                    {
                    if ($fragmentRoot[not(preceding-sibling::*) and not((ancestor::body|ancestor::back) and preceding::front/*)]) then
                        html:makeAncestorTeasers($fragmentRoot)
                    else ()    
                    }
                    {html:dispatch($fragmentRoot, 'html')}
                </div>
            </div>
        </div>
        {html:createPaginationLinks($workId, $fragmentIndex, $prevId, $nextId) (: finally, add pagination links :)}
    </div>
    (: the rest (to the right, in col-md-12) is filled by _spans_ of class marginal, possessing
         a negative right margin (this happens in eXist's work.html template) :)
};


declare function html:createPaginationLinks($workId as xs:string, $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) {
    let $prevLink :=
        if ($prevId) then
            let $link := 'work.html?wid=' || $workId || '&amp;frag=' || index:makeFragmentId($fragmentIndex - 1, $prevId)
            return
                (<a class="previous" href="{$link}">prev</a>, ' | ')
        else ()
    let $top := <a class="top" href="work.html?wid={$workId}">top</a>
    let $nextLink :=
        if ($nextId) then
            let $link := 'work.html?wid=' || $workId || '&amp;frag=' || index:makeFragmentId($fragmentIndex + 1, $nextId)
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
declare function html:determineListType($node as element()) as xs:string? {
    if ($node[self::tei:list and @type]) then $node/@type
    else if ($node/ancestor::tei:list[@type]) then $node/ancestor::tei:list[@type][1]/@type
    else () (: fall back to simple? :)
};


declare function html:resolveCanvasID($pb as element(tei:pb)) as xs:string {
    let $facs := normalize-space($pb/@facs/string())
    return
        if (matches($facs, '^facs:W[0-9]{4}-[A-z]-[0-9]{4}$')) then 
            let $index := string(count($pb/preceding::tei:pb[not(@sameAs) and substring(@facs, 1, 12) eq substring($facs, 1, 12)]) + 1)
            return $config:imageserver || '/iiif/presentation/' || sutil:convertVolumeID(substring($facs,6,7)) || '/canvas/p' || $index
        else if (matches($facs, '^facs:W[0-9]{4}-[0-9]{4}$')) then
            let $index := string(count($pb/preceding::tei:pb[not(@sameAs)]) + 1)
            return $config:imageserver || '/iiif/presentation/' || substring($facs,6,5) || '/canvas/p' || $index
        else error(xs:QName('html:resolveCanvasID'), 'Unknown pb/@facs value')
};


declare function html:resolveFacsURI($facsTargets as xs:string) as xs:string {
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
        else error(xs:QName('html:pb'), 'Illegal facs ID (pb/@facs): ' || $facs)
};


(:
~ Transforms a $node into an HTML link anchor (a[@href]), dispatching all its content ((html:dispatch())) and, if required,
    preventing tei:pb from occurring within the link.
:)
declare function html:transformToLink($node as element(), $uri as xs:string) {
    if (not($node/tei:pb)) then
        <a href="{$uri}" target="_blank">{html:passthru($node, 'html')}</a>
    else
        (: make an anchor for the preceding part, then render the pb, then "continue" the anchor :)
        (: TODO: ATM, this works only if pb occurs at the child level, and only with the first pb :)
        let $before :=
            <a href="{$uri}" target="_blank">
                {for $n in $node/tei:pb[1]/preceding-sibling::node() return html:dispatch($n, 'html')}
            </a>
        let $break := html:dispatch($node/tei:pb[1], 'html')
        let $after :=
            <a href="{$uri}" target="_blank">
                {for $n in $node/tei:pb[1]/following-sibling::node() return html:dispatch($n, 'html')}
            </a>
        return
            ($before, $break, $after)
};



(:
~ For a node, make a full-blown URI including the citetrail of the node
:)
declare function html:makeCitetrailURI($node as element()) as xs:string? {
    let $citetrail := sutil:getNodetrail($node/ancestor::tei:TEI/@xml:id, $node, 'citetrail')
    let $workId := $node/ancestor::tei:TEI/@xml:id
    return
        if ($citetrail) then $config:idserver || '/texts/' || $workId || ':' || $citetrail
        else ()
};


(: TODO: debugging with references to extratextual entities :)
declare function html:resolveURI($node as element(), $targets as xs:string) {
    let $currentWork := $node/ancestor-or-self::tei:TEI
    let $target := (tokenize($targets, ' '))[1]
    let $prefixDef := $currentWork//tei:prefixDef
    let $workScheme := '(work:(W[A-z0-9.:_\-]+))?#(.*)'
    let $facsScheme := 'facs:((W[0-9]+)[A-z0-9.:#_\-]+)'
    let $genericScheme := '(\S+):([A-z0-9.:#_\-]+)'
    return
        if (starts-with($target, '#') and $currentWork//*[@xml:id eq substring($target, 2)]) then
            (: target is some node within the current work :)
            html:makeCitetrailURI($currentWork//*[@xml:id eq substring($target, 2)])
        else if (matches($target, $workScheme)) then
            (: target is something like "work:W...#..." :)
            let $targetWorkId :=
                if (replace($target, $workScheme, '$2')) then (: Target is a link containing a work id :)
                    replace($target, $workScheme, '$2')
                else $currentWork/@xml:id/string() (: Target is just a link to a fragment anchor, so targetWorkId = currentWork :)
            let $anchorId := replace($target, $workScheme, '$3')
            return 
                if ($anchorId) then html:makeCitetrailURI($node) else ()
        else if (matches($target, $facsScheme)) then (: Target is a facs string :)
            (: Target does not contain "#", or is not a "work:..." url: :)
            let $targetWorkId :=
                if (replace($target, $facsScheme, '$2')) then (: extract work id from facs string :)
                    replace($target, $facsScheme, '$2')
                else $currentWork/@xml:id/string()
            let $anchorId := replace($target, $facsScheme, '$1') (: extract facs string :)
            return
                html:makeCitetrailURI($node)
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


(: ####====---- TEI NODE TYPESWITCH FUNCTIONS ----====#### :)

(:  MODES: 
~   - 'html': HTML snippet for the reading view
~   - 'html-title': a full version of the title, for toggling of teasers in the reading view (often simply falls back to index:dispatch($node, 'title'))
:)

(:
~ @param $node : the node to be dispatched
~ @param $mode : the mode for which the function shall generate results
:)
declare function html:dispatch($node as node(), $mode as xs:string) {
    let $rendering :=
        typeswitch($node)
        (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
            case text()                     return html:textNode($node, $mode)
            case element(tei:g)             return html:g($node, $mode)
            case element(tei:lb)            return html:lb($node, $mode)
            case element(tei:pb)            return html:pb($node, $mode)
            case element(tei:cb)            return html:cb($node, $mode)
    
            case element(tei:head)          return html:head($node, $mode) (: snippets: passthru :)
            case element(tei:p)             return html:p($node, $mode)
            case element(tei:note)          return html:note($node, $mode)
            case element(tei:div)           return html:div($node, $mode)
            case element(tei:milestone)     return html:milestone($node, $mode)
            
            case element(tei:choice)        return html:choice($node, $mode)
            case element(tei:abbr)          return html:abbr($node, $mode)
            case element(tei:orig)          return html:orig($node, $mode)
            case element(tei:sic)           return html:sic($node, $mode)
            case element(tei:expan)         return html:expan($node, $mode)
            case element(tei:reg)           return html:reg($node, $mode)
            case element(tei:corr)          return html:corr($node, $mode)
            
            case element(tei:persName)      return html:persName($node, $mode)
            case element(tei:placeName)     return html:placeName($node, $mode)
            case element(tei:docAuthor)     return html:docAuthor($node, $mode)
            case element(tei:orgName)       return html:orgName($node, $mode)
            case element(tei:pubPlace)      return html:pubPlace($node, $mode)
            case element(tei:publisher)     return html:publisher($node, $mode)
            case element(tei:title)         return html:title($node, $mode)
            case element(tei:term)          return html:term($node, $mode)
            case element(tei:bibl)          return html:bibl($node, $mode)
    
            case element(tei:hi)            return html:hi($node, $mode) 
            case element(tei:ref)           return html:ref($node, $mode) 
            case element(tei:quote)         return html:quote($node, $mode)
            case element(tei:soCalled)      return html:soCalled($node, $mode)
    
            case element(tei:list)          return html:list($node, $mode)
            case element(tei:item)          return html:item($node, $mode)
            
            case element(tei:lg)            return html:lg($node, $mode)
            case element(tei:l)             return html:l($node, $mode)
            
            case element(tei:signed)        return html:signed($node, $mode) 
            
            case element(tei:titlePage)     return html:titlePage($node, $mode)
            case element(tei:titlePart)     return html:titlePart($node, $mode)
            case element(tei:byline)        return html:byline($node, $mode)
            case element(tei:imprimatur)    return html:imprimatur($node, $mode)
            case element(tei:docImprint)    return html:docImprint($node, $mode)
            
            case element(tei:label)         return html:label($node, $mode)
            case element(tei:argument)      return html:argument($node, $mode)
            
            case element(tei:gap)           return html:gap($node, $mode)
            case element(tei:supplied)      return html:supplied($node, $mode)
            case element(tei:unclear)       return html:unclear($node, $mode)
            case element(tei:del)           return html:del($node, $mode)
            case element(tei:space)         return html:space($node, $mode)
            
            case element(tei:figure)        return html:figure($node, $mode)
            
            case element(tei:text)          return html:text($node, $mode) 
    
            case element(tei:table)         return html:table($node, $mode)
            case element(tei:row)           return html:row($node, $mode)
            case element(tei:cell)          return html:cell($node, $mode)
            
            case element(tei:foreign)       return html:foreign($node, $mode)
            
            case element(tei:figDesc)       return ()
            case element(tei:teiHeader)     return ()
            case element(tei:fw)            return ()
            case comment()                  return ()
            case processing-instruction()   return ()
    
            default return html:passthru($node, $mode)
    (: for fine-grained debugging: :)
    (:let $debug := 
        if (index:isIndexNode($node)) then 
            util:log('warn', '[RENDER] Processing node tei:' || local-name($node) || ', with @xml:id=' || $node/@xml:id) 
        else ():)
    return
        if ($mode eq 'html') then
            if (html:isCitableWithTeaser($node)) then
                let $citationAnchor := html:makeSummaryTitle($node)
                return ($citationAnchor, $rendering)
            else if (index:isBasicNode($node)) then 
                (: toolboxes need to be on the sibling axis with the text body they refer to... :)
                if (index:isMarginalNode($node) 
                    or $node/self::tei:head 
                    or $node/self::tei:argument (: no toolboxes for 'heading' elements such as head and argument :)
                    or $node/self::tei:titlePage (: toolbox is produced in html:titlePage :)
                    or $node/self::tei:p[ancestor::tei:list] (: we do not make toolboxes for p within list :)
                    or $node[ancestor::tei:list and ancestor::tei:div[@type eq 'contents']] (: TOC list elements do not need to be citable :)
                    ) then 
                    (: for these elements, $toolboxes are created right in their html: function if required :)
                    $rendering
                else 
                    let $toolbox := html:makeSectionToolbox($node)
                    return
                        <div class="hauptText">
                            {$toolbox}
                            <div class="hauptText-body">{$rendering}</div>
                        </div>
            else $rendering
        else 
            $rendering
};



(: ELEMENT FUNCTIONS :)


declare function html:abbr($node as element(tei:abbr), $mode) {
  