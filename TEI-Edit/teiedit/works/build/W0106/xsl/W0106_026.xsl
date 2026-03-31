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
                <title type="short" level="m">Controversiarum illustrium aliarumque usu frequentium</title>
                <title type="main" level="m">D. Fernandi Vasqvii, Menchacensis Pinciani Hispani Ivreconsvlti
                    In Svmmo Dominicae Rei Philippi Hispaniarvm Regis Cathol. Prætorio, Senatoris : Controversiarvm 
                    Illvstrivm Aliarvmqve Vsv Frequentium Libri Tres</title>
                <author>
                    <persName ref="author:A0093 gnd:118626302 cerl:cnp01240906" key="Vázquez de Menchaca, Fernando" full="yes">
                        <forename full="yes">Fernando</forename>
                        <surname full="yes">Vázquez de Menchaca</surname>
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
                    <persName ref="gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
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
                <edition n="1.0.0" xml:id="W0106-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2022-05-10">2022-05-10</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                				refer to our website.</ref></publisher>
                	</xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2022-05-10">2022-05-10</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0106</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0106?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0106?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0106?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0106?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0106?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0106?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="27"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0093 gnd:118626302 cerl:cnp01240906" key="Vázquez de Menchaca, Fernando" full="yes">
                                <forename full="yes">Fernando</forename>
                                <surname full="yes">Vázquez de Menchaca</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Controversiarum illustrium aliarumque usu frequentium</title>
                        <title type="main" level="m">D. Fernandi Vasqvii, Menchacensis Pinciani Hispani Ivreconsvlti
                            In Svmmo Dominicae Rei Philippi Hispaniarvm Regis Cathol. Prætorio, Senatoris : Controversiarvm 
                            Illvstrivm Aliarvmqve Vsv Frequentium Libri Tres</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7005293" key="Frankfurt/Main">Francofurti</pubPlace>
                            <date type="firstEd" when="1572">1572</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:118683527 cerl:cni00019583" key="Feyerabend, Sigismund" full="yes">
                                    <forename full="yes">Feyerabend</forename>
                                    <surname full="yes">Sigismund</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">8 ungezählte Seiten, 291 Blätter, 32 ungezählte Seiten</extent>
                        <extent xml:lang="en">[8] p., 291, [32] p.</extent>
                        <extent xml:lang="es">[8] p., 291, [32] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2 cerl:cnc00012769" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/search?oclcno=632744479&amp;db=100</idno>
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
				<normalization method="silent">
                   <p xml:id="meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
                      i.e. resolved to <q>s</q>.</p>
                   <p xml:id="facs-renumbered">4 blank pages were deleted (W0106-0400, W0106-0401, W0106-0408, W0106-0409), since they interrupt the text flow in main text.
                      In the original work they appear after Fol.[194]r and Fol.[197]r. Consequently, facsimiles from W0106-0400 on were renamed.</p>
                   <p xml:id="chapter-titles">Chapter titles were rearranged before their summaries to adapt the text to TEI P5. See @change="W0106_change_006".</p>
                   <p xml:id="hyphens">Some words separated by hyphens and marginal references were manually joined during editing.</p>
				   <p xml:id="marginal-notes">In this work each chapter has a summary that leads to numbers in the main text. 
				       These references also had in most cases the same text that appears in the summary lists. 
				       Since these texts were repeated in the margin area, only their numbers were included as references to their summaries.</p>
                </normalization>
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
                <change who="#DG #CR #auto" when="2022-05-10" status="g_enriched_approved" xml:lang="en" xml:id="W0106_change_035">teiHeader update after corrections.</change>
                <change who="#DG #CR #auto" when="2022-05-10" status="g_enriched_approved" xml:lang="en" xml:id="W0106_change_034">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2022-05-10" status="g_enriched_approved" xml:id="W0106_change_033" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2022-05-10" status="g_enriched_approved" xml:id="W0106_change_032" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2022-05-10" status="g_enriched_approved" xml:id="W0106_change_031" xml:lang="en">Post-correction fixes.</change>
                <change who="#CR #auto" when="2022-05-10" status="g_enriched_approved" xml:id="W0106_change_030" xml:lang="en">Transformed note(s) into milestone(s).</change>
                <change who="#DG #auto" when="2022-02-15" status="g_enriched_approved" xml:id="W0106_change_029" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#JLE" when="2022-02-10" status="g_enriched_approved" xml:id="W0106_change_028" xml:lang="en">Second round of corrections JLE.</change>
                <change who="#CR" when="2022-01-13" status="g_enriched_approved" xml:id="W0106_change_027" xml:lang="en">Corrected breaks after marginal notes.</change>
                <change who="#DG #auto" when="2022-01-06" status="g_enriched_approved" xml:id="W0106_change_026" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#JLE" when="2021-12-30" status="g_enriched_approved" xml:id="W0106_change_025" xml:lang="en">First round of corrections JLE.</change>
                <change who="#CR #auto" when="2021-05-28" status="f_enriched" xml:id="W0106_change_024" xml:lang="en">Semi-automatically expanded abbreviations with regex using word suffixes.</change>
                <change who="#DG #CR #auto" when="2021-05-28" status="f_enriched" xml:id="W0106_change_023" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#DG #CR #auto" when="2021-04-28" status="f_enriched" xml:id="W0106_change_022" xml:lang="en">Automatically expanded abbreviations (la-marginal) update.</change>
                <change who="#DG #CR #auto" when="2020-06-09" status="f_enriched" xml:id="W0106_change_021" xml:lang="en">Automatically expanded abbreviations (la-main) update.</change>
                <change who="#DG #CR #auto" when="2019-12-18" status="f_enriched" xml:id="W0106_change_020" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0106_change_019" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0106_change_018" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2019-11-28" status="f_enriched" xml:id="W0106_change_017" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-11-28" status="f_enriched" xml:id="W0106_change_016" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-11-27" status="c_hyph_proposed" xml:lang="en" xml:id="W0106_change_015">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-11-27" status="c_hyph_proposed" xml:id="W0106_change_014" xml:lang="en">Annotated hyphenated breaks interrupted by hi and label.</change>
                <change who="#DG #CR #auto" when="2019-11-27" status="c_hyph_proposed" xml:lang="en" xml:id="W0106_change_013">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" when="2019-11-26" status="a_raw" xml:id="W0106_change_012">Transformation from TEI Tite to TEI All P5.</change>
                <change who="#CR #auto" when="2019-11-26" status="a_raw" xml:id="W0106_change_011">Content and Index in nested lists.</change>
                <change who="#CR #auto" when="2019-11-22" status="a_raw" xml:id="W0106_change_010">Tagged crossed references between summaries and label(s).</change>
                <change who="#CR #auto" when="2019-11-21" status="a_raw" xml:id="W0106_change_009">Tagged label(s).(updated 13.01.22 W0106_change_027, returned to note format.)</change>
                <change who="#CR #auto" when="2019-11-13" status="a_raw" xml:id="W0106_change_008">Added @type to div2.</change>
                <change who="#CR #auto" when="2019-11-13" status="a_raw" xml:id="W0106_change_007">Added missing pagination.</change>
                <change who="#CR" when="2019-11-18" status="a_raw" xml:id="W0106_change_006">Chapter titles were rearranged before their summaries to adapt the text to TEI P5.</change>    
                <change who="#CR" when="2019-11-08" status="a_raw" xml:id="W0106_change_005">Structural annotation start.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2016-08-16" status="a_raw">Neu angelegt</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>