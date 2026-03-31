<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- transformation is finalized and probably optimized, ready to be integrated into the pipeline and to be applied -->
    
    <xsl:output method="xml"/> 
    
    <!-- state the limit of italicized text for processing here: if element contains more than the hereby stated percentage of 
        italicized text, invert-hi applies -->
    <xsl:param name="allowedItalicsRatio" as="xs:decimal" select="80.0"/>
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-12-12'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_022'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Reduced redundant hi[@rendition eq #it] taggings.'"/>
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
    
    <!-- general identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- identity transform in hi-inverting mode -->
    <xsl:template match="@*|node()" mode="invert-hi">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="invert-hi"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:p[count(descendant::tei:hi[@rendition eq '#it']) gt 1]|tei:item[count(descendant::tei:hi[@rendition eq '#it']) gt 1]"> <!-- TODO: other elements? -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="italicsRatio" as="xs:decimal" 
                 select="string-length(string-join(current()//text()[ancestor::tei:hi[@rendition eq '#it']], '')) div string-length(string-join(current()//text(), ''))"/>
            <xsl:choose>
                <!-- if ratio of italicized text is greater than 90%, try to reduce taggings -->
                <xsl:when test="$italicsRatio gt ($allowedItalicsRatio div 100)">
                    <xsl:variable name="recteElems" select="current()//*[not(ancestor-or-self::tei:hi[@rendition eq '#it'])]/name()"/>
                    <xsl:variable name="recteText" select="current()//text()[not(ancestor::tei:hi[@rendition eq '#it'])]"/>
                    <xsl:message select="'Found structural unit with more than ', string($allowedItalicsRatio), 
                                         '% hi[@rendition=#it] tagging: ', string($italicsRatio), '%'"/>
                    <xsl:message select="'Elements not marked as rendition=#it are: ', string-join($recteElems, ' | ')"/>
                    <xsl:message select="'Text nodes not marked as rendition=#it are: ', string-join($recteText, ' | ')"/>
                    <xsl:choose>
                        <xsl:when test="current()//text()[not(ancestor::tei:hi[@rendition eq '#it'])]
                                                         [not(normalize-space(.) eq ''
                                                              or ancestor::tei:hi[@rendition eq '#initCaps' or @rendition eq '#rt']
                                                              or local:isInvertible(.)
                                                         )]">
                            <xsl:message terminate="no" select="'Not all text nodes satisfy the given criteria for inversion, hi tagging will not be changed.'"/>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="hi">
                                <xsl:attribute name="rendition" select="'#it'"/>
                                <xsl:apply-templates mode="invert-hi"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:message select="'-----------------------------------------------------------------------------'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- specific rules for inverting rendition tagging: -->
    
    <!-- 1.) delete hi[@rendition eq '#it'] -->
    <xsl:template match="tei:hi[@rendition eq '#it']" mode="invert-hi">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- 2.) make invertible text nodes recte -->
    <!-- a) normal text nodes, not within g -->
    <xsl:template match="text()[local:isInvertible(.) and not(ancestor::tei:g) and not(ancestor::tei:hi[contains(@rendition, '#rt')])]" mode="invert-hi">
        <xsl:element name="hi">
            <xsl:attribute name="rendition" select="'#rt'"/>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <!-- b) g tags need special treatment, so as to not set hi tags within g -->
    <xsl:template match="tei:g[./text()[local:isInvertible(.)]]" mode="invert-hi">
        <xsl:element name="hi">
            <xsl:attribute name="rendition" select="'#rt'"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    
    <!-- 3.) text nodes marked as #initCaps (and NOT #it) also receive an additional tag #rt -->
    <xsl:template match="tei:hi[@rendition eq '#initCaps' and not(ancestor::tei:hi[@rendition eq '#it'])]" mode="invert-hi">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="rendition" select="'#initCaps #rt'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="local:isInvertible" as="xs:boolean">
        <xsl:param name="textNode" as="text()"/>
        <xsl:if test="$textNode/ancestor::*[self::tei:hi[contains(@rendition, '#it') or self::tei:g]]">
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:variable name="invertible" as="xs:boolean" 
                    select="string-length($textNode) le 25 and not(normalize-space($textNode) eq '')"/> 
        <!-- NOTE: we merely test for string length here, not taking into account special rules (as those below) -->
        <!-- invertible are:
             - certain characters, see $recteCharsRegex
             - numbers: '20.', '1554.', '3', '4.'
        -->
        <!-- 
        <xsl:variable name="recteCharsRegex" select="'^\s*[OçaDtSsj:\(\)]\s*$'"/>
        <xsl:variable name="recteNumbersRegex" select="'^\s*\d{1,4}\.?\s*$'"/>
        matches($textNode, $recteCharsRegex)
                            or matches($textNode, $recteNumbersRegex)
                            or 
        -->
        <xsl:value-of select="$invertible"/>
    </xsl:function>
    

</xsl:stylesheet>