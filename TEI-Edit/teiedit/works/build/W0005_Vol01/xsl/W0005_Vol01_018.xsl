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
                <title type="short" level="m">Política para Corregidores, Primer Tomo</title>
                <title type="main" level="m">Politica para Corregidores y Señores de Vassallos, en Tiempo de Paz, y de Gverra</title>
                <title type="volume" level="m" n="1">Primer Tomo</title>
                <author>
                    <persName ref="author:A0020 cerl:cnp00980649 gnd:100052711" key="Castillo de Bobadilla, Jerónimo">
                        <forename>Jerónimo</forename>
                        <surname>Castillo de Bobadilla</surname>
                    </persName>
                </author>
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
                <editor xml:id="MAH" role="#technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
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
                
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0005_Vol01-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-09-10">2025-09-10</date>.
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
                <date type="digitizedEd" when="2025-09-10">2025-09-10</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0005:vol1</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0005:vol1?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0005:vol1?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0005:vol1?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0005:vol1?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0005:vol1?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0005:vol1?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="55.1">Volume 55.1</biblScope>
            </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0005"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0020 cerl:cnp00980649 gnd:100052711" key="Castillo de Bobadilla, Jerónimo">
                                <forename>Jerónimo</forename>
                                <surname>Castillo de Bobadilla</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Política para Corregidores, Primer Tomo</title>
                        <title type="main" level="m">Politica para Corregidores y Señores de Vassallos, en Tiempo de Paz, y de Gverra</title>
                        <title type="volume" level="m" n="1">Primer Tomo</title>
                        <imprint> 
                            <pubPlace role="firstEd" ref="getty:7010420" key="Madrid">Madrid</pubPlace>
                            <date type="firstEd" when="1597">1597</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00045339" key="Sanchez, Luis">
                                    <forename>Luis</forename>
                                    <surname>Sanchez</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">188 ungezählte Seiten, 1284 Seiten</extent>
                        <extent xml:lang="en">[188], 1284 p.</extent>
                        <extent xml:lang="es">[188], 1284 p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2019144-3" xml:lang="de">Max-Planck-Institut für Rechtsgeschichte und Rechtstheorie</repository>
                        <idno type="catlink" xml:lang="en">https://sunrise.rg.mpg.de/webOPACClient/start.do?Language=en&amp;KatKeySearch=552662</idno>
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
              <language ident="la" n="margin" xml:lang="en">Latin</language>
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
                <p xml:id="W0005_Vol01_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2025-09-10" status="g_enriched_approved" xml:id="W0005_Vol01_change_025" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#CR #auto" when="2025-09-10" status="f_enriched" xml:id="W0005_Vol01_change_024" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2025-09-09" status="f_enriched" xml:id="W0005_Vol01_change_023" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2025-09-09" status="f_enriched" xml:id="W0005_Vol01_change_022" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2025-09-09" status="f_enriched" xml:id="W0005_Vol01_change_021" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2025-09-09" status="f_enriched" xml:id="W0005_Vol01_change_020" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2021-04-13" status="f_enriched" xml:id="W0005_Vol01_change_019" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2021-04-13" status="f_enriched" xml:id="W0005_Vol01_change_018" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2021-04-13" status="f_enriched" xml:lang="en" xml:id="W0005_Vol01_change_017">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2025-09-04" status="f_enriched" xml:id="W0005_Vol01_change_016" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2025-09-04" status="a_raw" xml:id="W0005_Vol01_change_015">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2021-02-18" status="a_raw" xml:id="W0005_Vol01_change_014">Added cb/@sameAs in note(s) manually.</change>
                <change who="#CR #DG #auto" when="2021-02-17" status="a_raw" xml:id="W0005_Vol01_change_013">Added pb-cb/@sameAs in note(s) from comment() 'tao:pb_in_note'.</change>
                <change who="#CR #DG #auto" when="2025-09-04" status="a_raw" xml:id="W0005_Vol01_change_012">Added (la) abbreviations depending on word endings with regex.</change>
                <change who="#CR #DG #auto" when="2025-09-04" status="a_raw" xml:id="W0005_Vol01_change_011">Added (es) abbreviations depending on word endings with regex.</change>
                <change who="#CR #DG #auto" when="2021-01-21" status="a_raw" xml:id="W0005_Vol01_change_010">Added crossed references between list (summaries) and milestone(s).</change>
                <change who="#CR #DG #auto" when="2021-01-20" status="a_raw" xml:id="W0005_Vol01_change_009">Added cross-references in note(s) and milestone(s) with anchore.</change>
                <change who="#CR #DG #auto" when="2021-01-19" status="a_raw" xml:id="W0005_Vol01_change_008">Added missing pagination in front.</change>
                <change who="#CR #DG #auto" when="2021-01-18" status="a_raw" xml:id="W0005_Vol01_change_007">Added @targets in toc, @type/@xml:id in list(s), div(s), @n, @unit, @xml:id in milestone(s).</change>
                <change who="#CR" when="2021-01-07" status="a_raw" xml:id="W0005_Vol01_change_006">Structural annotation and second round of unclear resolution.</change>
                <change who="#CR" when="2020-09-07" status="a_raw" xml:id="W0005_Vol01_change_005">teiHeader update.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en" xml:id="W0005_Vol01_change_004">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-27" status="a_raw" xml:lang="en" xml:id="W0005_Vol01_change_003">Revision of teiHeader and status reset.</change>
                <change who="#IC" when="2014-11-27" status="a_raw" xml:id="W0005_Vol01_change_002">revision of teiHeader</change>
                <change who="#IC" when="2014-09-25" status="a_raw" xml:id="W0005_Vol01_change_001">W0005_Vol01 Header angelegt</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>