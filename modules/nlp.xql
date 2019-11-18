xquery version "3.1";

module namespace nlp       = "http://salamanca/nlp";
declare namespace exist      = "http://exist.sourceforge.net/NS/exist";
declare namespace sal        = "http://salamanca.adwmainz.de";
declare namespace tei        = "http://www.tei-c.org/ns/1.0";
declare namespace util       = "http://exist-db.org/xquery/util";
import module namespace console   = "http://exist-db.org/xquery/console";


(:
~ Modes:
~   - 'all': punctuation characters/symbols count as tokens
~   - 'words': only tokens without punctuation are counted
:)
declare function nlp:tokenize($text as xs:string*, $mode as xs:string?) as xs:string* {
    
    let $punctuation := '([\+\.,;\?!\-–—\*¶†])'
    let $technicalChars := '([\{\}]|\[.*?\])' (: filter out '{'/'}' at the beginning/ending og marg. notes, and [.*?] altogether (LOD ids) :)
    
    let $preproc := replace(string-join($text, ' '), $technicalChars, '')
(:    let $debug := util:log('warn', '[NLP] in mode ' || $mode || ', $preproc starts with: ' || substring($preproc, 1, 200)):)
    
    let $normalized := 
        if ($mode eq 'all') then 
            replace($preproc, $punctuation, ' $1 ') (: make sure words and punctuation are separated :)
        else if ($mode eq 'words') then
            replace($preproc, $punctuation, ' ') (: remove punctuation altogether :)
        else replace($preproc, $punctuation, ' $1 ') (: 'all' :)
(:    let $debug := util:log('warn', '[NLP] in mode ' || $mode || ', $normalized starts with: ' || substring($normalized, 1, 200)):)
    
    let $tokenized := tokenize($normalized, '\s+')
    
    return $tokenized
};