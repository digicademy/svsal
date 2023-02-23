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
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string" select="'Wxxxx_change_xx'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Annotate Hyphenation'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="breakLB">
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
            <xsl:apply-templates mode="breakLB"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    <!--Changed lb @type to lb @break-->
    
    <xsl:variable name="breakLB">
        <xsl:apply-templates select="/" mode="breakLB"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="breakLB">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="breakLB"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb[@type eq 'nb']" mode="breakLB">
        <xsl:copy>
            <xsl:variable name="string" select="preceding::text()[1]"/>
            <xsl:copy-of select="@* except @type"/>
            <xsl:choose>
                <xsl:when test="matches($string,'[-=]$')">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#hyphen'"/>
                </xsl:when>
                <xsl:when test="not(matches($string,'[-=]$'))">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[matches(.,'[-=]\n?$') and following-sibling::node()[1][(self::tei:pb or self::tei:cb or self::tei:lb or self::tei:note or self::tei:milestone)]]" mode="breakLB">
        <xsl:choose>
            <xsl:when test="matches(.,'[-=]\n$')">
                <xsl:value-of select="substring(., 1, string-length(.)-2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(., 1, string-length(.)-1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    <!--    1. Added @break and @rendition to pb depending on cb and/or lb [@break]
            2. Added @break and/or @rendition to cb depending on lb[@break]
            3. Delete @rendition from lb, in case of preceding pb or cb with @rendition. -->
    
    <xsl:variable name="breakPB_CB">
        <xsl:apply-templates select="$breakLB" mode="breakPB_CB"/>
    </xsl:variable>
    
    <xsl:template match="@*|node()" mode="breakPB_CB">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="breakPB_CB"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:pb" mode="breakPB_CB">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="following-sibling::*[1]/self::tei:cb and following-sibling::*[2]/self::tei:lb[@rendition eq '#hyphen']">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#hyphen'"/>
                </xsl:when>
                <xsl:when test="following-sibling::*[1]/self::tei:cb and following-sibling::*[2]/self::tei:lb[@rendition='#noHyphen']">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                </xsl:when>
                <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition eq '#hyphen']">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#hyphen'"/>
                </xsl:when>
                <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#noHyphen']">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:cb" mode="breakPB_CB">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="not(preceding-sibling::*[1]/self::tei:pb)">
                    <xsl:choose>
                        <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#hyphen']">
                            <xsl:attribute name="break" select="'no'"/>
                            <xsl:attribute name="rendition" select="'#hyphen'"/>
                        </xsl:when>
                        <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#noHyphen']">
                            <xsl:attribute name="break" select="'no'"/>
                            <xsl:attribute name="rendition" select="'#noHyphen'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="preceding-sibling::*[1]/self::tei:pb">
                    <xsl:choose>
                        <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#hyphen']">
                            <xsl:attribute name="break" select="'no'"/>
                        </xsl:when>
                        <xsl:when test="following-sibling::*[1]/self::tei:lb[@rendition='#noHyphen']">
                            <xsl:attribute name="break" select="'no'"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb[@rendition]" mode="breakPB_CB">
        <xsl:copy>
            <xsl:copy-of select="@* except (@rendition, @break)"/>
            <xsl:choose>
                <xsl:when test="preceding-sibling::*[1]/self::tei:pb">
                    <xsl:attribute name="break" select="'no'"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::*[1]/self::tei:cb">
                    <xsl:attribute name="break" select="'no'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="(@rendition, @break)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
   
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    <!--Check: Delete \n preceding pb, cb or lb @break='no' -->
       
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$breakPB_CB"/>
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
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- chars -->
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'ERROR: amount of non-whitespace characters differs in input and output doc: '"/>
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