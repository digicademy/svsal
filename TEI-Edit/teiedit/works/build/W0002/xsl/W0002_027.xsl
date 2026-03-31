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
            <xsl:text>&#xa;</xsl:text>
            <xsl:processing-instruction name="svsal">htmlFragmentationDepth="4"</xsl:processing-instruction>
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
                <title type="short" level="m">Manual de Confessores y Penitentes</title>
                <title type="main" level="m">Manval De Confessores Y Penitentes, Qve Clara Y Brevemente Contiene, La Vniversal 
                    Y Particvlar Decision De Qvasi Todas Las Dvdas, que en las confessiones suelen 
                    ocurrir de los pecados, absoluciones, restituciones, censuras, &amp; irregularidades</title>
                <author>
                    <persName ref="author:A0011 gnd:118944053 cerl:cnp01451608" key="Azpilcueta, Martin de">
                        <forename>Martin</forename>
                        <nameLink>de</nameLink>
                        <surname>Azpilcueta</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
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
                <editor xml:id="CR" role="#additional">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#additional">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="1.0.0" xml:id="W0002-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2019-02-14">2019-02-14</date>.
               </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2019-02-14">2019-02-14</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0002</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0002?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0002?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0002?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0002?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0002?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0002?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="6" xml:lang="en">Volume 6</biblScope>
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
                        <title type="short" level="m">Manual de Confessores y Penitentes</title>
                        <title type="main" level="m">Manval De Confessores Y Penitentes, Qve Clara Y Brevemente Contiene, La Vniversal 
                            Y Particvlar Decision De Qvasi Todas Las Dvdas, que en las confessiones suelen 
                            ocurrir de los pecados, absoluciones, restituciones, censuras, &amp; irregularidades</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7010814" key="Coimbra">Coimbra</pubPlace>
                            <date type="firstEd" when="1549">1549</date>
                            <pubPlace role="thisEd" ref="getty:7002835" key="Salamanca">Salamanca</pubPlace>
                            <date type="thisEd" when="1556">1556</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037601092" key="Barreira, João de">
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
                                <persName ref="gnd:1037609387" key="Portonariis, Andreas de">
                                    <forename>Andrea</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Portonarijs</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 797, das heißt 799 Seiten ; 4°</extent>
                        <extent xml:lang="en">[16], 797 [i.e. 799] p. ; 4°</extent>
                        <extent xml:lang="es">[16], 797 [i.e. 799] p. ; 4°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991002069609705773</idno>
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
              <language ident="es" usage="85" n="main" xml:lang="en">Spanish</language>
              <language ident="la" usage="15" n="marginal" xml:lang="en">Latin</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/works-general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="W0002-00-meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
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
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="W0002-00-meta-no-0002"><p xml:id="d1e305">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/specialchars.xml">project website</ref>.</p></note></char></charDecl>
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
                <change who="#CR" when="2020-09-22" status="g_enriched_approved" xml:id="W0002-change-032" xml:lang="en">teiHeader update. Repository permalink updated.</change>
                <change who="#DG #CR #auto" when="2019-10-24" status="g_enriched_approved" xml:id="W0002-change-031" xml:lang="en">teiHeader update. Added #additional to @role in editor(s).</change>
                <change who="#DG #CR #auto" when="2019-08-07" status="g_enriched_approved" xml:id="W0002-change-030" xml:lang="en">Teiheader update. Added @role to editor.</change>
                <change who="#DG #auto" when="2019-02-14" status="g_enriched_approved" xml:id="W0002-change-029" xml:lang="en">Added publication metadata.</change>
                <change who="#DG #auto" when="2019-01-16" status="g_enriched_approved" xml:id="W0002-change-028" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #auto" when="2019-01-17" status="g_enriched_approved" xml:id="W0002-change-027" xml:lang="en">Numbered lines.</change>
                <change who="#DG #auto" when="2018-12-17" status="g_enriched_approved" xml:id="W0002_change_026" xml:lang="en">Renamed milestones/@unit (article -&gt; number).</change>
                <change who="#DG #auto" when="2018-12-17" status="g_enriched_approved" xml:id="W0002_change_025" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #auto" when="2018-12-17" status="g_enriched_approved" xml:id="W0002_change_024" xml:lang="en">Got @break and @rendition into the right order (pb/lb).</change>
                <change who="#DG" when="2018-12-17" status="g_enriched_approved" xml:lang="en">Correction cross-check with dictionaries.</change>
                <change who="#DG #auto" when="2018-12-12" status="f_enriched" xml:id="W0002_change_022" xml:lang="en">Reduced redundant hi[@rendition eq #it] taggings.</change>
                <change who="#CB" when="2018-12-12" status="f_enriched" xml:lang="en">Extensive corrections.</change>
                <change who="#DG" when="2018-12-10" status="e_emended_unenriched" xml:lang="en">Revision of titles according to RDA standards, localization of extent information.</change>
                <change who="#DG #auto" when="2018-11-08" status="d_hyph_approved" xml:id="W0002_change_020" xml:lang="en">Partially expanded single-character abbreviations.</change>
                <change who="#CB" when="2018-11-08" status="d_hyph_approved" xml:id="W0002_change_0019" xml:lang="en">Corrections/editings.</change>
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