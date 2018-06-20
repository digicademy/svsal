<xsl:stylesheet xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:sal="http://salamanca.adwmainz.de" version="3.0" exclude-result-prefixes="xsl xi tei functx xs exist fn sal xd" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <xsl:import href="xipr-1-1.xsl"/>   <!-- XInclude processing -->

    <xsl:param name="truncate-limit" select="45"/>
    <xsl:param name="serverDomain" as="xs:string" select="salamanca.school"/>

    <xsl:variable name="idserver" as="xs:string" select="concat('https://id.', $serverDomain)"/>
    <xsl:variable name="teiserver" as="xs:string" select="concat('https://tei.', $serverDomain)"/>

<!--<xsl:key name="elementsById"    match="div | p | head | list | item" use="@xml:id"/> <!-/- Does this require too much memory? -->
    <xsl:key name="targeting-refs" match="ref[@type='summary']" use="@target"/>
    <xsl:key name="chars" match="char" use="@xml:id"/>

    
    <!-- Generate valid html class names from attribute values and other un-html-safe strings -->
    <xsl:function name="sal:classableString" as="xs:string">
        <xsl:param name="inputString"/>
        <xsl:value-of select="translate(translate(translate($inputString, ',', ''), ' ', ''), ':', '')"/>
    </xsl:function>

    <!-- Extract teaser string from long string -->
    <xsl:template name="sal:teaserString">
        <xsl:param name="input"/>
        <xsl:param name="mode"/>                      <!-- shall we return html or plaintext? -->
        <xsl:param name="identifier" as="xs:string"/> <!-- if it's html, how should we identify the restOfString div? -->

        <xsl:variable name="normalizedString" select="normalize-space(string-join($input,' '))"/>

        <xsl:choose>
            <xsl:when test="string-length($normalizedString)&gt;=$truncate-limit">
                <xsl:variable name="localTeaserString" select="concat(substring($normalizedString, 1, $truncate-limit),'…')"/>
                <xsl:choose>
                    <xsl:when test="$mode/text()='html'">
                        <xsl:element name="a">
                            <xsl:attribute name="data-toggle">collapse</xsl:attribute>
                            <xsl:attribute name="data-target">#restOfString<xsl:value-of select="$identifier"/>
                            </xsl:attribute>
                            <xsl:value-of select="$localTeaserString"/>
                            <i class="fa fa-angle-double-down"/>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="class">collapse</xsl:attribute>
                            <xsl:attribute name="id">restOfString<xsl:value-of select="$identifier"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="$input"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$localTeaserString"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Resolve Private namespace prefixes...
	   cf. S. Rahtz on February 2013 in http://tei-l.970651.n3.nabble.com/TEI-P5-version-2-3-0-is-released-td4023117.html.
    -->
    <xsl:function name="sal:resolveURIOld">
        <xsl:param name="context"/>
        <xsl:param name="targets"/>

        <xsl:variable name="currentWork" select="$context/ancestor-or-self::TEI"/>
        <xsl:variable name="gotoTarget" select="(tokenize($targets, ' '))[1]"/>         <!-- If there are many targets, ours is always the first one -->
        <xsl:variable name="prefixDef" select="$currentWork//prefixDef"/>

        <!--
        <xsl:message>sal:resolveURI:</xsl:message>
        <xsl:message>... input URI <xsl:value-of select="$targets"/></xsl:message>
        <xsl:message> - gotoTarget <xsl:value-of select="$gotoTarget"/></xsl:message>
        <xsl:message> - count(currentWork): <xsl:value-of select="count($currentWork)"/></xsl:message>
        <xsl:message> - count(prefixDef):   <xsl:value-of select="count($prefixDef)"/></xsl:message>
-->
        <xsl:analyze-string select="$gotoTarget" regex="(work:(W[A-z0-9.:_\-]+))?#(.*)">
            <xsl:matching-substring>                                                    <!-- Target is something like "work:W...#..." -->
                <!--                <xsl:message>analyze-1: match</xsl:message>-->
                <xsl:variable name="targetWorkId">
                    <xsl:choose>
                        <xsl:when test="regex-group(2)">                <!-- Target is a link containing a work id -->
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:when>
                        <xsl:otherwise>                                 <!-- Target is just a link to a fragment anchor, so targetWorkId = currentWork -->
                            <xsl:value-of select="xs:string($currentWork/@xml:id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="anchorId" select="regex-group(3)"/>

                <!--
                <xsl:message> - targetWorkId <xsl:value-of select="$targetWorkId"/></xsl:message>
                <xsl:message> - achorId      <xsl:value-of select="$anchorId"/></xsl:message>
-->
                <xsl:if test="$anchorId">
                    <xsl:value-of select="sal:mkId($targetWorkId, $anchorId)"/>
                </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>                                                <!-- Target does not contain "#", or is not a "work:..." url -->
                <!--                <xsl:message>analyze-1: non-match</xsl:message>-->
                <xsl:analyze-string select="$gotoTarget" regex="(\S+):([A-z0-9.:#_\-]+)">           <!-- Use the general replacement mechanism as defined by the prefixDef in W_Head_general.xml -->
                    <xsl:matching-substring>
                        <!--                        <xsl:message>analyze-2: match</xsl:message>-->
                        <xsl:variable name="prefix" select="regex-group(1)"/>
                        <xsl:variable name="value" select="regex-group(2)"/>
                        <xsl:choose>
                            <xsl:when test="$prefixDef[@ident=regex-group(1)]">
                                <xsl:for-each select="$prefixDef[@ident=regex-group(1)][matches($value, @matchPattern)]">
                                    <xsl:sequence select="replace($value, @matchPattern, @replacementPattern)"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="regex-group(0)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>                                        <!-- If none of this applies, just copy the target from the input parameter -->
                        <!--                        <xsl:message>analyze-2: non-match</xsl:message>-->
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="sal:resolveURI">
        <xsl:param name="context"/>
        <xsl:param name="targets"/>

        <xsl:variable name="currentWork" select="$context/ancestor-or-self::TEI"/>
        <xsl:variable name="gotoTarget" select="(tokenize($targets, ' '))[1]"/>         <!-- If there are many targets, ours is always the first one -->
        <xsl:variable name="prefixDef" select="$currentWork//prefixDef"/>

        <!--
        <xsl:message>sal:resolveURI:</xsl:message>
        <xsl:message>... input URI <xsl:value-of select="$targets"/></xsl:message>
        <xsl:message> - gotoTarget <xsl:value-of select="$gotoTarget"/></xsl:message>
        <xsl:message> - count(currentWork): <xsl:value-of select="count($currentWork)"/></xsl:message>
        <xsl:message> - count(prefixDef):   <xsl:value-of select="count($prefixDef)"/></xsl:message>
-->
        <xsl:analyze-string select="$gotoTarget" regex="(work:(W[A-z0-9.:_\-]+))?#(.*)">
            <xsl:matching-substring>                                                    <!-- Target is something like "work:W...#..." -->
                <xsl:variable name="targetWorkId">
                    <xsl:choose>
                        <xsl:when test="regex-group(2)">                                    <!-- Target is a link containing a work id -->
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:when>
                        <xsl:otherwise>                                                     <!-- Target is just a link to a fragment anchor, so targetWorkId = currentWork -->
                            <xsl:value-of select="xs:string($currentWork/@xml:id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="anchorId" select="regex-group(3)"/>
<!--
                <xsl:message> - targetWorkId <xsl:value-of select="$targetWorkId"/></xsl:message>
                <xsl:message> - achorId      <xsl:value-of select="$anchorId"/></xsl:message>
-->
                <xsl:if test="$anchorId">
                    <xsl:value-of select="sal:mkId($targetWorkId, $anchorId)"/>
                </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>                                                <!-- Target does not contain "#", or is not a "work:..." url -->
                <xsl:analyze-string select="$gotoTarget" regex="facs:((W[0-9]+)[A-z0-9.:#_\-]+)">
                    <xsl:matching-substring>                                                        <!-- Target is a facs string -->
                        <xsl:variable name="targetWorkId">
                            <xsl:choose>
                                <xsl:when test="regex-group(2)">                                        <!-- extract work id from facs string-->
                                    <xsl:value-of select="regex-group(2)"/>
                                </xsl:when>
                                <xsl:otherwise>                                                         <!-- or use targetWorkId = currentWork -->
                                    <xsl:value-of select="xs:string($currentWork/@xml:id)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="anchorId" select="regex-group(1)"/>                         <!-- extract facs string -->
                        <xsl:value-of select="sal:mkId($targetWorkId, concat('facs_', $anchorId))"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>                                                    <!-- Target is not a facs string -->
                        <xsl:analyze-string select="$gotoTarget" regex="(\S+):([A-z0-9.:#_\-]+)">           <!-- Use the general replacement mechanism as defined by the prefixDef in W_Head_general.xml -->
                            <xsl:matching-substring>
                                <xsl:variable name="prefix" select="regex-group(1)"/>
                                <xsl:variable name="value" select="regex-group(2)"/>
                                <xsl:choose>
                                    <xsl:when test="$prefixDef[@ident=regex-group(1)]">
                                        <xsl:for-each select="$prefixDef[@ident=regex-group(1)][matches($value, @matchPattern)]">
                                            <xsl:sequence select="replace($value, @matchPattern, @replacementPattern)"/>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="regex-group(0)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>                                        <!-- If none of this applies, just copy the target from the input parameter -->
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>


    <!-- Function yields the appropriate iiif link for the image URI stated in @facs -->
    <xsl:function name="sal:resolveFacsURI">
        <xsl:param name="facsTargets"/>
        <xsl:param name="serverDomain"/>

        <xsl:variable name="gotoTarget" select="(tokenize($facsTargets, ' '))[1]"/>         <!-- If there are many targets, ours is always the first one -->
        <xsl:variable name="iiifRenderParams" select="string('/full/full/0/default.jpg')"/>

        <xsl:analyze-string select="$gotoTarget" regex="facs:(W[0-9]{{4}})\-([0-9]{{4}})">    <!-- single-volume work, e.g.: facs:W0017-0005 -->
            <xsl:matching-substring>                                                    
                <xsl:variable name="workId" select="regex-group(1)"/>
                <xsl:variable name="facsId" select="regex-group(2)"/>
                <xsl:value-of select="concat('http://facs.', $serverDomain, '/iiif/image/', $workId, '!', $workId, '-', $facsId, $iiifRenderParams)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>                                                
                <xsl:analyze-string select="$gotoTarget" regex="facs:(W[0-9]{{4}})\-([A-z])\-([0-9]{{4}})">    <!-- volume of a multi-volume work, e.g.: facs:W0013-A-0007-->
                    <xsl:matching-substring>                                                    
                        <xsl:variable name="workId" select="regex-group(1)"/>
                        <xsl:variable name="volId" select="regex-group(2)"/>
                        <xsl:variable name="facsId" select="regex-group(3)"/>
                        <xsl:value-of select="concat('http://facs.', $serverDomain, '/iiif/image/', $workId, '!', $volId, '!', $workId, '-', $volId, '-', $facsId, $iiifRenderParams)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="$gotoTarget"/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <!-- Function returns a full ID for a IIIF canvas element appropriate to the properties of a given TEI pb element -->
    <xsl:function name="sal:resolveCanvasID">
        <xsl:param name="facsTarget" as="xs:string"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="serverDomain" as="xs:string"/>
    <xsl:choose>
        <xsl:when test="matches($facsTarget, '^facs:W[0-9]{4}-[A-z]-[0-9]{4}$')">
            <xsl:value-of select="concat('https://facs.', $serverDomain, '/iiif/presentation/', sal:convertVolumeID(substring($facsTarget, 6, 7)), '/canvas/p', $index)"/>
        </xsl:when>
        <xsl:when test="matches($facsTarget, '^facs:W[0-9]{4}-[0-9]{4}$')">
            <xsl:value-of select="concat('https://facs.', $serverDomain, '/iiif/presentation/', substring($facsTarget, 6, 5), '/canvas/p', $index)"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:message>Error: unknown pb/@facs value</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
    </xsl:function>

    <!-- For a given work-id, get the (expanded) document node -->
    <xsl:function name="sal:getWork" as="document-node()">
        <xsl:param name="targetWorkId" as="xs:string"/>

        <xsl:variable name="filename" select="concat('../../../salamanca-data/tei/works/', $targetWorkId, '.xml')"/>   <!-- starting from app-root/resources/xsl ... -->
        <xsl:choose>
            <xsl:when test="doc-available($filename)">
                <xsl:variable name="targetWork-Unexpanded" select="doc($filename)"/>
                <xsl:variable name="targetWork">
                    <xsl:apply-templates select="$targetWork-Unexpanded" mode="xipr"/>
                </xsl:variable>
                <xsl:copy-of select="$targetWork"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:document>
                    <xsl:element name="sal:ERROR">
                        <xsl:attribute name="xml:id">NONE</xsl:attribute>
                        <xsl:attribute name="description" select="concat('Unable to open work with ID ', $targetWorkId, '.')"/>
                    </xsl:element>
                </xsl:document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- For a given node-id, get the id of the fragment containing it -->
    <xsl:function name="sal:getFragmentNodeId" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>

        <xsl:variable name="targetWork" select="sal:getWork($targetWorkId)"/>

        <xsl:choose>
            <xsl:when test="$targetWork/sal:ERROR">
                <xsl:value-of select="concat('ERROR: ', $targetWork/sal:ERROR/@description)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="filename" select="concat('../../../salamanca-data/tei/works/', $targetWorkId, '.xml')"/>             <!-- starting from app-root/resources/xsl ... -->
                <xsl:variable name="fragmentationDepth" select="count(doc($filename)/TEI/processing-instruction())"/>  <!-- Due to a bug in eXist's org.exist.dom.ProcessingInstructionImpl, our xipr.xsl has to delete processing instructions and we cannot read our PIs from the expanded work! -->
                <xsl:variable name="targetNode" select="$targetWork/id($targetNodeId)"/>

                <xsl:choose>
                    <xsl:when test="not($targetWork/id($targetNodeId))">
                        <xsl:value-of select="concat('ERROR: Unable to open Node &#34;', $targetNodeId, '&#34; in work ', $targetWorkId)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="targetNodeDepth" select="count($targetNode/ancestor-or-self::*)"/>

                        <xsl:choose>
                            <xsl:when test="$targetNodeDepth ge $fragmentationDepth"> <!--  if target anchor is at a level deeper than
                                                                                            or equal to the fragmentation level,
                                                                                            then search ancestor-or-self -->
                                <xsl:value-of select="xs:string($targetNode/ancestor-or-self::*[count(./ancestor-or-self::node())-1 eq $fragmentationDepth]/@xml:id)"/>
                            </xsl:when>
                            <xsl:otherwise>                                           <!--  otherwise, search descendants and
                                                                                            get the first one at the correct level -->
                                <xsl:value-of select="xs:string($targetNode/descendant::*[count(./ancestor-or-self::node())-1 eq $fragmentationDepth][1]/@xml:id)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!--For a given work-id and node-id, get the file containing the corresponding html fragment -->
    <xsl:function name="sal:getFragmentFile" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:value-of select="doc(xs:anyURI(concat('xmldb:exist:///db/apps/salamanca/data/', $targetWorkId, '_nodeIndex.xml')))//sal:node[@n = $targetNodeId]/sal:fragment/text()"/>
    </xsl:function>

    <!-- For a given work-id and node-id, get the node title -->
    <xsl:function name="sal:sectionTitle" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:value-of select="doc(xs:anyURI(concat('xmldb:exist:///db/apps/salamanca/data/', $targetWorkId, '_nodeIndex.xml')))//sal:node[@n = $targetNodeId]/sal:title/text()"/>
    </xsl:function>
    <xsl:function name="sal:sectionTitleOld" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:variable name="work" select="sal:getWork($targetWorkId)"/>
        <xsl:variable name="targetNode" select="$work//*[@xml:id = $targetNodeId]"/>
        <xsl:choose>
            <xsl:when test="$targetNode/self::div | $targetNode/self::milestone">
                <!-- See if we have something we can use to name the thing:
                 Either an @n attribute, a child heading or a summary at the beginning of the chapter/in the index etc. -->
                <xsl:choose>
                    <xsl:when test="$targetNode/@n and not(matches($targetNode/@n, '^[0-9]+$'))">
                        <xsl:value-of select="normalize-space(xs:string($targetNode/@n))"/>
                    </xsl:when>
<!--
                    <xsl:when test="$targetNode/head">
                        <xsl:value-of select="concat($targetNode/@type, ' ´', string-join($targetNode/tei:head[1], ' '), '´')"/>
                    </xsl:when>
-->
                    <xsl:when test="$targetNode/@n and (matches($targetNode/@n, '^[0-9]+$')) and ($targetNode/@type|$targetNode/@unit)">
                        <xsl:value-of select="concat(($targetNode/@type | $targetNode/@unit)[1], ' ', $targetNode/@n)"/>
                    </xsl:when>
                    <xsl:when test="$work/key('targeting-refs', concat('#',$targetNode/@xml:id))">
                        <xsl:value-of select="concat(($targetNode/@type | $targetNode/@unit)[1], ' ', $targetNode/@n, ': ', $work/key('targeting-refs', concat('#',$targetNode/@xml:id))[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$targetNode/@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$targetNode/self::text and $targetNode/@type='work_volume'">
                <xsl:value-of select="concat('Vol. ', $targetNode/@n)"/>
            </xsl:when>
            <xsl:when test="$targetNode/self::text and $targetNode/@xml:id='complete_work'">
                complete work
            </xsl:when>
            <xsl:when test="$targetNode/self::note">
                <xsl:value-of select="normalize-space(concat('Note ', $targetNode/@n))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Non-titleable node (', xs:string($targetNode/@xml:id), ')')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- <xsl:function name="sal:sectionTitleWithNode" as="xs:string">
        <xsl:param name="targetNode" as="node()"/>

        <xsl:variable name="target" select="$targetNode"/>
        <xsl:choose>
            <xsl:when test="$target/self::div">
                <xsl:choose>
                    <xsl:when test="$target/@n">
                        <xsl:choose>
                            <xsl:when test="$target/@n castable as xs:integer">
                                <xsl:value-of select="concat($target/@type, ' ', $target/@n)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="xs:string($target/@n)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$target/head">
                        <xsl:value-of select="concat($target/@type, ' "', $target/head[1], '"')"/>
                    </xsl:when>
                    <xsl:when test="$target/@type">
                        <xsl:value-of select="concat($target/@type, ' (no title), id ', $target/@xml:id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$target/@xml:id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$target/self::text">
                <xsl:value-of select="concat('Vol. ', $target/@n)"/>
            </xsl:when>
            <xsl:when test="$target/self::milestone">
                <xsl:value-of select="concat($target/@unit, ' ', $target/@n)"/>
            </xsl:when>
            <xsl:when test="$target/self::note">
                <xsl:value-of select="normalize-space(concat('Note ', $target/@n))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('Non-titleable node (', xs:string($target/@xml:id), ')')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
-->

    <!-- For a given work-id and node-id, make a permalink to it (server + workId + citetrail) -->
    <xsl:function name="sal:mkId" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:variable name="metadata" select="doc(xs:anyURI(concat('xmldb:exist:///db/apps/salamanca/data/', $targetWorkId, '_nodeIndex.xml')))"/> 
        <xsl:value-of select="concat($idserver, '/works.', $targetWorkId, ':', $metadata//sal:node[@n=$targetNodeId]/sal:citetrail)"/>
        <xsl:message><xsl:value-of select="concat('XSL rendering id: ', $idserver, '/works.', $targetWorkId, ':', $metadata//sal:node[@n=$targetNodeId]/sal:citetrail)"/></xsl:message>
    </xsl:function>

    <!-- For a given work-id and node-id, make a (fragmentation-sensitive) url to it in our webapp -->
    <xsl:function name="sal:mkUrl" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:value-of select="doc(xs:anyURI(concat('xmldb:exist:///db/apps/salamanca/data/', $targetWorkId, '_nodeIndex.xml')))//sal:node[@n = $targetNodeId]/sal:crumbtrail/a[last()]/@href"/>
    </xsl:function>
    <xsl:function name="sal:mkUrlOld" as="xs:string">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:variable name="frag" select="sal:getFragmentFile($targetWorkId, $targetNodeId)"/>
        <xsl:choose>
            <xsl:when test="substring($frag,1,5)='ERROR'">
                <xsl:value-of select="concat('#', $frag)"/><!-- So this creates an anchor pointing nowhere, preventing the user from clicking himself into 404... -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="substring($targetWorkId, 1, 2) = 'W0'">
                        <xsl:value-of select="concat(replace(replace(static-base-uri(), substring-after(static-base-uri(), '/salamanca/'), ''), '/db/', '/exist/'), 'work.html?wid=', $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeId)"/>
                    </xsl:when>
                    <xsl:when test="substring($targetWorkId, 1, 2) = 'L0'">
                        <xsl:value-of select="concat(replace(replace(static-base-uri(), substring-after(static-base-uri(), '/salamanca/'), ''), '/db/', '/exist/'), 'lemma.html?lid=', $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeId)"/>
                    </xsl:when>
                    <xsl:when test="substring($targetWorkId, 1, 2) = 'A0'">
                        <xsl:value-of select="concat(replace(replace(static-base-uri(), substring-after(static-base-uri(), '/salamanca/'), ''), '/db/', '/exist/'), 'author.html?aid=', $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeId)"/>
                    </xsl:when>
                    <xsl:when test="substring($targetWorkId, 1, 2) = 'WP'">
                        <xsl:value-of select="concat(replace(replace(static-base-uri(), substring-after(static-base-uri(), '/salamanca/'), ''), '/db/', '/exist/'), 'workingPaper.html?wpid=', $targetWorkId, (if ($frag) then concat('&amp;frag=', $frag) else ()), '#', $targetNodeId)"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- For a given work-id and node-id, make an html anchor linking to it in our webapp -->
    <xsl:function name="sal:mkAnchor" as="element()">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:copy-of select="doc(xs:anyURI(concat('xmldb:exist:///db/apps/salamanca/data/', $targetWorkId, '_nodeIndex.xml')))//sal:node[@n = $targetNodeId]/sal:crumbtrail/a[last()]"/>
    </xsl:function>
    <xsl:function name="sal:mkAnchorOld" as="element()">
        <xsl:param name="targetWorkId" as="xs:string"/>
        <xsl:param name="targetNodeId" as="xs:string"/>
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="sal:mkUrl($targetWorkId, $targetNodeId)"/>
            </xsl:attribute>
            <xsl:value-of select="sal:sectionTitle($targetWorkId, $targetNodeId)"/>
        </xsl:element>
    </xsl:function>

    <!-- For a volume ID of the form "W0013-A" or "W0096-B", return a matching ID of the form "W0013_Vol01" or "W0096_Vol02";
        currently covers volume numbers up to "10", or "J" -->
    <xsl:function name="sal:convertVolumeID" as="xs:string">
        <xsl:param name="volumeID" as="xs:string"/>
        <!-- a simple map does not work here for some reason, so we do this in the most straightforward way using if/else -->
        <xsl:variable name="volumeChar" select="substring($volumeID, 7, 1)"/>
        <xsl:choose> 
                <xsl:when test="$volumeChar = 'A'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol01')"/></xsl:when>
                <xsl:when test="$volumeChar = 'B'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol02')"/></xsl:when>
                <xsl:when test="$volumeChar = 'C'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol03')"/></xsl:when>
                <xsl:when test="$volumeChar = 'D'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol04')"/></xsl:when>
                <xsl:when test="$volumeChar = 'E'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol05')"/></xsl:when>
                <xsl:when test="$volumeChar = 'F'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol06')"/></xsl:when>
                <xsl:when test="$volumeChar = 'G'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol07')"/></xsl:when>
                <xsl:when test="$volumeChar = 'H'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol08')"/></xsl:when>
                <xsl:when test="$volumeChar = 'I'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol09')"/></xsl:when>
                <xsl:when test="$volumeChar = 'J'"><xsl:value-of select="concat(substring($volumeID, 1, 5), '_Vol10')"/></xsl:when>
                <xsl:otherwise><xsl:message>Error: volume number not supported</xsl:message></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>