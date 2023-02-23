xquery version "3.1";

declare namespace functx = "http://www.functx.com";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace corr = "https://api.salamanca.school/xquery/corr" at "corr.xql";

declare option output:omit-xml-declaration "yes";
declare option output:encoding "utf-8";
declare option output:indent "yes";

(: Creates a list of a text's word forms that were found in hyphenated form in a dictionary :)

let $workId := if (/html/head/meta/@content) then /html/head/meta/@content else error()

let $entries := for $entry in /html/body/table/tr[@class eq 'comp_hyph_intext']
                    where $entry/td/@class eq 'intext-hyphenation-id'
                    order by lower-case(replace($entry/*[1]/text(), ' [|-] ', ''))
                    (: remove style=hidden from <tr> :)
                    return <tr class="{$entry/@class}">{$entry/*}</tr>

let $title := $workId || ': Separate word forms in the context of breaks, which actually are cohesive word forms according to a comparison with distinct word forms 
                            in the text -> lb/pb/cb need to be tagged automatically as break="no"'

return
<html>
<head>
<meta charset="utf-8" xml:lang="{/html/head/meta/@xml:lang/string()}"/>
<title>{$title}</title>
</head>
<body>
<h3>{$title}</h3>
<table border="1" id="comp_hyph_intext">
<colgroup> <col width="18%"/> <col width="18%"/> <col width="11%"/> <col width="11%"/> <col width="18%"/> <col width="5%"/> <col width="17%"/> </colgroup>
<tr><th colspan="1">Type</th><th colspan="1">Wordform in text<br/>(Complete)</th><th colspan="1">Wordform in text<br/>(part 1)</th><th colspan="1">Wordform in text<br/>(part 2)</th>
<th colspan="1">Identifiers</th><th colspan="1">Freq.</th><th colspan="1">Links</th></tr>
{$entries}
</table>
</body>
</html>
