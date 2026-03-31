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
                <title type="short" level="m">Manual de confessores</title>
                <title type="main" level="m">Manual de confessores y penitentes</title>
                <author>
                    <persName ref="author:A0011 gnd:118944053 cerl:cnp01451608" key="Azpilcueta, Martin de">
                        <forename>Martin</forename>
                        <nameLink>de</nameLink>
                        <surname>Azpilcueta</surname>
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
                <editor xml:id="CR">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="orcid:0000-0003-1835-1653">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="unpublished"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
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
                            <persName ref="author:A0011 gnd:118944053 cerl:cnp01451608" key="Azpilcueta, Martin de">
                                <forename>Martin</forename>
                                <nameLink>de</nameLink>
                                <surname>Azpilcueta</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Manual de confessores</title>
                        <title type="main" level="m">Manval De Confessores Y Penitentes, Qve Clara Y Brevemente Contiene, La Vniversal Y Particular Decision De Qvasi Todas Las Dvdas, que en confessiones suelen ocurrir de los pecados, ... en cinco Comentarios de Vsura, Cambios, Symonia mental, Defension del proximo, De hurto notable, &amp; irregularidad ...</title>
                        <title type="245a" level="m">Manual de confessores y penitentes : que clara y breuemente contiene la universal y particular decision de quasi todas las dudas ... </title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010814" key="Coimbra">Coimbra</pubPlace>
                            <date type="firstEd" when="1553">1553</date>
                            <pubPlace role="thisEd" ref="getty:7002835" key="Salamanca">Salamanca</pubPlace>
                            <date type="thisEd" when="1556">1556</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037601092" key="Barreira, João de"><!--not found in CERL-->
                                    <forename>João</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Barreira</surname>
                                </persName>
                                <persName ref="cerl:cni00045922" key="Alvares, João">
                                    <forename>João</forename>
                                    <surname>Álvares</surname>
                                </persName>
                            </publisher>
                            <publisher n="thisEd">
                                <persName ref="gnd:1037609387" key="Portonariis, Andreas de"><!--not found in CERL-->
                                    <forename>Andrea</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Portonarijs</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[16], 797 [i.e. 799] S. ; 4°</extent>
                    </monogr>
                </biblStruct>
                <msDesc type="main">
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink">http://brumario.usal.es/record=b1857195~S1*spi</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <!-- where do facs:W0002-0430 facs:W0002-0431 originate from? -->
                <!--<msDesc type="additional" corresp="facs:W0002-0430 facs:W0002-0431">
                    <msIdentifier>
                        <repository></repository>
                        <idno type="catlink"></idno>
                    </msIdentifier>
                </msDesc>-->
            </sourceDesc>
        </fileDesc>
        
        <profileDesc>
           <langUsage>
              <language ident="es" usage="85" n="main" xml:lang="en">Spanish</language>
              <language ident="la" usage="15" n="marginal" xml:lang="en">Latin</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/W_Head_general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="W0002-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="W0002-00-meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
                <normalization>
                    <p xml:id="W0002-00-meta-pa-0006" xml:lang="en" n="long-s">Long s (<q>ſ</q>) were silently normalized, 
                      i.e. resolved to <q>s</q>.</p>
                    <p xml:id="W0002-00-meta-pa-0007" xml:lang="en" n="head-change">Where the structure of sections does not follow a 
                    "heading - summary - text body" structure in the original, the structure was normalized in TEI (head - list - p). These instances are retrievable through the following 
                    XPath, e.g.: /TEI/text//head[@change='#W0002_change_0010'].</p>
                </normalization>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/Sonderzeichen.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="W0002-00-meta-no-0002"><p xml:id="d1e305">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/Sonderzeichen.xml">project website</ref>.</p></note></char></charDecl>
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
                <change who="#DG #auto" when="2018-09-26" status="a_raw" xml:id="W0002_change_0018" xml:lang="en">Revision of teiHeader.</change>
                <change who="#DG #auto" when="2018-08-07" status="a_raw" xml:id="W0002_change_0017" xml:lang="en">Add language information to structural text units.</change>
                <change who="#DG #auto" when="2018-08-06" status="a_raw" xml:id="W0002_change_0016" xml:lang="en">Reduced excessive hi/@rendition[#it] in summaries.</change>
                <change who="#DG #auto" when="2018-08-02" status="a_raw" xml:lang="en" xml:id="W0002_change_0015">Generally annotated special characters.</change>
                <change who="#DG #auto" when="2018-08-02" status="a_raw" xml:lang="en" xml:id="W0002_change_0014">Annotated (hyphen-based) breaks.</change>
                <change who="#DG #auto" when="2018-08-02" status="a_raw" xml:lang="en" xml:id="W0002_change_0013">Further structural adaptations and validation according to SalTEI.</change>
                <change who="#DG" when="2018-07-16" status="a_raw" xml:id="W0002_change_0012">Revised and restructured teiHeader; resolved cross-references with unclear @target.</change>
                <change who="#CR #DG #auto" when="2018-02-08" status="a_raw" xml:id="W0002_change_0011">Added hyperlinks for summary references</change>
                <change who="#DG" when="2018-01-22" status="a_raw">
                    <list>
                        <item xml:id="W0002_change_0010">Restructured headings in subchapters that originally have a summary-heading-text structure into a normalized heading-summary-text structure; see /TEI/text//head[@change='#W0002_change_0010']</item>
                        <item xml:id="W0002_change_0009">Transformation to TEI, adding basic structural markup</item>
                    </list>
                </change>
                <change who="#AW" when="2015-08-25" status="a_raw" xml:id="W0002_change_0008">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw" xml:id="W0002_change_0007">revision of teiHeader</change>
                <change who="#IC" when="2014-11-12" status="a_raw">
                    <list>
                        <item xml:id="W0002_change_0006">@key bei pubPlace für die Facettierung eingetragen</item>
                        <item xml:id="W0002_change_0005">Wenn wir eine neuere als die Erstausgabe digitalisiert haben, müssen in den Facetten und in den bibl. Angaben die bibl. Daten richtig angezeigt werden. Dazu soll das Impressum der Erastausgabe zusätzlich auf der Seite detais_work.html aufgeführt werden. Deswegen folgendes vorghen.</item>
                        <item xml:id="W0002_change_0004">Regel in Editionsrichtlinien aufnehmen: Wenn wir die erste Ausgabe digitalisieren konnten, werden folgende Angaben verwendet: pubPlace@role=firstEd, date@type=firstEd, publisher@type=firstEd, date@type="summaryFirstEd"</item>
                        <item xml:id="W0002_change_0003">Regel in Editionsrichtlinien aufnehmen: Wenn wir eine andere  Ausgabe digitalisieren müssen, werden züsätzlich zu den Angaben der ersten Ausgabe, Angaben zur vorliegenden Ausgabe gemacht: pubPlace@role=thisEd, date@type=thisEd, publisher@type=
                            thisEd, date@type="summaryThisEd"</item>
                        <item xml:id="W0002_change_0002">Schema-Anpassungen für date@type="summaryFirstEd" (Wert anpassen) und date@type="summaryThisEd" (Wert hinzufügen) vornehmen</item>
                    </list>
                </change>
                <change who="#AW" when="2014-03-26" status="a_raw" xml:id="W0002_change_0001">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>