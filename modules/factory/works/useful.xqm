let $canvas-facs-seq := for $facs  in //text//pb/@facs  
return    (substring-after(substring-after($facs, "facs:"), "-"))
return $canvas-facs-seq


let  $firstpage :=   for $div in //div
return (//$div//pb[not(@sameAs or @corresp)])/@facs/string()
return for $i in $firstpage
return xs:integer((substring-after($i, '-')))

let $firstpage :=   ($div//tei:pb[not(@sameAs or @corresp)])[1]/@facs/string() 
  (:      if ($div[@type='work_volume'] | $div[@type = 'work_monograph']) then 
        else ($div/preceding::tei:pb[not(@sameAs or @corresp)])[last()]/@facs/string()  :)     
let $firstpage_number := xs:integer(substring-after($firstpage, "-"))  
(:let $firstpage_number := xs:integer(replace(tokenize($firstpage,'-')[last()], '^0*', ''))    :)
let $lastpage := 
        if ($div//tei:pb[not(@sameAs or @corresp)]) then ($div//tei:pb[not(@sameAs or @corresp)])[last()]/@facs/string() 
        else ()
let $lastpage_number := xs:integer(substring-after($lastpage, "-")) 

        "canvases": array {
        for $i in ($firstpage_number to $lastpage_number) 
            return   if   (string-length(string($i)) = 1)
                then $config:iiifPresentationServer  || $tei/@xml:id || "/canvas/p" || index-of($canvas-facs-seq, concat("000", $i))
            else if   (string-length(string($i)) = 2)
                then $config:iiifPresentationServer  || $tei/@xml:id || "/canvas/p"|| index-of($canvas-facs-seq, concat("00", $i))
            else if   (string-length(string($i)) = 3)
                then $config:iiifPresentationServer  || $tei/@xml:id || "/canvas/p"|| index-of($canvas-facs-seq, concat("0", $i))
            else $config:iiifPresentationServer  || $tei/@xml:id || "/canvas/p"|| index-of($canvas-facs-seq, $i)        
        }