<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="no"/> 
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:param name="pb" as="element(tei:pb)"/>
    
    <xsl:template match="tei:pb[not(self::tei:pb[@sameAs])]">
        <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:pb[not(self::tei:pb[@sameAs])])+1"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @n"/>
            <xsl:message>Adding @n to pb</xsl:message>
            <xsl:choose>
                <xsl:when test="contains(@n,'[')">
                    <xsl:copy-of select="@n"/>
                </xsl:when>
                <xsl:otherwise>
                     <xsl:attribute name="n" select="$n"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>    
    </xsl:template>
    

</xsl:stylesheet>