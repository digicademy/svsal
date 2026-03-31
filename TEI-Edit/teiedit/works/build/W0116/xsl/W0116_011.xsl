<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <xsl:output method="xml"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="TEI">
        <xsl:text>&#xa;</xsl:text>
        <xsl:copy copy-namespaces="no">
            <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
            <xsl:copy-of select="@*"></xsl:copy-of>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="teiHeader">
        <xsl:copy-of select="$teiHeader"/>
    </xsl:template>
    
    
<xsl:variable name="teiHeader" xml:space="preserve">
<teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">De Iustitia distributiva et acceptione personarum ei opposita.</title>
                <title type="main" level="m">Fratris Ioannis Capata, Y Sandoval Avgvstiniani, Theologiæ Magistri, ac eiusdem, in Vallisoletano D. Gabrielis Collegio Prouinciæ Castellæ, Primarij professoris, et studiorum Regentis. De Ivstitia Distribvtiva et Acceptione Personarum ei opposita</title>
                <author>
                    <persName ref="author:A0101 cerl:cnp02009238 viaf:78382258 gnd:1056172983" key="Zapata y Sandoval, Juan">
                        <forename>Juan</forename>
                        <surname>Zapata y Sandoval</surname>
                    </persName>
                </author>
                      <editor xml:id="MAH" role="#technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
                    </persName>
                </editor>
       <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
              
          
                
            </titleStmt>

            <editionStmt>
                 <edition n="1.0.0" xml:id="W0116-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-06-30">2025-06-30</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2025-06-30">2025-06-30</date>
<idno>
            	     <idno xml:id="urlid">https://id.salamanca.school/texts/W0116</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0116?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0116?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0116?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/textsW0116?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0116?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0116?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                             <biblScope unit="volume" n="51">Volume 51</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0101 cerl:cnp02009238 viaf:78382258 gnd:1056172983" key="Zapata y Sandoval, Juan">
                                <forename>Juan</forename>
                                <surname>Zapata y Sandoval</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iustitia distributiva et acceptione personarum ei opposita.</title>
                        <title type="main" level="m">Fratris Ioannis Capata, Y Sandoval Avgvstiniani, Theologiæ Magistri, ac eiusdem, in Vallisoletano D. Gabrielis Collegio Prouinciæ Castellæ, Primarij professoris, et studiorum Regentis. De Ivstitia Distribvtiva et Acceptione Personarum ei opposita</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008771" key="Valladolid">Vallisoleti</pubPlace>
                            <date type="firstEd" when="1609">1609</date>
                            <publisher n="firstEd">
                                <persName ref="viaf:98885565" key="Lasso Vaca, Cristobal">
                                    <forename>Christophorus</forename>
                                    <surname>Lasso Vaca</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">32 ungezählte Seiten, 454 das heißt 464 Seiten, 35 ungezählte Seiten</extent>
                        <extent xml:lang="en">[32], 454 [i.e. 464], [35] p.</extent>
                        <extent xml:lang="es">[32], 454 [i.e. 464], [35] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991005160659705773</idno>
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
                <p xml:id="W0116_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
        
        <revisionDesc status="g_enriched_approved">
            <listChange ordered="true">
                <change who="#DG #MAH #auto" when="2205-06-30" status="g_enriched_approved" xml:id="W0116_change_016" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #MAH #auto" when="2205-06-23" status="f_enriched" xml:id="W0116_change_015" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #MAH #auto" when="2205-06-23" status="f_enriched" xml:id="W0116_change_014" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #MAH #auto" when="2025-06-23" status="f_enriched" xml:id="W0116_change_013" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #MAH #auto" when="2025-06-23" status="f_enriched" xml:id="W0116_change_012" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #MAH #auto" when="2025-06-23" status="f_enriched" xml:id="W0116_change_011" xml:lang="en">Numbered lines.</change>
                <change who="#DG #MAH #auto" when="2025-06-11" status="f_enriched" xml:lang="en" xml:id="W0116_change_010">Annotated hyphenated breaks.</change>
                <change who="#DG #MAH #auto" when="2025-06-11" status="f_enriched" xml:lang="en" xml:id="W0116_change_009">Tagged special characters.</change>
                 <change who="#DG #MAH #auto" when="2025-06-11" status="f_enriched" xml:lang="en" xml:id="W0116_change_008">TEI -Tite to TEI P5.</change>
                 <change who="#DG #MAH #auto" when="2025-06-11" status="a_raw" xml:lang="en" xml:id="W0116_change_007">Tagged special characters.</change>
 <change who="#DG  #CR #MAH #auto" when="2025-05-29" status="a_raw" xml:lang="en" xml:id="W0116_change_006">Automatically expanded abbreviations with regex (es-main).</change>
 <change who="#DG #CR #MAH #auto" when="2025-05-29" status="a_raw" xml:lang="en" xml:id="W0116_change_005">Automatically expanded abbreviations with regex (la-main).</change>
 <change who="#MAH #auto" when="2025-05-26" status="a_raw" xml:lang="en" xml:id="W0116_change_004">Structural annotation.</change>
                <change who="#CR" when="2025-05-13" status="a_raw" xml:lang="en">Added encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2020-05-11" status="a_raw" xml:lang="en">Set teiHeader.</change>
                <change who="#AW" when="2019" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>