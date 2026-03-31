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
    <xsl:param name="editingDate" as="xs:string" select="'2020-10-26'"/>
    <xsl:param name="changeId" as="xs:string" select="'WXXXX_change_XXX'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Added (es) abbreviations depending on word endings with regex.'"/>
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
    
    <!-- identity transform -->
    <!-- expanding abbreviations of spanish words depending on their Endings e.g.:
        "endo - pudiẽdo", "ando - dudãdo", "ente - gẽte", "ende - entiẽde", "cion - Purificaciõ",
        "ento - mandamiẽto", "encia - differẽcia", "ẽ and er - entẽder", "ẽ and ar - encomẽdar",
        
        ATENTION!
        * "cõ - con" has too many exceptions because new lines, spaces etc., that is why it cannot be included here.
        e.g. "cõla", "cõ <lb/>feſſarſe"
        
         Requeriments:
         This program is to be used only in TEI-tite texts before the TEI-Transformation and special character annotation are done,
         otherwise it won't work.-->
    
    <!--words ending with "endo" e.g. "pudiẽdo"-->
    <xsl:variable name="endo">
        <xsl:apply-templates select="/" mode="endo"/>
    </xsl:variable>
        
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="endo">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="endo"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="endo">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſç]+)(ẽ|ẽ|ē)(do)([\s\.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- words ending in "ando" e.g. dudãdo -->
    <xsl:variable name="ando">
        <xsl:apply-templates select="$endo" mode="ando"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ando">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ando"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="ando">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ã|ã|ā)(do)([\s\.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--adverbs ending in "mente" e.g. "mortalmẽte", or nouns ending with "ẽte" e.g. "gẽte"-->
    <xsl:variable name="mente">
        <xsl:apply-templates select="$ando" mode="mente"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="mente">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="mente"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="mente">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(te)([\s\.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--words ending in "ende" e.g. "entiẽde"-->
    <xsl:variable name="ende">
        <xsl:apply-templates select="$mente" mode="ende"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ende">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ende"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="ende">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(de)([\s\.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--words ending in "cion" e.g. "Purificaciõ"-->
    <xsl:variable name="cion">
        <xsl:apply-templates select="$ende" mode="cion"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="cion">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="cion"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="cion">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(zi|ſi|si|ci)(õ|õ|ō|ō)([\s\.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),'on')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--words ending in "ento" e.g. "mandamiẽto"-->
    <xsl:variable name="ento">
        <xsl:apply-templates select="$cion" mode="ento"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ento">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ento"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="ento">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(to)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--words ending in "encia" e.g. "differẽcia"-->
    <xsl:variable name="encia">
        <xsl:apply-templates select="$ento" mode="encia"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="encia">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="encia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="encia">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(cia)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!--words ending in "ancia" e.g. "ignorãcia"-->
    <xsl:variable name="ancia">
        <xsl:apply-templates select="$encia" mode="ancia"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ancia">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ancia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="ancia">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ã|ã|ā)(cia)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!--verbs containing ẽ and ending in "er" e.g. "entẽder"-->
    <xsl:variable name="er">
        <xsl:apply-templates select="$ancia" mode="er"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="er">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="er"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="er">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſç]+)(ẽ|ẽ|ē)([aA-zZſç]?)(er)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    <!--verbs containing ẽ and ending in "ar" e.g. "encomẽdar"-->
    <xsl:variable name="ar">
        <xsl:apply-templates select="$er" mode="ar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="ar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſç]+)(ẽ|ẽ|ē)([aA-zZſç]?)(ar)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--verbs containing ã and ending in "ar" e.g. "mãdar"-->
    <xsl:variable name="aar">
        <xsl:apply-templates select="$ar" mode="aar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="aar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="aar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:text//text()[not(ancestor::tei:abbr)]" mode="aar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſç]+)(ã|ã|ā)([aA-zZſç]?)(ar)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
   
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$aar"/>
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
            <xsl:message select="'ERROR: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="yes"/>
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
        <!-- Update last variable from regex -->
        <xsl:variable name="Expansions" as="xs:integer" select="count($aar//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan'])"/>
        <xsl:message select="concat('INFO: added ', xs:string($Expansions), ' with regex-based (word endings) abbr. expansion.')"/>
        
        <xsl:message select="'INFO: quality check successfull.'"/>
    </xsl:template>
    

</xsl:stylesheet>