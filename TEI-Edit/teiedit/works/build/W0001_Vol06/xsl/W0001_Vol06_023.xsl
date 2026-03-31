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
                <title type="short" level="m">Thesaurus Indicus, Vol. 6</title>
                <title type="main" level="m">R. P. Didaci De Avendaño Societatis Iesv,
                    Cvrsvs Consvmmatvs, sive Avctarii Indici Tomus Quartus, Et Thesauri Tomus Sextus,
                    Multa continens peculiaria , &amp; generatim utilia</title>
                <title type="volume" level="m" n="6">Tomus Sextus</title>
                <author>
                    <persName ref="author:A0007 gnd:133542521 cerl:cnp01376179" key="Avendaño, Diego de" full="yes">
                        <forename full="yes">Diego</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Avendaño</surname>
                    </persName>
                </author>
                <editor xml:id="JLE" role="#scholarly"> 
                    <persName ref="orcid:0000-0002-9256-8490" full="yes"> 
                    <surname full="yes">Egío García</surname>, <forename full="yes">José Luis</forename> 
                    </persName> 
                </editor>
                <editor xml:id="CR" role="#technical"> 
                    <persName ref="orcid:0000-0001-5095-1793" full="yes"> 
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename> 
                    </persName> 
                </editor>
                <editor xml:id="AW" role="#technical"> 
                    <persName ref="gnd:108835820" full="yes"> 
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename> 
                    </persName> 
                </editor>
                <editor xml:id="DG" role="#technical"> 
                    <persName ref="orcid:0000-0002-0273-3844" full="yes"> 
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename> 
                    </persName> 
                </editor>
                <editor xml:id="IC" role="#technical"> 
                    <persName ref="gnd:1022577581" full="yes"> 
                        <surname full="yes">Caesar</surname>, <forename full="yes">Ingo</forename> 
                    </persName> 
                </editor>
                <editor xml:id="MT" role="#additional"> 
                    <persName ref="orcid:0000-0002-1488-6477" full="yes"> 
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename> 
                    </persName> 
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="1.0.0" xml:id="W0001_Vol06-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2021-02-08">2021-02-08</date>.
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
            	<date type="digitizedEd" when="2021-02-08">2021-02-08</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0001:vol6</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0001:vol6?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0001:vol6?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0001:vol6?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0001:vol6?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0001:vol6?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0001:vol6?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="11.6">Volume 11.6</biblScope>
            </seriesStmt>
                        
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0001"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:0007 gnd:133542521 cerl:cnp01376179" key="Avendaño, Diego de" full="yes">
                                <forename full="yes">Diego</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Avendaño</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Thesaurus Indicus, Vol. 6</title>
                        <title type="main" level="m">R. P. Didaci De Avendaño Societatis Iesv,
                            Cvrsvs Consvmmatvs, sive Avctarii Indici Tomus Quartus, Et Thesauri Tomus Sextus,
                            Multa continens peculiaria , &amp; generatim utilia</title>
                        <title type="volume" level="m" n="6">Tomus Sextus</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7007856" key="Antwerpen">Antverpiae</pubPlace>
                            <date type="firstEd" when="1686">1686</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00031626 gnd:123414245" key="Meurs, Jacob van" full="yes">
                                    <forename full="yes">Jacobus</forename>
                                    <surname full="yes">Meursius</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[12], 516, [22] S. ; 2°</extent>
                        <extent xml:lang="en">[12], 516, [22] p. ; 2°</extent>
                        <extent xml:lang="es">[12], 516, [22] p. ; 2°</extent>
                    </monogr>
                    <series>
                        <title type="main" level="s" ref="work:W0001">R. P. Didaci De Avendaño Societatis Iesv, Segoviensis, In Pervvio iam pridem publici &amp; 
                            primarij S. Theologiæ Professoris, &amp; in Sacro Inquisitionis Sanctæ Tribunali adlecti Censoris, 
                            Thesavrvs Indicvs, Sev Generalis Instrvctor pro regimine conscientiæ, in iis quæad Indias spectant</title>
                        <biblScope unit="volume" n="6" xml:lang="la">Tomus Sextus</biblScope>
                    </series>
                </biblStruct>
                <msDesc status="draft">
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991005145679705773</idno>
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
            <language ident="es" n="some quotes" xml:lang="en">Español</language> 
        </langUsage> 
    </profileDesc>
        
        <encodingDesc>
            <projectDesc><p xml:id="meta-pa-0004" part="N"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                
            <editorialDecl>
                <p xml:id="meta-pa-0005" part="N"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    
                <normalization method="silent">
                   <p xml:id="meta-pa-0006" xml:lang="en" part="N">The "long s" character (<q>ſ</q>) was normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
            </editorialDecl>
            
            <charDecl><char xml:lang="en"><note xml:id="meta-no-0001" anchored="true">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/specialchars.xml">project website</ref>.</note></char></charDecl>
                
			<appInfo>
                <application ident="auto-markup" version="1" xml:id="auto">
                    <desc>Automatically generated markup.</desc>
                </application>
            </appInfo>
        </encodingDesc>
        
        <revisionDesc status="g_enriched_approved">
            <listChange ordered="true">
                <change who="#DG #CR #auto" when="2021-02-08" status="g_enriched_approved" xml:lang="en" xml:id="W0001_Vol06_change_025">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2021-02-05" status="g_enriched_approved" xml:lang="en" xml:id="W0001_Vol06_change_024">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2021-02-05" status="g_enriched_approved" xml:id="W0001_Vol06_change_023" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2021-02-05" status="g_enriched_approved" xml:id="W0001_Vol06_change_022" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2021-02-05" status="g_enriched_approved" xml:id="W0001_Vol06_change_021" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2021-02-05" status="g_enriched_approved" xml:id="W0001_Vol06_change_020" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#JLE" when="2021-02-05" status="g_enriched_approved" xml:id="W0001_Vol06_change_019" xml:lang="en">Second round of corrections (JLE).</change>
                <change who="#DG #CR #auto" when="2021-02-03" status="g_enriched_approved" xml:id="W0001_Vol06_change_018" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#JLE" when="2021-02-03" status="g_enriched_approved" xml:id="W0001_Vol06_change_017" xml:lang="en">First round of corrections (JLE).</change>
                <change who="#DG #CR #auto" when="2020-06-04" status="f_enriched" xml:id="W0001_Vol06_change_016" xml:lang="en">Automatically expanded abbreviations (la-marginal) update.</change>
                <change who="#DG #CR #auto" when="2020-06-04" status="f_enriched" xml:id="W0001_Vol06_change_015" xml:lang="en">Automatically expanded abbreviations (la-main) update.</change>
                <change who="#DG #CR #auto" when="2019-09-12" status="f_enriched" xml:id="W0001_Vol01_change_014" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0001_Vol06_change_013" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0001_Vol06_change_012" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2019-09-04" status="f_enriched" xml:id="W0001_Vol06_change_011" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-09-04" status="f_enriched" xml:id="W000_Vol06_change_010" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2019-09-03" status="f_enriched" xml:lang="en" xml:id="W0001_Vol06_change_009">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-09-03" status="c_hyph_proposed" xml:lang="en" xml:id="W0001_Vol06_change_008">Annotated hyphenated breaks interrupted by hi and note.</change>
                <change who="#DG #CR #auto" when="2019-09-03" status="c_hyph_proposed" xml:lang="en" xml:id="W0001_Vol06_change_007">Annotated hyphenated breaks.</change>
                <change who="#DG #auto" when="2019-09-02" status="a_raw" xml:lang="en" xml:id="W0001_Vol06_change_0007">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR" when="2019-09-02" status="a_raw">Added @xml:ids and @unit=section to milestone.</change>
                <change who="#CR" when="2019-09-02" status="a_raw">Index in nested lists.</change>
                <change who="#CR" when="2019-08-16" status="a_raw">Added @type to div2 and div3.</change>
                <change who="#CR" when="2019-08-08" status="a_raw">Added missing pagination (pb/@n).</change>
                <change who="#CR" when="2019-08-08" status="a_raw">Structural annotation.</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-27" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-12" status="a_raw">
                    <list type="simple">
                        <item xml:id="item_ljawewa">@key bei pubPlace für die Facettierung eingetragen</item>
                        <item xml:id="item_ljwhvel23">Wenn wir eine neuere als die Erstausgabe digitalisiert haben, müssen in den Facetten und in den bibl. Angaben die bibl. Daten richtig angezeigt werden. Dazu soll das Impressum der Erastausgabe zusätzlich auf der Seite detais_work.html aufgeführt werden. Deswegen folgendes vorghen.</item>
                        <item xml:id="item_fasbw">Regel in Editionsrichtlinien aufnehmen: Wenn wir die erste Ausgabe digitalisieren konnten, werden folgende Angaben verwendet: pubPlace@role=firstEd, date@type=firstEd, publisher@type=firstEd, date@type="summaryFirstEd"</item>
                        <item xml:id="item_awlhbob">Regel in Editionsrichtlinien aufnehmen: Wenn wir eine andere  Ausgabe digitalisieren müssen, werden züsätzlich zu den Angaben der ersten Ausgabe, Angaben zur vorliegenden Ausgabe gemacht: pubPlace@role=thisEd, date@type=thisEd, publisher@type=
                            thisEd, date@type="summaryThisEd"</item>
                        <item xml:id="item_sljbhawef">Schema-Anpassungen für date@type="summaryFirstEd" (Wert anpassen) und date@type="summaryThisEd" (Wert hinzufügen) vornehmen</item>
                    </list>
                </change>
                <change who="#AW" when="2014-10-16" status="a_raw">Reihenfolge der Editoren korrigiert und ref-key f. Drucker u. Druckort eingetragen.</change>
                <change who="#IC" when="2014-09-25" status="a_raw">W0001_Vol06 Header angelegt</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>