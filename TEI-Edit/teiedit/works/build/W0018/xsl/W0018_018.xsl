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
    <xsl:param name="editingDate" as="xs:string" select="'2021-10-11'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0018_change_022'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformed note(s) with only digits into milestone(s).'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="Digit">
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
            <xsl:apply-templates mode="Digit"/>
        </xsl:copy>
    </xsl:template>
    
<!-- 1. Transforming note(s) starting with § and only digits into milestone(s). mode="Digit"-->
    
    <xsl:variable name="Digit">
        <xsl:apply-templates select="/" mode="Digit"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@* except @part|node()" mode="Digit">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="Digit"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:text//tei:note[tei:p[text()[matches(.,'§.? \d+[\.:]?$')]]]" mode="Digit">
        <xsl:element name="milestone">
            <xsl:variable name="numbers" select="tei:p/text()[matches(.,'(\d+)')]"/><!--replace(.,normalize-space('^\d{1,3}'),'')-->
            <xsl:attribute name="n">
                <xsl:value-of select="translate($numbers,'§.? [\.:]?','')"/>
            </xsl:attribute>
            <xsl:attribute name="resp" select="'#CR #auto'"/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:variable name="id" select="current()/@xml:id"/>
            <xsl:attribute name="xml:id" select="translate($id,'nm','ml')"/> 
        </xsl:element>
     </xsl:template>
    
    <!-- Update @targets to match with the new milestone(s)' xml:id(s). mode="Digit"--> 
    <xsl:template match="tei:text//tei:ref[@target]" mode="Digit">
        <xsl:copy>
            <xsl:attribute name="target" select="translate(current()/@target,'nm','ml')"/>
            <xsl:apply-templates mode="Digit"/>
        </xsl:copy>
    </xsl:template>
    
<!-- 2. Separating from note(s) the 1st line with only digits and transforming them into milestone(s). mode="Digit2"-->
    <xsl:variable name="Digit2">
        <xsl:apply-templates select="$Digit" mode="Digit2"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@* except @part|node()" mode="Digit2">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="Digit2"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="tei:text//tei:note[tei:p[text()[matches(.,'§.? \d+[\.:]?')]]]" mode="Digit2">
        <xsl:element name="milestone">
            <xsl:variable name="numbers" select="tei:p/text()[matches(.,'(\d+)')]"/>
            <xsl:attribute name="n">
                <xsl:value-of select="translate($numbers,'§.? [\.:\&#xA;]?','')"/>
            </xsl:attribute>
            <xsl:attribute name="resp" select="'#CR #auto'"/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:variable name="id" select="@xml:id[1]"/>
            <xsl:attribute name="xml:id" select="translate($id,'nm','ml')"/> 
        </xsl:element>
        <xsl:copy>
            <xsl:copy-of select="@* except @n"/>
            <xsl:apply-templates mode="Digit2"/>
        </xsl:copy>
    </xsl:template>
    
<!-- 3. Deleting the 1st line with only digits from note(s). mode="deleteLB"-->
    <xsl:variable name="deleteLB">
        <xsl:apply-templates select="$Digit2" mode="deleteLB"/>
    </xsl:variable>
    
    <xsl:template match="@* except @part|node()" mode="deleteLB">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="deleteLB"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:lb[1][ancestor::tei:note[tei:p[text()[matches(.,'§.? \d+[\.:]?')]]]]" mode="deleteLB"/>
    <xsl:template match="//text()[matches(.,'§.? \d+[\.:]?')][1][ancestor::tei:note]" mode="deleteLB"/>
        
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$deleteLB"/>
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
            <xsl:message terminate="no"/>
        </xsl:if>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    

</xsl:stylesheet>