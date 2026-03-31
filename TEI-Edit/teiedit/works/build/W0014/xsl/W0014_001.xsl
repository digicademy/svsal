<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    
    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- decrement all facs links from ...0140.jpg to ...0271.jpg by 1; rename ...0999.jpg to ...0271.jpg -->
            <xsl:if test="not(@sameAs)">
                <xsl:variable name="facsN" as="xs:integer" select="xs:integer(substring-before(substring-after(@facs, 'images/W0014/W0014-'), '.jpg'))"/>
                <xsl:choose>
                    <xsl:when test="$facsN ge 140 and $facsN le 271">
                        <xsl:variable name="newFacsN" as="xs:integer" select="$facsN -1"/>
                        <xsl:attribute name="facs" select="replace(@facs, '\d\d\d\.jpg$', concat(string($newFacsN), '.jpg'))"/>
                    </xsl:when>
                    <!-- the actual facs ...0271.jpg was provisionally marked as 0999.jpg -->
                    <xsl:when test="ends-with(@facs, '0999.jpg')">
                        <xsl:attribute name="facs" select="replace(@facs, '0999\.jpg$', '0271.jpg')"/>
                    </xsl:when>
                </xsl:choose>
                <!-- paginate those pb that are still unpaginated -->
                <xsl:choose>
                    <!-- those @n without any value are verso pages -->
                    <xsl:when test="@n eq ''">
                        <xsl:variable name="rectoN" as="xs:string">
                            <xsl:choose>
                                <!-- TODO: something here isn't quite working... -->
                                <xsl:when test="matches(preceding::tei:pb[not(@sameAs)][1]/@n, '\[\d{2,3}\]r')">
                                    <xsl:value-of select="substring-before(substring-after(preceding::tei:pb[not(@sameAs)][1]/@n, '['), ']')"/>
                                </xsl:when>
                                <xsl:when test="matches(preceding::tei:pb[not(@sameAs)][1]/@n, '\d{2,3}')">
                                    <xsl:value-of select="preceding::tei:pb[not(@sameAs)][1]/@n"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message terminate="yes" select="concat('Error: could not get valid recto page number for preceding pb: ', 
                                                                                preceding::tei:pb[not(@sameAs)][1]/@n)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:attribute name="n" select="concat('[', $rectoN, ']v')"/>
                    </xsl:when>
                    <!-- there are some recto pages without trailing "r" -->
                    <xsl:when test="matches(@n, '^\[?\d{1,3}\]?$')">
                        <xsl:attribute name="n" select="concat(@n, 'r')"/>
                    </xsl:when>
                    <!-- all other @n should have valid values -->
                    <xsl:otherwise>
                        <xsl:if test="not(matches(@n, '^\[?[\dijvx]{1,4}\]?[rv]$'))">
                            <xsl:message terminate="yes"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>