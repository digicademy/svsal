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
    
    <xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2025-04-10'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0112_Vol01_change_004'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged @n, @type, @xml:id(s) in div(s) and milestone, list(s) and @target in TOC.'"/>
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

<!--Added @type list.-->    
<!--Added @type to contents lists-->
    <xsl:template match="tei:list[ancestor::tei:div1[@type eq 'contents']]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'contents'"/>
            <xsl:apply-templates/>   
        </xsl:copy>
    </xsl:template>
<!--Added @type to contents lists-->
    <xsl:template match="tei:list[ancestor::tei:body]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'summaries'"/>
            <xsl:apply-templates/>   
        </xsl:copy>
    </xsl:template>
<!--Added @type to index lists-->
    <xsl:template match="tei:list[ancestor::tei:div1[@type eq 'index']]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'index'"/>
            <xsl:apply-templates/>   
        </xsl:copy>
    </xsl:template>
    <!--Added @n, @type in div1-->
    <xsl:template match="tei:div1[not(@type)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" select="count(preceding::tei:div1[not(@type)][ancestor::tei:body = current()/ancestor::tei:body])+1"/>
            <xsl:attribute name="type" select="'question'"/>
            <xsl:attribute name="xml:id" select="concat('q',$n)"/>
            <xsl:attribute name="n" select="$n"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!--Added @n, @type in div1-->
    <xsl:template match="tei:body//tei:div2[not(@type)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" select="count(preceding::tei:div2[not(@type)][ancestor::tei:div1 = current()/ancestor::tei:div1])+1"/>
            <xsl:variable name="id" select="count(preceding::tei:div2[not(@type)][ancestor::tei:body])+1"/>
            <xsl:attribute name="type" select="'article'"/>
            <xsl:attribute name="xml:id" select="concat('art',$id)"/>
            <xsl:attribute name="n">
                <xsl:choose>
                <xsl:when test="@n">
                    <xsl:value-of select="@n"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$n"/></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    

    <!--TOC Added @target in ref-->   
    
    <!-- div1 "Booklevel" -->
    
    <xsl:template match="tei:ref[starts-with(.,'Q')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="question-id"  select="current()/ancestor::tei:list/@xml:id"/>
            <xsl:attribute name="target" select="concat('#',translate($question-id,'list-',''))"/>  
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div1[@type eq 'contents']//tei:ref[starts-with(.,'A')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="art-id"  select="count(preceding::tei:ref[starts-with(.,'A')])+1"/>
            <xsl:attribute name="target" select="concat('#art',$art-id)"/>  
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:milestone">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>  
            <xsl:apply-templates/>
        </xsl:copy>
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