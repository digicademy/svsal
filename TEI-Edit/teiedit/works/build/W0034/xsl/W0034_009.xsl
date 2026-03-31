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
                <title type="short" level="m">Treinta Proposiciones</title>
                <title type="main" level="m">Aqui se co[n]tiene[n] treynta proposiciones muy juridicas: en las quales sumaria y succintamente se 
                    toca[n] muchas cosas pertenecie[n]tes al derecho q[ue] la yglesia y los principes christianos 
                    tienen / o puede[n] tener sobre los infieles de qual quier especie que sean</title>
                <author>
                    <persName ref="author:A0018 cerl:cnp01316779 viaf:46758461 gnd:118726625" key="Las Casas, Bartolomé de">
                        <forename>Bartolomé</forename>
                        <nameLink>de</nameLink>
                        <surname>Las Casas</surname>
                    </persName>
                </author>
                <editor xml:id="CB">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="CC">
                    <persName ref="orcid:0000-0003-1240-649X" full="yes">
                        <surname full="yes">Cárdenas Velásquez</surname>, <forename full="yes">Luisa Carolina</forename>
                    </persName>
                </editor>
                <editor xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="CR">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0034-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2018-11-29">2018-11-29</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                    <xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></publisher>
                    </xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2018-11-29">2018-11-29</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0034</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0034?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0034?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0034?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0034?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0034?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0034?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="4" xml:lang="en">Volume 4</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0018 cerl:cnp01316779 viaf:46758461 gnd:118726625" key="Las Casas, Bartolomé de">
                                <forename>Bartolomé</forename>
                                <nameLink>de</nameLink>
                                <surname>Las Casas</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Treinta Proposiciones</title>
                        <title type="main" level="m">Aqui se co[n]tiene[n] treynta proposiciones muy juridicas: en las quales sumaria y succintamente se 
                            toca[n] muchas cosas pertenecie[n]tes al derecho q[ue] la yglesia y los principes christianos 
                            tienen / o puede[n] tener sobre los infieles de qual quier especie que sean</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008676" key="Sevilla">Seuilla</pubPlace>
                            <date type="firstEd" when="1552">1552</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00036706" key="Trugillo, Sebastián"> <!--not in GND-->
                                    <forename>Sebastián</forename> 
                                    <surname>Trugillo</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">20 ungezählte Seiten ; 4º</extent>
                        <extent xml:lang="en">[20] p. ; 4º</extent>
                        <extent xml:lang="es">[20] p. ; 4º</extent>
                    </monogr>
                </biblStruct>
                <msDesc type="main">
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">http://brumario.usal.es/record=b1417287~S1*spi</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Rotunda typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        
        <profileDesc>
           <langUsage>
              <language ident="es" n="main" xml:lang="en">Spanish</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/works-general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="d1e222"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="d1e233"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
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
                <change who="#DG" when="2018-12-10" status="g_enriched_approved" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG #auto" when="2018-11-29" status="g_enriched_approved" xml:id="W0034_change_09" xml:lang="en">Created new @xml:id and line numbering.</change>
                <change who="#DG" when="2018-11-29" status="g_enriched_approved">Small modifications with metadata, and status update.</change>
                <change who="#CB" when="2018-11-29" status="f_enriched" xml:lang="en">Final corrections.</change>
                <change who="#DG #auto" when="2018-11-29" status="f_enriched" xml:id="W0034_change_07" xml:lang="en">Added @xml:id and line numbering.</change>
                <change who="#DG" when="2018-11-29" status="f_enriched" xml:lang="en">Post-correction fixes.</change>
                <change who="#CB" when="2018-11-29" status="f_enriched" xml:lang="en">Extensive corrections and enrichment.</change>
                <change who="#CR #auto" when="2018-11-28" status="c_hyph_proposed" xml:id="W0034_change_03" xml:lang="en">Added @xml:id and line numbering.</change>
                <change who="#CR #auto" when="2018-11-28" status="c_hyph_proposed" xml:lang="en" xml:id="W0034_change_003">Tagged special characters.</change>
                <change who="#DG" when="2018-11-28" status="c_hyph_proposed" xml:lang="en">Revised metadata and title page.</change>
                <change who="#DG" when="2018-11-27" status="c_hyph_proposed" xml:lang="en">Annotated title page and line/page breaks further.</change>
                <change who="#CR" when="2018-11-26" status="a_raw" xml:lang="en">Transformation from transcription to TEI, structural annotation</change>
                <change who="#CB #CC" when="2018-11-23" status="a_raw" xml:lang="en">Transcription</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset; set language to "es".</change>
                <change who="#AW" when="2017-07-30" status="a_raw">Create template/file for metadata</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>