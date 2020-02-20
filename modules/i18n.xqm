module namespace i18n = 'http://exist-db.org/xquery/i18n';

declare namespace request="http://exist-db.org/xquery/request"; 

declare namespace sal              = "http://salamanca.adwmainz.de";
(:import module namespace util       = "http://exist-db.org/xquery/util";:)

(:~
    : I18N Internationalization Module:
    
    : @author Lars Windauer <lars.windauer@betterform.de>
    : @author Tobias Krebs <tobi.krebs@betterform.de>
    
    : SvSal extensions:
    
    : @author David Glück
    : @author Andreas Wagner
:)

(:~
 : Start processing the provided content using the modules defined by $modules. $modules should
 : be an XML fragment following the scheme:
 :
 : <modules>
 :       <module prefix="module-prefix" uri="module-uri" at="module location relative to apps module collection"/>
 : </modules>
 :
 : @param $content the sequence of nodes which will be processed
 : @param $modules modules to import
 : @param $model a sequence of items which will be passed to all called template functions. Use this to pass
 : information between templating instructions.
:)
declare function i18n:apply($content as node()+, $modules as element(modules), $model as item()*) {   
    let $null := (
        request:set-attribute("$i18n:modules", $modules)
    )
    for $root in $content              
        return            
            i18n:process($root, (),(),())
};

(:~
 : Continue template processing on the given set of nodes. Call this function from
 : within other template functions to enable recursive processing of templates.
 :
 : @param $nodes the nodes to process
 : @param $model a sequence of items which will be passed to all called template functions. Use this to pass
 : information between templating instructions.
:)
declare function i18n:process($nodes as node()*, $selectedLang as xs:string,$pathToCatalogues as xs:string, $defaultLang as xs:string?) {        
    for $node in $nodes              
        let $selectedCatalogue := i18n:getLanguageCollection($nodes,$selectedLang, $pathToCatalogues,$defaultLang)  
        return        
            i18n:process($node, $selectedCatalogue)
};

(:~
 : recursive function to traverse through the document and to process all i18n prefixed nodes 
 : 
 : @param $node node to analyse if is an i18n:* node 
 : @param $model a sequence of items which will be passed to all called template functions. Use this to pass
 : information between templating instructions.
:)
declare function i18n:process($node as node(), $selectedCatalogue as node()) {  
    typeswitch ($node)
        case document-node() return
            for $child in $node/node() return i18n:process($child, $selectedCatalogue)     
                        
        case element(i18n:translate) return 
            let $text := i18n:process($node/i18n:text,$selectedCatalogue) 
            return 
                i18n:translate($node, $text,$selectedCatalogue)                           

        case element(i18n:text) return            
            i18n:getLocalizedText($node,$selectedCatalogue)                        

        case element() return                 
            element { node-name($node) } {
                    i18n:translateAttributes($node,$selectedCatalogue), 
                    for $child in $node/node() return i18n:process($child,$selectedCatalogue)
            }
                    
        default return 
            $node            
};

declare function i18n:translateAttributes($node as node(), $selectedCatalogue as node()){
    for $attribute in $node/@*
        return i18n:translateAttribute($attribute, $node, $selectedCatalogue)
};

(:declare function i18n:translateAttribute($attribute as attribute(), $node as node(),$selectedCatalogue as node()){
    if(starts-with($attribute, 'i18n(')) then
        let $key := 
            if(contains($attribute, ",")) then
                substring-before(substring-after($attribute,"i18n("),",")
            else 
                substring-before(substring-after($attribute,"i18n("),")")
        let $i18nValue :=   
            if(exists($selectedCatalogue//msg[@key eq $key])) then 
                $selectedCatalogue//msg[@key eq $key]/text() 
            else 
                substring-before(substring-after(substring-after($attribute,"i18n("),","),")")
        return 
            attribute {name($attribute)} {$i18nValue}
    else 
        $attribute
};:)

(:
~ Modified version of the original i18n:translateAttribute() function: 
    translates an attribute with an i18n() call *anywhere* within its string (not only at the beginning).
:)
declare function i18n:translateAttribute($attribute as attribute(), $node as node(),$selectedCatalogue as node()){
(:    if(matches($attribute, 'i18n(.*?)')) then   -- replace this with contains() for performance reasons. matches() uses regex, contains() does not :)
    if(contains($attribute, 'i18n(')) then
        let $match := replace($attribute, '^.*?(i18n\(.*?\)).*?$', '$1') (: takes only the first i18n() function call :)
        let $key := 
            if(contains($match, ",")) then
                substring-before(substring-after($match,"i18n("),",")
            else 
                substring-before(substring-after($match,"i18n("),")")
        let $i18nValue :=   
            if(exists($selectedCatalogue//msg[@key eq $key])) then 
                $selectedCatalogue//msg[@key eq $key]/text() 
            else 
                substring-before(substring-after(substring-after($match,"i18n("),","),")")
        let $processed := replace($attribute, 'i18n\(.*?\)', $i18nValue)
        return 
            attribute {name($attribute)} {$processed}
    else 
        $attribute
};


(: 
 : Get the localized value for a given key from the given catalgue 
 : if no localized value is available, the default value is used
:)
declare function i18n:getLocalizedText($textNode as node(), $selectedCatalogue as node()){
    if(exists($selectedCatalogue//msg[@key eq $textNode/@key])) then 
        $selectedCatalogue//msg[@key eq $textNode/@key]/text() 
    else 
        $textNode/text()
    
};

(:~
 : function implementing i18n:translate to enable localization of strings containing alphabetical or numerical parameters  
 : 
 : @param $node i18n:translate node eclosing i18n:text and parameters to substitute  
 : @param $text the processed(!) content of i18n:text    
:)
declare function i18n:translate($node as node(),$text as xs:string,$selectedCatalogue as node()) {  
    if(contains($text,'{')) then 
        (: text contains parameters to substitute :)
        let $params := $node//i18n:param
        let $paramKey := substring-before(substring-after($text, '{'),'}')
        return                        
            if(number($paramKey) and exists($params[position() eq number($paramKey)])) then
                (: numerical parameters to substitute :) 
                let $selectedParam := $node/i18n:param[number($paramKey)]                
                return 
                    i18n:replaceParam($node, $selectedParam,$paramKey, $text,$selectedCatalogue)
            else if(exists($params[@key eq $paramKey])) then
                (: alphabetical parameters to substituce :)    
                let $selectedParam := $params[@key eq $paramKey]
                return 
                    i18n:replaceParam($node, $selectedParam,$paramKey, $text,$selectedCatalogue)
            
            else 
                (: ERROR while processing parmaters to substitute:)
                concat("ERROR: Parameter ", $paramKey, " could not be substituted")         
    else 
        $text  
};

(:~
 : function replacing the parameter with its (localized) value  
 : 
 : @param $node     i18n:translate node eclosing i18n:text and parameters to substitute  
 : @param $param    currently processed i18n:param as node()
 : @param $paramKey currently processed parameterKey (numerical or alphabetical)
 : @param $text     the processed(!) content of i18n:text    
:)
declare function i18n:replaceParam($node as node(), $param as node(),$paramKey as xs:string, $text as xs:string,$selectedCatalogue as node()) {  
    if(exists($param/i18n:text)) then
        (: the parameter has to be translated as well :)         
        let $translatedParam := i18n:getLocalizedText($param/i18n:text, $selectedCatalogue)
        let $result := replace($text, concat("\{", $paramKey, "\}"), $translatedParam)
        return i18n:translate($node,$result,$selectedCatalogue)                                            
    else     
        (: simply substitute {paramKey} with it's param value' :)
        let $result := replace($text, concat("\{", $paramKey, "\}"), $param)
        return 
            i18n:translate($node, $result,$selectedCatalogue)
};

declare function i18n:getLanguageCollection($node as node()*,$selectedLang as xs:string,$pathToCatalogues as xs:string, $defaultLang as xs:string?) {
  let $tmpNode :=  typeswitch ($node)
        case document-node() return $node/node()                         
        default return $node
        
  let $lang := i18n:getSelectedLanguage($tmpNode,$selectedLang) 
  let $cataloguePath := i18n:getPathToCatalgogues($tmpNode,$pathToCatalogues)
  return 
     if(exists(collection($cataloguePath)//catalogue[@xml:lang eq $lang])) then
        collection($cataloguePath)//catalogue[@xml:lang eq $lang]
    else if(string-length(request:get-parameter("defaultLang", "")) gt 0) then         
        collection($cataloguePath)//catalogue[@xml:lang eq request:get-parameter("cataloguesPath", "")]
    else if(string-length($defaultLang) gt 0) then
        collection($cataloguePath)//catalogue[@xml:lang eq $defaultLang]
    else if(exists($tmpNode/@i18n:default-lang)) then  
        collection($cataloguePath)//catalogue[@xml:lang eq $tmpNode/@i18n:default-lang]
    else ()      

};

declare function i18n:getPathToCatalgogues($node as node()*,$pathToCatalogues as xs:string){
    if(string-length($pathToCatalogues) gt 0) then        
        $pathToCatalogues
    else if(string-length(request:get-parameter("cataloguesPath", "")) gt 0) then 
        request:get-parameter("cataloguesPath", "")
    else if (exists($node/@i18n:catalogues)) then 
        $node/@i18n:catalogues
    else 'ERROR: no path to language catalogues given'
};

declare function i18n:getSelectedLanguage($node as node()*,$selectedLang as xs:string) {    
    if(string-length(request:get-parameter("lang", "")) gt 0) then
        (: use http parameter lang as selected language :)
        request:get-parameter("lang", "")
    else if(exists($node/@xml:lang)) then
        (: use xml:lang attribute on given node as selected language :)
        $node/@xml:lang
    else if(string-length($selectedLang) gt 0) then
        (: use given xquery parameter as selected language :)
        $selectedLang
    else
        'en'
};

(: Consumes a date in standardized format (YYYY-MM-DD) and converts it to either German, English, or Spanish. 
: @param $date    the date string, in standardized format (YYYY-MM-DD)
: @param $lang    the language to convert the date to (either "de", "en", "es")
: @param $mode    the mode/format of the resulting date; this may either be "numeric" (which yields 
:                 a numeric date in the format "DD.MM.YYYY") or verbose (which results in verbose month names, e.g. "January")
: @return         the converted date as a string
:)
declare function i18n:convertDate($date as xs:string, $lang as xs:string, $mode) as xs:string {
    let $dateFormat := if (matches($date, '[0-9]{4}-[0-9]{2}-[0-9]{2}')) then xs:date($date) else ()
    let $convertedDate :=
        if ($mode eq 'verbose') then
            if ($lang eq 'de') then format-date($dateFormat, "[D]. [MNn] [Y]", "de", (), ())
            else if ($lang eq 'en') then format-date($dateFormat, "[D] [MNn] [Y]", "en", (), ())
            else if ($lang eq 'es') then 
                (: format-time does not contain Spanish month names, apparently, so we need to state those extra :)
                let $esMonths := map {"01": "enero", "02": "febrero", "03": "marzo", "04": "abril", "05": "mayo", "06": "junio", 
                          "07": "julio", "08": "agosto", "09": "septiembre", "10": "octubre", "11": "noviembre", "12": "diciembre"}
                let $dateItems := tokenize($date, '-')
                return concat(format-date($dateFormat, "[D]"), " de ", map:get($esMonths, $dateItems[2]), " de ", $dateItems[1])
            else ()
        else if ($mode eq 'numeric') then
            if ($lang eq 'de') then format-date($dateFormat, "[D].[M].[Y]")
            else if ($lang eq 'en') then $date
            else if ($lang eq 'es') then format-date($dateFormat, "[D]/[M]/[Y]")
            else ()
        else ()
    return $convertedDate
};

(: Based on a given sequence of nodes with different @xml:lang, decides which node aligns best with a given language. 
: Currently optimized only for English-German-Spanish.
: @param lang: the language for which to choose the respective node
: @param nodes: the sequence of nodes from which to select the proper node
: @return: the negotiated node, or the empty sequence if no proper node could be found
:)
declare function i18n:negotiateNodes($nodes as node()*, $lang as xs:string) as node()? {
    if (count($nodes) le 1) then $nodes
    else if ($nodes[@xml:lang eq $lang]) then $nodes[@xml:lang eq $lang][1]
    else
        if ($lang eq 'de') then
            if ($nodes[@xml:lang eq 'en']) then $nodes[@xml:lang eq 'en'][1]
            else if ($nodes[@xml:lang eq 'es']) then $nodes[@xml:lang eq 'es'][1]
            else $nodes[1]
        else if ($lang eq 'en') then 
            (: preferring Spanish over German as best substitute for English due to larger diaspora :)
            if ($nodes[@xml:lang eq 'es']) then $nodes[@xml:lang eq 'es'][1] 
            else if ($nodes[@xml:lang eq 'de']) then $nodes[@xml:lang eq 'de'][1]
            else $nodes[1]
        else if ($lang eq 'es') then 
            if ($nodes[@xml:lang eq 'en']) then $nodes[@xml:lang eq 'en'][1] 
            else if ($nodes[@xml:lang eq 'de']) then $nodes[@xml:lang eq 'de'][1]
            else $nodes[1]
        else $nodes[1]
};

(:
~ Enriches crumbtrails with i18n labels, according to the type stated in sal:crumbtrail/a/@class.
:)
declare function i18n:addLabelsToCrumbtrail($crumbtrail as element(sal:crumbtrail)?) as element(sal:crumbtrail)? {
    if ($crumbtrail) then
        <sal:crumbtrail>{
            for $node in $crumbtrail/node() return
                if ($node[self::a]) then 
                        <a href="{$node/@href}"><i18n:text key="{$node/@class}"/>{if ($node/text()) then ' ' || $node/text() else ()}</a>
                else $node
        }</sal:crumbtrail>
    else ()
};


