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
       <teiHeader xml:lang="en">
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">De Ivstitia Et Ivre</title>
                <title type="main" level="m">De Ivstitia Et Ivre</title> 
                <author>
                    <persName ref="author:A0022 cerl:cnp00104182 viaf:56215005 gnd:100075401" key="Castro Palao, Fernando de">
                        <forename>Fernando</forename>
                        <nameLink>de</nameLink>
                        <surname>Castro Palao</surname>
                    </persName>
                </author>
                
 <editor xml:id="MAH" role="#scholarly #technical">
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
              <edition n="1.0.0" xml:id="W0038-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2025-08-04">2025-08-04</date>.
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
            	<date type="digitizedEd" when="2025-08-04">2025-08-04</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0038</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0038?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0038?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0038?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/textsW0038?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0038?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0038?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en">
                            <ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref>
                        </title>
                    </xi:fallback>
                </xi:include>
                   <biblScope unit="volume" n="53">Volume 53</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0022 cerl:cnp00104182 viaf:56215005 gnd:100075401" key="Castro Palao, Fernando de">
                                <forename>Fernando</forename>
                                <nameLink>de</nameLink>
                                <surname>Castro Palao</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Ivstitia Et Ivre</title>
                        <title type="main" level="m">De Ivstitia Et Ivre</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lvgdvni</pubPlace>
                            <date type="firstEd" when="1651">1651</date>
                            <publisher n="firstEd"> 
                                <persName ref="cerl:cni00028037" key="Arnaud, Laurent">
                                    <forename>Laurent</forename>
                                    <surname>Arnaud</surname>
                                </persName>
                                <persName ref="cerl:cni00025649" key="Borde, Philippe">
                                    <forename>Philippe</forename>
                                    <surname>Borde</surname>
                                </persName>
                                <persName ref="cerl:cni00006903" key="Rigaud, Claude">
                                    <forename>Claude</forename>
                                    <surname>Rigaud</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 608, das heißt 612 Seiten, 42 ungezählte Seiten</extent>
                        <extent xml:lang="en">[16] p., 608 p., [42] p.</extent>
                        <extent xml:lang="es">[16] p., 608 p., [42] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/title/BV035544151</idno>
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
                <xi:fallback>
                    <projectDesc>
                        <p xml:id="meta-pa-0004">
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref>
                        </p>
                    </projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback>
                        <p xml:id="meta-pa-0005">
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref>
                        </p>
                    </xi:fallback>
                </xi:include>
                <p xml:id="W0038_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                    Abbreviations are partially resolved.</p>
            </editorialDecl>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback>
                    <charDecl>
                        <char xml:lang="en">
                            <note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/specialchars.xml">project website</ref>.</note>
                        </char>
                    </charDecl>
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
                <change who="#DG #MAH #auto" when="2025-08-04" status="g_enriched_approved" xml:id="W0038_change_014" xml:lang="en">teiHeader Update, ready for publication.</change>
                <change who="#CR #MAH #auto" when="2025-08-04" status="f_enriched" xml:id="W0038_change_013" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #MAH #auto" when="2025-07-31" status="f_enriched" xml:id="W0038_change_012" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #MAH #auto" when="2025-07-31" status="f_enriched" xml:id="W0038_change_011" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #MAH #auto" when="2025-07-31" status="f_enriched" xml:id="W0038_change_010" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #MAH #auto" when="2025-06-16" status="f_enriched" xml:id="W0038_change_009" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #MAH #auto" when="2025-06-13" status="f_enriched" xml:id="W0038_change_008" xml:lang="en">Numbered lines.</change>
                <change who="#DG #MAH #auto" when="2025-06-11" status="f_enriched" xml:lang="en" xml:id="W0038_change_007">Annotated hyphenated breaks.</change>
                <change who="#DG #MAH #auto" when="2025-06-11" status="f_enriched" xml:lang="en" xml:id="W0038_change_006">Tagged special characters.</change>
                <change who="#DG #MAH #auto" when="2025-06-11" status="f_enriched" xml:lang="en" xml:id="W0065_change_05">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#DG #MAH #auto" when="2025-06-06" status="a_raw" xml:lang="en" xml:id="W0038_change_04">Added (la) abbreviations depending on word structure with regex.</change>
                <change who=" #MAH #auto" when="2025-06-05" status="a_raw" xml:lang="en" xml:id="W0038_change_03">Structural annotation for milestne and refs. </change>
                <change who=" #MAH #auto" when="2025-06-05" status="a_raw" xml:lang="en" xml:id="W0038_change_02">Structural annotation. </change>
                <change who="#CR" when="2025-05-08" status="a_raw" xml:lang="en">Added encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2023-06-15" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>