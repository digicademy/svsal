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
    <xsl:param name="editingDate" as="xs:string" select="'2018-01-14'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0010-change-015'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added pagination.'"/>
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


    <xsl:template match="tei:pb[not(ancestor::tei:note)]">
        <xsl:copy>
            <xsl:copy-of select="@* except @n"/>
            <xsl:variable name="n">
                <xsl:choose>
                <!-- Roman numbers in front matter -->
                <xsl:when test="ancestor::tei:front">
                    <xsl:variable name="currentPage" as="xs:string">
                        <xsl:number value="count(preceding::tei:pb[not(ancestor::tei:note)]) + 1" format="i"/>
                    </xsl:variable>
                    <xsl:value-of select="concat('[', $currentPage, ']')"/>
                </xsl:when>
                <xsl:when test="ancestor::tei:body">
                    <!-- pages before before W0010-0700 can be numbered in a simple manner -->
                    <xsl:choose>
                        <xsl:when test="following::tei:pb[contains(@facs, 'W0010-0700')]">
                            <xsl:variable name="currentPage" as="xs:string">
                                <xsl:number value="count(preceding::tei:pb[ancestor::tei:body and not(ancestor::tei:note)]) + 1" format="1"/>
                            </xsl:variable>
                            <xsl:value-of select="$currentPage"/>
                        </xsl:when>
                        <!-- from page 0699 to 0700, there is a "jump" of three pages, so that every page number thererafter can be put in "[]" -->
                        <xsl:when test="following::tei:pb[contains(@facs, 'W0010-0843')]">
                            <xsl:variable name="currentPage" as="xs:string">
                                <xsl:number value="count(preceding::tei:pb[ancestor::tei:body and not(ancestor::tei:note)]) + 1" format="1"/>
                            </xsl:variable>
                            <xsl:value-of select="concat('[', $currentPage, ']')"/>
                        </xsl:when>
                        <!-- from 0843 onwards, original pagination is correct, thus no "[]" necessary -->
                        <xsl:otherwise>
                            <xsl:variable name="currentPage" as="xs:string">
                                <xsl:number value="count(preceding::tei:pb[ancestor::tei:body and not(ancestor::tei:note)]) + 1" format="1"/>
                            </xsl:variable>
                            <xsl:value-of select="$currentPage"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="ancestor::tei:back">
                    <xsl:variable name="currentPage" as="xs:string">
                        <xsl:number value="count(preceding::tei:pb[(ancestor::tei:body or ancestor::tei:back) and not(ancestor::tei:note)]) + 1" format="1"/>
                    </xsl:variable>
                    <xsl:value-of select="concat('[', $currentPage, ']')"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            </xsl:variable>
            <xsl:if test="$n">
                <xsl:attribute name="n" select="$n"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>