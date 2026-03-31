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
    <xsl:param name="workId" as="xs:string" select="'W0043_Vol08'"/>
    <xsl:param name="textId" as="xs:string" select="'Vol08'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_volume'"/> <!-- "work_monograph" or "work_volume" only for volumes - "work_multivolume" only for main work-->
    <xsl:param name="textLang" as="xs:string" select="'la'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="08"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- param for text processing mode -->
<!--    <xsl:param name="analyzeTextEnabled" as="xs:boolean" select="true()"/> <!-\- this doens't need to be modified -\->-->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2024-05-25'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from TEI-Tite to TEI-All.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0043_Vol07_change_012'"/>
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
    <xsl:include href="W0043_Vol08_003b.xsl"/>
    
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
  <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Universae Theologiae Moralis receptiores</title>
                <title type="main" level="m">R. P. Antonii De Escobar Et Mendoza, Vallisoletani, Societatis Iesv Theologi, Universae theologiae moralis, receptiores absque Lite Sententiae nec-non Controuersae Disquisitiones,</title>
                <title type="volume" level="m" n="7">Tomi Qvinti Pars Altera</title>
                <author>
                    <persName ref="author:A0029 gnd:121064751 cerl:cnp01036518" key="Escobar y Mendoza, Antonio de"> 
                        <forename>Antonio</forename>
                        <nameLink>de</nameLink>
                        <surname>Escobar y Mendoza</surname>
                    </persName>
                </author>
                
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
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
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477">
                        <surname>Thönes</surname>, <forename>Martin</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
               <edition n="unpublished"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback>
                        <publisher>
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref>
                        </publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en">
                            <ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref>
                        </title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="unpublished"/>
            </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0043"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0029 gnd:121064751 cerl:cnp01036518" key="Escobar y Mendoza, Antonio de">
                                <forename>Antonio</forename>
                                <nameLink>de</nameLink>
                                <surname>Escobar y Mendoza</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Universae Theologiae Moralis receptiores</title>
                        <title type="main" level="m">R. P. Antonii De Escobar Et Mendoza, Vallisoletani, Societatis Iesv Theologi, Universae theologiae moralis, receptiores absque Lite Sententiae nec-non Controuersae Disquisitiones,</title>
                        <title type="volume" level="m" n="7">Tomi Qvinti Pars Altera</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lvgdvni</pubPlace>
                            <date type="firstEd" when="1652">1663</date>
                            <date type="summaryFirstEd" when="1652">1.1652 - 10.1663</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00028037" key="Arnaud, Laurent">
                                    <forename>Laurent</forename>
                                    <surname>Arnaud</surname>
                                </persName>
                                <persName ref="cerl:cni00025649" key="Borde, Philippe">
                                    <forename>Philippe</forename>
                                    <surname>Borde</surname>
                                </persName>
                                <persName ref="cerl:cni00006903" key="Rigaud, Claude">
                                    <forename>Claude</forename>
                                    <surname>Rigaud</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[10] Bl., 168 S., [8] Bl.</extent>
                        <extent xml:lang="en">[10] l., 168 p., [8] l.</extent>
                        <extent xml:lang="es">[10] h., 168 p., [8] h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004876156" xml:lang="de">Staatsbibliothek München</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/title/BV035557740</idno>
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
                <xi:fallback>
                    <projectDesc>
                        <p xml:id="meta-pa-0004">
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref>
                        </p>
                    </projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback>
                        <p xml:id="meta-pa-0005">
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref>
                        </p>
                    </xi:fallback>
                </xi:include>
            </editorialDecl>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback>
                    <charDecl>
                        <char xml:lang="en">
                            <note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/specialchars.xml">project website</ref>.</note>
                        </char>
                    </charDecl>
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
                <change who="#CR #auto" when="2023-07-18" status="a_raw" xml:lang="en" xml:id="W0043_Vol07_change_009"><xsl:value-of select="$editingDesc"/></change>
                <change who="#CR #auto" when="2023-07-13" status="a_raw" xml:lang="en" xml:id="W0043_Vol07_change_008">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2023-07-06" status="a_raw" xml:lang="en" xml:id="W0043_Vol07_change_007">Tagged @n, @type, @xml:id(s) in div(s), list(s) and @target in TOC.</change>
                <change who="#CR" when="2023-06-28" status="a_raw" xml:lang="en" xml:id="W0043_Vol07_change_006">Structural annotation.</change>
                <change who="#CR" when="2021-06-18" status="a_raw" xml:lang="en">teiHeader title update.</change>
                <change who="#CR" when="2020-07-08" status="a_raw" xml:lang="en">teiHeader update.</change>
                <change who="#MT" when="2017-11-28" status="a_raw">Perma-Link des Kataloges eingetragen</change>
                <change who="#MT" when="2017-11-22" status="a_raw">Korrekturen beim Autoren-Eintrag für die Vorlage</change>
                <change who="#MT" when="2017-11-21" status="a_raw">Erstellung der XML-Datei</change>
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