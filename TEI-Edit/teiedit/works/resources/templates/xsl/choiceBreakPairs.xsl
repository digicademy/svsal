<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- This program processes choice elements where break elements (pb,cb,lb) appear only in the first (sic, abbr, orig), but not in the second (reg, abbr, expan))
        child element. It adds the respective break element(s) to the second child, interlinking them to those of the first child via @sameAs. 
        To simplify matters, the break elements are set exactly in the middle of the second child's text, regardless of where the break(s) occur within the first child.
        The program only applies to choice elements where the second element consists of nothing but tags (e.g., no special character or hi tagging). -->
    
    <!-- IMPORTANT: run this program BEFORE special characters are tagged in 2nd choice childs, so that 
        2nd choice childs only contain text nodes (but not also g tags) -->
    
    <!-- TODO: make this work with tei:cb as well -->
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string" select="'Wxxxx_change_yyy'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Correct choice/(pb|cb|lb) pairings.'"/>
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
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- 2.) do the actual choice pairing -->
    
    <xsl:variable name="out">
        <xsl:apply-templates/>
    </xsl:variable>
    
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    
    <!-- most practical approach: if pb/lb occurs within 1st choice child, 
                    replicate it after the first special character within the second choice child -->
    <xsl:template match="tei:choice[(child::*[1]/tei:pb or child::*[1]/tei:cb or child::*[1]/tei:lb)
                                    and not(child::*[2]/node()[not(self::text())])]">
        <xsl:if test="count(child::node()) ne count(child::*) or count(child::node()) ne 2">
            <xsl:message terminate="yes" select="concat('Error: element choice in line, ', preceding::tei:lb[@xml:id][1]/@xml:id, ' does not have exactly 2 child elements.')"/>
        </xsl:if>
        <xsl:variable name="pb1" as="element(tei:pb)?" select="./child::*[1]/tei:pb"/>
        <xsl:variable name="cb1" as="element(tei:cb)?" select="./child::*[1]/tei:cb"/>
        <xsl:variable name="lb1" as="element(tei:lb)?" select="./child::*[1]/tei:lb"/><!--'Error: Resolve manually - more than one lb in choice/abbr: //tei:choice//abbr/lb[2] or //tei:choice//sic/lb[2]'-->
        <xsl:if test="($pb1,$cb1,$lb1)/@sameAs and not(($pb1,$cb1,$lb1)/ancestor::*[@place eq 'margin'])">
            <xsl:message terminate="yes" select="'Error: no idea what to do with pb/cb/lb having @sameAs: ', ($pb1,$cb1,$lb1)/@sameAs[1]"/>
        </xsl:if>
        <!-- pair break elements will always be tagged as @break=no and rendition=#noHyphen (#hyphen wouldn't make much sense here...) -->
        <xsl:variable name="pb2" as="element(tei:pb)?">
            <xsl:if test="$pb1">
                <xsl:element name="pb">
                    <xsl:if test="not($pb1/@break eq 'no') or not($pb1/@xml:id)">
                        <xsl:message terminate="yes" select="'Error: element ', $pb1/@xml:id, ' is lacking @break or @xml:id'"/> <!-- if it lacks @xml:id, search for it manually... -->
                    </xsl:if>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="sameAs" select="concat('#', local:findTargetBreakId($pb1))"/>
                    <xsl:attribute name="xml:id" select="concat(generate-id(), '-pb')"/>
                </xsl:element>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="cb2" as="element(tei:cb)?">
            <xsl:if test="$cb1">
                <xsl:element name="cb">
                    <xsl:if test="not($cb1/@break eq 'no') or not($cb1/@xml:id)">
                        <xsl:message terminate="yes" select="'Error: element ', $cb1/@xml:id, ' is lacking @break or @xml:id'"/> <!-- if it lacks @xml:id, search for it manually... -->
                    </xsl:if>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="sameAs" select="concat('#', local:findTargetBreakId($cb1))"/>
                    <xsl:attribute name="xml:id" select="concat(generate-id(), '-cb')"/>
                </xsl:element>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="lb2" as="element(tei:lb)?">
            <xsl:if test="$lb1">
                <xsl:element name="lb">
                    <xsl:if test="not($lb1/@break eq 'no') or not($lb1/@xml:id)">
                        <xsl:message terminate="yes" select="'Error: element ', $lb1/@xml:id, ' is lacking @break or @xml:id'"/> <!-- if it lacks @xml:id, search for it manually... -->
                    </xsl:if>
                    <xsl:attribute name="rendition" select="'#noHyphen'"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="sameAs" select="concat('#', local:findTargetBreakId($lb1))"/>
                    <xsl:attribute name="xml:id" select="concat(generate-id(), '-lb')"/>
                </xsl:element>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(child::*[2]/text())">
            <xsl:message terminate="yes" select="concat('Error: second child element of choice containing break (',($pb1,$cb1,$lb1)/@xml:id[1] ,') does not have any text content.')"/>
        </xsl:if>
        <xsl:variable name="text" as="xs:string" select="child::*[2]/text()"/>
        <xsl:variable name="median" as="xs:integer" select="string-length($text) idiv 2"/>
        <xsl:variable name="text1" as="xs:string" select="substring($text,1,$median)"/>
        <xsl:variable name="text2" as="xs:string" select="substring($text,$median + 1)"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="child::*[1]"/>
            <xsl:element name="{child::*[2]/local-name()}">
                <xsl:copy-of select="child::*[2]/@*"/>
                <xsl:copy-of select="($text1,$pb2,$cb2,$lb2,$text2)"/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
    
    <!-- Finds the xml:id of the break element that is ultimately being referred to. -->
    <xsl:function name="local:findTargetBreakId" as="xs:string">
        <xsl:param name="sameAsNode" as="node()"/>
        <xsl:choose>
            <xsl:when test="$sameAsNode[@sameAs]">
                <xsl:value-of select="substring-after($sameAsNode/@sameAs, '#')"/>
            </xsl:when>
            <xsl:when test="$sameAsNode/@xml:id">
                <xsl:value-of select="$sameAsNode/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'ERROR: node targeted directly via @sameAs does neither have @sameAs or @xml:id.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- CHECKING and LOGGING -->
    
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
        <xsl:variable name="inWhitespace" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="inChars" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="inSpecialChars" as="xs:integer" select="count(//tei:g)"/>
        <xsl:variable name="outSpecialChars" as="xs:integer" select="count($out//tei:g)"/>
        <xsl:variable name="inPb" as="xs:integer" select="count(//tei:pb[not(ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg)])"/>
        <xsl:variable name="outPb" as="xs:integer" select="count($out//tei:pb[not(ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg)])"/>
        <xsl:variable name="inCb" as="xs:integer" select="count(//tei:cb[not(ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg)])"/>
        <xsl:variable name="outCb" as="xs:integer" select="count($out//tei:cb[not(ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg)])"/>
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb[not(ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg)])"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb[not(ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg)])"/>
        <xsl:variable name="addedPb" as="xs:integer" select="count($out//tei:pb[ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg]) 
                                                             - count(//tei:pb[ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg])"/>
        <xsl:variable name="addedCb" as="xs:integer" select="count($out//tei:cb[ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg]) 
                                                             - count(//tei:cb[ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg])"/>
        <xsl:variable name="addedLb" as="xs:integer" select="count($out//tei:lb[ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg]) 
                                                             - count(//tei:lb[ancestor::tei:expan or ancestor::tei:corr or ancestor::tei:reg])"/>
        <!-- checking for illegal breaks: -->
        <xsl:variable name="choiceIncorrectBreaks" as="node()*" select="$out//tei:choice//(tei:abbr|tei:sic|tei:reg)//(tei:lb|tei:cb|tei:pb)[not(preceding-sibling::node() and following-sibling::node())]"/>
        <xsl:choose>
            <xsl:when test="count($choiceIncorrectBreaks) gt 0">
                <xsl:for-each select="$choiceIncorrectBreaks">
                    <xsl:message select="concat('ERROR: found break element within choice/', ./parent::*/local-name(), ', of type ', ./local-name(), 
                                                ' without preceding or following sibling - resolve this manually! (in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' )')"/>
                </xsl:for-each>
                <!-- search these cases: //tei:choice//(tei:abbr|tei:sic|tei:reg)//(tei:lb|tei:cb|tei:pb)[not(preceding-sibling::node() or following-sibling::node())] -->
                <xsl:message terminate="yes"/>
            </xsl:when>
            <xsl:when test="//tei:choice[./*[1]//(tei:pb|tei:cb|tei:lb) and ./*[2][.//tei:g and not(.//(tei:pb|tei:cb|tei:lb))]]">
                <xsl:message terminate="yes" select="concat('WARN: found choice to be resolved, with special char (g) in second child - resolve this manually (in line ', 
                                                     //tei:choice[*[1]//(tei:pb|tei:cb|tei:lb) and *[2][//tei:g and not(//(tei:pb|tei:cb|tei:lb))]][1]/preceding::tei:lb/@xml:id,
                                                     ').')"></xsl:message>
                                                    <!--try the following Xpath in case no lb/@xml:id(s) are not shown. //tei:choice[child::*[1]//(tei:pb|tei:cb|tei:lb) and child::*[2][tei:g and not((tei:pb|tei:cb|tei:lb))]]/preceding::tei:lb[1]/@xml:id-->
            </xsl:when>
            <!-- whitespace and regular symbols -->
            <xsl:when test="$inWhitespace ne $outWhitespace or $inChars ne $outChars">
                <xsl:message select="'ERROR: Numbers of non-whitespace or whitespace characters differ in input and output doc: '"/>
                <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
                <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
                <xsl:message select="concat('Input characters: ', $inChars)"/>
                <xsl:message select="concat('Output characters: ', $outChars)"/>
                <xsl:message terminate="yes"/>
            </xsl:when>
            <!-- breaks -->
            <xsl:when test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
                <xsl:message select="'ERROR: different amount of input and output pb/cb/lb: '"/>
                <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
                <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
                <xsl:message terminate="yes"/>
            </xsl:when>
            <!-- special chars -->
            <xsl:when test="$inSpecialChars ne $outSpecialChars">
                <xsl:message select="'ERROR: different amount of input and output special chars: '"/>
                <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
                <xsl:message terminate="yes"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'INFO: quality check successfull.'"/>
                <xsl:message select="concat('INFO: added ', $addedPb, ' choice/*[2]/pb.')"/>
                <xsl:message select="concat('INFO: added ', $addedCb, ' choice/*[2]/cb.')"/>
                <xsl:message select="concat('INFO: added ', $addedLb, ' choice/*[2]/lb.')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>