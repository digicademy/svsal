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
    
    <xsl:param name="editors" as="xs:string" select="'#DG #CR #auto'"/>
    <xsl:param name="editingDate" as="xs:string" select="'2021-09-22'"/>
    <xsl:param name="changeId" as="xs:string" select="'W0043_Vol01_change_008'"></xsl:param>
    <xsl:param name="editingDesc" as="xs:string" select="'Tagged @type in div(s), list(s) and links in toc.'"/>
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

<!-- First part, tagging @type(s), @n(s), @xml:id(s) in <div1>(s), <div2>(s)-->
    <xsl:variable name="first-part">
        <xsl:apply-templates select="/" mode="first-part"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="first-part">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="first-part"/>
        </xsl:copy>
    </xsl:template>


<!--Added @type to contents lists-->
     <xsl:template match="tei:list[ancestor::tei:div1[@type eq 'contents']]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:attribute name="type" select="'contents'"/>
        <xsl:apply-templates mode="first-part"/>   
     </xsl:copy>
     </xsl:template>

<!--Added @type to index lists-->
     <xsl:template match="tei:list[ancestor::tei:div1[@type eq 'index']]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:attribute name="type" select="'index'"/>
        <xsl:apply-templates mode="first-part"/>   
     </xsl:copy>
     </xsl:template>
 
<!--Added target(s) to ref in toc.-->

<!-- ref(s) in toc, preface-->
    <xsl:template match="tei:ref[not(@target) and ancestor::tei:list[@xml:id eq 'list-pre']]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="nRef" select="count(preceding::tei:ref[not(@target)])+1"/>
        <xsl:attribute name="target" select="concat('#cap',$nRef,'pre')"/>
        <xsl:apply-templates mode="first-part"/>  
     </xsl:copy>
     </xsl:template>

<!-- ref(s) in toc, books(s)-->
    <xsl:template match="tei:head//tei:ref[starts-with(.,'Liber')]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="nRef" select="count(preceding::tei:head//tei:ref[starts-with(.,'Liber')])+1"/>
        <xsl:attribute name="target" select="concat('#b',$nRef)"/>
        <xsl:apply-templates mode="first-part"/>  
     </xsl:copy>
     </xsl:template>

<!-- ref(s) in toc, segments(s). Per book the 'sectio(s) nummering starts again.'-->
    <xsl:template match="tei:ref[not(@target) and matches(.,'SECTIO \w+\.')]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="nRef" select="count(preceding::tei:ref[ancestor::tei:list[@xml:id[matches(.,'list-b')]] = current()/ancestor::tei:list[@xml:id[matches(.,'list-b')]]][not(@target) and matches(.,'SECTIO \w+\.')])+1"/>
        <xsl:variable name="book-id">
            <xsl:value-of select="translate(ancestor::tei:list/@xml:id,'list-','')"/>
        </xsl:variable>
        <xsl:attribute name="target" select="concat('#seg',$nRef,$book-id)"/>
        <xsl:apply-templates mode="first-part"/>  
     </xsl:copy>
     </xsl:template>

<!--Added @n, @type, @xml:id preface.-->
    <xsl:template match="tei:div2[not(@type) and ancestor::tei:div1[@xml:id eq 'preface']]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="nDiv" select="count(preceding::tei:div2[not(@type)])+1"/>
        <xsl:attribute name="xml:id" select="concat('cap',$nDiv,'pre')"/>
        <xsl:attribute name="n" select="$nDiv"/>
        <xsl:attribute name="type" select="'chapter'"/>
        <xsl:apply-templates mode="first-part"/>  
     </xsl:copy>
     </xsl:template>

<!--Added @n, @type, @xml:id in div2 @type.-->

    <xsl:template match="tei:div2[not(@type) and ancestor::tei:div1[@type eq 'book']]" mode="first-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="nDiv" select="count(preceding::tei:div2[ancestor::tei:div1[@type eq 'book'] = current()/ancestor::tei:div1[@type eq 'book']][not(@type)])+1"/>
        <xsl:variable name="book-id"  select="ancestor::tei:div1/@xml:id"/>
        <xsl:attribute name="xml:id" select="concat('seg',$nDiv,$book-id)"/>
        <xsl:attribute name="n" select="$nDiv"/>
        <xsl:attribute name="type" select="'segment'"/>
        <xsl:apply-templates mode="first-part"/>  
     </xsl:copy>
     </xsl:template>


<!--Second-part
Depending on <div2 @type="segment"> adding @type(s), @n(s), @xml:id(s) in <div3>(s) and <div4>(s)
-->
    <xsl:variable name="second-part">
        <xsl:apply-templates select="$first-part" mode="second-part"/>
    </xsl:variable>

    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="second-part">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="second-part"/>
        </xsl:copy>
    </xsl:template>

<!-- Update! Added @target in <ref> of chapters-->

    <xsl:template match="//tei:list//tei:ref[not(@target)]" mode="second-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="capN" select="count(preceding::tei:ref[not(@target) and ancestor::tei:list[@xml:id[matches(.,'list-b')]]])+1"/><!--count(tei:list//tei:list[@xml:id[matches(.,'list-b')]]//tei:list//tei:ref[not(@target)])+1-->
        <!--<xsl:variable name="seg-id" select="preceding::tei:ref[@target[matches(.,'#seg')]][1]/@target"/>-->
        <xsl:attribute name="target" select="concat('#cap',$capN)"/>
        <xsl:apply-templates mode="second-part"/>  
     </xsl:copy>
     </xsl:template>

<!--Added @n, @type, @xml:id in div2 @type.-->

    <xsl:template match="tei:div3[not(@type) and ancestor::tei:div2[@type eq 'segment']]" mode="second-part">
     <xsl:copy>
     <xsl:copy-of select="@*"/>
        <xsl:variable name="nDiv" select="count(preceding::tei:div3[ancestor::tei:div1[@type eq 'book'] = current()/ancestor::tei:div1[@type eq 'book']][not(@type)])+1"/>
        <xsl:variable name="seg-id"  select="ancestor::tei:div2/@xml:id"/>
        <xsl:variable name="idNum" select="count(preceding::tei:div3[not(@type)])+1"/>
        <xsl:attribute name="xml:id" select="concat('cap',$idNum)"/> <!--For the links in toc, all chapters in the work were counted independently from the original number on the original--> 
        <xsl:attribute name="n" select="$nDiv"/> <!--Here, the chapters were counted depending on the original structure. 
                                                     It means in "sectio 1 and 2 in liber1" theare are 8 chapters.
                                                     they are tagged @n 1 to 8. In liber 2 they start the numbering again.-->
        <xsl:attribute name="type" select="'chapter'"/>
        <xsl:apply-templates mode="second-part"/>  
     </xsl:copy>
     </xsl:template>

<!--3rd Part added @type and @n to div4(s).-->
    <xsl:variable name="third-part">
        <xsl:apply-templates select="$second-part" mode="third-part"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="third-part">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="third-part"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div4[not(@type)]" mode="third-part">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="type" select="'section'"/>
            <xsl:variable name="problNum" select="count(preceding::*/self::tei:div4[not(@type)][ancestor::tei:div2[@type eq 'segment'] = current()/ancestor::tei:div2[@type eq 'segment']])+1"/>
            <xsl:attribute name="n" select="$problNum"/>
            <xsl:apply-templates mode="third-part"/>
        </xsl:copy>
    </xsl:template>
    
<!--4th Part added @type and normalized @n to erroneus div4(s).-->
    <xsl:variable name="fourth-part">
        <xsl:apply-templates select="$third-part" mode="fourth-part"/>
    </xsl:variable>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()" mode="fourth-part">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="fourth-part"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:div4[ancestor::tei:div2[@xml:id eq 'seg2b7']]|tei:div4[ancestor::tei:div2[@xml:id eq 'seg2b8']]" mode="fourth-part">
        <xsl:copy>
            <xsl:attribute name="type" select="'section'"/>
            <xsl:variable name="problNum" select="count(preceding::*/self::tei:div4[ancestor::tei:div2[@type eq 'segment'] = current()/ancestor::tei:div2[@type eq 'segment']])+1"/>
            <xsl:attribute name="n" select="concat('[',$problNum,']')"/>
            <xsl:apply-templates mode="third-part"/>
        </xsl:copy>
    </xsl:template>




    <!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$fourth-part"/>
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