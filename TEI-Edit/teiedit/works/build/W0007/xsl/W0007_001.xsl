<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-20'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0007_change_0010'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Revised pagination, added list/@type and note/@xml:lang.'"/>
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

    <!-- lists within the index list become @type='index' -->
    <xsl:template match="tei:back/tei:div[@type eq 'index']/tei:list/tei:item/tei:list">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'index'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add "fol." to pagination and put verso p. numbers in square brackets -->
    <xsl:template match="tei:pb/@n">
        <xsl:choose>
            <xsl:when test="ends-with(., 'v') and not(contains(., '[') or contains(., ']'))">
                <xsl:attribute name="n" select="concat('fol. [', substring-before(., 'v'), ']v')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="n" select="concat('fol. ', .)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- tag marginal notes generally as Latin -->
    <xsl:template match="tei:note[@type eq 'marginalia']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@xml:lang)">
                <xsl:attribute name="xml:lang" select="'la'"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>