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
    <xsl:param name="editingDate" as="xs:string" select="'2025-02-28'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0031_change_01'"></xsl:param>
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


    <!-- round 1: div1 + milestone -->
  <xsl:variable name="round-1">
        <xsl:apply-templates select="/" mode="round-1"/>
    </xsl:variable>

    <!-- identity transform -->
      <xsl:template match="@* | node()" mode="round-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-1"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:body//tei:div1[@type ne 'preface' and @type ne 'foreword' and @type ne 'epilogue' and @type ne 'colophon']" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div1[ancestor::tei:body and @type ne 'preface' and @type ne 'foreword' and @type ne 'epilogue' and @type ne 'colophon'])+1"/>
            <xsl:attribute name="n" select="$nDiv"/>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:milestone" mode="round-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates mode="round-1"/>
        </xsl:copy>
    </xsl:template>
    
  <!--Second round -div2 -->
    <xsl:variable name="round-2">
        <xsl:apply-templates select="$round-1" mode="round-2"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-2"/>
        </xsl:copy>
    </xsl:template>


<!--For the chapter "postremus" (last), number will be in [] -->


    <xsl:template match="tei:div1//tei:div2[(@type  eq 'chapter') and not(@type eq 'colophon') and not(@type  eq 'section')]" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

                <xsl:attribute name="n" select="concat('[', count(preceding-sibling::tei:div2[ancestor-or-self::tei:div1 and not(@type eq 'colophon') and not(@type  eq 'section')])+1, ']')"/>

    <xsl:attribute name="type" select="'chapter'"/>       
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>


 <!-- Every subpart with a title = div2. If unumbered, then @type = section manually inserted.  TODO: add exception for div1[12] from the sixth chapter -->
    <xsl:template match="tei:div1//tei:div2[not(@type)]" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

                <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div2[ancestor-or-self::tei:div1 and not(@type eq 'colophon') and not(@type  eq 'section')])+1"/>
<xsl:variable name="parentDiv1" select="ancestor::tei:div1[@n='12']"/>
<xsl:choose>
            <xsl:when test="$parentDiv1 and $nDiv > 5">
                <xsl:attribute name="n" select="concat('[', $nDiv, ']')"/>

         </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="n" select="$nDiv"/>

            </xsl:otherwise>
        </xsl:choose>   
    <xsl:attribute name="type" select="'chapter'"/>       
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>



   <xsl:template match="tei:div2//tei:div3[not(@type  eq 'section')]" mode="round-2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
          <xsl:variable name="nDiv" select="count(preceding-sibling::tei:div3[ancestor-or-self::tei:div2 and not(@type eq 'section')])+1"/>
              <xsl:variable name="parentDiv2" select="ancestor::tei:div2[@n='3']"/>
        <xsl:choose>
            <xsl:when test="$parentDiv2 and $nDiv > 1">
                <xsl:attribute name="n" select="concat('[', $nDiv, ']')"/>

         </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="n" select="$nDiv"/>

            </xsl:otherwise>
        </xsl:choose>   
            <xsl:attribute name="type" select="'section'"/>  
            <xsl:apply-templates mode="round-2"/>
        </xsl:copy>
    </xsl:template>
  

    

            <xsl:template match="tei:foreign[not(@xml:lang)]" mode="round-2">

        <xsl:copy>
            <xsl:copy-of select="@*"/>       
                        <xsl:attribute name="xml:lang" select="'es'"/>          
                <xsl:apply-templates mode="round-2"/>

            </xsl:copy>
    </xsl:template>

<xsl:template match="tei:note[@rend='noRef']" mode="round-2">
 <xsl:copy>
            <xsl:copy-of select="@*"/>

         
                <xsl:attribute name="type" select="'margin'"/>

        <xsl:apply-templates mode="round-2"/>       


 </xsl:copy>
</xsl:template>


  <!--Second round -note with * -->
    <xsl:variable name="round-3">
        <xsl:apply-templates select="$round-2" mode="round-3"/>
    </xsl:variable>

    <!-- identity transforms -->
    <xsl:template match="@* | node()" mode="round-3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="round-3"/>
        </xsl:copy>
    </xsl:template>


<xsl:template match="tei:note[@n='*']" mode="round-3">
<xsl:copy>
<xsl:attribute name="type" select="'margin'"/>
<xsl:attribute name="rend" select="'asterisk'"/>
<xsl:variable name ="nDiv1" select="ancestor::tei:div1/@n"/>
<xsl:variable name ="nDiv2" select="translate(ancestor::tei:div2/@n, '[]', '')"/>
<xsl:variable name ="nP" select="count(ancestor::tei:div2/preceding-sibling::tei:p)+1"/><!-- not working, groumpf -->
 <xsl:variable name="nAst" select="count(ancestor::tei:body//tei:note[@n='*' and preceding-sibling::tei:note]) + 1"/> <!-- not working, groumpf -->
<!-- <xsl:attribute name="xml:id" select="concat('n', $nDiv1, '_n', $nDiv2, '_n',  $nP, '_n', $nAst)"/> -->
<xsl:attribute name="xml:id" select="generate-id(.)"/>
    <xsl:apply-templates mode="round-3"/>
</xsl:copy>
</xsl:template>

<xsl:template match ="//tei:cb[@n]" mode="round-3">
<xsl:copy>
<xsl:apply-templates mode="round-3"/>
</xsl:copy>

</xsl:template >
    
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