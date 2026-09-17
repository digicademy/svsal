<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
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
    <xsl:param name="workId" as="xs:string" select="'W0025'"/>
    <xsl:param name="textId" as="xs:string" select="'completeWork'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_monograph'"/> <!-- "work_monograph" or "work_volume" only for volumes - "work_multivolume" only for main work-->
    <xsl:param name="textLang" as="xs:string" select="'la'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="0"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- param for text processing mode -->
<!--    <xsl:param name="analyzeTextEnabled" as="xs:boolean" select="true()"/> <!-\- this doens't need to be modified -\->-->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2026-04-14'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from TEI-Tite to TEI-All.'"/>
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
    <xsl:include href="W0025_003b.xsl"/>
    
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
  <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">De fide, Spe, &amp; Charitate</title>
                <title type="main" level="m">De fide, Spe, &amp; Charitate. Catholico Regi Philippo II. Magno Hispaniarvm Monarchæ, Scholastica Commentaria in Secundam Secundæ Angelici Doctoris partem, quæ ad Quæstionem Quadragesimam sextam protenduntur, dicata</title> 
                <author>
                    <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237 viaf:88708934" key="Báñez, Domingo">
                        <forename>Domingo</forename>
                        <surname>Báñez</surname>
                    </persName>
                </author>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
               <edition n="unpublished"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
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
                            <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237 viaf:88708934" key="Báñez, Domingo">
                                <forename>Domingo</forename>
                                <surname>Báñez</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De fide, Spe, &amp; Charitate</title>
                        <title type="main" level="m">De fide, Spe, &amp; Charitate. Catholico Regi Philippo II. Magno Hispaniarvm Monarchæ, Scholastica Commentaria in Secundam Secundæ Angelici Doctoris partem, quæ ad Quæstionem Quadragesimam sextam protenduntur, dicata</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanticae</pubPlace>
                            <date type="firstEd" when="1584">1584</date>
                            <publisher n="firstEd">
                                <placeName ref="cerl:cnc00008968 viaf:156550588 gnd:5164075-2" key="Convento de San Esteban">
                                    <orgName>Apud S. Stephanum Ordinis Prædicatorum</orgName>
                                </placeName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[11] Seiten, 1476 Spalten, [1] Blatt, [56] Seiten</extent>
                        <extent xml:lang="en">[11] p., 1476 col., [1] fol., [56] p.</extent>
                        <extent xml:lang="es">[11] p., 1476 col., [1] fol., [56] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="viaf:307472291" xml:lang="en">HathiTrust Digital Library</repository>
                        <idno type="catlink" xml:lang="en">https://babel.hathitrust.org/cgi/pt?id=ucm.5316859096&amp;seq=1</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#W0025-0440 #W0025-0441 #W0025-0153 #W0025-0199 #W0025-0258 #W0025-0278 #W0025-0310 #W0025-0326">
                    <msIdentifier>
                        <repository xml:lang="es">Biblioteca Virtual del Patrimonio Bibliográfico</repository>
                        <idno type="catlink" xml:lang="es">https://bvpb.mcu.es/en/consulta/registro.do?id=464064</idno>
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
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/works-general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <p xml:id="W0025_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                    Abbreviations are partially resolved.</p>
            </editorialDecl>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/specialchars.xml">project website</ref>.</note></char></charDecl>
                </xi:fallback>
            </xi:include>
			<appInfo>
                <application ident="auto-markup" version="1" xml:id="auto">
                    <desc>Automatically generated markup.</desc>
                </application>
            </appInfo>
        </encodingDesc>
        
        <revisionDesc status="a_raw">
            <listChange ordered="true">
                <change who="#CR #auto" when="2026-04-14" status="a_raw" xml:lang="en" xml:id="W0025_change_004">Transformation TEI-tite to TEI-All.</change>
                <change who="#CR #auto" when="2026-04-07" status="a_raw" xml:lang="en" xml:id="W0025_change_003">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2026-03-18" status="a_raw" xml:lang="en" xml:id="W0025_change_002">Tagged @n, @type, @xml:id(s) in div(s), list(s) and @target in TOC and summaries.</change>
                <change who="#CR" when="2026-03-11" status="a_raw" xml:lang="en" xml:id="W0025_change_001">Structural annotation and first round of unclear.</change>
                <change who="#CR" when="2025-05-08" status="a_raw" xml:lang="en">Corrected encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2025-04-23" status="a_raw" xml:lang="en">Set teiHeader.</change>
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
                    href="https://files.salamanca.school/saltei.rng"
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