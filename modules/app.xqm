xquery version "3.1";


(: ####++++----

    "Workhorse" module of the app, providing large parts of the content-related logic (such
    as functionality for displaying work/author/lemma overviews, catalogue records, working paper records, etc).

 ----++++#### :)


module namespace app         = "https://www.salamanca.school/xquery/app";

declare namespace exist      = "http://exist.sourceforge.net/NS/exist";
declare namespace map        = "http://www.w3.org/2005/xpath-functions/map";
declare namespace opensearch = "http://a9.com/-/spec/opensearch/1.1/";
declare namespace output     = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf        = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace sal        = "http://salamanca.adwmainz.de";
declare namespace session    = "http://exist-db.org/xquery/session";
declare namespace srw        = "http://www.loc.gov/zing/srw/";
declare namespace tei        = "http://www.tei-c.org/ns/1.0";
declare namespace transform  = "http://exist-db.org/xquery/transform";
declare namespace util       = "http://exist-db.org/xquery/util";
declare namespace xhtml      = "http://www.w3.org/1999/xhtml";
declare namespace xi         = "http://www.w3.org/2001/XInclude";
declare namespace xmldb      = "http://exist-db.org/xquery/xmldb";

import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace functx      = "http://www.functx.com";
import module namespace http        = "http://expath.org/ns/http-client";
import module namespace request     = "http://exist-db.org/xquery/request";
import module namespace templates   = "http://exist-db.org/xquery/html-templating";
import module namespace lib         = "http://exist-db.org/xquery/html-templating/lib";

import module namespace config      = "https://www.salamanca.school/xquery/config"           at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace i18n        = "http://exist-db.org/xquery/i18n"                      at "xmldb:exist:///db/apps/salamanca/modules/i18n.xqm";
import module namespace render-app  = "https://www.salamanca.school/xquery/render-app"       at "xmldb:exist:///db/apps/salamanca/modules/render-app.xqm";
import module namespace sphinx      = "https://www.salamanca.school/xquery/sphinx"           at "xmldb:exist:///db/apps/salamanca/modules/sphinx.xqm";
import module namespace iiif        = "https://www.salamanca.school/xquery/iiif"             at "xmldb:exist:///db/apps/salamanca/modules/iiif.xqm";
import module namespace sutil       = "https://www.salamanca.school/xquery/sutil"            at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";

(: declare option output:method            "html5";     :)
(: declare option output:media-type        "text/html"; :)
(: declare option output:expand-xincludes  "yes";       :)
(: declare option output:highlight-matches "both";      :)

(: ============ Helper functions ================= 
 :
 : - format a persName element, depending on the presence of forename/surname sub-elements
 : - resolve Names with online authority files
 : - dummy test function
 :)
 

(: Concatenates name(s): forename surname:)
declare function app:rotateFormatName($persName as element(tei:persName)*) as xs:string? {
    let $return-string := for $pers in $persName
                                return
                                        if ($pers/tei:surname and $pers/tei:forename) then
                                            normalize-space(concat(string-join($pers/tei:forename, ' '), ' ', string-join($pers/tei:nameLink, ' '), ' ', string-join($pers/tei:surname, ' '), if ($pers/tei:addName) then ($config:nbsp || '<' || string-join($pers/tei:addName, ' ') || '>') else ()))
                                        else if ($pers) then
                                            normalize-space(xs:string($pers))
                                        else 
                                            normalize-space($pers/text())
    return (string-join($return-string, ' &amp; '))
};

declare function app:resolvePersname($persName as element()*) {
    if ($persName/@key)
        then string($persName/@key)
    else if (contains($persName/@ref, 'cerl:')) then
        let $url := "http://sru.cerl.org/thesaurus?version=1.1&amp;operation=searchRetrieve&amp;query=identifier=" || tokenize(tokenize($persName/@ref, 'cerl:')[2], ' ')[1]
        let $resp := <resp>{http:send-request(<http:request href="{$url}" method="get"/>)}</resp>
        let $cerl := $resp//srw:searchRetrieveResponse/srw:records/srw:record[1]/srw:recordData/*:record/*:info/*:display/string()
        return 
            if ($cerl) then 
                $cerl
            else if ($persName/@key) then 
                string($persName/@key)
            else sutil:formatName($persName)
    else sutil:formatName($persName)
};

(: inactive: :)
(:declare function app:resolveURI($string as xs:string*) {
    let $tei2htmlXslt   := doc($config:app-root || '/resources/xsl/extract_elements.xsl')
    for $id in $string
        let $doc := <div><a xml:id="{$id}" ref="#{id}">dummy</a></div>
        let $xsl-parameters :=  <parameters>
                        <param name="targetNode" value="{$id}" />
                        <param name="targetWork" value="" />
                        <param name="mode"       value="url" />
                    </parameters>
                    return xs:string(transform:transform($doc, $tei2htmlXslt, $xsl-parameters))
};:)


declare function app:workCount($node as node(), $model as map (*), $lang as xs:string?) {
    count($model("listOfWorks"))
};

(: ============ End helper functions ================= :)



(: ============ List functions =================
 : create lists, 
 : load datasets,
 : with javascript and without javascript function
 : order: datasets for js support: authors, lemmata and works (in alphabetical order)
 : then: for simple output (without js): authors, lemmata, working papers, works (in alphabetical order)
 :)

(: Authors with js facets:)
(:
declare function app:switchOrder ($node as node(), $model as map (*), $lang as xs:string?) {
let $output := <i18n:text key="order">Orden</i18n:text>
    return
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "en")
};
declare function app:switchDeath ($node as node(), $model as map (*), $lang as xs:string?) {
let $output := <i18n:text key="death">Todesdatum</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "en")
};
declare function app:switchDiscipline ($node as node(), $model as map (*), $lang as xs:string?) {
let $output := <i18n:text key="discipline">Disziplinenzugehörigkeit</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "en")
};
declare function app:switchPlace ($node as node(), $model as map (*), $lang as xs:string?) {
let $output := <i18n:text key="place">Wirkort</i18n:text>
    return 
        i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "en")
};
:)
declare function app:AUTfinalFacets ($node as node(), $model as map (*), $lang as xs:string?) {
    for $item in collection($config:tei-authors-root)//tei:TEI[.//tei:text/@type eq "author_article"]//tei:listPerson/tei:person[1]
        let $aid            :=  xs:string($item/ancestor::tei:TEI/@xml:id)
        let $authorUrl      :=  'author.html?aid=' || $aid
        let $status         :=  xs:string($item/ancestor-or-self::tei:TEI//tei:revisionDesc/@status)
        let $name           :=  sutil:formatName($item/tei:persName[1])
        let $sortName       :=  sutil:strip-diacritics($item//tei:persName[1]/tei:surname)
        let $firstChar      :=  substring($sortName, 1, 1)
        let $nameFacet      :=       if ($firstChar = ('A','B','C','D','E','F')) then 'A - F'
                                else if ($firstChar = ('G','H','I','J','K','L')) then 'G - L'
                                else if ($firstChar = ('M','N','O','P','Q','R')) then 'M - R'
                                else                                                  'S - Z'
        let $birth          :=  if (contains($item/tei:birth/tei:date[1]/@when, '-')) then
                                    substring-before($item/tei:birth/tei:date[1]/@when, '-')
                                else
                                    replace(number($item/tei:birth/tei:date[1]/@when), 'NaN', '?')
        let $death          :=  if (contains($item/tei:death/tei:date[1]/@when, '-')) then
                                    substring-before($item/tei:death/tei:date[1]/@when, '-')
                                else
                                    replace(number($item/tei:death/tei:date[1]/@when), 'NaN', '?')
        let $deathFacet     :=       if ($death < "1501") then '1501-1550'
                                else if ($death < "1551") then '1501-1550'
                                else if ($death < "1601") then '1551-1600'
                                else if ($death < "1651") then '1601-1650'
                                else if ($death < "1701") then '1651-1700'
                                else if ($death eq "?")  then '?'
                                else ()
        let $orders         :=  for $a in distinct-values($item/tei:affiliation//tei:orgName/@key)
                                    return <i18n:text key="{$a}">{$a}</i18n:text> (: i18n:process(<i18n:text key="{$a}">{$a}</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
        let $ordersString   :=  string-join($orders, ", ")
        let $orderFacet     :=  '"' || string-join($orders, '","') || '"'
(:
        let $orderValueDom  :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq 'dominicans') then
                                        <i18n:text key="dominicans">Dominikaner</i18n:text> else ()
        let $orderValueJes  :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq 'jesuits') then
                                        <i18n:text key="jesuits">Jesuit</i18n:text> else ()
        let $orderValueFra  :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq 'franciscans') then
                                        <i18n:text key="franciscans">Franziskaner</i18n:text> else ()
        let $orderValueAug  :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq 'augustinians') then
                                        <i18n:text key="augustinians">Augustiner</i18n:text> else ()
        let $orderA         :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq'dominicans') then
                                        '"'||<i18n:text key="dominicans">Dominikaner</i18n:text>||'",' else()
        let $orderB         :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq'jesuits') then
                                        '"'||<i18n:text key="jesuits">Jesuiten</i18n:text>||'",' else()
        let $orderC         :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq'franciscans') then
                                        '"'||<i18n:text key="franciscans">Franziskaner</i18n:text>||'",' else()
        let $orderD         :=  for $a in distinct-values($item//tei:affiliation//tei:orgName/@key)
                                    return if ($a eq'augustinians') then
                                        '"'||<i18n:text key="augustinians">Dominikaner</i18n:text>||'",' else()                   
        let $orderFacet     :=  ($orderA || $orderB || $orderC || $orderD)
:)
        let $disciplines    :=  for $a in distinct-values($item/tei:education/@key)
                                    return <i18n:text key="{$a}">{$a}</i18n:text> (: i18n:process(<i18n:text key="{$a}">{$a}</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
        let $disciplinesString := string-join($disciplines, ", ")
        let $disciplineFacet :=  '"' || string-join($disciplines, '","') || '"'
(:
        let $philosoph      :=  for $a in distinct-values($item//tei:occupation/@key)
                                    return if ($a eq 'philosoph') then
                                        <i18n:text key="philosoph">Philosoph</i18n:text>
                                    else ()
        let $theologian     :=  for $a in distinct-values($item//tei:occupation/@key) return if ($a eq 'theologian') then  <i18n:text key="theologian">Theologe</i18n:text> else ()
        let $orderPhil      :=  for $a in distinct-values($item//tei:occupation/@key) return   
                                    if ($a eq 'philosoph') then'"'||<i18n:text key="philosoph">Philosoph</i18n:text> ||'",' else()
        let $orderTheol     :=  for $a in distinct-values($item//tei:occupation/@key) return   
                                    if ($a eq 'theologian') then'"'||<i18n:text key="theologian">Theologe</i18n:text>||'",' else()    
        let $occuFacet      :=  ($orderPhil||$orderTheol)
:) 
        let $places         :=  for $b in distinct-values(for $a in ($item//tei:placeName) order by string($a/@key) collation "?lang=es" return
                                    let $placeName := if ($a/@key) then string($a/@key) else $a/text() 
                                    return (: if ($a//(ancestor::tei:occupation | ancestor::tei:affiliation | ancestor::tei:education )/@from) then
                                             $placeName || ': ' || substring-before($a//(ancestor::tei:occupation | ancestor::tei:affiliation | ancestor::tei:education )/@from, '-') || '-' || substring-before($a//(ancestor::tei:occupation | ancestor::tei:affiliation | ancestor::tei:education )/@to, '-')
                                           else :)
                                             $placeName) return $b
        let $placesString   :=  string-join($places, ", ")
        let $placeFacet     :=  '"' || string-join($places, '","') || '"'
        let $output :=
                   '&#123;'
                || '"authorUrl":'        || '"' || $authorUrl         || '",'
                || '"name":'             || '"' || $name              || '",' 
                || '"status":'           || '"' || $status            || '",'
                || '"sortName":'         || '"' || $sortName          || '",'        (:default sorting:)
                || '"nameFacet":'        || '"' || $nameFacet         || '",'        (:facet I:)
                || '"birth":'            || '"' || $birth             || '",' 
                || (if ($death) then             '"death":'            || '"' || $death             || '",' 
                                              || '"deathFacet":'       || '"' || $deathFacet        || '",'        (:facet II:)
                    else ())
                || (if ($ordersString) then      '"orders":'           || '"' || $ordersString      || '",'
                                              || '"orderFacet":'       || '[' || $orderFacet        || '],'        (:facet III:)
                    else ())
                || (if ($disciplinesString) then '"disciplines":'      || '"' || $disciplinesString || '",'
                                              || '"disciplineFacet":'  || '[' || $disciplineFacet   || '],'        (:facet IV:) 
                    else ())
                || (if ($placesString) then      '"places":'           || '"' || $placesString      || '",'
                                              || '"placeFacet":'       || '[' || $placeFacet        || '],'        (:facet V:)
                    else ())

                || '&#125;'  || ','
        return $output
};


(: ==== LEMMATA-SECTION (with js) ==== :)
(: not in use :)
(:declare function app:switchName ($node as node(), $model as map (*), $lang as xs:string?) {
let $output := <i18n:text key="lemmata">Lemma</i18n:text>
    return 
        i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};:)

declare function app:LEMfinalFacets ($node as node(), $model as map (*), $lang as xs:string?) {
    for $item in (collection($config:tei-lemmata-root)//tei:TEI[.//tei:text/@type eq "lemma_article"])
        let $title          :=  $item//tei:titleStmt/tei:title[@type='short']
        let $status         :=  $item//tei:revisionDesc/@status/string()
        let $firstChar      :=  substring($title, 1, 1)
        let $titleFacet     :=       if ($firstChar = ('A','B','C','D','E','F')) then 'A - F'
                                else if ($firstChar = ('G','H','I','J','K','L')) then 'G - L'
                                else if ($firstChar = ('M','N','O','P','Q','R')) then 'M - R'
                                else                                                  'S - Z'
        let $author         :=  string-join(for $coauthor in $item//tei:titleStmt/tei:author/tei:persName return app:rotateFormatName($coauthor), ', ') 
        let $sortName       :=  $item//tei:titleStmt/tei:author[1]//tei:surname
        let $firstCharAut   :=  substring($item//tei:titleStmt/tei:author[1]//tei:surname, 1, 1)
        let $authorFacet   :=        if ($firstCharAut = ('A','B','C','D','E','F')) then 'A - F'
                                else if ($firstCharAut = ('G','H','I','J','K','L')) then 'G - L'
                                else if ($firstCharAut = ('M','N','O','P','Q','R')) then 'M - R'
                                else                                                     'S - Z'
        (:let $aid          :=  xs:string($item/@xml:id):)
        let $getLemmaId     :=  $item/@xml:id
        let $lemmaRefString :=  'lemma.html?lid=' || $getLemmaId
        return
                '&#123;' 
                || '"title":'                    || '"'|| $title          || '",'     (:default sorting:)
                || '"titleFacet":'               || '"'|| $titleFacet     || '",' (:facet I:)
                || '"status":'                   || '"'|| $status         || '",'
                || '"author":'                   || '"'|| $author         || '",'
                || '"sortName":'                 || '"'|| $sortName       || '",'     (:second sorting:)
                || '"authorFacet":'              || '"'|| $authorFacet    || '",' (:facet II:)
                || '"lemmaRefString":'           || '"'|| $lemmaRefString || '",'
                || '&#125;' || ','
};


(: ==== WORKS-SECTION (with js) ====  :)
declare function app:switchYear ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="year">Jahr</i18n:text>
        return 
            $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};
declare function app:switchPrintingPlace ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="printingPlace">Druckort</i18n:text>
        return 
            $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};
declare function app:switchLanguage ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="lang">Sprache</i18n:text>
        return 
            $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};
declare function app:switchAuthor($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="author">Autor</i18n:text>
        return 
            $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};
declare function app:switchTitle($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="title">Titel</i18n:text>
        return 
            $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};
declare function app:switchAvailability ($node as node(), $model as map (*), $lang as xs:string?) {
    let $output := <i18n:text key="availability">Availability</i18n:text>
        return 
            $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};

declare function app:WRKfinalFacets ($node as node(), $model as map (*), $lang as xs:string?) as array(*) {
    let $debug := if ($config:debug = ("trace")) then console:log("[APP] Building finalFacets (Js) for " || $lang || "...") else ()
    let $output :=
        for $item in (collection($config:tei-works-root)//tei:teiHeader[parent::tei:TEI//tei:text/@type = ("work_monograph", "work_multivolume")])
            let $wid            :=  $item/parent::tei:TEI/@xml:id
            let $title          :=  $item/tei:fileDesc/tei:titleStmt/tei:title[@type = 'short']
            let $status         :=  $item/ancestor-or-self::tei:TEI//tei:revisionDesc/@status
            let $WIPstatus      :=  
                if ($item/ancestor-or-self::tei:TEI//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched', 
                                           'g_enriched_approved',
                                           'h_revised'
                                         )) then "yes"
                else "no"
            let $wrkLink        :=  $config:idserver || '/texts/' || $wid
    
            let $name           :=  sutil:formatName($item//tei:titleStmt/tei:author[1]/tei:persName)
            let $sortName       :=  string-join(for $a in $item/tei:fileDesc/tei:titleStmt/tei:author/tei:persName/tei:surname return sutil:strip-diacritics(lower-case($a)), " &amp; ")
 (:lower-casing for equal sorting:)
            let $firstChar      :=  upper-case(substring($item//tei:titleStmt/tei:author[1]//tei:surname[1], 1, 1))
            let $nameFacet      :=       
                     if ($firstChar = ('A','B','C','D','E','F')) then 'A - F'
                else if ($firstChar = ('G','H','I','J','K','L')) then 'G - L'
                else if ($firstChar = ('M','N','O','P','Q','R')) then 'M - R'
                else                                                  'S - Z'
(: Change 2023-05-25 Andreas Wagner
   With the new infrastructure, the catalogue view is at URLs like:
       https://id.test.salamanca.school/texts/W0095?mode=details
            let $workDetails    :=  'workdetails.html?wid=' ||  $wid
:)          let $typeWork :=   if ($item/ancestor-or-self::tei:TEI//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched'
                                          )) then "Facsimiles"
else if ($item/ancestor-or-self::tei:TEI//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched', 
                                           'g_enriched_approved',
                                           'h_revised'
                                          ) and contains($item//tei:encodingDesc/tei:editorialDecl/tei:p/@xml:id, 'AEW'))  then "Automatically Edited Work"
                            else if ($item/ancestor-or-self::tei:TEI//tei:revisionDesc/@status =
                                         ( 'a_raw',
                                           'b_cleared',
                                           'c_hyph_proposed',
                                           'd_hyph_approved',
                                           'e_emended_unenriched',
                                           'f_enriched', 
                                           'g_enriched_approved',
                                           'h_revised'
                                          ) and contains($item//tei:encodingDesc/tei:editorialDecl/tei:p/@xml:id, 'RW'))  then "Reference Work"
else 'Edited Work'
            let $workDetails    :=  $config:idserver || '/texts/' || $wid || '?mode=details'
            let $DetailsInfo    :=  i18n:process(<i18n:text key="details">Katalogeintrag</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en")
    
            let $workImages     :=  'viewer-standalone.html?wid=' ||  $wid
            let $FacsInfo       :=  i18n:process(<i18n:text key="facsimiles">Bildansicht</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en")
    
            let $printingPlace  :=  
                if ($item//tei:pubPlace[@role = 'thisEd']) then $item//tei:pubPlace[@role = 'thisEd']
                else $item//tei:pubPlace[@role = 'firstEd']
            let $placeFirstChar :=  substring($printingPlace/@key, 1, 1)
            let $facetPlace     :=       
                     if ($placeFirstChar = ('A','B','C','D','E','F')) then 'A - F'
                else if ($placeFirstChar = ('G','H','I','J','K','L')) then 'G - L'
                else if ($placeFirstChar = ('M','N','O','P','Q','R')) then 'M - R'
                else                                                       'S - Z'
            let $date           :=  
                if ($item//tei:date[@type = 'thisEd']) then xs:integer($item//tei:date[@type = 'thisEd'][1]/@when)
                else xs:integer($item//tei:date[@type = 'firstEd'][1]/@when)
            let $datefacet      :=       
                     if ($date < 1501) then '1501-1550'
                else if ($date < 1551) then '1501-1550'
                else if ($date < 1601) then '1551-1600'
                else if ($date < 1651) then '1601-1650'
                else if ($date < 1701) then '1651-1700'
                else                        '??' 
            let $printer    := 
                if ($item//tei:sourceDesc//tei:publisher[@n="thisEd"]) then 
                     ': ' || $item//tei:sourceDesc//tei:publisher[@n="thisEd"][1]/tei:persName[1]/tei:surname
                else ': ' || $item//tei:sourceDesc//tei:publisher[@n="firstEd"][1]/tei:persName[1]/tei:surname
    
            let $language       :=
                i18n:process(if ($item/parent::tei:TEI//tei:text/@xml:lang = 'la') then <i18n:text key="latin">Latein</i18n:text>
                                                                                   else <i18n:text key="spanish">Spanisch</i18n:text>
                            , $lang, "/db/apps/salamanca/data/i18n", "en")
                let $facetAvailability :=
                i18n:process(if (($WIPstatus eq 'yes')) then <i18n:text key="facsimiles">Facsimiles</i18n:text>
                                                      else if (($WIPstatus eq 'no') and contains($item//tei:encodingDesc/tei:editorialDecl/tei:p/@xml:id, 'AEW')) then  <i18n:text key="AEW">Automatically Edited Work</i18n:text> 
  else if (($WIPstatus eq 'no') and contains($item//tei:encodingDesc/tei:editorialDecl/tei:p/@xml:id, 'RW')) then  <i18n:text key="referenceWork">Reference Work</i18n:text> 
else <i18n:text key="fullTextAvailable">Editions</i18n:text>  , $lang, "/db/apps/salamanca/data/i18n", "en")
            let $completeWork   :=  $item/parent::tei:TEI//tei:text[@xml:id="completeWork"]
            let $volIcon        :=  if ($completeWork/@type='work_multivolume') then 'icon-text' else ()
            let $volLabel       :=  
                if ($completeWork/@type='work_multivolume') then
                    <span>{i18n:process(<i18n:text key="volumes">Bände</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en") || ':' || $config:nbsp || $config:nbsp}</span> 
                else ()
            let $volumesString  :=  
                for $volume at $index in util:expand($completeWork)//tei:text[@type="work_volume"]
                    let $volId      := xs:string($volume/@xml:id)
                    let $volIdShort := $volume/@n
                    let $volFrag    := sutil:getFragmentID($wid, $volId)
                    let $volLink    := 
                        if (sutil:WRKisPublished($wid || '_' || $volId)) then $config:idserver || '/texts/' || $wid || ":vol" || $volIdShort
                        (: existence of link serves as indicator for single volumes' publication status (whether published or not) in works list :)
                        else ()
                    let $volContent := $volIdShort||'&#xA0;&#xA0;'
                    return '"vol' || $index || '":' || '"' || $volLink || '","vol' || $index || 'Cont":'|| '"' ||$volContent ||'",'
            let $volumesMaps  :=  map:merge ( for $volume at $index in util:expand($completeWork)//tei:text[@type="work_volume"]
                                                  let $volId      := xs:string($volume/@xml:id)
                                                  let $volIdShort := $volume/@n
                                                  let $volFrag    := sutil:getFragmentID($wid, $volId)
                                                  let $volLink    := 
                                                      if (sutil:WRKisPublished($wid || '_' || $volId)) then $config:idserver || '/texts/' || $wid || ":vol" || $volIdShort
                                                      (: existence of link serves as indicator for single volumes' publication status (whether published or not) in works list :)
                                                      else ()
                                                  let $volContent := $volIdShort||'&#xA0;&#xA0;'
                                                  return map  { concat("vol", $index) : $volLink,
                                                                concat("vol", $index, "Cont") : $volContent
                                                              }
                                                )
            return map:merge( ( map {  "title" :               xs:string($title),
                                       "status" :              xs:string($status),
                                       "WIPstatus" :           $WIPstatus,
                                       "monoMultiUrl" :        $wrkLink,
                                       "workdetails" :         $workDetails,
                                       "type":                 $typeWork,
                                       "titAttrib" :           $DetailsInfo,
                                       "workImages" :          $workImages,
                                       "facsAttrib" :          $FacsInfo,
                                       "printer" :             xs:string($printer),
                                       "name" :                $name,
                                       "sortName" :            $sortName,
                                       "nameFacet" :           $nameFacet,
                                       "date" :                $date,  
                                       "chronology" :          $datefacet,
                                       "textLanguage" :        $language,
                                       "printingPlace" :       xs:string($printingPlace),
                                       "facetPlace" :          $facetPlace,
                                       "facetAvailability" :   $facetAvailability,
                                       "volLabel" :            $volLabel
                                    },
                                $volumesMaps
                              ) )

(:            let $output :=
                   '&#123;'
                || '"title":'         || '"' || $title          || '",'
                || '"status":'        || '"' || $status         || '",'
                || '"WIPstatus":'     || '"' || $WIPstatus      || '",'
                || '"monoMultiUrl":'  || '"' || $wrkLink        || '",'
                || '"workdetails":'   || '"' || $workDetails    || '",'
                || '"titAttrib":'     || '"' || $DetailsInfo    || '",'
                || '"workImages":'    || '"' || $workImages     || '",'
                || '"facsAttrib":'    || '"' || $FacsInfo       || '",'
                || '"printer":'       || '"' || $printer        || '",'
                || '"name":'          || '"' || $name           || '",'
                || '"sortName":'      || '"' || $sortName       || '",'     (\:default sorting:\)
                || '"nameFacet":'     || '"' || $nameFacet      || '",'     (\:facet I:\)
                || '"date":'          || '"' || $date           || '",'  
                || '"chronology":'    || '"' || $datefacet      || '",'     (\:facet II:\)
                || '"textLanguage":'  || '"' || $language       || '",'     (\:facet III:\)
                || '"printingPlace":' || '"' || $printingPlace  || '",'
                || '"facetPlace":'    || '"' || $facetPlace     || '",'     (\:facet IV:\)
                || '"facetAvailability":' || '"' || $facetAvailability || '",'
    (\:                              ||'"sourceUrlAll":'   || '"' || $wid            || '",' :\)
                || '"volLabel":'      || '"' || $volLabel       || '",'
                || string-join($volumesString, '')
                || '&#125;' || ','
:)    
    let $dbg := if ($config:debug = ("trace")) then console:log("[APP] app:WRKfinalFacets about to return: " || serialize(array { $output }, map{"method":"text"})) else ()
    return array { $output }
};

declare function app:loadWRKfacets ($node as node(), $model as map (*), $lang as xs:string?) {
 if ($lang = 'de') then
    serialize(json-doc($config:html-root || "/" || 'works_de.json'), map {"method":"json", "media-type":"text/plain"})
 else  if ($lang = 'en') then
    serialize(json-doc($config:html-root || "/" || 'works_en.json'), map {"method":"json", "media-type":"text/plain"})
 else
    serialize(json-doc($config:html-root || "/" || 'works_es.json'), map {"method":"json", "media-type":"text/plain"})
};


(:  ==== AUTHORS-LIST (no js) ====  :)
declare %templates:wrap  
    function app:sortAUT ($node as node(), $model as map(*), $lang as xs:string?)  {
let $output := 
        <span>&#xA0;&#xA0;&#xA0;<span class="lead"><span class="glyphicon glyphicon-sort-by-alphabet" aria-hidden="true"></span> <i18n:text key="sort">Sortierung</i18n:text></span>
            <ul class="list-unstyled">
                 <li><a href="{('authors.html?sort=surname')}" role="button" class="btn btn-link"><i18n:text key="surname">Nachname</i18n:text></a></li>
                 <li><a href="{('authors.html?sort=order')}" role="button" class="btn btn-link"><i18n:text key="order">Orden</i18n:text></a></li>
                 <li><a href="{('authors.html?sort=death')}" role="button" class="btn btn-link"><i18n:text key="death">Todesdatum</i18n:text></a></li>
            </ul>
        </span>
            return 
                $output
                (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
};        

declare  %templates:wrap
    function app:countAUTsnoJs($node as node(), $model as map(*)) as xs:integer {
        <span>{count($model('listOfAuthors'))}</span>
};

declare %templates:wrap %templates:default("sort", "surname")
        function app:loadListOfAuthors($node as node(), $model as map(*), $sort as xs:string) as map(*) {
            let $coll := collection($config:tei-authors-root)//tei:TEI[.//tei:text/@type eq "author_article"]
            let $result := 
                switch($sort)
                    case 'surname' return
                        for $item in $coll
                            order by $item//tei:listPerson/tei:person[1]/tei:persName[1]/tei:surname ascending
                            return $item
                    case 'death' return
                        for $item in $coll
                            let $order := substring-before($item//tei:listPerson/tei:person[1]/tei:death/tei:date[1]/@when, '-')
                            order by $order ascending
                            return $item
                    case 'order' return
                        for $item in $coll
                            order by $item//tei:listPerson/tei:person[1]/tei:affiliation[1]/tei:orgName[1]/@key ascending
                            return $item
                    case 'discipline' return
                        for $item in $coll
                            order by $item//tei:listPerson/tei:person[1]/tei:occupation[last()]/@key ascending
                            return $item
                    case 'placesOfAction' return
                        for $item in $coll
                            let $placeName := 
                                if ($item//tei:listPerson/tei:person[1]/(tei:affiliation | tei:occupation | tei:education)//tei:placeName/@key) then
                                    string($item//tei:listPerson/tei:person[1]/(tei:affiliation | tei:occupation | tei:education)//tei:placeName/@key[1])
                                else
                                    $item//tei:listPerson/tei:person[1]/(tei:affiliation | tei:occupation | tei:education)//tei:placeName/text()[1]                    
                            order by $placeName ascending
                            return $item                   
                    default return
                        for $item in $coll
                            return $item
            return 
                map {'listOfAuthors' : $result}
};

declare %private
    function app:AUTnameLink($node as node(), $model as map(*), $lang as xs:string) {
        let $nameLink := 
            <a class="lead" href="{session:encode-url(xs:anyURI('author.html?aid=' || $model('currentAuthor')/@xml:id))}">
                <span class="glyphicon glyphicon-user"></span>
               &#xA0;{sutil:formatName($model('currentAuthor')/tei:persName[1])}
            </a>
        return $nameLink
};

declare %private
    function app:AUTfromTo ($node as node(), $model as map(*)) {
        let $birth  :=  replace(xs:string(number(substring-before($model('currentAuthor')/tei:birth/tei:date[1]/@when, '-'))), 'NaN', '??')
        let $death  :=  replace(xs:string(number(substring-before($model('currentAuthor')/tei:death/tei:date[1]/@when, '-'))), 'NaN', '??')
        return 
            <span>{$birth||' - '||$death}</span>
};

declare %private
    function app:AUTorder ($node as node(), $model as map(*), $lang) {
        let $relOrder  :=  $model('currentAuthor')//tei:affiliation/tei:orgName[1]/@key/string()
        return
            <span><i18n:text key="{$relOrder}">{$relOrder}</i18n:text></span>
            (: <span>{i18n:process(<i18n:text key="{$relOrder}">{$relOrder}</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en")}</span> heute geändert :)
};

declare %private
    function app:AUTdiscipline ($node as node(), $model as map(*), $lang as xs:string) {
        let $relOrder  :=  $model('currentAuthor')//tei:affiliation/tei:orgName[1]/@key/string()
        return
            <span><i18n:text key="{$relOrder}">{$relOrder}</i18n:text></span>
            (: <span>{i18n:process(<i18n:text key="{$relOrder}">{$relOrder}</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en")}</span> heute geändert :)
(:             <span>
               {if     ($relOrder eq 'OP') then <i18n:text key="dominicans">Dominikaner</i18n:text>
               else if ($relOrder eq 'SJ')  then <i18n:text key="jesuits">Jesuit</i18n:text>
               else if ($relOrder eq 'franciscans')  then <i18n:text key="franciscan">Franziskaner</i18n:text>
               else if ($relOrder eq 'augustinians')  then <i18n:text key="augustinians">Augustiner</i18n:text>
               else ()}
            </span>
:)
};


declare %templates:wrap
    function app:AUTmakeList($node as node(), $model as map(*), $lang as xs:string) {
        <div class="col-md-6"> 
            <div class="panel panel-default">
                <div class="panel-body">
                    {app:AUTnameLink($node, $model, $lang), $config:nbsp}<a href="{session:encode-url(xs:anyURI('author.html?aid=' || $model('currentAuthor')/@xml:id/string()))}" title="get information about this author"></a><br/>
                    {app:AUTfromTo($node, $model)}<br/>
                    {app:AUTorder($node, $model, $lang)}<br/>
                    <br/>
                </div>
            </div>
        </div>
};


(:  ==== LEMMATA-LIST (no js) ====  :)
declare %templates:wrap  
    function app:sortLEM ($node as node(), $model as map(*), $lang as xs:string?)  {
        let $output := 
            <span>&#xA0;&#xA0;&#xA0;<span class="lead" ><span class="glyphicon glyphicon-sort-by-alphabet" aria-hidden="true"></span> <i18n:text key="sort">Sortierung</i18n:text></span>
                <ul class="list-unstyled">
                     <li><a href="{('dictionary.html?sort=lemma')}" role="button" class="btn btn-link"><i18n:text key="lemma">Lemma</i18n:text></a></li>
                     <li><a href="{('dictionary.html?sort=author')}" role="button" class="btn btn-link"><i18n:text key="author">Autor</i18n:text></a></li>
                </ul>
            </span>
        return
            $output
            (: i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)                
}; 

declare  %templates:wrap
    function app:countLEMsnoJs($node as node(), $model as map(*)) as xs:integer {
        let $items  :=  (collection($config:tei-lemmata-root)//tei:TEI)//tei:text[@type = 'lemma_article']
        return <span>{count($items)}</span>
};

 declare %templates:wrap %templates:default("sort", "lemma")
        function app:loadDictionary($node as node(), $model as map(*), $sort as xs:string) as map(*) {
            let $coll := (collection($config:tei-lemmata-root)//tei:TEI[.//tei:text/@type eq 'lemma_article'])
            let $result := 
                if ($sort eq 'lemma') then
                    for $item in $coll
                    order by $item//tei:titleStmt/tei:title[@type = 'short'] ascending
                    return $item
                else if ($sort eq 'author') then
                    for $item in $coll
                    order by $item//tei:titleStmt/tei:author[1]/tei:persName/tei:surname ascending
                    return $item
                else() 
            return map { 'listOfLemmata': $result }
};

declare %private
    function app:LEMtitleShortLink($node as node(), $model as map(*), $lang) {
        <a href="{session:encode-url(xs:anyURI('lemma.html?lid=' || $model('currentLemma')/@xml:id))}">
             <span class="lead">
                <span class="glyphicon glyphicon-book" aria-hidden="true"></span>&#xA0;{$model('currentLemma')/tei:teiHeader//tei:titleStmt/tei:title[@type = 'short'] || $config:nbsp}
            </span>
        </a>   
};

declare  %templates:wrap
    function app:LEMauthor($node as node(), $model as map(*)) {
        let $names := for $author in $model('currentLemma')/tei:teiHeader//tei:author
                      return app:rotateFormatName($author/tei:persName)
        return string-join($names, ', ')
};

declare  %templates:wrap
    function app:LEMlist($node as node(), $model as map(*), $lang as xs:string?) {
       <div class="col-md-6"> 
            <div class="panel panel-default">
                <div class="panel-body">
                   {app:LEMtitleShortLink($node, $model, $lang)}<br/>  
                   {app:LEMauthor($node, $model)}<br/>
               </div>
            </div>
        </div>
};


(:  
        ==== WORKING-PAPERS-LIST (no js) ====
:)
declare %templates:wrap
        function app:loadListOfWps($node as node(), $model as map(*)) as map(*) {
            let $result := for $item in collection($config:tei-workingpapers-root)/tei:TEI[.//tei:text/@type eq "working_paper"]
                           order by $item/tei:teiHeader//tei:titleStmt/tei:title[@type='short'] descending
                           return $item
            return map { 'listOfWps': $result }
};

(:  
        ==== WORKS-LIST (no js) ====
:)
(:works with noscript. NOTE: this function is ONLY USED ON THE ADMIN PAGE:)
declare %templates:wrap %templates:default("sort", "surname")
        function app:loadListOfWorks($node as node(), $model as map(*), $sort as xs:string) as map(*) {
            let $coll := (collection($config:tei-works-root)//tei:TEI[.//tei:text/@type = ("work_monograph", "work_multivolume")]/tei:teiHeader)
            let $result := 
                for $item in $coll
                    let $wid := $item/parent::tei:TEI/@xml:id/string()
                    let $author := sutil:formatName($item//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)
                    let $titleShort := $item//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
                    order by $wid ascending
                    return 
                        map {'wid': $wid,
                             'author': $author,
                             'titleShort': $titleShort}
            return map { 'listOfWorks': $result }     
};


(: Deprecated 
    (creates a huge tree overhead - if necessary, adjust it towards more fine-grained collection access (e.g., picking only teiHeaders from collection...)) :)
(:works with noscript. NOTE: this function is ONLY USED ON THE ADMIN PAGE:)
(:declare %templates:wrap %templates:default("sort", "surname")
        function app:loadListOfWorksBak($node as node(), $model as map(*), $sort as xs:string) as map(*) {
            let $coll := (collection($config:tei-works-root)//tei:TEI[.//tei:text/@type = ("work_monograph", "work_multivolume")])
            let $result := 
                            if ($sort eq 'surname') then 
                                for $item in $coll
                                    order by $item//tei:sourceDesc//tei:author[1]//tei:surname ascending
                                    return $item
                             else if ($sort eq 'title') then 
                                 for $item in $coll
                                    order by $item//tei:sourceDesc//tei:monogr/tei:title[@type = 'short'] ascending
                                    return $item
                            else if ($sort eq 'year') then    
                                 for $item in $coll
                                    order by $item//tei:sourceDesc//tei:date[@type = 'firstEd']/@when ascending
                                    return $item
                            else if ($sort eq 'place') then    
                                for $item in $coll
                                    order by $item//tei:sourceDesc//tei:pubPlace[@role = 'firstEd'] ascending
                                    return $item
                             else
                                for $item in $coll
                                    order by $item/@xml:id ascending
                                    return $item
            return map { 'listOfWorks': $result }     
};:)


declare %templates:wrap 
    function app:WRKauthor($node as node(), $model as map(*)) {
         <span>{sutil:formatName($model('currentWorkHeader')//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)}</span>
};

declare %templates:wrap %private function app:WRKpublication($node as node(), $model as map(*)) {
        let $thisEd         :=      $model('currentWorkHeader')//tei:pubPlace[@role = 'thisEd']
        let $firstEd        :=      $model('currentWorkHeader')//tei:pubPlace[@role = 'firstEd']
        let $publisher      :=      if ($thisEd) then $model('currentWorkHeader')//tei:imprint/tei:publisher[@n = 'thisEd']/tei:persName[1]/tei:surname else $model('currentWorkHeader')//tei:imprint/tei:publisher[@n = 'firstEd']/tei:persName[1]/tei:surname
        let $place          :=      if ($thisEd) then $thisEd else $firstEd
        let $year           :=      if ($thisEd) 
                                    then $model('currentWorkHeader')//tei:date[@type = 'thisEd']/@when/string() 
                                    else $model('currentWorkHeader')//tei:date[@type = 'firstEd']/@when/string()
        let $vol            :=      if ($model('currentWorkHeader')//tei:monogr//tei:title[@type = 'volume']) 
                                    then concat(', ', $model('currentWorkHeader')//tei:monogr//tei:title[@type = 'volume']) 
                                    else ()                         
        let $pubDetails     :=  $place || '&#32;'||": " || $publisher || ", " || $year || $vol
        return $pubDetails
};

(: deprecated? :)
(:declare %templates:wrap %private
    function app:WRKlinks($node as node(), $model as map (*), $lang as xs:string?) {
        for $item in util:expand($model('currentWork'))//tei:text[@type="work_multivolume"]
        let $wid            :=  xs:string($item/ancestor::tei:TEI/@xml:id)
        let $completeWork   :=  $item[@xml:id="completeWork"]
        let $volumesString  :=  for $volume(\: at $index:\) in util:expand($completeWork)//tei:text[@type="work_volume"]
            let $volId      := xs:string($volume/@xml:id)
            let $volFrag    := sutil:getFragmentID($wid, $volId)
            let $volLink    :=  'work.html?wid=' || $wid || "&amp;frag=" || $volFrag || "#" || $volId
            let $volContent := $volId || '&#32;&#32;'
            return  	<a href="{$volLink}">{$volId||'&#32;'}</a>
        return $volumesString
};:)
        
declare %templates:wrap  
    function app:sortWRK ($node as node(), $model as map(*), $lang as xs:string?)  {
        let $output := 
            <span>&#xA0;&#xA0;&#xA0;<span class="lead" style="color: #999999;"><span class="glyphicon glyphicon-sort-by-alphabet" aria-hidden="true"></span> <i18n:text key="sort">Sortierung</i18n:text></span>
               <ul class="list-unstyled">
                  <li><a href="{('works.html?sort=surname')}" role="button" class="btn btn-link"><i18n:text key="surname">Nachname</i18n:text></a></li>
                  <li><a href="{('works.html?sort=title')}" role="button" class="btn btn-link"><i18n:text key="title">Titel</i18n:text></a></li>
                  <li><a href="{('works.html?sort=year')}" role="button" class="btn btn-link"><i18n:text key="year">Jahr</i18n:text></a></li>
                  <li ><a href="{('works.html?sort=place')}" role="button" class="btn btn-link"><i18n:text key="place">Ort</i18n:text></a></li>
                </ul>
            </span>
        return
            $output
            (: i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)                
};        

declare  %templates:wrap
    function app:countWRKsnoJs($node as node(), $model as map(*)) as xs:integer {
        let $items  :=  (collection($config:tei-works-root)//tei:TEI)//tei:text[@type = ('work_monograph', 'work_multivolume')]
        return <span>{count($items)}</span>
};

declare function app:WRKsingleVolumeString($wid as xs:string, $volume as element(tei:text)) {
    let $volId      := xs:string($volume/@xml:id)
    let $volFrag    := sutil:getFragmentID($wid, $volId)
    let $volLink    :=  
        if (sutil:WRKisPublished($wid || '_' || $volId)) then 'work.html?wid=' || $wid || "&amp;frag=" || $volFrag || "#" || $volId
        (: existence of link serves as indicator for single volumes' publication status (whether published or not) :)
        else ()
    let $volContent := $volId || '&#32;&#32;'
    return 
        if ($volLink) then <a href="{$volLink}">{$volId||'&#32;'}</a>   
        else <span>{$volId||'&#32;'}</span>
};

declare %templates:wrap function app:WRKcreateListSurname($node as node(), $model as map(*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace")) then console:log("[APP] Building surname-sorted finalFacets (No Js) for " || $lang || "...") else ()
    return  
        for $item in (collection($config:tei-works-root)//tei:TEI)//tei:text[@type = ('work_monograph', 'work_multivolume')]
            let $root       :=  $item/ancestor::tei:TEI
            let $id         :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id ) ))
            let $details    :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id || '?mode=details') ))
            let $title      :=  $root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
            let $author     :=  app:rotateFormatName($root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)
            order by $root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author[1]/tei:persName/tei:surname[1] ascending
                return
                    <div class="col-md-6"> 
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <a class="lead" href="{$id}"><span class="glyphicon glyphicon-file"></span>&#xA0;{$title}</a>
                                <br/>  
                                <span class="lead">{$author}</span>
                                <br/>
                                {
                                let $thisEd         :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'thisEd']
                                let $firstEd        :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'firstEd']
                                let $publisher := 
                                    if ($thisEd) then $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'thisEd']/tei:persName[1]/tei:surname 
                                    else $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'firstEd']/tei:persName[1]/tei:surname
                                let $place          :=      if ($thisEd) then $thisEd else $firstEd
                                let $year           :=      
                                    if ($thisEd) then $root//tei:teiHeader//tei:date[@type = 'thisEd']/@when/string() 
                                    else $root//tei:teiHeader//tei:date[@type = 'firstEd']/@when/string()
                                let $vol            :=      
                                    if ($root/tei:teiHeader//tei:monogr//tei:title[@type = 'volume']) then 
                                        concat(', ', $model('currentWorkHeader')//tei:monogr//tei:title[@type = 'volume']) 
                                    else ()                         
                                let $pubDetails     :=      $place || '&#32;'||": " || $publisher || ", " || $year || $vol
                                return 
                                    $pubDetails
                                }
                                <br/>  
                                {
                                let $wid    := string($root/@xml:id)
                                for $a in (doc($config:tei-works-root || "/" || $wid || ".xml")/tei:TEI//tei:text[@type="work_multivolume"])
                                     let $completeWork   :=  $a[@xml:id="completeWork"]
                                     let $volumesString  :=  
                                        for $volume in util:expand($completeWork)//tei:text[@type="work_volume"] return 
                                            app:WRKsingleVolumeString($wid, $volume)
                                     return  $volumesString
                               }
                                <br/> 
                               <a  href="{$details}"  title="bibliographical details about this book"> <span class="icon-info2 pull-right" style="font-size: 1.3em;"> </span></a>
                           </div>
                        </div>  
                    </div>
};

declare %templates:wrap function app:WRKcreateListTitle($node as node(), $model as map(*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace")) then console:log("[APP] Building title-sorted finalFacets (No Js) for " || $lang || "...") else ()
    return
        for $item in (collection($config:tei-works-root)//tei:TEI)//tei:text[@type = ('work_monograph', 'work_multivolume')]
            let $root       :=  $item/ancestor::tei:TEI
            let $id         :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id ) ))
            let $details    :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id || '?mode=details') ))
            let $title      :=  $root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
            let $author     :=  app:rotateFormatName($root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)
            order by $root/tei:teiHeader//tei:sourceDesc//tei:monogr/tei:title[@type = 'short'] ascending
                return
                    <div class="col-md-6"> 
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <a class="lead" href="{$id}"><span class="glyphicon glyphicon-file"></span>&#xA0;{$title}</a>
                                <br/>  
                                <span class="lead">{$author}</span>
                                <br/>
                                {
                                let $thisEd         :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'thisEd']
                                let $firstEd        :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'firstEd']
                                let $publisher      :=      if ($thisEd) then $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'thisEd']/tei:persName[1]/tei:surname 
                                                            else $root//tei:imprint/tei:publisher[@n = 'firstEd']/tei:persName[1]/tei:surname
                                let $place          :=      if ($thisEd) then $thisEd else $firstEd
                                let $year           :=      if ($thisEd) then $root//tei:teiHeader//tei:date[@type = 'thisEd']/@when/string() 
                                                            else $root//tei:teiHeader//tei:date[@type = 'firstEd']/@when/string()
                                let $vol            :=      if ($root/tei:teiHeader//tei:monogr//tei:title[@type = 'volume']) 
                                                            then concat(', ', $model('currentWorkHeader')//tei:monogr//tei:title[@type = 'volume']) 
                                                            else ()                         
                                let $pubDetails     :=      $place || '&#32;'||": " || $publisher || ", " || $year || $vol
                                return $pubDetails
                                }
                                <br/>  
                                {
                                let $wid    := string($root/@xml:id)
                                for $a in (doc($config:tei-works-root || "/" || $wid || ".xml")/tei:TEI//tei:text[@type="work_multivolume"])
                                     let $completeWork   :=  $a[@xml:id="completeWork"]
                                     let $volumesString  :=  
                                        for $volume in util:expand($completeWork)//tei:text[@type="work_volume"] return
                                            app:WRKsingleVolumeString($wid, $volume)
                                     return  $volumesString
                               }
                                <br/> 
                               <a  href="{$details}"  title="bibliographical details about this book"> <span class="icon-info2 pull-right" style="font-size: 1.3em;"> </span></a>
                           </div>
                        </div>  
                    </div>
};

declare %templates:wrap function app:WRKcreateListYear($node as node(), $model as map(*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace")) then console:log("[APP] Building year-sorted finalFacets (No Js) for " || $lang || "...") else ()
    return
        for $item in (collection($config:tei-works-root)//tei:TEI)//tei:text[@type = ('work_monograph', 'work_multivolume')]
            let $root       :=  $item/ancestor::tei:TEI
            let $id         :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id ) ))
            let $details    :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id || '?mode=details') ))
            let $title      :=  $root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
            let $author     :=  app:rotateFormatName($root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)
            order by $root/tei:teiHeader//tei:sourceDesc//tei:date[@type = 'firstEd']/@when ascending
                return
                    <div class="col-md-6"> 
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <a class="lead" href="{$id}"><span class="glyphicon glyphicon-file"></span>&#xA0;{$title}</a>
                                <br/>  
                                <span class="lead">{$author}</span>
                                <br/>
                                {
                                let $thisEd         :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'thisEd']
                                let $firstEd        :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'firstEd']
                                let $publisher      :=      if ($thisEd) then $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'thisEd']/tei:persName[1]/tei:surname 
                                                            else $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'firstEd']/tei:persName[1]/tei:surname
                                let $place          :=      if ($thisEd) then $thisEd else $firstEd
                                let $year           :=      if ($thisEd) 
                                                            then $root//tei:teiHeader//tei:date[@type = 'thisEd']/@when/string() 
                                                            else $root//tei:teiHeader//tei:date[@type = 'firstEd']/@when/string()
                                let $vol            :=      if ($root/tei:teiHeader//tei:monogr//tei:title[@type = 'volume']) 
                                                            then concat(', ', $model('currentWorkHeader')//tei:monogr//tei:title[@type = 'volume']) 
                                                            else ()                         
                                let $pubDetails     :=      $place || '&#32;'||": " || $publisher || ", " || $year || $vol
                                return $pubDetails
                                }
                                <br/>  
                                {
                                let $wid    := string($root/@xml:id)
                                for $a in (doc($config:tei-works-root || "/" || $wid || ".xml")/tei:TEI//tei:text[@type="work_multivolume"])
                                     let $completeWork   :=  $a[@xml:id="completeWork"]
                                     let $volumesString  :=  
                                        for $volume in util:expand($completeWork)//tei:text[@type="work_volume"] return
                                            app:WRKsingleVolumeString($wid, $volume)
                                     return  $volumesString
                               }
                                <br/> 
                               <a  href="{$details}"  title="bibliographical details about this book"> <span class="icon-info2 pull-right" style="font-size: 1.3em;"> </span></a>
                           </div>
                        </div>  
                    </div>
};

declare %templates:wrap function app:WRKcreateListPlace($node as node(), $model as map(*), $lang as xs:string?) {
    let $debug := if ($config:debug = ("trace")) then console:log("[APP] Building place-sorted finalFacets (No Js) for " || $lang || "...") else ()
    return  
        for $item in (collection($config:tei-works-root)//tei:TEI)//tei:text[@type = ('work_monograph', 'work_multivolume')]
            let $root       :=  $item/ancestor::tei:TEI
            let $id         :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id ) ))
            let $details    :=  (session:encode-url( xs:anyURI( $config:idserver || '/texts/' || $root/@xml:id || '?mode=details') ))
            let $title      :=  $root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
            let $author     :=  app:rotateFormatName($root/tei:teiHeader//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author/tei:persName)
            let $order      :=  if ($root/tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'thisEd']) then $root/tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'thisEd']
                                else $root/tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'firstEd'] 
            order by $order ascending
                return
                    <div class="col-md-6"> 
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <a class="lead" href="{$id}"><span class="glyphicon glyphicon-file"></span>&#xA0;{$title}</a>
                                <br/>  
                                <span class="lead">{$author}</span>
                                <br/>
                                {
                                let $thisEd         :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'thisEd']
                                let $firstEd        :=      $root//tei:teiHeader//tei:sourceDesc//tei:pubPlace[@role = 'firstEd']
                                let $publisher      :=      if ($thisEd) then $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'thisEd']/tei:persName[1]/tei:surname 
                                                            else $root//tei:teiHeader//tei:imprint/tei:publisher[@n = 'firstEd']/tei:persName[1]/tei:surname
                                let $place          :=      if ($thisEd) then $thisEd else $firstEd
                                let $year           :=      if ($thisEd) 
                                                            then $root//tei:teiHeader//tei:sourceDesc//tei:date[@type = 'thisEd']/@when/string() 
                                                            else $root//tei:teiHeader//tei:sourceDesc//tei:date[@type = 'firstEd']/@when/string()
                                let $vol            :=      if ($root/tei:teiHeader//tei:monogr//tei:title[@type = 'volume']) 
                                                            then concat(', ', $model('currentWorkHeader')//tei:monogr//tei:title[@type = 'volume']) 
                                                            else ()                         
                                let $pubDetails     :=      $place || '&#32;'||": " || $publisher || ", " || $year || $vol
                                return $pubDetails
                                }
                                <br/>  
                                {
                                let $wid    := string($root/@xml:id)
                                for $a in (doc($config:tei-works-root || "/" || $wid || ".xml")/tei:TEI//tei:text[@type="work_multivolume"])
                                     let $completeWork   :=  $a[@xml:id="completeWork"]
                                     let $volumesString  :=  
                                        for $volume in util:expand($completeWork)//tei:text[@type="work_volume"] return
                                            app:WRKsingleVolumeString($wid, $volume)  
                                     return  $volumesString
                               }
                                <br/> 
                               <a  href="{$details}"  title="bibliographical details about this book"> <span class="icon-info2 pull-right" style="font-size: 1.3em;"> </span></a>
                           </div>
                        </div>  
                    </div>
};

declare function app:loadWRKsnoJs ($node as node(), $model as map (*), $lang as xs:string?, $sort as xs:string?) {
         if ($sort = 'surname' and $lang ='de') then doc($config:data-root || "/" || 'worksNoJs_de_surname.xml')/sal
    else if ($sort = 'title'   and $lang ='de') then doc($config:data-root || "/" || 'worksNoJs_de_title.xml')/sal
    else if ($sort = 'year'    and $lang ='de') then doc($config:data-root || "/" || 'worksNoJs_de_year.xml')/sal
    else if ($sort = 'place'   and $lang ='de') then doc($config:data-root || "/" || 'worksNoJs_de_place.xml')/sal
    else if ($sort = 'surname' and $lang ='en') then doc($config:data-root || "/" || 'worksNoJs_en_surname.xml')/sal
    else if ($sort = 'title'   and $lang ='en') then doc($config:data-root || "/" || 'worksNoJs_en_title.xml')/sal
    else if ($sort = 'year'    and $lang ='en') then doc($config:data-root || "/" || 'worksNoJs_en_year.xml')/sal
    else if ($sort = 'place'   and $lang ='en') then doc($config:data-root || "/" || 'worksNoJs_en_place.xml')/sal
    else if ($sort = 'surname' and $lang ='es') then doc($config:data-root || "/" || 'worksNoJs_es_surname.xml')/sal
    else if ($sort = 'title'   and $lang ='es') then doc($config:data-root || "/" || 'worksNoJs_es_title.xml')/sal
    else if ($sort = 'year'    and $lang ='es') then doc($config:data-root || "/" || 'worksNoJs_es_year.xml')/sal
    else if ($sort = 'place'   and $lang ='es') then doc($config:data-root || "/" || 'worksNoJs_es_place.xml')/sal
    else if ($lang ='de')                       then doc($config:data-root || "/" || 'worksNoJs_de_surname.xml')/sal
    else if ($lang ='en')                       then doc($config:data-root || "/" || 'worksNoJs_en_surname.xml')/sal
    else if ($lang ='es')                       then doc($config:data-root || "/" || 'worksNoJs_es_surname.xml')/sal
    else()
};

declare %templates:wrap  
    function app:WRKsNotice ($node as node(), $model as map(*), $lang as xs:string?)  {
        let $output := 
            <div style="padding:0.2em;text-align:justify">
                    <i18n:text key="worksNotice1"/>
                    <a href="sources.html"><i18n:text key="worksNotice2"/></a>
                    <i18n:text key="worksNotice3"/>
                    <a href="guidelines.html">
                        <i18n:text key="guidelines">Editionsrichtlinien</i18n:text>
                    </a>.
            </div>
        return
            $output
            (: i18n:process($output, "de", "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)                
};

declare %templates:wrap
    function app:WRKsCorpusDownload ($node as node(), $model as map(*), $lang as xs:string?) {
    let $corpusDownloadField :=
        <div>
            <p><i18n:text key="downloadCorpusTitle">Download the complete corpus</i18n:text>:</p>
            <ul>
                <li>
                    <a href="{$config:idserver || '/texts?format=tei'}"><span class="glyphicon glyphicon-download-alt"/>{' '}<i18n:text key="teiFiles">TEI XML</i18n:text></a>
                </li>
                <li>
                    <a href="{$config:idserver || '/texts?format=txt'}"><span class="glyphicon glyphicon-download-alt"/>{' '}<i18n:text key="txtFiles">Plain text (TXT)</i18n:text></a>
                </li>
            </ul>
        </div>
    return
        $corpusDownloadField
        (: i18n:process($corpusDownloadField, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
};

declare %templates:wrap
    function app:WRKsList ($node as node(), $model as map(*), $lang as xs:string?) {
    let $corpusDownloadField :=
        <div>
            <p><a href="sources.html"><span class="fas fa-th-list" aria-hidden="true"/>{' '}<i18n:text key="listOfSources">List of all sources</i18n:text></a></p>
        </div>
    return
        $corpusDownloadField
        (: i18n:process($corpusDownloadField, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
};

declare %templates:wrap function app:corpusStatsTeaser ($node as node(), $model as map(*), $lang as xs:string?) as element(div)? {
    if (util:binary-doc-available($config:stats-root || '/corpus-stats.json')) then
        let $stats := json-doc($config:stats-root || '/corpus-stats.json')
        let $digiFacs := i18n:largeIntToString(xs:integer($stats('facs_count')?('all')), $lang)
        let $editFacs := i18n:largeIntToString(xs:integer($stats('facs_count')?('full_text')), $lang)
        let $tokens := i18n:largeIntToString(xs:integer($stats('tokens_count')), $lang)
        let $wordforms := i18n:largeIntToString(xs:integer($stats('wordforms_count')), $lang)
        let $out :=
            <div>
                <ul>
                    <li>{$digiFacs || ' '}<i18n:text key="digiFacsLow"/></li>
                    <li>{$editFacs || ' '}<i18n:text key="editFacsLow"/></li>
                    <li>{$tokens || ' '}<i18n:text key="tokensLow"/></li>
                    <li>{$wordforms || ' '}<i18n:text key="wordFormsLow"/></li>
                </ul>
                
            </div>
            (:    <a href="stats.html"><i class="glyphicon glyphicon-stats"></i>{' '}<i18n:text key="addStats">More statistics</i18n:text></a>    :)
        return
            $out
    else ()
};


(: ====================== End  List functions ========================== :)



(: =========== Load single author, lemma, working paper, work (in alphabetical order) ============= :)

(: ====Author==== :)
declare %templates:default("field", "all")
    function app:loadSingleAuthor($node as node(), $model as map(*), $aid as xs:string?){
    let $context  := if ($aid) then
                        util:expand(doc($config:tei-authors-root || "/" || sutil:normalizeId($aid) || ".xml")/tei:TEI)
                     else if ($model("currentAuthor")) then
                        let $aid := $model("currentAuthor")/@xml:id 
                        return ($model("currentAuthor"))
                     else
                        ()
    return map { "currentAuthor": $context }
};

(: TODO: adjust paths here once respective HTML is available: :)
declare %templates:wrap
    function app:AUTloadEntryHtml($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?){
     let $switchType         :=  if (request:get-parameter('aid', '')) then $aid else $lid
     return   doc($config:data-root || "/" || sutil:normalizeId($switchType)||'.html')/div
};
declare %templates:wrap
    function app:AUTloadCitedHtml($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?){
    let $switchType         :=  if (request:get-parameter('aid', '')) then $aid else $lid
    return   doc($config:data-root || "/" || sutil:normalizeId($switchType)||'_cited.html')/div/ul
};
declare %templates:wrap
    function app:AUTloadLemmataHtml($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?){
    let $switchType         :=  if (request:get-parameter('aid', '')) then $aid else $lid
    return   doc($config:data-root || "/" || sutil:normalizeId($switchType)||'_lemmata.html')/div/ul
};
declare %templates:wrap
    function app:AUTloadPersonsHtml($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?){
    let $switchType         :=  if (request:get-parameter('aid', '')) then $aid else $lid
    return   doc($config:data-root || "/" || sutil:normalizeId($switchType)||'_persons.html')/div/ul
};
declare %templates:wrap
    function app:AUTloadPlacesHtml($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?){
    let $switchType         :=  if (request:get-parameter('aid', '')) then $aid else $lid
    return  doc($config:data-root || "/" || sutil:normalizeId($switchType)||'_places.html')/div/ul
};

(: ====Lemma==== :)
declare %templates:default("field", "all")
    function app:loadSingleLemma($node as node(), $model as map(*), $lid as xs:string?) {
    let $context  := if ($lid) then
                        util:expand(doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lid) || ".xml")/tei:TEI)
                     else if ($model("currentLemma")) then
                        let $lid := $model("currentLemma")/@xml:id
                        return ($model("currentLemma"))
                     else
                        ()
    (:let $results-work := if (count($model("results"))>0) then
                            $model("results")
                         else if ($q) then
                            dq:search($context, $model, $wid, $aid, $lid, $q, $field)
                         else :)
    return map { "currentLemma": $context }
};

(: TODO: adjust path once LEM HTML is available :)
declare %templates:wrap function app:LEMloadEntryHtml($node as node(), $model as map(*), $lid as xs:string?){
    doc($config:data-root || "/" || sutil:normalizeId($lid)||'.html')/span
};

declare %public
    function app:displaySingleLemma($node as node(), $model as map(*), $lid as xs:string?, $q as xs:string?) {   
    let $lemma-id    :=  if ($lid) then
                            $lid
                        else
                            $model("currentLemma")/@xml:id
    let $doc        :=  if ($q and $model("results")) then
                            util:expand($model("results")/ancestor::tei:TEI)
                        else
                            util:expand(doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lemma-id) || ".xml")/tei:TEI)
    let $stylesheet := doc(xs:anyURI($config:app-root || "/resources/xsl/reading_view.xsl"))
    let $parameters :=  <parameters>
                            <param name="exist:stop-on-warn" value="yes"/>
                            <param name="exist:stop-on-error" value="yes"/>
                            <param name="docURL" value="{request:get-url() || '?lid=' || $lemma-id}"/>                       
                        </parameters>
    return 
            <div>{transform:transform($doc, $stylesheet, $parameters)}

                <span>
                      lid = {$lid}<br/>
                      lemma-id = {$lemma-id}<br/>
                      doc/id = {$doc/@xml:id/string()}<br/>
                      model(currentLemma)/id  = {$model("currentLemma")/@xml:id/string()}<br/>
                      count(m(results))      = {count($model("results"))}<br/>
                </span>

            </div>
};


(: ====Working paper==== :)
declare %templates:default
    function app:loadSingleWp($node as node(), $model as map(*), $wpid as xs:string?){
    let $context  := if ($wpid) then
                        doc($config:tei-workingpapers-root || "/" || sutil:normalizeId($wpid) || ".xml")/tei:TEI
                     else if ($model("currentWp")) then
                        let $wpid := $model("currentWp")/@xml:id 
                        return ($model("currentWp"))
                     else
                        ()
   (: let $results-work := if (count($model("results"))>0) then
                            $model("results")
                         else if ($q) then
                           dq:search($context, $model, $wid, $aid, $lid, $q, $field)
                         else :)
                            
    return map { "currentWp": $context }
};

(: ====Work==== :)

declare function app:watermark($node as node(), $model as map(*), $wid as xs:string?, $lang as xs:string?) {
    let $watermark :=   if (($model('currentAuthor')//tei:revisionDesc/@status |
                             $model('currentLemma')//tei:revisionDesc/@status  |
                             doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")/tei:TEI//tei:revisionDesc/@status)[1]
                                                        = ('a_raw',
                                                           'b_cleared',
                                                           'c_hyph_proposed',
                                                           'd_hyph_approved',
                                                           'e_emended_unenriched',
                                                           'f_enriched',
                                                           'r_reference_work'
                                                          )) then
                            <p class="watermark-wip-text">
                                <i18n:text key="workInProgress">Work in Progress!</i18n:text>
                            </p>
                        else
                            <p class="watermark-wip-text">
                                {string(($model('currentAuthor')//tei:revisionDesc/@status |
                                         $model('currentLemma')//tei:revisionDesc/@status  |
                                         $model('currentWorkHeader')//tei:revisionDesc/@status)[1])}          
                            </p>
    return
        $watermark
        (: i18n:process($watermark, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};

declare function app:watermark-txtonly($node as node(), $model as map(*), $wid as xs:string?, $lang as xs:string?) {
    let $watermark :=   if (($model('currentAuthor')//tei:revisionDesc/@status |
                             $model('currentLemma')//tei:revisionDesc/@status  |
                             doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")/tei:TEI//tei:revisionDesc/@status)[1] 
                                                        = ('a_raw',
                                                           'b_cleared',
                                                           'c_hyph_proposed',
                                                           'd_hyph_approved',
                                                           'e_emended_unenriched',
                                                           'f_enriched',
                                                           'r_reference_work'
                                                          )) then
                            <span><i18n:text key="workInProgress">Work in Progress!</i18n:text></span>
                            (: <span>{i18n:process(<i18n:text key="workInProgress">Work in Progress!</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))}</span> heute geändert :)
                        else
                            <span>{string(($model('currentAuthor')//tei:revisionDesc/@status |
                                     $model('currentLemma')//tei:revisionDesc/@status  |
                                     $model('currentWorkHeader')//tei:revisionDesc/@status)[1])}</span>
    return $watermark
};
(: deprecated :)
(:declare %templates:wrap function app:loadSingleWork($node as node(), $model as map(*), $wid as xs:string?) {
    let $context  :=   if (doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")/tei:TEI//tei:text[@type="work_multivolume"]) then
                            util:expand(doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")/tei:TEI)
                     else
                            doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")/tei:TEI
    return  map {"currentWork": $context}
};:)

declare %templates:wrap function app:loadWorkMetadata($node as node(), $model as map(*), $wid as xs:string?) {
    let $normId := sutil:normalizeId($wid)
    let $workPath := $config:tei-works-root || "/" || $normId || ".xml"
    let $header := util:expand(doc($workPath)/tei:TEI/tei:teiHeader)
                    (: or better util:expand(doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml"))/tei:TEI/tei:teiHeader ?:)
    let $workId := doc($workPath)/tei:TEI/@xml:id/string()
    let $type := doc($workPath)/tei:TEI/tei:text/@type/string()
    return  
        map {'currentWorkHeader': $header,
             'currentWorkId': $workId,
             'currentWorkType': $type}
};

declare function app:displaySingleWork($node as node(), 
                                        $model as map(*),
                                        $wid as xs:string?,
                                        $frag as xs:string?,
                                        $q as xs:string?,
                                        $mode as xs:string?,
                                        $viewer as xs:string?, 
                                        $lang as xs:string?) {
    let $workId     := if ($wid) then sutil:normalizeId($wid) else $model('currentWorkId')
    let $htmlPath   := $config:html-root || "/" || $workId
    let $qChecked   := if ($q = ('*', '%2A', '%2a', '&amp;ast;', '&amp;#x2a;', '&amp;#42;', 'lt', 'gt', 'amp')) then () else $q

    let $targetFragment := 
        if (xmldb:collection-available($htmlPath)) then
            if ($frag || ".html" = xmldb:get-child-resources($htmlPath)) then
                $frag || ".html"
            else
                functx:sort(xmldb:get-child-resources($htmlPath))[1]
        else ()

    let $originalDoc := doc($htmlPath || "/" || $targetFragment)

    (: Fill in all parameters (except frag) in pagination links :)
    let $urlParameters := 
        string-join((
            if (exists($qChecked)) then 'q=' || $qChecked else (),
            if (exists($mode)) then 'mode=' || $mode else (),
            if (exists($viewer)) then 'viewer=' || $viewer else (),
            if (exists($lang)) then 'lang=' || $lang else ()
            ), 
        '&amp;')
(:
    (\: add urlParameters with viewing mode, search term etc. to internal hyperlinks :\)
    let $xslSheet:= 
        <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            <xsl:output omit-xml-declaration="yes" indent="yes"/>
            <xsl:param name="urlParameters"/>

            <!-- Default: Copy everything -->
            <xsl:template match="node()|@*" priority="2">
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:copy>
            </xsl:template>

            <!-- Change href parameters on-site -->
            <xsl:template match="a/@href[not(contains(., 'http'))]" priority="80">
                <xsl:variable name="openingChar">
                    <xsl:choose>
                        <xsl:when test="contains(., '?')">
                            <xsl:text>&amp;</xsl:text>
                        </xsl:when>                                                            
                        <xsl:otherwise>
                            <xsl:text>?</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(., '#')">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="contains(., '#')">
                            <xsl:value-of select="replace(., '#', concat($openingChar, $urlParameters, '#'))"/>
                        </xsl:when>                                                            
                        <xsl:otherwise>
                            <xsl:value-of select="concat(., $openingChar, $urlParameters)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:template>
        </xsl:stylesheet>
:)
(:    
    let $parameters := 
        <parameters>
            <param name="exist:stop-on-warn"  value="yes"/>
            <param name="exist:stop-on-error" value="yes"/>
            <param name="urlParameters"       value="{$urlParameters}"/>
        </parameters>
:)    
(:    let $parametrizedDoc := transform:transform($originalDoc, $xslSheet, $parameters):)
    
    let $parametrizedDoc := app:insertParams($originalDoc/*, $urlParameters)

    (: If we have an active query string, highlight the original html fragment accordingly :)
    let $outHTML := 
        if ($qChecked) then 
            let $highlighted := $parametrizedDoc(:sphinx:highlight($parametrizedDoc, $qChecked)//item[1]/description :)
 
            return 
                if ($highlighted) then $highlighted else $parametrizedDoc  (:  problem here with highlight ?  :)
        (:  :  console:log("I am highlighted:" || $highlighted) :)
        else
            $parametrizedDoc

    let $debugOutput   := 
        if ($config:debug = "trace") then
            <p>
                wid: {$wid}<br/>
                $model('currentWorkId'): {xs:string($model('currentWorkId'))}<br/>
                workId: {$workId}<br/>
                q: {$q}<br/>
                mode: {$mode}<br/>
                viewer: {$viewer}<br/>
                lang: {$lang}<br/>
                doc($config:html-root || "/" || $workId || "/" || $targetFragment): {substring(serialize(doc($config:html-root || "/" || $workId || "/" || $targetFragment)), 1, 300)}
            </p>
        else ()
    let $workNotAvailable := <h2><span class="glyphicon glyphicon-file"></span> <i18n:text key="workNotYetAvailable">This work is not yet available.</i18n:text></h2>

return
    if ($targetFragment) then
        <div>
            { (: $debugOutput :) }
            { $outHTML
                (: i18n:process($outHTML, $lang, $config:i18n-root, "en") heute geändert :)
            }
        </div>
    else
        (: TODO: redirect to genuine error or resource-not-available page :)
        $workNotAvailable        
        (: i18n:process($workNotAvailable, $lang, $config:i18n-root, "en") heute geändert :)
    
};

        
(:
~ Recursively inserts concatenated query parameters into non-http links of an HTML fragment.
:)
declare (:  %private :)function app:insertParams($node as node()?, $params as xs:string?) {
    typeswitch($node)
        case element(a) return
            element {name($node)} {
                for $att in $node/@* return
                    app:attrInsertParams($att, $params)
                ,
                for $child in $node/node() return 
                    app:insertParams($child, $params)
            }
        case element() return
            element {name($node)} {
                for $att in $node/@*
                   return
                      attribute {name($att)} {$att}
                ,
                for $child in $node/node()
                   return app:insertParams($child, $params)
            }
        default return $node
};
declare(:  %private :) function app:attrInsertParams($attr as attribute(), $params as xs:string?) {
    typeswitch($attr)
        case attribute(href) return
            if (not(contains($attr, 'http'))) then
                let $openingChar := if (contains($attr, '?')) then '&amp;' else '?'
                let $value := 
                    if (starts-with($attr, '#')) then 
                        $attr/string()
                    else if (contains($attr, '#')) then
                        replace($attr, '#', concat($openingChar, $params, '#'))
                    else 
                        concat($attr, $openingChar, $params)
                return attribute {name($attr)} {$value}
            else 
                $attr
        default return
            $attr
};


declare function app:searchResultsNav($node as node(), $model as map(*), $q as xs:string?, $lang as xs:string?) {
    let $nav := if ($q) then
                    <div class="searchResultsNav col-lg-8 col-md-8 col-sm-9 col-xs-12">
                        Search for "{$q}". <a href="#" class="gotoResult" id="gotoPrevResult">Previous</a>{$config:nbsp || $config:nbsp}<a href="#" class="gotoResult" id="gotoNextResult">Next</a>
                    </div>
                else ()
    return $nav
};

(: =========== End of Load single author, lemma, working paper, work (in alphabetical order) ============= :)

(: ============== Retrieve single *pieces* of information ... ========= :)

(: ----------------- ... from AUTHORs -------------------
 : extract title etc. from $model('currentAuthor').
 :)
declare %templates:wrap 
    function app:AUTname($node as node(), $model as map(*)) {
         app:rotateFormatName($model("currentAuthor")//tei:listPerson/tei:person[1]/tei:persName[1])
}; 

declare
    function app:AUTarticleAuthor($node as node(), $model as map(*)) {
        <div style="text-align:right">
            {app:rotateFormatName($model("currentAuthor")//tei:titleStmt//tei:author/tei:persName)}
        </div>
};

declare %templates:wrap
    function app:AUTworks($node as node(), $model as map(*), $lang as xs:string) {
        let $autId := $model('currentAuthor')/@xml:id/string()
        let $works := for $hit in collection($config:tei-works-root)//tei:TEI[contains(.//tei:titleStmt/tei:author/tei:persName/@ref, $autId)][tei:text/@type = ("work_monograph", "work_multivolume")]
            let $getAutString   := $hit//tei:titleStmt/tei:author/tei:persName/@ref/string()
            let $workTitle      := $hit//tei:sourceDesc//tei:monogr/tei:title[@type eq 'short']/text()
            let $firstEd        := $hit//tei:sourceDesc//tei:date[@type = 'firstEd']
            let $thisEd         := $hit//tei:sourceDesc//tei:date[@type = 'thisEd']
            let $ed             := if ($thisEd) then $thisEd else $firstEd
            let $ref            := session:encode-url(xs:anyURI('work.html?wid=' || $hit/@xml:id/string()))
            order by $workTitle ascending
            return 
                    <p><a href="{$ref}"><span class="glyphicon glyphicon-file" aria-hidden="true"/>&#xA0;{$workTitle||'&#160;'}({$ed})</a></p>
        return $works
};

(:declare %public function app:AUTentry($node as node(), $model as map(*), $aid) {
    app:AUTsummary(doc($config:tei-authors-root || "/" || sutil:normalizeId($aid) || ".xml")//tei:text)
};

declare function app:AUTsummary($node as node()) as item()* {
    typeswitch($node)
        case element(tei:teiHeader) return ()
        case text() return $node
        case comment() return $node
        case element(tei:bibl) return 
             let $getGetId :=  $node/@sortKey
                return 
                    if ($getGetId) then
                        <span class="{('work hi_'||$getGetId)}">
                        {if ($node/tei:title/@ref) then
                            <a target="blank" href="{$node/tei:title/@ref}">{($node/text())}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                        else
                            <i>{($node/text())}</i>}
                        </span>    
                        else()
        case element(tei:birth) return 
            <span>
<!--
                <a class="anchor" name="{$node/ancestor::tei:div[1]/@xml:id}"></a>
                <h3>
                    <a class="anchorjs-link" href="{session:encode-url(xs:anyURI('author.html?aid=' || $node/ancestor::tei:TEI/@xml:id||'#'||$node/ancestor::tei:div[1]/@xml:id||'LifeData'))}">
                        <span class="anchorjs-icon"></span>
                    </a><i18n:text key="overview">Lebensdaten</i18n:text>
                </h3>
                <p class="autText"><!-/-<i class="fa fa-birthday-cake"></i>-/->*&#xA0;
                    {app:placeNames($node), ': '||$node/tei:date[1]}
                </p>
-->
                *&#xA0;{app:placeNames($node) || ': ' || $node/tei:date[1]}
            </span>
        case element(tei:death) return 
            <span>
<!--
             <p class="autText"><!-/-<i class="fa fa-plus"></i>-/->†&#xA0;
                    {app:placeNames($node), ': '||$node/tei:date[1]}
            </p>
-->
                †&#xA0;{app:placeNames($node) || ': '||$node/tei:date[1]}
            </span>
        case element(tei:head) return if ($node/@xml:id='overview') then () else 
            <span>
            <a class="anchor" name="{$node/parent::tei:div[1]/@xml:id}"></a>
                <h3>
                    <a class="anchorjs-link" href="{session:encode-url(xs:anyURI('author.html?aid=' || $node/ancestor::tei:TEI/@xml:id||'#'||$node/parent::tei:div[1]/@xml:id))}">
                        <span class="anchorjs-icon"></span>
                    </a>
                {$node}</h3>
            </span>
        case element(tei:list) return
            if ($node/tei:head) then
                <div>
                <h4>{local:passthru($node/tei:head)}</h4>
                <ul class="list-group" style="list-style-type: disc;">
                    {for $child in $node/tei:item
                    return
                    <li class="list-group-item">
                        {local:passthru($child)}
                    </li>}
                </ul>
                </div>    
            else
                <ul class="list-group" style="list-style-type: disc;">
                    {for $child in $node/tei:item
                    return
                    <li class="list-group-item">
                        {local:passthru($child)}
                    </li>}
                </ul>    
        case element(tei:orgName) return 
            let $lang := request:get-attribute('lang')
            let $getCerlId      :=  if (starts-with($node/@ref, 'cerl:')) then replace($node/@ref/string(), "(cerl):(\d{11})*", "$2") else ()
            let $CerlHighlight  :=  if (starts-with($node/@ref, 'cerl:')) then replace($node/@ref/string(), "(cerl):(\d{11})*", "$1$2") else ()
                return 
                    if (starts-with($node/@ref, 'cerl:')) then 
                         <span class="{('persName hi_'||$CerlHighlight)}">
                            <a target="_blank" href="{('http://thesaurus.cerl.org/cgi-bin/record.pl?rid='||$getCerlId)}">{$node||$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                         </span>
                    else
                        <span>{$node/text()}</span>
        case element(tei:p) return
            <p class="autText">{local:passthru($node)}</p>
        case element(tei:persName) return 
            let $lang := request:get-attribute('lang')
            let $getAutId       :=  if (starts-with($node/@ref, 'author:')) then substring($node/@ref/string(),8,5) else ()
            let $getGndId       :=  if (starts-with($node/@ref, 'gnd:'))  then replace($node/@ref/string(), "(gnd):(\d{9})*", "$1/$2") else ()
            let $GndHighlight   :=  if (starts-with($node/@ref, 'gnd:'))  then replace($node/@ref/string(), "(gnd):(\d{9})*", "$1$2") else ()
            let $getCerlId      :=  if (starts-with($node/@ref, 'cerl:')) then replace($node/@ref/string(), "(cerl):(\d{11})*", "$2") else ()
            let $CerlHighlight  :=  if (starts-with($node/@ref, 'cerl:')) then replace($node/@ref/string(), "(cerl):(\d{11})*", "$1$2") else ()
                return 
                    if ($node/tei:addName) then 
                        <span>
                            <h3>
                               <a class="anchorjs-link" href="{session:encode-url(xs:anyURI('author.html?aid=' || $node/ancestor::tei:TEI/@xml:id||'#'||$node/ancestor::tei:div[1]/@xml:id||'AddNames'))}">
                                   <span class="anchorjs-icon"></span>
                               </a><i18n:text key="addName">Aliasnamen</i18n:text>
                           </h3>
                           <p class="autText">{local:passthru($node/tei:addName)}</p>
                        </span>
                    else if (starts-with($node/@ref, 'author:')) then
                         <span class="{('persName hi_'||'author'||$getAutId)}">
                             <a href="{session:encode-url(xs:anyURI('author.html?aid=' || $getAutId))}">{($node/text())}</a>
                         </span> 
                    else if (starts-with($node/@ref, 'cerl:')) then 
                         <span class="{('persName hi_'||$CerlHighlight)}">
                            <a target="_blank" href="{('http://thesaurus.cerl.org/cgi-bin/record.pl?rid='||$getCerlId)}">{($node/text())||$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                         </span>
                    else if (starts-with($node/@ref, 'gnd:')) then 
                         <span class="{('persName hi_'||$GndHighlight)}">
                            <a target="_blank" href="{('http://d-nb.info/'||$getGndId)}">{($node/text())||$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                         </span>
                    else
                        <span>{$node/text()}</span>
        case element(tei:person) return
            <ul style="list-style-type: disc;">
                {for $child in $node/* return
                    <li>{local:passthru($child)}</li>}
            </ul>
        case element(tei:placeName) return
            let $getGetId :=  substring($node/@ref/string(),7,7)
            let $replaceGet :=  'http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid='||$getGetId
                return 
                    if (starts-with($node/@ref, 'getty:')) then
                        <span class="{('place hi_'||'getty'||$getGetId)}">
                            <a target="blank" href="{$replaceGet}">{($node/text())||$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                        </span>    
                    else
                        <span class="place">{($node/text())}</span>
        case element(tei:quote) return
            <span>»{local:passthru($node)}«</span>
        case element(tei:state) return
            <span>
<!--
            {if (not($node/preceding::tei:state)) then
                <span>
                    <a class="anchor" name="{$node/ancestor::tei:div[1]/@xml:id||'Degree'}"></a>
                    <h3>
                       <a class="anchorjs-link" href="{session:encode-url(xs:anyURI('author.html?aid=' || $node/ancestor::tei:TEI/@xml:id||'#'||$node/ancestor::tei:div[1]/@xml:id||'Degree'))}">
                           <span class="anchorjs-icon"></span>
                       </a><i18n:text key="degree">Abschluss</i18n:text>
                    </h3>
                </span>
                else()}
                 <p class="autText">{$node/@when/string()||'&#32;'||$node/tei:label}</p> 
-->
                 <p class="autText">{local:passthru($node)}</p> 
            </span>
         case element(tei:term) return   
            let $getLemId:=  substring($node/@ref/string(),7,5) 
                return
                    if (starts-with($node/@ref, 'lemma:')) then
                        <span class="{('term hi_'||'lemma'||$getLemId)}">
                            <a href="{session:encode-url(xs:anyURI('lemma.html?aid=' || $getLemId))}">{($node/text())}</a>
                        </span> 
                    else()
        default return local:passthru($node)
};

declare function local:passthru($nodes as node()*) as item()* {
    for $node in $nodes/node() return app:AUTsummary($node)
};:)



(:funx used in author.html and lemma.html:)
declare function app:placeNames($node as node()) {

    let $placesHTML :=  for $place in $node//tei:placeName
                            let $getGetId   := substring($place/@ref,7,7)
                            let $replaceGet :=  'http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=' || $getGetId
                            return
                                 <span class="{('place hi_'||'getty'||$getGetId)}">
                                    <a target="blank" href="{$replaceGet}">
                                        {$place || $config:nbsp}
                                        <span class="glyphicon glyphicon-new-window" aria-hidden="true"></span>
                                    </a>
                                 </span>
    return $placesHTML
};

declare function app:cited ($node as node(), $model as map(*), $lang as xs:string?, $aid as xs:string?, $lid as xs:string?) {
        <ul class="list-unstyled">
        {(:let $analyze-section  := if (request:get-parameter('aid', '')) then $model('currentAuthor')//tei:text else  $model('currentLemma')//tei:text:)
        let $analyze-section  := if (request:get-parameter('aid', '')) then doc($config:tei-authors-root || "/" || sutil:normalizeId($aid) || ".xml")//tei:text else  doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lid) || ".xml")//tei:text
        let $cited :=
            for $entity in $analyze-section//tei:bibl[@sortKey]
                let $ansetzungsform := $entity/@sortKey/string()
                let $author         := sutil:formatName($entity//tei:persName[1])
                let $title          :=  if ($entity//tei:title/@key) then
                                            ($entity//tei:title/@key)[1]
                                        else ()
                let $display-title  :=  if ($author and $title) then
                                            concat($author, ': ', $title)
                                        else
                                            replace($ansetzungsform, '_', ': ')
                order by $entity/@sortKey
                return
                    if ($entity is ($analyze-section//tei:bibl[@sortKey][@sortKey = $entity/@sortKey])[1]) then
                            <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;cursor:pointer;" onclick="highlightSpanClassInText('hi_{translate($entity/@sortKey, ':', '_')}',this)">
                                <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$display-title} ({count($analyze-section//tei:bibl[@sortKey][@sortKey eq $entity/@sortKey])})
                            </li>
                        else ()
       return if ($cited) then $cited  else  <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;">no data</li> }
        </ul>
};

declare function app:lemmata ($node as node(), $model as map(*), $lang as xs:string?, $aid as xs:string?, $lid as xs:string?) {
        <ul class="list-unstyled">
            {(:let $analyze-section  := if (request:get-parameter('aid', '')) then $model('currentAuthor')//tei:text else  $model('currentLemma')//tei:text:)
            let $analyze-section  := if (request:get-parameter('aid', '')) then doc($config:tei-authors-root || "/" || sutil:normalizeId($aid) || ".xml")//tei:text else  doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lid) || ".xml")//tei:text
            let $lemmata :=
                for $entity in $analyze-section//tei:term
                    let $ansetzungsform := $entity/@key/string()
                    order by $entity/@key
                    return if ($entity is ($analyze-section//tei:term[(tokenize(string(@ref), ' '))[1] = (tokenize(string($entity/@ref), ' '))[1]])[1]) then
                                <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;cursor:pointer;" onclick="highlightSpanClassInText('hi_{translate((tokenize(string($entity/@ref), ' '))[1], ':', '_')}',this)">
                                     <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$ansetzungsform} ({count($analyze-section//tei:term[@ref eq $entity/@ref])})
                                </li>
                            else()
            return if ($lemmata) then $lemmata else  <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;">no data</li> }
        </ul>
};

declare function app:persons($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?) {
        <ul class="list-unstyled">{
            let $analyze-section :=
                if (request:get-parameter('aid', '')) then
                    doc($config:tei-authors-root || "/" || sutil:normalizeId($aid) || ".xml")//tei:text
                else
                    doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lid) || ".xml")//tei:text
            let $persons :=
                for $entity in $analyze-section//tei:persName[not(parent::tei:author)]
                    let $ansetzungsform := app:resolvePersname($entity)
                    order by $entity/@key
                    return
                        (:exclude author entity:)
                        if (substring($entity/@ref, 8,5) eq $analyze-section/ancestor::tei:TEI/@xml:id) then ()
                        else if ($entity is ($analyze-section//tei:persName[(tokenize(string(@ref), ' '))[1] = (tokenize(string($entity/@ref), ' '))[1]])[1]) then
                           <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial; cursor:pointer;" onclick="highlightSpanClassInText('hi_{translate((tokenize(string($entity/@ref), ' '))[1], ':', '_')}',this)">
                                <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$ansetzungsform} ({count($analyze-section//tei:persName[@ref eq $entity/@ref])})
                           </li>
                        else ()
            return if ($persons) then $persons else  <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;">no data</li>
        }</ul>
};

declare function app:places ($node as node(), $model as map(*), $aid as xs:string?, $lid as xs:string?) {
        <ul class="list-unstyled">{
             let $analyze-section  := if (request:get-parameter('aid', '')) then doc($config:tei-authors-root || "/" || sutil:normalizeId($aid) || ".xml")//tei:text else  doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lid) || ".xml")//tei:text
             let $places :=
                     for $entity in $analyze-section//tei:placeName
                        let $ansetzungsform := if ($entity/@key) then
                                                    xs:string($entity/@key)
                                              else
                                                    xs:string($entity)
                        order by $entity/@key
                        return if ($entity is ($analyze-section//tei:placeName[(tokenize(string(@ref), ' '))[1] = (tokenize(string($entity/@ref), ' '))[1]])[1]) then
                                   <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;cursor:pointer;" onclick="highlightSpanClassInText('hi_{translate((tokenize(string($entity/@ref), ' '))[1], ':', '_')}',this)">
                                        <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$ansetzungsform} ({count($analyze-section//tei:placeName[@ref = $entity/@ref])})
                                   </li>
                                else()
            return if ($places) then $places else  <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;">no data</li>
        }</ul>
};


(: ----------------- ... from LEMMAta ------------------- 
 : extract title etc. from $model('currentLemma').
 :)
 declare function app:LEMtitle($node as node(), $model as map(*)) {
       $model('currentLemma')//tei:titleStmt/tei:title[@type='short']/text()
};
  
declare %public function app:LEMentry($node as node(), $model as map(*), $lid as xs:string) {
(:app:LEMsummary($model('currentLemma')//tei:text):)
(:    app:LEMsummary(doc($config:tei-lemmata-root || "/" || $lid || ".xml")//tei:text):)
    render-app:dispatch(doc($config:tei-lemmata-root || "/" || sutil:normalizeId($lid) || ".xml")//tei:body, "work", ())
};
(: Rendering is done in render-app.xqm! :)


(: ----------------- ... from WORKING PAPERs ------------------- all new
 : extract title etc. from $model('currentWp').
 :)
declare %templates:wrap
    function app:WPtitle ($node as node(), $model as map(*)) {
       <span style="text-align: justify;">{$model('currentWp')//tei:titleStmt/tei:title[1]/string()}</span>
};

declare %templates:wrap
    function app:WPauthor ($node as node(), $model as map(*)) {
        app:rotateFormatName($model('currentWp')/tei:teiHeader//tei:biblStruct/tei:monogr/tei:author/tei:persName)
};

declare %templates:wrap
    function app:WPdate ($node as node(), $model as map(*)) {
        $model('currentWp')/tei:teiHeader//tei:biblStruct//tei:date[@type = 'firstEd']/string()
};

declare %templates:wrap %templates:default("lang", "en")
    function app:WPvol  ($node as node(), $model as map(*), $lang as xs:string?) {
       let $link := 'workingpaper.html?wpid=' || $model('currentWp')/@xml:id/string()
       let $vol := $model('currentWp')//tei:titleStmt/tei:title[@type='short']/string()
       return <h4><a  href="{$link}">{$vol}</a></h4>
};

declare %templates:wrap
    function app:WPvolNoLink  ($node as node(), $model as map(*), $lang as xs:string?) {
       $model('currentWp')//tei:titleStmt/tei:title[@type='short']/string()     
};

declare %templates:wrap %templates:default("lang", "en")
    function app:WPimg ($node as node(), $model as map(*), $lang as xs:string?) {
    let $link := 'workingpaper.html?wpid=' || $model('currentWp')/@xml:id/string()
    let $img  := if ($model('currentWp')//tei:graphic/@url) then
                       <img style="border: 0.5px solid #E7E7E7; width:90%; height: auto;" src="{$model('currentWp')//tei:graphic/@url/string()}"/>
                 else ()
    return
       <a href="{$link}">{$img}</a>
};

declare %templates:wrap
    function app:urn ($node as node(), $model as map(*)) {
    let $urn := $model('currentWp')//tei:teiHeader//tei:biblStruct/tei:ref[@type = 'url'][starts-with(., 'urn')]
    return
       <a href="{$config:urnresolver || $urn}" target="_blank">{ $urn }&#xA0;<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
};

declare %templates:wrap %templates:default("lang", "en")
    function app:citation ($node as node(), $model as map(*), $lang as xs:string?) {
    let $urn := $model('currentWp')//tei:biblStruct/tei:ref[@type = 'url'][starts-with(., 'urn')]
    let $translate  :=  if ($lang = 'de') then
                            'Zitiervorschlag'
                        else if ($lang ='en') then
                            'Citation'
                        else
                            'Citación'
    let $citationsString := string-join(app:WPauthor($node,$model), ', ') || ' (' ||
                            app:WPdate($node,$model)   || '): ' ||
                            app:WPtitle($node,$model)  || ' - Salamanca Working Paper Series (ISSN 2509-5080) ' ||
                            $model('currentWp')//tei:titleStmt/tei:title[@type='short']/string() ||
                            '. ' || $urn || ' ('  ||
                            replace(current-date(),'(\d{4})-(\d{2})-(\d{2})([+].*)','$3.$2.$1') || ').'

    return
      <span>{$urn}&#xA0;&#xA0;<button type="button" class="btn btn-link"
                                      data-container="body" data-toggle="popover"
                                      data-placement="bottom" title="{$translate}: {$citationsString}"
                                      data-original-title="" data-content="{$citationsString}"><i style="margin-bottom: 6px" class="fa fa-question-circle"/></button></span>
};

declare %templates:wrap %templates:default("lang", "en")
    function app:WPpdf ($node as node(), $model as map(*), $lang as xs:string?) {
    let $link   := $model('currentWp')//tei:biblStruct/tei:ref[@type = 'url'][ends-with(., '.pdf')]/string()
    let $output :=
                    <a href="{$link}">
                        <span class="glyphicon glyphicon-download-alt" aria-hidden="true"></span>&#xA0;
                        <i18n:text key="download">herunterladen</i18n:text>
                    </a>
    return
        $output
        (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};

declare %templates:wrap
    function app:WPabstract ($node as node(), $model as map(*)) {
       $model('currentWp')//tei:abstract/string()
};

declare %templates:wrap %templates:default("lang", "en")
    function app:WPshowSingle ($node as node(), $model as map(*), $lang as xs:string?) {
        let $work := <a href="workingpaper.html?wpid=' {$model('currentWp')/@xml:id/string()}">{$model('currentWp')/@xml:id/string()}</a> 
        return
            $work
            (: i18n:process($work, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :) 
};

declare %templates:wrap
    function app:WPkeywords ($node as node(), $model as map(*)) {
    string-join($model('currentWp')//tei:keywords/tei:term, ', ')
(:
    for $term in $model('currentWp')//tei:keywords/tei:term
    let $termSeparated := concat($term,",")
    return
        if ($term is ($model('currentWp')//tei:keywords/tei:term)[last()])
            then concat($term,"")
            else concat($term,",")
:)
};    

declare %templates:wrap %templates:default("lang", "en")
    function app:WPlang ($node as node(), $model as map(*), $lang as xs:string) {
    let $language := $model('currentWp')/tei:teiHeader//tei:langUsage[1]
    let $result :=
             if ($language/tei:language/@ident = 'en') then <i18n:text key="english">Englisch</i18n:text>
        else if ($language/tei:language/@ident = 'es') then <i18n:text key="spanish">Spanisch</i18n:text>
        else if ($language/tei:language/@ident = 'de') then <i18n:text key="german">Deutsch</i18n:text>
        else ()
    return
        $result
        (: i18n:process($result, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};

declare %templates:wrap %templates:default("lang", "en")
    function app:WPgoBack ($node as node(), $model as map(*), $lang as xs:string?) {
        let $link       := 'workingpapers.html'
        let $icon       := <i class="fa fa-reply"></i>
        let  $translate := <i18n:text key="back">zurück</i18n:text>
        return <a title="{$translate}" href="{$link}">{$icon}&#xA0;&#xA0;</a>
};

declare %templates:wrap %templates:default("lang", "en")
    function app:WpEditiorial ($node as node(), $model as map(*), $lang as xs:string?) {
        let $more := <i18n:text key="more">Mehr</i18n:text>
        return 
            <a href="editorial-workingpapers.html?">&#32;&#32;{$more}&#160;<i class="fa fa-share"></i></a>
            (: <a href="editorial-workingpapers.html?">&#32;&#32;{i18n:process($more, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))}&#160;<i class="fa fa-share"></i></a> heute geändert :)
};


(:-------------------- funx for page workdetails.html ---------------------:)       

(:~
Returns the type of the current work/volume in parenthesis
~:)
declare %templates:wrap
    function app:WRKtype($node as node(), $model as map(*), $lang as xs:string?) {
        let $teiType := $model('currentWorkType')
        let $type :=  
            if ($teiType eq 'work_multivolume') then <i18n:text key="multivolume">Mehrbandwerk</i18n:text> 
            else if ($teiType eq 'work_volume') then <i18n:text key="workvolume">Einzelband</i18n:text>
            else ()
        let $translate := $type (: i18n:process($type, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
        return 
            if ($type) then
                ' ('|| $translate ||') '
            else ()
};
 
(:~
Main title of the print source 
~:)
declare function app:WRKtitleMain($node as node(), $model as map(*)) as xs:string? {
        $model('currentWorkHeader')//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'main']/string()  
};

(:~
Short title of the print source (for citation)
~:)
declare function app:WRKtitleShort($node as node(), $model as map(*)) as xs:string? {
       $model('currentWorkHeader')//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
};

(:~
Main title of the digital edition of a work/volume 
~:)
declare function app:WRKeditionTitleMain($node as node(), $model as map(*)) as xs:string? {
        $model('currentWorkHeader')/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main']/string()  
};

(:~
Short title of the digital edition of a work/volume (for citation)
~:)
declare function app:WRKeditionTitleShort($node as node(), $model as map(*)) as xs:string? {
       $model('currentWorkHeader')/tei:fileDesc/tei:titleStmt/tei:title[@type = 'short']/string()
};

(:~ 
Creates the heading for a catalogue entry: author name: work/volume title 
@return: HTML
~:)
declare %templates:wrap 
    function app:WRKcatRecordTitle($node as node(), $model as map(*), $lang as xs:string?) {
    let $authorName := app:rotateFormatName($model('currentWorkHeader')/tei:fileDesc/tei:titleStmt/tei:author/tei:persName)
    let $title := app:WRKeditionTitleShort($node, $model)
    let $workType := app:WRKtype($node, $model, $lang)
    return (
        <span class="text-muted">{$authorName}: </span>,
        <span class="text-muted">{$title}</span>,
        <span class="text-muted">{$workType}</span>,
        <hr/>
        )
};

 
(: TODO: Check if an alternative to workdetails.html is needed in the following function: :)
(:~ 
Creates a (HTML) catalogue record for a work/volume.
@param node: template node
@param model: application data for the current request
@param lang: current language
@param wid: ID for the current work
@return: HTML div
~:)
declare %templates:wrap function app:WRKcatRecord($node as node(), $model as map(*), $lang as xs:string?) {
    let $workType := $model('currentWorkType')
    let $volumeIds :=   
        if ($workType eq 'work_multivolume') then 
            for $item in $model('currentWorkHeader')/tei:fileDesc/tei:notesStmt/tei:relatedItem[@type eq 'work_volume'] return substring-after($item/@target/string(), 'work:')
        else ()
    let $multivolInfo := 
        if ($workType eq 'work_volume') then
            <div class="col-md-8" style="padding-bottom:0.8em;">
                <span style="font-size:1.2em;font-style:italic;"><a href="{$config:webserver || '/' || $lang || '/workdetails.html?wid=' || substring($model('currentWorkId'),1,5)}">
                    <i class="fas fa-info-circle"></i>{' '}<i18n:text key="partOfMultivol">Part of a multivolume work</i18n:text>
                </a></span>
            </div>
        else ()
    let $volumesCount := count($volumeIds)
    let $volumesRecord :=   
        if ($volumesCount gt 0) then 
            for $id in $volumeIds return app:WRKcatRecordTeaser($node, $model, $id, $lang, $volumesCount)
        else ()
    let $output := 
        <div>
            <div class="row">
                {$multivolInfo}
                <div class="col-md-8">
                    {app:WRKeditionRecord($node, $model, $lang)}
                    <hr/>
                    {app:WRKbibliographicalRecord($node, $model, $lang)}
                </div>
              <!--<div class="col-md-1"/>-->
                <div class="col-md-4">
                    {app:WRKadditionalInfoRecord($node, $model, $lang)}
                </div>
            </div>
            {if ($volumesRecord) then 
                <div>
                    <hr/>
                    <h4><i18n:text key="volumes">Volumes</i18n:text>{' (' || string($volumesCount) || ')'}</h4>
                    {$volumesRecord}
                </div>
            else ()}
        </div>
            
    return
        $output
        (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
};

declare function app:WRKadditionalInfoRecord($node as node(), $model as map(*), $lang as xs:string?) {
    let $workType := $model('currentWorkType')
    let $workId := $model('currentWorkId')
    let $normId := sutil:convertNumericVolumeID($workId)
    let $status := $model('currentWorkHeader')/tei:revisionDesc/@status/string()

    let $mirador := 'viewer-standalone.html?wid=' || $workId
    let $scanCount := 0
    let $isPublished := app:WRKisPublished($node, $model, $workId)
    (: ({$scanCount || ' '}<i18n:text key="scans">Scans</i18n:text>) :)
    let $imagesLink := 
        <a href="{$mirador}" target="_blank" rel="noopener noreferrer">
            <i18n:text key="facsimiles">Facsimiles</i18n:text> 
        </a>
    let $readingViewField :=
        if (($workType = ('work_monograph', 'work_volume') and $isPublished)
            or $workType eq 'work_multivolume' and sutil:WRKisPublished(upper-case($workId) || '_Vol01')) then
            let $thumbnail := app:WRKcatRecordThumbnail($node, $model, $workId, 'full')
            return 
                <li><h5><i18n:text key="readingView">Reading view</i18n:text>:</h5>
                    {$thumbnail}
                </li>
        else ()
    let $views := 
        <div>
            <h4><i18n:text key="textViews">Views for this Text</i18n:text></h4>
            <ul>
                {$readingViewField}
                <li>{$imagesLink}</li>
            </ul>
        </div>
        
    let $teiHeader := $config:idserver || '/texts/' || $normId || '?format=tei&amp;mode=meta'
    let $teiHeaderLink :=   <a href="{$teiHeader}">
                                <i18n:text key="teiHeader">TEI Header</i18n:text>
                            </a>
    let $iiifLink := if ($workType eq 'work_multivolume') then   
                        <a href="{$config:iiifPresentationServer || 'collection/' || $workId}">
                            IIIF Collection
                        </a>
                     else 
                        <a href="{$config:iiifPresentationServer || $workId || '/manifest'}">
                            IIIF Manifest
                        </a>
    let $rdfId := if ($workType eq 'work_volume') then substring-before($workId, '_Vol') (: redirecting to RDF dataset for the complete work :) else $workId
    let $rdfLink := <a href="{$config:idserver || '/texts/' || $rdfId ||'?format=rdf'}">RDF</a>
    let $metadata :=
        <div>
            <h4><i18n:text key="metadata">Metadata</i18n:text></h4>
            <ul>
                <li>{$teiHeaderLink}</li>
                <li>{$rdfLink}</li>
                <li>{$iiifLink}</li>
            </ul>
        </div>
    
    let $teiHeaderLink := ()
    let $download :=    
        if ($isPublished) then 
            <div>
                <hr/>
                <h4><i18n:text key="download">Metadata</i18n:text></h4>
                <ul>
                    <li><a href="{$config:idserver || '/texts/' || $normId ||'?format=tei'}">XML (TEI P5)</a></li>
                    <li><a href="{$config:idserver || '/texts/' || $normId ||'?format=txt&amp;mode=edit'}">
                            <i18n:text key="text">Text</i18n:text> (<i18n:text key="constitutedLower">constituted</i18n:text>)
                        </a>
                    </li>
                    <li><a href="{$config:idserver || '/texts/' || $normId ||'?format=txt&amp;mode=orig'}">
                            <i18n:text key="text">Text</i18n:text> (<i18n:text key="diplomaticLower">diplomatic</i18n:text>)
                        </a>
                    </li>
                </ul>
            </div>
        else ()
    return 
        <div>
            {$views}
            <hr/>
            {$metadata}
            {$download}
        </div> 
};

(:~ 
Creates a HTML fragment containing a "teaser" for each volume of a multi-volume work. A teaser contains 
essential information about the print source (title, publication date, etc.) and about the digital edition (editors, etc.),
as well as a link to the complete catalogue record of the respective volume; moreover, it is accompanied by a thumbnail 
for the respective volume. 
@return: a HTML div element
~:)
declare function app:WRKcatRecordTeaser($node as node(), $model as map(*), $wid as xs:string, $lang as xs:string?, $volumes as xs:integer) {
    let $teiHeader :=   
        if (sutil:normalizeId($wid) eq $model('currentWorkId')) then $model('currentWorkHeader') (: when does this ever evaluate to true? (DG) :)
        else if (doc-available($config:tei-works-root || '/' || $wid || '.xml')) then 
            doc($config:tei-works-root || '/' || $wid || '.xml')/tei:TEI/tei:teiHeader
        else ()
    let $log := if ($config:debug = ('trace', 'info')) then console:log('Creating cat record teaser for work/volume:' || $wid) else ()
    let $teaserText :=
        if ($teiHeader) then
            let $digital := app:WRKeditionMetadata($node, $model, sutil:normalizeId($wid))
            let $bibliographical := app:WRKprintMetadata($node, $model, sutil:normalizeId($wid), $lang)
            let $titleShort := $digital?('titleShort')
            let $volumeString := $bibliographical?('volumeNumber') || ' of ' || string($volumes)
            let $pubDate :=     
                if ($digital?('isPublished')) then
                    i18n:convertDate($digital?('publicationDate'), $lang, 'verbose')
                else ()
            let $recordLink := $config:idserver || '/texts/' || $wid || '?mode=details'
            let $imagesLink := 'viewer-standalone.html?wid=' || $wid
            let $col1-width := 'col-md-2'
            let $col2-width := 'col-md-10'
            let $publication := 
                if ($digital?('isPublished')) then 
                     <tr>
                         <td class="{$col1-width}" style="line-height: 1.2">
                             <i18n:text key="digitalPublication">Electronic Publication</i18n:text>:
                         </td>
                         <td class="{$col2-width}" style="line-height: 1.2">
                             {$pubDate}
                         </td>
                     </tr>
                else 
                    <tr>
                        <td class="{$col1-width}" style="line-height: 1.2">
                            <i18n:text key="digitalPublication">Electronic publication</i18n:text>:
                        </td>
                        <td class="{$col2-width}" style="line-height: 1.2">
                            <i18n:text key="notPublished">Not yet published</i18n:text>
                        </td>
                    </tr>
            return 
                <div class="col-md-9 catrecord-teasertext">
                    <table class="borderless table table-hover">
                        <tbody>
                            <tr>
                                <td class="{$col1-width}" style="line-height: 1.2">
                                    <i18n:text key="title">Title</i18n:text>:
                                </td>
                                <td class="{$col2-width}" style="line-height: 1.2">
                                    {$titleShort}
                                </td>
                            </tr>
                            <tr>
                                <td class="{$col1-width}" style="line-height: 1.2">
                                    <i18n:text key="originalVolume">Volume (original)</i18n:text>:
                                </td>
                                <td class="{$col2-width}" style="line-height: 1.2">
                                    {$bibliographical?('volumeNumber') || ' '}<i18n:text key="of"/>{' ' || string($volumes)}
                                </td>
                            </tr>
                            <tr>
                                <td class="{$col1-width}" style="line-height: 1.2">
                                    <i18n:text key="imprintThis">Imprint</i18n:text>:
                                </td>
                                <td class="{$col2-width}" style="line-height: 1.2">
                                    {$bibliographical?('imprint')}
                                </td>
                            </tr>
                            {$publication}
                        </tbody>
                    </table>
                    <span><a href="{$recordLink}"><span class="fa fa-arrow-right"/>{' '}<i18n:text key="fullCatalogueRecord">Full catalogue record</i18n:text></a></span>
                    <br/>
                    <span><a href="{$imagesLink}" target="_blank" rel="noopener noreferrer"><span class="fa fa-arrow-right"/>{' '}<i18n:text key="facsimiles">Facsimiles</i18n:text></a></span>
                </div>
        else ()
    let $thumbnail := <div class="col-md-3">{app:WRKcatRecordThumbnail($node, $model, $wid, 'teaser')}</div>
    return 
        <div class="row">
            {$thumbnail}
            {$teaserText}
        </div>
};

(:~
Determines whether a given work (not volume) is officially published as part of the digital edition.
@param wid: the ID of the requested work.
~:)
declare function app:WRKisPublished($node as node(), $model as map(*), $wid as xs:string) as xs:boolean {
    let $workId := sutil:normalizeId($wid)
    let $status :=  
        if ($workId eq $model('currentWorkId')) then
            $model('currentWorkHeader')/tei:revisionDesc/@status/string()
        else if (doc-available($config:tei-works-root || '/' || $workId || '.xml')) then 
            doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:teiHeader/tei:revisionDesc/@status/string()
        else 'no_status'
    let $publishedStatus := ('g_enriched_approved', 'h_revised', 'i_revised_approved', 'z_final')
    return $status = $publishedStatus
};

(:~
: Determines whether a work - regardless of its status of publication - is a work from the collection of sources.
~:)
declare function app:WRKisInCollectionOfSources($wid as xs:string) as xs:boolean {
    boolean(doc($config:tei-meta-root || '/sources-list.xml')/tei:TEI/tei:text//tei:bibl[substring-after(@corresp, 'work:' eq sutil:normalizeId($wid))])
};

(:~
Creates a thumbnail image for the catalogue record of a work or volume.
@param mode: 'full': larger image including link to reading view; 'teaser': smaller image without link
@return: HTML div
~:)
declare function app:WRKcatRecordThumbnail($node as node(), $model as map(*), $wid as xs:string?, $mode as xs:string?) {
    let $workId := 
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then 
            sutil:normalizeId($wid) 
        else sutil:normalizeId($model('currentWorkId'))
    let $iiifResource := iiif:fetchResource($workId)
    let $img :=  
        if ($iiifResource?('@type') eq 'sc:Manifest') then 
            $iiifResource?('thumbnail')?('@id') 
        (: if iiif doc is a collection (multi-volume work), get thumbnail of 1st volume :)
        else if ($iiifResource?('@type') eq 'sc:Collection') then
            $iiifResource?('members')?(1)?('thumbnail')?('@id')
        else ()
    let $scaledImg := if ($mode eq 'full') then iiif:scaleImageURI($img, 25) else iiif:scaleImageURI($img, 20)
    let $workType := 
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then 
            doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:text/@type/string()
        else $model('currentWorkType')
    let $volNumber := doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:text/@n/string()
    let $target := 
        if ($workType eq 'work_volume') then
            $config:idserver || '/texts/' || substring($workId,1,5) || ':vol' || $volNumber || '?format=html'
        else
            $config:idserver || '/texts/' || $workId || '?format=html'
    let $status :=
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then 
            doc($config:tei-works-root || '/' || $workId || '.xml')/tei:TEI/tei:teiHeader//tei:revisionDesc/@status/string() 
        else $model('currentWorkHeader')/tei:revisionDesc/@status/string()
    let $isPublished := app:WRKisPublished($node, $model, $workId)
    
    let $buttonText :=
        if (not($isPublished)) then
            if ($workType eq 'work_multivolume') then <i18n:text key="notFullyAvailable">Not (fully) available</i18n:text>
            else <i18n:text key="notAvailable">Not available</i18n:text>
        else 
            if ($workType eq 'work_volume') then 
                <span><i18n:text key="volume">Not available</i18n:text>{' ' || $volNumber}</span>
            else <i18n:text key="readWork">Read</i18n:text>
    let $thumbnail :=
        if ($mode eq 'full' and $scaledImg) then
            <div>
                <a class="{$status}" href="{if (not($isPublished)) then 'javascript:' else $target}">
                    <img src="{$scaledImg}" class="img-responsive thumbnail" alt="Titlepage {functx:capitalize-first(substring($workType, 6))}"/>
                </a>
                <a class="btn btn-info button {$status}" href="{if (not($isPublished)) then 'javascript:' else $target}">
                    <span class="glyphicon glyphicon-file"></span>
                    {$config:nbsp}{$buttonText}
                </a>
            </div>
            
        else if ($mode eq 'teaser' and $scaledImg) then 
            <div class="catrecord-teaser">
                <a class="{$status}" href="{if (not($isPublished)) then 'javascript:' else $target}">
                    <img src="{$scaledImg}" class="img-responsive thumbnail teaser-thumbnail" alt="Titlepage {functx:capitalize-first(substring($workType, 6))}"/>
                </a>
                <a class="btn btn-info teaser-button {$status}" href="{if (not($isPublished)) then 'javascript:' else $target}">
                    <span class="glyphicon glyphicon-file"></span>
                    {$config:nbsp}{$buttonText}
                </a>
            </div>
        else ()
    return $thumbnail
};

(:~
Creates a html (div) fragment containing metadata about a work's/volume's digital edition, 
for embedding in a larger catalogue record. Receives the edition information mainly from 
app:WRKeditionMetadata().
~:)
declare function app:WRKeditionRecord($node as node(), $model as map(*), $lang as xs:string?) {
    let $workId := $model('currentWorkId')
    let $workType := $model('currentWorkType')
    let $digital := app:WRKeditionMetadata($node, $model, $workId)
    let $status := $model('currentWorkHeader')/tei:revisionDesc/@status/string()
    (: layout specs :)
    let $col1-width := 'col-md-3'
    let $col2-width := 'col-md-9'
    let $isPublished := app:WRKisPublished($node, $model, $workId)
    let $publicationDate := 
        if ($isPublished and $workType = ('work_monograph', 'work_volume')) then 
            i18n:convertDate($digital?('publicationDate'), $lang, 'verbose') 
        else if ($isPublished and $workType eq 'work_multivolume') then 
            $model('currentWorkHeader')/tei:fileDesc/tei:publicationStmt/tei:date[@type eq 'summaryDigitizedEd']/text()
        else ()
    let $publicationInfo := 
        if ($isPublished) then
            (
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="digitalPublication">Electronic publication</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    {$publicationDate}
                </td>
            </tr>,
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="scholEditors">Scholarly editing</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    {$digital?('scholEditors')}
                </td>
            </tr>,
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="techEditors">Technical editing</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    {$digital?('techEditors')}
                </td>
            </tr>,
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="series">Series</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    <i18n:text key="editionSeries">The School of Salamanca. A Digital Collection of Sources</i18n:text>
                </td>
            </tr>,
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="seriesVolume">Series volume</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    {$digital?('currentVolume')}
                </td>
            </tr>,
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="editorsInChief">Editors of the Series</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    {$digital?('seriesEditors')}
                </td>
            </tr>,
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="digitalPublisher">Published by</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    {$digital?('publisher')}
                </td>
            </tr>)
        else 
            <tr>
                <td class="{$col1-width}">
                    <i18n:text key="digitalPublication">Electronic publication</i18n:text>:
                </td>
                <td class="{$col2-width}">
                    <i18n:text key="notPublished">Not yet published</i18n:text>
                </td>
            </tr>
        
    let $editionRecord :=
        <table class="borderless table table-hover">
            <tbody>
                <tr>
                    <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="citationTitle">Citation Title</i18n:text>:</td>
                    <td class="{$col2-width}" style="line-height: 1.2">{$digital?('titleShort')}</td>
                </tr>
                <tr>
                    <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="author">Author</i18n:text>:</td>
                    <td class="{$col2-width}" style="line-height: 1.2">{$digital?('author')}</td>
                </tr>
                {$publicationInfo}
            </tbody>
        </table>
        
        let $citation := 
            if ($isPublished) then
                <div class="catalogue-citation">
                    <span style="font-weight:bold"><i18n:text key="proposedCitation">Proposed citation</i18n:text>:</span><br/>
                    {app:WRKcitationReference($node, $model, $lang, 'record')}
                </div>
            else ()
        
        return
            <div>
                <h4><i18n:text key="editionInfo">Digital Edition</i18n:text></h4>
                <div>{$editionRecord}</div>
                {$citation}
            </div>
};

(: modes: "record" for generic citations in catalogue records; "reading-full", "reading-passage" - only relevant for access date :)
declare function app:WRKcitationReference($node as node()?, $model as map(*)?, $lang as xs:string?, $mode as xs:string) as element(span) {
    let $wid := sutil:convertNumericVolumeID($model('currentWorkId'))
    let $fileDesc := $model('currentWorkHeader')/tei:fileDesc
    let $content := sutil:HTMLmakeCitationReference($wid, $fileDesc, $mode, ())
(:    return i18n:process($content, $lang, $config:i18n-root, 'en'):)
    return $content
};


(:~
Creates a html (div) fragment containing bibliographic information about a print source, 
for embedding in a larger catalogue record. Receives the bibliographic information mainly from 
app:WRKprintMetadata().
~:)
declare function app:WRKbibliographicalRecord($node as node(), $model as map(*), $lang as xs:string?) {
    let $workType := $model('currentWorkType')
    let $workId := $model('currentWorkId')
    let $bibliographical := app:WRKprintMetadata($node, $model, $workId, $lang)
    (: layout specs :)
    let $col1-width := 'col-md-3'
    let $col2-width := 'col-md-9'
    
    let $publicationTime := 
        if ($bibliographical?('publicationSpan')) then
            <tr>
                <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="periodOfOrigin">Period of publication</i18n:text>:</td>
                <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('publicationSpan')}</td>
            </tr>
        else if ($bibliographical?('publicationYear')) then
            <tr>
                <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="pubYear">Year of publication</i18n:text>:</td>
                <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('publicationYear')}</td>
            </tr>
        else ()
    (: if the text is a volume within a multi-volume work, provide volume specifications: :)
    let $volumeSpecifications :=
        if ($workType eq 'work_volume') then
            let $volumeString := 
                $bibliographical?('volumeTitle') || ' (' || $bibliographical?('volumeNumber') || ' ' 
                 || <i18n:text key="of">of</i18n:text>
                 (: || i18n:process(<i18n:text key="of">of</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
                 || ' ' || $bibliographical?('totalVolumesCount') || ')'
            return
                <tr>
                    <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="volume">Volume</i18n:text>:</td>
                    <td class="{$col2-width}" style="line-height: 1.2">{$volumeString}</td>
                </tr>
        else ()   
    let $imprintFirst := 
        if ($bibliographical?('imprintFirst')) then 
            <tr>
                <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="imprintFirst">Imprint of the First Edition</i18n:text>:</td>
                <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('imprintFirst')}</td>
            </tr>
        else ()
    let $origin :=    
        if ($workType = ('work_monograph', 'work_volume')) then 
            let $extLink := <i18n:text key="externalWindow">externer Link</i18n:text> (: i18n:process(<i18n:text key="externalWindow">externer Link</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) heute geändert :)
            return
                (<tr>
                    <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="ownerPrimaryEd">Library</i18n:text>:</td>
                    <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('library')}</td>
                </tr>,
                <tr>
                    <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="catLink">Catalogue link</i18n:text>:</td>
                    <td class="{$col2-width}" style="line-height: 1.2">
                        <a  href="{$bibliographical?('catLink')}" title="{$extLink}" target="_blank">{($bibliographical?('catLink') || '&#32;')} 
                            <span class="glyphicon glyphicon-new-window"></span>
                        </a>
                    </td>
                </tr>)
            else ()
    
    let $title := $bibliographical?('titleMain')
    let $extent := 
        if ($workType eq 'work_multivolume') then () 
        else (: no extent for mv works :)
            <tr>
                <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="extent">Extent</i18n:text>:</td>
                <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('extent')}</td>
            </tr>
    
    let $bibliographicalRecord :=
        <table class="borderless table table-hover">
            <tbody>
                <tr>
                    <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="title">Title</i18n:text>:</td>
                    <td class="{$col2-width}" style="line-height: 1.2">{$title}</td>
                </tr>
                {$publicationTime}
                <tr>
                      <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="publisher">Publisher</i18n:text>:</td>
                      <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('publisher')}</td>
                </tr>
                <tr>
                      <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="printingPlace">Printing Place</i18n:text>:</td>
                      <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('publicationPlace')}</td>
                </tr>
                <tr>
                      <td class="{$col1-width}" style="line-height: 1.2"><i18n:text key="languageS">Language(s)</i18n:text>:</td>
                      <td class="{$col2-width}" style="line-height: 1.2">{$bibliographical?('languages')}</td>
                </tr>
                {$volumeSpecifications}
                {$extent}
                {$origin}
                {$imprintFirst}
            </tbody>
        </table>
    return
        <div>
            <h4><i18n:text key="biblInfo">Bibliographic Information</i18n:text></h4>
            <div>{$bibliographicalRecord}</div>
        </div>
};
    
(:~ 
Bundles the bibliographical data of a (print) source.
~:)
declare function app:WRKprintMetadata($node as node(), $model as map(*), $wid as xs:string?, $lang as xs:string?) as map(*)? {
    let $workId := if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then sutil:normalizeId($wid) else $model('currentWorkId')
    let $teiHeader := 
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then
            doc($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')/tei:TEI/tei:teiHeader
        else $model('currentWorkHeader')
    let $type := 
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then
            doc($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')/tei:TEI/tei:text/@type/string()
        else $model('currentWorkType')
    let $sourceDesc := $teiHeader/tei:fileDesc/tei:sourceDesc
    
    let $titleMain := $sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'main']/string()
    let $titleShort := $sourceDesc/tei:biblStruct/tei:monogr/tei:title[@type = 'short']/string()
    let $author := app:rotateFormatName($sourceDesc//tei:author/tei:persName)
    let $pubSpan := 
        if ($sourceDesc//tei:date[@type eq 'summaryThisEd']) then $sourceDesc//tei:date[@type eq 'summaryThisEd']/text()
        else if ($sourceDesc//tei:date[@type eq 'summaryFirstEd']) then $sourceDesc//tei:date[@type eq 'summaryFirstEd']/text()
        else ()
    let $pubYear := 
        if ($sourceDesc//tei:date[@type eq 'thisEd']) then $sourceDesc//tei:date[@type eq 'thisEd']/@when/string()
        else if ($sourceDesc//tei:date[@type eq 'firstEd']) then $sourceDesc//tei:date[@type eq 'firstEd']/@when/string()
        else ()
    let $publisher :=
        if ($sourceDesc//tei:publisher[@n eq 'thisEd']) then app:rotateFormatName($sourceDesc//tei:publisher[@n eq 'thisEd']/tei:persName)
        else app:rotateFormatName($sourceDesc//tei:publisher[@n eq 'firstEd']/tei:persName)
    let $pubPlace :=    
        if ($sourceDesc//tei:pubPlace[@role eq 'thisEd']) then $sourceDesc//tei:pubPlace[@role eq 'thisEd']/@key/string()
        else $sourceDesc//tei:pubPlace[@role eq 'firstEd']/@key/string()
    let $volumeNumber := if ($type eq 'work_volume') then $sourceDesc//tei:series/tei:biblScope/@n/string() else ()
    let $volumeTitle := if ($type eq 'work_volume') then $sourceDesc//tei:monogr/tei:title[@type ='volume']/text() else ()
    let $totalVolumes := 
        if ($type eq 'work_volume') then 
            string(count(doc($config:tei-works-root || '/' || substring-before($workId, '_Vol') || '.xml')/tei:TEI/tei:teiHeader//tei:notesStmt/tei:relatedItem[@type eq 'work_volume']))
        (: currently not necessary: :)
        (:else if ($type eq 'work_multivolume') then string(count($model('currentWorkheader')//tei:notesStmt/tei:relatedItem[@type eq 'work_volume'])):)
        else '0'
    let $imprint := $pubPlace || ' : ' || $publisher || ', ' || $pubYear
    (: if text is not the first edition, also supply imprint of the first edition :)
    let $imprintFirst := 
        if ($sourceDesc//tei:pubPlace[@role = 'thisEd']) then 
            let $printingPlaceFirst := $sourceDesc//tei:pubPlace[@role = 'firstEd']/@key/string()
            let $publisherFirst := app:rotateFormatName($sourceDesc//tei:publisher[@n="firstEd"]/tei:persName)
            let $dateFirst := $sourceDesc//tei:date[@type eq 'firstEd']/@when/string()
            return $printingPlaceFirst || ' : ' || $publisherFirst || ', ' || $dateFirst
        else ()
    (: catalogue link for the print source: if there are several original sources, state only the main/first source :)
    let $library := 
        if ($sourceDesc//tei:msDesc[@type eq 'main']) then $sourceDesc//tei:msDesc[@type eq 'main']//tei:repository/text() 
        else $sourceDesc//tei:msDesc[1]//tei:repository/text()
    let $catLink  := 
        if ($sourceDesc//tei:msDesc[@type eq 'main']) then i18n:negotiateNodes($sourceDesc//tei:msDesc[@type eq 'main']//tei:idno[@type eq 'catlink'], $lang)/text()
        else i18n:negotiateNodes($sourceDesc//tei:msDesc[1]//tei:idno[@type eq 'catlink'], $lang)/text()
    let $extent := if ($type eq 'work_multivolume') then () else i18n:negotiateNodes($sourceDesc/tei:biblStruct/tei:monogr/tei:extent, $lang)/text()
    let $languages := 
        string-join((for $l in distinct-values($teiHeader/tei:profileDesc/tei:langUsage/tei:language/@ident) return
                        if ($l eq 'es') then <i18n:text key="spanish">Spanish</i18n:text>
                        else if ($l eq 'la') then <i18n:text key="latin">Latin</i18n:text>
                        (: add further languages here, if required :)
                        else ()), ', ')
        (: string-join((for $l in distinct-values($teiHeader/tei:profileDesc/tei:langUsage/tei:language/@ident) return
                        if ($l eq 'es') then i18n:process(<i18n:text key="spanish">Spanish</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en')
                        else if ($l eq 'la') then i18n:process(<i18n:text key="latin">Latin</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en')
                        (: add further languages here, if required :)
                        else ()), ', ') heute geändert :)
    let $status := $teiHeader//tei:revisionDesc/@status/string()
    return 
        map {
            'workId': $workId,
            'titleMain': $titleMain,
            'titleShort': $titleShort,
            'author': $author,
            'publicationSpan': $pubSpan,
            'publicationYear': $pubYear,
            'publisher': $publisher,
            'publicationPlace': $pubPlace,
            'volumeNumber': $volumeNumber,
            'volumeTitle': $volumeTitle,
            'totalVolumesCount': $totalVolumes,
            'imprint': $imprint,
            'imprintFirst': $imprintFirst,
            'library': $library,
            'catLink': $catLink,
            'extent': $extent,
            'languages': $languages,
            'status': $status
        }
(:    TODO: make extent/format language-independent :)
};

(:~
Bundles the digital edition metadata of a work/volume.
~:)
declare function app:WRKeditionMetadata($node as node(), $model as map(*), $wid as xs:string?) as map(*)? {
    let $workId := if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then sutil:normalizeId($wid) else $model('currentWorkId')
    let $teiHeader := 
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then
            doc($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')/tei:TEI/tei:teiHeader
        else $model('currentWorkHeader')
    let $type := 
        if ($wid and sutil:normalizeId($wid) ne $model('currentWorkId')) then
            doc($config:tei-works-root || '/' || sutil:normalizeId($wid) || '.xml')/tei:TEI/tei:text/@type/string()
        else $model('currentWorkType')
    let $status := $teiHeader/tei:revisionDesc/@status/string()
    let $titleMain := $teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq 'main']/text()
    let $titleShort := $teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type eq 'short']/text()
    let $author := app:rotateFormatName($teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName)
    let $languages := <span>
        { if ('la' = $teiHeader/tei:profileDesc//tei:language[@n eq 'main']/@ident) then <i18n:text key="latin">Latein</i18n:text> else () }
        { if ('es' = $teiHeader/tei:profileDesc//tei:language[@n eq 'main']/@ident) then <i18n:text key="spanish">Spanisch</i18n:text> else () }
        </span>
    let $isPublished := app:WRKisPublished($node, $model, $workId)
    let $pubDate := 
        if ($isPublished) then
            $teiHeader/tei:fileDesc/tei:editionStmt/tei:edition/tei:date/@when/string()
        else ()
    let $scholarlyEditors := 
        if ($isPublished) then
            string-join(for $ed in $teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[contains(@role, '#scholarly')]/tei:persName
                             return app:rotateFormatName($ed), '; ')
        else ()
    let $technicalEditors := 
        if ($isPublished) then
            string-join(for $ed in $teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[contains(@role, '#technical')]/tei:persName
                             return app:rotateFormatName($ed), '; ')
        else ()
    let $currentVolume := $teiHeader/tei:fileDesc/tei:seriesStmt/tei:biblScope/@n/string()
    let $seriesEditors := string-join(for $ed in $teiHeader/tei:fileDesc/tei:seriesStmt/tei:editor/tei:persName 
                                                     order by $ed/tei:surname
                                                     return app:rotateFormatName($ed), '; ')
    let $digitalMaster := $teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher/tei:orgName[1]/text()
    let $published := app:WRKisPublished($node, $model, $workId)
    
    return 
        map {
            'workId': $workId,
            'titleMain': $titleMain,
            'titleShort': $titleShort,
            'author': $author,
            'language': string-join($languages/span, ", "),
            'publicationDate': $pubDate,
            'scholEditors': $scholarlyEditors,
            'techEditors': $technicalEditors,
            'currentVolume': $currentVolume,
            'seriesEditors': $seriesEditors,
            'publisher': $digitalMaster,
            'isPublished': $published
        }
};


(:jump from work.html to corresponding work_volume in workdetails.html:)(:FIXME:)
declare function app:WRKdetailsCurrent($node as node(), $model as map(*), $lang as xs:string?) {
       (: let $multiRoot := replace($model('currentWork')/@xml:id, '(W\d{4})(_Vol\d{2})', '$1')
        return if ($model("currentWork")//tei:text[@type='work_volume']) then <a class="btn btn-info" href="{session:encode-url(xs:anyURI('workdetails.html?wid=' || $multiRoot))||'#'||$model('currentWork')/tei:text/@xml:id}"><span class="glyphicon glyphicon-file"></span>{'&#32;' ||i18n:process(<i18n:text key="details">Details</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri())) 
        ||'&#32;'||i18n:process(<i18n:text key="volume">Band</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))        || '&#32;' ||$model("currentWork")//tei:text[@type='work_volume']/@n/string()}</a>
        else:) 
        let $output :=
        <a class="btn btn-link" href="{$config:idserver || '/texts/' || request:get-parameter('wid', '') || '?mode=details'}"><i class="fas fa-file-alt"></i>&#32; <i18n:text key="details">Katalogeintrag</i18n:text></a>
        return $output (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", 'en') heute geändert :)
};

(: ================= End Retrieve single pieces of information ======== :)


(: ================= Html construction routines ========== :)
(:
 : - render xml via xslt
 : - construct highlighting
 : - contruct toc
 : - construct search boxes
 : - construct footer
 :)

declare function app:contactEMailHTML($node as node(), $model as map(*)) {
    <a href="mailto:{$config:contactEMail}">{$config:contactEMail}</a>
};

declare function app:guidelines($node as node(), $model as map(*), $lang as xs:string) {
(:        let $store-lang := session:set-attribute("lang", $lang):)
        if ($lang = ('de', 'en', 'es'))  then
            let $guidelinesId := 'guidelines-' || $lang
            let $parameters :=  <parameters>
                                    <param name="exist:stop-on-warn" value="yes"/>
                                    <param name="exist:stop-on-error" value="yes"/>
                                    <param name="language" value="{$lang}"></param>
                                </parameters>
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          return transform:transform(doc($config:tei-meta-root || "/works-general.xml")/tei:TEI//tei:div[@xml:id eq $guidelinesId], doc(($config:app-root || "/resources/xsl/guidelines.xsl")), $parameters):)
            return transform:transform(doc($config:tei-meta-root || "/works-general.xml")/id($guidelinesId), doc(($config:app-root || "/resources/xsl/guidelines.xsl")), $parameters)
        else()
};

declare function app:sourcesList($node as node(), $model as map(*), $lang as xs:string) {
(:        let $store-lang := session:set-attribute("lang", $lang):)
        if ($lang = ('de', 'en', 'es') and doc-available($config:tei-meta-root || "/sources-list.xml"))  then
            let $parameters :=  <parameters>
                                    <param name="exist:stop-on-warn" value="yes"/>
                                    <param name="exist:stop-on-error" value="yes"/>
                                    <param name="language" value="{$lang}"/>
                                </parameters>
            return transform:transform(doc($config:tei-meta-root || "/sources-list.xml")/tei:TEI/tei:text, doc(($config:app-root || "/resources/xsl/sourcesList.xsl")), $parameters)
        else()
};

(: ------------- Construct Highlighting Boxes -----------
 : TODO:
 : - group bibls, and hightlight them fully
 :)
 (: deprecated? at least, currently not in use... :)
(: TODO: if active again, fields using $model('currentWork') need to be adjusted (see app:loadWorkMetadata) :)
(:declare %templates:default('startnodeId', 'none')
    function app:WRKhiliteBox($node as node(), $model as map(*), $lang as xs:string, $startnodeId as xs:string, $wid as xs:string?, $q as xs:string?) {
(\:      let $store-lang       := session:set-attribute("lang", $lang):\)
      
      let $debug := console:log('$startnodeId = ' || $startnodeId)

      let $work := 
        if (count($model('currentWork'))) then
            $model('currentWork')
        else
            if ($wid) then
                let $debug := console:log('Getting work based on $wid = ' || $config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml." )
                return doc($config:tei-works-root || "/" || sutil:normalizeId($wid) || ".xml")
            else ()
      let $debug := console:log('count($work) = ' || count($work))

      let $workId         := 
        if ($wid) then
            sutil:normalizeId($wid)
        else
            $work/@xml:id
      let $debug := console:log('$workId = ' || $workId)

      let $startnode := $work//*[@xml:id = $startnodeId]
      let $analyze-section  := if ($startnodeId ne 'none') then
                                   if (local-name($startnode) eq "milestone") then
                                        $startnode/ancestor::tei:div[1]
                                    else
                                        $startnode
                               else
                                   $work//tei:text
      let $debug := console:log('$analyze-section = ' || string($analyze-section/@xml:id))

      let $milestone        :=  if ($startnodeId ne 'none') then
                                    if (local-name($startnode) eq "milestone") then
                                        $startnode
                                    else
                                        false()
                                else
                                    false()


      let $analyze-section-title := if (not($milestone)) then
                                        render:sectionTitle($model('currentWork'), $analyze-section[1])
                                    else
                                        render:sectionTitle($model('currentWork'), $milestone)

      let $persons :=
          for $entity in $analyze-section//tei:persName[@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])]
            let $ansetzungsform := app:resolvePersname($entity)
            order by $ansetzungsform
            return
                if ($entity is ($analyze-section//tei:persName[tokenize(string($entity/@ref), ' ')[1] = tokenize(string(@ref), ' ')[1]][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])[1]) then
                    <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;" onclick="highlightSpanClassInText('hi_{translate((tokenize(string($entity/@ref), ' '))[1], ':', '')}',this)"> 
                        <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$ansetzungsform} ({count($analyze-section//tei:persName[@ref][@ref = $entity/@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])})
                    </li>
                else ()

        let $places :=
          for $entity in $analyze-section//tei:placeName[@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])]
            let $ansetzungsform := if ($entity/@key) then string($entity/@key) else normalize-space(string-join($entity//text(), ''))
            order by $ansetzungsform
            return
                if ($entity is ($analyze-section//tei:placeName[(tokenize(string(@ref), ' '))[1] = (tokenize(string($entity/@ref), ' '))[1]][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])[1]) then
                    <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;" onclick="highlightSpanClassInText('hi_{translate((tokenize($entity/@ref, ' '))[1], ':', '')}',this)">
                        <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$ansetzungsform} ({count($analyze-section//tei:placeName[@ref][@ref = $entity/@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])})
                    </li>
                else ()
                
        let $lemma :=
         for $entity in $analyze-section//tei:term[@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])]
            let $ansetzungsform := string($entity/@key)
            order by $ansetzungsform
            return
                if ($entity is ($analyze-section//tei:term[@ref = $entity/@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])[1]) then
                    <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;" onclick="highlightSpanClassInText('hi_{translate($entity/@ref, ':', '')}',this)">
                        <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$ansetzungsform} ({count($analyze-section//tei:term[@ref][@ref = $entity/@ref][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])})
                    </li>
                else ()

        let $titles :=
         for $entity in $analyze-section//tei:bibl[@sortKey][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])]
            let $ansetzungsform := string($entity/@sortKey)
            let $author         := sutil:formatName($entity//tei:persName)
            let $title          := if ($entity//tei:title/@key) then $entity//tei:title/@key else ()
            let $display-title  := if ($author and $title) then
                                       concat($author, ': ', $title)
                                   else
                                        translate($ansetzungsform, '_', ': ')
            order by $ansetzungsform
            return
                if ($entity is ($analyze-section//tei:bibl[@sortKey = $entity/@sortKey][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])[1]) then
                    <li class="menu-toggle" style="list-style-type: none; color:initial; background:initial; box-shadow:initial; border-radius:initial; padding: initial;" onclick="highlightSpanClassInText('hi_{translate($entity/@sortKey, ':', '')}',this)">
                        <span class="glyphicon glyphicon-unchecked" aria-hidden="true"></span>&#xA0;{$display-title} ({count($analyze-section//tei:bibl[@sortKey][@sortKey = $entity/@sortKey][not($milestone) or (. >> $milestone and . << $milestone/following::tei:milestone[1])])})
                    </li>
                else ()

(\: searchTermSection
        let $searchterm :=  if ($q and $model("results")) then
                            <section id="searchTermsSection">
                                <b><i18n:text key="searchterm">Suchbegriff(e)</i18n:text></b>
                                <ul id="searchTermsList">
                                    <li style="list-style-type: none;"><a class="highlighted" onclick="highlightSpanClassInText('searchterm',this)">{$q}: ({count($model("results"))})</a></li>
                                </ul>
                            </section>
                        else ()
    let $output :=
        <div>
<!--
            <section id="switchEditsSection">
                <ul id="switchEditsList">
                    <li style="list-style-type: none;">
                        <span class="original unsichtbar">
                            <a onclick="applyEditMode()">Modernisiert</a>
                        </span>
                        <span class="edited">
                            <a onclick="applyOrigMode()">Diplomatisch</a>
                        </span>
                    </li>
                </ul>
            </section>
:\)


        let $output :=
        <div>
            <h5>{   if (not($startnodeId)) then
                        "To load entities, click on a refresh button in one of the section menu popups..."
                    else if (string($analyze-section/@xml:id) = 'completeWork') then
                        "Entities in the entire work:"
                    else 
                        "Entities in " || $analyze-section-title || ":"
                }
            </h5>

            {if ($startnodeId) then
                <section id="personsSection">
                    <b><i18n:text key="persons">Personen</i18n:text> ({count($persons)})</b>
                    <ul id="personsList">
                        {$persons}
                    </ul>
                </section>
            else ()}
            {if ($startnodeId) then
                <section id="placesSection">
                    <b><i18n:text key="places">Orte</i18n:text> ({count($places)})</b>
                    <ul id="placesList">
                        {$places}
                    </ul>
                </section>
            else ()}
            {if ($startnodeId) then
                <section id="lemmataSection">
                    <b><i18n:text key="lemmata">Lemma</i18n:text> ({count($lemma)})</b>
                    <ul id="lemmataList">
                        {$lemma}
                    </ul>
                </section>
            else ()}
            {if ($startnodeId) then
                <section id="citedSection">
                    <b><i18n:text key="cited">Zitiert</i18n:text> ({count( $titles)})</b>
                    <ul id="citedList">
                        {$titles}
                    </ul>
                </section>
            else ()}
        </div>
    return i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};:)

(: deprecated :)
(:declare (\: %templates:wrap :\)
    function app:WRKhiliteBoxBak($node as node(), $model as map(*), $lang as xs:string, $q as xs:string?) {
(\:      let $store-lang := session:set-attribute("lang", $lang):\)
(\:      if ($model('currentwork')//id($startnodeid)) then
                            $model('currentwork')//id($startnodeid)
                        else
                            $model('currentwork')//tei:text  :\)
(\:      let $startnode := util:expand($model('currentwork')//tei:text) :\)
      let $persons :=
          for $entity in $model('currentWork')//tei:text//tei:persName
            let $ansetzungsform := app:resolvePersname($entity)
            order by $ansetzungsform
            return
                if ($entity is ($model('currentWork')//tei:text//tei:persName[(tokenize(@ref, ' '))[1] = (tokenize($entity/@ref, ' '))[1]])[1]) then
                        <li style="list-style-type: none;"><a onclick="highlightSpanClassInText('hi_{translate((tokenize($entity/@ref, ' '))[1], ':', '')}',this)">{$ansetzungsform} ({count($model('currentWork')//tei:text//tei:persName[@ref = $entity/@ref])})</a></li>
                else ()
      let $places :=
         for $entity in $model('currentWork')//tei:text//tei:placeName
            let $ansetzungsform := string($entity/@key)
            order by $ansetzungsform
            return
                if ($entity is ($model('currentWork')//tei:text//tei:placeName[(tokenize(@ref, ' '))[1] = (tokenize($entity/@ref, ' '))[1]])[1]) then
                    <li style="list-style-type: none;"><a onclick="highlightSpanClassInText('hi_{translate((tokenize($entity/@ref, ' '))[1], ':', '')}',this)">{$ansetzungsform} ({count($model('currentWork')//tei:text//tei:placeName[@ref = $entity/@ref])})</a></li>
                else ()
      let $lemma :=
         for $entity in $model('currentWork')//tei:text//tei:term
            let $ansetzungsform := string($entity/@key)
            order by $ansetzungsform
            return
                if ($entity is ($model('currentWork')//tei:text//tei:term[@ref = $entity/@ref])) then
                     <li style="list-style-type: none;"><a onclick="highlightSpanClassInText('hi_{translate($entity/@ref, ':', '')}',this)">{$ansetzungsform} ({count($model('currentWork')//tei:text//tei:term[@ref = $entity/@ref])})</a></li>
                else ()
      let $titles :=
         for $entity in $model('currentWork')//tei:text//tei:bibl
            let $ansetzungsform := string($entity/@sortKey)
            let $author := $entity/tei:persName
            let $title := $entity/tei:title
            order by $ansetzungsform
            return
                if ($entity is ($model('currentWork')//tei:text//tei:bibl[@sortKey=$entity/@sortKey])) then
                    <li style="list-style-type: none;"><a onclick="highlightSpanClassInText('hi_{translate($entity/@sortKey, ':', '')}',this)">{translate($entity/@sortKey, '_', ' ')}{string($author/@key)}: {string($title)} ({count($model('currentWork')//tei:bibl[@sortKey = $entity/@sortKey])})</a></li>
                else ()
    let $searchterm :=  if ($q and $model("results")) then
                            <section id="searchTermsSection">
                                <b><i18n:text key="searchterm">Suchbegriff(e)</i18n:text></b>
                                <ul id="searchTermsList">
                                    <li style="list-style-type: none;"><a class="highlighted" onclick="highlightSpanClassInText('searchterm',this)">{$q}: ({count($model("results"))})</a></li>
                                </ul>
                            </section>
                        else ()
    let $output :=
        <div>
            <section id="switchEditsSection">
                <ul id="switchEditsList">
                    <li style="list-style-type: none;">
                        <span class="original unsichtbar" style="cursor: pointer;">
                            <a onclick="applyEditMode()">Konstituiert</a>
                        </span>
                        <span class="edited" style="cursor: pointer;">
                            <a onclick="applyOrigMode()">Diplomatisch</a>
                        </span>
                    </li>
                </ul>
            </section>
            {$searchterm}
            <section id="personsSection">
                <b><i18n:text key="persons">Personen</i18n:text></b>
                <ul id="personsList">
                    {if($persons)then $persons else <li>- o -</li>}
                </ul>
            </section>
            <section id="placesSection">
                <b><i18n:text key="places">Orte</i18n:text></b>
                <ul id="placesList">
                    {if($places)then $places else <li> - o - </li>}
                </ul>
            </section>
            <section id="lemmataSection">
                <b><i18n:text key="lemmata">Lemma</i18n:text></b>
                <ul id="lemmataList">
                    {if($lemma)then $lemma else <li> - o - </li>}
                </ul>
            </section>
            <section id="citedSection">
                <b><i18n:text key="cited">Zitiert</i18n:text></b>
                <ul id="citedList">
                    {if($titles)then $titles else <li> - o - </li>}
                </ul>
            </section>
        </div>
    return i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", session:encode-url(request:get-uri()))
};:)


declare function app:WRKtextModus($node as node(), $model as map(*), $lang as xs:string) {
    let $output :=
        <div>
            <section id="switchEditsSection">
                <span class="original unsichtbar" style="cursor: pointer;">
                    <a class="btn btn-link" onclick="applyEditMode()"> <span class="glyphicon glyphicon-eye-open" aria-hidden="true"/>&#xA0;<i18n:text key="diplomatic">Diplomatisch</i18n:text></a>
                </span>
                <span class="edited" style="cursor: pointer;">
                    <a class="btn btn-link" onclick="applyOrigMode()"> <span class="glyphicon glyphicon-eye-open" aria-hidden="true"/>&#xA0;<i18n:text key="constituted">Konstituiert</i18n:text></a>
                </span>
            </section>
        </div>
    return $output
};


(: ------------- Construct TOC Boxes --------------------
 : Construct toc box for the (left margin of the) reading view
 :)
 declare %public function app:AUTtoc($node as node(), $model as map(*)) {
    <div>
        {
        app:print-sectionsAUT($model("currentAuthor")//tei:text/*/(tei:div))
        }
    </div>
};


declare %private function app:print-sectionsAUT($sections as element()*) {
    if ($sections) then
        <ul class="toc tocStyle">
        {
            for $section in $sections
            let $aid:= $section/ancestor::tei:TEI/@xml:id
            let $id := 'author.html?aid='||$aid ||'#'|| $section/tei:head/parent::tei:div[1]/@xml:id
            return
                <li class="tocStyle">
                    <a href="{$id}">{ $section/tei:head/text() }</a>
                    { app:print-sectionsAUT($section/(tei:div)) }
                </li>
        }
        </ul>
    else
        ()
};


declare %public function app:LEMtoc($node as node(), $model as map(*)) {
    <div>
        {
        app:print-sectionsLEM($model("currentLemma")//tei:text/*/(tei:div))
        }
    </div>
};


declare %private function app:print-sectionsLEM($sections as element()*) {
    if ($sections) then
        <ul class="toc tocStyle">
        {
            for $section in $sections
            let $lid:= $section/ancestor::tei:TEI/@xml:id
            let $id := 'lemma.html?lid='||$lid ||'#'|| $section/tei:head/parent::tei:div[1]/@xml:id
            return
                <li class="tocStyle">
                    <a href="{$id}">{ $section/tei:head/text() }</a>
                    { app:print-sectionsLEM($section/(tei:div)) }
                </li>
        }
       </ul>
    else
        ()
};


declare function app:tocGuidelines($node as node(), $model as map(*), $lang as xs:string) {
(:        let $store-lang := session:set-attribute("lang", $lang):)
       
        let $parameters :=  <parameters>
                                <param name="exist:stop-on-warn" value="yes"/>
                                <param name="exist:stop-on-error" value="yes"/>
                                 <param name="modus" value="toc" />
                            </parameters>
        return  if ($lang eq 'de')  then
            transform:transform(doc($config:tei-meta-root || "/works-general.xml")/tei:TEI//tei:div[@xml:id='guidelines-de'], doc(($config:app-root || "/resources/xsl/guidelines.xsl")), $parameters)
        else if  ($lang eq 'en')  then 
            transform:transform(doc($config:tei-meta-root || "/works-general.xml")/tei:TEI//tei:div[@xml:id='guidelines-en'], doc(($config:app-root || "/resources/xsl/guidelines.xsl")), $parameters)
        else if  ($lang eq 'es')  then
            transform:transform(doc($config:tei-meta-root || "/works-general.xml")/tei:TEI//tei:div[@xml:id='guidelines-es'], doc(($config:app-root || "/resources/xsl/guidelines.xsl")), $parameters)
        else()
};


declare function app:tocSourcesList($node as node(), $model as map(*), $lang as xs:string) {
(:        let $store-lang := session:set-attribute("lang", $lang):)
       
        let $parameters :=  <parameters>
                                <param name="exist:stop-on-warn" value="yes"/>
                                <param name="exist:stop-on-error" value="yes"/>
                                <param name="modus" value="toc" />
                                <param name="language" value="{$lang}"/>
                            </parameters>
        return  if ($lang = ('de', 'en', 'es') and doc-available($config:tei-meta-root || "/sources-list.xml"))  then
            transform:transform(doc($config:tei-meta-root || "/sources-list.xml")/tei:TEI/tei:text, doc(($config:app-root || "/resources/xsl/sourcesList.xsl")), $parameters)
        else()
};
 
declare function app:WRKtoc($node as node(), $model as map(*), $wid as xs:string, $q as xs:string?, $lang as xs:string?) {
    let $toc :=
        if ($q) then
            let $tocDoc := doc($config:html-root || '/' || sutil:normalizeId($wid) || '/' || sutil:normalizeId($wid) || '_toc.html')
            (:
            let $xslSheet       := 
                <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                    <xsl:output omit-xml-declaration="yes" indent="yes"/>
                    <xsl:param name="q"/>
                    <xsl:template match="node()|@*" priority="2">
                        <xsl:copy>
                            <xsl:apply-templates select="node()|@*"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="a/@href" priority="80">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="starts-with(., '#')">
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="contains(., '#')">
                                    <xsl:value-of select="replace(., '#', concat('&amp;q=', $q, '#'))"/>
                                </xsl:when>                                                            
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(., '&amp;q=', $q)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:template>
                </xsl:stylesheet>
            let $parameters :=  
                <parameters>
                    <param name="exist:stop-on-warn" value="yes"/>
                    <param name="exist:stop-on-error" value="yes"/>
                    <param name="q" value="{$q}"/>
                </parameters>
            return 
                transform:transform($tocDoc, $xslSheet, $parameters) (\: i18n:process(transform:transform($tocDoc, $xslSheet, $parameters), $lang, $config:i18n-root, 'en') heute geändert :\)
            :)
            return 
                app:copyInsertSearchParam($tocDoc/*, $q)
         else
            doc($config:html-root || '/' || sutil:normalizeId($wid) || '/' || sutil:normalizeId($wid) || '_toc.html')
    return 
        $toc
        (: i18n:process($toc, $lang, $config:i18n-root, 'en') heute geändert :)
};


(:
~ Recursively inserts a "q" query parameter into a/href values of an HTML fragment.
:)

declare %private function app:copyInsertSearchParam($node as node()?, $q as xs:string) {
    typeswitch($node)
        case element(a) return
            element {name($node)} {
                for $att in $node/@* return
                    app:attrInsertSearchParam($att, $q)
                ,
                for $child in $node/node()
                   return app:copyInsertSearchParam($child, $q)
            }
        case element() return
            element {name($node)} {
                for $att in $node/@*
                   return
                      attribute {name($att)} {$att}
                ,
                for $child in $node/node()
                   return app:copyInsertSearchParam($child, $q)
            }
        default return $node
};
declare %private function app:attrInsertSearchParam($attr as attribute(), $q as xs:string) {
    typeswitch($attr)
        case attribute(href) return
            let $value := 
                if (starts-with($attr, '#')) then 
                    $attr/string()
                else if (contains($attr, '#')) then
                    replace($attr, '#', concat('&amp;q=', $q, '#'))
                else 
                    concat($attr, '&amp;q=', $q)
            return attribute {name($attr)} {$value}
        default return
            $attr
};


(:declare function app:downloadTXT($node as node(), $model as map(*), $mode as xs:string, $lang as xs:string) {
    let $wid := request:get-parameter('wid', '')
    let $hoverTitleEdit := i18n:process(<i18n:text key="downloadTXTEdit">Download as plaintext (constituted variant)</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en')
    let $hoverTitleOrig := i18n:process(<i18n:text key="downloadTXTOrig">Download as plaintext (diplomatic variant)</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en')
    
    let $download := 
        if ($wid and ($mode eq 'edit')) then 
            <li><a title="{$hoverTitleEdit}" href="{$config:idserver || '/texts/' || $wid ||'?format=txt&amp;mode=edit'}"><span class="fas fa-align-left" aria-hidden="true"/>&#xA0;TXT (<i18n:text key="constitutedLower">constituted</i18n:text>)</a></li>
        else if ($wid and ($mode eq 'orig')) then 
            <li><a title="{$hoverTitleOrig}" href="{$config:idserver || '/texts/' || $wid ||'?format=txt&amp;mode=orig'}"><span class="fas fa-align-left" aria-hidden="true"/>&#xA0;TXT (<i18n:text key="diplomaticLower">diplomatic</i18n:text>)</a></li>
        else()
    return i18n:process($download, $lang, '/db/apps/salamanca/data/i18n', 'en')
};:)


(: ================= End Html construction routines ========== :)

(:Special GUI: HUD display for work navigation:)
declare %templates:default
    function app:guiWRK($node as node(), $model as map(*), $lang as xs:string, $wid as xs:string*, $q as xs:string?) as element() {    
    let $idUri := $config:idserver || '/texts/' || $wid
    let $downloadXML     :=  app:downloadXML($node, $model, $lang)
    let $downloadTXT :=
        <li class="dropdown-submenu">
            <a title="i18n(txtExp)" href="#">
                <i class="messengers fas fa-align-left"/>{' '}<i18n:text key="txtFiles">Plain text (TXT)</i18n:text>
            </a>
            <ul class="dropdown-menu">
                <li>
                    <a href="{$idUri || '?format=txt&amp;mode=edit'}">
                        <i18n:text key="constitutedLower">constituted</i18n:text>
                    </a>
                </li>
                <li>
                    <a href="{$idUri || '?format=txt&amp;mode=orig'}">
                        <i18n:text key="diplomaticLower">diplomatic</i18n:text>
                    </a>
                </li>
            </ul>
        </li>
    let $downloadRDF     :=  app:downloadRDF($node, $model, $lang)
    (:let $downloadCorpus  :=  app:downloadCorpusXML($node, $model, $lang):)
    let $name            :=  sutil:WRKcombined($node, $model, $wid)
    let $top             :=  'work.html?wid=' || $wid
    let $citeTitle := <i18n:text key="citeThisWork">Cite this work</i18n:text> (: i18n:process(<i18n:text key="citeThisWork">Cite this work</i18n:text>, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
    let $copyLink :=
        <li>
            <a href="#" onclick="copyLink(this); return false;" title="i18n(linkWork)">
                <i class="messengers fas fa-link"/>{' '}<i18n:text key="copyLink"/>
            </a>
            <span class="cite-link" style="display:none;">{$idUri || '?format=html'}</span>
        </li>
    let $copyCitation :=
        <li>
            <a href="#" onclick="copyCitRef(this); return false;" title="i18n(citeWork)">
                <i class="messengers fas fa-feather-alt"/>{' '}<i18n:text key="copyCit"/>
            </a>
            <span class="sal-cite-rec" style="display:none">
                {app:WRKcitationReference($node, $model, $lang, 'reading-full')}
            </span>
        </li>
    
    let $output := 
        
        <div class="container">
            <div class="navbar navbar-white navbar-fixed-top" style="z-index:1; margin-top: 10px">
                <div class="container">
                    <div class="row-fluid" style="margin-top: 0.9%;">
                        <h4 style="margin-top: 5px;" class="pull-left messengers">
                       <!--                                                       title="{$name}"> -->
                       <!-- style="margin-top: 6px; margin-left: 40px"                           > -->
                            <a href="{$top}" title="{concat('(Go to top of)&#x0A;', $name)}"><!-- &#xA0; -->
                                {substring($name, 1, 30)||' ...'}
                            </a>
                        </h4>
                    </div>
                    <div class="row-fluid">
                        <div class="btn-toolbar pull-left">
                            <!-- Hamburger Icon, used in small and eXtra-small views only: substitutes textmode, register, print and export functions -->
                            <div class="btn-group hidden-lg">
                                <button type="button" class="btn btn-link dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                   <i class="fa fa-bars"></i>&#xA0;<i18n:text key="moreb">Mehr</i18n:text>
                                </button>
                                <ul class="dropdown-menu" role="menu">
                                    <!--<li class="disabled"><a><span class="glyphicon glyphicon-stats text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted"><i18n:text key="register">Register</i18n:text></span></a></li>-->
                                    <li><a onclick="applyEditMode()" class="btn original unsichtbar" style="cursor: pointer;"><span class="glyphicon glyphicon-eye-open" aria-hidden="true"/>&#xA0;<i18n:text key="constituted">Konstituiert</i18n:text></a></li>
                                    <li><a onclick="applyOrigMode()" class="btn edited" style="cursor: pointer;"><span class="glyphicon glyphicon-eye-open" aria-hidden="true"/>&#xA0;<i18n:text key="diplomatic">Diplomatisch</i18n:text></a></li>
                                    <li>{app:WRKdetailsCurrent($node, $model, $lang)}</li>
                                    <!--<li class="disabled"><a><span class="glyphicon glyphicon-print text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted"><i18n:text key="print">Drucken</i18n:text></span></a></li>-->
                                    {$copyLink}
                                    {$copyCitation}
                                    {$downloadXML}
                                    {$downloadTXT}
                                    {$downloadRDF}
                                    <li class="disabled"><a><i class="fas fa-file-pdf text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted">PDF</span></a></li>   
                                    <li class="disabled"><a><i class="fas fa-book text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted"> <i18n:text key="ebook">E-book</i18n:text></span></a></li>   
                                </ul>
                            </div>
                            <!--Paginator-Dropdown-->
                            <div class="btn-group">
                                <div class="dropdown">
                                 <button class="btn btn-link dropdown-toggle" type="button" id="dropdownMenu1" data-toggle="dropdown" aria-expanded="true">
                                    <i class="fa fa-anchor"></i>&#xA0;<i18n:text key="page">Seite</i18n:text>&#xA0;
                                    <span class="caret"></span>
                                 </button>
                                  <ul id="loadMeLast" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1"></ul>
                                    {app:loadWRKpagination($node, $model, $wid, $lang, $q)}
                                </div>
                            </div>
                            <!--TOC-Button-->
                            <div class="btn-group">
                                <button type="button" class="btn btn-link" data-toggle="modal" data-target="#myModal">
                                    <i class="fa fa-list-ul" aria-hidden="true"> </i>&#xA0;<i18n:text key="toc">Inhalt</i18n:text>
                                </button>
                            </div>
                            <!--Details Button-->
                            <div class="btn-group hidden-md hidden-sm hidden-xs">
                               {app:WRKdetailsCurrent($node, $model, $lang)}
                            </div>
                        <!-- Textmode, register, print and export functions, in largeish views -->
                            <!--Textmode Button-->
                            <div class="btn-group hidden-md hidden-sm hidden-xs">{app:WRKtextModus($node, $model, $lang)}</div>
                            <div class="btn-group hidden-md hidden-sm hidden-xs">
                                <button type="button" class="btn btn-link dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <span class="glyphicon glyphicon-download-alt" aria-hidden="true"/>&#xA0;<i18n:text key="export">Export</i18n:text>&#xA0;
                                    <span class="caret"/>
                                </button>
                                <ul class="dropdown-menu export-options" role="menu">
                                    {$copyLink}
                                    {$copyCitation}
                                    {$downloadXML}
                                    {$downloadTXT}
                                    {$downloadRDF}
                                    <li class="disabled">
                                        <a><i class="fas fa-file-pdf text-muted" aria-hidden="true"></i> <span class="text-muted"> PDF</span></a>
                                    </li>
                                    <li class="disabled">
                                        <a><i class="fas fa-book text-muted" aria-hidden="true"></i>&#xA0;<span class="text-muted"> <i18n:text key="ebook">E-book</i18n:text></span></a>
                                    </li>
                                </ul>
                            </div>
                            <div class="btn-group">
                                <a class="btn btn-link" href="legal.html"><!--<i class="fa fa-info-circle">--><i class="fas fa-balance-scale"></i>&#32; <i18n:text key="legalShort">Datenschutz&amp;Impressum</i18n:text></a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
    return
        $output
        (: i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "en") heute geändert :)
    
(:  Further buttons / icons:

<!-- Register Button-->
<!--<div class="btn-group hidden-md hidden-sm hidden-xs btn btn-link disabled">
    <span class="glyphicon glyphicon-stats text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted"><i18n:text key="register">Register</i18n:text></span>
</div>-->

<!--Print-Button and Export-Dropdown-->
<!--<div class="btn-group hidden-md hidden-sm hidden-xs btn btn-link disabled">
    <span class="glyphicon glyphicon-print text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted"><i18n:text key="print">Drucken</i18n:text></span>
</div>-->

<!-- Hamburger Icon, used in small views only: substitutes textmode, print and export functions -->
<!--<div class="btn-group hidden-lg hidden-md hidden-xs">
    <button type="button" class="btn btn-link dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
       <i class="fa fa-bars"></i>&#xA0;<i18n:text key="moreb">Mehr</i18n:text>
    </button>
    <ul class="dropdown-menu" role="menu">
        <li>
            <a onclick="applyEditMode()"><span class="glyphicon glyphicon-eye-open" aria-hidden="true"/>&#xA0;<i18n:text key="constituted">Konstituiert</i18n:text></a>
        </li>
        <li>
            <a  onclick="applyOrigMode()"><span class="glyphicon glyphicon-eye-open" aria-hidden="true"/>&#xA0;<i18n:text key="diplomatic">Diplomatisch</i18n:text></a>
        </li>
        <li> 
            <a><span class="glyphicon glyphicon-print text-muted" aria-hidden="true"/>&#xA0;<span class="text-muted"><i18n:text key="print">Drucken</i18n:text></span></a>
        </li>
        {$downloadXML}
        <li> 
            <a href="#"><span class="glyphicon glyphicon-download-alt text-muted" aria-hidden="true"/> <span class="text-muted"> PDF</span></a>
        </li>
    </ul>
</div>-->

:)
};   

(:declare %templates:wrap
    function app:WRKhelp ($node as node(), $model as map(*), $lang as xs:string) {
        let $output :=
            <div class="modal fade" id="myModal2">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                 			<button class="close" data-dismiss="modal" type="button">
                 				<span aria-hidden="true">×</span>
                 				<span class="sr-only"><i18n:text key="close">Schließen</i18n:text></span>
                            </button>
                            <h4 class="modal-title" id="myModalLabel"><i18n:text key="addFunx">Zusatzfunktionen</i18n:text></h4>
                            <p><i18n:text key="onPage">auf dieser Seite</i18n:text></p>
                        </div>
               	        <div class="modal-body">
                  			<p class="lead"><i18n:text key="pages">Anklicken einer blauen Seitenzahl, um die Bilder der Vorlage anzuzeigen:</i18n:text></p> 
                  			<div class="lead">
                  				<a id="pageNo_W0001-C-0004" class="pageNo" href="http://wwwuser.gwdg.de/~svsal/images/W0001/C/W0001-C-0004.jpg" title="Open page: titlePage">p. XI</a>
                  			</div>
                  			<p class="lead"><span class="glyphicon glyphicon-leaf" aria-hidden="true"></span>&#xA0;<i18n:text key="leafText">Anklicken, um die Toolbox für einen Textbereich aufzurufen.</i18n:text></p> 
                  			<img src="resources/img/logos_misc/toolsMenu.png"/>
                  			<br/><br/>
                  			<p class="lead"><span class="glyphicon glyphicon-link" aria-hidden="true"></span>&#xA0;<i18n:text key="bookmarkText">Anklicken, um zu einer bestimmten Stelle zu springen.</i18n:text></p>
                  			<p><i18n:text key="copyURL">Sie können anschließend den Link aus der Browser-Adress-Zeile kopieren.</i18n:text></p>
                  			<br/>
                  			<p class="lead"><span class="glyphicon glyphicon-flag" aria-hidden="true"></span>&#xA0;<i18n:text key="highlightText">Öffnet einen Dialog, in dem Personen, Orte, Lemmata und Literatur ausgewählt und zugleich im Text markiert werden.</i18n:text></p>
               			</div>
                        <div class="modal-footer remove-top">
                          <!-- Make sure to include the 'nothanks' class on the buttons -->
                            <button class="btn btn-default nothanks" data-dismiss="modal" aria-hidden="true"><i18n:text key="dontShow">Nicht mehr anzeigen</i18n:text></button>
                            <button type="button" class="btn btn-default btn-primary" data-dismiss="modal"><i18n:text key="close">Schließen</i18n:text></button>
                        </div>
                    </div>
                </div>
            </div>
        return  i18n:process($output, $lang, "/db/apps/salamanca/data/i18n", "de")   
};:)
                
(: ==== Paginator Function ===== :)

declare function app:loadWRKpagination ($node as node(), $model as map (*), $wid as xs:string, $lang as xs:string, $q as xs:string?) {
    let $pagesFile  :=  doc($config:html-root || '/' || sutil:normalizeId($wid) || '/' || sutil:normalizeId($wid) || '_pages_' || $lang || '.html')
(:    let $dbg := console:log(substring(serialize($pagesFile),1,300)):)
    (:
    let $xslSheet   := 
        <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
            <xsl:output omit-xml-declaration="yes" indent="yes"/>
            <xsl:param name="q"/>
            <xsl:template match="node()|@*" priority="2">
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:copy>
            </xsl:template>
            <xsl:template match="a/@href" priority="80">
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="starts-with(., '#')">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:when test="contains(., '#')">
                            <xsl:value-of select="replace(., '#', concat('&amp;q=', $q, '#'))"/>
                        </xsl:when>                                                            
                        <xsl:otherwise>
                            <xsl:value-of select="concat(., '&amp;q=', $q)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:template>
        </xsl:stylesheet>
    let $parameters :=  
        <parameters>
            <param name="exist:stop-on-warn" value="yes"/>
            <param name="exist:stop-on-error" value="yes"/>
            <param name="q" value="{$q}"/>
        </parameters>
    :)
    return 
        if ($q) then
(:            transform:transform($pagesFile, $xslSheet, $parameters):)
            app:copyInsertSearchParam($pagesFile/*, $q)
        else
            $pagesFile
};

(: Old variants of the pagination loading function that differentiate too much between $q present/absent
declare function app:WRKpaginationQ ($node as node(), $model as map(*), $wid as xs:string?, $q as xs:string?, $lang as xs:string) {
<ul id="later" class="dropdown-menu scrollable-menu" role="menu" aria-labelledby="dropdownMenu1">
{ if ($q) then
    let $workId    :=  if ($wid) then $wid else $model("currentWork")/@xml:id
    for $pb in doc($config:index-root || "/" || $workId || '_nodeIndex.xml')//sal:node[@type="pb"][not(@subtype = ('sameAs', 'corresp'))]
        let $fragment := $pb/sal:fragment
        let $volume   := () (/: if (starts-with($pb/sal:crumbtrail/a[1]/text(), 'Vol. ')) then
                            $pb/sal:crumbtrail/a[1]/text() || ','
                         else () :/)
        let $url      := 'work.html?wid='||$workId || '&amp;' || 'frag='|| $fragment|| '&amp;q=' ||$q|| concat('#', replace($pb/@n, 'facs_', 'pageNo_'))
    return 
        <li role="presentation"><a role="menuitem" tabindex="-1" href="{$url}">{normalize-space($volume || $pb/sal:title)}</a></li>
        else ()
}
</ul>
};
:)

(:==== Common Functions ==== :)

(:get cover image:)
declare %templates:wrap
    function app:cover ($node as node(), $model as map(*), $lang) {
             if ($model('currentWp')//tei:graphic/@url)                 then <img style="width:90%; border-style: solid; border-width:0.1px; border-color:#E7E7E7; height: auto;" src="{$model('currentWp')//tei:graphic/@url}"/>
        else if ($model('currentAuthor')//tei:graphic/@type='noImage')  then <img src="http://placehold.it/250x350/777777/ffffff?text=No+image+available." class="center-block img-rounded img-responsive" />
        else if ($model('currentAuthor'))                               then <img src="{$config:webserver}/exist/rest/apps/salamanca/{$model('currentAuthor')//tei:titlePage//tei:graphic/@url}" class="center-block img-rounded img-responsive" />
        else()
            
};

(:download XML func:)
declare %private 
    function app:downloadXML($node as node(), $model as map(*), $lang as xs:string) {
    let $wid := request:get-parameter('wid', '')
    let $hoverTitle := <i18n:text key="downloadXML">Download TEI/XML source file</i18n:text> (: i18n:process(<i18n:text key="downloadXML">Download TEI/XML source file</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en') heute geändert :)
    let $download := 
        if ($wid) then 
            <li>
                <a title="{$hoverTitle}" href="{$config:idserver || '/texts/' || $wid ||'?format=tei'}">
                    <i class="fas fa-file-code" aria-hidden="true"/>&#xA0;TEI XML
                </a>
            </li>
        (:else if ($model('currentLemma'))  then <li><a title="{$hoverTitle}" href="{$config:teiserver || '/' || $model('currentLemma')/@xml:id}.xml">TEI/XML</a></li>
        else if ($model('currentAuthor')) then <li><a title="{$hoverTitle}" href="{$config:teiserver || '/' || $model('currentAuthor')/@xml:id}.xml">TEI/XML</a></li>:)
        else()
    return $download
};

(:declare function app:downloadCorpusXML($node as node(), $model as map(*), $lang as xs:string) {
    let $hoverTitle := i18n:process(<i18n:text key="downloadCorpus">Download corpus of XML sources</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en')
    let $download   := <li><a title="{$hoverTitle}" href="{$config:idserver ||'/texts?format=tei'}"><span class="glyphicon glyphicon-download-alt" aria-hidden="true"/> ZIP (XML Corpus)</a></li>
    return $download
};:)

declare %private 
    function app:downloadRDF($node as node(), $model as map(*), $lang as xs:string) {
    let $wid      :=  request:get-parameter('wid', '')
    let $hoverTitle := <i18n:text key="downloadRDF">Download RDF/XML data for this work</i18n:text> (: i18n:process(<i18n:text key="downloadRDF">Download RDF/XML data for this work</i18n:text>, $lang, '/db/apps/salamanca/data/i18n', 'en') heute geändert :)
    let $download := 
        if ($wid) then <li><a title="{$hoverTitle}" href="{$config:idserver || '/texts/' || $wid || '?format=rdf'}"><i class="fas fa-code-branch" aria-hidden="true"/>&#xA0;RDF (XML)</a></li>
        (:else if ($model('currentLemma'))  then <li><a title="{$hoverTitle}" href="{$config:dataserver || '/lemmata.' || $model('currentLemma')/@xml:id}.rdf">RDF/XML</a></li>
        else if ($model('currentAuthor')) then <li><a title="{$hoverTitle}" href="{$config:dataserver || '/authors.' || $model('currentAuthor')/@xml:id}.rdf">RDF/XML</a></li>:)
        else()
    return $download
};
 
(:declare function app:scaleImg($node as node(), $model as map(*), $wid as xs:string) {
             if ($wid eq 'W0001') then  'height: 3868, width:  2519'   
        else if ($wid eq 'W0002') then  'height: 2319, width:  1589'   
        else if ($wid eq 'W0003') then  'height: 3464, width:  2395' 
        else if ($wid eq 'W0004') then  'height: 4725, width:  3370' 
        else if ($wid eq 'W0005') then  'height: 3467, width:  2422' 
        else if ($wid eq 'W0006') then  'height: 5524, width:  3408' 
        else if ($wid eq 'W0007') then  'height: 2332, width:  1746' 
        else if ($wid eq 'W0008') then  'height: 3365, width:  2237' 
        else if ($wid eq 'W0010') then  'height: 3409, width:  2313' 
        else if ($wid eq 'W0011') then  'height: 4000, width:  2883' 
        else if ($wid eq 'W0012') then  'height: 3285, width:  2109' 
        else if ($wid eq 'W0013') then  'height: 1994, width:  1297' 
        else if ($wid eq 'W0014') then  'height: 1759, width:  1196' 
        else if ($wid eq 'W0015') then  'height: 1634, width:  1080'  
        else if ($wid eq 'W0039') then  'height: 2244, width:  1536' 
        else if ($wid eq 'W0078') then  'height: 1881, width:  1192' 
        else if ($wid eq 'W0092') then  'height: 4366, width:  2896' 
        else if ($wid eq 'W0114') then  'height: 2601, width:  1674' 
        else ()
};:)


(: legal declarations :)

declare function app:legalDisclaimer ($node as node(), $model as map(*), $lang as xs:string?) {
    let $disclaimerText := <i18n:text key="legalDisclaimer"/> (: i18n:process(<i18n:text key="legalDisclaimer"/>, $lang, '/db/apps/salamanca/data/i18n', 'en') heute geändert :)
    return if ($disclaimerText) then 
        <div style="margin-bottom:1em;border:1px solid gray;border-radius:5px;padding:0.5em;">
            <span>{$disclaimerText}</span>
        </div>
        else ()
};

declare function app:privDecl ($node as node(), $model as map(*), $lang as xs:string?) {
    let $declfile   := doc($config:data-root || "/i18n/privacy_decl.xml")
    let $decltext   := "div-privdecl-de"
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $html       := render-app:dispatch($declfile//tei:div[@xml:id = $decltext], "html", ()):)
    let $html       := render-app:dispatch($declfile/id($decltext), "html", ())
    return if (count($html)) then
        <div id="privDecl" class="help">
            {$html}
        </div>
    else ()
};

declare function app:imprint ($node as node(), $model as map(*), $lang as xs:string?) {
    let $declfile   := doc($config:data-root || "/i18n/imprint.xml")
    let $decltext   := "div-imprint-de"
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:  let $html       := render-app:dispatch($declfile//tei:div[@xml:id = $decltext], "html", ()):)
    let $html       := render-app:dispatch($declfile/id($decltext), "html", ())
    return if (count($html)) then
        <div id="imprint" class="help">
            {$html}
        </div>
    else ()
};

(: Error page functions :)

declare function app:errorCode($node as node(), $model as map(*)) as xs:string? {
    if (request:get-attribute('status-code')) then request:get-attribute('status-code')
    else '404'
};

declare function app:serverErrorMessage($node as node(), $model as map(*)) as xs:string? {
    let $errorMessage := 
        if (normalize-space(request:get-attribute('javax.servlet.error.message')) ne '') then request:get-attribute('javax.servlet.error.message')
(:        else if (normalize-space(templates:error-description($node, $model)) ne '') then templates:error-description($node, $model):)
        else if (normalize-space(request:get-attribute('error-message')) ne '') then request:get-attribute('error-message')
        else 'No description found...'
    return
        if ($config:debug eq 'trace' or $config:instanceMode = ("staging", "testing", "dockernet")) then 
            <div class="error-paragraph">
                <h4 class="error-title">Error message (debugging mode):</h4>
                <div class="error-paragraph"><span>{' ' || $errorMessage}</span></div>
            </div>
        else ()
};

declare %templates:wrap function app:errorTitle($node as node(), $model as map(*), $lang as xs:string?) { 
    let $out :=
        if (request:get-attribute('error-type') eq 'work-not-yet-available') then
            <i18n:text key="workNotYetAvailable">This work is not yet available.</i18n:text>
        else if (request:get-attribute('error-type') eq 'author-not-yet-available') then
            <i18n:text key="authorNotYetAvailable">This article is not yet available.</i18n:text>
        else if (request:get-attribute('error-type') eq 'lemma-not-yet-available') then
            <i18n:text key="lemmaNotYetAvailable">This dictionary article is not yet available.</i18n:text>
        else if (request:get-attribute('error-type') eq 'resource-not-yet-available') then
            <i18n:text key="resourceNotYetAvailable">This resource is not yet available.</i18n:text>
        else 
            <i18n:text key="pageNotFound">This is not the page you were looking for...</i18n:text>
        (:        <p class="error-paragraph"><i18n:text key="bugMessage">In case you found a bug in our website, please let us know at</i18n:text> <a href="mailto:info.salamanca@adwmainz.de">info.salamanca@adwmainz.de</a></p>  :)
    return
        $out
        (: i18n:process($out, $lang, '/db/apps/salamanca/data/i18n', 'en') heute geändert :)
};

(: tightly coupled to app:errorTitle, see above :)
declare %templates:wrap function app:errorInformation($node as node(), $model as map(*), $lang as xs:string?) { 
    if (not(request:get-attribute('error-type') eq 'work-not-yet-available'
            or request:get-attribute('error-type') eq 'author-not-yet-available'
            or request:get-attribute('error-type') eq 'lemma-not-yet-available'
            or request:get-attribute('error-type') eq 'resource-not-yet-available')) then
        <span><i18n:text key="bugMessage">In case you found a bug in our website, please let us know at</i18n:text>{' '}<a href="mailto:info.salamanca@adwmainz.de">info.salamanca@adwmainz.de</a></span>
        (: i18n:process(<span><i18n:text key="bugMessage">In case you found a bug in our website, please let us know at</i18n:text>{' '}<a href="mailto:info.salamanca@adwmainz.de">info.salamanca@adwmainz.de</a></span>, $lang, '/db/apps/salamanca/data/i18n', 'en') heute geändert :)
    else ()
};


(: Participants :)

declare %templates:wrap function app:participantsBody($node as node(), $model as map(*), $lang as xs:string?, $id as xs:string?) {
    let $id := if ($id) then lower-case($id) else if (request:get-parameter('id', '')) then lower-case(request:get-parameter('id', '')) else ()
    let $tei := doc($config:tei-meta-root || '/projectteam.xml')/tei:TEI
    let $body :=
        if ($id = ('directors', 'team')) then
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          for $p at $i in $tei/tei:text//tei:listPerson[@xml:id eq $id]/tei:person return:)
            for $p at $i in $tei/id($id)/tei:person return
                app:makeParticipantTeaser($p, $lang, 'multi', $i)
        else if ($id eq 'cooperators') then
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          for $p at $i in $tei/tei:text//tei:listPerson[@xml:id eq $id]/tei:person return:)
            for $p at $i in $tei/id($id)/tei:person return
                app:makeCooperatorEntry($p, $lang, $i)
        else if ($id = ('advisoryboard', 'former')) then
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:          for $p in $tei//tei:listPerson[@xml:id eq $id]/tei:person return:)
            for $p in $tei/id($id)/tei:person return
                <div style="font-size:1.1em;">
                    <p>{render-app:dispatch($p, 'participants', $lang)}</p>
                    <br/>
                </div>
(: Changed to improve performance on 2025-03-24, A.W.                               :)
(:      else if ($tei//tei:person[@xml:id eq upper-case($id)]) then:)
        else if ($tei/id(upper-case($id))) then
(: Changed to improve performance on 2025-03-24, A.W.                               :)
            let $p := $tei/id(upper-case($id))
            return
                if ($p) then app:makeParticipantEntry($p, $lang, 'single', ()) else ()
        else (: show everything :)
            <div>
                <div>
                    <h2><i18n:text key="projectDirectors"/></h2>
                    {app:participantsBody($node, $model, $lang, 'directors')}
                </div>
                <hr/>
                <div>
                    <h2><i18n:text key="projectTeam"/></h2>
                    {app:participantsBody($node, $model, $lang, 'team')}
                </div>
                <hr/>
                <div>
                    <h2><i18n:text key="projectCooperators"/></h2>
                    {app:participantsBody($node, $model, $lang, 'cooperators')}
                </div>
                <hr/>
                <div>
                    <h2><i18n:text key="projectAdvBoard"/></h2>
                    <br/>
                    {app:participantsBody($node, $model, $lang, 'advisoryboard')}
                </div>
                <hr/>
                <div>
                    <h2><i18n:text key="projectFormer"/></h2>
                    <br/>
                    {app:participantsBody($node, $model, $lang, 'former')}
                </div>
            </div>
    return 
        <div>
            {$body (: i18n:process($body, $lang, $config:i18n-root, 'en') heute geändert :)}
        </div>
        
};

declare %private 
    function app:makeParticipantTeaser($person as element(tei:person), $lang as xs:string, $mode as xs:string, $index as xs:integer?) as element(div) {
    <div class="row">
        <div class="col-md-8">
            <h3>
                <a href="{$config:webserver || '/' || $lang || '/participants.html?id=' || $person/@xml:id}">{string($person/tei:persName/tei:name)}</a>
            </h3>
            <div>
                <h4><i18n:text key="contact">Contact</i18n:text></h4>
                {render-app:passthru($person/tei:persName, 'participants', $lang)}
            </div>
            <div>{render-app:dispatch($person/tei:event[@type eq 'research_interest'], 'participants', $lang)}</div>
        </div>
        <img class="col-md-4" src="resources/img/participants/{$person/@xml:id}.jpg" style="width:230px;padding:2em;"/>
    </div>
};

(:
~ Modes: 'single' if page consists of single entry; 'multi' if page consists of several entries.
:)
declare %private 
    function app:makeParticipantEntry($person as element(tei:person), $lang as xs:string, $mode as xs:string, $index as xs:integer?) as element(div) {
    let $backLink := 
        <a href="{$config:webserver || '/' || $lang || '/participants.html'}" style="font-size:1.5em;padding-bottom:1em;">
            <i class="fas fa-arrow-left"></i>{' '}<i18n:text key="toOverview"/>
        </a>
    (: make list of works edited by the team member :)
    let $scholarlyContrib := 
        for $tei in collection($config:tei-works-root)/tei:TEI[matches(@xml:id, '^W\d{4}$')
            and sutil:WRKisPublished(@xml:id)
            and ./tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[@xml:id eq $person/@xml:id 
                and (contains(@role, 'scholarly'))]] return
            <a href="{$config:idserver || '/texts/' || $tei/@xml:id || '?mode=details'}">{
            app:rotateFormatName($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName) || ': ' ||
            $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'short']/string()
            }</a>
    let $technicalContrib := 
        for $tei in collection($config:tei-works-root)/tei:TEI[matches(@xml:id, '^W\d{4}$')
            and sutil:WRKisPublished(@xml:id)
            and ./tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[@xml:id eq $person/@xml:id 
                and (contains(@role, 'technical'))]] return
            <a href="{$config:idserver || '/texts/' || $tei/@xml:id || '?mode=details'}">{
            app:rotateFormatName($tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName) || ': ' ||
            $tei/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'short']/string()
            }</a>
    
    let $contributions :=
        if ($scholarlyContrib or $technicalContrib) then
            <div>
                <h4><i18n:text key="participantsContrib"/></h4>
                {if ($scholarlyContrib) then 
                    <div>
                    <h5><i18n:text key="scholEditors"/>:</h5>
                    <ul>{
                        for $c in $scholarlyContrib return <li>{$c}</li>
                    }</ul></div>
                else ()}
                {if ($technicalContrib) then 
                    <div>
                    <h5><i18n:text key="techEditors"/>:</h5>
                    <ul>{
                        for $c in $technicalContrib return <li>{$c}</li>
                    }</ul></div>
                else ()}
            </div>
        else ()
    
    let $content :=
        <div>
            <img src="resources/img/participants/{$person/@xml:id}.jpg" style="width:300px;padding:2em;float:right;"/>
            <div>
                <h4><i18n:text key="contact">Contact</i18n:text></h4>
                {render-app:passthru($person/tei:persName, 'participants', $lang)}
            </div>
            {for $e in $person/tei:persName/following-sibling::*[not(@xml:lang) or @xml:lang eq $lang] return 
                 render-app:dispatch($e, 'participants', $lang)}
            {$contributions}
            <br/>{$backLink}<br/>
        </div>
    return $content
};
declare function app:makeCooperatorEntry($person as element(tei:person), $lang as xs:string, $index as xs:integer?) as element(div) {
    let $content :=
        <div>
            <h3>{string($person/tei:persName/tei:name)}</h3>
            <div>
                {render-app:passthru($person/tei:persName, 'participants', $lang)}
            </div>
            {for $e in $person/tei:persName/following-sibling::*[not(@xml:lang) or @xml:lang eq $lang] return 
                 render-app:dispatch($e, 'participants', $lang)}
        </div>
    return $content
};
