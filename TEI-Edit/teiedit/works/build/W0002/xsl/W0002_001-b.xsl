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
    
    <xsl:param name="workId" as="xs:string"/>
    <xsl:param name="textId" as="xs:string"/>
    <xsl:param name="textType" as="xs:string"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:param name="textLang" as="xs:string"/> <!-- "es" or "la" -->
    <xsl:param name="volumeNumber" as="xs:integer"/> <!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->

<!--    <xsl:param name="teiStub" as="xs:string"/>-->
    
    <xsl:param name="generalTeiSchema" as="xs:boolean"/>
    <xsl:param name="fragmentationDepth" as="xs:integer"/>
    
    <xsl:param name="analyzeTextEnabled" as="xs:boolean"/>
    
    <!-- If a node not captured further below is observed, throw error & terminate - this ensures that every transformation is explicitely contained in this stylesheet -->
    <xsl:template match="@*|node()"> 
        <xsl:message terminate="yes">Error: unknown xml entity</xsl:message>
        <!--<xsl:copy>
            <!-\- TODO: marker for unprocessed elements -\->
            
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>-->
    </xsl:template>
    
    
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
            <xsl:attribute name="xml:id" select="$workId"/>
            <xsl:element name="teiHeader">
                <xsl:element name="fileDesc">
                    <xsl:message>Using TEI header template.</xsl:message>
                    <xsl:element name="titleStmt">
                        <xsl:element name="title">Title</xsl:element>
                    </xsl:element>
                    <xsl:element name="publicationStmt">
                        <xsl:element name="p">Publication Information</xsl:element>
                    </xsl:element>
                    <xsl:element name="sourceDesc">
                        <xsl:element name="p">Information about the source.</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" priority="2"/>
    
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="tei:text">
        <xsl:element name="text">
            <xsl:attribute name="type" select="$textType"/>
            <xsl:attribute name="xml:lang" select="$textLang"/>
            <xsl:if test="$volumeNumber > 0">
                <xsl:attribute name="n" select="$volumeNumber"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:front|tei:body|tei:back">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6|tei:div7">
        <xsl:element name="div">
            <xsl:copy-of select="@* except @n"/>
            <xsl:attribute name="n" select="substring-after(local-name(.), 'div')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:titlePage|tei:docTitle|tei:byline|tei:docDate">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:titlePart">
        <xsl:copy>
            <xsl:copy-of select="@type"/>
            <xsl:copy-of select="@resp|@cert|@change"/>
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
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:list">
        <xsl:copy>
            <xsl:copy-of select="@type"/>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:item|tei:label|tei:ref">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:choose>
                <xsl:when test="@rend = 'centered'">
                    <xsl:element name="hi">
                        <xsl:attribute name="rendition">#r-center</xsl:attribute>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="@rend = 'right'">
                    <xsl:element name="hi">
                        <xsl:attribute name="rendition">#right</xsl:attribute>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
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
    
    <xsl:template match="tei:lg">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:l">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:figure">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:message terminate="no">Warning: figure tag found, please resolve this manually</xsl:message>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:pb">
        <!-- Transform image URLs into Salamanca URIs -->
        <xsl:copy>
            <xsl:if test="not(@n) or string-length(@n) = 0">
                <xsl:message terminate="yes">Error: element pb has no @n, or @n has no valid value</xsl:message>
            </xsl:if>
            <xsl:copy-of select="@n"/>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:choose>
                <xsl:when test="@facs">
                    <xsl:variable name="pageURI">
                        <xsl:choose>
                            <xsl:when test="matches(./@facs, '^https?://.*?/W[0-9]{4}-[0-9]{4}\.(jpg|tif)$')">
                                <xsl:value-of select="replace(./@facs, '^.*?(W[0-9]{4}-[0-9]{4})\.(jpg|tif)$', '$1')"/>
                            </xsl:when>
                            <xsl:when test="matches(./@facs, '^https?://.*?/W[0-9]{4}-[A-z]-[0-9]{4}\.(jpg|tif)$')">
                                <xsl:value-of select="replace(./@facs, '^.*?(W[0-9]{4}-[A-z]-[0-9]{4})\.(jpg|tif)$', '$1')"/>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$pageURI">
                            <xsl:attribute name="facs">
                                <xsl:value-of select="concat('facs:', $pageURI)"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes">Error: @facs contains no or an unsupported value</xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">Error: element pb has no @facs</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tite:i">
        <xsl:element name="hi">
            <xsl:attribute name="rendition">#it</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tite:b">
        <xsl:element name="hi">
            <xsl:attribute name="rendition">#b</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tite:smcap">
        <xsl:element name="hi">
            <xsl:attribute name="rendition">#sc</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
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
            <xsl:copy-of select="@resp|@cert|@change"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tite:sup"/>
        <!--<xsl:choose>
            <xsl:when test="following-sibling::node()[position() &lt; 3][self::tei:note[@type='marginalia' and @n=current()/text()]]">
                <xsl:element name="hi">
                    <xsl:attribute name="rendition" select="'#sup'"/>
                    <xsl:element name="ref">
                    <xsl:message terminate="yes" select="'TODO: make ref with @target linking to note element'"/>
                    <xsl:attribute name="target" select="'...'"/>
                </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="hi">
                    <xsl:attribute name="rendition">#sup</xsl:attribute>
                    <xsl:copy-of select="@resp|@cert|@change"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>    
        </xsl:choose>
    </xsl:template>-->
    
    <xsl:template match="tei:note[@type='marginalia']">
        <xsl:copy>
            <xsl:attribute name="place">margin</xsl:attribute>
            <xsl:choose>
                <xsl:when test="@n and string-length(@n) > 0">
                    <xsl:attribute name="n" select="@n"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::node()[position() &lt; 3][self::tite:sup and string-length(.) &lt; 3]">
                    <xsl:attribute name="n" select="preceding-sibling::tite:sup[1]/text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="anchored">false</xsl:attribute>
                    <xsl:message>Warning: marginal note seems not to be anchored in the text</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test=".[@rend='init']">
                <xsl:copy>
                    <xsl:attribute name="rendition">#initCaps</xsl:attribute>
                    <xsl:copy-of select="@resp|@cert|@change"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test=".[@rend='right']">
                <xsl:copy>
                    <xsl:attribute name="rendition">#right</xsl:attribute> 
                    <xsl:copy-of select="@resp|@cert|@change"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test=".[@rend='centered']">
                <xsl:copy>
                    <xsl:attribute name="rendition">#r-center</xsl:attribute>
                    <xsl:copy-of select="@resp|@cert|@change"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- copy unclear tags with no attributes -->
    <xsl:template match="tei:unclear">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--<xsl:if test="not(@cert)">
                <xsl:attribute name="cert" select="'unknown'"/>
            </xsl:if>-->
            <!--<xsl:if test="not(@resp and @reason)">
                <xsl:message terminate="yes" select="'Error: element unclear has no @resp and/or @reason'"></xsl:message>
            </xsl:if>-->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- check for erroneous markup: -->
    <!--<xsl:template match="tei:note//tei:lb[not(following-sibling::node())]">
        <xsl:message terminate="yes" select="'Error: false lb at the end of note tag'"/>
    </xsl:template>
    <xsl:template match="tei:lb[following-sibling::node()[1] = tei:lb]">
        <xsl:message terminate="yes" select="'Error: false lb at the end of note tag'"/>
    </xsl:template>
    <xsl:template match="tei:pb[following-sibling::node()[1] = tei:pb]">
        <xsl:message terminate="yes" select="'Error: false lb at the end of note tag'"/>
    </xsl:template>
    <xsl:template match="tei:pb[not(following-sibling::node())]|tei:lb[not(following-sibling::node())]|tei:cb[not(following-sibling::node())]">
        <xsl:message terminate="yes" select="'Error: pb/lb/cb occurs as last sibling'"/>
    </xsl:template>-->
    
    <!-- delete redundant heading layout information -->
    <!--<xsl:template match="tei:head/tei:hi[@rendition='#r-center']">
        <xsl:apply-templates/>
    </xsl:template>-->
    
    <!-- check text nodes for unwanted content -->
    <xsl:template match="text()">
        <xsl:variable name="specialChars" select="('#','[', ']', '{', '}', '%', '$', '@', '&lt;', '&gt;', '^', '*', '〈', '〉', '〈', '〉')"/>
        <xsl:variable name="quotationMarks" select="('“','”', '„', '»','«', '›', '‹')"/> 
        <xsl:choose>
            <!-- 1.) check if text nodes contain any control signs from previous transcription/annotation processes -->
            <xsl:when test="$analyzeTextEnabled and (some $char in $specialChars satisfies contains(., $char))">
                <xsl:message terminate="yes">Error: special character detected -- resolve this manually</xsl:message>
            </xsl:when>
            <!-- 2.) check for unresolved quotation marks -->
            <xsl:when test="some $char in $quotationMarks satisfies contains(., $char)">
                <xsl:message terminate="yes">Warning: quotation mark detected -- resolve this using element q</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

</xsl:stylesheet>