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
    <xsl:param name="editingDate" as="xs:string" select="'2021-10-15'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0043_Vol01_change_009'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged @n in numbered note(s) and delete first line with only digits.'"/>
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
    
    
<!-- 1. Tagging @n in note(s) from first line in text, if it is a digit. mode  mode="n-Attribute"-->
    <!-- identity transform -->
    <xsl:variable name="n-Attribute">
        <xsl:apply-templates select="/" mode="n-Attribute"/>
    </xsl:variable>
    
    <xsl:template match="@* except @part|node()" mode="n-Attribute">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="n-Attribute"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:text//tei:note[matches(.,'^\d{1,3}')]" mode="n-Attribute">
         <xsl:copy>
             <xsl:copy-of select="@*"/>
             <xsl:variable name="numbers" select="t:i/text()[matches(.,'^\d{1,3}')]"/>
             <xsl:attribute name="n" select="translate($numbers,'\.','')"/>
             <xsl:apply-templates mode="n-Attribute"/>
         </xsl:copy>
     </xsl:template>
 
    
<!-- 2. Deleting first lb in notes starting with digits and its digits. -->
    <xsl:variable name="Delete-Digits">
        <xsl:apply-templates select="$n-Attribute" mode="Delete-Digits"/>
    </xsl:variable>
    
    <xsl:template match="@* except @part|node()" mode="Delete-Digits">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="Delete-Digits"/>
        </xsl:copy>
    </xsl:template>
    
    <!--first lb before first digit: 3246-->
    
    <xsl:template match="//tei:text//tei:note[matches(.,'^\d{1,3}')]//node()[1]/self::tei:lb" mode="Delete-Digits"/>
    
    <!--first text() node digit: 3246-->
    
    <xsl:template match="//tei:text//tei:note[matches(.,'^\d{1,3}')]//node()[2]/self::text()" mode="Delete-Digits"/>
    
    
<!--    
    
    
    Total note(s):                          3265
          note(s) starting with digits:     3246
          note(s) not starting with digits: 19
    -->
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$Delete-Digits"/>
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
            <xsl:message select="'INFO: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="no"/>
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
            <xsl:message select="'INFO: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- special chars -->
        <xsl:if test="$inSpecialChars ne $outSpecialChars">
            <xsl:message select="'INFO: different amount of input and output special chars: '"/>
            <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    

</xsl:stylesheet>