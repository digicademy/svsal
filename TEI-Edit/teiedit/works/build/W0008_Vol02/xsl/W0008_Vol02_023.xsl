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
                <title type="short" level="m">De Iustitia et Iure, Vol. 2</title>
                <title type="main" level="m">De Ivstitia Tomvs Secvndvs De Contractibvs</title>
                <title type="volume" level="m" n="2">Tomvs Secvndvs</title>
                <author>
                    <persName ref="author:A0061 gnd:118734555 cerl:cnp01237409" key=" Molina, Luis de">
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
                <edition n="1.0.0" xml:id="W0008_Vol02-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-12-04">2025-12-04</date>.
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
                <date type="digitizedEd" when="2025-01-14">2025-12-04</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0008_vol2</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0008_vol2?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0008_vol2?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0008_vol2?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0008_vol2?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0008_vol2?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0008_vol2?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="41.2">Volume 41.2</biblScope>
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
                        <title type="short" level="m">De Iustitia et Iure, Vol. 2</title>
                        <title type="main" level="m">De Ivstitia Tomvs Secvndvs De Contractibvs</title>
                        <title type="volume" level="m" n="2">Tomvs Secvndvs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7338606" key="Cuenca">Conchae</pubPlace>
                            <date type="firstEd" when="1597">1597</date>
                            <publisher n="firstEd">
                                <persName key="Serrano de Vargas, Miguel">
                                    <forename>Miguel</forename>
                                    <surname>Serrano de Vargas</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[8] S., 2144 Sp., [147] S. ; 2°</extent>
                        <extent xml:lang="en">[8] p., 2144 col., [147] p. ; 2°</extent>
                        <extent xml:lang="es">[8] p., 2144 col., [147] p. ; 2°</extent>
                    </monogr>
                    <series>
                        <title type="main" level="s" ref="work:W0008">De Iustitia et Iure</title>
                        <biblScope unit="volume" n="2" xml:lang="la">Tomvs Secvndvs</biblScope>
                    </series>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991000494519705773</idno>
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
                <change who="#DG #PS #auto" when="2025-11-10" status="g_enriched_approved" xml:id="W0008_Vol02_change_029" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #PS #auto" when="2025-11-10" status="g_enriched_approved" xml:id="W0008_Vol02_change_028" xml:lang="en">Numbered lines.</change>
                <change who="#DG #PS #auto" when="2025-11-10" status="g_enriched_approved" xml:lang="en" xml:id="W0008_Vol02_change_027">Tagged special characters.</change>
                <change who="#DG #PS #auto" when="2025-11-10" status="g_enriched_approved" xml:id="W0008_Vol02_change_026" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #PS #auto" when="2025-11-07" status="g_enriched_approved" xml:id="W0008_Vol02_change_025" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #PS #auto" when="2025-11-05" status="g_enriched_approved" xml:id="W0008_Vol02_change_024" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #PS #auto" when="2025-11-05" status="g_enriched_approved" xml:id="W0008_Vol02_change_023" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2025-10-30" status="g_enriched_approved" xml:id="W0008_Vol02_change_022" xml:lang="en">Second round of manual corrections (CB).</change>
                <change who="#DG #CR #auto" when="2025-08-19" status="g_enriched_approved" xml:id="W0008_Vol02_change_021" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2025-08-08" status="g_enriched_approved" xml:id="W0008_Vol02_change_020" xml:lang="en">First round of manual corrections (CB).</change>
                <change who="#DG #PS #auto" when="2024-07-23" status="f_enriched" xml:id="W0008_Vol02_change_019" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #PS #auto" when="2024-07-23" status="f_enriched" xml:id="W0008_Vol02_change_018" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #PS #auto" when="2024-07-23" status="f_enriched" xml:id="W0008_Vol02_change_017" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #PS #auto" when="2022-05-04" status="f_enriched" xml:id="W0008_Vol02_change_016" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #PS #auto" when="2022-04-21" status="f_enriched" xml:id="W0008_Vol02_change_015" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #PS #auto" when="2022-04-21" status="f_enriched" xml:id="W0008_Vol02_change_014" xml:lang="en">Numbered lines.</change>
                <change who="#DG #PS #auto" when="2022-04-19" status="f_enriched" xml:lang="en" xml:id="W0008_Vol02_change_013">Tagged special characters.</change>
                <change who="#DG #PS #auto" when="2022-04-11" status="f_enriched" xml:lang="en" xml:id="W0008_Vol02_change_012">Annotated hyphenated breaks.</change>
            <change who="#DG #CR #PS #auto" when="2022-04-11" status="a_raw" xml:lang="en" xml:id="W0008_Vol02_change_011">Transformation from TEI-Tite to TEI-All.</change>
            <change who="#PS #auto" when="2024-07-23" status="a_raw" xml:lang="en" xml:id="W0008_Vol02_change-010">Added (la) abbreviations depending on word structure with regex.</change>
            <change who="#PS #auto" when="2022-03-10" status="a_raw" xml:lang="en" xml:id="W0008_Vol02_change-009">Added pagination.</change>
            <change who="#PS #CR" when="2021-05-01" status="a_raw" xml:lang="en" xml:id="W0008_Vol02_change-008">Structural annotation.</change>
            <change who="#CR" when="2021-06-17" status="a_raw" xml:lang="en">teiHeader update.</change>
            <change who="#CR" when="2020-10-27" status="a_raw" xml:lang="en">teiHeader update.</change>
            <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
            <change who="#DG" when="2018-09-27" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
            <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
            <change who="#AW" when="2014-10-16" status="a_raw">Reihenfolge der Editoren korrigiert und ref-key f. Drucker u. Druckort eingetragen.</change>
            <change who="#IC" when="2014-10-10" status="a_raw">
                <list>
                    <item xml:id="item_fdvce4w">pubPlace@role="firstEd" (Eingabe des Erscheinungsortes nach Vorlageform) und date@type="firstEd", wenn wir die Erstausgabe haben</item>
                    <item xml:id="item_vww4rgv">publisher/persName nach RAK WB §§ 145: Nur Nachname im Nominativ</item>
                    <item xml:id="item_2qwa43y">ref@type="institution" und ref@type="catLink" im Schema ergänzen</item>
                </list>
            </change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>