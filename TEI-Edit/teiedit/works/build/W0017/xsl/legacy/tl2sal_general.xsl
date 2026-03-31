<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tite="http://www.tei-c.org/ns/tite/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <xsl:output method="xml"/> <!-- indent="yes" -->
    
    
    <!-- #### general parameters (received by stylesheet for specific work) -->
    
    <xsl:param name="workId" as="xs:string"/>
    <xsl:param name="textId" as="xs:string"/>
    <xsl:param name="textType" as="xs:string"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    <xsl:param name="teiStub" as="xs:string"/>
    <xsl:param name="generalTeiSchema" as="xs:boolean"/>
    <xsl:param name="fragmentationDepth" as="xs:integer"/>
    <xsl:param name="analyzeTextEnabled" as="xs:boolean"/> 
    
    <!-- If a node not captured further below is observed, throw error & terminate - this ensures that every transformation is explicitely contained in this stylesheet -->
    <xsl:template match="@*|node()"> 
        <xsl:message terminate="yes">Error: unknown xml entity</xsl:message>
        <!--<xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>-->
    </xsl:template>
    
    <!-- #### generate processing instructions and TEI header #### -->
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$generalTeiSchema">
                <xsl:processing-instruction name="xml-model">
                    href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"
                </xsl:processing-instruction>
                <xsl:processing-instruction name="xml-model">
                    href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml"
	                schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            </xsl:when>
            <xsl:otherwise>
                <xsl:processing-instruction name="xml-model" >
            href="https://files.salamanca.school/SvSal_txt.rng"
            type="application/xml"
            schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
            <xsl:attribute name="xml:id" select="$workId"/>
            <xsl:for-each select="1 to $fragmentationDepth">
                <xsl:processing-instruction name="svsal" select="concat('htmlFragmentationDepth=&quot;', string($fragmentationDepth), '&quot; ')"/>
            </xsl:for-each>
            <xsl:element name="teiHeader">
                <xsl:choose>
                    <xsl:when test="doc-available($teiStub)">
                        <!-- important: disable XInclude processing in XML parser AND in XSLT parser -->
                        <xsl:copy-of select="document($teiStub)/tei:TEI/tei:teiHeader"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="fileDesc">
                            <xsl:message>Using dummy TEI header</xsl:message>
                            <xsl:element name="titleStmt">
                                <xsl:element name="title">Title</xsl:element>
                            </xsl:element>
                            <xsl:element name="publicationStmt">
                                <xsl:element name="p">Publication Information</xsl:element>
                            </xsl:element>
                            <xsl:element name="sourceDesc">
                                <xsl:element name="p">Information about the source</xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- #### processing instructions #### -->
    
    <xsl:template match="processing-instruction()" priority="2"/>
    
    <!-- #### text element #### -->
    
    <xsl:template match="tei:text">
        <xsl:copy>
            <xsl:attribute name="type" select="$textType"/>
            <xsl:attribute name="xml:lang" select="$textLang"/>
            <xsl:if test="$volumeNumber > 0">
                <xsl:attribute name="n" select="$volumeNumber"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### structural parts of the work #### -->
    
    <xsl:template match="tei:front|tei:body|tei:back">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6|tei:div7">
        <xsl:element name="div">
            <xsl:attribute name="n" select="substring-after(local-name(.), 'div')"/>
            <xsl:copy-of select="@type"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    

    
    <!-- #### title page elements #### -->
    
    <xsl:template match="tei:titlePage|tei:docTitle|tei:byline|tei:docDate|tei:publisher|tei:pubPlace">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:titlePart">
        <xsl:copy>
            <xsl:copy-of select="@type"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:docImprint">
        <xsl:choose>
            <xsl:when test="@n = 'imprimatur'">
                <xsl:element name="imprimatur">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- #### epigraphs #### -->
    
    <xsl:template match="tei:epigraph">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### page and line breaks #### -->
    
    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="matches(@facs, '^W[0-9]{4}-[0-9]{4}$') or matches(@facs, '^W[0-9]{4}-[A-z]-[0-9]{4}$')">
                    <xsl:attribute name="facs" select="concat('facs:', @facs)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">Error: no correct @facs value given in element pb</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@* except @facs"></xsl:copy-of>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <xsl:copy>
            <xsl:if test="@type = 'nb'">
                <xsl:attribute name="break">no</xsl:attribute>
                <xsl:attribute name="resp" select="'#TL'"/>
                <xsl:attribute name="cert" select="'high'"/>
                <!-- TODO: check if text before ends with hyphen... rendition="#hyphen|#noHyphen" -->
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### headings #### -->
    
    <xsl:template match="tei:p[@rend]">
        <xsl:choose>
            <!-- all headings become <head>, independent of their level -->
            <xsl:when test="matches(@rend, '^h.$')">
                <xsl:element name="head">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Error: unknown value of p/@rend</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- #### paragraphs #### -->
    
    <xsl:template match="tei:p[not(@rend)]">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### marginal notes #### -->
    
    <xsl:template match="tei:note[@type='margin']">
        <xsl:copy>
            <xsl:attribute name="place" select="'margin'"/>
            <xsl:copy-of select="@n"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### lists and sub-elements (including list headings) #### -->
    
    <xsl:template match="tei:list">
        <xsl:copy>
            <!--<xsl:copy-of select="@*"/>-->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:item|tei:label">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <xsl:copy>
            <xsl:copy-of select="@target"/><!-- in case there already is @target -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@rend = 'centered'">
                    <xsl:element name="hi">
                        <xsl:attribute name="rendition">#r-center</xsl:attribute>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### verse text/lines #### -->
    
    <xsl:template match="tei:lg">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:l">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### figures, illustrations, ornaments ... #### -->
    
    <xsl:template match="tei:figure">
        <xsl:copy>
            <xsl:if test="@*">
                <xsl:message terminate="yes">Error: element figure has unknown attributes</xsl:message>
            </xsl:if>
            <xsl:if test="child::*">
                <xsl:message terminate="yes">Error: element figure has child element(s)</xsl:message>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tite:ornament">
        <xsl:element name="figure" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type" select="'ornament'"/>
        </xsl:element>
    </xsl:template>
    
    <!-- #### milestones #### -->
    
    <!-- TODO... -->
    
    <!-- #### typographic features #### -->
    
    <xsl:template match="tei:hi[@rend]">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@rend = 'init'">
                    <xsl:attribute name="rendition" select="'#initCaps'"/>
                </xsl:when>
                <xsl:when test="@rend = 'center'">
                    <xsl:attribute name="rendition" select="'#r-center'"/>
                </xsl:when>
                <xsl:when test="@rend = 'recte'">
                    <xsl:attribute name="rendition" select="'#rt'"></xsl:attribute>
                </xsl:when>
                <xsl:when test="@rend = 'right'">
                    <xsl:attribute name="rendition" select="'#right'"/>
                </xsl:when>
                <xsl:when test="@rend = 'sp'">
                    <xsl:attribute name="rendition" select="'#spc'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">Error: unknown attribute value of hi/@rend</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tite:i">
        <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rendition">#it</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tite:b">
        <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rendition">#b</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tite:smcap">
        <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rendition">#sc</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tite:sub">
        <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rendition">#sub</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tite:sup">
        <xsl:element name="hi" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="rendition">#sup</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:seg[@rend='gap']">
        <xsl:element name="space" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="dim" select="'horizontal'"/>
        </xsl:element>
    </xsl:template>
    
    <!-- #### column layout #### -->
    
    <xsl:template match="tite:colShift[@cols]">
        <xsl:choose>
            <xsl:when test="normalize-space(@cols) = '' or xs:integer(@cols) &lt; 1">
                <xsl:message terminate="yes">Error: colShift/@cols has invalid value</xsl:message>
            </xsl:when>
            <xsl:when test="@cols = '1'">
                <xsl:element name="cb">
                    <xsl:attribute name="type" select="'end'"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:cb">
        <xsl:copy>
            <xsl:copy-of select="@n"/>
            <!--<xsl:attribute name="n" select="count(preceding::tei:pb[1]/following::tei:cb intersect preceding::tei:cb) + 1"/>-->
            <xsl:if test="preceding-sibling::node()[position() &lt; 3][self::tite:colShift]">
                <xsl:attribute name="type" select="'start'"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### unclear marks #### -->
    
    <xsl:template match="tei:unclear">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="not(@resp = '#DG')">
                    <xsl:attribute name="resp" select="'#TL'"/>
                    <xsl:copy-of select="@*"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@*"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(@cert)">
                <xsl:attribute name="cert" select="'unknown'"/>
            </xsl:if>
            <xsl:copy-of select="@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- #### text elements #### -->
    
    <xsl:template match="text()" priority="2">
        <xsl:variable name="specialChars" select="('#','[', ']', '{', '}', '%', '$', '@', '&lt;-', '-&gt;', '^', '*')"/>
        <xsl:variable name="quotationMarks" select="('“','”', '„', '»','«', '›', '‹')"/> 
        <xsl:choose>
            <!-- 1.) check if text nodes contain any control signs from previous transcription/annotation processes -->
            <xsl:when test="$analyzeTextEnabled and (some $char in $specialChars satisfies contains(., $char))">
                <xsl:message terminate="yes">Error: special character detected -- reslove this manually</xsl:message>
            </xsl:when>
            <!-- 2.) check for unresolved quotation marks -->
            <xsl:when test="some $char in $quotationMarks satisfies contains(., $char)">
                <xsl:message terminate="yes">Warning: quotation mark detected -- resolve this using element q</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of xml:space="preserve" select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- as a means for detecting tite elements with wrong namespace: -->
    <!--<xsl:template match="tei:i|tei:b|tei:smcap|tei:colShift|tei:ul|
        tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6|tei:div7">
        <xsl:message terminate="yes">Error: found tite element in TEI namespace</xsl:message>
    </xsl:template>-->
    
    <!-- ################################################################ TODO: -->
    
    <!-- Sonderzeichen / g ! -->

    
    

    
    <xsl:template match="tei:note[@type='marginalia']">
        <xsl:copy>
            <xsl:attribute name="place">margin</xsl:attribute>
            <xsl:choose>
                <xsl:when test="./@n and string-length(./@n) > 0">
                    <xsl:attribute name="n" select="./@n"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::node()[position() &lt; 3][self::tite:sup and string-length(.) &lt; 3]">
                    <xsl:attribute name="n" select="preceding-sibling::tite:sup[1]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="anchored">false</xsl:attribute>
                    <xsl:message>Warning: marginal note seems not to be anchored in the text</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    

    
    

    
    
    <!-- TODO: 
        - ref and hi in note, if note is referenced by sup char?
        - test if column transformation works: cb/@type="start|end"
        - lb/@rendition="#hyphen"|#noHyphen
        - check that all children nodes are being transformed -->
     


</xsl:stylesheet>