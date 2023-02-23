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
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Reglas Ciertas, Y Precisamente Necessarias Para Ivezes, Y Ministros De Ivsticia de las Indias, y para sus Confessores</title>
                <title type="main" level="m">Reglas Ciertas, Y Precisamente Necessarias Para Ivezes, Y Ministros De Ivsticia de las Indias, y para sus Confessores</title>
                <author>
                    <persName ref="author:A0063 cerl:cnp00140754 viaf:54496756  gnd:100584756" key="Moreno, Gerónymo" full="yes">
                        <forename full="yes">Gerónymo</forename>
                        <surname full="yes">Moreno</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
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
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0076-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2022-11-10">2022-11-10</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2022-11-10">2022-11-10</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0076</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0076?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0076?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0076?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0076?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0076?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0076?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="28"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0063 cerl:cnp00140754 viaf:54496756  gnd:100584756" key="Moreno, Gerónymo" full="yes">
                                <forename full="yes">Gerónymo</forename>
                                <surname full="yes">Moreno</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Reglas Ciertas, Y Precisamente Necessarias Para Ivezes, Y Ministros De Ivsticia de las Indias, y para sus Confessores</title>
                        <title type="main" level="m">Reglas Ciertas, Y Precisamente Necessarias Para Ivezes, Y Ministros De Ivsticia de las Indias, y para sus Confessores</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7005560" key="Mexico">Mexico</pubPlace>
                            <date type="firstEd" when="1637">1637</date>
                            <publisher n="firstEd">
                                <persName ref=" cerl:cni00076174 viaf:304943188 gnd:1037509609" key="Salbago, Francisco" full="yes">
                                    <forename full="yes">Francisco</forename>
                                    <surname full="yes">Salbago</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 59 Blätter</extent>
                        <extent xml:lang="en">[16], 59 l.</extent>
                        <extent xml:lang="es">[16], 59 h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc status="draft">
                    <msIdentifier>
                        <repository ref="gnd:10193139-6" xml:lang="en">Linga-Bibliothek der Freien und Hansestadt Hamburg</repository>
                        <idno type="catlink" xml:lang="en">https://kataloge.uni-hamburg.de/DB=1.23/XMLPRS=N/PPN?PPN=577250124</idno>
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
                <change who="#CR #auto" when="2022-11-10" status="g_enriched_approved" xml:lang="en" xml:id="W0018_change_023">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2022-11-10" status="g_enriched_approved" xml:lang="en" xml:id="W0076_change_022">Tagged special characters after corrections.</change>
                <change who="#CR #DG #auto" when="2022-11-10" status="g_enriched_approved" xml:id="W0076_change_021" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2022-11-10" status="g_enriched_approved" xml:id="W0076_change_020" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#CR #DG #auto" when="2022-11-10" status="g_enriched_approved" xml:id="W0076_change_019" xml:lang="en">Post-correction fixes.</change>
                <change who="#CR" when="2022-11-10" status="g_enriched_approved" xml:id="W0076_change_018" xml:lang="en">Manual post-correction fixes (CR).</change>
                <change who="#CR #DG #auto" when="2022-11-10" status="g_enriched_approved" xml:id="W0076_change_017" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2022-11-09" status="g_enriched_approved" xml:id="W0076_change_016" xml:lang="en">Second round of manual corrections (CB).</change>
                <change who="#DG #CR #auto" when="2022-11-09" status="g_enriched_approved" xml:id="W0076_change_015" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2022-11-08" status="g_enriched_approved" xml:id="W0076_change_014" xml:lang="en">First round of manual corrections (CB).</change>
                <change who="#DG #CR #auto" when="2022-05-12" status="f_enriched" xml:id="W0076_change_013" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2022-05-12" status="f_enriched" xml:id="W0076_change_012" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2022-05-12" status="f_enriched" xml:id="W0076_change_011" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2022-05-12" status="f_enriched" xml:id="W0076_change_010" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2022-05-12" status="f_enriched" xml:id="W0076_change_009" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2022-05-04" status="c_hyph_proposed" xml:id="W0076_change_008" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2022-05-04" status="c_hyph_proposed" xml:lang="en" xml:id="W0076_change_007">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2022-05-04" status="a_raw" xml:lang="en">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2022-05-04" status="a_raw" xml:lang="en" xml:id="W0076_change_005">Added (es) abbreviations depending on word structure with regex.</change>
                <change who="#CR" when="2022-05-04" status="a_raw" xml:lang="en" xml:id="W0076_change_004">Added @type, @n to div2, div3.</change>
                <change who="#CR" when="2022-05-04" status="a_raw" xml:lang="en" xml:id="W0076_change_003">Structural annotation.</change>
                <change who="#CR" when="2020-03-26" status="a_raw" xml:lang="en" xml:id="W0076_change_002">Set teiHeader.</change>
                <change who="#AW" when="2020-03-14" status="a_raw" xml:lang="en" xml:id="W0076_change_001">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
</xsl:stylesheet>