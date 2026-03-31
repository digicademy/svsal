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
    
<xsl:variable name="teiHeader" xml:space="preserve"><xsl:copy-of select="preceding-sibling::processing-instruction('htmlFragmentationDepth')[1]"/><teiHeader xmlns:t="http://www.tei-c.org/ns/tite/1.0" xmlns:tite="http://www.tei-c.org/ns/tite/1.0" xmlns:sal="http://salamanca.adwmainz.de">
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Antinomia Ivris Regni Hispaniarvm, Ac Civilis</title>
                <title type="main" level="m">Antinomia Ivris Regni Hispaniarvm, Ac Civilis, In Qva Practica forensium causarum versatur: ac Aerarium commune opinionum communium iuxta ordinem alphabeti, cum concordantijs ac discordantijs legum regni Hispaniæ</title>
                <author>
                    <persName ref="author:A0097 cerl:cnp02002710 viaf:47114137 gnd:1055676422" key="Villalobos, Juan Bautista de">
                        <forename>Juan Bautista</forename>
                        <nameLink>de</nameLink>
                        <surname>Villalobos</surname>
                    </persName>
                </author>
                
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
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
                <edition n="1.0.0" xml:id="W0111-version1" xml:lang="en">
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
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0111</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0111?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0111?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0111?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0111?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0111?format=txt&amp;mode=orig</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="31"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0097 cerl:cnp02002710 viaf:47114137 gnd:1055676422" key="Villalobos, Juan Bautista de">
                                <forename>Juan Bautista</forename>
                                <nameLink>de</nameLink>
                                <surname>Villalobos</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Antinomia Ivris Regni Hispaniarvm, Ac Civilis</title>
                        <title type="main" level="m">Antinomia Ivris Regni Hispaniarvm, Ac Civilis, In Qva Practica forensium causarum versatur: ac Aerarium commune opinionum communium iuxta ordinem alphabeti, cum concordantijs ac discordantijs legum regni Hispaniæ</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salmanticae">Salmanticae</pubPlace>
                            <date type="firstEd" when="1569">1569</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00046861 viaf:99844936 gnd:103761836X" key="Cánova, Alejandro de">
                                    <forename>Alejandro</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Cánova</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">24 ungezählte Seiten, 46 Blätter, 190 Blätter, 2 ungezählte Seiten</extent>
                        <extent xml:lang="en">[24], 46, 190, [2] l. ; Fol.</extent>
                        <extent xml:lang="es">[24], 46, 190, [2] h. ; Fol.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://gredos.usal.es/handle/10366/136857</idno>
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
                <p xml:id="W0111_RW">Reference works contain automatic hyphenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2024-04-09" status="g_enriched_approved" xml:id="W0111_change_013" xml:lang="en">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2023-08-23" status="f_enriched" xml:id="W0111_change_012" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2023-08-23" status="f_enriched" xml:id="W0111_change_011" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2023-08-23" status="f_enriched" xml:id="W0111_change_010" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2023-08-22" status="c_hyph_proposed" xml:lang="en" xml:id="W0111_change_009">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2023-08-22" status="c_hyph_proposed" xml:id="W0111_change_008" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2023-08-22" status="a_raw" xml:lang="en">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2023-08-22" status="a_raw" xml:lang="en" xml:id="W0111_change_006">Unclear marks resolution.</change>
                <change who="#CR #auto" when="2023-08-08" status="a_raw" xml:lang="en" xml:id="W0111_change_005">Adding @target to ref in summaries.</change>
                <change who="#CR #auto" when="2023-08-08" status="a_raw" xml:lang="en" xml:id="W0111_change_004">Adding @xml:id and @unit to milestones.</change>
                <change who="#CR" when="2023-08-03" status="a_raw" xml:lang="en" xml:id="W0111_change_003">Structural annotation</change>
                <change who="#CR" when="2020-01-20" status="a_raw" xml:lang="en">Set teiHeader.</change>
                <change who="#CB" when="2016" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>    
</xsl:stylesheet>