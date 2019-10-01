xquery version "3.1";

module namespace stats       = "http://salamanca/stats";
declare namespace exist      = "http://exist.sourceforge.net/NS/exist";
declare namespace opensearch = "http://a9.com/-/spec/opensearch/1.1/";
declare namespace output     = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace sal        = "http://salamanca.adwmainz.de";
declare namespace tei        = "http://www.tei-c.org/ns/1.0";
declare namespace templates  = "http://exist-db.org/xquery/templates";
declare namespace util       = "http://exist-db.org/xquery/util";
import module namespace config    = "http://salamanca/config"                at "config.xqm";
import module namespace sphinx    = "http://salamanca/sphinx"                at "sphinx.xql";
import module namespace nlp    = "http://salamanca/nlp"                at "nlp.xql";
import module namespace console   = "http://exist-db.org/xquery/console";
import module namespace sal-util = "http://salamanca/sal-util" at "sal-util.xql";
import module namespace iiif     = "http://salamanca/iiif" at "iiif.xql";
(:
import module namespace i18n      = "http://exist-db.org/xquery/i18n"        at "i18n.xql";
import module namespace kwic      = "http://exist-db.org/xquery/kwic";
import module namespace request   = "http://exist-db.org/xquery/request";
import module namespace templates = "http://exist-db.org/xquery/templates";
:)

(: temporary corpus / stopword list ids for testing :)
declare variable $stats:texts :=
    map {
        'W0002': map {'corpus': '2d48af7331bcefd57aceddad39486044', 'lang': 'es'},
        'W0003': map {'corpus': '92812b2dd584cbce029af43903c4a0e5', 'lang': 'la'},
        'W0004': map {'corpus': '368c1dabc5ec01c30653f20937429de7', 'lang': 'es'},
        'W0007': map {'corpus': '4c5400ed74aaee9cdd07b322a5ab6da4', 'lang': 'es'},
        'W0010': map {'corpus': '349ec4cc5b9abb2c882327298317c1c1', 'lang': 'es'},
        'W0013': map {'corpus': '73ecbe84ed4014de980b138c99aef85d', 'lang': 'la'},
        'W0014': map {'corpus': '8c0501a097b017fe27a67c9794121af8', 'lang': 'la'},
        'W0015': map {'corpus': 'f5d56c4f2fbb2c005309934fc839b34c', 'lang': 'es'},
        'W0030': map {'corpus': 'd1ce5f298485838a046efee6f7df58a2', 'lang': 'la'},
        'W0034': map {'corpus': '10d96859e54e8e0284fe417d9c7ba3b5', 'lang': 'es'}
    };
declare variable $stats:stopwords :=
    map {
        'es': 'keywords-fbfc59c9d04ebfeae3d00ecd223cf0d3',
        'la': 'keywords-4a4422ee87f6548115c189eb5115d879'
    };
    
declare function stats:makeCorpusStats() as map(*) {
    
    (: LEMMATA :)
    (: TODO: are queries syntactically correct, e.g. "ius gentium"? :)
    let $lemmataList := doc($config:data-root || '/lemmata-97.xml')//sal:lemma[@type eq 'term']
    let $mfLemmata :=
        for $l in $lemmataList 
            let $query := $l/text()
            let $currentSearch := sphinx:search((), map{}, $query, 'corpus-nogroup', 0, 10)
            let $currentOccurrencesCount := 
                if (count($currentSearch("results")//terms) = 1) then
                    xs:integer($currentSearch("results")//terms/hits/text())
                else
                    xs:integer(sum($currentSearch("results")//terms/hits/text()))
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
    let $typesAllCount := count(distinct-values($wordsAll))
    
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
    
    (: NORMALIZATIONS :)
    let $resolvedAbbrCount :=
        count(collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                           and sal-util:WRKisPublished(./parent::tei:TEI/@xml:id)]//tei:expan)
    let $resolvedSicCount :=
        count(collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                           and sal-util:WRKisPublished(./parent::tei:TEI/@xml:id)]//tei:corr)

    (: FACSIMILES :)
    (: count full-text digitized images based on TEI//pb :)
    let $fullTextFacsCount := 
        count(
            collection($config:tei-works-root)//tei:text[@type = ('work_monograph', 'work_volume') 
                                                         and sal-util:WRKisPublished(./parent::tei:TEI/@xml:id)]//tei:pb[not(@sameAs or @corresp)]
        )
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
            'chars_count': $charsAllCount,
            'tokens_count': $tokensAllCount,
            'wordforms_count': map {'all': count($wordsAll)},
            'types_count': map {'all': $typesAllCount},
            'normalizations_count': map {'abbr': $resolvedAbbrCount, 'sic': $resolvedSicCount},
            'mf_lemmata': [subsequence($mfLemmata,1,15)],
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

(:
~ Returns the mode for displaying stats as a verbose string.
:)
declare function stats:mode($wid as xs:string?, $lid as xs:string?) as xs:string {
    if (not($wid or $lid)) then
        'all' (: show whole corpus with most frequent lemmata :)
    else if ($wid and not($lid)) then
        'work' (: show single text with most frequent lemmata :)
    else if (not($wid) and $lid) then
        'lemma' (: show single lemma across complete corpus :)
    else
        'work-lemma' (: show single lemma in single work :)
};


(:
~ Loads a (limited) amount of lemmata from a sal:lemmata list.
:)
declare function stats:loadListOfLemmata($node as node(), $model as map(*)) as map(*) {
    let $lemmaNodes := doc($config:data-root || "/lemmata-97.xml")//sal:lemma[@type='term'][position() le $config:stats-limit]
    return 
        map { 'listOfLemmata' := $lemmaNodes }
};

(:
~ Returns the number of lemmata loaded via stats:loadListOfLemmata().
:)
declare function stats:lemmaCount($node as node(), $model as map (*), $lang as xs:string?) {
    <span>{string(count($model('listOfLemmata')))}</span>
};


(: All: Number of occurrences / in number of different works :)
declare %templates:wrap
        %templates:default("wid", "W0013")
    function stats:singleLemmaStats($node as node(), $model as map (*), $wid as xs:string?, $lang as xs:string?) {

    let $currentLemma := $model('currentLemma')
(:    let $currentLemmaHTML   := replace(replace(replace(translate($currentLemma, ' ', '+'), '|', '&#124;'), '(', '&#40;'), ')', '&#41;'):)
    let $currentSearch := sphinx:search($node, $model, $currentLemma, 'corpus-nogroup', 0, 200) (: offset=0, limit=200 (not more than 200 matches are returned) :)
    let $currentOccurrencesCount := 
        if (count($currentSearch("results")//terms) = 1) then
            $currentSearch("results")//terms/hits/text()
        else
            sum($currentSearch("results")//terms/hits/text())

    let $currentSectionsCount := xs:int($currentSearch("results")//*:totalResults) (: TODO: are sections (snippets, really) a helpful information here? :)
    let $currentWorksCount := count(distinct-values($currentSearch("results")//item/work/text()))
    let $distribution := 
        <span title="({if ($currentOccurrencesCount) then 'number of occurrences/' else ()}number of sections containing the occurrences/number of works containing the sections)">
            {concat((if ($currentOccurrencesCount) then concat($currentOccurrencesCount, '/') else ()), $currentSectionsCount, '/', $currentWorksCount)}
        </span>
    let $cooccurrences := 
        if ($currentSectionsCount gt 0) then
            for $secondLemmaRaw in $model('listOfLemmata')
                 let $secondLemma           := $secondLemmaRaw
        (:                                     let $secondLemmaHTML     := replace(replace(replace(translate($secondLemma, ' ', '+'), '|', '&#124;'), '(', '&#40;'), ')', '&#41;'):)
                 let $secondSearch          := sphinx:search($node, $model, concat('(', $currentLemma, ') (', $secondLemma, ')'), 'corpus-nogroup', 0, 20)
                 let $secondSectionsCount   := xs:int($secondSearch("results")//*:totalResults)
                 let $secondWorksCount      := count(distinct-values($secondSearch("results")//item/work/text()))
                 where (($secondSectionsCount gt 0) and ($secondLemma ne $currentLemma))
                 order by $secondSectionsCount descending
                 return <a href='search.html?field=corpus&amp;q={encode-for-uri(concat('(', $currentLemma, ') (', $secondLemma, ')'))}&amp;action=Search'><sal:secondLemma lemma="{$secondLemma}" count="{$secondSectionsCount}">{$secondLemma}</sal:secondLemma> <span title="(number of sections/number of works containing the sections)">({$secondSectionsCount}/{$secondWorksCount})</span></a>
        else ()


(:    let $intraWorkDistribution := :)
(:                                href="#details_{translate(replace($currentLemma, ' | ', '|'), ' ', '+')}":)
    let $detailsLink :=  
        <a  class="toggleDetails"
            data-target="#details_{translate(replace($currentLemma, ' | ', '|'), ' ', '+')}"
            data-toggle="collapse">Frequenz von '{$currentLemma}' in W0013 <i class="fa fa-chevron-down"aria-hidden="true"></i>
        </a>
    let $detailsHTML :=  
        <span>
            {$detailsLink}<br/>
            <iframe  style='width: 80%; height: 300px'
                     src='//voyant-tools.org/tool/Trends/?stopList=keywords-1e40893403831dbd0a5ce8b94b7da6f7&amp;withDistributions=raw&amp;bins=30&amp;query={encode-for-uri(replace($currentLemma, ' | ', ' '))}&amp;docIndex=0&amp;mode=document&amp;corpus=c0c28e98246c4e145700560a15e4fd53'
                     id="details_{translate(replace($currentLemma, ' | ', '|'), ' ', '+')}"
                     class="resultsDetails"><!-- collapse -->
            </iframe> <!-- &amp;withDistributions=raw -->
        </span>


    return  
        <sal:stats><p>
            <b><a href="search.html?field=everything&amp;q={encode-for-uri($currentLemma)}&amp;action=Search">
                <sal:leadingLemma>{$currentLemma}</sal:leadingLemma>
               </a>
               {$distribution}: </b>
            {for $item in $cooccurrences where ($item/position() le count($model('listOfLemmata'))) return <span>{$item}; </span>}
            <br/>
            {$detailsHTML}
        </p></sal:stats>
};


(: ####++++---- HTML FUNCTIONS ----++++#### :)

declare function stats:HTMLtitle($node as node(), $model as map (*), $wid as xs:string?, $lid as xs:string?, $lang as xs:string?) as xs:string? {
    ()
};

declare function stats:HTMLhead($node as node(), $model as map (*), $wid as xs:string?, $lid as xs:string?, $lang as xs:string?) as element(h3)? {
    let $mode := stats:mode($wid, $lid)
    return
        switch($mode)
            case 'all' return ()
            case 'work' return ()
            case 'lemma' return ()
            case 'work-lemma' return ()
            default return ()
};

declare function stats:HTMLbody($node as node(), $model as map (*), $wid as xs:string?, $lid as xs:string?, $lang as xs:string?) as element(div)? {
    let $mode := stats:mode($wid, $lid)
    return
        switch($mode)
            case 'all' return ()
            case 'work' return ()
            case 'lemma' return ()
            case 'work-lemma' return ()
            default return ()
};

(:
TODO: 
    - in voyant ("query" param), state all forms/conjugations of the lemma that are also stated in Sphinx' index (otherwise, voyant shows
    a different amount of occurences than Sphinx...)
    - enhance stopword lists (especially the Spanish list is lacking many forms)
:)
