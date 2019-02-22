<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sal="http://salamanca.adwmainz.de" version="3.0" exclude-result-prefixes="exist sal tei xd xs xsl" xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<!-- TODO:
           * tweak/tune performance: use
                - key(), id(), idref() functions
                - self::XY instead of name()='XY'
                - Muenchian keys;
                - Kaysian intersection/set difference;
                - Piezian non-recursive looping;
                - Becker's non-conditional selection;
                - xsltsl library?
           * retrieve div/milestone/list etc. labels from _nodeIndex.xml instead of calculating them here (it's already available in sal:sectionTitle(targetWorkId, targetNodeId)!)
           * check and remove ...Old functions, here and in sal-functions.xsl
           * add line- and column breaks in diplomatic view (problem: infinite scrolling has to comply with the current viewmode as well!)
           * make marginal summary headings expandable/collapsible like we handle notes that are too long
           * make bibls, ref span across (page-)breaks (like persName/placeName/... already do)
           * notes: use templates for note content AND display note only from truncate-limit onwards...
           * notes: toggle '...' in notes when switching between full and teaser display
           * notes/marginal summaries: break teaser text at word boundaries
           * what happens to notes that intervene in a <hi> passage or similar?
           * test <g> code and original/edited switching
-->


<!-- **** I. Import helper functions **** -->
    <xsl:include href="sal-functions.xsl"/>


<!-- **** II. Parameters, Defaults, Key-Value Arrays etc. **** -->
    <xsl:param name="workId" as="xs:string"/>
    <xsl:param name="targetId" as="xs:string"/>
    <xsl:param name="targetIndex" as="xs:string"/>
    <xsl:param name="prevId" as="xs:string"/>
    <xsl:param name="nextId" as="xs:string"/>

    <xsl:output method="html" indent="no"/>

    <xsl:key name="targeting-refs" match="ref[@type='summary']" use="@target"/>         <!-- Key-value array for toc generation -->
    <xsl:key name="chars" match="char" use="@xml:id"/>                                  <!-- Key-value array for special symbol representation -->

    <xsl:param name="noteTruncLimit" select="35"/>
    

<!-- *** III. Named Templates *** -->
    <xsl:template name="anchor-id">                                                     <!-- Small toolbox including anchor for the passed xml:id -->
        <xsl:param name="id"/>
<!--        <xsl:message>Creating anchor for element with id <xsl:value-of select="@xml:id"/>...</xsl:message>-->
        <xsl:element name="span">
            <xsl:element name="a">
                <xsl:attribute name="id" select="$id"/>
                <xsl:attribute name="href" select="concat('#', $id)"/>
                <xsl:attribute name="data-rel">popover</xsl:attribute>
                <xsl:attribute name="data-content">
<!--                <xsl:value-of select="concat(   '<div>',       '<a href="',     sal:resolveURI(current(), concat('#',$id)), '">',           '<span class="    messengers glyphicon glyphicon-link"     title="    go to/link to this textarea"/>',       '</a>',    '  ',    '<a class="updateHiliteBox" href="', replace(sal:resolveURI(current(), concat('#',$id)), '#', concat('&startnodeId=', $id, '#')),'">',  '<span class="glyphicon glyphicon-refresh"/>',               '</a>', '  ', '<a href="print()">', '<span class="glyphicon glyphicon-print" style="color:red;"/>', '</a>', '</div>')"/>-->
                    <xsl:value-of select="concat('&lt;div&gt;', '&lt;a href=&#34;', sal:resolveURI(current(), concat('#',$id)), '&#34;&gt;', '&lt;span class=&#34;messengers glyphicon glyphicon-link&#34; title=&#34;go to/link this textarea&#34;/&gt;', '&lt;/a&gt;', '  ', '&lt;a class=&#34;updateHiliteBox&#34; href=&#34;#34;&gt;', '&lt;span class=&#34;glyphicon glyphicon-refresh&#34;/&gt;', '&lt;/a&gt;', '  ', '&lt;span class=&#34;glyphicon glyphicon-print text-muted&#34;/&gt;', '&lt;/div&gt;')"/>
<!-- Backup:        <xsl:value-of select="concat('   <div>',       '<a href="',                               concat('#',$id), '">',            '<span class="    messengers glyphicon glyphicon-link"     title="    go to/link this textarea"/>',           '</a>',    '  ',    '<span class="    icon-uniE638 text-muted"/>',        '  ',    '<span class="    glyphicon glyphicon-print text-muted"/>',           '</div>')"/> -->
                </xsl:attribute>
                <xsl:element name="i">
                    <xsl:attribute name="class">fa fa-hand-o-right messengers</xsl:attribute>
                    <xsl:attribute name="title">Open toolbox for this textarea</xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    <xsl:template name="pagination-links">                                              <!-- 'Prev' and 'Next' buttons for pagination; draw on global $prevId/$nextId parameters -->
        <div id="SvSalPagination">
            <xsl:if test="$prevId">
                <xsl:element name="a">
                    <xsl:attribute name="class">previous</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('work.html?wid=', $workId, '&amp;frag=', format-number(xs:integer($targetIndex) - 1, '0000'), '_', $prevId)"/>
                    </xsl:attribute>
                    prev
                </xsl:element> |
            </xsl:if>
            <a class="top" href="work.html?wid={$workId}">top</a>
            <xsl:if test="$nextId">
                | <xsl:element name="a">
                    <xsl:attribute name="class">next</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('work.html?wid=', $workId, '&amp;frag=', format-number(xs:integer($targetIndex) + 1, '0000'), '_', $nextId)"/>
                    </xsl:attribute>
                    next
                </xsl:element>
            </xsl:if>
        </div>
    </xsl:template>


<!-- **** IV. Matching Templates **** -->
    <!-- Root element, construct general html frame, then apply templates - to target node (and subnodes) only (*)... -->
    <!-- (*) Remember, however, that if there are ancestors to the target node that we want to render,
         we have to call the div or text templates in non-recursive mode for all such ancestors.
         (This is checked/done in the resp. target node.) -->
    <xsl:template match="/">
        <div class="row">
            <div class="col-md-12">
                <div id="SvSalPages">
                    <div class="SvSalPage">                 <!-- main area (id/class page in order to identify page-able content -->
                        <xsl:apply-templates select="descendant-or-self::*[@xml:id = $targetId]"/>
                    </div>
                </div>                                      <!-- the rest (to the right) is filled by _spans_ with class marginal, possessing
                                                                 a negative right margin (this happens in eXist's work.html template) -->
            </div>
            <xsl:call-template name="pagination-links"/>    <!-- finally, add pagination links --> 
        </div>
    </xsl:template>
    <xsl:template match="titlePage">
<!--        <xsl:message>Matched titlePage node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <xsl:if test="@xml:id=$targetId and not(preceding-sibling::*) and not((ancestor::body | ancestor::back) and preceding::front/*)">
            <xsl:for-each select="ancestor::text[@type='work_volume']/. | ancestor::div/. | ancestor::p/.">
                <xsl:apply-templates select="." mode="non-recursive"/>
            </xsl:for-each>
        </xsl:if>
        <div class="titlePage">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="titlePart[@type='main']">
        <xsl:element name="h1">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="titlePart[not(@type='main')]|docTitle|argument|docDate|docImprint">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="byline|imprimatur">
        <xsl:element name="span">
            <xsl:attribute name="class" select="'tp-paragraph'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="p[ancestor::titlePage]">
        <xsl:element name="span">
            <xsl:attribute name="class" select="'tp-paragraph'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    
    

    <!-- To every <text type='work_volume'>, add a section heading and an anchor
         (to grab link, refresh filters, export/print). -->
    <xsl:template match="text[@type='work_volume']">
<!-- CHECK: What is this doing? Is it even called?
        <xsl:if test="@xml:id=$targetId and not(preceding-sibling::*) and not((ancestor::body | ancestor::back) and preceding::front/*)">
            <xsl:for-each select="ancestor::text[@type='work_volume']/. | ancestor::div/. | ancestor::p/.">
                <xsl:apply-templates select="." mode="non-recursive"/>
            </xsl:for-each>
        </xsl:if>
-->
        <xsl:if test="xs:integer(@n) gt 1">   <!-- If this is the second or an even later volume, add a <hr/> -->
            <hr/>
        </xsl:if>
        <div class="summary_title">
            <xsl:call-template name="anchor-id">
                <xsl:with-param name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:with-param>
            </xsl:call-template> <b>
                <xsl:value-of select="concat('Vol. ', @n)"/>
            </b>
        </div>
        <xsl:apply-templates/>
    </xsl:template>
<!-- CHECK: What is this next template doing? Is it even called? -->
    <xsl:template match="text[@type='work_volume']" mode="non-recursive">
        <xsl:if test="position() gt 1">
            <hr/>
        </xsl:if>
        <div class="summary_title">
            <xsl:call-template name="anchor-id">
                <xsl:with-param name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:with-param>
            </xsl:call-template> <b>
                <xsl:value-of select="concat('Vol. ', @n)"/>
            </b>
        </div>
    </xsl:template>
    
    <!-- To every div, milestone, dictionary or dictionary entry, add a section heading and an anchor
         (to grab link, refresh filters, export/print). -->
    <xsl:template match="div|milestone[@unit ne 'other']|list[@type='dict']|item[parent::list/@type='dict']">
<!--        <xsl:message>Matched div/etc. node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <xsl:if test="@xml:id=$targetId and not(preceding-sibling::*) and not((ancestor::body | ancestor::back) and preceding::front/*)">
            <xsl:for-each select="ancestor::text[@type='work_volume']/. | ancestor::div/. | ancestor::p/.">
                <xsl:apply-templates select="." mode="non-recursive"/>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="@xml:id">
            <xsl:choose>
                <xsl:when test="@rendition='#dagger'">
                    <sup>†</sup>
                </xsl:when>
                <xsl:when test="@rendition='#asterisk'">
                    <xsl:text>*</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <!-- See if we have something we can use to name the thing:
                 Either an @n attribute, a child dict. term or heading, a unit/type + number, or a summary at the beginning of the chapter/in the index etc. -->
            <xsl:if test="@n or (child::head) or (key('targeting-refs', concat('#',@xml:id))) or (self::item and .//term[1]/@key)">
                <div class="summary_title">
                    <xsl:call-template name="anchor-id">
                        <xsl:with-param name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:with-param>
                    </xsl:call-template> 
                    <xsl:choose>
                        <xsl:when test="@n and not(matches(@n, '^\[?[0-9]+\[?$'))"> <!-- @n is something other than a mere number -->
                            <xsl:call-template name="sal:teaserString">
                                <xsl:with-param name="identifier" select="@xml:id"/>
                                <xsl:with-param name="mode">html</xsl:with-param>
                                <xsl:with-param name="input" select="xs:string(@n)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="self::item and .//term[1]/@key">
                            <xsl:value-of select=".//term[1]/@key"/>
                        </xsl:when>
                        <xsl:when test="child::head">
                            <xsl:call-template name="sal:teaserStringHead">
                                <xsl:with-param name="identifier" select="@xml:id"/>
                                <xsl:with-param name="mode">html</xsl:with-param>
                                <xsl:with-param name="input" select="child::head[1]//node()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="matches(@n, '^\[?[0-9]+\[?$') and (@unit eq 'number')">
                            <xsl:value-of select="@n"/>
                        </xsl:when>
                        <xsl:when test="matches(@n, '^\[?[0-9]+\[?$') and (@unit[. ne 'number'] or @type)">
                            <xsl:value-of select="concat(xs:string(@unit), xs:string(@type), ' ', @n)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="sal:teaserString">
                                <xsl:with-param name="identifier" select="@xml:id"/>
                                <xsl:with-param name="mode">html</xsl:with-param>
                                <xsl:with-param name="input" select="key('targeting-refs', concat('#',@xml:id))[1]"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:if>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="div|milestone[@unit ne 'other']|list[@type='dict']|item[parent::list/@type='dict']" mode="non-recursive">
<!--        <xsl:message>Matched div/etc. node <xsl:value-of select="@xml:id"/> (in non-recursive mode).</xsl:message>-->
        <xsl:if test="@xml:id">
            <xsl:choose>
                <xsl:when test="@rendition='#dagger'">
                    <sup>†</sup>
                </xsl:when>
                <xsl:when test="@rendition='#asterisk'">
                    <xsl:text>*</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <!-- See if we have something we can use to name the thing:
                 Either an @n attribute, a child dict. term or heading, a unit/type + number, or a summary at the beginning of the chapter/in the index etc. -->
            <xsl:if test="@n or (child::head) or (key('targeting-refs', concat('#',@xml:id))) or (self::item and .//term[1]/@key)">
                <div class="summary_title">
                    <xsl:call-template name="anchor-id">
                        <xsl:with-param name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:with-param>
                    </xsl:call-template>  
                    <xsl:choose>
                        <xsl:when test="@n and not(matches(@n, '^\[?[0-9]+\[?$'))"> <!-- @n is something other than a mere number -->
                            <xsl:call-template name="sal:teaserString">
                                <xsl:with-param name="identifier" select="@xml:id"/>
                                <xsl:with-param name="mode">html</xsl:with-param>
                                <xsl:with-param name="input" select="xs:string(@n)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="self::item and .//term[1]/@key">
                            <xsl:value-of select=".//term[1]/@key"/>
                        </xsl:when>
                        <xsl:when test="child::head">
                            <xsl:call-template name="sal:teaserStringHead">
                                <xsl:with-param name="identifier" select="@xml:id"/>
                                <xsl:with-param name="mode">html</xsl:with-param>
                                <xsl:with-param name="input" select="child::head[1]//node()"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="matches(@n, '^\[?[0-9]+\[?$') and (@unit eq 'number')">
                            <xsl:value-of select="@n"/>
                        </xsl:when>
                        <xsl:when test="matches(@n, '^\[?[0-9]+\[?$') and (@unit[. ne 'number'] or @type)">
                            <xsl:value-of select="concat(xs:string(@unit), xs:string(@type), ' ', @n)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="sal:teaserString">
                                <xsl:with-param name="identifier" select="@xml:id"/>
                                <xsl:with-param name="mode">html</xsl:with-param>
                                <xsl:with-param name="input" select="key('targeting-refs', concat('#',@xml:id))[1]"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="milestone[@unit eq 'other']" mode="#all">
        <xsl:choose>
            <xsl:when test="@rendition='#dagger'">
                <sup>†</sup>
            </xsl:when>
            <xsl:when test="@rendition='#asterisk'">
                <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- marginal labels will ONLY be displayed on the margin -->
    <!--<xsl:template match="label[@type and @place eq 'margin']" mode="#all">
        <xsl:if test="descendant::text()">
            <div class="summary_title">
                <xsl:call-template name="anchor-id">
                    <xsl:with-param name="id">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="sal:teaserStringHead">
                    <xsl:with-param name="identifier" select="@xml:id"/>
                    <xsl:with-param name="mode">html</xsl:with-param>
                    <xsl:with-param name="input" select=".//node()"/>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>-->

    <!-- Other lists (dict-type lists are handled like divs) -->
    <!-- In html, lists must contain nothing but <li>s, so we have to
         move headings before the list (inside a html <section>/<figure> with the actual list) and nest everything else (sub-lists) in <li>s. -->
    <xsl:template match="list[not(@type='dict')]">
        <xsl:choose>                                                <!-- available list types: "ordered", "simple", "bulleted", "gloss", "index", or "summaries" ("dict" in not available in this pattern) -->
            <xsl:when test="@type='ordered'">                       <!-- Make an enumerated/ordered list -->
                <section>
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:for-each select="child::head">
                        <h4>
                            <xsl:apply-templates/>
                        </h4>
                    </xsl:for-each>
                    <ol>
                        <xsl:for-each select="child::*[not(self::head)]">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </ol>
                </section>
            </xsl:when>
            <xsl:when test="@type='simple'">                        <!-- Make no list in html terms at all -->
                <section>
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:for-each select="child::head">
                        <h4>
                            <xsl:apply-templates/>
                        </h4>
                    </xsl:for-each>
                    <xsl:for-each select="child::*[not(self::head)]">
                        <xsl:apply-templates/>
                    </xsl:for-each>
                </section>
            </xsl:when>
            <xsl:otherwise>                                         <!-- Else put an unordered list (and captions) in a figure environment of class @type -->
                <figure class="{@type}">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:for-each select="child::head">
                        <h4>
                            <xsl:apply-templates/>
                        </h4>
                    </xsl:for-each>
                    <ul style="list-style-type:circle;">
                        <xsl:for-each select="child::*[not(self::head)]">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </ul>
                </figure>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="item[not(parent::list/@type='dict')]">
        <xsl:choose>
            <xsl:when test="parent::list/@type='simple'">
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

    <!-- Headings (unless they are parts of lists) -->
    <xsl:template match="head[not(parent::list[not(@type='dict')])]">
<!--        <xsl:message>Matched head node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    
    
    <!-- Marginal headings: they should only appear as marginal labels, not as actual in-text headings -->
    <!--<xsl:template match="head[@place eq 'margin']"/>-->
    
    <!-- Main Text: put <p> in html <div class="hauptText"> and create anchor if p@xml:id (or just create an html <p> if we are inside a list item);  -->
    <xsl:template match="p[not(ancestor::note or ancestor::titlePage)]">
<!--        <xsl:message>Matched p node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <xsl:choose>
            <xsl:when test="ancestor::item[not(ancestor::list/@type = ('dict', 'index'))]">
                <xsl:element name="p">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:element>
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
    
    <xsl:template match="p[ancestor::note]">
<!--        <xsl:message>Matched note/p node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
            <xsl:element name="span">
                <xsl:attribute name="class" select="'note-paragraph'"/>
                <xsl:apply-templates/>
            </xsl:element>
    </xsl:template>
    
    <xsl:template match="signed">
        <div class="hauptText">
            <div class="signed">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>
    

    <!-- BREAKS -->
    <xsl:template match="pb">                   <!-- insert a '|' and, eventually, a space to indicate pagebreaks in the text -->
<!--        <xsl:message>Matched pb node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <xsl:if test="preceding::pb">
            <xsl:choose>
                <xsl:when test="@break='no'">
                    <xsl:text>|</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> | </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="@n and not(@sameAs)">
            <xsl:element name="div">
                <xsl:attribute name="class">pageNumbers</xsl:attribute>
                <xsl:element name="a">
                    <xsl:attribute name="class">pageNo messengers</xsl:attribute>
                    <xsl:attribute name="href" select="sal:resolveFacsURI(@facs, $serverDomain)"/>  
                    <!-- Resolve canvas IDs, starting at 1 for each volume in multivolume works -->
                    <xsl:attribute name="data-canvas">
                        <xsl:choose>
                            <xsl:when test="matches(@facs, '^facs:W[0-9]{4}-[A-z]-[0-9]{4}$')">
                                <xsl:value-of select="sal:resolveCanvasID(@facs, count(preceding::pb[not(@sameAs) and substring(./@facs, 1, 12) eq substring(current()/@facs, 1, 12)]) + 1, $serverDomain)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="sal:resolveCanvasID(@facs, count(preceding::pb[not(@sameAs)]) + 1, $serverDomain)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="data-sal-id">
                        <xsl:value-of select="sal:mkId($workId, @xml:id)"/>
                    </xsl:attribute>
                    <xsl:choose><!-- create name/id attributes: take the @xml:id if possible -->
                        <xsl:when test="@xml:id">
                            <xsl:variable name="pageAnchor" select="concat('pageNo_', @xml:id/string())"/>
                            <xsl:attribute name="id" select="$pageAnchor"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id" select="concat('pageNo_', generate-id())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose><!-- create title attribute and text content -->
                        <xsl:when test="contains(@n, 'fol.')"><!--For folio paging-->
                            <xsl:attribute name="title" select="concat('View image of ', @n)"/>
                            <xsl:value-of select="@n"/>
                        </xsl:when>
                        <xsl:otherwise><!--For normal paging-->
                            <xsl:attribute name="title" select="concat('View image of page ', @n)"/>
                            <xsl:value-of select="concat('p. ', @n)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cb[not(@break='no')]"> <!-- insert a space if the break is not in a hyphenated word, otherwise insert nothing at all -->
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="lb[not(@break='no')]"> <!-- insert a space if the break is not in a hyphenated word, otherwise insert nothing at all -->
<!--        <xsl:message>Matched lb node <xsl:value-of select="@n"/>.</xsl:message>-->
        <xsl:text> </xsl:text>
    </xsl:template>
<!-- Alternative: Add linebreaks in diplomatic view    
    <xsl:template match="pb">
        <xsl:choose>
            <xsl:when test="@break='no'">
                <xsl:if test="@rendition='#hyphen'">
                    <span class="original unsichtbar">-</span>
                </xsl:if>
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> | </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <!-/- If a @sameAs-Attribute is present, then it's probably better to put the
             page number there where "the other" pagebreak happens...: -/->
        <xsl:if test="@n and empty(@sameAs)">
            <xsl:element name="div">
                <xsl:attribute name="class">pageNumbers</xsl:attribute>
                <xsl:element name="a">
                    <xsl:attribute name="class">pageNo  messengers</xsl:attribute>
                    <xsl:attribute name="href" select="sal:resolveURI(current(), @facs)"/>
                    <xsl:choose>    <!-/- create name/id attributes: take the @xml:id if possible -/->
                        <xsl:when test="@xml:id">
                            <xsl:variable name="pageAnchor" select="concat('pageNo_', substring-after(@xml:id, 'facs_'))"/>
                            <xsl:attribute name="id" select="$pageAnchor"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id" select="concat('pageNo_', generate-id())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>    <!-/- create title attribute and text content -/->
                        <xsl:when test="contains(@n, 'fol.')">  <!-/-For folio paging-/->
                            <xsl:attribute name="title" select="concat('View image of ', @n)"/>
                            <xsl:value-of select="@n"/>
                        </xsl:when>
                        <xsl:otherwise>                         <!-/-For normal paging-/->
                            <xsl:attribute name="title" select="concat('View image of page ', @n)"/>
                            <xsl:value-of select="concat('p. ', @n)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="cb">
        <xsl:choose>
            <xsl:when test="@break='no'">
                <xsl:if test="@rendition='#hyphen'">
                    <span class="original unsichtbar">-</span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="lb">
        <xsl:choose>
            <xsl:when test="@break='no'">
                <xsl:if test="@rendition='#hyphen'">
                    <span class="original unsichtbar">-</span>
                </xsl:if>
                <br class="original unsichtbar"/>
            </xsl:when>
            <xsl:otherwise>
                <br class="original unsichtbar"/>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
-->

    <!-- Notes (and, for now, marginal labels) -->
    <xsl:template match="note|label[@place eq 'margin']">
<!--        <xsl:message>Matched note node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <xsl:element name="div">
            <xsl:attribute name="class">marginal container</xsl:attribute>
            <xsl:attribute name="id" select="@xml:id"/>
            
            <xsl:variable name="normalizedString" select="normalize-space(string-join(.//text()[not(ancestor::sic or ancestor::abbr or ancestor::orig)],' '))"/>
            
            <xsl:variable name="noteContent">
                <xsl:if test="@n">
                    <span class="note-label">
                        <xsl:value-of select="concat(@n, ' ')"/>
                    </span>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="child::p"> <!-- note/p are handled elsewhere -->
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="note-paragraph">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="string-length(concat(@n, ' ', $normalizedString)) ge $noteTruncLimit">
                    <xsl:variable name="id" select="concat('collapse-', @xml:id)"/>
                    <a role="button" class="collapsed note-teaser" data-toggle="collapse" href="{concat('#', $id)}" aria-expanded="false" aria-controls="{$id}">    
                        <p class="collapse" id="{$id}" aria-expanded="false">
                            <xsl:copy-of select="$noteContent"/>
                        </p>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$noteContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- Editorial interventions: Don't hide original stuff where we have no modern alternative, otherwise
         put it in an "orignal" class span which we make invisible by default.
         Put our own edits in spans of class "edited" and add another class to indicate what type of edit has happened -->
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="abbr|orig|sic">
        <xsl:choose>
            <xsl:when test="not(parent::choice)">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="editedString">
                    <xsl:apply-templates select="./parent::choice/(expan|reg|corr)" mode="pureText"/>
                </xsl:variable>
                <span class="original {local-name(.)} unsichtbar" title="{string-join($editedString, '')}">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="abbr|orig|sic" mode="pureText"> <!-- mode pureText for getting text-only nodes for span/@title in original-edited pairs -->
        <xsl:apply-templates mode="pureText"/>
    </xsl:template>
    <xsl:template match="expan|reg|corr">
        <xsl:variable name="originalString">
            <xsl:apply-templates select="./parent::choice/(abbr|orig|sic)" mode="pureText"/>
        </xsl:variable>
        <span class="messengers edited {local-name(.)}" title="{string-join($originalString, '')}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="expan|reg|corr" mode="pureText"> <!-- mode pureText for getting text-only nodes for span/@title in original-edited pairs -->
        <xsl:apply-templates mode="pureText"/>
    </xsl:template>
    
    <!-- Special characters (and normalizations not marked as choice) -->
    <xsl:template match="g">
        <xsl:variable name="thisString" as="xs:string" select="./text()"/> <!-- g must have (only) one text node as child element -->
        <xsl:if test="not(key('chars', substring(@ref,2)))">
            <xsl:message terminate="yes" select="concat('Error: g/@ref has an invalid value, the char code does not exist): ', substring(@ref,2))"/>
        </xsl:if>
        <!-- #### Depending on the context or content of the g element, there are several possible cases: #### -->
        <xsl:choose>
            <!-- 1. if g occurs within choice, it must be a "simple" character since the larger context has already been edited -> pass it through  -->
            <xsl:when test="ancestor::choice">
                <xsl:value-of select="$thisString"/>
            </xsl:when>
            <!-- 2. g occurs outside of choice -->
            <xsl:otherwise>
                <xsl:variable name="precomposedString" as="xs:string?" select="key('chars', substring(@ref,2))/mapping[@type='precomposed']/text()"/>
                <xsl:variable name="composedString" as="xs:string?" select="key('chars', substring(@ref,2))/mapping[@type='composed']/text()"/>
                <xsl:variable name="originalGlyph" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$precomposedString">
                            <xsl:value-of select="$precomposedString" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$composedString" disable-output-escaping="yes"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="string-length($originalGlyph) eq 0">
                    <xsl:message terminate="yes" select="concat('ERROR: no correct mapping available for char: ', @ref)"/>
                </xsl:if>
                <xsl:choose>
                    <!-- a) g has been applied for resolving abbreviations (in early texts W0004, W0013 and W0015) -> treat it like choice elements -->
                    <xsl:when test="not($thisString = ($precomposedString, $composedString)) and not(substring(@ref, 2) = ('char017f', 'char0292'))">
                        <span class="original glyph unsichtbar" title="{$thisString}"><xsl:value-of select="$originalGlyph"/></span>
                        <span class="edited glyph" title="{$originalGlyph}"><xsl:value-of select="$thisString"/></span>
                    </xsl:when>
                    <!-- b) most common case: g simply marks a special character -> pass it through (except for the very frequent "long s" and "long z", 
                                which are to be normalized -->
                    <xsl:otherwise>
                        <xsl:choose>
                            <!-- long s and z shall be switchable in constituted mode to their standardized versions, but due to their high frequency 
                                    we refrain from colourful highlighting (.simple-char). In case colour highlighting is desirable, simply remove .simple-char -->
                            <xsl:when test="substring(@ref, 2) = ('char017f', 'char0292')">
                                <xsl:variable name="standardizedGlyph" as="xs:string" select="key('chars', substring(@ref,2))/mapping[@type='standardized']/text()"/>
                                <span class="original glyph unsichtbar simple-char" title="{$standardizedGlyph}"><xsl:value-of select="$originalGlyph"/></span>
                                <span class="edited glyph simple-char" title="{$originalGlyph}"><xsl:value-of select="$standardizedGlyph"/></span>
                            </xsl:when>
                            <!-- all other "simple" special characters -->
                            <xsl:otherwise>
                                <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="g" mode="pureText"> <!-- "function" for getting text-only nodes for span/@title in original-edited pairs -->
        <xsl:variable name="originalGlyph" as="xs:string">
            <xsl:choose>
                <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='precomposed']">
                    <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='precomposed']/text()" disable-output-escaping="yes"/>
                </xsl:when>
                <xsl:when test="key('chars', substring(@ref,2))/mapping[@type='composed']">
                    <xsl:value-of select="key('chars', substring(@ref,2))/mapping[@type='composed']/text()" disable-output-escaping="yes"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="./text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$originalGlyph"/>
    </xsl:template>
    
    <xsl:template match="damage">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="supplied">
        <span class="original unsichtbar" title="{string(.)}">[<xsl:value-of select="./text()"/>]</span> 
        <span class="edited" title="{concat('[', string(.), ']')}"><xsl:value-of select="./text()"/></span>
    </xsl:template>
    <xsl:template match="supplied" mode="pureText">
        <xsl:apply-templates mode="pureText"/>
    </xsl:template>

    <!-- Analytic references (persNames, titles etc.) -->
    <xsl:template match="docAuthor|persName|placeName|text//title|term">
        <xsl:element name="span">
            <xsl:variable name="class-elementname" select="local-name()"/>
            <xsl:variable name="class-hilightname">
                <xsl:if test="@ref">
                    <xsl:value-of select="concat('hi_', sal:classableString((tokenize(@ref, ' '))[1]))"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="class-dictLemma">
                <xsl:if test="self::term and ancestor::list[@type='dict'] and not(preceding-sibling::term)">
                    <xsl:text>dictLemma</xsl:text>
                </xsl:if>
            </xsl:variable>

            <xsl:attribute name="class" select="normalize-space(string-join(($class-elementname, $class-hilightname, $class-dictLemma), ' '))"/>
            
            <!-- as long as any link would lead nowhere, omit linking and simply grasp the content: -->
            <xsl:apply-templates/>
            <!-- when links have actual targets, execute the following: -->
            <!--<xsl:choose>
                <xsl:when test="@ref and substring(sal:resolveURI(current(), @ref)[1],1, 5) = ('http:', '/exis') ">
                    <xsl:choose>
                        <xsl:when test="not(./pb)"> <!-\- The entity does not contain a pagebreak intervention - no problem then -\->
                            <xsl:element name="a">
                                <xsl:attribute name="href" select="sal:resolveURI(current(), @ref)"/>
                                <xsl:attribute name="target">_blank</xsl:attribute>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>             <!-\- Otherwise, make an anchor for the preceding part, then render the pb, then "continue" the anchor -\->
                            <xsl:element name="a">
                                <xsl:attribute name="href" select="sal:resolveURI(current(), @ref)"/>
                                <xsl:attribute name="target">_blank</xsl:attribute>
                                <xsl:apply-templates select="./pb/preceding-sibling::node()"/>
                            </xsl:element>
                            <xsl:apply-templates select="./pb"/>
                            <xsl:element name="a">
                                <xsl:attribute name="href" select="sal:resolveURI(current(), @ref)"/>
                                <xsl:attribute name="target">_blank</xsl:attribute>
                                <xsl:apply-templates select="./pb/following-sibling::node()"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>-->
        </xsl:element>
    </xsl:template>
    <xsl:template match="bibl">
        <xsl:element name="span">
            <xsl:if test="@sortKey">
                <xsl:attribute name="class" select="concat(local-name(), ' hi_', sal:classableString(@sortKey))"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Other particular elements -->
    <xsl:template match="hi">
<!--        <xsl:message>Matched hi/<xsl:value-of select="@rendition"/> node.</xsl:message>-->
        <xsl:variable name="styles" select="tokenize(@rendition, ' ')"/>
        <xsl:variable name="css-styles">
            <xsl:if test="'#b' = $styles">font-weight:bold;</xsl:if>
            <xsl:if test="'#it' = $styles">font-style:italic;</xsl:if>
            <xsl:if test="'#l-indent' = $styles">display:block;margin-left:4em;</xsl:if>
            <xsl:if test="'#r-center' = $styles">display:block;text-align:center;</xsl:if>
            <xsl:if test="'#sc' = $styles">font-variant:small-caps;</xsl:if>
            <xsl:if test="'#spc' = $styles">letter-spacing:2px;</xsl:if>
            <xsl:if test="'#sub' = $styles">vertical-align:sub;font-size:.83em;</xsl:if>
            <xsl:if test="'#sup' = $styles">vertical-align:super;font-size: .83em;</xsl:if>
        </xsl:variable>
        <xsl:variable name="classnames">
            <xsl:if test="'#initCaps' = $styles">initialCaps</xsl:if>
        </xsl:variable>
        <xsl:element name="span">
            <xsl:if test="string-length(string-join($css-styles, ' ')) gt 0">
                <xsl:attribute name="style" select="string-join($css-styles, ' ')"/>
            </xsl:if>
            <xsl:if test="string-length(string-join($classnames, ' ')) gt 0">
                <xsl:attribute name="class" select="string-join($classnames, ' ')"/>
            </xsl:if>
<!--            <xsl:message>Opened html span with class='<xsl:value-of select="string-join($classnames, ' ')"/>' and style='<xsl:value-of select="string-join($css-styles, ' ')"/>'.</xsl:message>-->
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="l">
        <xsl:apply-templates/>
        <br/>
    </xsl:template>
    <xsl:template match="lg">
<!--        <xsl:message>Matched lg node <xsl:value-of select="@xml:id"/>.</xsl:message>-->
        <span class="poem">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="ref[not(@type='note-anchor')]"> <!-- omit note references -->
        <xsl:choose>
            <xsl:when test="@target">
                <xsl:element name="a">
                    <xsl:attribute name="href" select="sal:resolveURI(current(), @target)"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="quote">
        <span class="quote">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- represent ornaments as short horizontal line -->
    <xsl:template match="figure[@type eq 'ornament']">
        <xsl:element name="hr">
            <xsl:attribute name="class" select="'ornament'"/>
        </xsl:element>
    </xsl:template>
    
    <!-- less significant headings (i.e., h. which do not determine a dedicated div section) are tagged as label[@place=('inline','margin')], to be rendered similar to h4 -->
    <xsl:template match="label[@place eq 'inline']">
        <span class="label-inline">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- For highlighting of search results -->
<!-- <xsl:template match="exist:match">
        <span class="searchterm highlighted">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
-->

    <!-- For the following: dump them, incl. their contents -->
    <xsl:template match="figDesc" mode="#all"/>
    <xsl:template match="teiHeader" mode="#all"/>
    <xsl:template match="fw" mode="#all"/>
    <xsl:template match="text//processing-instruction()" mode="#all"/>
    
</xsl:stylesheet>