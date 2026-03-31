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
    
    <xsl:param name="editors" as="xs:string" select="'#MAH #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2025-06-05'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0038_change_03'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Structural annotation.'"/>
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

  <!-- round 1: div1 -->
    <xsl:variable name="round-1">
        <xsl:apply-templates select="/" mode="round-1"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="round-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-1"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body//tei:div1[@type ne 'title' and @type ne 'epilogue']" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="./@n"/>
                <xsl:attribute name="xml:id" select="concat('tractatus', $nDiv)"/>
<xsl:attribute name="type" select="'part'"/>  
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>




        <xsl:template match="tei:body//tei:list" mode="round-1">

        <xsl:copy>
            <xsl:copy-of select="@*"/>       
                        <xsl:attribute name="type" select="'summaries'" />          
                <xsl:apply-templates mode="round-1"/>
            </xsl:copy>
    </xsl:template>
      <xsl:template match="tei:front/tei:div1/tei:list" mode="round-1">

        <xsl:copy>
            <xsl:copy-of select="@*"/>       
                        <xsl:attribute name="type" select="'contents'" />          
                <xsl:apply-templates mode="round-1"/>
            </xsl:copy>
    </xsl:template>

<xsl:template match="tei:front/tei:div1/tei:list/tei:item/tei:list/tei:head/tei:ref" mode="round-1">
<xsl:copy>
   <xsl:copy-of select="@*"/>    
<xsl:attribute name="target" select="concat('#tractatus', ./@n)"/>
<xsl:attribute name="xml:id" select="concat('ref_tractatus', ./@n)"/>
     <xsl:apply-templates mode="round-1"/>
</xsl:copy>

</xsl:template>

    <xsl:template match="tei:back/tei:div1/tei:list" mode="round-1">

        <xsl:copy>
            <xsl:copy-of select="@*"/>       
                        <xsl:attribute name="type" select="'index'" />          
                <xsl:apply-templates mode="round-1"/>
            </xsl:copy>
    </xsl:template>


      <xsl:template match="tei:foreign" mode="round-1">

        <xsl:copy>
            <xsl:copy-of select="@*"/>       
                        <xsl:attribute name="xml:lang" select="'es'"/>          
                <xsl:apply-templates mode="round-1"/>
            </xsl:copy>
    </xsl:template>


    
  <!-- round 2: div2  and corresponding ref in div1/@contents-->
    <xsl:variable name="round-2">
        <xsl:apply-templates select="$round-1" mode="round-2"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="round-2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-2"/>
        </xsl:copy>
    </xsl:template>

   <xsl:template match="tei:div1[@xml:id]/tei:div2[not(@type eq 'section') and not(@type eq 'title')]" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
          <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div2[not(@type eq 'section') and not(@type eq 'title') and ancestor-or-self::tei:div1[@xml:id]])+1"/>
              <xsl:variable name="parentDiv" select="ancestor-or-self::tei:div1/@xml:id"/>
        <xsl:choose>
            <xsl:when test=".[not(@n)]">
                <xsl:attribute name="n" select="$nDiv"/>
         </xsl:when>
            <xsl:otherwise/>    
        </xsl:choose>   
            <xsl:attribute name="type" select="'part'"/>  
<xsl:choose>
  <xsl:when test="contains($parentDiv, '31')">
<xsl:attribute name="xml:id" select="concat($parentDiv,'_punctum', $nDiv)"/> 
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="xml:id" select="concat($parentDiv,'_disputatio', $nDiv)"/> 
</xsl:otherwise>
</xsl:choose>
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>

<!-- creating references in ToC for disputation-->
<xsl:template match="tei:front/tei:div1/tei:list/tei:item/tei:list/tei:item/tei:list/tei:head/tei:ref" mode="round-2">
<xsl:copy>
   <xsl:copy-of select="@*"/>    
    <xsl:variable name="parentDiv" select="../../../..//tei:ref/@xml:id"/>
<xsl:variable name="targetDiv" select="../../../..//tei:ref/@target"/>

 <xsl:variable name="nDiv" select="count(preceding::tei:head/tei:ref[not(@n) and ancestor-or-self::tei:list/tei:head/tei:ref[@xml:id eq $parentDiv]])+1"/>
<xsl:attribute name="xml:id" select="concat($parentDiv,'_disputatio', $nDiv)"/> 
<xsl:attribute name="target" select="concat($targetDiv,'_disputatio', $nDiv)"/>
     <xsl:apply-templates mode="round-2"/>
</xsl:copy>

</xsl:template>

<!-- creating references in ToC for tractatus 31, because the matching ref is not at the same level. -->
<xsl:template match="tei:front/tei:div1/tei:list/tei:item/tei:list/tei:item/tei:list/tei:item/tei:ref" mode="round-2">
<xsl:copy>
   <xsl:copy-of select="@*"/>    
    <xsl:variable name="parentDiv" select="../../../..//tei:ref/@xml:id"/>
<xsl:variable name="targetDiv" select="../../../..//tei:ref/@target"/>
<xsl:choose>
  <xsl:when test="contains($parentDiv, '31')">
 <xsl:variable name="nDiv" select="count(preceding::tei:item/tei:ref)+1"/>
<xsl:attribute name="xml:id" select="concat($parentDiv,'_punctum', $nDiv)"/>
<xsl:attribute name="target" select="concat($targetDiv,'_punctum', $nDiv)"/>
 </xsl:when>
 
<xsl:otherwise/>
</xsl:choose>
<xsl:apply-templates mode="round-2"/>
</xsl:copy>
</xsl:template>
  

  <!-- round 3: div3 -->
    <xsl:variable name="round-3">
        <xsl:apply-templates select="$round-2" mode="round-3"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="round-3">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-3"/>
        </xsl:copy>
    </xsl:template>

   <xsl:template match="tei:div2[@xml:id]/tei:div3" mode="round-3">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
          <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div3[ancestor-or-self::tei:div2[@xml:id]])+1"/>
              <xsl:variable name="parentDiv" select="ancestor-or-self::tei:div2/@xml:id"/>
        <xsl:choose>
            <xsl:when test=".[not(@n)]">
                <xsl:attribute name="n" select="$nDiv"/>
         </xsl:when>
            <xsl:otherwise/>    
        </xsl:choose>   
<xsl:choose>
  <xsl:when test="contains($parentDiv, '31')">
<xsl:attribute name="xml:id" select="concat($parentDiv,'_par', $nDiv)"/>
 <xsl:attribute name="type" select="'section'"/>  
 </xsl:when>
<xsl:otherwise>
<xsl:attribute name="xml:id" select="concat($parentDiv,'_punctum', $nDiv)"/> 
  <xsl:attribute name="type" select="'part'"/>  
</xsl:otherwise>
</xsl:choose>
         
            <xsl:apply-templates mode="round-3"/>
        </xsl:copy>
    </xsl:template>


      <!-- round 4: div4 -->
    <xsl:variable name="round-4">
        <xsl:apply-templates select="$round-3" mode="round-4"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="round-4">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round-4"/>
        </xsl:copy>
    </xsl:template>

   <xsl:template match="tei:div3[@xml:id]/tei:div4" mode="round-4">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
          <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div4[ancestor-or-self::tei:div3[@xml:id]])+1"/>
              <xsl:variable name="parentDiv" select="ancestor-or-self::tei:div3/@xml:id"/>
        <xsl:choose>
            <xsl:when test=".[not(@n)]">
                <xsl:attribute name="n" select="$nDiv"/>
         </xsl:when>
            <xsl:otherwise/>    
        </xsl:choose>   
            <xsl:attribute name="type" select="'section'"/>  
<xsl:attribute name="xml:id" select="concat($parentDiv,'_par', $nDiv)"/> 
            <xsl:apply-templates mode="round-4"/>
        </xsl:copy>
    </xsl:template>










    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
     <xsl:variable name="out">
        <xsl:copy-of select="$round-4"/>
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