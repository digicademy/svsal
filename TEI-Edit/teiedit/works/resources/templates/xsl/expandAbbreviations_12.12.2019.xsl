<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Rule-based abbreviation expansion. -->
    
    <!-- IMPORTANT: 
        in order for this stylesheet to work as expected, special characters declared in the 
        charDecl must already have been marked up throughout the entire input text
    -->
    
    <!-- current constraints: 
        - does not cover hyphenating abbreviations (e.g., " aũ<lb/>q̃ ")
        - does not resolve abbr. at the very end of lines (e.g., q̃<lb/>), since it doesn't know in these cases whether an abbr. is complete 
          or only the prefix of a larger, line-spanning abbr.
    -->
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- !! PARAMETERS (must be adjusted here, or injected as arguments) !! -->
    
    <!-- the language of the text parts in which abbreviations are to be resolved; must be stated depending on the $mode param (see below) -->
    <xsl:param name="lang"/>
    <!-- the "mode" for resolving abbreviations: 
             - if no mode is given, all text parts are analyzed according to their language (see param $lang) 
                    (should be safe if all sections/notes have been tagged correctly with @xml:lang)
             - 'main' analyzes abbr. only in the main parts of the text
             - 'marginal' analyzes abbr. only in the marginal parts of the text -->
    <xsl:param name="mode"/>
    <!-- Determines whether to start searching for abbreviations at the very beginning of lines, no matter how the previous line ended. 
         May lead to problems if an abbreviation traverses a line break and the part after the line break is itself registered as a (smaller) abbreviation.
         (Example: " aũ<lb/>q̃ ", where "aũq̃" is a registered abbreviation (aunque), but so is "q̃" (que) as well.) -->
    <xsl:param name="startAtLineBeginning" as="xs:boolean"/>
    <!-- List of abbreviations & expansions: choose it according to the $lang (see above) of the text parts to be analyzed -->
    <xsl:param name="abbrExpanFile" as="xs:string" select="concat('../config/abbr-', $lang, '.xml')"/>
    <!-- List of special characters -->
    <xsl:param name="specialCharFile" as="xs:string" select="'../../../resources/chars/specialchars_2020-11-06.xml'"/>
    
    <!-- The usual stuff: -->
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string"/>
    <xsl:param name="editingDesc" as="xs:string" select="concat('Automatically expanded abbreviations (', $lang, '-',$mode,').')"/>
    
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- 0.) Global config -->
    
    <xsl:output method="xml"/> 
    
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="make-choice">
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
            <xsl:apply-templates mode="make-choice"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- general TODOs: 
        - $startAtLineBeginning currently has no effect with text-only abbreviations (e.g., "atq;") such that these abbreviations will not be resolved 
          when occurring at the beginning of a line; however, since there aren't many such abbreviations, this should be manageable manually
        - additional word delimiters,such as \. ? include generic '\s' (problem with unmarked linebreaks...)? elements as delimiters?
        - are there some node sequences that *always* represent the same abbr., regardless of being delimited to the right/left (i.e. they are never infixes of other abbr.)?
        - expand abbreviations with arbitrary stem (e.g. - *chare8bf (* = word prefix) -> *que) : add wildcard option to abbrPart[@type eq 'text']
        - include function for tolerating differences of u-v or i-j? (j-x?)
    -->
    
    <!-- currently, only in-line tokens are analyzed for abbr. expan., not tokens occurring at the very beginning/end of a line -->
    <xsl:variable name="wordDelimiters" as="xs:string" select="'[, \?!\(\)\*\+✝]'"/> <!-- this is a *regex*, and special regex symbols need to be escaped. 
        For texts inpanish texts can be added the characters \.:; --> 
    <!-- load external resources and sanitize input -->
    <xsl:variable name="abbrExpanList" as="element(local:abbrExpanList)" select="doc($abbrExpanFile)/local:abbrExpanList"/>
    <xsl:variable name="specialCharacters" as="element(tei:char)+" select="doc($specialCharFile)//tei:teiHeader//tei:charDecl//tei:char"/>
    <xsl:variable name="sanitizeInput">
        <xsl:if test="not($lang = ('es', 'la')) or not($mode = ('main', 'marginal'))">
            <xsl:message terminate="yes" select="'ERROR: illegal input values for parameters $lang (must be one of -es- or -la-) or $mode (must be one of -main- or -marginal-)'"/>
        </xsl:if>
    </xsl:variable>
    
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- 1.) Identify abbreviations -->
    
    <xsl:variable name="identifiedAbbr">
        <xsl:apply-templates select="/" mode="identify-abbr"/>
        <xsl:message select="'INFO: identified abbreviations.'"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="identify-abbr">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="identify-abbr"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[local:relevantLangMode(.) and count(local:getAbbrBeginning(.)) ge 1]" mode="identify-abbr">
        <xsl:variable name="getAbbrBeg" as="xs:string+" select="local:getAbbrBeginning(.)"/>
        <xsl:choose>
            <!-- special case: abbreviations fully contained within the text node - we create choice/abbr/expan right here -->
            <xsl:when test="$getAbbrBeg[2] eq 'single-text'">
                <xsl:variable name="thisNode" as="node()" select="."/>
                <xsl:variable name="singleRegex" as="xs:string" select="concat('(',$wordDelimiters, ')(', $getAbbrBeg[3], $wordDelimiters, ')')"/>
                <xsl:analyze-string select="." regex="{$singleRegex}">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                        <xsl:element name="abbrBeg" namespace="http://salamanca.adwmainz.de">
                            <xsl:attribute name="n" select="$getAbbrBeg[1]"/>
                            <xsl:attribute name="reach" select="'1'"/>
                            <xsl:attribute name="endsWith" select="$getAbbrBeg[3]"/>
                        </xsl:element>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <!-- usual case: text node contains only the beginning of an abbr. -->
            <xsl:otherwise>
                <xsl:variable name="begRegex" as="xs:string" select="concat($abbrExpanList/local:abbrExpan[@xml:id eq $getAbbrBeg[1]]/local:abbreviation/local:abbrPart[1]/text(), '$')"/>
                <xsl:analyze-string select="." regex="{$begRegex}">
                    <xsl:matching-substring>
                        <xsl:element name="abbrBeg" namespace="http://salamanca.adwmainz.de">
                            <xsl:attribute name="n" select="$getAbbrBeg[1]"/>
                            <xsl:attribute name="reach" select="$getAbbrBeg[2]"/>
                            <xsl:if test="$getAbbrBeg[3]">
                                <xsl:attribute name="endsWith" select="$getAbbrBeg[3]"/>
                            </xsl:if>
                        </xsl:element>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:g[local:relevantLangMode(.) and count(local:getAbbrBeginning(.)) ge 1]" mode="identify-abbr">
        <xsl:variable name="getAbbrBeg" as="xs:string+" select="local:getAbbrBeginning(.)"/>
        <xsl:element name="abbrBeg" namespace="http://salamanca.adwmainz.de">
            <xsl:attribute name="n" select="$getAbbrBeg[1]"/>
            <xsl:attribute name="reach" select="$getAbbrBeg[2]"/>
            <xsl:if test="$getAbbrBeg[3]">
                <xsl:attribute name="endsWith" select="$getAbbrBeg[3]"/>
            </xsl:if>
        </xsl:element>
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- Determines whether a node is potentially relevant, given the stated mode and language, for abbreviation expansion. Also makes sure
         that the node hasn't been tagged already as some kind of normalization -->
    <xsl:function name="local:relevantLangMode" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="normElements" as="xs:string+"
            select="('choice', 'orig', 'reg', 'sic', 'corr', 'abbr', 'expan')"/>
        <xsl:choose>
            <!-- if the node occurs within a "normalization" element, we refrain from doing any further normalization -->
            <xsl:when test="$node/ancestor::*[local-name(.) = $normElements]">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$mode eq 'main'">
                <xsl:choose>
                    <xsl:when test="not($node/ancestor::*[@place eq 'margin']) and $node/ancestor::*[@xml:lang][1]/@xml:lang eq $lang">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$mode eq 'marginal'">
                <xsl:choose>
                    <xsl:when test="$node/ancestor::*[@place eq 'margin'] and $node/ancestor::*[@xml:lang][1]/@xml:lang eq $lang">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node/ancestor::*[@xml:lang][1]/@xml:lang eq $lang">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- Determines whether a node is the beginning of an abbreviation. If this is the case, a tuple containing the following strings 
        is returned:
        - 1) the @xml:id of a matching abbrExpan element from the abbrExpan list
        - 2) the reach of the abbreviation, expressed as a number stating how many nodes are part of the abbreviation token, counted from the supposed beginning of the 
             abbreviation
             (special case: 'single-text' (instead of number) signifies an abbreviation within a single text node)
        - 3) (optional) if the last node of the abbreviation sequence is contained within a text node, the (sub-)string of that node that still is part of the 
            abbreviation (so that the next transformation step knows where to set the cut within text nodes that contain the endings of abbreviations)
        Otherwise, the empty sequence is returned. -->
    <xsl:function name="local:getAbbrBeginning" as="xs:string*">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <xsl:when test="$node/self::text()">
                <xsl:choose>
                    <!-- abbreviations that are within a single text node -->
                    <!-- TODO: $startAtLineBeginning currently has no effect here... -->
                    <xsl:when test="some $ae in $abbrExpanList//local:abbrPart[@type eq 'text' and not(preceding-sibling::* or following-sibling::*)] 
                                        satisfies matches($node, concat($wordDelimiters, $ae/text(), $wordDelimiters))">
                        <xsl:variable name="singleTextAbbr" as="element(local:abbrPart)" 
                            select="$abbrExpanList//local:abbrPart[@type eq 'text' and not(preceding-sibling::* or following-sibling::*)
                                                                       and matches($node, concat($wordDelimiters, ./text(), $wordDelimiters))]"/>
                        <xsl:copy-of select="($singleTextAbbr/ancestor::local:abbrExpan/@xml:id, 'single-text', $singleTextAbbr/text())"/>
                        
                    </xsl:when>
                    <!-- multi-node abbreviations -->
                    <xsl:otherwise>
                        <xsl:variable name="abbrCandidates" as="element(local:abbrPart)*" 
                            select="$abbrExpanList/local:abbrExpan/local:abbreviation/local:abbrPart[1][@type eq 'text' 
                                    and (matches($node, concat($wordDelimiters, ./text(), '$')) or (matches($node, concat('^', ./text(), '$')) and local:isDelimitedLeft($node)))]"/>
                        <xsl:variable name="actualAbbr" as="xs:string*">
                            <xsl:for-each select="$abbrCandidates">
                                <xsl:variable name="followingAbbrParts" as="element(local:abbrPart)*" select="./following-sibling::local:abbrPart"/>
                                <!-- in case there are no followingAbbrParts, the node must be a single (special character) brevigraph, which is dealt with below -->
                                <xsl:if test="count($followingAbbrParts) ge 1
                                              and local:followingAbbrNodesAreEqual($followingAbbrParts, $node/following-sibling::node()[position() le count($followingAbbrParts)])">
                                    <xsl:copy-of select="(./ancestor::local:abbrExpan/@xml:id, 
                                                          string(count($followingAbbrParts) + 1), 
                                                          if ($followingAbbrParts[last()]/@type eq 'text') then $followingAbbrParts[last()]/text() else ())"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <!-- the resulting sequence must either be empty, or have 2 or 3 string items -->
                            <xsl:when test="count($actualAbbr) = (0,2,3)"><xsl:copy-of select="$actualAbbr"/></xsl:when>
                            <xsl:otherwise>
                                <xsl:message terminate="yes" select="concat('ERROR: found more than 1 abbrExpan element for abbreviation defined in abbrExpan/@type ', $actualAbbr[1], ': ', 
                                    count($actualAbbr), ' return values in total in function local:getAbbrBeginning() ( ', string-join($actualAbbr, ' | '), ' ).', 
                                    ' Perhaps an error in the abbrExpan list (e.g., multiple abbrExpan of the same type)?')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node/self::tei:g">
                <xsl:choose>
                    <!-- single-tei:g brevigraphs -->
                    <xsl:when test="local:isDelimitedLeft($node) 
                                    and local:isDelimitedRight($node) 
                                    and $abbrExpanList//local:abbrPart[@type eq 'g' and ./text() eq $node/@ref and not(following-sibling::* or preceding-sibling::*)]">
                        <xsl:copy-of select="($abbrExpanList//local:abbrPart[@type eq 'g' and ./text() eq $node/@ref and not(following-sibling::* or preceding-sibling::*)]/ancestor::local:abbrExpan/@xml:id,
                                              '1')"/> <!-- reach=1 in the case of single brevigraphs; endsWith not necessary -->
                    </xsl:when>
                    <!-- multi-node abbreviations -->
                    <xsl:when test="local:isDelimitedLeft($node)">
                        <xsl:variable name="abbrCandidates" as="element(local:abbrPart)*" 
                            select="$abbrExpanList/local:abbrExpan/local:abbreviation/local:abbrPart[1][@type eq 'g' and $node/@ref eq ./text()]"/>
                        <xsl:variable name="actualAbbr" as="xs:string*">
                            <xsl:for-each select="$abbrCandidates">
                                <xsl:variable name="followingAbbrParts" as="element(local:abbrPart)*" select="./following-sibling::local:abbrPart"/>
                                <xsl:if test="count($followingAbbrParts) ge 1
                                              and local:followingAbbrNodesAreEqual($followingAbbrParts, $node/following-sibling::node()[position() le count($followingAbbrParts)])">
                                    <xsl:copy-of select="(./ancestor::local:abbrExpan/@xml:id, 
                                                          string(count($followingAbbrParts) + 1), 
                                                          if ($followingAbbrParts[last()]/@type eq 'text') then $followingAbbrParts[last()]/text() else ())"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:choose>
                            <!-- the resulting sequence must either be empty, or have 2 or 3 string items -->
                            <xsl:when test="count($actualAbbr) = (0,2,3)"><xsl:copy-of select="$actualAbbr"/></xsl:when>
                            <xsl:otherwise>
                                <xsl:message terminate="yes" select="concat('ERROR: found more than 1 abbrExpan element for abbreviation defined in abbrExpan/@type ', $actualAbbr[1], ': ', 
                                    count($actualAbbr), ' return values in total in function local:getAbbrBeginning() ( ', string-join($actualAbbr, ' | '), ' ).', 
                                    ' Perhaps an error in the abbrExpan list (e.g., multiple abbrExpan of the same type)?')"/>
                            </xsl:otherwise>
                       </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:message terminate="yes" select="concat('ERROR: wrong input node in local:isAbbrBeginning() of type: ', local-name($node))"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- Compares two sequences, one consisting of abbrPart nodes and the other of nodes from the text. -->
    <xsl:function name="local:followingAbbrNodesAreEqual" as="xs:boolean">
        <xsl:param name="seq1" as="element(local:abbrPart)*"/>
        <xsl:param name="seq2" as="node()*"/>
        <xsl:choose>
            <xsl:when test="empty($seq1)">
                <!--<xsl:value-of select="true()"/>-->
                <xsl:message terminate="yes" select="'ERROR: called local:followingAbbrNodesAreEqual() with empty first sequence.'"/>
            </xsl:when>
            <xsl:when test="count($seq1) ne count($seq2)"><xsl:value-of select="false()"/></xsl:when>
            <xsl:otherwise>
                <!-- compare sequences node by node - in case of a non-match, return 0 -->
                <xsl:variable name="sequencesComparison" as="xs:integer+">
                    <xsl:for-each select="$seq1">
                        <xsl:variable name="i" as="xs:integer" select="position()"/>
                        <xsl:choose>
                            <xsl:when test="$i eq count($seq1)">
                                <xsl:value-of select="local:compareAbbrNodes(., $seq2[$i], 'last')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="local:compareAbbrNodes(., $seq2[$i], ())"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="not(0 = $sequencesComparison)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Compares a node from the abbrExpanList (abbrPart) with a node from the text. Returns 1 if nodes are considered equal, 0 if not -->
    <xsl:function name="local:compareAbbrNodes" as="xs:integer">
        <xsl:param name="node1" as="element(local:abbrPart)"/>
        <xsl:param name="node2" as="node()"/>
        <xsl:param name="mode" as="xs:string?"/>
        <xsl:if test="$node1[not(text())]">
            <xsl:message terminate="yes" select="concat('ERROR: found element abbrPart without text content, in abbrExpan ', $node1/ancestor::local:abbrExpan/@xml:id)"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$node1/@type eq 'text'">
                <xsl:choose>
                    <xsl:when test="$mode eq 'last'">
                        <xsl:choose>
                            <xsl:when test="matches($node2[self::text()], concat('^', $node1/text(), $wordDelimiters))">
                                <xsl:value-of select="1"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$node2/self::text() and $node2 eq $node1/text()"><xsl:value-of select="1"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$node1/@type eq 'g'">
                <xsl:choose>
                    <xsl:when test="$mode eq 'last'">
                        <xsl:choose>
                            <xsl:when test="$node2/self::tei:g[@ref eq $node1/text()] and local:isDelimitedRight($node2)">
                                <xsl:if test="not(local:isValidCharRef($node1/text()))"><xsl:message terminate="yes" select="concat('ERROR: invalid char reference: ', $node1/text(), ' (char not defined in specialchars.xml) - fix your abbreviation list!')"/></xsl:if>
                                <xsl:value-of select="1"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$node2/self::tei:g[@ref eq $node1/text()]"><xsl:value-of select="1"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'ERROR: unknown abbrPart/@type: ', $node1/@type, ' - get your abbreviation list right!'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Determines whether a node (tei:g or text()) is delimited to the left by means of structural or typographical items that may 
         indicate the beginning of an abbreviation. -->
    <xsl:function name="local:isDelimitedLeft" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:if test="not($node[self::text() or self::tei:g])">
            <xsl:message terminate="yes" select="'ERROR: invalid parameter value for node in local:isDelimitedLeft()'"/>
        </xsl:if>
        <xsl:variable name="delimiterElems" as="xs:string+" select="('lb')"/> <!-- other elements? -->
        <xsl:choose>
            <!-- a) delimitation indicated by specific text characters -->
            <xsl:when test="$node/self::tei:g and $node/preceding-sibling::node()[1]/self::text()[matches(., concat($wordDelimiters, '$'))]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <!-- b) structural delimitation (only evaluated if explicitely allowed through program arguments) -->
            <xsl:when test="$startAtLineBeginning">
                <xsl:choose>
                    <xsl:when test="$node/preceding-sibling::node()[1]/self::*[not(@break)][local-name() = $delimiterElems]">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:when test="not($node/preceding-sibling::node()) and ($node/parent::tei:hi/preceding-sibling::node()[1]/self::*[local-name() = $delimiterElems])">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:isDelimitedRight" as="xs:boolean">
        <xsl:param name="g" as="element(tei:g)"/>
        <xsl:choose>
            <xsl:when test="$g/following-sibling::node()[1]/self::text()[matches(., concat('^', $wordDelimiters))]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    <!-- 2.) Put identified abbreviations in proper choice/abbr/expan tags -->
    
    <xsl:variable name="expandedAbbr">
        <xsl:apply-templates select="$identifiedAbbr" mode="make-choice"/>
        <xsl:message select="'INFO: expanded abbreviations.'"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="make-choice">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="make-choice"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*|node()" mode="copy-then-make-choice">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="make-choice"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Transform nodes that are within the @reach of a local:abbrBeg (i.e., part of an abbreviation) -->
    <xsl:template match="node()[not(self::local:abbrBeg) and preceding-sibling::local:abbrBeg]" mode="make-choice">
        <xsl:variable name="abbrBeg" as="element(local:abbrBeg)" select="preceding-sibling::local:abbrBeg[1]"/>
        <xsl:variable name="abbrBegReach" as="xs:integer" select="xs:integer($abbrBeg/@reach)"/>
        <xsl:variable name="distanceToAbbrBeg" as="xs:integer" select="count(preceding-sibling::node() intersect $abbrBeg/following-sibling::node()) + 1"/>
        <xsl:choose>
            <!-- text nodes at the end of an abbr. must be split after the final substring of the abbr. -->
            <xsl:when test="self::text() and $distanceToAbbrBeg eq $abbrBegReach">
                <!-- if ending part of the abbr. is a text node, abbrBeg must have @endsWith containing the beginning of the current text node -->
                <xsl:variable name="endsWith" as="xs:string" select="$abbrBeg/@endsWith"/>
                <xsl:if test="not(matches(., concat('^', $endsWith)))">
                    <xsl:message terminate="yes" select="'ERROR: @endsWith does not match the beginning of the string to be cut. Text node is: ', ., 'endsWith is: ', @endsWith"/>
                </xsl:if>
                <!-- delete the beginning of the text node that matches @endsWith -->
                <xsl:value-of select="local:splitString(.,$abbrBeg/@endsWith)[2]"/>
            </xsl:when>
            <!-- all other nodes within the reach can simply be omitted (including last node, if it is a tei:g) -->
            <xsl:when test="$abbrBegReach ge $distanceToAbbrBeg">
                <xsl:if test="not(self::tei:g or self::text())"> <!-- adjust this test once there are other types of nodes (than tei:g or text()) included -->
                    <xsl:message terminate="yes" select="'ERROR: node of type ', local-name(.), ' (not tei:g or text()) is in reach of abbrBeg.'"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="self::node()" mode="copy-then-make-choice"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- finally, replace local:abbrBeg by choice/abbr/expan -->
    <xsl:template match="local:abbrBeg" mode="make-choice">
        <xsl:if test="not(@n or @reach)"><xsl:message terminate="yes"/></xsl:if>
        <xsl:variable name="reach" as="xs:integer" select="xs:integer(@reach)"/>
        <xsl:variable name="abbrNodes" as="node()+">
            <xsl:choose>
                <xsl:when test="@endsWith">
                    <xsl:if test="not(starts-with(following-sibling::node()[position() eq $reach]/self::text(), @endsWith))">
                        <xsl:message terminate="yes" select="concat('ERROR: @endsWith does not match the beginning of the respective text node. Text node is: ',
                                                             following-sibling::node()[position() eq $reach]/self::text(), ', endsWith is: ', @endsWith,
                                                             '@reach is ', @reach, ', in line ', preceding-sibling::tei:lb[1]/@xml:id)"/>
                    </xsl:if>
                    <xsl:copy-of select="following-sibling::node()[position() lt $reach]"/>
                    <xsl:value-of select="local:splitString(following-sibling::node()[position() eq $reach]/self::text(), @endsWith)[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="following-sibling::node()[position() le $reach]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- make sure that only tei:g and text() have been "captured" by local:abbrPart/@reach -->
        <xsl:if test="$abbrNodes[not(self::text() or self::tei:g)]">
            <xsl:message terminate="yes" select="'ERROR: abbrBeg/@reach spans nodes that are not text() or tei:g.'"/>
        </xsl:if>
        <xsl:element name="choice">
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="ancestor::tei:note">
                        <xsl:value-of select="concat(generate-id(), 'mn')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
                <xsl:element name="abbr">
                    <xsl:copy-of select="$abbrNodes"/>
                </xsl:element>
                <xsl:element name="expan">
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:copy-of select="local:getExpanNodes(@n)"/>
                </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- Divides a text node into a given substring at the beginning and the rest, and returns both parts as a 2-tuple -->
    <xsl:function name="local:splitString" as="xs:string+">
        <xsl:param name="textNode" as="xs:string"/>
        <xsl:param name="substring" as="xs:string"/>
        <xsl:if test="not(matches($textNode, concat('^', $substring)))">
            <xsl:message terminate="yes" select="concat('ERROR: local:cutString expects substring to be at the beginning of the supplied text node. Text node was: ', $textNode,
                                                        ' ; substring was: ', $substring)"/>
        </xsl:if>
        <xsl:copy-of select="($substring, substring-after($textNode, $substring))"/>
    </xsl:function>
    
    <xsl:function name="local:getExpanNodes" as="node()+">
        <xsl:param name="abbrExpanId" as="xs:string"/>
        <xsl:if test="not($abbrExpanList/local:abbrExpan[@xml:id eq $abbrExpanId])">
            <xsl:message terminate="yes" select="'ERROR: ID ', $abbrExpanId ,' passed to function local:getExpanNodes() does not match any abbrExpan/@xml:id in abbrExpanList'"/>
        </xsl:if>
        <xsl:for-each select="$abbrExpanList/local:abbrExpan[@xml:id eq $abbrExpanId]/local:expansion/local:expanPart">
            <xsl:if test="not(./text())">
                <xsl:message terminate="yes" select="concat('ERROR: found element expanPart without text content, in abbrExpan ', ./ancestor::local:abbrExpan/@xml:id)"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@type eq 'text'">
                    <xsl:value-of select="./text()"/>
                </xsl:when>
                <xsl:when test="@type eq 'g'">
                    <xsl:if test="not(local:isValidCharRef(./text()))"><xsl:message terminate="yes" select="concat('ERROR: invalid char reference: ', ./text())"/></xsl:if>
                    <xsl:element name="g" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="ref" select="./text()"/>
                        <xsl:value-of select="local:getSpecialCharMapping(./text())"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise><xsl:message terminate="yes" select="'ERROR: unknown or non-existing expanPart/@type.'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>


    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

    <!-- 3.) expand "q;" abbreviations -->

    <xsl:variable name="expandedSemicolonAbbr">
        <xsl:apply-templates select="$expandedAbbr" mode="semicolon-abbr"/>
        <xsl:message select="'INFO: expanded semicolon abbreviations.'"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="semicolon-abbr">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="semicolon-abbr"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="tei:text//text()[not(ancestor::tei:choice)]" mode="semicolon-abbr">
        <xsl:analyze-string select="." regex="{'(\s)([^\s\.,;\(\)]+?)(q;)([\s\.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="choice">
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="expan">
                        <xsl:attribute name="resp" select="'#auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'que')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- 4.) quality check, logging, and output -->
    
    <xsl:template match="/">
        <!-- logging about step 1.)  -->
        <xsl:variable as="xs:string*" name="abbrCodes" select="distinct-values($identifiedAbbr//local:abbrBeg/@n)"/>
        <xsl:for-each select="$abbrCodes">
            <xsl:variable name="abbrCode" select="."/>
            <xsl:message select="concat('Identified ', count($identifiedAbbr//local:abbrBeg[@n eq $abbrCode]), ' instances of type ', $abbrCode, '.')"/>
        </xsl:for-each>
        <!-- comparison 1.) vs. 2.): -->
        <!-- make sure that no text has been lost, and get total number of added choice/expan -->
        <xsl:variable name="textLength0" as="xs:integer" select="string-length(replace(string-join(//tei:text//text()[not(ancestor::tei:expan)], ''), '\s', ''))"/>
        <xsl:variable name="textLength1" as="xs:integer" select="string-length(replace(string-join($identifiedAbbr//tei:text//text()[not(ancestor::tei:expan)], ''), '\s', ''))"/>
        <xsl:variable name="textLength2" as="xs:integer" select="string-length(replace(string-join($expandedAbbr//tei:text//text()[not(ancestor::tei:expan)], ''), '\s', ''))"/>
        <xsl:variable name="textLength3" as="xs:integer" select="string-length(replace(string-join($expandedSemicolonAbbr//tei:text//text()[not(ancestor::tei:expan)], ''), '\s', ''))"/>
        <xsl:if test="$textLength0 ne $textLength1">
            <xsl:message terminate="yes" select="concat('ERROR: length of text in input doc (', xs:string($textLength0), ') varies from text in $identifiedAbbr (', xs:string($textLength1), ').')"/>
        </xsl:if>
        <xsl:if test="$textLength1 ne $textLength2">
            <xsl:message terminate="yes" select="concat('ERROR: length of text in $identifiedAbbr (', xs:string($textLength1), ') varies from text in $expandedAbbr (', xs:string($textLength2), ').')"/>
        </xsl:if>
        <xsl:if test="$textLength2 ne $textLength3">
            <xsl:message terminate="yes" select="concat('ERROR: length of text in $expandedAbbr (', xs:string($textLength2), ') varies from text in $expandedSemicolonAbbr (', xs:string($textLength3), ').')"/>
        </xsl:if>
        <xsl:variable name="choiceDiff1" as="xs:integer" select="count($expandedAbbr//tei:choice[tei:expan]) - count($identifiedAbbr//tei:choice[tei:expan])"/>
        <xsl:message select="concat('INFO: added ', xs:string($choiceDiff1), ' choice/expan in list-based abbr. expansion.')"/>
        
        <xsl:variable name="choiceDiff2" as="xs:integer" select="count($expandedSemicolonAbbr//tei:choice[tei:expan]) - count($expandedAbbr//tei:choice[tei:expan])"/>
        <xsl:message select="concat('INFO: added ', xs:string($choiceDiff2), ' choice/expan in regex-based (semicolon) abbr. expansion.')"/>
        
        <!-- final output: -->
        <xsl:copy-of select="$expandedSemicolonAbbr"/>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- OTHER HELPER FUNCTIONS -->
    
    <xsl:function name="local:isValidCharRef" as="xs:boolean">
        <xsl:param name="charRef" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="substring-after($charRef, '#') = $specialCharacters/@xml:id">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:getSpecialCharMapping">
        <xsl:param name="charRef"/>
        <xsl:variable name="charId" select="substring-after($charRef, '#')"/>
        <xsl:choose>
            <xsl:when test="$specialCharacters[@xml:id eq $charId]/tei:mapping[@type eq 'precomposed']">
                <xsl:value-of select="$specialCharacters[@xml:id eq $charId]/tei:mapping[@type eq 'precomposed']/text()"/>
            </xsl:when>
            <xsl:when test="$specialCharacters[@xml:id eq $charId]/tei:mapping[@type eq 'composed']">
                <xsl:value-of select="$specialCharacters[@xml:id eq $charId]/tei:mapping[@type eq 'composed']/text()"/>
            </xsl:when>
            <xsl:otherwise><xsl:message terminate="yes" select="concat('ERROR: no precomposed/composed mapping found for char reference: ', $charRef)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    
</xsl:stylesheet>