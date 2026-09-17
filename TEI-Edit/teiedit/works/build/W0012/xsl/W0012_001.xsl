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
    <xsl:param name="editingDate" as="xs:string" select="'2025-10-07'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0012_change_016'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged milestone(s).'"/>
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
 
   
    <xsl:template match="@* except @part|node()">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()"/>
        </xsl:copy>
    </xsl:template>
    

    <xsl:template match="tei:body//tei:milestone">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:if test="not(@xml:id)">
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            </xsl:if>
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
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb[not(ancestor::tei:note)])"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb[not(ancestor::tei:note)])"/>
        <xsl:variable name="inMilestone" as="xs:integer" select="count(//tei:body//tei:milestone)"/>
        <xsl:variable name="outMilestone" as="xs:integer" select="count($out//tei:body//tei:milestone)"/>
        <xsl:variable name="autoMilestone" as="xs:integer" select="count($out//tei:body//tei:milestone[@resp eq '#auto'])"/>
        <xsl:variable name="inNote" as="xs:integer" select="count(//tei:body//tei:note)"/>
        <xsl:variable name="outNote" as="xs:integer" select="count($out//tei:body//tei:note)"/>
        
        
        <!-- Added milestone(s)-->
        
        <xsl:if test="$inMilestone ne $outMilestone">
            <xsl:message select="'INFO: Milestone added: '"/>
            <xsl:message select="concat('Manual Milestone(s): ',$inMilestone)"/>
            <xsl:message select="concat('#auto Milestone(s): ',$autoMilestone)"/>            
            <xsl:message select="concat('Total milestone(s): ',$outMilestone)"/>
            <xsl:message terminate="no"/>
        </xsl:if>

        <!-- Transformed note(s) in milestones -->
        
        <xsl:if test="$inNote ne $outNote">
            <xsl:message select="'INFO: Note(s): '"/>
            <xsl:message select="concat('In Note(s): ',$inNote)"/>
            <xsl:message select="concat('Out Note(s): ',$outNote)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        
        <!-- Deleted digits in notes.-->

        <xsl:variable name="deletedDigitNote" as="xs:integer" select="count(//tei:body//tei:note[@rend eq 'deleteDigit']//text()[1][matches(.,normalize-space('^\d{1,3}\.?\s?'))])"/>
        <xsl:variable name="OutDeletedDigitNote" as="xs:integer" select="count($out//tei:body//tei:note[@rend eq 'deleteDigit']//text()[1][matches(.,normalize-space('^\d{1,3}\.?\s?'))])"/>
        <xsl:if test="$deletedDigitNote ne $OutDeletedDigitNote">
            <xsl:message select="'INFO: deleted digits in note(s): '"/>
            <xsl:message select="concat('In deleted digits in note(s): ', $deletedDigitNote)"/>
            <xsl:message select="concat('Out deleted digits in note(s): ', $OutDeletedDigitNote)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        
        <!--Deleted lb in notes-->

        <xsl:variable name="inNoteLb" as="xs:integer" select="count(//tei:lb[ancestor::tei:note])"/>
        <xsl:variable name="outNoteLb" as="xs:integer" select="count($out//tei:lb[ancestor::tei:note])"/>

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
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb, ' | NoteLb: ', $inNoteLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb,' | NoteLb: ', $outNoteLb)"/>
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