xquery version "3.1";

declare namespace functx = "http://www.functx.com";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace corr = "https://api.salamanca.school/xquery/corr" at "corr.xql";

declare option output:omit-xml-declaration "yes";
declare option output:encoding "utf-8";
declare option output:indent "yes";

(: Creates a list of a text's word forms that were found in hyphenated form in a dictionary :)

declare variable $editText as xs:string external; (: must be one of 'special-chars-only', 'no-special-chars', 'all' :)

let $workId := if (/html/head/meta/@content) then /html/head/meta/@content else error()

let $permissibleSpecialChars := '([œæſßę⁊ʒç†])|(q́)' (: these characters are not counted as brevigraph chars. 
                                                    The list can be extended for composed characters by using regex groups: ()|() e.g (q́):)

let $entries := for $entry in /html/body/table/tr[@class = ('simple_not_found', 'hyphen_not_found', 'comp_not_found')]
                    order by xs:integer($entry/*[last() - 1]/text()) descending
                    (: filtering out words with special chars for now, since those are likely to be brevigraphs (TODO: allow for certain common chars?) :)
                    return  
                        if ($editText eq 'special-chars-only') then 
                            if (matches(replace($entry/*[1]/text(), $permissibleSpecialChars, ''), '[&#x0100;-&#x10ffff;]')) then
                                <tr class="{$entry/@class/string()}">
                                    <td class="wordform" bgcolor="{$corr:color-ambiguous}">{$entry/*[1]/text()}</td>
                                    <td class="dictEntry" bgcolor="{$corr:color-not-found}"></td>
                                    <td class="lemma" bgcolor="{$corr:color-lemma-unknown}"></td>
                                    <td class="namedEntity" bgcolor="{$corr:color-special-form}"></td>
                                    {($entry/*[last() - 1], 
                                      $entry/*[last()])}
                                </tr>
                            else ()
                        else if ($editText eq 'no-special-chars') then 
                            if (not(matches(replace($entry/*[1]/text(), $permissibleSpecialChars, ''), '[&#x0100;-&#x10ffff;]'))) then
                                <tr class="{$entry/@class/string()}">
                                    <td class="wordform" bgcolor="{$corr:color-ambiguous}">{$entry/*[1]/text()}</td>
                                    <td class="dictEntry" bgcolor="{$corr:color-not-found}"></td>
                                    <td class="lemma" bgcolor="{$corr:color-lemma-unknown}"></td>
                                    <td class="namedEntity" bgcolor="{$corr:color-special-form}"></td>
                                    {($entry/*[last() - 1], 
                                      $entry/*[last()])}
                                </tr>
                            else ()
                        else if ($editText eq 'all') then
                            <tr class="{$entry/@class/string()}">
                                <td class="wordform" bgcolor="{$corr:color-ambiguous}">{$entry/*[1]/text()}</td>
                                <td class="dictEntry" bgcolor="{$corr:color-not-found}"></td>
                                <td class="lemma" bgcolor="{$corr:color-lemma-unknown}"></td>
                                <td class="namedEntity" bgcolor="{$corr:color-special-form}"></td>
                                {($entry/*[last() - 1], 
                                  $entry/*[last()])}
                            </tr>
                        else error()

let $title := $workId || ': Unknown single-line or hyphenated word forms'

return
<html>
<head>
<meta charset="utf-8"/>
<title>{$title}</title>
</head>
<body>
<h3>{$title}</h3>
<p>
Follow the link and check if the suggested word should be expanded.<br/>
<br/>
</p>
<table border="1">
<colgroup> <col width="18%"/> <col width="18%"/> <col width="15%"/> <col width="18%"/> <col width="5%"/> <col width="17%"/> </colgroup>
<tr><th colspan="1">Type</th><th colspan="1">Dict. Entry</th><th colspan="1">Lemma(ta)</th>
<th colspan="1">Name</th><th colspan="1">Freq.</th><th colspan="1">Links</th></tr>
{$entries}
</table>
</body>
</html>

(:<p>
Instructions for manually adding word forms to the dictionary:<br/>
- if word form is correct, insert "OK" (without quotation signs) in column 2 (red), otherwise leave empty<br/>
- optionally, if word form is correct, state the lemma in lower-cased form in column 3 (purple); 
    if there are several lemmata (e.g. with compound words like "casarse" or "pedirle"), state all lemmata, separated by ' + '; 
    if word is ambiguous (= can be associated with multiple lemmata), its lemmata are indicated separated by commas.<br/>
- if the word form is correct and is a name, a normalized form of the name (e.g., as found in lod databases) should be provided in the lemma field (3), while the type of the name ('PERSON', 'PLACE') is to be stated in column 4 (aquamarine)<br/>

</p>:)