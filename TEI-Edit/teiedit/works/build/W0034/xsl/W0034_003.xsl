<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:sal="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- stylesheet developed using Saxon-HE 9.6.0.7 -->
    
    <!-- This stylesheet takes a (Salamanca) TEI document as input and adds @xml:id to any given element node -->
    
    <!-- General syntax for xml:id: "$workId-$volumeNumber-$facsNumber-$elementCode-$randomHexId"
    Special cases are lb elements: "$workId-$volumeNumber-$facsNumber-$elementCode-$lineNumber" -->
    
    
    <xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2018-11-28'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0034_change_03'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added @xml:id and line numbering.'"/>
    
    
    <xsl:output method="xml"/> 
    
    <!-- keys relevant for correctly transforming cross-references, see tei:ref below -->
    <xsl:key name="milestone" match="tei:milestone" use="@xml:id"/>
    <xsl:key name="lb" match="tei:lb" use="@xml:id"/>
    <xsl:key name="pb" match="tei:pb" use="@xml:id"/>
    <xsl:key name="p" match="tei:p" use="@xml:id"/>
    <xsl:key name="list" match="tei:list" use="@xml:id"/>
    <xsl:key name="div" match="tei:div" use="@xml:id"/>
    <xsl:key name="item" match="tei:item" use="@xml:id"/>
    <xsl:key name="mnote" match="tei:note[@place='margin']" use="@xml:id"/>
    
    <xsl:variable name="workId" as="xs:string" select="substring(/tei:TEI/@xml:id, 1, 5)"/>
    <xsl:variable name="volumeNumber" as="xs:integer">
        <xsl:choose>
            <xsl:when test="tei:TEI/tei:text/@n">
                <xsl:value-of select="xs:integer(tei:TEI/tei:text/@n)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="volN"  as="xs:string" 
        select="substring(concat('00', string($volumeNumber)), string-length(string($volumeNumber)) + 1, 2)"/>
    
    <!-- (necessary for performance issues:) state maximal number of lines on pages of the work,
    including each line in separate columns AND in the marginal area -->
    <xsl:variable name="maximalLinesOnPage" as="xs:integer" select="250"/> 

    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
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
    
    <xsl:template match="tei:text">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="xs:integer(@n) > 0">
                        <xsl:value-of select="concat('Vol', $volN)"/> <!-- why not with underscore? -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'completeWork'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text/tei:front">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'fm')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text/tei:body">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'tb')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text/tei:back">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'bm')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:titlePage">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'tp')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:titlePart">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'tt')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:div">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'div')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text//tei:head">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'he')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text//tei:p">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'pa')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="tei:text//tei:list">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'li')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:text//tei:item">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'it')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:lg">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'lg')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:text//tei:pb">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:choose>
                <xsl:when test="@sameAs">
                    <xsl:if test="@facs">
                        <xsl:message terminate="yes" select="'Error: pb has @sameAs *and* @facs.'"/>
                    </xsl:if>
                    <xsl:variable name="targetPb" select="key('pb', substring-after(@sameAs, '#'))"/>
                    <xsl:if test="not($targetPb)">
                        <xsl:message terminate="yes" select="'Error: key element variable for lb has no value, or an unacceptable value'"/>
                    </xsl:if>
                    <xsl:attribute name="sameAs" select="concat('#', sal:mkPbId($targetPb, $targetPb/@facs))"/>
                    <xsl:attribute name="xml:id" select="sal:mkPbId(current(), $targetPb/@facs)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="xml:id" select="sal:mkPbId(current(), @facs)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- lb/@xml:id does not use a hex code for the last 4 digits, but precisely states the line number 
        (depending on the area of the text it is in) in the last 4 digits; e.g. "...-0001" first line of main text area, no columns;
        "...-2001" first line in main text area, second column; "...-9001" first line of marginal text area -->
    <xsl:template match="tei:text//tei:lb">
        <xsl:copy>
            <xsl:copy-of select="@* except @n"/> <!-- remove olden @n, if still existing -->
            <xsl:attribute name="xml:id" select="sal:mkLbId(current())"/>
            <!-- if lb is @sameAs, refer to the new xml:id of the target lb -->
            <xsl:if test="@sameAs">
                <xsl:variable name="targetLb" select="key('lb', substring-after(@sameAs, '#'))"/>
                <xsl:choose>
                    <xsl:when test="$targetLb">
                        <xsl:attribute name="sameAs" select="concat('#', sal:mkLbId($targetLb))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="'Error: key element variable for lb has no value, or an unacceptable value'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text//tei:cb">
        <xsl:copy>
            <xsl:if test="@sameAs">
                <xsl:message terminate="yes" select="'Error: cb has @sameAs'"></xsl:message>
            </xsl:if>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id">
                <xsl:variable name="pageFacs" select="preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                <xsl:variable name="pageN" select="substring($pageFacs, string-length($pageFacs) - 3, 4)"/>
                <xsl:variable name="hexId" select="sal:mkHexId(current())"/> 
                <xsl:if test="not($workId and $volN and $pageN and $hexId)">
                    <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
                </xsl:if>
                <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-ti-', $hexId)"/>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text//tei:note[@place='margin']">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'nm')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Milestones: if they already are referenced by means of <ref>, we need also to change the reference according to the new xml:id -->
    <xsl:template match="tei:text//tei:milestone">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id">
                <xsl:value-of select="sal:mkMilestoneId(.)"/>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- adjust ref/@target values to new xml:id of elements (except for those of marginal notes, which happens elsewhere) -->
    <xsl:template match="tei:text//tei:ref[@target and not((substring(@target, 15, 4) eq '_mn_') or (substring(@target, 15, 4) eq '-nm-'))]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="milestone" select="key('milestone', substring-after(@target, '#'))"/>
            <xsl:variable name="p" select="key('p', substring-after(@target, '#'))"/>
            <xsl:variable name="div" select="key('div', substring-after(@target, '#'))"/>
            <xsl:variable name="list" select="key('list', substring-after(@target, '#'))"/>
            <xsl:variable name="item" select="key('item', substring-after(@target, '#'))"/>
            <xsl:variable name="mnote" select="key('mnote', substring-after(@target, '#'))"/>
            <xsl:variable name="pb" select="key('pb', substring-after(@target, '#'))"/>
            <xsl:choose>
                <xsl:when test="$milestone or $p or $div or $list or $item or $mnote or $pb">
                    <xsl:choose>
                        <xsl:when test="$milestone">
                            <xsl:attribute name="target" select="concat('#', sal:mkMilestoneId($milestone))"/>
                        </xsl:when>
                        <xsl:when test="$p">
                            <xsl:attribute name="target" select="concat('#', sal:mkContainerElemId($p, 'pa'))"/>
                        </xsl:when>
                        <xsl:when test="$div">
                            <xsl:attribute name="target" select="concat('#', sal:mkContainerElemId($div, 'div'))"/>
                        </xsl:when>
                        <xsl:when test="$list">
                            <xsl:attribute name="target" select="concat('#', sal:mkContainerElemId($list, 'li'))"/>
                        </xsl:when>
                        <xsl:when test="$item">
                            <xsl:attribute name="target" select="concat('#', sal:mkContainerElemId($item, 'it'))"/>
                        </xsl:when>
                        <xsl:when test="$mnote">
                            <xsl:attribute name="target" select="concat('#', sal:mkContainerElemId($mnote, 'nm'))"/>
                        </xsl:when>
                        <xsl:when test="$pb">
                            <xsl:attribute name="target" select="concat('#', sal:mkPbId($pb, $pb/@facs))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no" select="concat('Error: no key element found for element ', local-name(.), ', @target: ', @target)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:ref[(substring(@target, 15, 4) eq '_mn_') or (substring(@target, 15, 4) eq '-nm-')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="margnote" select="following-sibling::node()[position() &lt; 3 and self::tei:note[@place='margin']][1]"/>
            <xsl:choose>
                <xsl:when test="$margnote">
                    <xsl:variable name="xmlid" as="xs:string">
                        <xsl:variable name="pageFacs">
                            <xsl:choose>
                                <xsl:when test="$margnote/descendant::tei:lb">
                                    <xsl:value-of select="$margnote/descendant::tei:lb[1]/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$margnote/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="pageN" select="substring($pageFacs, string-length($pageFacs) - 3, 4)"/>
                        <xsl:variable name="hexId" select="sal:mkHexId($margnote)"/>
                        <xsl:if test="not($workId and $volN and $pageN and $hexId)">
                            <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
                        </xsl:if>
                        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-nm-', $hexId)"/>
                    </xsl:variable>
                    <xsl:attribute name="target" select="concat('#', $xmlid)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="'Error: found no marginal note to refer to'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text//tei:unclear">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'un')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:text//tei:persName">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'pe')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:placeName">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'pl')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:term">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'te')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:title">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'ti')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>    
    
    <xsl:template match="tei:text//tei:docTitle">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'dt')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!--<xsl:template match="tei:text//tei:byline">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'by')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>-->
    
    <xsl:template match="tei:text//tei:bibl">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'bi')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:supplied">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id" select="sal:mkContainerElemId(current(), 'su')"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:anchor">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:variable name="facs" as="xs:string" select="preceding::tei:pb[not(@sameAs)][1]/@facs"/>
            <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
            <xsl:variable name="hexId" select="sal:mkHexId(current())"/>  
            <xsl:if test="not($workId and $volN and $pageN and $hexId)">
                <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
            </xsl:if>
            <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-an-', $hexId)"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- important: choice must not use @facs from child pb, but may only use preceding pb's @facs -->
    <xsl:template match="tei:text//tei:choice">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/> 
            <xsl:attribute name="xml:id">
                <xsl:variable name="facs" as="xs:string" select="preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
                <xsl:variable name="hexId" select="sal:mkHexId(current())"/>  
                <xsl:if test="not($workId and $volN and $pageN and $hexId)">
                    <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="./tei:corr">
                        <!-- correction of error in print source -->
                        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-cc-', $hexId)"/>
                    </xsl:when>
                    <xsl:when test="./tei:expan">
                        <!-- abbreviation expansion -->
                        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-ce-', $hexId)"/>
                    </xsl:when>
                    <xsl:when test="./tei:reg">
                        <!-- normalization -->
                        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-cr-', $hexId)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-ch-', $hexId)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- delete any xml:id in choice sub-elements -->
    <xsl:template match="tei:sic|tei:corr|tei:abbr|tei:expan|tei:orig|tei:reg">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- Helper functions: -->
    
    <!-- the following function currently is not in use -->
    <!--<xsl:function name="sal:mkEmptyElemId">
        <xsl:param name="elemNode" as="node()"/>
        <xsl:param name="elemCode" as="xs:string"/>
        <xsl:if test="not(string-length($elemCode) eq 2)">
            <xsl:message terminate="yes" select="concat('Error: invalid element code: ', $elemCode)"/>
        </xsl:if>
        <xsl:variable name="facs" as="xs:string" select="$elemNode/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
        <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
        <xsl:variable name="hexId" select="sal:mkHexId($elemNode)"/>  
        <xsl:if test="not($workId and $volN and $pageN and $hexId)">
            <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
        </xsl:if>
        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-', $elemCode, '-', $hexId)"/>
    </xsl:function>-->
    
    <xsl:function name="sal:mkPbId" as="xs:string">
        <xsl:param name="pbNode" as="node()"/>
        <xsl:param name="facs" as="xs:string"/>
        <!-- check syntax of pb/@facs, since this value is of utmost importance for the whole key generation -->
        <xsl:if test="not(matches($facs, '^W[0-9]{4}-[0-9]{4}$')) and not(matches($facs, '^facs:W[0-9]{4}-[A-z]-[0-9]{4}$'))">
            <xsl:message terminate="yes" select="concat('Error: unknown @facs value in element pb: ', $facs)"/>
        </xsl:if>
        <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
        <xsl:variable name="hexId" select="sal:mkHexId($pbNode)"/>  
        <xsl:if test="not($workId and $volN and $pageN and $hexId)">
            <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
        </xsl:if>
        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-pb-', $hexId)"/>
    </xsl:function>
    
    <!-- Create xml:id for lb. 
         The fourth last digit serves as signifier for the type of line that is identified:
         - 0 stands for line in the main area of the text, no column format
         - 1-9 stands for line in the main area in column 1-9
         - m stands for line in the marginal area of the text (regardless of the side (left vs. right))
         - s stands for a line that is not actually a countable line, but needs to be tagged as such for processing reasons,
            refering by means of @sameAs to an "actual" line (lines of this type contain no specific group of digits stating 
            the number/position of the current line, but merely a "random" hexadecimal ID) -->
    <xsl:function name="sal:mkLbId" as="xs:string">
        <xsl:param name="lbNode" as="node()"/>
        <xsl:variable name="lbId" as="xs:string">
            <xsl:choose>
                <!-- if lb is not a genuine line beginning (but refers to one) give it a "-s..." (sameAs) id  -->
                    <xsl:when test="$lbNode/@sameAs">
                        <xsl:variable name="facs" as="xs:string" select="$lbNode/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                        <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
                        <xsl:variable name="hexId" select="sal:mkHexId($lbNode)"/>
                        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-lb-s', substring($hexId, 2, 3))"/>
                    </xsl:when>
                <!-- if lb occurs within a marginal note, create xml:id based on number of previous marginal note lines on the same page and give it a "-m..." id -->
                <!-- within marginal notes, line numbering needs to take into account "virtual" pb elements that merely refer to real pb (using @sameAs). 
                     Thus, we also take into account pb[@sameAs] (unlike in other cases). -->
                <xsl:when test="$lbNode/ancestor::tei:note[@place='margin']"> 
                    <xsl:variable name="currentPage" as="xs:integer" select="count($lbNode/preceding::tei:pb[not(@sameAs)])"/>
                    <xsl:variable name="currentMarginalLineOnPage" as="xs:integer">
                        <xsl:value-of select="count($lbNode/preceding::tei:lb[(not(@sameAs)
                                                                               and position() lt $maximalLinesOnPage) 
                                                                               and (count(./preceding::tei:pb[not(@sameAs)]) = $currentPage) 
                                                                               and ./ancestor::tei:note[@place='margin']]) + 1"/>
                    </xsl:variable>
                    <xsl:variable name="facs" as="xs:string" select="$lbNode/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                    <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
                    <xsl:if test="not($pageN)">
                        <xsl:message terminate="yes" select="'Error: no preceding element pb found for element lb'"/>
                    </xsl:if>
                    <xsl:variable name="marginalLineN"  as="xs:string" 
                            select="substring(concat('000', string($currentMarginalLineOnPage)), string-length(string($currentMarginalLineOnPage)) + 1, 3)"/>
                    <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-lb-m', $marginalLineN)"/>
                </xsl:when>
                    <!-- if lb occurs in the main area of the text, give it a "-0-9..." id, depending on number of columns: -->
                <xsl:otherwise>
                    <xsl:variable name="currentPage" as="xs:integer" select="count($lbNode/preceding::tei:pb[not(@sameAs)])"/>
                    <xsl:variable name="currentColumnOnPage" as="xs:integer" select="count($lbNode/preceding::tei:cb[count(preceding::tei:pb[not(@sameAs)]) = $currentPage])"/>
                    <xsl:if test="$currentColumnOnPage > 9">
                        <xsl:message terminate="yes" select="'Error: illegal number of columns on page'"/>
                    </xsl:if>
                    <xsl:variable name="currentLine" as="xs:integer">
                        <!-- select only lines that do not occur within marginal notes -->
                        <xsl:choose>
                            <!-- if columns exist on page, count the number of lines in the current column -->
                            <xsl:when test="$currentColumnOnPage > 0">
                                <xsl:variable name="previousColumnsInDocument" as="xs:integer" select="count($lbNode/preceding::tei:cb[not(@sameAs)])"/>
                                <xsl:value-of select="count($lbNode/preceding::tei:lb[not(@sameAs) 
                                                                                      and (position() &lt; $maximalLinesOnPage) and (count(preceding::tei:cb[not(@sameAs)]) = $previousColumnsInDocument) 
                                                                                      and not(./ancestor::tei:note[@place='margin'])]) + 1"/>
                            </xsl:when>
                            <!-- if no columns exist on page, count lines since page beginning -->
                            <xsl:otherwise>
                                <xsl:value-of select="count($lbNode/preceding::tei:lb[not(@sameAs) 
                                                                                      and (position() &lt; $maximalLinesOnPage) 
                                                                                      and (count(preceding::tei:pb[not(@sameAs)]) = $currentPage) 
                                                                                      and not(ancestor::tei:note[@place='margin'])]) + 1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="facs" as="xs:string" select="$lbNode/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                    <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
                    <xsl:variable name="lineNumber" as="xs:string">
                        <xsl:variable name="columnN" as="xs:string" select="string($currentColumnOnPage)"/>
                        <xsl:variable name="lineN"  as="xs:string" 
                            select="substring(concat('000', string($currentLine)), string-length(string($currentLine)) + 1, 3)"/>
                        <xsl:value-of select="concat($columnN, $lineN)"/>
                    </xsl:variable>
                    <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-lb-', $lineNumber)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(string-length($lbId) eq 21)">
            <xsl:message terminate="yes" select="'Error: invalid xml:id length for element lb.'"/>
        </xsl:if>
        <xsl:value-of select="$lbId"/>
        <!-- ATTENTION: this function has currently one flaw: if lb occurs directly after a pb[@sameAs], it will use 
        the previous pb (not having @sameAs) for numbering; the same applies with cb[@sameAs] -->
    </xsl:function>
    
    <!-- create an xml:id value for milestone, following the schema stated above (using hexId at the end) -->
    <xsl:function name="sal:mkMilestoneId" as="xs:string">
        <xsl:param name="milestoneNode" as="node()"/>
        <xsl:variable name="facs" as="xs:string" select="$milestoneNode/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
        <xsl:variable name="pageN" select="substring($facs, string-length($facs) - 3, 4)"/>
        <xsl:variable name="hexId" select="sal:mkHexId($milestoneNode)"/>  
        <xsl:if test="not($workId and $volN and $pageN and $hexId)">
            <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
        </xsl:if>
        <xsl:if test="not(string-length(concat($workId, '-', $volN, '-', $pageN, '-mi-', $hexId)) eq 21)">
            <xsl:message terminate="yes" select="'Error: invalid xml:id length for element milestone.'"/>
        </xsl:if>
        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-mi-', $hexId)"/>
    </xsl:function>
    
    <!-- Creates a complete xml:id value for elements that may contain element pb -->
    <xsl:function name="sal:mkContainerElemId" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="elemCode" as="xs:string"/>
        <xsl:if test="not(string-length($elemCode) eq 2 or $elemCode eq 'div')">
            <xsl:message terminate="yes" select="concat('Error: invalid element code: ', $elemCode)"/>
        </xsl:if>
        <xsl:variable name="pageFacs">
            <xsl:choose>
                <xsl:when test="$node/descendant::tei:lb">
                    <xsl:value-of select="$node/descendant::tei:lb[1]/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node/preceding::tei:pb[not(@sameAs)][1]/@facs"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="pageN" select="substring($pageFacs, string-length($pageFacs) - 3, 4)"/>
        <xsl:variable name="hexId" select="sal:mkHexId($node)"/>  
        <xsl:if test="not($workId and $volN and $pageN and $hexId)">
            <xsl:message terminate="yes" select="'Error: required variables have null values'"/>
        </xsl:if>
        <xsl:variable name="code" as="xs:string">
            <xsl:choose>
                <!-- for div elements, make specific code including their levels in the div hierarchy -->
                <xsl:when test="$elemCode eq 'div' and (count($node/ancestor::tei:div) + 1) lt 10">
                    <xsl:variable name="divN" as="xs:string" select="$node/xs:string(count(ancestor::tei:div) + 1)"/>
                    <xsl:value-of select="concat('d', $divN)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$elemCode"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(string-length(concat($workId, '-', $volN, '-', $pageN, '-', $code, '-', $hexId)) eq 21)">
            <xsl:message terminate="yes" select="concat('Error: invalid xml:id length for element ', local-name($node))"/>
        </xsl:if>
        <xsl:value-of select="concat($workId, '-', $volN, '-', $pageN, '-', $code, '-', $hexId)"/>
    </xsl:function>
    
    <!-- create a 4-digit hexcode that is unique at least for one page, using the number of preceding text nodes and nodes of the same name  -->
    <xsl:function name="sal:mkHexId" as="xs:string">
        <xsl:param name="targetNode" as="node()"/>
        <!-- convert decimal integer to hexadecimal -->
        <xsl:variable name="hexString">
            <xsl:choose>
                <!-- calculate a hexadecimal 4-digit number based on number of preceding and ancestral elements of the same type and the addition 
                    of an arbitrary value for "random" numbering; 
                    elements in notes might have the same number of preceding elements as those in their parent 
                    p elements, so we add a different number to that -->
                <xsl:when test="$targetNode[ancestor::tei:note]">
                    <xsl:value-of select="sal:decToHex(count($targetNode/preceding::node()[./name() eq $targetNode/name()]) + 2000)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="preceding" as="xs:integer" select="count($targetNode/preceding::*[./name() eq $targetNode/name()])"/>
                    <xsl:variable name="ancestral" as="xs:integer" select="count($targetNode/ancestor::*[./name() eq $targetNode/name()])"/>
                    <!-- multiplicate $ancestral by 300 so as to avoid collisions with other elements on the same page -->
                    <xsl:value-of select="sal:decToHex($preceding + ($ancestral * 300) + 1000)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- make surto return a 4-digit string -->
        <xsl:choose>
            <xsl:when test="string-length($hexString) &lt; 4">
                <xsl:value-of select="substring(concat('0000', string($hexString)), string-length(string($hexString)) + 1, 4)"/>
            </xsl:when>
            <xsl:when test="string-length($hexString) eq 4">
                <xsl:value-of select="$hexString"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($hexString, string-length($hexString) - 3, 4)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- taken from https://stackoverflow.com/questions/5482860/xslt-converting-characters-to-their-hexadecimal-unicode-representation -->
    <xsl:function name="sal:decToHex" as="xs:string">
        <xsl:param name="in" as="xs:integer"/>
        <xsl:sequence
        select="if ($in eq 0) then '0'
        else concat(if ($in ge 16) then sal:decToHex($in idiv 16) else '',
            substring('0123456789abcdef',
            ($in mod 16) + 1, 1))"/>
    </xsl:function>

    
    
    <!-- TODO 
        - tei:cb, @type='start' | @type='end'...
    -->
    
    <!-- currently used infixes:
    
    - fm (front matter - front)
    - tb (text body - text)
    - bm (back matter - back)
    - tp (title page - titlePage)
    - mt (main title, titlePart[@type='main'] )
    - dX (div, X stands for number of level (usually 1-7))
    - he (heading - head)
    - it (item)
    - li (list)
    - pa (paragraph - p)
    - pb (page beginning - pb)
    - lb (line beginning - lb)
    - nm (note, marginal - note[@place='margin'])
    - mi (milestone, any type)
    - un (unclear)
    - lg (lg)
    - pe (persName)
    - pl (placeName)
    - te (term)
    - ti (title)
    - an (anchor)
    - dt (docTitle)
    - bi (bibl)
    - cc (choice with corr)
    - ce (choice with expan)
    - cr (choice with reg)
    - ch (choice, not further defined)
    - su (supplied)
    
    -->
    
    <!-- TODO: 
        - damage, del, damageSpan, delSpan -> xml:id and references to anchor elements -->
    
    
</xsl:stylesheet>