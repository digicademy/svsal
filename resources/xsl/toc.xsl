<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sal="http://salamanca.adwmainz.de" version="2.0" exclude-result-prefixes="exist sal tei xd xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:import href="sal-functions.xsl"/>
    <xsl:output method="html"/>
    <xsl:param name="workId" as="xs:string"/>

<!-- TODO:
    * use templates to parse head contents, not just output text() value (e.g we may have <g> elements or editorial interventions) ...
-->

    <!-- Prepare a key-value array for toc generation -->
    <xsl:key name="targeting-refs" match="ref[@type='summary']" use="@target"/>
    <xsl:key name="chars" match="char" use="@xml:id"/>

    <!-- Root and high-level elements -->
    <xsl:template match="/">
        <ul class="work_toc">
            <xsl:apply-templates select="//text[@type='work_volume'] | //text[@type = 'work_monograph']//front/div | //text[@type = 'work_monograph']//body/div | //text[@type = 'work_monograph']//back/div"/>
        </ul>
    </xsl:template>
    <xsl:template match="text[@type='work_volume']">
        <li>
            <xsl:if test="not(following::text)">
                <xsl:attribute name="class">last</xsl:attribute>
            </xsl:if>
            <xsl:if test="./front/div | ./body/div | ./back/div">
                <xsl:attribute name="class">expandable</xsl:attribute>
                <div class="hitarea expandable-hitarea"/>
            </xsl:if>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="sal:mkUrl($workId, ./@xml:id)"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>hideMe</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="sal:teaserString">
                    <xsl:with-param name="identifier" select="@xml:id"/>
                    <xsl:with-param name="mode">text</xsl:with-param>
                    <xsl:with-param name="input" select="sal:sectionTitle($workId, ./@xml:id)"/>
                </xsl:call-template>
            </xsl:element>
            <xsl:if test="./front/div | ./body/div | ./back/div">
                <ul>
                    <xsl:apply-templates select="./front/div | ./body/div | ./back/div"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
    <xsl:template match="div[@type='work_part']"> <!-- This is just a technical div, don't render it, but go further down/inside ... -->
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="div | milestone">
        <li>
            <xsl:if test="not(following::div | following::milestone | following::text)">
                <xsl:attribute name="class">last</xsl:attribute>
            </xsl:if>
            <xsl:if test="div | milestone">
                <xsl:attribute name="class">expandable</xsl:attribute>
                <div class="hitarea expandable-hitarea"/>
            </xsl:if>
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="sal:mkUrl($workId, @xml:id)"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>hideMe</xsl:text>
                </xsl:attribute>
                <xsl:call-template name="sal:teaserString">
                    <xsl:with-param name="identifier" select="@xml:id"/>
                    <xsl:with-param name="mode">text</xsl:with-param>
                    <xsl:with-param name="input" select="sal:sectionTitle($workId, ./@xml:id)"/>
                </xsl:call-template>
            </xsl:element>
            <xsl:if test="div | p/milestone">
                <ul>
                    <xsl:apply-templates select="div | p/milestone"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
</xsl:stylesheet>