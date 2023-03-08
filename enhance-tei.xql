xquery version "3.1";

declare         namespace   exist       = "http://exist.sourceforge.net/NS/exist";
declare         namespace   output      = "http://www.w3.org/2010/xslt-xquery-serialization";
declare         namespace   request     = "http://exist-db.org/xquery/request";
declare         namespace   sal         = "http://salamanca.adwmainz.de";
declare         namespace   tei         = "http://www.tei-c.org/ns/1.0";
declare         namespace   itei        = "http://www.salamanca.school/indexed-tei";
declare         namespace   util        = "http://exist-db.org/xquery/util";

import module   namespace   console     = "http://exist-db.org/xquery/console";

import module   namespace   config      = "http://www.salamanca.school/xquery/config"   at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module   namespace   i18n        = "http://exist-db.org/xquery/i18n"             at "xmldb:exist:///db/apps/salamanca/modules/i18n.xqm";

(: Reduces a TEI doc to pure structural information and indexes structural nodes according to sal:node index, thus enhancing the TEI for RDF extraction. :)

declare option exist:timeout '3500000'; (: ~1h :)

declare option output:method 'xml';

declare variable $omittableElemTypes := ('g', 'lb', 'cb', 'hi', 'choice', 'abbr', 'sic', 'orig', 'expan', 'corr', 'reg', 'ref', 'foreign');
declare variable $omittableAttrTypes := ('anchored', 'rendition', 'resp', 'change', 'cert');

declare function local:copy($input as item()*, $salNodes as map()?) as item()* {
    for $node in $input return 
        typeswitch($node)
            case element()
                return
                    (: remove frequent, but irrelevant elements :)
                    if (local-name($node) = $omittableElemTypes) then 
                        for $child in $node return local:copy($child/node(), $salNodes)
                    else if ($node/self::tei:text and $node/@xml:id eq 'completeWork') then
                        (: since the text root itself might not be in the index, we must handle it here especially :)
                        element {'itei:' || local-name($node)} {
                            (
                            (: give tei:text fragments rudimentary information about their context, so that rdf extraction doesn't need to access respective teiHeaders especially :)
                            attribute in {$node/ancestor::tei:TEI/@xml:id},
                            $node/@*
                            ),
                            for $child in $node
                                return local:copy($child/node(), $salNodes)
                        }
                    else 
                        element {'itei:' || local-name($node)} {
                          (: copy all the attributes :)
                          for $att in $node/@*[not(name(.) = $omittableAttrTypes)]
                              return
                                  (: if we are dealing with an xml:id attribute, and this also occurs in the _nodeIndex file, pull in more attributes from there :)
                                  if (name($att) = "xml:id" and map:get($salNodes,$att)) then (: equivalent to render:isIndexNode() :)
                                      let $sn := map:get($salNodes,$att)
                                      let $pn := map:get($salNodes,$sn/sal:citableParent/string())
                                      (: add (only English) label to title (also German and Spanish?) :)
                                      let $title := 
                                          i18n:process(<i18n:text key="{$sn/@class/string()}"/>,'en','/db/apps/salamanca/data/i18n','en') || ' ' || $sn/sal:title/text()
                                      return (
                                          attribute title {$title},
                                          if ($sn/sal:crumbtrail/a[last()]/@href) then attribute web {$sn/sal:crumbtrail/a[last()]/@href} else (),
                                          attribute citableParent {$pn/sal:citetrail},
                                          attribute citetrail {$sn/sal:citetrail},
                                          $att,
                                          (: give tei:text fragments rudimentary information about their context, so that rdf extraction doesn't need to access respective teiHeaders especially :)
                                          if ($node/self::tei:text[@type eq "work_volume"]) then 
                                            attribute in {$node/ancestor::tei:TEI/@xml:id}
                                          else ()
                                      )
                                  else
                                      attribute {name($att)} {$att}
                          ,
                          (: output all the child elements of this element recursively :)
                          for $child in $node
                             return local:copy($child/node(), $salNodes)
                        }
            case processing-instruction() return $node
            (: remove text nodes and comments :)
            default return ()
};

let $wid        :=  request:get-parameter('wid', '')
let $debug      := if ($config:debug = ("trace", "info")) then console:log("tei enhancer running, requested work " || $wid || ".") else ()

let $origTEI    := util:expand(doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI)
let $salNodesF  := doc($config:index-root || '/' || $wid || '_nodeIndex.xml')/sal:index
let $salNodesM := map:merge(for $n in $salNodesF/sal:node return map:entry($n/@n/string(), $n))

let $output     := local:copy($origTEI, $salNodesM)

return $output
