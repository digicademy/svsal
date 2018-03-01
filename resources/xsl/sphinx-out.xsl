<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sal="http://salamanca.adwmainz.de" version="3.0" exclude-result-prefixes="exist sal tei xd xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0">


<!-- **** I. Import helper functions **** -->
<!--    <xsl:include href="sal-functions.xsl"/>-->

<!-- **** II. Parameters, Defaults, named templates etc. **** -->
    <xsl:param name="targetWorkId" as="xs:string"/>
    <xsl:param name="targetNodeId" as="xs:string"/>
    <xsl:param name="mode" as="xs:string" select="orig"/>
    <xsl:output method="text" indent="no"/>

    <!-- Prepare a key-value array for toc generation -->
    <xsl:key name="targeting-refs" match="ref[@type='summary']" use="@target"/>
    <xsl:key name="chars" match="char" use="@xml:id"/>

<!-- **** III. Matching Templates **** -->

<!-- Diese Elemente liefern wir an sphinx aus:                text//(p|head|item|note|titlePage)
     Diese weiteren Elemente enthalten ebenfalls Textknoten:        (fw hi l g body div front)
     Diese weiteren Elemente enthalten ebenfalls Textknoten:        (fw hi l g body div front)
            [zu ermitteln durch distinct-values(collection(/db/apps/salamanca-data/tei)//tei:text[@type = ("work_monograph", "work_volume")]//node()[not(./ancestor-or-self::tei:p | ./ancestor-or-self::tei:head | ./ancestor-or-self::tei:list | ./ancestor-or-self::tei:titlePage)][text()])]
     Wir ignorieren fw, während hi, l und g immer schon in p, head, item usw. enthalten sind.
     => Wir müssen also noch dafür sorgen, dass front, body und div's keinen Text außerhalb von p, head, item usw. enthalten!
-->

    <!-- Root element: apply templates to target node (and subnodes) only -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$mode='edit'">
                <xsl:apply-templates select="descendant-or-self::*[@xml:id = $targetNodeId]" mode="edit"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="descendant-or-self::*[@xml:id = $targetNodeId]" mode="orig"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- Shall we include matches that do nothing but run apply-templates on all their children?
     I think this is done by default anyway... -->
<!--
    <xsl:template match="titlePage">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="titlePart">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="head">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="list">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="item">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="p">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="note">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="abbr|orig|sic">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="expan|reg|corr">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="lg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="l">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="ref">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="hi">
        <xsl:apply-templates/>
    </xsl:template>
-->

    <!-- If divs and milestones have a ("hidden") title return that, too. -->
    <xsl:template match="div|milestone" mode="edit">
        <!-- See if we have something we can use to name the thing:
             Either an @n attribute, a child heading or a summary at the beginning of the chapter/in the index etc. -->
        <xsl:choose>
            <xsl:when test="@n and not(matches(@n, '^[0-9]+$'))">
                <xsl:value-of select="@n"/>
            </xsl:when>
<!-- The head child is indexed anyway, so we needn't include it again here. -->
            <xsl:otherwise>
                <xsl:value-of select="key('targeting-refs', concat('#',@xml:id))[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates mode="edit"/>
    </xsl:template>

    <!-- Choice elements return both their children, separated by space -->
<!--    <xsl:template match="choice"><xsl:apply-templates select="child::*[1]" /><xsl:text> </xsl:text><xsl:apply-templates select="child::*[2]" /></xsl:template>-->
    <!-- No, we rather should render the whole snippet twice, once in original and once in edited form. That keeps
         the word sequence intact. Otherwise phrase searches will be confused -->
    <!-- Orig mode: only abbr, orig, sic elements: -->
    <xsl:template match="abbr|orig|sic" mode="orig">
        <xsl:apply-templates mode="orig" />
    </xsl:template>
    <xsl:template match="expan|reg|corr" mode="orig"/>
    <!-- Edit mode: Only when no expan, reg, corr elements are present, render abbr, orig, err elements. -->
    <xsl:template match="abbr[not(preceding-sibling::expan|following-sibling::expan)]|orig[not(preceding-sibling::reg|following-sibling::reg)]|sic[not(preceding-sibling::corr|following-sibling::corr)]" mode="edit">
        <xsl:apply-templates mode="edit"/>
    </xsl:template>
    <xsl:template match="abbr|orig|sic" mode="edit"/>
    <xsl:template match="expan|reg|corr" mode="edit">
        <xsl:apply-templates mode="edit"/>
    </xsl:template>


    <!-- Analytic references (persNames, titles etc.) -->
    <!-- In edit mode, return an eventual key (resp. sortKey) attribute instead of the actual element content (which we have in orig mode anyway) -->
    <xsl:template match="persName|placeName|text//title|term" mode="orig">
        <xsl:apply-templates mode="orig"/>
    </xsl:template>
    <xsl:template match="persName[@key]|placeName[@key]|text//title[@key]|term[@key]" mode="edit">
        <xsl:value-of select="@key"/>
    </xsl:template>
    <xsl:template match="persName|placeName|text//title|term" mode="edit">
        <xsl:apply-templates mode="edit"/>
    </xsl:template>
    <xsl:template match="bibl" mode="orig">
        <xsl:apply-templates mode="orig"/>
    </xsl:template>
    <xsl:template match="bibl[@sortKey]" mode="edit">
        <xsl:value-of select="@sortKey"/>
    </xsl:template>
    <xsl:template match="bibl" mode="edit">
        <xsl:apply-templates mode="edit"/>
    </xsl:template>

    <xsl:template match="g" mode="orig">
        <xsl:choose>
            <xsl:when test="key('chars', substring(@ref,2))">
                <xsl:choose>
                    <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='precomposed']">
                        <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='precomposed']/text()" disable-output-escaping="yes"/>
                    </xsl:when>
                    <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='composed']">
                        <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='composed']/text()" disable-output-escaping="yes"/>
                    </xsl:when>
                    <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='standardized']">
                        <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='standardized']/text()" disable-output-escaping="yes"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="orig"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="g" mode="edit">
        <xsl:apply-templates mode="edit"/>
    </xsl:template>
    
    <!-- Breaks represent whitespace, unless @break=no. The more specific template wins... -->
    <xsl:template match="pb[not(@break='no')]" mode="#all">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="lb[not(@break='no')]" mode="#all">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="cb[not(@break='no')]" mode="#all">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="pb | cb | lb" mode="#all"/>


    <!-- For these: dump them, contents included -->
    <xsl:template match="figDesc" mode="#all"/>
    <xsl:template match="teiHeader" mode="#all"/>
    <xsl:template match="fw" mode="#all"/>
</xsl:stylesheet>