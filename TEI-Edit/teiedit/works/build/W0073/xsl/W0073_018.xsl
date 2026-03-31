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
    <teiHeader xmlns:sal="http://salamanca.adwmainz.de">
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Restitutione et Contractibus Tractatus</title>
                <title type="main" level="m">Ioannis a Medina S. Theologiae Doctoris, et in Complutensi Academia Professoris, de Restitutione et Contractibus Tractatus/Tomvs Secvndvs</title>
                <author>
                    <persName ref="author:A0058 cerl:cnp01237209 viaf:59430948 gnd:100374824" key="Medina, Juan de">
                        <forename>Juan</forename>
                        <nameLink>de</nameLink>
                        <surname>Medina</surname>
                    </persName>
                </author>
                
                <editor xml:id="MAH" role="#scholarly">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
                    </persName>
                </editor>
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
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0073-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2024-10-08">2024-10-08</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2024-10-08">2024-10-08</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0073</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0073?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0073?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0073?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0073?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0073?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0073?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="37"/>
            </seriesStmt>
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0058 cerl:cnp01237209 viaf:59430948 gnd:100374824" key="Medina, Juan de">
                                <forename>Juan</forename>
                                <nameLink>de</nameLink>
                                <surname>Medina</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Restitutione et Contractibus Tractatus</title>
                        <title type="main" level="m">Ioannis a Medina S. Theologiae Doctoris, et in Complutensi Academia Professoris, de Restitutione et Contractibus Tractatus/Tomvs Secvndvs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salmanticae">Salmanticae</pubPlace>
                            <date type="firstEd" when="1553">1553</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00045910 viaf:99338813 gnd:1037609387" key="Portonariis, Andreas de">
                                    <forename>Andreas</forename>
                                    <nameLink>à</nameLink>
                                    <surname>Portonariis</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">27 ungezählte Seiten, 172 Blätter</extent>
                        <extent xml:lang="en">[27], 172 l.</extent>
                        <extent xml:lang="es">[27], 172 h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004059190" xml:lang="es">Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991009863823205773</idno>
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
                <change who="#CR #auto" when="2024-10-08" status="g_enriched_approved" xml:id="W0073_change_020" xml:lang="en">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2024-10-02" status="g_enriched_approved" xml:lang="en" xml:id="W0073_change_019">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2024-10-02" status="g_enriched_approved" xml:id="W0073_change_018" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2024-10-02" status="g_enriched_approved" xml:id="W0073_change_017" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2024-10-01" status="g_enriched_approved" xml:id="W0073_change_016" xml:lang="en">Post-correction fixes.</change>
                <change who="#CR" when="2024-10-01" status="g_enriched_approved" xml:id="W0073_change_015" xml:lang="en">Manual post-corrections CR.</change>
                <change who="#DG #CR #auto" when="2024-10-01" status="g_enriched_approved" xml:id="W0073_change_014" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2024-09-26" status="g_enriched_approved" xml:id="W0073_change_013" xml:lang="en">Second round of manual corrections CB.</change>
                <change who="#DG #CR #auto" when="2024-05-23" status="g_enriched_approved" xml:id="W0073_change_012" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#MAH" when="2024-05-23" status="g_enriched_approved" xml:id="W0073_change_011" xml:lang="en">First round of manual corrections MAH.</change>
                <change who="#DG #CR #auto" when="2022-10-22" status="f_enriched" xml:id="W0073_change_010" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2022-10-22" status="f_enriched" xml:id="W0073_change_009" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2022-10-27" status="f_enriched" xml:id="W0073_change_008" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2022-10-27" status="f_enriched" xml:id="W0073_change_007" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2022-10-26" status="f_enriched" xml:id="W0073_change_006" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2022-10-26" status="f_enriched" xml:lang="en" xml:id="W0073_change_005">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2022-10-26" status="a_raw" xml:lang="en" xml:id="W0073_change_004">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2022-10-20" status="a_raw" xml:lang="en" xml:id="W0073_change_003">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR" when="2022-10-04" status="a_raw" xml:lang="en" xml:id="W0073_change_002">Structural annotation.</change>
                <change who="#CR" when="2020-05-11" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>