xquery version "3.1";

(: ####++++----  

    Functions for extracting node indices (sal:index) from TEI works; also includes functionality for making 
    citeIDs, labels, and crumbtrails.
   
January 2023: All the crumbtrails parts are commented, because we created a separate files (crumb.xqm). 
   
   ----++++#### :)

module namespace index    = "https://www.salamanca.school/factory/works/index";

declare namespace tei     = "http://www.tei-c.org/ns/1.0";
declare namespace sal     = "http://salamanca.adwmainz.de";
declare namespace admin   = "https://www.salamanca.school/xquery/admin";

declare namespace map     = "http://www.w3.org/2005/xpath-functions/map";
declare namespace xi      = "http://www.w3.org/2001/XInclude";

import module namespace functx  = "http://www.functx.com";

import module namespace config = "https://www.salamanca.school/xquery/config"      at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace sutil  = "https://www.salamanca.school/xquery/sutil"       at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";
import module namespace txt    = "https://www.salamanca.school/factory/works/txt"  at "xmldb:exist:///db/apps/salamanca/modules/factory/works/txt.xqm";

(: SETTINGS :)

(: Note: The following eXist-db specific options have been removed for portability:
   - exist:timeout
   - exist:output-size-limit
   These settings should be configured at the XQuery processor level instead.
:)

declare variable $index:citeIDConnector := '.';
declare variable $index:labelConnector := ' ';
(: declare variable $index:crumbtrailConnector := ' » '; :)


(: NODE INDEX functions :)


(:
~ Controller function for creating (and reporting about) node indexes.
~ Here's what it does:
~ - It determines at which depth to segment a work
~ - It resolves all XIncludes
~ - It calls index:getFragmentNodes() in order to build the set of nodes constituting html fragments (the "target-set")
~ - It collects all nodes that we should be keeping track of (defined in index:isIndexNode())
~ - For all these nodes, it registers in which fragment they end up
~   (the nearest ((ancestor-or-self or descendant that has no preceding siblings) that's also contained in the target-set))
:)
declare function index:makeNodeIndex($tei as element(tei:TEI)) as map(*) {
    let $wid := $tei/@xml:id
    let $fragmentationDepth := index:determineFragmentationDepth($tei)
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Indexing " || $wid || " at fragmentation level " || $fragmentationDepth, "[INDEX]") else ()

    let $xincludes := $tei//tei:text//xi:include/@href
    let $pages := $tei//tei:pb
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Indexing " || $wid || " (" || count($pages) || " p.) at fragmentation level " || $fragmentationDepth, "[INDEX]") else ()

    let $target-set := index:getFragmentNodes($tei, $fragmentationDepth)
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Target set contains " || count($target-set) || " nodes (to become html fragments)", "[INDEX]") else ()

    (: First, get all relevant nodes :)
    let $nodes := 
        for $text in $tei//tei:text[@type = ('work_volume', 'work_monograph', 'lemma_article')] return 
            (: make sure that we only grasp nodes that are within a published volume :)
            if (($text/@type eq 'work_volume' and sutil:WRKisPublished($wid || '_' || $text/@xml:id))
                or $text/@type eq 'work_monograph' or $text/@type eq 'lemma_article') then 
                $text/descendant-or-self::*[index:isIndexNode(.)]
            else ()

    (: Create the fragment id for each node beforehand, so that recursive crumbtrail creation has it readily available :)
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Node indexing: Found " || count($nodes) || " nodes to process", "[INDEX]") else ()
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Node indexing: Identifying fragment ids", "[INDEX]") else ()
    let $fragmentIds :=
        map:merge(
            for $node at $pos in $nodes
                let $debug :=   if (($config:debug = "trace") and ($pos mod 1000 eq 0)) then
                                    trace("[INDEX] Node indexing: processing node no. " || string($pos), "[INDEX]")
                                else ()
                let $n := $node/@xml:id/string()
                let $frag := (($node/ancestor-or-self::* | $node//tei:*[not(preceding-sibling::*)]) intersect $target-set)[1]
                let $err  := if ((count($frag/@xml:id) eq 0) or ($frag/@xml:id eq "")) then
                    let $debug := if ($config:debug = ("trace", "info")) then
                                     trace("[INDEX] Node indexing: Could not find $frag for $node '" || $n || "'. Target set was: [" || string-join(fn:for-each($target-set, function ($k) {concat($k/local-name(), ':', $k/@xml:id)}), ', ') || "]. Aborting.", "[INDEX]")
                                 else ()
                    return error(QName('http://salamanca.school/err', 'FragmentationProblem'),
                                 'Could not find $frag for ' || $n || '.')
                else ()
                let $fragId := index:makeFragmentId(functx:index-of-node($target-set, $frag), $frag/@xml:id)
                return map:entry($n, $fragId)
        )
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Node indexing: Extracted " || count($fragmentIds) || " fragment ids", "[INDEX]") else ()
    let $debug := if ($config:debug = ("trace", "info")) then trace("[INDEX] Node indexing: Creating index file", "[INDEX]") else ()

    (: node indexing has 2 stages: :)
    (: 1.) extract nested sal:nodes with rudimentary information :)
    let $indexTree := 
        <sal:index>
            {index:extractNodeStructure($wid, $tei//tei:text[(@type eq 'work_volume' and sutil:WRKisPublished($wid || '_' || @xml:id))
                                                            or @type eq 'work_monograph'
                                                            or @type eq 'lemma_article'], $xincludes, $fragmentIds)}
        </sal:index>

    (: 2.) flatten the index from 1.) and enrich sal:nodes with full-blown citeID, etc. :)
    let $debug := if ($config:debug = ("trace")) then trace("[INDEX] Node indexing: stage 1 finished with " || count($indexTree//*) || " elements in $indexTree", "[INDEX]") else ()
    let $index := 
        <sal:index work="{$wid}" xml:space="preserve">
            {index:createIndexNodes($wid, $indexTree)}
        </sal:index>
    let $debug := if ($config:debug = ("trace")) then trace("[INDEX] Node indexing: stage 2 finished with " || count($index//*) || " elements in $index , cont'ing with quality check", "[INDEX]") else ()
        
    let $check := index:qualityCheck($index, $tei, $target-set, $fragmentationDepth)
        
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
~ We are setting it as Processing Instructions in the TEI files: <?svsal htmlFragmentationDepth="4"?>
:)
declare function index:determineFragmentationDepth($work as element(tei:TEI)) as xs:integer {
    let $fd := if ($work//processing-instruction('svsal')[matches(., 'htmlFragmentationDepth="\d{1,2}"')]) then
                   xs:integer($work//processing-instruction('svsal')[matches(., 'htmlFragmentationDepth="\d{1,2}"')][1]/replace(., 'htmlFragmentationDepth="(\d{1,2})"', '$1'))
               else $config:fragmentationDepthDefault
    return $fd
};


(: 
~ A rule picking those elements that should become the fragments for HTML-rendering a work.
~ Requires an expanded(!) TEI work's dataset.
~ Here's what it does:
~ - It finds all tei nodes that have n ancestors up to the root node,
~   where n is a configurable value that is extracted (via index:determineFragmentationDepth) from the TEI file itself.
~ - Then, if a node is member of our set of "structural nodes" (div, front etc., defined in index:isStructuralNode),
~   it goes into the target set; otherwise is nearest ancestor that is a "structural node" does.
~ - Finally, we return the distinct nodes, i.e. no duplicates
~   (two non-structural nodes of the desired level may have the same ancestor)
~ - (Obsolete: In front and back, fragmentation must not go below the child level, since we don't expect child fragments be too large here.)
:)
declare function index:getFragmentNodesOld($work as element(tei:TEI), $fragmentationDepth as xs:integer) as node()* {
    functx:distinct-nodes(
        for $text in $work//tei:text[@type eq 'work_monograph' 
                                      or (@type eq 'work_volume' and sutil:WRKisPublished($work/@xml:id || '_' || @xml:id))] return 
(:
            (
                (if ($text/tei:front//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]) then
                    $text/tei:front/*
                 else
                    $text/tei:front
                ),
:)
                (if ($text//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]) then
                    for $node in $text//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth] return
                        (if ($node[index:isStructuralNode(.)]) then
                            $node
                        else
                            $node/ancestor::tei:*[index:isStructuralNode(.)][1])
                 else
                    $text/tei:text
                )
(:
                (if ($text/tei:back//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]) then
                    $text/tei:back/*
                 else
                    $text/tei:back
                )
            )
:)
    )
};


declare function index:getFragmentNodes($work as element(tei:TEI), $fragmentationDepth as xs:integer) as node()* {
    (: we collect all suitable nodes (divs, front, back, text) that are not too high in the hierarchy :)
    if ($work/tei:text/@type eq 'lemma_article' ) then
        $work/tei:text
    else
        $work//tei:text//tei:*[index:isPotentialFragmentNode(.)][index:isBestDepth(., $fragmentationDepth)]  
};


(:
~ Creates a tree of index nodes (sal:node), where nodes are hierarchically nested
~   according to the hierarchy of nodes in the original TEI tree.
~ Supplies nodes with basic information (sal:title, sal:passage, etc.),
~   while temporary elements/attributes provide information that can be used
~   for the production of citeID, crumbtrails etc. in the 
~   final index creation through index:createIndexNodes().
:)
declare function index:extractNodeStructure($wid as xs:string,
                                            $input as node()*,
                                            $xincludes as attribute()*,
                                            $fragmentIds as map(*)?) as element(sal:node)* {
    for $node in $input return
        typeswitch($node)
            case element() return
                let $children := $node/*
                let $dbg := if ($node/self::tei:pb and count($node/preceding::tei:pb) mod 250 eq 0 and $config:debug = ("info", "trace")) then
                                  trace('[INDEX] Processing tei:pb ' || $node/@n, "[INDEX]")
                            else ()
                let $dbg := if (contains($node/@xml:id, 'W0116-00-0526-pa')) then trace('[INDEX] DEBUG: processing (1) node ' || string($node/@xml:id), "[INDEX]") else ()
                let $returnvalue :=
                    if ($node/@xml:id and $fragmentIds($node/@xml:id/string())) then
                        let $subtype := 
                            if ($node[self::tei:milestone]/@n) then (: TODO: where is this used? :)
                                string($node/@n)
                            else if ($node/@type) then
                                string($node/@type)
                            else ()
                        let $title  := index:dispatch($node, 'title')
                        let $class  := index:dispatch($node, 'class')
                        (:  The link created below serves to build the crumbtrail for the search engine.
                            Ideally, we woult want them to be PID-style links, but the citeID is being created only
                            in the next phase.
                        :)
                        let $link   := index:makeLink($wid, $node, $title, $class, $fragmentIds)
                        let $parent := index:getCitableParent($node)
                        return
                            element sal:node {
                                attribute wid               {$wid},
                                attribute type              {local-name($node)}, 
                                attribute subtype           {$subtype}, 
                                attribute xml:id            {$node/@xml:id/string()},
                                if ($node/id('completeWork') and $xincludes) then
                                    attribute xinc          {$xincludes}
                                else (), 
                                attribute class             {$class},
                                attribute isNamedCit        {index:isNamedCiteIDNode($node)},
                                    element sal:title           {$title},
                                    element sal:fragment        {$fragmentIds($node/@xml:id/string())},
                                    element sal:citableParent   {$parent/@xml:id/string()},
                                    element sal:link            {$link},
                                    if (index:isLabelNode($node)) then
                                        element sal:passage     {index:dispatch($node, 'label')}
                                    else (),
                                    (: if the node is a named citeID node, we include its citeID part here already 
                                       - unnamed citeID can be done much faster in phase 2 :)
                                    if (index:isNamedCiteIDNode($node)) then 
                                        element sal:cit         {index:dispatch($node, 'citeID')} 
                                    else (),
                                    element sal:children        {index:extractNodeStructure($wid, $node/node(), $xincludes, $fragmentIds)}
                            }
                    else
                        (: let $dbg := if ($node/@xml:id and not(contains($node/@xml:id, '-lb-')) and not(contains($node/@xml:id, '-ce-'))) then
                                        trace('[INDEX] Skipping node with xml:id "' || $node/@xml:id/string() || '" but not present as a key in $fragmentIds map.  Continuing with children', "[INDEX]")
                                    else
                                        ()
                        return :) index:extractNodeStructure($wid, $children, $xincludes, $fragmentIds)
                let $dbg := if (contains($node/@xml:id, 'W0116-00-0526-pa')) then trace('[INDEX] DEBUG: processed (1) node ' || string($node/@xml:id) || ', result: ' || serialize($returnvalue), "[INDEX]") else ()
                return $returnvalue
            default return ()
};

(:
~ Creates a flat structure of index nodes (sal:node) from a hierarchically structured preliminary index (see index:extractNodeStructure()),
~ while enriching those nodes with final citeID, crumbtrail, etc.
:)
declare function index:createIndexNodes($wid as xs:string, $input as element(sal:index)) as element(sal:node)* {
    let $numberOfNodes := count($input//sal:node)
    return
    for $node at $pos in $input//sal:node return
        let $debug := if ($pos mod 500 eq 0 and $config:debug = ("info", "trace")) then trace('[INDEX] Processing sal:node ' || $pos || ' of ' || $numberOfNodes, "[INDEX]") else ()

        let $citeID     := index:constructCiteID($node)
        let $label      := index:constructLabel($node)
        (: 
            Ideally, we woult want the crumbtrail to consist of PID-style links, but the citeID is being created only
            in this phase. And we want to utilize the link hierarchy created in the previous phase.
            Maybe we should do the crumtrail creation in the sphinx export after all? But there we don't have the hierarchy either...
        :)
        let $crumbtrail := encode-for-uri(string-join(for $link in $node/ancestor-or-self::sal:node/sal:link/* return serialize($link), ' ⨠ '))
        let $returnvalue := element sal:node {
                    attribute n             {$node/@xml:id/string()},
                    (: copy some attributes from the previous node :)
                    $node/@* except ($node/@category, $node/@isBasicNode, $node/@isNamedCit, $node/@isPassage, $node/@xml:id),
                    attribute title         {$node/sal:title/string()},
                    attribute fragment      {$node/sal:fragment/string()},
                    attribute citableParent {$node/sal:citableParent/string()},
                    attribute citeID        {$citeID},
                    attribute crumbtrail    {$crumbtrail},
                    attribute label         {$label}
                }
        let $dbg := if (contains($node/@xml:id, 'W0116-00-0526-pa')) then trace('[INDEX] DEBUG: processed (2) node ' || string($node/@xml:id) || ', result: ' || serialize($returnvalue), "[INDEX]") else ()
        return $returnvalue
};

(: Conducts some basic quality checks with regards to consistency, uniqueness of citeID, etc. within an sal:index :)
declare function index:qualityCheck($index as element(sal:index), 
                                    $work as element(tei:TEI), 
                                    $targetNodes as element()*, 
                                    $fragmentationDepth as xs:integer) {
                                    
    let $wid := $work/@xml:id
    let $resultNodes := $index//sal:node[not(@n eq 'completeWork')]
    let $numberOfResultNodes := count($resultNodes)
    let $debug := if ($config:debug = ("info", "trace")) then trace('[INDEX] QC: check ' || $numberOfResultNodes || ' nodes in index for ' || $wid, "[INDEX]") else ()
    
    (: #### Basic quality / consistency check #### :)
    let $testNodes := 
        if ($numberOfResultNodes eq 0) then 
            error(xs:QName('admin:createNodeIndex'), 'Node indexing did not produce any results.') 
        else $resultNodes

    (: every ordinary sal:node should have all of the required fields and values: :)
    let $debug := if ($config:debug = "trace") then trace('[INDEX] QC: check @class/@type/@n attributes', "[INDEX]") else ()
    let $testAttributes := 
        if ($testNodes[not(@class/string() and @type/string() and @n/string())]) then 
            error(xs:QName('admin:createNodeIndex'), 'Essential attributes are missing in at least one index node (in ' || $wid || ')') 
        else ()
    let $debug := if ($config:debug = "trace") then trace('[INDEX] QC: check @title/@fragment/@citableParent/@label attributes and sal:crumbtrail children', "[INDEX]") else ()
    let $testChildren := if ($testNodes[not(@title and @fragment and @citableParent and @citeID and @label (:and sal:crumbtrail/* :))]) then error() else ()

    let $debug := if ($config:debug = "trace") then trace('[INDEX] QC: check empty @citeID attributes', "[INDEX]") else ()
    let $testEmptyCiteID :=
        if (count($resultNodes/@citeID[not(./string())]) gt 0) then
            error(xs:QName('admin:createNodeIndex'), 
                  'Could not produce a citeID for one or more sal:node (in' || $wid || '). Problematic nodes: '
                  || string-join((for $x in $resultNodes[not(@citeID/string())] return $x/@n/string() || '(' || $x/@type/string() || ')'), '; '))
        else ()

    (: there should be as many distinctive citeID and crumbtrails as there are ordinary sal:node elements: :)
    let $debug := if ($config:debug = "trace") then trace('[INDEX] QC: make sure @citeIDs are unique', "[INDEX]") else ()
    let $testAmbiguousCiteID :=
        let $uniqueCiteIDs := for $node at $pos in $resultNodes
                                let $id := $node/@citeID/string()
 group by $id
            let $debug := if (($config:debug = "trace") and ($pos[1]                        mod 1000 eq 0)) then
 trace('[INDEX] QC: ... counting citeIDs ' ||
                         '(' || string($pos[1]) || '/' || string($numberOfResultNodes) || ')', "[INDEX]")
                                       else ()
 return $id[1]
 let $numberOfUniqueCiteIDs := count($uniqueCiteIDs)
 return if ($numberOfResultNodes ne                                       $numberOfUniqueCiteIDs)                        then 
                    let                $debug1            := trace('[INDEX]: ERROR: Could not produce a unique citeID for each sal:node (in ' || $wid || '). ' ||
                  $numberOfResultNodes || ' result nodes vs ' || $numberOfUniqueCiteIDs                  || ' unique cite ids.', "[INDEX]")
                        let $problematicNodes := for $id in $uniqueCiteIDs
                                        let $nodes := $resultNodes[@citeID/string() = $id]
                         where count($nodes) gt 1
 return $id || ': '                                       || string-join($nodes/@n/string(), ', ')
 let $debug2 := trace('[INDEX]: ERROR: Problematic nodes: ' || string-join($problematicNodes, '; '), "[INDEX]")
(:
                  || string-join(
                        (for $x in $resultNodes[@citeID = preceding::sal:node/@citeID]
                         return concat($x/@n || ' (citeID ' || $x/@citeID || ') <-> ',
                                       string-join(for $y in $resultNodes[following::sal:node/@citeID = $x/@citeID] return concat($y/@n, ' (citeID ', $y/@citeID, ')'), ' ~ ')
                                       )
                        ), ' || '
                    )
                )
:)
 return error(xs:QName('admin:createNodeIndex'), 
                                       'Could not produce a unique citeID for each sal:node (in '                        || $wid || '). ' ||
                    $numberOfResultNodes || ' result nodes vs ' || $numberOfUniqueCiteIDs || ' unique cite ids.' ||
                ' Problematic nodes: ' || string-join($problematicNodes, '; '))
(:
                  || string-join(
                        (for $x in $resultNodes[@citeID = preceding::sal:node/@citeID]
                         return concat($x/@n || ' (citeID ' || $x/@citeID || ') <-> ',
                                       string-join(for $y in $resultNodes[following::sal:node/@citeID = $x/@citeID] return concat($y/@n, ' (citeID ', $y/@citeID, ')'), ' ~ ')
                                       )
                        ), ' || '
                    )
                )
:)
        else ()
    (: search for " //@citeID[not(./string())] ":)
    (: not checking crumbtrails here ATM for not slowing down index creation too much... :)
    
    (: check whether all text is being captured through basic index nodes (that is, whether every single passage is citable) :)
    let $debug := if ($config:debug = "trace") then trace('[INDEX] QC: check whether every single passage is citable', "[INDEX]") else ()
    let $checkBasicNodes := 
        let $textNodes := $work//tei:text[@type eq 'work_monograph' 
                                  or (@type eq 'work_volume' and sutil:WRKisPublished($wid || '_' || @xml:id))]
                                  //text()[normalize-space() ne '']
 let $numberOfTextNodes := count($textNodes)
        for $t at $i in $textNodes return
            let $debug := if (($config:debug = "trace") and ($i mod 2500 eq 0)) then
                              trace('[INDEX] QC: ... checking text nodes ' ||
                              '(' || xs:string($i) || '/' || xs:string($numberOfTextNodes) || ')', "[INDEX]")
                          else ()
            return
                if ($t[not(ancestor::*[index:isBasicNode(.)]) and not(ancestor::tei:figDesc)]) then 
                let $debug := trace('Encountered text node without ancestor::*[index:isBasicNode(.)], in line ' || $t/preceding::tei:lb[1]/@xml:id/string() || ' – this might indicate a structural anomaly in the TEI data.', "[INDEX-ERROR]")
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
    
    let $debug := if ($config:debug = ("info", "trace")) then trace('[INDEX] QC: all checks passed for ' || $wid, "[INDEX]") else ()

        return
        (: return information that we want to inform about rather than throw hard errors :)
        map {
            'missed_elements': $missed-elements,
            'unidentified_elements': $unidentified-elements
        }
};


(: LABELS, CiteID, CRUMBTRAILS (-- deep recursion) :)

declare function index:constructCiteID($node as element(sal:node)) as xs:string {
    let $prefix := 
        if ($node/sal:citableParent/text()) then
            index:constructCiteID($node/root()/id($node/sal:citableParent/text()) intersect $node/ancestor::sal:node)
        else ()
    let $this := 
        if ($node/sal:cit) then
            $node/sal:cit/text()
        else (: if sal:cit doesn't already exist, we are dealing with a numeric/unnamed citeID node and create the citeID part here: :)
            string(count($node/preceding-sibling::sal:node[@isNamedCit eq 'false']) + 1)
    return
        if ($prefix and $this) then $prefix || $index:citeIDConnector || $this else $this
};

(:declare function index:constructCrumbtrail($wid as xs:string, $citeID as xs:string, $node as element(sal:node)) as item()+ {
    let $prefix := 
        if ($node/sal:citableParent/text() and $node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()]) then
            index:constructCrumbtrail($wid, index:constructCiteID($node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()]), $node/ancestor::sal:node[@xml:id eq $node/sal:citableParent/text()])
        else ()
    let $this := if ($citeID) then <a href="{$config:idserver || '/texts/' || $wid || ':' || $citeID}">{$node/sal:title/text()}</a> else $node/sal:crumb/*
    return
        if ($prefix and $this) then ($prefix, $index:crumbtrailConnector, $this) else $this
}; :)

declare function index:constructLabel($node as element(sal:node)) as xs:string? {
    let $prefix :=
        (: find citable parent node :)
        let $citableParent := if ($node/sal:citableParent/text()) then
                                    $node/root()/id($node/sal:citableParent/text()) intersect $node/ancestor::sal:node
                                else ()
        return  if ($citableParent) then
                    index:constructLabel($citableParent)
                else ()
    (: not every sal:node has a distinctive passage: :)
    let $this := if ($node/sal:passage/text()) then $node/sal:passage/text() else ''
    return
        if ($prefix and $this) then 
            $prefix || $index:labelConnector || $this 
        else $prefix || $this (: this will only return one of both, if any at all :)
};

declare function index:makeLink($wid as xs:string, $node as node(), $title as xs:string*, $class as xs:string*, $fragmentIds as map(*)) as element(a)? {
    let $t := if (string-length($title) gt 0) then $title else " · "
    return
        if ($class) then
            <a class="{$class}" href="{index:makeUrl($wid, $node, $fragmentIds)}">{$t}</a>
        else 
            <a                  href="{index:makeUrl($wid, $node, $fragmentIds)}">{$t}</a>
};

(: Gets the citable crumbtrail/citeID (not label!) parent :)
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

(: Marginal citeID: "nX" where X is the anchor used (if it is alphanumeric) and "nXY" where Y is the number of times that X occurs inside the current div
    (important: nodes are citeID children of div (not of p) and are counted as such) :)
declare function index:makeMarginalCiteID($node as element()) as xs:string {
    let $currentSection := sutil:copy(index:getCitableParent($node))
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $currentNode := $currentSection//*[@xml:id eq $node/@xml:id]:)

(:TO DO: distinguish between note with or without n, otherwise pb with indexing. DONE 20.05.2025:)
    let $currentNode := $currentSection/id($node/@xml:id)
    let $label :=
        if ($currentNode/self::tei:note) then
        
          if (matches($currentNode/@n, '^[A-Za-z0-9\[\]]+$')) then
            if (count($currentSection//tei:note[index:isMarginalNode(.) and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]) gt 1) then
                concat(
                    upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', '')),
                    concat('n_n', string(
                        count($currentSection//tei:note[index:isMarginalNode(.) and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))]
                              intersect $currentNode/preceding::tei:note[index:isMarginalNode(.) and upper-case(replace(@n, '[^a-zA-Z0-9]', '')) eq upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))])
                        + 1))
                )
            else upper-case(replace($currentNode/@n, '[^a-zA-Z0-9]', ''))
        else concat('n_un', string(count($currentNode/preceding::tei:note[not(@n) and index:isMarginalNode(.) ] intersect $currentSection//tei:note[not(@n) and index:isMarginalNode(.)]) + 1))
        
       else if($currentNode/self::tei:ref) then
            concat('ref', string(count($currentNode/preceding::tei:ref[index:isMarginalNode(.)] intersect $currentSection//tei:ref[index:isMarginalNode(.)]) + 1))
            else if ($currentNode/self::tei:label) then
            concat('lab', string(count($currentNode/preceding::tei:label[index:isMarginalNode(.)] intersect $currentSection//tei:label[index:isMarginalNode(.)]) + 1)) 
        else () 
    return  $label
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

declare function index:makeUrl($wid as xs:string, $targetNode as node(), $fragmentIds as map(*)) as xs:string {
    let $targetNodeId := $targetNode/@xml:id/string()
    let $viewerPage   :=      
        if (substring($wid, 1, 2) eq 'W0') then
            'work.html?wid='
        else if (substring($wid, 1, 2) eq 'L0') then
            'lemma.html?lid='
        else if (substring($wid, 1, 2) eq 'A0') then
            'author.html?aid='
        else if (substring($wid, 1, 2) eq 'WP') then
            'workingpaper.html?wpid='
        else
            'index.html?wid='
    let $targetNodeHTMLAnchor :=    
        if (contains($targetNodeId, '-pb-')) then
            concat('pageNo_', $targetNodeId)
        else $targetNodeId
    let $frag := $fragmentIds($targetNodeId)
(: Edit 2023-05-25 Andreas Wagner:
   In the new infrastructure URLs are no longer like "work.html?wid=W0013&amp;frag=ae-fa-fwef-134#Vol01" ...
   This is how it was before:
      return concat($viewerPage, $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeHTMLAnchor)
:)
    return concat($wid, "/html/", $frag, '.html#', $targetNodeHTMLAnchor)
};

(:
~  Creates a teaser string of limited length (defined in $config:chars_summary) from a given node.
~  @param mode: must be one of 'orig', 'edit' (default)
:)
declare function index:makeTeaserString($node as element(), $mode as xs:string?) as xs:string {
    let $thisMode := if ($mode = 'edit') then $mode else 'orig'
    let $string := normalize-space(string-join(txt:dispatch($node, $thisMode), ''))
    return 
        if (string-length($string) gt $config:chars_summary) then
            concat('&#34;', normalize-space(substring($string, 1, $config:chars_summary)), '…', '&#34;')
        else
            concat('&#34;', $string, '&#34;')
};

declare function index:makeFragmentId($index as xs:integer, $xmlId as xs:string) as xs:string {
    format-number($index, '00000') || '_' || $xmlId
};



(: BOOLEAN FUNCTIONS for defining different classes of nodes :)

(: 
!!! IMPORTANT: before changing any of these functions, make sure to have read and understood
    the section on node indexing in the docs/technical.md documentation file.
:)

(:
~ Determines which nodes serve for "label" production.
:)
(: NOTE: the tei:text[@type eq 'completeWork'] node is NOT part of the index itself :)
declare function index:isLabelNode($node as element()) as xs:boolean {
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
~ Determines whether a node is a specific citeID element, i.e. one that is specially prefixed in citeID.
:)
declare function index:isNamedCiteIDNode($node as element()) as xs:boolean {
    boolean(
        index:isAnchorNode($node) or
        index:isPageNode($node) or
        index:isMarginalNode($node) or
        (index:isStructuralNode($node) 
            and $node[self::tei:text[@type eq 'work_volume'] or 
                      self::tei:back or 
                      self::tei:front or
                      self::tei:argument]) or (: TODO: include div here? :)
        (index:isMainNode($node) 
            and $node[self::tei:head or 
                      self::tei:titlePage]) or
        (index:isListNode($node) 
            and $node[self::tei:list[@type = ('dict', 'index')] or
                      self::tei:item[ancestor::tei:list[@type = ('dict')]]])
    )
};

(:
~ Determines whether a node is a 'generic' citeID element, i.e. one that isn't specially prefixed in citeID.
~ --> complement of index:isNamedCiteIDNode()
:)
declare function index:isUnnamedCiteIDNode($node as element()) as xs:boolean {
    index:isIndexNode($node) and not(index:isNamedCiteIDNode($node))
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
    $node/@xml:id and
    $node/self::tei:pb[not(@sameAs or @corresp)]
};

(:
~ Marginal nodes occur within structural or main nodes.
~ (NOTE: should work with on-the-fly copying of sections. )
:)
(: TODO: if this is changed, we also need to change txt:isMarginalNode() :)
declare function index:isMarginalNode($node as node()) as xs:boolean {
    $node/@xml:id and
    (
        $node/self::tei:note[@place eq 'margin'] or
        $node/self::tei:label[@place eq 'margin'] or
        $node/self::tei:ref or
        $node/self::tei:p[ancestor::tei:note[@place eq 'margin']]
    )
    (:and not($node/ancestor::*[index:isMarginalNode(.)]):) (: that shouldn't be possible :)
};

(:
~ Main nodes are mixed-content elements such as tei:p, which contain text but may also contain marginal or anchor nodes.
~ Note: all main (i.e. directly text-containing) nodes should be citable in the reading view.
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
(: A.W. 2024-05-01: Replace this
            $node/self::tei:argument[not(ancestor::tei:list)] or
   with the following line, in order to enable indexing of p[parent:argument] and p[ancestor:list].
   (when the argument contains a p element, it cannot itself contain text nodes,
    so it's the contained text nodes, but not the argument that should be included in this list of main nodes.)
:)
            $node/self::tei:argument[not(ancestor::tei:list)][not(./tei:p)] or
            $node/self::tei:table
        ) and 
(: A.W. 2024-02-24: change the following, in order to also index <p>s on titlepages, in arguments etc.
        not($node/ancestor::*[index:isMainNode(.) or index:isMarginalNode(.) or self::tei:list])
:)
        not($node/ancestor::*[index:isMarginalNode(.) or self::tei:list])
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
(: A.W. 2024-05-01: Add the following line, in order to enable indexing of p[parent:argument] and p[ancestor:list]:  :)
            $node/self::tei:p[ancestor::tei:list] or
            $node/self::tei:argument[ancestor::tei:list]
        ) and 
        not($node/ancestor::*[index:isMainNode(.) or index:isMarginalNode(.)])
    )
};

(:
~ Structural nodes are high-level nodes containing only other types of nodes (main, marginal, anchor nodes), not immediate text nodes.
Line 584: [not(./(ancestor::tei:front || ancestor::tei:back))] added to resolve a HTML problem (#6459: <front> displayed twice)
TODO: What about list, lg and quote nodes?
:)
declare function index:isStructuralNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:div[@type ne "work_part"] or (: TODO: comment out for div label experiment :)
(: A.W. 2024-05-01: Replace this
            $node/self::tei:argument[not(ancestor::tei:list)] or
   with the following line, in order to enable indexing of p[parent:argument] and p[ancestor:list]:
:)
            $node/self::tei:argument[not(ancestor::tei:list)][./tei:p] or
            $node/self::tei:back or
            $node/self::tei:front or
            $node/self::tei:text[@type eq 'work_volume'] or
            $node/self::tei:note[@place eq 'margin'][./tei:p]
        )
    )
};

declare function index:isPotentialFragmentNode($node as node()) as xs:boolean {
    not($node/ancestor::tei:front |            $node/ancestor::tei:back) and
            boolean($node[  self::tei:front |
 self::tei:back |
            self::tei:div |
                    self::tei:head |
                    self::tei:p |
                    self::tei:list |
                    self::tei:lg |
                    self::tei:quote |
                    self::tei:argument |
                    (: $node/self::tei:argument[not($node/ancestor::tei:list)] | :)
            self::tei:text[@type = ('work_monograph', 'work_volume')]
            ])
};

declare function index:isBestDepth($node as node(), $fragmentationDepth as xs:integer) as xs:boolean {
    (: If the node is at a good depth (less than or equal to the fragmentation depth) and
       does not have a descendant that is at a good depth, too (deeper but still less than or equal than the fragmentation depth),
       then the present node is good to serve as html container :)
    boolean(count($node/ancestor::tei:*) le $fragmentationDepth and
            not($node/descendant::tei:*[index:isPotentialFragmentNode(.)][count(./ancestor::tei:*) le $fragmentationDepth])
           )
};

(:
~ Basic nodes represent *all* container nodes at the bottom of the index tree, i.e. mixed-content elements 
    that comprise all text nodes in a sequential, non-overlapping manner. 
    To be used for Sphinx snippets, for checking consistency etc.
:)
declare function index:isBasicNode($node as node()) as xs:boolean {
    index:isMainNode($node) or
    index:isMarginalNode($node) or
    $node[self::tei:p][parent::tei:argument | ancestor::tei:list] or
    $node[self::tei:item[not(./tei:p)] | self::tei:head | self::tei:argument[not(./tei:p)] ] 
    (: (this is quite a complicated XPath, but I don't know how to simplify it without breaking things...) :)
};



(: NODE TYPESWITCH FUNCTIONS :)

(:  MODES: 
~   - 'title': title of a node/section (only for nodes that represent sections)
~   - 'label': label of a node (only for nodes that represent label sections)
~   - 'citeID': citeID ID of a node (only for nodes that are index:isNamedCiteIDNode() - all other are created at index time)
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
        case element(tei:ref)          return index:ref($node, $mode)
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
        case 'title' return
            normalize-space(
                if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                    '"' || string($node/@n) || '"'
                else if ($node/(tei:head|tei:label)) then
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'orig')
                else
                    $config:citationLabels(local-name($node))?('abbr')
            )
        case 'class' return 
            'tei-' || local-name($node)
        case 'citeID' return
            let $abbr := $config:citationLabels(local-name($node))?('abbr')
            let $prefix :=
                if ($abbr) then 
                    lower-case(if (contains($abbr, '.')) then substring-before($abbr, '.') else $abbr)
                else 'arg'
            let $position :=   (: If we have several siblings that happen to have the same abbreviation, provide a position count :)
                if (count($node/parent::*[index:isIndexNode(.)]/tei:*[$abbr = $config:citationLabels(local-name(.))?('abbr') or (@type and $abbr eq $config:citationLabels(@type)?('abbr'))]) gt 1) then
                          string(count($node/preceding-sibling::tei:*[$abbr = $config:citationLabels(local-name(.))?('abbr') or (@type and $abbr eq $config:citationLabels(@type)?('abbr'))]) + 1)
                else ()
            return $prefix || $position

        case 'label' return
                lower-case($config:citationLabels(local-name($node))?('abbr')) (: TODO: upper-casing with first element of label ? :)
        default return
            ()
};

declare function index:back($node as element(tei:back), $mode as xs:string) {
    switch($mode)
        case 'title' return
            ()
        case 'class' return
            'tei-' || local-name($node)
        case 'citeID' return
            'backmatter'
        case 'label' return
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
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'orig')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@type)) then
                    string($node/@n)
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'orig')
                (: if there is a list/head and nothing else works, we may use that :)
                else if ($node/tei:list/(tei:head|tei:label)) then
                    index:makeTeaserString(($node/tei:list/(tei:head|tei:label))[1], 'orig')
                else ()
            )
            
        case 'class' return
            'tei-div-' || $node/@type
        
        case 'citeID' return
            if (index:isNamedCiteIDNode($node)) then
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
        
        case 'label' return
            if (index:isLabelNode($node)) then
                let $prefix := lower-case($config:citationLabels($node/@type)?('abbr')) (: TODO: upper-casing with first element of label ? :)
                return 
                    if ($node/@type = ('lecture', 'gloss')) then (: TODO: 'lemma'? :)
                        (: special cases: with these types, we provide a short teaser string instead of a numeric value :)
                        let $teaser := '"' || normalize-space(substring(substring-after(index:div($node, 'title'), '"'),1,15)) || '…"'
                        return $prefix || ' ' || $teaser
                    else
                        let $position := 
                            if ($node/@n[matches(., '^[0-9\[\]]+$')]) then $node/@n (:replace($node/@n, '[\[\]]', '') ? :)
                            else if ($node/ancestor::*[index:isLabelNode(.)]) then
                                (: using the none-copy version here for sparing memory: :)
                                if (count($node/ancestor::*[index:isLabelNode(.)][1]//tei:div[@type eq $node/@type and index:isLabelNode(.)]) gt 1) then 
                                    string(count($node/ancestor::*[index:isLabelNode(.)][1]//tei:div[@type eq $node/@type and index:isLabelNode(.)]
                                                 intersect $node/preceding::tei:div[@type eq $node/@type and index:isLabelNode(.)]) + 1)
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
            
        case 'citeID' return
            'frontmatter'
            
        case 'label' return
            $config:citationLabels(local-name($node))?('abbr')
            
        default return
            ()
};

(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function index:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'orig')
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citeID' return
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
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'orig')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$'))) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'orig')
                else ()
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citeID' return
            (: "entryX" where X is the section title (index:item($node, 'title')) in capitals, use only for items in indexes and dictionary :)
            if(index:isNamedCiteIDNode($node)) then
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
        
        case 'label' return
            ()
        
        default return
            ()
};

declare function index:label($node as element(tei:label), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'orig')
            )
          
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citeID' return
            if (index:isNamedCiteIDNode($node)) then
                index:makeMarginalCiteID($node)
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
                    index:makeTeaserString(($node/(tei:head|tei:label))[1], 'orig')
                (: purely numeric section titles: :)
                else if ($node/@n and (matches($node/@n, '^[0-9\[\]]+$')) and ($node/@type)) then
                    $node/@n/string()
                (: otherwise, try to derive a title from potential references to the current node :)
                else if ($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)]) then
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'orig')
                else ()
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'label' return
            ()
        
        case 'citeID' return
            (: dictionaries, indices and summaries get their type prepended to their number :)
            if(index:isNamedCiteIDNode($node)) then
                let $currentSection := sutil:copy($node/(ancestor::tei:div|ancestor::tei:body|ancestor::tei:front|ancestor::tei:back)[last()])
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:              let $currentNode := $currentSection//tei:list[@xml:id eq $node/@xml:id]:)
                let $currentNode := $currentSection/id($node/@xml:id)/self::tei:list
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
                index:makeTeaserString($node, 'orig')
            )
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citeID' return
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
                    index:makeTeaserString($node/ancestor::tei:TEI//tei:ref[@target = concat('#', $node/@xml:id)][1], 'orig')
                else ()
            )
            
        case 'class' return
            'tei-ms-' || $node/@unit
            
        case 'citeID' return
            (: "XY" where X is the unit and Y is the anchor or the number of milestones where this occurs :)
            let $currentSection := sutil:copy(index:getCitableParent($node))
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          let $currentNode := $currentSection//tei:milestone[@xml:id eq $node/@xml:id]:)
            let $currentNode := $currentSection/id($node/@xml:id)/self::tei:milestone
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
        
        case 'label' return
            if (index:isLabelNode($node)) then
                (: TODO: ATM milestone/@unit = ('article', 'section') resolves to the same abbrs as div/@type = ('article', 'section') :)
                (: TODO: if @n is numeric, always resolve to 'num.' ? :)
                let $prefix := lower-case($config:citationLabels($node/@unit)?('abbr'))
                let $num := 
                    if ($node/@n[matches(., '^[0-9\[\]]+$')]) then $node/@n (:replace($node/@n, '[\[\]]', '') ? :)
                    else 
                        let $currentSection := sutil:copy($node/ancestor::*[index:isLabelNode(.) and not(self::tei:p)][1])
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:                      let $currentNode := $currentSection//tei:milestone[@xml:id eq $node/@xml:id]:)
                        let $currentNode := $currentSection/id($node/@xml:id)/self::tei:milestone
                        let $position := count($currentSection//tei:milestone[@unit eq $currentNode/@unit and index:isLabelNode(.)]
                                               intersect $currentNode/preceding::tei:milestone[@unit eq $currentNode/@unit and index:isLabelNode(.)]) + 1
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
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:              let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]:)
                let $currentNode := $currentSection/id($node/@xml:id)/self::tei:note
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
        
        case 'citeID' return
            index:makeMarginalCiteID($node)
        
        case 'label' return
            if (index:isLabelNode($node)) then
                (: label parents of note are div, not p :)
                (: let $debug := console:log("index:note/label for note: " || $node/@xml:id/string()) :)
                let $currentSection := sutil:copy($node/ancestor::*[not(self::tei:p)][index:isLabelNode(.)][1])
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:              let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]:)
                let $currentNode := $currentSection/id($node/@xml:id)/self::tei:note
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

declare function index:ref($node as element(tei:ref), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                let $currentSection := sutil:copy(index:getCitableParent($node))
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:              let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]:)
                let $currentNode := $currentSection/id($node/@xml:id)/self::tei:note
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
        
        case 'citeID' return
            index:makeMarginalCiteID($node)
        
        case 'label' return
            if (index:isLabelNode($node)) then
                (: label parents of note are div, not p :)
                (: let $debug := console:log("index:note/label for note: " || $node/@xml:id/string()) :)
                let $currentSection := sutil:copy($node/ancestor::*[not(self::tei:p)][index:isLabelNode(.)][1])
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:              let $currentNode := $currentSection//tei:note[@xml:id eq $node/@xml:id]:)
                let $currentNode := $currentSection/id($node/@xml:id)/self::tei:note
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
            index:makeTeaserString($node, 'orig')
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citeID' return
            let $result := string(count($node/preceding-sibling::* intersect $node/parent::*/(tei:p|tei:list)) + 1)
            return $result
        
        case 'label' return
            if (index:isLabelNode($node)) then
                if (starts-with($node/ancestor::tei:TEI/@xml:id, 'L')) then
                    let $prefix := $config:citationLabels(local-name($node))?('abbr')
                let $pNumber := count($node/(preceding::tei:p | preceding::tei:list) intersect $node/ancestor::tei:text//*) + 1
                    let $teaser := '"' || normalize-space(substring(substring-after(index:p($node, 'title'), '"'),1,15)) || '…"'(: short teaser :)
                return $prefix || ' ' || $pNumber || ' (' || $teaser || ')'
            else
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
                    else if  (contains($node/@n, 'r')|| contains($node/@n, ']r') ||  ends-with($node/@n, 'v') and $node/@n[string-length(.) >1]  || contains($node/@n, ']v')) then
 'fol. ' || $node/@n
else 
                        'p. ' || $node/@n
            )
        
        case 'class' return
            'tei-' || local-name($node)
        
        case 'citeID' return
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
        
        case 'label' return
            if (contains($node/@n, 'fol.')) then 
                        $node/@n
                    else if  (contains($node/@n, 'r')|| contains($node/@n, ']r') ||  ends-with($node/@n, 'v') and $node/@n[string-length(.) >1]  || contains($node/@n, ']v')) then
 'fol. ' || $node/@n
else 
                        'p. ' || $node/@n
        
        (: pb nodes are good candidates for tracing the speed/performance of document processing, 
            since they are equally distributed throughout a document
            but in order not to spam the log, we log only every 250th pb element :)
        case 'debug' return
                if (count($node/preceding::tei:pb) mod 250 eq 0 and $config:debug = ("info", "trace")) then
                    trace('[INDEX] Processing tei:pb node ' || $node/@xml:id || '(@n=' || $node/@n || ')', "[INDEX]")
                else ()
        
        default return ()
};

declare function index:signed($node as element(tei:signed), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'orig')
            )
        
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citeID' return
            error()
            
        default return
            ()
};

declare function index:table($node as element(tei:table), $mode as xs:string) {
    switch($mode)
        case 'title' return
            if ($node/tei:head) then
                normalize-space(
                    index:makeTeaserString($node/tei:head, 'orig')
                )
            else ()
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citeID' return
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
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:              else if ($node/@xml:id eq 'completeWork') then:)
                else if ($node/id('completeWork')) then
                    '[complete work]'
                else if (matches($node/@xml:id, 'work_part_[a-z]')) then
                    '[process-technical part: ' || substring(string($node/@xml:id), 11, 1) || ']'
                else ()
            )
        
        case 'class' return
            if ($node/@type eq 'work_volume') then 'tei-text-' || $node/@type
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          else if ($node/@xml:id eq 'completeWork') then 'tei-text-' || $node/@xml:id:)
            else if ($node/id('completeWork')) then 'tei-text-' || $node/@xml:id
            else if (matches($node/@xml:id, 'work_part_[a-z]')) then 'elem-text-' || $node/@xml:id
            else 'tei-text'
        
        case 'citeID' return
            (: "volX" where X is the current volume number, don't use it at all for monographs :)
            if ($node/@type eq 'work_volume') then
               concat('vol', count($node/preceding::tei:text[@type eq 'work_volume']) + 1)
            else ()
        
        case 'label' return
            if (index:isLabelNode($node)) then
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
        
        case 'citeID' return
            if (count($node/ancestor::tei:front//tei:titlePage) gt 1) then
                'titlepage' || string(count($node/preceding-sibling::tei:titlePage) + 1)
            else 'titlepage'
        
        case 'label' return
            $config:citationLabels(local-name($node))?('abbr')
        
        default return
            ()
};

declare function index:titlePart($node as element(tei:titlePart), $mode as xs:string) {
    switch($mode)
        case 'title' return
            normalize-space(
                index:makeTeaserString($node, 'orig')
            )
            
        case 'class' return
            'tei-' || local-name($node)
            
        case 'citeID' return
            (: "titlePage.X" where X is the number of parts where this occurs :)
            concat('titlepage.', string(count($node/preceding-sibling::tei:titlePart) + 1))
        
        default return 
            ()
};
