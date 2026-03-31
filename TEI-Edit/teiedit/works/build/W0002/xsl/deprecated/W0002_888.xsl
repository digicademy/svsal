<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!-- Please note: this stylesheet should only be applied *after* corrections (otherwise, original text would be inserted into div/@n). 
         Also, for logging purposes, it relies on div/@xml:id (which therefore should be available). -->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- state the number of tokens that div/@n may maximally contain -->
    <xsl:param name="tokenLimit" as="xs:integer" select="7"/>
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'...'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_xxx'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added div/@n for div[not(child::head)].'"/>
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
    
    <!-- if a div does not contain a heading on the child axis, we take the first few words, concatenated with a '...' as a default "label" -->
    <xsl:template match="tei:div[not(child::tei:head or @n)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- TODO: there are still @n with "..." -->
            <xsl:choose>
                <!-- we require a child::p for automatic resolving of div/@n, taking the first tokens of p as value for div/@n -->
                <xsl:when test="child::tei:p">
                    <xsl:variable name="n" as="xs:string" select="local:makeDivTeaserFromText(child::tei:p[1])"/>
                    <xsl:attribute name="n" select="$n"/>
                    <xsl:message select="concat('div ', @xml:id, ': created @n using child::p : ', $n)"/>
                </xsl:when>
                <!-- if there is no p that we can make use of, try to get a heading or a paragraph from the first sub div, if existing -->
                <xsl:when test="child::tei:div">
                    <xsl:choose>
                        <xsl:when test="child::tei:div[1]/tei:head">
                            <!-- is this quite kosher? it may lead to subsequent entries in the toc and/or headings in the left margin 
                                 with identical text contents -->
                            <xsl:variable name="n" as="xs:string" select="string-join(child::tei:div[1]/tei:head//text()[not(ancestor::tei:note or ancestor::tei:ref)], ' ')"/>
                            <xsl:attribute name="n" select="$n"/>
                            <xsl:message select="concat('div ', @xml:id, ': created @n using child::div/head : ', $n)"/>
                        </xsl:when>
                        <xsl:when test="child::tei:div[1]/tei:p">
                            <xsl:variable name="n" as="xs:string" select="local:makeDivTeaserFromText(child::tei:div[1]/tei:p[1])"/>
                            <xsl:attribute name="n" select="$n"/>
                            <xsl:message select="concat('div ', @xml:id, ': created @n using child::div/p : ', $n)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="'Error: could not find a resource in child::div for the creation of div/@n.'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'Error: could not find a resource for the creation of div/@n.'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- function to extract the first tokens from the text content (nodes) of a given node, to be used as a teaser in div/@n -->
    <xsl:function name="local:makeDivTeaserFromText" as="xs:string">
        <xsl:param name="targetNode" as="node()"/>
        <xsl:if test="not($targetNode)">
            <xsl:message terminate="yes" select="'Error: targetNode does not exist.'"/>
        </xsl:if>
        <!-- TODO: insert blank for lb/cb/pb? -->
        <xsl:variable name="pTextNodes" as="xs:string*" select="$targetNode//text()[not((matches(., '\n') and normalize-space(.) eq '') 
                                                                                        or ancestor::tei:ref 
                                                                                        or ancestor::tei:note
                                                                                        or (ancestor::tei:choice and ancestor::*[1][self::tei:sic or self::tei:abbr or self::tei:orig])
                                                                                    )]"/>
        <!-- TODO: this still keeps &#xA; entities, although they should be deleted via translate(): -->
        <xsl:variable name="pString" as="xs:string" select="normalize-space(translate(string-join($pTextNodes, ''), '&#xA;', ''))"/>
        <!-- assuming that dots are only used as sentence boundaries (which may be a problem with dots as abbreviation markers...): -->
        <xsl:variable name="firstSentence" as="xs:string" select="substring-before($pString, '.')"/>
        <xsl:variable name="teaser" as="xs:string">
            <xsl:choose>
                <xsl:when test="count(tokenize($firstSentence, ' ')) gt $tokenLimit">
                    <xsl:value-of select="concat(string-join(tokenize($firstSentence, ' ')[position() le $tokenLimit], ' '), '...')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$firstSentence"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not($teaser)">
            <xsl:message terminate="yes" select="'Error: could not find a teaser for div/@n'"/>
        </xsl:if>
        <xsl:value-of select="$teaser"/>

    </xsl:function>


</xsl:stylesheet>