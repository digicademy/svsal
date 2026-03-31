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
    <xsl:variable name="teiHeader" xml:space="preserve"><xsl:copy-of select="preceding-sibling::processing-instruction('htmlFragmentationDepth')[1]"></xsl:copy-of><teiHeader>        
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Summula Caietani</title>
                <title type="main" level="m">Summa caietana de p[e]c[ca]tis</title>
                <author>
                    <persName ref="author:A0023 gnd:119859564 cerl:cnp01319958" key="Vio, Tommaso de">
                        <forename>Thomas</forename>
                        <nameLink>de</nameLink>
                        <surname>Vio Caietanus</surname>
                    </persName>
                </author>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
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
                <editor xml:id="CB" role="#additional">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="IC" role="#technical">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#additional">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0114-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2024-04-09">2024-04-09</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2024-04-09">2024-04-09</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0114</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0114?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0114?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0114?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0114?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0114?format=txt&amp;mode=orig</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="30"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0023 gnd:119859564 cerl:cnp01319958" key="Vio, Tommaso de">
                                <forename>Tommaso</forename>
                                <nameLink>de</nameLink>
                                <surname>Vio</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Summula Caietani</title>
                        <title type="main" level="m">Summa caietana de p[e]c[ca]tis</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7000874" key="Roma">Rome</pubPlace>
                            <date type="firstEd" when="1525">1525</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00021783" key="Silber, Marcellus">
                                    <forename>Marcellus</forename>
                                    <surname>Silber</surname>
                                </persName>
                                <persName ref="cerl:cni00081548" key="Giunta, Jacques">
                                    <forename>Jacques</forename>
                                    <surname>Giunta</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 242 Blätter</extent>
                        <extent xml:lang="en">[16], 242 l.</extent>
                        <extent xml:lang="es">[16], 242 h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:5036103-X" xml:lang="en">Staatsbibliothek zu Berlin</repository>
                        <idno type="catlink" xml:lang="de">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=77622347X</idno>
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
                <normalization>
                   <p xml:id="meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
                <p xml:id="W0114_RW">Reference works contain automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                   Abbreviations are coded as they appear in the original.</p>
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
            <listChange>
                <change who="#CR #auto" when="2024-04-09" status="g_enriched_approved" xml:id="W0114_change_019" xml:lang="en">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2019-10-30" status="f_enriched" xml:id="W0114_change_018" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-10-29" status="f_enriched" xml:id="W0114_change_017" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-10-29" status="f_enriched" xml:id="W0114_change_016" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-10-29" status="c_hyph_proposed" xml:lang="en" xml:id="W0114_change_015">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-10-28" status="c_hyph_proposed" xml:lang="en" xml:id="W0114_change_014">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" when="2019-10-25" status="a_raw" xml:lang="en" xml:id="W0114_change_013">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR #auto" when="2021-10-07" status="a_raw" xml:lang="en" xml:id="W0114_change_012">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2020-03-31" status="a_raw" xml:lang="en" xml:id="W0114_change_011">Transformed label into head.</change>
                <change who="#CR #auto" when="2019-10-23" status="a_raw" xml:lang="en" xml:id="W0114_change_010">Added @type, @xml:id to div(s) and @target to ref(s).</change>
                <change who="#CR #auto" when="2019-10-21" status="a_raw" xml:lang="en" xml:id="W0114_change_009">Transformed hi(s) @rend.</change>
                <change who="#CR #auto" when="2019-10-21" status="a_raw" xml:lang="en" xml:id="W0114_change_008">Added missing pagination @n in pb.</change>
                <change who="#CR" when="2019-10-18" status="a_raw" xml:lang="en" xml:id="W0114_change_007">Structural Annotation.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2015-08-28" status="a_raw">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-25" status="a_raw">Neu angelegt</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>    
</xsl:stylesheet>