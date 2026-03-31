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
                <title type="short" level="m">Universae Theologiae Moralis receptiores.</title>
                <title type="main" level="m">R.P. Antonii De Escobar Et Mendoza, Vallisoletani, Societatis Iesv Theologi, Vniversae Theologiae Moralis, Receptiores Absqve Lite Sententiae nec non Problematicae disquisitiones, Siue quod frequentius, Doctoribus consentientibus, asserendum eligitur: &amp; quod, dissentientibus plerumque in vtrumuis probabile apponitur</title>
                <title type="volume" level="m" n="2">Volvmen Secvndvm</title>
                <author>
                    <persName ref="author:A0029 gnd:121064751 cerl:cnp01036518" key="Escobar y Mendoza, Antonio de"> 
                        <forename>Antonio</forename>
                        <nameLink>de</nameLink>
                        <surname>Escobar y Mendoza</surname>
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
                <editor xml:id="MAH" role="#scholarly #technical">
                    <persName ref="orcid:0000-0003-4124-0214">
                        <surname>Hugel</surname>, <forename>Marie-Astrid</forename>
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
                    <persName ref="orcid:0000-0002-1488-6477">
                        <surname>Thönes</surname>, <forename>Martin</forename>
                    </persName>
                </editor>
            </titleStmt>

            <editionStmt>
                <edition n="1.0.0" xml:id="W0043_Vol02-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2024-08-06">2024-08-06</date>.
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
                <date type="digitizedEd" when="2024-08-06">2024-08-06</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0043:vol2</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0043:vol2?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0043:vol2?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0043:vol2?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0043:vol2?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0043:vol2?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0043:vol2?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="33.2">Volume 33.2</biblScope>
           </seriesStmt>
            
            <notesStmt>
                <relatedItem type="work_multivolume" target="work:W0043"/>
            </notesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0029 gnd:121064751 cerl:cnp01036518" key="Escobar y Mendoza, Antonio de">
                                <forename>Antonio</forename>
                                <nameLink>de</nameLink>
                                <surname>Escobar y Mendoza</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Universae Theologiae Moralis receptiores.</title>
                        <title type="main" level="m">R.P. Antonii De Escobar Et Mendoza, Vallisoletani, Societatis Iesv Theologi, Vniversae Theologiae Moralis, Receptiores Absqve Lite Sententiae nec non Problematicae disquisitiones, Siue quod frequentius, Doctoribus consentientibus, asserendum eligitur: &amp; quod, dissentientibus plerumque in vtrumuis probabile apponitur</title>
                        <title type="volume" level="m" n="2">Volvmen Secvndvm</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lvgdvni</pubPlace>
                            <date type="firstEd" when="1652">1655</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00028037" key="Arnaud, Laurent">
                                    <forename>Laurent</forename>
                                    <surname>Arnaud</surname>
                                </persName>
                                <persName ref="cerl:cni00025649" key="Borde, Philippe">
                                    <forename>Philippe</forename>
                                    <surname>Borde</surname>
                                </persName>
                                <persName ref="cerl:cni00006903" key="Rigaud, Claude">
                                    <forename>Claude</forename>
                                    <surname>Rigaud</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">44 ungezählte Seiten, 572 Seiten, 14 ungezählte Seiten</extent>
                        <extent xml:lang="en">[44] p., 572 p., [14] p.</extent>
                        <extent xml:lang="es">[44] p., 572 p., [14] p.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004876156" xml:lang="de">Staatsbibliothek München</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/title/BV035557735</idno>
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
                <p xml:id="W0043_Vol02_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
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
                <change who="#CR #auto" when="2024-10-15" status="g_enriched_approved" xml:id="W0043_Vol02_change_020" xml:lang="en">teiHeader update: added p xml:id="W0043_Vol02_AEW".</change>
                <change who="#CR #auto" when="2024-08-06" status="g_enriched_approved" xml:id="W0043_Vol02_change_019" xml:lang="en">teiHeader update for online publication.</change>
                <change who="#CR #auto" when="2024-08-01" status="f_enriched" xml:id="W0043_Vol02_change_018" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#CB" when="2024-07-30" status="g_enriched_approved" xml:id="W0043_Vol02_change_017" xml:lang="en">Resolution of remaining unclear marks.</change>
                <change who="#DG #CR #auto" when="2024-06-20" status="f_enriched" xml:id="W0043_Vol02_change_016" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2024-06-20" status="f_enriched" xml:id="W0043_Vol02_change_015" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2024-06-25" status="f_enriched" xml:id="W0043_Vol02_change_014" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2022-04-19" status="f_enriched" xml:id="W0043_Vol02_change_013" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2022-04-19" status="f_enriched" xml:id="W0043_Vol02_change_012" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2022-04-19" status="f_enriched" xml:lang="en" xml:id="W0043_Vol02_change_011">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2022-04-19" status="f_enriched" xml:lang="en" xml:id="W0043_Vol02_change_010">Annotated hyphenated breaks.</change>
                <change who="#DG #CR #auto" when="2022-04-07" status="a_raw" xml:lang="en" xml:id="W0043_Vol02_change_009">Transformation from TEI-Tite to TEI-All.</change>
                <change who="#CR #auto" when="2022-04-07" status="a_raw" xml:lang="en" xml:id="W0043_Vol02_change_008">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2021-11-16" status="a_raw" xml:lang="en" xml:id="W0043_Vol02_change_007">Tagged @type in div(s), list(s) and links in toc.</change>
                <change who="#CR" when="2021-10-26" status="a_raw" xml:lang="en" xml:id="W0043_Vol02_change_006">Structural annotation started.</change>
                <change who="#CR" when="2021-06-18" status="a_raw" xml:lang="en">teiHeader title update.</change>
                <change who="#CR" when="2020-07-01" status="a_raw" xml:lang="en">teiHeader update.</change>
                <change who="#MT" when="2017-11-28" status="a_raw">Perma-Link des Kataloges eingetragen</change>
                <change who="#MT" when="2017-11-22" status="a_raw">Korrekturen beim Autoren-Eintrag für die Vorlage</change>
                <change who="#MT" when="2017-11-21" status="a_raw">Erstellung der XML-Datei</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>