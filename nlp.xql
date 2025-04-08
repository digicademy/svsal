xquery version "3.1";

(: ####++++----  

    NLP (plain text) export endpoint. Call this in the browser.
    All parameters are optional:
    - xmlid: pass an xml:id of a paragraph and get results only for this paragraph (default: '*', meaning all paragraphs)
    - wid: Only get paragraphs for this work (default: '*', meaning all works)
    - lang: return paragraphs of a particular language only (default: *', meaning all languages) 
    - mode: nonotes, edit, orig, snippets-edit etc. (default: nonotes - currently this is the only one available)
    - debug: Report to console about paragraphs being processed (default: false)
   
   ----++++#### :)

declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace tei           = "http://www.tei-c.org/ns/1.0";
declare namespace xi            = "http://www.w3.org/2001/XInclude";

import module namespace console = "http://exist-db.org/xquery/console";
import module namespace config  = "https://www.salamanca.school/xquery/config"       at "modules/config.xqm";
import module namespace index   = "https://www.salamanca.school/factory/works/index" at "modules/factory/works/index.xqm";
import module namespace nlp     = "https://www.salamanca.school/factory/works/nlp"   at "modules/factory/works/nlp.xqm";
import module namespace sutil   = "https://www.salamanca.school/xquery/sutil"        at "modules/sutil.xqm";

declare option output:method "text";
declare option output:media-type "text/plaintext";

let $mode       := request:get-parameter('mode', 'nonotes') (: edit, snippets-edit, nonotest, [nlp, ner, plain, ...] :)
let $xmlid      := request:get-parameter('xmlid', '*')
let $wid        := request:get-parameter('wid', '*')
let $lang       := request:get-parameter('lang', '*')
let $dbg        := xs:boolean(request:get-parameter('debug', 'false') ne "false")

let $debug      := console:log("[NLP] Starting export in '" || $mode || "' mode for wid '" || $wid || "' and @xml:id '" || $xmlid || "' ...")

let $collection :=  if ($wid ne '*') then
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:                      util:expand(collection($config:tei-works-root)//tei:TEI[@xml:id eq $wid])//tei:text:)
                        util:expand(collection($config:tei-works-root)/id($wid)/self::tei:TEI)//tei:text
                    else
                        collection($config:tei-works-root)//tei:TEI[sutil:WRKisPublished(@xml:id/string())]//tei:text[@type/string() = ("work_monograph", "work_volume")]

let $textnodes := if ($xmlid ne '*') then
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:                      $collection//tei:p[@xml:id eq $xmlid]:)
                        $collection/id($xmlid)/self::tei:*
                    else
                        $collection//tei:*[not(ancestor::tei:note)][not(ancestor::xi:fallback)][index:isMainNode(.)]

let $debug      := console:log("[NLP] Processing " || count($textnodes) || " text nodes in " || count($collection) || " text elements in '" || $mode || "' mode ...")
let $content    := nlp:createCSV($textnodes, $mode, $lang)
let $debug      := console:log("[NLP] Export done.")

return $content
