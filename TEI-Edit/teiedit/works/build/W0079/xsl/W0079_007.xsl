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
                <title type="short" level="m">Vocabvlarivm Vtrivsqve Ivris</title>
                <title type="main" level="m">Vocabvlarivm Vtrivsqve Ivris</title> 
                <author>
                    <persName ref="author:A0065 cerl:cnp01443478 gnd:118980955 viaf:71379496" key="Nebrija, Elio Antonio de">
                        <forename>Elio Antonio</forename>
                        <nameLink>de</nameLink>
                        <surname>Nebrija</surname>
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
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0079-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-01-22">2025-01-22</date>.
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
                <date type="digitizedEd" when="2025-01-22">2025-01-22</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0079</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0079?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0079?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0079?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0079?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0079?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0079?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="42">Volume 42</biblScope>
           </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0065 cerl:cnp01443478 gnd:118980955 viaf:71379496" key="Nebrija, Elio Antonio de">
                                <forename>Elio Antonio</forename>
                                <nameLink>de</nameLink>
                                <surname>Nebrija</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Vocabvlarivm Vtrivsqve Ivris</title>
                        <title type="main" level="m">Vocabvlarivm Vtrivsqve Ivris</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lvgdvni</pubPlace>
                            <date type="firstEd" when="1559">1559</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00024947 viaf:99384286 gnd:1037614704" key="Giunta, Jacques">
                                    <forename>Jacobus</forename>
                                    <surname>Iuncta</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">720 Seiten</extent>
                        <extent xml:lang="en">720 p.</extent>
                        <extent xml:lang="es">720 p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">https://mdz-nbn-resolving.de/details:bsb11277085</idno>
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
                <p xml:id="W0079_RW">
                   Reference works contain automatic hyphenation of marked and unmarked words in the pb, cb and lb elements.
                   Abbreviations are coded as they appear in the original.</p>
                <p xml:id="W0079-full-text">
                   This Reference work contains full text until W0079-0556, page 556, where the work finishes as "Finis Vocabvlarivm vtrivsqve Ivris".</p>
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
                <change who="#CR" when="2025-01-22" status="g_enriched_approved" xml:id="W0079_change_009" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#DG #CR #auto" when="2025-01-22" status="f_enriched" xml:id="W0079_change_008" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2025-01-21" status="f_enriched" xml:id="W0079_change_007" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2025-01-21" status="f_enriched" xml:id="W0079_change_006" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2025-01-16" status="f_enriched" xml:id="W0079_change_005" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2025-01-16" status="f_enriched" xml:lang="en" xml:id="W0079_change_004">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2025-01-15" status="a_raw" xml:lang="en" xml:id="W0079_change_003">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2024-12-19" status="a_raw" xml:lang="en" xml:id="W0079_change_002">Structural annotation and unclear resolution.</change>
                <change who="#CR" when="2023-12-14" status="a_raw" xml:lang="en" xml:id="W0079_change_001">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>