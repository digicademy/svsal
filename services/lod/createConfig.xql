xquery version "3.0";

import module namespace request     = "http://exist-db.org/xquery/request";
import module namespace transform   = "http://exist-db.org/xquery/transform";
import module namespace console     = "http://exist-db.org/xquery/console";
import module namespace config      = "http://salamanca/config" at "../../modules/config.xqm";
declare       namespace sal         = "http://salamanca.adwmainz.de";
declare       namespace tei         = "http://www.tei-c.org/ns/1.0";
declare       namespace util        = "http://exist-db.org/xquery/util";
declare       namespace xi          = "http://www.w3.org/2001/XInclude";

let $resourceId    := request:get-parameter('resourceId', '')
let $idServer      := $config:idserver
let $teiServer     := $config:teiserver
let $webServer     := $config:webserver
let $imageServer   := $config:imageserver

let $rawConfiguration   :=  if (starts-with($resourceId, 'A') or starts-with($resourceId, 'authors.')) then
                                doc("svsal-xtriples-person.xml")
                            else if (starts-with($resourceId, 'W0') or starts-with($resourceId, 'works.')) then
                                let $xslSheet      := <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                                                        <xsl:output omit-xml-declaration="yes" indent="yes"/>
                                                        <xsl:param name="idServer"/>
                                                        <xsl:param name="teiServer"/>
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
                                                        <xsl:template match="attribute::resource[contains(., 'tei.salamanca.school')]"      priority="80">
                                                            <xsl:attribute name="resource">
                                                                <xsl:value-of select="replace(., 'https?://tei.salamanca.school', $teiServer)"/>
                                                            </xsl:attribute>
                                                        </xsl:template>
                                                        <xsl:template match="attribute::repeat[contains(., 'tei.salamanca.school')]"      priority="80">
                                                            <xsl:attribute name="repeat">
                                                                <xsl:value-of select="replace(., 'https?://tei.salamanca.school', $teiServer)"/>
                                                            </xsl:attribute>
                                                        </xsl:template>
                                                        <xsl:template match="attribute::prepend[contains(., 'id.salamanca.school')]"      priority="80">
                                                            <xsl:attribute name="prepend">
                                                                <xsl:value-of select="replace(., 'https?://id.salamanca.school', $idServer)"/>
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
                                let $parameters    := <parameters>
                                                        <param name="exist:stop-on-warn"  value="yes"/>
                                                        <param name="exist:stop-on-error" value="yes"/>
                                                        <param name="idServer"            value="{$idServer}"/>
                                                        <param name="teiServer"           value="{$teiServer}"/>
                                                        <param name="webServer"           value="{$webServer}"/>
                                                        <param name="imageServer"         value="{$imageServer}"/>
                                                      </parameters>
                                let $prelim        := doc("svsal-xtriples-work2.xml")
                                let $localized := transform:transform($prelim, $xslSheet, $parameters)
                                return $localized
                            else
                                doc("svsal-xtriples-everything.xml")


let $nodeIndex     := doc($config:data-root || '/' || $resourceId || '_nodeIndex.xml')
let $fullTEI       := doc($config:tei-works-root || '/' || $resourceId || '.xml')/tei:TEI

(: 
    metadata (teiHeader(s)) are stored separately in one or more resource(s)
    (either one resource for a single-volume work or several $resources for a work and its volumes
:)
let $workMetadata :=  if (starts-with($resourceId, 'W0')) then
                            let $workTEI := doc($config:tei-works-root || '/' || $resourceId || '.xml')/tei:TEI
                            let $workType := $workTEI/tei:text/@type
                            let $workHeader := util:expand(<document docType="{$workType}" docId="{$resourceId}">{$workTEI/tei:teiHeader}</document>)
                            return 
                                if ($workType eq 'work_multivolume') then 
                                    let $volumeIds := $workTEI/tei:text/tei:group/xi:include/@href/string()
                                    (: TODO: fix the substring() workaround by stating correct rdf uris in the teiHeader in the first place :)
                                    let $volumeHeaders := for $id in $volumeIds return  <document type="work_volume" docId="{$resourceId || ':vol' || substring($id,11,1)}">
                                                                                            {util:expand(doc($config:tei-works-root || '/' || $id)/tei:TEI/tei:teiHeader)}
                                                                                        </document>
                                    return ($workHeader, $volumeHeaders)
                                else $workHeader
                        else ()

let $collection         :=  if (starts-with($resourceId, "authors.")) then
                                <collection uri="{$config:tei-authors-root}/{substring-after($resourceId, "authors.")}.xml">
                                    <resource uri="{{//tei:listPerson}}"/>
                                </collection>
                            else if (starts-with($resourceId, "works.")) then
                                <collection uri="enhance-tei.xql?wid={substring-after($resourceId, "works.")}">
                                    {$workMetadata}
                                    <resource uri="{{//(tei:front|tei:body|tei:back)/tei:div}}"/>
                                </collection>
                            else if (starts-with($resourceId, 'A')) then
                                <collection uri="{$config:tei-authors-root}/{$resourceId}.xml">
                                    <resource uri="{{//tei:listPerson}}"/>
                                </collection>
                            else if (starts-with($resourceId, 'W0')) then
                                <collection uri="enhance-tei.xql?wid={$resourceId}">
                                    {$workMetadata}
                                    <resource uri="{{//(tei:front|tei:body|tei:back)/tei:div}}"/>
                                </collection>
                            else if (starts-with($resourceId, 'Q')) then
                                <collection>
                                    <dokument>
                                        {$nodeIndex}
                                        {$workMetadata}
                                        {$fullTEI}
                                    </dokument>
                                    <resource uri="{//sal:index}"/>
                                    <resource uri="{//sal:node}"/>
                                    <resource uri="{//document}"/>
                                    <resource uri="{//tei:TEI}"/>
                                </collection>
                            else ()

let $output := <xtriples xml:base="{$idServer}/">{$rawConfiguration//configuration}{$collection}</xtriples>

return $output