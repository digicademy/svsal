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
    <xsl:param name="editingDate" as="xs:string" select="'2018-12-17'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_024'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Got @break and @rendition into the right order (pb/lb).'"/>
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


    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
            <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#hyphen']">
                <xsl:attribute name="break" select="'no'"/>
                <xsl:attribute name="rendition" select="'#hyphen'"/>
            </xsl:when>
                <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#noHyphen']">
                <xsl:attribute name="break" select="'no'"/>
                <xsl:attribute name="rendition" select="'#noHyphen'"/>
            </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:lb[@break eq 'no' and @rendition = ('#noHyphen', '#hyphen')]">
        <xsl:copy>
            <xsl:copy-of select="@* except (@rendition, @break)"/>
            <xsl:choose>
                <xsl:when test="preceding-sibling::*[1]/self::tei:pb">
                    <xsl:copy-of select="@break"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="(@rendition, @break)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>