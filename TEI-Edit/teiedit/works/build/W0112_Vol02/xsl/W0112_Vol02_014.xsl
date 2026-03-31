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
    
    
<xsl:variable name="teiHeader" xml:space="preserve"><teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Govierno Eclesiastico Pacifico</title>
                <title type="main" level="m">Govierno Eclesiastico Pacifico, Y Vnion De Los Dos Cvchillos, Pontificio, Y Regio</title>
                <title type="volume" level="m" n="2">Segvnda Parte</title>
                <author>
                    <persName ref="author:A0099 gnd:11880460X viaf:13103890 cerl:cnp00538814" key="de Villarroel, Gaspar">
                        <forename>Gaspar</forename>
                        <nameLink>de</nameLink>
                        <surname>Villarroel</surname>
                    </persName>
                </author>
                
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="MAH" role="#technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0112_Vol02-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-09-30">2025-09-30</date>.
                </edition>
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
                <date type="digitizedEd" when="2025-09-30">2025-09-30</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0112:vol2</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0112:vol2?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0112:vol2?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0112:vol2?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0112:vol2?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0112:vol2?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0112:vol2?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="50.2">Volume 50.2</biblScope>
           </seriesStmt>
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0112"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0099 gnd:11880460X viaf:13103890 cerl:cnp00538814" key="de Villarroel, Gaspar">
                                <forename>Gaspar</forename>
                                <nameLink>de</nameLink>
                                <surname>Villarroel</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Govierno Eclesiastico Pacifico</title>
                        <title type="main" level="m">Govierno Eclesiastico Pacifico, Y Vnion De Los Dos Cvchillos, Pontificio, Y Regio</title>
                        <title type="volume" level="m" n="2">Segvnda Parte</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010420" key="Madrid">Madrid</pubPlace>
                            <date type="firstEd" when="1656">1657</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00017148 gnd:1037643399 viaf:304955080" key="Garcia Morràs, Domingo">
                                    <forename>Domingo</forename>
                                    <surname>Garcia Morràs</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 697 Seiten, 122 ungezählte Seiten</extent>
                        <extent xml:lang="en">[16] p., 697 p., [122] p.</extent>
                        <extent xml:lang="es">[16] p., 697 p., [122] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">British Library</repository>
                        <idno type="catlink" xml:lang="en">http://explore.bl.uk/BLVU1:LSCOP-ALL:BLL01003794859</idno>
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
              <language ident="es" n="main" xml:lang="en">Spanish</language>
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
                <p xml:id="W0112_Vol02_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2025-09-30" status="g_enriched_approved" xml:id="W0112_Vol02_change_019" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_018" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_017" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_016" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_015" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_014" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_013" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2025-09-30" status="f_enriched" xml:id="W0112_Vol02_change_012" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2025-09-25" status="f_enriched" xml:id="W0112_Vol02_change_011" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2025-09-25" status="f_enriched" xml:lang="en" xml:id="W0112_Vol02_change_010">Tagged special characters.</change>
                <change who="#CR #auto" when="2025-09-25" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_009">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR #auto" when="2025-09-23" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_008">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2025-09-23" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_007">Added (es) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2025-09-10" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_006">Tagging foreign (la).</change>
                <change who="#CR #auto" when="2025-09-09" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_005">Adding @target to ref in summaries.</change>
                <change who="#CR #auto" when="2025-09-03" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_004">Tagged @n, @type, @xml:id(s) in div(s) and milestone, list(s) and @target in TOC.</change>
                <change who="#CR" when="2025-06-10" status="a_raw" xml:lang="en" xml:id="W0112_Vol02_change_003">Structural annotation and unclear first round.</change>
                <change who="#CR" when="2025-05-13" status="a_raw" xml:lang="en">Added encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2022-08-17" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
</xsl:stylesheet>