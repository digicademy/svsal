<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    xmlns:tite="http://www.tei-c.org/ns/tite/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <xsl:key name="anyNode" match="tei:text//*[@xml:id]" use="@xml:id"/>
    
    
    <!-- make sure that we have defined a transformation for each possible element -->
    <xsl:template match="@*|node()">
        <!-- if there is any node not explicitely defined further below, terminate: -->
        <xsl:message terminate="yes" select="concat('Error: encountered node not specified in the transformation: ', local-name(.))"/>
        <!--<xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>-->
    </xsl:template>
    
    
    <xsl:template match="tei:front|tei:body|tei:back">
        <xsl:copy>
            <xsl:copy-of select="@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div1|tei:div2|tei:div3|tei:div4|tei:div5|tei:div6|tei:div7">
        <xsl:element name="div">
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang|@type"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="tei:titlePage|tei:docTitle">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:byline|tei:docAuthor|tei:publisher">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:pubPlace">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:if test="not(@n) or not(@n = ('thisEd', 'firstEd'))">
                <xsl:message terminate="yes" select="'Error: element pubPlace (on title page) is missing required @n (@role) or has invalid @n.'"/>
            </xsl:if>
            <xsl:attribute name="role" select="@n"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:docEdition">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@when|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:docDate">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@when|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:titlePart">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="@type = ('main', 'sub', 'alt', 'short', 'desc')">
                    <xsl:copy-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'Error: invalid titlePart/@type.'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:docImprint">
        <xsl:choose>
            <xsl:when test="@n = 'imprimatur'">
                <xsl:element name="imprimatur">
                    <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:q">
        <xsl:element name="quote"> 
            <xsl:copy-of select="@*"/>
                <xsl:if test="not(@xml:id)">
                    <xsl:attribute name="xml:id" select="generate-id(.)"/>
                </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:signed">
        <xsl:copy>
            <xsl:copy-of select="@type|@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:list">
        <xsl:copy>
            <xsl:copy-of select="@type|@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:item|tei:label[not(@type eq 'inline')]">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:table|tei:row|tei:cell">
        <xsl:copy>
            <xsl:copy-of select="@cols|@rows|@role|@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang|@type"/>
            <xsl:if test="@target">
                <xsl:attribute name="target">
                    <xsl:variable name="targetNode" select="key('anyNode', substring-after(@target, '#'))"/>
                    <xsl:choose>
                        <xsl:when test="$targetNode">
                            <xsl:value-of select="concat('#', generate-id($targetNode))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="concat('Error: could not find a matching element for ref/@target: ', @target)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:p[not(@rend)]">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:p[@rend eq 'arg']">
        <xsl:element name="argument">
            <xsl:copy>
                <xsl:copy-of select="@type|@resp|@cert|@change|@xml:lang"/>
                <xsl:attribute name="xml:id" select="generate-id(.)"/>
                <xsl:apply-templates/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:argument">
        <xsl:copy>
            <xsl:copy-of select="@type|@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:p[starts-with(@rend, 'h')]">
        <xsl:element name="head">
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang"/>
            <xsl:if test="@rend[. ne 'centered']">
                <xsl:message terminate="yes" select="'Error: element head has unexpected @rend.'"/>
            </xsl:if>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- label[@type='inline'] marks a heading in the text (equal to head, but without an "own" div subdivision) -->
    <xsl:template match="tei:label[@type eq 'inline']">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang"/>
            <xsl:attribute name="place" select="@type"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lg">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:l">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:figure">
        <xsl:choose>
            <!-- tag ornaments properly -->
            <xsl:when test="@type eq 'ornament'">
                <xsl:copy>
                    <xsl:copy-of select="@type|@resp|@cert|@change"/>
                    <xsl:attribute name="place" select="'inline'"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@type eq 'illustration'">
                <xsl:copy>
                    <xsl:copy-of select="@type|@resp|@cert|@change"/>
                </xsl:copy>
            </xsl:when>
            <!-- non-ornament figures: copy, but inform about them -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@resp|@cert|@change|@n|@xml:lang"/>
                    <xsl:message terminate="no" select="concat('Warning: found figure tag, please resolve this manually: pb ', preceding::tei:pb[1]/@n)"/>
                    <xsl:if test="./child::node()">
                        <xsl:message terminate="yes" select="'Error: found unexpected content in element figure.'"/>
                    </xsl:if>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:ornament">
        <xsl:element name="figure">
            <xsl:attribute name="place" select="'inline'"/>
            <xsl:attribute name="type" select="'ornament'"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:pb">
        <xsl:copy>
            <xsl:if test="(not(@n) or normalize-space(@n) eq '' or not(matches(@n, '\[?[\dxivj]{1,7}\]?[rv]?'))) and not(@sameAs)">
                <xsl:message terminate="yes" select="concat('Error: element pb has no @n, or @n has no valid value: ', @n)"/>
            </xsl:if>
            <xsl:copy-of select="@resp|@cert|@change|@n|@sameAs|@type"/>
            <!-- Transform image URLs into Salamanca facs URNs: -->
            <xsl:choose>
                <xsl:when test="@facs">
                    <xsl:variable name="pageURN">
                        <xsl:choose>
                            <xsl:when test="matches(./@facs, '^https?://.*?/W[0-9]{4}-[0-9]{4}\.(jpg|tif)$')">
                                <xsl:value-of select="replace(./@facs, '^.*?(W[0-9]{4}-[0-9]{4})\.(jpg|tif)$', '$1')"/>
                            </xsl:when>
                            <xsl:when test="matches(./@facs, '^https?://.*?/W[0-9]{4}-[A-z]-[0-9]{4}\.(jpg|tif)$')">
                                <xsl:value-of select="replace(./@facs, '^.*?(W[0-9]{4}-[A-z]-[0-9]{4})\.(jpg|tif)$', '$1')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message terminate="yes" select="concat('Error: unknown pb/@facs URL: ', @facs)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:attribute name="facs">
                        <xsl:value-of select="concat('facs:', $pageURN)"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@sameAs">
                    <xsl:variable name="sameAsPb" select="key('anyNode', substring-after(@sameAs, '#'))"/>
                    <xsl:choose>
                        <xsl:when test="$sameAsPb">
                            <xsl:attribute name="sameAs" select="concat('#', generate-id($sameAsPb))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="concat('Error: could not find a matching pb for pb/@sameAs: ', @sameAs)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'Error: element pb has no @facs.'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
        </xsl:copy>
        <!-- check for clustered pb -->
        <xsl:if test="following-sibling::node()[1]/self::tei:pb">
            <xsl:message terminate="yes" select="'Error: multiple pb are clustered.'"/>
        </xsl:if>
    </xsl:template>
        
    <xsl:template match="tei:lb">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@sameAs"/> <!-- this deletes @xml:id, if existing -->
            <!-- check for erroneous lb constructs: -->
            <xsl:choose>
                <xsl:when test="ancestor::tei:note and not(following-sibling::node())">
                    <xsl:message terminate="yes" select="'Error: false lb at the end of note tag.'"/>
                </xsl:when>
                <xsl:when test="following-sibling::node()[1]/self::tei:lb">
                    <xsl:message terminate="yes" select="'Error: multiple lb are clustered.'"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="@xml:id">
                <xsl:attribute name="xml:id" select="generate-id(.)"/>
            </xsl:if>
            <xsl:if test="@sameAs">
                <xsl:variable name="targetLb" select="key('anyNode', substring-after(@sameAs, '#'))"/>
                <xsl:choose>
                    <xsl:when test="$targetLb">
                        <xsl:attribute name="sameAs" select="concat('#', generate-id($targetLb))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="concat('Error: could not find a matching lb for lb/@sameAs: ', @sameAs)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@type eq 'nb'">
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::*[1]/self::tei:pb">
                            <xsl:attribute name="break" select="'no'"/>
                        </xsl:when>
                        <xsl:when test="preceding-sibling::*[1]/self::tei:cb">
                            <xsl:attribute name="break" select="'no'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="break" select="'no'"/>
                            <xsl:attribute name="rendition" select="'#hyphen'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@type ne 'nb'"><xsl:message terminate="yes" select="'ERROR: unknown lb/@type'"/></xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:i">
        <xsl:element name="hi">
            <xsl:attribute name="rendition">#it</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="t:b">
        <xsl:element name="hi">
            <xsl:attribute name="rendition">#b</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="t:smcap">
        <xsl:element name="hi">
            <xsl:attribute name="rendition">#sc</xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="t:sup">
        <xsl:element name="hi">
            <xsl:attribute name="rendition" select="'#sup'"/>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <!-- make sure there are no elements with olden tite prefix: -->
    <!-- TODO: is this even doing anything? -->
    <xsl:template match="tite:*">
        <xsl:message terminate="yes" select="concat('Error: found element with tite:... prefix: ', local-name())"/>
    </xsl:template>
    
    <!-- #### column layout #### -->
    
    <!-- NOTE: this transformation of cb assumes that cb have either been correctly tagged as type="start|end", or that there are tite:colShift as markers 
    for column layout -->
    
    <xsl:template match="tei:cb">
        <xsl:choose>
            <!-- remove cb if occurring directly after colShift[@cols = 1] - the respective cb[@type=start] tagging is performed within a colShift transformation -->
            <xsl:when test="preceding-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::t:colShift[xs:integer(@t:cols) gt 1]">
                <xsl:message select="'INFO: Removing cb at the beginning of column layout change (t:colShift[xs:integer(@cols) gt 1]).'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:if test="@n">
                        <xsl:message select="'WARN: Found cb/@n: refers to actual column number?'"/>
                    </xsl:if>
                    <xsl:copy-of select="@type|@n|@resp|@cert|@change|@sameAs"/>
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="xml:id" select="generate-id(.)"/>
                    </xsl:if>
                    <xsl:if test="@sameAs">
                        <xsl:variable name="targetCb" select="key('anyNode', substring-after(@sameAs, '#'))"/>
                        <xsl:choose>
                            <xsl:when test="$targetCb">
                                <xsl:attribute name="sameAs" select="concat('#', generate-id($targetCb))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message terminate="yes" select="concat('Error: could not find a matching cb for cb/@sameAs: ', @sameAs)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:colShift[@t:cols eq '1']">
        <xsl:element name="cb">
            <xsl:if test="@n">
                <xsl:message select="'WARN: Found cb/@n: refers to actual column number?'"/>
            </xsl:if>
            <xsl:copy-of select="@resp|@cert|@change|@sameAs"/>
            <xsl:attribute name="type" select="'end'"/>
            <xsl:if test="@xml:id">
                <xsl:attribute name="xml:id" select="generate-id(.)"/>
            </xsl:if>
            <xsl:if test="@sameAs">
                <xsl:variable name="targetCb" select="key('anyNode', substring-after(@sameAs, '#'))"/>
                <xsl:choose>
                    <xsl:when test="$targetCb">
                        <xsl:attribute name="sameAs" select="concat('#', generate-id($targetCb))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="concat('ERROR: could not find a matching cb for cb/@sameAs: ', @sameAs)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="t:colShift[xs:integer(@t:cols) gt 1]">
        <xsl:choose>
            <xsl:when test="following-sibling::node()[not(self::text() and normalize-space() eq '')][1]/self::tei:cb">
                <xsl:message select="'INFO: Tagging t:colShift[xs:integer(@cols) gt 1] as @type=start.'"/>
                <xsl:element name="cb">
                    <xsl:if test="@n">
                        <xsl:message select="'WARN: Found cb/@n: refers to actual column number?'"/>
                    </xsl:if>
                    <xsl:copy-of select="@resp|@cert|@change|@sameAs"/>
                    <xsl:attribute name="type" select="'start'"/>
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="xml:id" select="generate-id(.)"/>
                    </xsl:if>
                    <xsl:if test="@sameAs"><xsl:message terminate="yes" select="'ERROR: found unexpected @sameAs in t:colShift[@cols > 1]'"/></xsl:if>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'ERROR: Found tite:colShift marking the beginning of a multi-column layout, but there seems to be no matching cb.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:note[@type='marginalia']">
        <xsl:variable name="xmlId" as="xs:string" select="generate-id(.)"/>
        <xsl:if test="@rend = ('dagger', 'asterisk')">
            <xsl:element name="ref">
                <xsl:attribute name="type" select="'note-anchor'"/>
                <xsl:if test="not(@xml:id)"><xsl:message terminate="yes" select="'ERROR: tei:note element lacks @xml:id.'"/></xsl:if>
                <xsl:attribute name="target" select="concat('#', $xmlId)"/>
                <xsl:value-of select="if (@rend eq 'dagger') then '†' else if (@rend eq 'asterisk') then '*' else error()"/>
            </xsl:element>
        </xsl:if>
        <xsl:copy>
            <xsl:attribute name="place" select="'margin'"/>
            <!--<xsl:copy-of select="local:copyAttributes(., (@resp|@cert|@change|@xml:lang|@anchored), (@n, @type, @xml:id, @rend))"/>--> <!-- must be debugged first -->
            <xsl:choose>
                <xsl:when test="@n">
                    <xsl:choose>
                        <xsl:when test="normalize-space(@n) eq ''">
                            <xsl:message terminate="yes" select="'ERROR: note/@n has no content.'"/>
                        </xsl:when>
                        <xsl:when test="(not(@n) or @n eq 'noRef') and not(@rend = ('asterisk', 'dagger'))">
                            <xsl:attribute name="anchored" select="'false'"/>
                        </xsl:when>
                        <xsl:when test="@n eq 'noRef'"/>
                        <xsl:otherwise>
                            <xsl:copy-of select="@n"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <!-- delete @rend, but check its content -->
            <xsl:if test="@rend and not(@rend = ('dagger', 'asterisk'))">
                <xsl:message terminate="yes" select="'ERROR: unknown value of note/@rend.'"/>
            </xsl:if>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <!-- TODO @n eq dagger or asterisk -->
            <xsl:attribute name="xml:id" select="$xmlId"/>
            <!-- if there are no p sub elements, wrap the whole note content in a single p -->
            <xsl:choose>
                <xsl:when test="not(descendant::tei:p)">
                    <xsl:element name="p">
                        <xsl:attribute name="xml:id" select="concat('mn_', generate-id(.))"/>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:milestone">
        <xsl:copy>
            <xsl:copy-of select="@n|@resp|@cert|@change"/>
            <!-- copy @unit only if it has a valid value -->
            <xsl:choose>
                <xsl:when test="@unit = ('article', 'question', 'section', 'other')">
                    <xsl:copy-of select="@unit"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'Error: milestone/@unit is lacking or has invalid value.'"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- transform @rend to @rendition only if it has an expected value -->
            <xsl:choose>
                <xsl:when test="@rend = ('asterisk', 'dagger')">
                    <xsl:attribute name="rendition" select="concat('#', @rend)"/>
                </xsl:when>
                <xsl:when test="@rend and not(@rend = ('asterisk', 'dagger'))">
                    <xsl:message terminate="yes" select="'Error: milestone/@rend is invalid.'"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="@xml:id">
                <xsl:attribute name="xml:id" select="generate-id(.)"/>
            </xsl:if>
        <xsl:if test="@sameAs">
                <xsl:variable name="targetMilestone" select="key('anyNode', substring-after(@sameAs, '#'))"/>
                <xsl:choose>
                    <xsl:when test="$targetMilestone">
                        <xsl:attribute name="sameAs" select="concat('#', generate-id($targetMilestone))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="concat('Error: could not find a matching milestone for milestone/@sameAs: ', @sameAs)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:hi">
        <xsl:choose>
            <!-- 1.) if value of @rend allowed, transform it to Salamanca value -->
            <xsl:when test="@rend = ('init', 'right', 'centered', 'spaced', 'spc', 'centered spaced', 'spaced italics')">
                <xsl:copy>
                    <xsl:copy-of select="@resp[not(contains(., 'tao'))]|@cert|@change"/>
                    <xsl:choose>
                        <xsl:when test="@rend eq 'init'">
                            <xsl:attribute name="rendition" select="'#initCaps'"/>
                        </xsl:when>
                        <xsl:when test="@rend eq 'right'">
                            <xsl:attribute name="rendition" select="'#right'"/>
                        </xsl:when>
                        <xsl:when test="@rend eq 'centered'">
                            <xsl:attribute name="rendition" select="'#r-center'"/>
                        </xsl:when>
                        <xsl:when test="@rend eq 'spaced' or 'spc'">
                            <xsl:attribute name="rendition" select="'#spc'"/>
                        </xsl:when>
                        <xsl:when test="@rend eq 'spaced italics'">
                            <xsl:attribute name="rendition" select="'#spc #it'"/>
                        </xsl:when>
                        <xsl:when test="@rend eq 'centered spaced'">
                            <xsl:attribute name="rendition" select="'#r-center #spc'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="concat('Error: found unexpected or no hi/@rend: ', @rend)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:copy-of select="@xml:lang"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <!-- 2.) irrelevant values (remove hi element, but keep content): -->
            <!-- a) negative indentation (negEZ) -->
            <xsl:when test="@rend eq 'tao:negEZ'">
                <xsl:apply-templates/>
            </xsl:when>
            <!-- b) font size (W+-x) -->
            <xsl:when test="matches(@rend, 'tao:W[+-]?[1234]?')">
                <xsl:apply-templates/>
            </xsl:when>
            <!-- 3.) if value of hi/@rend is unknown, terminate -->
            <xsl:otherwise>
                <xsl:message terminate="yes" select="concat('Error: unknown value of hi/@rend: ', @rend)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- make sure that rendition information is only stated in tei:hi (except for Tite elements) -->
    <xsl:template match="*[not(self::tei:hi or self::tei:p or self::tei:seg or self::tei:milestone)][@rend or @rendition]">
        <xsl:message terminate="yes" select="concat('Error: @rend or @rendition not allowed in element ', local-name())"/>
    </xsl:template>
    
    
    <xsl:template match="tei:foreign">
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- empty unclear tags are uncertainty marks by the provider; simply copy them -->
    <xsl:template match="tei:unclear">
        <xsl:if test="child::*">
            <xsl:message terminate="yes" select="'Error: found unclear tag with content nodes.'"/>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@resp|@cert|@change|@reason|@xml:lang"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:if test="@* except (@resp, @cert, @change, @reason)">
                <xsl:message terminate="yes" select="'Error: found unexpected attributes in element unclear.'"/>
            </xsl:if>
            <xsl:if test="not(@resp)">
                <xsl:attribute name="resp" select="'#TT'"/>
            </xsl:if>
            <xsl:if test="not(@cert)">
                <xsl:attribute name="cert" select="'unknown'"/>
            </xsl:if>
            <xsl:if test="not(@reason) or @reason eq 'unclear'">
                <xsl:attribute name="reason" select="'unknown'"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Tite does not allow for supplied elements, so any text supplied during manual annotation is annotated using seg[@type eq 'supplied'], to be transformed to supplied. 
    seg/@n must state a reason for @reason. -->
    <xsl:template match="tei:seg[@type eq 'supplied']">
        <xsl:if test="not(@resp and @cert and @n)">
            <xsl:message terminate="yes" select="'Error: supplied text is lacking @resp, @cert and/or @n.'"/>
        </xsl:if>
        <xsl:element name="supplied">
            <xsl:copy-of select="@resp|@cert"/>
            <xsl:attribute name="reason" select="@n"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- gaps are annotated as seg[@type eq 'gap'] -->
    <xsl:template match="tei:seg[@type eq 'gap' or @rend eq 'gap']">
        <xsl:element name="space">
            <xsl:attribute name="dim" select="'horizontal'"/>
            <xsl:attribute name="rendition" select="'#h-gap'"></xsl:attribute>
            <xsl:copy-of select="@resp|@cert|@change|@xml:lang"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:seg[@type eq 'corr']">
        <xsl:element name="corr">
            <xsl:copy-of select="@resp|@cert|@change"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:seg[@type eq 'manicule']">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:g">
        <xsl:choose>
            <xsl:when test="@n eq '#chart0303'">
                <xsl:copy>
                    <xsl:attribute name="ref" select="@n"/>
                    <xsl:value-of select="'t̃'"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@n eq '#char0142'">
                <xsl:copy>
                    <xsl:attribute name="ref" select="@n"/>
                    <xsl:value-of select="'ł'"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'Error: unknown value of g/@n or g/@ref'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Delete remaining TAO markup preserved in comments, and other comments by TK -->
    <xsl:template match="comment()" priority="2">
        <xsl:choose>
            <xsl:when test="matches(normalize-space(.), '^tao:A[-\+][1-9](beg|end)$')"/> <!-- delete font size information -->
            <xsl:when test="matches(normalize-space(.), 'p ergänzt TK')"/> 
            <xsl:when test="matches(normalize-space(.), 'BegTag p ergänzt, TK')"/>
            <xsl:when test="matches(normalize-space(.), 'cb:note_note::cb')"/>
            <xsl:when test="matches(normalize-space(.), '^tao:A[-\+][1-9][_](beg|end)$')"/>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="concat('Error: unexpected comment: ', .)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- check text nodes for unwanted characters -->
    <xsl:template match="text()" priority="2">
        <xsl:variable name="strangeChars" select="('#', '{', '}', '%', '$', '@', '&lt;', '&gt;', '>', '^', '〈', '〉', '〈', '〉')"/>
        <xsl:variable name="quotationMarks" select="('“','”', '„', '»','«', '›', '‹', '&quot;')"/> 
        <xsl:variable name="interestingChars" select="('*')"/>
        <xsl:choose>
            <!-- 1.) check if text nodes contain any control signs from previous transcription/annotation processes -->
            <xsl:when test="some $char in $strangeChars satisfies contains(., $char)">
                <xsl:message terminate="yes" select="concat('Error: special character detected -- resolve this manually: ', .)"/>
            </xsl:when>
            <!-- 2.) check for unresolved quotation marks -->
            <xsl:when test="some $char in $quotationMarks satisfies contains(., $char)">
                <xsl:message terminate="yes" select="concat('Error: quotation mark detected -- resolve this using element q: ', .)"/>
            </xsl:when>
            <!-- 3.) chars that are generally okay, but should be logged: -->
            <xsl:when test="some $char in $interestingChars satisfies contains(., $char)">
                <xsl:message terminate="no" select="concat('Info: encountered special character in text node: ', .)"/>
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- For a given element $elem, copies all attributes of the element that are explicitely stated ($attr) and raises a warning message if the 
         element has attributes other than the ones stated in $attr. Parameter $excAttr may be used to state attributes that shouldn't be copied, 
         but neither should raise an error message (usually, these are attributes for which specific transformations are specified elsewhere, or
         which shall be removed altogether). 
         Simply works like: "From element $elem copy attributes $attr without taking into account attributes $excAttr"
    -->
    <!-- TODO: debugging, and application in all relevant templates -->
    <xsl:function name="local:copyAttributes" as="attribute()*">
        <xsl:param name="elem" as="element()"/>
        <xsl:param name="attr" as="attribute()*"/>
        <xsl:param name="excAttr" as="attribute()*"/>
        <xsl:if test="count($attr intersect $excAttr) gt 0">
            <xsl:message terminate="yes" select="'ERROR: in local:copyAttributes(copyAttributes): attributes that shall be copied cannot be in the list of exceptional attributes as well.'"/>
        </xsl:if>
        <xsl:if test="$elem/@* except ($attr|$excAttr)">
            <xsl:message terminate="yes" select="'WARN: found attribute(s) for which no transformation is specified: ', $elem/@* except ($attr|$excAttr)"/>
        </xsl:if>
        <xsl:copy-of select="$attr"/>
    </xsl:function>
    
    
    <!-- TODO: in case further rules for copying or generating @xml:id are stated, tei:ref needs to be adjusted -->
    
    
    
</xsl:stylesheet>