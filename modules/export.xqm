xquery version "3.1";

(:~
 : Salamanca Export XQuery-Module
 : This module contains functions for producing export formats such as pure TEI, TEI Simple, PDF, or ePub (to be implemented).
 :
 : For doc annotation format, see
 : - https://exist-db.org/exist/apps/doc/xqdoc
 :
 : For testing, see
 : - https://exist-db.org/exist/apps/doc/xqsuite
 : - https://en.wikibooks.org/wiki/XQuery/XUnit_Annotations
 :
 : @author David Glück
 : @author Cindy Rico Carmona
 : @author Andreas Wagner
 : @version 1.0
 :
 ~:)
 
module namespace export = "https://www.salamanca.school/xquery/export";

declare namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal     = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";
declare namespace xi      = "http://www.w3.org/2001/XInclude";
declare namespace util    = "http://exist-db.org/xquery/util";

import module namespace console   = "http://exist-db.org/xquery/console";
(:import module namespace functx    = "http://www.functx.com";:)
import module namespace config    = "https://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace sutil     = "https://www.salamanca.school/xquery/sutil"  at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";


(:~
Fetches the teiHeader of a work's dataset.
@param mode: 'metadata' for reduced teiHeader without text-related information such as charDecl and revisionDesc
~:)
declare function export:WRKgetTeiHeader($wid as xs:string?, $mode as xs:string?, $citeID as xs:string?) as element(tei:teiHeader) {
    let $expanded := 
        if (doc-available($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')) then 
            util:expand(doc($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')/tei:TEI/tei:teiHeader)
        else ()
    let $header :=  
        if ($mode = ('metadata', 'passage')) then 
            let $processedHeader := local:processHeaderNode($wid, $expanded, $mode, $citeID)
            return 
                element {QName('http://www.tei-c.org/ns/1.0', 'teiHeader')} {
                    (:($nodes, $encodingDesc):)
                    $processedHeader/*
                }
        else $expanded
    return $header
};

(:
~ Recursive teiHeader processing function for fine-grained filtering of header information depending on $mode.
:)
declare function local:processHeaderNode($wid as xs:string, $node as node(), $mode as xs:string?, $citeID as xs:string?) {
    switch($mode)
        case 'metadata' return
            typeswitch($node)
                case element(tei:revisionDesc) return ()
                (:case element(tei:encodingDesc) return ():)
                case element(tei:charDecl) return ()
                case element() return
                    local:copyHeaderElement($wid, $node, $mode, $citeID)
                case attribute() return () 
                case comment() return ()
                case text() return $node
                default return () 
        case 'passage' return
            typeswitch($node)
                case element(tei:idno) return
                    if (count($node/text()[matches(., $wid)]) eq 1) then 
                        (: add specific citeID to work id :)
                        element {QName('http://www.tei-c.org/ns/1.0', local-name($node))} {
                            $node/@*,
                            replace($node/text()[matches(., $wid)], $wid, $wid || ':' || $citeID)   
                        }
                    else 
                        local:copyHeaderElement($wid, $node, $mode, $citeID)
                case element(tei:title) return
                    if ($node/ancestor::tei:titleStmt) then
                        let $passageTitle := 
                            doc($config:index-root || '/' || $wid || '_nodeIndex.xml')//sal:node[@citeID eq $citeID]/@title/string()
                        return
                            element {QName('http://www.tei-c.org/ns/1.0', local-name($node))} {
                                $node/@*,
                                $node/text() || (if ($passageTitle) then ', ' || $passageTitle else ())
                            }
                    else 
                        local:copyHeaderElement($wid, $node, $mode, $citeID)
                case element(tei:notesStmt) return ()
                case element() return
                    local:copyHeaderElement($wid, $node, $mode, $citeID)
                (: omittable node types :)
                case comment() return ()
                case attribute() return ()
                case text() return $node
                default return ()        
        default return 
            $node
};

declare function local:passthruHeaderNode($wid as xs:string, $node as node(), $mode as xs:string?, $citeID as xs:string?) as node()* {
    for $child in $node/node() return local:processHeaderNode($wid, $child, $mode, $citeID)
};

(: Namespaces are removed here :)
declare function local:copyHeaderElement($wid as xs:string, $node as node(), $mode as xs:string?, $citeID as xs:string?) {
    element {QName('http://www.tei-c.org/ns/1.0', local-name($node))} {
        $node/@*,
        local:passthruHeaderNode($wid, $node, $mode, $citeID)
    }
};

(:
~ For a given citeID, returns the respective TEI node (hierarchically embedded) and a teiHeader.
:)
declare function export:WRKgetTeiPassage($wid as xs:string, $citeID as xs:string) as element(tei:TEI)? {
    let $workPath := $config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml'
    let $indexPath := $config:index-root || '/' || sutil:normalizeId($wid) || '_nodeIndex.xml'
    let $tei := 
        if (doc-available($workPath) and doc-available($indexPath)) 
            then util:expand(doc($workPath)/tei:TEI)
        else ()
    return
        if ($tei) then
            let $id := doc($indexPath)//sal:node[@citeID eq $citeID]/@n/string()
            let $node := $tei//*[@xml:id eq $id]
            let $wrappedNode := local:wrapInAncestorNode($node, $node)
            let $teiHeader := export:WRKgetTeiHeader($wid, 'passage', $citeID)
            return
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'TEI')} {
                    $node/ancestor::tei:TEI/(@* except @xml:id),
                    attribute xml:id {$wid || '_' || $citeID},
                    ($teiHeader,
                     $wrappedNode)
                }
        else ()
};

(:
~ Recursively wraps a tei node in its (non-technical) ancestor nodes.
@param $node : the in-tree node, required for navigating the tree towards the top.
@param $wrappedNode : a copy of the original node or its wrapping, which will eventually be returned.
:)
declare function local:wrapInAncestorNode($node as element(), $wrappedNode as element()) as element() {
    if ($node/parent::*[not(self::tei:TEI or self::tei:text[@type eq 'work_part'])]) then
        (:let $debug := util:log('info', '[EXPORT] number of ancestor nodes in local:wrapInAncestorNode(): ' 
                               || count($node/ancestor::*[not(self::tei:TEI or self::tei:text[@type eq 'work_part'])])):)
        let $parent := $node/parent::*
        let $wrap := 
            element {fn:QName('http://www.tei-c.org/ns/1.0', local-name($parent))} {
                $parent/@*, 
                $wrappedNode}
        return local:wrapInAncestorNode($parent, $wrap)
    else $wrappedNode
};
