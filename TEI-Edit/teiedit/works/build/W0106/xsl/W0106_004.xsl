<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-11-22'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0106_change_010'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged crossed references summaries and label(s).'"/>
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
    
    <!-- First round:
         Finding target(s) and marked unknown label(s).-->
    <xsl:variable name="refTypeNum">
        <xsl:apply-templates select="/" mode="refTypeNum"/>
    </xsl:variable>
    
    
    <xsl:template match="@*|node()" mode="refTypeNum">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="refTypeNum"/>
        </xsl:copy>
    </xsl:template>
    
     
    <xsl:template match="tei:list[@type='summaries']//tei:ref[@type eq 'num']" mode="refTypeNum">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="refNumber" as="xs:string" select="./text()"/>
            <xsl:variable name="labelId" select="following::tei:label[@type eq 'margin' and ancestor::tei:div2 = current()/ancestor::tei:div2 and @n eq $refNumber][1]/@xml:id"/>
            <xsl:choose>
                <xsl:when test="not($labelId)">
                    <xsl:attribute name="target" select="concat('#', 'unknown')"/> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="target" select="concat('#', $labelId)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="refTypeNum"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Second round:
         Deleting unnecessary ref(s). -->
    
    <xsl:variable name="noTypeNum">
        <xsl:apply-templates select="$refTypeNum" mode="noTypeNum"/>
    </xsl:variable>
    
    <xsl:template match="@*|node()" mode="noTypeNum">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="noTypeNum"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:ref[not(@type or @target)]" mode="noTypeNum">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="descendant::tei:ref[1][@target]">
                <xsl:attribute name="target" select="descendant::tei:ref[1]/@target"/>
            </xsl:if>
            <xsl:apply-templates mode="noTypeNum"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:ref[@type eq 'num']" mode="noTypeNum">
        <xsl:apply-templates mode="noTypeNum"/>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$noTypeNum"/>
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
            <xsl:message select="'ERROR: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="yes"/>
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