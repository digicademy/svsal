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
                <title type="short" level="m">Primera Partida</title>
                <title type="main" level="m">Las Siete Partidas Del Sabio Rey don Alonso el nono, nueuamente Glosadas por el Licenciado Gregorio Lopez del Consejo Real de Indias de su Magestad</title>
                <author>
                    <persName ref="author:A0046 viaf:72759209" key="López, Gregorio">
                        <forename>Gregorio</forename>
                        <surname>López</surname>
                    </persName>
                </author>
                <author>
                    <persName ref="gnd:11864811X" key="Alfonso X">
                        <forename>Alfonso</forename>
                        <genName>X</genName>
                        <surname>de Castilla</surname>
                    </persName>
                </author>
                
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
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
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0063_Vol01-version1" xml:lang="en">
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
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0063:vol1</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0063:vol1?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0063:vol1?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0063:vol1?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0063:vol1?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0063:vol1?format=txt&amp;mode=orig</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="32.1">Volume 32.1</biblScope>
            </seriesStmt>
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0063"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                    <author>
                        <persName ref="author:A0046 viaf:72759209" key="López, Gregorio">
                            <forename>Gregorio</forename>
                            <surname>López</surname>
                        </persName>
                    </author>
                    <author>
                        <persName ref="gnd:11864811X" key="Alfonso X">
                            <forename>Alfonso</forename>
                            <genName>X</genName>
                            <surname>de Castilla</surname>
                        </persName>
                    </author>
                        <title type="short" level="m">Primera Partida</title>
                        <title type="main" level="m">Las Siete Partidas Del Sabio Rey don Alonso el nono, nueuamente Glosadas por el Licenciado Gregorio Lopez del Consejo Real de Indias de su Magestad</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanca</pubPlace>
                            <date type="firstEd" when="1555">1555</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00036591 viaf:99338813" key="Portonaris, Andrés de">
                                    <forename>Andrés</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Portonaris</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">151 Blätter</extent>
                        <extent xml:lang="en">151 l.</extent>
                        <extent xml:lang="es">151 h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1231401982" xml:lang="de">Max-Planck-Institut für Rechtsgeschichte und Rechtstheorie.</repository>
                        <idno type="catlink" xml:lang="de">https://sunrise.lhlt.mpg.de/webOPACClient/start.do?KatKeySearch=646647</idno>
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
              <language ident="la" n="marginal" xml:lang="en">Latin</language>
              <language ident="es" n="main" xml:lang="en">Spanish</language>
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
                <p xml:id="W0063_Vol01_RW">Reference works contain automatic hyphenation of marked and unmarked words in the pb, cb and lb elements.
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
            <listChange ordered="true">
                <change who="#CR #auto" when="2024-11-06" status="g_enriched_approved" xml:id="W0063_Vol01_change_015" xml:lang="en">Rearranged pb(s) in div[@type eq 'gloss'] with only @sameAs.</change>
                <change who="#CR #auto" when="2024-04-09" status="g_enriched_approved" xml:id="W0063_Vol01_change_014" xml:lang="en">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2024-01-25" status="f_enriched" xml:id="W0063_Vol01_change_013" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2024-01-25" status="f_enriched" xml:id="W0063_Vol01_change_012" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#CR #auto" when="2024-01-24" status="f_enriched" xml:id="W0063_Vol01_change_011" xml:lang="en">Rearranged pb/@sameAs and lb/xml:id(s) in gloss.</change>
                <change who="#DG #CR #auto" when="2024-01-24" status="f_enriched" xml:id="W0063_Vol01_change_010" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2024-01-23" status="f_enriched" xml:id="W0063_Vol01_change_009" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2024-01-18" status="c_hyph_proposed" xml:lang="en" xml:id="W0063_Vol01_change_008">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2024-01-17" status="c_hyph_proposed" xml:id="W0063_Vol01_change_007" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR #auto" when="2024-01-17" status="a_raw" xml:lang="en" xml:id="W0063_Vol01_change_006">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2024-01-11" status="a_raw" xml:lang="en" xml:id="W0063_Vol01_change_005">Check unclear marks.</change>
                <change who="#CR" when="2023-11-14" status="a_raw" xml:lang="en" xml:id="W0063_Vol01_change_004">Tagged @n, @type, @xml:id(s) in div(s) and @target in TOC, ref(s).</change>
                <change who="#CR" when="2023-11-14" status="a_raw" xml:lang="en" xml:id="W0063_Vol01_change_003">Structural annotation.</change>
                <change who="#CR" when="2023-11-22" status="a_raw" xml:lang="en" xml:id="W0063_Vol01_change_002">teiHeader: Author correction.</change>
                <change who="#CR" when="2022-03-01" status="a_raw" xml:lang="en" xml:id="W0063_Vol01_change_001">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
</xsl:stylesheet>