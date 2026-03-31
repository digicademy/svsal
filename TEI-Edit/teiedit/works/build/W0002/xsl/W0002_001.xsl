<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tite="http://www.tei-c.org/ns/tite/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <xsl:import href="W0002_001-b.xsl"/>
    
      
    <xsl:output method="xml"/>
    
    <xsl:variable name="workId" as="xs:string" select="'W0002'"/>
    <xsl:variable name="textType" as="xs:string" select="'work_monograph'"/> <!-- "work_monograph" or "work_volume" or "work_multivolume" -->
    <xsl:variable name="textLang" as="xs:string" select="'es'"/><!-- "es" or "la" -->
    <xsl:variable name="volumeNumber" as="xs:integer" select="0"/><!-- number of the volume in a multi-volume work (must be "0" for single-volume works)  -->
    
    <!--<xsl:variable name="teiStub" as="xs:string" select="'../../../../../svsal-data/tei/works/W0002.xml'"/>-->

    <!-- The Salamanca TEI demands certain attributes (e.g. @type in div) which require semantic annotation and thus cannot be provided at this point; 
        hence, we use the general TEI schema for validation for now: -->
    <xsl:variable name="generalTeiSchema" as="xs:boolean" select="true()"/> <!-- use this for adding the general TEI validation schema (instead of Salamanca TEI) -->
    <xsl:variable name="fragmentationDepth" as="xs:integer">0</xsl:variable>
    
    <xsl:variable name="analyzeTextEnabled" as="xs:boolean" select="true()"/> 
    <!-- if set to true, all text nodes will be analyzed with regards to unwanted control characters -->


    <!-- ####++++ Special section for W0002 ++++#### -->
    
    <!-- Abbreviation expansions -->
    <xsl:template match="tei:g[@n]">
        <xsl:choose>
            <xsl:when test="@n = '#chart0303'">
                <xsl:copy>
                    <xsl:attribute name="ref">#chart0303</xsl:attribute>
                    <xsl:attribute name="resp">#DG</xsl:attribute>
                    <xsl:attribute name="cert">high</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Error: unknown value of g/@n</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- copy asterisk and dagger milestones and adapt/extend them -->
    <xsl:template match="tei:milestone">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@rend = 'asterisk' or @rend = 'asterisk_special'">
                    <xsl:if test="@n">
                        <xsl:message terminate="yes">Warning: Asterisk unexpectedly references a marginal note or number</xsl:message>
                    </xsl:if>
                    <xsl:attribute name="unit">article</xsl:attribute>
                    <xsl:attribute name="rendition">#asterisk</xsl:attribute>
                    <xsl:if test="@rend = 'asterisk_special'">
                        <xsl:attribute name="type">titlePage</xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@rend = 'dagger'">
                    <xsl:attribute name="unit">article</xsl:attribute>
                    <xsl:attribute name="rendition">#dagger</xsl:attribute>
                    <xsl:copy-of select="@n"/>
                    <xsl:attribute name="xml:id" select="concat('dag_', generate-id())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@unit"/>
                    <xsl:copy-of select="@n"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@resp|@cert|@change"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Delete remaining comments (i.e. remaining TAO markup) -->
    <xsl:template match="comment()">
        <xsl:choose>
            <xsl:when test="matches(normalize-space(.), '^tao:A[-\+][1-3]_(beg|end)$')"/> <!-- delete font size information -->
            <xsl:otherwise>
                <xsl:element name="unclear">
                    <xsl:attribute name="n">comment</xsl:attribute>
                    <xsl:attribute name="xml:id"/> <!-- empty xml:id for yielding validation errors as markers of unresolved comments -->
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
       
    <xsl:template match="text()">
        <xsl:variable name="specialChars" select="('#','[', ']', '{', '}', '%', '$', '@', '&lt;', '&gt;', '^', '*', '〈', '〉')"/>
        <xsl:variable name="quotationMarks" select="('“','”', '„', '»','«', '›', '‹')"/> 
        <xsl:choose>
            <!-- 1.) check if text nodes contain any control signs from previous transcription/annotation processes -->
            <xsl:when test="$analyzeTextEnabled and (some $char in $specialChars satisfies contains(., $char))">
                <xsl:message terminate="yes">Error: special character detected -- resolve this manually</xsl:message>
            </xsl:when>
            <!-- Daggers '†' have been resolved manually, therefore the following xsl:when is only interesting for similar cases in the future -->
            <!-- 2.) check for hard-coded daggers in the text (apparently, TAO resolved daggers mostly 
                (but not always) when according marginal numbers are on the right hand side
            from the text) -->
            <!--<xsl:when test="contains(., '†')">
                <!-\- if multiple daggers occur in one line, break: -\->
                <xsl:choose>
                    <xsl:when test="matches(., '†.*?†') or matches(., '††')">
                        <xsl:value-of select="."/>
                        <xsl:message>Warning: multiple daggers detected in one line -\- resolve this manually</xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-\- try to link a marginal on the same typographical height to the milestone -\->
                        <xsl:variable name="followingMargNum" select="current()/following::tei:note[@type='marginalia' and @n='noRef'] 
                            intersect current()/following::tei:lb[1]/preceding::tei:note[@type='marginalia' and @n='noRef']"/>
                        <xsl:variable name="precedingMargNum" select="current()/preceding::tei:note[@type='marginalia' and @n='noRef'] 
                            intersect current()/preceding::tei:lb[1]/following::tei:note[@type='marginalia' and @n='noRef']"/>
                        <xsl:choose>
                            <xsl:when test="count($followingMargNum) > 0">
                                <xsl:variable name="before" select="substring-before(., '†')"/>
                                <xsl:variable name="after" select="substring-after(., '†')"/>
                                <xsl:variable name="milestone" as="element()">
                                    <xsl:element name="milestone">
                                        <xsl:attribute name="unit">article</xsl:attribute>
                                        <xsl:attribute name="rendition">#dagger</xsl:attribute>
                                        <xsl:attribute name="n" select="$followingMargNum[1]/text()"/>
<!-\-                                        <xsl:attribute name="xml:id" select="concat('dag_', generate-id())"/>-\->
                                    </xsl:element>
                                </xsl:variable>
                                <xsl:copy-of xml:space="preserve" select="($before, $milestone, $after)"/> 
                            </xsl:when>
                            <xsl:when test="count($precedingMargNum) > 0">
                                <xsl:variable name="before" select="substring-before(., '†')"/>
                                <xsl:variable name="after" select="substring-after(., '†')"/>
                                <xsl:variable name="milestone" as="element()">
                                    <xsl:element name="milestone">
                                        <xsl:attribute name="unit">article</xsl:attribute>
                                        <xsl:attribute name="rendition">#dagger</xsl:attribute>
                                        <xsl:attribute name="n" select="$precedingMargNum[1]/text()"/>
<!-\-                                        <xsl:attribute name="xml:id" select="concat('dag_', generate-id())"/>-\->
                                    </xsl:element>
                                </xsl:variable>
                                <xsl:copy-of xml:space="preserve" select="($before, $milestone, $after)"/> 
                            </xsl:when>
                            <!-\- no marginal number found -\->
                            <xsl:otherwise>
                                <xsl:variable name="before" select="substring-before(., '†')"/>
                                <xsl:variable name="after" select="substring-after(., '†')"/>
                                <xsl:variable name="milestone" as="element()">
                                    <xsl:element name="milestone">
                                        <xsl:attribute name="unit">article</xsl:attribute>
                                        <xsl:attribute name="rendition">#dagger</xsl:attribute>
                                        <xsl:attribute name="n">unclear</xsl:attribute>
<!-\-                                        <xsl:attribute name="xml:id" select="concat('dag_', generate-id())"/>-\->
                                    </xsl:element>
                                </xsl:variable>
                                <xsl:copy-of xml:space="preserve" select="($before, $milestone, $after)"/>
                                <xsl:message>Warning: dagger could not be linked to marginal number -\- resolve this manually</xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>-->
            <!-- 3.) check for unresolved quotation marks -->
            <xsl:when test="some $char in $quotationMarks satisfies contains(., $char)">
                <xsl:message terminate="yes">Warning: quotation mark detected -- resolve this using element q</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- TODO: introduce space element to SvSal schema -->
    <xsl:template match="tei:seg[@rend='gap']">
        <xsl:element name="space">
            <xsl:attribute name="dim">horizontal</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change"/>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="tei:list">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@type = 'summary'">
                    <xsl:attribute name="type">summaries</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type = 'toc'">
                    <xsl:attribute name="type">simple</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>



</xsl:stylesheet>