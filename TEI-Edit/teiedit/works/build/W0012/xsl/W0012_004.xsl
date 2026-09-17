<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!--<xsl:param name="editors" as="xs:string" select="#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-10-10'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0012_change_019'"></xsl:param>
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
    
    <xsl:variable name="refs">
        <xsl:apply-templates select="/" mode="refs"/>
    </xsl:variable>

    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="refs">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="refs"/>
        </xsl:copy>
    </xsl:template>

<!--10 different Tables of contents in W0012-->
    
    <!-- Book1 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book1']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book1']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b1')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book2 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book2']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book2']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b2')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book3 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book3']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book3']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b3')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book4 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book4']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book4']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b4')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book5 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book5']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book5']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b5')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book6 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book6']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book6']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b6')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book7 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book7']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book7']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b7')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Book8 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book8']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book8']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b8')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>

    <!-- Book9 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book9']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book9']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b9')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>

    <!-- Book10 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <xsl:template match="tei:list[@type='contents' and ancestor::tei:div1[@xml:id eq 'book10']]//tei:ref" mode="refs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:ref[ancestor::tei:div1[@xml:id eq 'book10']])+1"/>
            <xsl:attribute name="target" select="concat('#c',$n,'b10')"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:apply-templates mode="refs"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$refs"/>
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