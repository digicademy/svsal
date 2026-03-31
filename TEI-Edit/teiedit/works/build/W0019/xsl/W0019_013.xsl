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
                <title type="short" level="m">Tractatvs De Officio Fiscalis</title>
                <title type="main" level="m">Don Francisci De Alfaro, Regii In Argentina Cancellaria Regnorvm Pirv Fiscalia Procvratoris, Tractatvs De Officio Fiscalis, Deque Fiscalibus priuilegijs</title> 
                <author>
                    <persName ref="author:A0004 cerl:cnp02012322 viaf:72924861 gnd:1066444730" key="Alfaro, Francisco de">
                        <forename>Francisco</forename>
                        <nameLink>de</nameLink>
                        <surname>Alfaro</surname>
                    </persName>
                </author>   
                <editor xml:id="MAH" role="#scholarly #technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>           
            </titleStmt>
            <editionStmt>
              <edition n="1.0.0" xml:id="W0019-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2024-10-29">2024-10-29</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2024-10-29">2024-10-29</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0019</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0019?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0019?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0019?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/textsW0019?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0019?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0019?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
              <biblScope unit="volume" n="39">Volume 39</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0004 cerl:cnp02012322 viaf:72924861 gnd:1066444730" key="Alfaro, Francisco de">
                                <forename>Francisco</forename>
                                <nameLink>de</nameLink>
                                <surname>Alfaro</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Tractatvs De Officio Fiscalis</title>
                        <title type="main" level="m">Don Francisci De Alfaro, Regii In Argentina Cancellaria Regnorvm Pirv Fiscalia Procvratoris, Tractatvs De Officio Fiscalis, Deque Fiscalibus priuilegijs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008771" key="Valladolid">Vallesoleti</pubPlace>
                            <date type="firstEd" when="1606">1606</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00045339" key="Sanchez, Luis">
                                    <forename>Luis</forename>
                                    <surname>Sanchez</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">8 ungezählte Seiten, 362, das heißt 364 Seiten, 65 ungezählte Seiten</extent>
                        <extent xml:lang="en">[8], 362 [i.e. 364], [65] p.</extent>
                        <extent xml:lang="es">[8], 362 [i.e. 364], [65] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://gredos.usal.es/handle/10366/41063</idno>
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
              <language ident="la" n="main" xml:lang="la">Latin</language>
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
 <p xml:id="W0019_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#MAH #auto" when="2024-10-29" status="g_enriched_approved" xml:id="W0019_017" xml:lang="en">teiHeader Update for online publication.</change>
                <change who="#CR # MAH #auto" when="2024-10-24" status="f_enriched" xml:id="W0019_016" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#CR #MAH #auto" when="2024-10-23" status="f_enriched" xml:id="W0019_change_015" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="# MAH #auto" when="2024-10-29" status="f_enriched" xml:id="W0019_014" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#MAH #auto" when="2024-10-16" status="f_enriched" xml:id="W0019_change_013" xml:lang="en">Generated @xml:id.</change>
                <change who="#MAH #auto" when="2024-10-16" status="f_enriched" xml:id="W0019_change_012" xml:lang="en">Numbered lines.</change>
                <change who="#MAH #auto" when="2024-10-15" status="f_enriched" xml:id="W0019_change_011" xml:lang="en">Annotated hyphenated breaks interrupted by hi and note.</change>
                <change who="#MAH #auto" when="2024-10-14" status="f_enriched" xml:id="W0019_change_010" xml:lang="en">Annotate Hyphenation</change>
                <change who="#MAH #auto" when="2024-10-14" status="f_enriched" xml:lang="en" xml:id="W0019_change_009">Tagged special characters.</change>
                <change who=" #MAH #auto" when="2024-10-10" status="f_enriched" xml:lang="en" xml:id="W0019_change_008">Transformation TEI tite to TEI P5.</change>
                <change who=" #MAH #auto" when="2024-10-10" status="a_raw" xml:lang="en" xml:id="W0019_change_007">Added abbreviations depending on word endings with regex (la), twice.</change>
                <change who=" #MAH #auto" when="2024-10-08" status="a_raw" xml:lang="en" xml:id="W0019_change_006">Summaries, adding @target to ref using @xml:id in milestones</change>
                <change who=" #MAH #auto" when="2024-10-03" status="a_raw" xml:lang="en" xml:id="W0019_change_005">Added @type to list, @unit and @xml:ids to milestone.</change>
                <change who=" #MAH #auto" when="2024-10-01" status="a_raw" xml:lang="en" xml:id="W0019_change_004">Structural annotation.</change>
                <change who="#MAH" when="2024-10-01" status="a_raw" xml:lang="en">5 unclear solved.</change>
                <change who="#CR" when="2024-10-08" status="a_raw" xml:lang="en">Set teiHeader.</change>               
                <change who="#CR" when="2022-10-11" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>