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
                <title type="short" level="s">Commentariorum theologicorum ac disputationum in primam secundae sancti Thomae.</title>
                <title type="main" level="s">Commentariorum theologicorum ac disputationum in primam secundae sancti Thomae.</title>
                <title type="volume" level="m" n="1">TOMVS PRIMVS</title>
                <author>
                    <persName ref="author:A0092 gnd:118804065 viaf:20476819 cerl:cnp01379472" key="Vázquez, Gabriel">
                        <forename>Gabriel</forename>
                        <surname>Vázquez</surname>
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
                    <edition n="1.0.0" xml:id="W0105_Vol01-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2026-02-11">2026-02-11</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	   <date type="digitizedEd" when="2026-02-11">2026-02-11</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0105:vol1</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0105:vol1?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0105:vol1?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0105:vol1?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0105:vol1?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0105:vol1?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0105:vol1?format=txt&amp;mode=edit</idno>
                </idno>
         
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="60.1">Volume 60.1</biblScope>
            </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0105"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0092 gnd:118804065 viaf:20476819 cerl:cnp01379472" key="Vázquez, Gabriel">
                                <forename>Gabriel</forename>
                                <surname>Vázquez</surname>
                            </persName>
                        </author>
                        <title type="short" level="s">Commentariorum theologicorum ac disputationum in primam secundae sancti Thomae.</title>
                        <title type="main" level="s">Commentariorum theologicorum ac disputationum in primam secundae sancti Thomae.</title>
                        <title type="volume" level="m" n="1">TOMVS PRIMVS</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7017035" key="Ingolstadt">Ingolstaii</pubPlace>
                            <date type="firstEd" when="1606">1606</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00008383 gnd:1037515404  viaf:122266366" key="Hertsroy, Johannes">
                                    <forename>Ioannis</forename>
                                    <surname>Hertsroy</surname>
                                </persName>
                                <persName ref="cerl:cni00074796 gnd:119607026 viaf:164509226" key="Angermaier, Andreas">
                                    <forename>Andreæ</forename>
                                    <surname>Angermarii</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 741 Seiten, 14 ungezählte Seiten</extent>
                        <extent xml:lang="en">[28], 741, [14] l.</extent>
                        <extent xml:lang="es">[28], 741, [14] h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">Loyola University Library New Orleans. LA.</repository>
                        <idno type="catlink" xml:lang="en">https://lalo.ent.sirsi.net/client/en_US/loyola/search/detailnonmodal/ent:$002f$002fSD_LOYNO$002f0$002fSD_LOYNO:738625/one</idno>
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
                <p xml:id="W0105_Vol01_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#DG #MAH #auto" when="2026-02-11" status="g_enriched_approved" xml:id="W0105_Vol01_change_015" xml:lang="en">teiHeader updated, volume ready for online publication. </change>
                <change who="#CR #MAH #auto" when="2026-02-09" status="f_enriched" xml:id="W0105_Vol01_change_014" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#MAH  #DG #auto" when="2025-02-06" status="f_enriched" xml:id="W0105_Vol01_change_013" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#MAH  #DG #auto" when="2025-02-06" status="f_enriched" xml:id="W0105_Vol01_change_012" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#MAH #DG #auto" when="2025-02-06" status="f_enriched" xml:id="W0105_vol01_change_11" xml:lang="en">Tag unmarked breaks (la) in marginals.</change>
                <change who="#MAH #DG #auto" when="2025-02-06" status="f_enriched" xml:id="W0105_vol01_change_10" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#MAH #DG #auto" when="2026-02-04" status="f_enriched" xml:id="W0105_Vol01_change_09" xml:lang="en">Generated @xml:id.</change>
                <change who="#MAH #DG #auto" when="2026-02-04" status="f_enriched" xml:id="W0105_Vol01_change_008" xml:lang="en">Numbered lines.</change>
                <change who="#DG #MAH #CR #auto" when="2026-01-29" status="f_enriched" xml:id="W0105_Vol01_change_007" xml:lang="en">Annotate Hyphenation</change>
                <change who="#MAH #DG #auto" when="2025-11-27" status="f_enriched" xml:lang="en" xml:id="W0105_Vol01_change_006">Tagged special characters.</change>
                 <change who="#MAH #DG #CR #auto" when="2025-11-27" status="f_enriched" xml:lang="en" xml:id="W0105_Vol01_change_005">Transformation from TEI-Tite to TEI-All.</change>
                  <change who="#MAH #CR #auto" when="2025-11-04" status="a_raw" xml:lang="en" xml:id="W0105_Vol01_change_004">Added (la) abbreviations depending on word structure with regex.</change>
                  <change who="#MAH #auto" when="2025-09-08" status="a_raw" xml:lang="en" xml:id="W0105_Vol01_change_003">Structural annotation in 4 rounds. </change>
                <change who="#CR" when="2025-05-13" status="a_raw" xml:lang="en">Added encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2020-07-30" status="a_raw" xml:lang="en">Set teiHeader.</change>
                <change who="#AW" when="2020" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>