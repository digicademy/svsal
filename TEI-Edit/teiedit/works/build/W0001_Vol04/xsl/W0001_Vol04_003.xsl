<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!--<xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-07-09'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0001_Vol04_change_004'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added ref in table of contents.'"/>
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
    </xsl:template>-->
    
    <xsl:variable name="ref">
        <xsl:apply-templates select="/" mode="ref"/>
    </xsl:variable>

    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="ref">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ref"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:list[@type='contents'][count(ancestor::tei:list[@type='contents']) eq 2]/tei:head" mode="ref">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="ref">
                <xsl:variable name="currentPartList" as="xs:integer" select="count(./ancestor::tei:list[count(ancestor::tei:list) eq 1]/parent::tei:item/preceding-sibling::tei:item) + 1"/>  
                <xsl:variable name="currentSegmentOrAdditionalList" as="xs:integer">
                    <xsl:choose>
                        <xsl:when test="$currentPartList eq 1">
                            <xsl:value-of select="count(./parent::tei:list/parent::tei:item/preceding-sibling::tei:item) + 1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="count(./parent::tei:list/parent::tei:item/preceding-sibling::tei:item)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!-- div1[@type eq 'part'][$currentPartList]/div2[@type = ('segment', 'additional')][$currentSegmentOrAdditionalList]/@xml:id -->
               <!-- <xsl:message terminate="no" select="'currentPartList=', $currentPartList"></xsl:message>
                <xsl:message terminate="no" select="'currentSegmentOrAdditionalList=', $currentSegmentOrAdditionalList"></xsl:message>-->
                <xsl:variable name="PartDiv1" as="element(tei:div1)" select="following::tei:body//tei:div1[@type eq 'part'][$currentPartList]"/>  
                <xsl:variable name="SegmentOrAdditonalDiv2" as="element(tei:div2)" select="$PartDiv1//tei:div2[$currentSegmentOrAdditionalList]"/>
                <xsl:variable name="xmlId" select="$SegmentOrAdditonalDiv2/@xml:id"/>
                <!--<xsl:message select="'$xmlId = ', $xmlId"></xsl:message>-->
                <xsl:attribute name="target" select="concat('#', $xmlId)"/>
                <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="ref"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:list[@type='contents'][count(ancestor::tei:list[@type='contents']) eq 1]/tei:head" mode="ref">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="ref">
                <xsl:variable name="precedingPartLists" as="xs:integer" select="count(./parent::tei:list/parent::tei:item/preceding-sibling::tei:item)"/>
                <xsl:variable name="PartDiv" as="element(tei:div1)" select="following::tei:body//tei:div1[@type eq 'part' and @n eq string($precedingPartLists+5)]"/>
                <xsl:variable name="PartId" as="xs:string" select="concat('p',string($precedingPartLists+5))"/>
                <xsl:if test="not(following::tei:div1[@xml:id eq $PartId])">
                    <xsl:message terminate="no" select="'ERROR: could not find exactly one matching Part, found in list/head with text content:', descendant::text()[1], 
                        ' in Part list no. ', $precedingPartLists+1"/>
                </xsl:if>
                <xsl:attribute name="target" select="concat('#',$PartDiv/@xml:id)"/>
                <xsl:attribute name="resp" select="'#auto'"/>
                <xsl:apply-templates mode="ref"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$ref"/>
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
        <!-- whitespace and regular symbols -->
        <xsl:if test="$inWhitespace ne $outWhitespace or $inChars ne $outChars">
            <xsl:message select="'ERROR: Numbers of non-whitespace or whitespace characters differ in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
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