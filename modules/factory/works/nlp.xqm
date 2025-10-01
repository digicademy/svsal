xquery version "3.1";

module namespace nlp         = "https://www.salamanca.school/factory/works/nlp";

declare namespace sal        = "http://salamanca.adwmainz.de";
declare namespace tei        = "http://www.tei-c.org/ns/1.0";

import module namespace config  = "https://www.salamanca.school/xquery/config"       at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace sutil   = "https://www.salamanca.school/xquery/sutil"        at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";
import module namespace txt     = "https://www.salamanca.school/factory/works/txt"   at "txt.xqm";

(: ####++++----

Functions for extracting data (such as token streams) from TEI work datasets 
for statistical and/or NLP analysis.

----++++#### :)


(:
~ Modes:
~   - 'all': punctuation characters/symbols count as tokens
~   - 'words': only tokens without punctuation are counted
:)
declare function nlp:tokenize($text as xs:string*, $mode as xs:string?) as xs:string* {
    
    let $punctuation := '([\+\.,;\?!\-–—\*¶†])'
    let $technicalChars := '([\{\}]|\[.*?\])' (: filter out '{'/'}' at the beginning/ending og marg. notes, and [.*?] altogether (LOD ids) :)
    
    let $preproc := replace(string-join($text, ' '), $technicalChars, '')
(:    let $debug := util:log('info', '[NLP] in mode ' || $mode || ', $preproc starts with: ' || substring($preproc, 1, 200)):)
    
    let $normalized := 
        if ($mode eq 'all') then 
            replace($preproc, $punctuation, ' $1 ') (: make sure words and punctuation are separated :)
        else if ($mode eq 'words') then
            replace($preproc, $punctuation, ' ') (: remove punctuation altogether :)
        else replace($preproc, $punctuation, ' $1 ') (: 'all' :)
(:    let $debug := util:log('info', '[NLP] in mode ' || $mode || ', $normalized starts with: ' || substring($normalized, 1, 200)):)
    
    let $tokenized := tokenize($normalized, '\s+')
    
    return $tokenized
};

declare function nlp:createCSV($textnodes as node()*, $mode as xs:string?, $lang as xs:string?) {
    let $content := for $t in $textnodes
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
            let $report := if ($config:debug = ("trace")) then 
                             let $debug := trace("[NLP] *[xml:id='" || string($t/@xml:id) || "'] - " || string-join(distinct-values(for $e in $t/* return local-name($e)), ', ') || ": " || serialize($t), "[NLP]")
                             let $debug := trace("[NLP] txt:dispatch($t, $mode): " || $text-content, "[NLP]")
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

    return concat("url,xmlid,lang,wid,author-id,author-name,title,year,passage,citation-recommendation,content", $config:nl, string-join($content, ''))
};
