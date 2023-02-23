<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE v9.6.0.7+ -->
    
    <!-- NOTE: this stylesheet analyzes text nodes with regards to unicode characters above codepoint \u00FF. 
    If it finds such a character and the character is declared in the SvSal charDecl, it will be automatically tagged. 
    In case no suitable character is declared, the program thros an error and the character is either to be modified manually 
    in the text, or to be added to the charDecl. -->
    
    <!-- this program may be run before and/or after manual corrections -->
        
    <xsl:output method="xml"/> 
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2020-07-27'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged special characters after corrections.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0033_change_022'"/>
    <xsl:param name="specialCharFile" as="xs:string" select="'../../../resources/chars/specialchars_2020-04-30.xml'"/>
    
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&#xa;                </xsl:text>
            <xsl:element name="change">
                <xsl:attribute name="who" select="$editors"/>
                <xsl:attribute name="when" select="$editingDate"/>
                <xsl:attribute name="status" select="ancestor::tei:revisionDesc[1]/@status"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:attribute name="xml:id" select="$changeId"/>
                <xsl:value-of select="$editingDesc"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- load special characters from the Sonderzeichen.xml file and concat them (in length-descending order) into a long regular expression -->
    <xsl:variable name="specialCharacters" select="doc($specialCharFile)//tei:teiHeader//tei:charDecl//tei:char"/>
    <xsl:variable name="specialCharsSorted" as="xs:string*">
        <xsl:for-each select="$specialCharacters/tei:mapping[@type = ('precomposed', 'composed')]">
            <xsl:sort select="string-length(.)" order="descending"/>
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="specialCharsRegex"  as="xs:string" select="concat('(', string-join($specialCharsSorted, '|'), ')')"/>
    
        
    <!-- annotate all special chars declared in the charDecl with g tags; the "original" character is kept as the text content of the g tag -->
    <!-- warning: this template must not be applied before milestones have been tagged (otherwise, daggers etc. would 
         be tagged with g elements)-->
    <xsl:template match="tei:text//text()[not(ancestor::tei:g or ancestor::tei:foreign[@xml:lang=('gr', 'gre', 'grc', 'he')])]" priority="2">
        <xsl:if test="$specialCharsRegex = '()'"> <!-- check whether the characters have been loaded correctly -->
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:variable name="thisText" as="node()" select="."/>
        <xsl:choose>
            <!-- process only text nodes that a) are not empty and b) are not already annotated as special or "foreign" chars -->
            <xsl:when test="(normalize-space(.) != '')">
                <xsl:analyze-string select="." regex="{$specialCharsRegex}"> 
                    <xsl:matching-substring>
                        <xsl:variable name="specChar" as="xs:string" select="."/>
                        <xsl:variable name="specCharID" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$specialCharacters//tei:mapping[@type = ('precomposed', 'composed') and . = $specChar]">
                                    <xsl:value-of select="$specialCharacters//tei:mapping[@type = ('precomposed', 'composed') and . = $specChar]/ancestor::tei:char[1]/@xml:id"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message terminate="yes">Error: no valid character reference found.</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable> 
                        <xsl:element name="g">
                            <xsl:attribute name="ref" select="concat('#', $specCharID)"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <!-- check if there are any further special chars not (yet) declared in the charDecl -->
                        <xsl:if test="matches(., '[&#x0100;-&#x10ffff;]')">
                            <xsl:message terminate="yes" select="concat('Error: found undeclared special character in text node: ', $thisText)"/><!--, ' | after element with xml:id: ', $thisText/preceding::*[@xml:id]/@xml:id)-->
                        </xsl:if>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
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
        <xsl:message select="concat('INFO: added ', $outSpecialChars - $inSpecialChars, ' special character tags (tei:g).')"/>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    
    
</xsl:stylesheet>