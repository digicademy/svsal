<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- LATIN VERSION of single-character abbreviation expansion -->
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-11-08'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0014_change_020'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Partially expanded single-character abbreviations.'"/>
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
    
    <!-- define LATIN single-character abbreviations and their expansion -->
    <xsl:variable name="expansions">
        <local:expansions>
            <local:exp id="chara75f">vel</local:exp> <!-- LATIN SMALL LETTER V WITH DIAGONAL STROKE -->
            <local:exp id="chara759">quod</local:exp> <!-- LATIN SMALL LETTER Q WITH DIAGONAL STROKE -->
            <local:exp id="chara751">per</local:exp> <!-- LATIN SMALL LETTER P WITH STROKE THROUGH DESCENDER -->
        </local:expansions>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:message select="concat('Annotated ', string($logG), ' g tags as abbreviations (incl. expansions).')"/>
    </xsl:template>

    <!-- limit automatic tagging to sections in Latin only, and cut out those g that are already tagged as abbreviations -->
    <xsl:template match="tei:text[@xml:lang eq 'la']//tei:g[not(ancestor::*[@xml:lang and @xml:lang ne 'la']) 
                                                            and not(ancestor::tei:choice)
                                                            and not(ancestor::tei:note)]"> <!-- TODO: really limit abbreviation expansion to notes only? -->
        <xsl:choose>
            <xsl:when test="substring-after(@ref, '#') = $expansions//@id and local:isFreestandingG(.)">
                <xsl:variable name="expansion" as="xs:string" select="$expansions//local:exp[@id eq substring-after(current()/@ref, '#')]/text()"/>
                <xsl:element name="choice">
                    <xsl:element name="abbr">
                        <xsl:copy-of select="."/>
                    </xsl:element>
                    <xsl:element name="expan">
                        <xsl:attribute name="resp" select="'#auto'"/>
                        <xsl:attribute name="cert" select="'high'"/>
                        <xsl:value-of select="$expansion"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:variable name="logG" as="xs:integer" select="count(//tei:text[@xml:lang eq 'la']//tei:g[(not(ancestor::*[@xml:lang and @xml:lang ne 'la']) and not(ancestor::tei:choice) and not(ancestor::tei:note))
                                                                                 and
                                                                                 substring-after(@ref, '#') = $expansions//@id and local:isFreestandingG(.)]
                                                                                 )"/>
    
    <xsl:function name="local:isFreestandingG" as="xs:boolean">
        <xsl:param name="gNode" as="element(tei:g)"/>
        
        <xsl:variable name="breakElems" select="('pb', 'cb', 'lb')"/>
        
        <xsl:choose>
            <xsl:when test="local:hasWhitespaceLeft($gNode) and local:hasWhitespaceRight($gNode)">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="local:hasWhitespaceLeft($gNode) and $gNode/following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::*[local-name(.) = $breakElems]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="local:hasWhitespaceRight($gNode) and $gNode/preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::*[local-name(.) = $breakElems]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:hasWhitespaceLeft" as="xs:boolean">
        <xsl:param name="gNode" as="element(tei:g)"/>
        <xsl:choose>
            <xsl:when test="$gNode/preceding-sibling::node()[1]/self::text() and matches($gNode/preceding-sibling::node()[1], '\s$')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:hasWhitespaceRight" as="xs:boolean">
        <xsl:param name="gNode" as="element(tei:g)"/>
        <xsl:choose>
            <xsl:when test="$gNode/following-sibling::node()[1]/self::text() and matches($gNode/following-sibling::node()[1], '^\s')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    

</xsl:stylesheet>