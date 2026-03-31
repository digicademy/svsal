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
                <title type="short" level="m">Summa Sacramentorum</title>
                <title type="main" level="m">Summa sacramentorum Ecclesiae</title>
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
                <editor xml:id="AW">
                    <persName ref="gnd:108835820">
                        <surname>Wagner</surname>, <forename>Andreas</forename>
                    </persName>
                </editor>
            </titleStmt>
            
            <editionStmt>
               <edition n="unpublished"/>
            </editionStmt>
            
            <publicationStmt xml:id="publicationStmt">
            	<xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:publicationStmt/*)">
            		<xi:fallback><publisher><ref target="https://www.salamanca.school" xml:lang="en">For information about the digital edition, please 
            					refer to our website.</ref></publisher>
            		</xi:fallback>
            	</xi:include>
            	<date type="digitizedEd" n="unpublished"/>
            	<idno/>
            </publicationStmt>
            
            <seriesStmt>
                <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:fileDesc/tei:seriesStmt/*)">
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
                            <persName ref="author:A0100 cerl:cnp01234843 gnd:118768735" key="Vitoria, Francisco de">
                                <forename>Francisco</forename>
                                <nameLink>de</nameLink>
                                <surname>Vitoria</surname>
                            </persName>
                        </author>
                        <editor>
                            <persName ref="viaf:17576008 cerl:cni00049414" key="Chaves, Thomas de">
                                <forename>Thomas</forename>
                                <nameLink>de</nameLink>
                                <surname>Chaves</surname>
                            </persName>
                        </editor>
                        <title type="short" level="m">Summa Sacramentorum</title>
                        <title type="main" level="m">Svmma Sacramentorvm Ecclesiæ : Ex doctrina doctissimi patris magistri fratris Francisci a Victoria, cathedram primæ in Salmanticensi florentissima academia profitentis, ex sacra predicatorum familia oriundi / co[n]gesta per fratrem Thomam de Chaues eius fidelem discipulu[m]</title>
                        <title type="245a" level="m">Summa Sacramentorum Ecclesiae : ex doctrina doctissimi patris magistri fratris Fratris Francisci a Victoria, cathedram primae in Salmanticensi florentissima academia profitentis, ex sacra predicatorum familia oriundi / congesta per fratrem Thomam de Chaues eius fidelem discipulum</title>
                        <imprint>
                            <pubPlace role="firstEd" ref="getty:7008771" key="Valladolid">Pinciae</pubPlace>
                            <date type="firstEd" when="1561">1561</date>
                            <publisher n="firstEd">
                                <persName ref="cerl:cni00031746" key="Martinez, Sebastián">
                                    <forename>Sebastianus</forename>
                                    <surname>Martinez</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">[8], 248, [10] Bl. ; 8°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:4313400-2" xml:lang="es">Bibliotecas de la Universidad de Salamanca</repository>
                        <idno type="catlink">http://brumario.usal.es/record=b1725183~S6*spi</idno>
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
              <language ident="la" usage="99" n="main" xml:lang="en">Latin</language>
              <language ident="es" usage="1" xml:lang="en">Spanish</language>
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
                <normalization>
                   <p xml:id="meta-pa-0006" xml:lang="en">The "long s" character (<q>ſ</q>) was normalized, 
                      i.e. resolved to <q>s</q>.</p>
                </normalization>
            </editorialDecl>
            <xi:include href="../meta/W_Head_general.xml" xpointer="xmlns(tei=http://www.tei-c.org/ns/1.0)xpointer(//tei:encodingDesc/tei:editorialDecl/following-sibling::*)">
                <xi:fallback/>
            </xi:include>
            <xi:include href="../meta/Sonderzeichen.xml" xpointer="charDecl">
                <xi:fallback><charDecl><char xml:lang="en"><note xml:id="meta-no-0001">The definition of 
                     non-standard characters could not be embedded, but it is available on the 
                     <ref target="https://files.salamanca.school/Sonderzeichen.xml">project website</ref>.</note></char></charDecl>
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
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#DG #auto" when="2018-08-20" status="a_raw" xml:id="W0014_change_0017" xml:lang="en">Created @xml:id.</change>
                <change who="#DG #auto" when="2018-08-17" status="a_raw" xml:lang="en" xml:id="W0014_change_0016">Tagged special characters.</change>
                <change who="#DG #auto" when="2018-08-17" status="a_raw" xml:lang="en" xml:id="W0014_change_0015">Automatically resolved hyphenations.</change>
                <change who="#DG #auto" when="2018-08-16" status="a_raw" xml:id="W0014_change_0014" xml:lang="en">Automatically added cross-references in table of contents.</change>
                <change who="#DG #auto" when="2018-08-16" status="a_raw" xml:id="W0014_change_0013" xml:lang="en">Resolving marginal notes with leading numbers as head[@place=margin]</change>
                <change who="#DG #auto" when="2018-08-10" status="a_raw" xml:id="W0014_change_0012" xml:lang="en">Enriched titlePage elements.</change>
                <change who="#DG #auto" when="2018-08-10" status="a_raw" xml:lang="en" xml:id="W0014-00-change-0011">Transformation from TEI Tite to SalTEI.</change>
                <change who="#DG #auto" when="2018-08-09" status="a_raw" xml:lang="en">
                    <list>
                        <item xml:id="W0014-00-change-0010">Added pagination (pb/@n), fixed page order.</item>
                        <item xml:id="W0014-00-change-0009">Added structural annotations (div, head, p).</item>
                        <item xml:id="W0014-00-change-0008">Annotated table of contents (back matter) as list (normalizing the heading structure, see head[@change="#W0014-00-change-0008"]).</item>
                        <item xml:id="W0014-00-change-0007">Resolved some unclear marks.</item>
                        <item xml:id="W0014-00-change-0006">Normalized marginal note structure, aligning "divergent" notes with their 
                            actual paragraphs and combining page-breaking notes; 
                            resolved number-only marg. notes as milestone elements (see //milestone).</item>
                    </list>
                </change>
                <change who="#DG" when="2018-08-09" status="a_raw" xml:lang="en">Added basic structural markup to TEI Tite text (front/body/back, div, titlePage, head, ...).</change>
                <change who="#AW" when="2015-08-28" status="a_raw" xml:lang="en">Reset status.</change>
                <change who="#IC" when="2014-11-27" status="a_raw" xml:lang="en">Revision of teiHeader.</change>
                <change who="#IC" when="2014-11-18" status="a_raw" xml:lang="de">titleStmt und sourceDesc angepasst.</change>
                <change who="#AW" when="2014-03-26" status="a_raw" xml:lang="de">teiHeader überarbeitet nach neuem Schema/Editionsrichtlinien.</change>
                <change who="#AW" when="2013-09-27" status="a_raw" xml:lang="de">teiHeader überarbeitet nach Schema-Update.</change>
                <change who="#AW" when="2013-08-22" status="a_raw" xml:lang="de">teiHeader nach Schema-Updates angepasst.</change>
                <change who="#AW" when="2013-08-13" status="a_raw" xml:lang="de">Datei(en) aufgeteilt und mit XInclude
                    zusammengehalten (Header und die div. Teile des mehrbändigen Werkes).</change>
                <change who="#AW" when="2013-08-08" status="a_raw" xml:lang="de">Ausgehend von Testdatensatz W0014 angelegt, um
                    das schwierige Layout abzubilden.</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
    
</xsl:stylesheet>