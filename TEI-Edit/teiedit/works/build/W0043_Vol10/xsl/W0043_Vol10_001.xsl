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
    <xsl:param name="editingDate" as="xs:string" select="'2024-05-29'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0043_Vol10_change_007'"/>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged @n, @type, @xml:id(s) in div(s), list(s) and @target in TOC.'"/>
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
    
    <!--first round  mode="first-round"-->
    <xsl:variable name="first-round">
        <xsl:apply-templates select="/" mode="first-round"/>
    </xsl:variable>
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="first-round">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="first-round"/>
        </xsl:copy>
    </xsl:template>

<!--Added @type list.-->    
<!--Added @type to contents lists-->
    <xsl:template match="tei:list[ancestor::tei:div1[@type eq 'contents']]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'contents'"/>
            <xsl:apply-templates mode="first-round"/>   
        </xsl:copy>
    </xsl:template>
<!--Added @type to index lists-->
    <xsl:template match="tei:list[ancestor::tei:div1[@type eq 'index']]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'index'"/>
            <xsl:apply-templates mode="first-round"/>   
        </xsl:copy>
    </xsl:template>
    <!--Added @n, @type in div1-->
    <xsl:template match="tei:div1[not(@type)]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'book'"/>
            <xsl:attribute name="n" select="replace(./@xml:id,'b','')"/>
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>
    <!--Added @n, @type, @xml:id in div2-->
    <xsl:template match="tei:div2" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="not(@type)">
                        <xsl:value-of select="'segment'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@type"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:variable name="book-id" select="current()/ancestor::tei:div1/@xml:id"/>
            <xsl:variable name="n" select="count(preceding::tei:div2[not(@type)][ancestor::tei:div1[starts-with(@xml:id,'b')] = current()/ancestor::tei:div1[starts-with(@xml:id,'b')]])+1"/>
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="not(@xml:id)">
                        <xsl:value-of select="concat('seg',$n,$book-id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="not(@n)">
                    <xsl:value-of select="$n"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@n"/></xsl:otherwise>
                </xsl:choose>            
            </xsl:attribute>
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>
    <!--Added @n, @type, @xml:id in div3-->
    
    <xsl:template match="tei:div3[ancestor::tei:div1[@xml:id = ('b54','b55','b56','b57','b58','b59','b60','b61')]]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div3[ancestor::tei:div1[starts-with(@xml:id,'b')] = current()/ancestor::tei:div1[starts-with(@xml:id,'b')]])+1"/>
            <xsl:variable name="book-id"  select="ancestor::tei:div1/@xml:id"/>
            <xsl:attribute name="xml:id" select="concat('cap',$nDiv,$book-id)"/>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="not(@n)">
                        <xsl:value-of select="$nDiv"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@n"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="type" select="'chapter'"/>  
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div3[ancestor::tei:div1[@xml:id = ('b62')]]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div3[ancestor::tei:div2 = current()/ancestor::tei:div2])+1"/>
            <xsl:variable name="part-id"  select="ancestor::tei:div2/@xml:id"/>
            <xsl:variable name="tocDiv" select="count(preceding::tei:div3[ancestor::tei:div1 = current()/ancestor::tei:div1])+1"/>
            <xsl:attribute name="xml:id" select="concat('cap',$tocDiv,'b62')"/>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="not(@n)">
                        <xsl:value-of select="$nDiv"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@n"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="type" select="'chapter'"/>  
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>

    <!--TOC Added @target in ref-->   
    
    <!-- div1 "Booklevel" -->
    
    <xsl:template match="tei:ref[starts-with(.,'L')]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="book-id"  select="current()/ancestor::tei:list/@xml:id"/>
            <xsl:attribute name="target" select="concat('#',translate($book-id,'list-',''))"/>  
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- div2 "Segmentlevel"-->
    <xsl:template match="tei:head//tei:ref[starts-with(.,'S')]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nSeg" select="count(preceding::tei:head//tei:ref[starts-with(.,'S') and ancestor::tei:list[@xml:id[starts-with(.,'list')]] = current()//ancestor::tei:list[@xml:id[starts-with(.,'list')]]])+1"/>
            <xsl:variable name="book-id"  select="current()/ancestor::tei:list/@xml:id[starts-with(.,'list')]"/>
            <xsl:attribute name="target" select="concat('#seg',$nSeg,translate($book-id,'list-',''))"/>  
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:head//tei:ref[starts-with(.,'P')]" mode="first-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nPart" select="count(preceding::tei:head//tei:ref[starts-with(.,'P') and ancestor::tei:list[@xml:id[starts-with(.,'list')]] = current()//ancestor::tei:list[@xml:id[starts-with(.,'list')]]])+1"/>
            <xsl:variable name="book-id"  select="current()/ancestor::tei:list/@xml:id[starts-with(.,'list')]"/>
            <xsl:attribute name="target" select="concat('#part',$nPart,translate($book-id,'list-',''))"/>  
            <xsl:apply-templates mode="first-round"/>
        </xsl:copy>
    </xsl:template>
<!--Second round  mode="second-round"-->

    <xsl:variable name="second-round">
        <xsl:apply-templates select="$first-round" mode="second-round"/>
    </xsl:variable>
    <xsl:template match="@*|node()" mode="second-round">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="second-round"/>
        </xsl:copy>
    </xsl:template>

<!-- TOC div3 "Chapterlevel" -->
    <xsl:template match="tei:ref[not(@target)]" mode="second-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nCap" select="count(preceding::tei:ref[not(@target) and ancestor::tei:list[@xml:id] = current()//ancestor::tei:list[@xml:id[starts-with(.,'list')]]])+1"/>
            <xsl:variable name="book-id"  select="current()/ancestor::tei:list/@xml:id[starts-with(.,'list')]"/>
            <xsl:attribute name="target" select="concat('#cap',$nCap,translate($book-id,'list-',''))"/>  
            <xsl:apply-templates mode="second-round"/>
        </xsl:copy>
    </xsl:template>

<!--Added @n in div4. Some cases normalized in []. @type, doubt. @type section was added manually-->  
    
    <xsl:template match="tei:div4[not(@type) and ancestor::tei:div1[@xml:id = ('b54','b55','b57','b58','b60','b61')]]" mode="second-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div4[not(@type) and ancestor::tei:div2[@type eq 'segment'] = current()/ancestor::tei:div2[@type eq 'segment']])+1"/>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$nDiv"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="type" select="'doubt'"/>  
            <xsl:apply-templates mode="second-round"/>
        </xsl:copy>
    </xsl:template>
    <!-- For cases where @n should be normalized with [] b56-->
    <xsl:template match="tei:div4[not(@type) and ancestor::tei:div1[@xml:id = ('b56','b59')]]" mode="second-round">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="nDiv" select="count(preceding::tei:div4[not(@type) and ancestor::tei:div2[@type eq 'segment'] = current()/ancestor::tei:div2[@type eq 'segment']])+1"/>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('[',$nDiv,']')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="type" select="'doubt'"/>  
            <xsl:apply-templates mode="second-round"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$second-round"/>
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
            <xsl:message select="'ERROR: amount of non-whitespace characters differs in input and output doc: '"/>
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
    

</xsl:stylesheet>