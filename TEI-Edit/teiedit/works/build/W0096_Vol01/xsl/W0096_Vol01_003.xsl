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
    <xsl:param name="workId" as="xs:string" select="'W0096_Vol01'"/>
    <xsl:param name="textId" as="xs:string" select="'Vol01'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_multivolume'"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string" select="'la'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="01"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- param for text processing mode -->
    <!--    <xsl:param name="analyzeTextEnabled" as="xs:boolean" select="true()"/> <!-\- this doens't need to be modified -\->-->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-11-21'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from Tite to TEI'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0096_Vol01-00-change-0005'"/>
    <!-- schemes for validation, either 'SalTEI' (for validation with the custom Salamanca TEI scheme, or 'TEIAll' for generic TEI): -->
    <xsl:param name="validationScheme" as="xs:string" select="'SalTEI'"/>
    <!-- the teiHeader to be embedded in the document, see the variable at the bottom of this stylesheet -->
    <xsl:param name="teiHeader" xml:space="preserve" select="$teiHeaderCopy"/> 
    
    
    
    <!-- ##################################################################################################################### -->
    
    <!-- remove any existing processing instructions, to be replaced by the ones below -->    
    <xsl:template match="processing-instruction()" priority="2"/>
    
    
    
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
    
    
    <!-- templates for processing elements within tei:text are included from tl2sal_tite2tei_text.xsl -->
    <xsl:include href="W0096_Vol01_003b.xsl"/>
    
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
  <teiHeader>
        <fileDesc>
            
            <!-- Titelangaben unserer digitalen Editions-Datei -->
            <titleStmt>
                <title type="short" level="m">De Indiarum Iure, sive de Iusta Indiarum Occidentalium Inquisitione, Acquisitione, et Retentiones Tribus Libris Comprehensum. 2 vols.</title>
                <title type="main" level="m">D. Philip. IV. Hisp. Etind. Regiopt. Max Ioannes De Solorzano Pereira I.V.D. Ex Primarijs olim Academiæ Salmanticensis Antecessoribus. Postea Limensis Prætorij in Peruano Regno Novi Orbis Senator: Nunc vero in Supremo Indiarum Conisilio Regij Fisci Patronus, Dispvtationem De Indiarvm Ivre De iusta Indiarum Occidentalium inquisitione, acquisitione, et retentione Tribvs Libris, Comprehensam, .D.E.C. Cvm Privilegio. Matriti. Ex Typographia Fanciscia Martinez. Anno 1629</title>
                <author>
                    <persName ref="author:A0082 gnd:118837389 cerl:cnp01341312" key="Solórzano Pereira, Juan de" full="yes">
                        <forename full="yes">Juan</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Solórzano Pereira</surname>
                    </persName>
                </author>
                
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                <editor xml:id="CB" role="#additional">
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
                    </persName>
                </editor>
                
            </titleStmt>
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>
            <seriesStmt>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="unpublished"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0082 gnd:118837389 cerl:cnp01341312" key="Solórzano Pereira, Juan de" full="yes">
                                <forename full="yes">Juan</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Solórzano Pereira</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Dispvtationem De Indiarvm Ivre De iusta Indiarum Occidentalium inquisitione, acquisitione, et retentione</title>
                        <title type="main" level="m">D. Philip. IV. Hisp. Etind. Regiopt. Max Ioannes De Solorzano Pereira I.V.D. Ex Primarijs olim Academiæ Salmanticensis Antecessoribus. Postea Limensis Prætorij in Peruano Regno Novi Orbis Senator: Nunc vero in Supremo Indiarum Conisilio Regij Fisci Patronus, Dispvtationem De Indiarvm Ivre De iusta Indiarum Occidentalium inquisitione, acquisitione, et retentione Tribvs Libris, Comprehensam, .D.E.C. Cvm Privilegio. Matriti. Ex Typographia Fanciscia Martinez. Anno 1629</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010413" key="Madrid">Matriti</pubPlace>
                            <date type="firstEd" when="1629">1629</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00025919" key="Martinez, Francisco" full="yes">
                                    <forename full="yes">Fanciscia</forename>
                                    <surname full="yes">Martinez</surname>
                                </persName>
                            </publisher>
                        </imprint>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">http://brumario.usal.es/record=b1465315#.W_QWA-hKhaQ</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#facs:W0096-A-0552 #facs:W0096-A-0553" >
                    <msIdentifier>
                        <repository ref="gnd:7721988-0" xml:lang="es">Google books</repository>
                        <idno type="catlink" xml:lang="en">https://play.google.com/books/reader?id=03N0p36BkpkC&amp;hl=es_419&amp;pg=GBS.PA518</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        <profileDesc>
           <langUsage>
              <language ident="la" n="main" xml:lang="en">Latin</language>
              <language ident="es" n="administrative" xml:lang="en">Español</language>
           </langUsage>
        </profileDesc>
      
        <encodingDesc>
            <xi:include href="../meta/W_Head_general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/Sonderzeichen.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/Sonderzeichen.xml">project website</ref>.</note></char></charDecl>
                </xi:fallback>
            </xi:include>
			<appInfo>
                <application ident="auto-markup" version="1" xml:id="auto">
                    <desc>Automatically generated markup.</desc>
                </application>
            </appInfo>
        </encodingDesc>
        
        
        <!-- Hier anpassen: Überarbeitungshistorie dieses Dokuments -->
      <revisionDesc status="a_raw">
            <listChange ordered="true">
                <change who="#CR" when="2018-12-04" status="a_raw" xml:id="W0096_Vol01_change_010">Normalized Greek special characters tagged as unclear @reason="unbekanntes-Zeichen"</change>
                <change who="#CR" when="2018-11-24" status="a_raw" xml:id="W0096_Vol01_change_007">Chapter titles were rearranged before summaries to successfully adapt the text to TEI structure.</change>
                <change who="#DG #CR #auto" when="2018-11-23" status="a_raw" xml:id="W0096_Vol01_change_006">Changed milestone @unit to 'section'.</change>
                <change who="{$editors}" when="{$editingDate}" status="a_raw" xml:lang="en" xml:id="{$changeId}"><xsl:value-of select="$editingDesc"/></change>
                <change who="#CR #auto" when="2018-11-16" status="a_raw" xml:id="W0096_Vol01_change_004">Added references between milestones and summaries.</change>
                <change who="#CR" when="2018-11-16" status="a_raw" xml:id="W0096_Vol01_change_003">Table of contents references with chapters</change>
                <change who="#CR" when="2018-11-15" status="a_raw" xml:id="W0096_Vol01_change_002">Transcription of missing pages (518, 519 - facsimiles 0552, 0553)</change>
                <change who="#CR" when="2018-11-13" status="a_raw" xml:id="W0096_Vol01_change_001">Structural Annotation</change>
                <change who="#CB" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>

<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="textOut" as="element(tei:text)">
        <xsl:apply-templates/>
    </xsl:variable>
    
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
            <xsl:copy-of select="$textOut"/>
        </xsl:element>
        
        <!-- LOGGING -->
        <xsl:message select="'-----------------------------------------------------------'"/>
        <xsl:variable name="inWhitespace" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="inChars" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($textOut//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($textOut//text(), ''), '\s', ''))"/>
        <xsl:variable name="inSpecialChars" as="xs:integer" select="count(//tei:g)"/>
        <xsl:variable name="outSpecialChars" as="xs:integer" select="count($textOut//tei:g)"/>
        <xsl:variable name="inPb" as="xs:integer" select="count(//tei:pb)"/>
        <xsl:variable name="outPb" as="xs:integer" select="count($textOut//tei:pb)"/>
        <xsl:variable name="inCb" as="xs:integer" select="count(//tei:cb)"/>
        <xsl:variable name="outCb" as="xs:integer" select="count($textOut//tei:cb)"/>
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb)"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($textOut//tei:lb)"/>
        <!-- whitespace and regular symbols -->
        <xsl:if test="$inWhitespace ne $outWhitespace or $inChars ne $outChars">
            <xsl:message select="'WARN: different amounts of non-whitespace or whitespace characters in input and output tei:text: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message select="'-----------------------------------------------------------'"/>
        </xsl:if>
        <!-- breaks -->
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb">
            <xsl:message select="'WARN: different amounts of input and output pb/cb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb)"/>
            <xsl:message select="'-----------------------------------------------------------'"/>
        </xsl:if>
        <!-- lb must not differ in input and output, since the transformation doesn't add/remove any of them -->
        <xsl:if test="$inLb ne $outLb">
            <xsl:message select="'ERROR: different amounts of input and output lb: '"/>
            <xsl:message select="concat('Input lb: ', $inLb)"/>
            <xsl:message select="concat('Output lb: ', $outLb)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- special chars -->
        <xsl:if test="$inSpecialChars ne $outSpecialChars">
            <xsl:message select="'ERROR: different amounts of input and output special chars: '"/>
            <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
     
</xsl:stylesheet>