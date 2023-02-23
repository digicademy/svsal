<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- 
            This program adds line numbering to tei:lb elements (in @n). A line number follows the following syntax: 
            [workID]_[facsimileID, 4-digit]_[lineNumber, 4-digit] (thus, the line number will be stored in the last 4 places of tei:lb/@facs, following 
            the last underscore.
            
            The first place of the actual line number (i.e., of the four last digits) has a certain meaning:
            - 0 stands for line in the main area of the text, no column format
            - 1-9 stands for line in the main area in column 1-9
            - m stands for line in the marginal area of the text (regardless of the side (left vs. right))
            Then follows the position with regards to the text area (main area/column, marginal area) which the line is located in.
            
            Please note that tei:lb[@sameAs] are NOT numbered.
    -->
    
    
    <xsl:output method="xml"/> 
    
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2020-05-06'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0033_change_009'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Numbered lines.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="include-numbers">
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
            <xsl:apply-templates mode="include-numbers"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    <!-- 1.) generate temporary xml:id for tei:lb, so that these are uniquely identifiable later on -->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="generate-id">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="generate-id"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb" mode="generate-id">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="@xml:id">
                    <!-- keep old xml:id for consistency of hyperlinks -->
                    <xsl:copy-of select="@xml:id"/>
                    <xsl:if test="@subtype"><xsl:message terminate="yes"/></xsl:if>
                    <xsl:attribute name="subtype" select="'oldId'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="xml:id" select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="docLbId">
        <xsl:if test="//tei:pb[not(@sameAs) and not(@facs and @xml:id)]">
            <xsl:message terminate="yes" select="'There are tei:pb[not(@sameAs)] in the input document that have no @xml:id and/or @facs. Please make sure tei:pb are tagged correctly.'"/>
        </xsl:if>
        <xsl:apply-templates select="/" mode="generate-id"/>
        <xsl:message select="'Generated temporary lb/@xml:id.'"/>
    </xsl:variable>
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    <!-- 2.) a) get all pb, cb, and lb elements from the main part of the text 
        and store them page-wise in a relatively flat (and quickly queryable) data structure -->
    
    <xsl:variable name="pages" as="element(pages)">
        <xsl:element name="pages" namespace="">
            <xsl:for-each select="$docLbId//tei:pb[local:isMainBreak(.)]">
                <xsl:element name="page" namespace="">
                    <xsl:attribute name="corresp" select="@xml:id"/>
                    <xsl:attribute name="facs" select="@facs"/>
                    <xsl:copy-of select="."/>
                    <xsl:choose>
                        <xsl:when test="following::tei:pb[local:isMainBreak(.)]">
                            <xsl:copy-of select="./following::*[(self::tei:cb or self::tei:lb) and local:isMainBreak(.)] 
                                                 intersect ./following::tei:pb[local:isMainBreak(.)][1]/preceding::*[(self::tei:cb or self::tei:lb) and local:isMainBreak(.)]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="./following::*[(self::tei:cb or self::tei:lb) and local:isMainBreak(.)]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
        <xsl:message select="'Extracted tei:lb from pages in the main area of the text.'"/>
    </xsl:variable>
    
    <!-- 2.) b) extract all lb (and pb) from marginals, first storing them per each marginal element, then mapping them to the right pages -->
    
    <xsl:variable name="marginalPages" as="element(marginalPages)">
        <!-- (i) extract lb per marginal element and give the marginal element some info about the page it occurs in -->
        <xsl:variable name="margElems1" as="element(margElems)">
            <xsl:element name="margElems" namespace="">
                <xsl:for-each select="$docLbId//*[local:isMarginal(.)]">
                    <xsl:if test="ancestor::*[local:isMarginal(.)]">
                        <xsl:message terminate="yes" select="'ERROR: marginal elements are nested illegaly.'"/>
                    </xsl:if>
                    <xsl:element name="margElem" namespace="">
                        <xsl:attribute name="corresp" select="./preceding::tei:pb[local:isMainBreak(.)][1]/@xml:id"/>
                        <xsl:copy-of select=".//*[(self::tei:lb or self::tei:pb) and local:isMarginalBreak(.)]"/>    
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:variable>
        <!-- (ii) re-process marg. elements: in case a marginal contains a page break, split it into two separate elements with respective page information -->
        <xsl:variable name="margElems2" as="element(margElems)">
            <xsl:element name="margElems" namespace="">
                <xsl:for-each select="$margElems1//margElem">
                    <xsl:choose>
                        <xsl:when test="count(.//tei:pb[local:isRelevantMarginalBreak(.)]) gt 1">
                            <xsl:message terminate="yes" select="concat('ERROR: encountered marginal element containing more than one page break: ', ./@xml:id)"/>
                        </xsl:when>
                        <xsl:when test="count(./tei:pb[local:isRelevantMarginalBreak(.)]) eq 0">
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="count(./tei:pb[local:isRelevantMarginalBreak(.)]) eq 1">
                            <xsl:element name="margElem" namespace="">
                                <xsl:copy-of select="./@corresp"/> <!-- first element inherits page number from original margElem -->
                                <xsl:copy-of select="./tei:lb[following-sibling::tei:pb]"/>
                            </xsl:element>
                            <xsl:element name="margElem" namespace="">
                                <xsl:variable as="xs:string" name="correspSameAs" select="./tei:pb/@sameAs"/>
                                <xsl:if test="not(matches($correspSameAs, '^#.+'))">
                                    <xsl:message terminate="yes" select="concat('ERROR: tei:pb within marginal element has invalid value: ', $correspSameAs)"/>
                                </xsl:if>
                                <xsl:attribute name="corresp" select="substring($correspSameAs, 2)"/>
                                <xsl:copy-of select="./tei:lb[preceding-sibling::tei:pb]"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise><xsl:message terminate="yes"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:element>
        </xsl:variable>
        <!-- (iii) finally, store marginal lines page-wise -->
        <xsl:element name="marginalPages" namespace="">
            <xsl:for-each select="distinct-values($margElems2//@corresp/string())"> 
                <xsl:variable name="thisCorresp" as="xs:string" select="."/>
                <!-- this might iterate through pages in the wrong order, but the only thing that counts here is that the margElems are still in the correct order -->
                <xsl:element name="page" namespace="">
                    <xsl:attribute name="corresp" select="$thisCorresp"/>
                    <xsl:attribute name="facs" select="$docLbId//tei:pb[@xml:id eq $thisCorresp]/@facs"/>
                    <xsl:copy-of select="$margElems2//tei:lb[ancestor::margElem[@corresp eq $thisCorresp]]"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
        <xsl:message select="'Extracted tei:lb from the marginal area.'"/>
    </xsl:variable>
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    <!-- 3.) do the actual line numbering, resulting in a simple sequence of lb elements -->
    
    <!-- a) main text -->
    
    <xsl:variable name="numberedMainLines" as="element(numberedMainLines)">
        <xsl:element name="numberedMainLines" namespace="">
            <xsl:for-each select="$pages//tei:lb">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:variable name="prefix" as="xs:string">
                        <xsl:variable name="facs" as="xs:string" select="./parent::page/@facs"/>
                        <xsl:if test="not(matches($facs, '^facs:W\d{4}(-[A-z])?-\d{4}$'))">
                            <xsl:message terminate="yes" select="concat('ERROR: @facs in $pages//tei:lb has invalid value: ', $facs)"/>
                        </xsl:if>
                        <xsl:value-of select="replace($facs, '^facs:(W\d{4}(-[A-z])?)-(\d{4})$', '$1_$3')"/>
                    </xsl:variable>
                <xsl:attribute name="n" select="concat($prefix, '_', local:getCurrentMainLine(.))"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:element>
        <xsl:message select="'Numbered tei:lb from the main area.'"/>
    </xsl:variable>
    
    <!-- Determines the number of a line (and, potentially, the column it is in), returning this information as a 4-digit string where the first 
    number states the column and the last three digits the number of the line (either in the column or, if there are no columns, on the whole page). -->
    <xsl:function name="local:getCurrentMainLine" as="xs:string">
        <xsl:param name="thisLb" as="element(tei:lb)"/>
        <xsl:variable name="lineNumber" as="xs:string">
            <xsl:choose>
            <!-- (i) simple case: there are no (preceding) columns on the page -> simply count preceding lines -->
                <xsl:when test="not($thisLb/preceding-sibling::tei:cb)">
                    <xsl:variable name="currentLine" as="xs:integer" select="count($thisLb/preceding-sibling::tei:lb) + 1"/>
                    <xsl:if test="$currentLine gt 200">
                        <xsl:message terminate="yes" select="'Error: counted line number greater than 200 - is this correct?'"/>
                    </xsl:if>
                    <xsl:value-of select="concat('0', substring(concat('000', string($currentLine)), string-length(string($currentLine)) + 1, 3))"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- (ii) there are columns -> determine which column the current line is in (or if it is in a column at all) and count all 
                         preceding lines in the same column -->
                    <xsl:variable name="currentColumn" as="xs:integer" select="local:getCurrentColumn($thisLb)"/>
                    <xsl:variable name="currentLine" as="xs:integer" select="count($thisLb/preceding-sibling::tei:lb[local:getCurrentColumn(.) eq $currentColumn]) + 1"/>
                    <xsl:if test="$currentLine gt 200">
                        <xsl:message terminate="yes" select="'Error: counted line number greater than 200 - is this correct?'"/>
                    </xsl:if>
                    <xsl:value-of select="concat(string($currentColumn), substring(concat('000', string($currentLine)), string-length(string($currentLine)) + 1, 3))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not(matches($lineNumber, '^\d{4}$')) or matches($lineNumber, '^0000$')">
            <xsl:message terminate="yes" select="concat('ERROR: got illegal line number: ', $lineNumber)"/>
        </xsl:if>
        <xsl:value-of select="$lineNumber"/>
    </xsl:function>
    
    <xsl:function name="local:getCurrentColumn" as="xs:integer">
        <xsl:param name="thisLb" as="element(tei:lb)"/>
        <xsl:variable name="columnN" as="xs:integer">
            <xsl:choose>
                <!-- if there is no preceding cb at all, return 0 -->
                <xsl:when test="not($thisLb/preceding-sibling::tei:cb)">
                    <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="precedingCbStart" as="element(tei:cb)?" select="$thisLb/preceding-sibling::tei:cb[@type eq 'start'][1]"/>
                    <xsl:variable name="precedingCbEnd" as="element(tei:cb)?" select="$thisLb/preceding-sibling::tei:cb[@type eq 'end'][1]"/>
                    <xsl:choose>
                        <!-- if layout doesn't change on page, simply count preceding cb -->
                        <xsl:when test="not($precedingCbEnd)">
                            <xsl:value-of select="count($thisLb/preceding-sibling::tei:cb)"/>
                        </xsl:when>
                        <!-- if end of column layout is nearer than any column break, the line obviously cannot be in any column -->
                        <xsl:when test="count($precedingCbEnd/preceding-sibling::tei:lb) gt count($thisLb/preceding-sibling::tei:cb[not(@type eq 'end')][1]/preceding-sibling::tei:lb)">
                            <xsl:value-of select="0"/>
                        </xsl:when>
                        <!-- if column layout starts again after having ended somewhere on the same page, count number of columns since restart -->
                        <xsl:when test="count($precedingCbStart/preceding-sibling::tei:lb) gt count($precedingCbEnd/preceding-sibling::tei:lb)">
                            <xsl:value-of select="count($thisLb/preceding-sibling::tei:cb intersect $precedingCbStart/following-sibling::tei:cb) + 1"/> <!-- adding 1 for the start itself -->
                        </xsl:when>
                        <!-- in case of some bizarre or incorrectly tagged column layout, terminate -->
                        <xsl:otherwise>
                            <xsl:message terminate="yes" select="concat('Error: encountered unforeseen column structure on page ', $thisLb/preceding-sibling::tei:pb/@facs)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$columnN gt 9">
            <xsl:message terminate="yes" select="concat('Error: counted amount of columns on page greater than 9: ', 
                                                        string($columnN), ' columns in total on page ', $thisLb/preceding-sibling::tei:pb/@facs)"/>
        </xsl:if>
        <xsl:value-of select="$columnN"/>
    </xsl:function>
    
    
    <!-- b) marginal text -->
    
    <xsl:variable name="numberedMarginalLines" as="element(numberedMarginalLines)">
        <xsl:element name="numberedMarginalLines" namespace="">
            <xsl:for-each select="$marginalPages//tei:lb">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:variable name="prefix" as="xs:string">
                        <xsl:variable name="facs" as="xs:string" select="./parent::page/@facs"/>
                        <xsl:if test="not(matches($facs, '^facs:W\d{4}(-[A-z])?-\d{4}$'))">
                            <xsl:message terminate="yes" select="concat('ERROR: @facs in $marginalPages//tei:lb has invalid value: ', $facs)"/>
                        </xsl:if>
                        <xsl:value-of select="replace($facs, '^facs:(W\d{4}(-[A-z])?)-(\d{4})$', '$1_$3')"/>
                    </xsl:variable>
                    <!-- counting marginal lines is simply, since we don't have to deal with columns and stuff like that here -->
                    <xsl:variable name="currentLine" as="xs:integer" select="count(./preceding-sibling::tei:lb) + 1"/>
                    <xsl:if test="$currentLine gt 200">
                        <xsl:message terminate="yes" select="'Error: counted marginal line number greater than 200 - is this correct?'"/>
                    </xsl:if>
                <xsl:variable name="lineNumber" as="xs:string" select="concat('m', substring(concat('000', string($currentLine)), string-length(string($currentLine)) + 1, 3))"/>
                    <xsl:if test="not(matches($lineNumber, '^m\d{3}$')) or matches($lineNumber, '^m000$')">
                        <xsl:message terminate="yes" select="concat('ERROR: got illegal line number: ', $lineNumber)"/>
                    </xsl:if>
                    <xsl:attribute name="n" select="concat($prefix, '_', $lineNumber)"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:element>
        <xsl:message select="'Numbered tei:lb from the marginal area.'"/>
    </xsl:variable>
    
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    <!-- 4.) generate output -->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="include-numbers">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="include-numbers"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb" mode="include-numbers">
        <xsl:copy>
            <xsl:variable name="xmlId" select="@xml:id"/>
            <xsl:choose>
                <xsl:when test="@subtype eq 'oldId'">
                    <xsl:copy-of select="@* except @subtype"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@* except @xml:id"/> <!-- remove temporary xml:id -->
                </xsl:otherwise>
            </xsl:choose> <xsl:variable name="lineNumber" as="xs:string">
                <!-- searching for an adequate line/@n in numbered*Lines via xml:id seems to take most of the time atm, perhaps we can tune that somehow? -->
                <xsl:choose>
                    <xsl:when test="local:isMainBreak(.)">
                        <xsl:value-of select="$numberedMainLines/tei:lb[@xml:id eq $xmlId]/@n/string()"/>
                    </xsl:when>
                    <xsl:when test="local:isMarginalBreak(.)">
                        <xsl:value-of select="$numberedMarginalLines/tei:lb[@xml:id eq $xmlId]/@n/string()"/>
                    </xsl:when>
                    <xsl:when test="@sameAs">
                        <xsl:message select="'INFO: Omitting line numbering for tei:lb[@sameAs]'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="'ERROR: Encountered type of tei:lb for which no numbering scenario is specified.'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="not(@sameAs)">
                <xsl:attribute name="n" select="$lineNumber"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="out">
        <xsl:apply-templates select="$docLbId" mode="include-numbers"/>
    </xsl:variable>
    
    <!-- LOGGING and quality check -->
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
        <xsl:message select="'INFO: Added line numbers to tei:lb/@n.'"/>
        <xsl:message select="'INFO: Serializing final output...'"/>
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
        <xsl:if test="$inWhitespace ne $outWhitespace or $inChars ne $outChars">
            <xsl:message select="'ERROR: Numbers of non-whitespace or whitespace characters differ in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="yes"/>
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
    
    
    <!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    
    <!-- HELPER FUNCTIONS FOR DISTINGUISHING MAIN AND MARGINAL ELEMENTS -->
    
    <!-- determines whether or not a break element is in the main part of the text and is a "true" break (i.e. not just referring to another break) -->
    <xsl:function name="local:isMainBreak" as="xs:boolean">
        <xsl:param name="breakElem"/>
        <xsl:if test="not($breakElem[self::tei:pb or self::tei:cb or self::tei:lb])">
            <xsl:message terminate="yes" select="'Error: invalid element given to function local:isMainElement(local:isMainElement(): element ', $breakElem/name(), ')'"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$breakElem/@sameAs or $breakElem/ancestor::*[(self::tei:note or self::tei:label or self::tei:head) and @place eq 'margin']">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:isMarginalBreak" as="xs:boolean">
        <xsl:param name="breakElem"/>
        <xsl:if test="not($breakElem[self::tei:pb or self::tei:cb or self::tei:lb])">
            <xsl:message terminate="yes" select="'Error: invalid element given to function local:isMainElement(local:isMainElement(): element ', $breakElem/name(), ')'"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$breakElem/ancestor::*[local:isMarginal(.)] and local:isRelevantMarginalBreak($breakElem)">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="local:isRelevantMarginalBreak" as="xs:boolean">
        <xsl:param name="breakElem"/>
        <xsl:if test="not($breakElem[self::tei:pb or self::tei:cb or self::tei:lb])">
            <xsl:message terminate="yes" select="'Error: invalid element given to function local:isMainElement(local:isMainElement(): element ', $breakElem/name(), ')'"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not($breakElem/self::tei:lb[@sameAs])
                            and not($breakElem[ancestor::tei:reg or ancestor::tei:corr or ancestor::tei:expan])"> 
                <!-- omitting lb with @sameAs, but keeping pb and cb of this type since they are helpful for page/column changes within marginals -->
                <!-- omitting breaks in normalized elements so we don't have any double breaks -->
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Determines whether a given element is a marginal text unit. Currently, we count as marg. units: notes, labels, and headings that are 
        marked as @place="margin" -->
    <xsl:function name="local:isMarginal" as="xs:boolean">
        <xsl:param name="elem"/>
        <xsl:choose>
            <xsl:when test="$elem[@place eq 'margin' and (self::tei:note or self::tei:label or self::tei:head)]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    

</xsl:stylesheet>