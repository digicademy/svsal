xquery version "3.1";

module namespace index            = "https://www.salamanca.school/factory/works/index";
declare namespace exist            = "http://exist.sourceforge.net/NS/exist";
declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";
declare namespace xi                = "http://www.w3.org/2001/XInclude";

import module namespace functx      = "http://www.functx.com";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace config     = "http://www.salamanca.school/xquery/config" at "../../config.xqm";
import module namespace sutil    = "http://www.salamanca.school/xquery/sutil" at "../../sutil.xqm";
import module namespace txt        = "https://www.salamanca.school/factory/works/txt" at "txt.xqm";



(: ####++++----  

    Functions for extracting node indices (sal:index) from TEI works; also includes functionality for making 
    citetrails, passagetrails, and crumbtrails.
   
   ----++++#### :)


(: CONFIG :)


declare variable $index:citetrailConnector := '.';
declare variable $index:passagetrailConnector := ' ';
declare variable $index:crumbtrailConnector := ' » ';



(: NODE INDEX functions :)


(:
~ Controller function for creating (and reporting about) node indexes. 
:)
declare function index:makeNodeIndex($tei as element(tei:TEI)) as map(*) {
    let $wid := $tei/@xml:id
    let $xincludes := $tei//tei:text//xi:include/@href
    let $work := util:expand($tei)
    
    let $fragmentationDepth := index:determineFragmentationDepth($tei)
    let $debug := if ($config:debug = ("trace", "info")) then console:log("Rendering " || $wid || " at fragmentation level " || $fragmentationDepth || ".") else ()
    let $target-set := index:getFragmentNodes($work, $fragmentationDepth)
    
    (: First, get all relevant nodes :)
    let $nodes := 
        for $text in $work//tei:text[@type = ('work_volume', 'work_monograph')] return 
            (: make sure that we only grasp nodes that are within a published volume :)
            if (($text/@type eq 'work_volume' and sutil:WRKisPublished($wid || '_' || $text/@xml:id))
                or $text/@type eq 'work_monograph') then 
                $text/descendant-or-self::*[index:isIndexNode(.)]
            else ()
                
    (: Create the fragment id for each node beforehand, so that recursive crumbtrail creation has it readily available :)
    let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Node indexing: identifying fragment ids ...") else ()
    let $fragmentIds :=
        map:merge(
            for $node in $nodes
                let $n := $node/@xml:id/string()
                let $frag := (($node/ancestor-or-self::tei:* | $node//tei:*) intersect $target-set)[1]
                let $fragId := index:makeFragmentId(functx:index-of-node($target-set, $frag), $frag/@xml:id)
                return map:entry($n, $fragId)
        )
    let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Node indexing: fragment ids extracted.") else ()
                
    let $debug := if ($config:debug = ("trace")) then console:log("[ADMIN] Node indexing: creating index file ...") else ()
    (: node indexing has 2 stages: :)
    (: 1.) extract nested sal:nodes with rudimentary information :)
    let $indexTree := 
        <sal:index>
            {index:extractNodeStructure($wid, $work//tei:text[not(ancestor::tei:text)], $xincludes, $fragmentIds)}
        </sal:index>
    (: 2.) flatten the index from 1.) and enrich sal:nodes with full-blown citetrails, etc. :)
    let $index := 
        <sal:index work="{$wid}" xml:space="preserve">
            {index:createIndexNodes($indexTree)(:$indexTree/*:)}
        </sal:index>
        
    let $check := index:qualityCheck($index, $work, $target-set, $fragmentationDepth)
        
    return 
        map {
            'index': $index,
            'missed_elements': $check('missed_elements'),
            'unidentified_elements': $check('unidentified_elements'),
            'fragmentation_depth': $fragmentationDepth,
            'target_set_count': count($target-set)
        }
};


(:
~ Determines the fragmentation depth of a work, i.e. the hierarchical level of nodes within a TEI dataset which serve
~ as root nodes for spltting the dataset into HTML fragments.
:)
declare function index:determineFragmentationDepth($work as element(tei:TEI)) as xs:integer {
    if ($work//processing-instruction('svsal')[matches(., 'htmlFragmentationDepth="\d{1,2}"')]) then
        xs:integer($work//processing-instruction('svsal')[matches(., 'htmlFragmentationDepth="\d{1,2}"')][1]/replace(., 'htmlFragmentationDepth="(\d{1,2})"', '$1'))
    else $config:fragmentationDepthDefault
};


(: 
~ A rule picking those elements that should become the fragments for HTML-rendering a work. Requires an expanded(!) TEI work's dataset.
:)
declare function index:getFragmentNodes($work as element(tei:TEI), $fragmentationDepth as xs:integer) as node()* {
    (for $text in $work//tei:text[@type eq 'work_monograph' 
                                  or (@type eq 'work_volume' and sutil:WRKisPublished($work/@xml:id || '_' || @xml:id))] return 
        (
        (: in front, fragmentation must not go below the child level (child fragments shouldn't be too large here) :)
        (if ($text/tei:front//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]) then
             $text/tei:front/*
         else $text/tei:front),
        (if ($text/tei:body//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]) then
             $text/tei:body//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]
         else $text/tei:body),
        (if ($text/tei:back//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]) then
             $text/tei:back//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]
         else $text/tei:back)
        )
    )
    (:    $work//tei:text//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]:)
};


(:
~ Creates a tree of index nodes (sal:node), where nodes are hierarchically nested according to the hierarchy of nodes in the original TEI tree.
~ Supplies nodes with basic information (sal:title, sal:passage, etc.), while temporary elements/attributes provide 
~ information that can be used for the production of citetrails, crumbtrails etc. in the 
~ final index creation through index:createIndexNodes().
:)
declare function index:extractNodeStructure($wid as xs:string, $input as node()*, $xincludes as attribute()*, $fragmentIds as map()?) as element(sal:node)* {
    for $node in $input return
        typeswitch($node)
            case element() return
                (: index:isIndexNode($node) has already been called in admin:createIndex, so we can use that run here: :)
                if (:(index:isIndexNode($node)):) ($node/@xml:id and $fragmentIds($node/@xml:id)) then
                    let $debug := if ($config:debug = ("trace") and $node/self::tei:pb) then index:pb($node, 'debug') else ()
                    let $subtype := 
                        if ($node[self::tei:milestone]/@n) then (: TODO: where is this used? :)
                            string($node/@n)
                        else if ($node/@type) then
                            string($node/@type)
                        else ()
(:                    let $isBasicNode := if (index:isBasicNode($node)) then 'true' else 'false':)
                    let $isNamedCitetrailNode := if (index:isNamedCitetrailNode($node)) then 'true' else 'false'
(:                    let $category := index:getNodeCategory($node):)
(:                    let $isPassageNode := if (index:isPassagetrailNode($node)) then 'true' else 'false':)
                    return
                        element sal:node {
                            attribute type              {local-name($node)}, 
                            attribute subtype           {$subtype}, 
                            attribute xml:id                 {$node/@xml:id/string()},
                            if ($node/@xml:id eq 'completeWork' and $xincludes) then
                                attribute xinc          {$xincludes}
                            else (), 
                            attribute class             {index:dispatch($node, 'class')},
(:                            attribute category          {$category},:)
(:                            attribute isBasic           {$isBasicNode},:)
                            attribute isNamedCit        {$isNamedCitetrailNode},
(:                            attribute isPassage         {$isPassageNode},:)
                            element sal:title           {index:dispatch($node, 'title')},
                            element sal:fragment        {$fragmentIds($node/@xml:id/string())},
                            element sal:crumb           {index:makeCrumb($wid, $node, $fragmentIds)},
                            if (index:isPassagetrailNode($node)) then 
                                element sal:passage {index:dispatch($node, 'passagetrail')}
                            else (),
                            element sal:citableParent   {index:getCitableParent($node)/@xml:id/string()},
                            (: if the node is a named citetrail node, we include its citetrail part here already 
                               - unnamed citetrails can be done much faster in phase 2 :)
                            if ($isNamedCitetrailNode eq 'true') then 
                                element sal:cit {index:dispatch($node, 'citetrail')} 
                            else (),
                            element sal:children        {index:extractNodeStructure($wid, $node/node(), $xincludes, $fragmentIds)}
                        }
                else index:extractNodeStructure($wid, $node/node(), $xincludes, $fragmentIds)
            default return ()
};

(:
~ Creates a flat structure of index nodes (sal:node) from a hierarchically structured preliminary index (see index:extractNodeStructure()),
~ while enriching those nodes with final citetrails, crumbtrails, etc.
:)
declare function index:createIndexNodes($input as element(sal:index)) as element(sal:node)* {
    for $node in $input//sal:node return
        let $citetrail := index:constructCitetrail($node)
        let $crumbtrail := index:constructCrumbtrail($node)
        let $passagetrail := index:constructPassagetrail($node)
        return
            element sal:node {
                (: copy some elements and attributes from the previous node :)
                attribute n {$node/@xml:id/string()},
                $node/@* except ($node/@category, $node/@isBasicNode, $node/@isNamedCit, $node/@isPassage, $node/@xml:id),
                $node/sal:title, $node/sal:fragment, $node/sal:citableParent,
                element sal:citetrail {$citetrail},
                element sal:crumbtrail {$crumbtrail},
                element sal:passagetrail {$passagetrail}
            }
};


(: Conducts some basic quality checks with regards to consistency, uniqueness of citetrails, etc. within an sal:index :)
declare function index:qualityCheck($index as element(sal:index), 
                                    $work as element(tei:TEI), 
                                    $targetNodes as element()*, 
                                    $fragmentationDepth as xs:integer) {
                                    
    let $wid := $work/@xml:id
    
    (: #### Basic quality / consistency check #### :)
    let $resultNodes := $index//sal:node[not(@n eq 'completeWork')]
    let $testNodes := 
        if (count($resultNodes) eq 0) then 
            error(xs:QName('admin:createNodeIndex'), 'Node indexing did not produce any results.') 
        else ()
    (: every ordinary sal:node should have all of the required fields and values: :)
    let $testAttributes := 
        if ($testNodes[not(@class/string() and @type/string() and @n/string())]) then 
            error(xs:QName('admin:createNodeIndex'), 'Essential attributes are missing in at least one index node (in ' || $wid || ')') 
        else ()
    let $testChildren := if ($testNodes[not(sal:title and sal:fragment/text() and sal:citableParent/text() and sal:citetrail/text() and sal:crumbtrail/* and sal:passagetrail/text())]) then error() else ()
    (: there should be as many distinctive citetrails and crumbtrails as there are ordinary sal:node elements: :)
    let $testAmbiguousCitetrails := 
        if (count($resultNodes) ne count(distinct-values($resultNodes/sal:citetrail/text()))) then 
            error(xs:QName('admin:createNodeIndex'), 
                  'Could not produce a unique citetrail for each sal:node (in ' || $wid || '). Problematic nodes: '
                  || string-join(($resultNodes[sal:citetrail/text() = preceding::sal:citetrail/text()]/@n), '; ')) 
        else () 
    (: search these cases using: " //sal:citetrail[./text() = following::sal:citetrail/text()] :)
    let $testEmptyCitetrails :=
        if (count($resultNodes/sal:citetrail[not(./text())]) gt 0) then
            error(xs:QName('admin:createNodeIndex'), 
                  'Could not produce a citetrail for one or more sal:node (in' || $wid || '). Problematic nodes: '
                  || string-join(($resultNodes[not(sal:citetrail/text())]/@n), '; '))
        else ()
    (: search for " //sal:citetrail[not(./text())] ":)
    (: not checking crumbtrails here ATM for not slowing down index creation too much... :)
    
    (: check whether all text is being captured through basic index nodes (that is, whether every single passage is citable) :)
    let $checkBasicNodes := 
        for $t in $work//tei:text[@type eq 'work_monograph' 
                                  or (@type eq 'work_volume' and sutil:WRKisPublished($wid || '_' || @xml:id))]
                                  //text()[normalize-space() ne ''] return
            if ($t[not(ancestor::*[index:isBasicNode(.)]) and not(ancestor::tei:figDesc)]) then 
                let $debug := util:log('error', 'Encountered text node without ancestor::*[index:isBasicNode(.)], in line ' || $t/preceding::tei:lb[1]/@xml:id/string())
                return error(xs:QName('admin:createNodeIndex'), 'Encountered text node without ancestor::*[index:isBasicNode(.)], in line ' || $t/preceding::tei:lb[1]/@xml:id/string()) 
            else ()
    (: if no xml:id is put out, try to search these cases like so:
        //text//text()[not(normalize-space() eq '')][not(ancestor::*[@xml:id and (self::p or self::signed or self::head or self::titlePage or self::lg or self::item or self::label or self::argument or self::table)])]
    :)
    
    (: See if there are any leaf elements in our text that are not matched by our rule :)
    let $missed-elements := $work//(tei:front|tei:body|tei:back)//tei:*[count(./ancestor-or-self::tei:*) < $fragmentationDepth][not(*)]
    (: See if any of the elements we did get is lacking an xml:id attribute :)
    let $unidentified-elements := $targetNodes[not(@xml:id)]
    (: Keep track of how long this index did take :)
    
    return 
        (: return information that we want to inform about rather than throw hard errors :)
        map {
            'missed_elements': $missed-elements,
            'unidentified_elements': $unidentified-elements
        }
};


(: PASSAGETRAILS, CITETRAILS, CRUMBTRAILS (-- deep recursion) :)

declare function index:constructCitetrail($node as element(sal:node)) as xs:string {
    let $prefix := 
        if ($node/sal:citableParent/text() and $node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()]) then
            index:constructCitetrail($node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()])
        else ()
    let $this := 
        if ($node/sal:cit) then $node/sal:cit/text() 
        (: if sal:cit doesn't already exist, we are dealing with a numeric/unnamed citetrail node and create the citetrail part here: :)
        else string(count($node/preceding-sibling::sal:node[@isNamedCit eq 'false']) + 1)
    return
        if ($prefix and $this) then $prefix || $index:citetrailConnector || $this else $this
};

declare function index:constructCrumbtrail($node as element(sal:node)) as item()+ {
    let $prefix := 
        if ($node/sal:citableParent/text() and $node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()]) then
            index:constructCrumbtrail($node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()])
        else ()
    let $this := $node/sal:crumb/*
    return
        if ($prefix and $this) then ($prefix, $index:crumbtrailConnector, $this) else $this
};

declare function index:constructPassagetrail($node as element(sal:node)) as xs:string? {
    let $prefix := 
        if ($node/sal:citableParent/text() and $node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()]) then
            index:constructPassagetrail($node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()])
        else ()
    (: not every sal:node has a distinctive passage: :)
    let $this := if ($node/sal:passage/text()) then $node/sal:passage/text() else ''
    return
        if ($prefix and $this) then 
            $prefix || $index:passagetrailConnector || $this 
        else $prefix || $this (: this will only return one of both, if any at all :)
};

declare function index:makeCrumb($wid as xs:string, $node as node(), $fragmentIds as map()?) as element(a)? {
    let $class := index:dispatch($node, 'class')
    return
        if ($class) then
            <a class="{$class}" href="{index:makeUrl($wid, $node, $fragmentIds)}">{index:dispatch($node, 'title')}</a>
        else 
            <a href="{index:makeUrl($wid, $node, $fragmentIds)}">{index:dispatch($node, 'title')}</a>
};


(: Gets the citable crumbtrail/citetrail (not passagetrail!) parent :)
declare function index:getCitableParent($node as node()) as node()? {
    if (index:isMarginalNode($node) or index:isAnchorNode($node)) then
        (: notes, milestones etc. must not have p as their citableParent :)
        $node/ancestor::*[index:isStructuralNode(.)][1]
    else if (index:isPageNode($node)) then
        if ($node/ancestor::tei:front|$node/ancestor::tei:back|$node/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type eq 'work_part')]) then
            (: within front, back, and single volumes, citable parent resolves to one of those elements for avoiding collisions with identically named pb in other parts :)
            ($node/ancestor::tei:front|$node/ancestor::tei:back|$node/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type eq 'work_part')])[last()]
        else () (: TODO: this makes "ordinary" pb appear outside of any structural hierarchy - is this correct? :)
    else $node/ancestor::*[index:isIndexNode(.)][1]
};


(: Marginal citetrails: "nX" where X is the anchor used (if it is alphanumeric) and "nXY" where Y is the number of times that X occurs inside the current div
    (important: nodes are citetrail children of div (not of p) and are counted as such) :)
declare function index:makeMarginalCitetrail($node as element()) as xs:string {
    let $currentSection := sutil:copy(index:getCitableParent($node))
    let $currentNode := $currentSection//*[@xml:id eq $node/@xml:id]
    let $label :=
        if (matches($currentNode/@n, '^[A-Za-z0-9\[\]]+$')) then
            if (count($currentSection//*[index:isMarginalNode(.) and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]) gt 1) then
                concat(
                    upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', '')),
                    string(
                        count($currentSection//*[index:isMarginalNode(.) and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]
                              intersect $currentNode/preceding::*[index:isMarginalNode(.) and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))])
                        + 1)
                )
            else upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))
        else string(count($currentNode/preceding::*[index:isMarginalNode(.)] intersect $currentSection//*[index:isMarginalNode(.)]) + 1)
    return 'n' || $label
};


(: BOOLEAN FUNCTIONS for defining different classes of nodes :)

(:
~ Determines which nodes serve for "passagetrail" production.
:)
(: NOTE: the tei:text[@type eq 'completeWork'] node is NOT part of the index itself :)
declare function index:isPassagetrailNode($node as element()) as xs:boolean {
    boolean(
        index:isIndexNode($node) and
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
~ Determines the set of nodes that are generally citable (and indexed).
:)
declare function index:isIndexNode($node as node()) as xs:boolean {
    typeswitch($node)
        case element() return
            (: any element type relevant for nodetrail creation must be included in one of the following functions: :)
            boolean(
                index:isStructuralNode($node) or
                index:isMainNode($node) or
                index:isMarginalNode($node) or
                index:isAnchorNode($node) or
                index:isPageNode($node) or
                index:isListNode($node)
            )
        default return 
            false()
};

(:
~ Determines whether a node is a specific citetrail element, i.e. one that is specially prefixed in citetrails.
:)
declare function index:isNamedCitetrailNode($node as element()) as xs:boolean {
    boolean(
        index:isAnchorNode($node) or
        index:isPageNode($node) or
        index:isMarginalNode($node) or
        (index:isStructuralNode($node) 
            and $node[self::tei:text[@type eq 'work_volume'] or 
                      self::tei:back or 
                      self::tei:front]) or (: TODO: include div here? :)
        (index:isMainNode($node) 
            and $node[self::tei:head or 
                      self::tei:titlePage]) or
        (index:isListNode($node) 
            and $node[self::tei:list[@type = ('dict', 'index')] or
                      self::tei:item[ancestor::tei:list[@type = ('dict')]]])
    )
};

(:
~ Determines whether a node is a 'generic' citetrail element, i.e. one that isn't specially prefixed in citetrails.
~ --> complement of index:isNamedCitetrailNode()
:)
declare function index:isUnnamedCitetrailNode($node as element()) as xs:boolean {
    index:isIndexNode($node) and not(index:isNamedCitetrailNode($node))
};

(:
~ Basically, we can determine several types of elements in a TEI/text tree:
:)

(:
~ Anchor and page nodes occur within main nodes, marginal nodes, or structural nodes, and have no content.
~ (NOTE: should work with on-the-fly copying of sections. )
:)
declare function index:isAnchorNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        $node/self::tei:milestone[@unit ne 'other']
    )
};

(:
~ Page nodes are regular page breaks.
~ (NOTE: should work with on-the-fly copying of sections. )
:)
declare function index:isPageNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        $node/self::tei:pb[not(@sameAs or @corresp)]
    )
};

(:
~ Marginal nodes occur within structural or main nodes.
~ (NOTE: should work with on-the-fly copying of sections. )
:)
(: TODO: if this is changed, we also need to change txt:isMarginalNode() :)
declare function index:isMarginalNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:note[@place eq 'margin'] or
            $node/self::tei:label[@place eq 'margin']
        )
        (:and not($node/ancestor::*[index:isMarginalNode(.)]):) (: that shouldn't be possible :)
    )
};

(:
~ Main nodes are mixed-content elements such as tei:p, which may contain marginal or anchor nodes.
~ Note: all main nodes should be citable in the reading view.
:)
declare function index:isMainNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:p or
            $node/self::tei:signed or
            $node/self::tei:head[not(ancestor::tei:list)] or
            $node/self::tei:titlePage or
            $node/self::tei:lg or
            $node/self::tei:label[@place ne 'margin'] or
            $node/self::tei:argument[not(ancestor::tei:list)] or
            $node/self::tei:table
        ) and 
        not($node/ancestor::*[index:isMainNode(.) or index:isMarginalNode(.) or self::tei:list])
    )
};

(:
~ List nodes are certain nodes within lists (list, item, head) that occur outside of main nodes and marginal nodes.
:)
declare function index:isListNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:list or
            $node/self::tei:item or
            $node/self::tei:head[ancestor::tei:list] or
            $node/self::tei:argument[ancestor::tei:list]
        ) and 
        not($node/ancestor::*[index:isMainNode(.) or index:isMarginalNode(.)])
    )
};


(:
~ Structural nodes are high-level nodes containing any of the other types of nodes (main, marginal, anchor nodes).
:)
declare function index:isStructuralNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:div[@type ne "work_part"] or (: TODO: comment out for div label experiment :)
            $node/self::tei:back or
            $node/self::tei:front or
            $node/self::tei:text[@type eq 'work_volume']
        )
    )
};


(:
~ Basic nodes represent *all* elements at the bottom of the tree, i.e. all mixed-content elements 
    that, in total, comprise all text nodes. To be used for Sphinx snippets, for checking consistency etc.
:)
declare function index:isBasicNode($node as node()) as xs:boolean {
    boolean(
        index:isMainNode($node) or
        index:isMarginalNode($node) or
        (:(index:isListNode($node) and not($node/descendant::*[index:isListNode(.)])):)
        (index:isListNode($node) and (($node/self::tei:list and not($node/descendant::tei:list))
                                       or ($node[(self::tei:item or self::tei:head or self::tei:argument) 
                                                 and not(descendant::tei:list) 
                                                 and following-sibling::tei:item[./tei:list[index:isListNode(.)]]])
                                      )
        (: read as: 'lists that do not contain lists (=lists at the lowest level), or siblings thereof' :)
        (: (this is quite a complicated XPath, but I don't know how to simplify it without breaking things...) :)
        )
    )
};


declare function index:getNodeCategory($node as element()) as xs:string {
    if (index:isMainNode($node)) then 'main'
    else if (index:isMarginalNode($node)) then 'marginal'
    else if (index:isStructuralNode($node)) then 'structural'
    else if (index:isListNode($node)) then 'list'
    else if (index:isPageNode($node)) then 'page'
    else if (index:isAnchorNode($node)) then 'anchor'
    else error()
};


declare function index:makeUrl($targetWorkId as xs:string, $targetNode as node(), $fragmentIds as map()) {
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


(:
~  Creates a teaser string of limited length (defined in $config:chars_summary) from a given node.
~  @param mode: must be one of 'orig', 'edit' (default)
:)
declare function index:makeTeaserString($node as element(), $mode as xs:string?) as xs:string {
    let $thisMode := if ($mode = ('orig', 'edit')) then $mode else 'edit'
    let $string := normalize-space(replace(replace(string-join(txt:dispatch($node, $thisMode)), '\[.*?\]', ''), '\{.*?\}', ''))
    return 
        if (string-length($string) gt $config:chars_summary) then
            concat('&#34;', normalize-space(substring($string, 1, $config:chars_summary)), '…', '&#34;')
        else
            concat('&#34;', $string, '&#34;')
};


declare function index:makeFragmentId($index as xs:integer, $xmlId as xs:string) as xs:string {
    format-number($index, '0000') || '_' || $xmlId
};



(: NODE TYPESWITCH FUNCTIONS :)

(:  MODES: 
~   - 'title': title of a node/section (only for nodes that represent sections)
~   - 'passagetrail': passagetrail ID of a node (only for nodes that represent passagetrail sections)
~   - 'citetrail': citetrail ID of a node (only for nodes that are index:isNamedCitetrailNode() - all other are created at index time)
~   - 'class': i18n class of a node, usually to be used by HTML-/RDF-related functionalities for generating verbose labels when displaying section titles 
:)

(:
~ @param $node : the node to be dispatched
~ @param $mode : the mode for which the function shall generate results
:)
declare function index:dispatch($node as node(), $mode as xs:string) {
    typeswitch($node)
    (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
        case element(tei:pb)            return index:pb($node, $mode)
        case element(tei:head)          return index:head($node, $mode)
        case element(tei:p)             return index:p($node, $mode)
        case element(tei:signed)        return index:signed($node, $mode)
        case element(tei:note)          return index:note($node, $mode)
        case element(tei:div)           return index:div($node, $mode)
        case element(tei:milestone)     return index:milestone($node, $mode)
        
        case element(tei:list)          return index:list($node, $mode)
        case element(tei:item)          return index:item($node, $mode)

        case element(tei:lg)            return index:lg($node, $mode)
        
        case element(tei:table)         return index:table($node, $mode)
        
        case element(tei:label)         return index:label($node, $mode)
        case element(tei:argument)      return index:argument($node, $mode)
        
        case element(tei:titlePage)     return index:titlePage($node, $mode)
        case element(tei:titlePart)     return index:titlePart($node, $mode)
        
        case element(tei:front)         return index:front($node, $mode) 
        case element(tei:body)          return index:body($node, $mode)
        case element(tei:back)          return index:back($node, $mode)
        case element(tei:text)          return index:text($node, $mode)
        
        case element(tei:figDesc)       return ()
        case element(tei:teiHeader)     return ()
        case element(tei:fw)            return ()
        case element()                  return error(QName('index:dispatch', 'Unknown element: ' || local-name($node) || ' (in mode: "' || $mode || '")'))
        case comment()                  return ()
        case processing-instruction()   return ()

        default return ()
};


(: ####++++ Element functions (ordered alphabetically) ++++#### :)


declare function index:argument($node as element(tei:argument), $mode as xs:string) {
    switch($mode)
        case 'class' return 
            'tei-' || local-name($node)
        default return
            ()
};


declare function index:back($node as element(tei:back), $mode as xs:string) {
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
            ()
};


declare function index:body($node as element(tei:body), $mode as xs:string) {
    switch($mode)
        case 'class' return
            'tei-' || local-name($node)
        default return
            ()
};


declare function index:div($node as element(tei:div), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                else if ($node/(tei:head|tei:label)) then
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'edit')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@type)) then
                    string($node/@n)
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                (: if there is a list/head and nothing else works, we may use that :)
                else if ($node/tei:list/(tei:head|tei:label)) then
                    index:makeTeaserString(($node/tei:list/(tei:head|tei:label))[1], 'edit')
                else ()
            )
            
        case 'class' return
            'tei-div-' || $node/@type
        
        case 'citetrail' return
            if (index:isNamedCitetrailNode($node)) then
                (: use abbreviated form of @type (without dot), possibly followed by position :)
                (: TODO: div label experiment (delete the following block if this isn't deemed plausible) :)
                let $abbr := $config:citationLabels($node/@type)?('abbr')
                let $prefix :=
                    if ($abbr) then 
                        lower-case(if (contains($abbr, '.')) then substring-before($config:citationLabels($node/@type)?('abbr'), '.') else $abbr)
                    else 'div' (: divs for which we haven't defined an abbr. :)
                let $position :=
                    if (count($node/parent::*[self::tei:body or index:isIndexNode(.)]/tei:div[$config:citationLabels(@type)?('abbr') eq $config:citationLabels($node/@type)?('abbr')]) gt 1) then
                        string(count($node/preceding-sibling::tei:div[$config:citationLabels(@type)?('abbr') eq $config:citationLabels($node/@type)?('abbr')]) + 1)
                    else ()
                return $prefix || $position
            else error()
        
        case 'passagetrail' return
            if (index:isPassagetrailNode($node)) then
                let $prefix := lower-case($config:citationLabels($node/@type)?('abbr')) (: TODO: upper-casing with first element of passagetrail ? :)
                return 
                    if ($node/@type = ('lecture', 'gloss')) then (: TODO: 'lemma'? :)
                        (: special cases: with these types, we provide a short teaser string instead of a numeric value :)
                        let $teaser := '"' || normalize-space(substring(substring-after(index:div($node, 'title'), '"'),1,15)) || '…"'
                        return $prefix || ' ' || $teaser
                    else
                        let $position := 
                            if ($node/@n[matches(., '^[0-9\[\]]+$')]) then $node/@n (:replace($node/@n, '[\[\]]', '') ? :)
                            else if ($node/ancestor::*[index:isPassagetrailNode(.)]) then
                                (: using the none-copy version here for sparing memory: :)
                                if (count($node/ancestor::*[index:isPassagetrailNode(.)][1]//tei:div[@type eq $node/@type and index:isPassagetrailNode(.)]) gt 1) then 
                                    string(count($node/ancestor::*[index:isPassagetrailNode(.)][1]//tei:div[@type eq $node/@type and index:isPassagetrailNode(.)]
                                                 intersect $node/preceding::tei:div[@type eq $node/@type and index:isPassagetrailNode(.)]) + 1)
                                else ()
                            else if (count($node/parent::*/tei:div[@type eq $node/@type]) gt 1) then 
                                string(count($node/preceding-sibling::tei:div[@type eq $node/@type]) + 1)
                            else ()
                        return
                            $prefix || (if ($position) then ' ' || $position else ())
            else ()
        
        default return
            ()
};


declare function index:front($node as element(tei:front), $mode as xs:string) {
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
            ()
};


(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function index:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            'heading' ||
            (if (count($node/parent::*/tei:head) gt 1) then          
                (: we have several headings on this level of the document ... :)
                string(count($node/preceding-sibling::tei:head) + 1)
             else ())
        
        default return 
            ()
};

declare function index:item($node as element(tei:item), $mode as xs:string) {
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
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'edit')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$'))) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            (: "entryX" where X is the section title (index:item($node, 'title')) in capitals, use only for items in indexes and dictionary :)
            if(index:isNamedCitetrailNode($node)) then
                let $title := upper-case(replace(index:item($node, 'title'), '[^a-zA-Z0-9]', ''))
                let $position :=
                    if ($title) then
                        let $siblings := $node/parent::tei:list/tei:item[upper-case(replace(index:item(., 'title'), '[^a-zA-Z0-9]', '')) eq $title]
                        return
                            if (count($siblings) gt 0) then 
                                string(count($node/preceding-sibling::tei:item intersect $siblings) + 1)
                            else ()
                    else if (count($node/parent::tei:list/tei:item) gt 0) then 
                        string(count($node/preceding-sibling::tei:item) + 1)
                    else ()
                return 'entry' || $title || $position
            else error() 
        
        case 'passagetrail' return
            ()
        
        default return
            ()
};


declare function index:label($node as element(tei:label), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )
          
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            if (index:isNamedCitetrailNode($node)) then
                index:makeMarginalCitetrail($node)
            else error()
            
        default return
            ()
};


declare function index:list($node as element(tei:list), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                else if ($node/(tei:head|tei:label)) then
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'edit')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@type)) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'passagetrail' return
            ()
        
        case 'citetrail' return
            (: dictionaries, indices and summaries get their type prepended to their number :)
            if(index:isNamedCitetrailNode($node)) then
                let $currentSection := sutil:copy($node/(ancestor::tei:div|ancestor::tei:body|ancestor::tei:front|ancestor::tei:back)[last()])
                let $currentNode := $currentSection//tei:list[@xml:id eq $node/@xml:id]
                return
                  concat(
                      $currentNode/@type, 
                      string(
                          count($currentNode/preceding::tei:list[@type eq $currentNode/@type]
                                intersect $currentSection//tei:list[@type eq $currentNode/@type]
                          ) + 1)
                  )
            else error()
            
        default return
            ()
};


declare function index:lg($node as element(tei:lg), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            error()
            
        default return
            ()
};

declare function index:milestone($node as element(tei:milestone), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                (: purely numeric section titles: :)
                (:else if (matches($node/@n, '^[0-9\[\]]+$') and $node/@unit eq 'number') then
                    $node/@n/string():)
                (: use @unit to derive a title: :)
                (:else if (matches($node/@n, '^\[?[0-9]+\]?$') and $node/@unit[. ne 'number']) then
                    $config:citationLabels($node/@unit)?('abbr') || ' ' || $node/@n:)
                (: if milestone has numerical information, just state the number, regardless of @unit and other attributes: :)
                else if (matches($node/@n, '^[0-9\[\]]+$')) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'edit')
                else ()
            )
            
        case 'class' return
            'tei-ms-' || $node/@unit
            
        case 'citetrail' return
            (: "XY" where X is the unit and Y is the anchor or the number of milestones where this occurs :)
            let $currentSection := sutil:copy(index:getCitableParent($node))
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
        
        case 'passagetrail' return
            if (index:isPassagetrailNode($node)) then
                (: TODO: ATM milestone/@unit = ('article', 'section') resolves to the same abbrs as div/@type = ('article', 'section') :)
                (: TODO: if @n is numeric, always resolve to 'num.' ? :)
                let $prefix := lower-case($config:citationLabels($node/@unit)?('abbr'))
                let $num := 
                    if ($node/@n[matches(., '^[0-9\[\]]+$')]) then $node/@n (:replace($node/@n, '[\[\]]', '') ? :)
                    else 
                        let $currentSection := sutil:copy($node/ancestor::*[index:isPassagetrailNode(.) and not(self::tei:p)][1])
                        let $currentNode := $currentSection//tei:milestone[@xml:id eq $node/@xml:id]
                        let $position := count($currentSection//tei:milestone[@unit eq $currentNode/@unit and index:isPassagetrailNode(.)]
                                               intersect $currentNode/preceding::tei:milestone[@unit eq $currentNode/@unit and index:isPassagetrailNode(.)]) + 1
                        return string($position)
                return
                    $prefix || ' ' || $num
            else ()
        
        default return () (: also for snippets-orig, snippets-edit :)
};


declare function index:note($node as element(tei:note), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                let $currentSection := sutil:copy(index:getCitableParent($node))
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
                        return '"' || normalize-space($currentNode/@n) || '"' || $noteNumber
                    else string(count($currentNode/preceding::tei:note intersect $currentSection//tei:note) + 1)
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            index:makeMarginalCitetrail($node)
        
        case 'passagetrail' return
            if (index:isPassagetrailNode($node)) then
                (: passagetrail parents of note are div, not p :)
                let $currentSection := sutil:copy($node/ancestor::*[index:isPassagetrailNode(.) and not(self::tei:p)][1])
                let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]
                let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $label := 
                    if ($node/@n) then '"' || $node/@n || '"' (: TODO: what if there are several notes with the same @n in a div :)
                    else string(count($currentSection//tei:note
                                      intersect $currentNode/preceding::tei:note) + 1)
                return $prefix || ' ' || $label
            else ()
        
        default return
            ()
};


declare function index:p($node as element(tei:p), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citetrail' return
            error()
        
        case 'passagetrail' return
            if (index:isPassagetrailNode($node)) then
                let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $teaser := '"' || normalize-space(substring(substring-after(index:p($node, 'title'), '"'),1,15)) || '…"'(: short teaser :)
                return $prefix || ' ' || $teaser
            else ()
        
        default return
            ()
};


(:declare function index:passthru($nodes as node()*, $mode as xs:string) as item()* {
    for $node in $nodes/node() return index:dispatch($node, $mode)
};:)


declare function index:pb($node as element(tei:pb), $mode as xs:string) {
    switch($mode)
        case 'title' return
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
        
        case 'passagetrail' return
            if (contains($node/@n, 'fol.')) then $node/@n/string()
            else 'p. ' || $node/@n/string()
        
        (: pb nodes are good candidates for tracing the speed/performance of document processing, 
            since they are equally distributed throughout a document :)
        case 'debug' return
            util:log('warn', '[INDEX] Processing tei:pb node ' || $node/@xml:id)
        
        default return ()
};

declare function index:signed($node as element(tei:signed), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            error()
            
        default return
            ()
};


declare function index:table($node as element(tei:table), $mode as xs:string) {
    switch($mode)
        case 'title' return
            if ($node/tei:head) then
                normalize-space(
                    index:makeTeaserString($node/tei:head, 'edit')
                )
            else ()
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            error()
            
        default return
            ()
};


declare function index:text($node as element(tei:text), $mode as xs:string) {
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
            if (index:isPassagetrailNode($node)) then
                'vol. ' || $node/@n
            else ()
        
        default return
            ()
};


declare function index:titlePage($node as element(tei:titlePage), $mode as xs:string) {
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
            if (count($node/ancestor::tei:front//tei:titlePage) gt 1) then
                'titlepage' || string(count($node/preceding-sibling::tei:titlePage) + 1)
            else 'titlepage'
        
        case 'passagetrail' return
            $config:citationLabels(local-name($node))?('abbr')
        
        default return
            ()
};

declare function index:titlePart($node as element(tei:titlePart), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'edit')
            )
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citetrail' return
            (: "titlePage.X" where X is the number of parts where this occurs :)
            concat('titlepage.', string(count($node/preceding-sibling::tei:titlePart) + 1))
        
        default return 
            ()
};

