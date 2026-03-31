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
    
    <xsl:param name="editors" as="xs:string" select="'#CR #DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2021-01-18'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0005_Vol01_change_007'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added @targets in toc, @type/@xml:id in list(s), div(s), @n, @unit, @xml:id milestone.'"/>
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

<!--Added @type to list(s) in toc-->
    
    <xsl:template match="tei:div1[@type eq 'contents']//tei:list[not(@type)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'contents'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

<!--Added @target to Toc Libro Primero-->

    <xsl:template match="tei:list[@xml:id eq 'listToc1']//tei:ref[not(@target)]">
         <xsl:copy>
             <xsl:variable name="refNum" select="count(preceding::tei:ref[ancestor::tei:list[@xml:id eq 'listToc1']])+1"/>
             <xsl:attribute name="target" select="concat('#chap',$refNum,'b1')"/>
             <xsl:apply-templates/>
         </xsl:copy>
     </xsl:template>
    
<!--Added @target to Toc Libro Segundo-->   
    
    <xsl:template match="tei:list[@xml:id eq 'listToc2']//tei:ref[not(@target)]">
        <xsl:copy>
            <xsl:variable name="refNum" select="count(preceding::tei:ref[ancestor::tei:list[@xml:id eq 'listToc2']])+1"/>
            <xsl:attribute name="target" select="concat('#chap',$refNum,'b2')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
 
<!--Added @type to list(s) in indexes-->    
    <xsl:template match="tei:div1[@type eq 'index']//tei:list">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'index'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
<!--Added @type and @xml:id to div2(s) book 1  -->
    
    <xsl:template match="tei:div1[@xml:id eq 'b1']//tei:div2[not(@type)]">
        <xsl:copy>
            <xsl:variable name="chapNum" select="count(preceding::tei:div2[not(@type) and ancestor::tei:div1[@xml:id eq 'b1']])+1"/>
            <xsl:attribute name="type" select="'chapter'"/>
            <xsl:attribute name="n" select="$chapNum"/>
            <xsl:attribute name="xml:id" select="concat('chap',$chapNum,'b1')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

<!--Added @type and @xml:id to div2(s) book 2  -->
    
    <xsl:template match="tei:div1[@xml:id eq 'b2']//tei:div2[not(@type)]">
        <xsl:copy>
            <xsl:variable name="chapNum" select="count(preceding::tei:div2[not(@type) and ancestor::tei:div1[@xml:id eq 'b2']])+1"/>
            <xsl:attribute name="type" select="'chapter'"/>
            <xsl:attribute name="n" select="$chapNum"/>
            <xsl:attribute name="xml:id" select="concat('chap',$chapNum,'b2')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

<!--Added @type and @xml:id to div3(s) -->
    
    <xsl:template match="tei:body//tei:div3[not(@type)]">
        <xsl:copy>
            <xsl:attribute name="type" select="'section'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

<!--Added @type to lists in summaries.-->
    
    <xsl:template match="tei:body//tei:list[not(@type)]">
        <xsl:copy>
            <xsl:attribute name="type" select="'summaries'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
<!--Changed hi[@resp eq 'tao:zuo'] to milestone(s), added @n, @unit, @xml:id -->
    <xsl:template match="tei:hi[@resp eq 'tao:zuo']">
        <xsl:element name="milestone">
            <xsl:attribute name="n" select="."/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="xml:id" select="concat('ml-',generate-id())"/>
            <xsl:choose>
                <xsl:when test="preceding-sibling::*[1]/self::tei:ref">
                    <xsl:attribute name="rend" select="'dagger'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:apply-templates/>
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
            <xsl:message select="'INFO: amount of non-whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="no"/>
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