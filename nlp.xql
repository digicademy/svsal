xquery version "3.1";

(: ####++++----  

    NLP (plain text) export endpoint. Call this in the browser.
    All parameters are optional:
    - xmlid: pass an xml:id of a paragraph and get results only for this paragraph (default: all paragraphs)
    - wid: Only get paragraphs for this work (default: all works)
    - mode: nonotes, edit, orig, snippets-edit etc. (default: nonotes)
    - debug: Report to console about paragraphs being processed (default: false)
   
   ----++++#### :)

declare namespace exist         = "http://exist.sourceforge.net/NS/exist";
declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace sal           = "http://salamanca.adwmainz.de";
declare namespace tei           = "http://www.tei-c.org/ns/1.0";
declare namespace xi            = "http://www.w3.org/2001/XInclude";

import module namespace config  = "https://www.salamanca.school/xquery/config"      at "modules/config.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace txt     = "https://www.salamanca.school/factory/works/txt"  at "modules/factory/works/txt.xqm";

declare option output:method "text";
declare option output:media-type "text/plaintext";

let $mode       := request:get-parameter('mode', 'nonotes') (: edit, snippets-edit, nonotest, [nlp, ner, plain, ...] :)
let $xmlid      := request:get-parameter('xmlid', '*')
let $wid        := request:get-parameter('wid', '*')
let $dbg        := request:get-parameter('debug', 'false')
let $lang      := request:get-parameter('lang', '*')
let $debug      := console:log("[NLP] Starting export in '" || $mode || "' mode for wid '" || $wid || "' and @xml:id '" || $xmlid || "' ...")

let $collection :=  if ($wid ne '*') then
                        util:expand(collection($config:tei-works-root)//tei:TEI[@xml:id eq $wid])//tei:text
                    else
                        collection($config:tei-works-root)//tei:text

let $paragraphs := if ($xmlid ne '*') then
                        $collection//tei:p[@xml:id eq $xmlid]
                    else
                        $collection//tei:p[not(ancestor::tei:note)][not(ancestor::xi:fallback)]

let $debug      := console:log("[NLP] Processing " || count($paragraphs) || " paragraphs in " || count($collection) || " text elements in '" || $mode || "' mode ...")
let $content    := for $p in $paragraphs
                        let $plang := $p/ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang/string()
                        let $year := ($p/ancestor::tei:TEI/tei:teiHeader//tei:sourceDesc//tei:imprint//tei:date)[1]/@when/string()
                        let $author-id := substring(tokenize(($p/ancestor::tei:TEI/tei:teiHeader//tei:titleStmt//tei:author//@ref)[1], ' ')[1], 8)

                        return if ($lang = '*' or $lang = $plang) then                        
                            let $report := if ($dbg ne 'false') then 
                                             let $debug := console:log("p[xml:id='" || string($p/@xml:id) || "'] - " || string-join(distinct-values(for $e in $p/* return local-name($e)), ', ') || ": " || serialize($p))
                                             let $debug := console:log("txt:p($p, $mode): " || txt:p($p, $mode))
                                             return ()
                                            else ()
                            
                            return try {
                                concat(
                                    $p/@xml:id, ',', $plang, ',', $year, ',', $author-id, ',"',
                                    normalize-space(txt:p($p, $mode)), '"',
                                    $config:nl
                                )
                            } catch * {
                                concat("WARNING: error in paragraph ", $p/@xml:id, ".", $config:nl)
                            }
                        else ()
let $debug      := console:log("[NLP] Export done.")

return $content
