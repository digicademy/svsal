<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!-- utility program for cleansing document of excessive whitespace (e.g., like those produced by the svsal oXygen plugin) -->
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2020-07-23'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0033_change_016'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Reduced excessive whitespace.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="round1">
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
            <xsl:apply-templates mode="round1"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- we process a doc two times in different modes for applying different text-processing rulesets that would collide if applied together -->
    
    <xsl:template match="@*|node()" mode="round1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round1"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="round1">
        <xsl:apply-templates mode="round1"/>
    </xsl:variable>
    
    <xsl:template match="@*|node()" mode="round2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="round2">
        <xsl:apply-templates mode="round2" select="$round1"/>
    </xsl:variable>
    
    
    <!-- warning: the following ruleset needs to be strictly idempotent for being applied multiple times -->
    <xsl:template match="tei:text//text()" mode="round1">
        <xsl:choose>
            <!-- text nodes that contain excessive whitespace in-between character sequences: condense whitespace to single blank -->
            <xsl:when test="not(normalize-space(.) eq '')">
                <xsl:value-of select="replace(., '\s+', ' ')"/>
            </xsl:when>
            <!-- whitespace between choice/child::*: omit altogether -->
            <xsl:when test="normalize-space(.) eq '' and parent::tei:choice"/>
            <!-- whitespace between break elements: remove it -->
            <xsl:when test="normalize-space(.) eq '' and following-sibling::node()[1][self::tei:pb or self::tei:cb or self::tei:lb]
                                                     and preceding-sibling::node()[1][self::tei:pb or self::tei:cb or self::tei:lb]"/>
            <!-- whitespace-only text nodes between larger structural elements: replace by "\n" -->
            <xsl:when test="normalize-space(.) eq '' and (following-sibling::*[1][self::tei:p or self::tei:div or self::tei:list or self::tei:head or self::tei:item or self::tei:l or self::tei:figure]
                                                          or preceding-sibling::*[1][self::tei:p or self::tei:div or self::tei:list or self::tei:head or self::tei:item or self::tei:l or self::tei:figure])">
                <xsl:value-of select="'&#xA;'"/>
            </xsl:when>
            <!-- replace whitespace at the beginning/end of structural units by single \n -->
            <xsl:when test="normalize-space(.) eq '' and (not(following-sibling::node()) or not(preceding-sibling::node()))">
                <xsl:value-of select="'&#xA;'"/>
            </xsl:when>
            <!-- whitespace between two mixed-content children: replace by single blank -->
            <xsl:when test="normalize-space(.) eq '' and (following-sibling::node()[1][self::tei:g or self::tei:hi or self::tei:choice] or preceding-sibling::node()[1][self::tei:g or self::tei:hi or self::tei:choice])">
                <xsl:value-of select="' '"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:text//text()" mode="round2">
        <xsl:choose>
            <!-- whitespace at the end of line, followed by break element: replace by \n -->
            <xsl:when test="not(normalize-space(.) eq '') and matches(., '\s+$') and following-sibling::*[1][self::tei:pb or self::tei:cb or self::tei:lb]">
                <xsl:value-of select="replace(., '\s+$', '&#xA;')"/>
            </xsl:when>
            <!-- whitespace-only text nodes followed by line/column/page break: replace by '\n' -->
            <xsl:when test="normalize-space(.) eq '' and following-sibling::*[1][self::tei:pb or self::tei:cb or self::tei:lb]">
                <xsl:value-of select="'&#xA;'"/>
            </xsl:when>
            <!-- redundant whitespace before/after paragraph within note: delete it -->
            <xsl:when test="normalize-space(.) eq '' and ((parent::tei:note and not(preceding-sibling::node()) and following-sibling::node()[1]/self::tei:p)
                                                          or (parent::tei:note and not(following-sibling::node()) and preceding-sibling::node()[1]/self::tei:p))"/>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$round2"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
        <xsl:variable name="inWhitespace" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="inChars" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="inSpecialChars" as="xs:integer" select="count(//tei:g)"/>
        <xsl:variable name="outSpecialChars" as="xs:integer" select="count($out//tei:g)"/>
        <xsl:variable name="inPb" as="xs:integer" select="count(//tei:pb)"/>
        <xsl:variable name="outPb" as="xs:integer" select="count($out//tei:pb)"/>
        <xsl:variable name="inCb" as="xs:integer" select="count(//tei:cb)"/>
        <xsl:variable name="outCb" as="xs:integer" select="count($out//tei:cb)"/>
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb)"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb)"/>
        <!-- whitespace -->
        <xsl:if test="$inWhitespace ne $outWhitespace">
            <xsl:message select="'WARN: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- chars -->
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'ERROR: amount of non-whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- breaks -->
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
            <xsl:message select="'ERROR: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- special chars -->
        <xsl:if test="$inSpecialChars ne $outSpecialChars">
            <xsl:message select="'ERROR: different amount of input and output special chars: '"/>
            <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    

</xsl:stylesheet>