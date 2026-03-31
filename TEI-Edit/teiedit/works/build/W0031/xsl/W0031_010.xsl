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
                <title type="short" level="m">De locis Theologicis Libri duodecim</title>
                <title type="main" level="m">Reverendissimi. D. Domini Melchioris Cani Episcopí Canariensis, ordinis prædicatorum, &amp; sacræ Theologiæ professoris, ac primariæ cathedræ in academia Salmanticensi olim pr[a]efecti, De locis Theologicis Libri duodecim</title> 
                <author>
                    <persName ref="author:A0016 gnd:118518844 cerl:cnp01118010" key="Cano, Melchor" full="yes">
                        <forename full="yes">Melchor</forename>
                        <surname full="yes">Cano</surname>
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
                      <edition n="1.0.0" xml:id="W0031-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-04-23">2025-04-23</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2025-04-23">2025-04-23</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0031</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0031?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0031?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0031?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/textsW0031?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0031?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0031?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="46"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0016 gnd:118518844 cerl:cnp01118010 viaf:59102478" key="Cano, Melchor" full="yes">
                                <forename full="yes">Melchor</forename>
                                <surname full="yes">Cano</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De locis Theologicis Libri duodecim</title>
                        <title type="main" level="m">Reverendissimi. D. Domini Melchioris Cani Episcopí Canariensis, ordinis prædicatorum, &amp; sacræ Theologiæ professoris, ac primariæ cathedræ in academia Salmanticensi olim pr[a]efecti, De locis Theologicis Libri duodecim</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanca</pubPlace>
                            <date type="firstEd" when="1563">1563</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:103759522X cerl:cnp01372311 viaf:170457147" key="Gast, Matías">
                                    <forename>Matías</forename>
                                    <surname>Gast</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">4 ungezählte Seiten, 518 Seiten, 27 ungezählte Seiten</extent>
                        <extent xml:lang="en">[4], 518, [27] p. ; Fol.</extent>
                        <extent xml:lang="es">[4], 518, [27] p. ; Fol.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004059190" xml:lang="es">Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991005049089705773</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc>
                    <msIdentifier corresp="#facs:W0031-0300">
                        <repository ref="gnd:7721988-0" xml:lang="en">Google-digitized</repository>
                        <idno type="catlink" xml:lang="es">https://books.google.fr/books?vid=BML37001100511745</idno>
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
 <p xml:id="W0031_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#MAH #auto" when="2025-04-23" status="g_enriched_approved" xml:id="W0031_011" xml:lang="en">teiHeader Update for online publication.</change>
                 <change who="#CR #MAH #auto" when="2025-04-17" status="f_enriched" xml:id="W0031_change_010" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #MAH #auto" when="2025-04-15" status="f_enriched" xml:id="W0031_change_009" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #MAH #auto" when="2025-04-15" status="f_enriched" xml:id="W0031_change_008" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG # MAH #auto" when="2025-04-14" status="f_enriched" xml:id="W0031_change_007" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #auto" when="2025-04-14" status="f_enriched" xml:id="W0031_change_006" xml:lang="en">Numbered lines.</change>
                <change who="#DG #MAH #auto" when="2025-04-10" status="f_enriched" xml:lang="en" xml:id="W0031_change_005">Annotated hyphenated breaks.</change>
                <change who="#DG #MAH #auto" when="2025-04-10" status="f_enriched" xml:lang="en" xml:id="W0031_change_004">Tagged special characters.</change>
                <change who="#DG #MAH #auto" when="2025-03-10" status="f_enriched" xml:lang="en" xml:id="W0031_change_003">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#MAH #auto" when="2025-04-09" status="a_raw" xml:lang="en" xml:id="W0031_change_002">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#MAH #auto" when="2025-02-28" status="a_raw" xml:lang="en" xml:id="W0031_change_001">Structural annotation.</change>
                <change who="#CR" when="2024-04-09" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>