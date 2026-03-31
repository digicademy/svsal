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
                <title type="short" level="m">De Iure et Iustitia Decisiones</title>
                <title type="main" level="m">De Iure &amp; Iustitia Decisiones</title>
                <author>
                    <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237" key="Báñez, Domingo">
                        <forename>Domingo</forename>
                        <surname>Báñez</surname>
                    </persName>
                </author>
                <editor role="scholarly" xml:id="CB">
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
                    </persName>
                </editor>
                <editor role="scholarly" xml:id="JLE">
                    <persName ref="orcid:0000-0002-9256-8490">
                        <surname>Egío García</surname>, <forename>José Luis</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="CR">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                <editor role="technical" xml:id="IC">
                    <persName ref="gnd:1022577581" full="yes">
                        <surname full="yes">Caesar</surname>, <forename full="yes">Ingo</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="1.0.0" xml:id="W0003-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2019-07-04">2019-07-04</date>.
               </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2019-07-04">2019-07-04</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0003</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0003?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0003?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0003?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0003?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0003?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0003?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="9" xml:lang="en">Volume 9</biblScope>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237" key="Báñez, Domingo">
                                <forename>Domingo</forename>
                                <surname>Báñez</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iure et Iustitia Decisiones</title>
                        <title type="main" level="m">De Iure &amp; Iustitia Decisiones</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanticae</pubPlace>
                            <date type="firstEd" when="1594">1594</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00045680" key="Renaut, Andrés">
                                    <forename>Andreas</forename>
                                    <surname>Renaut</surname>
                                </persName>
                                <persName ref="cerl:cni00046508" key="Renaut, Juan">
                                    <forename>Ioannes</forename>
                                    <surname>Renaut</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">14 ungezählte Seiten, 654 Seiten, 18 ungezählte Seiten ; 2°</extent>
                        <extent xml:lang="en">[14], 654, [18] p. ; 2°</extent>
                        <extent xml:lang="es">[14], 654, [18] p. ; 2°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink">http://brumario.usal.es/record=b1508195~S6*spi</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#facs:W0003-0373 #facs:W0003-0374 #facs:W0003-0454 #facs:W0003-0455 #facs:W0003-0630 #facs:W0003-0631">
                    <msIdentifier>
                        <repository ref="gnd:25995-0" xml:lang="es">Biblioteca Histórica Fondo Antiguo, Universidad Complutense de Madrid</repository>
                        <idno type="catlink">https://ucm.on.worldcat.org/oclc/1025014839</idno>
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
              <language ident="es" xml:lang="en">Español</language>
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
                <change who="#DG #auto" when="2019-07-03" status="g_enriched_approved" xml:lang="en" xml:id="W0003_change_030">Revised teiHeader, set fragmentationDepth to 4, and status update.</change>
                <change who="#DG #auto" when="2019-07-03" status="f_enriched" xml:lang="en" xml:id="W0003_change_029">Generated xml:id.</change>
                <change who="#DG #auto" when="2019-07-03" status="f_enriched" xml:lang="en" xml:id="W0003_change_028">Numbered lines.</change>
                <change who="#DG #auto" when="2019-07-02" status="d_hyph_approved" xml:lang="en" xml:id="W0003_change_027">Tagged special characters.</change>
                <change who="#DG #auto" when="2019-07-02" status="d_hyph_approved" xml:id="W0003_change_026" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #auto" when="2019-07-02" status="d_hyph_approved" xml:id="W0003_change_025" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #auto" when="2019-07-01" status="d_hyph_approved" xml:id="W0003_change_024" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #auto" when="2019-07-01" status="d_hyph_approved" xml:id="W0003_change_023" xml:lang="en">Structural changes: div/@type=commented to div/@type=source, tei:cit to tei:bibl</change>
                <change who="#CB" when="2019-07-01" status="f_enriched" xml:id="W0003_change_022" xml:lang="en">Final scholarly revisions, and further annotation of citations.</change>
                <change who="#JLE" when="2019-06-27" status="d_hyph_approved" xml:id="W0003_change_021" xml:lang="en">Re-merged two parts.</change>
                <change who="#JLE" when="2019-06-27" status="d_hyph_approved" xml:id="W0003_change_019" xml:lang="en">Corrections (until facs:W0003-0345).</change>
                <change who="#CB" when="2019-06-20" status="c_hyph_proposed" xml:id="W0003_change_018" xml:lang="en">Corrections (from facs:W0003-0346 until end).</change>
                <change who="#DG" when="2019-04-08" status="c_hyph_proposed" xml:id="W0003_change_017" xml:lang="en">Split into two parts for correction (first part until facs:W0003-0345).</change>
                <change who="#DG #auto" when="2019-04-08" status="c_hyph_proposed" xml:id="W0003_change_016" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#JLE" when="2019-04-05" status="c_hyph_proposed" xml:id="W0003_change_010" xml:lang="en">Corrections.</change>
                <change who="#DG #auto" when="2019-03-28" status="c_hyph_proposed" xml:id="W0003_change_009" xml:lang="en">Automatically expanded abbreviations (es).</change>
                <change who="#DG #auto" when="2019-03-28" status="c_hyph_proposed" xml:id="W0003_change_008" xml:lang="en">Automatically expanded abbreviations (la).</change>
                <change who="#CR #auto" when="2019-02-20" status="c_hyph_proposed" xml:id="W0003_change_0007" xml:lang="en">Generated @xml:id.</change>
                <change who="#CR #auto" when="2019-02-20" status="c_hyph_proposed" xml:id="W0003_change_0006" xml:lang="en">Numbered lines.</change>
                <change who="#CR #auto" when="2019-02-20" status="c_hyph_proposed" xml:lang="en" xml:id="W0003_change_0005">Tagged special characters.</change>
                <change who="#CR #DG #auto" when="2019-02-20" status="c_hyph_proposed" xml:lang="en" xml:id="W0003_change_0004">Annotated hyphenated breaks.</change>
                <change who="#CR" when="2019-02-21" status="a_raw" xml:lang="en" xml:id="W0003_change_0008">Milestones were replaced by note @anchored="true".</change>
                <change who="#CR #auto" when="2019-02-19" status="a_raw" xml:lang="en" xml:id="W0003-00-change-0003">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR #auto" when="2019-02-19" status="a_raw" xml:lang="en" xml:id="W0003_change_0002">Added @n to pb.</change>
                <change who="#CR" when="2019-02-12" status="a_raw" xml:lang="en" xml:id="W0003_change_0001">Structural Annotation</change>
                <change who="#DG" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-12" status="a_raw">
                    <list>
                        <item xml:id="item_sgeg">@key bei pubPlace für die Facettierung eingetragen</item>
                        <item xml:id="item_sdjqw">Wenn wir eine neuere als die Erstausgabe digitalisiert haben, müssen in den Facetten und in den bibl. Angaben die bibl. Daten richtig angezeigt werden. Dazu soll das Impressum der Erastausgabe zusätzlich auf der Seite detais_work.html aufgeführt werden. Deswegen folgendes vorghen.</item>
                        <item xml:id="item_jsdbf">Regel in Editionsrichtlinien aufnehmen: Wenn wir die erste Ausgabe digitalisieren konnten, werden folgende Angaben verwendet: pubPlace@role=firstEd, date@type=firstEd, publisher@type=firstEd, date@type="summaryFirstEd"</item>
                        <item xml:id="item_nasljw">Regel in Editionsrichtlinien aufnehmen: Wenn wir eine andere  Ausgabe digitalisieren müssen, werden züsätzlich zu den Angaben der ersten Ausgabe, Angaben zur vorliegenden Ausgabe gemacht: pubPlace@role=thisEd, date@type=thisEd, publisher@type=
                            thisEd, date@type="summaryThisEd"</item>
                        <item xml:id="item_sdljbh">Schema-Anpassungen für date@type="summaryFirstEd" (Wert anpassen) und date@type="summaryThisEd" (Wert hinzufügen) vornehmen</item>
                    </list>
                </change>
                <change who="#IC" when="2014-09-25" status="a_raw">W0003 Header angelegt</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>