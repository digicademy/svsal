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
                <title type="short" level="m">Dispvtationvm in secundam secundae D.Thomae. Tomus alter</title>
                <title type="main" level="m">Lvisii Tvrriani complvtensis, Societatis Iesv Theologi, Dispvtationvm in secundam secundae D.Thomae, de fide, spe, charitate et prvdentia; Tomus alter.</title> 
                <author>
                    <persName ref="author:A0088 cerl:cnp01133164 viaf:49574937" key="Torres, Luis de">
                        <forename>Luis</forename>
                        <nameLink>de</nameLink>
                        <surname>Torres</surname>
                    </persName>
                </author>
                
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
                
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0102-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-12-17">2025-12-17</date>.
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
                <date type="digitizedEd" when="2025-12-17">2025-12-17</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0102</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0102?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0102?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0102?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0102?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0102?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0102?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>


            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="59">Volume 59</biblScope>
           </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0088 cerl:cnp01133164 viaf:49574937" key="Torres, Luis de">
                                <forename>Luis</forename>
                                <nameLink>de</nameLink>
                                <surname>Torres</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Dispvtationvm in secundam secundae D.Thomae. Tomus alter</title>
                        <title type="main" level="m">Lvisii Tvrriani complvtensis, Societatis Iesv Theologi, Dispvtationvm in secundam secundae D.Thomae, de fide, spe, charitate et prvdentia; Tomus alter.</title> 
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1621">1621</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00042117 gnd:1037586743 viaf:51857410" key="Cardon, Iacob">
                                    <forename>Iacob</forename>
                                    <surname>Cardon</surname>
                                </persName>
                                <persName ref="cerl:cni00012135 gnd:1037594142 viaf:5099127" key="Cavellat, Petrus">
                                    <forename>Petrus</forename>
                                    <surname>Cavellat</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">92 ungezählte Seiten, 904 Spalten, 65 ungezählte Seiten</extent>
                        <extent xml:lang="en">[92] p., 904 col., [65] p.</extent>
                        <extent xml:lang="es">[92] p., 904 col., [65] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">http://mdz-nbn-resolving.de/urn:nbn:de:bvb:12-bsb10325793-3</idno>
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
                <p xml:id="W0102_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2025-12-17" status="g_enriched_approved" xml:id="W0102_change_014" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#CR #auto" when="2025-12-17" status="f_enriched" xml:id="W0102_change_013" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2025-12-17" status="f_enriched" xml:id="W0102_change_012" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2025-12-16" status="f_enriched" xml:id="W0102_change_011" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #auto" when="2025-12-16" status="f_enriched" xml:id="W0102_change_010" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #auto" when="2025-12-16" status="f_enriched" xml:id="W0102_change_009" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2025-12-16" status="f_enriched" xml:lang="en" xml:id="W0102_change_008">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2025-12-11" status="f_enriched" xml:id="W0102_change_007" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR #auto" when="2025-12-11" status="a_raw" xml:id="W0102_change_006" xml:lang="en">Transformation TEI-tite to TEI-All.</change>
                <change who="#CR #auto" when="2025-12-09" status="a_raw" xml:id="W0102_change_005" xml:lang="en">Abbr. with regex - Added (la) abbreviations depending on word endings with regex.</change>
                <change who="#CR #auto" when="2025-11-27" status="a_raw" xml:id="W0102_change_004" xml:lang="en">Tagged @n, @type, @xml:id(s) in div(s), list(s) and @target in TOC and summaries.</change>
                <change who="#CR" when="2025-10-21" status="a_raw" xml:id="W0102_change_003" xml:lang="en">Structural annotation and first round of unclear resolution.</change>
                <change who="#CR" when="2025-05-13" status="a_raw" xml:lang="en">Added encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2024-07-24" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>