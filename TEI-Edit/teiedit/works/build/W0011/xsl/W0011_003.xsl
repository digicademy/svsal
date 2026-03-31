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
    
    <!-- IMPORTANT: 
        - this transformation will only work correctly if there already is a basic TEI skeleton, including 
          a teiHeader specific to the work/volume to be processed
        - define the parameters individually for each work/volume (see below) 
        - optionally, define the teiHeader to be added to the document (if not already added)
    -->
    
    <xsl:output method="xml"/>
    
    <!-- the following parameters need to be stated for each work/volume individually: -->
    <!-- params for work type, no. and ID -->
    <xsl:param name="workId" as="xs:string" select="'W0011'"/>
    <xsl:param name="textId" as="xs:string" select="'completeWork'"/> <!-- "completeWork" (for the whole work) or "Vol_xx" (for volume xx) -->
    <xsl:param name="textType" as="xs:string" select="'work_monograph'"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string" select="'la'"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer" select="0"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <!-- param for text processing mode -->
<!--    <xsl:param name="analyzeTextEnabled" as="xs:boolean" select="true()"/> <!-\- this doens't need to be modified -\->-->
    <!-- params for revisionDesc -->
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-03-20'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformation from TEI Tite to TEI P5.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0011-00-change-00014'"/>
    <!-- schemes for validation, either 'SalTEI' (for validation with the custom Salamanca TEI scheme, or 'TEIAll' for generic TEI): -->
    <xsl:param name="validationScheme" as="xs:string" select="'SalTEI'"/>
    <!-- the teiHeader to be embedded in the document, see the variable at the bottom of this stylesheet -->
    <xsl:param name="teiHeader" xml:space="preserve" select="$teiHeaderCopy"/> 
    
    
    
    <!-- ##################################################################################################################### -->
    
    <!-- remove any existing processing instructions, to be replaced by the ones below -->    
    <xsl:template match="processing-instruction()" priority="2"/>
    
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$validationScheme eq 'SalTEI'">
                <xsl:processing-instruction name="xml-model" >
                    href="https://files.salamanca.school/SvSal_txt.rng"
                    type="application/xml"
                    schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
            </xsl:when>
            <xsl:when test="$validationScheme eq 'TEIAll'">
                <xsl:processing-instruction name="xml-model">
                    href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"
                </xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
                <xsl:processing-instruction name="xml-model">
                    href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	                schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <xsl:text>&#xA;</xsl:text>
            </xsl:when>
            <xsl:otherwise><xsl:message terminate="yes"/></xsl:otherwise>
        </xsl:choose>
        
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
            <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"/>
            <xsl:attribute name="xml:id" select="$workId"/>
            
            <xsl:copy-of select="$teiHeader"/>
            
            <xsl:apply-templates/>
            
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <xsl:element name="text">
            <xsl:attribute name="type" select="$textType"/>
            <xsl:attribute name="xml:lang" select="$textLang"/>
            <xsl:if test="$volumeNumber > 0">
                <xsl:attribute name="n" select="$volumeNumber"/>
            </xsl:if>
            <xsl:attribute name="xml:id" select="$textId"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- templates for processing elements within tei:text are included from W0014_002-b.xsl -->
    <xsl:include href="W0011_003b.xsl"/>
    
    
    
    <!-- ######################################################################################################################## -->
    
    <!-- provide a copy of the teiHeader to be included in the document here, in the following variable; keep in mind to include  
         information about the current transformation step in the revisionDesc-->
    
<xsl:variable name="teiHeaderCopy" xml:space="preserve">
    <teiHeader>
        <fileDesc>
            
            <titleStmt>
                <title type="short" level="m">De Iustitia et Iure</title>
                <title type="main" level="m">Fratris Dominici Soto Segouiensis, Theologi, ordinis Prædicatorum, 
                    Cæsareæ Maiestati à sacris confessionibus, Salmantini Professoris, De Iustitia &amp; Iure Libri decem</title>
                <author>
                    <persName ref="author:A0083 gnd:118798111 cerl:cnp01327727" key="Soto, Domingo de">
                        <forename>Domingo</forename>
                        <nameLink>de</nameLink>
                        <surname>Soto</surname>
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
                <editor xml:id="CR">
                    <persName ref="orcid:0000-0001-5095-1793" full="yes">
                        <surname full="yes">Rico Carmona</surname>, <forename full="yes">Cindy</forename>
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
                            <persName ref="author:A0083 gnd:118798111 cerl:cnp01327727" key="Soto, Domingo de">
                                <forename>Domingo</forename>
                                <nameLink>de</nameLink>
                                <surname>Soto</surname>
                            </persName>
                        </author>
                        <title type="short" level="m">De Iustitia et Iure</title>
                        <title type="main" level="m">Fratris Dominici Soto Segouiensis, Theologi, ordinis Prædicatorum, 
                            Cæsareæ Maiestati à sacris confessionibus, Salmantini Professoris, De Iustitia &amp; Iure Libri decem</title>
                        <imprint>
                           <pubPlace role="firstEd" ref="getty:7002835" key="Salamanca">Salamanticae</pubPlace>
                           <date type="firstEd" when="1553">1553</date>
                            <publisher n="firstEd">
                                <persName ref="gnd:1037609387" key="Portonariis, Andreas de"><!--not found in CERL-->
                                    <forename>Andrea</forename>
                                    <nameLink>à</nameLink>
                                    <surname>Portonariis</surname>
                                </persName>
                            </publisher>
                        </imprint>
                        <extent xml:lang="de">904 Seiten, 60 ungezählte Seiten ; 2°</extent>
                        <extent xml:lang="en">904, [60] p. ; 2°</extent>
                        <extent xml:lang="es">904, [60] p. ; 2°</extent>
                    </monogr>
                </biblStruct>
                <msDesc>
                    <msIdentifier>
                        <repository ref="gnd:1023420-2" xml:lang="en">British Library</repository>
                        <idno type="catlink" xml:lang="en">http://explore.bl.uk/primo_library/libweb/action/dlDisplay.do?vid=BLVU1&amp;docId=BLL01003445097</idno>
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
        
        <revisionDesc status="a_raw">
            <listChange ordered="true">
                <change who="{$editors}" when="{$editingDate}" status="a_raw" xml:lang="en" xml:id="{$changeId}"><xsl:value-of select="$editingDesc"/></change>
                <change who="#CR #auto" when="2019-03-20" status="a_raw" xml:lang="en">Added missing pb@n.</change>
                <change who="#CR" when="2019-03-12" status="a_raw" xml:lang="en">Structural annotation.</change>
                <change who="#DG" when="2018-12-10" status="a_raw" xml:lang="en">Revised metadata (titles, extent) according to RDA guidelines</change>
                <change who="#DG" when="2018-09-26" status="a_raw" xml:lang="en">Revision of teiHeader and status reset.</change>
                <change who="#AW" when="2015-08-28" status="a_raw">reset status</change>
                <change who="#IC" when="2014-11-27" status="a_raw">revision of teiHeader</change>
                <change who="#IC" when="2014-11-18" status="a_raw">titleStmt und sourceDesc angepassrt</change>
                <change who="#AW" when="2014-03-26" status="a_raw">Überarbeitet nach neuem Schema/Editionsrichtlinien</change>
                <change who="#AW" when="2013-10-05" status="a_raw">Seitenumbrüche *vor* die Abschnitte gezogen</change>
                <change who="#AW" when="2013-09-27" status="a_raw">Anpassung nach Schema-Update</change>
                <change who="#AW" when="2013-09-17" status="a_raw">
                    <list>
                        <item xml:id="item_gjtddx">Leerräume und Zeilenumbrüche angepasst</item>
                        <item xml:id="item_ljchfsd">führende Nullen in @n-Tags entfernt</item>
                        <item xml:id="item_segdtzj">Kommentare und Fragen aus den vorausgegangenen Beratungen übernommen</item>
                        <item xml:id="item_awef33v5">Typen von text und div-tags z.T. angepasst.</item>
                    </list>
                </change>
                <change who="#AW" when="2013-08-22" status="a_raw">Nach Schema-Updates
                    angepasst.</change>
                <change who="#AW" when="2013-08-13" status="a_raw">Datei(en) aufgeteilt und mit XInclude
                    zusammengehalten (Header und die div. Teile des mehrbändigen Werkes).</change>
                <change who="#AW" when="2013-08-08" status="a_raw">Ausgehend von Testdatensatz W0014 angelegt, um
                    das schwierige Layout abzubilden</change>
                <change who="#CB" when="2012" status="a_raw" xml:lang="en">Identification of basic bibliographic data.</change>
            </listChange>
        </revisionDesc>
    </teiHeader>
</xsl:variable>
</xsl:stylesheet>