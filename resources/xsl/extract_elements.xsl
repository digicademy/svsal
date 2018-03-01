<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	xmlns:sal="http://salamanca.adwmainz.de"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="3.0"
	exclude-result-prefixes="exist sal tei xd xs xsl"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<!-- **** I. Import helper functions **** -->
    <xsl:include href="sal-functions.xsl"/>

<!-- **** II. Parameters, Defaults, named templates etc. **** -->
    <xsl:param name="targetWork"/>
    <xsl:param name="targetNode"/>
    <xsl:param name="mode"/>

    <!--    <xsl:output method="xml" omit-xml-declaration="yes"/>-->
    <!--    <xsl:output method="html"/>-->
    <xsl:output method="html"/>
    <xsl:output indent="no"/>


<!-- **** III. Matching Templates **** -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$mode='node'">
                <xsl:apply-templates mode="node"/>
            </xsl:when>
            <xsl:when test="$mode='crumbtrail'">
                <xsl:apply-templates mode="crumbtrail"/>
            </xsl:when>
            <xsl:when test="$mode='parentFragment'">
                <xsl:apply-templates mode="parentFragment"/>
            </xsl:when>
            <xsl:when test="$mode='parentFragmentFile'">
                <xsl:apply-templates mode="parentFragmentFile"/>
            </xsl:when>
            <xsl:when test="$mode='url'">
                <xsl:apply-templates mode="url"/>
            </xsl:when>
            <xsl:when test="$mode='index'">
                <xsl:apply-templates mode="index"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="/*" mode="parentFragment">
        <xsl:value-of select="sal:getFragmentNodeId($targetWork, $targetNode)"/>
    </xsl:template>
    <xsl:template match="/*" mode="parentFragmentFile">
        <xsl:value-of select="sal:getFragmentFile($targetWork, $targetNode)"/>
    </xsl:template>
    <xsl:template match="/*" mode="crumbtrail">
        <xsl:sequence select="sal:crumbtrail($targetWork, $targetNode, true())"/>
    </xsl:template>
    <xsl:template match="/*" mode="url">
        <xsl:value-of select="sal:resolveURI(., $targetNode)"/>
    </xsl:template>
</xsl:stylesheet>