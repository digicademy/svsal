<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exist="http://exist.sourceforge.net/NS/exist"
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    version="2.0"
    exclude-result-prefixes="xd xs exist teix tei"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output method="html"/>
    <xsl:param name="modus"/>
    <xsl:param name="language"/>

    <!-- Root -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$modus='toc'">
                <xsl:apply-templates select="//div[@type='chapter']" mode="toc"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--process h2-hn-->
    <xsl:template match="div[@type='part']/head">
        <h1 class="alignedGuidelines">
            <xsl:apply-templates/>
        </h1>
    </xsl:template>
    <xsl:template match="div[@type='chapter']/head">
        <h2 class="alignedGuidelines">
            <xsl:if test="@n">
                <xsl:value-of select="@n"/>  </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <xsl:template match="div[@type='section']/head">
        <h3 class="alignedGuidelines">
            <xsl:if test="@n">
                <xsl:value-of select="@n"/>  </xsl:if>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>
    <xsl:template match="div[@type='part']//div">
        <div>
            <xsl:element name="a">
                <xsl:attribute name="name">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!--Importante-->
    <xsl:template match="q[@type='optional']">
        <xsl:choose>
            <xsl:when test="$language='de'">
                <span class="label label-success">OPTIONAL</span> 
            </xsl:when>
            <xsl:when test="$language='en'">
                <span class="label label-success">OPTIONAL</span> 
            </xsl:when>
            <xsl:when test="$language='es'">
                <span class="label label-success">OPCIONAL</span> 
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="q[@type='important']">
        <xsl:choose>
            <xsl:when test="$language='de'">
                <span class="label label-danger">WICHTIG</span>
            </xsl:when>
            <xsl:when test="$language='en'">
                <span class="label label-danger">IMPORTANT</span>
            </xsl:when>
            <xsl:when test="$language='es'">
                <span class="label label-danger">IMPORTANTE</span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="q[@type='glyphicon-leaf']">
        <span class="glyphicon glyphicon-leaf blue"/>
    </xsl:template>

    <!--Making span-Element look as code-->
    <xsl:template match="hi[@rendition='#code']|att|val|tag|gi">
        <xsl:choose>
            <xsl:when test="@type='bold'">
                <code style="color:black; font-size:2em;">
                    <xsl:apply-templates/>
                </code>
            </xsl:when>
            <xsl:when test="@type='text-bold'">
                <span style="font-size:1.2em;">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <code style="color:black;">
                    <xsl:apply-templates/>
                </code>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="p">
        <p class="textGuidelines">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="ref">
        <a href="{@target}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template match="graphic">
        <img src="{@url}">
            <xsl:apply-templates/>
        </img>
    </xsl:template>
    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="@type='ordered'">
                <ol class="textGuidelines">
                    <xsl:apply-templates/>
                </ol>
            </xsl:when>
            <xsl:otherwise>
                <ul class="textGuidelines">
                    <xsl:apply-templates/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="item">
        <xsl:if test="parent::list[@type='ordered']">
            <li class="listGuidelines">
                <xsl:value-of select="item"/>
                <xsl:apply-templates/>
            </li>
        </xsl:if>
        <xsl:if test="not(parent::list[@type='ordered'])">
            <li style="list-style-type: square; margin-left: 20px;">
                <xsl:value-of select="item"/>
                <xsl:apply-templates/>
            </li>
        </xsl:if>
    </xsl:template>
    <xsl:template match="teiHeader"/>
    <xsl:template match="teix:egXML">
        <div class="textGuidelines">
            <pre type="syntaxhighlighter" class="brush: xml">
                <xsl:apply-templates/>
            </pre>
        </div>
    </xsl:template>
    <xsl:template match="teix:*">
        <xsl:copy-of select="." copy-namespaces="no"/>
    </xsl:template>


    <!-- ================================================================= -->
    <!--                             TOC MODE                              -->
    <!-- ================================================================= -->

    <!-- TODO:
        * use templates to parse head contents, not just output text() value...
        * in recursion, only go one level deeper, not to all of them.
-->
    <!-- <xsl:template match="div" mode="toc">
        <li class="toc">
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('#',@xml:id)"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="child::head">
                        <xsl:value-of select="head[1]/@n"/>  <xsl:value-of select="head[1]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </li>
        <xsl:for-each select="./div">
            <ul class="toc">
                <xsl:apply-templates select="." mode="toc"/>
            </ul>
        </xsl:for-each>
    </xsl:template>-->
   <!-- <xsl:template match="div" mode="toc">
        <li class="toc">
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('#',@xml:id)"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="child::head">
                        <xsl:value-of select="head[1]/@n"/>  <xsl:value-of select="head[1]"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </li>
        <xsl:for-each select="./div">
                <xsl:apply-templates select="." mode="toc"/>
        </xsl:for-each>
    </xsl:template>-->
    
    <!--in Collapsible manner-->
    <xsl:template match="div" mode="toc">
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::div[@type = 'chapter']) and @type='chapter'">
                <div class="panel panel-default">
                    <div class="panel-heading" role="tab" id="{@xml:id}">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" data-parent="#accordion" href="#{head/@xml:id}" aria-expanded="true" aria-controls="{head/@xml:id}">
                                <xsl:value-of select="head/@n"/>  
                                <xsl:choose>
                                    <xsl:when test="head/att">
                                        <xsl:value-of select="head/att/text()"/>
                                    </xsl:when>
                                    <xsl:when test="head">
                                        <xsl:value-of select="head/text()"/>
                                    </xsl:when>
                                </xsl:choose>
                                
                               <!-- <xsl:if test="head/att/text()">
                                    <xsl:value-of select="head/att/text()"/>
                                </xsl:if>
                                <xsl:value-of select="head"/>-->
                            </a>
                        </h4>
                    </div>
                    <div id="{head/@xml:id}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="{@xml:id}">
                        <ul class="list-group">
                            <xsl:for-each select="descendant::div">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('#',@xml:id)"/>
                                    </xsl:attribute>
                                    <li class="list-group-item">
                                        <xsl:apply-templates select="head/@n"/> <!--<xsl:apply-templates select="head/text()"/>-->
                                        <xsl:choose>
                                            <xsl:when test="head/att">
                                                <xsl:value-of select="head/att/text()"/>
                                            </xsl:when>
                                            <xsl:when test="head">
                                                <xsl:value-of select="head/text()"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </li>
                                </xsl:element>
                            </xsl:for-each>
                        </ul>
                    </div>
                </div>
            </xsl:when>
            <xsl:when test="preceding-sibling::div[@type = 'chapter']">
                <div class="panel panel-default">
                    <div class="panel-heading" role="tab" id="{@xml:id}">
                        <h4 class="panel-title">
                            <a class="collapsed" data-toggle="collapse" data-parent="#accordion" href="#{head/@xml:id}" aria-expanded="false" aria-controls="{head/@xml:id}">
                                <xsl:value-of select="head/@n"/>  <xsl:value-of select="head"/>
                            </a>
                        </h4>
                    </div>
                    <div id="{head/@xml:id}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="{@xml:id}">
                        <ul class="list-group">
                            <xsl:for-each select="descendant::div">
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('#',@xml:id)"/>
                                    </xsl:attribute>
                                    <li class="list-group-item">
                                        <xsl:apply-templates select="head/@n"/> <!--<xsl:apply-templates select="head/text()"/>-->
                                        <xsl:choose>
                                            <xsl:when test="head/att">
                                                <xsl:value-of select="head/att/text()"/>
                                            </xsl:when>
                                            <xsl:when test="head">
                                                <xsl:value-of select="head/text()"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </li>
                                </xsl:element>
                            </xsl:for-each>
                        </ul>
                    </div>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>