<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
   
    <xsl:output method="xml" indent="no"/>
    
    <xsl:key name="milestoneKeys" match="tei:milestone" use="@xml:id"/>
    
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:front|tei:div|tei:titlePage|tei:head|tei:p">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:message>Adding @xml:ids</xsl:message>
               <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>    
    </xsl:template>
</xsl:stylesheet>