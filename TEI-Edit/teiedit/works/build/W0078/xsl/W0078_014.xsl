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
    <xsl:param name="editingDate" as="xs:string" select="'2020-03-19'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0078_change_025'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Changed labels in heads.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="second">
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
            <xsl:apply-templates mode="second"/>
        </xsl:copy>
    </xsl:template>
    
    <!--    first round ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-->
    
    <xsl:variable name="first">
        <xsl:apply-templates select="/" mode="first"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="first">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="first"/>
        </xsl:copy>
    </xsl:template>


     <!--Changed label in the first paragraph into head bevor the first paragraph.
         Delete lb from label and put it on the head.-->
         
     
    <xsl:template match="tei:p[ancestor::tei:div[@type eq 'entry']]" mode="first">
        <xsl:element name="head">
            <xsl:element name="lb"/>
            <xsl:element name="hi">
                <xsl:attribute name="rendition" select="'#sc'"/>
                <xsl:value-of select="current()/tei:label/tei:hi[1]"/>
            </xsl:element>
        </xsl:element>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="first"/>
        </xsl:copy>
        
    </xsl:template>
<!--    Deleted label and lb -->
    <xsl:template match="tei:p[ancestor::tei:div[@type eq 'entry']]/tei:lb[1]" mode="first"/>
    <xsl:template match="tei:p[ancestor::tei:div[@type eq 'entry']]/tei:label[1]" mode="first"/>
    
    <!--    second round ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-->
    <xsl:variable name="second">
        <xsl:apply-templates select="$first" mode="second"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="second">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="second"/>
        </xsl:copy>
    </xsl:template>
    <!--    Added hi  #initCaps to the first letter each entry in order to keep it like in the original.-->
    <xsl:template match="tei:div[@type eq 'entry']//tei:div[@type eq 'entry'][1]/tei:head[1]/tei:hi" mode="second">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="hi">
                <xsl:attribute name="rendition" select="'#initCaps'"/>
            <xsl:value-of select="substring(.,1,1)"/>
            </xsl:element>
            <xsl:value-of select="substring(.,2)"/>
        </xsl:copy>
    </xsl:template>
    
  
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$second"/>
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