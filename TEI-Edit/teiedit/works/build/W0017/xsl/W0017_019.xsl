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
    <teiHeader xmlns:t="http://www.tei-c.org/ns/tite/1.0" xmlns:tite="http://www.tei-c.org/ns/tite/1.0" xmlns:sal="http://salamanca.adwmainz.de" xml:lang="de">
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Arte de los contractos</title>
                <title type="main" level="m">Arte de los contractos. Compuesto por Bartolome de Albornoz, Estudiante de Talavera. Dirigido al Illustissimo y Reverendiss. S. Don Diego Covarruvias De Leiva, Obispo de Segouia, Presidente del consejo Real, etc.</title>
                <author>
                    <persName ref="author:A0002 gnd:104592251X cerl:cnp02094209" key="Albornoz, Bartolomé de">
                        <forename>Bartolomé</forename>
                        <nameLink>de</nameLink>
                        <surname>Albornoz</surname>
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
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477">
                        <surname>Thönes</surname>, <forename>Martin</forename>
                    </persName>
                </editor>
            </titleStmt>
            <editionStmt>
                <edition n="1.0.0" xml:id="W0017-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2020-07-22">2020-07-22</date>.
                </edition>
            </editionStmt>
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2020-07-22">2020-07-22</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0017</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0017?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0017?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0017?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0017?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0017?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0017?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="17"/>
            </seriesStmt>
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0002 gnd:104592251X cerl:cnp02094209" key="Albornoz, Bartolomé de">
                                <forename>Bartolomé</forename>
                                <nameLink>de</nameLink>
                                <surname>Albornoz</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Arte de los contractos</title>
                        <title type="main" level="m">Arte De Los Contractos Compuesto por Bartolome de Albornoz Estvdiante De Talavera. Dirigido al Illustrissimo y Reuerendiss. S. Don Diego Covarrvvias De Leiva Obispo de Segouia, Presidente del consejo Real,etc.,...</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002793" key="Valencia">Valenica</pubPlace>
                            <date type="firstEd" when="1573">1573</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037649370" key="Huete, Pedro de">
                                    <forename>Pedro</forename>
                                    <nameLink>de</nameLink>
                                    <surname>Huete</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">10 ungezählte Seiten, 176 Blätter</extent>
                        <extent xml:lang="en">[10], 176 l.</extent>
                        <extent xml:lang="es">[10], 176 h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:050361031" xml:lang="es">Staatsbibliothek zu Berlin</repository>
                            <idno type="catlink" xml:lang="de">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=59416821X</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc>
                    <msIdentifier>
                        <repository ref="viaf:123343900" xml:lang="en">Internet Archive</repository>
                        <idno type="catlink" xml:lang="en">https://archive.org/details/ARes44318/page/n1/mode/2up</idno>
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
              <language ident="es" n="main" xml:lang="en">Español</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <xi:include href="../meta/W_Head_general.xml" xpointer="projectDesc">
                <xi:fallback><projectDesc><p xml:id="meta-pa-0004"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback><p xml:id="meta-pa-0005"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    </xi:fallback>
                </xi:include>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
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
                <change who="#DG #CR #auto" when="2020-07-22" status="g_enriched_approved" xml:lang="en" xml:id="W0017_change_021">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-07-22" status="g_enriched_approved" xml:lang="en" xml:id="W0017_change_020">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2020-07-21" status="g_enriched_approved" xml:id="W0017_change_019" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-07-21" status="g_enriched_approved" xml:id="W0017_change_018" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2020-07-21" status="g_enriched_approved" xml:id="W0017_change_017" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2020-07-21" status="g_enriched_approved" xml:id="W0017_change_015" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-07-14" status="g_enriched_approved" xml:id="W0017_change_014">Second round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-07-16" status="g_enriched_approved" xml:id="W0017_change_013" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-07-14" status="g_enriched_approved" xml:id="W0017_change_012">First round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2019-07-16" status="f_enriched" xml:id="W0017_change_011" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#CR #DG #auto" when="2019-05-16" status="f_enriched" xml:id="W0017_change_010" xml:lang="en">Automatically expanded abbreviations (es-marginal).</change>
                <change who="#CR #DG #auto" when="2019-05-16" status="f_enriched" xml:id="W0017_change_009" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #auto" when="2019-01-16" status="f_enriched" xml:id="W0017_change_008" xml:lang="en">Added @xml:id.</change>
                <change who="#DG #auto" when="2019-01-16" status="f_enriched" xml:id="W0017_change_007" xml:lang="en">Numbered lines.</change>
                <change who="#CR #auto" when="2018-09-04" status="f_enriched" xml:lang="en" xml:id="W0017_change_06">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2019-05-13" status="c_hyph_proposed" xml:id="W0017_change_005" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR #auto" when="2018-09-05" status="a_raw" xml:lang="en" xml:id="W0017-00-change-0003">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR" when="2018-12-06" status="a_raw">Transcription missing text facsimiles 0005, 0006, 0292</change>
                <change who="#CR" when="2018-12-06" status="a_raw">teiHeader revision</change>
                <change who="#CR" when="2018-09-03" status="a_raw">Orcid-ID von CR eingetragen</change>
                <change who="#CR" when="2018-09-03" status="a_raw">Titel Struktur</change>
                <change who="#CR" when="2018-08-28" status="a_raw">Strukturelle Annotation</change>
                <change who="#MT" when="2017-12-04" status="a_raw">Orcid-ID von DG eingetragen</change>
                <change who="#MT" when="2017-11-28" status="a_raw">Permanenter CatLink eingefügt</change>
                <change who="#MT" when="2017-11-20" status="a_raw">Ausbesserung von frontmatter und Links für den Fundort</change>
                <change who="#MT" when="2017-11-13" status="a_raw">Ausbesserung von Links zur head xml und Sonderzeichen xml</change>
                <change who="#MT" when="2017-11-09" status="a_raw">Kleine Verbesserungen</change>
                <change who="#MT" when="2017-11-06" status="a_raw">Dokument wurde zur Übung erstellt.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>