xquery version "3.1";

module namespace render-app            = "http://salamanca/render-app";
declare namespace exist            = "http://exist.sourceforge.net/NS/exist";
declare namespace output           = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace tei              = "http://www.tei-c.org/ns/1.0";
declare namespace sal              = "http://salamanca.adwmainz.de";
import module namespace request    = "http://exist-db.org/xquery/request";
import module namespace templates  = "http://exist-db.org/xquery/templates";
import module namespace xmldb      = "http://exist-db.org/xquery/xmldb";
import module namespace util       = "http://exist-db.org/xquery/util";
import module namespace console    = "http://exist-db.org/xquery/console";
import module namespace config     = "http://salamanca/config" at "config.xqm";
import module namespace functx     = "http://www.functx.com";
import module namespace transform  = "http://exist-db.org/xquery/transform";
import module namespace sal-util    = "http://salamanca/sal-util" at "sal-util.xql";


declare function render-app:dispatch($node as node(), $mode as xs:string) {
    typeswitch($node)
    (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
        case text()                     return render-app:textNode($node, $mode)
        case element(tei:g)             return render-app:g($node, $mode)
        case element(tei:lb)            return render-app:lb($node, $mode)
        case element(tei:pb)            return render-app:pb($node, $mode)
        case element(tei:cb)            return render-app:cb($node, $mode)
        case element(tei:fw)            return render-app:fw($node, $mode)

        case element(tei:head)          return render-app:head($node, $mode) (: snippets: passthru :)
        case element(tei:p)             return render-app:p($node, $mode)
        case element(tei:note)          return render-app:note($node, $mode)
        case element(tei:div)           return render-app:div($node, $mode)
        case element(tei:milestone)     return render-app:milestone($node, $mode)
        
        case element(tei:abbr)          return render-app:abbr($node, $mode)
        case element(tei:orig)          return render-app:orig($node, $mode)
        case element(tei:sic)           return render-app:sic($node, $mode)
        case element(tei:expan)         return render-app:expan($node, $mode)
        case element(tei:reg)           return render-app:reg($node, $mode)
        case element(tei:corr)          return render-app:corr($node, $mode)
        
        case element(tei:persName)      return render-app:name($node, $mode)
        case element(tei:placeName)     return render-app:name($node, $mode)
        case element(tei:orgName)       return render-app:name($node, $mode)
        case element(tei:title)         return render-app:name($node, $mode)
        case element(tei:term)          return render-app:term($node, $mode)
        case element(tei:bibl)          return render-app:bibl($node, $mode)

        case element(tei:hi)            return render-app:hi($node, $mode) 
        case element(tei:emph)          return render-app:emph($node, $mode)
        case element(tei:ref)           return render-app:ref($node, $mode) 
        case element(tei:quote)         return render-app:quote($node, $mode)
        case element(tei:soCalled)      return render-app:soCalled($node, $mode)

        case element(tei:list)          return render-app:list($node, $mode)
        case element(tei:item)          return render-app:item($node, $mode)
        case element(tei:gloss)         return render-app:gloss($node, $mode)
        case element(tei:eg)            return render-app:eg($node, $mode)

        case element(tei:birth)         return render-app:birth($node, $mode) 
        case element(tei:death)         return render-app:death($node, $mode)

        case element(tei:figDesc)       return ()
        case element(tei:teiHeader)     return ()
        case comment()                  return ()
        case processing-instruction()   return ()

        default return render-app:passthru($node, $mode)
};



declare function render-app:textNode($node as node(), $mode as xs:string) {
    switch($mode)
        case "html"
        case "work" return
            let $leadingSpace   := if (matches($node, '^\s+')) then ' ' else ()
            let $trailingSpace  := if (matches($node, '\s+$')) then ' ' else ()
            return concat($leadingSpace, 
                          normalize-space(replace($node, '&#x0a;', ' ')),
                          $trailingSpace)
        
        default return ()
};

declare function render-app:passthru($nodes as node()*, $mode as xs:string) as item()* {
    for $node in $nodes/node() return render-app:dispatch($node, $mode)
};

declare function render-app:pb($node as element(tei:pb), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render-app:cb($node as element(tei:cb), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render-app:lb($node as element(tei:lb), $mode as xs:string) {
    switch($mode)
        case 'work' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
    
        case 'html' return 
            <br/>
        default return () 
};

declare function render-app:p($node as element(tei:p), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/ancestor::tei:note) then
                render-app:passthru($node, $mode)
            else
                <p class="hauptText" id="{$node/@xml:id}">
                    {render-app:passthru($node, $mode)}
                </p>
        
        case 'work' return   (: the same as in html mode except for distinguishing between paragraphs in notes and in the main text. In the latter case, make them a div, not a p and add a tool menu. :)
            if ($node/parent::tei:note) then
                render-app:passthru($node, $mode)
            else
                <p class="hauptText" id="{$node/@xml:id}">
                    {render-app:passthru($node, $mode)}
                </p>
        
        default return
            render-app:passthru($node, $mode)
};

declare function render-app:note($node as element(tei:note), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            let $normalizedString := normalize-space(string-join(render-app:passthru($node, $mode), ' '))
            let $identifier       := $node/@xml:id
            return
                (<sup>*</sup>,
                <span class="marginal note" id="note_{$identifier}">
                    {if (string-length($normalizedString) gt $config:chars_summary) then
                        (<a class="{string-join(for $biblKey in $node//tei:bibl/@sortKey return concat('hi_', $biblKey), ' ')}" data-toggle="collapse" data-target="#subdiv_{$identifier}">{concat('* ', substring($normalizedString, 1, $config:chars_summary), '…')}<i class="fa fa-angle-double-down"/></a>,<br/>,
                         <span class="collapse" id="subdiv_{$identifier}">{render-app:passthru($node, $mode)}</span>)
                     else
                        <span><sup>* </sup>{render-app:passthru($node, $mode)}</span>
                    }
                </span>)
        
        default return
            render-app:passthru($node, $mode)
};

declare function render-app:div($node as element(tei:div), $mode as xs:string) {
    switch($mode)
        case 'html' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                (<h4 id="{$node/@xml:id}">{string($node/@n)}</h4>,<p id="p_{$node/@xml:id}">{render-app:passthru($node, $mode)}</p>)
                (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                <div id="{$node/@xml:id}">{render-app:passthru($node, $mode)}</div>
        
        case 'work' return (: basically, the same except for eventually adding a <div class="summary_title"/> the data for which is complicated to retrieve :)
            render-app:passthru($node, $mode)
        
        default return
            render-app:passthru($node, $mode)
};


declare function render-app:milestone($node as element(tei:milestone), $mode as xs:string) {
    switch($mode)
        case "html" return
            let $anchor :=  if ($node/@rendition = '#dagger') then
                                '†'
                            else if ($node/@rendition = '#asterisk') then
                                '*'
                            else ()
            let $summary := if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                                <div class="summary_title" id="{string($node/@xml:id)}">{string($node/@n)}</div>
                            else if ($node/@n and matches($node/@n, '^[0-9\[\]]+$')) then
                                <div class="summary_title" id="{string($node/@xml:id)}">{concat($config:citationLabels($node/@unit)?('abbr'), ' ', string($node/@n))}</div>
                            (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
                            else ()
            return ($anchor, $summary)
        
        case "work" return () 
        
        default return () 
};


(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function render-app:head($node as element(tei:head), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            let $lang   := request:get-attribute('lang')
            let $page   :=      if ($node/ancestor::tei:text/@type="author_article") then
                                    "author.html?aid="
                           else if ($node/ancestor::tei:text/@type="lemma_article") then
                                    "lemma.html?lid="
                           else
                                    "work.html?wid="
            return    
                <h3 id="{$node/@xml:id}">
                    <a class="anchorjs-link" id="{$node/parent::tei:div/@xml:id}" href="{session:encode-url(xs:anyURI($page || $node/ancestor::tei:TEI/@xml:id || '#' || $node/parent::tei:div/@xml:id))}">
                        <span class="anchorjs-icon"></span>
                    </a>
                    {render-app:passthru($node, $mode)}
                </h3>
        
        default return 
            render-app:passthru($node, $mode)
};

declare function render-app:origElem($node as element(), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            let $editedString := render-app:dispatch($node/parent::tei:choice/(tei:expan|tei:reg|tei:corr), "edit")
            return  if ($node/parent::tei:choice) then
                        <span class="original {local-name($node)} unsichtbar" title="{string-join($editedString, '')}">
                            {render-app:passthru($node, $mode)}
                        </span>
                    else
                        render-app:passthru($node, $mode)
        default return
            render-app:passthru($node, $mode)
};

declare function render-app:editElem($node as element(), $mode as xs:string) {
    switch($mode)
        case "html"
        case "work" return
            let $originalString := render-app:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), "orig")
            return  
                <span class="edited {local-name($node)}" title="{string-join($originalString, '')}">
                    {render-app:passthru($node, $mode)}
                </span>
        default return
            render-app:passthru($node, $mode)
};

declare function render-app:g($node as element(tei:g), $mode as xs:string) {
    switch ($mode)
        case "work" return
            let $originalGlyph := render-app:g($node, "orig")
            return
                (<span class="original glyph unsichtbar" title="{$node/text()}">
                    {$originalGlyph}
                </span>,
                <span class="edited glyph" title="{$originalGlyph}">
                    {$node/text()}
                </span>)
        
        default return (: also 'snippets-edit' :)
            render-app:passthru($node, $mode)
};

(: FIXME: In the following, work mode functionality has to be added - also paying attention to intervening pagebreak marginal divs :)
declare function render-app:term($node as element(tei:term), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            let $elementName    := "term"
            let $key            := $node/@key
            let $getLemmaId     := tokenize(tokenize($node/@ref, 'lemma:')[2], ' ')[1]
            let $highlightName  :=  
                if ($node/@ref) then
                    concat('hi_', translate(translate(translate(tokenize($node/@ref, ' ')[1], ',', ''), ' ', ''), ':', ''))
                else if ($node/@key) then
                    concat('hi_', translate(translate(translate(tokenize($node/@key, ' ')[1], ',', ''), ' ', ''), ':', ''))
                else ()
            let $dictLemmaName :=  
                if ($node/ancestor::tei:list[@type="dict"] and not($node/preceding-sibling::tei:term)) then
                    'dictLemma'
                else ()
            let $classes := normalize-space(string-join(($elementName, $highlightName, $dictLemmaName), ' '))
            return                
                <span style="font-weight:bold;" class="{$classes}" title="{$key}">
                    {if ($getLemmaId) then
                        <a href="{session:encode-url(xs:anyURI('lemma.html?lid=' || $getLemmaId))}">{render-app:passthru($node, $mode)}</a>
                     else
                        render-app:passthru($node, $mode)
                    }
                </span>
                
        default return
            render-app:passthru($node, $mode)
};


declare function render-app:name($node as element(*), $mode as xs:string) {
    switch($mode)
        case 'html'
        case 'work' return
            let $nodeType       := local-name($node)
            let $lang           := request:get-attribute('lang')
            let $getWorkId      := tokenize(tokenize($node/@ref, 'work:'  )[2], ' ')[1]
            let $getAutId       := tokenize(tokenize($node/@ref, 'author:')[2], ' ')[1]
            let $getCerlId      := tokenize(tokenize($node/@ref, 'cerl:'  )[2], ' ')[1]
            let $getGndId       := tokenize(tokenize($node/@ref, 'gnd:'   )[2], ' ')[1]
            let $getGettyId     := tokenize(tokenize($node/@ref, 'getty:' )[2], ' ')[1]
            let $key            := $node/@key
    
            return
               if ($getWorkId) then
                     <span class="{($nodeType || ' hi_work_' || $getWorkId)}">
                         <a href="{concat($config:idserver, '/works.', $getWorkId)}" title="{$key}">{render-app:passthru($node, $mode)}</a>
                     </span> 
               else if ($getAutId) then
                     <span class="{($nodeType || ' hi_author_' || $getAutId)}">
                         <a href="{concat($config:idserver, '/authors.', $getAutId)}" title="{$key}">{render-app:passthru($node, $mode)}</a>
                     </span> 
                else if ($getCerlId) then 
                     <span class="{($nodeType || ' hi_cerl_' || $getCerlId)}">
                        <a target="_blank" href="{('http://thesaurus.cerl.org/cgi-bin/record.pl?rid=' || $getCerlId)}" title="{$key}">{render-app:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                     </span>
                else if ($getGndId) then 
                     <span class="{($nodeType || ' hi_gnd_' || $getGndId)}">
                        <a target="_blank" href="{('http://d-nb.info/' || $getGndId)}" title="{$key}">{render-app:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                     </span>
                else if ($getGettyId) then 
                     <span class="{($nodeType || ' hi_getty_' || $getGettyId)}">
                        <a target="_blank" href="{('http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=' || $getGettyId)}" title="{$key}">{render-app:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                     </span>
                else
                    <span>{render-app:passthru($node, $mode)}</span>
        default return
            render-app:passthru($node, $mode)
};

declare function render-app:bibl($node as element(tei:bibl), $mode as xs:string) {
    switch($mode)
        case 'work' return
            let $getBiblId :=  $node/@sortKey
            return if ($getBiblId) then
                        <span class="{('work hi_' || $getBiblId)}">
                            {render-app:passthru($node, $mode)}
                        </span>
                    else
                        render-app:passthru($node, $mode)
        default return
            render-app:passthru($node, $mode)
};


declare function render-app:emph($node as element(tei:emph), $mode as xs:string) {
    if ($mode = "work") then
        <span class="emph">{render-app:passthru($node, $mode)}</span>
    else if ($mode = "html") then
        <em>{render-app:passthru($node, $mode)}</em>
    else
        render-app:passthru($node, $mode)
};
declare function render-app:hi($node as element(tei:hi), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        if ("#b" = $node/@rendition) then
            <b>
                {render-app:passthru($node, $mode)}
            </b>
        else if ("#initCaps" = $node/@rendition) then
            <span class="initialCaps">
                {render-app:passthru($node, $mode)}
            </span>
        else if ("#it" = $node/@rendition) then
            <it>
                {render-app:passthru($node, $mode)}
            </it>
        else if ("#l-indent" = $node/@rendition) then
            <span style="display:block;margin-left:4em;">
                {render-app:passthru($node, $mode)}
            </span>
        else if ("#r-center" = $node/@rendition) then
            <span style="display:block;text-align:center;">
                {render-app:passthru($node, $mode)}
            </span>
        else if ("#sc" = $node/@rendition) then
            <span class="smallcaps">
                {render-app:passthru($node, $mode)}
            </span>
        else if ("#spc" = $node/@rendition) then
            <span class="spaced">
                {render-app:passthru($node, $mode)}
            </span>
        else if ("#sub" = $node/@rendition) then
            <sub>
                {render-app:passthru($node, $mode)}
            </sub>
        else if ("#sup" = $node/@rendition) then
            <sup>
                {render-app:passthru($node, $mode)}
            </sup>
        else
            <it>
                {render-app:passthru($node, $mode)}
            </it>
    else 
        render-app:passthru($node, $mode)
};
declare function render-app:ref($node as element(tei:ref), $mode as xs:string) {
    if ($mode = "html" and $node/@type = "url") then
        if (substring($node/@target, 1, 4) = "http") then
            <a href="{$node/@target}" target="_blank">{render-app:passthru($node, $mode)}</a>
        else
            <a href="{$node/@target}">{render-app:passthru($node, $mode)}</a>
    else if ($mode = "work") then                                       (: basically the same, but use the resolveURI functions to get the actual target :)
        <a href="{$node/@target}">{render-app:passthru($node, $mode)}</a>
    else
        render-app:passthru($node, $mode)
};
declare function render-app:soCalled($node as element(tei:soCalled), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        <span class="soCalled">{render-app:passthru($node, $mode)}</span>
    else
        ("'", render-app:passthru($node, $mode), "'")
};
declare function render-app:quote($node as element(tei:quote), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        <span class="quote">{render-app:passthru($node, $mode)}</span>
    else
        ('"', render-app:passthru($node, $mode), '"')
};

declare function render-app:list($node as element(tei:list), $mode as xs:string) {
    switch($mode)
         case 'html'
         case 'work' return
             if ($node/@type = "ordered") then
                 <section>
                     {if ($node/child::tei:head) then
                         for $head in $node/tei:head
                             return
                                 <h4>
                                     {render-app:passthru($head, $mode)}
                                 </h4>
                      else ()
                     }
                     <ol>
                         {for $item in $node/tei:*[not(local-name() = "head")]
                                 return
                                     render-app:dispatch($item, $mode)
                         }
                     </ol>
                 </section>
             else if ($node/@type = "simple") then
                 <section>
                     {if ($node/tei:head) then
                         for $head in $node/tei:head
                             return
                                 <h4>{render-app:passthru($head, $mode)}</h4>
                      else ()
                     }
                     {for $item in $node/tei:*[not(local-name() = "head")]
                             return
                                     render-app:dispatch($item, $mode)
                     }
                 </section>
             else
                 <figure class="{$node/@type}">
                     {if ($node/child::tei:head) then
                         for $head in $node/tei:head
                             return
                                 <h4>{render-app:passthru($head, $mode)}</h4>
                      else ()
                     }
                     <ul>
                         {for $item in $node/tei:*[not(local-name() = "head")]
                                 return
                                     render-app:dispatch($item, $mode)
                         }
                     </ul>
                 </figure>
                 
         default return
             ($config:nl, render-app:passthru($node, $mode), $config:nl)
};

declare function render-app:item($node as element(tei:item), $mode as xs:string) {
    switch($mode)
        case "html"
        case "work" return
            if ($node/parent::tei:list/@type="simple") then
                render-app:passthru($node, $mode)
            else
                <li>{render-app:passthru($node, $mode)}</li>
        
        default return
            render-app:passthru($node, $mode)
};
declare function render-app:gloss($node as element(tei:gloss), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        render-app:passthru($node, $mode)
    else
        render-app:passthru($node, $mode)
};

declare function render-app:eg($node as element(tei:eg), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        <pre>{render-app:passthru($node, $mode)}</pre>
    else 
        render-app:passthru($node, $mode)
};


declare function render-app:birth($node as element(tei:birth), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        <span>*&#xA0;{render-app:name($node/tei:placeName[1], $mode) || ': ' || $node/tei:date[1]}</span>
    else ()
};
declare function render-app:death($node as element(tei:death), $mode as xs:string) {
    if ($mode = ("html", "work")) then
        <span>†&#xA0;{render-app:name($node/tei:placeName[1], $mode) || ': ' || $node/tei:date[1]}</span>
    else ()
};

declare function render-app:persName($node as element(tei:persName), $mode as xs:string) {
        render-app:name($mode, $node)
};

declare function render-app:placeName($node as element(tei:placeName), $mode as xs:string) {
    render-app:name($mode, $node)
};

declare function render-app:orgName($node as element(tei:orgName), $mode as xs:string) {
    render-app:name($mode, $node)
};

declare function render-app:title($node as element(tei:title), $mode as xs:string) {
    switch($mode)
        case "html"
        case "work" return
            if ($node/@ref) then
                 <span class="bibl-title"><a target="blank" href="{$node/@ref}">{render-app:passthru($node, $mode)}<span class="glyphicon glyphicon-new-window" aria-hidden="true"/></a></span>
            else
                 <span class="bibl-title">{render-app:passthru($node, $mode)}</span>
            default return
                render-app:passthru($mode, $node)
};

declare function render-app:abbr($node as element(tei:abbr), $mode) {
    render-app:origElem($node, $mode)
};

declare function render-app:orig($node as element(tei:orig), $mode) {
    render-app:origElem($node, $mode)
};

declare function render-app:sic($node as element(tei:sic), $mode) {
    render-app:origElem($node, $mode)
};

declare function render-app:expan($node as element(tei:expan), $mode) {
    render-app:editElem($node, $mode)
};
declare function render-app:reg($node as element(tei:reg), $mode) {
    render-app:editElem($node, $mode)
};
declare function render-app:corr($node as element(tei:corr), $mode) {
    render-app:editElem($node, $mode)
};

declare function render-app:fw($node as element(tei:fw), $mode) {
    ()
};
