<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:local="http://salamanca.adwmainz.de" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" xmlns:t="http://www.tei-c.org/ns/tite/1.0" version="2.0">

    <xsl:output method="xml"/>

    <xsl:param name="editors" as="xs:string" select="' #MAH #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2025-09-08'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0105_change_003'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Structural annotation in 4 rounds.'"/>
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



    <!-- round 1: type, n and ID of div1.  -->
    <xsl:variable name="round-1">
        <xsl:apply-templates select="/" mode="round-1"/>
    </xsl:variable>

    <!-- identity transform  for round 1-->

    <xsl:template match="@* | node()" mode="round-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-1"/>
        </xsl:copy>
    </xsl:template>



    <xsl:template match="tei:body//tei:div1[not(@type eq 'part' or @type eq 'preface' or @type eq 'errata' or @type eq 'colophon') ]" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div1[not(@type eq 'part' or @type eq 'preface' or @type eq 'errata' or @type eq 'colophon') and ancestor::tei:body]) + 1"/>
<xsl:choose>
    <xsl:when test="$nDiv > 21">   <xsl:attribute name="n" select="concat('[', $nDiv, ']')"/></xsl:when>
<xsl:otherwise>          <xsl:attribute name="n" select="$nDiv"/></xsl:otherwise>
</xsl:choose>
            <xsl:attribute name="type" select="'question'"/>
            <xsl:attribute name="xml:id" select="concat('quest', $nDiv)"/>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>





<!-- milestone: suppressing all punctuation in  the @n with regex. -->
    <xsl:template match="tei:milestone" mode="round-1">
        <xsl:copy>   
                    <xsl:attribute name="n" select="replace(@n/string(), '(\d+)(.*)', '$1')"/> 
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>

<xsl:template match="//tei:body/tei:div1/tei:div2/tei:list" mode="round-1">
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:attribute name="type" select="'summaries'"/>
         <xsl:apply-templates mode="round-1"/>
</xsl:copy>
</xsl:template>

    <!-- round 2: type, n and ID of div2.  -->
    <xsl:variable name="round-2">
        <xsl:apply-templates select="$round-1" mode="round-2"/>
    </xsl:variable>

    <!-- identity transform  for round 2-->

    <xsl:template match="@* | node()" mode="round-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-2"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:div1//tei:div2[not(@type eq 'section')]" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
       <xsl:variable name="div1ID" select="./ancestor::tei:div1/@xml:id"/>
<xsl:choose>
    <xsl:when test="contains(., 'Dispvt')"> 
<!-- Disputationes are counted from the body, not the div1 parent ! -->
<xsl:variable name="nDisp" select="count(preceding::tei:div2[contains(., 'Dispvt') and not(@type eq 'section') and ancestor::tei:body]) + 1"/>
  <xsl:attribute name="n" select="$nDisp"/>
 <xsl:attribute name="type" select="'disputation'"/>
<xsl:attribute name="xml:id" select="concat('disput', $nDisp)"/>
</xsl:when>
  <xsl:when test="contains(., 'Articvl')"> 
<xsl:variable name="nArt" select="count(preceding-sibling::tei:div2[contains(., 'Articvl') and not(@type eq 'section') and ancestor-or-self::tei:div1]) + 1"/>
<xsl:choose>
<xsl:when test="not(./@n)">
  <xsl:attribute name="n" select="$nArt"/>
</xsl:when>
<xsl:otherwise/>
</xsl:choose>

 <xsl:attribute name="type" select="'article'"/>
<xsl:attribute name="xml:id" select="concat($div1ID, '_article', $nArt)"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="nPart" select="count(preceding-sibling::tei:div2[@type eq 'part' and not(@type eq 'section') and ancestor-or-self::tei:div1]) + 1"/>
  <xsl:attribute name="n" select="$nPart"/>
 <xsl:attribute name="type" select="'part'"/>
<xsl:attribute name="xml:id" select="concat($div1ID, '_part_', $nPart)"/>

</xsl:otherwise>        
</xsl:choose>       
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>


    <!-- round 3: type, n and ID of div3  -->
    <xsl:variable name="round-3">
        <xsl:apply-templates select="$round-2" mode="round-3"/>
    </xsl:variable>

    <!-- identity transform  for round 3-->

    <xsl:template match="@* | node()" mode="round-3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-3"/>
        </xsl:copy>
    </xsl:template>

<xsl:template match="//tei:div2[@type eq 'disputation']/tei:div3" mode="round-3">
<xsl:copy>
  <xsl:copy-of select="@*"/>
<xsl:variable name="div2ID" select="./ancestor-or-self::tei:div2/@xml:id"/>
<xsl:variable name="nChap" select="count(preceding-sibling::tei:div3[ancestor-or-self::tei:div2])+1"/>
<xsl:attribute name="type" select="'chapter'"/>
<xsl:attribute name="n" select="$nChap"/>
<xsl:attribute name="xml:id" select="concat($div2ID, '_chapter', $nChap)"/>
   <xsl:apply-templates mode="round-3"/>
</xsl:copy>
</xsl:template>

<xsl:template match="//tei:div2[@type eq 'article']/tei:div3" mode="round-3">
<xsl:copy>
  <xsl:copy-of select="@*"/>
<xsl:variable name="div2ID" select="./ancestor-or-self::tei:div2/@xml:id"/>
<xsl:choose>
<xsl:when test="./p[@rend eq 'h3' and contains(., 'Dub') or @rend eq 'h3' and contains(., 'dub')]">
<xsl:variable name="nDub" select="count(preceding-sibling::tei:div3[(contains(., 'Dub')  or contains(., 'dub')) and ancestor-or-self::tei:div2])+1"/>
<xsl:attribute name="type" select="'doubt'"/>
<xsl:attribute name="n" select="$nDub"/>
<xsl:attribute name="xml:id" select="concat($div2ID, '_doubt', $nDub)"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="nSec" select="count(preceding-sibling::tei:div3[(not(contains(., 'Dub')) or not(contains(., 'dub'))) and ancestor-or-self::tei:div2])+1"/>
<xsl:attribute name="type" select="'section'"/>
<xsl:attribute name="n" select="$nSec"/>
<xsl:attribute name="xml:id" select="concat($div2ID, '_section', $nSec)"/>
</xsl:otherwise>
</xsl:choose>

   <xsl:apply-templates mode="round-3"/>
</xsl:copy>
</xsl:template>

<xsl:template match="tei:list[@type='contents']/tei:item/tei:list/tei:head//tei:ref" mode="round-3">
   <xsl:copy>
            <xsl:copy-of select="@*"/>
<xsl:variable name="nDisp" select="count(preceding::tei:head//tei:ref)+1"/>
<xsl:attribute name ="xml:id" select="concat('ref_disput', $nDisp)"/>
<xsl:attribute name="target" select="concat('#disput', $nDisp)"/>
     <xsl:apply-templates mode="round-3"/>
   </xsl:copy>
</xsl:template>

<!-- round 4: type, ref and id of refs -->
    <xsl:variable name="round-4">
        <xsl:apply-templates select="$round-3" mode="round-4"/>
    </xsl:variable>

    <!-- identity transform  for round 4-->

    <xsl:template match="@* | node()" mode="round-4">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-4"/>
        </xsl:copy>
    </xsl:template>


<xsl:template match="tei:list[@type='summaries']//tei:ref" mode="round-4">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--<xsl:message>Adding @target to ref in summaries.</xsl:message>-->
                   <xsl:variable name="refNumber" select="replace(., '(\d+)(.*)', '$1')"/> 
<xsl:attribute name="n" select="$refNumber"/>
                <xsl:variable name="div3ID" select="following::tei:div3[ancestor::tei:div2 = current()/ancestor::tei:div2][replace(@n, '[\[\]]', '') eq $refNumber][1]/@xml:id"/>
<xsl:attribute name="xml:id" select="concat('ref_', $div3ID)"/>
                <xsl:choose>
                    <xsl:when test="not($div3ID)">
                        <xsl:attribute name="target" select="'unknown'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="target" select="concat('#', $div3ID)"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates mode="round-4"/>
            </xsl:copy>
    </xsl:template>

<!-- Test to to ToC for div3 -->

<xsl:template match="tei:list[@type='contents']/tei:item/tei:list/tei:item/tei:ref" mode="round-4">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            
<xsl:variable name="divID" select="substring-after(../../tei:head//tei:ref/@target, '#')"/>

                   <xsl:variable name="refNumber" select="replace(., '(\d+)(.*)', '$1')"/> 
<xsl:attribute name="n" select="$refNumber"/>

<xsl:attribute name="xml:id" select="concat('ref2_', $divID, '_chapter', $refNumber)"/>
              <xsl:attribute name="target" select="concat('#', $divID, '_chapter', $refNumber)"/>
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
