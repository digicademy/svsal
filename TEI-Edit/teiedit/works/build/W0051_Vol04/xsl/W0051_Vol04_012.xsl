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
    
    
<xsl:variable name="teiHeader" xml:space="preserve"><teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Complectens Librvm Qvartvm, Additis Notis vberioribus ab Historia, &amp; Chorographia</title>
                <title type="main" level="m">D.D. Emanvelis Gonzalez Tellez, In Inclyta Salmanticensi Academia Collegij Maioris Conchensis Alumni, &amp; antiquioris vespertinæ sacrorum Canonum Cathedræ propietarij Interpretis; in Pinciano Sanctæ Inquisitionis Tribunali Inquisitoris Apostolici, &amp; in supremo S. Inquisitionis Senatu Consiliarij; Commentaria Perpetva In singulos Textus quinque Librorum Decretalivm Gregorii IX./Tomvs Qvartvs</title>
                <title type="volume" n="4" level="m">Tomvs Qvartvs</title>
                <author>
                    <persName ref="author:A0037 gnd:124372805 viaf:88993552 cerl:cnp00984136" key="González Téllez, Manuel">
                        <forename>Manuel</forename>
                        <surname>González Téllez</surname>
                    </persName>
                </author>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="FK" role="#scholarly">
                    <persName ref="orcid:0009-0006-2438-0513">
                        <surname>König</surname>, <forename>Florian</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0051_Vol04-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2026-10-07">2026-10-07</date>.
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
                <date type="digitizedEd" when="2026-10-07">2026-10-07</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0051:vol4</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0051:vol4?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0051:vol4?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0051:vol4?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0051:vol4?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0051:vol4?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0051:vol4?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="62.4">Volume 62.4</biblScope>
           </seriesStmt>

            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0051"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0037 gnd:124372805 viaf:88993552 cerl:cnp00984136" key="González Téllez, Manuel">
                                <forename>Manuel</forename>
                                <surname>González Téllez</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Complectens Librvm Qvartvm, Additis Notis vberioribus ab Historia, &amp; Chorographia</title>
                        <title type="main" level="m">D.D. Emanvelis Gonzalez Tellez, In Inclyta Salmanticensi Academia Collegij Maioris Conchensis Alumni, &amp; antiquioris vespertinæ sacrorum Canonum Cathedræ propietarij Interpretis; in Pinciano Sanctæ Inquisitionis Tribunali Inquisitoris Apostolici, &amp; in supremo S. Inquisitionis Senatu Consiliarij; Commentaria Perpetva In singulos Textus quinque Librorum Decretalivm Gregorii IX./Tomvs Qvartvs</title>
                        <title type="volume" n="4" level="m">Tomvs Qvartvs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lvgdvni</pubPlace>
                            <date type="firstEd" when=" 1673"> 1673</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00028037 gnd:103753526X viaf:34511695" key="Arnaud, Laurent">
                                    <forename>Lavrentii</forename>
                                    <surname>Arnavd</surname>
                                </persName>
                                <persName ref="cerl:cni00107487 gnd:1037610423 viaf:29587523" key="Borde, Petrus">
                                    <forename>Petri</forename>
                                    <surname>Borde</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">8 ungezählte Seiten, 336 Seiten, 162 ungezählte Seiten</extent>
                        <extent xml:lang="en">[8] p., 336 p., [162] p.</extent>
                        <extent xml:lang="es">[8] p., 336 p., [162] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991001847089705773</idno>
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
                <p xml:id="W0051_Vol04_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                    Abbreviations are partially resolved.</p>
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
                <change who="#CR #auto" when="2026-10-07" status="g_enriched_approved" xml:id="W0051_Vol04_change_016" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#FK" when="2026-07-30" status="g_enriched_approved" xml:id="W0051_Vol04_change_015" xml:lang="en">Resolution of remaining unclear marks.</change>
                <change who="#CR #auto" when="2026-10-07" status="f_enriched" xml:id="W0091_change_014" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2026-10-07" status="f_enriched" xml:id="W0051_Vol04_change_013" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2026-10-07" status="f_enriched" xml:id="W0051_Vol04_change_012" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2026-10-06" status="f_enriched" xml:id="W0051_Vol04_change_011" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2026-10-06" status="f_enriched" xml:id="W0051_Vol04_change_010" xml:lang="en">Numbered lines.</change>
                <change who="#DG #MAH #CR #auto" when="2026-10-01" status="f_enriched" xml:id="W0051_Vol04_change_009" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2026-10-01" status="f_enriched" xml:lang="en" xml:id="W0051_Vol04_change_008">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2026-09-29" status="a_raw" xml:lang="en" xml:id="W0051_Vol04_change_007">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR #auto" when="2026-10-06" status="a_raw" xml:lang="en" xml:id="W0051_Vol04_change_006">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2026-10-06" status="a_raw" xml:lang="en" xml:id="W0051_Vol04_change_005">Automatically expanded abbreviations - dictionary from manually corrected texts using python.</change>
                <change who="#MAH #CR #auto" when="2026-09-22" status="a_raw" xml:lang="en" xml:id="W0051_Vol04_change_004">Structural annotation: added @type, @n in div(s), list(s), etc.</change>
                <change who="#MAH #CR" when="2026-09-16" status="a_raw" xml:lang="en" xml:id="W0051_Vol04_change_003">Structural annotation and unclear resolution.</change>
                <change who="#CR" when="2025-05-08" status="a_raw" xml:lang="en">Added encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2022-10-18" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>       
</xsl:variable>
    
</xsl:stylesheet>