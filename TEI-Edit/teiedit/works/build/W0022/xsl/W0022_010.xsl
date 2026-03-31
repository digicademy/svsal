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
                <title type="short" level="m">De iure et officiis bellicis et disciplina militari libri III.</title>
                <title type="main" level="m">De iure et officiis bellicis et disciplina militari libri III.</title>
                <author>
                    <persName ref="author:A0008 cerl:cnp01879392 viaf:127826 gnd:117764736" key="Ayala, Balthasar">
                        <forename>Balthasar</forename>
                        <surname>Ayala</surname>
                    </persName>
                </author>
                
        <editor xml:id="MAH" role="#technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
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
            </titleStmt>

           <editionStmt>
                      <edition n="1.0.0" xml:id="W0022-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-05-06">2025-05-06</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2025-05-06">2025-05-06</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0022</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0022?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0022?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0022?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/textsW0022?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0022?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0022?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="47"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                        <persName ref="author:A0008 cerl:cnp01879392 viaf:127826 gnd:117764736" key="Ayala, Balthasar">
                            <forename>Balthasar</forename>
                            <surname>Ayala</surname>
                        </persName>
                        </author>
                        <title type="short" level="m">De iure et officiis bellicis et disciplina militari libri III.</title>
                        <title type="main" level="m">De iure et officiis bellicis et disciplina militari libri III.</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7652526" key="Douai">Douai</pubPlace>
                            <date type="firstEd" when="1582">1582</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00044801 viaf:61429771" key="Bogard, Jean">
                                    <forename>Ioannis</forename>
                                    <surname>Bogardi</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[8], 226, Bl.</extent>
                        <extent xml:lang="en">[8], 226, [16] l.</extent>
                        <extent xml:lang="es">[8], 226, [16] h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">British Library</repository>
                        <idno type="catlink" xml:lang="en">http://explore.bl.uk/BLVU1:LSCOP-ALL:BLL01017650252</idno>
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
 <p xml:id="W0022_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                   Abbreviations are partially resolved.</p>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
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
                <change who="#CR #MAH #auto" when="2025-05-06" status="g_enriched_approved" xml:id="W0022_0012" xml:lang="en">Update of teiHeader, work ready for publication.</change>
                <change who="#CR #MAH #auto" when="2025-05-06" status="f_enriched" xml:id="W0022_0011" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                  <change who="#CR #MAH #auto" when="2025-05-06" status="f_enriched" xml:id="W0022_change_010" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #MAH #auto" when="2025-04-28" status="f_enriched" xml:id="W0022_change_009" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #MAH #auto" when="2024-04-28" status="f_enriched" xml:id="W0022_change_008" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #MAH #auto" when="2025-04-28" status="f_enriched" xml:id="W0022_change_007" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #MAH #auto" when="2025-04-28" status="f_enriched" xml:id="W0022_change_006" xml:lang="en">Numbered lines.</change>
                <change who="#DG #MAH #auto" when="2025-04-28" status="f_enriched" xml:lang="en" xml:id="W0022_change_005">Annotated hyphenated breaks.</change>
                <change who="#DG #MAH #auto" when="2025-04-28" status="f_enriched" xml:lang="en" xml:id="W0022_change_004">Tagged special characters.</change>
                 <change who="#DG #MAH #auto" when="2025-04-15" status="f_enriched" xml:lang="en" xml:id="W0022_change_003">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#MAH #auto" when="2025-04-15" status="a_raw" xml:lang="en" xml:id="W0022_change_002">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#MAH #auto" when="2025-03-11" status="a_raw" xml:lang="en" xml:id="W0022_change_001">Structural annotation.</change>
                <change who="#CR" when="2020-03-23" status="a_raw" xml:lang="en">Set teiHeader.</change>
                <change who="#AW" when="2020-03-14" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>