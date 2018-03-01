xquery version "3.0";

module namespace render            = "http://salamanca/render";
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
import module namespace app        = "http://salamanca/app"    at "app.xql";
import module namespace functx     = "http://www.functx.com";
import module namespace transform  = "http://exist-db.org/xquery/transform";

(:declare option exist:serialize       "method=html5 media-type=text/html indent=no";:)

(: ####====---- Helper Functions ----====#### :)

declare function render:authorString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentAuthorId  := $model('currentAuthor')/@xml:id/string()
    return <td><a href="author.html?aid={$currentAuthorId}">{$currentAuthorId} - {app:AUTname($node, $model)}</a></td>
};

declare function render:authorMakeHTML($node as node(), $model as map(*)) {
    let $currentAuthorId := $model('currentAuthor')/@xml:id/string()
    return if (render:needsRender($currentAuthorId)) then
                <td title="source from: {string(xmldb:last-modified($config:tei-authors-root, $currentAuthorId || '.xml'))}{if (xmldb:collection-available($config:temp) and xmldb:get-child-resources($config:temp) = $currentAuthorId || ".html") then concat(', rendered on: ', xmldb:last-modified($config:temp, $currentAuthorId || ".html")) else ()}"><a href="renderTheRest.html?aid={$currentAuthorId}"><b>Render NOW!</b></a></td>
            else
                <td title="source from: {string(xmldb:last-modified($config:tei-authors-root, $currentAuthorId || '.xml'))}, Rendered on: {xmldb:last-modified($config:temp, $currentAuthorId || '.html')}">Rendering unnecessary. <small><a href="renderTheRest.html?aid={$currentAuthorId}">Render anyway!</a></small></td>
};

declare function render:lemmaString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentLemmaId  := string($model('currentLemma')/@xml:id)
    return <td><a href="lemma.html?lid={$currentLemmaId}">{$currentLemmaId} - {app:LEMtitle($node, $model)}</a></td>
};

declare function render:lemmaMakeHTML($node as node(), $model as map(*)) {
    let $currentLemmaId := string($model('currentLemma')/@xml:id)
    return if (render:needsRender($currentLemmaId)) then
                <td title="source from: {string(xmldb:last-modified($config:tei-lemmata-root, $currentLemmaId || '.xml'))}{if (xmldb:collection-available($config:temp) and xmldb:get-child-resources($config:temp) = $currentLemmaId || ".html") then concat(', rendered on: ', xmldb:last-modified($config:temp, $currentLemmaId || ".html")) else ()}"><a href="renderTheRest.html?lid={$currentLemmaId}"><b>Render NOW!</b></a></td>
            else
                <td title="source from: {string(xmldb:last-modified($config:tei-lemmata-root, $currentLemmaId || '.xml'))}, Rendered on: {xmldb:last-modified($config:temp, $currentLemmaId || ".html")}">Rendering unnecessary. <small><a href="renderTheRest.html?lid={$currentLemmaId}">Render anyway!</a></small></td>
};
           
declare function render:WPString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentWPId  := string($model('currentWp')/@xml:id)
    return <td><a href="workingPaper.html?wpid={$currentWPId}">{$currentWPId} - {app:WPtitle($node, $model)}</a></td>
};

declare function render:needsRender($targetWorkId as xs:string) as xs:boolean {
    let $targetSubcollection := for $subcollection in $config:tei-sub-roots return 
                                    if (doc-available(concat($subcollection, '/', $targetWorkId, '.xml'))) then $subcollection
                                    else ()
    let $workModTime := xmldb:last-modified($targetSubcollection, $targetWorkId || '.xml')
    return
        if (substring($targetWorkId,1,2) eq "W0") then
            if ($targetWorkId || "_nodeIndex.xml" = xmldb:get-child-resources($config:data-root)) then
                    let $renderModTime := xmldb:last-modified($config:data-root, $targetWorkId || "_nodeIndex.xml")
                    return if ($renderModTime lt $workModTime) then true() else false()
            else
                true()
        else if (substring($targetWorkId,1,2) = ("A0", "L0", "WP")) then
            if (not(xmldb:collection-available($config:data-root))) then
                true()
            else if ($targetWorkId || ".html" = xmldb:get-child-resources($config:data-root)) then
                    let $renderModTime := xmldb:last-modified($config:data-root, $targetWorkId || ".html")
                    return if ($renderModTime lt $workModTime) then true() else false()
            else
                true()
        else
            true()
};

declare function render:workString($node as node(), $model as map(*), $lang as xs:string?) {
    let $currentWorkId  := string($model('currentWork')/@xml:id)
    return <td><a href="{$config:webserver}/en/work.html?wid={$currentWorkId}">{$currentWorkId}: {app:WRKauthor($node, $model)} - {app:WRKtitleShort($node, $model)}</a></td>
};

declare function render:needsRenderString($node as node(), $model as map(*)) {
    let $currentWorkId := string($model('currentWork')/@xml:id)
    return if (render:needsRender($currentWorkId)) then
                    <td title="Source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}{if (xmldb:get-child-resources($config:data-root) = $currentWorkId || "_nodeIndex.xml") then concat(', rendered on: ', xmldb:last-modified($config:data-root, $currentWorkId || "_nodeIndex.xml")) else ()}"><a href="render.html?wid={$currentWorkId}"><b>Render NOW!</b></a></td>
            else
                    <td title="Source from: {string(xmldb:last-modified($config:tei-works-root, $currentWorkId || '.xml'))}, rendered on: {xmldb:last-modified($config:data-root, $currentWorkId || "_nodeIndex.xml")}">Rendering unnecessary. <small><a href="render.html?wid={$currentWorkId}">Render anyway!</a></small></td>
};


declare function render:needsCorpusZipString($node as node(), $model as map(*)) {
    let $worksModTime := max(for $work in xmldb:get-child-resources($config:tei-works-root) return xmldb:last-modified($config:tei-works-root, $work))    
    let $needsCorpusZip := if (util:binary-doc-available($config:data-root || '/sal-tei-corpus.zip')) then
                let $resourceModTime := xmldb:last-modified($config:data-root, 'sal-tei-corpus.zip')
                return if ($resourceModTime lt $worksModTime) then true() else false()
        else
            true()

    return if ($needsCorpusZip) then
                <td title="Most current source from: {string($worksModTime)}"><a href="corpus-admin.xql"><b>Create corpus zip NOW!</b></a></td>
            else
                <td title="{concat('Corpus zip created on: ', string(xmldb:last-modified($config:data-root, 'sal-tei-corpus.zip')), ', most current source from: ', string($worksModTime), '.')}">Creating corpus zip unnecessary. <small><a href="corpus-admin.xql">Create corpus zip anyway!</a></small></td>
    
};


(: Todo: :)
(:
   ✓ Fix lbs
   ✓ Fix pbs not to include sameAs pagebreaks
   ✓ Fix milestones and notes to have divs as predecessors, not p's
   - Add head,
         ref,
         reg,
         corr,
         ...?
:)
declare function render:getCrumbtrail ($targetWork as node()*, $targetNode as node(), $mode as xs:string) {
    let $targetWorkId   := string($targetWork/@xml:id)
    let $targetNodeId   := string($targetNode/@xml:id)
    let $node           :=       if ($mode = 'html') then
                                    <a href='{render:mkUrl($targetWork, $targetNode)}'>{app:sectionTitle($targetWork, $targetNode)}</a>
                            else if ($mode = 'numeric') then
                                    typeswitch($targetNode)
                                        case element(tei:front)
                                            return 'frontmatter'
                                        case element(tei:back)
                                            return 'backmatter'
                                        case element(tei:titlePage)
                                            return 'titlepage'
                                        case element(tei:titlePart)                                             (: "titlePage.X" where X is the number of parts where this occurs :)
                                            return concat('titlepage.', string(count($targetNode/preceding-sibling::tei:titlePart) + 1))
                                        case element(tei:text)                                                  (: "volX" where X is the current volume number, don't use it at all for monographs :)
                                            return if ($targetNode/@type='work_volume') then
                                                       concat('vol', count($targetNode/preceding::tei:text[@type = 'work_volume']) + 1)
                                                   else ()
                                        case element(tei:note)                                                  (: "nX" where X is the anchor used (if it is alphanumeric) and "nXY" where Y is the number of times that X occurs inside the current div :)
                                            return concat('n',  if (matches($targetNode/@n, '[A-Za-z0-9]')) then
                                                                    if (count($targetNode/ancestor::tei:div[1]//tei:note[@n = $targetNode/@n]) gt 1) then
                                                                        concat(upper-case(replace($targetNode/@n, '[^a-zA-Z0-9]', '')),
                                                                               string(count($targetNode/ancestor::tei:div[1]//tei:note intersect $targetNode/preceding::tei:note[@n = $targetNode/@n])+1)
                                                                              )
                                                                    else
                                                                       upper-case(replace($targetNode/@n, '[^a-zA-Z0-9]', ''))
                                                                else
                                                                       count($targetNode/preceding::tei:note intersect $targetNode/ancestor::tei:div[1]//tei:note) + 1)
                                        case element(tei:milestone)                                             (: "XY" where X is the unit (if there is one) and Y is the anchor or the number of milestones where this occurs :)
                                            return concat(if ($targetNode/@unit) then
                                                              string($targetNode/@unit)
                                                          else (),
                                                          if ($targetNode/@n) then
                                                              replace($targetNode/@n, '[^a-zA-Z0-9]', '')
                                                          else
                                                              count($targetNode/preceding::tei:milestone intersect $targetNode/ancestor::tei:div[1]//tei:milestone) + 1)
                                        case element(tei:item)                                                  (: "entryX" where X is the section title (app:sectionTitle) in capitals, use only for items in indexes and dictionary :)
                                            return if($targetNode/ancestor::tei:list/@type = ('dict', 'index')) then
                                                       concat('entry', upper-case(replace(app:sectionTitle($targetWork, $targetNode), '[^a-zA-Z0-9]', '')))
                                                   else
                                                       string(count($targetNode/preceding::tei:item intersect $targetNode/ancestor::tei:list[1]//tei:item) + 1)
                                        case element(tei:list)
                                            return if($targetNode/@type = ('dict', 'index', 'summaries')) then               (: dictionaries, indices and summaries get their type prepended to their number :) 
(:                                            return if($targetNode/@type = ('dict', 'index')) then               (\: dictionaries and indices get their type prepended to their number :\):)
                                                       concat($targetNode/@type, string(count($targetNode/preceding::tei:list[@type = ('dict', 'index', 'summaries')] intersect
                                                                                                                                              $targetNode/(
                                                                                                                                                           ancestor::tei:div   |
                                                                                                                                                           ancestor::tei:body  |
                                                                                                                                                           ancestor::tei:front |
                                                                                                                                                           ancestor::tei:back
                                                                                                                                                          )[last()]//tei:list[@type = ('dict', 'index', 'summaries')]) + 1)
                                                              )
                                                   else                                                         (: other types of lists are simply counted :)
                                                        string(count(
                                                                      $targetNode/preceding-sibling::tei:div[@type ne "work_part"]  |
                                                                      $targetNode/preceding-sibling::tei:p (: [$targetNode/self::tei:p] :) | (: We happen to have lists as siblings following ps... :)
                                                                      $targetNode/preceding::tei:list[not(@type = ('dict', 'index', 'summaries'))] intersect
                                                                                                                                              $targetNode/(
                                                                                                                                                           ancestor::tei:div   |
                                                                                                                                                           ancestor::tei:body  |
                                                                                                                                                           ancestor::tei:front |
                                                                                                                                                           ancestor::tei:back
                                                                                                                                                          )[last()]//tei:list[not(@type = ('dict', 'index', 'summaries'))]) + 1)
                                        case element(tei:lb)                                                    (: "pXlineY" where X is page and Y line number :)
                                            return concat('l',  if (matches($targetNode/@n, '[A-Za-z0-9]')) then
                                                                    replace(substring-after($targetNode/@n, '_'), '[^a-zA-Z0-9]', '')
                                                                else
                                                                    string(count($targetNode/preceding::tei:lb intersect $targetNode/preceding::tei:pb[1]/following::tei:lb) + 1)
                                                          )
                                        case element(tei:pb)                                                    (: "pX" where X is page number :)
                                            return concat('p',  if (matches($targetNode/@n, '[A-Za-z0-9]')) then
                                                                    upper-case(replace($targetNode/@n, '[^a-zA-Z0-9]', ''))
                                                                else
                                                                    substring($targetNode/@facs, 6)
                                                          )
                                        case element(tei:head)
                                            return  concat('heading', (if (count($targetNode/(
                                                                                    parent::tei:back                                                            |
                                                                                    parent::tei:div[@type ne "work_part"]                                       |
                                                                                    parent::tei:front                                                           |
                                                                                    parent::tei:list                                                            |
                                                                                    parent::tei:titlePart
                                                                                )/tei:head) gt 1) then          (: We have several headings on this level of the document ... :)
                                                                            string(count($targetNode/preceding-sibling::tei:head) + 1)
                                                                        else ()
                                                                        )
                                                            )
(: Other section types (e.g. ps and divs) are identified by number :)
                                        default
                                            return string(count(
                                                                 $targetNode/preceding-sibling::tei:div[@type ne "work_part"]  |
                                                                 $targetNode/preceding-sibling::tei:p (: [$targetNode/self::tei:p] :) | (: We happen to have divs as siblings following ps... :)
                                                                 $targetNode/preceding::tei:list[not (@type = ('dict', 'index', 'summaries'))] intersect
                                                                        $targetNode/(
                                                                                        ancestor::tei:back                        |
                                                                                        ancestor::tei:div[@type ne "work_part"]   |
                                                                                        ancestor::tei:body                        |
                                                                                        ancestor::tei:front                       |
                                                                                        ancestor::tei:back
                                                                                    )[last()]//tei:list[not (@type = ('dict', 'index', 'summaries'))]
                                                               ) + 1)
                            else (: neither html nor numeric mode :) 
                                app:sectionTitle($targetWork, $targetNode)
    let $crumbtrail := (
                        if ($targetNode/(                                                                                   (: === get parent node's "name" - HERE is the RECURSION === :)
                                            ancestor::tei:back                                                                  |
                                            ancestor::tei:div[@type ne "work_part"]                                             |
                                            ancestor::tei:front                                                                 |
                                            ancestor::tei:item[ancestor::tei:list[1][@type = ('dict', 'index', 'summaries')]]   |
                                            ancestor::tei:list[@type = ('dict', 'index', 'summaries')]                          |
                                            ancestor::tei:note                                                                  |
                                            ancestor::tei:p                                                                     |
                                            ancestor::tei:text[not(@xml:id = 'completeWork' or @type = "work_part")]            |
                                            ancestor::tei:titlePart                                                 
                                        )
                           ) then
                                    if ($targetNode[self::tei:lb] | $targetNode[self::tei:cb]) then
                                        render:getCrumbtrail($targetWork,  $targetNode/preceding::tei:pb[1], $mode)
                               else if ($targetNode[self::tei:pb] and ($targetNode/ancestor::tei:front | $targetNode/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")])) then
                                        render:getCrumbtrail($targetWork,  ($targetNode/ancestor::tei:front | $targetNode/ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")])[last()], $mode)
                               else if ($targetNode[self::tei:pb]) then
                                        ()
                               else
                                        render:getCrumbtrail($targetWork, $targetNode/(
                                                                                          ancestor::tei:back[1]                                                                     |
                                                                                          ancestor::tei:div[@type ne "work_part"][1]                                                |
                                                                                          ancestor::tei:front[1]                                                                    |
                                                                                          ancestor::tei:item[ancestor::tei:list[1][@type = ('dict', 'index', 'summaries')]][1]      |
                                                                                          ancestor::tei:list[@type = ('dict', 'index', 'summaries')][1]                             |
                                                                                          ancestor::tei:note[1][not($targetNode[self::tei:milestone])]                              |
                                                                                          ancestor::tei:p[1][not($targetNode[self::tei:milestone] | $targetNode[self::tei:note])]   |
                                                                                          ancestor::tei:text[1][not(@xml:id = 'completeWork' or @type = "work_part")]               |
                                                                                          ancestor::tei:titlePart[1]
                                                                                      )[last()], $mode)
                        else (),

                        if ($targetNode[                                                                            (: === get connector MARKER: ".", " » ", or none === :)
                                        self::tei:back      or
                                        self::tei:div[@type ne "work_part"]       or
                                        self::tei:front     or
                                        self::tei:item      or
                                        self::tei:lb        or
                                        self::tei:list      or
                                        self::tei:milestone or
                                        self::tei:note      or
                                        self::tei:p         or
                                       (self::tei:pb and (ancestor::tei:front | ancestor::tei:text[not(@xml:id = 'completeWork' or @type = "work_part")])) or
                                        self::tei:text      or
                                        self::tei:titlePage or
                                        self::tei:titlePart
                                       ] and $targetNode/(
                                                          ancestor::tei:back                                                        |
                                                          ancestor::tei:div[@type ne "work_part"]                                   |
                                                          ancestor::tei:front                                                       |
                                                          ancestor::tei:item                                                        |
                                                          ancestor::tei:list                                                        |
                                                          ancestor::tei:note                                                        |
                                                          ancestor::tei:p                                                           |
                                                          ancestor::tei:text[not(@xml:id = 'completeWork' or @type = "work_part")]  |
                                                          ancestor::tei:titlePart 
                                                         )
                           ) then
                                if ($mode = 'html') then ' » ' else if ($mode = 'numeric') then '.' else ()
                        else (),

                        if ($targetNode[                                                                            (: === get current node's "NAME" === :)
                                        self::tei:front     or
                                        self::tei:back      or
                                        self::tei:div[@type ne "work_part"]       or
                                        self::tei:milestone or
                                        self::tei:text      or
                                        self::tei:note      or
                                        self::tei:p         or
                                        self::tei:item      or
                                        self::tei:pb        or
                                        self::tei:lb        or
                                        self::tei:titlePage or
                                        self::tei:titlePart or
                                        self::tei:list
                                       ]) then
                            $node                                           (: defined before/above :)
                        else ()
                       )
    return $crumbtrail
};

declare function render:mkAnchor ($targetWork as node()*, $targetNode as node()) {
    let $targetWorkId := string($targetWork/tei:TEI/@xml:id)
    let $targetNodeId := string($targetNode/@xml:id)
    return <a href="{render:mkUrl($targetWork, $targetNode)}">{app:sectionTitle($targetWork, $targetNode)}</a>    
};

declare function render:mkUrl ($targetWork as node(), $targetNode as node()) {
    let $targetWorkId := string($targetWork/@xml:id)
    let $targetNodeId := string($targetNode/@xml:id)
    let $viewerPage   :=      if (substring($targetWorkId, 1, 2) eq "W0") then
                            "work.html?wid="
                         else if (substring($targetWorkId, 1, 2) eq "L0") then
                            "lemma.html?lid="
                         else if (substring($targetWorkId, 1, 2) eq "A0") then
                            "author.html?aid="
                         else if (substring($targetWorkId, 1, 2) eq "WP") then
                            "workingPaper.html?wpid="
                         else
                            "index.html?wid="
    let $targetNodeHTMLAnchor :=    if (contains($targetNodeId, 'facs_')) then
                                        replace($targetNodeId, 'facs_', 'pageNo_')
                                    else
                                        $targetNodeId
    let $frag := render:getFragmentFile($targetWorkId, $targetNodeId)
    return concat($viewerPage, $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeHTMLAnchor)
};

declare function render:getFragmentFile ($targetWorkId as xs:string, $targetNodeId as xs:string) {
    doc($config:data-root || '/' || $targetWorkId || '_nodeIndex.xml')//sal:node[@n = $targetNodeId][1]/sal:fragment/text()
};

(: ####====---- End Helper Functions ----====#### :)




(: ####====---- Actual Rendering Typeswitch Functions ----====#### :)


(: $mode can be "orig", "edit" (both being plain text modes), "html" or, even more sophisticated, "work" :)
declare function render:dispatch($node as node(), $mode as xs:string) {
    typeswitch($node)
    (: Try to sort the following nodes based (approx.) on frequency of occurences, so fewer checks are needed. :)
        case text()                 return local:text($node, $mode)

        case element(tei:lb)        return local:break($node, $mode)
        case element(tei:pb)        return local:break($node, $mode)
        case element(tei:cb)        return local:break($node, $mode)
        case element(tei:fw)        return ()

        case element(tei:head)      return local:head($node, $mode)
        case element(tei:p)         return local:p($node, $mode)
        case element(tei:note)      return local:note($node, $mode)
        case element(tei:div)       return local:div($node, $mode)
        case element(tei:milestone) return local:milestone($node, $mode)
        
        case element(tei:abbr)      return local:orig($node, $mode)
        case element(tei:orig)      return local:orig($node, $mode)
        case element(tei:sic)       return local:orig($node, $mode)
        case element(tei:expan)     return local:edit($node, $mode)
        case element(tei:reg)       return local:edit($node, $mode)
        case element(tei:corr)      return local:edit($node, $mode)
        case element(tei:g)         return local:g($node, $mode)

        case element(tei:persName)  return local:name($node, $mode)
        case element(tei:placeName) return local:name($node, $mode)
        case element(tei:orgName)   return local:name($node, $mode)
        case element(tei:title)     return local:name($node, $mode)
        case element(tei:term)      return local:term($node, $mode)
        case element(tei:bibl)      return local:bibl($node, $mode)

        case element(tei:hi)        return local:hi($node, $mode)
        case element(tei:emph)      return local:emph($node, $mode)
        case element(tei:ref)       return local:ref($node, $mode)
        case element(tei:quote)     return local:quote($node, $mode)
        case element(tei:soCalled)  return local:soCalled($node, $mode)

        case element(tei:list)      return local:list($node, $mode)
        case element(tei:item)      return local:item($node, $mode)
        case element(tei:gloss)     return local:gloss($node, $mode)
        case element(tei:eg)        return local:eg($node, $mode)


        case element(tei:birth)     return local:birth($node, $mode)
        case element(tei:death)     return local:death($node, $mode)


        case element(tei:figDesc)     return ()
        case element(tei:teiHeader)   return ()
        case comment()                return ()
        case processing-instruction() return ()

        default return local:passthru($node, $mode)
};

declare function local:text($node as node(), $mode as xs:string) {
    if ($mode = ("orig", "edit", "html", "work")) then
        let $leadingSpace   := if (matches($node, '^\s+')) then ' ' else ()
        let $trailingSpace  := if (matches($node, '\s+$')) then ' ' else ()
        return concat($leadingSpace, 
                      normalize-space(replace($node, '&#x0a;', ' ')),
                      $trailingSpace)
    else ()
};

declare function local:passthru($nodes as node()*, $mode as xs:string) as item()* {
(:    for $node in $nodes/node() return element {name($node)} {($node/@*, local:dispatch($node, $mode))}:)
    for $node in $nodes/node() return render:dispatch($node, $mode)
};

declare function local:break($node as element(), $mode as xs:string) {
    if ($mode = ("orig", "edit", "html", "work")) then
        if (not($node/@break = 'no')) then
            ' '
        else ()
    else ()         (: some sophisticated function to insert a pipe and a pagenumber div in the margin :)
};

declare function local:p($node as element(tei:p), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        if ($node/ancestor::tei:note) then
            if ($node/following-sibling::tei:p) then
                (local:passthru($node, $mode), $config:nl)
            else
                local:passthru($node, $mode)
        else
            ($config:nl, local:passthru($node, $mode), $config:nl)
    else if ($mode = "html") then
        if ($node/ancestor::tei:note) then
            local:passthru($node, $mode)
        else
            <p class="hauptText" id="{$node/@xml:id}">
                {local:passthru($node, $mode)}
            </p>
    else if ($mode = "work") then   (: the same as in html mode except for distinguishing between paragraphs in notes and in the main text. In the latter case, make them a div, not a p and add a tool menu. :)
        if ($node/parent::tei:note) then
            local:passthru($node, $mode)
        else
            <p class="hauptText" id="{$node/@xml:id}">
                {local:passthru($node, $mode)}
            </p>
    else
        local:passthru($node, $mode)
};
declare function local:note($node as element(tei:note), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        ($config:nl, "        {", local:passthru($node, $mode), "}", $config:nl)
    else if ($mode = ("html", "work")) then
        let $normalizedString := normalize-space(string-join(local:passthru($node, $mode), ' '))
        let $identifier       := $node/@xml:id
        return
            (<sup>*</sup>,
            <span class="marginal note" id="note_{$identifier}">
                {if (string-length($normalizedString) gt $config:chars_summary) then
                    (<a class="{string-join(for $biblKey in $node//tei:bibl/@sortKey return concat('hi_', $biblKey), ' ')}" data-toggle="collapse" data-target="#subdiv_{$identifier}">{concat('* ', substring($normalizedString, 1, $config:chars_summary), '…')}<i class="fa fa-angle-double-down"/></a>,<br/>,
                     <span class="collapse" id="subdiv_{$identifier}">{local:passthru($node, $mode)}</span>)
                 else
                    <span><sup>* </sup>{local:passthru($node, $mode)}</span>
                }
            </span>)
    else
        local:passthru($node, $mode)
};

declare function local:div($node as element(tei:div), $mode as xs:string) {
    if ($mode = "orig") then
         ($config:nl, local:passthru($node, $mode), $config:nl)
    else if ($mode = "edit") then
        if ($node/@n and not(matches($node/@n, '^[0-9]+$'))) then
            (concat($config:nl, '[ *', string($node/@n), '* ]'), $config:nl, local:passthru($node, $mode), $config:nl)
(: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
        else
            ($config:nl, local:passthru($node, $mode), $config:nl)
    else if ($mode = "html") then
        if ($node/@n and not(matches($node/@n, '^[0-9]+$'))) then
            (<h4 id="{$node/@xml:id}">{string($node/@n)}</h4>,<p id="p_{$node/@xml:id}">{local:passthru($node, $mode)}</p>)
(: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
        else
            <div id="{$node/@xml:id}">{local:passthru($node, $mode)}</div>
    else if ($mode = "work") then     (: basically, the same except for eventually adding a <div class="summary_title"/> the data for which is complicated to retrieve :)
        local:passthru($node, $mode)
    else
        local:passthru($node, $mode)
};
declare function local:milestone($node as element(tei:milestone), $mode as xs:string) {
    if ($mode = "orig") then
        if ($node/@rendition = '#dagger') then
            '†'
        else if ($node/@rendition = '#asterisk') then
            '*'
        else 
            '[*]'
    else if ($mode = "edit") then
        if ($node/@n and not(matches($node/@n, '^[0-9]+$'))) then
            concat('[', string($node/@n), ']')
        else if ($node/@n and matches($node/@n, '^[0-9]+$')) then
            concat('[',  string($node/@unit), ' ', string($node/@n), ']')
(: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
        else
            '[*]'
    else if ($mode = "html") then
        let $anchor :=  if ($node/@rendition = '#dagger') then
                            '†'
                        else if ($node/@rendition = '#asterisk') then
                            '*'
                        else ()
        let $summary := if ($node/@n and not(matches($node/@n, '^[0-9]+$'))) then
                            <div class="summary_title" id="{string($node/@xml:id)}">{string($node/@n)}</div>
                        else if ($node/@n and matches($node/@n, '^[0-9]+$')) then
                            <div class="summary_title" id="{string($node/@xml:id)}">{concat(string($node/@unit), ' ', string($node/@n))}</div>
(: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
                        else ()
        return ($anchor, $summary)
    else if ($mode = "work") then ()    (: basically, the same except for eventually adding a <div class="summary_title"/> :)
    else ()
};

(: FIXME: In the following, the #anchor does not take account of html partitioning of works. Change this to use semantic section id's. :)
declare function local:head($node as element(tei:head), $mode as xs:string) {
(:if ($node/@xml:id='overview') then ():)
    if ($mode = ("orig", "edit")) then
        (local:passthru($node, $mode), $config:nl)
    else if ($mode = ("html", "work")) then
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
                {local:passthru($node, $mode)}
            </h3>
    else 
        local:passthru($node, $mode)
};

declare function local:orig($node as element(), $mode as xs:string) {
    if ($mode = "orig") then
        local:passthru($node, $mode)
    else if ($mode = "edit") then
        if (not($node/(preceding-sibling::tei:expan|preceding-sibling::tei:reg|preceding-sibling::tei:corr|following-sibling::tei:expan|following-sibling::tei:reg|following-sibling::tei:corr))) then
            local:passthru($node, $mode)
        else ()
    else if ($mode = ("html", "work")) then
        let $editedString := render:dispatch($node/parent::tei:choice/(tei:expan|tei:reg|tei:corr), "edit")
        return  if ($node/parent::tei:choice) then
                    <span class="original {local-name($node)} unsichtbar" title="{string-join($editedString, '')}">
                        {local:passthru($node, $mode)}
                    </span>
                else
                    local:passthru($node, $mode)
    else
        local:passthru($node, $mode)
};
declare function local:edit($node as element(), $mode as xs:string) {
    if ($mode = "orig") then ()
    else if ($mode = "edit") then
        local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        let $originalString := render:dispatch($node/parent::tei:choice/(tei:abbr|tei:orig|tei:sic), "orig")
        return  <span class="edited {local-name($node)}" title="{string-join($originalString, '')}">
                    {local:passthru($node, $mode)}
                </span>
    else
        local:passthru($node, $mode)
};
declare function local:g($node as element(tei:g), $mode as xs:string) {
    if ($mode="orig") then
        let $glyph := $node/ancestor::tei:TEI//tei:char[@xml:id = substring(string($node/@ref), 2)]
        return if ($glyph/tei:mapping[@type = 'precomposed']) then
                string($glyph/tei:mapping[@type = 'precomposed'])
            else if ($glyph/tei:mapping[@type = 'composed']) then
                string($glyph/tei:mapping[@type = 'composed'])
            else if ($glyph/tei:mapping[@type = 'standardized']) then
                string($glyph/tei:mapping[@type = 'standardized'])
            else
                local:passthru($node, $mode)
    else if ($mode = "edit") then
        local:passthru($node, $mode)
    else if ($mode = "work") then
        let $originalGlyph := local:g($node, "orig")
        return
            (<span class="original glyph unsichtbar" title="{$node/text()}">
                {$originalGlyph}
            </span>,
            <span class="edited glyph" title="{$originalGlyph}">
                {$node/text()}
            </span>)
    else
        local:passthru($node, $mode)
};

(: FIXME: In the following, work mode functionality has to be added - also paying attention to intervening pagebreak marginal divs :)
declare function local:term($node as element(tei:term), $mode as xs:string) {
    if ($mode = "orig") then
        local:passthru($node, $mode)
    else if ($mode = "edit") then
        if ($node/@key) then
            (local:passthru($node, $mode), ' [', string($node/@key), ']')
        else
            local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        let $elementName    := "term"
        let $key            := $node/@key
        let $getLemmaId     := tokenize(tokenize($node/@ref, 'lemma:')[2], ' ')[1]
        let $highlightName  :=  if ($node/@ref) then
                                    concat('hi_', translate(translate(translate(tokenize($node/@ref, ' ')[1], ',', ''), ' ', ''), ':', ''))
                                else if ($node/@key) then
                                    concat('hi_', translate(translate(translate(tokenize($node/@key, ' ')[1], ',', ''), ' ', ''), ':', ''))
                                else ()
        let $dictLemmaName  :=  if ($node/ancestor::tei:list[@type="dict"] and not($node/preceding-sibling::tei:term)) then
                                    'dictLemma'
                                else ()
        let $classes        := normalize-space(string-join(($elementName, $highlightName, $dictLemmaName), ' '))
    
        return                
            <span class="{$classes}" title="{$key}">
                {if ($getLemmaId) then
                    <a href="{session:encode-url(xs:anyURI('lemma.html?lid=' || $getLemmaId))}">{local:passthru($node, $mode)}</a>
                 else
                    local:passthru($node, $mode)
                }
            </span>
    else
        local:passthru($node, $mode)
};
declare function local:name($node as element(*), $mode as xs:string) {
    if ($mode = "orig") then
        local:passthru($node, $mode)
    else if ($mode = "edit") then
        if ($node/(@key|@ref)) then
            (local:passthru($node, $mode), ' [', string-join(($node/@key, $node/@ref), '/'), ']')
        else
            local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
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
                     <a href="{concat($config:idserver, '/works.', $getWorkId)}" title="{$key}">{local:passthru($node, $mode)}</a>
                 </span> 
           else if ($getAutId) then
                 <span class="{($nodeType || ' hi_author_' || $getAutId)}">
                     <a href="{concat($config:idserver, '/authors.', $getAutId)}" title="{$key}">{local:passthru($node, $mode)}</a>
                 </span> 
            else if ($getCerlId) then 
                 <span class="{($nodeType || ' hi_cerl_' || $getCerlId)}">
                    <a target="_blank" href="{('http://thesaurus.cerl.org/cgi-bin/record.pl?rid=' || $getCerlId)}" title="{$key}">{local:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                 </span>
            else if ($getGndId) then 
                 <span class="{($nodeType || ' hi_gnd_' || $getGndId)}">
                    <a target="_blank" href="{('http://d-nb.info/' || $getGndId)}" title="{$key}">{local:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                 </span>
            else if ($getGettyId) then 
                 <span class="{($nodeType || ' hi_getty_' || $getGettyId)}">
                    <a target="_blank" href="{('http://www.getty.edu/vow/TGNFullDisplay?find=&amp;place=&amp;nation=&amp;english=Y&amp;subjectid=' || $getGettyId)}" title="{$key}">{local:passthru($node, $mode)}{$config:nbsp}<span class="glyphicon glyphicon-new-window" aria-hidden="true"></span></a>
                 </span>
            else
                <span>{local:passthru($node, $mode)}</span>
    else
        local:passthru($node, $mode)
};
(: titles are dealt with using the general name function above...
declare function local:title($node as element(tei:title), $mode as xs:string) {
    if ($mode = "orig") then
        local:passthru($node, $mode)
    else if ($mode = "edit") then
        if ($node/@key) then
            string($node/@key)
        else
            local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        if ($node/@ref) then
             <span class="bibl-title"><a target="blank" href="{$node/@ref}">{local:passthru($node, $mode)}<span class="glyphicon glyphicon-new-window" aria-hidden="true"/></a></span>
        else
             <span class="bibl-title">{local:passthru($node, $mode)}</span>
    else
        local:passthru($node, $mode)
};:)
declare function local:bibl($node as element(tei:bibl), $mode as xs:string) {
    if ($mode = "orig") then
        local:passthru($node, $mode)
    else if ($mode = "edit") then
        if ($node/@sortKey) then
            (local:passthru($node, $mode), ' [', replace(string($node/@sortKey), '_', ', '), ']')
        else
            local:passthru($node, $mode)
    else if ($mode = "work") then
        let $getBiblId :=  $node/@sortKey
        return if ($getBiblId) then
                    <span class="{('work hi_' || $getBiblId)}">
                        {local:passthru($node, $mode)}
                    </span>
                else
                    local:passthru($node, $mode)
    else
        local:passthru($node, $mode)
};


declare function local:emph($node as element(tei:emph), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = "work") then
            <span class="emph">{local:passthru($node, $mode)}</span>
    else if ($mode = "html") then
            <em>{local:passthru($node, $mode)}</em>
    else
        local:passthru($node, $mode)
};
declare function local:hi($node as element(tei:hi), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        if ("#b" = $node/@rendition) then
            <b>
                {local:passthru($node, $mode)}
            </b>
        else if ("#initCaps" = $node/@rendition) then
            <span class="initialCaps">
                {local:passthru($node, $mode)}
            </span>
        else if ("#it" = $node/@rendition) then
            <it>
                {local:passthru($node, $mode)}
            </it>
        else if ("#l-indent" = $node/@rendition) then
            <span style="display:block;margin-left:4em;">
                {local:passthru($node, $mode)}
            </span>
        else if ("#r-center" = $node/@rendition) then
            <span style="display:block;text-align:center;">
                {local:passthru($node, $mode)}
            </span>
        else if ("#sc" = $node/@rendition) then
            <span class="smallcaps">
                {local:passthru($node, $mode)}
            </span>
        else if ("#spc" = $node/@rendition) then
            <span class="spaced">
                {local:passthru($node, $mode)}
            </span>
        else if ("#sub" = $node/@rendition) then
            <sub>
                {local:passthru($node, $mode)}
            </sub>
        else if ("#sup" = $node/@rendition) then
            <sup>
                {local:passthru($node, $mode)}
            </sup>
        else
            <it>
                {local:passthru($node, $mode)}
            </it>
    else 
        local:passthru($node, $mode)
};
declare function local:ref($node as element(tei:ref), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = "html" and $node/@type = "url") then
        if (substring($node/@target, 1, 4) = "http") then
            <a href="{$node/@target}" target="_blank">{local:passthru($node, $mode)}</a>
        else
            <a href="{$node/@target}">{local:passthru($node, $mode)}</a>
    else if ($mode = "work") then                                       (: basically the same, but use the resolveURI functions to get the actual target :)
        <a href="{$node/@target}">{local:passthru($node, $mode)}</a>
    else
        local:passthru($node, $mode)
};
declare function local:soCalled($node as element(tei:soCalled), $mode as xs:string) {
    if ($mode=("orig", "edit")) then
        ("'", local:passthru($node, $mode), "'")
    else if ($mode = ("html", "work")) then
        <span class="soCalled">{local:passthru($node, $mode)}</span>
    else
        ("'", local:passthru($node, $mode), "'")
};
declare function local:quote($node as element(tei:quote), $mode as xs:string) {
    if ($mode=("orig", "edit")) then
        ('"', local:passthru($node, $mode), '"')
    else if ($mode = ("html", "work")) then
        <span class="quote">{local:passthru($node, $mode)}</span>
    else
        ('"', local:passthru($node, $mode), '"')
};

declare function local:list($node as element(tei:list), $mode as xs:string) {
    if ($mode = "orig") then
        ($config:nl, local:passthru($node, $mode), $config:nl)
    else if ($mode = "edit") then
        if ($node/@n and not(matches($node/@n, '^[0-9]+$'))) then
            (concat($config:nl, ' [*', string($node/@n), '*]', $config:nl), local:passthru($node, $mode), $config:nl)
(: oder das hier?:   <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/> :)
        else
            ($config:nl, local:passthru($node, $mode), $config:nl)
    else if ($mode = ("html", "work")) then
        if ($node/@type = "ordered") then
            <section>
                {if ($node/child::tei:head) then
                    for $head in $node/tei:head
                        return
                            <h4>
                                {local:passthru($head, $mode)}
                            </h4>
                 else ()
                }
                <ol>
                    {for $item in $node/tei:*[not(local-name() = "head")]
                            return
                                render:dispatch($item, $mode)
                    }
                </ol>
            </section>
        else if ($node/@type = "simple") then
            <section>
                {if ($node/tei:head) then
                    for $head in $node/tei:head
                        return
                            <h4>{local:passthru($head, $mode)}</h4>
                 else ()
                }
                {for $item in $node/tei:*[not(local-name() = "head")]
                        return
                                render:dispatch($item, $mode)
                }
            </section>
        else
            <figure class="{$node/@type}">
                {if ($node/child::tei:head) then
                    for $head in $node/tei:head
                        return
                            <h4>{local:passthru($head, $mode)}</h4>
                 else ()
                }
                <ul>
                    {for $item in $node/tei:*[not(local-name() = "head")]
                            return
                                render:dispatch($item, $mode)
                    }
                </ul>
            </figure>
    else
        ($config:nl, local:passthru($node, $mode), $config:nl)
};
declare function local:item($node as element(tei:item), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        let $leader :=  if ($node/parent::tei:list/@type = "numbered") then
                            '#' || $config:nbsp
                        else if ($node/parent::tei:list/@type = "simple") then
                            $config:nbsp
                        else
                            '-' || $config:nbsp
        return ($leader, local:passthru($node, $mode), $config:nl)
    else if ($mode = ("html", "work")) then
        if ($node/parent::tei:list/@type="simple") then
            local:passthru($node, $mode)
        else
            <li>{local:passthru($node, $mode)}</li>
    else
        local:passthru($node, $mode)
};
declare function local:gloss($node as element(tei:gloss), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        local:passthru($node, $mode)
    else
        local:passthru($node, $mode)
};
declare function local:eg($node as element(tei:eg), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        <pre>{local:passthru($node, $mode)}</pre>
    else 
        local:passthru($node, $mode)
};


declare function local:birth($node as element(), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        <span>*&#xA0;{local:name($node/tei:placeName[1], $mode) || ': ' || $node/tei:date[1]}</span>
    else ()
};
declare function local:death($node as element(), $mode as xs:string) {
    if ($mode = ("orig", "edit")) then
        local:passthru($node, $mode)
    else if ($mode = ("html", "work")) then
        <span>†&#xA0;{local:name($node/tei:placeName[1], $mode) || ': ' || $node/tei:date[1]}</span>
    else ()
};



(: FIXME: Still left to be implemented: titlePage, titlePart, docTitle, text, choice, lg, l, and author fields: state etc. :)