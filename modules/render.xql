xquery version "3.0";

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

(: ####====---- Helper Functions ----====#### :)


(: Todo: :)
(:
   ✓ Fix lbs
   ✓ Fix pbs not to include sameAs pagebreaks
   ✓ Fix milestones and notes to have divs as predecessors, not p's
   - Add head,
         ref,
         reg,
         corr,
         ...?
:)

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
        else if ($mode = ('citetrail', 'passagetrail')) then
            render:dispatch($targetNode, $mode)
        else 
            (: neither html nor numeric mode :) 
            render:dispatch($targetNode, 'title')
    
    (: (2) get related element's (e.g., ancestor's) trail, if required, and glue it together with the current trail ID 
            - HERE is the RECURSION :)
    (: (a) trail of related element: :)
    let $trailPrefix := 
        if ($mode = ('citetrail', 'crumbtrail')) then
            if ($targetNode/ancestor::*[render:isIndexNode(.) and not(self::tei:text[not(@type eq 'work_volume')])]) then
                if ($targetNode[self::tei:pb]) then 
                    if ($targetNode/ancestor::tei:front|$targetNode/ancestor::tei:back|$targetNode/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")]) then
                        (: within front, back, and single volumes, prepend front's or volume's trail ID for avoiding multiple identical IDs in the same work :)
                        render:getNodetrail($targetWork,  ($targetNode/ancestor::tei:front|$targetNode/ancestor::tei:back|$targetNode/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")])[last()], $mode, $fragmentIds)
                    else ()
                else if ($targetNode[self::tei:note or self::tei:milestone]) then
                    (: citable parents of notes and milestones should not be p :)
                    render:getNodetrail($targetWork, $targetNode/ancestor::*[render:isIndexNode(.) and not(self::tei:p)][1], $mode, $fragmentIds)
                else 
                    (: === for all other node types, get parent node's trail (deep recursion) === :)
                    render:getNodetrail($targetWork, $targetNode/ancestor::*[render:isIndexNode(.)][1], $mode, $fragmentIds)
            else ()
        else if ($mode eq 'passagetrail') then
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
        else if ($mode eq 'citetrail') then string-join(($trailPrefix, $connector, $currentNode), '')
        else if ($mode eq 'passagetrail') then string-join(($trailPrefix, $connector, $currentNode), '')
        else ()
        
    return $trail
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
        if (substring($targetWorkId, 1, 2) eq "W0") then
            "work.html?wid="
        else if (substring($targetWorkId, 1, 2) eq "L0") then
            "lemma.html?lid="
        else if (substring($targetWorkId, 1, 2) eq "A0") then
            "author.html?aid="
        else if (substring($targetWorkId, 1, 2) eq "WP") then
            "workingPaper.html?wpid="
        else
            "index.html?wid="
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

(: ####====---- End Helper Functions ----====#### :)




(: ####====---- Actual Rendering Typeswitch Functions ----====#### :)

(:  MODES: 
~   - 'orig', 'edit': plain text
~   - 'html', 'work': HTML
~   - 'snippets-orig', 'snippets-edit': plain text for Sphinx snippets
~   - 'title': title of a node (only for nodes that represent sections)
~   - 'passagetrail': passagetrail ID of a node (only for nodes that represent passagetrail sections)
~   - 'citetrail': citetrail ID of a node (only for nodes that represent citetrail/crumbtrail sections)
~   - 'crumbtrail': crumbtrail ID of a node (only for nodes that represent citetrail/crumbtrail sections)
~   - 'class': i18n class of a node, usually to be used by HTML-/RDF-related functionalities for generating verbose labels when displaying section titles 
:)

(: $mode can be "orig", "edit" (both being plain text modes), "html" or, even more sophisticated, "work" :)
declare function render:dispatch($node as node(), $mode as xs:string) {
    typeswitch($node)
    (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
        case text()                 return render:textNode($node, $mode)
        case element(tei:g)         return render:g($node, $mode)
        case element(tei:lb)        return render:lb($node, $mode)
        case element(tei:pb)        return render:pb($node, $mode)
        case element(tei:cb)        return render:cb($node, $mode)
        case element(tei:fw)        return render:fw($node, $mode)

        case element(tei:head)      return render:head($node, $mode) (: snippets: passthru :)
        case element(tei:p)         return render:p($node, $mode)
        case element(tei:note)      return render:note($node, $mode)
        case element(tei:div)       return render:div($node, $mode)
        case element(tei:milestone) return render:milestone($node, $mode)
        
        case element(tei:abbr)      return render:abbr($node, $mode)
        case element(tei:orig)      return render:orig($node, $mode)
        case element(tei:sic)       return render:sic($node, $mode)
        case element(tei:expan)     return render:expan($node, $mode)
        case element(tei:reg)       return render:reg($node, $mode)
        case element(tei:corr)      return render:corr($node, $mode)
        
        case element(tei:persName)  return render:name($node, $mode)
        case element(tei:placeName) return render:name($node, $mode)
        case element(tei:orgName)   return render:name($node, $mode)
        case element(tei:title)     return render:name($node, $mode)
        case element(tei:term)      return render:term($node, $mode)
        case element(tei:bibl)      return render:bibl($node, $mode)

        case element(tei:hi)        return render:hi($node, $mode) 
        case element(tei:emph)      return render:emph($node, $mode)
        case element(tei:ref)       return render:ref($node, $mode) 
        case element(tei:quote)     return render:quote($node, $mode)
        case element(tei:soCalled)  return render:soCalled($node, $mode)

        case element(tei:list)      return render:list($node, $mode)
        case element(tei:item)      return render:item($node, $mode)
        case element(tei:gloss)     return render:gloss($node, $mode)
        case element(tei:eg)        return render:eg($node, $mode)

        case element(tei:birth)     return render:birth($node, $mode) 
        case element(tei:death)     return render:death($node, $mode)

        case element(tei:lg)        return render:lg($node, $mode)
        case element(tei:signed)    return render:signed($node, $mode) 
        case element(tei:titlePage) return render:titlePage($node, $mode)
        case element(tei:label)     return render:label($node, $mode)
        
        case element(tei:text)      return render:text($node, $mode) 
        case element(tei:front)     return render:front($node, $mode) 
        case element(tei:body)      return render:body($node, $mode)
        case element(tei:back)      return render:back($node, $mode)

        case element(tei:figDesc)     return ()
        case element(tei:teiHeader)   return ()
        case comment()                return ()
        case processing-instruction() return ()

        default return render:passthru($node, $mode)
};


declare function render:text($node as element(tei:text), $mode as xs:string) {
    if ($mode eq 'title') then
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
    
    else if ($mode eq 'class') then
        if ($node/@type eq 'work_volume') then 'tei-text-' || $node/@type
        else if ($node/@xml:id eq 'completeWork') then 'tei-text-' || $node/@xml:id
        else if (matches($node/@xml:id, 'work_part_[a-z]')) then 'elem-text-' || $node/@xml:id
        else 'tei-text'
    
    else if ($mode eq 'citetrail') then
        (: "volX" where X is the current volume number, don't use it at all for monographs :)
        if ($node/@type eq 'work_volume') then
           concat('vol', count($node/preceding::tei:text[@type eq 'work_volume']) + 1)
        else ()
    
    else if ($mode eq 'passagetrail') then
        if (render:isPassagetrailNode($node)) then
            'vol. ' || $node/@n
        else ()
    
    else
        render:passthru($node, $mode)
};

declare function render:titlePart($node as element(tei:titlePart), $mode as xs:string) {
    if ($mode eq 'title') then
        normalize-space(
            render:teaserString($node, 'edit')
        )
    else if ($mode eq 'class') then
        'tei-' || local-name($node)
    else if ($mode eq 'citetrail') then
        (: "titlePage.X" where X is the number of parts where this occurs :)
        concat('titlepage.', string(count($node/preceding-sibling::tei:titlePart) + 1))
    else 
        render:passthru($node, $mode)
};

declare function render:lg($node as element(tei:lg), $mode as xs:string) {
    if ($mode eq 'title') then
        normalize-space(
            render:teaserString($node, 'edit')
        )
    else if ($mode eq 'class') then
        'tei-' || local-name($node)
        
    else if ($mode eq 'citetrail') then
        if (render:isUnnamedCitetrailNode($node)) then 
            string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
        else ()
        
    else
        render:passthru($node, $mode)
};

declare function render:signed($node as element(tei:signed), $mode as xs:string) {
    if ($mode eq 'title') then
        normalize-space(
            render:teaserString($node, 'edit')
        )
    else if ($mode eq 'class') then
        'tei-' || local-name($node)
        
    else if ($mode eq 'citetrail') then
        if (render:isUnnamedCitetrailNode($node)) then 
            string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
        else ()
        
    else if ($mode = ('snippets-orig', 'snippets-edit')) then
        for $subnode in $node/node() where (local-name($subnode) ne 'note') return render:dispatch($subnode, $mode)
        
    else
        render:passthru($node, $mode)
};

declare function render:titlePage($node as element(tei:titlePage), $mode as xs:string) {
    if ($mode eq 'title') then
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
    
    else if ($mode eq 'class') then
        'tei-' || local-name($node)
    
    else if ($mode eq 'citetrail') then
        'titlepage'
    
    else if ($mode eq 'passagetrail') then
        $config:citationLabels(local-name($node))?('abbr')
    
    else
        render:passthru($node, $mode)
};

declare function render:label($node as element(tei:label), $mode as xs:string) {
    if ($mode eq 'title') then
        normalize-space(
            render:teaserString($node, 'edit')
        )
    else if ($mode eq 'class') then
        'tei-' || local-name($node)
        
    else if ($mode eq 'citetrail') then
        if (render:isUnnamedCitetrailNode($node)) then 
            string(count($node/preceding-sibling::*[render:isUnnamedCitetrailNode(.)]) + 1)
        else ()
        
    else
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

declare function render:body($node as element(tei:body), $mode as xs:string) {
    switch($mode)
        case 'class' return
            'tei-' || local-name($node)
        
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

declare function render:textNode($node as node(), $mode as xs:string) {
    switch($mode)
        case "orig"
        case "edit"
        case "html"
        case "work" return
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

declare function render:passthru($nodes as node()*, $mode as xs:string) as item()* {
    for $node in $nodes/node() return render:dispatch($node, $mode)
};

declare function render:pb($node as element(tei:pb), $mode as xs:string) {
    switch($mode)
        case 'title' return
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
                if (matches($node/@n, '[A-Za-z0-9]')) then
                    upper-case(replace($node/@n, '[^a-zA-Z0-9]', ''))
                else substring($node/@facs, 6)
            )
            (: TODO: are collisions possible, esp. if pb's crumb does not inherit from the specific section (titlePage|div)? 
               -> for example, with repetitive page numbers in the appendix 
                (ideally, such collisions should be resolved in TEI markup, but one never knows...) :)
        
        case 'passagetrail' return
            if (contains($node/@n, 'fol.')) then $node/@n
            else 'p. ' || $node/@n
        
        case "orig"
        case "edit"
        case "html"
        case "work" return
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

declare function render:cb($node as element(tei:cb), $mode as xs:string) {
    switch($mode)
        case "orig" 
        case "edit"
        case "html"
        case "work"
        case 'snippets-orig'
        case 'snippets-edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render:lb($node as element(tei:lb), $mode as xs:string) {
    switch($mode)
        case "orig"
        case "edit"
        case "work"
        case 'snippets-orig'
        case 'snippets-edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
    
        case "html" return 
            <br/>
    
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

declare function render:p($node as element(tei:p), $mode as xs:string) {
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
        
        case 'passagetrail' return
            if (render:isPassagetrailNode($node)) then
                let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $teaser := '"' || normalize-space(substring(substring-after(render:p($node, 'title'), '"'),1,15)) || '…"'(: short teaser :)
                return $prefix || ' ' || $teaser
            else ()
        
        case "orig"
        case "edit" return
            if ($node/ancestor::tei:note) then
                if ($node/following-sibling::tei:p) then
                    (render:passthru($node, $mode), $config:nl)
                else
                    render:passthru($node, $mode)
            else
                ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case "html" return
            if ($node/ancestor::tei:note) then
                render:passthru($node, $mode)
            else
                <p class="hauptText" id="{$node/@xml:id}">
                    {render:passthru($node, $mode)}
                </p>
        
        case "work" return   (: the same as in html mode except for distinguishing between paragraphs in notes and in the main text. In the latter case, make them a div, not a p and add a tool menu. :)
            if ($node/parent::tei:note) then
                render:passthru($node, $mode)
            else
                <p class="hauptText" id="{$node/@xml:id}">
                    {render:passthru($node, $mode)}
                </p>
        
        case 'snippets-orig'
        case 'snippets-edit' return
            for $subnode in $node/node() where (local-name($subnode) ne 'note') return render:dispatch($subnode, $mode)
        
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
            
        case "orig"
        case "edit" return
            ($config:nl, "        {", render:passthru($node, $mode), "}", $config:nl)
        
        case "html"
        case "work" return
            let $normalizedString := normalize-space(string-join(render:passthru($node, $mode), ' '))
            let $identifier       := $node/@xml:id
            return
                (<sup>*</sup>,
                <span class="marginal note" id="note_{$identifier}">
                    {if (string-length($normalizedString) gt $config:chars_summary) then
                        (<a class="{string-join(for $biblKey in $node//tei:bibl/@sortKey return concat('hi_', $biblKey), ' ')}" data-toggle="collapse" data-target="#subdiv_{$identifier}">{concat('* ', substring($normalizedString, 1, $config:chars_summary), '…')}<i class="fa fa-angle-double-down"/></a>,<br/>,
                         <span class="collapse" id="subdiv_{$identifier}">{render:passthru($node, $mode)}</span>)
                     else
                        <span><sup>* </sup>{render:passthru($node, $mode)}</span>
                    }
                </span>)
        
        default return
            render:passthru($node, $mode)
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
        
        case "orig" return
             ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case "edit" return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                (concat($config:nl, '[ *', string($node/@n), '* ]'), $config:nl, render:passthru($node, $mode), $config:nl)
                (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                ($config:nl, render:passthru($node, $mode), $config:nl)
        
        case 'html' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                (<h4 id="{$node/@xml:id}">{string($node/@n)}</h4>,<p id="p_{$node/@xml:id}">{render:passthru($node, $mode)}</p>)
                (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                <div id="{$node/@xml:id}">{render:passthru($node, $mode)}</div>
        
        case "work" return (: basically, the same except for eventually adding a <div class="summary_title"/> the data for which is complicated to retrieve :)
            render:passthru($node, $mode)
        
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


declare function render:milestone($node as element(tei:milestone), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '&#34;' || string($node/@n) || '&#34;'
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@unit)) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    render:teaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
            
        case 'class' return
            'tei-milestone-' || $node/@unit
            
        case 'citetrail' return
            (: "XY" where X is the unit and Y is the anchor or the number of milestones where this occurs :)
            let $currentSection := sal-util:copy($node/ancestor::*[render:isIndexNode(.) and not(self::tei:p)][1])
            let $currentNode := $currentSection//tei:milestone[@xml:id eq $node/@xml:id]
            return
                if ($node/@n[matches(., '[a-zA-Z0-9]')]) then 
                    
                    let $similarMs :=
                        $currentSection//tei:milestone[@unit eq $currentNode/@unit 
                                                       and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]
                    let $position :=
                        if (count($similarMs) gt 1) then
                            
                            string(count($currentNode/preceding::tei:milestone intersect $similarMs) + 1) (: TODO: performance issues? :)
                        else ()
                    return $currentNode/@unit || upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', '')) || $position
                else $currentNode/@unit || string(count($currentNode/preceding::tei:milestone[@unit eq $node/@unit] intersect $currentSection//tei:milestone[@unit eq $currentNode/@unit]) + 1)
                (: without on-the-fly copying: :)
                (:if ($node/@n[matches(., '[a-zA-Z0-9]')]) then 
                    let $similarMs :=
                        $node/ancestor::*[render:isIndexNode(.) and not(self::tei:p)][1]//tei:milestone[@unit eq $node/@unit 
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
        
        case "html" return
            let $anchor :=  if ($node/@rendition = '#dagger') then
                                '†'
                            else if ($node/@rendition = '#asterisk') then
                                '*'
                            else ()
            let $summary := if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                                <div class="summary_title" id="{string($node/@xml:id)}">{string($node/@n)}</div>
                            else if ($node/@n and matches($node/@n, '^[0-9\[\]]+$')) then
                                <div class="summary_title" id="{string($node/@xml:id)}">{concat($config:citationLabels($node/@unit)?('abbr'), ' ', string($node/@n))}</div>
                            (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
                            else ()
            return ($anchor, $summary)
        
        case "work" return ()    (: basically, the same except for eventually adding a <div class="summary_title"/> :)
        
        default return () (: also for snippets-orig, snippets-edit :)
};


(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function render:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                render:teaserString($node, 'edit')
            )
        
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
        
        case "orig"
        case "edit" return
            (render:passthru($node, $mode), $config:nl)
        
        case "html"
        case "work" return
            let $lang   := request:get-attribute('lang')
            let $page   :=      if ($node/ancestor::tei:text/@type="author_article") then
                                    "author.html?aid="
                           else if ($node/ancestor::tei:text/@type="lemma_article") then
                                    "lemma.html?lid="
                           else
                                    "work.html?wid="
            return    
                <h3 id="{$node/@xml:id}">
                    <a class="anchorjs-link" id="{$node/parent::tei:div/@xml:id}" href="{session:encode-url(xs:anyURI($page || $node/ancestor::tei:TEI/@xml:id || '#' || $node/parent::tei:div/@xml:id))}">
                        <span class="anchorjs-icon"></span>
                    </a>
                    {render:passthru($node, $mode)}
                </h3>
        
        default return 
            render:passthru($node, $mode)
};

declare function render:origElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'orig' return
            render:passthru($node, $mode)
        
        case 'edit' return
            if (not($node/(preceding-sibling::tei:expan|preceding-sibling::tei:reg|preceding-sibling::tei:corr|following-sibling::tei:expan|following-sibling::tei:reg|following-sibling::tei:corr))) then
                render:passthru($node, $mode)
            else ()
        
        case 'html'
        case 'work' return
            let $editedString := render:dispatch($node/parent::tei:choice/(tei:expan|tei:reg|tei:corr), "edit")
            return  if ($node/parent::tei:choice) then
                        <span class="original {local-name($node)} unsichtbar" title="{string-join($editedString, '')}">
                            {render:passthru($node, $mode)}
                        </span>
                    else
                        render:passthru($node, $mode)
        default return
            render:passthru($node, $mode)
};

declare function render:editElem($node as element(), $mode as xs:string) {
    if ($mode = "orig") then ()
    else if ($mode = "edit") then
        render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        let $originalString := render:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), "orig")
        return  
            <span class="edited {local-name($node)}" title="{string-join($originalString, '')}">
                {render:passthru($node, $mode)}
            </span>
    else
        render:passthru($node, $mode)
};

declare function render:g($node as element(tei:g), $mode as xs:string) {
    switch ($mode)
        case "orig"
        case "snippets-orig" return
            let $glyph := $node/ancestor::tei:TEI//tei:char[@xml:id = substring(string($node/@ref), 2)] (: remove leading '#' :)
            return if ($glyph/tei:mapping[@type = 'precomposed']) then
                    string($glyph/tei:mapping[@type = 'precomposed'])
                else if ($glyph/tei:mapping[@type = 'composed']) then
                    string($glyph/tei:mapping[@type = 'composed'])
                else if ($glyph/tei:mapping[@type = 'standardized']) then
                    string($glyph/tei:mapping[@type = 'standardized'])
                else
                    render:passthru($node, $mode)
        
        case "edit" return
            let $glyph := $node/ancestor::tei:TEI//tei:char[@xml:id = substring(string($node/@ref), 2)]
            return  if ($glyph/tei:mapping[@type = 'standardized']) then
                        string($glyph/tei:mapping[@type = 'standardized'])
                    else
                        render:passthru($node, $mode)
        case "work" return
            let $originalGlyph := render:g($node, "orig")
            return
                (<span class="original glyph unsichtbar" title="{$node/text()}">
                    {$originalGlyph}
                </span>,
                <span class="edited glyph" title="{$originalGlyph}">
                    {$node/text()}
                </span>)
        
        default return (: also 'snippets-edit' :)
            render:passthru($node, $mode)
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
                
        case 'html'
        case 'work' return
            let $elementName    := "term"
            let $key            := $node/@key
            let $getLemmaId     := tokenize(tokenize($node/@ref, 'lemma:')[2], ' ')[1]
            let $highlightName  :=  
                if ($node/@ref) then
                    concat('hi_', translate(translate(translate(tokenize($node/@ref, ' ')[1], ',', ''), ' ', ''), ':', ''))
                else if ($node/@key) then
                    concat('hi_', translate(translate(translate(tokenize($node/@key, ' ')[1], ',', ''), ' ', ''), ':', ''))
                else ()
            let $dictLemmaName :=  
                if ($node/ancestor::tei:list[@type="dict"] and not($node/preceding-sibling::tei:term)) then
                    'dictLemma'
                else ()
            let $classes := normalize-space(string-join(($elementName, $highlightName, $dictLemmaName), ' '))
            return                
                <span class="{$classes}" title="{$key}">
                    {if ($getLemmaId) then
                        <a href="{session:encode-url(xs:anyURI('lemma.html?lid=' || $getLemmaId))}">{render:passthru($node, $mode)}</a>
                     else
                        render:passthru($node, $mode)
                    }
                </span>
                
        default return
            render:passthru($node, $mode)
};

declare function render:name($node as element(*), $mode as xs:string) {
    if ($mode = "orig") then
        render:passthru($node, $mode)
    else if ($mode = "edit") then
        if ($node/(@key|@ref)) then
            (render:passthru($node, $mode), ' [', string-join(($node/@key, $node/@ref), '/'), ']')
        else
            render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        let $nodeType       := local-name($node)
        let $lang           := request:get-attribute('lang')
        let $getWorkId      := tokenize(tokenize($node/@ref, 'work:'  )[2], ' ')[1]
        let $getAutId       := tokenize(tokenize($node/@ref, 'author:')[2], ' ')[1]
        let $getCerlId      := tokenize(tokenize($node/@ref, 'cerl:'  )[2], ' ')[1]
        let $getGndId       := tokenize(tokenize($node/@ref, 'gnd:'   )[2], ' ')[1]
        let $getGettyId     := tokenize(tokenize($node/@ref, 'getty:' )[2], ' ')[1]
        let $key            := $node/@key

        return
           if ($getWorkId) then
                 <span class="{($nodeType || ' hi_work_' || $getWorkId)}">
                     <a href="{concat($config:idserver, '/works.', $getWorkId)}" title="{$key}">{render:passthru($node, $mode)}</a>
                 </span> 
           else if ($getAutId) then
                 <span class="{($nodeType || ' hi_author_' || $getAutId)}">
                     <a href="{concat($config:idserver, '/authors.', $getAutId)}" title="{$key}">{render:passthru($node, $mode)}</a>
                 </span> 
            else if ($getCerlId) then 
                 <span class="{($nodeType || ' hi_cerl_' || $getCerlId)}">
                    <a target="_blank" href="{('http://thesaurus.cerl.org/cgi-bin/record.pl?rid=' || $getCerlId)}" title="{$key}">{render:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                 </span>
            else if ($getGndId) then 
                 <span class="{($nodeType || ' hi_gnd_' || $getGndId)}">
                    <a target="_blank" href="{('http://d-nb.info/' || $getGndId)}" title="{$key}">{render:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                 </span>
            else if ($getGettyId) then 
                 <span class="{($nodeType || ' hi_getty_' || $getGettyId)}">
                    <a target="_blank" href="{('http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=' || $getGettyId)}" title="{$key}">{render:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                 </span>
            else
                <span>{render:passthru($node, $mode)}</span>
    else
        render:passthru($node, $mode)
};
(: titles are dealt with using the general name function above...
declare function render:title($node as element(tei:title), $mode as xs:string) {
    if ($mode = "orig") then
        render:passthru($node, $mode)
    else if ($mode = "edit") then
        if ($node/@key) then
            string($node/@key)
        else
            render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        if ($node/@ref) then
             <span class="bibl-title"><a target="blank" href="{$node/@ref}">{render:passthru($node, $mode)}<span class="glyphicon glyphicon-new-window" aria-hidden="true"/></a></span>
        else
             <span class="bibl-title">{render:passthru($node, $mode)}</span>
    else
        render:passthru($node, $mode)
};:)

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
        
        case 'work' return
            let $getBiblId :=  $node/@sortKey
            return if ($getBiblId) then
                        <span class="{('work hi_' || $getBiblId)}">
                            {render:passthru($node, $mode)}
                        </span>
                    else
                        render:passthru($node, $mode)
        default return
            render:passthru($node, $mode)
};


declare function render:emph($node as element(tei:emph), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = "work") then
            <span class="emph">{render:passthru($node, $mode)}</span>
    else if ($mode = "html") then
            <em>{render:passthru($node, $mode)}</em>
    else
        render:passthru($node, $mode)
};
declare function render:hi($node as element(tei:hi), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        if ("#b" = $node/@rendition) then
            <b>
                {render:passthru($node, $mode)}
            </b>
        else if ("#initCaps" = $node/@rendition) then
            <span class="initialCaps">
                {render:passthru($node, $mode)}
            </span>
        else if ("#it" = $node/@rendition) then
            <it>
                {render:passthru($node, $mode)}
            </it>
        else if ("#l-indent" = $node/@rendition) then
            <span style="display:block;margin-left:4em;">
                {render:passthru($node, $mode)}
            </span>
        else if ("#r-center" = $node/@rendition) then
            <span style="display:block;text-align:center;">
                {render:passthru($node, $mode)}
            </span>
        else if ("#sc" = $node/@rendition) then
            <span class="smallcaps">
                {render:passthru($node, $mode)}
            </span>
        else if ("#spc" = $node/@rendition) then
            <span class="spaced">
                {render:passthru($node, $mode)}
            </span>
        else if ("#sub" = $node/@rendition) then
            <sub>
                {render:passthru($node, $mode)}
            </sub>
        else if ("#sup" = $node/@rendition) then
            <sup>
                {render:passthru($node, $mode)}
            </sup>
        else
            <it>
                {render:passthru($node, $mode)}
            </it>
    else 
        render:passthru($node, $mode)
};
declare function render:ref($node as element(tei:ref), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = "html" and $node/@type = "url") then
        if (substring($node/@target, 1, 4) = "http") then
            <a href="{$node/@target}" target="_blank">{render:passthru($node, $mode)}</a>
        else
            <a href="{$node/@target}">{render:passthru($node, $mode)}</a>
    else if ($mode = "work") then                                       (: basically the same, but use the resolveURI functions to get the actual target :)
        <a href="{$node/@target}">{render:passthru($node, $mode)}</a>
    else
        render:passthru($node, $mode)
};
declare function render:soCalled($node as element(tei:soCalled), $mode as xs:string) {
    if ($mode=("orig", "edit")) then
        ("'", render:passthru($node, $mode), "'")
    else if ($mode = ("html", "work")) then
        <span class="soCalled">{render:passthru($node, $mode)}</span>
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else
        ("'", render:passthru($node, $mode), "'")
};
declare function render:quote($node as element(tei:quote), $mode as xs:string) {
    if ($mode=("orig", "edit")) then
        ('"', render:passthru($node, $mode), '"')
    else if ($mode = ("html", "work")) then
        <span class="quote">{render:passthru($node, $mode)}</span>
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else
        ('"', render:passthru($node, $mode), '"')
};

declare function render:list($node as element(tei:list), $mode as xs:string) {
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
    
    case "html"
    case "work" return
        if ($node/@type = "ordered") then
            <section>
                {if ($node/child::tei:head) then
                    for $head in $node/tei:head
                        return
                            <h4>
                                {render:passthru($head, $mode)}
                            </h4>
                 else ()
                }
                <ol>
                    {for $item in $node/tei:*[not(local-name() = "head")]
                            return
                                render:dispatch($item, $mode)
                    }
                </ol>
            </section>
        else if ($node/@type = "simple") then
            <section>
                {if ($node/tei:head) then
                    for $head in $node/tei:head
                        return
                            <h4>{render:passthru($head, $mode)}</h4>
                 else ()
                }
                {for $item in $node/tei:*[not(local-name() = "head")]
                        return
                                render:dispatch($item, $mode)
                }
            </section>
        else
            <figure class="{$node/@type}">
                {if ($node/child::tei:head) then
                    for $head in $node/tei:head
                        return
                            <h4>{render:passthru($head, $mode)}</h4>
                 else ()
                }
                <ul>
                    {for $item in $node/tei:*[not(local-name() = "head")]
                            return
                                render:dispatch($item, $mode)
                    }
                </ul>
            </figure>
    
    case 'snippets-edit'
    case 'snippets-orig' return
        render:passthru($node, $mode)
    
    default return
        ($config:nl, render:passthru($node, $mode), $config:nl)
};

declare function render:item($node as element(tei:item), $mode as xs:string) {
    switch($mode)
        case 'title' return
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
        
        case "orig"
        case "edit" return
            let $leader :=  if ($node/parent::tei:list/@type = "numbered") then
                                '#' || $config:nbsp
                            else if ($node/parent::tei:list/@type = "simple") then
                                $config:nbsp
                            else
                                '-' || $config:nbsp
            return ($leader, render:passthru($node, $mode), $config:nl)
       
        case "html"
        case "work" return
            if ($node/parent::tei:list/@type="simple") then
                render:passthru($node, $mode)
            else
                <li>{render:passthru($node, $mode)}</li>
        
        default return
            render:passthru($node, $mode)
};
declare function render:gloss($node as element(tei:gloss), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        render:passthru($node, $mode)
    else
        render:passthru($node, $mode)
};

declare function render:eg($node as element(tei:eg), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        <pre>{render:passthru($node, $mode)}</pre>
    else 
        render:passthru($node, $mode)
};


declare function render:birth($node as element(tei:birth), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        <span>*&#xA0;{render:name($node/tei:placeName[1], $mode) || ': ' || $node/tei:date[1]}</span>
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else ()
};
declare function render:death($node as element(tei:death), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        render:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        <span>†&#xA0;{render:name($node/tei:placeName[1], $mode) || ': ' || $node/tei:date[1]}</span>
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        render:passthru($node, $mode)
    else ()
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

declare function render:orgName($node as element(tei:orgName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig'
        case 'snippets-edit' return
            render:passthru($node, $mode)
        default return
            render:name($mode, $node)
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

declare function render:expan($node as element(tei:expan), $mode) {
    switch($mode)
        case 'snippets-orig' return 
            ()
        case 'snippets-edit' return
            render:passthru($node, $mode)
        default return
            render:editElem($node, $mode)
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
declare function render:corr($node as element(tei:corr), $mode) {
    switch($mode)
        case 'snippets-orig' return 
            ()
        case 'snippets-edit' return
            render:passthru($node, $mode)
        default return
            render:editElem($node, $mode)
};

declare function render:fw($node as element(tei:fw), $mode) {
    ()
};

(: TODO: still undefined: titlePage descendants: titlePart, docTitle, ...; choice, l; author fields: state etc. :)

