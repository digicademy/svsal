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
                
                <title type="short" level="m">Politica Indiana</title>
                <title type="main" level="m">Politica Indiana</title>
                <author>
                    <persName ref="author:A0082 gnd:118837389 cerl:cnp01240087" key="Solórzano Pereira, Juan de">
                        <forename>Juan</forename>
                        <nameLink>de</nameLink>
                        <surname>Solórzano Pereira</surname>
                    </persName>
                </author>
                <editor role="scholarly" xml:id="CB">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="AW">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="IC">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="MT">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="1.0.0" xml:id="W0010-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2019-05-15">2019-05-15</date>.
               </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2019-05-15">2019-05-15</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0010</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0010?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0010?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0010?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0010?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0010?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0010?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="8" xml:lang="en">Volume 8</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0082 gnd:118837389 cerl:cnp01240087" key="Solórzano Pereira, Juan de">
                                <forename>Juan</forename>
                                <nameLink>de</nameLink>
                                <surname>Solórzano Pereira</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Politica Indiana</title>
                        <title type="main" level="m">Politica Indiana</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010413" key="Madrid">Madrid</pubPlace>
                            <date type="firstEd" when="1648">1648</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037561783 cerl:cni00031194" key="Diaz de la Carrera, Diego">
                                    <forename>Diego</forename>
                                    <surname>Diaz de la Carrera</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">44 ungezählte Seiten, 1040 Seiten, 104 ungezählte Seiten, 1 ungezähltes Blatt ; 4°</extent>
                        <extent xml:lang="en">[44], 1040, [104] p., [1] l. ; 4°</extent>
                        <extent xml:lang="es">[44], 1040, [104] p., [1] h. ; 4°</extent>
                    </monogr>
                </biblStruct>
                <msDesc type="main">
                    <msIdentifier>
                        <repository ref="gnd:2019144-3" xml:lang="de">Max-Planck-Institut für Europäische Rechtsgeschichte</repository>
                        <idno>
                            <idno type="catlink" xml:lang="de">http://sunrise.rg.mpg.de/webOPACClient/start.do?KatKeySearch=540392</idno>
                            <idno type="catlink" xml:lang="en">https://sunrise.rg.mpg.de/webOPACClient/start.do?KatKeySearch=540392&amp;Language=en</idno>
                        </idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1027025-5" xml:lang="es" corresp="#facs:W0010-0725 #facs:W0010-0726 #facs:W0010-0727 #facs:W0010-0728">Biblioteca Nacional de España</repository>
                        <idno type="catlink">http://bdh.bne.es/bnesearch/detalle/bdh0000134097</idno>
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
               <language ident="la" n="marginal" xml:lang="en">Latin</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/works-general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="W0010-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="W0010-00-meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <normalization>
                   <p xml:id="W0010-00-meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
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
            <listChange>
                <change who="#DG #auto" when="2019-05-13" status="g_enriched_approved" xml:id="W0010_change_047" xml:lang="en">Revised teiHeader.</change>
                <change who="#DG #auto" when="2019-05-13" status="g_enriched_approved" xml:id="W0010_change_046" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #auto" when="2019-05-13" status="g_enriched_approved" xml:id="W0010_change_045" xml:lang="en">Numbered lines.</change>
                <change who="#DG #auto" when="2019-05-13" status="g_enriched_approved" xml:lang="en" xml:id="W0010_change_044">Tagged special characters.</change>
                <change who="#DG #auto" when="2019-05-10" status="g_enriched_approved" xml:id="W0010_change_043" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #auto" when="2019-05-10" status="g_enriched_approved" xml:id="W0010_change_042" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #auto" when="2019-05-06" status="g_enriched_approved" xml:id="W0010_change_041" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #auto" when="2019-05-06" status="g_enriched_approved" xml:id="W0010_change_040" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2019-05-06" status="g_enriched_approved" xml:id="W0010_change_039" xml:lang="en">List-based cross check.</change>
                <change who="#DG" when="2019-04-24" status="f_enriched" xml:id="W0010_change_038" xml:lang="en">Added Latin as language in marginals, and updated status.</change>
                <change who="#CB" when="2019-04-24" status="f_enriched" xml:id="W0010_change_037" xml:lang="en">Corrections, editings and semantic annotations.</change>
                <change who="#DG #auto" when="2019-04-08" status="e_emended_unenriched" xml:id="W0010_change_036" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #auto" when="2019-04-08" status="e_emended_unenriched" xml:id="W0010_change_035" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#CB" when="2019-04-08" status="e_emended_unenriched" xml:id="W0010_change_033" xml:lang="en">Corrections and editings.</change>
                <change who="#DG #auto" when="2019-03-04" status="c_hyph_proposed" xml:id="W0010_change_032" xml:lang="en">Automatically expanded abbreviations (la).</change>
                <change who="#DG #auto" when="2019-03-04" status="c_hyph_proposed" xml:id="W0010_change_031" xml:lang="en">Automatically expanded abbreviations (es).</change>
                <change who="#DG #auto" when="2019-03-04" status="c_hyph_proposed" xml:id="W0010_change_030" xml:lang="en">Added xml:lang (la) info to marg. notes</change>
                <change who="#DG #auto" when="2019-01-23" status="c_hyph_proposed" xml:id="W0010-change-023" xml:lang="en">Resolved most frequent abbreviations.</change>
                <change who="#DG #auto" when="2019-01-17" status="c_hyph_proposed" xml:id="W0010-change-022" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #auto" when="2019-01-17" status="c_hyph_proposed" xml:id="W0010-change-021" xml:lang="en">Numbered lines.</change>
                <change who="#DG #auto" when="2019-01-15" status="c_hyph_proposed" xml:lang="en" xml:id="W0010-change-020">Tagged special characters.</change>
                <change who="#DG #auto" when="2019-01-15" status="c_hyph_proposed" xml:lang="en" xml:id="W0010-change-019">Annotated marked hyphenations.</change>
                <change who="#DG #auto" when="2019-01-15" status="a_raw" xml:id="W0010-change-018" xml:lang="en">Tagged note cross-references and deleted reference character from beginnings of marginal notes.</change>
                <change who="#DG #auto" when="2019-01-15" status="a_raw" xml:id="W0010-change-017" xml:lang="en">Added #spc and #r-center rendering information to chapter headings and table of contents.</change>
                <change who="#DG #auto" when="2019-01-15" status="a_raw" xml:lang="en">Transformation from TEI Tite to TEI P5, integrating text (Tite) and teiHeader.</change>
                <change who="#DG" when="2019-01-15" status="a_raw" xml:lang="en">Removed double hyphens at the end of lines.</change>
                <change who="#DG" when="2019-01-15" status="a_raw" xml:lang="en">Annotated cross-references in table of contents.</change>
                <change who="#DG" when="2019-01-11" status="a_raw" xml:lang="en">Annotated structure (div+head) in text body.</change>
                <change who="#DG" when="2019-01-10" status="a_raw" xml:lang="en">Annotated title pages and structures (div, list) in front and back matter.</change>
                <change who="#DG #MT" when="2019-01-10" status="a_raw" xml:lang="en">Addition and normalization of pagination.</change>
                <change who="#DG" when="2019-01-10" status="a_raw" xml:lang="en">Correct tagging of ornamental figures and verse text.</change>   
                <change who="#DG" when="2019-01-09" status="a_raw" xml:lang="en">Adjusted column layout (tei:cb).</change>
                <change who="#DG" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-10-10" status="a_raw">
                    <list>
                        <item xml:id="item_jpiiaw4">pubPlace@role="firstEd" (Eingabe des Erscheinungsortes nach Vorlageform) und date@type="firstEd", wenn wir die Erstausgabe haben</item>
                        <item xml:id="item_jopuhp92">publisher/persName nach RAK WB §§ 145: Nur Nachname im Nominativ</item>
                        <item xml:id="item_croouhp2">ref@type="institution" und ref@type="catLink" eingetragen, noch im Schema ergänzen...</item>
                    </list>
                </change>
                <change when="2014-07-01" who="#AW" status="a_raw">Felder im Header ergänzt (sourceDesc, profileDesc, XIncludes)</change>
                <change when="2014-05-26" who="#AW" status="a_raw">Autor und Titel eingetragen</change>
                <change when="2014-01-01" status="a_raw">In xml importiert (TEI header, Stellvertreter-Werte in Meta-Infos, TEI-konforme Tags usw.</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>