<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE v9.6.0.7+ -->
        
    <xsl:output method="xml"/> 
    
    <!-- please note: it is essential for this program to run correctly that the order of mutually occurring 
         break elements (pb, cb, lb) is correct.-->
    
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-22'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Annotated hyphenated breaks.'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0007_change_0013'"/>
    
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:message select="concat('Annotated ', string($hyphenatingPb), ' pb elements as break=no and rendition=#hyphen.')"/>
        <xsl:message select="concat('Annotated ', string($hyphenatingCb), ' cb elements as break=no and rendition=#hyphen.')"/>
        <xsl:message select="concat('Annotated ', string($breakingCb), ' cb elements as break=no.')"/>
        <xsl:message select="concat('Annotated ', string($hyphenatingLb), ' lb elements as break=no and rendition=#hyphen.')"/>
        <xsl:message select="concat('Annotated ', string($breakingLb), ' lb elements as break=no.')"/>
        <xsl:message select="concat('Removed ', string($removedHyphens), ' hyphens (and, potentially, newlines) from line endings.')"/>
        <xsl:message select="concat('Removed ', string($removedNewlines), ' text nodes containing only newlines.')"/>
        <xsl:choose>
            <xsl:when test="not(($hyphenatingPb + $hyphenatingCb + $hyphenatingLb) eq $removedHyphens)">
                <xsl:message terminate="yes">Error: the number of break elements marked as hyphenating is not equal to the number of resolved hyphens!</xsl:message>
            </xsl:when>
            <xsl:when test="not($breakingLb eq ($hyphenatingPb + $hyphenatingCb))">
                <xsl:message terminate="yes">Error: the number of lb elements marked (only) as break="no" does not align with the total number of 
                    hyphenating pb and cb elements.</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'All good: successfully resolved hyphenations.'"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>
    
    
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
    
       
    <!-- Annotate line breaks within words. -->
    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="local:isHyphenation(.)">
                <xsl:attribute name="break" select="'no'"/>
                <xsl:attribute name="rendition" select="'#hyphen'"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:cb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="local:isHyphenation(.)">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#hyphen'"/>
                </xsl:when>
                <xsl:when test="local:isBreakOnly(.)">
                    <xsl:attribute name="break" select="'no'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:lb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="local:isHyphenation(.)">
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="'#hyphen'"/>
                </xsl:when>
                <xsl:when test="local:isBreakOnly(.)">
                    <xsl:attribute name="break" select="'no'"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy> 
    </xsl:template>
    <xsl:template match="tei:text//text()" priority="2">
        <xsl:choose>
            <!-- if text node is merely a line break between two elements that represent a break within a word, remove it: -->
            <xsl:when test="matches(., '\n') and (normalize-space(.) eq '') and local:isInterferingWhitespace(.)"/>
            <!-- otherwise, process the text node... -->
            <xsl:when test="matches(., '[-=]')">
                <xsl:copy-of select="local:removeHyphen(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Checks if break element (pb, cb, lb) marks a hyphenation. -->
    <xsl:function name="local:isHyphenation" as="xs:boolean">
        <xsl:param name="elem" as="node()"/>
        <xsl:if test="not($elem[self::tei:pb or self::tei:cb or self::tei:lb])">
            <xsl:message terminate="yes" select="'Error: invalid element passed to function local:isHyphenation().'"/>
        </xsl:if>
        <xsl:choose>
            <!-- cb preceded by pb can never be a hyphenating element -->
            <xsl:when test="$elem[self::tei:cb and preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:pb]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <!-- lb preceded by cb or lb can never be a hyphenating element -->
            <xsl:when test="$elem[self::tei:lb and (preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:pb 
                                                    or preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:cb)]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <!-- 1.) "normal" case: break element preceded by text node ending with hyphen (possibly followed by \n) -->
            <xsl:when test="$elem[preceding-sibling::node()[1]/self::text() and matches(preceding-sibling::node()[1], '[-=]\n?$')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <!-- 2.) tei:note element between break and preceding text node -->
            <xsl:when test="$elem[preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:note]">
                <xsl:variable name="precedingNote" select="$elem/preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]"/>
                <xsl:choose>
                    <xsl:when test="$precedingNote/preceding-sibling::node()[1]/self::text()[matches(., '[-=]\n?$')]">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- 3.) hyphen-ending text occurs within tei:hi (the latter being followed by the break element) -->
            <xsl:when test="$elem[preceding-sibling::*[1]/self::tei:hi and matches(preceding-sibling::*[1]/text()[last()], '[-=]$')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <!-- return false by default -->
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- Checks if subsequent break element (cb, lb) occurs within a hyphenation (marked by the previous break element: pb or cb) and thus 
    shall be annotated as break="no" (but not rendition="#hyphen") -->
    <xsl:function name="local:isBreakOnly" as="xs:boolean">
        <xsl:param name="elem" as="node()"/>
        <xsl:if test="not($elem[self::tei:cb or self::tei:lb])">
            <xsl:message terminate="yes" select="'Error: invalid element used for local:isBreakOnly().'"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$elem[self::tei:cb and preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:pb
                                  and local:isHyphenation(preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1])]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$elem/self::tei:lb">
                <xsl:variable name="precedingNode" select="$elem/preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]"/>
                <xsl:choose>
                    <xsl:when test="$precedingNode/self::tei:cb">
                        <xsl:value-of select="local:isHyphenation($precedingNode) or local:isBreakOnly($precedingNode)"/>
                    </xsl:when>
                    <xsl:when test="$precedingNode/self::tei:pb">
                        <xsl:value-of select="local:isHyphenation($precedingNode)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Removes hyphens at the end of lines.
         The three cases herein need to match exactly the respective cases in local:isHyphenation -->
    <xsl:function name="local:removeHyphen">
        <xsl:param name="textNode" as="text()"/>
            <xsl:choose>
                <!-- 1.) "normal" case: text nodes ending with hyphen (possibly followed by \n), directly before a break element -->
                <xsl:when test="matches($textNode, '[-=]\n?$') 
                                and $textNode/following-sibling::node()[1][(self::tei:pb or self::tei:cb or self::tei:lb) and local:isHyphenation(.)]">
                    <xsl:value-of select="replace($textNode, '[-=]\n?$', '')"/>
                </xsl:when>
                <!-- 2.) note element between text node and breaking element -->
                <xsl:when test="matches($textNode, '[-=]\n?$') 
                                and $textNode/following-sibling::node()[1]/self::tei:note
                                and $textNode/following-sibling::node()[1]/following-sibling::node()[not(self::text() and normalize-space() eq '')][1][(self::tei:pb or self::tei:cb or self::tei:lb)
                                                                                           and local:isHyphenation(.)]">
                    <xsl:value-of select="replace($textNode, '[-=]\n?$', '')"/>
                </xsl:when>
                <!-- 3.) hyphens at the end of a line wrapped in hi (if there are further such 'wrap' elements, they can be included here): -->
                <xsl:when test="matches($textNode, '[-=]$') 
                                and $textNode/ancestor::*[1]/self::tei:hi 
                                and ($textNode/position() eq $textNode/ancestor::*[1]//text()[last()]/position())
                                and $textNode/ancestor::*[1]/following-sibling::node()[not(self::text() and normalize-space() eq '')][1]
                                                                                      [(self::tei:pb or self::tei:cb or self::tei:lb) and local:isHyphenation(.)]">
                    <xsl:value-of select="replace($textNode, '[-=]$', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$textNode"/>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function>
    
    <!-- Checks whether a whitespace-only text node occurring between two elements is interfering with a hyphenation 
        (i.e., producing inacceptable whitespace within a word)-->
    <xsl:function name="local:isInterferingWhitespace" as="xs:boolean">
        <xsl:param name="textNode" as="text()"/>
        <xsl:if test="normalize-space($textNode) ne ''">
            <xsl:message terminate="yes" select="'Error: text node parameter for function local:isInterferingWhitespace() does not only contain whitespace.'"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$textNode[following-sibling::node()[1][(self::tei:pb or self::tei:cb or self::tei:lb)]
                            and preceding-sibling::*[1]/self::tei:hi and matches(preceding-sibling::*[1]/text()[last()], '[-=]$')]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Finally, calculate the numbers of processed instances for comparison and for the record: -->
    <xsl:variable name="removedHyphens" select="count(//tei:text//text()[matches(., '[-=]') and . ne local:removeHyphen(.)])"/>
    <xsl:variable name="removedNewlines" select="count(//tei:text//text()[matches(., '\n') and (normalize-space(.) eq '') and local:isInterferingWhitespace(.)])"/>
    <xsl:variable name="hyphenatingPb" select="count(//tei:pb[local:isHyphenation(.)])"/>
    <xsl:variable name="hyphenatingCb" select="count(//tei:cb[local:isHyphenation(.)])"/>
    <xsl:variable name="breakingCb" select="count(//tei:cb[local:isBreakOnly(.)])"/>
    <xsl:variable name="hyphenatingLb" select="count(//tei:lb[local:isHyphenation(.)])"/>
    <xsl:variable name="breakingLb" select="count(//tei:lb[local:isBreakOnly(.)])"/>
      
    
    <!-- 
        even if this runs smoothly, check if there are hyphens and/or equation signs left in the output
    -->

    
</xsl:stylesheet>