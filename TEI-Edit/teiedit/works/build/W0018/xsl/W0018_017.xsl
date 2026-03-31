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
                <title type="short" level="m">Tractado de los préstamos.</title>
                <title type="main" level="m">Tractado en que a la clara ſe ponen y determinan las materias delos p[r]estamos que ſe vſan entre los que tractan y negocian: y de los logros [y] co[mpr]as adelantadas y ventas al fiado. [e]tc. </title>
                <author>
                    <persName ref="author:A0003 cerl:cnp00099755 viaf:169431628 gnd:100007112" key="Alcalá, Luis de" full="yes">
                        <forename full="yes">Luis</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Alcalá</surname>
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
                <edition n="1.0.0" xml:id="W0018-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2022-01-27">2022-01-27</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2022-01-27">2022-01-27</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0018</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0018?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0018?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0018?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0018?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0018?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0018?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="25"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0003 cerl:cnp00099755 viaf:169431628 gnd:100007112" key="Alcalá, Luis de" full="yes">
                                <forename full="yes">Luis</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Alcalá</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Tractado de los préstamos.</title>
                        <title type="main" level="m">Tractado en que a la clara ſe ponen y determinan las materias delos p[r]estamos que ſe vſan entre los que tractan y negocian: y de los logros [y] co[mpr]as adelantadas y ventas al fiado. [e]tc. </title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008719" key="Toledo">Toledo</pubPlace>
                            <date type="firstEd" when="1543">1543</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00007995 viaf:66518925 gnd:1077518854" key="Ayala, Juan de" full="yes">
                                    <forename full="yes">Juan</forename>
                                    <nameLink>de</nameLink>
                                    <surname full="yes">Ayala</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">8 ungezählte Seiten, xxx Blätter</extent>
                        <extent xml:lang="en">[8], xxx l.</extent>
                        <extent xml:lang="es">[8], xxx h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://gredos.usal.es/handle/10366/48766</idno>
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
                <change who="#CR #auto" when="2022-01-27" status="g_enriched_approved" xml:lang="en" xml:id="W0018_change_021">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2021-10-01" status="g_enriched_approved" xml:lang="en" xml:id="W0018_change_020">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2021-10-01" status="g_enriched_approved" xml:id="W0018_change_019" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2021-10-01" status="g_enriched_approved" xml:id="W0018_change_018" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2021-09-30" status="g_enriched_approved" xml:id="W0018_change_017" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2021-09-30" status="g_enriched_approved" xml:id="W0018_change_016" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2021-09-30" status="g_enriched_approved" xml:lang="en" xml:id="W0018_change_015">Second round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2021-09-21" status="g_enriched_approved" xml:id="W0018_change_014" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2021-09-29" status="g_enriched_approved" xml:lang="en" xml:id="W0018_change_013">First round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="f_enriched" xml:id="W0018_change_012" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="f_enriched" xml:id="W0018_change_011" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="f_enriched" xml:id="W0018_change_010" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="f_enriched" xml:id="W0018_change_009" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="c_hyph_proposed" xml:id="W0018_change_008" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="c_hyph_proposed" xml:lang="en" xml:id="W0018_change_007">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-12-23" status="a_raw" xml:lang="en" xml:id="W0018_change_006">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2020-05-06" status="a_raw" xml:lang="en" xml:id="W0018_change_005">Added (es) abbreviations depending on word endings with regex.</change>
                <change who="#CR #DG" when="2020-12-23" status="a_raw" xml:lang="en" xml:id="W0018_change_004">Added @type to list, @rend to note, @unit and @xml:ids to milestone.</change>
                <change who="#CR" when="2020-12-21" status="a_raw" xml:lang="en" xml:id="W0018_change_003">Structural annotation.</change>
                <change who="#CR" when="2020-04-21" status="a_raw" xml:lang="en" xml:id="W0018_change_002">Set teiHeader.</change>
                <change who="#CB" when="2019-10-02" status="a_raw" xml:lang="en" xml:id="W0018_change_001">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>