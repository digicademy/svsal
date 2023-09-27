xquery version "3.1";

declare namespace exist         = "http://exist.sourceforge.net/NS/exist";
declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace sal           = "http://salamanca.adwmainz.de";
declare namespace tei           = "http://www.tei-c.org/ns/1.0";

import module namespace config  = "https://www.salamanca.school/xquery/config"      at "modules/config.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace txt     = "https://www.salamanca.school/factory/works/txt"  at "modules/factory/works/txt.xqm";

declare option output:media-type "text/plaintext";
declare option output:method "txt";
declare option output:indent "no";

let $mode       :=  request:get-parameter('mode', 'nonotes') (: edit, snippets-edit, nonotest, [nlp, ner, plain, ...] :)

let $collection := collection($config:tei-works-root)//tei:text
let $paragraphs := $collection//tei:p[not(ancestor::tei:note)]
let $debug      := console:log("[NLP] Processing " || count($paragraphs) || " paragraphs in '" || $mode || "' mode ...")
let $content    := for $p in $paragraphs
                        return try {
                            concat(
                                $p/@xml:id, ',"',
                                normalize-space(txt:p($p, $mode)), '"',
                                $config:nl
                            )
                        } catch * {
                            concat("WARNING: error in paragraph ", $p/@xml:id, ".", $config:nl)
                        }
return $content
