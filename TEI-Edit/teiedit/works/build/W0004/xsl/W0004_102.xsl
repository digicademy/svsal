<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <xsl:output method="xml"/> 
    
    <xsl:variable name="specialCharacters" select="doc('../../../resources/chars/Sonderzeichen_2018-07-06.xml')//tei:teiHeader//tei:charDecl//tei:char"/>
    
    <!-- Identity transformation for everything that is not encountered further below -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="editors" as="xs:string" select="'#DG'"/>
    <xsl:variable name="editingDate" as="xs:string" select="'2018-07-10'"/>
    <xsl:variable name="editingDesc" as="xs:string" select="'Structural adaptations according to new edition guidelines; revised special characters.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&#xa;                </xsl:text>
            <xsl:element name="change">
                <xsl:attribute name="who" select="$editors"/>
                <xsl:attribute name="when" select="$editingDate"/>
                <xsl:attribute name="status" select="ancestor::tei:revisionDesc[1]/@status"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:value-of select="$editingDesc"/>
            </xsl:element>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:text//tei:p/@part[. = 'N']"/>
    
    <xsl:template match="tei:text//tei:ref/@xml:id"/>

    <xsl:template match="tei:text//tei:note[@anchored='true']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="place" select="'margin'"/>
            <xsl:if test="count(child::tei:p) > 1">
                <xsl:message terminate="yes">Error: note contains more than one p elements.</xsl:message>
            </xsl:if>
            
            <xsl:variable name="signInNote" select=".//tei:hi[@rendition='#sup'][1]"/>
            
            <xsl:if test="not(@n)">
                <xsl:variable name="label1" 
                select="replace(string-join(./tei:p//text()[not(normalize-space(.) eq '') 
                                                            and count(preceding::node()) le count($signInNote/preceding::node())
                                                            and not(parent::tei:sic or parent::tei:abbr)], ''), '&#xA;', ' ')"/>
                <xsl:variable name="label2">
                    <xsl:choose>
                        <xsl:when test="starts-with($signInNote/following-sibling::text()[1], '.')">
                            <xsl:value-of select="concat($label1, '.')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$label1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="noteLabel">
                    <xsl:choose>
                        <xsl:when test="$label1 and $label2">
                            <xsl:value-of select="$label2" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="'Error: found no label for marginal note.'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:message terminate="no" select="concat('Creating note label in @n: ', $noteLabel)"/>
                <xsl:attribute name="n" select="$noteLabel"/>
            </xsl:if>
            
            
            <xsl:choose>
                <xsl:when test="$signInNote">
                    <xsl:element name="p"> <!-- TODO: for debugging -->
                    <xsl:choose>
                        <xsl:when test="$signInNote/following-sibling::node()[1][self::text() and (starts-with(., '.') or starts-with(., ' '))]">
                            <xsl:choose>
                                <xsl:when test="starts-with($signInNote/following-sibling::node()[1], '. ')">
                                    <xsl:value-of select="substring($signInNote/following-sibling::node()[1], 3)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring($signInNote/following-sibling::node()[1], 2)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="$signInNote/following-sibling::node()[1]/following-sibling::node()"/>
                            <xsl:message terminate="no" 
                                select="concat('Omitting text in marg. note: ', 
                                                string-join($signInNote/preceding-sibling::node()[self::text() or .//text()], ''), 
                                                $signInNote//text(), 
                                                substring($signInNote/following-sibling::node()[1], 1, 1))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$signInNote/following-sibling::node()"/>
                            <xsl:message terminate="no" 
                                select="concat('Omitting text in marg. note: ', 
                                                string-join($signInNote/preceding-sibling::node()[self::text() or .//text()], ''), 
                                                $signInNote//text())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- with a simple apply-templates, we have about 2683 lines in the result doc -->
            
        </xsl:copy>
    </xsl:template>
    
    <!-- omit nodes within note: p, lb (if it has no following sibling), and obsolete whitespace at the end of the not -->
    <xsl:template match="tei:text//tei:note//tei:lb[last() and count(following-sibling::node()) eq 1 and following-sibling::node()[self::text()[normalize-space(.) = '']]]"/>
    <!--<xsl:template match="tei:text//tei:note/tei:p">
        <xsl:apply-templates/>
    </xsl:template>-->
    <xsl:template match="tei:text//tei:note//text()[preceding-sibling::tei:p and not(following-sibling::node()) and normalize-space(.) eq '']"/>
    
    
    <xsl:template match="tei:text//tei:hi[@rendition='#sup' and following-sibling::node()[position() lt 3 and self::tei:note[@anchored='true']]]">
        <!-- TODO: perhaps cut off blank before the superscript sign? -->
        <xsl:variable name="noteId" select="following-sibling::node()[position() lt 3 and self::tei:note[@anchored='true']][1]/@xml:id"/>
            <xsl:element name="ref">
                <xsl:attribute name="type" select="'note-anchor'"/>
                <xsl:attribute name="n" select="current()/text()"/>
                <xsl:attribute name="target" select="concat('#', $noteId)"/>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    
    <!-- make sure that every g/@ref starts with '#' and refers to an actual char in the char declaration -->
    <xsl:template match="tei:g">
        <xsl:if test="not(starts-with(@ref, '#char')) 
                      or not($specialCharacters//@xml:id[. eq substring-after(current()/@ref, '#')])
                      or contains(@ref, ' ')">
            <xsl:message terminate="yes" select="concat('Error: invalid value for g/@ref: ', @ref)"/>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>