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
    
    <xsl:param name="editors" as="xs:string" select="' #MAH #DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2025-02-20'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0006_Vol01_change_032'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Correcting pb numeration post-corrections..'"/>
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

<!-- correcting 16 in 106-->
<xsl:template match="tei:pb[@xml:id='W0006-01-0121-pb-045d']/@n[.='16']">
  <xsl:attribute name="n">[106]</xsl:attribute>
</xsl:template>

<!-- correcting 153 in 253-->
<xsl:template match="tei:pb[@xml:id='W0006-01-0268-pb-04f1']/@n[.='153']">
  <xsl:attribute name="n">[253]</xsl:attribute>
</xsl:template>

<!-- correcting 157 in 257-->
<xsl:template match="tei:pb[@xml:id='W0006-01-0272-pb-04f5']/@n[.='157']">
  <xsl:attribute name="n">[257]</xsl:attribute>
</xsl:template>

<!-- correcting 158 in 258-->
<xsl:template match="tei:pb[@xml:id='W0006-01-0273-pb-04f6']/@n[.='158']">
  <xsl:attribute name="n">[258]</xsl:attribute>
</xsl:template>

<!-- correcting 159 in 259-->
<xsl:template match="tei:pb[@xml:id='W0006-01-0274-pb-04f7']/@n[.='159']">
  <xsl:attribute name="n">[259]</xsl:attribute>
</xsl:template>

<!-- correcting 904 in 934 -->
<xsl:template match="tei:pb[@xml:id='W0006-01-0949-pb-07a2']/@n[.='904']">
  <xsl:attribute name="n">[934]</xsl:attribute>
</xsl:template>

<!-- correcting [945] in 937 -->
<xsl:template match="tei:pb[@xml:id='W0006-01-0952-pb-07a5']">
<xsl:copy>
 <xsl:copy-of select="@*"/>
  <xsl:attribute name="n">937</xsl:attribute>
</xsl:copy>
</xsl:template>

<!-- correcting 937 in 945 -->
<xsl:template match="tei:pb/@n[.='937']">
  <xsl:attribute name="n">[945]</xsl:attribute>
</xsl:template>


<!-- correcting 938 in 946-->
<xsl:template match="tei:pb/@n[.='[938]']">
  <xsl:attribute name="n">[946]</xsl:attribute>
</xsl:template>
    
    <!--Correcting pagination in back matter.-->
    <xsl:template match="tei:back//tei:pb[not(@sameAs)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <xsl:attribute name="n">
                <xsl:variable name="n" as="xs:string">
                    <xsl:number value="count(preceding::tei:pb[ancestor::tei:back and not(ancestor::tei:note and @sameAs)]) + 947"/>
                </xsl:variable>
                <xsl:value-of select="concat('[', $n, ']')"/>
            </xsl:attribute>
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