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
                <title type="short" level="m">Provechoso tratado de cambios y contrataciones de mercaderes y reprovación de usura.</title>
                <title type="main" level="m">Prouechoso tratado de cambios y contrataciones de mercaderes y reprouacion de vsura; prouechoso para conoscer los tratantes en que pecan y necessario para los confessores sabellos juzgar ; visto por los señores ynquisidores</title>
                <author>
                    <persName ref="author:A0098 cerl:cnp01326236 viaf:7423594 gnd:1089545509" key="Villalón, Cristóbal de" full="yes">
                        <forename full="yes">Cristóbal</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">Villalón</surname>
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
                <edition n="1.0.0" xml:id="W0113-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2020-04-27">2020-04-27</date>.
                </edition>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" when="2020-04-27">2020-04-27.</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0113</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0113?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0113?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0113?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0113?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0113?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0113?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="15"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0098 cerl:cnp01326236 viaf:7423594 gnd:1089545509" key="Villalón, Cristóbal de" full="yes">
                                <forename full="yes">Cristóbal</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">Villalón</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Provechoso tratado de cambios y contrataciones de mercaderes y reprovación de usura.</title>
                        <title type="main" level="m">Prouechoso tratado de cambios y contrataciones de mercaderes y reprouacion de vsura; prouechoso para conoscer los tratantes en que pecan y necessario para los confessores sabellos juzgar ; visto por los señores ynquisidores</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002848" key="place">Valladolid</pubPlace>
                            <date type="firstEd" when="1541">1541</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00092530 viaf:313314828 gnd:1055667210" key="Fernandez de Córdoba, Francisco de" full="yes">
                                    <forename full="yes">Francisco</forename>
                                    <surname full="yes">Fernandez d[e] Cordoua</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">xlv, das heißt xlvi Blätter, 1 ungezählte Seite</extent>
                        <extent xml:lang="en">xlv, [1] l. ; Fol.</extent>
                        <extent xml:lang="es">xlv, [1] h. ; Fol.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:023445289 cerl:xxx" xml:lang="es">Universidad de Salamanca</repository>
                        <idno type="catlink" xml:lang="es">https://gredos.usal.es/handle/10366/48761</idno>
                    </msIdentifier>
                    <physDesc>
                        <typeDesc>
                            <typeNote n="antiqua" xml:lang="en">Rotunda</typeNote>
                        </typeDesc>
                    </physDesc>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        
        <profileDesc>
           <langUsage>
              <language ident="es" n="main" xml:lang="en">Spanish</language>
           </langUsage>
        </profileDesc>
        
        <encodingDesc>
            <projectDesc><p xml:id="meta-pa-0004" part="N"><ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref></p></projectDesc>
                
            <editorialDecl>
                <p xml:id="meta-pa-0005" part="N"><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref></p>
                    
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
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_022" xml:lang="en">teiHeader update.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_021" xml:lang="en">Generated @xml:id after corrections.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_020" xml:lang="en">Numbered lines after corrections.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:lang="en" xml:id="W0113_change_019">Tagged special characters after corrections.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_018" xml:lang="en">Correct choice/(pb|cb|lb) pairings.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_017" xml:lang="en">Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_016" xml:lang="en">Post-correction fixes.</change>
                <change who="#DG #CR #auto" when="2020-04-27" status="g_enriched_approved" xml:id="W0113_change_015" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-04-07" status="g_enriched_approved" xml:id="W0113_change_014" xml:lang="en">Second round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-04-06" status="g_enriched_approved" xml:id="W0113_change_013" xml:lang="en">Reduced excessive whitespace.</change>
                <change who="#CB" when="2020-04-03" status="g_enriched_approved" xml:id="W0113_change_012" xml:lang="en">First round of corrections (CB).</change>
                <change who="#DG #CR #auto" when="2020-03-26" status="f_enriched" xml:id="W0113_change_011" xml:lang="en">Tag unmarked breaks (es).</change>
                <change who="#DG #CR #auto" when="2020-03-26" status="f_enriched" xml:id="W0113_change_010" xml:lang="en">Automatically expanded abbreviations (es-main).</change>
                <change who="#DG #CR #auto" when="2020-03-25" status="f_enriched" xml:id="W0113_change_009" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2020-03-25" status="f_enriched" xml:id="W0113_change_008" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2020-03-25" status="c_hyph_proposed" xml:lang="en" xml:id="W0113_change_007">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2020-03-25" status="c_hyph_proposed" xml:id="W0113_change_006" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2020-03-25" status="a_raw" xml:id="W0113_change_005" xml:lang="en">Transformation from TEI Tite to TEI P5.</change>
                <change who="#CR #auto" when="2020-03-25" status="a_raw" xml:id="W0113_change_004" xml:lang="en">Added @n, @type, @xml:id to div2.</change>
                <change who="#CR" when="2020-03-24" status="a_raw" xml:id="W0113_change_003" xml:lang="en">Structural annotation.</change>
                <change who="#CR" when="2020-01-14" status="a_raw" xml:id="W0113_change_002" xml:lang="en">Set teiHeader.</change>
                <change who="#CB" when="2015" status="a_raw" xml:id="W0113_change_001" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>