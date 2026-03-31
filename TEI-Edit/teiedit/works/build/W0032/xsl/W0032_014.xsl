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
                <title type="short" level="m">Interpretatio Ad Aliquas Leges Recopilationis Regni Castellae.</title>
                <title type="main" level="m">Interpretatio Ad Aliquas Leges Recopilationis Regni Castellae; explicatæq; quæstiones plures, anteanon ita diſcuſſæ, in praxi frequentes iudicibus quibuſcumq; nec non cauſidicis , &amp; in Scholis vtiles, ribus, &amp; confeſſarijs</title>
                <author>
                    <persName ref="author:A0017 viaf:18960292" key="Carrasco del Saz, Francisco">
                        <forename>Francisco</forename>
                        <surname>Carrasco del Saz</surname>
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
               <edition n="1.0.0" xml:id="W0032-version1" xml:lang="en">
   Complete digitized edition, <date type="digitizedEd" when="2025-05-21">2025-05-21</date>.
</edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2025-05-21">2025-05-21</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0032</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0032?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0032?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0032?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/textsW0032?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0032?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0032?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
             <biblScope unit="volume" n="49">Volume 49</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0017 viaf:18960292" key="Carrasco del Saz, Francisco">
                                <forename>Francisco</forename>
                                <surname>Carrasco del Saz</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Interpretatio Ad Aliquas Leges Recopilationis Regni Castellae.</title>
                        <title type="main" level="m">Interpretatio Ad Aliquas Leges Recopilationis Regni Castellae; explicatæq; quæstiones plures, anteanon ita diſcuſſæ, in praxi frequentes iudicibus quibuſcumq; nec non cauſidicis , &amp; in Scholis vtiles, ribus, &amp; confeſſarijs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008676" key="Sevilla">Hispali</pubPlace>
                            <date type="firstEd" when="1620">1620</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cnp01036829 viaf:363305 gnd:100797849" key="Contreras, Gerónimo de">
                                    <forename>Hieronimum</forename>
                                    <nameLink>a</nameLink>
                                    <surname>Contreras</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">14 ungezählte Seiten, 198 Blätter, 49 ungezählte Seiten, 1 ungezähltes Blatt</extent>
                        <extent xml:lang="en">[14], 198, [49], [1] l.</extent>
                        <extent xml:lang="es">[14], 198, [49], [1] h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">British Library</repository>
                        <idno type="catlink" xml:lang="en">http://explore.bl.uk/BLVU1:LSCOP-ALL:BLL01000615224</idno>
                    </msIdentifier>
                    
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc status="a_raw" corresp="#facs:W0032-0016">
                    <msIdentifier>
                        <repository ref="gnd:7721988-0" xml:lang="es">Google digitized.</repository>
                        <idno type="catlink" xml:lang="en">https://hdl.handle.net/2027/ucm.5319067854</idno>
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
                <normalization>
                   <p xml:id="meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
 <p xml:id="W0032_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
<change who="#DG #MAH #auto" when="2025-05-23" status="g_enriched_approved" xml:id="W0032_change_17" xml:lang="en">Update of teiHeader, ready for publication. </change>
 <change who="#DG #MAH #auto" when="2025-05-23" status="f_enriched" xml:id="W0032_change_16" xml:lang="en">Reduced excessive whitespace.</change>
<change who="#MAH" when="2025-05-23" status="f_enriched" xml:id="W0032_change_15" xml:lang="en">Corrections of expansions in title.</change>
                <change who="#CR #MAH #auto" when="2025-05-22" status="f_enriched" xml:id="W032_change_014" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#MAH #DG #auto" when="2025-05-20" status="f_enriched" xml:id="W0032_change_013" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#MAH #DG #auto" when="2025-05-20" status="f_enriched" xml:id="W0032_change_012" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#MAH #DG #auto" when="2025-05-20" status="f_enriched" xml:id="W0032_change_011" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#MAH #DG #auto" when="2025-05-20" status="f_enriched" xml:id="W0032_change_010" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#MAH #DG #auto" when="2025-05-20" status="f_enriched" xml:id="W0032_change_009" xml:lang="en">Generated @xml:id.</change>
                <change who="#MAH #DG #auto" when="2025-05-20" status="f_enriched" xml:id="W0032_change_008" xml:lang="en">Numbered lines.</change>
                <change who="#MAH #DG #auto" when="2025-05-19" status="f_enriched" xml:lang="en" xml:id="W0032_change_007">Annotated hyphenated breaks.</change>
                <change who="#MAH #DG #auto" when="2025-05-19" status="f_enriched" xml:lang="en" xml:id="W0032_change_006">Tagged special characters.</change>
  <change who="#MAH #DG #auto" when="2025-05-19" status="a_raw" xml:lang="en" xml:id="W0032_change_005">Transformation from TEI-Title to TEI-P5. </change>
<change who="#MAH #CR #auto" when="2025-05-19" status="a_raw" xml:lang="en" xml:id="W0032_change_004">Added (es) abbreviations depending on word structure with regex</change>
 <change who="#MAH #CR #auto" when="2025-05-19" status="a_raw" xml:lang="en" xml:id="W0032_change_003">Added (la) abbreviations depending on word structure with regex</change>
 <change who="#MAH  #auto" when="2025-05-19" status="a_raw" xml:lang="en" xml:id="W0032_change_002">Structural annotation.</change>
                <change who="#CR" when="2020-06-23" status="a_raw" xml:lang="en">Set teiHeader.</change>
                <change who="#AW" when="2019" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>