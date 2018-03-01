xquery version "3.0";

declare namespace tei           = "http://www.tei-c.org/ns/1.0";
declare namespace json          = "http://www.json.org";
declare namespace request       = "http://exist-db.org/xquery/request";
declare namespace xmldb         = "http://exist-db.org/xquery/xmldb";
declare namespace ft            = "http://exist-db.org/xquery/lucene";
declare namespace output        = "http://www.w3.org/2010/xslt-xquery-serialization";
import module namespace config  = "http://exist-db.org/xquery/apps/config" at "config.xqm";
declare option output:method "json";
(: declare option output:media-type "application/json"; :)
declare option output:media-type "text/javascript";

declare variable $coll 				as xs:string 	:= request:get-parameter('coll', '');
declare variable $q 				as xs:string 	:= request:get-parameter('q', '');
declare variable $luceneOptions 	as node()		:= <options>
															<default-operator>and</default-operator>
															<leading-wildcard>yes</leading-wildcard>
														</options>;


(:~
~ Main database query (four-column server response: @ref, @key, text, additional) ...
:)
declare function local:query () as node()* {
    let $qstring :=
       if ($q = '') then
           ''
       else
           concat('*', $q, '*')
    let $hits := 
        if ($qstring='' or $coll='') then
            () 
        else if ($coll='persons') then
            collection($config:app-root)//tei:TEI[@xml:id = "Personennamen"]//tei:persName[ ft:query(., $qstring, $luceneOptions)]
        else if ($coll='places') then
            collection($config:app-root)//tei:placeName[ft:query(., $qstring, $luceneOptions)]
        else if ($coll='works') then
            collection($config:app-root)//tei:title[    ft:query(., $qstring, $luceneOptions)]
        else if ($coll='lemmata') then
            collection($config:app-root)//tei:term[     ft:query(., $qstring, $luceneOptions)]
        else
            ()
    let $header := for $colName in ('Ref', 'Key', 'Text', 'Additional') return
                    <cols json:array="true">
                       <name>{$colName}</name>
                    </cols>
    let $body   := for $i in $hits
                    let $ref  := string($i/@ref)
                    let $key  := string($i/@key)
                    let $text := if ($coll='persons') then
                                    normalize-space($i/tei:forename ||
                                    " " ||
                                    $i/tei:nameLink ||
                                    " " ||
                                    $i/tei:surname)
                                else if ($coll='places') then
                                    distinct-values($i)
                                else if ($coll='works') then
                                    distinct-values($i)
                                else if ($coll='lemmata') then
                                    distinct-values($i)
                                else ()
                    let $add  := if ($coll='persons') then
                                    normalize-space($i/tei:genName ||
                                    " " ||
                                    $i/tei:addName)
                                 else ()
                     let $sortValue := if ($coll='persons') then
                                            $i/tei:surname/text()
                                       else
                                            $text
                    order by $key, $sortValue
                    return
                        <data json:array="true">
                             <json:value>{$ref}</json:value>
                             <json:value>{$key}</json:value>
                             <json:value>{$text}</json:value>
                             <json:value>{$add}</json:value>
                        </data>
return
		element response {
		  $header,
		  $body
		}
};


(: Demo and testing responses, to be called with q=1 or q=2 ... :)
(:~
~ Static three-columns demo response
:)
declare function local:demoResponse () as node() {
	<response>
		<cols>
			<name>Key</name>
		</cols>
		<cols>
			<name>Name</name>
		</cols>
		<cols>
			<name>Description</name>
		</cols>
		<data json:array="true">
			<json:value>0</json:value>
			<json:value>This is a static demo server response, {xmldb:get-current-user()}.</json:value>
			<json:value>param "coll"="{$coll}", param "q"="{$q}"</json:value>
		</data>
		<data json:array="true">
			<json:value>1</json:value>
			<json:value>Mottl</json:value>
			<json:value>Dirigent</json:value>
		</data>
		<data json:array="true">
			<json:value>2</json:value>
			<json:value>Singer</json:value>
			<json:value>Kopist</json:value>
		</data>
		<data json:array="true">
			<json:value>3</json:value>
			<json:value>Bla</json:value>
			<json:value>x</json:value>
		</data>
	</response>
};
(:~
~ Test1: Empty results
:)
declare function local:demoResponse1 () as node() {

	<response>
		<cols>
			<name>Key</name>
		</cols>
		<cols>
			<name>Name</name>
		</cols>
		<cols>
			<name>Description</name>
		</cols>
	</response>

};
(:~
~ Test2: Throw a server exception
:)
declare function local:demoResponse2 () as node() { '' };


(:~
~ Decide which of the search or demo functions to call, based on q ...
:)
if ($q = "1") then
    local:demoResponse()
else if ($q = "2") then
    local:demoResponse1()
else
    local:query()
