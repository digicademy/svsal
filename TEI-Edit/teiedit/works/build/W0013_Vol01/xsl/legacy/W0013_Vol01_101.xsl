<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!--<xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-09-21'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0013_Vol01_change_0010'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Restructured structural elements with @rendition, separating @rendition to hi elements.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&#xa;                </xsl:text>
            <xsl:element name="change">
                <xsl:attribute name="who" select="$editors"/>
                <xsl:attribute name="when" select="$editingDate"/>
                <xsl:attribute name="status" select="ancestor::tei:revisionDesc[1]/@status"/>
                <xsl:attribute name="xml:id" select="$changeId"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:value-of select="$editingDesc"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>-->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    
    <xsl:template match="tei:head[@rendition]|tei:item[@rendition]|tei:p[@rendition]">
        <xsl:copy>
            <xsl:copy-of select="@* except @rendition"/>
            <xsl:choose>
                <!-- if the first child is a pb, pb and lb need to be separated from hi -->
                <xsl:when test="child::node()[not(self::text() and normalize-space(.) eq '')][1]/self::tei:pb">
                    <xsl:copy-of select="child::node()[not(self::text() and normalize-space(.) eq '')][1]"/>
                    <xsl:if test="not(child::node()[not(self::text() and normalize-space(.) eq '')][2]/self::tei:lb)">
                        <xsl:message terminate="yes"/>
                    </xsl:if>
                    <xsl:copy-of select="child::node()[not(self::text() and normalize-space(.) eq '')][2]"/>
                    <xsl:element name="hi">
                        <xsl:attribute name="rendition" select="@rendition"/>
                        <xsl:apply-templates select="child::node()[not(self::text() and normalize-space(.) eq '')][2]/following-sibling::node()"/>
                    </xsl:element>
                </xsl:when>
                <!-- if the first child is a lb, separate it from hi -->
                <xsl:when test="child::node()[not(self::text() and normalize-space(.) eq '')][1]/self::tei:lb">
                    <xsl:copy-of select="child::node()[not(self::text() and normalize-space(.) eq '')][1]"/>
                    <xsl:element name="hi">
                        <xsl:attribute name="rendition" select="@rendition"/>
                        <xsl:apply-templates select="child::node()[not(self::text() and normalize-space(.) eq '')][1]/following-sibling::node()"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>