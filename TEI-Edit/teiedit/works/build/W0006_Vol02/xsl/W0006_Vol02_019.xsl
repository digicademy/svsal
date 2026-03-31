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
                <title type="short" level="m">Opera Omnia, Vol. 2</title>
                <title type="main" level="m">Variarvm Resolvtionvm Ivridicarvm Ex Ivre Pontificio, Regio, Et Caesareo Libri III</title>
                <title type="volume" level="m" n="2">[Tomus Secundus]</title>
                <author>
                    <persName ref="author:A0026 gnd:118837478 cerl:cnp01329697" key="Covarrubias y Leyva, Diego de" full="yes">
                        <forename full="yes">Diego</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Covarrubias y Leyva</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly #technical">
                        <persName ref="gnd:138962987" full="yes">
                            <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
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
               <edition n="1.0.0" xml:id="W0006_Vol02-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2021-06-11">2021-06-11</date>.
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
                <date type="digitizedEd" when="2021-06-11">2021-06-11</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0006:vol2</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0006:vol2?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0006:vol2?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0006:vol2?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0006:vol2?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0006:vol2?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0006:vol2?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="20.2">Volume 20.2</biblScope>
           </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0006"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0026 gnd:118837478 cerl:cnp01329697" key="Covarrubias y Leyva, Diego de" full="yes">
                                <forename full="yes">Diego</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Covarrubias y Leyva</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Opera Omnia, Vol. 2</title>
                        <title type="main" level="m">Variarvm Resolvtionvm Ivridicarvm Ex Ivre Pontificio, Regio, Et Caesareo Libri III</title>
                        <title type="volume" level="m" n="2">[Tomus Secundus]</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7193538" key="Frankfurt">Francofurti</pubPlace>
                            <date type="firstEd" when="1573">1573</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:118683527 cerl:cni00024730" full="yes">
                                    <forename full="yes">Sigmund</forename>
                                    <surname full="yes">Feierabend</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">8 ungezählte Seiten, 464 Seiten, 15 ungezählte Seiten, 127 Seiten, 7 ungezählte Seiten</extent>
                        <extent xml:lang="en">[8] p., 464 p., [15] p., 127 p., [7] p.</extent>
                        <extent xml:lang="es">[8] p., 464 p., [15] p., 127 p., [7] p.</extent>
                    </monogr>
                    <series>
                        <title type="main" level="s" ref="work:W0006">Dn. Didaci Covarrvviae a Leyva Toletani, Archiepiscopi S. Dominici Designati, et Ivreconsvlti Celeberrimi, 
                            Opera Omnia Quae Hactenvs Extant, Tribvs Tomis distincta</title>
                        <biblScope unit="volume" n="2" xml:lang="la">Tomus Secundus</biblScope>
                    </series>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/search?oclcno=230055764&amp;db=100</idno>
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
            <projectDesc><p xml:id="meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                
            <editorialDecl>
                <p xml:id="meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    
                <normalization method="silent">
                   <p xml:id="meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
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
                <change who="#CR" when="2021-06-11" status="g_enriched_approved" xml:id="W0006_Vol02_change_030" xml:lang="en">teiHeader update after corrections.</change>
                <change who="#DG #CR #auto" when="2021-06-10" status="g_enriched_approved" xml:lang="en" xml:id="W0006_Vol02_change_029">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2021-06-10" status="g_enriched_approved" xml:id="W0006_Vol02_change_028" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2021-06-10" status="g_enriched_approved" xml:id="W0006_Vol02_change_027" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2021-06-10" status="g_enriched_approved" xml:id="W0006_Vol02_change_026" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2021-06-10" status="g_enriched_approved" xml:id="W0006_Vol02_change_025" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2021-06-09" status="g_enriched_approved" xml:id="W0006_Vol02_change_024" xml:lang="en">Second round of corrections (CB).</change>
                <change who="#CR #DG #auto" when="2021-05-27" status="g_enriched_approved" xml:id="W0006_Vol02_change_023" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2021-05-27" status="g_enriched_approved" xml:id="W0006_Vol02_change_022" xml:lang="en">First round of corrections (CB).</change>
                <change who="#CR" when="2020-10-16" status="f_enriched" xml:id="W0006_Vol02_change_021" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-09-10" status="f_enriched" xml:id="W0006_Vol02_change_020" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2020-09-10" status="f_enriched" xml:id="W0006_Vol02_change-019" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-09-10" status="f_enriched" xml:id="W0006_Vol02_change-018" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-09-10" status="f_enriched" xml:id="W0006_Vol02_change-017" xml:lang="en">Numbered lines.</change>
                <change who="#DG #auto" when="2020-09-09" status="f_enriched" xml:lang="en" xml:id="W0006_Vol02_change-016">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-09-09" status="c_hyph_proposed" xml:lang="en" xml:id="W0006_Vol02_change-015">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" when="2020-09-09" status="a_raw" xml:id="W0006_Vol02_change-014" xml:lang="en">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2020-08-12" status="a_raw" xml:id="W0006_Vol02_change-013" xml:lang="en">Added @targets to ref in summaries from milestones' @xml:id.</change>
                <change who="#CR" when="2020-08-07" status="a_raw" xml:id="W0006_Vol02_change-012" xml:lang="en">Added ref in summaries.</change>
                <change who="#CR" when="2020-08-07" status="a_raw" xml:id="W0006_Vol02_change-011" xml:lang="en">Added @n, @type, @xml:id to div(s) and @target to ref(s) in toc.</change>
                <change who="#CR" when="2020-08-03" status="a_raw" xml:id="W0006_Vol02_change-010" xml:lang="en">Added missing pagination.</change>
                <change who="#CR" when="2020-08-04" status="a_raw" xml:id="W0006_Vol02_change-009" xml:lang="en">Structural annotation.</change>    
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-27" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#AW" when="2014-10-16" status="a_raw">Reihenfolge der Editoren korrigiert und ref-key f. Drucker u. Druckort eingetragen.</change>
                <change who="#IC" when="2014-10-10" status="a_raw">
                    <list type="simple">
                        <item xml:id="item_kfjzjz">pubPlace@role="firstEd" (Eingabe des Erscheinungsortes nach Vorlageform) und date@type="firstEd", wenn wir die Erstausgabe haben</item>
                        <item xml:id="item_kg8786f">publisher/persName nach RAK WB §§ 145: Nur Nachname im Nominativ</item>
                        <item xml:id="item_loij5353">ref@type="institution" und ref@type="catLink" im Schema ergänzen</item>
                    </list>
                </change>
                <change who="#IC" when="2014-09-25" status="a_raw">W0006_Vol02 Header angelegt</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>