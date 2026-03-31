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
                <title type="short" level="m">Tractatus De Legibus</title>
                <title type="main" level="m">R. Patris Ioan. De Salas, Gvmielensis, E[x] Provincia Castellana, 
                    Societatis Iesv, Tractatus De Legibvs, In Secvndam Secvndæ S. Thomæ</title>
                <author>
                    <persName ref="author:A0077 gnd:119442523 cerl:cnp01162170" key="Salas, Juan de">
                        <forename>Johannes</forename>
                        <nameLink>de</nameLink>
                        <surname>Salas</surname>
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
                <editor xml:id="IC" role="#technical">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="MT" role="#technical">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname>Thönes</surname>, <forename>Martin</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0092-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2024-09-03">2024-09-03</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2024-09-03">2024-09-03</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0092</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0092?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0092?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0092?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0092?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0092?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0092?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="35"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0077 gnd:119442523 cerl:cnp01162170" key="Salas, Juan de">
                                <forename>Johannes</forename>
                                <nameLink>de</nameLink>
                                <surname>Salas</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Tractatus De Legibus</title>
                        <title type="main" level="m">R. Patris Ioan. De Salas, Gvmielensis, E[x] Provincia Castellana, 
                            Societatis Iesv, Tractatus De Legibvs, In Secvndam Secvndæ S. Thomæ</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1611">1611</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037609670 cerl:cnp01876548" key="Gabiano, Jean de">
                                    <forename>Ioannis</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Gabiano</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">12 ungezählte Seiten, 632 Seiten, 98 ungezählte Seiten</extent>
                        <extent xml:lang="en">[12] p., 632 p., [98] p.</extent>
                        <extent xml:lang="es">[12] p., 632 p., [98] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:5036103-X" xml:lang="de">Staatsbibliothek zu Berlin</repository>
                        <idno type="catlink" xml:lang="de">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=778486346</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#facs:W0092-0152 #facs:W0092-0177 #facs:W0092-0224 #facs:W0092-0229 #facs:W0092-0257 #facs:W0092-0282 #facs:W0092-0285 #facs:W0092-0288 #facs:W0092-0302 #facs:W0092-0421 #facs:W0092-0614 #facs:W0092-0625">
                    <msIdentifier>
                        <repository ref="gnd:7721988-0" xml:lang="en">Google Books</repository>
                        <idno type="catlink" xml:lang="de">https://books.google.de/books?id=J1Nx4onJqSgC&amp;dq=Salas%2C%20Juan%20de&amp;hl=de&amp;pg=PA136#v=onepage&amp;q=Salas,%20Juan%20de&amp;f=false</idno>
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
                <p xml:id="W0092_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2024-10-15" status="g_enriched_approved" xml:id="W0092_change_023" xml:lang="en">teiHeader update: added p xml:id="W0092_AEW".</change>
                <change who="#CR #auto" when="2024-09-03" status="g_enriched_approved" xml:id="W0092_change_022" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2024-09-03" status="f_enriched" xml:id="W0092_change_021" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2024-09-03" status="f_enriched" xml:id="W0092_change_020" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2024-09-03" status="f_enriched" xml:id="W0092_change_019" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-07-01" status="f_enriched" xml:id="W0092_change_018" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-07-01" status="f_enriched" xml:id="W0092_change_017" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-07-01" status="f_enriched" xml:id="W0092_change_016" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-06-26" status="f_enriched" xml:lang="en" xml:id="W0092_change_015">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-06-26" status="f_enriched" xml:id="W0092_change_014" xml:lang="en">Annotated hyphenated breaks interrupted by hi and note.</change>
                <change who="#DG #CR #auto" when="2020-06-26" status="f_enriched" xml:lang="en" xml:id="W0092_change_013">Annotated hyphenated breaks.</change>
                <change who="#CB" when="2024-08-07" status="g_enriched_approved" xml:lang="en">Resolution remaining 40 unclear marks (CB).</change>
                <change who="#DG #CR #auto" when="2020-06-24" status="a_raw" xml:lang="en" xml:id="W0092_change_012">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2021-10-12" status="a_raw" xml:lang="en" xml:id="W0092_change_011">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2020-06-26" status="a_raw" xml:lang="en" xml:id="W0092_change_010">Changed notes with only digits into milestone, and added @unit.</change>
                <change who="#CR #auto" when="2020-06-19" status="a_raw" xml:lang="en" xml:id="W0092_change_009">Added missing pagination.</change>
                <change who="#CR #auto" when="2020-06-15" status="a_raw" xml:lang="en" xml:id="W0092_change_008">Added @n, @type, @xml:id to div(s) and @target to ref.</change>
                <change who="#CR" when="2020-06-09" status="a_raw" xml:lang="en" xml:id="W0092_change_007">Structural annotation.</change>
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