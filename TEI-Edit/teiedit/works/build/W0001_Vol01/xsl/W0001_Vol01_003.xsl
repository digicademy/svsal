<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-04-12'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0001_Vol01_change_011'"></xsl:param>
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
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <!--<xsl:template match="tei:list[@type='contents']//tei:hi[@rend='right']">
        <xsl:element name="ref">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:element>
     </xsl:template> -->
    <xsl:template match="tei:list[@type='contents'][count(ancestor::tei:list[@type='contents']) eq 2]/tei:head">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="ref">
                <xsl:variable name="precedingTitulusLists" as="xs:integer" select="count(./parent::tei:list/parent::tei:item/parent::tei:list/parent::tei:item/preceding-sibling::tei:item)"/>
                <xsl:variable name="titulusDiv" as="element(tei:div1)" select="following::tei:body//tei:div1[@type eq 'title' and count(preceding-sibling::tei:div1) eq $precedingTitulusLists]"/>
                <xsl:variable name="precedingChapterLists" as="xs:integer" select="count(./parent::tei:list/parent::tei:item/preceding-sibling::tei:item)"/>
                <xsl:variable name="chapterDiv" as="element(tei:div2)*" select="$titulusDiv/child::tei:div2[@type eq 'chapter' and @n eq string($precedingChapterLists+1)]"/> <!-- [count(preceding-sibling::tei:div2[@type eq 'chapter']) eq $precedingChapterLists] -->
                <xsl:variable name="chapterId" as="xs:string" select="concat('c', string($precedingChapterLists+1), 't', string($precedingTitulusLists+1))"/>
                <xsl:if test="not(following::tei:div2[@xml:id eq $chapterId])">
                    <xsl:message terminate="yes" select="'ERROR: could not find exactly one matching chapter, found in list/head with text content: ', descendant::text()[1], 
                                                         ' in Titulus list no. ', $precedingTitulusLists+1, ' in chapter list no. ', $precedingChapterLists+1, ' chapterId was ', $chapterId"/>
                </xsl:if>
                <xsl:attribute name="target" select="concat('#', $chapterDiv/@xml:id)"/>
            <xsl:apply-templates/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:list[@type='contents'][count(ancestor::tei:list[@type='contents']) eq 1]/tei:head">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="ref">
                <xsl:variable name="precedingTitulusLists" as="xs:integer" select="count(./parent::tei:list/parent::tei:item/preceding-sibling::tei:item)"/>
                <xsl:variable name="titulusDiv" as="element(tei:div1)" select="following::tei:body//tei:div1[@type eq 'title' and @n eq string($precedingTitulusLists+1)]"/>
                <xsl:variable name="titulusId" as="xs:string" select="concat('t',string($precedingTitulusLists+1))"/>
                <xsl:if test="not(following::tei:div1[@xml:id eq $titulusId])">
                    <xsl:message terminate="yes" select="'ERROR: could not find exactly one matching title, found in list/head with text content:', descendant::text()[1], 
                        ' in Titulus list no. ', $precedingTitulusLists+1"/>
                </xsl:if>
                <xsl:attribute name="target" select="concat('#',$titulusDiv/@xml:id)"/>
                <xsl:apply-templates/>
            </xsl:element>
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