<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0"
    >
   
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:message>Info: created pb/@xml:id.</xsl:message>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//tei:div1[@type='index']//tei:list//tei:ref">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
                <xsl:variable name="refNumber" as="text()" select="./text()"/>
                <xsl:variable name="pbN" select="following::tei:pb/@n"/>
                
                <xsl:variable name="pb" select="following::tei:pb[@n eq $refNumber]/@xml:id"/>
                <xsl:choose>
                    <xsl:when test="not($pbN)">
                        <xsl:attribute name="target" select="'#'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="target" select="concat('#', $pb)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
