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
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace functx     = "http://www.functx.com";
import module namespace config    = "http://salamanca/config"               at "config.xqm";


(:~
Fetches the teiHeader of a work's dataset.
@param mode: 'metadata' for reduced teiHeader without text-related information such as charDecl and revisionDesc
~:)
declare function export:WRKteiHeader($wid as xs:string?, $mode as xs:string?) {
    let $unexpanded := if (doc-available($config:tei-works-root || '/' || replace(replace($wid, "w0", "W0"), '_vol', '_Vol') || '.xml')) 
                           then doc($config:tei-works-root || '/' || replace(replace($wid, "w0", "W0"), '_vol', '_Vol') || '.xml')/tei:TEI/tei:teiHeader
                       else ()
    let $options   := (util:declare-option("output:method", "xml"),
                       util:declare-option("output:media-type", "application/tei+xml"),
                       util:declare-option("output:indent", "yes"),
                       util:declare-option("output:expand-xincludes", "yes"))
    let $expanded := util:expand($unexpanded)
    
    let $header :=  if ($mode eq 'metadata') then 
                        let $nodes := $expanded/*[not(self::tei:encodingDesc) and not(self::tei:revisionDesc)]
                        let $encodingDesc := <encodingDesc>{$expanded/tei:encodingDesc/*[not(self::tei:charDecl)]}</encodingDesc>
                        return <teiHeader xmlns="http://www.tei-c.org/ns/1.0">{($nodes, $encodingDesc)}</teiHeader>
                    else $expanded
    return $header
};


