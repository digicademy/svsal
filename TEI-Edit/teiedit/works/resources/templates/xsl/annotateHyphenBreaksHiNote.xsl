<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #EE #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string" select="'WXXXX_VolXX_change_XXX'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Annotated hyphenated breaks interrupted by hi and note.'"/>

<!--    
        * This is a template to be used with texts from TAO-Trier. 
        * It solves the hyphenation breaks among lb @break, milestone, hi and/or note. 
        * To be used after "annotateHyphenBreaks"-->

    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="round1">
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
            <xsl:apply-templates mode="round1"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:variable name="round1">
        <xsl:apply-templates select="/" mode="round1"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="round1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round1"/>
        </xsl:copy>
    </xsl:template>
    
    <!--hi and note interfering -->
          
    <xsl:template match="tei:lb[local:hyphens(.)]" mode="round1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="break" select="'no'"/>
            <xsl:attribute name="rendition" select="'#hyphen'"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="local:hyphens" as="xs:boolean">
        <xsl:param name="lb" as="element(tei:lb)"/>
        <xsl:value-of select="not($lb/ancestor::tei:note) and $lb/preceding-sibling::*[1]/self::tei:note and $lb/preceding-sibling::*[2]/self::tei:hi[matches((.//text())[last()],'-$')]"/>
    </xsl:function>
    
    <xsl:template match="text()[matches(.,'-\s*$') and ./parent::tei:hi/following-sibling::*[1]/self::tei:note and ./parent::tei:hi/following-sibling::*[2]/self::tei:lb[local:hyphens(.)]]" mode="round1">
        <xsl:value-of select="replace(.,'-\s*$','')"/>
    </xsl:template>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    <!-- Deleted \n between note, lb@break, pb, cb
         +Corrected pb, cb @break according to following lb@break-->
    <xsl:variable name="round2">
        <xsl:apply-templates select="$round1" mode="round2"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="round2">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="round2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[normalize-space() eq '' and following-sibling::node()[1]/self::tei:lb[@break='no']]" mode="round2"/>
    
    <xsl:template match="tei:pb[not(@break)]" mode="round2">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:if test="./following-sibling::*[2]/self::tei:lb[@break eq 'no']">
            <xsl:attribute name="break" select="'no'"/>
            <xsl:attribute name="rendition" select="'#hyphen'"/>
        </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:cb[not(@break)]" mode="round2">
        <xsl:copy>
        <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="not(preceding-sibling::*[1]/self::tei:pb)">
                    <xsl:choose>
                        <xsl:when test="following-sibling::*[1]/self::tei:lb[@break='no']">
                            <xsl:attribute name="break" select="'no'"/>
                            <xsl:attribute name="rendition" select="'#hyphen'"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="preceding-sibling::*[1]/self::tei:pb">
                    <xsl:choose>
                        <xsl:when test="following-sibling::*[1]/self::tei:lb[@break eq 'no']">
                            <xsl:attribute name="break" select="'no'"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>
    </xsl:template> 
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$round2"/>
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
        
        <xsl:variable name="hyphens" select="count(//tei:lb[local:hyphens(.)])"/>
        <xsl:message select="concat('lb nach note und hi ',$hyphens)"></xsl:message>
        
        <xsl:variable name="geloscht" select="count(//text()[matches(.,'-\s*$') and ./parent::tei:hi/following-sibling::*[1]/self::tei:note and ./parent::tei:hi/following-sibling::*[2]/self::tei:lb[local:hyphens(.)]])"/>
        <xsl:message select="concat('deletedlB ', $geloscht)"></xsl:message>
        
        <!-- whitespace and regular symbols -->
        <xsl:if test="$inWhitespace ne $outWhitespace or $inChars ne $outChars">
            <xsl:message select="'ERROR: Numbers of non-whitespace or whitespace characters differ in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="no"/>
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