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
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-10'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0014_change_0012'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Enriched titlePage elements.'"/>
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

    <!-- there are three figure tags that actually stand for ornamental markers -->
    <xsl:template match="tei:figure">
        <xsl:copy>
            <xsl:attribute name="place" select="'inline'"/>
            <xsl:attribute name="type" select="'ornament'"/>
        </xsl:copy>
    </xsl:template>

    <!-- enrich titlePage elements further -->
    <xsl:template match="tei:titlePage//tei:docAuthor">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="ref" select="'author:A0100 cerl:cnp01234843 gnd:118768735'"/>
            <xsl:attribute name="key" select="'Vitoria, Francisco de'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:titlePage//tei:publisher">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="ref" select="'cerl:cni00031746'"/>
            <xsl:attribute name="key" select="'Martinez, Sebastián'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:titlePage//tei:pubPlace">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="ref" select="'getty:7008771'"/>
            <xsl:attribute name="key" select="'Valladolid'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:pb/@n">
        <xsl:attribute name="n" select="concat('fol. ', .)"/>
    </xsl:template>
    
    <xsl:template match="tei:body/tei:div[@type eq 'part']">
        <xsl:apply-templates/>
    </xsl:template>
    
    

</xsl:stylesheet>