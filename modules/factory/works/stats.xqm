xquery version "3.1";

module namespace stats       = "https://www.salamanca.school/factory/works/stats";

declare namespace exist      = "http://exist.sourceforge.net/NS/exist";
declare namespace opensearch = "http://a9.com/-/spec/opensearch/1.1/";
declare namespace output     = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal        = "http://salamanca.adwmainz.de";
declare namespace tei        = "http://www.tei-c.org/ns/1.0";
declare namespace util       = "http://exist-db.org/xquery/util";

import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace templates   = "http://exist-db.org/xquery/html-templating";
import module namespace lib         = "http://exist-db.org/xquery/html-templating/lib";

import module namespace config      = "https://www.salamanca.school/xquery/config"           at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace sphinx      = "https://www.salamanca.school/xquery/sphinx"           at "xmldb:exist:///db/apps/salamanca/modules/sphinx.xqm";
import module namespace iiif        = "https://www.salamanca.school/xquery/iiif"             at "xmldb:exist:///db/apps/salamanca/modules/iiif.xqm";
import module namespace nlp         = "https://www.salamanca.school/factory/works/nlp"       at "xmldb:exist:///db/apps/salamanca/modules/factory/works/nlp.xqm";
import module namespace sutil       = "https://www.salamanca.school/xquery/sutil"            at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";


(: ####++++----

Functions for extracting statistical data from TEI works.

----++++#### :)

declare function stats:makeWorkStats($wid as xs:string) as map(*) {
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating stats for ' || $wid || '...') else ()

    (: LEMMATA :)
    (: search for single work like so: "ley @sphinx_work ^W0002":)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating Lemma stats for ' || $wid || '...') else ()
    let $lemmataDoc := json-doc($config:html-root || '/dictionary_en.json')
    let $lemmataList := array:for-each($lemmataDoc, function ($l) {
                                                                    if (map:contains($l, 'searchTerms')) then
                                                                        map { "lemma": $l?title, "searchTerms": $l?searchTerms }
                                                                    else
                                                                        map { "lemma": $l?title, "searchTerms": $l?title }
                                                                    })
    let $mfLemmata :=
        array:for-each($lemmataList, function ($l) {
            let $query := $l?searchTerms || ' @sphinx_work ^' || $wid
            let $currentSearch :=  sphinx:search((), map{}, $query, 'corpus-nogroup', 0, 10)
            let $currentOccurrencesCount := 
                if (count($currentSearch("results")//opensearch:totalResults) = 1) then
                    xs:integer($currentSearch("results")//opensearch:totalResults/text())
                else
                    xs:integer(sum($currentSearch("results")//opensearch:totalResults/text()))                       
            order by $currentOccurrencesCount descending
            return map{ 'lemma': $l?lemma, 'terms': $l?searchTerms, 'freq': $currentOccurrencesCount }
        })
    
    (: TOKENS / CHARS / WORDFORMS / TYPES :)
    (: generic, lang=all :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating character and token stats for ' || $wid || '...') else ()
    let $tei := doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI
    let $workType := $tei/tei:text/@type/string()
    let $text :=
        if ($workType eq 'work_monograph') then $tei/tei:text
        else if ($workType eq 'work_multivolume') then 
            for $t in util:expand($tei)//tei:text[@type eq 'work_volume'] return
                if (sutil:WRKisPublished($tei/@xml:id || '_' || $t/@xml:id)) then $t else ()
        else error('[STATS] $workType ' || $workType || ' does not match required types "work_monograph", "work_volume"')
    let $txt := 
        if (fn:unparsed-text-available($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt')) then
            fn:unparsed-text($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt')
        else error(xs:QName('stats:makeWorkStats'), 'No (edit) txt available for published work ' || $wid)

    let $charsCount := string-length(replace(string-join($txt, ''), '\s', ''))
    let $tokensCount := count(nlp:tokenize($txt, 'all'))
    let $words := nlp:tokenize($txt, 'words')
    let $wordformsCount := count(distinct-values($words))
    
    (: NORMALIZATIONS :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating expan/corr stats for ' || $wid || '...') else ()
    let $pureAbbrCount := count($text//tei:abbr)
    let $resolvedAbbrCount := count($text//tei:expan)
    let $pureSicCount := count($text//tei:sic)
    let $resolvedSicCount := count($text//tei:corr)
    let $resolvedHyphenationsCount := count($text//(tei:pb|tei:cb|tei:lb)[@rendition eq '#noHyphen'])

    (: FACSIMILES :)
    (: count full-text digitized images based on TEI//pb :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating facsimile stats for ' || $wid || '...') else ()
    let $fullTextFacsCount := count($text//tei:pb[not(@sameAs or @corresp)])

    let $lang := $tei/tei:teiHeader/tei:profileDesc//tei:language[@n eq 'main']/@ident/string()
    let $out :=
        map {
            'id': $wid,
            'lang': $lang,
            'chars_count': $charsCount,
            'tokens_count': $tokensCount,
            'words_count': count($words),
            'wordforms_count': $wordformsCount,
            'normalizations_count': map {
                'abbr':  $pureAbbrCount,
                'expan': $resolvedAbbrCount,
                'sic':   $pureSicCount,
                'corr':  $resolvedSicCount,
                'unmarked_hyph': $resolvedHyphenationsCount
            },
            'mf_lemmata': $mfLemmata,
            'facs_count': map {
                'full_text': $fullTextFacsCount
            }
        }

    let $debug := if ($config:debug = "info") then console:log('[STATS] Stats for ' || $wid || ' done.') else ()
    let $debug := if ($config:debug = "trace") then console:log('[STATS] Stats for ' || $wid || ' done: ') else ()
    let $debug := if ($config:debug = "trace") then console:log($out) else ()

    return $out
};
