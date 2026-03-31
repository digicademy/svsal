<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:local="http://salamanca.adwmainz.de" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" xmlns:t="http://www.tei-c.org/ns/tite/1.0" version="2.0">

    <xsl:output method="xml"/>

    <xsl:param name="editors" as="xs:string" select="' #MAH #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2025-09-08'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0062_change_003'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'...'"/>
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



    <xsl:template match="tei:body//tei:div1" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div1[ancestor::tei:body]) + 1"/>
            <xsl:attribute name="n" select="$nDiv"/>
            <xsl:attribute name="type" select="'book'"/>
            <xsl:attribute name="xml:id" select="concat('b', $nDiv)"/>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>





    <!--Second round - type, n and ID  of div2.-->
    <xsl:variable name="round-2">
        <xsl:apply-templates select="$round-1" mode="round-2"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-2"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body//tei:div1/tei:div2[not(@type eq 'section') and not(@type eq 'colophon')] " mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div2[ancestor-or-self::tei:div1 and not(@type eq 'section') and not(@type eq 'colophon')]) + 1"/>
            <xsl:attribute name="n" select="$nDiv"/>
            <xsl:variable name="bookId" select="ancestor-or-self::tei:div1/@xml:id"/>
            <xsl:choose>
                <xsl:when test="$bookId eq 'b2'">
                    <xsl:attribute name="type" select="'section'"/>
                    <xsl:attribute name="xml:id" select="concat('section', $nDiv, '_', $bookId)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type" select="'chapter'"/>
                    <xsl:attribute name="xml:id" select="concat('chap', $nDiv, '_', $bookId)"/>

                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="n" select="$nDiv"/>
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>



    <!--Third round - type, n and ID  of div3. -->
    <xsl:variable name="round-3">
        <xsl:apply-templates select="$round-2" mode="round-3"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-3"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body//tei:div1/tei:div2/tei:div3" mode="round-3">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="ancestor-or-self::tei:div2[@type eq 'section']">
 <xsl:variable name="div1ID" select="ancestor-or-self::tei:div1/@xml:id"/>


<xsl:variable name="nPart">
  <xsl:number level="any" count="tei:div3" from="tei:div1"/>
</xsl:variable>

                    <xsl:attribute name="xml:id" select="concat('chap', $nPart, '_', $div1ID)"/>
                    <xsl:attribute name="type" select="'chapter'"/>
       <xsl:attribute name="n" select="$nPart"/>
                </xsl:when>
                <xsl:otherwise>
 <xsl:variable name="div2ID" select="ancestor-or-self::tei:div2/@xml:id"/>
<xsl:variable name="nPart" select="count(preceding-sibling::tei:div3[ancestor-or-self::tei:div2]) + 1"/>
                    <xsl:attribute name="xml:id" select="concat('doubt', $nPart, '_', $div2ID)"/>
                    <xsl:attribute name="type" select="'doubt'"/>
 <xsl:attribute name="n" select="$nPart"/>
                </xsl:otherwise>
            </xsl:choose>
           
            <xsl:apply-templates mode="round-3"/>
        </xsl:copy>
    </xsl:template>

<!-- First steps of the ToC in the back: giving list xml:id, and populating xml:id and target for the book (div1)-->

<xsl:template match="tei:back/tei:div1/tei:list[@type eq 'contents']/tei:item/tei:list" mode="round-3">

<xsl:copy>
            <xsl:copy-of select="@*"/>

<xsl:variable name="nB">
  <xsl:number level="any" count="tei:list[not(@type)]" from="tei:list[@type eq 'contents']"/>
</xsl:variable>
<xsl:attribute name="xml:id" select="concat('list_b', $nB)"/>
 <xsl:apply-templates mode="round-3"/> 
</xsl:copy>

</xsl:template>

<xsl:template match="tei:back/tei:div1/tei:list[@type eq 'contents']/tei:item/tei:list/tei:head/tei:ref" mode="round-3">

<xsl:copy>
            <xsl:copy-of select="@*"/>

<xsl:variable name="nB">
  <xsl:number level="any" count="tei:div1/tei:list/tei:item/tei:list/tei:head" from="tei:list[@type eq 'contents']"/>
</xsl:variable>
<xsl:attribute name="xml:id" select="concat('ref_b', $nB)"/>
<xsl:attribute name="target" select="concat('#b', $nB)"/>
<xsl:apply-templates mode="round-3"/> 
</xsl:copy>
 
</xsl:template>


    <!--4th round - type, n and ID of div4 milestones, + building the linking of the 2 tables of contents from b2 and the general (back). -->
    <xsl:variable name="round-4">
        <xsl:apply-templates select="$round-3" mode="round-4"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-4">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-4"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:body//tei:div2/tei:div3/tei:div4" mode="round-4">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="div3ID" select="ancestor-or-self::tei:div3/@xml:id/string()"/>

<xsl:choose>
            <xsl:when test="contains($div3ID, 'chap1_b2')">
      <xsl:variable name="base" select="1"/>
                <xsl:variable name="nPart" select="count(preceding-sibling::tei:div4[ancestor-or-self::tei:div3]) +$base + 1"/>
            <xsl:attribute name="xml:id" select="concat('doubt', $nPart, '_', $div3ID)"/>
            <xsl:attribute name="type" select="'doubt'"/>
            <xsl:attribute name="n" select="$nPart"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="nPart" select="count(preceding-sibling::tei:div4[ancestor-or-self::tei:div3]) + 1"/>
            <xsl:attribute name="xml:id" select="concat('doubt', $nPart, '_', $div3ID)"/>
            <xsl:attribute name="type" select="'doubt'"/>
            <xsl:attribute name="n" select="$nPart"/>
</xsl:otherwise>
</xsl:choose>
            <xsl:apply-templates mode="round-4"/>
        </xsl:copy>
    </xsl:template>

<!-- First ToC : inside b2, with the sectios and the chapters -->

<xsl:template match="tei:div1[@xml:id eq 'b2']/tei:list[@type eq 'contents']/tei:item/tei:list/tei:head/tei:ref" mode="round-4">

<xsl:copy>
            <xsl:copy-of select="@*"/>

<xsl:variable name="nSectio">
  <xsl:number level="any" count="tei:head" from="tei:list[@type eq 'contents']"/>
</xsl:variable>
<xsl:variable name="div1ID" select="ancestor-or-self::tei:div1/@xml:id"/>

<xsl:attribute name="xml:id" select="concat('ref_section', $nSectio, '_', $div1ID)"/>
<xsl:attribute name="target" select="concat('#section', $nSectio, '_', $div1ID)"/>

</xsl:copy>



 <xsl:apply-templates mode="round-4"/> 
</xsl:template>

<xsl:template match="tei:div1[@xml:id eq 'b2']/tei:list[@type eq 'contents']/tei:item/tei:list/tei:item/tei:ref" mode="round-4">
<xsl:copy>
            <xsl:copy-of select="@*"/>
<xsl:variable name="nChap">
  <xsl:number level="any" count="tei:item[child::tei:lb]" from="tei:list[@type eq 'contents']"/>
</xsl:variable>
<xsl:variable name="div1ID" select="ancestor-or-self::tei:div1/@xml:id"/>

<xsl:attribute name="xml:id" select="concat('ref_chap', $nChap, '_', $div1ID)"/>
<xsl:attribute name="target" select="concat('#chap', $nChap, '_', $div1ID)"/>
</xsl:copy>
 <xsl:apply-templates mode="round-4"/>
</xsl:template>



<!-- Second ToC : inside back, with only the books and the chapters. Dubia are not linked here. -->




<xsl:template match="tei:back/tei:div1/tei:list[@type eq 'contents']/tei:item/tei:list/tei:item/tei:list/tei:head/tei:ref" mode="round-4">
<xsl:copy>
            <xsl:copy-of select="@*"/>
<xsl:variable name="nChap">
  <xsl:number level="any" count="tei:div1/tei:list/tei:item/tei:list/tei:item/tei:list/tei:head" from="tei:list[@xml:id]"/>
</xsl:variable>
<xsl:variable name="b1ID" select="substring-after(ancestor-or-self::tei:list/tei:head/tei:ref/@xml:id, '_')"/>

<xsl:choose>
<xsl:when test="$b1ID eq 'b2'">
<xsl:attribute name="xml:id" select="concat('ref2_chap', $nChap, '_', $b1ID)"/>
<xsl:attribute name="sameAs" select="concat('ref_chap', $nChap, '_', $b1ID)"/>
<xsl:attribute name="target" select="concat('#chap', $nChap, '_', $b1ID)"/>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="xml:id" select="concat('ref_chap', $nChap, '_', $b1ID)"/>
<xsl:attribute name="target" select="concat('#chap', $nChap, '_', $b1ID)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:copy>
 <xsl:apply-templates mode="round-4"/>
</xsl:template>


<!-- milestone: suppressing all punctuation in  the @n with regex. -->
    <xsl:template match="tei:milestone" mode="round-4">
        <xsl:copy>   
                    <xsl:attribute name="n" select="replace(@n/string(), '(\d+)(.*)', '$1')"/> 
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
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
