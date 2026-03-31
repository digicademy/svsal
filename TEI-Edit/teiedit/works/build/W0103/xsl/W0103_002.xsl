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
    <xsl:param name="editingDate" as="xs:string" select="'2019-12-17'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0103_change_xx'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added @type to div(s)'"/>
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
    
<!--Round 1 @type and @xml:id to div1 and div2-->

    <xsl:variable name="Round1">
        <xsl:apply-templates select="/" mode="Round1"/>
    </xsl:variable>
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="Round1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Round1"/>
        </xsl:copy>
    </xsl:template>


     <xsl:template match="tei:div1[@type eq 'preface']//tei:div2" mode="Round1">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:if test="not(@type)">
                <xsl:attribute name="type" select="'section'"/>
            </xsl:if>
            <xsl:apply-templates mode="Round1"/>
        </xsl:copy>
     </xsl:template>
     <xsl:template match="tei:div1[@xml:id eq 'b1']//tei:div2" mode="Round1">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:if test="not(@type)">
                <xsl:variable name="n" select="count(preceding-sibling::tei:div2[ancestor::tei:div1[@xml:id eq 'b1']])"/>
                <xsl:attribute name="n">
                    <xsl:choose>
                        <xsl:when test="not(@n)">
                            <xsl:value-of select="$n"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@n"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="type" select="'title'"/>
                <xsl:attribute name="xml:id" select="concat('t',$n,'b1')"/>
            </xsl:if>
            <xsl:apply-templates mode="Round1"/>
        </xsl:copy>
     </xsl:template>
     <xsl:template match="tei:div1[@xml:id eq 'b2']//tei:div2" mode="Round1">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:if test="not(@type)">
                <xsl:variable name="n" select="count(preceding-sibling::tei:div2[ancestor::tei:div1[@xml:id eq 'b2']])+1"/>
                <xsl:attribute name="n">
                    <xsl:choose>
                        <xsl:when test="not(@n)">
                            <xsl:value-of select="$n"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@n"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="type" select="'title'"/>
                <xsl:attribute name="xml:id" select="concat('t',$n,'b2')"/>
            </xsl:if>
            <xsl:apply-templates mode="Round1"/>
        </xsl:copy>
     </xsl:template>

<!--Round 2 @type and @xml:id to div3-->

    <xsl:variable name="Round2">
        <xsl:apply-templates select="$Round1" mode="Round2"/>
    </xsl:variable>

    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="Round2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="Round2"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:body//tei:div3" mode="Round2">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:if test="not(@type)">
                <xsl:attribute name="type" select="'section'"/>
                <xsl:variable name="n" select="count(preceding-sibling::tei:div3[parent::tei:div2[1]])+1"/>
                <xsl:variable name="parent" select="parent::tei:div2/@xml:id"/>
                <xsl:attribute name="xml:id" select="concat('s',$n,$parent)"/>
            </xsl:if>
            <xsl:apply-templates mode="Round2"/>
        </xsl:copy>
     </xsl:template>
 
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$Round2"/>
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