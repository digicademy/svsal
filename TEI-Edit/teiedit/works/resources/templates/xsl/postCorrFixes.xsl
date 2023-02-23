<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <!-- Automatic fixing of some frequent 'errors'/inconsistencies introduced through working with the oXygen plugin -->
    <!-- NOTE: if one or several of the templates herein fail and seem difficult to debug, try to apply at least those that work and resolve 
        other issues by means of other scripts, or manually. -->
    
    <xsl:param name="editors" as="xs:string" select="'#DG #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'YYYY-MM-DD'"/>
    <xsl:param name="changeId" as="xs:string" select="''"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Post-correction fixes.'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="postcorr-fixes">
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
            <xsl:apply-templates mode="postcorr-fixes"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="postcorr-fixes">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="postcorr-fixes"/>
        </xsl:copy>
    </xsl:template>

    <!-- delete unwanted attributes -->
    <xsl:template match="tei:expan/@xml:id" mode="postcorr-fixes"/>
    <xsl:template match="tei:corr/@xml:id" mode="postcorr-fixes"/>
    <xsl:template match="tei:hi/@resp[. eq 'tao:R']" mode="postcorr-fixes"/>
    <xsl:template match="tei:lb/@n" mode="postcorr-fixes"/>
    
    <!-- correct wrapping of single brevigraphs: g/choice/abbr -> choice/abbr/g -->
    <xsl:template match="tei:g[tei:choice/tei:abbr]" mode="postcorr-fixes">
        <xsl:if test="tei:choice//text()[matches(., '\s')]">
            <xsl:message terminate="yes" select="'ERROR: detected whitespace in g/choice.'"/>
        </xsl:if>
        <xsl:if test=".//text()[not(ancestor::tei:abbr or ancestor::tei:expan) and matches(., '\S')]">
            <xsl:message terminate="yes" select="concat('ERROR: identified illegal g/choice wrapping with non-whitespace text content outside of abbr / expan, in line ',
                                                    preceding::tei:lb[1]/@xml:id, ' ; text nodes: ', string-join(.//text()[not(ancestor::tei:abbr or ancestor::tei:expan) and matches(., '\S')], ' | '))"/>
        </xsl:if>
        <xsl:if test="tei:choice/preceding-sibling::text()">
            <xsl:message select="concat('INFO: externalized whitespace before g/choice, in line ', preceding::tei:lb[1]/@xml:id)"/>
            <xsl:value-of select="tei:choice/preceding-sibling::text()"/>
        </xsl:if>
        <xsl:element name="choice">
            <xsl:copy-of select="tei:choice/@*"/>
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:if test="count(tei:choice/(tei:abbr|tei:expan)) ne 2">
                <xsl:message terminate="yes" select="'ERROR: illegal structure within choice[abbr|expan].'"/>
            </xsl:if>
            <xsl:element name="abbr">
                <xsl:copy-of select="tei:choice/tei:abbr/@*"/>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="tei:choice/tei:abbr/text()"/>
                </xsl:copy>
            </xsl:element>
            <!--<xsl:copy-of select="tei:choice/tei:expan"/>-->
            <xsl:apply-templates select="tei:choice/tei:expan" mode="postcorr-fixes"/>
        </xsl:element>
        <xsl:if test="tei:choice/following-sibling::text()">
            <xsl:message select="concat('INFO: externalized whitespace after g/choice ', preceding::tei:lb[1]/@xml:id)"/>
            <xsl:value-of select="tei:choice/following-sibling::text()"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:g[tei:choice/(tei:sic|tei:corr|tei:orig|tei:reg)]">
        <xsl:message terminate="yes" select="'ERROR: found unexpected tei:choice within tei:g, of type other than abbr-expan - resolve this manually (in line',
                                             preceding::tei:lb[@xml:id][1]/@xml:id ,').'"/>
    </xsl:template>
    
    <!-- extract foreign from within choice 
        (assuming here for simplicity that if at least one text node within choice is tagged as tei:foreign, the whole choice complex is to be tagged as such) -->
    <xsl:template match="tei:choice[.//tei:foreign]" mode="postcorr-fixes">
        <!-- in case not all text nodes in choice are tagged as foreign, simply copy (to be edited manually) -->
        <!--<xsl:if test=".//text()[not(ancestor::tei:foreign)]">
            <xsl:message select="concat('WARNING: detected text within tei:choice not wrapped in foreign ', 
                 '(while trying to extract tei:foreign from within tei:choice) - resolve this manually (in line ', preceding::tei:lb[1]/@xml:id, ').')"/>
            <xsl:copy-of select="."/>
        </xsl:if>-->
        <!-- make sure that all foreign within choice have the same language -->
        <xsl:if test="count(distinct-values(.//foreign/@xml:lang/string()) gt 1)">
            <xsl:message terminate="yes" select="concat('ERROR: found tei:foreign with different @xml:lang within the same tei:choice, in line ', preceding::tei:lb[1]/@xml:id)"/>
        </xsl:if>
        <xsl:element name="foreign">
            <xsl:copy-of select=".//tei:foreign[1]/@*"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="postcorr-fixes"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:foreign[ancestor::tei:choice]" mode="postcorr-fixes">
        <xsl:apply-templates mode="postcorr-fixes"/>
    </xsl:template>
    
    <!-- normalize blank space -->
    <xsl:template match="tei:text//text()[matches(., ' {2,99999}')]" mode="postcorr-fixes">
        <xsl:analyze-string select="." regex=" {{2,999}}">
            <xsl:matching-substring>
                <xsl:value-of select="' '"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:variable name="postCorrFixes">
        <xsl:apply-templates select="/" mode="postcorr-fixes"/>
    </xsl:variable>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- re-position lb that have accidentally slipped into choice during corrections (if there also are incorrectly placed pb/cb, resolve those manually) -->
    <!-- NOTE: currently works only with lb, not pb or cb -->
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="reposition-lb">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="reposition-lb"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:choice[./*[1][self::tei:abbr or self::tei:sic or self::tei:orig]/node()[1]/self::tei:lb[local:needsRepositioning(.)]]" mode="reposition-lb">
        <xsl:copy-of select="./*[1]/node()[1]"/>
        <xsl:message select="concat('INFO: repositioned lb ', ./*[1]/node()[1]/@xml:id)"></xsl:message>
        <xsl:copy>
            <xsl:apply-templates mode="reposition-lb"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:lb[local:needsRepositioning(.)]" mode="reposition-lb"/>
    
    <xsl:function name="local:needsRepositioning" as="xs:boolean">
        <xsl:param name="lb" as="element(tei:lb)"/>
        <xsl:choose>
            <xsl:when test="$lb[parent::*[self::tei:abbr or self::tei:sic or self::tei:orig]/parent::tei:choice[count(.//tei:lb) eq 1 and not(.//tei:pb or .//tei:cb)] 
                                and not(preceding-sibling::node()) and following-sibling::node()]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="repositionedLb">
        <xsl:apply-templates mode="reposition-lb"/>
    </xsl:variable>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:apply-templates select="$postCorrFixes" mode="reposition-lb"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
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
        <xsl:variable name="choiceIncorrectBreaks" as="node()*" select="$out//tei:choice//(tei:abbr|tei:sic|tei:reg)//(tei:lb|tei:cb|tei:pb)[not(preceding-sibling::node() and following-sibling::node())]"/>
        <xsl:variable name="choiceDescendantOfChoice" as="element(tei:choice)*" select="$out//tei:choice//tei:choice"/>
        <!-- identify possible duplications in adjacent choice resolvings -->
        <xsl:variable name="choiceDuplicatesMain" 
            select="for $e in $out//tei:choice[not(ancestor::*[@place eq 'margin'])]/(tei:corr|tei:expan|tei:reg) return 
                        $e[string-join(./text(),'') eq string-join(preceding::*[local-name(.) eq $e/local-name() and parent::tei:choice and not(ancestor::*[@place eq 'margin'])][1]/text(),'') and ./parent::tei:choice/preceding::tei:choice[not(ancestor::*[@place eq 'margin'])] and count((./parent::tei:choice/preceding::text() intersect ./parent::tei:choice/preceding::tei:choice[1]/following::text())) eq 0]"/>
        <xsl:variable name="choiceDuplicatesMarg" 
            select="for $e in $out//*[@place eq 'margin']//tei:choice/(tei:corr|tei:expan|tei:reg) return 
                        $e[string-join(./text(),'') eq string-join(preceding::*[local-name(.) eq $e/local-name() and parent::tei:choice and ancestor::*[@place eq 'margin']][1]/text(),'') and ./parent::tei:choice/preceding::tei:choice[ancestor::*[@place eq 'margin']] and count((./parent::tei:choice/preceding::text() intersect ./parent::tei:choice/preceding::tei:choice[ancestor::*[@place eq 'margin']][1]/following::text())) eq 0]"/>
        <xsl:variable name="choiceEmptyChildren" as="node()*" select="$out//tei:choice[./*[not(.//text())]]"/>
        <xsl:variable name="choiceChildrenWhitespace" as="element(tei:choice)*" select="$out//tei:choice[child::*/text()[matches(., '\s')]]"/>
        <xsl:variable name="choiceWithoutBorder" as="element(tei:choice)*" select="$out//tei:choice[local:choiceHasNoBorder(.)]"/>
        
        <!-- illegal node within tei:lb -->
        <xsl:variable name="lbIllegalChildNode" as="element(tei:lb)*" select="$out//tei:lb[child::node()]"/>
        
        <!-- checking for invalid or exceptional choice constructs: -->
        <!-- a) choice which seems to be appended to neighbour text/element -->
        <xsl:if test="count($choiceWithoutBorder) gt 0">
            <xsl:for-each select="$choiceWithoutBorder">
                <xsl:message select="concat('WARN: found choice element which seems not to be separated from preceding or following text - resolve this manually! (in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' )')"/>
            </xsl:for-each>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- b) solitary pb/cb/lb within choice are clues for duplications -->
        <xsl:if test="count($choiceIncorrectBreaks) gt 0">
            <xsl:for-each select="$choiceIncorrectBreaks">
                <xsl:message select="concat('ERROR: found solitary break element within choice/', ./parent::*/local-name(), ', of type ', ./local-name(), ' - resolve this manually! (in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' )')"/>
            </xsl:for-each> 
            <!-- search these cases: //tei:choice//(tei:abbr|tei:sic|tei:reg)//(tei:lb|tei:cb|tei:pb)[not(preceding-sibling::node() or following-sibling::node())] -->
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- c) choice duplications (adjacent choice containing identical resolvings -->
        <xsl:if test="count($choiceDuplicatesMain) gt 0">
            <xsl:for-each select="$choiceDuplicatesMain">
                <xsl:message select="concat('ERROR: found adjacent choice/', ./local-name(), ' with identically resolved text - resolve this manually! (in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' )')"/>
            </xsl:for-each>
            <xsl:message terminate="yes" select="concat('ERROR: found ', count($choiceDuplicatesMain), ' cases of adjacent choice with identically resolved text in the main area.')"/>
        </xsl:if>
        <xsl:if test="count($choiceDuplicatesMarg) gt 0">
            <xsl:for-each select="$choiceDuplicatesMarg">
                <xsl:message select="concat('ERROR: found adjacent choice/', ./local-name(), ' with identically resolved text in the marginal area - resolve this manually! (in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' )')"/>
            </xsl:for-each>
            <xsl:message terminate="yes" select="concat('ERROR: found ', count($choiceDuplicatesMarg), ' cases of adjacent choice with identically resolved text in the marginal area.')"/>
        </xsl:if>
        <!-- d) informing about empty choice children -->
        <xsl:if test="count($choiceEmptyChildren) gt 0">
            <xsl:variable name="quot" as="xs:string" select="'&quot;'"/>
            <xsl:for-each select="$choiceEmptyChildren">
                <xsl:message select="concat('WARN: found choice element with empty child, in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' :&#xA;',
                                            '&#009;child::tei:', ./*[1]/local-name(), ' (child 1) has content: ', $quot, string-join(./*[1]//text(),''), $quot, '&#xA;',
                                            '&#009;child::tei:', ./*[2]/local-name(), ' (child 2) has content: ', $quot, string-join(./*[2]//text(),''), $quot)"/>
            </xsl:for-each>
        </xsl:if>
        <!-- e) choice within choice (not strictly an error, but not an expected construct either) -->
        <xsl:if test="$choiceDescendantOfChoice">
            <xsl:for-each select="$choiceDescendantOfChoice">
                <xsl:message select="concat('ERROR: found tei:choice as descendant of other tei:choice, in line ', preceding::tei:lb[1]/@xml:id)"/>
            </xsl:for-each>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- f) whitespace within choice/* -->
        <xsl:if test="count($choiceChildrenWhitespace) gt 0">
            <xsl:variable name="quot" as="xs:string" select="'&quot;'"/>
            <xsl:for-each select="$choiceChildrenWhitespace">
                <xsl:message select="concat('WARN: found choice element with at least one child that has a whitespace-containing text node, in line ', ./preceding::tei:lb[@xml:id][1]/@xml:id, ' :&#xA;',
                                            '&#009;child::tei:', ./*[1]/local-name(), ' (child 1) has content: ', $quot, string-join(./*[1]//text(),''), $quot, '&#xA;',
                                            '&#009;child::tei:', ./*[2]/local-name(), ' (child 2) has content: ', $quot, string-join(./*[2]//text(),''), $quot)"/>
            </xsl:for-each>
        </xsl:if>
        <!-- g) illegal node within tei:lb -->
        <xsl:if test="$lbIllegalChildNode">
            <xsl:for-each select="$lbIllegalChildNode">
                <xsl:message select="concat('ERROR: found lb element with child node(s): ', ./@xml:id, ' - resolve this manually')"/>    
            </xsl:for-each>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- whitespace and regular symbols -->
        <xsl:if test="$inWhitespace ne $outWhitespace">
            <xsl:message select="'WARN: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
        </xsl:if>
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'ERROR: amount of non-whitespace characters differs in input and output.'"/>
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
    
    <!-- TODO: currently not needed, but possibly useful for enhancing performance in finding choice duplications (by avoiding intersections): -->
    <!-- Determines whether a node is itself a tei:choice or contains a tei:choice as last element (recursively). -->
    <xsl:function name="local:getChoice" as="element(tei:choice)?">
        <xsl:param name="rootNode" as="node()?"/>
        <xsl:choose>
            <xsl:when test="$rootNode/self::tei:choice">
                <xsl:copy-of select="$rootNode"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$rootNode/node()[last()]/self::*">
                        <xsl:copy-of select="local:getChoice($rootNode/node()[last()])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

<xsl:function name="local:choiceHasNoBorder" as="xs:boolean">
        <xsl:param name="node" as="element(tei:choice)"/>
        <xsl:variable name="precSibling" as="node()?" select="$node/preceding-sibling::node()[1]"/>
        <xsl:variable name="follSibling" as="node()?" select="$node/following-sibling::node()[1]"/>
        <xsl:choose>
            <xsl:when test="$precSibling/self::text()[not(matches(., '[\s:\.,;\?!\(\)]$'))]
                            or $follSibling/self::text()[not(matches(., '^[\s:\.,;\?!\(\)]'))]
                            or $precSibling/self::*[not(local-name() = ('pb', 'cb', 'lb', 'milestone', 'figure', 'note'))]
                            or $follSibling/self::*[not(local-name() = ('pb', 'cb', 'lb', 'milestone', 'figure', 'note'))]">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

</xsl:stylesheet>