xquery version "3.0" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xi = "http://www.w3.org/2001/XInclude";
declare default element namespace "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare copy-namespaces preserve, inherit;
declare namespace functx = "http://www.functx.com";
declare option output:method "xml"; 
declare option output:indent "no";
 
declare variable $workId as xs:string 
                 := substring(/tei:TEI/@xml:id, 1, 5 );
declare variable $volumeNumber as xs:string 
                 := if(/tei:TEI/tei:text/@n) 
                    then (xs:integer(/tei:TEI/tei:text/@n)) 
                    else ('0');
declare variable $volN as xs:string
                 := substring(concat('00', string($volumeNumber)), string-length(string($volumeNumber)) + 1, 2);

declare variable $maximalLinesOnPage as xs:integer
                 := 250;
                 


(::::::::::::::::::::::
         Create xml:id for lb. 
         The fourth last digit serves as signifier for the type of line that is identified:
         - 0 stands for line in the main area of the text, no column format
         - 1-9 stands for line in the main area in column 1-9
         - m stands for line in the marginal area of the text (regardless of the side (left vs. right))
         - s stands for a line that is not actually a countable line, but needs to be tagged as such for processing reasons,
            refering by means of @sameAs to an "actual" line (lines of this type contain no specific group of digits stating 
            the number/position of the current line, but merely a "random" hexadecimal ID)
            ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::)
            
declare function local:lbID($lbNode as node()) as xs:string
      {
(:if lb is not a genuine line beginning (but refers to one) give it a "-s..." (sameAs) id:) 
      let $lbId as xs:string := let $facs as xs:string := $lbNode/preceding::tei:pb[not(@sameAs)][1]/xs:string(@facs)
                                let $pageN := substring($facs, string-length($facs) - 3, 4)
                                let $hexId := '123'
                                return if ($lbNode/@sameAs)
                                       then(concat($workId, '-', $volN, '-', $pageN, '-lb-s', substring($hexId, 2, 3)))
                                else 
                                (:if lb occurs within a marginal note, create xml:id based on number of previous marginal note lines on the same page and give it a "-m..." id 
                                within marginal notes, line numbering needs to take into account "virtual" pb elements that merely refer to real pb (using @sameAs). 
                                Thus, we also take into account pb[@sameAs] (unlike in other cases).:)
                                    let $currentPage as xs:integer := count($lbNode/preceding::tei:pb[not(@sameAs)])
                                    let $currentMarginalLineOnPage as xs:integer := count($lbNode/preceding::tei:lb[(not(@sameAs)
                                                                               and position() lt $maximalLinesOnPage) 
                                                                               and (count(./preceding::tei:pb[not(@sameAs)]) = $currentPage) 
                                                                               and ./ancestor::tei:note[@place='margin']]) + 1
                                    let $facs as xs:string := $lbNode/preceding::tei:pb[not(@sameAs)][1]/xs:string(@facs)
                                    let $pageN := substring($facs, string-length($facs) - 3, 4)
                                    let $marginalLineN as xs:string := substring(concat('000', string($currentMarginalLineOnPage)), string-length(string($currentMarginalLineOnPage)) + 1, 3)
                                    return  if($lbNode/ancestor::tei:note[@place='margin'])
                                                then(concat($workId, '-', $volN, '-', $pageN, '-lb-m', $marginalLineN))
                                            else if (not($pageN))
                                                then (fn:error(xs:QName('ERROR'), 'Error: no preceding element pb found for element lb'))
                                            else 
                                            (:if lb occurs in the main area of the text, give it a "-0-9..." id, depending on number of columns::)
                                                let $currentPage as xs:integer := count($lbNode/preceding::tei:pb[not(@sameAs)]) 
                                                let $currentColumnOnPage as xs:integer := local:currentColumnN($lbNode) (:count($lbNode/preceding::tei:cb[count(preceding::tei:pb[not(@sameAs)]) = $currentPage]):)
                                                let $currentLine as xs:integer := 
                                                                                  (:select only lines that do not occur within marginal notes:)
                                                                                  let $previousColumnsInDocument as xs:integer := count($lbNode/preceding::tei:cb[not(@sameAs)]) 
                                                                                  (:if columns exist on page, count the number of lines in the current column:)
                                                                                   return  
                                                                                        if ($currentColumnOnPage > 0) then
                                                                                              (count($lbNode/preceding::tei:lb[not(@sameAs) 
                                                                                                                               and (position() lt $maximalLinesOnPage) and (count(preceding::tei:cb[not(@sameAs)]) = $previousColumnsInDocument) 
                                                                                                                               and not(./ancestor::tei:note[@place='margin'])
                                                                                                                               and local:currentColumnN(.) eq $currentColumnOnPage]) + 1)
                                                                                               (:if no columns exist on page, count lines since page beginning:)
                                                                                         else (count($lbNode/preceding::tei:lb[not(@sameAs) 
                                                                                                     and (position() lt $maximalLinesOnPage) 
                                                                                                     and (count(preceding::tei:pb[not(@sameAs)]) = $currentPage) 
                                                                                                     and not(ancestor::tei:note[@place='margin'])
                                                                                                     and local:currentColumnN(.) eq $currentColumnOnPage]) + 1)
                                                let $facs as xs:string := $lbNode/preceding::tei:pb[not(@sameAs)][1]/xs:string(@facs)
                                                let $pageN := substring($facs, string-length($facs) - 3, 4)
                                                let $lineNumber := 
                                                    let $columnN as xs:string := string($currentColumnOnPage)
                                                    let $lineN as xs:string := substring(concat('000', string($currentLine)), string-length(string($currentLine)) + 1, 3)
                                                    return concat($columnN, $lineN)
                                                return if ($currentColumnOnPage > 9)
                                                           then(fn:error(xs:QName('ERROR'),'Error: illegal number of columns on page'))
                                                       else(concat($workId, '-', $volN, '-', $pageN, '-lb-', $lineNumber))
      return if (not(string-length($lbId) eq 21))
                 then (fn:error(xs:QName('Error'), 'Error: invalid xml:id length for element lb:' || $lbId))
             else ($lbId)
        (::::::::
        ATTENTION: this function has currently one flaw: if lb occurs directly after a pb[@sameAs], it will use 
        the previous pb (not having @sameAs) for numbering; the same applies with cb[@sameAs]
        :::::::::)
      
      };
      
(:count columns:)

declare function local:currentColumnN ($lb as node()) 
{
    (:if there is no preceding cb at all, return 0:)
    if (not($lb/preceding::tei:cb[not(@sameAs)]))
    then(0)
    else (:if there is no preceding cb among the last 600 elements, return 0:) 
        if (not($lb/preceding::tei:cb[not(@sameAs) and position() le 600]))
        then (0)
        else (:get number of columns since last <cb type="start"/> or since last <pb/>, whichever is nearer; if the nearest element is 
                    a cb of type "end", then column number must be 0 :)
            let $precedingPb := $lb/preceding::tei:pb[not(@sameAs)][1]
            let $precedingCbStart := $lb/preceding::tei:cb[@type eq 'start' and not(@sameAs)][1]
            let $precedingCbEnd := $lb/preceding::tei:cb[@type eq 'end' and not(@sameAs)][1]
            (:using tei:lb here instead of * for determining position - is this kosher? :)
            let $columnAnchor := if (count($precedingPb/preceding::tei:lb) gt count($precedingCbStart/preceding::tei:lb)) 
                                 then $precedingPb 
                                 else $precedingCbStart
            let $prevColumns := if (count($precedingCbEnd/preceding::tei:lb) gt count($columnAnchor/preceding::tei:lb))
                                then (0)
                                else if ($columnAnchor/self::tei:pb)
                                     then (count($lb/preceding::tei:cb[not(@sameAs) and (count(preceding::tei:cb[not(@sameAs)]) ge count($columnAnchor/preceding::tei:cb[not(@sameAs)]))]))
                                     else (count($lb/preceding::tei:cb[not(@sameAs) and (count(preceding::tei:cb[not(@sameAs)]) ge count($columnAnchor/preceding::tei:cb[not(@sameAs)]))]))
            return $prevColumns
            
};

(::::::::::::::::
identity transform
::::::::::::::::::)

declare function local:copy($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        case element(tei:lb) 
        return <lb>{attribute xml:id {local:lbID($node)}}</lb>
                           
        case element()
           return
              element {name($node)} {
                
                (: output each attribute in this element :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {$att}
                ,
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                   return local:copy($child/node())

              }
        (: otherwise pass it through.  Used for text(), comments, and PIs :)
        default return $node
};
    
let $text := local:copy(./node())
return $text
