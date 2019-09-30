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
    (: remove technical / non-word items (including interpunctuation) and remove excessive whitespace: :)
    let $punctuation := '[\+\.,;\?!-–—\*¶†]'
    let $technicalChars := '[\{\}\[\]]'
    let $preproc := replace(string-join($text, ' '), $technicalChars, '')
    let $normalized := 
        if ($mode eq 'all') then 
            replace($preproc, '(' || $punctuation || ')', ' $1 ') (: make sure words and punctuation are separated :)
        else if ($mode eq 'words') then
            replace($preproc, $punctuation, ' ') (: remove punctuation altogether :)
        else replace($preproc, '(' || $punctuation || ')', ' $1 ') (: 'all' :)
    let $tokenized := tokenize($normalized, '\s+')
    return $tokenized
};
