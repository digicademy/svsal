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
    <xsl:param name="workId" as="xs:string" select="'W0003'"/>
    <xsl:param name="textId" as="xs:string" select="'completeWork'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_monograph'"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string" select="'la'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="0"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- param for text processing mode -->
<!--    <xsl:param name="analyzeTextEnabled" as="xs:boolean" select="true()"/> <!-\- this doens't need to be modified -\->-->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-02-19'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from TEI Tite to TEI P5.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0003-00-change-0003'"/>
    <!-- schemes for validation, either 'SalTEI' (for validation with the custom Salamanca TEI scheme, or 'TEIAll' for generic TEI): -->
    <xsl:param name="validationScheme" as="xs:string" select="'SalTEI'"/>
    <!-- the teiHeader to be embedded in the document, see the variable at the bottom of this stylesheet -->
    <xsl:param name="teiHeader" xml:space="preserve" select="$teiHeaderCopy"/> 
    
    
    
    <!-- ##################################################################################################################### -->
    
    <!-- remove any existing processing instructions, to be replaced by the ones below -->    
    <xsl:template match="processing-instruction()" priority="2"/>
    
    
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
        <xsl:text>&#xA;</xsl:text>
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
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($textOut//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($textOut//tei:text//text(), ''), '\s', ''))"/>
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
    <xsl:include href="W0003_002b.xsl"/>
    
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
    <teiHeader>
        <fileDesc>
            
            <titleStmt>
                <title type="short" level="m">De Iure et Iustitia Decisiones</title>
                <title type="main" level="m">De Iure &amp; Iustitia Decisiones</title>
                <author>
                    <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237" key="Báñez, Domingo">
                        <forename>Domingo</forename>
                        <surname>Báñez</surname>
                    </persName>
                </author>
                <editor xml:id="CB">
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="IC">
                    <persName ref="gnd:1022577581" full="yes">
                        <surname full="yes">Caesar</surname>, <forename full="yes">Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="TD">
                    <persName ref="gnd:1028938721" full="yes">
                        <surname full="yes">Duve</surname>, <forename full="yes">Thomas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                <editor xml:id="MLB">
                    <persName ref="gnd:1022577581" full="yes">
                        <surname full="yes">Lutz-Bachmann</surname>, <forename full="yes">Matthias</forename>
                    </persName>
                </editor>
                <editor xml:id="CR">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AS">
                    <persName ref="gnd:13605708X" full="yes">
                        <surname full="yes">Spindler</surname>, <forename full="yes">Anselm</forename>
                    </persName>
                </editor>
                <editor xml:id="MT">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
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
                            <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237" key="Báñez, Domingo">
                                <forename>Domingo</forename>
                                <surname>Báñez</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iure et Iustitia Decisiones</title>
                        <title type="main" level="m">De Iure &amp; Iustitia Decisiones</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanticae</pubPlace>
                            <date type="firstEd" when="1594">1594</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00045680" key="Renaut, Andrés">
                                    <forename>Andreas</forename>
                                    <surname>Renaut</surname>
                                </persName>
                                <persName ref="cerl:cni00046508" key="Renaut, Juan">
                                    <forename>Ioannes</forename>
                                    <surname>Renaut</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">14 ungezählte Seiten, 654 Seiten, 18 ungezählte Seiten ; 2°</extent>
                        <extent xml:lang="en">[14], 654, [18] p. ; 2°</extent>
                        <extent xml:lang="es">[14], 654, [18] p. ; 2°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink">http://brumario.usal.es/record=b1508195~S6*spi</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#facs:W0003-0373 #facs:W0003-0374 #facs:W0003-0454 #facs:W0003-0455 #facs:W0003-0630 #facs:W0003-0631">
                    <msIdentifier>
                        <repository ref="gnd:25995-0" xml:lang="es">Biblioteca Histórica Fondo Antiguo, Universidad Complutense de Madrid</repository>
                        <idno type="catlink" xml:lang="es">https://ucm.on.worldcat.org/oclc/1025014839</idno>
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
                <normalization>
                   <p xml:id="meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
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
            <listChange>
                <change who="#CR" when="2019-02-21" status="a_raw" xml:lang="en" xml:id="W0003_change_0008">Milestones were replaced by note @anchored="true".</change>
                <change who="{$editors}" when="{$editingDate}" status="a_raw" xml:lang="en" xml:id="{$changeId}"><xsl:value-of select="$editingDesc"/></change>
                <change who="#CR #auto" when="2019-02-19" status="a_raw" xml:lang="en" xml:id="W0003_change_0002">Added @n to pb.</change>
                <change who="#CR" when="2019-02-12" status="a_raw" xml:lang="en" xml:id="W0003_change_0001">Structural Annotation</change>
                <change who="#DG" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-12" status="a_raw">
                    <list>
                        <item xml:id="item_sgeg">@key bei pubPlace für die Facettierung eingetragen</item>
                        <item xml:id="item_sdjqw">Wenn wir eine neuere als die Erstausgabe digitalisiert haben, müssen in den Facetten und in den bibl. Angaben die bibl. Daten richtig angezeigt werden. Dazu soll das Impressum der Erastausgabe zusätzlich auf der Seite detais_work.html aufgeführt werden. Deswegen folgendes vorghen.</item>
                        <item xml:id="item_jsdbf">Regel in Editionsrichtlinien aufnehmen: Wenn wir die erste Ausgabe digitalisieren konnten, werden folgende Angaben verwendet: pubPlace@role=firstEd, date@type=firstEd, publisher@type=firstEd, date@type="summaryFirstEd"</item>
                        <item xml:id="item_nasljw">Regel in Editionsrichtlinien aufnehmen: Wenn wir eine andere  Ausgabe digitalisieren müssen, werden züsätzlich zu den Angaben der ersten Ausgabe, Angaben zur vorliegenden Ausgabe gemacht: pubPlace@role=thisEd, date@type=thisEd, publisher@type=
                            thisEd, date@type="summaryThisEd"</item>
                        <item xml:id="item_sdljbh">Schema-Anpassungen für date@type="summaryFirstEd" (Wert anpassen) und date@type="summaryThisEd" (Wert hinzufügen) vornehmen</item>
                    </list>
                </change>
                <change who="#IC" when="2014-09-25" status="a_raw">W0003 Header angelegt</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
    
    
</xsl:stylesheet>