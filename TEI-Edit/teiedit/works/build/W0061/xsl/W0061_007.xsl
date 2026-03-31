<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    xmlns:tite="http://www.tei-c.org/ns/tite/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0"
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
    
    <xsl:template match="tei:TEI">
        <xsl:text>&#xa;</xsl:text>
        <xsl:copy copy-namespaces="no">
            <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
            <xsl:copy-of select="@*"></xsl:copy-of>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:teiHeader">
        <xsl:copy-of select="$teiHeader"/>
    </xsl:template>
    
    
<xsl:variable name="teiHeader" xml:space="preserve">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title type="short" level="m">Confirmaciones Reales de Encomiendas</title>
                <title type="main" level="m">Tratado De Confirmaciones Reales De Encomiendas, Oficios i casas, en que se requieren para las Indias Occidentales</title>
                <author>
                    <persName ref="author:A0046 gnd:189570571 cerl:cnp01324640" key="León Pinelo, Antonio de" full="yes">
                        <forename full="yes">Antonio</forename>
                        <nameLink>de</nameLink>
                        <surname full="yes">León Pinelo</surname>
                    </persName>
                </author>
                <editor xml:id="CB" role="#scholarly">
                    <persName ref="gnd:138962987" full="yes">
                        <surname full="yes">Birr</surname>, <forename full="yes">Christiane</forename>
                    </persName>
                </editor>
                <editor xml:id="DG" role="#technical">
                    <persName ref="orcid:0000-0002-0273-3844" full="yes">
                        <surname full="yes">Glück</surname>, <forename full="yes">David</forename>
                    </persName>
                </editor>
                <editor xml:id="CR" role="#technical">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
                    </persName>
                </editor>
                <editor xml:id="MT" role="#technical">
                    <persName ref="orcid:0000-0002-1488-6477" full="yes">
                        <surname full="yes">Thönes</surname>, <forename full="yes">Martin</forename>
                    </persName>
                </editor>
                <editor xml:id="AW" role="#technical">
                    <persName ref="gnd:108835820" full="yes">
                        <surname full="yes">Wagner</surname>, <forename full="yes">Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="unpublished"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/works-general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
                    <xi:fallback>
                       <title xml:lang="en"><ref target="https://www.salamanca.school" xml:lang="en">The School of Salamanca. A Digital Collection of Sources</ref></title>
                    </xi:fallback>
                </xi:include>
                <biblScope unit="volume" n="unpublished"/>
            </seriesStmt>
            
            <sourceDesc>
                <biblStruct>
                    <monogr>
                        <author>
                            <persName ref="author:A0046 gnd:189570571 cerl:cnp01324640" key="León Pinelo, Antonio de" full="yes">
                                <forename full="yes">Antonio</forename>
                                <nameLink>de</nameLink>
                                <surname full="yes">León Pinelo</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">Confirmaciones Reales de Encomiendas</title>
                        <title type="main" level="m">Tratado De Confirmaciones Reales De Encomiendas, Oficios i casas, en que se requieren para las Indias Occidentales</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7002795" key="Madrid">Madrid</pubPlace>
                            <date type="firstEd" when="1630">1630</date>
                            
                            <publisher n="firstEd"> 
                                <persName ref="cerl:cni00043826" key="González, Juan" full="yes">
                                    <forename full="yes">Juan</forename>
                                    <nameLink/>
                                    <surname full="yes">González</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[16], 173, [17] Bl. ; 4°</extent>
                        <extent xml:lang="en">[16], 173, [17] l. ; 4°</extent>
                        <extent xml:lang="es">[16], 173, [17] h. ; 4°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:050361031" xml:lang="es">Staatsbibliothek zu Berlin</repository>
                        <idno type="catlink">http://stabikat.de/DB=1/XMLPRS=N/PPN?PPN=455236585</idno>
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
              <language ident="es" n="main" xml:lang="en">Spanish</language>
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
        
        <revisionDesc status="a_raw">
            <listChange ordered="true">
                <change who="#CR #auto" when="2020-10-26" status="a_raw" xml:lang="en">Added (es) abbreviations depending on word endings with regex.</change>
                <change who="#DG #CR #auto" when="2018-09-12" status="a_raw" xml:lang="en" xml:id="W0061-change-010">Tagged special characters.</change>
                <change who="#DG #CR #auto" when="2018-09-11" status="a_raw" xml:lang="en" xml:id="W0061-change-009">Transformation from TEI Tite to TEI P5..</change>
                <change who="#DG #MT" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG #CR #auto" when="2018-09-10" status="a_raw" xml:lang="en" xml:id="W0061-change-008">Adding ref @target for note anchors.</change>
                <change who="#DG #CR #auto" when="2018-09-10" status="a_raw" xml:lang="en" xml:id="W0061-change-007">Added cross references in summaries.</change>
                <change who="#DG #CR #auto" when="2018-09-10" status="a_raw" xml:lang="en" xml:id="W0061-change-006">Adding @xml:id and @unit to milestones.</change>
                <change who="#CR" when="2018-12-18" status="a_raw">Title rearrangement.</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#CR" when="2018-09-11" status="a_raw">Orcid-ID von CR eingetragen</change>
                <change who="#CR" when="2018-09-10" status="a_raw">Structural Annotation</change>
                <change who="#DG" when="2017-12-22" status="a_raw">Conversion to TEI and basic structural annotations</change>
                <change who="#MT" when="2017-11-28" status="a_raw">Added CatLink</change>
                <change who="#MT" when="2017-11-16" status="a_raw">Metadata created</change>
                <change who="#TL" when="2017-11-01" status="a_raw">Text recognition and basic TEI-tite encoding</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>