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
                <title type="short" level="m">Universae Theologiae Moralis receptiores</title>
                <title type="main" level="m">R. P. Antonii De Escobar Et Mendoza, Vallisoletani, Societatis Iesv Theologi, Universae theologiae moralis, receptiores absque Lite Sententiae nec-non Controuersae Disquisitiones,</title>
                <title type="volume" level="m" n="9">Tomi Sexti Pars Altera</title>
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
                <edition n="1.0.0" xml:id="W0043_Vol09-version1" xml:lang="en">
                    Complete digitized edition, <date type="digitizedEd" when="2024-11-26">2024-11-26</date>.
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
                <date type="digitizedEd" when="2024-11-26">2024-11-26</date>
                <idno>
                    <idno xml:id="urlid">https://id.salamanca.school/texts/W0043:vol9</idno>
                    <idno xml:id="urltei">https://id.salamanca.school/texts/W0043:vol9?format=tei</idno>
                    <idno xml:id="urlhtml">https://id.salamanca.school/texts/W0043:vol9?format=html</idno>
                    <idno xml:id="urlrdf">https://id.salamanca.school/texts/W0043:vol9?format=rdf</idno>
                    <idno xml:id="urliiif">https://id.salamanca.school/texts/W0043:vol9?format=iiif</idno>
                    <idno xml:id="urltxtorig">https://id.salamanca.school/texts/W0043:vol9?format=txt&amp;mode=orig</idno>
                    <idno xml:id="urltxtedit">https://id.salamanca.school/texts/W0043:vol9?format=txt&amp;mode=edit</idno>
                </idno>
            </publicationStmt>

            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
               <biblScope unit="volume" n="33.9">Volume 33.9</biblScope>
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
                        <title type="short" level="m">Universae Theologiae Moralis receptiores</title>
                        <title type="main" level="m">R. P. Antonii De Escobar Et Mendoza, Vallisoletani, Societatis Iesv Theologi, Universae theologiae moralis, receptiores absque Lite Sententiae nec-non Controuersae Disquisitiones,</title>
                        <title type="volume" level="m" n="9">Tomi Sexti Pars Altera</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008772" key="Lyon">Lvgdvni</pubPlace>
                            <date type="firstEd" when="1652">1663</date>
                            <date type="summaryFirstEd" when="1652">1.1652 - 10.1663</date>
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
                        <extent xml:lang="de">[2] Bl., 186 S., [10] Bl.</extent>
                        <extent xml:lang="en">[2] l., 186 p., [10] l.</extent>
                        <extent xml:lang="es">[2] h., 186 p., [10] h.</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:004876156" xml:lang="de">Staatsbibliothek München</repository>
                        <idno type="catlink" xml:lang="de">https://opacplus.bsb-muenchen.de/title/BV035557741</idno>
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
                <xi:fallback>
                    <projectDesc>
                        <p xml:id="meta-pa-0004">
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the project, please 
                               refer to our website.</ref>
                        </p>
                    </projectDesc>
                </xi:fallback>
            </xi:include>
            <editorialDecl>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/tei:p)">
                    <xi:fallback>
                        <p xml:id="meta-pa-0005">
                            <ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
                                refer to our website.</ref>
                        </p>
                    </xi:fallback>
                </xi:include>
                <p xml:id="W0043_Vol09_AEW">Only automatically edited work: it contains automatic hypenation of marked and unmarked words in the pb, cb and lb elements.
                   Abbreviations are partially resolved.</p>
            </editorialDecl>
            <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/specialchars.xml" xpointer="charDecl">
                <xi:fallback>
                    <charDecl>
                        <char xml:lang="en">
                            <note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/specialchars.xml">project website</ref>.</note>
                        </char>
                    </charDecl>
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
                <change who="#CR #auto" when="2024-11-26" status="g_enriched_approved" xml:id="W0043_Vol09_change_019" xml:lang="en">teiHeader Update for online publication. </change>
                <change who="#CB" when="2024-10-30" status="f_enriched" xml:id="W0043_Vol09_change_018" xml:lang="en">9 unclear resolved by CB.</change>
                <change who="#CR #auto" when="2024-11-26" status="g_enriched_approved" xml:id="W0043_Vol09_change_017" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>
                <change who="#DG #CR #auto" when="2024-11-14" status="f_enriched" xml:id="W0043_Vol09_change_016" xml:lang="en">Automatically expanded abbreviations (la-marginal).</change>
                <change who="#DG #CR #auto" when="2024-11-14" status="f_enriched" xml:id="W0043_Vol09_change_015" xml:lang="en">Automatically expanded abbreviations (la-main).</change>
                <change who="#DG #CR #auto" when="2024-11-14" status="f_enriched" xml:id="W0043_Vol09_change_014" xml:lang="en">Tag unmarked breaks (la).</change>
                <change who="#DG #CR #auto" when="2024-05-21" status="f_enriched" xml:id="W0043_Vol09_change_013" xml:lang="en">Generated @xml:id.</change>
                <change who="#DG #CR #auto" when="2024-05-21" status="f_enriched" xml:id="W0043_Vol09_change_012" xml:lang="en">Numbered lines.</change>
                <change who="#DG #CR #auto" when="2024-05-21" status="f_enriched" xml:id="W0043_Vol09_change_011" xml:lang="en">Annotate Hyphenation</change>
                <change who="#DG #CR #auto" when="2024-05-21" status="f_enriched" xml:lang="en" xml:id="W0043_Vol09_change_010">Tagged special characters.</change>
                <change who="#CR #auto" when="2024-05-21" status="a_raw" xml:lang="en" xml:id="W0043_Vol09_change_009">Transformation TEI-tite to TEI-All.</change>
                <change who="#CR #auto" when="2024-05-16" status="a_raw" xml:lang="en" xml:id="W0043_Vol09_change_008">Added (la) abbreviations depending on word structure with regex.</change>
                <change who="#CR #auto" when="2024-05-07" status="a_raw" xml:lang="en" xml:id="W0043_Vol09_change_007">Tagged @n, @type, @xml:id(s) in div(s).</change>
                <change who="#CR" when="2024-04-30" status="a_raw" xml:lang="en" xml:id="W0043_Vol09_change_006">Structural annotation and unclear marks.</change>
                <change who="#CR" when="2021-06-18" status="a_raw" xml:lang="en">teiHeader title update.</change>
                <change who="#CR" when="2020-07-08" status="a_raw" xml:lang="en">teiHeader update.</change>
                <change who="#MT" when="2017-11-28" status="a_raw">Perma-Link des Kataloges eingetragen</change>
                <change who="#MT" when="2017-11-22" status="a_raw">Korrekturen beim Autoren-Eintrag für die Vorlage</change>
                <change who="#MT" when="2017-11-21" status="a_raw">Erstellung der XML-Datei</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>