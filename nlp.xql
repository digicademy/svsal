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

declare namespace exist         = "http://exist.sourceforge.net/NS/exist";
declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace sal           = "http://salamanca.adwmainz.de";
declare namespace tei           = "http://www.tei-c.org/ns/1.0";
declare namespace xi            = "http://www.w3.org/2001/XInclude";

import module namespace config  = "https://www.salamanca.school/xquery/config"      at "modules/config.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace txt     = "https://www.salamanca.school/factory/works/txt"  at "modules/factory/works/txt.xqm";
import module namespace index   = "https://www.salamanca.school/factory/works/index" at "modules/factory/works/index.xqm";
import module namespace sutil   = "https://www.salamanca.school/xquery/sutil" at "modules/sutil.xqm";

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
let $content    := for $t in $textnodes
                        let $wid := tokenize($t/ancestor::tei:TEI/@xml:id/string(), '_')[1]
                        let $index := doc($config:index-root || '/' || $wid || '_nodeIndex.xml')
                        let $idxnode := $index//sal:node[@n/string() eq $t/@xml:id/string()]
                        let $citeId := $idxnode/@citeID/string()
                        let $url := $config:idserver || '/texts/' || $wid || ':' || $citeId
                        let $plang := $t/ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang/string()
                        let $fileDesc := $t/root()//tei:fileDesc
                        let $sourceDesc :=  $t/root()//tei:sourceDesc
                        let $author-name := string-join($fileDesc//tei:titleStmt//tei:author//tei:surname, '/')
                        let $author-id := substring(tokenize(($fileDesc//tei:titleStmt//tei:author//@ref)[1], ' ')[1], 8)
                        let $short-title := $fileDesc//tei:titleStmt//tei:title[@type eq "short"]
                        let $long-title := $fileDesc//tei:titleStmt//tei:title[@type eq "main"]
                        let $title := if ($short-title) then $short-title else $long-title
                        let $year := ($sourceDesc//tei:imprint//tei:date)[1]/@when/string()
                        let $passage := translate(sutil:getNodetrail($wid, $t, 'label'), '"', "'")
                        let $cit-rec := translate(sutil:HTMLmakeCitationReference($wid, $fileDesc, 'reading-passage', $t), '"', "'")
                        let $text-content := translate(normalize-space(string-join(txt:dispatch($t, $mode), ' ')), '"', "'")
                        return if ($lang = '*' or $lang = $plang) then                        
                            let $report := if ($dbg) then 
                                             let $debug := console:log("[NLP] *[xml:id='" || string($t/@xml:id) || "'] - " || string-join(distinct-values(for $e in $t/* return local-name($e)), ', ') || ": " || serialize($t))
                                             let $debug := console:log("[NLP] txt:dispatch($t, $mode): " || $text-content)
                                             return ()
                                            else ()
                            
                            return try {
                                concat(
                                    $url, ',', $t/@xml:id, ',', $plang, ',',
                                    $wid, ',', $author-id, ',',
                                    $author-name, ',',
                                    '"', $title, '"', ',',
                                    $year, ',',
                                    '"', $passage, '"', ',',
                                    '"', $cit-rec, '"', ',',
                                    '"', $text-content, '"',
                                    $config:nl
                                )
                            } catch * {
                                concat("WARNING: error in paragraph ", $t/@xml:id, ".", $config:nl)
                            }
                        else ()
let $debug      := console:log("[NLP] Export done.")

return concat("url,xmlid,lang,wid,author-id,author-name,title,year,passage,citation-recommendation,content", $config:nl, string-join($content, ''))
