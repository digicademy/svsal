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
                <title type="short" level="m">De Iustitia et Iure</title>
                <title type="main" level="m">Fratris Dominici Soto Segouiensis, Theologi, ordinis Prædicatorum, 
                    Cæsareæ Maiestati à sacris confessionibus, Salmantini Professoris, De Iustitia &amp; Iure Libri decem</title>
                <author>
                    <persName ref="author:A0083 gnd:118798111 cerl:cnp01327727" key="Soto, Domingo de">
                        <forename>Domingo</forename>
                        <nameLink>de</nameLink>
                        <surname>Soto</surname>
                    </persName>
                </author>
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
                <editor xml:id="IC" role="#technical">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
                <edition n="1.0.0" xml:id="W0011-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2020-04-27">2020-04-27</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2020-04-27">2020-04-27.</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0011</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0011?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0011?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0011?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0011?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0011?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0011?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="14"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0083 gnd:118798111 cerl:cnp01327727" key="Soto, Domingo de">
                                <forename>Domingo</forename>
                                <nameLink>de</nameLink>
                                <surname>Soto</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iustitia et Iure</title>
                        <title type="main" level="m">Fratris Dominici Soto Segouiensis, Theologi, ordinis Prædicatorum, 
                            Cæsareæ Maiestati à sacris confessionibus, Salmantini Professoris, De Iustitia &amp; Iure Libri decem</title>
                        <imprint>
                           <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanticae</pubPlace>
                           <date type="firstEd" when="1553">1553</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037609387" key="Portonariis, Andreas de">
                                    <forename>Andrea</forename>
                                    <nameLink>à</nameLink>
                                    <surname>Portonariis</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">904 Seiten, 60 ungezählte Seiten ; 2°</extent>
                        <extent xml:lang="en">904, [60] p. ; 2°</extent>
                        <extent xml:lang="es">904, [60] p. ; 2°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">British Library</repository>
                        <idno type="catlink" xml:lang="en">http://explore.bl.uk/primo_library/libweb/action/dlDisplay.do?vid=BLVU1&amp;docId=BLL01003445097</idno>
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
            <listChange ordered="true">
                <change who="#CR #auto" when="2020-04-24" status="g_enriched_approved" xml:id="W0011_change_031" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-04-24" status="g_enriched_approved" xml:id="W0011_change_030" xml:lang="en">Generated @xml:id after corrections.</change>
                <change who="#DG #CR #auto" when="2020-04-24" status="g_enriched_approved" xml:id="W0011_change_029" xml:lang="en">Numbered lines after corrections.</change>
                <change who="#DG #CR #auto" when="2020-04-24" status="g_enriched_approved" xml:lang="en" xml:id="W0011_change_028">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-04-21" status="g_enriched_approved" xml:id="W0011_change_027" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-04-21" status="g_enriched_approved" xml:id="W0011_change_026" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2020-04-02" status="g_enriched_approved" xml:id="W0011_change_025" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2020-04-02" status="g_enriched_approved" xml:id="W0011_change_024" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-04-01" status="g_enriched_approved" xml:id="W0011_change_023" xml:lang="en">Second round of corrections.</change>
                <change who="#CB" when="2020-03-25" status="g_enriched_approved" xml:id="W0011_change_022" xml:lang="en">First round of corrections.</change>
                <change who="#DG #CR #auto" when="2019-06-21" status="f_enriched" xml:id="W0011_change_021" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#CR #DG #auto" when="2019-05-16" status="f_enriched" xml:id="W0011_change_020" xml:lang="en">Automatically expanded abbreviations (la marginal).</change>
                <change who="#CR #DG #auto" when="2019-05-16" status="f_enriched" xml:id="W0011_change_019" xml:lang="en">Automatically expanded abbreviations (la main).</change>
                <change who="#DG #CR #auto" when="2019-03-22" status="f_enriched" xml:id="W0011_change_0018" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-03-22" status="f_enriched" xml:id="W0011_change_0017" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-03-22" status="c_hyph_proposed" xml:lang="en" xml:id="W0011_change_0016">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-04-03" status="c_hyph_proposed" xml:lang="en" xml:id="W0011_change_0015">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" when="2019-03-20" status="a_raw" xml:lang="en" xml:id="W0011-00-change-00014">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR #auto" when="2019-03-20" status="a_raw" xml:lang="en">Added missing pb@n.</change>
                <change who="#CR" when="2019-03-12" status="a_raw" xml:lang="en">Structural annotation.</change>
                <change who="#DG" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2015-08-28" status="a_raw">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-18" status="a_raw">titleStmt und sourceDesc angepassrt</change>
                <change who="#AW" when="2014-03-26" status="a_raw">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="a_raw">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="a_raw">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="a_raw">
                    <list>
                        <item xml:id="item_gjtddx">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_ljchfsd">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_segdtzj">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_awef33v5">Typen von text und div-tags z.T. angepasst.</item>
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