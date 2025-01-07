xquery version "3.0";

import module namespace request     = "http://exist-db.org/xquery/request";
import module namespace transform   = "http://exist-db.org/xquery/transform";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace config      = "https://www.salamanca.school/xquery/config" at "../../modules/config.xqm";
declare       namespace exist       = "http://exist.sourceforge.net/NS/exist";
declare       namespace sal         = "http://salamanca.adwmainz.de";
declare       namespace tei         = "http://www.tei-c.org/ns/1.0";
declare       namespace itei        = "https://www.salamanca.school/indexed-tei";
declare       namespace util        = "http://exist-db.org/xquery/util";
declare       namespace xi          = "http://www.w3.org/2001/XInclude";

declare option exist:timeout "43200000"; (: 12 h :)

let $resourceId    := request:get-parameter('resourceId', '')
let $idServer      := $config:idserver
let $apiServer     := $config:apiserver
let $webServer     := $config:webserver
let $imageServer   := $config:imageserver

(:
    adjust config for runtime changes:
    - test server hostnames instead of salamanca.school hostnames
    - resourceId in @prepend="texts/W0015:"
:)
let $rawConfiguration   :=  
    if (starts-with($resourceId, 'A') or starts-with($resourceId, 'authors.')) then
        doc("svsal-xtriples-person.xml")
    else if (starts-with($resourceId, 'W0') or starts-with($resourceId, 'works.')) then
        let $xslSheet := 
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:output omit-xml-declaration="yes" indent="yes"/>
                <xsl:param name="resourceId"/>
                <xsl:param name="idServer"/>
                <xsl:param name="apiServer"/>
                <xsl:param name="webServer"/>
                <xsl:param name="imageServer"/>
                <xsl:template match="node()|@*" priority="2">
                    <xsl:copy>
                        <xsl:apply-templates select="node()|@*"/>
                    </xsl:copy>
                </xsl:template>
                <xsl:template match="script"      priority="80"/>
                <xsl:template match="attribute::xml:base[contains(., 'id.salamanca.school')]"      priority="80">
                    <xsl:attribute name="xml:base">
                        <xsl:value-of select="replace(., 'https?://id.salamanca.school', $idServer)"/>
                    </xsl:attribute>
                </xsl:template>
                <xsl:template match="attribute::prepend[contains(., 'texts/WXXXX')]"      priority="80">
                    <xsl:attribute name="prepend">
                        <xsl:value-of select="replace(., 'texts/WXXXX', concat('texts/', $resourceId))"/>
                    </xsl:attribute>
                </xsl:template>
                <xsl:template match="attribute::prepend[contains(., 'id.salamanca.school')]"      priority="80">
                    <xsl:attribute name="prepend">
                        <xsl:value-of select="replace(., 'https?://id.salamanca.school', $idServer)"/>
                    </xsl:attribute>
                </xsl:template>
                <xsl:template match="attribute::prepend[contains(., 'api.salamanca.school')]"      priority="80">
                    <xsl:attribute name="prepend">
                        <xsl:value-of select="replace(., 'https?://api.salamanca.school', $apiServer)"/>
                    </xsl:attribute>
                </xsl:template>
                <xsl:template match="attribute::prepend[contains(., 'www.salamanca.school')]"      priority="80">
                    <xsl:attribute name="prepend">
                        <xsl:value-of select="replace(., 'https?://www.salamanca.school', $webServer)"/>
                    </xsl:attribute>
                </xsl:template>
                <xsl:template match="attribute::prepend[contains(., 'facs.salamanca.school')]"      priority="80">
                    <xsl:attribute name="prepend">
                        <xsl:value-of select="replace(., 'https?://facs.salamanca.school', $imageServer)"/>
                    </xsl:attribute>
                </xsl:template>
            </xsl:stylesheet>
        let $parameters := 
            <parameters>
                <param name="exist:stop-on-warn"  value="yes"/>
                <param name="exist:stop-on-error" value="yes"/>
                <param name="resourceId"          value="{$resourceId}"/>
                <param name="idServer"            value="{$idServer}"/>
                <param name="apiServer"           value="{$apiServer}"/>
                <param name="webServer"           value="{$webServer}"/>
                <param name="imageServer"         value="{$imageServer}"/>
            </parameters>
        let $prelim     := doc("svsal-xtriples-work.xml")
        let $localized  := transform:transform($prelim, $xslSheet, $parameters)
        return $localized
    else
        doc("svsal-xtriples-everything.xml")

(: 
    metadata (teiHeader(s)) are stored separately in one or more resource(s)
    (either one resource for a single-volume work or several $resources for a work AND its volumes
:)
let $workMetadata :=  
    if (starts-with($resourceId, 'W0')) then
        let $workTEI := doc($config:tei-works-root || '/' || $resourceId || '.xml')/tei:TEI
        let $workType := $workTEI/tei:text/@type
        let $workHeader := util:expand(<resource><header docType="{$workType}" docId="{$resourceId}">{$workTEI/tei:teiHeader}</header></resource>)
        return
            if ($workType eq 'work_multivolume') then 
                let $volumeIds := $workTEI/tei:text/tei:group/xi:include/@href/string()
                (: TODO: fix the substring() workaround by stating correct rdf uris in the teiHeader in the first place :)
                let $volumeHeaders := for $id in $volumeIds return
                    <resource>
                        <header type="work_volume" docId="{$resourceId || ':vol' || substring($id,11,1)}">
                            {util:expand(doc($config:tei-works-root || '/' || $id)/tei:TEI/tei:teiHeader)}
                        </header>
                    </resource>
                return ($workHeader, $volumeHeaders)
            else $workHeader
    else ()
(:
    Build collection node with sources and resource children
:)
let $collection :=  
    if (starts-with($resourceId, "authors.")) then
        <collection uri="{$config:tei-authors-root}/{substring-after($resourceId, "authors.")}.xml">
            <resource uri="{{//tei:listPerson}}"/>
        </collection>
    else if (starts-with($resourceId, "works.")) then
        let $uri := if ($config:instanceMode = "dockernet") then 
                "http://existdb:8080/exist/apps/salamanca/enhance-tei.xql?wid=" || substring-after($resourceId, "works.")
            else
                "http://www.salamanca.school:8080/exist/apps/salamanca/enhance-tei.xql?wid=" || substring-after($resourceId, "works.")
        return
            <collection uri="{$uri}">
                {$workMetadata}
                <!--<resource uri="{{//(*:front|*:body|*:back)}}"/>-->
                <resource uri="{{//itei:text[not(descendant::itei:text)]}}"/>
            </collection>
    else if (starts-with($resourceId, 'A')) then
        <collection uri="{$config:tei-authors-root}/{$resourceId}.xml">
            <resource uri="{{//tei:listPerson}}"/>
        </collection>
    else if (starts-with($resourceId, 'W0')) then
        let $uri := if ($config:instanceMode = "dockernet") then 
                "http://existdb:8080/exist/apps/salamanca/enhance-tei.xql?wid=" || $resourceId
            else
                "http://www.salamanca.school:8080/exist/apps/salamanca/enhance-tei.xql?wid=" || $resourceId
        return
            (: <collection uri="{$config:webserver}/enhance-tei.xql?wid={$resourceId}"> :)
            <collection uri="{$uri}">
                {$workMetadata}
                <!--<resource uri="{{//(*:front|*:body|*:back)}}"/>-->
                <resource uri="{{//itei:text[not(descendant::itei:text)]}}"/>
            </collection>
    else if (starts-with($resourceId, 'Q')) then
        <collection>
            <dokument>
                {$workMetadata}
            </dokument>
            <resource uri="{//sal:index}"/>
            <resource uri="{//sal:node}"/>
            <resource uri="{//document}"/>
            <resource uri="{//tei:TEI}"/>
        </collection>
    else ()

(:
    Build config from tranformed configuration and collection
:)
let $output := <xtriples xml:base="{$idServer}/">{$rawConfiguration//configuration}{$collection}</xtriples>


return $output
