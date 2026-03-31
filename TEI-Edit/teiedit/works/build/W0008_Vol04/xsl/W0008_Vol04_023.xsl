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
    
    
<xsl:variable name="teiHeader" xml:space="preserve"><teiHeader>
        <fileDesc>          
            <titleStmt>
                <title type="short" level="m">De Iustitia et Iure, Vol. 4</title>
                <title type="main" level="m">De Ivstitia Tomi Tertii Pars Posterior. De delictis &amp; quasi delictis</title>
                <title type="volume" n="4">Tomi Tertii Pars Posterior</title>
                <author>
                    <persName ref="author:A0061 gnd:118734555 cerl:cnp01237409" key="Molina, Luis de">
                        <forename>Luis</forename>
                        <nameLink>de</nameLink>
                        <surname>Molina</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="PS" role="#technical">
                    <persName ref="orcid:0000-0001-5223-1220">
                        <surname>Solonets</surname>, <forename>Polina</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="MAH" role="#technical #scholarly">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
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
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0008_Vol04-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-01-27">2025-01-27</date>.
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
                <date type="digitizedEd" when="2025-01-08">2025-01-27</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0008:vol4</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0008:vol4?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0008:vol4?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0008:vol4?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0008:vol4?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0008:vol4?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0008:vol4?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
          <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="41.7">Volume 41.4</biblScope>
           </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0008"/>
            </notesStmt>
 
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0061 gnd:118734555 cerl:cnp01237409" key="Molina, Luis de">
                                <forename>Luis</forename>
                                <nameLink>de</nameLink>
                                <surname>Molina</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iustitia et Iure, Vol. 4</title>
                        <title type="main" level="m">De Ivstitia Tomi Tertii Pars Posterior. De delictis &amp; quasi delictis</title>
                        <title type="volume" level="m" n="4">Tomi Tertii Pars Posterior</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7007856" key="Antwerpen">Antverpiae</pubPlace>
                            <date type="firstEd" when="1609">1609</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:138925127 viaf:2524980 cerl:cni00032184" key="Martinus, Nutius">
                                    <forename>Martinus</forename>
                                    <surname>Nutius</surname>
                                </persName>
                                <persName ref="gnd:1090718691 viaf:2939145857123022922472 cerl:cni00043671" key="Hetsroy, Johannes">
                                    <forename>Ioannis</forename>
                                    <surname>Hetsroy</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[4] Bl., Sp. 1113 - 1692</extent>
                        <extent xml:lang="en">[4] Bl., Sp. 1113 - 1692</extent>
                        <extent xml:lang="es">[4] Bl., Sp. 1113 - 1692</extent>
                    </monogr>
                    <series>
                        <title type="main" level="s" ref="work:W0008">De Iustitia et Iure</title>
                        <biblScope unit="volume" n="3" xml:lang="la">Tomi Tertii Pars Posterior</biblScope>
                    </series>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">https://mdz-nbn-resolving.de/details:bsb10497096</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc>
                    <msIdentifier corresp="#facs:W0008-D-0074 #facs:W0008-D-0075">
                        <repository ref="gnd:2020893-5" xml:lang="de">Österreichische Nationalbibliothek</repository>
                        <idno type="catlink" xml:lang="de">http://data.onb.ac.at/rep/1039D4E8</idno>
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
                <change who="#DG #PS #auto" when="2025-01-27" status="g_enriched_approved" xml:id="W0008_Vol04_change_031" xml:lang="en">TEI Header Update for online publication.</change>
                <change who="#DG #PS #auto" when="2025-01-22" status="g_enriched_approved" xml:id="W0008_Vol04_change_030" xml:lang="en">Tagged special characters.</change>
                <change who="#DG #PS #auto" when="2025-01-22" status="g_enriched_approved" xml:id="W0008_Vol04_change_029" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #PS #auto" when="2025-01-22" status="g_enriched_approved" xml:id="W0008_Vol04_change_028" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #PS #auto" when="2025-01-22" status="g_enriched_approved" xml:id="W0008_Vol04_change_027" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #PS #auto" when="2025-01-22" status="g_enriched_approved" xml:id="W0008_Vol04_change_026" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2025-01-20" status="g_enriched_approved" xml:id="W0008_Vol04_change_025" xml:lang="en">Third round of manual corrections (CB).</change>
                <change who="#DG #PS #CR #auto" when="2025-01-09" status="g_enriched_approved" xml:id="W0008_Vol04_change_024" xml:lang="en">Reduced excessive whitespace.</change>
            <change who="#CB" when="2025-01-08" status="g_enriched_approved" xml:id="W0008_Vol04_change_023" xml:lang="en">Second round of manual corrections (CB).</change>
            <change who="#CR #DG #auto" when="2022-08-22" status="g_enriched_approved" xml:id="W0008_Vol04_change_022" xml:lang="en">Reduced excessive whitespace.</change>
            <change who="#MAH #CB" when="2024-08-21" status="g_enriched_approved" xml:id="W0008_Vol04_change_021" xml:lang="en">First round of manual corrections (MAH/CB).</change>
            <change who="#DG #PS #auto" when="2024-04-23" status="f_enriched" xml:id="W0008_Vol04_change_020" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
            <change who="#DG #PS #auto" when="2024-04-23" status="f_enriched" xml:id="W0008_Vol04_change_019" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
            <change who="#DG #PS #auto" when="2024-04-23" status="f_enriched" xml:id="W0008_change_018" xml:lang="en">Tag unmarked breaks (la).</change>
            <change who="#DG #auto #PS" when="2024-04-23" status="f_enriched" xml:id="W0008_change_017" xml:lang="en">Generated @xml:id.</change>
            <change who="#DG #PS #auto" when="2023-03-01" status="f_enriched" xml:id="W0008_change_016" xml:lang="en">Numbered lines.</change>
            <change who="#DG #PS #auto" when="2023-03-01" status="f_enriched" xml:lang="en" xml:id="W0008_change_015">Tagged special characters.</change>
            <change who="#DG #CR #PS #auto" when="2023-03-01" status="f_enriched" xml:id="W0008_change_014" xml:lang="en">Annotate Hyphenation</change>
            <change who="#DG #CR #PS #auto" when="2023-02-13" status="a_raw" xml:lang="en" xml:id="W0008_Vol04_change_013">Transformation from TEI-Tite to TEI-All.</change>
            <change who="#PS #auto" when="2023-02-13" status="a_raw" xml:lang="en" xml:id="W0008_Vol04_change_012">Added (la) abbreviations depending on word structure with regex.</change>
            <change who="#PS #auto" when="2023-02-07" status="a_raw" xml:lang="en" xml:id="W0008_Vol04_change_011">Added xml:ids to milestones and cross references in summaries.</change>
            <change who="#PS #auto" when="2023-02-07" status="a_raw" xml:lang="en" xml:id="W0008_Vol01_change-010">Recounting pb and cb elements, adding pagination, @n and @xml:id to div3, @xml:id to milestone, adding toc.</change>
            <change who="#PS #CR" when="2022-06-01" status="a_raw" xml:lang="en" xml:id="W0008_Vol01_change-009">Structural annotation.</change>
            <change who="#PS #CR" when="2024-03-19" status="a_raw" xml:lang="en">teiHeader update: Added new repository for the facsimiles W0008-D-0074.jpg and W0008-D-0075.jpg.</change>
            <change who="#CR" when="2021-06-17" status="a_raw" xml:lang="en">teiHeader update.</change>
            <change who="#CR" when="2020-10-27" status="a_raw" xml:lang="en">teiHeader update.</change>
            <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
            <change who="#DG" when="2018-09-27" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
            <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
            <change who="#AW" when="2014-10-16" status="a_raw">Reihenfolge der Editoren korrigiert und ref-key f. Drucker u. Druckort eingetragen.</change>
            <change who="#IC" when="2014-10-10" status="a_raw">
                <list>
                    <item xml:id="item_avrc3xdf">pubPlace@role="firstEd" (Eingabe des Erscheinungsortes nach Vorlageform) und date@type="firstEd", wenn wir die Erstausgabe haben</item>
                    <item xml:id="item_vardfhhs34">publisher/persName nach RAK WB §§ 145: Nur Nachname im Nominativ</item>
                    <item xml:id="item_bvrdvvxs4">ref@type="institution" und ref@type="catLink" im Schema ergänzen</item>
                </list>
            </change>
        </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>