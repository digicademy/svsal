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
                <title type="short" level="m">Relectio de Poenitentia</title>
                <title type="main" level="m">Relectio De Poenitentia Habita In Academia Salmanticensis, Anno M.D.XLVIII.</title>
                <author>
                    <persName ref="author:A0016 gnd:118518844 cerl:cnp01118010" key="Cano, Melchor" full="yes">
                        <forename full="yes">Melchor</forename>
                        <surname full="yes">Cano</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="1.0.0" xml:id="W0030-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2019-07-31">2019-07-31</date>.
               </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                    <xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></publisher>
                    </xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2019-07-31">2019-07-31</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0030</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0030?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0030?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0030?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0030?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0030?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0030?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                        <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="10" xml:lang="en">Volume 10</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0016 gnd:118518844 cerl:cnp01118010" key="Cano, Melchor" full="yes">
                                <forename full="yes">Melchor</forename>
                                <nameLink/>
                                <surname full="yes">Cano</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Relectio de Poenitentia</title>
                        <title type="main" level="m">Relectio De Poenitentia Habita In Academia Salmanticensis, Anno M.D.XLVIII.</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7007139" key="Alcalá de Henares">Compluti</pubPlace>
                            <date type="firstEd" when="1558">1558</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1090682077 cerl:cni00045617" key="Brocar, Juan de" full="yes">
                                    <forename full="yes">Juan</forename>
                                    <nameLink>de</nameLink>
                                    <surname full="yes">Brocar</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">176 Blätter ; 8°.</extent>
                        <extent xml:lang="en">176 l. ; 8°.</extent>
                        <extent xml:lang="es">176 h. ; 8°.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004059190" xml:lang="es">Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://gredos.usal.es/jspui/handle/10366/136985</idno>
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
                <xi:fallback><projectDesc><p xml:id="W0030-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="W0030-00-meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
            </editorialDecl>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="W0030-00-meta-no-0001">The definition of 
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
                <change who="#CR #auto" when="2019-10-25" status="g_enriched_approved" xml:id="W0030_change_041" xml:lang="en">teiHeader update. Rearranged editor(s) sequece and @role #additional.</change>
                <change who="#DG #CR #auto" when="2019-08-08" status="g_enriched_approved" xml:id="W0030_change_040" xml:lang="en">Revised teiHeader, update @role in editor.</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="g_enriched_approved" xml:id="W0030_change_039" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="a_raw" xml:id="W0030_change_038" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="a_raw" xml:id="W0030_change_037" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="g_enriched_approved" xml:id="W0030_change_036" xml:lang="en">changed cit to bibl</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="g_enriched_approved" xml:lang="en" xml:id="W0030_change_030">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="g_enriched_approved" xml:id="W0030_change_031" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2019-07-31" status="g_enriched_approved" xml:id="W0030_change_035" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#CR #DG #auto" when="2019-07-31" status="g_enriched_approved" xml:id="W0030_change_034" xml:lang="en">Post-correction fixes.</change>
                <change who="#CB" when="2019-07-30" status="f_enriched" xml:id="W0030_change_033" xml:lang="en">Text correction.</change>
                <change who="#DG #auto" when="2019-05-22" status="c_hyph_proposed" xml:id="W0030_change_009" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#CR #DG #auto" when="2019-05-16" status="a_raw" xml:id="W0030_change_008" xml:lang="en">Automatically expanded abbreviations (la).</change>
                <change who="#DG #CR #auto" when="2019-04-11" status="a_raw" xml:id="W0030_change_07" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-04-11" status="a_raw" xml:id="W0030_change_06" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-04-11" status="a_raw" xml:lang="en" xml:id="W0030_change_05">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-04-10" status="a_raw" xml:id="W0030_change_005" xml:lang="en">Changed pb, cb attributes dependending on lb break=nos</change>
                <change who="#DG #CR #auto" when="2019-04-10" status="a_raw" xml:id="W0030_change_004" xml:lang="en">Changed lb attributes.</change>
                <change who="#DG #CR #auto" when="2019-04-10" status="a_raw" xml:lang="en" xml:id="W0030-00-change-03">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR" when="2019-04-10" status="a_raw" xml:lang="en" xml:id="W0003_change_0002">Structural Annotation</change>
                <change who="#MT #DG" when="2019-02-27" status="a_raw">Added basic bibliographic metadata.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>