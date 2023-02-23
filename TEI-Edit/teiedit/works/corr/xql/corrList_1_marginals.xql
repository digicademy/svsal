xquery version "3.1";

declare namespace functx = "http://www.functx.com";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

import module namespace corr = "https://api.salamanca.school/xquery/corr" at "corr.xql";

declare option output:omit-xml-declaration "yes";
declare option output:encoding "utf-8";
declare option output:indent "yes";
(:declare option output:media-type "application/xhtml";:)

declare variable $language as xs:string external;

(: WARNING: the extraction of correction instances for marginals is still experimental and needs to be checked by working with the lists. 
Special focus should lie on the correct separation of marginals. 

:)

(: INFO: in order for this query to work correctly, the following preconditions must be satisfied:
    - hyphen-marked hyphenations must already have been resolved in the original work XML file (by means of lb/@break[. eq 'no']) 
    - all lb and all pb elements must have @xml:id 
    - pb and lb must have valid @sameAs values, if any
:)


(: ==================================================================================================== :)

(: FUNCTX HELPER FUNCTIONS :)

declare function functx:distinct-deep($nodes as node()*) as node()* {
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(.,$nodes[position() < $seq]))]
};
 declare function functx:is-node-in-sequence-deep-equal($node as node()? ,$seq as node()*) as xs:boolean {
    some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
};

(: ==================================================================================================== :)


(: LIST CREATION :)

(: 0.) get text and main language :)
let $workId := if (/tei:TEI/@xml:id) then /tei:TEI/@xml:id else error()
let $lang := if ($language = ('es', 'la')) then $language else error()
let $text := /tei:TEI/tei:text
let $marginals := $text//*[@place eq 'margin' and (@xml:lang eq $lang or (not(@xml:lang) and ancestor::*[@xml:lang][1]/@xml:lang eq $lang))] 
(: selecting only marginals in the given language :)

(: 1.) Store lb nodes and respective text nodes for each tei:*[@place eq 'margin'] :) 
let $margNodes :=   <nodesPerMarginal>{
                        for $marg in $marginals return 
                            <marginal>{
                                for $node in $marg//node() return
                                    if ($node/self::text() or $node/self::tei:lb) then
                                        (: in case there are foreign tags or other-language-tagged elements within the node, omit their content :)
                                        if (ancestor::*[@xml:lang][1]/@xml:lang ne $lang) then ()
                                        (: omit original text (edited text units shouldn't yield any results - or if they do, they need to be revised): :)
                                        else if ($node[ancestor::tei:choice and (ancestor::tei:abbr or ancestor::tei:sic or ancestor::tei:orig)]) then ()
                                        else 
                                            if ($node/self::tei:lb) then $node
                                            else (: return text nodes, but only if they are not just \n - TODO: omit all nodes that solely consist of \s? :)
                                                if (not(matches($node, '^\n$'))) then <text>{$node}</text> else ()
                                    else ()
                            }</marginal>
                    }</nodesPerMarginal>


(: 2.) Get tokens for the lines' text nodes and identify breaking lb elements: <line>, containing <lb> followed by <text> containing tokens (<tok>) :)
(: first round: create <line> strucutre and primarily identify tokens :)
let $margLines0 :=   <linesPerMarginal>{
                    for $marg in $margNodes/marginal return
                        <marginal>{
                            for $n in $marg/* return
                                if ($n/self::tei:lb) then
                                    let $thisLbWithBreak := corr:getBreak($n)
                                    let $followingLb := $n/following-sibling::tei:lb[1]
                                    let $followingLbWithBreak := if ($followingLb) then corr:getBreak($followingLb) else ()
                                    (: getting the line's text, omitting note anchors (probably there aren't any within marginals, but anyway...) :)
                                    let $lineText := (: usual case: line is in between two lb elements :)
                                                     if ($followingLb) then
                                                         string-join(($n/following-sibling::text[not(@type eq 'note-anchor')]/text() 
                                                                      intersect $followingLb/preceding-sibling::text[not(@type eq 'note-anchor')]/text()), '')
                                                     (: only relevant for the last line (?), which has no subsequent lb element: :)
                                                     else string-join($n/following-sibling::text[not(@type eq 'note-anchor')]/text(), '')
                                    (: first round: plain tokenization of the line's text string :)
                                    let $tokens := <tokens>{corr:tokenizeLine($lineText)}</tokens>
                                    (: second round: determine the token type ("simple" = not interfering with lb; "complex" = possibly spanning across the preceding/following lb) :)
                                    let $tokensProc := for $tok in $tokens/* return <tok type="{corr:getTokenType($tok, $thisLbWithBreak, $followingLbWithBreak)}">{$tok/text()}</tok>
                                    return <line>{($thisLbWithBreak, <text>{$tokensProc}</text>)}</line>
                                else ()
                        }</marginal>
                    }</linesPerMarginal>
                    
(: second round: re-process the created structure, identifying "complex" tokens that are actually "simple". This is the case if:
    a) the adjacent token is of type "hyphenated"
    b) the adjacent line has no text/token nodes (<text/>)
    c) there is no adjacent line whatsoever (first and last line)
    d) a previous complex token begins lowercased, while the next complex token begins uppercased
    
    Also, some simple tokens might be complex, see below.
    :)
let $margLines1 :=   <lines>{
                        for $marg in $margLines0/marginal return
                            <marginal>{
                                for $l in $marg/* return
                                    (: TODO: if there is only one token that has been tagged as "simple" and any of the adjacent 
                                        ones is tagged as "complex", it should be complex, too :)
                                    if ($l/text/tok[@type eq "complex"]) then
                                        let $tokNumber := count($l/text/tok)
                                        let $newL := 
                                            if ($tokNumber le 1) then $l (: single-token lines are not taken into account atm... (TODO?) :)
                                            else
                                                let $lb := $l/lb
                                                let $firstTok := if ($l/text/tok[1][@type eq 'complex']) then 
                                                                     if (not($l/preceding-sibling::line)
                                                                         or not($l/preceding-sibling::line[1]/text/tok)
                                                                         or $l/preceding-sibling::line[1]/text/tok[last()][@type eq 'hyphenated']
                                                                         ) then
                                                                         <tok type="simple">{$l/text/tok[1]/text()}</tok>
                                                                     else $l/text/tok[1]
                                                                 else $l/text/tok[1]
                                                let $lastTok := if ($l/text/tok[$tokNumber][@type eq 'complex']) then 
                                                                    if (not($l/following-sibling::line)
                                                                        or not($l/following-sibling::line[1]/text/tok)
                                                                        or $l/following-sibling::line[1]/text/tok[1][@type eq 'hyphenated']) then
                                                                        <tok type="simple">{$l/text/tok[$tokNumber]/text()}</tok>
                                                                    else $l/text/tok[$tokNumber]
                                                                else $l/text/tok[$tokNumber]
                                                let $interToks := $l/text/tok[position() gt 1 and position() lt $tokNumber]
                                                let $tokens := <text>{($firstTok, $interToks, $lastTok)}</text>
                                                return 
                                                    <line>{
                                                        ($lb, $tokens)
                                                    }</line>
                                                return $newL
                                    else $l
                        }</marginal>
                    }</lines>


(: finally, flatten $margLines structure (omit "marginal" level) here, since we have integrated all necessary information about marginal beginnings/endings :)
let $margLines := <lines>{$margLines1/marginal/line}</lines>


(: 3.) import dictionary for the given language :)

let $dict := corr:importDict($lang) 


(: 4.) Token-dictionary comparison :)

(: there are generally 8 types of wordforms with regards to the correction process:
    - simple_ok: wordform not interrupted by break, found in the dictionary -> ok, no processing/editing required (ok)
    - simple_not_found: wordform not interrupted by break, but NOT found in the dictionary -> needs to be checked manually (not_ok)
    - hyphen_ok: concatenated wordform interfering with break, but already tagged as such (i.e., as hyphenation marked by hyphen) AND found in dictionary 
                 -> ok, no processing/editing required (tr_ok?)
    - hyphen_not_found: wordform interrupted by break AND already tagged as such (i.e., as hyphenation marked by hyphen), but
                        not found in dictionary -> needs to be checked manually (_?)
    - comp_hyph: wordform(s) interrupted by break and NOT tagged as a single wordform, but found in dictionary in concatenated form (whereas the single parts of the 
                 wordform were not (all) found in the dict -- this is the case even if one of the two parts was found in the dict) 
                 -> concatenated wordform, to be tagged automatically as break='no' and rendition='noHyphen' (nohyph)
    - comp_hyph_intext: wordform(s) interrupted by break and NOT tagged as a single wordform, but the concatenation of both parts also occurs 
                        as an inline or markedly hyphenated wordform in the text, such that automatic hyphenation resolving (in a post-processing step) is suggested.
    - comp_nohyph_ok: wordform(s) interrupted by break and NOT tagged as a single wordform, but the single tokens of which the conc. wordform consists 
                      were both found in the dictionary (unlike the concatenated wordform) -> ok, no processing/editing required (tr_ok)
    - comp_hyph_nohyph: wordform(s) interrupted by break and NOT tagged as a single wordform, with the concatenated form as well as (both) the single 
                        parts occurring in the dictionary -> must be revised and edited manually (nohy_hy)
    - comp_not_found: wordform(s) interrupted by break and NOT tagged as a single wordform, with neither the concatenated form nor all of the single 
                        parts occurring in the dictionary -> must be revised and edited manually
    Hence, if the type label contains the "_ok" suffix, no correction is necessary.
:)

(: a) simple (and most frequent) case: single-line forms :)
let $simpleTokens := distinct-values($margLines//tok[@type eq 'simple'])
let $simpleEntries := 
    for $tok in $simpleTokens return
        let $token := $tok
        let $wordformDict := corr:getWordformFromDict($tok, $dict)
        let $lemma := if ($wordformDict) then map:get($dict, $wordformDict) else ()
        let $tokenField :=   if ($wordformDict) then <td bgcolor="{$corr:color-ok}">{$token}</td>
                             else <td bgcolor="{$corr:color-ambiguous}">{$token}</td>
        let $wordformDictField :=   if ($wordformDict) then <td bgcolor="{$corr:color-ok}">{$wordformDict}</td>
                                    else <td bgcolor="{$corr:color-not-found}"> ? </td>
        let $hyph1Field := <td> - </td>
        let $hyph2Field := <td> - </td>
        let $lemmaField :=  if ($lemma and $lemma ne 'N/A') then <td bgcolor="{$corr:color-ok}">{$lemma}</td>
                            else <td bgcolor="{$corr:color-not-found}"> ? </td>
        let $freq := count($margLines//tok[@type eq 'simple' and . eq $tok])
        let $freqField := <td bgcolor="{$corr:color-additional}">{string($freq)}</td>
        let $links := for $tok in $margLines//tok[@type eq 'simple' and . eq $tok] return
                              let $id := $tok/parent::text/preceding-sibling::lb[1]/@xml:id
                              let $pb := $text//tei:lb[@xml:id eq $id]/preceding::tei:pb[not(@sameAs) and not(ancestor::*[@place eq 'margin'])][1]
                              let $imgUrl := corr:makeImageUrl($pb/@facs) (:in case there is a problem with the urls variable $imgUrl, this line can be commented, so it works without them.:)
                              (: marginals are stored, for now, in a subdir :)
                              let $aElems := (<a href="{'../../xml/' || $workId || '_corr.xml#' || $id}">{$id/string()}</a>, 
                                              <a href="{$imgUrl}">img</a>)(:in case there is a problem with the urls $imgUrl, ", <a href="{$imgUrl}">img</a>" can be commented, so it works without them.:)
                              return $aElems
        let $class := if ($wordformDict) then 'simple_ok' else 'simple_not_found'
        let $linksField := if (not(contains($class, '_ok'))) then 
                              if ($freq gt 1) then <td bgcolor="{$corr:color-additional}">{for $l at $i in $links return if ($l/text() eq 'img' and not($i eq count($links))) then ($l, <br/>) else $l}</td>
                              else <td bgcolor="{$corr:color-additional}">{$links}</td>
                          else <td bgcolor="{$corr:color-additional}"/> (: we don't need links when everything is ok :)
        return <tr class="{$class}">{($tokenField, $wordformDictField, $hyph1Field, $hyph2Field, $lemmaField, $freqField, $linksField)}</tr>
        
(: shall we include not only 'simple' forms, but also forms marked as 'hyphenated' or 'complex' that occur without a 
    matching 'hyphenated' or 'complex' partner token for some reason? :)

(: b) hyphenated forms :)
(: create a sequence of "hyphToken" nodes, with each "hyphToken" containing two tokens / token parts and the lb in between :)
(: TODO: check if this works: tokens should be safely tagged as simple/hyphenated at this point, so that marginal structure should not 
be necessary here any more:)
let $hyphenatedTokens := for $lb in $margLines//lb[@break eq 'no'] return 
                                            <hyphToken>{
                                                ($lb/parent::line/preceding-sibling::line[1]/text/tok[last()][@type eq 'hyphenated'],
                                                $lb,
                                                $lb/following-sibling::text[1]/tok[1][@type eq 'hyphenated'])
                                             }</hyphToken>
(: get distinct hyphenations by removing the (unique) lb :)
let $hyphenatedForms := functx:distinct-deep(for $hyphTok in $hyphenatedTokens return <hyphForm>{($hyphTok/tok[1], $hyphTok/tok[2])}</hyphForm>)                                         

(: #### START DEBUGGING SECTION :)
let $unpairedHyphenations := $margLines//lb[@break eq 'no' and (parent::line/preceding-sibling::line[1]/text/tok[last()][not(@type eq 'hyphenated')]
                                                                 or following-sibling::text[1]/tok[1][not(@type eq 'hyphenated')])]
let $unmarkedHyphenations := $margLines//lb[not(@break eq 'no') and (parent::line/preceding-sibling::line[1]/text/tok[last()][@type eq 'hyphenated']
                                                                    or following-sibling::text[1]/tok[1][@type eq 'hyphenated'])]
let $debugHyphenated1 := if ($unpairedHyphenations) then 
                            error(xs:QName("UnpairedHyphenation"), "Found lb marked as break='no' without being preceded AND followed by a token marked as 'hyphenated': " 
                                                                   || string-join($unpairedHyphenations//@xml:id, ' | '))
                         else ()
let $debugHyphenated2 := if ($unmarkedHyphenations) then 
                            error(xs:QName("UnpairedHyphenation"), "Found lb NOT marked as break='no' although the preceding or following token is marked as 'hyphenated':" 
                                                                   || string-join($unmarkedHyphenations//@xml:id, ' | '))
                         else ()
(: #### END DEBUGGING SECTION :)


let $hyphenEntries := 
    for $hyphSeq in $hyphenatedForms return
        (: NOTE: if the following throws an error, there are tokens marked as hyphenated without adjacent hyphenated token... :)
        let $tok1 := $hyphSeq/tok[1]/text()
        let $tok2 := $hyphSeq/tok[2]/text()
        let $token := $tok1 || $tok2
        let $wordformDict := corr:getWordformFromDict($token, $dict)
        let $lemma := if ($wordformDict) then map:get($dict, $wordformDict) else ()
        let $hyph1Field := <td> - </td>
        let $hyph2Field := <td> - </td>
        let $tokenField :=  if ($wordformDict) then <td bgcolor="{$corr:color-ok}">{$tok1 || ' - ' || $tok2}</td>
                            else <td bgcolor="{$corr:color-ambiguous}">{$tok1 || ' - ' || $tok2}</td>
        let $wordformDictField :=   if ($wordformDict) then <td bgcolor="{$corr:color-ok}">{$wordformDict}</td>
                                    else <td bgcolor="{$corr:color-not-found}"> ? </td>
        let $lemmaField :=  if ($lemma and $lemma ne 'N/A') then <td bgcolor="{$corr:color-ok}">{$lemma}</td>
                            else <td bgcolor="{$corr:color-not-found}"> ? </td>
        let $allInstances := $hyphenatedTokens//lb[preceding-sibling::*[1]/self::tok[./text() eq $tok1] and following-sibling::*[1]/self::tok[./text() eq $tok2]]
        let $freq := count($allInstances)
        let $freqField := <td bgcolor="{$corr:color-additional}">{string($freq)}</td>
        let $links := for $lb in $allInstances return
                              (: with lb-separated tokens, we need to go to the lb of the line in which the first token occurs :)
                              let $thisId := $lb/@xml:id
                              let $id := $text//tei:lb[@xml:id eq $thisId]/preceding::tei:lb[not(@sameAs)][1]/@xml:id
                              let $pb := $text//tei:lb[@xml:id eq $id]/preceding::tei:pb[not(@sameAs) and not(ancestor::*[@place eq 'margin'])][1]
                              let $imgUrl := corr:makeImageUrl($pb/@facs) (:in case there is a problem with the urls variable $imgUrl, this line can be commented, so it works without them.:)
                              let $idLink := '../../xml/' || $workId || '_corr.xml#' || $id
                              let $aElems := (<a href="{$idLink}">{$id/string()}</a>, 
                                              <a href="{$imgUrl}">img</a>) (:in case there is a problem with the urls $imgUrl, ", <a href="{$imgUrl}">img</a>" can be commented, so it works without them.:)
                              return $aElems
        let $class := if ($wordformDict) then 'hyphen_ok' else 'hyphen_not_found'
        let $linksField := if ($class ne 'hyphen_ok') then
                              if ($freq gt 1) then <td bgcolor="{$corr:color-additional}">{for $l at $i in $links return if ($l/text() eq 'img' and not($i eq count($links))) then ($l, <br/>) else $l}</td>
                              else <td bgcolor="{$corr:color-additional}">{$links}</td>
                          else <td bgcolor="{$corr:color-additional}"/> (: we don't need links when everything is ok :)
        return <tr class="{$class}">{($tokenField, $wordformDictField, $hyph1Field, $hyph2Field, $lemmaField, $freqField, $linksField)}</tr>         



(: c) most complex case: "interrupted" forms, where it is not clear whether the parts must be concatenated or separated :)
(: first, we create a sequence of "complexToken" nodes, with each "complexToken" containing two tokens / token parts and the lb in between :)
let $complexTokens := for $lb in $margLines//lb[not(@break)][
                                                parent::line/preceding-sibling::line[1]/text/tok[last()][@type eq 'complex']
                                                and following-sibling::text[1]/tok[1][@type eq 'complex']
                                            ] return 
                                            <complexToken>{
                                                ($lb/parent::line/preceding-sibling::line[1]/text/tok[last()][@type eq 'complex'],
                                                 $lb,
                                                 $lb/following-sibling::text[1]/tok[1][@type eq 'complex'])
                                             }</complexToken>
let $complexForms := functx:distinct-deep(for $compTok in $complexTokens return <complexForm>{($compTok/tok[1], $compTok/tok[2])}</complexForm>)                                   


(: #### START DEBUGGING SECTION :)
let $unpairedComplex := $margLines//lb[not(@break) and (parent::line/preceding-sibling::line[1]/text/tok[last()][@type ne 'complex']
                                                        or following-sibling::text[1]/tok[1][@type ne 'complex']
                                                       )]
let $unmarkedComplex := $margLines//lb[@break and (parent::line/preceding-sibling::line[1]/text/tok[last()][@type eq 'complex']
                                                   or following-sibling::text[1]/tok[1][@type eq 'complex']
                                                  )]
let $debugComplex := if ($unpairedComplex) then 
                         error(xs:QName("UnpairedComplex"), "Found lb not marked as @break but without being preceded AND followed by a token marked as 'complex': " 
                                                            || string-join($unpairedComplex//@xml:id, ' | '))
                     else ()
let $debugComplex2 := if ($unmarkedComplex) then 
                          error(xs:QName("UnmarkedComplex"), "Found lb already marked as break='yes|no' although the preceding and/or following token is marked as 'complex':" 
                                                             || string-join($unmarkedComplex//@xml:id, ' | '))
                      else ()
(: #### END DEBUGGING SECTION :)

(: extract a simple list of all "simple" and "hyphen" wordforms in the text (regardless of whether occurring in one of the dicts) 
        for comparison with "complex" cases :)
let $distinctWordformsInText := distinct-values(($simpleTokens, for $h in $hyphenatedForms return concat($h/tok[1]/text(), $h/tok[2]/text())))

let $complexEntries := 
    for $complexSeq in $complexForms return
        (: NOTE: if the following throws an error, there are tokens marked as complex without adjacent complex token... :)
        let $tok1 := $complexSeq/tok[1]/text()
        let $tok2 := $complexSeq/tok[2]/text()
        let $token := $tok1 || $tok2
        let $wordformDictConcat := corr:getWordformFromDict($token, $dict)
        let $wordformDictTok1 :=    if ($tok1) then corr:getWordformFromDict($tok1, $dict) 
                                    else error()
        let $wordformDictTok2 := if ($tok2) then corr:getWordformFromDict($tok2, $dict) else error()
        let $lemmaConcat := if ($wordformDictConcat and map:get($dict, $wordformDictConcat) ne 'N/A') then map:get($dict, $wordformDictConcat) else ()
        let $lemmaTok1 := if ($wordformDictTok1 and map:get($dict, $wordformDictTok1) ne 'N/A') then map:get($dict, $wordformDictTok1) else ()
        let $lemmaTok2 := if ($wordformDictTok2 and map:get($dict, $wordformDictTok2) ne 'N/A') then map:get($dict, $wordformDictTok2) else ()
        let $wordformDictConcatField := if ($wordformDictConcat) then <td bgcolor="{$corr:color-ok}">{$wordformDictConcat}</td>
                                        else <td bgcolor="{$corr:color-not-found}">? ({$token})</td>
        let $comp1Field :=  if ($wordformDictTok1) then <td bgcolor="{$corr:color-ok}">{$wordformDictTok1}</td>
                            else <td bgcolor="{$corr:color-not-found}">? ({$tok1})</td>
        let $comp2Field :=  if ($wordformDictTok2) then <td bgcolor="{$corr:color-ok}">{$wordformDictTok2}</td>
                            else <td bgcolor="{$corr:color-not-found}">? ({$tok2})</td>
        let $tokenField :=  if (not($wordformDictConcat) and $wordformDictTok1 and $wordformDictTok2) then <td bgcolor="{$corr:color-ok}">{$tok1 || ' | ' || $tok2}</td>
                            else <td bgcolor="{$corr:color-ambiguous}">{$tok1 || ' | ' || $tok2}</td>
        let $lemmaField :=  if ($wordformDictConcat and not($wordformDictTok1 or $wordformDictTok2)) then 
                                if ($lemmaConcat) then <td bgcolor="{$corr:color-ok}">{$lemmaConcat}</td>
                                else <td bgcolor="{$corr:color-not-found}"> ? </td>
                            else if ($wordformDictTok1 and $wordformDictTok2 and not($wordformDictConcat)) then
                                if ($lemmaTok1 and $lemmaTok2) then <td bgcolor="{$corr:color-ok}">{$lemmaTok1}, {$lemmaTok2}</td>
                                else <td bgcolor="{$corr:color-not-found}">{if ($lemmaTok1) then $lemmaTok1 else '?'}, {if ($lemmaTok2) then $lemmaTok2 else '?'}</td>
                            (: if all or none of the wordforms/parts have been found, the final lemma is not clear: :)
                            else <td bgcolor="{$corr:color-not-found}"> ? </td>
        let $allInstances := $complexTokens//lb[preceding-sibling::*[1]/self::tok[./text() eq $tok1] and following-sibling::*[1]/self::tok[./text() eq $tok2]]
        let $freq := count($allInstances)
        let $freqField := <td bgcolor="{$corr:color-additional}">{string($freq)}</td>          
        let $links := for $lb in $allInstances return
                              (: with lb-separated tokens, we need to go to the lb of the line in which the first token occurs :)
                              let $thisId := $lb/@xml:id
                              let $id := $text//tei:lb[@xml:id eq $thisId]/preceding::tei:lb[not(@sameAs)][1]/@xml:id
                              let $pb := $text//tei:lb[@xml:id eq $id]/preceding::tei:pb[not(@sameAs) and not(ancestor::*[@place eq 'margin'])][1]
                              let $imgUrl := corr:makeImageUrl($pb/@facs)
                              let $aElems := (<a id="{$thisId}" href="{'../../xml/' || $workId || '_corr.xml#' || $id}" target="_blank">{$id/string()}</a>, 
                                              <a href="{$imgUrl}" target="_blank">img</a>)
                              return $aElems
        let $class := if ($wordformDictConcat) then 
                          if ($wordformDictTok1 and $wordformDictTok2) then 'comp_hyph_nohyph'
                          else 'comp_hyph'
                      else if (not($wordformDictConcat)) then 
                          if ($wordformDictTok1 and $wordformDictTok2) then 'comp_nohyph_ok'
                          else 'comp_not_found'
                      else 'comp_not_found'
        let $linkField := if ($class ne 'comp_nohyph_ok') then 
                              (: if we have multiple instances, create a break after each instance's "img" link :)
                              if ($freq gt 1) then <td bgcolor="{$corr:color-additional}">{for $l at $i in $links return if ($l/text() eq 'img' and not($i eq count($links))) then ($l, <br/>) else $l}</td>
                              else <td bgcolor="{$corr:color-additional}">{$links}</td>
                          else <td bgcolor="{$corr:color-additional}"/> (: we don't need links when everything is ok :)
        (: -------------------------------------------------------------------- :)
        (: additional entries for in-text wordforms comparison - hidden from the "all-wordforms" list, but extractable later on :)
        let $tokenInText := $token = $distinctWordformsInText
        let $tok1InText := $tok1 = $distinctWordformsInText
        let $tok2InText := $tok2 = $distinctWordformsInText
        (: token appears as a hyphenation only if none of its parts also occurs by itself as a distinct wordform in the text (or, if maximally 1 part is a distinct wordform?) :)
        let $tokenIsHyphenationInText := $tokenInText and not($tok1InText or $tok2InText)
        let $tokenInTextFieldColor := if (not($tokenInText) and $tok1InText and $tok2InText) then $corr:color-ok  
                                      else if ($tokenIsHyphenationInText) then $corr:color-special-form
                                      else $corr:color-ambiguous
        let $tokenInTextField := <td bgcolor="{$tokenInTextFieldColor}">{$tok1 || ' | ' || $tok2}</td>
        let $wordformInTextField := if ($tokenInText) then <td bgcolor="{$corr:color-ok}">{$token}</td> else <td bgcolor="{$corr:color-not-found}">? ({$token})</td>
        let $tok1InTextField := if ($tok1InText) then <td bgcolor="{$corr:color-ok}">{$tok1}</td> else <td bgcolor="{$corr:color-not-found}">? ({$tok1})</td>
        let $tok2InTextField := if ($tok2InText) then <td bgcolor="{$corr:color-ok}">{$tok2}</td> else <td bgcolor="{$corr:color-not-found}">? ({$tok2})</td>
        (: store the respective lb/@xml:id in an easily queryable format (i.e., separated by blank only) for later xslt processing 
            (- misusing the lemma field for now for storing this information...) - but only if $tokenIsHyphenationInText is true! :)
        let $xmlIdField := if ($tokenIsHyphenationInText) then <td class="intext-hyphenation-id" bgcolor="{$corr:color-special-form}">{string-join(for $lb in $allInstances return $lb/@xml:id, '&#xA;')}</td>
                           else <td/>
        let $linkInTextField := if (true()) then (: originally if ($tokenIsHyphenationInText) :) 
                                    if ($freq gt 1) then <td bgcolor="{$corr:color-additional}">{for $l at $i in $links return if ($l/text() eq 'img' and not($i eq count($links))) then ($l, <br/>) else $l}</td>
                                    else <td bgcolor="{$corr:color-additional}">{$links}</td>
                                else <td/>
        (: -------------------------------------------------------------------- :)
        return (<tr class="{$class}">{($tokenField, $wordformDictConcatField, $comp1Field, $comp2Field, $lemmaField, $freqField, $linkField)}</tr>,
        <tr class="comp_hyph_intext" style="display:none;">{($tokenInTextField, $wordformInTextField, $tok1InTextField, $tok2InTextField, $xmlIdField, $freqField, $linkInTextField)}</tr>)



(: 5.) Output and logging :)

(: put all three sequences together and sort them nicely :)
let $allEntriesSorted := (for $entry in ($simpleEntries, $hyphenEntries, $complexEntries) 
                              order by lower-case(replace($entry/*[1]/text(), ' [|-] ', ''))
                              return $entry)

let $log1 := trace(count($allEntriesSorted//tr[@class eq 'simple_ok']), 'Entries tagged as simple_ok: ')
let $log8 := trace(count($allEntriesSorted//tr[@class eq 'simple_not_found']), 'Entries tagged as simple_not_found: ')
let $log2 := trace(count($allEntriesSorted//tr[@class eq 'hyphen_ok']), 'Entries tagged as hyphen_ok: ')
let $log3 := trace(count($allEntriesSorted//tr[@class eq 'hyphen_not_found']), 'Entries tagged as hyphen_not_found: ')
let $log4 := trace(count($allEntriesSorted//tr[@class eq 'comp_hyph']), 'Entries tagged as comp_hyph: ')
let $log5 := trace(count($allEntriesSorted//tr[@class eq 'comp_nohyph_ok']), 'Entries tagged as comp_nohyph_ok: ')
let $log6 := trace(count($allEntriesSorted//tr[@class eq 'comp_hyph_nohyph']), 'Entries tagged as comp_hyph_nohyph: ')
let $log7 := trace(count($allEntriesSorted//tr[@class eq 'comp_not_found']), 'Entries tagged as comp_not_found: ')
let $log8 := trace(count($allEntriesSorted//tr[@class eq 'comp_hyph_intext']), 'Entries tagged as comp_hyph_intext: ')

let $title := $workId || ': List of all word forms (incl. unresolved hyphenations)'

return
<html>
<head>
<meta content="{$workId}" charset="utf-8" xml:lang="{$lang}"/>
<title>{$title}</title>
</head>
<body>
<h1>{$title}</h1>
<table border="1">
<colgroup> <col width="18%"/> <col width="18%"/> <col width="11%"/> <col width="11%"/> <col width="18%"/> <col width="5%"/> <col width="17%"/> </colgroup>
<tr><th colspan="1">Word Form</th><th colspan="1">Dict. Entry<br/>(Complete)</th><th colspan="1">Dict. Entry<br/>(1)</th><th colspan="1">Dict. Entry<br/>(2)</th>
<th colspan="1">Lemma(ta)</th><th colspan="1">Freq.</th><th colspan="1">Links</th></tr>
{$allEntriesSorted}
</table>
</body>
</html>


(: TODO: 
- uppercased after lb following on word ending with lowercased (and vice versa) -> simple
- u vs. v, i vs. j? -> the freeling dict seems to have forms even with u instead of v etc., and we can add further forms manually
:)

(: QUESTIONS: 
    - delete quotation signs " and ' (although there shouldn't be any)?
:)

