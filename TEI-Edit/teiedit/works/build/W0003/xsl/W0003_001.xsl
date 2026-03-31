<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
   
    <xsl:output method="xml" indent="no"/>
    
    <!--<xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2019-02-19'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0003_change_002'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Add @n to pb.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="include-numbers">
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
            <xsl:apply-templates mode="include-numbers"/>
        </xsl:copy>
    </xsl:template>-->
    
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:param name="pb" as="element(tei:pb)"/>
    
    <xsl:template match="tei:body//tei:pb">
        <xsl:variable name="n" as="xs:integer" select="count(./preceding::tei:pb[ancestor::tei:body])+1"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @n"/>
            <xsl:message>Adding @n to pb</xsl:message>
            <xsl:choose>
                <xsl:when test="contains(@n,'[')">
                    <xsl:copy-of select="@n"/>
                </xsl:when>
                <xsl:otherwise>
                     <xsl:attribute name="n" select="$n"/>
                </xsl:otherwise>
            </xsl:choose>
           
                
        </xsl:copy>    
    </xsl:template>
       
</xsl:stylesheet>