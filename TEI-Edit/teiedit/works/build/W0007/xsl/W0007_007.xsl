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
                <title type="short" level="m">Suma de Tratos y Contratos</title>
                <title type="main" level="m">Tratos Y Contratos De Mercaderes y tratantes discididos y determinados</title>
                <author>
                    <persName ref="author:A0060 gnd:115379762 cerl:cnp01237271" key="Mercado, Tomás de">
                        <forename>Tomás</forename>
                        <nameLink>de</nameLink>
                        <surname>Mercado</surname>
                    </persName>
                </author>
                <editor xml:id="CB">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="IC">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="unpublished"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="unpublished"/>
            </seriesStmt>
          
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0060 gnd:115379762 cerl:cnp01237271" key="Mercado, Tomás de">
                                <forename>Tomás</forename>
                                <nameLink>de</nameLink>
                                <surname>Mercado</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Suma de Tratos y Contratos</title>
                        <title type="main" level="m">Tratos Y Contratos De Mercaderes y tratantes discididos y determinados</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanca</pubPlace>
                            <date type="firstEd" when="1569">1569</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:103759522X cerl:cnp01372311" key="Gast, Matías">
                                    <forename>Matías</forename>
                                    <surname>Gast</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">28 ungezählte Seiten, 249 Blätter, 28 ungezählte Seiten ; 4°</extent>
                        <extent xml:lang="en">[28] p., 249 l., [28] p. ; 4°</extent>
                        <extent xml:lang="es">[28] p., 249 h., [28] p. ; 4°</extent>
                    </monogr>
                </biblStruct>
                <msDesc type="main">
                    <msIdentifier>
                        <repository ref="gnd:5036103-X" xml:lang="de">Staatsbibliothek zu Berlin</repository>
                        <idno type="catlink">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=388031387</idno>
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
              <language ident="es" usage="97" n="main" xml:lang="en">Spanish</language>
              <language ident="la" usage="3" n="marginal" xml:lang="en">Latin</language>
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
        
        <revisionDesc status="a_raw">
            <listChange>
                <change who="#DG" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#DG #auto" when="2018-08-23" status="a_raw" xml:id="W0007_change_0015" xml:lang="en">Created @xml:id.</change>
                <change who="#DG #auto" when="2018-08-22" status="a_raw" xml:lang="en" xml:id="W0007_change_0014">Tagged special characters.</change>
                <change who="#DG #auto" when="2018-08-22" status="a_raw" xml:lang="en" xml:id="W0007_change_0013">Annotated hyphenated breaks.</change>
                <change who="#DG #auto" when="2018-08-22" status="a_raw" xml:id="W0007_change_0012" xml:lang="en">Added cross-references in index.</change>
                <change who="#DG #auto" when="2018-08-21" status="a_raw" xml:lang="en" xml:id="W0007-change-0011">Transformation from TEI Tite to TEI P5; revised teiHeader.</change>
                <change who="#DG" when="2018-08-21" status="a_raw" xml:lang="en">Revised and added structural markup; typified div; combined page-breaking marginal notes.</change>
                <change who="#DG" when="2018-08-20" status="a_raw" xml:lang="en">Reset all revision statuses to a_raw.</change>
                <change who="#DG" when="2016-12-20" status="a_raw" xml:lang="en">Annotated structural divisions, tables of contents, and index; added pagination.</change>
                <change who="#AW" when="2015-08-25" status="a_raw" xml:lang="en">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw" xml:lang="en">revision of teiHeader</change>
                <change who="#IC" when="2014-09-01" status="a_raw" xml:lang="de">titleStmt und sourceDesc angepasst</change>
                <change who="#AW" when="2014-03-26" status="a_raw" xml:lang="de">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="a_raw" xml:lang="de">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="a_raw" xml:lang="de">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="a_raw" xml:lang="de">
                    <list>
                        <item xml:id="item_lgwlwdf4">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_oioiou">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_jlolin">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_ayweedf">Typen von text und div-tags z.T. angepasst.</item>
                    </list>
                </change>
                <change who="#AW" when="2013-08-22" status="a_raw" xml:lang="de">Nach Schema-Updates
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