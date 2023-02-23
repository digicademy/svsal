<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns="http://purl.oclc.org/dsdl/schematron">
    
    <!-- SCHEMATRON aims at checking integrity of "advanced" conditions of a SvSal TEI doc that must be met in order for the document 
        to be ready for publication. Such features include the correct tagging of special characters, abbreviation expansions, semantic 
        properties of head and div elements, or the checking for (redundant) whitespace, among others -->
    
    <ns uri="http://www.tei-c.org/ns/1.0" prefix="tei"/>
    
    <!-- !!! PARAMETERS (need to be adjusted) !!! -->
    
    <!-- POST-CORRECTION: the following parameters need to be set to true() -->
    <let name="checkLbHasXmlId" value="false()"/> <!-- check whether lb has @xml:id -->
    <let name="checkUntaggedSpecialChars" value="true()"/> <!-- search for untagged special chars -->
    <let name="checkExcessiveWhitespace" value="false()"/> <!-- search for excessive whitespace (e.g., more than two blanks clustered together) -->
    
    <!-- OPTIONAL parameters: further parameters: -->
    <let name="checkDivN" value="true()"/> <!-- check whether tei:div has @n -->
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <let name="specialCharsDeclared" value="doc('../../../../../svsal-tei/meta/specialchars.xml')//tei:teiHeader//tei:charDecl//tei:char"/>
    
    <pattern id="text_in_basicElemt">
        <rule context="text()[not(normalize-space() eq '') and ancestor::tei:text]">
            <assert test="ancestor::*[local-name() = ('p', 'head', 'item', 'l', 'label', 'note', 'signed', 'titlePage','cell')]">
                ERROR: Text outside basic element: <value-of select="preceding::tei:lb/@xml:id[1]"/>.
            </assert>
        </rule>
    </pattern>
    <pattern id="special-chars">
        <rule context="tei:g">
            <assert test="starts-with(@ref, '#') and substring-after(@ref, '#') = $specialCharsDeclared/@xml:id">
                ERROR: special character code should be a valid code from the charDecl: <value-of select="@ref"/>.
            </assert>
            <assert test="count(child::node()) eq 1 and child::node()/self::text() and not(matches(child::node(), '\s'))">
                ERROR: g element must have exactly one child, which must be a text node without any whitespace.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="untagged-special-chars">
        <rule context="tei:text//text()[$checkUntaggedSpecialChars and not(ancestor::tei:g or ancestor::tei:foreign)]">
            <assert test="not(matches(., '[&#x0100;-&#x10ffff;]'))">
                ERROR: Text node untagged as special character should only contain characters between U+0000 and U+00FF (caused by char 
                <value-of select="replace(., '.*?([&#x0100;-&#x10ffff;]).*?', '$1')"/>).
            </assert>
            <!-- if errors of this type point to higher-level elements (p, item, ...), try searching for regex [\u0100-\uFFFF] in order to find the 
                precise location of untagged chars -->
        </rule>
        <rule context="tei:text//text()[not(ancestor::tei:ref)]">
            <assert test="not(contains(., '[†\*]'))">
                WARN: found unannotated '†' or '*'.
            </assert>
        </rule>
        <rule context="tei:text//text()">
            <assert test="not(matches(., '[-=]{2,}'))">
                WARN: found sequence of hyphenation marks.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="oxygen-comments">
        <rule context="tei:text//processing-instruction()">
            <assert test="not(starts-with(name(.), 'oxy_comment_start') or starts-with(name(.), 'oxy_comment_end'))">
                WARN: oXygen/editor comments should have been resolved.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="whitespace">
        <rule context="tei:g">
            <assert test="not(matches(.//text(), '\s'))">
                ERROR: Element g must not contain any whitespace.
            </assert>
        </rule>
        <rule context="(tei:pb|tei:cb|tei:lb)[not(ancestor::*[@place eq 'margin'])]">
            <assert test="not(@break eq 'no' and matches(preceding::text()[not(ancestor::*[@place eq 'margin'])][1], '\s$'))">
                ERROR: The text node preceding a break="no" element in the main text should end with a non-whitespace character.
            </assert>
            <assert test="not(@break eq 'yes' and matches(following::text()[1], '^\s'))">
                Error: the text node following a break="yes" element should start with a non-white character.
            </assert>
        </rule>
        <!-- find these by means of: //(pb|cb|lb)[@break eq 'no' and matches(preceding::text()[1], '\s$')] -->
        <rule context="(tei:pb|tei:cb|tei:lb)[ancestor::*[@place eq 'margin']]">
            <assert test="not(@break eq 'no' and matches(following::text()[ancestor::*[@place eq 'margin']][1], '^\s'))">
                ERROR: the text node following a break="no" element in the marginal area should start with a non-whitespace character.
            </assert>
            <assert test="not(@break eq 'yes' and matches(following::text()[1], '^\s'))">
                Error: the text node following a break="yes" element should start with a non-white character.
            </assert>
        </rule>
        <!-- find these by means of: //(pb|cb|lb)[@break eq 'no' and matches(following::text()[1], '^\s')] -->
        <rule context="tei:text//text()[$checkExcessiveWhitespace and not(normalize-space() eq '')]"> <!-- limit this rule to those text nodes not occurring immediately before lb[not(@break eq 'no')]? -->
            <assert test="not(matches(., '\S\s{2,}\S'))"> <!-- excessive whitespace within text -->
                WARN: text node contains redundant whitespace (found in node with preceding lb: <value-of select="preceding::tei:lb[1]/@xml:id"/>).
            </assert>
            <!-- check for whitespace at the end of line? -->
            <!-- to find these instances, search for regex '\s{3,}' in XPath '//text//text()[matches(., '\S')]' -->
        </rule>
    </pattern>
    
    <pattern id="multi-breaks">
        <rule context="tei:text//tei:lb">
            <assert test="not(@break eq 'no' and (preceding-sibling::*[1]/self::tei:cb[not(@break eq 'no')] or preceding-sibling::*[1]/self::tei:pb[not(@break eq 'no')]))">
                ERROR: lb marked as break="no" need to be preceded by cb or pb that are equally marked as 'no'.
            </assert>
            <assert test="not(@rendition eq '#hyphen' and preceding-sibling::*[1][self::tei:cb or self::tei:pb])">
                ERROR: lb marked as rendition="#hyphen" must not be preceded by cb or pb or must not be tagged as such.
            </assert>
            <assert test="not(@break eq 'no' and (preceding-sibling::node()[1]/descendant-or-self::tei:foreign or (preceding-sibling::node()[1]/self::tei:note and preceding-sibling::node()[2]/descendant-or-self::tei:foreign)) and (following-sibling::node()[1]/descendant-or-self::tei:foreign or (following-sibling::node()[1]/self::tei:note and following-sibling::node()[2]/descendant-or-self::tei:foreign)))">
                ERROR: tei:foreign is divided by a lb @break and a marginal note. 
            </assert>
        </rule>
        <rule context="tei:text//tei:cb[not(@type eq 'end')]">
            <assert test="not(@break eq 'no' and (preceding-sibling::*[1]/self::tei:pb[not(@break eq 'no')] or following-sibling::*[1]/self::tei:lb[not(@break eq 'no')]))">
                ERROR: cb marked as break="no" need to be preceded by pb and/or followed by lb that are equally marked as 'no'.
            </assert>
            <assert test="not(@rendition eq '#hyphen' and preceding-sibling::*[1]/self::tei:pb)">
                ERROR: cb marked as rendition="#hyphen" must not be preceded by pb or must not be tagged as such.
            </assert>
            <assert test="following-sibling::node()[not(self::text() and normalize-space() eq '')][1][self::tei:lb or self::tei:figure]">
                ERROR: cb must be directly followed by lb.
            </assert>
        </rule>
        <rule context="tei:text//tei:pb">
            <assert test="not(@break eq 'no' and (following-sibling::*[1][self::tei:cb[not(@break eq 'no')] or self::tei:lb[not(@break eq 'no')]]))">
                ERROR: pb tagged as break="no" must be followed by cb or lb equally tagged as break="no".
            </assert>
            <assert test="following-sibling::node()[not(self::text() and normalize-space() eq '')][1][self::tei:lb or self::tei:cb or self::tei:figure] or @type eq 'blank'">
                ERROR: pb must be directly followed by either cb or lb, or have @type='blank'.
            </assert> <!-- what about figure after pb? -->
            <assert test="not(@break eq 'no' and not(@rendition))">
                ERROR: a pb marked as break='no' should also have @rendition.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="cb">
        <rule context="tei:cb[@type eq 'start']">
            <assert test="preceding::tei:cb[not(ancestor::tei:note)][1]/@type[. eq 'end'] or not(preceding::tei:cb[not(ancestor::tei:note)])">
                ERROR: cb[@type=start] must occur after cb[type=end] or as the first cb overall.
            </assert>
        </rule>
        <rule context="tei:cb[@type eq 'end']">
            <assert test="following::tei:cb[not(ancestor::tei:note)][1]/@type[. eq 'start'] or not(following::tei:cb[not(ancestor::tei:note)])">
                ERROR: cb[@type=end] must occur before cb[type=start] or as the last cb overall.
            </assert>
        </rule>
        <rule context="tei:cb[not(@type)]">
            <assert test="preceding::tei:cb[@type eq 'start'] and following::tei:cb[@type eq 'end']">
                ERROR: Intermediate cb must be preceded by a cb[@type=start] and followed by a cb[@type=end].
            </assert>
        </rule>
        <rule context="tei:note//tei:cb">
            <assert test="matches(@sameAs, '^#')">
                ERROR: cb within note must be tagged as @sameAs, its value starting with '#'.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="line-numbers">
        <rule context="tei:lb[$checkLbHasXmlId and not(@sameAs)]">
            <assert test="@xml:id">
                ERROR: lb needs to have @xml:id.
            </assert>
            <!--<assert test="matches(@xml:id, 'W\d{4}-\d{2}-\d{4}-[a-z]{2}-[m\d]\d{3}')">
                lb/@xml:id needs to follow the pattern ''W\d{4}-\d{2}-\d{4}-[a-z]{2}-[m\d]\d{3}' (found <value-of select="@xml:id"/>).
            </assert>-->
        </rule>
        <rule context="tei:lb[$checkLbHasXmlId and @sameAs]">
            <assert test="@xml:id">
                ERROR: lb[@sameAs] needs to have @xml:id.
            </assert>
            <!--<assert test="matches(@xml:id, 'W\d{4}-\d{2}-\d{4}-[a-z]{2}-[s]\w{3}')">
                lb[@sameAs]/@xml:id needs to follow the pattern ''W\d{4}-\d{2}-\d{4}-[a-z]{2}-s\w{3}' (found <value-of select="@xml:id"/>).
            </assert>-->
        </rule>
    </pattern>
    
    <pattern id="general-xmlid">
        <!--<rule context="tei:text//*[not(self::tei:lb)]/@xml:id">
            <assert test="$checkXmlId and matches(., 'W\d{4}-\d{2}-\d{4}-[a-z][\w]-\w{4}')">
                xml:id should have a 21-place value following the pattern W\d{4}-\d{2}-\d{4}-[a-z][\w]-\w{4} (found <value-of select="."/>).
            </assert>
        </rule>-->
    </pattern>
    
    <pattern id="choice-breaks">
        <rule context="tei:choice[descendant::tei:pb]">
            <assert test="count(descendant::tei:pb) = (count(child::*),count(child::*)*2)">
                ERROR: if pb occurs within choice, all child elements need to have (the same amount of) pb.
            </assert>
        </rule>
        <rule context="tei:choice[descendant::tei:cb]">
            <assert test="count(descendant::tei:cb) = (count(child::*),count(child::*)*2)">
                ERROR: if cb occurs within choice, all child elements need to have (the same amount of) cb.
            </assert>
        </rule>
        <rule context="tei:choice[descendant::tei:lb]">
            <assert test="count(descendant::tei:lb) = (count(child::*),count(child::*)*2)">
                ERROR: if lb occurs within choice, all child elements need to have (the same amount of) lb.
            </assert>
        </rule>
        <rule context="tei:choice//*[self::tei:pb or self::tei:cb or self::tei:lb]">
            <assert test="@break">
                ERROR: pb/cb/lb within choice should always have @break.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="choice-general">
        <rule context="tei:choice">
            <assert test="not(preceding-sibling::node()[1]/self::tei:choice[child::*[1]/name() eq current()/child::*[1]/name()])">
                WARN: choice elements of the same type usually should not occur clustered together.
            </assert> <!-- search by means of: //tei:choice/following-sibling::node()[1]/self::tei:choice -->
            <assert test="count(child::node()) eq 2 and 
                            ((child::tei:sic and child::tei:corr)
                             or (child::tei:abbr and child::tei:expan)
                             or (child::tei:orig and child::tei:reg)
                            )">
                ERROR: Element choice needs to have 2 child elements of correct types and pairing (sic-corr, abbr-expan, orig-reg).
            </assert>
            <assert test="not(.//text()[matches(., '\.,;\?!')])">
                WARN: interpunctuation should not be corrected/normalized.
            </assert>
            <assert test="if (not(./*[not(.//text())])) then count(./*[1]//tei:hi) eq count(./*[2]//tei:hi) else true()">
                WARN: amount of tei:hi should be equal in all child elements of tei:choice.
            </assert>
        </rule>
        <rule context="tei:choice/*[not(self::tei:sic)]/text()"> <!-- sic elements may contain erroneously printed blanks -->
            <assert test="not(matches(.,'\s'))">
                WARN: text nodes within choice usually should not contain any whitespace.
            </assert>
        </rule>
        <rule context="tei:choice//tei:abbr">
            <assert test="following-sibling::node()[1]/self::tei:expan">
                ERROR: tei:abbr (within tei:choice) must be immediately followed by tei:expan.
            </assert>
        </rule>
        <rule context="tei:choice//(tei:abbr|tei:sic|tei:reg)//(tei:lb|tei:cb|tei:pb)">
            <assert test="./following-sibling::node() and preceding-sibling::node()">
                ERROR: break element within first orig unit must have preceding and following siblings.
            </assert>
        </rule>
        <rule context="tei:choice//tei:sic">
            <assert test="following-sibling::node()[1]/self::tei:corr">
                ERROR: tei:sic (within tei:choice) must be immediately followed by tei:corr.
            </assert>
        </rule>
        <rule context="tei:choice//tei:orig">
            <assert test="following-sibling::node()[1]/self::tei:reg">
                ERROR: tei:abbr (within tei:choice) must be immediately followed by tei:reg.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="choice-structure">
        <rule context="(orig|abbr|sic)[parent::choice]">
            <assert test="./parent::choice/(expan|reg|corr)">
                ERROR: orig|abbr|sic within choice requires a matching sibling of type expan|reg|corr.
            </assert>
        </rule>
        <rule context="(expan|reg|corr)[parent::choice]">
            <assert test="./parent::choice/(orig|abbr|sic)">
                ERROR: expan|reg|corr within choice requires a matching sibling of type orig|abbr|sic.
            </assert>
        </rule>
    </pattern>
    
    <!-- TODO: tei:choice sanity checks from postCorrFixes.xsl (duplications etc.) -->
    
    <!-- if lb/cb/pb in abbr etc. then also in expan etc. ... -->
    
    
    <pattern id="div">
        <rule context="tei:div[$checkDivN and not(@type = ('chapter', 'part', 'article', 'book'))]">
            <assert test="@n/string()">
                WARN: does tei:div need a descriptive @n value?
            </assert>
        </rule>
        <rule context="tei:div[$checkDivN and @type = ('chapter', 'part', 'article', 'book')]">
            <assert test="matches(@n, '\d')">
                WARN: does tei:div (chapter, book, part, article) need a numeric @n value?
            </assert>
        </rule>
        <rule context="tei:div">
            <assert test="(.//text())[1]/ancestor::tei:head">
                WARN: first text node within div is not within a heading - (tei:div usually has tei:head as first child).
            </assert>
        </rule>
    </pattern>
    
    <pattern id="foreign">
        <rule context="tei:foreign">
            <assert test="@xml:lang">
                ERROR: element tei:foreign must have @xml:lang.
            </assert>
            <assert test="not(following-sibling::node()[1]/self::tei:g)">
                ERROR: tei:foreign must include all (special) characters of a word.
            </assert>
            <assert test="not(following-sibling::node()[1]/self::tei:g)">
                ERROR: tei:foreign must include all (special) characters of a word.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="del">
        <rule context="tei:del">
            <assert test="not(.//text() and .//tei:gap)">
                ERROR: tei:del should either contain a tei:gap element or text content, but not both.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="references">
        <rule context="tei:text//@sameAs|tei:text//@corresp|tei:text//@target">
            <assert test="starts-with(./string(), '#')">
                ERROR: values of reference attributes need to be prefixed by '#'.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="milestones">
        <rule context="tei:milestone">
            <assert test="not(ancestor::tei:choice)">
                WARN: element milestone must not occur within a choice element.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="unclear">
        <rule context="tei:unclear">
            <assert test=".">
                WARN: unclear marks should have been resolved.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="pb">
        <rule context="tei:pb[not(@type eq 'blank' or @sameAs)]">
            <assert test="matches(@n, '^(Fo\.)?(fo\.)?(Fol\.)?(fol\. )?\[?(Fo\.)?(fo\.)?([\dclijxv]{1,11})\.?\]?[rv]?$')">
                ERROR: pb/@n must follow the pattern '^(Fo\.)?(Fol\.)?(fol\. )?\[?(Fo\.)?([\dclijxv]{1,11})\.?\]?[rv]?$'.
            </assert>
        </rule>
        <rule context="tei:note//tei:pb">
            <assert test="matches(@sameAs, '^#')">
                ERROR: pb within note must be tagged as @sameAs, its value starting with '#'.
            </assert>
        </rule>
        <rule context="tei:pb">
            <assert test="not(@sameAs and @facs)">
                ERROR: pb cannot have both @facs and @sameAs.
            </assert>
            <assert test="not(./parent::*[self::tei:front or self::tei:body or self::tei:back])">
                ERROR: pb must not occur as child of front|body|back (but within titlePage, div, ...)
            </assert>
        </rule>
    </pattern>
    
    <!-- unresolved hyphens -->
    <pattern id="hyphens">
        <rule context="tei:text//tei:lb[preceding::text()[not(normalize-space() eq '')][1][matches(., '[-=]\s?$')]]">
            <assert test="not(.)">
                WARN: hyphens at the end of text nodes should be resolved in @break/@rendition of pb/cb/lb.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="p">
        <rule context="tei:p[not(ancestor::tei:note|ancestor::tei:argument)]">
            <assert test="string-length(replace(string-join(.//text(), ''), '\s', '')) ge 5">
                ERROR: a main-text paragraph (tei:p) must contain at least 5 non-whitespace characters.
            </assert>
            <assert test="string-length(replace(string-join(.//text(), ''), '\s', '')) ge 25">
                INFO: extremely short paragraph.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="note">
        <rule context="tei:text//tei:note[not(@anchored eq 'false')]">
            <assert test="preceding-sibling::*[1]/self::tei:ref[substring(./@target, 2) eq current()/@xml:id]">
                ERROR: a note not marked as anchored=false requires an in-text reference (tei:ref).
            </assert>
        </rule>
    </pattern>
    
    <pattern id="list">
        <rule context="tei:text//tei:list">
            <assert test="@type">
                WARN: List must have @type.
            </assert>
        </rule>
    </pattern>
    
    <pattern id="ref">
        <rule context="tei:text//tei:ref">
            <assert test="not(child::tei:pb)">
                WARN: tei:ref contains tei:pb - this may lead to erroneous image links in the web reading view (should be dealt with by web app, though).
            </assert>
            <assert test="not(child::tei:cb or tei:lb)">
                WARN: tei:ref should not contain tei:cb or tei:lb (these always should occur within the first mixed-content element).
            </assert>
        </rule>
        <!--
        This rule should be fixed to find ref elements without @n, @type="note-anchor", @target before anchored notes.
        <rule context="tei:ref[following-sibling::*[1]/self::tei:note]">
            <assert test="@type or @n">
                WARN: tei:ref before anchored notes should contain @n, @type="note-anchor", @target.
            </assert>
        </rule>-->
    </pattern>
    
    <pattern id="figure">
        <rule context="tei:figure">
            <assert test="not(child::node())">
                ERROR: Element figure must not have children.
            </assert>
            <assert test="not(preceding-sibling::node()[1]/self::tei:lb)">
                ERROR: A mere figure should not be marked as a line.
            </assert>
            <assert test="not(ancestor::tei:p[not(descendant::text()[not(normalize-space() eq '')])])">
                ERROR: A mere figure should not be tagged as a paragraph (p).
            </assert>
            <assert test="@type">
                ERROR: Figure tags should be typed (@type, with a value of either "ornament" or "illustration").
            </assert>
            <assert test="not(not(ancestor::tei:div) and following-sibling::*[1]/self::tei:div or following-sibling::*[1]/self::tei:back)">
                ERROR: Found Figure outside div(s). They should be inside div(s).
            </assert>
        </rule>
    </pattern>
    
</schema>