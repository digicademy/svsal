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
    <xsl:param name="workId" as="xs:string" select="'W0014'"/>
    <xsl:param name="textId" as="xs:string" select="'completeWork'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_monograph'"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string" select="'la'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="0"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-10'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from TEI Tite to SalTEI.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0014-00-change-0011'"/>
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
    <xsl:include href="W0014_002-b.xsl"/>
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Summa Sacramentorum</title>
                <title type="main" level="m">Summa sacramentorum Ecclesiae</title>
                <author>
                    <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key="Vitoria, Francisco de">
                        <forename>Francisco</forename>
                        <nameLink>de</nameLink>
                        <surname>Vitoria</surname>
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
            
            <!--<editionStmt>
               <edition n="1" xml:id="W0014-version1" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd"/>.
               </edition>
            </editionStmt>-->
            
            <publicationStmt xml:id="publicationStmt" xml:lang="de">
                <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                    <xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></publisher>
                    </xi:fallback>
                </xi:include>
                <!--<date type="digitizedEd"/>-->
                <idno>
                    <!--<idno xml:id="urlid">https://id.salamanca.school/works.W0014</idno>-->
                    <!--<idno xml:id="urltei">https://tei.salamanca.school/W0014.xml</idno>-->
                    <!--<idno xml:id="urlhtml">https://www.salamanca.school/work.html?wid=W0014</idno>-->
                    <!--<idno xml:id="urlrdf">https://data.salamanca.school/works.W0014.rdf</idno>-->
                    <idno xml:id="urliiif">https://facs.salamanca.school/iiif/presentation/W0014</idno>
                    <!--<idno xml:id="urltext">https://api.salamanca.school/txt/work.W0014.edit</idno>-->
                </idno>
            </publicationStmt>
            <seriesStmt>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <!--<biblScope unit="volume" n="..." xml:lang="en">Volume ...</biblScope>-->
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key="Vitoria, Francisco de">
                                <forename>Francisco</forename>
                                <nameLink>de</nameLink>
                                <surname>Vitoria</surname>
                            </persName>
                        </author>
                        <editor>
                            <persName ref="viaf:17576008 cerl:cni00049414" key="Chaves, Thomas de">
                                <forename>Thomas</forename>
                                <nameLink>de</nameLink>
                                <surname>Chaves</surname>
                            </persName>
                        </editor>
                        <title type="short" level="m">Summa Sacramentorum</title>
                        <title type="main" level="m">Svmma Sacramentorvm Ecclesiæ : Ex doctrina doctissimi patris magistri fratris Francisci a Victoria, cathedram primæ in Salmanticensi florentissima academia profitentis, ex sacra predicatorum familia oriundi / co[n]gesta per fratrem Thomam de Chaues eius fidelem discipulu[m]</title>
                        <title type="245a" level="m">Summa Sacramentorum Ecclesiae : ex doctrina doctissimi patris magistri fratris Fratris Francisci a Victoria, cathedram primae in Salmanticensi florentissima academia profitentis, ex sacra predicatorum familia oriundi / congesta per fratrem Thomam de Chaues eius fidelem discipulum</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008771" key="Valladolid">Pinciae</pubPlace>
                            <date type="firstEd" when="1561">1561</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00031746" key="Martinez, Sebastián"><!--not in GND-->
                                    <forename>Sebastianus</forename>
                                    <surname>Martinez</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent>[8], 248, [10] Bl. ; 8°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink">http://brumario.usal.es/record=b1725183~S6*spi</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc xml:lang="en"><p xml:id="W0014-00-meta-pa-0001">Antiqua</p></typeDesc>
                    </physDesc>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        
        <profileDesc>
           <langUsage>
              <language ident="la" usage="100" n="main" xml:lang="en">Latin</language>
              <language ident="es" xml:lang="en">Spanish</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/W_Head_general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="W0014-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="W0014-00-meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <normalization>
                   <p xml:id="W0014-00-meta-pa-0006" xml:lang="en">Long s (<q>ſ</q>) were silently normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/Sonderzeichen.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="W0014-00-meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/Sonderzeichen.xml">project website</ref>.</note></char></charDecl>
                </xi:fallback>
            </xi:include>
            <appInfo>
                <application ident="auto-markup" version="0.99" xml:id="auto">
                    <desc>Automatically generated markup.</desc>
                </application>
            </appInfo>
        </encodingDesc>
        
        <revisionDesc status="a_raw">
            <listChange ordered="true">
                <change who="{$editors}" when="{$editingDate}" status="a_raw" xml:lang="en" xml:id="{$changeId}"><xsl:value-of select="$editingDesc"/></change>
                <change who="#DG #auto" when="2018-08-09" status="a_raw" xml:lang="en">
                    <list>
                        <item xml:id="W0014-00-change-0010">Added pagination (pb/@n), fixed page order.</item>
                        <item xml:id="W0014-00-change-0009">Added structural annotations (div, head, p).</item>
                        <item xml:id="W0014-00-change-0008">Annotated table of contents (back matter) as list (normalizing the heading structure, see head[@change="#W0014-00-change-0008"]).</item>
                        <item xml:id="W0014-00-change-0007">Resolved some unclear marks.</item>
                        <item xml:id="W0014-00-change-0006">Normalized marginal note structure, aligning "divergent" notes with their 
                            actual paragraphs and combining page-breaking notes; 
                            resolved number-only marg. notes as milestone elements (see //milestone).</item>
                    </list>
                </change>
                <change who="#DG" when="2018-08-09" status="a_raw" xml:lang="en">Added basic structural markup to TEI Tite text (front/body/back, div, titlePage, head, ...).</change>
                <change who="#AW" when="2015-08-28" status="a_raw" xml:lang="en">Reset status.</change>
                <change who="#IC" when="2014-11-27" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#IC" when="2014-11-18" status="a_raw" xml:lang="de">titleStmt und sourceDesc angepasst.</change>
                <change who="#AW" when="2014-03-26" status="a_raw" xml:lang="de">teiHeader überarbeitet nach neuem Schema/Editionsrichtlinien.</change>
                <change who="#AW" when="2013-09-27" status="a_raw" xml:lang="de">teiHeader überarbeitet nach Schema-Update.</change>
                <change who="#AW" when="2013-08-22" status="a_raw" xml:lang="de">teiHeader nach Schema-Updates angepasst.</change>
                <change who="#AW" when="2013-08-13" status="a_raw" xml:lang="de">Datei(en) aufgeteilt und mit XInclude
                    zusammengehalten (Header und die div. Teile des mehrbändigen Werkes).</change>
                <change who="#AW" when="2013-08-08" status="a_raw" xml:lang="de">Ausgehend von Testdatensatz W0014 angelegt, um
                    das schwierige Layout abzubilden.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
    
    
</xsl:stylesheet>