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
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="teiHeader">
        <xsl:copy-of select="$teiHeader"/>
    </xsl:template>
    
<xsl:variable name="teiHeader" xml:space="preserve">
    <teiHeader xmlns:t="http://www.tei-c.org/ns/tite/1.0" xmlns:tite="http://www.tei-c.org/ns/tite/1.0" xmlns:sal="http://salamanca.adwmainz.de">
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Practica criminalis canonica</title>
                <title type="main" level="m">Ioannis Bernardi Diaz De Lvco, Decretorum Doctoris, Hispani, Episcopi Calagurritani, ac inuictissimi Romanorum Imperatoris, ac Hispaniarum regis Caroli Quinti à consiliis, Practica criminalis canonica, in qua omnia ferè flagitia, quæ à clericis committi possunt, cum eorum pœnis describuntur</title>
                <author>
                    <persName ref="author:A0027 cerl:cnp01324347 viaf:61572063 gnd:120148226" key="Díaz de Luco, Juan Bernardo">
                        <forename>Juan Bernardo</forename>
                        <surname>Díaz de Luco</surname>
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
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0041-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2021-09-29">2021-09-29</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2021-09-29">2021-09-29</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0041</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0041?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0041?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0041?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0041?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0041?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0041?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="24"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0027 cerl:cnp01324347 viaf:61572063 gnd:120148226" key="Díaz de Luco, Juan Bernardo">
                                <forename>Juan Bernardo</forename>
                                <surname>Díaz de Luco</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Practica criminalis canonica</title>
                        <title type="main" level="m">Ioannis Bernardi Diaz De Lvco, Decretorum Doctoris, Hispani, Episcopi Calagurritani, ac inuictissimi Romanorum Imperatoris, ac Hispaniarum regis Caroli Quinti à consiliis, Practica criminalis canonica, in qua omnia ferè flagitia, quæ à clericis committi possunt, cum eorum pœnis describuntur</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1554">1554</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00044778 viaf:100210128 gnd:104181176" key="Rouillé, Guillaume">
                                    <forename>Gulielmum</forename>
                                    <surname>Rouillium</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">347 Seiten, 4 ungezählte Seiten</extent>
                        <extent xml:lang="en">347, [4] p.</extent>
                        <extent xml:lang="es">347, [4] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004773233 viaf:140160251" xml:lang="de">Max-Planck-Institut für Europäische Rechtsgeschichte. Bibliothek.</repository>
                        <idno type="catlink" xml:lang="de">https://sunrise.rg.mpg.de/webOPACClient/start.do?Language=de&amp;KatKeySearch=51988</idno>
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
                <change who="#DG #CR #auto" when="2021-09-28" status="g_enriched_approved" xml:lang="en" xml:id="W0041_change_021">teiHeader update after corrections.</change>
                <change who="#DG #CR #auto" when="2021-09-28" status="g_enriched_approved" xml:lang="en" xml:id="W0041_change_020">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2021-09-28" status="g_enriched_approved" xml:id="W0041_change_019" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2021-09-28" status="g_enriched_approved" xml:id="W0041_change_018" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2021-09-28" status="g_enriched_approved" xml:id="W0041_change_017" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2021-09-28" status="g_enriched_approved" xml:id="W0041_change_016" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2021-09-28" status="g_enriched_approved" xml:lang="en" xml:id="W0041_change_015">Second round of corrections CB.</change>
                <change who="#DG #auto" when="2021-09-24" status="g_enriched_approved" xml:id="W0041_change_014" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2021-09-23" status="g_enriched_approved" xml:lang="en" xml:id="W0041_change_013">First round of corrections CB.</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="f_enriched" xml:id="W0041_change_012" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="f_enriched" xml:id="W0041_change_011" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="f_enriched" xml:id="W0041_change_010" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="f_enriched" xml:id="W0041_change_009" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="c_hyph_proposed" xml:id="W0041_change_008" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="c_hyph_proposed" xml:lang="en" xml:id="W0041_change_007">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-12-29" status="a_raw" xml:lang="en" xml:id="W0041_change_006">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR #auto" when="2021-08-23" status="a_raw" xml:lang="en" xml:id="W0041_change_005">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2020-12-28" status="a_raw" xml:lang="en" xml:id="W0041_change_004">Added @type to div2(s) and list(s).</change>
                <change who="#CR" when="2020-12-28" status="a_raw" xml:lang="en" xml:id="W0041_change_003">Structural annotation.</change>
                <change who="#CR" when="2020-05-07" status="a_raw" xml:lang="en" xml:id="W0041_change_002">Set teiHeader.</change>
                <change who="#AW" when="2019" status="a_raw" xml:lang="en" xml:id="W0041_change_001">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>    
</xsl:stylesheet>