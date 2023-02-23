xquery version "3.1";

declare namespace functx = "http://www.functx.com";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace corr = "https://api.salamanca.school/xquery/corr" at "corr.xql";

declare option output:omit-xml-declaration "yes";
declare option output:encoding "utf-8";
declare option output:indent "yes";

(: Creates a list of a text's word forms that were found in hyphenated form in a dictionary :)

let $workId := if (/html/head/meta/@content) then /html/head/meta/@content else error()

let $entries := for $entry in /html/body/table/tr[@class eq 'comp_not_found']
                    order by lower-case(replace($entry/td[1]/text(), ' | ', ''))
                    return $entry

let $title := $workId || ': Unknown word forms, occurring either within lines or in the context of line breaks -> possible solutions (not mutually exclusive): 1.) manual editing of words in the text, if a wordform is clearly incorrect or not yet normalized; 2.) tagging breaks as hyphenations (Umbruch) in case two word forms are actually *one* word'

return
<html>
<meta charset="utf-8"/>
<head>
<meta charset="utf-8"/>
<title>{$title}</title>
</head>
<body>
<h3>{$title}</h3>
<table border="1">
<colgroup> <col width="18%"/> <col width="18%"/> <col width="11%"/> <col width="11%"/> <col width="18%"/> <col width="5%"/> <col width="17%"/> </colgroup>
<tr><th colspan="1">Type</th><th colspan="1">Dict. Entry<br/>(Complete)</th><th colspan="1">Dict. Entry<br/>(1)</th><th colspan="1">Dict. Entry<br/>(2)</th>
<th colspan="1">Lemma(ta)</th><th colspan="1">Freq.</th><th colspan="1">Links</th></tr>
{$entries}
</table>
</body>
</html>
