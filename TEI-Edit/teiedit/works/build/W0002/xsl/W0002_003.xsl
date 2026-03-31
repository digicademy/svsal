<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <!-- This stylesheet takes a (Salamanca) TEI version of W0002 with unique identifiers (@xml:id) for structural units as input and attempts to align the references 
    given in the summaries for each (sub)chapter to their according reference point in the text by using <ref> and @target, thereby creating cross-references -->
    
    <xsl:output method="xml"/> 
    
    <!-- Identity transformation for everything that is not encountered further below -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO: ref/@xml:id ? -->
    
    <xsl:template match="//tei:text//tei:list[@type='summaries']//tei:item//text()">
        <xsl:variable name="ancestorDiv" select="ancestor::tei:div[1]"/>
        <xsl:analyze-string select="." regex="(\d+\.?)">
            <xsl:matching-substring>
                <xsl:variable name="refDigits" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="contains(regex-group(1), '.')">
                            <xsl:value-of select="substring-before(regex-group(1), '.')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="milestoneId" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$ancestorDiv//tei:milestone[(@rendition='#dagger' or not(@rendition)) and @n=$refDigits]">
                            <xsl:value-of select="$ancestorDiv//tei:milestone[(@rendition='#dagger' or not(@rendition)) and @n=$refDigits][1]/@xml:id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'noTargetFound'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="ref">
                    <xsl:attribute name="target" select="concat('#', $milestoneId)"/>
                    <xsl:attribute name="resp" select="'#AUTO'"/>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>