<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:param name="idServer"/> 
    <xsl:template match="/rdf:RDF">
        <xsl:element name="rdf:RDF">
            <xsl:for-each select="@*">
                <xsl:copy/>
            </xsl:for-each>
            <xsl:copy-of select="//namespace::*"/>
            <xsl:attribute name="xml:base">
                <xsl:value-of select="$idServer"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@rdf:about[starts-with(., 'http://any23.org/tmp/')]">
        <xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <xsl:value-of select="substring(., 22)"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@rdf:resource[starts-with(., 'http://any23.org/tmp/')]">
        <xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
            <xsl:value-of select="substring(., 22)"/>
        </xsl:attribute>
    </xsl:template>
</xsl:stylesheet>