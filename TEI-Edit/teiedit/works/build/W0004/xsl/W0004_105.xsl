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
                <title type="short" level="m">Tratado de Cuentas</title>
                <title type="main" level="m">Tratado de cue[n]tas</title>
                <author>
                    <persName ref="author:A0019 gnd:130116688 cerl:cnp01232744" key="Castillo, Diego de" full="yes">
                        <forename full="yes">Diego</forename>
                        <nameLink>del</nameLink>
                        <surname full="yes">Castillo</surname>
                    </persName>
                </author>
                <editor xml:id="CB">
                    <persName ref="gnd:138962987" full="yes" role="#scholarly">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="IC">
                    <persName ref="gnd:1022577581" full="yes">
                        <surname full="yes">Caesar</surname>, <forename full="yes">Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                <editor xml:id="MK" ref="gnd:1161481540">
                    <persName>
                        <surname full="yes">Kirchen</surname>, <forename full="yes">Matthias</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
           
            <editionStmt>
               <edition n="1.0.0" xml:id="W0004-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2018-07-10">2018-07-10</date>.
               </edition>
            </editionStmt>
           
            <publicationStmt xml:id="publicationStmt">
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
                    <xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></publisher>
                    </xi:fallback>
                </xi:include>
                <date type="digitizedEd" when="2018-07-10">2018-07-10</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0004</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0004?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0004?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0004?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0004?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0004?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0004?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="2" xml:lang="en">Volume 2</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0019 gnd:130116688 cerl:cnp01232744" key="Castillo, Diego de" full="yes">
                                <forename full="yes">Diego</forename>
                                <nameLink>del</nameLink>
                                <surname full="yes">Castillo</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Tratado de Cuentas</title>
                        <title type="main" level="m">Tratado de cue[n]tas</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002810" key="Burgos">Burgos</pubPlace>
                            <date type="firstEd" when="1522">1522</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00036504" key="Melgar, Alfonso de" full="yes">
                                    <forename full="yes">Alonso</forename>
                                    <nameLink>de</nameLink>
                                    <surname full="yes">Melgar</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">XXVIII Blätter ; 8°</extent>
                        <extent xml:lang="en">XXVIII l. ; 8°</extent>
                        <extent xml:lang="es">XXVIII h. ; 8°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1083752-8" xml:lang="en">Columbia University / Libraries</repository>
                        <idno type="catlink" xml:lang="en">http://clio.columbia.edu/catalog/7480120</idno>
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
              <language ident="es" usage="75" n="main" xml:lang="en">Spanish</language>
              <language ident="la" usage="25" n="marginal" xml:lang="en">Latin</language>
           </langUsage>
        </profileDesc>
     
        <encodingDesc>
            <xi:include href="../meta/works-general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="W0004-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="W0004-00-meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <normalization>
                   <p xml:id="W0004-00-meta-pa-0006" xml:lang="en">Long s (<q>ſ</q>) were silently normalized, 
                      i.e. resolved to <q>s</q>.</p>
                   <p xml:id="W0004-00-meta-pa-0007" xml:lang="de">Schaft-s (<q>ſ</q>) wurden stillschweigend 
                      normalisiert, d.h. als <q>s</q> aufgelöst.</p>
                   <p xml:id="W0004-00-meta-pa-0008" xml:lang="es">La s larga (<q>ſ</q>) fue reemplazada 
                      implícitamente por <q>s</q>.</p>
                </normalization>
            </editorialDecl>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="W0004-00-meta-no-0001">The definition of 
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
                <change who="#DG #auto" when="2018-08-07" status="g_enriched_approved" xml:lang="en">Added xml:lang information to structural units (notes).</change>
                <change who="#DG" when="2018-07-13" status="g_enriched_approved" xml:lang="en">Restructured and extended teiHeader.</change>
                <change who="#DG" when="2018-07-10" status="g_enriched_approved" xml:lang="en">Generate new @xml:id.</change>
                <change who="#DG" when="2018-07-10" status="g_enriched_approved" xml:lang="en">Structural adaptations according to new edition guidelines; revised special characters.</change>
                <change who="#AW" when="2018-06-28" status="g_enriched_approved" xml:lang="en">Revisions, mostly word break/hyphenation problems.</change>
                <change who="#DG" when="2018-06-28" status="f_enriched" xml:lang="en">Formal adaptations to revised edition guidelines; add editors.</change>
                <change who="#AW" when="2018-06-27" status="f_enriched" xml:lang="de">Überarbeitungen bis ca. p. 38.</change>
                <change who="#CB" when="2018-06-22" status="f_enriched" xml:lang="en">Corrections, abbreviation expansions, enrichments (names).</change>
                <change who="#AW" when="2016-04-28" status="e_emended_unenriched" xml:lang="de">Einrückungen korrigiert.</change>
                <change who="#MK" when="2016-03-30" status="d_hyph_approved" xml:lang="de">MK Textkorrekturen.</change>
                <change who="#AW" when="2015-09-13" status="c_hyph_proposed" xml:lang="de">persNames eingefügt, harte Zeilenumbrüche und Element-Reihenfolgen korrigiert.</change>
                <change who="#AW" when="2015-09-11" status="c_hyph_proposed" xml:lang="de">HWB: Zeilenzählung in Marginalnoten korrigiert</change>
                <change who="#IC" when="2014-11-27" status="b_cleared" xml:lang="en">revision of teiHeader</change>
                <change who="#IC" when="2014-09-01" status="b_cleared" xml:lang="de">titleStmt und sourceDesc angepasst</change>
                <change who="#AW" when="2014-03-26" status="b_cleared" xml:lang="de">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="b_cleared" xml:lang="de">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="b_cleared" xml:lang="de">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="b_cleared">
                    <list type="simple">
                        <item xml:id="item_sgfawef1" xml:lang="de">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_sgfawef2" xml:lang="de">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_sgfawef3" xml:lang="de">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_sgfawef4" xml:lang="de">Typen von text und div-tags z.T. angepasst.</item>
                    </list>
                </change>
                <change who="#AW" when="2013-08-22" status="b_cleared" xml:lang="de">Nach Schema-Updates
                    angepasst.</change>
                <change who="#AW" when="2013-08-13" status="a_raw" xml:lang="de">Datei(en) aufgeteilt und mit XInclude
                    zusammengehalten (Header und die div. Teile des mehrbändigen Werkes).</change>
                <change who="#AW" when="2013-08-08" status="a_raw" xml:lang="de">Ausgehend von Testdatensatz W0014 angelegt, um
                    das schwierige Layout abzubilden</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>