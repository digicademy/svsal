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
 
module namespace export = "http://salamanca/export";

declare namespace exist   = "http://exist.sourceforge.net/NS/exist";
declare namespace output  = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal     = "http://salamanca.adwmainz.de";
declare namespace tei     = "http://www.tei-c.org/ns/1.0";
declare namespace xi      = "http://www.w3.org/2001/XInclude";
declare namespace util       = "http://exist-db.org/xquery/util";
(:import module namespace console    = "http://exist-db.org/xquery/console";:)
(:import module namespace functx     = "http://www.functx.com";:)
import module namespace config    = "http://salamanca/config"               at "config.xqm";
import module namespace sal-util    = "http://salamanca/sal-util" at "sal-util.xql";


(:~
Fetches the teiHeader of a work's dataset.
@param mode: 'metadata' for reduced teiHeader without text-related information such as charDecl and revisionDesc
~:)
declare function export:WRKgetTeiHeader($wid as xs:string?, $mode as xs:string?) as element(tei:teiHeader) {
    let $expanded := 
        if (doc-available($config:tei-works-root || '/' || sal-util:normalizeId($wid) || '.xml')) then 
            util:expand(doc($config:tei-works-root || '/' || sal-util:normalizeId($wid) || '.xml')/tei:TEI/tei:teiHeader)
        else ()
    let $header :=  
        if ($mode eq 'metadata') then 
            let $nodes := $expanded/*[not(self::tei:encodingDesc) and not(self::tei:revisionDesc)]
            let $encodingDesc := 
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'encodingDesc')} { 
                    $expanded/tei:encodingDesc/*[not(self::tei:charDecl)]
                }
            return 
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'teiHeader')} {
                    ($nodes, $encodingDesc)
                }
        else $expanded
    return $header
};

(:
~ For a given citetrail, returns the respective TEI node along with its hierarchy (in the complete work) and a teiHeader.
:)
declare function export:WRKgetTeiPassage($wid as xs:string, $citetrail as xs:string) as element(tei:TEI)? {
    let $workPath := $config:tei-works-root || '/' || sal-util:normalizeId($wid) || '.xml'
    let $indexPath := $config:index-root || '/' || sal-util:normalizeId($wid) || '_nodeIndex.xml'
    let $tei := 
        if (doc-available($workPath) and doc-available($indexPath)) 
            then util:expand(doc($workPath)/tei:TEI)
        else ()
    return
        if ($tei) then
            let $id := doc($indexPath)//sal:node[./sal:citetrail/text() eq $citetrail]/@n
            let $node := $tei/tei:text//*[@xml:id eq $id]
            let $wrappedNode := local:wrapInAncestorNode($node, $node)
            let $teiHeader := export:WRKgetTeiHeader($wid, 'metadata')
            return
                element {fn:QName('http://www.tei-c.org/ns/1.0', 'TEI')} {
                    $node/ancestor::tei:TEI/@*,
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
    if ($node/ancestor::*[not(self::tei:TEI or self::tei:text[@type eq 'work_part'])]) then
        let $debug := util:log('warn', '[EXPORT] number of ancestor nodes in local:wrapInAncestorNode(): ' 
                               || count($node/ancestor::*[not(self::tei:TEI or self::tei:text[@type eq 'work_part'])]))
        let $ancestor := $node/ancestor::*[not(self::tei:TEI or self::tei:text[@type eq 'work_part'])][1]
        let $wrap := 
            element {fn:QName('http://www.tei-c.org/ns/1.0', local-name($ancestor))} {
                $ancestor/@*, 
                $wrappedNode}
        return local:wrapInAncestorNode($ancestor, $wrap)
    else $wrappedNode
};


