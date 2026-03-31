<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-22'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0007_change_0012'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Added cross-references in index.'"/>
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


    <xsl:template match="tei:back/tei:div[@type eq 'index']/tei:list//tei:item//text()[last()]">
        <xsl:variable name="ancestorList" select="ancestor::tei:list[1]"/>
        <xsl:analyze-string select="." regex="(\d\. ?\d{{1,2}}\. ?)((\d{{1,3}})\.?)( y\.? (\d{{1,3}}).)?">
            <xsl:matching-substring>
                <xsl:variable name="pageId" select="$ancestorList/preceding::tei:pb[matches(@n, concat('^fol. \[?', regex-group(3), '\]?r$'))]/@xml:id"/>
                <xsl:variable name="secondPageId" select="$ancestorList/preceding::tei:pb[matches(@n, concat('^fol. \[?', regex-group(5), '\]?r$'))]/@xml:id"/>
                <xsl:if test="count($pageId) gt 1">
                    <xsl:message terminate="yes" select="'Debug: found several matching pb: ', string-join($pageId, ', '), 'for text node: ', ."/>
                </xsl:if>
                <xsl:choose>
                    <!-- numbers <= 17 are ambivalent, they are tagged manually -->
                    <xsl:when test="$pageId">
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:element name="ref">
                            <xsl:attribute name="target" select="concat('#', $pageId)"/>
                            <xsl:attribute name="resp" select="'#auto'"/>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:element>
                        <xsl:if test="regex-group(4)">
                            <xsl:if test="not($secondPageId)"><xsl:message terminate="yes"/></xsl:if>
                            <xsl:element name="ref">
                                <xsl:attribute name="target" select="concat('#', $secondPageId)"/>
                                <xsl:attribute name="resp" select="'#auto'"/>
                                <xsl:value-of select="regex-group(4)"/>
                            </xsl:element>
                        </xsl:if>
                        <xsl:message select="concat('Info: created cross-reference for text node: ', .)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="concat('Warning: could not find a matching pb for text node: ', .)"/>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>