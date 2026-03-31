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
    <xsl:param name="editingDate" as="xs:string" select="'2019-01-15'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0010-change-018'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged note cross-references and deleted reference character from beginnings of marginal notes.'"/>
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
        <xsl:message select="concat('Removing ', 
                                    string(count(//text()[ancestor::tei:note[@place eq 'margin' and @n] 
                                                          and not(normalize-space() eq '')
                                                          and local:isFirstTextNode(., ancestor::tei:note[@place eq 'margin']) 
                                                          and local:removableNoteLabel(., ancestor::tei:note[@place eq 'margin']/@n) gt 0])),
                                    ' note labels from the beginnings of notes.')"/>
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:hi[@rendition eq '#sup' and following-sibling::node()[1]/self::tei:note[@place eq 'margin']]">
        <xsl:choose>
            <xsl:when test="count(.//text()) gt 1">
                <xsl:message terminate="yes" select="concat('Found hi[#sup] with more than one text children on page ', preceding::tei:pb[1]/@xml:id)"></xsl:message>
            </xsl:when>
            <xsl:when test=".//text() eq replace(following-sibling::node()[1]/self::tei:note[@place eq 'margin']/@n, '[\[\]]', '')
                            and following-sibling::node()[1]/self::tei:note[@place eq 'margin']/@xml:id">
                <xsl:element name="ref">
                    <xsl:attribute name="type" select="'note-anchor'"/>
                    <xsl:attribute name="target" select="concat('#', following-sibling::node()[1]/self::tei:note[@place eq 'margin']/@xml:id)"/>
                    <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </xsl:copy>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no" select="'Incoherence between note anchor and label, see xml:id ', following-sibling::node()[1]/self::tei:note[@place eq 'margin']/@xml:id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::tei:note[@place eq 'margin' and @n] 
                                and not(normalize-space() eq '')
                                and local:isFirstTextNode(., ancestor::tei:note[@place eq 'margin']) 
                                and local:removableNoteLabel(., ancestor::tei:note[@place eq 'margin']/@n) gt 0]">
        <xsl:variable name="removeLabel" as="xs:integer" select="local:removableNoteLabel(., ancestor::tei:note[@place eq 'margin']/@n)"/>
        <!--<xsl:message select="concat('Transforming: ', ., ' -\-TO-\- ', substring(., $removeLabel + 1))"/>-->
        <xsl:value-of select="substring(., $removeLabel + 1)"/>
    </xsl:template>
    
    <xsl:function name="local:removableNoteLabel" as="xs:integer">
        <xsl:param name="textNode" as="text()"/>
        <xsl:param name="noteLabel" as="xs:string"/>
        <xsl:choose>
            <!-- *lower-cased* string comparison: we assume that lower-/upper-casing has no meaning when it comes to note labels -->
            <xsl:when test="matches(lower-case($textNode), concat('^', lower-case($noteLabel), '[\.,] '))">
                <xsl:value-of select="string-length($noteLabel) + 2"/>
            </xsl:when>
            <xsl:when test="matches(lower-case($textNode), concat('^', lower-case($noteLabel), ' '))">
                <xsl:value-of select="string-length($noteLabel) + 1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:isFirstTextNode" as="xs:boolean">
        <xsl:param name="textNode" as="text()"/>
        <xsl:param name="note" as="element(tei:note)"/>
        <xsl:variable name="firstNoteText" as="text()" select="($note//text()[not(normalize-space() eq '')])[1]"/>
        <xsl:value-of select="count($textNode|$firstNoteText) eq 1"/>
        <!--<xsl:if test="count($textNode|$firstNoteText) eq 1">
            <xsl:message select="concat('$textNode is: ', $textNode, ' || $firstNoteText is: ', $firstNoteText)"/>
        </xsl:if>-->
    </xsl:function>
    
    <xsl:template match="tei:text//tei:list//tei:ref[not(@type)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'summary'"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>