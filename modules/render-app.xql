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
import module namespace i18n      = "http://exist-db.org/xquery/i18n"        at "i18n.xql";

(:
~ A conglomeration of rendering mechanisms for different, not necessarily related parts of the app, such as search help, participants pages, etc.
:)

(:
~ Modes:
~  - 'participants': HTML rendering for the project team's page (projectTeam.html)
:)
declare function render-app:dispatch($node as node(), $mode as xs:string, $lang as xs:string?) {
    typeswitch($node)
    (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
        case text()                     return render-app:textNode($node, $mode, $lang)
        case element(tei:g)             return render-app:g($node, $mode, $lang)
        case element(tei:lb)            return render-app:lb($node, $mode, $lang)
        case element(tei:pb)            return render-app:pb($node, $mode, $lang)
        case element(tei:cb)            return render-app:cb($node, $mode, $lang)
        case element(tei:fw)            return render-app:fw($node, $mode, $lang)

        case element(tei:head)          return render-app:head($node, $mode, $lang) (: snippets: passthru :)
        case element(tei:p)             return render-app:p($node, $mode, $lang)
        case element(tei:note)          return render-app:note($node, $mode, $lang)
        case element(tei:div)           return render-app:div($node, $mode, $lang)
        case element(tei:milestone)     return render-app:milestone($node, $mode, $lang)
        
        case element(tei:event)         return render-app:event($node, $mode, $lang)
        
        case element(tei:abbr)          return render-app:abbr($node, $mode, $lang)
        case element(tei:orig)          return render-app:orig($node, $mode, $lang)
        case element(tei:sic)           return render-app:sic($node, $mode, $lang)
        case element(tei:expan)         return render-app:expan($node, $mode, $lang)
        case element(tei:reg)           return render-app:reg($node, $mode, $lang)
        case element(tei:corr)          return render-app:corr($node, $mode, $lang)
        
        case element(tei:persName)      return render-app:persName($node, $mode, $lang)
        case element(tei:placeName)     return render-app:placeName($node, $mode, $lang)
        case element(tei:orgName)       return render-app:orgName($node, $mode, $lang)
        case element(tei:title)         return render-app:name($node, $mode, $lang)
        case element(tei:name)          return render-app:nameNode($node, $mode, $lang)
        case element(tei:term)          return render-app:term($node, $mode, $lang)
        case element(tei:bibl)          return render-app:bibl($node, $mode, $lang)
        case element(tei:listBibl)      return render-app:listBibl($node, $mode, $lang)

        case element(tei:hi)            return render-app:hi($node, $mode, $lang) 
        case element(tei:emph)          return render-app:emph($node, $mode, $lang)
        case element(tei:ref)           return render-app:ref($node, $mode, $lang) 
        case element(tei:quote)         return render-app:quote($node, $mode, $lang)
        case element(tei:soCalled)      return render-app:soCalled($node, $mode, $lang)

        case element(tei:list)          return render-app:list($node, $mode, $lang)
        case element(tei:item)          return render-app:item($node, $mode, $lang)
        case element(tei:gloss)         return render-app:gloss($node, $mode, $lang)
        case element(tei:eg)            return render-app:eg($node, $mode, $lang)
        
        case element(tei:num)           return render-app:num($node, $mode, $lang)
        case element(tei:email)         return render-app:email($node, $mode, $lang)

        case element(tei:birth)         return render-app:birth($node, $mode, $lang) 
        case element(tei:death)         return render-app:death($node, $mode, $lang)
        
        case element(tei:keywords)      return render-app:keywords($node, $mode, $lang)

        case element(tei:figDesc)       return ()
        case element(tei:teiHeader)     return ()
        case comment()                  return ()
        case processing-instruction()   return ()

        default return render-app:passthru($node, $mode, $lang)
};



declare function render-app:textNode($node as node(), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case "html"
        case "work" return
            let $leadingSpace   := if (matches($node, '^\s+')) then ' ' else ()
            let $trailingSpace  := if (matches($node, '\s+$')) then ' ' else ()
            return concat($leadingSpace, 
                          normalize-space(replace($node, '&#x0a;', ' ')),
                          $trailingSpace)
        
        case 'snippets-orig' 
        case 'snippets-edit'
        case 'participants' return
            $node
        
        default return ()
};

declare function render-app:passthru($nodes as node()*, $mode as xs:string, $lang as xs:string?) as item()* {
    switch($mode)
        case 'participants' return
            for $node in $nodes/node() return 
                if (not($node/@xml:lang) or $node/@xml:lang eq $lang) then
                    render-app:dispatch($node, $mode, $lang)
                else ()
        default return
            for $node in $nodes/node() return render-app:dispatch($node, $mode, $lang)
};

declare function render-app:pb($node as element(tei:pb), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'html'
        case 'work' 
        case 'snippets-orig' 
        case 'snippets-edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        case 'participants' return ()
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render-app:cb($node as element(tei:cb), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'html'
        case 'work' 
        case 'snippets-orig' 
        case 'snippets-edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
        
        case 'participants' return ()
        
        default return () (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function render-app:lb($node as element(tei:lb), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'work' 
        case 'snippets-orig' 
        case 'snippets-edit' return
            if (not($node/@break = 'no')) then
                ' '
            else ()
    
        case 'html'
        case 'participants' return
            <br/>
        default return () 
};

declare function render-app:keywords($node as element(tei:keywords), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return ()
        default return render-app:passthru($node, $mode, $lang)
};

declare function render-app:p($node as element(tei:p), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        
        case 'participants' return 
            <p>{render-app:passthru($node, $mode, $lang)}</p>
        
        case 'html' return
            if ($node/ancestor::tei:note) then
                render-app:passthru($node, $mode, $lang)
            else
                <p class="hauptText" id="{$node/@xml:id}">
                    {render-app:passthru($node, $mode, $lang)}
                </p>
        
        case 'work' return   (: the same as in html mode except for distinguishing between paragraphs in notes and in the main text. In the latter case, make them a div, not a p and add a tool menu. :)
            if ($node/parent::tei:note) then
                render-app:passthru($node, $mode, $lang)
            else
                <p class="hauptText" id="{$node/@xml:id}">
                    {render-app:passthru($node, $mode, $lang)}
                </p>
                
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:note($node as element(tei:note), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'html'
        case 'work' return
            let $normalizedString := normalize-space(string-join(render-app:passthru($node, $mode, $lang), ' '))
            let $identifier       := $node/@xml:id
            return
                (<sup>*</sup>,
                <span class="marginal note" id="note_{$identifier}">
                    {if (string-length($normalizedString) gt $config:chars_summary) then
                        (<a class="{string-join(for $biblKey in $node//tei:bibl/@sortKey return concat('hi_', $biblKey), ' ')}" data-toggle="collapse" data-target="#subdiv_{$identifier}">{concat('* ', substring($normalizedString, 1, $config:chars_summary), '…')}<i class="fa fa-angle-double-down"/></a>,<br/>,
                         <span class="collapse" id="subdiv_{$identifier}">{render-app:passthru($node, $mode, $lang)}</span>)
                     else
                        <span><sup>* </sup>{render-app:passthru($node, $mode, $lang)}</span>
                    }
                </span>)
        
        case 'participants' return ()
        
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:div($node as element(tei:div), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'html' return
            if ($node/@n and not(matches($node/@n, '^[0-9\[\]]+$'))) then
                (<h4 id="{$node/@xml:id}">{string($node/@n)}</h4>,<p id="p_{$node/@xml:id}">{render-app:passthru($node, $mode, $lang)}</p>)
                (: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
            else
                <div id="{$node/@xml:id}">{render-app:passthru($node, $mode, $lang)}</div>
        
        case 'work' return (: basically, the same except for eventually adding a <div class="summary_title"/> the data for which is complicated to retrieve :)
            render-app:passthru($node, $mode, $lang)
        
        case 'participants' return ()
        
        default return
            render-app:passthru($node, $mode, $lang)
};


declare function render-app:milestone($node as element(tei:milestone), $mode as xs:string, $lang as xs:string?) {
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
        
        case 'work'
        case 'participants' return ()
        
        default return () 
};


(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function render-app:head($node as element(tei:head), $mode as xs:string, $lang as xs:string?) {
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
                    {render-app:passthru($node, $mode, $lang)}
                </h3>
        
        case 'participants' return
            <h4>{render-app:passthru($node, $mode, $lang)}</h4>
        
        default return 
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:origElem($node as element(), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'html'
        case 'work' return
            let $editedString := render-app:dispatch($node/parent::tei:choice/(tei:expan|tei:reg|tei:corr), "edit", $lang)
            return  if ($node/parent::tei:choice) then
                        <span class="original {local-name($node)} unsichtbar" title="{string-join($editedString, '')}">
                            {render-app:passthru($node, $mode, $lang)}
                        </span>
                    else
                        render-app:passthru($node, $mode, $lang)
        
        case 'snippets-orig' return
            render-app:passthru($node, $mode, $lang)
        
        case 'snippets-edit' return
            if (not($node/(preceding-sibling::tei:expan|preceding-sibling::tei:reg|preceding-sibling::tei:corr|following-sibling::tei:expan|following-sibling::tei:reg|following-sibling::tei:corr))) then
                render-app:passthru($node, $mode, $lang)
            else ()
        case 'participants' return ()
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:editElem($node as element(), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case "html"
        case "work" return
            let $originalString := render-app:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), "orig", $lang)
            return  
                <span class="edited {local-name($node)}" title="{string-join($originalString, '')}">
                    {render-app:passthru($node, $mode, $lang)}
                </span>
        
        case 'snippets-orig' return ()
        case 'snippets-edit' return
            render-app:passthru($node, $mode, $lang)
        case 'participants' return ()
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:g($node as element(tei:g), $mode as xs:string, $lang as xs:string?) {
    switch ($mode)
        case "work" return
            let $originalGlyph := render-app:g($node, "orig", $lang)
            return
                (<span class="original glyph unsichtbar" title="{$node/text()}">
                    {$originalGlyph}
                </span>,
                <span class="edited glyph" title="{$originalGlyph}">
                    {$node/text()}
                </span>)
        case 'participants' return ()
        default return (: also 'snippets-edit' :)
            render-app:passthru($node, $mode, $lang)
};

(: FIXME: In the following, work mode functionality has to be added - also paying attention to intervening pagebreak marginal divs :)
declare function render-app:term($node as element(tei:term), $mode as xs:string, $lang as xs:string?) {
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
                        <a href="{session:encode-url(xs:anyURI('lemma.html?lid=' || $getLemmaId))}">{render-app:passthru($node, $mode, $lang)}</a>
                     else
                        render-app:passthru($node, $mode, $lang)
                    }
                </span>
        case 'snippets-orig' return
            render-app:passthru($node, $mode, $lang)
        case 'snippets-edit' return
            if ($node/@key) then
                string($node/@key)
            else
                render-app:passthru($node, $mode, $lang)
        case 'participants' return ()
        default return
            render-app:passthru($node, $mode, $lang)
};


declare function render-app:name($node as element(*), $mode as xs:string, $lang as xs:string?) {
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
                         <a href="{concat($config:idserver, '/works.', $getWorkId)}" title="{$key}">{render-app:passthru($node, $mode, $lang)}</a>
                     </span> 
               else if ($getAutId) then
                     <span class="{($nodeType || ' hi_author_' || $getAutId)}">
                         <a href="{concat($config:idserver, '/authors.', $getAutId)}" title="{$key}">{render-app:passthru($node, $mode, $lang)}</a>
                     </span> 
                else if ($getCerlId) then 
                     <span class="{($nodeType || ' hi_cerl_' || $getCerlId)}">
                        <a target="_blank" href="{('http://thesaurus.cerl.org/cgi-bin/record.pl?rid=' || $getCerlId)}" title="{$key}">{render-app:passthru($node, $mode, $lang)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                     </span>
                else if ($getGndId) then 
                     <span class="{($nodeType || ' hi_gnd_' || $getGndId)}">
                        <a target="_blank" href="{('http://d-nb.info/' || $getGndId)}" title="{$key}">{render-app:passthru($node, $mode, $lang)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                     </span>
                else if ($getGettyId) then 
                     <span class="{($nodeType || ' hi_getty_' || $getGettyId)}">
                        <a target="_blank" href="{('http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=' || $getGettyId)}" title="{$key}">{render-app:passthru($node, $mode, $lang)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                     </span>
                else
                    <span>{render-app:passthru($node, $mode, $lang)}</span>
        
        case 'participants' return 
            <h4>{render-app:passthru($node, $mode, $lang)}</h4>
        
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:bibl($node as element(tei:bibl), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'work' return
            let $getBiblId :=  $node/@sortKey
            return if ($getBiblId) then
                        <span class="{('work hi_' || $getBiblId)}">
                            {render-app:passthru($node, $mode, $lang)}
                        </span>
                    else
                        render-app:passthru($node, $mode, $lang)
        
        case 'participants' return
            <li>{render-app:passthru($node, $mode, $lang)}</li>
        
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:listBibl($node as element(tei:listBibl), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return
            if ($node/@type eq 'publications') then
                <div>
                    <h4><i18n:text key="selectedPublications"/></h4>
                    <ul>{render-app:passthru($node, $mode, $lang)}</ul>
                </div>
            else
                <ul>{render-app:passthru($node, $mode, $lang)}</ul>
        
        default return
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:emph($node as element(tei:emph), $mode as xs:string, $lang as xs:string?) {
    if ($mode = "work") then
        <span class="emph">{render-app:passthru($node, $mode, $lang)}</span>
    else if ($mode = "html") then
        <em>{render-app:passthru($node, $mode, $lang)}</em>
    else
        render-app:passthru($node, $mode, $lang)
};

declare function render-app:hi($node as element(tei:hi), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'html'
        case 'work'
        case 'participants' return
            switch($node/@rendition/string())
                case "#b" return
            <b>{render-app:passthru($node, $mode, $lang)}</b>
                case "#initCaps" return
                    <span class="initialCaps">{render-app:passthru($node, $mode, $lang)}</span>
                case "#it" return
                    <it>{render-app:passthru($node, $mode, $lang)}</it>
                case "#l-indent" return
                    <span style="display:block;margin-left:4em;">
                        {render-app:passthru($node, $mode, $lang)}
                    </span>
                case "#r-center" return
                    <span style="display:block;text-align:center;">
                        {render-app:passthru($node, $mode, $lang)}
                    </span>
                case "#sc" return
                    <span class="smallcaps">
                        {render-app:passthru($node, $mode, $lang)}
                    </span>
                case "#spc" return
                    <span class="spaced">
                        {render-app:passthru($node, $mode, $lang)}
                    </span>
                case "#sub" return
                    <sub>
                        {render-app:passthru($node, $mode, $lang)}
                    </sub>
                case "#sup" return
                    <sup>
                        {render-app:passthru($node, $mode, $lang)}
                    </sup>
                default return
                    <it>
                        {render-app:passthru($node, $mode, $lang)}
                    </it>
        default return 
            render-app:passthru($node, $mode, $lang)
};
declare function render-app:ref($node as element(tei:ref), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "participants") and $node/@type = "url") then
        if (substring($node/@target, 1, 4) = "http") then
            <a href="{$node/@target}" target="_blank">{render-app:passthru($node, $mode, $lang)}</a>
        else
            <a href="{$node/@target}">{render-app:passthru($node, $mode, $lang)}</a>
    else if ($mode = "work") then                                       (: basically the same, but use the resolveURI functions to get the actual target :)
        <a href="{$node/@target}">{render-app:passthru($node, $mode, $lang)}</a>
    else
        render-app:passthru($node, $mode, $lang)
};
declare function render-app:soCalled($node as element(tei:soCalled), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "work")) then
        <span class="soCalled">{render-app:passthru($node, $mode, $lang)}</span>
    else if ($mode eq 'participants') then render-app:passthru($node, $mode, $lang)
    else
        ("'", render-app:passthru($node, $mode, $lang), "'")
};
declare function render-app:quote($node as element(tei:quote), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "work", "participants")) then
        <span class="quote">{render-app:passthru($node, $mode, $lang)}</span>
    else
        ('"', render-app:passthru($node, $mode, $lang), '"')
};

declare function render-app:list($node as element(tei:list), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
         case 'html'
         case 'work' return
             if ($node/@type = "ordered") then
                 <section>
                     {if ($node/child::tei:head) then
                         for $head in $node/tei:head
                             return
                                 <h4>
                                     {render-app:passthru($head, $mode, $lang)}
                                 </h4>
                      else ()
                     }
                     <ol>
                         {for $item in $node/tei:*[not(local-name() = "head")]
                                 return
                                     render-app:dispatch($item, $mode, $lang)
                         }
                     </ol>
                 </section>
             else if ($node/@type = "simple") then
                 <section>
                     {if ($node/tei:head) then
                         for $head in $node/tei:head
                             return
                                 <h4>{render-app:passthru($head, $mode, $lang)}</h4>
                      else ()
                     }
                     {for $item in $node/tei:*[not(local-name() = "head")]
                             return
                                     render-app:dispatch($item, $mode, $lang)
                     }
                 </section>
             else
                 <figure class="{$node/@type}">
                     {if ($node/child::tei:head) then
                         for $head in $node/tei:head
                             return
                                 <h4>{render-app:passthru($head, $mode, $lang)}</h4>
                      else ()
                     }
                     <ul>
                         {for $item in $node/tei:*[not(local-name() = "head")]
                                 return
                                     render-app:dispatch($item, $mode, $lang)
                         }
                     </ul>
                 </figure>
         
         case 'participants' return
             <ul>{render-app:passthru($node, $mode, $lang)}</ul>
         
         default return
             ($config:nl, render-app:passthru($node, $mode, $lang), $config:nl)
};

declare function render-app:item($node as element(tei:item), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case "html"
        case "work" return
            if ($node/parent::tei:list/@type="simple") then
                render-app:passthru($node, $mode, $lang)
            else
                <li>{render-app:passthru($node, $mode, $lang)}</li>
        
        case 'participants' return
            <li>{render-app:passthru($node, $mode, $lang)}</li>
        
        case 'snippets-orig' 
        case 'snippets-edit' return
            ($config:nl, render-app:passthru($node, $mode, $lang), $config:nl)
        
        default return
            render-app:passthru($node, $mode, $lang)
};
declare function render-app:gloss($node as element(tei:gloss), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "work")) then
        render-app:passthru($node, $mode, $lang)
    else if ($mode eq 'participants') then ()
    else
        render-app:passthru($node, $mode, $lang)
};

declare function render-app:eg($node as element(tei:eg), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "work")) then
        <pre>{render-app:passthru($node, $mode, $lang)}</pre>
    else if ($mode eq 'participants') then ()
    else 
        render-app:passthru($node, $mode, $lang)
};


declare function render-app:birth($node as element(tei:birth), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "work")) then
        <span>*&#xA0;{render-app:name($node/tei:placeName[1], $mode, $lang) || ': ' || $node/tei:date[1]}</span>
    else if ($mode eq 'participants') then render-app:passthru($node, $mode, $lang)
    else ()
};
declare function render-app:death($node as element(tei:death), $mode as xs:string, $lang as xs:string?) {
    if ($mode = ("html", "work")) then
        <span>†&#xA0;{render-app:name($node/tei:placeName[1], $mode, $lang) || ': ' || $node/tei:date[1]}</span>
    else if ($mode eq 'participants') then render-app:passthru($node, $mode, $lang)
    else ()
};

declare function render-app:persName($node as element(tei:persName), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return
            render-app:passthru($node, $mode, $lang)
        default return
            render-app:name($mode, $node, $lang)
};

declare function render-app:placeName($node as element(tei:placeName), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return
            render-app:passthru($node, $mode, $lang)
        default return
            render-app:name($mode, $node, $lang)
};

declare function render-app:orgName($node as element(tei:orgName), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return
            render-app:passthru($node, $mode, $lang)
        default return
            render-app:name($mode, $node, $lang)
};

declare function render-app:title($node as element(tei:title), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case "html"
        case "work" return
            if ($node/@ref) then
                 <span class="bibl-title"><a target="blank" href="{$node/@ref}">{render-app:passthru($node, $mode, $lang)}<span class="glyphicon glyphicon-new-window" aria-hidden="true"/></a></span>
            else
                 <span class="bibl-title">{render-app:passthru($node, $mode, $lang)}</span>
        case 'participants' return ()
        default return
            render-app:passthru($mode, $node, $lang)
};

declare function render-app:nameNode($node as element(tei:name), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return ()
        default return 
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:num($node as element(tei:num), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return 
            if ($node/@type eq 'phone') then
                <span><i18n:text key="phoneAbbr"/>{(': ', render-app:passthru($node, $mode, $lang))}</span>
            else ()
        default return 
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:email($node as element(tei:email), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return 
            <span><i18n:text key="email"/>{(': ', render-app:passthru($node, $mode, $lang))}</span>
        default return 
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:event($node as element(tei:event), $mode as xs:string, $lang as xs:string?) {
    switch($mode)
        case 'participants' return 
            if ($node/@type eq 'person') then
                <div>
                    <h4><i18n:text key="cv"/></h4>
                    {render-app:passthru($node, $mode, $lang)}
                </div>
            else if ($node/@type eq 'research_interest') then
                <div>
                    <h4><i18n:text key="researchInterests"/></h4>
                    {render-app:passthru($node, $mode, $lang)}
                </div>
            else 
                <div>{render-app:passthru($node, $mode, $lang)}</div>
        default return 
            render-app:passthru($node, $mode, $lang)
};

declare function render-app:abbr($node as element(tei:abbr), $mode as xs:string, $lang as xs:string?) {
    render-app:origElem($node, $mode, $lang)
};

declare function render-app:orig($node as element(tei:orig), $mode as xs:string, $lang as xs:string?) {
    render-app:origElem($node, $mode, $lang)
};

declare function render-app:sic($node as element(tei:sic), $mode as xs:string, $lang as xs:string?) {
    render-app:origElem($node, $mode, $lang)
};

declare function render-app:expan($node as element(tei:expan), $mode as xs:string, $lang as xs:string?) {
    render-app:editElem($node, $mode, $lang)
};
declare function render-app:reg($node as element(tei:reg), $mode as xs:string, $lang as xs:string?) {
    render-app:editElem($node, $mode, $lang)
};
declare function render-app:corr($node as element(tei:corr), $mode as xs:string, $lang as xs:string?) {
    render-app:editElem($node, $mode, $lang)
};

declare function render-app:fw($node as element(tei:fw), $mode as xs:string, $lang as xs:string?) {
    ()
};
