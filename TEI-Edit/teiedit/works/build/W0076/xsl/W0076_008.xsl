<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!-- INFO: analyzes pb/cb/lb elements that have been identified as unmarked hyphenations during a previous step  
        of creating correction lists, and tags these elements accordingly (as @break=no and @rendition=#noHyphen). 
        Hence, the program requires one or several correction lists of the correct type (@class eq 'comp_hyph_intext').
        It also performs some normalization of whitespace and break-attribute order along the way. -->
    
    <!-- preconditions:
            - marked hyphenations must have been resolved in order for this to work correctly.
    -->
    
    <!-- current caveats:
            - frequent tei:unclear marks in the text might affect the precision of this annotation negatively, 
              since the upstream correction list program doesn't know what to do with them and simply ignores them.
    -->
    
    <!-- PARAMETERS -->
    
    <!-- provide one or several paths to lists here, separated by comma (",") -->
    <xsl:param name="corrListPaths" as="xs:string"/>
    <!-- state the language for which the correction lists were created (this has no meaning for analysis, but is used for error prevention) -->
    <xsl:param name="lang" as="xs:string" select="'es'"/> <!--select 'la' or 'es'--> 
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2022-05-12'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0076_change_011'"/>
    <xsl:param name="editingDesc" as="xs:string" select="concat('Tag unmarked breaks (', $lang, ').')"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="correct-breaks">
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
            <xsl:apply-templates mode="correct-breaks"/>
        </xsl:copy>
    </xsl:template> 
    
    
    <xsl:variable name="corrLists" as="document-node()+" 
        select="for $path in tokenize($corrListPaths, ',') return if (doc-available($path)) then doc($path) else error()"/>
    <xsl:variable name="hyphTr" as="element(tr)+" 
        select="for $list in $corrLists return if ($list/html/head/meta[@xml:lang eq $lang]) then 
                                                       $list/html[./head/meta[@xml:lang eq $lang]]/body/table[@id eq 'comp_hyph_intext']/tr[@class eq 'comp_hyph_intext' and ./td[@class eq 'intext-hyphenation-id']]
                                                   else error()"/>
    <xsl:variable name="hyphLbIds" as="xs:string+" 
        select="for $td in $hyphTr/td[@class eq 'intext-hyphenation-id'] return tokenize($td/text(), '\n')"/>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- 1.) tag lb elements as @break=no and @rendition='#noHyphen' based on the list #### -->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="tag-lb">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="tag-lb"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb[@xml:id = $hyphLbIds]" mode="tag-lb">
        <!-- check integrity of lang info -->
        <xsl:if test="ancestor::*[@xml:lang][1]/@xml:lang ne $lang and not(@break eq 'no')">
            <xsl:message terminate="yes" select="concat('ERROR: untagged lb ', @xml:id, ' is supposed to be annotated as @break=no and @rendition=#noHyphen, ', 
                'but has an ancestor tagged with @xml:lang different than the one found in the correction list.')"/>
        </xsl:if>
        <xsl:variable name="thisLb" as="element(tei:lb)" select="."/>
        <xsl:variable name="thisId" as="xs:string" select="@xml:id"/>
        <!-- quality check: make sure that list is applied to the correct version of the text by checking if text nodes actually match -->
        <!--<xsl:if test="count($hyphTr[contains(./td[@class eq 'intext-hyphenation-id']/text(), @xml:id)]) gt 1">
            <xsl:message terminate="yes" select="'ERROR: found multiple tr elements containing lb-id '"></xsl:message>
        </xsl:if>-->
        <xsl:variable name="tr" as="element(tr)" select="$hyphTr[contains(./td[@class eq 'intext-hyphenation-id']/text(), $thisId)]"/>
        <!-- TODO: lower-casing? -->
        <xsl:variable name="tok1" as="xs:string" select="normalize-space(substring-before($tr/td[1]/text(), '|'))"/>
        <xsl:variable name="tok2" as="xs:string" select="normalize-space(substring-after($tr/td[1]/text(), '|'))"/>
        <xsl:variable name="precedingText" as="xs:string">
            <xsl:choose>
                <xsl:when test="not(ancestor::*[@place eq 'margin'])">
                    <xsl:value-of select="normalize-space(./preceding::text()[not(normalize-space() eq '') and not(ancestor::*[@place eq 'margin'])][1])"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="normalize-space(./preceding::text()[not(normalize-space() eq '') and ancestor::*[@place eq 'margin']][1])"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="followingText" as="xs:string" select="normalize-space(./following::text()[not(normalize-space() eq '')][1])"/>
        <xsl:variable name="tok1End" as="xs:string" select="substring($tok1, string-length($tok1))"/>
        <xsl:variable name="tok2Start" as="xs:string" select="substring($tok2,1,1)"/>
        <xsl:variable name="precedingTextEnd" as="xs:string" select="substring($precedingText, string-length($precedingText))"/>
        <xsl:variable name="followingTextStart" as="xs:string" select="substring($followingText,1,1)"/>
        <xsl:choose>
            <!-- compare ending/starting characters of text nodes as a rudimentary check for equality (not whole tokens, since there may be interfering special char tags...) -->
            <xsl:when test="$tok1End eq $precedingTextEnd and $tok2Start eq $followingTextStart"> <!-- matches(./preceding::text()[1], concat($tok1, '\s*$')) and matches(./following::text()[1], concat('^\s*', $tok2)) -->
                <xsl:choose>
                    <xsl:when test="@break eq 'no'">
                        <xsl:message select="concat('INFO: omitting break annotation for lb that already has @break=no: ', $thisId)"/>
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                        </xsl:copy>
                    </xsl:when>
                    <!-- check for collision with previous taggings -->
                    <xsl:when test="@break eq 'yes' or @rendition eq '#hyphen'">
                        <xsl:message terminate="yes" select="'ERROR: trying to annotate lb as @break=no and @rendition=#noHyphen that is tagged as @break=yes or @rendition=#hyphen.'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy>
                            <xsl:copy-of select="@*"/>
                            <xsl:attribute name="break" select="'no'"/>
                            <xsl:attribute name="rendition" select="'#noHyphen'"/>
                            <xsl:attribute name="resp" select="'#auto'"/>
                        </xsl:copy>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat('WARN: could not align list entry with lb of xml:id: ', @xml:id, ' because ending/starting characters differ:&#xA;',
                                            'token 1 ending is: ', $tok1End, ' , preceding text ending is: ', $precedingTextEnd, '&#xA;',
                                            'token part 2 beginning is: ', $tok2Start, ' , following text node beginning is: ', $followingTextStart)"/>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                </xsl:copy>
            </xsl:otherwise>            
        </xsl:choose>
    </xsl:template>
    
    <xsl:variable name="taggedLb">
        <xsl:apply-templates mode="tag-lb"/>
    </xsl:variable>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- 2.) correct break attribute order (pb|cb|lb)/(@break|@rendition) and remove unwanted whitespace -->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="correct-breaks">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="correct-breaks"/>
        </xsl:copy>
    </xsl:template>
    

    <xsl:template match="tei:pb" mode="correct-breaks">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="local:isPrimaryNonBreaking(.)">
                <xsl:attribute name="break" select="'no'"/>
                <xsl:attribute name="rendition" select="local:isPrimaryNonBreaking(.)"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:cb|tei:lb" mode="correct-breaks">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="local:isPrimaryNonBreaking(.)">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="break" select="'no'"/>
                    <xsl:attribute name="rendition" select="local:isPrimaryNonBreaking(.)"/>
                </xsl:when>
                <xsl:when test="local:isSecondaryNonBreaking(.)">
                    <xsl:copy-of select="@* except @rendition"/>
                    <xsl:attribute name="break" select="'no'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@break[. ne 'yes'] or @rendition">
                        <!-- if none of the above is the case, the element shouldn't have @rendition or @break in the first place -->
                        <xsl:message terminate="yes" select="concat('ERROR: encountered unexpected @break or @rendition in element ', @xml:id)"/>
                    </xsl:if>
                    <xsl:copy-of select="@*"/> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
     
    
    <!-- remove unwanted whitespace immediately before break element -->
    <xsl:template match="tei:text//text()[not(ancestor::*[@place eq 'margin']) 
                                          and following-sibling::*[not(ancestor::*[@place eq 'margin'])][1][(self::tei:pb or self::tei:cb or self::tei:lb) 
                                                                                                             and (local:isPrimaryNonBreaking(.) or local:isSecondaryNonBreaking(.))]
                                          and matches(., '\s+$')]" mode="correct-breaks">
        <!-- through applying this to secondary no-breaks as well, this should also delete illegal whitespace in-between two no-breaks -->
        <xsl:value-of select="replace(., '\s+$', '')"/>
    </xsl:template>
    <xsl:template match="tei:text//text()[ancestor::*[@place eq 'margin'] 
                                          and following-sibling::*[ancestor::*[@place eq 'margin']][1][(self::tei:pb or self::tei:cb or self::tei:lb) 
                                                                                                        and (local:isPrimaryNonBreaking(.) or local:isSecondaryNonBreaking(.))]
                                          and matches(., '\s+$')]" mode="correct-breaks">
        <!-- through applying this to secondary no-breaks as well, this should also delete illegal whitespace in-between two no-breaks -->
        <xsl:value-of select="replace(., '\s+$', '')"/>
    </xsl:template>
    
    
    <!-- Determines whether a break element is the first (or only) non-breaking element at a given breaking point in the text (line, column, page break). 
         Returns the type of no-break as a string (i.e., the value of @rendition - #noHyphen or #hyphen) in case the element is a first no-break, or 
         the empty sequence in case it is not. -->
    <xsl:function name="local:isPrimaryNonBreaking" as="xs:string?">
        <xsl:param name="node"/>
        <xsl:choose>
            <!-- pb -->
            <xsl:when test="$node/self::tei:pb">
                <xsl:choose>
                    <xsl:when test="$node/@break eq 'no' and $node/@rendition = ('#hyphen', '#noHyphen')">
                        <xsl:value-of select="$node/@rendition"/>
                    </xsl:when>
                    <xsl:when test="$node/following-sibling::*[1]/self::tei:lb[@break eq 'no' and @rendition = ('#hyphen', '#noHyphen')]">
                        <xsl:value-of select="$node/following-sibling::*[1]/self::tei:lb/@rendition"/>
                    </xsl:when>
                    <xsl:when test="$node/following-sibling::*[1]/self::tei:cb and $node/following-sibling::*[2]/self::tei:lb[@break eq 'no' and @rendition = ('#hyphen', '#noHyphen')]">
                        <xsl:value-of select="$node/following-sibling::*[2]/self::tei:lb/@rendition"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- cb -->
            <xsl:when test="$node/self::tei:cb">
                <xsl:choose>
                    <xsl:when test="$node/@break eq 'no' and $node/@rendition = ('#hyphen', '#noHyphen')
                                    and not($node/preceding-sibling::*[1]/self::tei:pb)">
                        <xsl:value-of select="$node/@rendition"/>
                    </xsl:when>
                    <xsl:when test="$node/following-sibling::*[1]/self::tei:lb[@break eq 'no' and @rendition = ('#hyphen', '#noHyphen')]
                                    and not($node/preceding-sibling::*[1]/self::tei:pb)">
                        <xsl:value-of select="$node/following-sibling::*[1]/self::tei:lb/@rendition"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- lb -->
            <xsl:when test="$node/self::tei:lb">
                <xsl:choose>
                    <xsl:when test="$node/@break eq 'no' and $node/@rendition = ('#hyphen', '#noHyphen')
                                    and not($node/preceding-sibling::*[1][self::tei:pb or self::tei:cb])">
                        <xsl:value-of select="$node/@rendition"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:message terminate="yes" select="'ERROR: illegal input element for local:isPrimaryNonBreaking()'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Determines whether a break element is a subsequent non-breaking break element (true) or not (false) -->
    <xsl:function name="local:isSecondaryNonBreaking" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:choose>
            <!-- only cb and lb may be secondary no-breaks -->
            <xsl:when test="$node/self::tei:cb and $node/preceding-sibling::*[1]/self::tei:pb[local:isPrimaryNonBreaking(.)]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$node/self::tei:lb and ($node/preceding-sibling::*[1]/self::tei:pb[local:isPrimaryNonBreaking(.)]
                                                    or $node/preceding-sibling::*[1]/self::tei:cb[local:isPrimaryNonBreaking(.) or local:isSecondaryNonBreaking(.)])">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:apply-templates select="$taggedLb" mode="correct-breaks"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
        <!-- logging about break annotation -->
        <xsl:variable name="inTaggedPb" as="xs:integer" select="count(//tei:text//tei:pb[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="outTaggedPb" as="xs:integer" select="count($out//tei:text//tei:pb[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="inTaggedCb" as="xs:integer" select="count(//tei:text//tei:cb[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="outTaggedCb" as="xs:integer" select="count($out//tei:text//tei:cb[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="inTaggedLb" as="xs:integer" select="count(//tei:text//tei:lb[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="outTaggedLb" as="xs:integer" select="count($out//tei:text//tei:lb[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="inTaggedBreaks" as="xs:integer" select="count(//tei:text//(tei:pb|tei:cb|tei:lb)[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:variable name="outTaggedBreaks" as="xs:integer" select="count($out//tei:text//(tei:pb|tei:cb|tei:lb)[@break eq 'no' and @rendition eq '#noHyphen'])"/>
        <xsl:message select="concat('INFO: tagged ', $outTaggedPb - $inTaggedPb, ' pb as break=no and rendition=#noHyphen')"/>
        <xsl:message select="concat('INFO: tagged ', $outTaggedCb - $inTaggedCb, ' cb as break=no and rendition=#noHyphen')"/>
        <xsl:message select="concat('INFO: tagged ', $outTaggedLb - $inTaggedLb, ' lb as break=no and rendition=#noHyphen')"/>
        <xsl:message select="concat('INFO: tagged ', $outTaggedBreaks - $inTaggedBreaks, ' breaks in total as break=no and rendition=#noHyphen')"/>
        <xsl:message select="'------------------------------------------------------'"/>
        <!-- general logging -->
        <xsl:variable name="inWhitespace" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="inChars" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="inSpecialChars" as="xs:integer" select="count(//tei:g)"/>
        <xsl:variable name="outSpecialChars" as="xs:integer" select="count($out//tei:g)"/>
        <xsl:variable name="inPb" as="xs:integer" select="count(//tei:pb)"/>
        <xsl:variable name="outPb" as="xs:integer" select="count($out//tei:pb)"/>
        <xsl:variable name="inCb" as="xs:integer" select="count(//tei:cb)"/>
        <xsl:variable name="outCb" as="xs:integer" select="count($out//tei:cb)"/>
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb)"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb)"/>
        <!-- whitespace and regular symbols -->
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'ERROR: Amount of non-whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:if test="$inWhitespace ne $outWhitespace">
            <xsl:message select="'INFO: Amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
        </xsl:if>
        <!-- breaks -->
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
            <xsl:message select="'ERROR: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- special chars -->
        <xsl:if test="$inSpecialChars ne $outSpecialChars">
            <xsl:message select="'ERROR: different amount of input and output special chars: '"/>
            <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    
    <!-- TODO:
        - get @resp='#auto' into the first element if there is a multi-break (pb-cb-lb)
    -->

</xsl:stylesheet>