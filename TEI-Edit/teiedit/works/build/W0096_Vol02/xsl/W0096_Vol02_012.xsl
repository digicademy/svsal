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
    
<!-- TODO :the character ` should be suppressed ! -->
    
<xsl:variable name="teiHeader" xml:space="preserve">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">De Indiarum Iure, Vol. 2</title>
                <title type="main" level="m">D. Philip. IV. Hisp. Etind. Regiopt. Max Ioannes De Solorzano Pereira I.V.D. Ex Primarijs olim Academiae Salmanticensis Antecessoribus. Postea Limensis Praetorij in Peruano Regno Novi Orbis Senator: Deinde vero supremo Indiarum Consilio Regij Fisci Patronus et nunc Consiliarius.</title>
                <title type="volume" level="m" n="2">Tomum Alterum</title>
                <author>
                    <persName ref="author:A0082 gnd:118837389 cerl:cnp01341312" key="Solórzano Pereira, Juan de" full="yes">
                        <forename full="yes">Juan</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Solórzano Pereira</surname>
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
                <editor xml:id="MAH" role="#technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                
            </titleStmt>
            <editionStmt>
               <edition n="1.0.0" xml:id="W0096_Vol02-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2024-08-22">2024-08-22</date>.
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
            	<date type="digitizedEd" when="2024-08-22">2024-08-22</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0096:vol2</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0096:vol2?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0096:vol2?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0096:vol2?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0096:vol2?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0096:vol2?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0096:vol2?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="22.2">Volume 22.2</biblScope>
            </seriesStmt>
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0096"/>
            </notesStmt>
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0082 gnd:118837389 cerl:cnp01341312" key="Solórzano Pereira, Juan de" full="yes">
                                <forename full="yes">Juan</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Solórzano Pereira</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Indiarum Iure, Vol. 2</title>
                        <title type="main" level="m">D. Philip. IV. Hisp. Etind. Regiopt. Max Ioannes De Solorzano Pereira I.V.D. Ex Primarijs olim Academiae Salmanticensis Antecessoribus. Postea Limensis Praetorij in Peruano Regno Novi Orbis Senator: Deinde vero supremo Indiarum Consilio Regij Fisci Patronus et nunc Consiliarius.</title>
                        <title type="volume" level="m" n="2">Tomum Alterum</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010413" key="Madrid">Matriti</pubPlace>
                            <date type="firstEd" when="1639">1639</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00025919" key="Martinez, Francisco" full="yes">
                                    <forename full="yes">Francisco</forename>
                                    <surname full="yes">Martinez</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">57 ungezählte Seiten, 1076 Seiten, 133 ungezählte Seiten</extent>
                        <extent xml:lang="en">[57], 1076, [133] p.</extent>
                        <extent xml:lang="es">[57], 1076, [133] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">http://hdl.handle.net/10366/48284</idno>
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
              <language ident="es" n="administrative" xml:lang="en">Español</language>
           </langUsage>
        </profileDesc>
      
        <encodingDesc>
            <xi:include href="../meta/W_Head_general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <p xml:id="W0096_Vol02_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                   Abbreviations are partially resolved.</p>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/Sonderzeichen.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/Sonderzeichen.xml">project website</ref>.</note></char></charDecl>
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
                <change who="#CR #auto" when="2024-10-15" status="g_enriched_approved" xml:id="W0096_Vol02_change_019" xml:lang="en">teiHeader update: added p xml:id="W0096_Vol02_AEW".</change>
                <change who="#CR #auto" when="2024-08-22" status="a_raw" xml:id="W0096_Vol02_change_018" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#CR #auto" when="2024-08-22" status="f_enriched" xml:id="W0096_Vol02_change_017" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0096_Vol02_change_0016" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0096_Vol02_change_0015" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#CR #DG #auto" when="2024-08-20" status="f_enriched" xml:id="W0096_Vol02_change_0014" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-02-05" status="f_enriched" xml:id="W0096_Vol02_change_0013" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-02-05" status="f_enriched" xml:id="W0096_Vol02_change_0012" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2018-12-12" status="f_enriched" xml:lang="en" xml:id="W0096_Vol02_change_0011">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2018-11-12" status="f_enriched" xml:id="W0096_Vol02_change_0010" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR" when="2018-12-12" status="a_raw" xml:id="W0096_Vol02-00-change-0009">Chapter titles were rearranged before summaries to adapt the text to TEI.</change>
                <change who="#CR #auto" when="2018-12-11" status="a_raw" xml:lang="en" xml:id="W0096_Vol02-00-change-0008">Transformation from Tite to TEI.</change>
                <change who="#DG #CR #auto" when="2018-12-10" status="a_raw" xml:id="W0096_Vol02-00-change-0007">Added references between milestones and summaries.</change>
                <change who="#DG #CR #auto" when="2018-12-10" status="a_raw" xml:id="W0096_Vol02-00-change-0006">Added @xml:id, @unit to milestone and @n to div2.</change>
                <change who="#CR #auto" when="2024-08-07" status="a_raw" xml:id="W0096_Vol02-00-change-0005">Added (es) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2024-08-07" status="a_raw" xml:id="W0096_Vol02-00-change-0004">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2024-08-08" status="a_raw" xml:id="W0096_Vol02-00-change-0003">Added foreign ES.</change>
                <change who="#CB" when="2024-08-08" status="g_enriched_approved" xml:id="W0096_Vol02-00-change-0002">Resolved remaining unclear marks.</change>
                <change who="#CR" when="2018-12-05" status="a_raw" xml:id="W0096_Vol02-00-change-0001">Structural annotation.</change>
                <change who="#CB" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>