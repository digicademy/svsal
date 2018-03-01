<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output method="html"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:p">
        <xsl:choose>
            <xsl:when test="@rendition='h3'">
                <h3 style="margin-top: 3%">
                    <xsl:apply-templates/>
                </h3>
            </xsl:when>
            <xsl:when test="@rendition='bold'">
                <p class="newsP">
                    <b>
                        <xsl:apply-templates/>
                    </b>
                </p>
            </xsl:when>
            <xsl:when test="@rendition='italics'">
                <p class="newsP">
                    <i>
                        <xsl:apply-templates/>
                    </i>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <p class="newsP">
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ref">
        <a href="{@target}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="tei:list">
        <ul style="list-style-type:square;">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:item">
        <li style="font-size: 1.3em; text-align: justify; text-justify:inter-word">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
</xsl:stylesheet>