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
                <title type="short" level="m">Tractatvs De Legibvs</title>
                <title type="main" level="m">Tractatvs De Legibvs, Ac Deo Legislatore</title>
                <author>
                    <persName ref="author:A0084 gnd:118619799 cerl:cnp01240285" key="Suárez, Francisco">
                        <forename>Francisco</forename>
                        <surname>Suárez</surname>
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
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>                
                <editor xml:id="IC" role="#technical">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
                
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0012-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2026-08-20">2026-08-20</date>.
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
                <date type="digitizedEd" when="2026-08-20">2026-08-20</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0012</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0012?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0012?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0012?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0012?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0012?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0012?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="66">Volume 66</biblScope>
           </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0084 gnd:118619799 cerl:cnp01240285" key="Suárez, Francisco">
                                <forename>Francisco</forename>
                                <surname>Suárez</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Tractatvs De Legibvs</title>
                        <title type="main" level="m">Tractatvs De Legibvs, Ac Deo Legislatore</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010814" key="Coimbra">Conimbricæ</pubPlace>
                            <date type="firstEd" when="1612">1612</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00009499" key="Loureiro, Diogo Gomes de">
                                    <forename>Didacus</forename> 
                                    <surname>Gomez de Loureyro</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[8], 1266, [30] S. ; 2º</extent>
                        <extent xml:lang="en">[8], 1266, [30] p. ; 2º</extent>
                        <extent xml:lang="es">[8], 1266, [30] p. ; 2º</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">British Library</repository>
                        <idno type="catlink" xml:lang="en">http://explore.bl.uk/BLVU1:LSCOP-ALL:BLL01017661985</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#facs:W0012-0006 #facs:W0012-0007 #facs:W0012-0008 #facs:W0012-0009">
                    <msIdentifier>
                        <repository ref="gnd:1215790-9" xml:lang="pt">Biblioteca Pública Municipal do Porto</repository>
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
                <p xml:id="W0012_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2026-08-20" status="g_enriched_approved" xml:id="W0012_change_032" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2026-08-19" status="f_enriched" xml:id="W0012_change_031" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2026-08-19" status="f_enriched" xml:id="W0012_change_030" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2025-10-08" status="f_enriched" xml:id="W0012_change_029" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-10-16" status="f_enriched" xml:id="W0012_change_028" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-10-16" status="f_enriched" xml:id="W0012_change_027" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-10-16" status="f_enriched" xml:lang="en" xml:id="W0012_change_026">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2025-10-01" status="f_enriched" xml:id="W0012_change_024" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2025-10-07" status="a_raw" xml:lang="en" xml:id="W0012_change_023">Transformation TEI tite to TEI P5.</change>
                <change who="#CR #auto" when="2025-10-01" status="a_raw" xml:lang="en" xml:id="W0012_change_022">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#MAH" when="2025-09-18" status="g_enriched_approved" xml:lang="en" xml:id="W0012_change_021">Unclear resolution second round (MAH).</change>
                <change who="#CR #auto" when="2019-10-14" status="a_raw" xml:lang="en" xml:id="W0012_change_020">Added nested lists and @type in Index.</change>
                <change who="#CR #auto" when="2019-09-23" status="a_raw" xml:lang="en" xml:id="W0012_change_019">Added @target(s) in tables of contents.</change>
                <change who="#CR #auto" when="2019-09-23" status="a_raw" xml:lang="en" xml:id="W0012_change_018">Added @type to div2 and div3.</change>
                <change who="#CR #auto" when="2019-09-19" status="a_raw" xml:lang="en" xml:id="W0012_change_017">Added missing pagination (pb/@n).</change>
                <change who="#CR #auto" when="2025-10-07" status="a_raw" xml:lang="en" xml:id="W0012_change_016">Tagged milestone(s).</change>
                <change who="#CR #MAH" when="2025-09-18" status="a_raw" xml:lang="en" xml:id="W0012_change_015">Structural annotation and unclear first round (CR).</change>
                <change who="#DG" when="2019-03-06" status="a_raw" xml:lang="en">Added msDesc for facsimiles from BPMP.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2015-08-28" status="a_raw">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-09-01" status="a_raw">titleStmt und sourceDesc angepassrt</change>
                <change who="#AW" when="2014-03-26" status="a_raw">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="a_raw">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="a_raw">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="a_raw">
                    <list>
                        <item xml:id="item_safrgaef">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_sfrgawev">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_sfgebtq3">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_ljjaskiz">Typen von text und div-tags z.T. angepasst.</item>
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