<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- WARNING: THIS XSLT ILLEGALY REMOVES TEXT AND NEEDS TO BE DEBUGGED -->
    <!-- due to many false positives the recognition of allegedly hyphenating wordforms (e.g., when the determiner "a" occurs as one part of such a wordform)
         originating from the current dictionaries, this program is (or better, the utilized dictionaries are) not ready for automatic tagging for unmarked hyphenations -->
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-11-08'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_021'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Tag unmarked hyphenations as break=no and rencition=#noHyphen.'"/>
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

    <xsl:variable name="hyphenatingLbIds" as="xs:string*" select="doc('../html/W0002_comp-hyph.html')//tr/td[7]/a/@id/string()"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:variable name="logLb" as="xs:integer" select="count(//tei:lb[local:isHyphenatingLb(.)])"/>
        <xsl:message select="concat('Tagged ', $logLb, ' lb (in total) as @break=no')"/>
        <xsl:variable name="logCb" as="xs:integer" select="count(//tei:cb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/
                                                                                                        self::tei:lb[local:isHyphenatingLb(.)]])"/>
        <xsl:message select="concat('Tagged ', $logCb, ' cb as @break=no')"/>
        <xsl:variable name="logPb" as="xs:integer" select="count(//tei:pb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/
                                                                                                        self::tei:lb[local:isHyphenatingLb(.)]
                                                                          or (following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:cb
                                                                              and following-sibling::node()[not(self::text() and normalize-space() eq '')][2]/self::tei:lb[local:isHyphenatingLb(.)])                              
                                                                         ])"/>
        <xsl:message select="concat('Tagged ', $logPb, ' pb as @break=no and @rendition=#noHyphen')"/>
        <xsl:message select="concat('Cut ', $cutWhitespace, ' instances of trailing whitespace.')"/>
        <!-- make sure that not more whitespace is being cut than there are instances of tagged unmarked hyphenations -->
        <xsl:if test="$cutWhitespace gt $logLb">
            <xsl:message terminate="yes" select="'Error: more whitespace is being cut than lb elements being marked as break=no.'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:lb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="local:isHyphenatingLb(.)">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:pb or preceding-sibling::node()[1]/self::tei:cb">
                        <xsl:choose>
                            <xsl:when test="@break eq 'no'">
                                <xsl:message select="concat('Not tagging ', @xml:id, ', which already is tagged as break=no.')"/>
                            </xsl:when>
                            <xsl:when test="@break">
                                <xsl:message terminate="yes" select="'Error: ', @xml:id, ' already has @break of different value.'"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="break" select="'no'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="@break eq 'no' and @rendition eq '#noHyphen'">
                                <xsl:message select="concat('Not tagging ', @xml:id, ', which already is tagged as break=no and rendition=#noHyphen.')"/>
                            </xsl:when>
                            <xsl:when test="@break or @rendition">
                                <xsl:message terminate="yes" select="'Error: ', @xml:id, ' already has @break and/or @rendition of different values.'"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="break" select="'no'"/>
                        <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:cb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]">
                <xsl:choose>
                    <xsl:when test="preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:pb">
                        <xsl:choose>
                            <xsl:when test="@break eq 'no'">
                                <xsl:message select="concat('Not tagging ', @xml:id, ', which already is tagged as break=no.')"/>
                            </xsl:when>
                            <xsl:when test="@break">
                                <xsl:message terminate="yes" select="'Error: ', @xml:id, ' already has @break of different value.'"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="break" select="'no'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="@break eq 'no' and @rendition eq '#noHyphen'">
                                <xsl:message select="concat('Not tagging ', @xml:id, ', which already is tagged as break=no and rendition=#noHyphen.')"/>
                            </xsl:when>
                            <xsl:when test="@break or @rendition">
                                <xsl:message terminate="yes" select="'Error: ', @xml:id, ' already has @break and/or @rendition of different values.'"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:attribute name="break" select="'no'"/>
                        <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]
                            or (following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:cb
                                and following-sibling::node()[not(self::text() and normalize-space() eq '')][2]/self::tei:lb[local:isHyphenatingLb(.)])">
                <xsl:choose>
                    <xsl:when test="@break eq 'no' and @rendition eq '#noHyphen'">
                        <xsl:message select="concat('Not tagging ', @xml:id, ', which already is tagged as break=no and rendition=#noHyphen.')"/>
                    </xsl:when>
                    <xsl:when test="@break or @rendition">
                        <xsl:message terminate="yes" select="'Error: ', @xml:id, ' already has @break and/or @rendition of different values.'"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="break" select="'no'"/>
                <xsl:attribute name="rendition" select="'#noHyphen'"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- finally, cut trailing whitespace if it is followed by a breaking lb, cb or pb -->
    <xsl:template match="tei:text//text()" priority="2">
        <xsl:choose>
            <xsl:when test="matches(., '\s$')">
                <xsl:choose>
                    <xsl:when test="following-sibling::*[1]/self::tei:lb[local:isHyphenatingLb(.)]
                                    or following-sibling::*[1]/self::tei:cb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]]
                                    or following-sibling::*[1]/self::tei:pb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]]
                                    or following-sibling::*[1]/self::tei:pb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:cb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]]]">
                        <xsl:message select="concat('Cutting trailing whitespace before ', following-sibling::tei:lb[1]/@xml:id, ': &quot;',
                                                    replace(., '^(.*?)(\s+)$', '$2')), '&quot;.'"/>
                        <xsl:value-of select="replace(., '^(.*?)(\s+)$', '$1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:variable name="cutWhitespace" as="xs:integer" 
        select="count(//tei:text//text()[matches(., '\s$')
                                         and
                                         (following-sibling::*[1]/self::tei:lb[local:isHyphenatingLb(.)]
                                          or following-sibling::*[1]/self::tei:cb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]]
                                          or following-sibling::*[1]/self::tei:pb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]]
                                          or following-sibling::*[1]/self::tei:pb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:cb[following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:lb[local:isHyphenatingLb(.)]]]
                                         )])"/>
    
    <xsl:function name="local:isHyphenatingLb" as="xs:boolean">
        <xsl:param name="lbNode" as="element(tei:lb)"/>
        <xsl:choose>
            <xsl:when test="$lbNode/@xml:id = $hyphenatingLbIds">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>