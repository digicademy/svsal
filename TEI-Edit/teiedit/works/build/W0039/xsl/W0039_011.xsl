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
    
    
<xsl:variable name="teiHeader" xml:space="preserve"><xsl:copy-of select="preceding-sibling::processing-instruction('htmlFragmentationDepth')[1]"></xsl:copy-of><teiHeader>    
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Summa Angelica</title>
                <title type="main" level="m">Svmma Angelica Reverendi Patris fratris Angeli de clauasio secundu[m] 
                    primu[m] exe[m]plar ipsius hac editione castigata</title>
                <author>
                    <persName ref="author:A0024 cerl:cnp00086868 gnd:119253593" key="Clavasio, Angel de">
                        <forename>Angel</forename>
                        <nameLink>de</nameLink>
                        <surname>Clavasio</surname>
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
            <editor xml:id="AW" role="#technical">
                <persName ref="gnd:108835820">
                    <surname>Wagner</surname>, <forename>Andreas</forename>
                </persName>
            </editor>
            <editor xml:id="IC" role="#technical">
                <persName ref="gnd:1022577581">
                    <surname>Caesar</surname>, <forename>Ingo</forename>
                </persName>
            </editor>
            <editor xml:id="DG" role="#technical">
                <persName ref="orcid:0000-0002-0273-3844">
                    <surname>Glück</surname>, <forename>David</forename>
                </persName>
            </editor>
            <editor xml:id="MT" role="#technical">
                <persName ref="orcid:0000-0002-1488-6477" full="yes">
                    <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                </persName>
            </editor>
            
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0039-version1" xml:lang="en">
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
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0039</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0039?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0039?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0039?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0039?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0039?format=txt&amp;mode=orig</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="29"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0024 cerl:cnp00086868 gnd:119253593" key="Clavasio, Angel de">
                                <forename>Angel</forename>
                                <nameLink>de</nameLink>
                                <surname>Clavasio</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Summa Angelica</title>
                        <title type="main" level="m">Svmma Angelica Reverendi Patris fratris Angeli de clauasio secundu[m] 
                            primu[m] exe[m]plar ipsius hac editione castigata</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1534">1534</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00034721" key="Gabiano, Scipion de">
                                    <forename>Scipio</forename> 
                                    <nameLink>de</nameLink> 
                                    <surname>Gabiano</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[40], CCCLXXX Bl. ; 8°</extent>
                        <extent xml:lang="en">[40], CCCLXXX l. ; 8°</extent>
                        <extent xml:lang="es">[40], CCCLXXX h. ; 8°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/search?oclcno=242759575&amp;db=100</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="rotunda" xml:lang="en">Rotunda typeface</typeNote>
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
                <p xml:id="W0039_RW">Reference works contain automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2024-04-09" status="g_enriched_approved" xml:id="W0039_change_026" xml:lang="en">teiHeader update for publication.</change>
                <change who="#DG #CR #auto" when="2020-08-03" status="f_enriched" xml:id="W0039_change_025" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-07-31" status="f_enriched" xml:id="W0039_change_024" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-07-31" status="f_enriched" xml:id="W0039_change_023" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-04-30" status="c_hyph_proposed" xml:lang="en" xml:id="W0039_change_021">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-04-30" status="c_hyph_proposed" xml:lang="en" xml:id="W0039_change_020">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" xml:id="W0039_change_019" when="2020-04-29" status="a_raw" xml:lang="en">Transformation from TEI-tite to TEI-All.</change>
                <change who="#CR" xml:id="W0039_change_022" when="2020-07-31" status="a_raw" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" xml:id="W0039_change_018" when="2020-04-29" status="a_raw" xml:lang="en">Added @xml:id and @unit to milestone.</change>
                <change who="#DG #CR #auto" xml:id="W0039_change_017" when="2020-04-28" status="a_raw" xml:lang="en">Tagged @type(s) to div(s) and @target to ref.</change>
                <change who="#DG #CR #auto" xml:id="W0039_change_016" when="2020-01-16" status="a_raw" xml:lang="en">Corrected hi @rend.</change>
                <change who="#DG #CR #auto" xml:id="W0039_change_015" when="2020-01-14" status="a_raw" xml:lang="en">Added missing pagination @n in pb.</change>
                <change who="#DG #CR" xml:id="W0039_change_014" when="2020-01-14" status="a_raw" xml:lang="en">Structural annotation.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2015-08-28" status="a_raw">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-18" status="a_raw">titleStmt und sourceDesc angepassrt</change>
                <change who="#AW" when="2014-03-26" status="a_raw">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="a_raw">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="a_raw">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="a_raw">
                    <list>
                        <item xml:id="item_saaswca3">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_sefywca">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_sxcgbxfgb">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_cyyd4s">Typen von text und div-tags z.T. angepasst.</item>
                    </list>
                </change>
                <change who="#AW" when="2013-08-22" status="a_raw">Nach Schema-Updates
                    angepasst.</change>
                <change who="#AW" when="2013-08-13" status="a_raw">Datei(en) aufgeteilt und mit XInclude
                    zusammengehalten (Header und die div. Teile des mehrbändigen Werkes).</change>
                <change who="#AW" when="2013-08-08" status="a_raw">Ausgehend von Testdatensatz W0014 angelegt, um
                    das schwierige Layout abzubilden</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>