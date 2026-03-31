<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- This program processes choice elements where break elements (pb,cb,lb) appear only in the first (sic, abbr, orig), but not in the second (reg, abbr, expan))
        child element. It adds the respective break elements to the second child, interlinking them to those of the first child via @sameAs. However, this 
        only applies to choice elements where the second element consists of nothing but tags (e.g., no special character or hi tagging). -->
    
    <!-- IMPORTANT: run this program BEFORE special characters are tagged in 2nd choice childs, so that 
        2nd choice childs only contain text nodes (but not also g tags) -->
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-12-17'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_026'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Renamed milestones/@unit (article -> number).'"/>
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
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    
    <xsl:template match="tei:milestone/@unit[./string() eq 'article']">
        <xsl:attribute name="unit" select="'number'"/>
    </xsl:template>

</xsl:stylesheet>