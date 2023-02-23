<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Corrects order of break elements' attributes (pb|cb|lb)/(@rendition|@break) and removes illegal whitespace before (pb|cb|lb)[@break eq 'no'] -->
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string" select="'Wxxxx_change_yyy'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Fixed order of break attributes (@rendition and @break) and removed whitespace before non-breaking elements.'"/>
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
    

    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="local:isPrimaryNonBreaking(.)">
                <xsl:attribute name="break" select="'no'"/>
                <xsl:attribute name="rendition" select="local:isPrimaryNonBreaking(.)"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:cb|tei:lb">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="local:isPrimaryNonBreaking(.)">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="local:isPrimaryNonBreaking(.)"/>
                </xsl:when>
                <xsl:when test="local:isSecondaryNonBreaking(.)">
                    <xsl:copy-of select="@* except @rendition"/>
                    <xsl:attribute name="break" select="'no'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@break[. ne 'yes'] or @rendition">
                        <!-- if none of the above is the case, the element shouldn't have @rendition or @break in the first place -->
                        <xsl:message terminate="yes" select="concat('ERROR: encountered unexpected @break or @rendition in element ', @xml:id)"/>
                    </xsl:if>
                    <xsl:copy-of select="@*"/> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
     
    <!-- remove unwanted whitespace immediately before break element -->
    <xsl:template match="tei:text//text()[not(ancestor::*[@place eq 'margin']) 
                                          and following-sibling::*[not(ancestor::*[@place eq 'margin'])][1][(self::tei:pb or self::tei:cb or self::tei:lb) 
                                                                                                             and (local:isPrimaryNonBreaking(.) or local:isSecondaryNonBreaking(.))]
                                          and matches(., '\s+$')]">
        <!-- through applying this to secondary no-breaks as well, this should also delete illegal whitespace in-between two no-breaks -->
        <xsl:value-of select="replace(., '\s+$', '')"/>
    </xsl:template>
    <xsl:template match="tei:text//text()[ancestor::*[@place eq 'margin'] 
                                          and following-sibling::*[ancestor::*[@place eq 'margin']][1][(self::tei:pb or self::tei:cb or self::tei:lb) 
                                                                                                        and (local:isPrimaryNonBreaking(.) or local:isSecondaryNonBreaking(.))]
                                          and matches(., '\s+$')]">
        <!-- through applying this to secondary no-breaks as well, this should also delete illegal whitespace in-between two no-breaks -->
        <xsl:value-of select="replace(., '\s+$', '')"/>
    </xsl:template>
    
    
    <!-- Determines whether a break element is the first (or only) non-breaking element at a given breaking point in the text (line, column, page break). 
         Returns the type of no-break as a string (i.e., the value of @rendition - #noHyphen or #hyphen) in case the element is a first no-break, or 
         the empty sequence in case it is not. -->
    <xsl:function name="local:isPrimaryNonBreaking" as="xs:string?">
        <xsl:param name="node"/>
        <xsl:choose>
            <!-- pb -->
            <xsl:when test="$node/self::tei:pb">
                <xsl:choose>
                    <xsl:when test="$node/@break eq 'no' and $node/@rendition = ('#hyphen', '#noHyphen')">
                        <xsl:value-of select="$node/@rendition"/>
                    </xsl:when>
                    <xsl:when test="$node/following-sibling::*[1]/self::tei:lb[@break eq 'no' and @rendition = ('#hyphen', '#noHyphen')]">
                        <xsl:value-of select="$node/following-sibling::*[1]/self::tei:lb/@rendition"/>
                    </xsl:when>
                    <xsl:when test="$node/following-sibling::*[1]/self::tei:cb and $node/following-sibling::*[2]/self::tei:lb[@break eq 'no' and @rendition = ('#hyphen', '#noHyphen')]">
                        <xsl:value-of select="$node/following-sibling::*[2]/self::tei:lb/@rendition"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- cb -->
            <xsl:when test="$node/self::tei:cb">
                <xsl:choose>
                    <xsl:when test="$node/@break eq 'no' and $node/@rendition = ('#hyphen', '#noHyphen')
                                    and not($node/preceding-sibling::*[1]/self::tei:pb)">
                        <xsl:value-of select="$node/@rendition"/>
                    </xsl:when>
                    <xsl:when test="$node/following-sibling::*[1]/self::tei:lb[@break eq 'no' and @rendition = ('#hyphen', '#noHyphen')]
                                    and not($node/preceding-sibling::*[1]/self::tei:pb)">
                        <xsl:value-of select="$node/following-sibling::*[1]/self::tei:lb/@rendition"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- lb -->
            <xsl:when test="$node/self::tei:lb">
                <xsl:choose>
                    <xsl:when test="$node/@break eq 'no' and $node/@rendition = ('#hyphen', '#noHyphen')
                                    and not($node/preceding-sibling::*[1][self::tei:pb or self::tei:cb])">
                        <xsl:value-of select="$node/@rendition"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:message terminate="yes" select="'ERROR: illegal input element for local:isPrimaryNonBreaking()'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Determines whether a break element is a subsequent non-breaking break element (true) or not (false) -->
    <xsl:function name="local:isSecondaryNonBreaking" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <!-- only cb and lb may be secondary no-breaks -->
            <xsl:when test="$node/self::tei:cb and $node/preceding-sibling::*[1]/self::tei:pb[local:isPrimaryNonBreaking(.)]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$node/self::tei:lb and ($node/preceding-sibling::*[1]/self::tei:pb[local:isPrimaryNonBreaking(.)]
                                                    or $node/preceding-sibling::*[1]/self::tei:cb[local:isPrimaryNonBreaking(.) or local:isSecondaryNonBreaking(.)])">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
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
        <!-- count breaks to be changed -->
        <xsl:variable name="primPb" as="xs:integer" select="count(//tei:pb[not(@break or @rendition) and local:isPrimaryNonBreaking(.)])"/>
        <xsl:variable name="primCb" as="xs:integer" select="count(//tei:cb[not(@break or @rendition) and local:isPrimaryNonBreaking(.)])"/>
        <xsl:variable name="secCbNoBreak" as="xs:integer" select="count(//tei:cb[not(@break) and local:isSecondaryNonBreaking(.)])"/>
        <xsl:variable name="secCbPrim" as="xs:integer" select="count(//tei:cb[@break eq 'no' and @rendition and local:isSecondaryNonBreaking(.)])"/>
        <xsl:variable name="primLb" as="xs:integer" select="count(//tei:lb[not(@break or @rendition) and local:isPrimaryNonBreaking(.)])"/>
        <xsl:variable name="secLbNoBreak" as="xs:integer" select="count(//tei:lb[not(@break) and local:isSecondaryNonBreaking(.)])"/>
        <xsl:variable name="secLbPrim" as="xs:integer" select="count(//tei:lb[@break eq 'no' and @rendition and local:isSecondaryNonBreaking(.)])"/>
        <xsl:variable name="modTextPrim" as="xs:integer" select="count(//tei:text//text()[following-sibling::node()[1][(self::tei:pb or self::tei:cb or self::tei:lb) and local:isPrimaryNonBreaking(.)] and matches(., '\s+$')])"/>
        <xsl:variable name="modTextSec" as="xs:integer" select="count(//tei:text//text()[following-sibling::node()[1][(self::tei:pb or self::tei:cb or self::tei:lb) and local:isSecondaryNonBreaking(.)] and matches(., '\s+$')])"/>
        <xsl:message select="concat('INFO: identified ', $primPb, ' *pb* as primary no-break that were not previously marked as such.')"/>
        <xsl:message select="concat('INFO: identified ', $primCb, ' *cb* as primary no-break that were not previously marked as such.')"/>
        <xsl:message select="concat('INFO: identified ', $secCbNoBreak, ' *cb* as secondary break that were not previously marked as no-break at all.')"/>
        <xsl:message select="concat('INFO: identified ', $secCbPrim, ' *cb* as secondary break that were previously marked as primary no-break.')"/>
        <xsl:message select="concat('INFO: identified ', $primLb, ' *lb* as primary no-break that were not previously marked as such.')"/>
        <xsl:message select="concat('INFO: identified ', $secLbNoBreak, ' *lb* as secondary break that were not previously marked as no-break at all.')"/>
        <xsl:message select="concat('INFO: identified ', $secLbPrim, ' *lb* as secondary break that were previously marked as primary no-break.')"/>
        <xsl:message select="concat('INFO: replaced trailing whitespace in ', $modTextPrim, ' text nodes before primary no-breaks.')"/>
        <xsl:message select="concat('INFO: replaced trailing whitespace in ', $modTextSec, ' text nodes before secondary no-breaks.')"/>
        <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
        <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
        <xsl:choose>
            <!-- whitespace and regular symbols -->
            <xsl:when test="$inChars ne $outChars">
                <xsl:message select="'ERROR: Numbers of non-whitespace characters differ in input and output doc: '"/>
                <xsl:message select="concat('Input characters: ', $inChars)"/>
                <xsl:message select="concat('Output characters: ', $outChars)"/>
                <xsl:message terminate="yes"/>
            </xsl:when>
            <!-- breaks -->
            <xsl:when test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
                <xsl:message select="'ERROR: different amount of input and output pb/cb/lb: '"/>
                <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
                <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
                <xsl:message terminate="yes"/>
            </xsl:when>
            <!-- special chars -->
            <xsl:when test="$inSpecialChars ne $outSpecialChars">
                <xsl:message select="'ERROR: different amount of input and output special chars: '"/>
                <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
                <xsl:message terminate="yes"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'---------------------------------------------------------'"/>
                <xsl:message select="'INFO: quality check successfull.'"></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

</xsl:stylesheet>