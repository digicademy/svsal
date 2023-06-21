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


declare function stats:makeCorpusStats() as map(*) {
    (: LEMMATA :)
    (: TODO: are queries syntactically correct, e.g. "ius gentium"? :)
    (: search for single work like so: "ley @sphinx_work ^W0002":)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating corpus lemma stats...') else ()
    let $lemmataList := doc($config:data-root || '/lemmata-97.xml')//sal:lemma[@type eq 'term']
    let $mfLemmata :=
        for $l in $lemmataList 
            let $query := $l/text()
            let $currentSearch :=  sphinx:search((), map{}, $query, 'corpus-nogroup', 0, 10)
            let $currentOccurrencesCount := 
                if (count($currentSearch("results")//terms) = 1) then
                    xs:integer($currentSearch("results")//terms/hits/text())
                else
                    xs:integer(sum($currentSearch("results")//terms/hits/text()))
                        
(:                        let $secondWorksCount      := count(distinct-values($secondSearch("results")//item/work/text()))
:)                        
            order by $currentOccurrencesCount descending
            return map{'lid': $l/@xml:id/string(), 'terms': $l/text(), 'freq': $currentOccurrencesCount }
    
    (: TOKENS / CHARS / WORDFORMS / TYPES :)
    (: generic, lang=all :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating corpus character and token stats...') else ()
    let $publishedWorkIds := 
                collection($config:tei-works-root)//tei:TEI[./tei:text[@type = ('work_monograph', 'work_multivolume')] 
                                                    and sutil:WRKisPublished(./@xml:id)]/@xml:id/string()
    let $txtAll := 
        for $id in $publishedWorkIds order by $id return 
            if (fn:unparsed-text-available($config:txt-root || '/' || $id || '/' || $id || '_edit.txt')) then
                fn:unparsed-text($config:txt-root || '/' || $id || '/' || $id || '_edit.txt')
            else error(xs:QName('stats:makeCorpusStats()'), 'No (edit) txt available for published work ' || $id)
(:    let $debug := util:log('info', '[STATS] sending ' || count($txtAll) || ' texts to nlp:tokenize()'):)
    let $charsAllCount := string-length(replace(string-join($txtAll, ''), '\s', ''))
    let $tokensAllCount := count(nlp:tokenize($txtAll, 'all'))
    let $wordsAll := nlp:tokenize($txtAll, 'words')
(:    let $debug := util:log('info', '[STATS] $wordsAll[1:20] is: ' || string-join(subsequence($wordsAll,1,20), ', ')):)
    let $wordformsAllCount := count(distinct-values($wordsAll))  
    
    (: not counting tokens etc. per language, since this slows down this function quite a bit... :)
    (: lang=es :)
    (:let $txtEs := 
        for $text in collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                                  and sutil:WRKisPublished(./parent::tei:TEI/@xml:id)] return
                let $debug := util:log('info', 'Processing text nodes for ' || $text/parent::tei:TEI/@xml:id || ' in lang=es') return
                string-join($text//text()[ancestor::*[@xml:lang][1]/@xml:lang eq 'es'], '')
    let $wordsEs := nlp:tokenize($txtEs, 'words')
    let $typesEsCount := count(distinct-values($wordsEs)):)
    (: lang=la :)
    (:let $txtLa := 
        for $text in collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                                  and sutil:WRKisPublished(./parent::tei:TEI/@xml:id)] return
                let $debug := util:log('info', 'Processing text nodes for ' || $text/parent::tei:TEI/@xml:id || ' in lang=la') return
                string-join($text//text()[ancestor::*[@xml:lang]/@xml:lang eq 'la'], '')
    let $wordsLa := nlp:tokenize($txtLa, 'words')
    let $typesLaCount := count(distinct-values($wordsLa)):)
    
    let $textCollection :=
        collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                     and sutil:WRKisPublished(./parent::tei:TEI/@xml:id)]
    (: NORMALIZATIONS :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating corpus expan/corr stats...') else ()
    let $resolvedAbbrCount := count($textCollection//tei:expan)
    let $resolvedSicCount := count($textCollection//tei:corr)
    let $resolvedHyphenationsCount := count($textCollection//(tei:pb|tei:cb|tei:lb)[@rendition eq '#noHyphen'])

    (: FACSIMILES :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating corpus facsimile stats...') else ()
    (: count full-text digitized images based on TEI//pb :)
    let $fullTextFacsCount := count($textCollection//tei:pb[not(@sameAs or @corresp)])
    (: count other images based on iiif resources :)
    let $unpublishedWorkIds :=
        collection($config:tei-works-root)//tei:TEI[./tei:text[@type = ('work_monograph', 'work_volume')] 
                                                    and not(sutil:WRKisPublished(@xml:id))]/@xml:id/string()
    let $otherFacs :=
        for $id in $unpublishedWorkIds order by $id return (: $unpublishedWorkIds can only comprise manifests, not collections :)
            let $iiif := iiif:fetchResource($id)
            return
                if (count($iiif) gt 0) then 
                    if ($iiif('@type') eq 'sc:Manifest') then
                        array:size(array:get($iiif('sequences'), 1)?('canvases'))
                    else
                        let $debug := console:log('[Stats] Invalid iiif manifest for work ' || $id || '.')
                        return 0
                        (: error() :)
                else
                    let $debug := console:log('[Stats] No iiif resource available for work ' || $id || '.')
                    (: error(xs:QName('stats:makeCorpusStats'), 'No iiif resource available for work ' || $id) :)
                    return 0
    let $totalFacsCount := $fullTextFacsCount + sum($otherFacs)


    let $out :=
        map {
            'id': 'corpus',
            'chars_count': $charsAllCount,
            'tokens_count': $tokensAllCount,
            'words_count': count($wordsAll),
            'wordforms_count': $wordformsAllCount,
            'normalizations_count': map {'abbr': $resolvedAbbrCount, 'sic': $resolvedSicCount, 'unmarked_hyph': $resolvedHyphenationsCount},
            'mf_lemmata': $mfLemmata,
            'facs_count': map {'full_text': $fullTextFacsCount, 'all': $totalFacsCount}
        }
    let $debug := if ($config:debug = "info") then console:log('[STATS] Corpus stats done.') else ()
    let $debug := if ($config:debug = "trace") then console:log('[STATS] Corpus stats done: ') else ()
    let $debug := if ($config:debug = "trace") then console:log($out) else ()

    (:let $debugParams := 
        <output:serialization-parameters 
                xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:method value="json"/>
        </output:serialization-parameters>
    let $debug := util:log('info', 'Finalized statistics: ' || serialize($out, $debugParams)):)

    return $out
    (: TODO: basic description of how wf/tokens are counted (and possible pitfalls like abbreviations...) :)
};

declare function stats:makeWorkStats($wid as xs:string) as map(*) {
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating stats for ' || $wid || '...') else ()
    (: LEMMATA :)
    (: search for single work like so: "ley @sphinx_work ^W0002":)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating Lemma stats for ' || $wid || '...') else ()
    let $lemmataList := doc($config:data-root || '/lemmata-97.xml')//sal:lemma[@type eq 'term']
    let $mfLemmata :=
        for $l in $lemmataList 
            let $query := $l/text() || ' @sphinx_work ^' || $wid
            let $currentSearch :=  sphinx:search((), map{}, $query, 'corpus-nogroup', 0, 10)
            let $currentOccurrencesCount := 
                if (count($currentSearch("results")//opensearch:totalResults) = 1) then
                    xs:integer($currentSearch("results")//opensearch:totalResults/text())
                else
                    xs:integer(sum($currentSearch("results")//opensearch:totalResults/text()))                       
            order by $currentOccurrencesCount descending
            return map{'lid': $l/@xml:id/string(), 'terms': $l/text(), 'freq': $currentOccurrencesCount }
    
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
(:    let $debug := util:log('info', '[STATS] $wordsAll[1:20] is: ' || string-join(subsequence($wordsAll,1,20), ', ')):)
    let $wordformsCount := count(distinct-values($words))
    
    (: NORMALIZATIONS :)
    let $debug := if ($config:debug = ("info", "trace")) then console:log('[STATS] Creating expan/corr stats for ' || $wid || '...') else ()
    let $resolvedAbbrCount := count($text//tei:expan)
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
            'normalizations_count': map {'abbr': $resolvedAbbrCount, 'sic': $resolvedSicCount, 'unmarked_hyph': $resolvedHyphenationsCount},
            'mf_lemmata': $mfLemmata,
            'facs_count': map {'full_text': $fullTextFacsCount}
        }

    (:let $debugParams := 
        <output:serialization-parameters 
                xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:method value="json"/>
        </output:serialization-parameters>
    let $debug := util:log('info', 'Finalized statistics: ' || serialize($out, $debugParams)):)

    let $debug := if ($config:debug = "info") then console:log('[STATS] Stats for ' || $wid || ' done.') else ()
    let $debug := if ($config:debug = "trace") then console:log('[STATS] Stats for ' || $wid || ' done: ') else ()
    let $debug := if ($config:debug = "trace") then console:log($out) else ()

    return $out
};
