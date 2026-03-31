<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- This program processes choice elements where break elements (pb,cb,lb) appear only in the first (sic, abbr, orig), but not in the second (reg, abbr, expan))
        child element. It adds the respective break elements to the second child, interlinking them to those of the first child via @sameAs. However, this 
        only applies to choice elements where the second element consists of nothing but tags (e.g., no special character or hi tagging). -->
    
    <!-- IMPORTANT: run this program BEFORE special characters are tagged in 2nd choice childs, so that 
        2nd choice childs only contain text nodes (but not also g tags) -->
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-12-17'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_025'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Correct choice/(pb|cb|lb) pairings.'"/>
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

    
    <!-- most practical approach: if pb/lb occurs within 1st choice child, 
                    replicate it after the first special character within the second choice child -->
    <xsl:template match="tei:choice[(child::*[1]/tei:pb or child::*[1]/tei:cb or child::*[1]/tei:lb)
                                    and not(child::*[2]/node()[not(self::text())])]">
        <xsl:if test="count(child::node()) ne count(child::*) or count(child::node()) ne 2">
            <xsl:message terminate="yes" select="concat('Error: element choice in line, ', preceding::tei:lb[@xml:id][1]/@xml:id, ' does not have exactly 2 child elements.')"/>
        </xsl:if>
        <xsl:variable name="pb1" as="element(tei:pb)?" select="./child::*[1]/tei:pb"/>
        <xsl:variable name="cb1" as="element(tei:cb)?" select="./child::*[1]/tei:cb"/>
        <xsl:variable name="lb1" as="element(tei:lb)?" select="./child::*[1]/tei:lb"/>
        <xsl:if test="($pb1,$cb1,$lb1)/@sameAs">
            <xsl:message terminate="yes" select="'Error: no idea what to do with pb/cb/lb having @sameAs: ', ($pb1,$cb1,$lb1)/@sameAs[1]"/>
        </xsl:if>
        <!-- pair break elements will always be tagged as @break=no and rendition=#noHyphen (#hyphen wouldn't make much sense here...) -->
        <xsl:variable name="pb2" as="element(tei:pb)?">
            <xsl:if test="$pb1">
                <xsl:element name="pb">
                    <xsl:if test="not($pb1/@break eq 'no') or not($pb1/@xml:id)">
                        <xsl:message terminate="yes" select="'Error: element ', $pb1/@xml:id, ' is lacking @break or @xml:id'"/> <!-- if it lacks @xml:id, search for it manually... -->
                    </xsl:if>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="sameAs" select="concat('#', $pb1/@xml:id)"/>
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                </xsl:element>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="cb2" as="element(tei:cb)?">
            <xsl:if test="$cb1">
                <xsl:element name="cb">
                    <xsl:if test="not($cb1/@break eq 'no') or not($cb1/@xml:id)">
                        <xsl:message terminate="yes" select="'Error: element ', $cb1/@xml:id, ' is lacking @break or @xml:id'"/> <!-- if it lacks @xml:id, search for it manually... -->
                    </xsl:if>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="sameAs" select="concat('#', $cb1/@xml:id)"/>
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                </xsl:element>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="lb2" as="element(tei:lb)?">
            <xsl:if test="$lb1">
                <xsl:element name="lb">
                    <xsl:if test="not($lb1/@break eq 'no') or not($lb1/@xml:id)">
                        <xsl:message terminate="yes" select="'Error: element ', $lb1/@xml:id, ' is lacking @break or @xml:id'"/> <!-- if it lacks @xml:id, search for it manually... -->
                    </xsl:if>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="sameAs" select="concat('#', $lb1/@xml:id)"/>
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                </xsl:element>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(child::*[2]/text())">
            <xsl:message terminate="yes" select="concat('Error: second child element of choice containing break (',($pb1,$cb1,$lb1)/@xml:id[1] ,') does not have any text content.')"/>
        </xsl:if>
        <xsl:variable name="text" as="xs:string" select="child::*[2]/text()"/>
        <xsl:variable name="median" as="xs:integer" select="string-length($text) idiv 2"/>
        <xsl:variable name="text1" as="xs:string" select="substring($text,1,$median)"/>
        <xsl:variable name="text2" as="xs:string" select="substring($text,$median + 1)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="child::*[1]"/>
            <xsl:element name="{child::*[2]/local-name()}">
                <xsl:copy-of select="child::*[2]/@*"/>
                <xsl:copy-of select="($text1,$pb2,$cb2,$lb2,$text2)"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>