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
                <title type="short" level="m">Apologia pro libro de iustis belli causis</title>
                <title type="main" level="m">Apologia Ioannis Genesij Sepuluedae pro libro de iustis belli causis : ad amplissimum &amp; doctissimum praesulem D. Antonium Ramirum episcopum Segouiensem</title>
                <author>
                    <persName ref="author:A0081 cerl:cnp01877108 viaf:39405614 gnd:118796194" key="Sepúlveda, Juan Ginés de">
                        <forename>Juan Ginés</forename>
                        <nameLink>de</nameLink>
                        <surname>Sepúlveda</surname>
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
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                
            </titleStmt>

            <editionStmt>
               <edition n="1.0.0" xml:id="W0095-v1.0.0" xml:lang="en">
                Complete digitized edition, <date type="digitizedEd" when="2020-01-30">2020-01-30</date>.
               </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2020-01-30"/>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0095</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0095?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0095?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0095?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0095?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0095?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0095?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="12"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0081 cerl:cnp01877108 viaf:39405614 gnd:118796194" key="Sepúlveda, Juan Ginés de">
                                <forename>Juan Ginés</forename>
                                <nameLink>de</nameLink>
                                <surname>Sepúlveda</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Apologia pro libro de iustis belli causis</title>
                        <title type="main" level="m">Apologia Ioannis Genesij Sepuluedae pro libro de iustis belli causis : ad amplissimum &amp; doctissimum praesulem D. Antonium Ramirum episcopum Segouiensem</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7000874" key="Rom">Romae</pubPlace>
                            <date type="firstEd" when="1550">1550</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cnp00559287 viaf:305414737 gnd:119559854" key="Dorico, Valerio">
                                    <forename>Valerio</forename>
                                    <surname>Dorico</surname>
                                </persName>
                                <persName ref="cerl:cnp02082507 viaf:22194470 gnd:1037564960" key="Dorico, Luigi">
                                    <forename>Luigi</forename>
                                    <surname>Dorico</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">47 ungezählte Seiten</extent>
                        <extent xml:lang="en">[47] l.</extent>
                        <extent xml:lang="es">[47] h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004059190" xml:lang="es">Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">http://hdl.handle.net/10366/19474</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua italic typeface</typeNote>
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
                   <p xml:id="meta-pa-0006" xml:lang="en">The work is set entirely in italic font type, with capital letters, numbers, brackets and punctuation marks only in recte. All of these phenomena was not tagged.</p>
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
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:id="W0095_change_019" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:id="W0095_change_018" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:id="W0095_change_017" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:lang="en" xml:id="W0095_change_016">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:id="W0095_change_015" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:id="W0095_change_014" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2020-01-28" status="g_enriched_approved" xml:id="W0095_change_013" xml:lang="en">Post-correction fixes.</change>
                <change who="#CB" when="2020-01-28" status="f_enriched" xml:id="W0095_change_012" xml:lang="en">Post-correction.</change>
                <change who="#CB" when="2020-01-27" status="f_enriched" xml:id="W0095_change_011" xml:lang="en">Text correction.</change>
                <change who="#CR" when="2020-01-14" status="a_raw" xml:lang="en">Set teiHeader.</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="c_hyph_proposed" xml:id="W0095_change_010" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="a_raw" xml:id="W0095_change_009" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="a_raw" xml:id="W0095_change_008" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="a_raw" xml:id="W0095_change_007" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="a_raw" xml:id="W0095_change_006" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="a_raw" xml:lang="en" xml:id="W0095_change_005">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-01-13" status="a_raw" xml:id="W0095_change_004" xml:lang="en">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR" when="2020-01-09" status="a_raw" xml:lang="en">Structural annotation.</change>
                <change who="#MT" when="2019-03-18" status="a_raw">Added basic bibliographic metadata.</change>
                <change who="#CB" when="2014" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>