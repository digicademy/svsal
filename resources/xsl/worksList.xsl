<xsl:stylesheet xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:teix="http://www.tei-c.org/ns/Examples" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xd xs exist teix tei" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output method="html"/>
    <xsl:param name="modus"/>
    <xsl:param name="language"/>

    <!-- Root -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$modus='toc'">
                <xsl:apply-templates select="//listBibl" mode="toc"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="teiHeader"/>
    
    <xsl:template match="text">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="body/head"/>
    <xsl:template match="body/p"/>
    <xsl:template match="listBibl/head[@xml:lang ne $language]"/>
    
    <xsl:template match="listBibl">
        <xsl:if test="preceding-sibling::listBibl">
            <hr/>
        </xsl:if>
        <div>
            <a name="{@xml:id}"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!--process h2-hn-->
    
    <xsl:template match="listBibl/head[@xml:lang eq $language]">
        <h2 class="alignedGuidelines">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    
    <xsl:template match="bibl">
        <p class="lead" style="text-align: justify" title="{@xml:id}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="author|persName|title|pubPlace|date">
        <xsl:apply-templates/>
    </xsl:template>
        
    <xsl:template match="ref">
        <a href="{@target}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>
    
    
    <xsl:template match="listBibl" mode="toc">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4 class="panel-title">
                    <a href="{concat('#', @xml:id)}">
                        <xsl:value-of select="head[@xml:lang eq $language]/text()"/>  
                    </a>
                </h4>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>