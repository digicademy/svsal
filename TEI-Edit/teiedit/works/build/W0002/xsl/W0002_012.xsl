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
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-08-06'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0002_change_0016'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Reduced excessive hi/@rendition[#it] in summaries.'"/>
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
    
    <xsl:template match="tei:text//tei:list[@type='summaries']//tei:item">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- we first do some checking: if the text in a given list[@type='summaries']//item is wrapped in several
                hi[@rendition='#it'] - except for whitespace-only nodes and nodes wrapped in ref -, the whole thing shall be wrapped in one 
                large hi[@rendition='#it'], the various single hi[@rendition='#it'] being deleted and text in ref being wrapped in 
                hi[@rendition='#recte']  -->
            <xsl:choose>
                <!-- checking whether there are several hi[@rendition=#it] at all -->
                <xsl:when test="count(//tei:hi[@rendition eq '#it']) gt 1">
                    <xsl:choose>
                        <!-- for safety reasons, we process only those items in a particular way which do not contain text nodes satisfying all of the following preconditions:
                                 - already wrapped in hi or ref
                                 - whitespace-only node containing newline or merely blanks
                                 - short-length text node containing a specific character (Tao-Trier had a predilection for isolating single characters, 
                                   such as "j" or ":", from hi[@rendition=#it] elements in the context; some of them are correctly tagged, given the 
                                   typographic features of the original facsimile, but we resolve these short-text instances nonetheless since 
                                   they do not carry any special meaning and for not having a large hi[@rendition] overhead in the final document.) 
                                   attention: these conditions are specific only for W0002 and may be different with other works
                        -->
                        <xsl:when test=".//text()[not(ancestor::tei:hi[@rendition eq '#it'] or ancestor::tei:ref)
                                                  and not(normalize-space(.) eq '' and (matches(., '\n') or matches(., '^ +$')))
                                                  and not(matches(., '^ ?[,:Ojisu\?\(\)]\.? ?$'))]">
                            <xsl:message select="'Info: found item containing text node(s) with undefined form; applying default processing.'"/>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message select="'Info: reducing several hi[@rendition=#it] within item, and tagging ref as #rt.'"/>
                            <xsl:element name="hi">
                                <xsl:attribute name="rendition" select="'#it'"/>
                                <xsl:apply-templates mode="delete-hi"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- no multiple hi, do default processing (silently) -->
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:hi[@rendition eq '#it']" mode="delete-hi">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:ref" mode="delete-hi">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="current()//text()[ancestor::tei:hi[@rendition eq '#it']]">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="hi">
                        <xsl:attribute name="rendition" select="'#rt'"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- identity transform within item -->
    <xsl:template match="@*|node()[not(self::tei:hi[@rendition eq '#it'] or self::tei:ref)]" mode="delete-hi">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    

</xsl:stylesheet>