<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE v9.6.0.7+ -->
        
    <xsl:output method="xml"/> 
    
    <!-- Identity transformation for everything that is not encountered further below -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- reference SalTEI schema for validation in the processing instructions -->
    <xsl:template match="processing-instruction('xml-model')"/>
        
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model" >
            href="https://files.salamanca.school/SvSal_txt.rng"
            type="application/xml"
            schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <xsl:text>&#xa;</xsl:text>
        <xsl:apply-templates/>
        <xsl:variable name="removedNl" select="count(//tei:text//text()[matches(., '^\n[\.,:\?]') and preceding-sibling::node()[1]/self::tei:note])"/>
        <xsl:message select="concat('Removed ', string($removedNl), ' newline characters from the beginnings of note-following text nodes.')"/>
    </xsl:template>
    
    <xsl:variable name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:variable name="editingDate" as="xs:string" select="'2018-08-02'"/>
    <xsl:variable name="editingDesc" as="xs:string" select="'Further structural adaptations and validation according to SalTEI.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&#xa;                </xsl:text>
            <xsl:element name="change">
                <xsl:attribute name="who" select="$editors"/>
                <xsl:attribute name="when" select="$editingDate"/>
                <xsl:attribute name="status" select="ancestor::tei:revisionDesc[1]/@status"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:attribute name="xml:id" select="'W0002_change_0013'"/>
                <xsl:value-of select="$editingDesc"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- get xmlns:xi attribute from fileDesc to TEI element -->
    <xsl:template match="tei:TEI">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:namespace name="xi" select="'http://www.w3.org/2001/XInclude'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- further div processing: @type -->
    <xsl:template match="tei:text//tei:div">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- typify sub-level divs as generic "section", if they don't already have a type -->
            <xsl:if test="not(@type) and (count(ancestor::tei:div) eq 1 or count(ancestor::tei:div) eq 2)">
                <xsl:attribute name="type" select="'section'"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- make milestone/unit="editorial" to unit="unknown" -->
    <xsl:template match="tei:milestone[@unit='editorial']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="unit" select="'other'"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- back-convert <g> tags containing the 'tur' expansion into t with tilde -->
    <xsl:template match="tei:g[@ref = '#chart0303' and . = 'tur']">
        <xsl:copy>
            <xsl:copy-of select="@ref"/>
            <xsl:text>t̃</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <!-- there is one space element that we need to enrich a bit -->
    <xsl:template match="tei:space[@dim = 'horizontal']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="rendition" select="'#gap'"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:unclear[@resp = '#TT']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="cert" select="'unknown'"/>
            <xsl:attribute name="reason" select="'unknown'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- there are two figure tags that can be thrown away -->
    <xsl:template match="tei:text//tei:figure"/>
        
    <xsl:template match="tei:text//tei:ref[@resp eq '#AUTO' and not(@target eq 'unclear')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- omit ref/@target in summaries if value is 'unclear' -->
    <xsl:template match="tei:list[@type eq 'summaries']//tei:ref[@target eq 'unclear']">
        <xsl:copy>
            <xsl:copy-of select="@* except @target"/>
            <xsl:choose>
                <xsl:when test="@resp eq '#CR'">
                    <xsl:attribute name="cert" select="'unknown'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="resp" select="'#DG #auto'"/>
                    <xsl:attribute name="cert" select="'unknown'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- wrap note content in p element -->
    <xsl:template match="tei:note">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="p">
                <xsl:attribute name="xml:id" select="generate-id()"/>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- remove leading newline in text node following tei:note, of the text node starts with a punctuation sign -->
    <xsl:template match="tei:text//text()[matches(., '^\n[\.,:\?]') and preceding-sibling::node()[1]/self::tei:note]">
        <xsl:value-of select="substring(., 2)"/>
    </xsl:template>
    
    
</xsl:stylesheet>