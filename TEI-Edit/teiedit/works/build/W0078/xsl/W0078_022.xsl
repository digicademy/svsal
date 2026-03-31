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
    <teiHeader xmlns:t="http://www.tei-c.org/ns/tite/1.0" xmlns:tite="http://www.tei-c.org/ns/tite/1.0" xmlns:sal="http://salamanca.adwmainz.de">
        <fileDesc>
            
            <titleStmt>
                <title level="m" type="short">Lexicon Iuris Civilis</title>
                <title level="m" type="main">Lexicon Iuris Civilis, Adversvs quosdam insignes Accvrs errores æditum</title>
                <author>
                    <persName ref="author:A0065 cerl:cnp01443478 gnd:118980955" key="Nebrija, Antonio de">
                        <forename>Elio Antonio</forename>
                        <nameLink>de</nameLink>
                        <surname>Nebrija</surname>
                    </persName>
                </author>
                <editor xml:id="PDS" role="#scholarly">
                    <persName ref="orcid:0000-0001-6255-6141">
                        <surname>da Silva Santos</surname>, <forename>Pedro</forename>
                    </persName>
                </editor>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
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
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477">
                        <surname>Thönes</surname>, <forename>Martin</forename>
                    </persName>
                </editor>
                <editor xml:id="IC" role="#additional">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                
                
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0078-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2020-03-31">2020-03-31</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2020-03-31">2020-03-31.</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0078</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0078?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0078?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0078?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0078?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0078?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0078?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="13"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0065 cerl:cnp01443478 gnd:118980955" key="Nebrija, Antonio de">
                                <forename>Elio Antonio</forename>
                                <nameLink>de</nameLink>
                                <surname>Nebrija</surname>
                            </persName>
                        </author>
                        <title level="m" type="short">Lexicon Iuris Civilis</title>
                        <title level="m" type="main">Lexicon Iuris Civilis, Adversvs quosdam insignes Accvrs errores æditum</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1537">1537</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00030497" key="Frellon, Jean">
                                    <forename>Ioannes</forename>
                                    <surname>Frellaeus</surname>
                                </persName>
                                <persName ref="cerl:cni00028532" key="Frellon, François">
                                    <forename>Franciscus</forename>
                                    <surname>Frellaeus</surname>
                                </persName>
                                <persName ref="cerl:cni00033028" key="Barbou, Jean">
                                    <forename>Jean</forename>
                                    <surname> Barbous</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">210 Seiten, 12 ungezählte Seiten</extent>
                        <extent xml:lang="en">210 p., [12] l. ; 8°</extent>
                        <extent xml:lang="es">210 p., [12] h. ; 8°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:5036103-X" xml:lang="en">Staatsbibliothek zu Berlin</repository>
                        <idno type="catlink" xml:lang="de">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=776143530</idno>
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
            <listChange>
                <change who="#CR #auto" when="2020-03-20" status="g_enriched_approved" xml:id="W0078_change_028" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-03-19" status="g_enriched_approved" xml:id="W0078_change_027" xml:lang="en">Generated @xml:id after corrections.</change>
                <change who="#DG #CR #auto" when="2020-03-19" status="g_enriched_approved" xml:id="W0078_change_026" xml:lang="en">Numbered lines after corrections.</change>
                <change who="#DG #CR #auto" when="2020-03-18" status="g_enriched_approved" xml:lang="en" xml:id="W0078_change_024">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2020-03-18" status="g_enriched_approved" xml:id="W0078_change_023" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-03-18" status="g_enriched_approved" xml:id="W0078_change_022" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2020-03-18" status="g_enriched_approved" xml:id="W0078_change_021" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2020-03-19" status="g_enriched_approved" xml:id="W0078_change_025" xml:lang="en">Changed labels in heads.</change>
                <change who="#PDS" when="2020-03-12" status="g_enriched_approved" xml:id="W0078_change_020" xml:lang="en">Second round of corrections (PDS).</change>
                <change who="#PDS" when="2020-03-11" status="g_enriched_approved" xml:id="W0078_change_019" xml:lang="en">First round of corrections (PDS).</change>
                <change who="#DG #CR #auto" when="2019-10-18" status="f_enriched" xml:id="W0078_change_018" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-10-17" status="f_enriched" xml:id="W0078_change_017" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2019-10-17" status="f_enriched" xml:id="W0078_change_016" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-10-17" status="f_enriched" xml:id="W0078_change_015" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-10-17" status="c_hyph_proposed" xml:lang="en" xml:id="W0078_change_014">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-10-17" status="c_hyph_proposed" xml:lang="en" xml:id="W0078_change_013">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" when="2019-10-17" status="a_raw" xml:lang="en" xml:id="W0078-change-012">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR #auto" when="2019-10-17" status="a_raw" xml:lang="en" xml:id="W0078_change_011">'Changed hi @rend right to seg @type gap'</change>
                <change who="#CR #auto" when="2019-10-17" status="a_raw" xml:lang="en" xml:id="W0078_change_010">'Tagged entries with label.'</change>
                <change who="#CR #auto" when="2019-10-16" status="a_raw" xml:lang="en" xml:id="W0078_change_009">Added @type(s) to div(s) and @target to ref.</change>
                <change who="#CR #auto" when="2019-10-16" status="a_raw" xml:lang="en" xml:id="W0078_change_008">Added missing pagination (pb/@n).</change>
                <change who="#CR" when="2019-10-16" status="a_raw" xml:lang="en" xml:id="W0078_change_007">Structural Annotation.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2015-08-28" status="a_raw">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#AW" when="2014-04-17" status="a_raw">In xml importiert (TEI header, Pseudo-WErte in Schema, Autor usw.</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>