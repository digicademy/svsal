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
                <title type="short" level="m">Relectiones Theologicae XII, Vol. 1</title>
                <title type="main" level="m">Reverendi Patris F. Francisci De Victoria, ordinis Prædictoru[m] sacræ Theologiæ in Salmanticensi Academia quondam primarij Professoris, Relectiones Theologicæ XII.</title>
                <title type="volume" level="m" n="1">Tomvs Primvs</title>
                <author>
                    <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key="Vitoria, Francisco de">
                        <forename>Francisco</forename>
                        <nameLink>de</nameLink>
                        <surname>Vitoria</surname>
                    </persName>
                </author>
                <editor xml:id="CB">
                    <persName ref="gnd:138962987">
                        <surname>Birr</surname>, <forename>Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="IC">
                    <persName ref="gnd:1022577581">
                        <surname>Caesar</surname>, <forename>Ingo</forename>
                    </persName>
                </editor>
                <editor xml:id="DG">
                    <persName ref="orcid:0000-0002-0273-3844">
                        <surname>Glück</surname>, <forename>David</forename>
                    </persName>
                </editor>
                <editor xml:id="AS">
                    <persName ref="gnd:13605708X">
                        <surname>Spindler</surname>, <forename>Anselm</forename>
                    </persName>
                </editor>
                <editor xml:id="AW">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
               <edition n="1.0.0" xml:id="W0013_Vol01-v1.0.0" xml:lang="en">
                   Complete digitized edition, <date type="digitizedEd" when="2018-11-28">2018-11-28</date>.
               </edition>
            </editionStmt>

            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2018-11-28">2018-11-28</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0013:vol1</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0013:vol1?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0013:vol1?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0013:vol1?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0013:vol1?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0013:vol1?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0013:vol1?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="3.1" xml:lang="en">Volume 3.1</biblScope>
            </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0013"/>
            </notesStmt>

            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key="Vitoria, Francisco de">
                                <forename>Francisco</forename>
                                <nameLink>de</nameLink>
                                <surname>Vitoria</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Relectiones Theologicae XII, Vol. 1</title>
                        <title type="main" level="m">Reverendi Patris F. Francisci De Victoria, ordinis Prædictoru[m] sacræ Theologiæ in Salmanticensi Academia quondam primarij Professoris, Relectiones Theologicæ XII.</title>
                        <title type="volume" level="m" n="1">Tomvs Primvs</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lugduni</pubPlace>
                            <date type="firstEd" when="1557">1557</date>
                            <publisher n="firstEd"><persName ref="cerl:cni00045838 gnd:124112331">
                                    <forename>Jacobus</forename>
                                    <surname>Boyerius</surname></persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">487 Seiten ; 8°</extent>
                        <extent xml:lang="en">487 p. ; 8°</extent>
                        <extent xml:lang="es">487 p. ; 8°</extent>
                    </monogr>
                    <series>
                        <title type="main" level="s" ref="work:W0013">Reverendi Patris F. Francisci De Victoria, ordinis Prædictoru[m] sacræ Theologiæ in Salmanticensi 
                            Academia quondam primarij Professoris, Relectiones Theologicæ XII</title>
                        <biblScope unit="volume" n="1" xml:lang="la">Tomvs Primvs</biblScope>
                    </series>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">http://brumario.usal.es/record=b1737070~S6*spi#.VHcHg8l-ZOI</idno>
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
                <change who="#DG" when="2018-12-10" status="g_enriched_approved" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG #auto" when="2018-11-28" status="g_enriched_approved" xml:id="W0013_Vol01_change_020" xml:lang="en">Produced new @xml:id and line numbering.</change>
                <change who="#DG" when="2018-11-28" status="g_enriched_approved" xml:lang="en">Set publication date.</change>
                <change who="#DG" when="2018-11-21" status="g_enriched_approved" xml:lang="en">Set status to g_enriched_approved and updated publishing information.</change>
                <change who="#DG" when="2018-11-13" status="f_enriched" xml:lang="en">Annotated title page further.</change>
                <change who="#DG" when="2018-09-27" status="f_enriched" xml:lang="en">Revision of teiHeader.</change>
                <change who="#DG" when="2018-09-20" status="e_emended_unenriched" xml:lang="en">Revised teiHeader</change>
                <change who="#CB" when="2018-09-18" status="d_hyph_approved" xml:lang="de">Umfassende Korrekturen und Anreicherungen</change>
                <change who="#AW" when="2018-06-27" status="c_hyph_proposed" xml:lang="de">Einzelne Korrekturen</change>
                <change who="#AS #AW" when="2015-08-31" status="c_hyph_proposed" xml:lang="de">Korrekturen aus der Wortliste und (nochmal) Einrückungen und Umbrüche im Rohtext</change>
                <change who="#AW" when="2015-06-03" status="a_raw" xml:lang="de">Struktur/Hierarchie eingetragen bis zum Ende</change>
                <change who="#AW" when="2015-06-03" status="a_raw" xml:lang="de">Struktur/Hierarchie eingetragen bis Z. 12449</change>
                <change who="#AW" when="2015-06-01" status="a_raw" xml:lang="de">Struktur/Hierarchie eingetragen bis Z. 9837</change>
                <change who="#AW" when="2015-05-27" status="a_raw" xml:lang="de">Struktur/Hierarchie eingetragen bis einschl. Vol01Lect02</change>
                <change who="#AW" when="2015-04-23" status="a_raw" xml:lang="de">persNames, bibl, quote und andere Tags eingetragen bis S. 15, Z. 2 (lb n="1015_002").</change>
                <change who="#AW" when="2015-04-10" status="a_raw" xml:lang="de">Erstmals eingelesen und mit (Header- und z.T. Struktur-)Angaben aus Muster-Datei zusammengeführt.</change>
                <change who="#IC" when="2014" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>