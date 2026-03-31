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
    <teiHeader xmlns:t="http://www.tei-c.org/ns/tite/1.0" xmlns:tite="http://www.tei-c.org/ns/tite/1.0" xmlns:sal="http://salamanca.adwmainz.de">
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Summa de casos de consciencia</title>
                <title type="main" level="m">Summa de casos de consciencia</title>
                <author>
                    <persName ref="author:A0069 cerl:cnp02179962 viaf:36035482 gnd:/119097052" key="Pedraza, Juan de" full="yes">
                        <forename full="yes">Juan</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Pedraza</surname>
                    </persName>
                </author>
                
                <editor xml:id="JLE" role="#scholarly">
                    <persName ref="orcid:0000-0002-9256-8490" full="yes">
                        <surname full="yes">Egío García</surname>, <forename full="yes">José Luis</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                
                <editor xml:id="CB" role="#technical">
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0083-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2021-05-03">2021-05-03</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2021-05-03">2021-05-03</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0083</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0083?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0083?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0083?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0083?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0083?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0083?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="23"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0069 cerl:cnp02179962 viaf:36035482 gnd:/119097052" key="Pedraza, Juan de" full="yes">
                                <forename full="yes">Juan</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Pedraza</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Summa de casos de consciencia</title>
                        <title type="main" level="m">Summa de casos de consciencia</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008033" key="Medina del Campo">Medina del Campo</pubPlace>
                            <date type="firstEd" when="1568">1568</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00045649 viaf:14828413" key="Canto, Francisco del" full="yes">
                                    <forename full="yes">Francisco</forename>
                                    <nameLink>del</nameLink>
                                    <surname full="yes">Canto</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">151 Blätter, 1 ungezähltes Blatt</extent>
                        <extent xml:lang="en">151, [1] l. ; Fol.</extent>
                        <extent xml:lang="es">151, [1] h. ; Fol.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1vo1p7h/alma991005481459705773</idno>
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
                <change who="#DG #CR #auto" when="2021-05-03" status="g_enriched_approved" xml:lang="en" xml:id="W0083_change_021">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2021-05-03" status="g_enriched_approved" xml:lang="en" xml:id="W0083_change_020">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2021-05-03" status="g_enriched_approved" xml:id="W0083_change_019" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2021-05-03" status="g_enriched_approved" xml:id="W0083_change_018" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2021-04-30" status="g_enriched_approved" xml:id="W0083_change_017" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #auto" when="2021-04-30" status="g_enriched_approved" xml:id="W0083_change_016" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#JLE" when="2021-04-29" status="g_enriched_approved" xml:id="W0083_change_015" xml:lang="en">Second round of corrections (JLE).</change>
                <change who="#DG #CR #auto" when="2021-04-26" status="g_enriched_approved" xml:id="W0083_change_014" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#JLE" when="2021-04-26" status="g_enriched_approved" xml:id="W0083_change_013" xml:lang="en">First round of corrections (JLE).</change>
                <change who="#DG #CR #auto" when="2020-10-21" status="f_enriched" xml:id="W0083_change_011" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2020-10-15" status="f_enriched" xml:id="W0083_change_010" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2020-10-15" status="f_enriched" xml:id="W0083_change_009" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-10-15" status="f_enriched" xml:id="W0083_change_008" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-10-15" status="c_hyph_proposed" xml:lang="en" xml:id="W0083_change_007">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-10-15" status="c_hyph_proposed" xml:id="W0083_change_006" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR #auto" when="2020-10-21" status="c_hyph_proposed" xml:lang="en" xml:id="W0083_change_012">Added (es) abbreviations depending on word endings with regex.</change>
                <change who="#DG #CR #auto" when="2020-10-15" status="a_raw" xml:lang="en" xml:id="W0083_change_005">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2020-10-13" status="a_raw" xml:lang="en" xml:id="W0083_change_004">Added @type, @n, @xml:id to div(s) and @target to ref in toc.</change>
                <change who="#CR" when="2020-10-13" status="a_raw" xml:lang="en" xml:id="W0083_change_003">Structural annotation.</change>
                <change who="#CR" when="2020-01-16" status="a_raw" xml:lang="en" xml:id="W0083_change_002">Set teiHeader.</change>
                <change who="#CB" when="2019" status="a_raw" xml:lang="en" xml:id="W0083_change_001">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>