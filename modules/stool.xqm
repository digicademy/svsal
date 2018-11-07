xquery version "3.1";

(:~
 : Salamanca Tools XQuery-Module
 : This module contains generic, low-profile helper functions.
 :
 : - format a persName element, depending on the presence of forename/surname sub-elements
 : - resolve Names with online authority files
 : - dummy test function
 :
 : For doc annotation format, see
 : - https://exist-db.org/exist/apps/doc/xqdoc
 :
 : For testing, see
 : - https://exist-db.org/exist/apps/doc/xqsuite
 : - https://en.wikibooks.org/wiki/XQuery/XUnit_Annotations
 :
 : @author Andreas Wagner
 : @author David Glück
 : @author Ingo Caesar
 : @version 1.0
 :
 :)

module namespace stool                  = "http://salamanca.school/ns/stool";

declare namespace exist                 = "http://exist.sourceforge.net/NS/exist";
declare namespace httpclient            = "http://exist-db.org/xquery/httpclient";
declare namespace srw                   = "http://www.loc.gov/zing/srw/";
declare namespace tei                   = "http://www.tei-c.org/ns/1.0";
declare namespace test                  = "http://exist-db.org/xquery/xqsuite";
import module namespace config          = "http://salamanca.school/ns/config"                at "config.xqm";

(:~
 : format list of name TEI elements as a continuous string: family name, "comma", given name, separated by ampersands.
 : 
 :  @param $persName the list of persName elements to re-format 
 :  @return the string of person's names if succesful, the empty sequence otherwise
~:)
declare
    %test:arg("persName", <tei:persName key="Bar,   Foo ">Bla</tei:persName>)
    %test:assertEquals("Bar, Foo")
function stool:formatName($persName as element()*) as xs:string? {
    let $return-string := for $pers in $persName
                                return
                                        if ($pers/@key) then
                                            normalize-space(xs:string($pers/@key))
                                        else if ($pers/tei:surname and $pers/tei:forename) then
                                            normalize-space(concat($pers/tei:surname, ', ', $pers/tei:forename, ' ', $pers/tei:nameLink, if ($pers/tei:addName) then ('&amp;nbsp;(' || $pers/tei:addName || ')') else ()))
                                        else if ($pers) then
                                            normalize-space(xs:string($pers))
                                        else 
                                            normalize-space($pers/text())
    return (string-join($return-string, ' &amp; '))
};

(:~
 : format list of name TEI elements as a continuous string: given name and family name, without "comma", separated by ampersands.
 : 
 :  @param $persName the list of persName elements to re-format 
 :  @return the string of person's names if succesful, the empty sequence otherwise
~:)
declare
    %test:arg("persName", <tei:persName key="Bar,   Foo "><tei:forename>Foo</tei:forename><tei:surname>Bar</tei:surname></tei:persName>)
    %test:assertEquals("Foo Bar")
function stool:rotateFormatName($persName as element()*) as xs:string? {
    let $return-string := for $pers in $persName
                                return
                                        if ($pers/tei:surname and $pers/tei:forename) then
                                            normalize-space(concat($pers/tei:forename, ' ', $pers/tei:nameLink, ' ', $pers/tei:surname, if ($pers/tei:addName) then ($config:nbsp || '<' || $pers/tei:addName || '>') else ()))
                                        else if ($pers) then
                                            normalize-space(xs:string($pers))
                                        else 
                                            normalize-space($pers/text())
    return (string-join($return-string, ' &amp; '))
};

declare
function stool:resolvePersname($persName as element()*) {
    if ($persName/@key)
         then string($persName/@key)
    else if (contains($persName/@ref, 'cerl:')) then
        let $url := "http://sru.cerl.org/thesaurus?version=1.1&amp;operation=searchRetrieve&amp;query=identifier=" || tokenize(tokenize($persName/@ref, 'cerl:')[2], ' ')[1]
        let $result := httpclient:get(xs:anyURI($url), true(), ())
        let $cerl := $result//srw:searchRetrieveResponse/srw:records/srw:record[1]/srw:recordData/*:record/*:info/*:display/string()
        return if ($cerl) 
               then $cerl
               else if ($persName/@key)
                    then string($persName/@key)
                    else stool:formatName($persName)
    else stool:formatName($persName)
};

(: Todo: Do we need the following? :)
declare
function stool:resolveURI($string as xs:string*) {
    let $tei2htmlXslt   := doc($config:app-root || '/resources/xsl/extract_elements.xsl')
    for $id in $string
        let $doc := <div><a xml:id="{$id}" ref="#{id}">dummy</a></div>
        let $xsl-parameters :=  <parameters>
                        <param name="targetNode" value="{$id}" />
                        <param name="targetWork" value="" />
                        <param name="mode"       value="url" />
                    </parameters>
                    return xs:string(transform:transform($doc, $tei2htmlXslt, $xsl-parameters))
};

declare
function stool:sectionTitle ($targetWork as node()*, $targetNode as node()) {
    let $targetWorkId := string($targetWork/tei:TEI/@xml:id)
    let $targetNodeId := string($targetNode/@xml:id)
    return normalize-space(
    (: div, milestone, items and lists are named according to //tei:term[1]/@key, ./head, @n, ref->., @xml:id :)
            if (local-name($targetNode) = ('div', 'milestone', 'item', 'list')) then
                if ($targetNode/self::tei:item and $targetNode/parent::tei:list/@type='dict' and $targetNode//tei:term[1]/self::attribute(key)) then
                    concat('dictionary entry: &#34;',
                            concat($targetNode//tei:term[1]/@key,
                                    if        (count($targetNode/parent::tei:list/tei:item[.//tei:term[1]/@key eq $targetNode//tei:term[1]/@key]) gt 1) then
                                        concat('-', count($targetNode/preceding::tei:item[tei:term[1]/@key eq $targetNode//tei:term[1]/@key] intersect $targetNode/ancestor::tei:div[1]//tei:item[tei:term[1]/@key eq $targetNode//tei:term[1]/@key]) + 1)
                                    else ()
                                  ),
                           '&#34;'
                          )
                else if ($targetNode/@n and not(matches($targetNode/@n, '^[0-9]+$'))) then
                    string($targetNode/@n)
                else if ($targetNode/tei:head) then
                    let $headString := normalize-space(string-join($targetNode/tei:head[1], ''))
                    return if (string-length($headString) gt $config:chars_summary) then
                        concat($targetNode/@type, ' &#34;', normalize-space(substring($headString, 1, $config:chars_summary)), '…', '&#34;')
                    else
                        concat($targetNode/@type, ' &#34;', $headString, '&#34;')
                else if ($targetNode/@n and (matches($targetNode/@n, '^[0-9]+$')) and ($targetNode/@type|$targetNode/@unit)) then
                    concat(($targetNode/@type | $targetNode/@unit)[1], ' ', $targetNode/@n)
                else if ($targetNode/@n and (not(matches($targetNode/@n, '^[0-9]+$'))) and ($targetNode/@unit)) then
                    concat($targetNode/@unit[1], ' ', $targetNode/@n)
                else if ($targetWork/tei:ref[@target = concat('#', $targetNode/@xml:id)]) then
                    let $referString := normalize-space(string-join($targetWork/tei:ref[@target = concat('#',$targetNode/@xml:id)][1]/text(), ''))
                    return if (string-length($referString) gt $config:chars_summary) then
                        concat(($targetNode/@type | $targetNode/@unit)[1], ' ', $targetNode/@n, ': &#34;', normalize-space(substring($referString, 1, $config:chars_summary)), '…', '&#34;')
                    else
                        concat(($targetNode/@type | $targetNode/@unit)[1], ' ', $targetNode/@n, ': &#34;', $referString, '&#34;')
                else
                    string($targetNode/@xml:id)
    (: p's are names according to their beginning :)
            else if ($targetNode/self::tei:p) then
                if (string-length(string-join($targetNode, '')) gt $config:chars_summary) then
                    concat('Paragraph &#34;', normalize-space(substring(string-join($targetNode//text(), ''), 1, $config:chars_summary)), '…', '&#34;')
                else
                    concat('Paragraph &#34;', normalize-space(string-join($targetNode//text(), '')), '&#34;')
            else if ($targetNode/self::tei:text and $targetNode/@type='work_volume') then
                concat('Vol. ', $targetNode/@n)
            else if ($targetNode/self::tei:text and $targetNode/@xml:id='complete_work') then
                'complete work'
            else if ($targetNode/self::tei:text and matches($targetNode/@xml:id, 'work_part_[a-z]')) then
                '(process-technical) part ' | substring(string($targetNode/@xml:id), 11, 1)
    (: notes are named according to @n (with a counter if there are several in the div) or numbered :)
            else if ($targetNode/self::tei:note) then
                if ($targetNode/self::attribute(n)) then
                    concat('Note ', normalize-space($targetNode/@n),
                            if (count($targetNode/ancestor::tei:div[1]//tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($targetNode/@n))]) gt 1) then
                                concat('-', count($targetNode/preceding::tei:note[upper-case(normalize-space(@n)) eq upper-case(normalize-space($targetNode/@n))] intersect $targetNode/ancestor::tei:div[1]//tei:note) + 1)
                            else 
                                ()
                          )
                else
                    concat('Note ', 
                            string(count($targetNode/preceding::tei:note intersect $targetNode/ancestor::tei:div[1]//tei:note) + 1))
            else if ($targetNode/self::tei:pb) then
                if ($targetNode/@sameAs) then
                    concat('sameAs_', string($targetNode/@n))
                else if ($targetNode/@corresp) then
                    concat('corresp_', string($targetNode/@n))
                else
                    let $volumeString := if ($targetNode/ancestor::tei:text[@type='work_volume']) then concat('Vol. ', $targetNode/ancestor::tei:text[@type='work_volume']/@n, ', ') else ()
                    return if (contains($targetNode/@n, 'fol.')) then concat($volumeString, ' ', $targetNode/@n)
                    else concat($volumeString, 'p. ', $targetNode/@n)
            else if ($targetNode/self::tei:titlePart || $targetNode/self::tei:titlePage) then
                "Titulus"
            else if ($targetNode/self::tei:frontmatter) then
                "frontmatter"
            else if ($targetNode/self::tei:backmatter) then
                "backmatter"
            else if ($targetNode/self::tei:lb) then
                concat('Beginning of line ', $targetNode/@n)
            else if ($targetNode/self::tei:pb) then
                concat('Beginning of page ', $targetNode/@n)
            else
                concat('Non-titleable node (', local-name($targetNode), ' ', $targetNode/@xml:id, ')')
            )
};

declare
function stool:workCount($node as node(), $model as map (*), $lang as xs:string?) {
    count($model("listOfWorks"))
};

declare
function local:docSubjectname($id as xs:string) as xs:string? {
        switch (substring($id, 1, 2))
            case 'A0'
                return if (doc-available($config:tei-authors-root || '/' || $id || '.xml')) then 
                    config:formatName(doc($config:tei-authors-root || '/' || $id || '.xml')//tei:listPerson/tei:person[1]/tei:persName)
                else ()
            case 'W0'
                return if (doc-available($config:tei-works-root || '/' || $id || '.xml')) then
                    string-join(doc($config:tei-works-root || "/" || $id || ".xml")//tei:sourceDesc//tei:author/tei:persName/tei:surname, ', ') ||
                                   ': ' || doc($config:tei-works-root || "/" || $id || ".xml")//tei:sourceDesc//tei:title[@type = 'short']/string()
                else ()
            case 'L0'
                return if (doc-available($config:tei-lemmata-root || '/' || $id || '.xml')) then
                    doc($config:tei-lemmata-root || '/' || $id || '.xml')//tei:titleStmt//tei:title[@type = 'short']/string()
                else ()
            case 'WP'
                return if (doc-available($config:tei-workingpapers-root || '/' || $id || '.xml')) then
                    doc($config:tei-workingpapers-root || '/' || $id || '.xml')//tei:titleStmt/tei:title[@type = 'short']/string()
                else ()
            default return ()
};

declare
    %templates:wrap
 function stool:test($node as node(), $model as map(*), $lang as xs:string?) {
        <p>
  <!--  request:get-uri(): {request:get-uri()}<br/>
        $config:app-root: {$config:app-root}<br/>
        $config:data-root: {$config:data-root}<br/>
        (cerl:cnp00396685)[1]: {($model('currentWork')//tei:text//tei:persName[@ref='cerl:cnp00396685'])[1]}<br/> -->
        resolvePersname('cerl:cnp00396685')<br/>[1]: {string(stool:resolvePersname(($model('currentWork')//tei:persName[@ref='cerl:cnp00396685'])[1]))}<br/>
  <!--  lang variable: {$lang}<br/>
        tei:text nodes: {$model('currentWork')//tei:text/@xml:id/string()} -->
        </p>
};
