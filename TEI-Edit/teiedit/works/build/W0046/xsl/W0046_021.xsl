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
                <title type="short" level="m">De Iusto Imperio Lusitanorum Asiatico</title>
                <title type="main" level="m">De Ivsto Imperio Lvsitanorvm Asiatico</title>
                <author>
                    <persName ref="author:A0032 cerl:cnp01325529 viaf:14801557 gnd:13700849X" key="Freitas, Serafim de">
                        <forename>Serafim</forename>
                        <nameLink>de</nameLink>
                        <surname>Freitas</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly #technical">
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
                    <persName ref="orcid:0000-0003-1835-1653 gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="MT" role="#additional">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
            <edition n="1.0.0" xml:id="W0046-version1" xml:lang="en">
                Complete digitized edition, <date type="digitizedEd" when="2020-11-13">2020-11-13</date>.
            </edition>
        </editionStmt>
            
        <publicationStmt xml:id="publicationStmt">
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            	<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            				refer to our website.</ref></publisher>
            	</xi:fallback>
            </xi:include>
            <date type="digitizedEd" when="2020-11-13">2020-11-13</date>
            <idno>
                <idno xml:id="urlid">https://id.salamanca.school/texts/W0046</idno>
                <idno xml:id="urltei">https://id.salamanca.school/texts/W0046?format=tei</idno>
                <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0046?format=html</idno>
                <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0046?format=rdf</idno>
                <idno xml:id="urliiif">https://id.salamanca.school/texts/W0046?format=iiif</idno>
                <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0046?format=txt&amp;mode=orig</idno>
                <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0046?format=txt&amp;mode=edit</idno>
            </idno>
        </publicationStmt>

        <seriesStmt>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                <xi:fallback>
                   <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                </xi:fallback>
            </xi:include>
            <biblScope unit="volume" n="19"/>
        </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0032 cerl:cnp01325529 viaf:14801557 gnd:13700849X" key="Freitas, Serafim de">
                                <forename>Serafim</forename>
                                <nameLink>de</nameLink>
                                <surname>Freitas</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iusto Imperio Lusitanorum Asiatico</title>
                        <title type="main" level="m">De Ivsto Imperio Lvsitanorvm Asiatico</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008771" key="Valladolid">Vallisoleti</pubPlace>
                            <date type="firstEd" when="1625">1625</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00036533" key="Morillo, Jerónimo">
                                    <forename>Hieronymus</forename> 
                                    <surname>Morillo</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">16 ungezählte Seiten, 190 Blätter, 56 ungezählte Seiten</extent>
                        <extent xml:lang="en">[16] p., 190 l., [56] p.</extent>
                        <extent xml:lang="es">[16] p., 190 h., [56] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://brumario.usal.es/permalink/34BUC_USAL/1r2qv74/alma991002598609705773</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink">http://hdl.handle.net/10366/48004</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Antiqua typeface</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
                <msDesc status="g_enriched_approved" corresp="#facs:0046-0301, #facs:0046-0302, #facs:0046-0370, #facs:0046-0371, #facs:0046-0372, #facs:0046-0373">
                    <msIdentifier>
                        <repository ref="gnd:2031351-2" xml:lang="de">Bayerische Staatsbibliothek</repository>
                        <idno type="catlink">http://mdz-nbn-resolving.de/urn:nbn:de:bvb:12-bsb10691210-0</idno>
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
                <change who="#DG #CR #auto" when="2020-11-12" status="g_enriched_approved" xml:lang="en" xml:id="W0046_change_025">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-11-11" status="g_enriched_approved" xml:lang="en" xml:id="W0046_change_024">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-11-11" status="g_enriched_approved" xml:id="W0046_change_023" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-11-11" status="g_enriched_approved" xml:id="W0046_change_022" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2020-11-11" status="g_enriched_approved" xml:id="W0046_change_021" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2020-11-10" status="g_enriched_approved" xml:id="W0046_change_020" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-11-10" status="g_enriched_approved" xml:id="W0046_change_019" xml:lang="en">Second round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-11-09" status="g_enriched_approved" xml:id="W0046_change_018" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-11-09" status="g_enriched_approved" xml:id="W0046_change_017" xml:lang="en">First round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-06-04" status="f_enriched" xml:id="W0046_change_016" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2020-06-04" status="f_enriched" xml:id="W0046_change_015" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2020-05-22" status="f_enriched" xml:id="W0046_change_014" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-05-22" status="f_enriched" xml:id="W0046_change_013" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-05-22" status="f_enriched" xml:lang="en" xml:id="W0046_change_012">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-05-22" status="c_hyph_proposed" xml:id="W0046_change_011" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2020-05-19" status="a_raw" xml:id="W0046_change_010" xml:lang="en">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#DG #CR #auto" when="2020-05-19" status="a_raw" xml:id="W0046_change_009" xml:lang="en">Added crossed references in summaries.</change>
                <change who="#DG #CR #auto" when="2020-05-15" status="a_raw" xml:id="W0046_change_008" xml:lang="en">Adding @xml:id and @unit to milestone</change>
                <change who="#DG #CR #auto" when="2020-05-15" status="a_raw" xml:id="W0046_change_007" xml:lang="en">Added @type to list (summaries) and changed label(s) into ref(s).</change>
                <change who="#CR #auto" when="2020-05-15" status="a_raw" xml:id="W0046_change_006" xml:lang="en">Added @type to div(s) and @target to toc.</change>
                <change who="#CR" when="2020-05-13" status="a_raw" xml:id="W0046_change_005b" xml:lang="en">Transcribed missing text from facs (0370, 0371, 0372, 0373).</change>
                <change who="#CR" when="2020-05-11" status="a_raw" xml:id="W0046_change_005" xml:lang="en">Structural annotations</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#AW" when="2017-07-30" status="a_raw">Create template/file for metadata</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>