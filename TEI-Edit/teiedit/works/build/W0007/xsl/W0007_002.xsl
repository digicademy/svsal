<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    xmlns:tite="http://www.tei-c.org/ns/tite/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <!-- IMPORTANT: 
        - this transformation will only work correctly if there already is a basic TEI skeleton, including 
          a teiHeader specific to the work/volume to be processed
        - define the parameters individually for each work/volume (see below) 
        - optionally, define the teiHeader to be added to the document (if not already added)
    -->
    
    <xsl:output method="xml"/>
    
    <!-- the following parameters need to be stated for each work/volume individually: -->
    <!-- params for work type, no. and ID -->
    <xsl:param name="workId" as="xs:string" select="'W0007'"/>
    <xsl:param name="textId" as="xs:string" select="'completeWork'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_monograph'"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string" select="'es'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="0"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- param for text processing mode -->
<!--    <xsl:param name="analyzeTextEnabled" as="xs:boolean" select="true()"/> <!-\- this doens't need to be modified -\->-->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-21'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from TEI Tite to TEI P5.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0007-change-0011'"/>
    <!-- schemes for validation, either 'SalTEI' (for validation with the custom Salamanca TEI scheme, or 'TEIAll' for generic TEI): -->
    <xsl:param name="validationScheme" as="xs:string" select="'SalTEI'"/>
    <!-- the teiHeader to be embedded in the document, see the variable at the bottom of this stylesheet -->
    <xsl:param name="teiHeader" xml:space="preserve" select="$teiHeaderCopy"/> 
    
    
    
    <!-- ##################################################################################################################### -->
    
    <!-- remove any existing processing instructions, to be replaced by the ones below -->    
    <xsl:template match="processing-instruction()" priority="2"/>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$validationScheme eq 'SalTEI'">
                <xsl:processing-instruction name="xml-model" >
                    href="https://files.salamanca.school/SvSal_txt.rng"
                    type="application/xml"
                    schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
            </xsl:when>
            <xsl:when test="$validationScheme eq 'TEIAll'">
                <xsl:processing-instruction name="xml-model">
                    href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"
                </xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
                <xsl:processing-instruction name="xml-model">
                    href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	                schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
            </xsl:when>
            <xsl:otherwise><xsl:message terminate="yes"/></xsl:otherwise>
        </xsl:choose>
        
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
            <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"/>
            <xsl:attribute name="xml:id" select="$workId"/>
            
            <xsl:copy-of select="$teiHeader"/>
            
            <xsl:apply-templates/>
            
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <xsl:element name="text">
            <xsl:attribute name="type" select="$textType"/>
            <xsl:attribute name="xml:lang" select="$textLang"/>
            <xsl:if test="$volumeNumber > 0">
                <xsl:attribute name="n" select="$volumeNumber"/>
            </xsl:if>
            <xsl:attribute name="xml:id" select="$textId"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- templates for processing elements within tei:text are included from W0014_002-b.xsl -->
    <xsl:include href="W0007_002b.xsl"/>
    
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
    <teiHeader>
        
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Suma de Tratos</title>
                <title type="main" level="m">Suma de tratos y contratos de mercaderes dividido en seis libros</title>
                <author>
                    <persName ref="author:A0060 gnd:115379762 cerl:cnp01237271" key="Mercado, Tomás de">
                        <forename>Tomás</forename>
                        <nameLink>de</nameLink>
                        <surname>Mercado</surname>
                    </persName>
                </author>
                <editor xml:id="CB">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="IC">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="incomplete"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt" xml:lang="de">
                <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                    <xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></publisher>
                    </xi:fallback>
                </xi:include>
                <date type="digitizedEd"/>
                <idno>
                    <idno xml:id="urlid" n="incomplete"/>
                    <idno xml:id="urltei">https://tei.salamanca.school/W0007.xml</idno>
                    <idno xml:id="urlhtml" n="incomplete"/>
                    <idno xml:id="urlrdf" n="incomplete"/>
                    <idno xml:id="urliiif">https://facs.salamanca.school/iiif/presentation/W0007/manifest</idno>
                    <idno xml:id="urltext" n="incomplete"/>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume"/>
            </seriesStmt>
          
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0060 gnd:115379762 cerl:cnp01237271" key="Mercado, Tomás de">
                                <forename>Tomás</forename>
                                <nameLink>de</nameLink>
                                <surname>Mercado</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Suma de tratos</title>
                        <title type="main" level="m">Tratos y Contratos De Mercaderes y tratantes discididos y determinados, por el Padre Presentado Fray Thomas de Mercado, de la orden de los Predicadores</title>
                        <title type="245a" level="m">Tratos y contratos de mercaderes y tratantes discididos y determinados ...</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanca</pubPlace>
                            <date type="firstEd" when="1569">1569</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:103759522X cerl:cnp01372311" key="Gast, Matías">
                                    <forename>Matías</forename>
                                    <surname>Gast</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[14], 249, [14] Bl. : Druckerm. (Holzschn.). ; 4°</extent>
                    </monogr>
                </biblStruct>
                <msDesc type="main">
                    <msIdentifier>
                        <repository ref="gnd:5036103-X" xml:lang="de">Staatsbibliothek zu Berlin</repository>
                        <idno type="catlink">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=388031387</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc xml:lang="en"><p xml:id="W0007-00-meta-pa-0003">Antiqua</p></typeDesc>
                    </physDesc>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        
        <profileDesc>
           <langUsage>
              <language ident="es" usage="97" n="main" xml:lang="en">Spanish</language>
              <language ident="la" usage="3" n="marginal" xml:lang="en">Latin</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/W_Head_general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="W0007-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="W0007-00-meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <normalization>
                    <p xml:id="W0007-00-meta-pa-0006" xml:lang="en" n="long-s">Long s (<q>ſ</q>) were silently normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/Sonderzeichen.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="W0007-00-meta-no-0002"><p xml:id="d1e305">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/Sonderzeichen.xml">project website</ref>.</p></note></char></charDecl>
                </xi:fallback>
            </xi:include>
            <appInfo>
                <application ident="auto-markup" version="0.99" xml:id="auto">
                    <desc>Automatically generated markup.</desc>
                </application>
            </appInfo>
        </encodingDesc>
        <revisionDesc status="a_raw">
            <listChange>
                <change who="#DG #auto" when="2018-08-21" status="a_raw" xml:lang="en" xml:id="W0007-change-0011">Transformation from TEI Tite to TEI P5; revised teiHeader.</change>
                <change who="#DG" when="2018-08-21" status="a_raw" xml:lang="en">Revised and added structural markup; typified div; combined page-breaking marginal notes.</change>
                <change who="#DG" when="2018-08-20" status="a_raw" xml:lang="en">Reset all revision statuses to a_raw.</change>
                <change who="#DG" when="2016-12-20" status="a_raw" xml:lang="en">Annotated structural divisions, tables of contents, and index; added pagination.</change>
                <change who="#AW" when="2015-08-25" status="a_raw" xml:lang="en">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw" xml:lang="en">revision of teiHeader</change>
                <change who="#IC" when="2014-09-01" status="a_raw" xml:lang="de">titleStmt und sourceDesc angepasst</change>
                <change who="#AW" when="2014-03-26" status="a_raw" xml:lang="de">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="a_raw" xml:lang="de">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="a_raw" xml:lang="de">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="a_raw" xml:lang="de">
                    <list>
                        <item xml:id="item_lgwlwdf4">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_oioiou">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_jlolin">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_ayweedf">Typen von text und div-tags z.T. angepasst.</item>
                    </list>
                </change>
                <change who="#AW" when="2013-08-22" status="a_raw" xml:lang="de">Nach Schema-Updates
                    angepasst.</change>
                <change who="#AW" when="2013-08-13" status="a_raw" xml:lang="de">Datei(en) aufgeteilt und mit XInclude
                    zusammengehalten (Header und die div. Teile des mehrbändigen Werkes).</change>
                <change who="#AW" when="2013-08-08" status="a_raw" xml:lang="de">Ausgehend von Testdatensatz W0014 angelegt, um
                    das schwierige Layout abzubilden</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
    
    
</xsl:stylesheet>