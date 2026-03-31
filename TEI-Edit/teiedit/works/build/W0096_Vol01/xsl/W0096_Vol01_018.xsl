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
                <title type="short" level="m">De Indiarum Iure, Vol. 1</title>
                <title type="main" level="m">Ioannes De Solorzano Pereira I.V.D. Ex Primarijs olim Academiae Salmanticensis Antecessoribus. Posteà Limensis Praetorij in Peruano Regno Novi Orbis Senator: Nunc verò in Supremo Indiarum Consilio Regij Fisci Patronus, Dispvtationem De Indiarvm Ivre, Sive De iusta Indiarum Occidentalium inquisitione, acquisitione, et retentione Tribvs Libris Comprehensam, D.E.C.</title>
                <title type="volume" level="m" n="1">Vol. 1</title>
                <author> 
                    <persName ref="author:A0082 gnd:118837389 cerl:cnp01341312" key="Solórzano Pereira, Juan de" full="yes"> 
                        <forename full="yes">Juan</forename> 
                        <nameLink>de</nameLink> 
                        <surname full="yes">Solórzano Pereira</surname> 
                    </persName> 
                </author>
                <editor xml:id="PDS" role="#scholarly">
                    <persName ref="orcid:0000-0001-6255-6141" full="yes">
                        <surname full="yes">da Silva Santos</surname>, <forename full="yes">Pedro</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical"> 
                    <persName ref="orcid:0000-0001-5095-1793" full="yes"> 
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename> 
                    </persName> 
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical"> 
                    <persName ref="orcid:0000-0002-0273-3844" full="yes"> 
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename> 
                    </persName> </editor>
                <editor xml:id="CB" role="#scholarly"> 
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename> 
                    </persName> 
                </editor>
            </titleStmt>
            <editionStmt>
               <edition n="1.0.0" xml:id="W0096_Vol01-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2021-03-15">2021-03-15</date>.
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
            	<date type="digitizedEd" when="2021-03-15">2021-03-15</date>
            	<idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0096:vol1</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0096:vol1?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0096:vol1?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0096:vol1?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0096:vol1?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0096:vol1?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0096:vol1?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="22.1">Volume 22.1</biblScope>
            </seriesStmt>
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0096"/>
            </notesStmt>
            <sourceDesc> 
                <biblStruct> 
                    <monogr> 
                        <author> 
                            <persName ref="author:A0082 gnd:118837389 cerl:cnp01341312" key="Solórzano Pereira, Juan de" full="yes"> 
                                <forename full="yes">Juan</forename> 
                                <nameLink>de</nameLink> 
                                <surname full="yes">Solórzano Pereira</surname> 
                            </persName> 
                        </author> 
                        <title type="short" level="m">De Indiarum Iure, Vol. 1</title>
                        <title type="main" level="m">Ioannes De Solorzano Pereira I.V.D. Ex Primarijs olim Academiae Salmanticensis Antecessoribus. Posteà Limensis Praetorij in Peruano Regno Novi Orbis Senator: Nunc verò in Supremo Indiarum Consilio Regij Fisci Patronus, Dispvtationem De Indiarvm Ivre, Sive De iusta Indiarum Occidentalium inquisitione, acquisitione, et retentione Tribvs Libris Comprehensam, D.E.C.</title>
                        <title type="volume" level="m" n="1">Vol. 1</title> 
                        <imprint> 
                            <pubPlace role="firstEd" ref="getty:7010413" key="Madrid">Matriti</pubPlace> 
                            <date type="firstEd" when="1629">1629</date> 
                            <publisher n="firstEd"> 
                                <persName ref="cerl:cni00025919" key="Martinez, Francisco" full="yes"> 
                                    <forename full="yes">Fanciscia</forename> 
                                    <surname full="yes">Martinez</surname> 
                                </persName> 
                            </publisher> 
                        </imprint> 
                        <extent xml:lang="de"> 28 ungezählte Seiten, 751 Seiten, 100 ungezählte Seiten</extent>
                        <extent xml:lang="en">[28], 751, [100] p.</extent>
                        <extent xml:lang="es">[28], 751, [100] p.</extent>
                    </monogr> 
                </biblStruct> 
                <msDesc> 
                    <msIdentifier> 
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository> 
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1rt5o3i/alma991002774369705773</idno> 
                    </msIdentifier> 
                    <physDesc> 
                        <typeDesc> 
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote> 
                        </typeDesc> 
                    </physDesc> 
                </msDesc> 
                <msDesc corresp="#facs:W0096-A-0552 #facs:W0096-A-0553"> 
                    <msIdentifier> 
                        <repository ref="gnd:7721988-0" xml:lang="es">Google books</repository> 
                        <idno type="catlink" xml:lang="en">https://play.google.com/books/reader?id=03N0p36BkpkC&amp;hl=es_419&amp;pg=GBS.PA518</idno> 
                    </msIdentifier> 
                    <physDesc> 
                        <typeDesc> 
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote> 
                        </typeDesc> 
                    </physDesc> 
                </msDesc> 
            </sourceDesc></fileDesc>
        <profileDesc> 
            <langUsage> 
                <language ident="la" n="main" xml:lang="en">Latin</language> 
                <language ident="es" n="administrative" xml:lang="en">Español</language> 
            </langUsage> 
        </profileDesc>
        <encodingDesc>
            <projectDesc><p xml:id="meta-pa-0004" part="N"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                
            <editorialDecl>
                <p xml:id="meta-pa-0005" part="N"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    
                <normalization method="silent">
                   <p xml:id="meta-pa-0006" xml:lang="en" part="N">Chapter titles were rearranged before summaries to successfully adapt the text to TEI structure..</p>
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
                <change who="#DG #CR #auto" when="2021-06-18" status="g_enriched_approved" xml:lang="en" xml:id="W0096_Vol01_change_028">teiHeader title update.</change>
                <change who="#DG #CR #auto" when="2021-03-15" status="g_enriched_approved" xml:lang="en" xml:id="W0096_Vol01_change_025">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2021-03-12" status="g_enriched_approved" xml:lang="en" xml:id="W0096_Vol01_change_024">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2021-03-10" status="g_enriched_approved" xml:id="W0096_Vol01_change_023" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2021-03-10" status="g_enriched_approved" xml:id="W0096_Vol01_change_022" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2021-03-09" status="g_enriched_approved" xml:id="W0096_Vol01_change_021" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2021-03-09" status="g_enriched_approved" xml:id="W0096_Vol01_change_020" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#PDS" when="2021-03-08" status="g_enriched_approved" xml:id="W0096_Vol01_change_019" xml:lang="en">Second round of corrections PDS.</change>
                <change who="#DG #CR #auto" when="2021-03-03" status="g_enriched_approved" xml:id="W0096_Vol01_change_018" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#PDS" when="2021-03-02" status="g_enriched_approved" xml:id="W0096_Vol01_change_017" xml:lang="en">First round of corrections PDS.</change>
                <change who="#CR #auto" when="2020-01-13" status="f_enriched" xml:lang="en">Set teiHeader.</change>
                <change who="#DG #CR #auto" when="2019-11-01" status="f_enriched" xml:id="W0096_Vol01_change_016" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0096_Vol01_change_015" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2019-12-16" status="f_enriched" xml:id="W0096_Vol01_change_014" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2019-02-04" status="f_enriched" xml:id="W0096_Vol01_change_013" xml:lang="en">Added @xml:id.</change>
                <change who="#DG #CR #auto" when="2019-02-04" status="f_enriched" xml:id="W0096_Vol01_change_012" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2018-11-29" status="f_enriched" xml:lang="en" xml:id="W0096_Vol01_change_011">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2018-11-24" status="c_hyph_proposed" xml:id="W0096_Vol01_change_008" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR" when="2018-12-04" status="c_hyph_proposed" xml:id="W0096_Vol01_change_010">Normalized Greek special characters tagged as unclear @reason="unbekanntes-Zeichen"</change>
                <change who="#CR" when="2018-11-24" status="c_hyph_proposed" xml:id="W0096_Vol01_change_007">Chapter titles were rearranged before summaries to successfully adapt the text to TEI structure.</change>
                <change who="#DG #CR #auto" when="2018-11-23" status="a_raw" xml:id="W0096_Vol01_change_006">Changed milestone @unit to 'section'.</change>
                <change who="#CR #auto" when="2018-11-21" status="a_raw" xml:lang="en" xml:id="W0096_Vol01-00-change-0005">Transformation from Tite to TEI</change>
                <change who="#CR #auto" when="2018-11-16" status="a_raw" xml:id="W0096_Vol01_change_004">Added references between milestones and summaries.</change>
                <change who="#CR" when="2018-11-16" status="a_raw" xml:id="W0096_Vol01_change_003">Table of contents references with chapters</change>
                <change who="#CR" when="2018-11-15" status="a_raw" xml:id="W0096_Vol01_change_002">Transcription of missing pages (518, 519 - facsimiles 0552, 0553)</change>
                <change who="#CR" when="2018-11-13" status="a_raw" xml:id="W0096_Vol01_change_001">Structural Annotation</change>
                <change who="#CB" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
        </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>