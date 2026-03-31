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
    
    <xsl:param name="editors" as="xs:string" select="'#DG #MAH #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2024-11-21'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0016_Vol02_change_02'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added @n, @type and @xml:id to div2(s), lists and @target(s) to ref in toc. Adding ref @target in contents for refs.'"/>
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
    
    

<!-- round 1: div1 and div2 -->
    <xsl:variable name="round-1">
        <xsl:apply-templates select="/" mode="round-1"/>
    </xsl:variable>  

<!-- identity transform  for round 1-->  

<xsl:template match="@*|node()" mode="round-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-1"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body//tei:div1[@type ne 'foreword']" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div1[ancestor::tei:body and @type ne 'foreword'])+1"/>
            <xsl:attribute name="n" select="$nDiv"/>
<xsl:attribute name="type" select="'book'"/>  
<xsl:attribute name="xml:id" select="concat('b', $nDiv)"/>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>

  

    <xsl:template match="tei:body//tei:div1//tei:div2" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div2[ancestor-or-self::tei:div1])+1"/>
                <xsl:attribute name="n" select="$nDiv"/>
    <xsl:attribute name="type" select="'chapter'"/> 
  
           <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:back//tei:list//tei:list" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
 <xsl:variable name="nList" select="count(preceding::tei:list[ancestor::tei:list])+1"/>
            
                <xsl:attribute name="xml:id" select="concat('list-b', $nList) "/>
           <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>

<!--Second round - type="arg"-->
    <xsl:variable name="round-2">
        <xsl:apply-templates select="$round-1" mode="round-2"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="round-2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-2"/>
        </xsl:copy>
    </xsl:template>

<xsl:template match="tei:div1//tei:div2[@type='chapter']//tei:p[@rend eq 'h2']" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
    
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body//tei:div1//tei:div2" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="bookId" select="ancestor-or-self::tei:div1/@xml:id"/>
                <xsl:attribute name="xml:id" select="concat('chap', ./@n, '_', $bookId)"/>
           <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>

   <xsl:template match="tei:back//tei:list//tei:list[@xml:id]//tei:ref" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
  <xsl:variable name="listId" select="ancestor-or-self::tei:list/@xml:id"/>
 <xsl:variable name="nItem" select="count(ancestor::tei:item/preceding-sibling::tei:item[ancestor-or-self::tei:list[@xml:id]]) + 1"/>
          
                <xsl:attribute name="xml:id" select="concat('ref_chap', $nItem, '_', $listId)"/>
           <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>

  <!--third round - adding target-->
    <xsl:variable name="round-3">
        <xsl:apply-templates select="$round-2" mode="round-3"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="round-3">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-3"/>
        </xsl:copy>
    </xsl:template>


  <xsl:template match="tei:back//tei:list//tei:list[@xml:id]//tei:ref" mode="round-3">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
  <xsl:variable name="listId" select="substring(ancestor-or-self::tei:list/@xml:id, 6)"/>
 <xsl:variable name="nItem" select="count(ancestor::tei:item/preceding-sibling::tei:item[ancestor-or-self::tei:list[@xml:id]]) + 1"/>
          
                <xsl:attribute name="target" select="concat('#chap', $nItem, '_', $listId)"/>

           <xsl:apply-templates mode="round-3"/>
        </xsl:copy>
    </xsl:template>

    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
      <xsl:variable name="out">
        <xsl:copy-of select="$round-3"/>
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