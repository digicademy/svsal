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
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-16'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0014_change_0014'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Automatically added cross-references in table of contents.'"/>
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

    <xsl:template match="tei:back/tei:div[@type eq 'contents']/tei:list//tei:item//text()">
        <xsl:variable name="ancestorList" select="ancestor::tei:list[1]"/>
        <xsl:analyze-string select="." regex="(nu?m?e?r?o?[\.,]? (\d{{1,3}})\.?)">
            <xsl:matching-substring>
                <xsl:variable name="divId" select="$ancestorList/preceding::tei:div[@type eq 'article' and translate(@n, '[]', '') eq regex-group(2) and xs:integer(translate(@n, '[]', '')) gt 17]/@xml:id"/>
                <xsl:if test="count($divId) gt 1">
                    <xsl:message terminate="yes" select="'Debug: found several matching div: ', string-join($divId, ', ')"/>
                </xsl:if>
                <xsl:choose>
                    <!-- numbers <= 17 are ambivalent, they are tagged manually -->
                    <xsl:when test="$divId and xs:integer(regex-group(2)) gt 17">
                        <xsl:element name="ref">
                            <xsl:attribute name="target" select="concat('#', $divId)"/>
                            <xsl:attribute name="resp" select="'#auto'"/>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:element>
                        <xsl:message select="concat('Info: created cross-reference for text node: ', regex-group(1))"></xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="concat('Warning: could not find a matching div for reference: ', regex-group(1))"/>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
    <!-- other topic: wrap note content in p elements -->
    <xsl:template match="tei:note[@place eq 'margin']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="not(descendant::tei:p)">
                    <xsl:element name="p">
                        <xsl:attribute name="xml:id" select="generate-id()"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>