xquery version "3.1";

module namespace stats       = "https://www.salamanca.school/factory/works/stats";
declare namespace exist      = "http://exist.sourceforge.net/NS/exist";
declare namespace opensearch = "http://a9.com/-/spec/opensearch/1.1/";
declare namespace output     = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal        = "http://salamanca.adwmainz.de";
declare namespace tei        = "http://www.tei-c.org/ns/1.0";
declare namespace templates  = "http://exist-db.org/xquery/templates";
declare namespace util       = "http://exist-db.org/xquery/util";
import module namespace config    = "http://salamanca/config"                at "config.xqm";
import module namespace sphinx    = "http://salamanca/sphinx"                at "sphinx.xql";
import module namespace console   = "http://exist-db.org/xquery/console";
import module namespace iiif     = "http://salamanca/iiif" at "iiif.xql";
import module namespace nlp    = "https://www.salamanca.school/factory/works/nlp" at "nlp.xqm";
import module namespace sal-util = "http://salamanca/sal-util" at "sal-util.xql";


(: ####++++----

Functions for extracting statistical data from TEI works.

----++++#### :)


declare function stats:makeCorpusStats() as map(*) {
    (: LEMMATA :)
    (: TODO: are queries syntactically correct, e.g. "ius gentium"? :)
    (: search for single work like so: "ley @sphinx_work ^W0002":)
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
    let $publishedWorkIds := 
                collection($config:tei-works-root)//tei:TEI[./tei:text[@type = ('work_monograph', 'work_multivolume')] 
                                                    and sal-util:WRKisPublished(./@xml:id)]/@xml:id/string()
    let $txtAll := 
        for $id in $publishedWorkIds return 
            if (fn:unparsed-text-available($config:txt-root || '/' || $id || '/' || $id || '_edit.txt')) then
                fn:unparsed-text($config:txt-root || '/' || $id || '/' || $id || '_edit.txt')
            else error('No (edit) txt available for published work ' || $id)
(:    let $debug := util:log('warn', '[STATS] sending ' || count($txtAll) || ' texts to nlp:tokenize()'):)
    let $charsAllCount := string-length(replace(string-join($txtAll, ''), '\s', ''))
    let $tokensAllCount := count(nlp:tokenize($txtAll, 'all'))
    let $wordsAll := nlp:tokenize($txtAll, 'words')
(:    let $debug := util:log('warn', '[STATS] $wordsAll[1:20] is: ' || string-join(subsequence($wordsAll,1,20), ', ')):)
    let $wordformsAllCount := count(distinct-values($wordsAll))
    
    (: not counting tokens etc. per language, since this slows down this function quite a bit... :)
    (: lang=es :)
    (:let $txtEs := 
        for $text in collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                                  and sal-util:WRKisPublished(./parent::tei:TEI/@xml:id)] return
                let $debug := util:log('warn', 'Processing text nodes for ' || $text/parent::tei:TEI/@xml:id || ' in lang=es') return
                string-join($text//text()[ancestor::*[@xml:lang][1]/@xml:lang eq 'es'], '')
    let $wordsEs := nlp:tokenize($txtEs, 'words')
    let $typesEsCount := count(distinct-values($wordsEs)):)
    (: lang=la :)
    (:let $txtLa := 
        for $text in collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                                  and sal-util:WRKisPublished(./parent::tei:TEI/@xml:id)] return
                let $debug := util:log('warn', 'Processing text nodes for ' || $text/parent::tei:TEI/@xml:id || ' in lang=la') return
                string-join($text//text()[ancestor::*[@xml:lang]/@xml:lang eq 'la'], '')
    let $wordsLa := nlp:tokenize($txtLa, 'words')
    let $typesLaCount := count(distinct-values($wordsLa)):)
    
    let $textCollection :=
        collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                     and sal-util:WRKisPublished(./parent::tei:TEI/@xml:id)]
    (: NORMALIZATIONS :)
    let $resolvedAbbrCount := count($textCollection//tei:expan)
    let $resolvedSicCount := count($textCollection//tei:corr)
    let $resolvedHyphenationsCount := count($textCollection//(tei:pb|tei:cb|tei:lb)[@rendition eq '#noHyphen'])

    (: FACSIMILES :)
    (: count full-text digitized images based on TEI//pb :)
    let $fullTextFacsCount := count($textCollection//tei:pb[not(@sameAs or @corresp)])
    (: count other images based on iiif resources :)
    let $unpublishedWorkIds :=
        collection($config:tei-works-root)//tei:TEI[./tei:text[@type = ('work_monograph', 'work_volume')] 
                                                    and not(sal-util:WRKisPublished(@xml:id))]/@xml:id/string()
    let $otherFacs :=
        for $id in $unpublishedWorkIds return (: $unpublishedWorkIds can only comprise manifests, not collections :)
            let $iiif := iiif:fetchResource($id)
            return
                if (count($iiif) gt 0) then 
                    if ($iiif('@type') eq 'sc:Manifest') then
                        array:size(array:get($iiif('sequences'), 1)?('canvases'))
                    else error()
                else error('No iiif resource available for work ' || $id)
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

    (:let $debugParams := 
        <output:serialization-parameters 
                xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
          <output:method value="json"/>
        </output:serialization-parameters>
    let $debug := util:log('warn', 'Finalized statistics: ' || serialize($out, $debugParams)):)

    return $out
    (: TODO: basic description of how wf/tokens are counted (and possible pitfalls like abbreviations...) :)
};

declare function stats:makeWorkStats($wid as xs:string) as map(*) {
    (: LEMMATA :)
    (: search for single work like so: "ley @sphinx_work ^W0002":)
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
    let $tei := doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI
    let $workType := $tei/tei:text/@type/string()
    let $text :=
        if ($workType eq 'work_monograph') then $tei/tei:text
        else if ($workType eq 'work_multivolume') then 
            for $t in util:expand($tei)//tei:text[@type eq 'work_volume'] return
                if (sal-util:WRKisPublished($tei/@xml:id || '_' || $t/@xml:id)) then $t else ()
        else error('[STATS] $workType ' || $workType || ' does not match required types "work_monograph", "work_volume"')
    let $txt := 
        if (fn:unparsed-text-available($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt')) then
            fn:unparsed-text($config:txt-root || '/' || $wid || '/' || $wid || '_edit.txt')
        else error('[STATS] No (edit) txt available for published work ' || $wid)

    let $charsCount := string-length(replace(string-join($txt, ''), '\s', ''))
    let $tokensCount := count(nlp:tokenize($txt, 'all'))
    let $words := nlp:tokenize($txt, 'words')
(:    let $debug := util:log('warn', '[STATS] $wordsAll[1:20] is: ' || string-join(subsequence($wordsAll,1,20), ', ')):)
    let $wordformsCount := count(distinct-values($words))
    
    (: NORMALIZATIONS :)
    let $resolvedAbbrCount := count($text//tei:expan)
    let $resolvedSicCount := count($text//tei:corr)
    let $resolvedHyphenationsCount := count($text//(tei:pb|tei:cb|tei:lb)[@rendition eq '#noHyphen'])

    (: FACSIMILES :)
    (: count full-text digitized images based on TEI//pb :)
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
    let $debug := util:log('warn', 'Finalized statistics: ' || serialize($out, $debugParams)):)

    return $out
};
