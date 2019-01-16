xquery version "3.0";

module namespace admin              = "http://salamanca/admin";
declare namespace exist             = "http://exist.sourceforge.net/NS/exist";
declare namespace tei               = "http://www.tei-c.org/ns/1.0";
declare namespace xi                = "http://www.w3.org/2001/XInclude";
declare namespace sal               = "http://salamanca.adwmainz.de";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace functx      = "http://www.functx.com";
import module namespace templates   = "http://exist-db.org/xquery/templates";
import module namespace util        = "http://exist-db.org/xquery/util";
import module namespace xmldb       = "http://exist-db.org/xquery/xmldb";
import module namespace app         = "http://salamanca/app"                    at "app.xql";
import module namespace config      = "http://salamanca/config"                 at "config.xqm";
import module namespace render      = "http://salamanca/render"                 at "render.xql";
import module namespace sphinx      = "http://salamanca/sphinx"                 at "sphinx.xql";

declare option exist:timeout "10800000"; (: 3 h :)

declare function admin:cleanCollection ($wid as xs:string, $collection as xs:string) {
    let $collectionName := if ($collection = "html") then
                                $config:html-root || "/" || $wid
                            else if ($collection = "data") then
                                $config:data-root || "/"
                            else if ($collection = "snippets") then
                                $config:snippets-root || "/" || $wid
                            else
                                $config:data-root || "/trash/"
    let $create-parent-status   :=    if ($collection = "html"    and not(xmldb:collection-available($config:html-root))) then
                                          xmldb:create-collection($config:data-root, "html")
                                 else if ($collection = "snippets" and not(xmldb:collection-available($config:snippets-root))) then
                                          xmldb:create-collection($config:data-root, "snippets")
                                 else ()
    let $create-collection-status :=      if ($collection = "html"     and not(xmldb:collection-available($collectionName))) then
                                          xmldb:create-collection($config:html-root, $wid)
                                     else if ($collection = "snippets" and not(xmldb:collection-available($collectionName))) then
                                          xmldb:create-collection($config:snippets-root, $wid)
                                     else ()
    let $chmod-collection-status  := xmldb:set-collection-permissions($collectionName, 'sal', 'svsal',  util:base-to-integer(0775, 8))
    let $remove-status            := if (count(xmldb:get-child-resources($collectionName))) then
                                         for $file in xmldb:get-child-resources($collectionName) return xmldb:remove($collectionName, $file)
                                     else ()
    return $remove-status
};

declare function admin:saveFile ($wid as xs:string, $fileName as xs:string, $content as node(), $collection as xs:string?) {
    let $collectionName := if ($collection = "html") then
                                $config:html-root || "/" || $wid
                            else if ($collection = "data") then
                                $config:data-root || "/"
                            else if ($collection = "snippets") then
                                $config:snippets-root || "/" || $wid
                            else if ($collection = "rdf") then
                                $config:rdf-root || "/"
                            else
                                $config:data-root || "/trash/"
    let $create-parent-status     :=      if ($collection = "html"     and not(xmldb:collection-available($config:html-root))) then
                                          xmldb:create-collection($config:data-root, "html")
                                     else if ($collection = "snippets" and not(xmldb:collection-available($config:snippets-root))) then
                                          xmldb:create-collection($config:data-root, "snippets")
                                     else ()
    let $create-collection-status :=      if ($collection = "html"     and not(xmldb:collection-available($collectionName))) then
                                          xmldb:create-collection($config:html-root, $wid)
                                     else if ($collection = "snippets" and not(xmldb:collection-available($collectionName))) then
                                          xmldb:create-collection($config:snippets-root, $wid)
                                     else if ($collection = "rdf"      and not(xmldb:collection-available($config:rdf-root))) then
                                          xmldb:create-collection($config:salamanca-data-root, "rdf")
                                     else ()
    let $chmod-collection-status  := xmldb:set-collection-permissions($collectionName, 'sal', 'svsal',  util:base-to-integer(0775, 8))
    let $remove-status            := if ($content and $fileName = xmldb:get-child-resources($collectionName)) then
                                          xmldb:remove($collectionName, $fileName)
                                     else ()
    let $store-status             := if ($content) then
                                          xmldb:store($collectionName, $fileName, $content)
                                     else ()
    return $store-status
};

declare function admin:saveFileWRK ($node as node(), $model as map (*), $lang as xs:string?) {
    let $create-collection  :=  if (not(xmldb:collection-available($config:data-root))) then xmldb:create-collection($config:app-root, "data") else ()
    let $fileNameDe         :=  'works_de.xml'
    let $fileNameEn         :=  'works_en.xml'
    let $fileNameEs         :=  'works_es.xml'
    let $contentDe          :=  <sal>
                                    {app:WRKfinalFacets($node, $model, 'de')}
                                </sal>
    let $contentEn          :=  <sal>
                                    {app:WRKfinalFacets($node, $model, 'en')}
                                </sal>
    let $contentEs          :=  <sal>
                                    {app:WRKfinalFacets($node, $model, 'es')}
                                </sal> 
    let $store              :=  (xmldb:store($config:data-root, $fileNameDe, $contentDe), xmldb:store($config:data-root, $fileNameEn, $contentEn), xmldb:store($config:data-root, $fileNameEs, $contentEs))
    return
        <span>
            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> List of works saved!</p>
            <br/><br/>
            <a href="works.html" class="btn btn-info" role="button"><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Open works.html</a>
        </span>   

};

declare function admin:saveFileWRKnoJs ($node as node(), $model as map (*), $lang as xs:string?) {
    let $create-collection  :=  if (not(xmldb:collection-available($config:data-root))) then xmldb:create-collection(util:collection-name($config:data-root), $config:data-root) else ()
    let $fileNameDeSn       :=  'worksNoJs_de_surname.xml'
    let $fileNameEnSn       :=  'worksNoJs_en_surname.xml'
    let $fileNameEsSn       :=  'worksNoJs_es_surname.xml'
    let $contentDeSn        :=  <sal>
                                    {app:WRKcreateListSurname($node, $model, 'de')}
                                </sal>   
    let $contentEnSn        :=  <sal>
                                    {app:WRKcreateListSurname($node, $model, 'en')}
                                </sal>
    let $contentEsSn        :=  <sal>
                                    {app:WRKcreateListSurname($node, $model, 'es')}
                                </sal> 
    let $fileNameDeTi         :=  'worksNoJs_de_title.xml'
    let $fileNameEnTi         :=  'worksNoJs_en_title.xml'
    let $fileNameEsTi         :=  'worksNoJs_es_title.xml'
    let $contentDeTi        :=  <sal>
                                    {app:WRKcreateListTitle($node, $model, 'de')}
                                </sal>   
    let $contentEnTi        :=  <sal>
                                    {app:WRKcreateListTitle($node, $model, 'en')}
                                </sal>
    let $contentEsTi        :=  <sal>
                                    {app:WRKcreateListTitle($node, $model, 'es')}
                                </sal>                                
    let $fileNameDeYe         :=  'worksNoJs_de_year.xml'
    let $fileNameEnYe         :=  'worksNoJs_en_year.xml'
    let $fileNameEsYe         :=  'worksNoJs_es_year.xml'
    let $contentDeYe          :=  <sal>
                                    {app:WRKcreateListYear($node, $model, 'de')}
                                </sal>   
    let $contentEnYe        :=  <sal>
                                    {app:WRKcreateListYear($node, $model, 'en')}
                                </sal>
    let $contentEsYe        :=  <sal>
                                    {app:WRKcreateListYear($node, $model, 'es')}
                                </sal>  
    let $fileNameDePl         :=  'worksNoJs_de_place.xml'
    let $fileNameEnPl         :=  'worksNoJs_en_place.xml'
    let $fileNameEsPl         :=  'worksNoJs_es_place.xml'
    let $contentDePl          :=  <sal>
                                    {app:WRKcreateListPlace($node, $model, 'de')}
                                </sal>   
    let $contentEnPl        :=  <sal>
                                    {app:WRKcreateListPlace($node, $model, 'en')}
                                </sal>
    let $contentEsPl        :=  <sal>
                                    {app:WRKcreateListPlace($node, $model, 'es')}
                                </sal>
    let $store              :=  (   xmldb:store($config:data-root, $fileNameDeSn, $contentDeSn), xmldb:store($config:data-root, $fileNameEnSn, $contentEnSn), xmldb:store($config:data-root, $fileNameEsSn, $contentEsSn),
                                    xmldb:store($config:data-root, $fileNameDeTi, $contentDeTi), xmldb:store($config:data-root, $fileNameEnTi, $contentEnTi), xmldb:store($config:data-root, $fileNameEsTi, $contentEsTi),
                                    xmldb:store($config:data-root, $fileNameDeYe, $contentDeYe), xmldb:store($config:data-root, $fileNameEnYe, $contentEnYe), xmldb:store($config:data-root, $fileNameEsYe, $contentEsYe),
                                    xmldb:store($config:data-root, $fileNameDePl, $contentDePl), xmldb:store($config:data-root, $fileNameEnPl, $contentEnPl), xmldb:store($config:data-root, $fileNameEsPl, $contentEsPl))
    return      
                            <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span> Noscript-files saved!</p>

};

declare %templates:wrap function admin:renderAuthorLemma ($node as node(), $model as map(*), $aid as xs:string*, $lid as xs:string*, $lang as xs:string*) {

    let $request            :=  request:get-parameter('aid', '')
    let $switchType         :=  if ($request) then $aid else $lid
    let $switchLabel1       :=  if ($request) then 'author.html' else 'lemma.html'
    let $switchLabel2       :=  if ($request) then '?aid=' else '?lid='
    let $create-collection  :=  if (not(xmldb:collection-available($config:temp))) then xmldb:create-collection($config:app-root, "temp") else ()
    let $fileMain           :=  $switchType || '.html'
    let $fileCited          :=  $switchType || '_cited.html'
    let $fileLemma          :=  $switchType || '_lemmata.html'
    let $filePersons        :=  $switchType || '_persons.html'
    let $filePlaces         :=  $switchType || '_places.html'
    let $main               :=  if ($request) then 
                                    <div>
                                       { render:dispatch(doc($config:tei-authors-root || "/" || $aid || ".xml")//tei:body, "work")
                                       }
                                    </div>  
                                else 
                                    <div>
                                        { render:dispatch(doc($config:tei-lemmata-root || "/" || $lid || ".xml")//tei:body, "work")
                                        }
                                    </div>  
    let $cited              :=  <div>
                                    {app:cited($node, $model, $lang, $aid, $lid)}
                                </div>
    let $lemmata            :=  <div>
                                    {app:lemmata($node, $model, $lang, $aid, $lid)}
                                </div>                                       
    let $persons            :=  <div>
                                    {app:persons($node, $model, $aid, $lid)}
                                </div>   
    let $places             :=  <div>
                                   {app:places($node, $model, $aid, $lid)}
                               </div>                              
    let $store              :=  (   
                                    xmldb:store($config:data-root, $fileMain, $main),
                                    xmldb:store($config:data-root, $filePersons, $persons), 
                                    xmldb:store($config:data-root, $fileCited,   $cited),
                                    xmldb:store($config:data-root, $fileLemma,   $lemmata),
                                    xmldb:store($config:data-root, $filePlaces,  $places)
                                )     
    return  <p class="lead">{$config:data-root||'/'||$switchType||'.html created'}
                <a href="{($switchLabel1||$switchLabel2||$switchType)}">&#32;&#32;
                    <span class="glyphicon glyphicon-play" aria-hidden="true"></span>
                </a>
            </p>
};

declare function admin:generate-toc-from-div($node, $wid) {
   for $div in ($node/tei:div[@type="work_part"]/tei:div | $node/tei:div[not(@type="work_part")]| $node/*/tei:milestone[@unit ne 'other'])
            return admin:toc-div($div, $wid)
};                      

declare function admin:toc-div($div, $wid) {
    let $frag    :=     for $item in doc($config:data-root || "/" || $wid || '_nodeIndex.xml')//sal:node
                        where $item/@n eq $div/@xml:id
                        return 'work.html?wid='||$wid ||'&amp;' || 'frag='|| $item/sal:fragment||'#'|| $item/@n
    let $section := $div/@xml:id/string()
    let $getTitle := admin:derive-title($div)
    return 
        <ul><li><a class="hideMe" href="{$frag}" title="{$getTitle}">{$getTitle}<span class="jstree-anchor hideMe pull-right">{admin:get-pages-from-div($div) }</span></a>
            { admin:generate-toc-from-div($div, $wid)}
        </li></ul>
};

declare function admin:derive-title($node as node()) as item()* {
     typeswitch($node)
     case text()                    return $node
     case element(tei:teiHeader)    return ()
     case element(tei:choice)       return $node/tei:expan/text() | $node/tei:reg/text() | $node/tei:cor/text()
     case element(tei:titlePart)    return ('[', $node/@type/string(), '] ',  local:passthruTOC($node))
     case element(tei:div)          return
                                        if($node/tei:head) then ('[', $node/@type/string(), '] ',  local:passthruTOC($node/tei:head))
                                        else if ($node/tei:list/tei:head) then ('[', $node/@type/string(), '] ',  local:passthruTOC($node/tei:list/tei:head))
                                        else if (not($node/tei:head | $node/tei:list/tei:head)) then  ('[', $node/@type/string(), '] ',  $node/@n/string())
                                        else()
     case element(tei:milestone)    return ('[', $node/@unit/string(), '] ',  $node/@n/string())
     (:case element(tei:label)        return if ($node/@type) then ('[', $node/@type/string(), '] ', local:passthruTOC($node)) else ():)
     case element(tei:pb)           return if (not($node[@break eq 'no'])) then ' ' else ()
     case element(tei:cb)           return if (not($node[@break eq 'no'])) then ' ' else ()
     case element(tei:lb)           return if (not($node[@break eq 'no'])) then ' ' else ()
     default return local:passthruTOC($node)
};
   
declare function local:passthruTOC($nodes as node()*) as item()* {
    for $node in $nodes/node() return admin:derive-title($node)
};

declare function admin:get-pages-from-div($div) {
    let $firstpage :=   if ($div[@type='work_volume'] | $div[@type = 'work_monograph']) then ($div//tei:pb)[1]/@n/string() 
                        else ($div/preceding::tei:pb)[last()]/@n/string()
    let $lastpage :=    if ($div//tei:pb) then ($div//tei:pb)[last()]/@n/string() else ()
    return
        if ($firstpage ne '' or $lastpage ne '') then 
            concat(' ', string-join(($firstpage, $lastpage), ' - ')) 
        else ()
};    

declare %templates:wrap function admin:renderWork($node as node(), $model as map(*), $wid as xs:string*, $lang as xs:string?) as element(div) {
    let $debug            := if ($config:debug = ("trace", "info")) then console:log("Rendering " || $wid || ".") else ()
    let $start-time       := util:system-time()
    let $wid              := request:get-parameter('wid', '*')
    let $indexedElTypes   := "pb|text|front|titlePart|div|p|milestone|list|item|lg|back"
    
    (: define the works to be fragmented: :)
    let $todo             := if ($wid = '*') then
                                collection($config:tei-works-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph")]]
                             else
                                collection($config:tei-works-root)//tei:TEI[@xml:id = distinct-values($wid)]

    (: für jedes Werk: erzeuge die Fragmente, speise sie in die Transformation ein und erzeuge diagnost. Informationen :)
    let $gerendert        := for $work-raw in $todo
                                let $cleanStatus        := admin:cleanCollection($work-raw/@xml:id, "html")
                                let $work               := util:expand($work-raw)
                                let $xincludes          := $work-raw//tei:text//xi:include/@href
                                let $fragmentationDepth := if ($work-raw//processing-instruction('svsal')[matches(., 'htmlFragmentationDepth="[^"]*"')][1]) then
                                                                        xs:integer($work-raw//processing-instruction('svsal')[matches(., 'htmlFragmentationDepth="[^"]*"')][1]/replace(substring-after(., 'htmlFragmentationDepth="'), '"', ''))
                                                                    else
                                                                        $config:fragmentationDepthDefault
                                let $debug              := if ($config:debug = ("trace", "info")) then console:log("Rendering " || string($work-raw/@xml:id) || " at fragmentation level " || $fragmentationDepth || ".") else ()
                                
                                let $start-time-a := util:system-time()

                                (: a rule picking those elements that should become our fragments :)
                                let $target-set := $work//tei:text//tei:*[count(./ancestor-or-self::tei:*) eq $fragmentationDepth]
                                let $debug              := if ($config:debug = ("trace", "info")) then console:log("  " || string(count($target-set)) || " elements to be rendered as fragments...") else ()

                                (: First, create a preliminary index of nodes for generating HTML fragments (there is a second run below) :)
                                let $index1           := <sal:index work="{string($work/@xml:id)}">{
                                                                    (:for $node at $pos in $work//tei:*[ancestor-or-self::tei:text][not(self::tei:lb)][@xml:id]:)
                                                                    (:for $node at $pos in $work//tei:text/descendant-or-self::tei:*[@xml:id and not(self::tei:lb 
                                                                                                                                                   or self::tei:item 
                                                                                                                                                   or self::tei:milestone[@unit eq 'other']
                                                                                                                                                   or self::tei:choice)] :)
                                                                    for $node at $pos in $work//tei:text/descendant-or-self::*[matches(local-name(.), '^(' || $indexedElTypes || ')$') and not(ancestor::tei:note)] 
                                                                        let $subtype         := if ($node/@sameAs) then
                                                                                                    "sameAs"
                                                                                                else if ($node/@corresp) then
                                                                                                    "corresp"
                                                                                                else if ($node/@type eq "work_part") then
                                                                                                    "work_part"
                                                                                                else if ($node[self::tei:milestone]/@n) then
                                                                                                    string($node/@n)
                                                                                                else if ($node/@type) then
                                                                                                    string($node/@type)
                                                                                                else ()
                                                                        let $frag            := (($node/ancestor-or-self::tei:* | $node//tei:*) intersect $target-set)[1]
                                                                        return (element sal:node { 
                                                                                                    attribute type      {local-name($node)}, 
                                                                                                    attribute subtype   {$subtype}, 
                                                                                                    attribute n         {$node/@xml:id},
                                                                                                    if ($node/@xml:id eq 'completeWork' and $xincludes) then
                                                                                                       attribute xinc    {$xincludes}
                                                                                                    else (), 
                                                                                                    element sal:title           {app:sectionTitle($work, $node)},
                                                                                                    element sal:fragment        {format-number(functx:index-of-node($target-set, $frag), "0000") || "_" || $frag/@xml:id},
                                                                                                    element sal:citableParent   {string(($node/ancestor::tei:text[not(@type="work_part")] | $node/ancestor::tei:div[not(@type="work_part")][1] 
                                                                                                                                            | $node/ancestor::tei:p[not(./ancestor::tei:note)] | $node/ancestor::tei:note | $node/ancestor::tei:item[./ancestor::tei:list/@type = 'dict'])[last()]/@xml:id)},
                                                                                                    (: Crumbtrails include URLs with "frag=..." parameters pointing to the right HTML fragment; 
                                                                                                    they can only be created properly if HTML fragments already exist (see render:mkUrl(...)) :)
                                                                                                    element sal:crumbtrail      {render:getCrumbtrail($work, $node, 'html')},
                                                                                                    element sal:citetrail       {string-join(render:getCrumbtrail($work, $node, 'numeric'), '')}
                                                                                                }
                                                                                )
                                                                   }
                                                        </sal:index>
                                let $index1SaveStatus := admin:saveFile($work/@xml:id, $work/@xml:id || "_nodeIndex.xml", $index1, "data")
                                let $debug              := if ($config:debug = ("trace", "info")) then console:log("  Preliminary index file created.") else ()


                                (: Next, create a ToC html file. :)
                                let $doc    :=      util:expand(doc($config:tei-works-root || '/' || $wid ||   '.xml')/tei:TEI)
                                let $text   :=      $doc//tei:text[@type='work_volume'] | $doc//tei:text[@type = 'work_monograph']
                                let $elements :=    $doc//tei:text[@type = 'work_monograph']/(tei:front | tei:body | tei:back)  
                                let $title  :=      app:WRKcombined($doc, $model, $wid)
                                let $store  :=     
                                    <div id="tableOfConts">
                                        <ul>
                                            <li>
                                                <b>{$title}</b> 
                                                <span class="jstree-anchor hideMe pull-right">{admin:get-pages-from-div($text) }</span>
                                                
                                                    {if ($doc//tei:text[@type='work_volume']) then for $a in $doc//tei:text where $a[@type='work_volume'] return
                                                    <ul>
                                                        <li>
                                                            <a class="hideMe"><b>{concat('Volume: ', $a/@n/string())}</b></a>
                                                            { admin:generate-toc-from-div($a/(tei:front | tei:body | tei:back), $wid)}
                                                    </li></ul>
                                                    else admin:generate-toc-from-div($elements, $wid)}
                                            </li>
                                        </ul>
                                    </div>
                                let $tocSaveStatus := admin:saveFile($doc/@xml:id, $doc/@xml:id || "_toc.html", $store, "html")
                                let $debug         := if ($config:debug = ("trace", "info")) then console:log("  ToC file created.") else ()
                                

                                (:Next, create the Pages html file. :)
                                let $pagesDe        :=  app:WRKpreparePagination($node, $model, $wid, 'de')
                                let $pagesEn        :=  app:WRKpreparePagination($node, $model, $wid, 'en')
                                let $pagesEs        :=  app:WRKpreparePagination($node, $model, $wid, 'es')
                                let $savePages      :=  (admin:saveFile($work/@xml:id, $work/@xml:id || "_pages_de.html", $pagesDe, "html"),
                                                         admin:saveFile($work/@xml:id, $work/@xml:id || "_pages_en.html", $pagesEn, "html"),
                                                         admin:saveFile($work/@xml:id, $work/@xml:id || "_pages_es.html", $pagesEs, "html"))
                                let $debug          := if ($config:debug = ("trace", "info")) then console:log("  Pages files created.") else ()


                                (: Next, get "previous" and "next" fragment ids and hand the current fragment over to the renderFragment function :)
                                let $fragments := for $section at $index in $target-set
                                        let $prev   :=  if ($index > 1) then
                                                            $target-set[(xs:integer($index) - 1)]
                                                        else ()
                                        let $next   :=  if ($index < count($target-set)) then
                                                            $target-set[(xs:integer($index) + 1)]
                                                        else ()
                                        let $prevId :=  if ($prev) then
                                                            xs:string($prev/@xml:id)
                                                        else ()
                                        let $nextId :=  if ($next) then
                                                            xs:string($next/@xml:id)
                                                        else ()
                                        let $result :=  admin:renderFragment($work, xs:string($work/@xml:id), $section, $index, $fragmentationDepth, $prevId, $nextId, $config:serverdomain)
                                        return <p>
                                                    <div>
                                                        {format-number($index, "0000")}: &lt;{local-name($section) || " xml:id=&quot;" || string($section/@xml:id) || "&quot;&gt;"} (Level {count($section/ancestor-or-self::tei:*)})
                                                    </div>
                                                    {$result}
                                                </p>
                                
                                (: Finally, create ultimate version of node index with proper fragment URLs, required for RDF extraction etc. :)
                                let $index2           := <sal:index work="{string($work/@xml:id)}">{
                                                                    (:for $node at $pos in $work//tei:*[ancestor-or-self::tei:text][not(self::tei:lb)][@xml:id]:)
                                                                    (:for $node at $pos in $work//tei:text/descendant-or-self::tei:*[@xml:id and not(self::tei:lb 
                                                                                                                                                   or self::tei:item 
                                                                                                                                                   or self::tei:milestone[@unit eq 'other']
                                                                                                                                                   or self::tei:choice)] :)
                                                                    for $node at $pos in $work//tei:text/descendant-or-self::*[matches(local-name(.), '^(' || $indexedElTypes || ')$') and not(ancestor::tei:note)] 
                                                                        let $subtype         := if ($node/@sameAs) then
                                                                                                    "sameAs"
                                                                                                else if ($node/@corresp) then
                                                                                                    "corresp"
                                                                                                else if ($node/@type eq "work_part") then
                                                                                                    "work_part"
                                                                                                else if ($node[self::tei:milestone]/@n) then
                                                                                                    string($node/@n)
                                                                                                else if ($node/@type) then
                                                                                                    string($node/@type)
                                                                                                else ()
                                                                        let $frag            := (($node/ancestor-or-self::tei:* | $node//tei:*) intersect $target-set)[1]
                                                                        return (element sal:node { 
                                                                                                    attribute type      {local-name($node)}, 
                                                                                                    attribute subtype   {$subtype}, 
                                                                                                    attribute n         {$node/@xml:id},
                                                                                                    if ($node/@xml:id eq 'completeWork' and $xincludes) then
                                                                                                      attribute xinc    {$xincludes} else
                                                                                                      (), 
                                                                                                    element sal:title           {app:sectionTitle($work, $node)},
                                                                                                    element sal:fragment        {format-number(functx:index-of-node($target-set, $frag), "0000") || "_" || $frag/@xml:id},
                                                                                                    element sal:citableParent   {string(($node/ancestor::tei:text[not(@type="work_part")] | $node/ancestor::tei:div[not(@type="work_part")][1] 
                                                                                                                                            | $node/ancestor::tei:note | $node/ancestor::tei:item[./ancestor::tei:list/@type = 'dict'])[last()]/@xml:id)},
                                                                                                    (: Crumbtrails include URLs with "frag=..." parameters pointing to the right HTML fragment; 
                                                                                                    they can only be created properly if HTML fragments already exist (see render:mkUrl(...)) :)
                                                                                                    element sal:crumbtrail      {render:getCrumbtrail($work, $node, 'html')},
                                                                                                    element sal:citetrail       {string-join(render:getCrumbtrail($work, $node, 'numeric'), '')}
                                                                                                }
                                                                                )
                                                                   }
                                                        </sal:index>
                                let $index2SaveStatus := admin:saveFile($work/@xml:id, $work/@xml:id || "_nodeIndex.xml", $index2, "data")
                                let $debug              := if ($config:debug = ("trace", "info")) then console:log("  Revised index file created.") else ()


                            (: Done. The rest is reporting... :)
                                (: See if there are any leaf elements in our text that are not matched by our rule :)
                                let $missed-elements := $work//(tei:front|tei:body|tei:back)//tei:*[count(./ancestor-or-self::tei:*) < $fragmentationDepth][not(*)]
                                (: See if any of the elements we did get is lacking an xml:id attribute :)
                                let $unidentified-elements := $target-set[not(@xml:id)]
                                (: Keep track of how long this work did take :)
                                let $runtime-ms-a := ((util:system-time() - $start-time-a) div xs:dayTimeDuration('PT1S'))  * 1000
                                return <div>
                                             <p><a href="work.html?wid={$work/@xml:id}">{string($work/@xml:id)}</a>, Fragmentierungstiefe: <code>{$fragmentationDepth}</code></p>
                                             {if (count($missed-elements)) then <p>{count($missed-elements)} nicht erfasste Elemente:<br/>
                                                {for $e in $missed-elements return <code>{local-name($e) || "(" || string($e/@xml:id) || "); "}</code>}</p>
                                              else ()}
                                             {if (count($unidentified-elements)) then <p>{count($unidentified-elements)} erfasste, aber wegen fehlender xml:id nicht verarbeitbare Elemente:<br/>
                                                {for $e in $unidentified-elements return <code>{local-name($e)}</code>}</p>
                                              else ()}
                                             <p>{count($target-set)} erfasste Elemente {if (count($target-set)) then "der folgenden Typen: " || <br/> else ()}
                                                <code>{distinct-values(for $i in $target-set return local-name($i) || "(" || count($target-set[local-name(.) = local-name($i)]) || ")")}</code></p>
                                             <p>Rechenzeit: {      if ($runtime-ms-a < (1000 * 60))      then format-number($runtime-ms-a div 1000, "#.##") || " Sek."
                                                              else if ($runtime-ms-a < (1000 * 60 * 60)) then format-number($runtime-ms-a div (1000 * 60), "#.##") || " Min."
                                                              else                                            format-number($runtime-ms-a div (1000 * 60 * 60), "#.##") || " Std."
                                                             }
                                             </p>
                                             {if ($config:debug = "trace") then $fragments else ()}
                                       </div>

    (: Now put everything out :)
    let $runtime-ms       := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))  * 1000 
    return <div>
                <p>Zu rendern: {count($todo)} Werk(e); gesamte Rechenzeit:
                    {if ($runtime-ms < (1000 * 60))             then format-number($runtime-ms div 1000, "#.##") || " Sek."
                      else if ($runtime-ms < (1000 * 60 * 60))  then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
                      else                                           format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
                    }
                </p>
                <hr/>
                {$gerendert}
            </div>
};

declare function admin:renderFragment ($work as node(), $wid as xs:string, $target as node(), $targetindex as xs:integer, $fragmentationDepth as xs:integer, $prevId as xs:string?, $nextId as xs:string?, $serverDomain as xs:string?) {
    let $tei2htmlXslt      := doc($config:resources-root || '/xsl/render-fragments2.xsl')
    let $targetid          := xs:string($target/@xml:id)
    let $xsl-parameters    :=  <parameters>
                                 <param name="exist:stop-on-warn"  value="yes" />
                                 <param name="exist:stop-on-error" value="yes" />
                                 <param name="workId"        value="{$wid}" />
                                 <param name="targetId"      value="{$targetid}" />
                                 <param name="targetIndex"   value="{$targetindex}" />
                                 <param name="prevId"        value="{$prevId}" />
                                 <param name="nextId"        value="{$nextId}" />
                                 <param name="serverDomain"  value="{$serverDomain}" />
                               </parameters>
    let $debugOutput   := if ($config:debug = ("trace", "info")) then console:log("  Render Element " || $targetindex || ": " || $targetid || " of " || $wid || "...") else ()
    let $html              := transform:transform($work, $tei2htmlXslt, $xsl-parameters)

    (: Now for saving the fragment ... :)
    let $fileName       := format-number($targetindex, "0000") || "_" || $targetid || ".html"
    let $storeStatus    := if ($html) then admin:saveFile($wid, $fileName, $html, "html") else ()

    return <div style="border:'3px solid black';background-color:'grey';">
                <code>{$wid}/{$fileName}:<br/>
                        target xml:id={$targetid} <br/>
                        prev xml:id={$prevId} <br/>
                        next xml:id={$nextId} <br/>
                </code>
                {$html}
           </div> 
};

(: Generate fragments for sphinx' indexer to grok :)
declare function admin:sphinx-out ($node as node(), $model as map(*), $wid as xs:string*, $mode as xs:string?) {
                (:
                   Diese Elemente liefern wir an sphinx aus:                text//(p|head|item|note|titlePage)
                   Diese weiteren Elemente enthalten ebenfalls Textknoten:        (fw hi l g body div front)
                            [zu ermitteln durch distinct-values(collection(/db/apps/salamanca/data)//tei:text[@type = ("work_monograph", "work_volume")]//node()[not(./ancestor-or-self::tei:p | ./ancestor-or-self::tei:head | ./ancestor-or-self::tei:list | ./ancestor-or-self::tei:titlePage)][text()])]
                   Wir ignorieren fw, während hi, l und g immer schon in p, head, item usw. enthalten sind.
                   => Wir müssen also noch dafür sorgen, dass front, body und div's keinen Text außerhalb von p, head, item usw. enthalten!
                :)

    let $start-time       := util:system-time()

    (: Which works are to be indexed? :)
    let $todo             := if ($wid = '*') then
                                collection($config:tei-root)//tei:TEI[.//tei:text[@type = ("work_multivolume", "work_monograph", "author_article", "lemma_article", "working_paper")]]
                             else
                                collection($config:tei-root)//tei:TEI[@xml:id = distinct-values($wid)]
    let $expanded         := for $work-raw in $todo
                                let $cleanStatus := admin:cleanCollection($work-raw/@xml:id, "snippets")
                                return util:expand($work-raw)

    (: which parts of those works constitute a fragment that is to count as a hit? :)
    let $hits := 
            for $hit at $index in ($expanded//tei:text//(tei:titlePage|tei:head|tei:item|tei:note|tei:p[not(ancestor::tei:note | ancestor::tei:item)]|tei:lg[not(ancestor::tei:note | ancestor::tei:item  | ancestor::tei:p)]) | $expanded//tei:profileDesc//(tei:p | tei:keywords))

                (: for each fragment, populate our sphinx fields and attributes :)
                let $work              := $hit/ancestor-or-self::tei:TEI
                let $work_id           := xs:string($work/@xml:id)
                let $work_type         := xs:string($work/tei:text/@type)
                let $work_author_name := app:formatName($work//tei:titleStmt//tei:author//tei:persName)
                let $work_author_id   := string-join($work//tei:titleStmt//tei:author//tei:persName/@ref, " ")
                let $work_title        := if ($work//tei:titleStmt/tei:title[@type="short"] and not($work//tei:text[@type = "working_paper"])) then
                                            $work//tei:titleStmt/tei:title[@type="short"]/text()
                                         else if ($work//tei:titleStmt/tei:title[@type="main"]) then
                                            $work//tei:titleStmt/tei:title[@type="main"]/text()
                                         else
                                            $work//tei:titleStmt/tei:title[1]/text()
                let $work_year        := if ($work//tei:sourceDesc//tei:date[@type = "summaryThisEd"]) then
                                            xs:string($work//tei:sourceDesc//tei:date[@type = "summaryThisEd"])
                                        else if  ($work//tei:sourceDesc//tei:date[@type = "thisEd"]) then
                                            xs:string($work//tei:sourceDesc//tei:date[@type = "thisEd"])
                                        else if  ($work//tei:sourceDesc//tei:date[@type = "summaryFirstEd"]) then
                                            xs:string($work//tei:sourceDesc//tei:date[@type = "summaryFirstEd"])
                                        else if  ($work//tei:sourceDesc//tei:date[@type = "firstEd"]) then
                                            xs:string($work//tei:sourceDesc//tei:date[@type = "firstEd"])
                                        else if  ($work//tei:date[@type ="digitizedEd"]) then
                                            xs:string($work//tei:date[@type = "digitizedEd"])
                                        else ()
                let $hit_type         := local-name($hit)
                let $hit_id           := xs:string($hit/@xml:id)
                let $hit_citetrail    := doc($config:data-root || '/' || $work_id || '_nodeIndex.xml')//sal:node[@n = $hit_id]/sal:citetrail
                let $hit_language     := xs:string($hit/ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang)
                let $hit_fragment     := if ($hit_id and xmldb:collection-available($config:html-root || '/' || $work_id)) then
                                            render:getFragmentFile($work_id, $hit_id)
                                         else ()
                let $hit_fragment_number := if ($hit_fragment) then
                                                xs:int(substring($hit_fragment, 1, 4))
                                            else ()
                let $hit_path         := if ($hit_fragment) then
                                            $config:webserver || "/html/" || $work_id || "/" || $hit_fragment || ".html"
                                         else
                                            "#No fragment discoverable!"
                let $hit_url          :=      if ($hit_fragment and substring($work_id,1,2)="W0") then
                                            $config:idserver || "/works."   || $work_id || ':' || $hit_citetrail
                                         else if (substring($work_id,1,1)="A") then
                                            $config:idserver || "/authors." || $work_id
                                         else if (substring($work_id,1,1)="L") then
                                            $config:idserver || "/lemmata." || $work_id
                                         else if (substring($work_id,1,2)="WP") then
                                            $config:webserver || "/workingPaper.html?wpid=" || $work_id
                                         else
                                            "#No fragment discoverable!"

                (: Here we define the to-be-indexed content! :)
                let $hit_content_orig := if ($hit_id) then
                                            string-join(sphinx:dispatch($hit, "orig"), '')
                                          else
                                            "There is no xml:id in the " || $hit_type || " hit!"
                let $hit_content_edit := if ($hit_id) then
                                            string-join(sphinx:dispatch($hit, "edit"), '')
                                          else
                                            "There is no xml:id in the " || $hit_type || " hit!"

                (: Now build a sphinx "row" for the fragment :)
                let $sphinx_id    := xs:long(substring($work_id, functx:index-of-string-first($work_id, "0"))) * 1000000 + ( (string-to-codepoints(substring($work_id, 1, 1)) + string-to-codepoints(substring($work_id, 2, 1))) * 10000 ) + $index
                let $html_snippet :=
                        <sphinx:document id="{$sphinx_id}">
                            <div>
                                <h3>Hit
                                    <sphinx_docid>{$sphinx_id}</sphinx_docid>
                                    in <sphinx_work_type>{$work_type}</sphinx_work_type> <sphinx_work>{$work_id}</sphinx_work>:<br/>
                                    <sphinx_author>{$work_author_name}</sphinx_author>
                                    {if ($work_author_id) then " (" || <sphinx_authorid>{$work_author_id}</sphinx_authorid> || ")" else ()},
                                    <sphinx_title>{$work_title}</sphinx_title>
                                    (<sphinx_year>{$work_year}</sphinx_year>)
                                </h3>
                                <h4>Hit
                                    language: &quot;<sphinx_hit_language>{$hit_language}</sphinx_hit_language>&quot;,
                                    node type: &lt;<sphinx_hit_type>{$hit_type}</sphinx_hit_type>&gt;,
                                    node xml:id: &quot;<sphinx_hit_id>{$hit_id}</sphinx_hit_id>&quot;
                                </h4>
                                <p>
                                    <em><sphinx_description_orig>{$hit_content_orig}</sphinx_description_orig></em>
                                </p>
                                <p>
                                    <em><sphinx_description_edit>{$hit_content_edit}</sphinx_description_edit></em>
                                </p>
                                <p>
                                    find it in fragment number {$hit_fragment_number} here: <a href="{$hit_path}"><sphinx_html_path>{$hit_path}</sphinx_html_path></a><br/>
                                    or here: <a href="{$hit_url}"><sphinx_fragment_path>{$hit_url}</sphinx_fragment_path></a>
                                </p>
                                <hr/>
                            </div>
                        </sphinx:document>

                let $sphinx_snippet :=
                        <sphinx:document id="{$sphinx_id}">
                            <sphinx_docid>{$sphinx_id}</sphinx_docid>
                            <sphinx_work>{$work_id}</sphinx_work>
                            <sphinx_work_type>{$work_type}</sphinx_work_type>
                            <sphinx_author>{$work_author_name}</sphinx_author>
                            <sphinx_authorid>{$work_author_id}</sphinx_authorid>
                            <sphinx_title>{$work_title}</sphinx_title>
                            <sphinx_year>{$work_year}</sphinx_year>
                            <sphinx_hit_language>{$hit_language}</sphinx_hit_language>
                            <sphinx_hit_type>{$hit_type}</sphinx_hit_type>
                            <sphinx_hit_id>{$hit_id}</sphinx_hit_id>
                            <sphinx_description_orig>{$hit_content_orig}</sphinx_description_orig>
                            <sphinx_description_edit>{$hit_content_edit}</sphinx_description_edit>
                            <sphinx_html_path>{$hit_path}</sphinx_html_path>
                            <sphinx_fragment_path>{$hit_url}</sphinx_fragment_path>
                            <sphinx_fragment_number>{$hit_fragment_number}</sphinx_fragment_number>
                        </sphinx:document>

                let $fileName       := format-number($index, "00000") || "_" || $hit_id || ".snippet.xml"
                let $storeStatus    := if ($hit_id) then admin:saveFile($work_id, $fileName, $sphinx_snippet, "snippets") else ()

                order by $work_id ascending
                return if ($mode = "html") then
                            $html_snippet
                        else if ($mode = "sphinx") then
                            $sphinx_snippet
                        else ()

(: Now return statistics, schema and the whole document-set :)
    let $runtime-ms := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S')) * 1000
    return if ($mode = "html") then
                <html>
                <body>
                    <sphinx:docset>
                        <p>
                            Zu indizieren: {count($todo)} Werk(e); {count($hits)} Fragmente generiert; gesamte Rechenzeit:
                            {if ($runtime-ms < (1000 * 60))             then format-number($runtime-ms div 1000, "#.##") || " Sek."
                              else if ($runtime-ms < (1000 * 60 * 60)) then format-number($runtime-ms div (1000 * 60), "#.##") || " Min."
                              else                                          format-number($runtime-ms div (1000 * 60 * 60), "#.##") || " Std."
                            }
                        </p>
                        {$hits}
                    </sphinx:docset>
                </body>
                </html>
            else if ($mode = "sphinx") then
                <sphinx:docset>
                    {$sphinx:schema}
                    {$hits}
                </sphinx:docset>
    else
                <html>
                    <body>
                        <div>
                            Called with unknown mode &quot;{$mode}&quot; (as httpget parameter).
                        </div>
                    </body>
                </html>
};
