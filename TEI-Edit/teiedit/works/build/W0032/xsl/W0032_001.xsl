<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:local="http://salamanca.adwmainz.de" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" xmlns:t="http://www.tei-c.org/ns/tite/1.0" version="2.0">

    <xsl:output method="xml"/>

    <xsl:param name="editors" as="xs:string" select="'#DG #MAH #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2025-13-05'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0065_change_02'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Automatic structural enrichment.'"/>
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

    <xsl:template match="@* | node()" mode="round-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-1"/>
        </xsl:copy>
    </xsl:template>



    <xsl:template match="tei:body//tei:div1[not(@type)]" mode="round-1">

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div1[ancestor::tei:body and not(@type)]) + 1"/>
            <xsl:attribute name="n" select="$nDiv"/>
            <xsl:attribute name="type" select="'chapter'"/>
            <xsl:attribute name="xml:id" select="concat('chap', $nDiv)"/>
             <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>



    <xsl:template match="tei:body//tei:div1//tei:div2[not(ancestor::tei:div1[@type='contents'])]" mode="round-1">

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'segment'"/>
<xsl:if test="position() > 1">
            <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div2[not(position() eq 1) and ancestor-or-self::tei:div1]) + 1"/>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$nDiv"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
</xsl:if>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>

<xsl:template match="tei:div3[not(@type)]" mode="round-1">
        <xsl:copy>
        <xsl:copy-of select="@n"/>
        <xsl:attribute name="type" select="'section'"/>
        <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>

<xsl:template match="tei:milestone" mode="round-1">
        <xsl:copy>
        <xsl:copy-of select="@n"/>
        <xsl:attribute name="unit" select="'section'"/>
        <xsl:attribute name="xml:id" select="generate-id(.)"/>
        <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>




    <!--Second round -refining IDs, foreign-->
    <xsl:variable name="round-2">
        <xsl:apply-templates select="$round-1" mode="round-2"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-2"/>
        </xsl:copy>
    </xsl:template>

 <xsl:template match="tei:list[not(ancestor::tei:list) and not(ancestor::tei:back)]" mode="round-2">

<xsl:choose>
<xsl:when test="./ancestor::tei:div1[@n eq '5']">
 <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:attribute name="type" select="'summaries'"/>
   <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
</xsl:when>
<xsl:otherwise><xsl:element name="argument">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
            <xsl:attribute name="type" select="'summaries'"/>
   <xsl:apply-templates mode="round-2"/>
            
        </xsl:copy>
</xsl:element></xsl:otherwise>

      
</xsl:choose>
       
    </xsl:template>

    <xsl:template match="tei:body//tei:div1//tei:div2" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="chapId" select="ancestor-or-self::tei:div1/@xml:id"/>
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="contains(@n, '[')">
                        <xsl:variable name="Numb" select="replace(@n, '(\S)(\d{2})(\S)', '$2')"/>
                        <xsl:value-of select="concat('part', $Numb, '_', $chapId)"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:value-of select="concat('part', ./@n, '_', $chapId)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:div1[@type='contents']/tei:div2" mode="round-2">

        <xsl:copy>
            <xsl:copy-of select="@*"/>
<xsl:attribute name="type" select="'contents'"></xsl:attribute>
           <xsl:apply-templates mode="round-2"/>
        </xsl:copy>

    </xsl:template>



<xsl:template match="tei:list[@type='summaries']//tei:ref" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--<xsl:message>Adding @target to ref in summaries.</xsl:message>-->
          
<xsl:if test="following::tei:milestone[ancestor::tei:div2]">
      <xsl:variable name="refNumber" as="xs:string" select="."/>
                <xsl:variable name="milestoneId" select="following::tei:milestone[ancestor::tei:div2 = current()/ancestor::tei:div2][replace(@n, '[\[\]]', '') eq $refNumber][1]/@xml:id"/>
                <xsl:choose>
                    <xsl:when test="not($milestoneId)">
                     
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="target" select="concat('#', $milestoneId)"/>
                    </xsl:otherwise>
                </xsl:choose>
</xsl:if>
<xsl:if test="following::tei:milestone[ancestor::tei:div1]">
      <xsl:variable name="refNumber" as="xs:string" select="."/>
                <xsl:variable name="milestoneId" select="following::tei:milestone[ancestor::tei:div1 = current()/ancestor::tei:div1][replace(@n, '[\[\]]', '') eq $refNumber][1]/@xml:id"/>
                <xsl:choose>
                    <xsl:when test="not($milestoneId)">
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="target" select="concat('#', $milestoneId)"/>
                    </xsl:otherwise>
                </xsl:choose>
</xsl:if>
                <xsl:apply-templates mode="round-2"/>
            </xsl:copy>
    </xsl:template>



    <xsl:template match="tei:foreign" mode="round-2">

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:lang" select="'es'"/>
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>

    <!--Second round -refining IDs, foreign-->
    <xsl:variable name="round-3">
        <xsl:apply-templates select="$round-2" mode="round-3"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-3"/>
        </xsl:copy>
    </xsl:template>

 <xsl:template match="tei:div2[@type eq 'contents']/tei:p[1]/tei:hi[1]" mode="round-3"> 
<xsl:element name="ref">
<xsl:variable name="position" select="count(preceding::tei:div2[ancestor::tei:div1[@type='contents']])+1"/>
      <xsl:attribute name="xml:id" select="concat('ref_chap', $position)"></xsl:attribute>    
           <xsl:attribute name="target" select="concat('#chap', $position)"></xsl:attribute>
  <xsl:copy>
            <xsl:copy-of select="@*"/>
           <xsl:apply-templates mode="round-3"/>
        </xsl:copy>
</xsl:element>


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
