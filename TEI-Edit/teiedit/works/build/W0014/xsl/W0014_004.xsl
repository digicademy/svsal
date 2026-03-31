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
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-16'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0014_change_0013'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Resolving marginal notes with leading numbers as head[@place=margin]'"/>
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
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:div[@type eq 'article' and not(descendant::tei:milestone[@n])]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="marginalHeading" select="local:getMarginalHeading(.)"/>
            <xsl:choose>
                <xsl:when test="$marginalHeading">
                    <xsl:variable name="numberNote" select="$marginalHeading//text()[1]"/>
                    <!-- cut the leading number away from the content, to be used as div/@n -->
                    <xsl:variable name="headContent">
                        <xsl:choose>
                            <xsl:when test="$numberNote/ancestor::*[1]/self::tei:supplied">
                                <xsl:copy-of select="$numberNote/ancestor::*[1]/following-sibling::node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$numberNote/following-sibling::node()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="not(@n)">
                        <xsl:attribute name="n">
                            <xsl:choose>
                                <xsl:when test="ends-with($numberNote, '.')">
                                    <xsl:value-of select="substring-before($numberNote, '.')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$numberNote"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <!-- if the first child already is a head, put the marg. heading and everything else behind that (if there are several
                             head, terminate for now) -->
                        <xsl:when test="child::*[1]/self::tei:head">
                            <xsl:if test="child::*[2] = tei:head"><xsl:message terminate="yes"/></xsl:if>
                            <xsl:apply-templates select="child::*[1]"/><xsl:text>&#xa;</xsl:text>
                            <xsl:element name="head">
                                <xsl:attribute name="place" select="'margin'"/>
                                <xsl:attribute name="xml:id" select="$marginalHeading/@xml:id"/>
                                <xsl:attribute name="change" select="concat('#', $changeId)"/>
                                <xsl:apply-templates select="$headContent"/>
                                <xsl:message select="concat('Info: resolving note as head, note/@xml:id = ', $marginalHeading/@xml:id)"/>
                            </xsl:element>
                            <xsl:apply-templates select="child::*[1]/following-sibling::node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="head">
                                <xsl:attribute name="place" select="'margin'"/>
                                <xsl:attribute name="xml:id" select="$marginalHeading/@xml:id"/>
                                <xsl:attribute name="change" select="concat('#', $changeId)"/>
                                <xsl:apply-templates select="$headContent"/>
                                <xsl:message select="concat('Info: resolving note as head, note/@xml:id = ', $marginalHeading/@xml:id)"/>
                            </xsl:element>
                            <xsl:text>&#xa;</xsl:text>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!-- there shouldn't be any articles without numbers: -->
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="concat('Warning: found div without marginal heading: ', @xml:id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:note[ancestor::tei:div[1][@type eq 'article']]">
        <xsl:variable name="margHeading" select="local:getMarginalHeading(ancestor::tei:div[1])"/>
        <xsl:choose>
            <xsl:when test="$margHeading and $margHeading = .">
                <xsl:message select="concat('Info: deleting marginal note, note/@xml:id = ', @xml:id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:div[@type eq 'article' and descendant::tei:milestone[@n]]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="count(descendant::tei:milestone/@n) ne 1">
                <xsl:message terminate="yes"/>
            </xsl:if>
            <xsl:attribute name="n" select="descendant::tei:milestone/@n"/>
            <xsl:message select="concat('Info: added div/@n: ', descendant::tei:milestone/@n)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:milestone[ancestor::tei:div[@type eq 'article']]">
        <xsl:if test="not(@n)">
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:message select="concat('Deleted milestone with @n: ', @n)"/>
    </xsl:template>
    
    
    <xsl:function name="local:getMarginalHeading">
        <xsl:param name="div" as="node()"/>
        <xsl:if test="not($div[@type eq 'article'])">
            <xsl:message terminate="yes" select="'Error: invalid node as parameter in function local:getMarginalHeading()'"/>
        </xsl:if>
        <xsl:variable name="margHead" select="$div//tei:note[@place eq 'margin'][child::node()[1]/self::tei:lb and child::node()[2][self::text()[matches(., '^\d{1,3}')]
                                                                                                                                    or self::tei:supplied[matches(., '^\d{1,3}')]]]"/>
        <xsl:choose>
            <xsl:when test="$margHead">
                <xsl:copy-of select="$margHead"/>
            </xsl:when>
            <xsl:when test="count($margHead) gt 1">
                <xsl:message select="concat('Error: found more than one marginal heading: ', string-join($margHead//@xml:id, ', '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no" select="concat('Warning: could not find a marginal heading for div: ', $div/@xml:id)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
        

</xsl:stylesheet>