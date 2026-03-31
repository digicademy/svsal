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
                <title type="short" level="s">Opera omnia, sive quotidianarum controversiarum iuris</title>
                <title type="main" level="s"> D. Ioannis Del Castillo Sotomayor I.C. Nobilissimi; Olim Complvtensis Academiæ Antecessoris Primarii; Postmodùm in Gallæciano, Hispalensi, &amp; Granatensi Auditoriis, Regiísque Curiis, successiuè Senatoris Amplissimi; Demum in Supremo Dominicæ Rei, siue Patrimonij Regij Senatu Consiliarij præstantissimi; Opera Omnia, Sive Qvotidianarvm Controversiarvm Ivris Tomi Octo</title>
                <title type="volume" level="m" n="2">Liber Secvndvs</title>
                <author>
                    <persName ref="author:A0021 gnd:100972144 viaf:7742296 cerl:cnp01132965" key="Castillo Sotomayor, Juan de" full="yes">
                        <forename full="yes">Juan</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Castillo Sotomayor</surname>
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
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0037_Vol02-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2022-07-19">2022-07-19</date>.
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
                <date type="digitizedEd" when="2022-07-19">2022-07-19</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0037:vol2</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0037:vol2?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0037:vol2?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0037:vol2?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0037:vol2?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0037:vol2?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0037:vol2?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="26.2">Volume 26.2</biblScope>
           </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0037"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0021 gnd:100972144 viaf:7742296 cerl:cnp01132965" key="Castillo Sotomayor, Juan de" full="yes">
                                <forename full="yes">Juan</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Castillo Sotomayor</surname>
                            </persName>
                        </author>
                        <title type="short" level="s">Opera omnia, sive quotidianarum controversiarum iuris</title>
                        <title type="main" level="s"> D. Ioannis Del Castillo Sotomayor I.C. Nobilissimi; Olim Complvtensis Academiæ Antecessoris Primarii; Postmodùm in Gallæciano, Hispalensi, &amp; Granatensi Auditoriis, Regiísque Curiis, successiuè Senatoris Amplissimi; Demum in Supremo Dominicæ Rei, siue Patrimonij Regij Senatu Consiliarij præstantissimi; Opera Omnia, Sive Qvotidianarvm Controversiarvm Ivris Tomi Octo</title>
                        <title type="volume" level="m" n="2">Liber Secvndvs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1658">1658</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00071345 gnd:1037560329 viaf:39429535" key="Anisson, Laurent" full="yes">
                                    <forename full="yes">Laurent</forename>
                                    <surname full="yes">Anisson</surname>
                                </persName>
                                <persName ref="cerl:cni00071443 gnd:1037593340 viaf:29469987" key="Devenet, Jean-Baptiste" full="yes">
                                    <forename full="yes">Jean-Baptiste</forename>
                                    <surname full="yes">Devenet</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de"> 8 ungezählte Seiten, 175 Seiten, 39 ungezählte Seiten</extent>
                        <extent xml:lang="en">[8] p, 175, [39] p.</extent>
                        <extent xml:lang="es">[8] p, 175, [39] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:2019144-3" xml:lang="de">Max-Planck-Institut für Rechtsgeschichte und Rechtstheorie &lt;Frankfurt, Main&gt;</repository>
                        <idno type="catlink" xml:lang="de">https://sunrise.rg.mpg.de/webOPACClient/start.do?Language=de&amp;KatKeySearch=53007</idno>
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
                <change who="#DG #CR #auto" when="2022-07-19" status="g_enriched_approved" xml:lang="en" xml:id="W0037_Vol02_change_022">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2022-07-19" status="g_enriched_approved" xml:lang="en" xml:id="W0037_Vol02_change_021">Tagged special characters after manual corrections.</change>
                <change who="#DG #CR #auto" when="2022-07-19" status="g_enriched_approved" xml:id="W0037_Vol02_change_020" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2022-07-19" status="g_enriched_approved" xml:id="W0037_Vol02_change_019" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2022-07-19" status="g_enriched_approved" xml:id="W0037_Vol02_change_018" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #auto" when="2022-07-17" status="g_enriched_approved" xml:id="W0037_Vol02_change_017" xml:lang="en">Second round of manual corrections (CB) and reduced excessive white space.</change>
                <change who="#DG #CR #auto" when="2022-05-03" status="g_enriched_approved" xml:id="W0037_Vol02_change_016" xml:lang="en">Reduced excessive white space.</change>
                <change who="#CB" when="2022-05-02" status="g_enriched_approved" xml:lang="en" xml:id="W0037_Vol02_change_015">First round of manual corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-11-03" status="f_enriched" xml:id="W0037_Vol02_change_014" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-11-02" status="f_enriched" xml:id="W0037_Vol02_change_013" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2020-11-02" status="f_enriched" xml:id="W0037_Vol02_change_012" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-11-02" status="f_enriched" xml:id="W0037_Vol02_change_011" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-11-02" status="f_enriched" xml:id="W0037_Vol02_change_010" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2020-11-02" status="f_enriched" xml:lang="en" xml:id="W0037_Vol02_change_009">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-11-02" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_008">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR" when="2021-10-04" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_007">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR" when="2020-11-02" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_006">Resolved unclear marks partially.</change>
                <change who="#CR #auto" when="2020-10-30" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_005">Summaries, adding @target to ref using @xml:id in milestones.</change>
                <change who="#CR #auto" when="2020-10-30" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_004">Adding @xml:id and @unit to milestones.</change>
                <change who="#CR #auto" when="2020-10-30" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_003">Added @n, @type and @xml:id to div2(s), div3(s), lists and @target(s) to ref in toc.</change>
                <change who="#CR" when="2020-10-30" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_002">Structural annotation.</change>
                <change who="#CR" when="2020-06-04" status="a_raw" xml:lang="en" xml:id="W0037_Vol02_change_001">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>