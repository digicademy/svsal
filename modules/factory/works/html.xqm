xquery version "3.1";

(: ####++++----

    Utility functions for transforming TEI nodes to html.
   
   ----++++#### :)

module namespace html              = "https://www.salamanca.school/factory/works/html";

declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";

declare namespace exist            = "http://exist.sourceforge.net/NS/exist";
declare namespace output           = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace util             = "http://exist-db.org/xquery/util";

import module namespace console    = "http://exist-db.org/xquery/console";

import module namespace config     = "http://www.salamanca.school/xquery/config"        at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace i18n       = "http://exist-db.org/xquery/i18n"                  at "xmldb:exist:///db/apps/salamanca/modules/i18n.xqm";
import module namespace sutil      = "http://www.salamanca.school/xquery/sutil"         at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";
import module namespace index      = "https://www.salamanca.school/factory/works/index" at "xmldb:exist:///db/apps/salamanca/modules/factory/works/index.xqm";
import module namespace txt        = "https://www.salamanca.school/factory/works/txt"   at "xmldb:exist:///db/apps/salamanca/modules/factory/works/txt.xqm";



(: SETTINGS :)

declare option exist:timeout "166400000"; (: in miliseconds, 25.000.000 ~ 7h, 43.000.000 ~ 12h :)
declare option exist:output-size-limit "5000000"; (: max number of nodes in memory :)

(: the max. amount of characters to be shown in a note teaser :)
declare variable $html:noteTruncLimit := 33;
(: the max. amount of characters to be shown in a title teaser :)
declare variable $html:titleTruncLimit := 15;

declare variable $html:basicElemNames := ('p', 'head', 'note', 'item', 'cell', 'label', 'signed', 'lg', 'titlePage');

declare variable $html:defaultLang := collection($config:i18n-root)/*:catalogue[@xml:lang="de"];

(: sometimes, we want to i18n-look up simple strings, but exist's i18n functions need nodes as input arguments, so we wrap our strings here :)
declare function html:i18nNodify($s as xs:string) {
    <msg key="{$s}">{$s}</msg>
};



(: 
~ Controller function for creating (and informing about) HTML fragments, pagination lists, and TOCs
:)
declare function html:makeHTMLData($tei as element(tei:TEI)) as map(*) {
    html:makeHTMLData($tei, $html:defaultLang)
};

declare function html:makeHTMLData($tei as element(tei:TEI), $lang as node()*) as map(*) {
    let $work := util:expand($tei)
    let $fragmentationDepth := index:determineFragmentationDepth($tei)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Rendering " || string($tei/@xml:id) || " (" || xs:string($html:defaultLang/@xml:lang) || ") at fragmentation level " || $fragmentationDepth || " ...") else ()

    let $target-set := index:getFragmentNodes($work, $fragmentationDepth)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] " || string(count($target-set)) || " elements to be rendered as fragments ...") else ()

    let $workId := $work/@xml:id
    let $text := $work//tei:text[@type='work_volume'] | $work//tei:text[@type = 'work_monograph']
    let $elements := $work//tei:text[@type = 'work_monograph']/(tei:front | tei:body | tei:back)  
    let $title := sutil:WRKcombined($work, (), $workId)

    (: (1) table of contents :)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Creating ToC file for " || $workId || " ...") else ()
    let $toc :=     
        <div id="tableOfConts">
            <ul>
                <li>
                    <b>{$title}</b>
                    {
                    if (not($work//tei:text[@type='work_volume'])) then
                        <span class="jstree-anchor hideMe pull-right">{html:getPagesFromDiv($text)}</span>
                    else ()
                    }
                    {
                    if ($work//tei:text[@type='work_volume']) then 
                        for $a in $work//tei:text where $a[@type='work_volume' and sutil:WRKisPublished($workId || '_' || @xml:id)] return
                            <ul>
                                <li>
                                    <a class="hideMe">
                                        <b>{concat(i18n:getLocalizedText(html:i18nNodify('volume'), $lang), ': ', $a/@n/string())}</b>
                                        <span class="jstree-anchor hideMe pull-right">{html:getPagesFromDiv($a)}</span>
                                    </a>
                                    { html:generateTocFromDiv($a/(tei:front | tei:body | tei:back), $workId, $lang)}
                                </li>
                            </ul>
                    else html:generateTocFromDiv($elements, $workId, $lang)
                    }
                </li>
            </ul>
        </div>
    
    (: (2) pagination :)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Creating pagination ...") else ()
    let $pages :=  html:makePagination((), (), $workId)

    (: (3) fragments :)
    (: TODO: Mysteriously, if you look at top or a similar tool, the following seems to run mainly on one processor core only... :)
    (: get "previous" and "next" fragment ids and hand the current fragment over to the renderFragment function :)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Rendering fragments (new method) ...") else ()
    let $fragments := 
        for $section at $index in $target-set
            let $debug :=   if ($config:debug = ("trace", "info") and ($index mod 50 eq 0)) then
                                console:log("[HTML] HTML rendering: processing fragment no. " || string($index)  || " ...")
                            else ()
            let $prev   :=  
                if ($index > 1) then
                    $target-set[(xs:integer($index) - 1)]
                else ()
            let $next   :=  
                if ($index < count($target-set)) then
                    $target-set[(xs:integer($index) + 1)]
                else ()
            let $prevId :=  
                if ($prev) then
                    xs:string($prev/@xml:id)
                else ()
            let $nextId := 
                if ($next) then
                    xs:string($next/@xml:id)
                else ()
            let $result := html:renderFragment($work, xs:string($workId), $section, $index, $fragmentationDepth, $prevId, $nextId, $config:serverdomain)
            return 
                map {
                    'index': $index,
                    'number': format-number($index, "00000"),
                    'tei_name': local-name($section),
                    'tei_id': string($section/@xml:id),
                    'tei_level': count($section/ancestor-or-self::tei:*),
                    'prev': $prevId,
                    'next': $nextId,
                    'html': $result
                }
            
    (: Reporting :)
    
    (: See if there are any leaf elements in our text that are not matched by our rule :)
    let $missed-elements := $work//(tei:front|tei:body|tei:back)//tei:*[count(./ancestor-or-self::tei:*) < $fragmentationDepth][not(*)]
    (: See if any of the elements we did get is lacking an xml:id attribute :)
    let $unidentified-elements := $target-set[not(@xml:id)]

    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Done.") else ()
    
    return 
        map {
            'toc': $toc,
            'pagination': $pages,
            'fragments': $fragments,
            'missed_elements': $missed-elements,
            'unidentified_elements': $unidentified-elements,
            'tei_fragment_roots': $target-set
        }
};

declare function html:makeHTMLDataOld($tei as element(tei:TEI)) as map(*) {
    let $work := util:expand($tei)
    let $fragmentationDepth := index:determineFragmentationDepth($tei)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Rendering " || string($tei/@xml:id) || " at fragmentation level " || $fragmentationDepth || " ...") else ()

    let $target-set := index:getFragmentNodes($work, $fragmentationDepth)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] " || string(count($target-set)) || " elements to be rendered as fragments ...") else ()

    let $workId := $work/@xml:id
    let $text := $work//tei:text[@type='work_volume'] | $work//tei:text[@type = 'work_monograph']
    let $elements := $work//tei:text[@type = 'work_monograph']/(tei:front | tei:body | tei:back)  
    let $title := sutil:WRKcombined($work, (), $workId)

    (: (1) table of contents :)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Creating ToC file for " || $workId || " ...") else ()
    let $toc :=     
        <div id="tableOfConts">
            <ul>
                <li>
                    <b>{$title}</b>
                    {
                    if (not($work//tei:text[@type='work_volume'])) then
                        <span class="jstree-anchor hideMe pull-right">{html:getPagesFromDiv($text)}</span>
                    else ()
                    }
                    {
                    if ($work//tei:text[@type='work_volume']) then 
                        for $a in $work//tei:text where $a[@type='work_volume' and sutil:WRKisPublished($workId || '_' || @xml:id)] return
                            <ul>
                                <li>
                                    <a class="hideMe">
                                        <b><i18n:text key="volume">Volume</i18n:text>{concat(': ', $a/@n/string())}</b>
                                        <span class="jstree-anchor hideMe pull-right">{html:getPagesFromDiv($a)}</span>
                                    </a>
                                    { html:generateTocFromDiv($a/(tei:front | tei:body | tei:back), $workId)}
                                </li>
                            </ul>
                    else html:generateTocFromDiv($elements, $workId)
                    }
                </li>
            </ul>
        </div>
    
    (: (2) pagination :)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Creating pagination ...") else ()
    let $pagesDe :=  html:makePagination((), (), $workId)
    let $pagesEn :=  html:makePagination((), (), $workId)
    let $pagesEs :=  html:makePagination((), (), $workId)

    (: (3) fragments :)
    (: TODO: Mysteriously, if you look at top or a similar tool, the following seems to run mainly on one processor core only... :)
    (: get "previous" and "next" fragment ids and hand the current fragment over to the renderFragment function :)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Rendering fragments (old method) ...") else ()
    let $fragments := 
        for $section at $index in $target-set
            let $debug :=   if ($config:debug = ("trace", "info") and ($index mod 50 eq 0)) then
                                console:log("[HTML] HTML rendering: processing fragment no. " || string($index)  || " ...")
                            else ()
            let $prev   :=  
                if ($index > 1) then
                    $target-set[(xs:integer($index) - 1)]
                else ()
            let $next   :=  
                if ($index < count($target-set)) then
                    $target-set[(xs:integer($index) + 1)]
                else ()
            let $prevId :=  
                if ($prev) then
                    xs:string($prev/@xml:id)
                else ()
            let $nextId := 
                if ($next) then
                    xs:string($next/@xml:id)
                else ()
            let $result := html:renderFragmentOld($work, xs:string($workId), $section, $index, $fragmentationDepth, $prevId, $nextId, $config:serverdomain)
            return 
                map {
                    'index': $index,
                    'number': format-number($index, "00000"),
                    'tei_name': local-name($section),
                    'tei_id': string($section/@xml:id),
                    'tei_level': count($section/ancestor-or-self::tei:*),
                    'prev': $prevId,
                    'next': $nextId,
                    'html': $result
                }
            
    (: Reporting :)
    
    (: See if there are any leaf elements in our text that are not matched by our rule :)
    let $missed-elements := $work//(tei:front|tei:body|tei:back)//tei:*[count(./ancestor-or-self::tei:*) < $fragmentationDepth][not(*)]
    (: See if any of the elements we did get is lacking an xml:id attribute :)
    let $unidentified-elements := $target-set[not(@xml:id)]

    let $debug := if ($config:debug = ("trace", "info")) then console:log("[HTML] Done.") else ()
    
    return 
        map {
            'toc': $toc,
            'pagination_de': $pagesDe,
            'pagination_en': $pagesEn,
            'pagination_es': $pagesEs,
            'fragments': $fragments,
            'missed_elements': $missed-elements,
            'unidentified_elements': $unidentified-elements,
            'tei_fragment_roots': $target-set
        }
};

declare function html:renderFragmentOld($work as node(), $wid as xs:string, $target as node(), $targetindex as xs:integer, $fragmentationDepth as xs:integer, $prevId as xs:string?, $nextId as xs:string?, $serverDomain as xs:string?) {
    let $targetid := xs:string($target/@xml:id)
    let $fragment := html:createFragmentOld($wid, $target, $targetindex, $prevId, $nextId)
    return $fragment
};

declare function html:renderFragment($work as node(), $wid as xs:string, $target as node(), $targetindex as xs:integer, $fragmentationDepth as xs:integer, $prevId as xs:string?, $nextId as xs:string?, $serverDomain as xs:string?) {
    html:renderFragment($work, $wid, $target, $targetindex, $fragmentationDepth, $prevId, $nextId, $serverDomain, $html:defaultLang)
};

declare function html:renderFragment($work as node(), $wid as xs:string, $target as node(), $targetindex as xs:integer, $fragmentationDepth as xs:integer, $prevId as xs:string?, $nextId as xs:string?, $serverDomain as xs:string?, $lang as node()*) {
    let $targetid := xs:string($target/@xml:id)
    let $fragment := html:createFragment($wid, $target, $targetindex, $prevId, $nextId)
    return $fragment
};


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


(:
    declare function html:preparePagination($work as element(tei:TEI), $fragmentIds as map(*)) as element(ul) {
        let $workId := $work/@xml:id
        return 
            <ul id="later" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1">{
                for $pb in $work//tei:text//tei:pb[index:isIndexNode(.) and not(@sameAs or @corresp)] return
                    let $fragment := $fragmentIds($pb/@xml:id/string()) (:$pb/sal:fragment:)
                    let $url      := 'work.html?wid=' || $workId || '&amp;frag=' || $fragment || '#' || concat('pageNo_', $pb/@n)
                    return 
                        <li role="presentation"><a role="menuitem" tabindex="-1" href="{$url}">{normalize-space($pb/@title/string())}</a></li>
            }</ul>
    };
:)

(:
~ Recursively creates a TOC list (of lists...) for a sequence of nodes.
:)
declare function html:generateTocFromDiv($nodes as element()*, $wid as xs:string) as element(ul)* {
    html:generateTocFromDiv($nodes, $wid, $html:defaultLang)
};

declare function html:generateTocFromDiv($nodes as element()*, $wid as xs:string, $lang as node()*) as element(ul)* {
    for $node in $nodes/(tei:div[@type="work_part"]/tei:div[index:isIndexNode(.)]
                         |tei:div[not(@type="work_part")][index:isIndexNode(.)]
                         |*/tei:milestone[@unit ne 'other'][index:isIndexNode(.)]
                         |tei:argument[index:isIndexNode(.)]) return
        let $citeID := sutil:getNodetrail($wid, $node, 'citeID')        
        let $fragId := $config:idserver || '/texts/' || $wid || ':' || $citeID || '?format=html'
        let $section := $node/@xml:id/string()
        let $i18nKey := 
            if (index:dispatch($node, 'class')) then index:dispatch($node, 'class')
            else 'tei-generic'
        let $label := concat('[', i18n:getLocalizedText(html:i18nNodify($i18nKey), $lang), ']')
        let $titleString := index:dispatch($node, 'title')
        let $titleAtt := '[' || i18n:getLocalizedText(html:i18nNodify($i18nKey), $lang) || '] ' || $titleString
(:        let $titleElems := html:makeTOCTitle($node):)
        (: title="{$title}" :)
        return 
            <ul>
                <li>
                    <a class="hideMe" href="{$fragId}" title="{$titleAtt}">
                        {($label, ' ', $titleString)}
                        <span class="jstree-anchor hideMe pull-right">{html:getPagesFromDiv($node)}</span>
                    </a>
                    {html:generateTocFromDiv($node, $wid, $lang)}
                </li>
            </ul>
};

declare function html:makeTOCTitle($node as node()) as item()* {
    html:makeTOCTitle($node, $html:defaultLang)
};

declare function html:makeTOCTitle($node as node(), $lang as node()*) as item()* {
    let $i18nKey := 
        (: every div or milestone type with a citation label should have an entry in i18n files: :)
        if ($node/self::tei:div) then
            if ($config:citationLabels($node/@type/string())?('full')) then 'tei-div-' || $node/@type 
            else 'tei-generic'
        else if ($node/self::tei:milestone) then
            if ($config:citationLabels($node/@unit/string())?('full')) then 'tei-ms-' || $node/@unit
            else 'tei-generic'
        else ()
    let $divLabel := concat('[', i18n:getLocalizedText(html:i18nNodify($i18nKey), $lang), ']')
    let $titleString := index:dispatch($node, 'title')
    return
        ($divLabel, ' ', $titleString)
};

declare function html:getPagesFromDiv($div) {
    let $firstpage :=   
        $div/descendant::text()[string-length(normalize-space(.)) gt 0][1]/preceding::tei:pb[not(@sameAs or @corresp)][1]/@n/string()
(:
        if ($div[@type='work_volume'] | $div[@type = 'work_monograph']) then
            ($div//tei:pb[not(@sameAs or @corresp)])[1]/@n/string() 
        else
            ($div/preceding::tei:pb[not(@sameAs or @corresp)])[last()]/@n/string()
:)
    let $lastpage := if ($div//tei:pb[not(@sameAs or @corresp)]) then
                        ($div//tei:pb[not(@sameAs or @corresp)])[last()]/@n/string()
                     else ()
    return
        if ($lastpage ne '') then 
            concat(' ', string-join(($firstpage, $lastpage), ' - '))
        else $firstpage
};


(:
~ From a given fragment root, searches for ancestors that occur above the fragmentation level and renders them (non-recursively)
    such that they can be re-included into a fragment's HTML.
:)
(: TODO: currently, this merely creates a "Vol. X" teaser at the beginning of volumes - this means that fragmentation depth cannot go below (front|body|back)/* ! :)
declare function html:makeAncestorTeasers($fragmentRoot as element()) {
    html:makeAncestorTeasers($fragmentRoot, $html:defaultLang)
};

declare function html:makeAncestorTeasers($fragmentRoot as element(), $lang as node()*) {
    (: determine whether fragment is first structural element of volume :)
    if ($fragmentRoot[ancestor-or-self::tei:text[@type eq 'work_volume'] 
                      and not(preceding::*[self::tei:div or self::tei:titlePage] 
                              intersect ancestor-or-self::tei:text[@type eq 'work_volume']//*[self::tei:div or self::tei:titlePage])]) then
        let $delimiter := 
            if ($fragmentRoot/ancestor-or-self::tei:text[@type='work_volume']/preceding::tei:text[@type='work_volume']) then 
                <hr/> 
            else ()
        let $sumTitle := html:makeSummaryTitle($fragmentRoot/ancestor-or-self::tei:text[@type eq 'work_volume'], $lang)
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
    html:makeSummaryTitle($node, $html:defaultLang)
};

declare function html:makeSummaryTitle($node as element(), $lang as node()*) as element(div) {
    let $toolbox := html:makeSectionToolbox($node, $lang)
    let $fullTitle := 
        <span class="section-title-text">{
            if ($node/self::tei:text[@type='work_volume']) then <b>{html:dispatch($node, 'html-title', $lang)}</b>
            else html:dispatch($node, 'html-title', $lang)
        }</span>
    (: make anchors according to the amount of structural ancestors so that JS knows what to highlight: :)
    let $levels := count($node/ancestor::*[index:isStructuralNode(.)])
    let $levelAnchors := for $l in (1 to $levels) return <a style="display:none;" class="div-l-{$l}"></a>
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
        string-length((if ($label) then $node/@n || ' ' else ()) || normalize-space(string-join(txt:dispatch($node, 'edit'), '')))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
        string-length((if ($label) then $node/@n || ' ' else ()) || normalize-space(replace(string-join(txt:dispatch($node, 'edit'), ''), '\[.*?\]', '')))
:)
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
    html:makeSectionToolbox($node, $html:defaultLang)
};

declare function html:makeSectionToolbox($node as element(), $lang as node()*) as element(div) {
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
    let $citeIDBaseUrl := html:makeCiteIDURI($node)
    return
        <div class="{$class}">
            <a id="{$id}" href="#" data-rel="popover" class="sal-tb-a"><!-- href="{('#' || $id)}" -->
                <span class="fas fa-hand-point-right messengers" title="{i18n:getLocalizedText(html:i18nNodify(concat('openToolbox', $i18nSuffix)), $lang)}"></span>
            </a>
            <div class="sal-toolbox-body">
                <div class="sal-tb-btn" title="{i18n:getLocalizedText(html:i18nNodify(concat('link', $i18nSuffix)), $lang)}">
                    <button onclick="copyLink(this); return false;" class="messengers">
                        <span class="fas fa-link"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('copyLink'), $lang)}
                    </button>
                    <span class="cite-link" style="display:none;">{$citeIDBaseUrl || '?format=html'}</span>
                </div>
                <div class="sal-tb-btn" title="{i18n:getLocalizedText(html:i18nNodify(concat('cite', $i18nSuffix)), $lang)}">
                    <button onclick="copyCitRef(this); return false;" class="messengers">
                        <span class="fas fa-feather-alt"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('copyCit'), $lang)}
                    </button>
                    <span class="sal-cite-rec" style="display:none">
                        {sutil:HTMLmakeCitationReference($wid, $fileDesc, 'reading-passage', $node)}
                    </span>
                </div>
                <div class="sal-tb-btn dropdown" title="{i18n:getLocalizedText(html:i18nNodify(concat('txtExp', $i18nSuffix)), $lang)}">
                    <button class="dropdown-toggle messengers" data-toggle="dropdown">
                        <span class="fas fa-align-left" title="{i18n:getLocalizedText(html:i18nNodify('txtExpPass'), $lang)}"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('txtExpShort'), $lang)}
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="{$citeIDBaseUrl || '?format=txt&amp;mode=edit'}"><span class="messengers fas fa-align-left" title="{i18n:getLocalizedText(html:i18nNodify('downloadTXTEdit'), $lang)}"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('constitutedLower'), $lang)}</a></li>
                        <li><a href="{$citeIDBaseUrl || '?format=txt&amp;mode=orig'}"><span class="messengers fas fa-align-left" title="{i18n:getLocalizedText(html:i18nNodify('downloadTXTOrig'), $lang)}"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('diplomaticLower'), $lang)}</a></li>
                    </ul>
                </div>
                <div class="sal-tb-btn" title="{i18n:getLocalizedText(html:i18nNodify(concat('teiExp', $i18nSuffix)), $lang)}">
                    <a href="{$citeIDBaseUrl || '?format=tei'}"><span class="messengers fas fa-align-left" title="{i18n:getLocalizedText(html:i18nNodify('downloadXML'), $lang)}"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('teiExpShort'), $lang)}</a><!--
                    <button class="messengers" onclick="window.location.href = '{$citeIDBaseUrl || '?format=tei'}'">
                        <span class="fas fa-file-code"></span>{' '}{i18n:getLocalizedText(html:i18nNodify('teiExpShort'), $lang)}
                    </button>-->
                </div>
                <div class="sal-tb-btn" style="display:none;">
                    <a class="updateHiliteBox" href="#"> 
                        <span class="glyphicon glyphicon-refresh"></span>
                    </a>
                </div>
            </div>
        </div>
};

declare function html:makePagination($node as node()?, $model as map(*)?, $wid as xs:string?) {
    let $workId :=  
        if ($wid) then 
            if (contains($wid, '_')) then substring-before(sutil:normalizeId($wid), '_') 
            else sutil:normalizeId($wid)
        else substring-before($model('currentWorkId'), '_')
    return 
        <ul id="later" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1">{
            for $pb in doc($config:index-root || '/' || $workId || '_nodeIndex.xml')//sal:node[@type='pb'][not(starts-with(@title, 'sameAs') or starts-with(@title, 'corresp'))]
                let $fragment := $pb/@fragment
                let $url      := $config:idserver || '/texts/' || $workId || ':' || $pb/@citeID/string() 
                (:'work.html?wid=' || $workId || '&amp;frag=' || $fragment || '#' || concat('pageNo_', $pb/@n):)
                return 
                    <li role="presentation"><a role="menuitem" tabindex="-1" href="{$url}">{normalize-space($pb/@title/string())}</a></li>
        }</ul>
};


declare function html:makeClassableString($str as xs:string) as xs:string? {
    replace($str, '[,: ]', '')
};


declare function html:createFragmentOld($workId as xs:string, $fragmentRoot as element(), $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) as element(div) {
    (: SvSalPage: main area (id/class page in order to identify page-able content :)
    <div class="row" xml:space="preserve">
        <div class="col-md-12">
            <div id="SvSalPages">
                <div class="SvSalPage">                
                    {
                    if ($fragmentRoot[not(preceding-sibling::*) and
                                      not((ancestor::tei:body|ancestor::tei:back) and
                                           preceding::tei:front/*)
                                     ]) then
                        html:makeAncestorTeasers($fragmentRoot)
                    else ()    
                    }
                    {html:dispatch($fragmentRoot, 'html')}
                </div>
            </div>
        </div>
        {html:createPaginationLinksOld($workId, $fragmentIndex, $prevId, $nextId) (: finally, add pagination links :)}
    </div>
    (: the rest (to the right, in col-md-12) is filled by _spans_ of class marginal, possessing
         a negative right margin (this happens in eXist's work.html template) :)
};

declare function html:createFragment($workId as xs:string, $fragmentRoot as element(), $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) {
    html:createFragment($workId, $fragmentRoot, $fragmentIndex, $prevId, $nextId, $html:defaultLang)  
};

declare function html:createFragment($workId as xs:string, $fragmentRoot as element(), $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?, $lang as node()*) {
    concat(
        '{{$content := `', codepoints-to-string(10), serialize(
            <div class="iasItem">                
                {
                if ($fragmentRoot[not(preceding-sibling::*) and
                                  not((ancestor::tei:body|ancestor::tei:back) and
                                       preceding::tei:front/*)
                                 ]) then
                    html:makeAncestorTeasers($fragmentRoot)
                else ()    
                }
                {html:dispatch($fragmentRoot, 'html', $lang)}
            </div>, map{"method":"html", "indent": true(), "encoding":"utf-8"}), codepoints-to-string(10),
        '`}}',
        codepoints-to-string(10), codepoints-to-string(10),
        html:createPaginationLinks($workId, $fragmentIndex, $prevId, $nextId),
        codepoints-to-string(10), codepoints-to-string(10),
        '{{include "../../../resources/templates/template_work.html" $work_info }}',
        codepoints-to-string(10)
    )
};
    

declare function html:createPaginationLinksOld($workId as xs:string, $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) {
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

declare function html:createPaginationLinks($workId as xs:string, $fragmentIndex as xs:integer, $prevId as xs:string?, $nextId as xs:string?) {
    let $sourceDesc := collection($config:tei-works-root)//tei:TEI[@xml:id = $workId][.//tei:text[@type = ("work_multivolume", "work_monograph")]]//tei:sourceDesc
    let $authorname := string-join($sourceDesc//tei:author//tei:surname, '/')
    let $title      := $sourceDesc//tei:title[@type='short']
    let $place      := if ($sourceDesc//tei:imprint/tei:pubPlace[@role = 'thisEd']) then $sourceDesc//tei:imprint/tei:pubPlace[@role = 'thisEd'] 
                       else $sourceDesc//tei:imprint/tei:pubPlace[1]
    let $printer    := string-join($sourceDesc//tei:publisher//tei:surname, '/')
    let $year       := if ($sourceDesc//tei:imprint/tei:date[@type = 'thisEd']) then $sourceDesc//tei:imprint/tei:date[@type = 'thisEd']
                       else $sourceDesc//tei:imprint/tei:date[1]
    return
    concat(
        '{{$work_info := dict ',
        '"id" "',      $workId,     '" ',
        '"author" "',  $authorname, '" ',
        '"title" "',   $title,      '" ',
        '"place" "',   $place,      '" ',
        '"printer" "', $printer,    '" ',
        '"year" "',    $year,       '" ',
        if ($prevId) then concat('"prev" "', format-number($fragmentIndex - 1, "00000"), '_', $prevId, '.html" ') else (),
        if ($nextId) then concat('"next" "', format-number($fragmentIndex + 1, "00000"), '_', $nextId, '.html" ') else (),
        '"content" $content}}'
    )
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
~ For a node, make a full-blown URI including the citeID of the node
:)
declare function html:makeCiteIDURI($node as element()) as xs:string? {
    let $debug := if (not($node/@xml:id)) then console:log("[HTML] Problem: intend to html:makeCiteIDURI of a " || local-name($node) || " node without xml:id. After line " || $node/preceding::tei:lb[1]/@xml:id/string() || "." ) else ()
    let $workId := $node/ancestor::tei:TEI/@xml:id
    let $citeID := sutil:getNodetrail($workId, $node, 'citeID')
    return
        if ($citeID) then $config:idserver || '/texts/' || $workId || ':' || $citeID
        else ()
};


(: TODO: debugging with references to extratextual entities :)
declare function html:resolveURI($node as element(), $targets as xs:string) {
    let $currentWork := $node/ancestor-or-self::tei:TEI
    let $target := (tokenize($targets, ' '))[1]
    let $prefixDef := $currentWork//tei:prefixDef
    let $workScheme := '(work:(W[A-z0-9.:_\-]+))?#(.*)'
    let $lemmaScheme := 'lemma:(L[0-9]+)'
    let $facsScheme := 'facs:((W[0-9]+)[A-z0-9.:#_\-]+)'
    let $genericScheme := '(\S+):([A-z0-9.:#_\-]+)'
    return
        if (starts-with($target, '#') and $currentWork//*[@xml:id eq substring($target, 2)]) then
            (: target is some node within the current work :)
            html:makeCiteIDURI($currentWork//*[@xml:id eq substring($target, 2)])
        else if (matches($target, $workScheme)) then
            (: target is something like "work:W...#..." :)
            let $targetWorkId :=
                if (replace($target, $workScheme, '$2')) then (: Target is a link containing a work id :)
                    replace($target, $workScheme, '$2')
                else $currentWork/@xml:id/string() (: Target is just a link to a fragment anchor, so targetWorkId = currentWork :)
            let $anchorId := replace($target, $workScheme, '$3')
            return 
                if ($anchorId) then html:makeCiteIDURI($node) else ()
        else if (matches($target, $lemmaScheme)) then (: Target is a Salamanca Lemma :)
            concat('lemma.html?lid=', substring($target, 7))
        else if (matches($target, $facsScheme)) then (: Target is a facs string :)
            (: Target does not contain "#", or is not a "work:..." url: :)
            let $targetWorkId :=
                if (replace($target, $facsScheme, '$2')) then (: extract work id from facs string :)
                    replace($target, $facsScheme, '$2')
                else $currentWork/@xml:id/string()
            let $anchorId := replace($target, $facsScheme, '$1') (: extract facs string :)
            return
                html:makeCiteIDURI($node)
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
    html:dispatch($node, $mode, $html:defaultLang)
};

declare function html:dispatch($node as node(), $mode as xs:string, $lang as node()*) {
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
    
            default return html:passthru($node, $mode, $lang)
    (: for fine-grained debugging: :)
    (: let $debug := 
        if (index:isIndexNode($node)) then 
            util:log('warn', '[RENDER] Processing node tei:' || local-name($node) || ', with @xml:id=' || $node/@xml:id) 
        else ()
    :)
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
                    let $toolbox := html:makeSectionToolbox($node, $lang)
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

declare function html:passthru($nodes as node()*, $mode as xs:string) as item()* {
    html:passthru($nodes, $mode, $html:defaultLang)
};

declare function html:passthru($nodes as node()*, $mode as xs:string, $lang as node()*) as item()* {
    for $node in $nodes/node() return html:dispatch($node, $mode, $lang)
};

(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function html:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'html-title' return
            normalize-space(string-join(txt:dispatch($node, 'edit'), ''))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
            normalize-space(replace(string-join(txt:dispatch($node, 'edit')), '\[.*?\]', ''))
:)
        case 'html' return
            (: list[not(@type eq 'dict')]/head are handled in html:list() :)
            if ($node/parent::tei:list[not(@type eq 'dict')]) then 
                () 
            (: within notes: :)
            else if ($node/parent::tei:lg) then 
                <h5 class="poem-head">{html:passthru($node, $mode)}</h5>
            (: usual headings: :)
            else 
(:                let $toolbox := html:makeSectionToolbox($node)
                return:)
                <h3>
                    <span class="heading-text">{html:passthru($node, $mode)}</span>
                </h3>

        default return 
            html:passthru($node, $mode)
};

(: FIXME: In the following, work mode functionality has to be added - also paying attention to intervening pagebreak marginal divs :)
declare function html:term($node as element(tei:term), $mode as xs:string) {
    switch($mode)
        case 'html' return
            html:name($node, $mode)

        default return
            html:passthru($node, $mode)
};

(: TODO - Html:
    * add line- and column breaks in diplomatic view? (problem: infinite scrolling has to comply with the current viewmode as well!)
    * make bibls, ref span across (page-)breaks (like persName/placeName/... already do)
    * teasers: break text at word boundaries
:)

declare function html:abbr($node as element(tei:abbr), $mode) {
        html:origElem($node, $mode)
};

declare function html:argument($node as element(tei:argument), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if (index:isBasicNode($node)) then
                <div class="hauptText">
                    <div class="argument">
                        {html:passthru($node, $mode)}
                    </div>
                </div>
            else
                <div class="argument">
                    {html:passthru($node, $mode)}
                </div>

        default return
            html:passthru($node, $mode)
};

declare function html:bibl($node as element(tei:bibl), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@sortKey) then 
                <span class="{local-name($node) || ' hi_', html:makeClassableString($node/@sortKey)}">{html:passthru($node, $mode)}</span>
            else <span>{html:passthru($node, $mode)}</span>

        default return
            html:passthru($node, $mode)
};

declare function html:byline($node as element(tei:byline), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="tp-paragraph">
                {html:passthru($node, $mode)}
            </span>

        default return
            html:passthru($node, $mode)
};

declare function html:cb($node as element(tei:cb), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if (not($node/@break = 'no')) then
                ' '
            else ()

        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function html:cell($node as element(tei:cell), $mode) {
    switch($mode)
        case 'html' return 
            if ($node/@role eq 'label') then 
                <td class="table-label">{html:passthru($node, $mode)}</td>
            else <td>{html:passthru($node, $mode)}</td>

        default return
            html:passthru($node, $mode)
};

declare function html:choice($node as element(tei:choice), $mode as xs:string) {
    (: HTML: Editorial interventions: Don't hide original stuff where we have no modern alternative, otherwise
      put it in an "orignal" class span which we make invisible by default.
      Put our own edits in spans of class "edited" and add another class to indicate what type of edit has happened :)
    html:passthru($node, $mode)
};

declare function html:corr($node as element(tei:corr), $mode) {
    html:editElem($node, $mode)
};

declare function html:del($node as element(tei:del), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/tei:supplied) then
                html:passthru($node, $mode)
            else error(xs:QName('html:del'), 'Unexpected content in tei:del')

        default return 
            html:passthru($node, $mode)
};

declare function html:div($node as element(tei:div), $mode as xs:string) {
    html:div($node, $mode, $html:defaultLang)
};

declare function html:div($node as element(tei:div), $mode as xs:string, $lang as node()*) {
    switch($mode)
        case 'html-title' return
            if (not($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) and $node/(tei:head|tei:label)) then
                (: for expanded titles, we need the full version, not just the teaser :)
                normalize-space(string-join(txt:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
                normalize-space(replace(string-join(txt:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''), '\[.*?\]', ''))
:)
            else if (index:div($node, 'title')) then replace(index:div($node, 'title'), '"', '')
            else i18n:getLocalizedText(html:i18nNodify(index:div($node, 'class')), $lang) (: if everything fails, simply use the label (such as 'Preface') :)

        default return
            html:passthru($node, $mode)
};

declare function html:docAuthor($node as element(tei:docAuthor), $mode as xs:string) {
    switch($mode)
        case 'html' return
            html:name($node, $mode)
        default return 
            html:passthru($node, $mode)
};

declare function html:docImprint($node as element(tei:docImprint), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="tp-paragraph">
                {html:passthru($node, $mode)}
            </span>

        default return
            html:passthru($node, $mode)
};

declare function html:editElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/parent::tei:choice) then
                let $origString := normalize-space(string-join(txt:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), 'orig'), ''))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
                let $origString := string-join(txt:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), 'orig'), '')
:)
                return
                    <span class="messengers edited {local-name($node)}" title="{$origString}">
                        {string-join(html:passthru($node, $mode), '')}
                    </span>
            else html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:expan($node as element(tei:expan), $mode) {
    html:editElem($node, $mode)
};

declare function html:figure($node as element(tei:figure), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@type eq 'ornament') then
                <hr class="ornament"/>
            else ()

        default return ()
};

declare function html:foreign($node as element(tei:foreign), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="foreign-lang">{html:passthru($node, $mode)}</span>

        default return 
            html:passthru($node, $mode)
};

declare function html:g($node as element(tei:g), $mode as xs:string) {
    switch($mode)
        case 'html' return
            let $thisString := 
                if ($node/text()) then 
                    xs:string($node/text())
                else error(xs:QName('html:g'), 'Found tei:g without text content') (: ensure correct character markup :)
            let $charCode  := lower-case(substring($node/@ref, 2))                             (: substring to remove leading '#' :)
(:            let $char := $node/ancestor::tei:TEI//tei:charDecl/tei:char[@xml:id eq $charCode]:)
            let $char := $config:tei-specialchars/tei:char[lower-case(@xml:id) eq $charCode]
            let $test :=                                                       (: make sure that the char reference is correct :)
                if (not($char)) then 
                    error(xs:QName('html:g'), 'g/@ref is invalid, the char code "' || $charCode || '" does not exist in specialChars.')
                else ()
            let $mapping := $char/tei:mapping[@type = ('composed', 'precomposed')]
            let $precomposedString := 
                if ($char/tei:mapping[@type='precomposed']/text()) then 
                    $char/tei:mapping[@type='precomposed']/text()
                else ()
(:            let $composedString := 
                if ($char/tei:mapping[@type='composed']/text()) then
                    $char/tei:mapping[@type='composed']/text()
                else ()
            let $originalGlyph := if ($composedString) then $composedString else $precomposedString:)
            let $originalGlyph := string($mapping[1])
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
                            error(xs:QName('html:g'), 'No correct mapping available for char: ', $node/@ref)
                        else ()
                    return
                        (: a) g has been used for resolving abbreviations (in early texts W0004, W0013 and W0015) -> treat it like choice elements :)
(:                        if (not($thisString = ($precomposedString, $composedString)) and not($charCode = ('char017f', 'char0292'))) then:)
                        if (not($thisString = $mapping) and not($charCode = ('char017f', 'char0292'))) then
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
                            html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:gap($node as element(tei:gap), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/ancestor::tei:damage) then
                <span title="?" class="gap"/>
            else ()
        default return ()
};

declare function html:hi($node as element(tei:hi), $mode as xs:string) {
    switch($mode)
        case 'html' return
            let $styles := distinct-values(tokenize($node/@rendition, ' '))
            (: names of elements that have their own, specific text alignment 
                (where hi/@rendition alignment is to be omitted) :)
            let $specificAlignElems := ('head', 'signed', 'titlePage', 'argument') (: TODO: add more element names here when necessary :)
            let $cssStyles := 
                for $s in $styles return
                    if ($s eq '#b') then 'font-weight:bold;'
                    else if ($s eq '#it') then 'font-style:italic;'
                    else if ($s eq '#rt') then 'font-style: normal;'
                    else if ($s eq '#l-indent') then 'display:block;margin-left:4em;'
                    (: centering and right-alignment apply only in certain contexts :)
                    else if ($s eq '#r-center'
                             and not($node/ancestor::*[local-name(.) = $specificAlignElems])
                             and not($node/ancestor::*[local-name(.) = $html:basicElemNames][1]//text()[not(ancestor::tei:hi[contains(@rendition, '#r-center')])])
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
                    html:passthru($node, $mode)
                }

        default return 
            html:passthru($node, $mode)
};

declare function html:imprimatur($node as element(tei:imprimatur), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="tp-paragraph">
                {html:passthru($node, $mode)}
            </span>

        default return
            html:passthru($node, $mode)
};

declare function html:item($node as element(tei:item), $mode as xs:string) {
    switch($mode)
        case 'html-title' return
            if (not($node/parent::tei:list/@type='dict' and $node//tei:term[1][@key])
                and not($node/@n and not(matches($node/@n, '^[0-9\[\]]+$')))
                and $node/(tei:head|tei:label)) 
                then normalize-space(string-join(txt:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
                then normalize-space(replace(string-join(txt:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''),'\[.*?\]', ''))
:)
            else replace(index:dispatch($node, 'title'), '"', '')

        case 'html' return
            (: tei:item should be handled exclusively in html:list :)
            error()

        default return
            html:passthru($node, $mode)
};

declare function html:l($node as element(tei:l), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (html:passthru($node, $mode),<br/>)

        default return html:passthru($node, $mode)
};

declare function html:label($node as element(tei:label), $mode as xs:string) {
    switch($mode)
        case 'html-title' return
            normalize-space(string-join(txt:dispatch($node, 'edit'), ''))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
            normalize-space(replace(string-join(txt:dispatch($node, 'edit')), '\[.*?\]', ''))
:)
        case 'html' return
            switch($node/@place)
                case 'margin' return
                    html:makeMarginal($node)
                case 'inline' return
                    <span class="label-inline">
                        {html:passthru($node, $mode)}
                    </span>
                default return html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:lb($node as element(tei:lb), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        default return () 
};

declare function html:list($node as element(tei:list), $mode as xs:string) {
    switch($mode)
        case 'html-title' return
            if (not($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) and $node/(tei:head|tei:label)) then
                normalize-space(string-join(txt:dispatch(($node/(tei:head|tei:label))[1], 'edit'), ''))
(: replaced the following with the above for performance reasons on 2021-04-28 ...
                normalize-space(replace(string-join(txt:dispatch(($node/(tei:head|tei:label))[1], 'edit')), '\[.*?\]', ''))
:)
            else replace(index:dispatch($node, 'title'), '"', '')

        case 'html' return
            (: available list types: "dict", "ordered", "simple", "bulleted", "gloss", "index", or "summaries" :)
            (: In html, lists must contain nothing but <li>s, so we have to move headings (and arguments) before the list 
               and nest everything else (sub-lists) in <li>s. :)
            switch(html:determineListType($node))
                (: tei:item are actually handled here, not in html:item, due to the tight coupling of their layout to tei:list :)
                case 'ordered' return (: enumerated/ordered list :)
                    <div id="{$node/@xml:id}">
                        {for $head in $node/tei:head return <h4>{html:passthru($head, $mode)}</h4>}
                        {
                        (: in ordered lists, we outsource non-item elements before items (such as argument, p, ...) to a non-ordered, non-bulleted list :)
                        if ($node/*[not(self::tei:head or self::tei:item) and not(preceding-sibling::tei:item)]) then
                            <ul style="list-style: none;">
                                {
                                for $child in $node/*[not(self::tei:head or self::tei:item) and not(preceding-sibling::tei:item)] return
                                    <li>{html:passthru($child, $mode)}</li>
                                }    
                            </ul>
                        else ()
                        }
                        <ol>
                            {for $child in $node/*[self::tei:item or preceding-sibling::tei:item] return 
                                <li>{html:passthru($child, $mode)}</li>
                            }
                        </ol>
                    </div>
                case 'simple' return (: make no list in html terms at all :)
                    <div id="{$node/@xml:id}">
                        {for $head in $node/tei:head return <h4 class="inlist-head">{html:passthru($head, $mode)}</h4>}
                        {for $child in $node/*[not(self::tei:head)] return
                            if ($child//list) then html:passthru($child, $mode)
                            else if (not($child/self::tei:item)) then (: argument, p, etc. :)
                                <div>{html:passthru($child, $mode)}</div>
                            else (' ', <span class="inline-item">{html:passthru($child, $mode)}</span>, ' ')}
                    </div>
                case 'index'
                case 'summaries' return (: unordered list :)
                    let $content := 
                        <div class="list-index" id="{$node/@xml:id}">
                            {for $head in $node/tei:head return <h4 class="list-index-head">{html:passthru($head, $mode)}</h4>}
                            <ul style="list-style-type:circle;">
                                {for $child in $node/*[not(self::tei:head)] return 
                                    if (not($child/self::tei:item)) then (: argument, p, etc. :)
                                        <li class="list-paragraph">{html:passthru($child, $mode)}</li>
                                    else
                                        <li class="list-index-item">{html:passthru($child, $mode)}</li>}
                            </ul>
                        </div>
                    return
                        (:if (not($node/ancestor::tei:list)) then
                            <section>{$content}</section>
                        else :)
                        $content
                default return (: e.g., 'bulleted' :)
                    (: put an unordered list (and captions) in a figure environment (why?) of class @type :)
                    <div class="list-default" id="{$node/@xml:id}">
                        {for $head in $node/tei:head return <h4 class="list-default-head">{html:passthru($head, $mode)}</h4>}
                        <ul style="list-style-type:circle;">
                             {for $child in $node/*[not(self::tei:head)] return 
                                  if (not($child/self::tei:item)) then (: argument, p, etc. :)
                                      <li class="list-paragraph">{html:passthru($child, $mode)}</li>
                                  else
                                      <li class="list-default-item">{html:passthru($child, $mode)}</li>}
                        </ul>
                    </div>

        default return
            ($config:nl, html:passthru($node, $mode), $config:nl)
};

declare function html:lg($node as element(tei:lg), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <span class="poem">{html:passthru($node, $mode)}</span>

        default return
            html:passthru($node, $mode)
};

declare function html:milestone($node as element(tei:milestone), $mode as xs:string) {
    switch($mode)
        (: TODO: bring i18n labels somehow into html-title... :)
        case 'html-title' return
            replace(index:milestone($node, 'title'), '"', '')

        case 'html' return
            if ($node/@rendition eq '#dagger') then <sup>†</sup> else '*'

        default return () (: also for snippets-orig, snippets-edit :)
};

declare function html:name($node as element(*), $mode as xs:string) {
    switch($mode)
        case 'html' return
            let $hiliteName := if ($node/@ref) then 'hi_' || html:makeClassableString((tokenize($node/@ref, ' '))[1]) else ()
            let $dictLemma := 
                if ($node[self::tei:term and ancestor::tei:list[@type='dict'] and not(preceding-sibling::tei:term)]) then
                    'dictLemma'
                else ()
            return 
                (: as long as any link would lead nowhere, omit linking and simply grasp the content: :)
                (:
                <span class="{normalize-space(string-join((local-name($node),$hiliteName,$dictLemma), ' '))}">
                    {html:passthru($node, $mode)}
                </span>
                :)
                (: as soon as links have actual targets, execute something like the following: :)
                let $resolvedURI := if ($node/@ref) then html:resolveURI($node, $node/@ref) else ()
                return
                    if ($resolvedURI) then
                        html:transformToLink($node, $resolvedURI)
                    else 
                        html:passthru($node, $mode)
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
            html:passthru($node, $mode)
};

declare function html:note($node as element(tei:note), $mode as xs:string) {
    switch($mode)
        case 'html-title' return ()

        case 'html' return
            html:makeMarginal($node)

        default return
            html:passthru($node, $mode)
};

declare function html:orgName($node as element(tei:orgName), $mode as xs:string) {
    html:name($node, $mode)
};

declare function html:orig($node as element(tei:orig), $mode) {
    html:origElem($node, $mode)
};

declare function html:origElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'html' return 
            if ($node/parent::tei:choice) then
                let $editString := normalize-space(string-join(txt:dispatch($node/parent::tei:choice/(tei:expan|tei:reg|tei:corr), 'edit'), ''))
                return
                    <span class="original {local-name($node)} unsichtbar" title="{$editString}">
                        {string-join(html:passthru($node, $mode), '')}
                    </span>
            else 
                html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:p($node as element(tei:p), $mode as xs:string) {
    switch($mode)
        case 'html-title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )

        case 'html' return
            (: special cases :)
            if ($node/ancestor::tei:note) then
                <span class="note-paragraph">
                    {html:passthru($node, $mode)}
                </span>
            else if ($node/ancestor::tei:item) then
                <span class="item-paragraph">
                    {html:passthru($node, $mode)}
                </span>
            else if ($node/ancestor::tei:titlePage) then
                <span class="tp-paragraph">
                    {html:passthru($node, $mode)}
                </span>
            (: main text: :)
            else if ($node/ancestor::item[not(ancestor::list/@type = ('dict', 'index'))]) then
                <p id="{$node/@xml:id}">
                    {html:passthru($node, $mode)}
                </p>
            else
                html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:pb($node as element(tei:pb), $mode as xs:string) {
    switch($mode)
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

        case 'html' return
            if (index:isIndexNode($node)) then 
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
                        let $title := if (contains($node/@n, 'fol.')) then 'View image of ' || $node/@n else 'View image of p. ' || $node/@n
                        return
                            <div class="pageNumbers">
                                <a href="{html:resolveFacsURI($node/@facs)}" data-canvas="{html:resolveCanvasID($node)}"
                                   data-sal-id="{html:makeCiteIDURI($node)}" id="{$pageAnchor}" title="{$title}"
                                   class="pageNo messengers">
                                    <span class="fas fa-book-open facs-icon"></span>
                                    {' '}
                                        {html:pb($node, 'html-title')}
                                </a>
                            </div>
                    else ()
                return ($inlineBreak, $link)
            else ()

        (: pb nodes are good candidates for tracing the speed/performance of document processing, 
            since they are equally distributed throughout a document :)
        case 'debug' return
            util:log('warn', '[RENDER] Processing tei:pb node ' || $node/@xml:id)

        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function html:persName($node as element(tei:persName), $mode as xs:string) {
    html:name($node, $mode)
};

declare function html:placeName($node as element(tei:placeName), $mode as xs:string) {
    html:name($node, $mode)
};

(: Same as html:persName() :)
declare function html:publisher($node as element(tei:publisher), $mode as xs:string) {
    html:name($node, $mode)
};

(: Same as html:placeName() :)
declare function html:pubPlace($node as element(tei:pubPlace), $mode as xs:string) {
    html:name($node, $mode)
};

declare function html:quote($node as element(tei:quote), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (:<span class="quote">
                {:)html:passthru($node, $mode)(:}
            </span>:)
            (: how to deal with longer quotes, spanning several paragraphs or even divs? (possible solution: anchors) :)

        default return
            ('"', html:passthru($node, $mode), '"')
};

declare function html:ref($node as element(tei:ref), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@type eq 'note-anchor') then
                () (: omit note references :)
            else if ($node/@target) then
                let $resolvedUri := html:resolveURI($node, $node/@target) (: TODO: verify that this works :)
                return html:transformToLink($node, $resolvedUri)
            else html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:reg($node as element(tei:reg), $mode) {
    html:editElem($node, $mode)
};

declare function html:row($node as element(tei:row), $mode) {
    switch($mode)
        case 'html' return 
            <tr>{html:passthru($node, $mode)}</tr>

        default return
            html:passthru($node, $mode)
};

declare function html:sic($node as element(tei:sic), $mode) {
    html:origElem($node, $mode)
};

declare function html:signed($node as element(tei:signed), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <div class="signed">
                {html:passthru($node, $mode)}
            </div>

        default return
            html:passthru($node, $mode)
};

declare function html:soCalled($node as element(tei:soCalled), $mode as xs:string) {
    ("'", html:passthru($node, $mode), "'")
};

declare function html:space($node as element(tei:space), $mode as xs:string) {
    if ($node/@dim eq 'horizontal' or @rendition eq '#h-gap') then ' ' else ()
};

declare function html:supplied($node as element(tei:supplied), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (<span class="original unsichtbar" title="{string($node)}">{'[' || string-join(html:passthru($node,$mode)) || ']'}</span>,
            <span class="edited" title="{concat('[', string($node), ']')}">{html:passthru($node,$mode)}</span>)

        default return
            html:passthru($node, $mode)
};

declare function html:table($node as element(tei:table), $mode as xs:string) {
    switch($mode)
        case 'html' return
            <table>{html:passthru($node, $mode)}</table>

        default return html:passthru($node, $mode)
};

declare function html:text($node as element(tei:text), $mode as xs:string) {
    switch($mode)
        case 'html-title' return
            if ($node/@type eq 'work_volume') then
                'Vol. ' || $node/@n/string()
            else ()

        case 'html' return
            if (html:isCitableWithTeaser($node)) then
                let $delimiter := 
                    if ($node/@type eq 'work_volume' and $node/preceding::tei:text[@type eq 'work_volume']) 
                        then <hr/> 
                    else ()
                return ($delimiter, html:passthru($node, $mode))
            else html:passthru($node, $mode)

        default return
            html:passthru($node, $mode)
};

declare function html:textNode($node as node(), $mode as xs:string) {
    $node
};

declare function html:title($node as element(tei:title), $mode as xs:string) {
    html:name($node, $mode)
};

declare function html:titlePage($node as element(tei:titlePage), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (: Make toolbox for titlePage at the same point where it is created for all other elements, in html:dispatch :)
            let $toolbox := html:makeSectionToolbox($node)
            (: distinguishing first and subsequent titlePage(s) for rendering them differently :)
            let $class := if ($node[not(preceding-sibling::tei:titlePage)]) then 'titlePage' else 'sec-titlePage'
            return
                <div class="{$class}">
                    {$toolbox}
                    <div class="titlePage-body">
                        {html:passthru($node, $mode)}
                    </div>
                </div>

        default return
            html:passthru($node, $mode)
};

declare function html:titlePart($node as element(tei:titlePart), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@type eq 'main') then
                <h1>{html:passthru($node, $mode)}</h1>
            else html:passthru($node, $mode)

        default return 
            html:passthru($node, $mode)
};

declare function html:unclear($node as element(tei:unclear), $mode as xs:string) {
    switch($mode)
        case 'html' return
            (: TODO i18n title :)
            if ($node//text()) then
                <span title="unclear" class="sal-unclear-text">{html:passthru($node, $mode)}</span>
            else <span title="unclear" class="sal-unclear"/>

        default return 
            html:passthru($node, $mode)
};
