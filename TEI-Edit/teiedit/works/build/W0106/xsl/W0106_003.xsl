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
    <xsl:param name="editingDate" as="xs:string" select="'2019-11-21'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0106_change_009'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged label(s).'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="digit">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&#xa;                </xsl:text>
            <xsl:element name="change">
                <xsl:attribute name="who" select="$editors"/>
                <xsl:attribute name="when" select="$editingDate"/>
                <xsl:attribute name="status" select="ancestor::tei:revisionDesc[1]/@status" />
                <xsl:attribute name="xml:id" select="$changeId"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:value-of select="$editingDesc"/>
            </xsl:element>
            <xsl:apply-templates mode="digit"/>
        </xsl:copy>
    </xsl:template>


<!-- 1. note(s) starting with digits (2269 cases)--> 
    
    <xsl:variable name="Digit">
         <xsl:apply-templates select="/" mode="Digit"/>
    </xsl:variable>
    
    <!-- identity transform mode="Digit"-->
    
    <xsl:template match="@* except @part|node()" mode="Digit">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="Digit"/>
        </xsl:copy>
    </xsl:template>

         
    <xsl:template match="tei:text//tei:note[matches(.,'^\d{1,3}')]" mode="Digit">
        <xsl:variable name="numbers" select="text()[1][matches(.,'^\d{1,3}')]"/>
        <xsl:element name="label">
            <xsl:attribute name="n" select="$numbers"/>
            <xsl:attribute name="resp" select="'#auto'"/>
            <xsl:attribute name="rend" select="'deleteDigit'"/>
            <xsl:attribute name="type" select="'margin'"/>
            <xsl:attribute name="xml:id" select="translate(current()/@xml:id,'nm','lm')"/>
            <xsl:apply-templates mode="Digit"/>
        </xsl:element>
    </xsl:template>

<!-- 2. delete digits from note(s)  -->
<!-- identity transform mode="deleteDigit"-->

    <xsl:variable name="deleteDigit">
         <xsl:apply-templates select="$Digit" mode="deleteDigit"/>
    </xsl:variable>
    
    <xsl:template match="@* except @part|node()" mode="deleteDigit">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="deleteDigit"/>
        </xsl:copy>
    </xsl:template>

         
    <xsl:template match="tei:label[@rend eq 'deleteDigit']/text()[1][matches(.,normalize-space('^\d{1,3}'))]" mode="deleteDigit">
        <xsl:value-of select="replace(.,normalize-space('^\d{1,3}'),'')"/>
    </xsl:template>

<!-- 3. Delete empty <lb/> in label(s) -->
    <xsl:variable name="deleteLB">
         <xsl:apply-templates select="$deleteDigit" mode="deleteLB"/>
    </xsl:variable>

    <xsl:template match="@* except @part|node()" mode="deleteLB">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="deleteLB"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:lb[parent::tei:label[@type eq 'margin'] and preceding-sibling::node()[1]/self::tei:lb]" mode="deleteLB"/>
        
    <xsl:template match="tei:label[@rend eq 'deleteDigit']" mode="deleteLB">
        <xsl:copy>
         <xsl:copy-of select="@* except @rend"/>
            <xsl:apply-templates mode="deleteLB"/>
        </xsl:copy>
    </xsl:template>
    
    
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
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb[not(ancestor::tei:note)])"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb[not(ancestor::tei:note)])"/>
        <xsl:variable name="inLabel" as="xs:integer" select="count(//tei:body//tei:label[@type eq 'marginalia' or 'margin'])"/>
        <xsl:variable name="outLabel" as="xs:integer" select="count($out//tei:body//tei:label[@type eq 'marginalia' or 'margin'])"/>
        <xsl:variable name="autoLabel" as="xs:integer" select="count($out//tei:body//tei:label[@resp eq '#auto'])"/>
        <xsl:variable name="inNote" as="xs:integer" select="count(//tei:body//tei:note)"/>
        <xsl:variable name="outNote" as="xs:integer" select="count($out//tei:body//tei:note)"/>
        
        
        <!-- Added label(s)-->
        
        <xsl:if test="$inLabel ne $outLabel">
            <xsl:message select="'INFO: Label added: '"/>
            <xsl:message select="concat('Manual Label(s): ',$inLabel)"/>
            <xsl:message select="concat('#auto Label(s): ',$autoLabel)"/> 
            <xsl:message terminate="no"/>
        </xsl:if>

        <!-- Transformed note(s) in label -->
        
        <xsl:if test="$inNote ne $outNote">
            <xsl:message select="'INFO: Note(s): '"/>
            <xsl:message select="concat('In Note(s): ',$inNote)"/>
            <xsl:message select="concat('Out Note(s): ',$outNote)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        
        <!-- Deleted digits in notes.-->

        <xsl:variable name="deletedDigitLabel" as="xs:integer" select="count(//tei:body//tei:label[@rend eq 'deleteDigit']//text()[1][matches(.,'^\d{1,3}')])"/>
        <xsl:variable name="OutDeletedDigitLabel" as="xs:integer" select="count($out//tei:body//tei:label[@rend eq 'deleteDigit']//text()[1][matches(.,'^\d{1,3}')])"/>
        <xsl:if test="$deletedDigitLabel ne $OutDeletedDigitLabel">
            <xsl:message select="'INFO: deleted digits in note(s): '"/>
            <xsl:message select="concat('In deleted digits in label(s): ', $deletedDigitLabel)"/>
            <xsl:message select="concat('Out deleted digits in label(s): ', $OutDeletedDigitLabel)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        
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
        <!--Deleted lb in notes and label-->
        <xsl:variable name="inNoteLb" as="xs:integer" select="count(//tei:lb[ancestor::tei:note])"/>
        <xsl:variable name="inLabelLb" as="xs:integer" select="count(//tei:lb[ancestor::tei:label[@type eq 'margin']])"/>
        <xsl:variable name="outLabelLb" as="xs:integer" select="count($out//tei:lb[ancestor::tei:label[@type eq 'margin']])"/>
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
            <xsl:message select="'INFO: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb, ' | labelLb: ', $inLabelLb,' | NoteLb: ', $inNoteLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb,' | labelLb: ', $outLabelLb)"/>
            <xsl:message terminate="no"/>
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