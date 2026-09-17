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
                <title type="short" level="m">De fide, Spe, &amp; Charitate</title>
                <title type="main" level="m">De fide, Spe, &amp; Charitate. Catholico Regi Philippo II. Magno Hispaniarvm Monarchæ, Scholastica Commentaria in Secundam Secundæ Angelici Doctoris partem, quæ ad Quæstionem Quadragesimam sextam protenduntur, dicata</title> 
                <author>
                    <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237 viaf:88708934" key="Báñez, Domingo">
                        <forename>Domingo</forename>
                        <surname>Báñez</surname>
                    </persName>
                </author>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793">
                        <surname>Rico Carmona</surname>, <forename>Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0025-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2026-05-07">2026-05-07</date>.
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
                <date type="digitizedEd" when="2026-05-07">2026-05-07</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0025</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0025?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0025?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0025?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0025?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0025?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0025?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="63">Volume 63</biblScope>
           </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0012 gnd:11865702X cerl:cnp01014237 viaf:88708934" key="Báñez, Domingo">
                                <forename>Domingo</forename>
                                <surname>Báñez</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De fide, Spe, &amp; Charitate</title>
                        <title type="main" level="m">De fide, Spe, &amp; Charitate. Catholico Regi Philippo II. Magno Hispaniarvm Monarchæ, Scholastica Commentaria in Secundam Secundæ Angelici Doctoris partem, quæ ad Quæstionem Quadragesimam sextam protenduntur, dicata</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanticae</pubPlace>
                            <date type="firstEd" when="1584">1584</date>
                            <publisher n="firstEd">
                                <placeName ref="cerl:cnc00008968 viaf:156550588 gnd:5164075-2" key="Convento de San Esteban">
                                    <orgName>Apud S. Stephanum Ordinis Prædicatorum</orgName>
                                </placeName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[11] Seiten, 1476 Spalten, [1] Blatt, [56] Seiten</extent>
                        <extent xml:lang="en">[11] p., 1476 col., [1] fol., [56] p.</extent>
                        <extent xml:lang="es">[11] p., 1476 col., [1] fol., [56] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="viaf:307472291" xml:lang="en">HathiTrust Digital Library</repository>
                        <idno type="catlink" xml:lang="en">https://babel.hathitrust.org/cgi/pt?id=ucm.5316859096&amp;seq=1</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc corresp="#W0025-0440 #W0025-0441 #W0025-0153 #W0025-0199 #W0025-0258 #W0025-0278 #W0025-0310 #W0025-0326">
                    <msIdentifier>
                        <repository xml:lang="es">Biblioteca Virtual del Patrimonio Bibliográfico</repository>
                        <idno type="catlink" xml:lang="es">https://bvpb.mcu.es/en/consulta/registro.do?id=464064</idno>
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
                <p xml:id="W0025_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2026-05-07" status="g_enriched_approved" xml:id="W0025_change_012" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#CR #auto" when="2026-04-29" status="g_enriched_approved" xml:id="W0025_change_011" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2026-04-28" status="a_raw" xml:id="W0025_change_010" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2026-04-20" status="a_raw" xml:id="W0025_change_009" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2026-04-20" status="a_raw" xml:id="W0025_change_008" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2026-04-20" status="a_raw" xml:id="W0025_change_007" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2026-04-15" status="a_raw" xml:lang="en" xml:id="W0025_change_006">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2026-04-15" status="a_raw" xml:id="W0025_change_005" xml:lang="en">Annotate Hyphenation</change>
                <change who="#CR #auto" when="2026-04-14" status="a_raw" xml:lang="en" xml:id="W0025_change_004">Transformation TEI-tite to TEI-All.</change>
                <change who="#CR #auto" when="2026-04-07" status="a_raw" xml:lang="en" xml:id="W0025_change_003">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2026-03-18" status="a_raw" xml:lang="en" xml:id="W0025_change_002">Tagged @n, @type, @xml:id(s) in div(s), list(s) and @target in TOC and summaries.</change>
                <change who="#CR" when="2026-03-11" status="a_raw" xml:lang="en" xml:id="W0025_change_001">Structural annotation and first round of unclear.</change>
                <change who="#CR" when="2025-05-08" status="a_raw" xml:lang="en">Corrected encodingDesc//editorialDecl/p xml:id="..._AEW".</change>
                <change who="#CR" when="2025-04-23" status="a_raw" xml:lang="en">Set teiHeader.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>