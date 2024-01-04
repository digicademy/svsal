xquery version "3.1";

(: ####++++----  

    Dispatch functions for transforming TEI nodes to plain text.
    Currently used for dynamic/static txt output as well as sphinx snippets for works.
   
   ----++++#### :)

module namespace txt               = "https://www.salamanca.school/factory/works/txt";

declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";

declare namespace exist            = "http://exist.sourceforge.net/NS/exist";
declare namespace output           = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace util             = "http://exist-db.org/xquery/util";

import module namespace console    = "http://exist-db.org/xquery/console";

import module namespace config     = "https://www.salamanca.school/xquery/config" at "xmldb:exist:///db/apps/salamanca/modules/config.xqm";
import module namespace sutil      = "https://www.salamanca.school/xquery/sutil"  at "xmldb:exist:///db/apps/salamanca/modules/sutil.xqm";

(: there are some index functions referred to below, but we needed to implement workarounds that do not depend on index.xqm, so as to avoid
   circular dependencies between index.xqm and txt.xqm :)


(:
~ Creates text data as a string for a whole work/volume.
~ @param $tei : the tei:TEI element to be transformed
~ @param $mode : select the diplomatic transcription ("orig") or the constituted text ("edit", default)
:)
declare function txt:makeTXTData($tei as element(tei:TEI), $mode as xs:string) as xs:string? {
    let $work := util:expand($tei)
    let $procmode := if ($mode ne "orig") then "edit" else "orig"
    return
        string-join(txt:dispatch($work, $procmode), '')
};



(: DUPLICATE of index:isMarginalNode() for avoiding import of index.xqm (due to circular dependencies...) :)
(:
~ Marginal nodes occur within structural or main nodes.
~ (NOTE: should work with on-the-fly copying of sections. )
:)
declare function txt:isMarginalNode($node as node()) as xs:boolean {
    boolean(
        $node/@xml:id and
        (
            $node/self::tei:note[@place eq 'margin'] or
            $node/self::tei:label[@place eq 'margin']
        )
        (:and not($node/ancestor::*[index:isMarginalNode(.)]):) (: that shouldn't be possible :)
    )
};



(: ####====---- TEI NODE TYPESWITCH FUNCTIONS ----====#### :)

(:  MODES: 
~   - 'orig', 'edit': plain text
~   - 'snippets-orig', 'snippets-edit': plain text for Sphinx snippets
:)

(:
~ @param $node : the node to be dispatched
~ @param $mode : the mode for which the function shall generate results
:)
declare function txt:dispatch($node as node(), $mode as xs:string) as xs:string* {
    typeswitch($node)
        case text()                     return txt:textNode($node, $mode)
        case element(tei:g)             return txt:g($node, $mode)
        case element(tei:lb)            return txt:lb($node, $mode)
        case element(tei:pb)            return txt:pb($node, $mode)
        case element(tei:cb)            return txt:cb($node, $mode)
    
        case element(tei:head)          return txt:head($node, $mode) (: snippets: passthru :)
        case element(tei:p)             return txt:p($node, $mode)
        case element(tei:note)          return txt:note($node, $mode)
        case element(tei:div)           return txt:div($node, $mode)
        case element(tei:milestone)     return txt:milestone($node, $mode)
        
        case element(tei:abbr)          return txt:abbr($node, $mode)
        case element(tei:orig)          return txt:orig($node, $mode)
        case element(tei:sic)           return txt:sic($node, $mode)
        case element(tei:expan)         return txt:expan($node, $mode)
        case element(tei:reg)           return txt:reg($node, $mode)
        case element(tei:corr)          return txt:corr($node, $mode)
        
        case element(tei:persName)      return txt:persName($node, $mode)
        case element(tei:placeName)     return txt:placeName($node, $mode)
        case element(tei:orgName)       return txt:orgName($node, $mode)
        case element(tei:pubPlace)      return txt:pubPlace($node, $mode)
        case element(tei:publisher)     return txt:publisher($node, $mode)
        case element(tei:title)         return txt:title($node, $mode)
        case element(tei:term)          return txt:term($node, $mode)
        case element(tei:bibl)          return txt:bibl($node, $mode)
    
        case element(tei:quote)         return txt:quote($node, $mode)
        case element(tei:soCalled)      return txt:soCalled($node, $mode)
    
        case element(tei:list)          return txt:list($node, $mode)
        case element(tei:item)          return txt:item($node, $mode)
        case element(tei:eg)            return txt:eg($node, $mode)
    
        case element(tei:death)         return txt:death($node, $mode)
    
        case element(tei:lg)            return txt:lg($node, $mode)
        case element(tei:l)             return txt:l($node, $mode)
        
        case element(tei:signed)        return txt:signed($node, $mode) 
        
        case element(tei:label)         return txt:label($node, $mode)
        
        case element(tei:gap)           return txt:gap($node, $mode)
        case element(tei:space)         return txt:space($node, $mode)
        
        case element(tei:figure)        return txt:figure($node, $mode)
        
        case element(tei:text)          return txt:text($node, $mode) 
    
        case element(tei:row)           return txt:row($node, $mode)
        
        case element(tei:TEI)           return txt:passthru($node, $mode)
        case element(tei:group)         return txt:passthru($node, $mode)
        
        case element(tei:figDesc)       return ()
        case element(tei:teiHeader)     return ()
        case element(tei:fw)            return ()
        case comment()                  return ()
        case processing-instruction()   return ()
    
        default return txt:passthru($node, $mode)
};


(: ####++++ Element functions (ordered alphabetically) ++++#### :)


declare function txt:abbr($node as element(tei:abbr), $mode) {
    txt:origElem($node, $mode)
};

declare function txt:bibl($node as element(tei:bibl), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'snippets-orig' return
            txt:passthru($node, $mode)
            
        case 'edit' return
            if ($node/@sortKey) then
                (txt:passthru($node, $mode), ' [', replace(string($node/@sortKey), '_', ', '), ']')
            else
                txt:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@sortKey) then
                replace(string($node/@sortKey), '_', ', ')
            else
                txt:passthru($node, $mode)
        
        default return
            txt:passthru($node, $mode)
};

declare function txt:cb($node as element(tei:cb), $mode as xs:string) {
    if (not($node/@break = 'no')) then
        ' '
    else ()
};

declare function txt:corr($node as element(tei:corr), $mode) {
    txt:editElem($node, $mode)
};

declare function txt:death($node as element(tei:death), $mode as xs:string) {
    txt:passthru($node, $mode)
};

declare function txt:div($node as element(tei:div), $mode as xs:string) {
    let $content := replace(
 translate(
        normalize-space(string-join(txt:passthruWithParaMarkers($node, $mode),    "")),
 "€", "&#xA;&#xA;" ),
 "&#xA;&#xA;\s+", "&#xA;&#xA;" )
 return
    switch($mode)
        case 'orig' return
             ($config:nl, $config:nl, $content, $config:nl)
        case 'edit' return
            if ($node/@n) then
                ($config:nl, $config:nl, '# ', string($node/@n), $config:nl, $content, $config:nl)
            else
                ($config:nl, $config:nl, $content, $config:nl)
        
        case 'snippets-orig' return 
            $content
            
        case 'snippets-edit' return
            if ($node/@n) then
                (string($node/@n), ' ', $content)
            else
                $content
        
        default return
            $content
};

(: replaced the following with the above for performance reasons on 2021-04-28 ...

declare function txt:div($node as element(tei:div), $mode as xs:string) {
    switch($mode)
        case 'orig' return
             ($config:nl, $config:nl, txt:passthru($node, $mode), $config:nl)
        
        case 'edit' return
(/:          if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then :/)
            if ($node/@n) then
                ($config:nl, $config:nl, '# ', string($node/@n), $config:nl, $config:nl, txt:passthru($node, $mode), $config:nl)
                (/: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :/)
            else
                ($config:nl, $config:nl, txt:passthru($node, $mode), $config:nl)
        
        case 'snippets-orig' return 
            txt:passthru($node, $mode)
            
        case 'snippets-edit' return
(/:          if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then :/)
            if ($node/@n) then
                (' ', string($node/@n), ' ', txt:passthru($node, $mode))
                (/: or this?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :/)
            else txt:passthru($node, $mode)
        
        default return
            txt:passthru($node, $mode)
};
:)

declare function txt:editElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'orig' 
        case 'snippets-orig' return 
            ()
        
        case 'edit' 
        case 'snippets-edit' return
            txt:passthru($node, $mode)
            
        default return
            txt:passthru($node, $mode)
};

declare function txt:eg($node as element(tei:eg), $mode as xs:string) {
    txt:passthru($node, $mode)
};

declare function txt:expan($node as element(tei:expan), $mode) {
    txt:editElem($node, $mode)
};

declare function txt:figure($node as element(tei:figure), $mode as xs:string) {
    ()
};

declare function txt:g($node as element(tei:g), $mode as xs:string) {
(: TODO: improvements: use id()/idref(), manually enforce lowercasing in g/@ref and char/@xml:id :)

    let $charCode   := substring($node/@ref, 2)                       (: substring to remove leading '#' :)
    let $char       := $config:tei-specialchars/id($charCode)
(:
    let $debug := console:log("g-processing node in " || $node/ancestor-or-self::*[@xml:id][1]/string(@xml:id) || ". $charCode is '" || $charCode || "' and $char is '" || serialize($char) || "' ...")
    let $debug := console:log("for $m in $char/tei:mapping where $m/@type = 'standardized' return $m/text() is '" || (for $m in $char/tei:mapping where $m/@type = 'standardized' return $m/text())[1] || "' ...")
:)

(: replaced the following with the above for performance reasons on 2021-04-28 ...
    let $char       := $config:tei-specialchars/tei:char[lower-case(@xml:id) eq $charCode]
:)
    return
    switch($mode)
        case 'orig'
        case 'snippets-orig' return
            let $mapping := for $m in $char/tei:mapping where $m/@type = ('precomposed', 'composed', 'standardized') return $m/text()
            return
                if ($mapping) then
                    string($mapping[1])
                else if ($node/text()) then
                    $node/text()
                else
                    string('')
(:                  error(xs:QName('txt:g'), 'Found tei:g without text content'):)

        case 'edit' 
        case 'snippets-edit'
        case 'nonotes' return
            if (for $m in $char/tei:mapping where $m/@type = 'standardized' return $m/text()) then
                (for $m in $char/tei:mapping where $m/@type = 'standardized' return $m/text())[1]
            else if ($node/text()) then
                string($node)
            else
                string('')
(:              return error(xs:QName('txt:g'), 'Found tei:g without either standardized mapping or text content'):)
        default return
            if ($node/text()) then
                $node/text()
            else
                string('')
(:              error(xs:QName('txt:g'), 'Found tei:g without valid mode parameter AND without text content.'):)
};

declare function txt:gap($node as element(tei:gap), $mode as xs:string) {
    ()
};

(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function txt:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit' return
            (txt:passthru($node, $mode), $config:nl)
        
        default return 
            txt:passthru($node, $mode)
};

declare function txt:item($node as element(tei:item), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit' return
            let $leader :=  
                if ($node/parent::tei:list/@type = "numbered") then
                    '§.' || $config:nbsp
                else if ($node/parent::tei:list/@type = "simple") then
                    $config:nbsp
                else
                    '-' || $config:nbsp
            return ($leader, txt:passthru($node, $mode), $config:nl)
       
        default return
            txt:passthru($node, $mode)
};

declare function txt:l($node as element(tei:l), $mode as xs:string) {
    concat(string-join(txt:passthru($node, $mode), ''), $config:nl)
};

declare function txt:label($node as element(tei:label), $mode as xs:string) {
    switch($mode)
        case 'edit'
        case 'orig' return
            if ($node/@place eq 'margin') then
                ('{ ', txt:passthru($node, $mode), ' }') 
            else txt:passthru($node, $mode) (: TODO: more fine-grained processing? (simple vs. important/heading-like labels) :)
        
        default return
            txt:passthru($node, $mode)
};

declare function txt:lb($node as element(tei:lb), $mode as xs:string) as xs:string {
    if (not($node/@break eq 'no')) then
                ' '
    else ''
};

declare function txt:lg($node as element(tei:lg), $mode as xs:string) {
    concat($config:nl, string-join(txt:passthru($node, $mode), ''), $config:nl)
};

declare function txt:list($node as element(tei:list), $mode as xs:string) {
    switch($mode)
        case 'orig' return
            concat($config:nl, string-join(txt:passthru($node, $mode), ''), $config:nl)
        
        case 'edit' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                concat(concat($config:nl, '# ', string($node/@n), $config:nl), string-join(txt:passthru($node, $mode), ''), $config:nl)
                (: or this?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                concat($config:nl, string-join(txt:passthru($node, $mode), ''), $config:nl)
        
        default return
            txt:passthru($node, $mode)
};

declare function txt:milestone($node as element(tei:milestone), $mode as xs:string) {
    switch($mode)
        case 'orig' return
            if ($node/@rendition = '#dagger') then '†'
            else if ($node/@rendition = '#asterisk') then '*'
            else '[*]'
        
        case 'edit' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                concat('[', string($node/@n), ']')
            else if ($node/@n and matches($node/@n, '^[0-9\[\]]+$')) then
                concat('[',  $config:citationLabels($node/@unit)?('abbr'), ' ', string($node/@n), ']')
                (: TODO: remove normalization parentheses '[', ']' here (and elsewhere?) :)
            else '[*]'
            
        default return () (: snippets-orig, snippets-edit: do not show milestone/placeholder :)
};

declare function txt:name($node as element(*), $mode as xs:string) {
    switch($mode)
        case 'orig' return
            txt:passthru($node, $mode)
        
        case 'edit' return
            if ($node/(@key|@ref)) then
                concat(string-join(txt:passthru($node, $mode), ''), ' [', string-join(($node/@key, $node/@ref), '/'), ']')
            else
                txt:passthru($node, $mode)
        
        default return
            txt:passthru($node, $mode)
};

declare function txt:note($node as element(tei:note), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit' return
            ('{ ', txt:passthru($node, $mode), ' }') 
        
        case 'nonotes' return ()

        default return
            txt:passthru($node, $mode)
};

declare function txt:orgName($node as element(tei:orgName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig'
        case 'snippets-edit' return
            txt:passthru($node, $mode)
        default return
            txt:name($node, $mode)
};

declare function txt:orig($node as element(tei:orig), $mode) {
    txt:origElem($node, $mode)
};

declare function txt:origElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        
        case 'edit'
        case 'snippets-edit'
        case 'nonotes' return
            if (not($node/(preceding-sibling::tei:expan|preceding-sibling::tei:reg|preceding-sibling::tei:corr|following-sibling::tei:expan|following-sibling::tei:reg|following-sibling::tei:corr))) then
                txt:passthru($node, $mode)
            else ()
            
        default return error()
};

declare function txt:p($node as element(tei:p), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit' return
            if ($node/parent::tei:note) then
                normalize-space(string-join(txt:passthru($node, $mode), ''))
            else
                concat(normalize-space(string-join(txt:passthru($node, $mode), '')), $config:nl)
        default
            return normalize-space(string-join(txt:passthru($node, $mode), ''))
};

declare function txt:passthru($nodes as node()*, $mode as xs:string) {
    for $n in $nodes/node() return
        txt:dispatch($n, $mode)
};

declare function txt:passthruWithParaMarkers($nodes as node()*, $mode as xs:string) {
            for            $n in $nodes/node()        return
            (txt:dispatch($n, $mode), '€')
};

declare function txt:pb($node as element(tei:pb), $mode as xs:string) as xs:string {
    switch($mode)
        case 'orig'
        case 'edit'
        case 'snippets-orig'
        case 'snippets-edit'
        case 'nonotes' return
            if (not($node/@break = 'no')) then
                ' '
            else ''
        
        (: pb nodes are good candidates for tracing the speed/performance of document processing, 
            since they are equally distributed throughout a document :)
        case 'debug' return
            let $debug := util:log('info', '[RENDER] Processing tei:pb node ' || $node/@xml:id)
            return ''
        
        default return ' '
};

declare function txt:persName($node as element(tei:persName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        
        case 'snippets-edit' return
            (: make persons searchable by their normalized names or IDs :)
            if ($node/@key and $node/@ref) then
                string($node/@key) || ' [' || string($node/@ref) || ']'
            else if ($node/@key) then
                string($node/@key)
            else if ($node/@ref) then
                '[' || string($node/@ref) || ']'
            else
                txt:passthru($node, $mode)
        
        default return
            txt:name($node, $mode)
};

declare function txt:placeName($node as element(tei:placeName), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        case 'snippets-edit' return
            (: make persons searchable by their normalized names :)
            if ($node/@key) then
                string($node/@key)
            else
                txt:passthru($node, $mode)
                
        default return
            txt:name($node, $mode)
};

(: Same as txt:persName() :)
declare function txt:publisher($node as element(tei:publisher), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key and $node/@ref) then
                string($node/@key) || ' [' || string($node/@ref) || ']'
            else if ($node/@key) then
                string($node/@key)
            else if ($node/@ref) then
                '[' || string($node/@ref) || ']'
            else
                txt:passthru($node, $mode)
        
        default return
            txt:name($node, $mode)
};

(: Same as txt:placeName() :)
declare function txt:pubPlace($node as element(tei:pubPlace), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                txt:passthru($node, $mode)
        default return
            txt:name($node, $mode)
};

declare function txt:quote($node as element(tei:quote), $mode as xs:string) {
    switch($mode)
        case 'orig'
        case 'edit' return
            ('"', txt:passthru($node, $mode), '"')
        
        case 'snippets-edit'
        case 'snippets-orig' return
            txt:passthru($node, $mode)
         
        default return
            txt:passthru($node, $mode)
};

declare function txt:reg($node as element(tei:reg), $mode) {
    txt:editElem($node, $mode)
};

declare function txt:row($node as element(tei:row), $mode) {
    concat(string-join(txt:passthru($node, $mode), ''), '&#xA;')
};

declare function txt:sic($node as element(tei:sic), $mode) {
    txt:origElem($node, $mode)
};

declare function txt:signed($node as element(tei:signed), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig'
        case 'snippets-edit' return
            txt:passthru($node, $mode)
(:            for $subnode in $node/node() where (local-name($subnode) ne 'note') return txt:dispatch($subnode, $mode):)
            
        default return
            txt:passthru($node, $mode)
};

declare function txt:soCalled($node as element(tei:soCalled), $mode as xs:string) {
    if ($mode=("orig", "edit")) then
        concat("'", string-join(txt:passthru($node, $mode), ''), "'")
    else if ($mode = ('snippets-edit', 'snippets-orig')) then
        txt:passthru($node, $mode)
    else txt:passthru($node, $mode)
};

declare function txt:space($node as element(tei:space), $mode as xs:string) {
    if ($node/@dim eq 'horizontal' or @rendition eq '#h-gap') then ' ' else ()
};

(: FIXME: In the following, work mode functionality has to be added - also paying attention to intervening pagebreak marginal divs :)
declare function txt:term($node as element(tei:term), $mode as xs:string) {
    switch($mode)
        case 'orig' 
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        
        case 'edit' return
            if ($node/@key) then
                concat(string-join(txt:passthru($node, $mode), ''), ' [', string($node/@key), ']')
            else
                txt:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                txt:passthru($node, $mode)
        
        default return
            txt:passthru($node, $mode)
};

declare function txt:text($node as element(tei:text), $mode as xs:string) {
    switch($mode)
        case 'edit' return
            if ($node/@type eq 'work_volume') then (: make title :)
                concat($config:nl, '[Vol. ' || $node/@n || ']', $config:nl, string-join(txt:passthru($node, $mode), ''))
            else
                txt:passthru($node, $mode)
        
        default return
            txt:passthru($node, $mode)
};

declare function txt:textNode($node as text(), $mode as xs:string) {
    $node
};

declare function txt:title($node as element(tei:title), $mode as xs:string) {
    switch($mode)
        case 'snippets-orig' return
            txt:passthru($node, $mode)
        
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                txt:passthru($node, $mode)
        
        default return
            txt:name($node, $mode)
};
