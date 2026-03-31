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
            <xsl:text>&#xa;</xsl:text>
            <xsl:processing-instruction name="svsal">htmlFragmentationDepth="4"</xsl:processing-instruction>
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
                <title type="short" level="m">Confessionario</title>
                <title type="main" level="m">Confessionario vtil y prouechoso</title>
                <author>
                    <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key=" Vitoria, Francisco de">
                        <forename>Francisco</forename>
                        <nameLink>de</nameLink>
                        <surname>Vitoria</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                
                <editor xml:id="JLE" role="#scholarly">
                    <persName ref="orcid:0000-0002-9256-8490">
                        <surname>Egío García</surname>, <forename>José Luis</forename>
                    </persName>
                </editor>

                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="IC" role="#technical">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0015-v1.0.0" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2018-05-09">2018-05-09</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                    <xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></publisher>
                    </xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2018-05-09">2018-05-09</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0015</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0015?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0015?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0015?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0015?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0015?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0015?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="1" xml:lang="en">Volume 1</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key=" Vitoria, Francisco de">
                                <forename>Francisco</forename>
                                <nameLink>de</nameLink>
                                <surname>Vitoria</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Confessionario</title>
                        <title type="main" level="m">Confessionario vtil y prouechoso</title>
                        
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008643" key="Santiago de Compostela">Santiago</pubPlace>
                            <date type="firstEd" when="1562">1562</date>
                            <publisher n="firstEd">
                                <persName>
                                    <surname>[s.n.]</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">24 ungezählte Blätter ; 8°</extent>
                        <extent xml:lang="en">[24] l. ; 8°</extent>
                        <extent xml:lang="es">[24] h. ; 8°</extent>
                    </monogr>
                </biblStruct>
                <msDesc type="main">
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">http://brumario.usal.es/record=b1699003~S6*spi</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc type="additional" corresp="#facs:W0015-0037 #facs:W0015-0038">
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" subtype="main" xml:lang="en">http://hdl.handle.net/10366/19465</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="rotunda" xml:lang="en">Rotunda typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        
        <profileDesc>
           <langUsage>
              <language ident="es" usage="100" n="main" xml:lang="en">Spanish</language>
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
                <change who="#CR #auto" when="2020-09-22" status="g_enriched_approved" xml:id="W0015_change_026" xml:lang="en">teiHeader update. Repository permalink update.</change>
                <change who="#CR #auto" when="2019-10-25" status="g_enriched_approved" xml:id="W0015_change_025" xml:lang="en">teiHeader update. Rearranged editor(s) sequece and @role #additional.</change>
                <change who="#DG #CR #auto" when="2019-09-25" status="g_enriched_approved" xml:id="W0015_change_024" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-09-25" status="g_enriched_approved" xml:id="W0015_change_023" xml:lang="en">Numbered lines.</change>
                <change who="#CR" when="2019-09-17" status="g_enriched_approved" xml:lang="en">Structural annotation update.</change>
                <change who="#DG #CR #auto" when="2019-08-08" status="g_enriched_approved" xml:lang="en">Revised teiHeader, update @role in editor.</change>
                <change who="#DG" when="2018-12-10" status="g_enriched_approved" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="g_enriched_approved" xml:lang="en">Revision of teiHeader.</change>
                <change who="#DG" when="2018-07-09" status="g_enriched_approved" xml:lang="en">Generate new @xml:id.</change>
                <change who="#DG" when="2018-07-09" status="g_enriched_approved" xml:lang="en">Further annotated title page.</change>
                <change who="#DG" when="2018-07-06" status="g_enriched_approved" xml:lang="en">Technical fixes with special characters.</change>
                <change who="#JLE #DG" when="2018-07-06" status="g_enriched_approved" xml:lang="en">Transcribed, annotated, and inserted missing pages [38] and [39].</change>
                <change who="#AW" when="2018-06-20" status="g_enriched_approved" xml:lang="en">Some corrections.</change>
                <change who="#AW" when="2018-05-16" status="g_enriched_approved" xml:lang="en">Add formats to notesStmt.</change>
                <change who="#AW" when="2018-05-09" status="g_enriched_approved" xml:lang="en">Fixes in special characters.</change>
                <change who="#DG" when="2018-05-08" status="g_enriched_approved" xml:lang="en">Update @xml:id within TEI/text.</change>
                <change who="#DG" when="2018-05-07" status="f_enriched" xml:lang="en">Update status labels; 
                                                                        annotate title page; 
                                                                        annotate cross-references in first table of contents;
                                                                        state original (Spanish) name of digitization institution.</change>
                <change who="#AW" when="2018-05-02" status="f_enriched" xml:lang="en">Add #DG to editors.</change>
                <change who="#AW" when="2018-02-22" status="f_enriched" xml:lang="en">Fixed linebreaks and a few special z-characters.</change>
                <change who="#AW" when="2018-02-21" status="f_enriched" xml:lang="de">Anpassung des Revisions-Status</change>
                <change who="#CB" when="2018-02-10" status="e_emended_unenriched" xml:lang="de">Korrekturen, Expansionen</change>
                <change who="#IC" when="2015-09-29" status="c_hyph_proposed" xml:lang="de">Anpassung der Paginierung im n-Attribut</change>
                <change who="#AW" when="2015-07-02" status="c_hyph_proposed" xml:lang="de">Import des Trierer Haupttextes, Auflösung von Unsicherheitsmarkierungen, Struktur-Markup, Transformation in Sal-TEI</change>
                <change who="#IC" when="2014-11-27" status="e_emended_unenriched" xml:lang="en">revision of teiHeader</change>
                <change who="#IC" when="2014-11-18" status="e_emended_unenriched" xml:lang="de">titleStmt und sourceDesc angepasst</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>