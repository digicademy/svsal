<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <!-- step 2 of the xslt-based transformation for W0002 -->
    
    <xsl:output method="xml"/> 
    
    <!-- Identity transformation for everything that is not encountered further below -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- add "virtual" lb at the beginning of marginal notes, refering with @sameAs to the "actual", previous lb -->
    <xsl:template match="tei:note[@place='margin']">
        <!-- if note is anchored, reintroduce superscript anchor symbol before each note (was falsely deleted 
                in previous transformation process) -->
        <xsl:if test="not(@anchored = 'false')">
            <xsl:element name="ref">
                <xsl:attribute name="type" select="'note-anchor'"/>
                <xsl:choose>
                    <xsl:when test="current()/@n and current()/@xml:id">
                        <xsl:attribute name="n" select="current()/@n"/>
                        <xsl:attribute name="target" select="concat('#', current()/@xml:id)"/>
                        <xsl:element name="hi">
                            <xsl:attribute name="rendition" select="'#sup'"/>
                            <xsl:value-of select="current()/@n"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="'Error: element note lacks @xml:id and/or @n'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@anchored = 'false')">
                <xsl:attribute name="anchored" select="'true'"/>
            </xsl:if>
            <!-- add "virtual" lb with @sameAs for correction purposes -->
            <xsl:if test="not(child::node()[1] = tei:lb)">
                <xsl:element name="lb">
                    <xsl:variable name="prevId" as="xs:string" select="preceding::tei:lb[ancestor::tei:note[@place='margin']][1]/@xml:id"/>
                    <xsl:choose>
                        <xsl:when test="$prevId">
                            <xsl:attribute name="sameAs" select="concat('#', $prevId)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="'Error: no preceding lb/@xml:id found'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:if>
            <!-- add @anchored for stating whether note is anchored in the text -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- if text of marginal note starts with a note marker that is already captured in @n, delete this marker from the text -->
    <xsl:template match="tei:note[@place='margin']//text()[not(normalize-space(.) = '')][1]">
        <xsl:variable name="parentNodeN" as="xs:string" select="ancestor::tei:note[@place='margin'][1]/@n"/>
        <xsl:choose>
             <xsl:when test="(string-length(.) > 2) and starts-with(., concat($parentNodeN, ' '))">
                 <xsl:value-of select="substring(., 3)"/>
             </xsl:when>
            <xsl:when test="(string-length(.) = 2) and (. = concat($parentNodeN, ' '))"/>
            <xsl:otherwise>
<!--                <xsl:message terminate="no" select="'Error: note/text() does not start with proper note marker'"/>-->
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- delete hi[@rendition='#r-center'], since this information is implicit in head -->
    <xsl:template match="tei:head/tei:hi[@rendition='#r-center']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- delete div/@n (hitherto numeric values, but irrelevant) -->
    <xsl:template match="tei:div/@n"/>
    
    <!-- change @unit in milestone[@rendition="#asterisk"] from "article" to "editorial" -->
    <xsl:template match="tei:milestone[@rendition = '#asterisk']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="unit" select="'editorial'"/>
        </xsl:copy>
    </xsl:template>

    
</xsl:stylesheet>