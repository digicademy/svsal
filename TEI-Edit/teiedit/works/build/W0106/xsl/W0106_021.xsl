<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    <xsl:param name="editors" as="xs:string" select="'#CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2022-05-10'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0106_change_030'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Transformed note(s) into milestone(s).'"/>
    <xsl:template match="tei:teiHeader/tei:revisionDesc/tei:listChange" mode="round1">
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
            <xsl:apply-templates mode="round1"/>
        </xsl:copy>
    </xsl:template>
    
    <!--INFO:
        
        JLE 05.05.22 on converting notes into milestones.
        
     It is true that Vázquez de Menchaca does not introduce in the Controversiae notes per se, but the text in the margin coincides, 
     in general, with that of the summary that appears at the beginning of each section. However, the text of this second summary or
     reading guide in the margin does not coincide one hundred percent with that of the summary. Let's say that Vázquez de Menchaca 
     reformulates it in many cases with other words. There are also cases in which he or the editors introduce in the margin the
     name of some author on which he is relying or more arguments than those initially contemplated in the summary (this is the case 
     of this example where the numbers end in Intelli. 8, but then adds 6 more arguments in short form, such as Intelli. 9, 10, 11, etc.).
     In any case, the option of doing it without the marginal texts seems to be a good one. You lose something, but you don't really 
     lose much and the readers can follow the work without having the feeling that they are missing content that we cut out.
     
    The following shows, the proces of correcting notes from manual corrections and afterwards converting ref into into milestones, so all marginal text <notes> will be deleted.-->
    
    <!--1. add ref-element to anchores '†' next to note(s), in order to complete <ref><note> structure.-->

    <xsl:variable name="round1">
        <xsl:apply-templates select="/" mode="round1"/>
    </xsl:variable>
    <!-- identity transform -->
    <xsl:template match="@* except @part|node()" mode="round1">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="round1"/>
        </xsl:copy>
    </xsl:template>

     <xsl:template match="//tei:g[matches(.,'†') and following-sibling::node()[1]/self::tei:note]" mode="round1">
         <xsl:element name="ref">
             <xsl:attribute name="target" select="concat('#',following-sibling::node()[1]/self::tei:note/@xml:id[1])"/>
             <xsl:attribute name="type" select="'note-anchor'"/>
             <xsl:attribute name="resp" select="'#CR #auto'"/>
             <xsl:copy>
             <xsl:copy-of select="@*"/>
             <xsl:apply-templates mode="round1"/>
            </xsl:copy>
         </xsl:element>
     </xsl:template>
    
    
    <!--2. convert ref (anchors) into milestone. -->
    
    <xsl:variable name="round2">
        <xsl:apply-templates select="$round1" mode="round2"/>
    </xsl:variable>
    <!-- identity transform -->
    <xsl:template match="@* except @part|node()" mode="round2">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="round2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:ref[@type eq 'note-anchor' and following-sibling::*[1]/self::tei:note[@n and @anchored eq 'true']]" mode="round2">
        <xsl:element name="milestone">
            <xsl:attribute name="n" select="following-sibling::*[1]/self::tei:note[@n and @anchored eq 'true']/@n"/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="rendition" select="'dagger'"/>
            <xsl:variable name="id" select="current()/@target"/>
            <xsl:attribute name="xml:id" select="translate($id,'#','')"/>
            <xsl:attribute name="resp" select="'#CR #auto'"/>
        </xsl:element>
    </xsl:template>
    
    <!--3. Delete notes with anchor-->
    
    <xsl:variable name="round3">
        <xsl:apply-templates select="$round2" mode="round3"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@* except @part|node()" mode="round3">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="round3"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:note[@n and @anchored eq 'true']" mode="round3"/>
    
    <!--4. convert nummbered notes without anchor in milestone(s).-->
    
    <xsl:variable name="round4">
        <xsl:apply-templates select="$round3" mode="round4"/>
    </xsl:variable>
    <!-- identity transform -->
    <xsl:template match="@* except @part|node()" mode="round4">
        <xsl:copy>
            <xsl:apply-templates select="@* except @part|node()" mode="round4"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//tei:note[@n and @anchored eq 'false']" mode="round4">
        <xsl:element name="milestone">
            <xsl:attribute name="n" select="@n"/>
            <xsl:attribute name="unit" select="'section'"/>
            <xsl:attribute name="xml:id" select="@xml:id"/>
            <xsl:attribute name="resp" select="'#CR #auto'"/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$round4"/>
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
        <!-- whitespace -->
        <xsl:if test="$inWhitespace ne $outWhitespace">
            <xsl:message select="'INFO: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- chars -->
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'INFO: amount of non-whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- breaks -->
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
            <xsl:message select="'INFO: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- special chars -->
        <xsl:if test="$inSpecialChars ne $outSpecialChars">
            <xsl:message select="'INFO: different amount of input and output special chars: '"/>
            <xsl:message select="concat('Input special chars: ', $inSpecialChars, ' | output special chars: ', $outSpecialChars)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    

</xsl:stylesheet>