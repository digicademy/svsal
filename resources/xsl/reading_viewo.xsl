<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sal="http://salamanca.adwmainz.de" version="2.0" exclude-result-prefixes="exist sal tei xd xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output method="html"/>
    <xsl:param name="modus"/>
    <xsl:param name="docURL"/>

<!-- TODO:
           * test <g> code and original/edited switching
           * Check for other necessary substitutions when constructing class names from attributes
             (in sal:classableString)
           * notes: use templates for note content AND display note only from truncate-limit onwards...
           * notes: toggle '...' in notes when switching between full and teaser display
           * notes/marginal summaries: break teaser text at word boundaries
           ok PersName/PlaceName already have code to cater for intervening pagebreaks
              (end span, create "|" and pagination div, continue by opening a span with the same class)
              ===> Add this for titles, terms and bibls, too
           ok Cater for multiple values in @ref attributes (in tei:resolveURI function, span classes and app.xql)
           ok Add bibl identifying code (using @sortKey)
-->

<!-- **** I. Defaults, Functions, Named Templates etc. **** -->
    <xsl:param name="truncate-limit" select="45"/>

    <!-- resolve Prefixes...
	S. Rahtz on February 2013 in http://tei-l.970651.n3.nabble.com/TEI-P5-version-2-3-0-is-released-td4023117.html.
-->
    <xsl:function name="tei:resolveURI" as="xs:string">
        <xsl:param name="context"/>
        <xsl:param name="targets"/>
        <xsl:variable name="gotoTarget" select="(tokenize($targets, ' '))[1]"/>
        <xsl:analyze-string select="$gotoTarget" regex="(\S+):(\S+)">
            <xsl:matching-substring>
                <xsl:variable name="prefix" select="regex-group(1)"/>
                <xsl:variable name="value" select="regex-group(2)"/>
                <xsl:choose>
                    <xsl:when test="$context/ancestor::*/teiHeader//prefixDef[@ident=regex-group(1)]">
                        <xsl:for-each select="$context/ancestor::*/teiHeader//prefixDef[@ident=regex-group(1)]">
                            <xsl:sequence select="replace($value,@matchPattern,@replacementPattern)"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="regex-group(0)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:choose>
                    <xsl:when test="matches($targets,'^#')">
                        <xsl:value-of select="resolve-uri($targets, $docURL)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    <!-- Generate html class names from attribute values and other un-html-safe strings -->
    <xsl:function name="sal:classableString" as="xs:string">
        <xsl:param name="inputString"/>
        <xsl:value-of select="translate(translate(translate($inputString, ',', ''), ' ', ''), ':', '')"/>
    </xsl:function>
    <!-- Extract teaser string from long string -->
    <xsl:function name="sal:teaserString" as="xs:string">
        <xsl:param name="eingabe"/>
        <xsl:variable name="inputString" select="normalize-space(string-join($eingabe,' '))"/>
        <xsl:choose>
            <xsl:when test="string-length($inputString)&gt;=$truncate-limit">
                <xsl:value-of select="concat(substring($inputString,1,$truncate-limit),'…')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$inputString"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- The following removes accidental whitespace around <lb break="no">, but is not
		needed when the input is properly encoded:
	<xsl:template match="text()[preceding-sibling::*[1][self::lb[@break='no']]]">
		<xsl:value-of select="replace(., '^\s+', '')"/>
	</xsl:template>
	<xsl:template match="text()[following-sibling::*[1][self::lb[@break='no']]]">
		<xsl:value-of select="replace(., '\s+$', '')"/>
	</xsl:template> 
	<xsl:template match="text()[preceding-sibling::*[1][self::cb[@break='no']]]">
		<xsl:value-of select="replace(., '^\s+', '')"/>
	</xsl:template>
	<xsl:template match="text()[following-sibling::*[1][self::cb[@break='no']]]">
		<xsl:value-of select="replace(., '\s+$', '')"/>
	</xsl:template> 
	<xsl:template match="text()[preceding-sibling::*[1][self::pb[@break='no']]]">
		<xsl:value-of select="replace(., '^\s+', '')"/>
	</xsl:template>
	<xsl:template match="text()[following-sibling::*[1][self::pb[@break='no']]]">
		<xsl:value-of select="replace(., '\s+$', '')"/>
	</xsl:template> 
-->
    <xsl:key name="targeting-refs" match="ref[@type='summary']" use="@target"/>
    <xsl:key name="chars" match="char" use="@xml:id"/>

    <!-- named template to create an anchor for the passed xml:id -->
    <xsl:template name="anchor-id">
        <xsl:param name="id"/>
        <xsl:element name="span">
            <xsl:element name="a">
                <xsl:attribute name="name">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <xsl:attribute name="rel">popover</xsl:attribute>
<!--            <xsl:attribute name="data-original-title">myBox oder:<xsl:value-of select="tei:resolveURI(current(), concat('#',$id))"/></xsl:attribute> -->
<!--            <xsl:attribute name="title">my</xsl:attribute>  -->
                <xsl:attribute name="data-content">
                    <xsl:value-of select="concat(                         '&lt;div&gt;',                             '&lt;a href=&#34;',tei:resolveURI(current(), concat('#',$id)),'&#34;&gt;',                                 '&lt;span class=&#34;glyphicon glyphicon-bookmark&#34;/&gt;',                             '&lt;/a&gt;',                             '&#160;&#160;',                             '&lt;a href=&#34;refresh()&#34;&gt;',                                 '&lt;span class=&#34;glyphicon glyphicon-refresh&#34; style=&#34;color:red;&#34;/&gt;',                             '&lt;/a&gt;',                             '&#160;&#160;',                             '&lt;a href=&#34;print()&#34;&gt;',                                 '&lt;span class=&#34;glyphicon glyphicon-print&#34; style=&#34;color:red;&#34;/&gt;',                             '&lt;/a&gt;',                         '&lt;/div&gt;')"/>
                </xsl:attribute>
                <xsl:element name="span">
                    <xsl:attribute name="class">glyphicon glyphicon-leaf</xsl:attribute>
                </xsl:element>
            </xsl:element>
<!--        <xsl:element name="div">
                <xsl:attribute name="id">popover-content</xsl:attribute>
                <xsl:attribute name="class">hide</xsl:attribute>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="tei:resolveURI(current(), concat('#',$id))"/>
                        </xsl:attribute>
                        <xsl:element name="span">
                            <xsl:attribute name="class">glyphicon glyphicon-bookmark</xsl:attribute>
                        </xsl:element>
                    </xsl:element>  
                    <xsl:element name="a">
                        <xsl:attribute name="href"/>
                        <xsl:element name="span">
                            <xsl:attribute name="class">glyphicon glyphicon-refresh</xsl:attribute>
                            <xsl:attribute name="style">color: red;</xsl:attribute>
                        </xsl:element>
                    </xsl:element>  
                    <xsl:element name="a">
                        <xsl:attribute name="href"/>
                        <xsl:element name="span">
                            <xsl:attribute name="class">glyphicon glyphicon-print</xsl:attribute>
                            <xsl:attribute name="style">color: red;</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
            </xsl:element> -->
        </xsl:element>
    </xsl:template>


<!-- **** II. Matching Templates **** -->

    <!-- Root and high-level elements -->
    <!-- In toc mode, apply templates for div children of body, front and back elements. Otherwise,
         prepare html divs and column layout and apply templates for everything -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$modus='toc'">
                <xsl:apply-templates select="//body/div|//front/div|//back/div" mode="toc"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="col-md-11">        <!-- main area -->
                    <xsl:apply-templates/>
                </div>                        <!-- the rest (to the right) is filled by
                                                   spans with class marginal, possessing
                                                   a negative right margin -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="titlePage">
        <div class="titlePage">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!-- Introduce single volumes with special routines (not necessary for monographs) -->
    <xsl:template match="text">
        <div class="summary_title">
            <xsl:call-template name="anchor-id">
                <xsl:with-param name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="@type='work_volume'">
                &#160;Vol.&#160;
                <xsl:choose>
                    <xsl:when test="@n and not(matches(@n, '^[0-9]+$'))">
                        '<xsl:value-of select="sal:teaserString(@n)"/>'
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@n"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </div>
        <xsl:element name="div">
            <xsl:if test="@xml:lang">
                <xsl:attribute name="class">
                    <xsl:text>alpheios-enabled-text</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="lang">
                    <xsl:value-of select="@xml:lang"/>
                </xsl:attribute>
            </xsl:if>
            <!--        <xsl:attribute name="class">lightframe</xsl:attribute>  -->
            <h2 style="text-align:center;">-&#160;※&#160;-</h2>
            <hr/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- To every <div> or milestone, add a section heading and an anchor (to grab link, export, refresh filters). -->
    <xsl:template match="div|milestone">
        <xsl:if test="@xml:id">
<!--        <xsl:if test="(@n and not(matches(@n, '^[0-9]+$'))) or (child::head) or (key('targeting-refs', concat('#',@xml:id)))"> -->
            <xsl:if test="@n or (child::head) or (key('targeting-refs', concat('#',@xml:id)))">
                <div class="summary_title">
                    <xsl:call-template name="anchor-id">
                        <xsl:with-param name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:with-param>
                    </xsl:call-template>&#160; <xsl:choose>
                        <xsl:when test="@n and not(matches(@n, '^[0-9]+$'))">
                            <xsl:value-of select="sal:teaserString(@n)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="child::head">
                                    <xsl:value-of select="sal:teaserString(child::head[1]/text())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="@n and (matches(@n, '^[0-9]+$')) and @type">
                                            <xsl:value-of select="@type"/>
                                            <xsl:value-of select="@n"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="sal:teaserString(key('targeting-refs', concat('#',@xml:id))[1])"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:if>
            <!-- <xsl:call-template name="anchor-id">
                <xsl:with-param name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:with-param>
            </xsl:call-template>-->
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Headings -->
    <!-- In case of a list-heading, this is handled in the list template, so do nothing here: -->
    <xsl:template match="head[(parent::list)]"/>
    <xsl:template match="head[not(parent::list)]">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <!-- Lists -->
    <xsl:template match="list">
        <xsl:choose>
<!-- available list types: "bulleted", "gloss", "index", "ordered", "simple" or "summaries" -->
            <xsl:when test="@type='ordered'">
                <xsl:choose>
                    <xsl:when test="child::head">
                        <figure class="summaria">
                            <xsl:element name="p">
                                <xsl:value-of select="child::head"/>
                            </xsl:element>
                            <ol>
                                <xsl:apply-templates/>
                            </ol>
                        </figure>
                    </xsl:when>
                    <xsl:otherwise>
                        <ol>
                            <xsl:apply-templates/>
                        </ol>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='simple'">
                <xsl:choose>
                    <xsl:when test="child::head">
                        <figure class="summaria">
                            <xsl:element name="p">
                                <xsl:value-of select="child::head"/>
                            </xsl:element>
<!--                            <ul style="list-style-type:none;">  -->
                            <xsl:apply-templates/>
<!--                            </ul>                               -->
                        </figure>
                    </xsl:when>
                    <xsl:otherwise>
<!--                        <ul style="list-style-type:none;"> -->
                        <xsl:apply-templates/>
<!--                        </ul>                              -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@type='summaries'">
                <figure class="summaria">
                    <xsl:if test="child::head">
                        <xsl:element name="p">
                            <xsl:value-of select="child::head"/>
                        </xsl:element>
                    </xsl:if>
                    <ul style="list-style-type:circle;">
                        <xsl:apply-templates/>
                    </ul>
                </figure>
            </xsl:when>
<!--            <xsl:when test="@type=('index', 'gloss', 'bulleted')"> -->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="child::head">
                        <figure class="summaria">
                            <xsl:element name="p">
                                <xsl:value-of select="child::head"/>
                            </xsl:element>
                            <ul style="list-style-type:circle;">
                                <xsl:apply-templates/>
                            </ul>
                        </figure>
                    </xsl:when>
                    <xsl:otherwise>
                        <ul style="list-style-type:circle;">
                            <xsl:apply-templates/>
                        </ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="item|/item">
        <xsl:choose>
            <xsl:when test="parent::list[1]/@type='simple'">
                <xsl:text> </xsl:text>
                <xsl:apply-templates/>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:apply-templates/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Main Text: put <p> in (html) <div>s and create anchor if p@xml:id -->
    <xsl:template match="p">
        <xsl:choose>
            <xsl:when test="ancestor::note">
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <div class="hauptText">
                    <xsl:if test="@xml:id">
                        <xsl:call-template name="anchor-id">
                            <xsl:with-param name="id">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:if> 
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- BREAKS -->
    <!-- Wenn das @sameAs-Attribut gesetzt ist, dann nehmen wir an, ist die Seitenzahl nicht hier,
		 sondern "an der anderen Stelle" in die Marginalspalte zu setzen...: -->
    <xsl:template match="//pb/@xml:id">
        <xsl:variable name="vnumsOnly" select="translate(., translate(.,'0123456789',''), '')"/>
        <xsl:value-of select="substring($vnumsOnly, (substring($vnumsOnly,1,1)='1') +1)"/>
    </xsl:template>
    <xsl:template match="pb">
        <xsl:choose>
            <xsl:when test="@break='no'">
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> | </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@n and empty(@sameAs)">
            <xsl:element name="div">
                <xsl:attribute name="class">pagination</xsl:attribute>
                <xsl:text/>
                <xsl:element name="a">
<!--                <xsl:attribute name="name"><xsl:value-of select="@xml:id"/></xsl:attribute>
                    <xsl:attribute name="title">Open page: <xsl:value-of select="@n"/></xsl:attribute>
                    <xsl:attribute name="id">pageNo<xsl:value-of select="@next"/></xsl:attribute>  -->
                    <xsl:attribute name="class">pageNo</xsl:attribute>
                    <xsl:attribute name="name">
                        <xsl:value-of select="concat('pageNo_', substring-after(@facs, ':'))"/>
                    </xsl:attribute>
                    <xsl:attribute name="id">
                        <xsl:value-of select="concat('pageNo_', substring-after(@facs, ':'))"/>
                    </xsl:attribute>
                    <xsl:attribute name="title">
                        Open page:&#160;<xsl:value-of select="@n"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="tei:resolveURI(current(), @facs)"/>
                    </xsl:attribute>
                    <xsl:value-of select="@n"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="lb[not(@break='no')]">
        <xsl:text> </xsl:text><!-- <br class="original unsichtbar" />-->
    </xsl:template>
<!--    <xsl:template match="lb[@break='no']">
        <br class="original unsichtbar" />
    </xsl:template>
-->
    <xsl:template match="cb[not(@break='no')]">
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Notes -->
    <xsl:template match="note">
        <xsl:element name="div">
            <xsl:attribute name="class">marginal note</xsl:attribute>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
                <xsl:attribute name="name">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(.)) &gt; $truncate-limit">
                    <xsl:element name="a">
                        <xsl:attribute name="data-toggle">collapse</xsl:attribute>
                        <xsl:attribute name="data-target">#restofnote<xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                        <xsl:if test="@n">
                            <b>
                                <sup>
                                    <xsl:value-of select="@n"/>
                                </sup>&#160;
                            </b>
                        </xsl:if>
                        <xsl:value-of select="concat(substring(normalize-space(.),1,$truncate-limit),'…')"/>
                    </xsl:element>
                    <xsl:element name="div">
                        <xsl:attribute name="class">collapse</xsl:attribute>
                        <xsl:attribute name="id">restofnote<xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                        <xsl:attribute name="name">restofnote<xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                        <!--			         <xsl:value-of select="substring(normalize-space(.),$truncate-limit+1)"/>    -->
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- Editorial interventions -->
    <xsl:template match="choice">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- Don't tag original stuff where we have no modern alternative,
         otherwise put it in an "orignal" class span which we make invisible by default -->
    <xsl:template match="abbr|orig|sic">
        <xsl:choose>
            <xsl:when test="not(parent::choice)">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <span class="original unsichtbar">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Put our edits in spans of class "edited" -->
    <xsl:template match="expan|reg|corr">
        <span class="edited">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="g">
        <span class="original unsichtbar">
            <xsl:choose>
                <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='precomposed']">
                    <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='precomposed']/text()" disable-output-escaping="yes"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='composed']">
                            <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='composed']/text()" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <span class="edited">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Analytic references (persNames, titles etc.) -->
    <xsl:template match="persName|placeName|text//title|term">
        <xsl:element name="span">
            <xsl:if test="@ref">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('hi_', sal:classableString((tokenize(@ref, ' '))[1]))"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@ref">
                    <xsl:choose>
                        <xsl:when test="not(./pb)">
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="tei:resolveURI(current(), @ref)"/>
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:value-of select="'_blank'"/>
                                </xsl:attribute>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="tei:resolveURI(current(), @ref)"/>
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:value-of select="'_blank'"/>
                                </xsl:attribute>
                                <xsl:apply-templates select="./pb/preceding-sibling::node()"/>
                            </xsl:element>
                            <xsl:apply-templates select="./pb"/>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="tei:resolveURI(current(), @ref)"/>
                                </xsl:attribute>
                                <xsl:attribute name="target">
                                    <xsl:value-of select="'_blank'"/>
                                </xsl:attribute>
                                <xsl:apply-templates select="./pb/following-sibling::node()"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
<!--
    <xsl:template match="text//title|term">
        <xsl:choose>
            <xsl:when test="@ref">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="tei:resolveURI(current(), @ref)"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:value-of select="concat('hi_', translate(@ref, ':', ''))"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->
    <xsl:template match="bibl">
        <xsl:element name="span">
            <xsl:if test="@sortKey">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('hi_', sal:classableString(@sortKey))"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Other particular elements -->
    <xsl:template match="lg">
        <xsl:element name="span">
            <xsl:attribute name="class">poem</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="l">
        <xsl:apply-templates/>
        <br/>
    </xsl:template>
    <xsl:template match="ref">
        <xsl:choose>
            <xsl:when test="@target">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="tei:resolveURI(current(), @target)"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="hi[@rendition='#sup']">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <xsl:template match="hi[@rendition='#it']">
        <it>
            <xsl:apply-templates/>
        </it>
    </xsl:template>
    <xsl:template match="hi[@rendition='#sc']">
        <span class="smallcaps">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Für  das highlighting der results -->
    <xsl:template match="exist:match">
        <span class="searchterm highlighted">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Für diese: Schmeiss' sie ganz raus, inkl. ihres Inhalts -->
    <xsl:template match="teiHeader"/>
    <xsl:template match="figDesc"/>
    <xsl:template match="fw"/>

    <!-- ================================================================= -->
    <!--                             TOC MODE                              -->
    <!-- ================================================================= -->

    <!-- TODO:
        * use templates to parse head contents, not just output text() value...
        * in recursion, only go one level deeper, not to all of them.
-->
    <!--    <xsl:template match="div|milestone" mode="toc">
        <xsl:if test="(@n and not(matches(@n, '^[0-9]+$'))) or (child::head) or (key('targeting-refs', concat('#',@xml:id)))">
            <li class="toc">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('#',@xml:id)"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="@n and not(matches(@n, '^[0-9]+$'))">
                            <xsl:value-of select="sal:teaserString(@n)"/>
                        </xsl:when>
                        <xsl:when test="child::head">
                            <xsl:value-of select="sal:teaserString(child::head[1])"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="sal:teaserString(key('targeting-refs', concat('#',@xml:id))[1])"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </li>
        </xsl:if>
        <xsl:for-each select="./div|p/milestone">
            <ul class="toc-sub">
                <xsl:apply-templates select="." mode="toc"/>
            </ul>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>-->
<!-- ================================================================= -->
    <!--       TOC MODE     -->
    <!-- ================================================================= -->
    
    <!-- TODO:
    use templates to parse head contents, not just output text() value...
-->
    <xsl:template match="div|milestone" mode="toc">
        <xsl:if test="(preceding-sibling::*) and (following-sibling::*) and (not(child::div))">
            <li>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="string-join(('#',@xml:id), '')"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>hideMe</xsl:text>
                    </xsl:attribute>
                   <!-- <xsl:attribute name="data-dismiss">
                        <xsl:text>modal</xsl:text>
                    </xsl:attribute>-->
                    <!--<xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>-->
                    <xsl:choose>
                        <xsl:when test="child::head">
                            <xsl:value-of select="concat(substring(string-join(head,''),1,$truncate-limit),'…')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="key('targeting-refs',string-join(('#',@xml:id),''))[1]">
                                <xsl:value-of select="concat(substring(string-join(text(),''),1,$truncate-limit),'…')"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </li>
        </xsl:if>
        <!-- <xsl:if test="((position() = last()) or (not(following-sibling::div)))">
            <li class="last">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="string-join(('#',@xml:id), '')"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="child::head">
                            <xsl:value-of select="concat(substring(string-join(head/text(),''),1,$truncate-limit),'…')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="key('targeting-refs',string-join(('#',@xml:id),''))[1]">
                                <xsl:value-of select="concat(substring(string-join(text(),''),1,$truncate-limit),'…')"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </li>
        </xsl:if>-->
        <xsl:if test="not(following-sibling::div) and not(descendant::div[1])">
            <li class="last">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="string-join(('#',@xml:id), '')"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">
                        <xsl:text>hideMe</xsl:text>
                    </xsl:attribute>
                    <!--<xsl:attribute name="data-dismiss">
                        <xsl:text>modal</xsl:text>
                    </xsl:attribute>-->
                    <!--<xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>-->
                    <xsl:choose>
                        <xsl:when test="child::head">
                            <xsl:value-of select="concat(substring(string-join(head,''),1,$truncate-limit),'…')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="key('targeting-refs',string-join(('#',@xml:id),''))[1]">
                                <xsl:value-of select="concat(substring(string-join(text(),''),1,$truncate-limit),'…')"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </li>
        </xsl:if>
        <xsl:if test="div">
            <xsl:if test="(not(preceding-sibling::div)) or (descendant::div[1])">
                <li class="expandable">
                    <div class="hitarea expandable-hitarea"/>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="string-join(('#',@xml:id), '')"/>
                        </xsl:attribute>
                        <xsl:attribute name="class">
                            <xsl:text>hideMe</xsl:text>
                        </xsl:attribute>
                       <!-- <xsl:attribute name="data-dismiss">
                            <xsl:text>modal</xsl:text>
                        </xsl:attribute>-->
                      <!--  <xsl:attribute name="target">
                            <xsl:text>_blank</xsl:text>
                        </xsl:attribute>-->
                        <xsl:choose>
                            <xsl:when test="child::head">
                                <xsl:value-of select="concat(substring(string-join(head,''),1,$truncate-limit),'…')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="key('targeting-refs',string-join(('#',@xml:id),''))[1]">
                                    <xsl:value-of select="concat(substring(string-join(text(),''),1,$truncate-limit),'…')"/>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <ul style="display: none;">
                        <xsl:apply-templates select="div" mode="toc"/>
                    </ul>
                </li>
            </xsl:if>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>