<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xsl:output method="xml" indent="no" encoding="UTF-8"/>
<xsl:variable name="guidelines" select="document('_works-general.xml') "/>
<xsl:variable name="specialchars" select="document('_specialchars.xml') "/>
<xsl:variable name="work_id" select="tei:TEI/@xml:id"/>
<xsl:key name="title_image" match="//tei:graphic" use="@xml:id"/>
<xsl:key name="chars" match="//tei:char" use="@xml:id"/>
    <xsl:template match="/">    
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format" font-selection-strategy="character-by-character" font-family="Junicode, Antinoou, SBL Hebrew" xmlns:rx="http://www.renderx.com/XSL/Extensions">
            <fo:layout-master-set>
                <!-- "Schmutztitel" layout: no header, no page numbers-->
                <fo:simple-page-master master-name="start" page-height="29.7cm" page-width="21cm" margin-top="1.77cm" margin-bottom="1.77cm" margin-left="1.5cm" margin-right="1.5cm">
                    <fo:region-body margin-top="1.52cm" margin-bottom="1.27cm" margin-left="1.5cm" margin-right="1.5cm"/>
                    <fo:region-before region-name="start-region-before" extent="1.77cm"/>
                    <fo:region-after region-name="start-region-after" extent="0.5cm"/>                    
                    <fo:region-start extent="0cm"/>
                    <fo:region-end extent="0cm"/>
                </fo:simple-page-master>
                <!-- MS Titlepage picture layout -->
                <fo:simple-page-master master-name="pics" page-height="29.7cm" page-width="21cm" margin-top="1cm" margin-bottom="1cm" margin-left="1cm" margin-right="1cm">
                    <fo:region-body margin-top="0cm" margin-bottom="0cm" margin-left="0cm" margin-right="0cm"/>
                </fo:simple-page-master>
                <!-- Odd pages layout-->
                <fo:simple-page-master master-name="chapsOdd" page-height="29.7cm" page-width="21cm" margin-top="1.77cm" margin-bottom="1.77cm" margin-left="1.5cm" margin-right="1.5cm">
                    <fo:region-body margin-top="1.52cm" margin-bottom="1.27cm" margin-left="1.5cm" margin-right="1.5cm"/>
                    <fo:region-before region-name="chapsOdd-region-before" extent="1.77cm"/>
                    <fo:region-after region-name="chapsOdd-region-after" extent="0.5cm"/>
                    <fo:region-start extent="0cm"/>
                    <fo:region-end extent="0cm"/>
                </fo:simple-page-master>
                <!--  Even pages  layout-->

                <fo:simple-page-master master-name="chapsEven" page-height="29.7cm" page-width="21cm" margin-top="1.77cm" margin-bottom="1.77cm" margin-left="1.5cm" margin-right="1.5cm">
                    <fo:region-body margin-top="1.52cm" margin-bottom="1.27cm" margin-left="1.5cm" margin-right="1.5cm"/>
                    <fo:region-before region-name="chapsEven-region-before" extent="1.77cm"/>
                    <fo:region-after region-name="chapsEven-region-after" extent="0.5cm"/>
                    <fo:region-start extent="0cm"/>
                    <fo:region-end extent="0cm"/>
                </fo:simple-page-master>
                <!-- Sequencing odd and even pages  -->
                <fo:page-sequence-master master-name="chaps">
                    <fo:repeatable-page-master-alternatives>
                        <!--   <fo:conditional-page-master-reference master-reference="chapsOdd" page-position="any"/>-->
                        <fo:conditional-page-master-reference master-reference="chapsOdd" odd-or-even="odd"/>
                        <!--   <fo:conditional-page-master-reference master-reference="chapsEven" page-position="any"/>-->
                        <fo:conditional-page-master-reference master-reference="chapsEven" odd-or-even="even"/>
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>

            </fo:layout-master-set>

            <!-- Content for page I: "Schmutztitel" -->
            <fo:page-sequence master-reference="start">
                <fo:flow flow-name="xsl-region-body">
                    <fo:block text-align="center" font-size="25pt" font-style="normal" font-weight="bold" space-before="70mm" space-after="70mm">
                        <xsl:apply-templates select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                    <fo:block text-align="center" font-size="20pt">
                        <xsl:apply-templates select="//tei:titleStmt//tei:author"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>

            <!-- Content for page II: "MS-Titelblatt (Bild)" -->
            <fo:page-sequence master-reference="pics">
                <fo:flow flow-name="xsl-region-body">
                    <fo:block text-align="center">
                    <fo:external-graphic content-width="19cm" content-height="27.7cm">
                    <xsl:attribute name="src">
                    <xsl:value-of select="$guidelines/key('title_image', $work_id)/tei:image/text()" />
                    </xsl:attribute>
                    </fo:external-graphic>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>

            <!-- Content for page III: "(Haupt-)Titelblatt" -->
            <fo:page-sequence master-reference="start">
                <fo:flow flow-name="xsl-region-body">
                    <fo:block text-align="center" font-size="25pt" font-style="normal" font-weight="bold">
                        <xsl:apply-templates select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                    <xsl:apply-templates select="//tei:sourceDesc"/>
                </fo:flow>
            </fo:page-sequence>

            <!-- Content for page IV: "Editors" -->
            <fo:page-sequence master-reference="start">
                <fo:static-content flow-name="start-region-after">
                    <fo:block font-size="12pt" text-align="justify" font-style="normal">
                        <fo:inline>This pdf edition does not render the layout of the original print. 
                                    For detailed information about editorial interventions consult our Edition Guidelines: https://www.salamanca.school/en/guidelines.html. 
                                    Marginal notes of the original appear as consecutively numbered end notes. </fo:inline>  
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block font-size="14pt" space-after="10mm">Editors:</fo:block>
                    <xsl:apply-templates select="//tei:editor"/>
                    <fo:block font-size="14pt" space-before="10mm" space-after="10mm">Digitized original(s):</fo:block>
                    <xsl:apply-templates select="//tei:msIdentifier"/>  
                     <fo:block font-size="14pt" space-before="10mm" space-after="10mm">Proposed citation: </fo:block>
                    <fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="center">
                <fo:inline><xsl:value-of select="$guidelines/key('title_image', $work_id)/@source" /></fo:inline>                
                <fo:inline>, in: The School of Salamanca. A Digital Collection of Sources</fo:inline>
                </fo:block>
                <fo:block font-size="14pt" text-align="center"><xsl:apply-templates select="//tei:publicationStmt//tei:idno[@xml:id = 'urlid']"/></fo:block> 
                </fo:flow>
            </fo:page-sequence>

            <!--Content for page V: "MS-Titelblatt (Text: front/titlePage)"  -->
            <!--Taken from: "front/titlePage""  -->
            <fo:page-sequence master-reference="start">
                <fo:flow flow-name="xsl-region-body">
                    <fo:block text-align="center" font-size="30pt" font-weight="bold" space-before="10mm" space-after="10mm">
                        <xsl:apply-templates select="//tei:titlePart"/>
                    </fo:block>
                    <fo:block text-align="center" font-size="20pt" font-weight="normal" space-before="10mm" space-after="10mm">
                        <xsl:apply-templates select="//tei:titlePage//tei:byline"/>
                        <xsl:apply-templates select="//tei:titlePage//tei:argument"/>
                        <xsl:apply-templates select="//tei:titlePage//tei:docEdition"/>
                        <xsl:apply-templates select="//tei:titlePage//tei:docImprint"/>
                        <fo:inline padding-left="0.2cm">
                            <xsl:apply-templates select="//tei:titlePage//tei:imprimatur"/>
                        </fo:inline>
                        <fo:inline padding-left="0.2cm">
                            <xsl:apply-templates select="//tei:monogr/tei:imprint/tei:date"/>
                        </fo:inline>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>


            <!--Content for the introduction ("front/div")-->
            <!--Pagination starts with <front> in case it contains <div> -->
            <xsl:choose>
            <xsl:when test="//tei:text/tei:front/tei:div">
            <fo:page-sequence master-reference="chaps" initial-page-number="1">
                <!-- Defining static content for four regions:  "region-before" (header) on odd pages is filled with work author;
                                                                "region-before" (header) on even pages is filled with short work title;
                                                                "region-after" (footer) on odd pages is filled with page number placed on the right; 
                                                                "region-after" (footer) on even pages is filled with page number placed on the left -->
                <fo:static-content flow-name="chapsOdd-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:author"/> 
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsOdd-region-after">
                    <fo:block text-align="right">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-after">
                    <fo:block text-align="left">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <!-- Defining content flow for the body region of "front"-->
                <!-- Creating a table. Originally the table design was intended for marginal notes (
                    main text in the left column, marginal notes in the right column. Now as marginal notes are 
                    printed as end notes we have just one column for the main text. -->
                <fo:flow flow-name="xsl-region-body">
                    <fo:block>

                        <fo:table>
                            <fo:table-body>
 
                                <xsl:apply-templates select="//tei:front"/>

                            </fo:table-body>
                        </fo:table>
                    
                    </fo:block>

                </fo:flow>
            </fo:page-sequence>

            <!--Content for the main part ("body")-->
            <fo:page-sequence master-reference="chaps">
                <!-- Defining static content for four regions:  "region-before" (header) on odd pages is filled with work author;
                                                                "region-before" (header) on even pages is filled with short work title;
                                                                "region-after" (footer) on odd pages is filled with page number placed on the right; 
                                                                "region-after" (footer) on even pages is filled with page number placed on the left -->
                <fo:static-content flow-name="chapsOdd-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:author"/> 
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsOdd-region-after">
                    <fo:block text-align="right">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-after">
                    <fo:block text-align="left">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <!-- Defining content flow for the body region of the main part ("body")-->
                <!-- Creating a table. Originally the table design was intended for marginal notes (
                    main text in the left column, marginal notes in the right column. Now as marginal notes are 
                    printed as end notes we have just one column for the main text. -->
                <fo:flow flow-name="xsl-region-body">
                    <fo:block>
                    <!--    <fo:table border-style="solid" border-width="0.1mm">-->
                        <fo:table>
                            <fo:table-body>
                                <xsl:apply-templates select="//tei:body"/>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
            </xsl:when>
            <!--Pagination starts with <body> in case <front> does not contain <div> -->
            <xsl:otherwise>
            <fo:page-sequence master-reference="chaps" initial-page-number="1">
                <!-- Defining static content for four regions:  "region-before" (header) on odd pages is filled with work author;
                                                                "region-before" (header) on even pages is filled with short work title;
                                                                "region-after" (footer) on odd pages is filled with page number placed on the right; 
                                                                "region-after" (footer) on even pages is filled with page number placed on the left -->
                <fo:static-content flow-name="chapsOdd-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:author"/> 
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsOdd-region-after">
                    <fo:block text-align="right">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-after">
                    <fo:block text-align="left">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <!-- Defining content flow for the body region of the main part ("body")-->
                <!-- Creating a table. Originally the table design was intended for marginal notes (
                    main text in the left column, marginal notes in the right column. Now as marginal notes are 
                    printed as end notes we have just one column for the main text. -->
                <fo:flow flow-name="xsl-region-body">
                    <fo:block>
                    <!--    <fo:table border-style="solid" border-width="0.1mm">-->
                        <fo:table>
                            <fo:table-body>
                                <xsl:apply-templates select="//tei:body"/>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
            </xsl:otherwise>
            </xsl:choose>
            <!--Content for the conclusion ("back")-->
            <xsl:if test="//tei:text/tei:back">
            <fo:page-sequence master-reference="chaps">
                <!-- Defining static content for four regions:  "region-before" (header) on odd pages is filled with work author;
                                                                "region-before" (header) on even pages is filled with short work title;
                                                                "region-after" (footer) on odd pages is filled with page number placed on the right; 
                                                                "region-after" (footer) on even pages is filled with page number placed on the left -->
                <fo:static-content flow-name="chapsOdd-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:author"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsOdd-region-after">
                    <fo:block text-align="right">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-after">
                    <fo:block text-align="left">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <!-- Defining content flow for the body region of the last part ("back")-->
                <!-- Creating a table. Originally the table design was intended for marginal notes (
                    main text in the left column, marginal notes in the right column. Now as marginal notes are 
                    printed as end notes we have just one column for the main text. -->
                <fo:flow flow-name="xsl-region-body">
                    <fo:block>
                   <!--     <fo:table border-style="solid" border-width="0.1mm">-->
                        <fo:table>
                            <fo:table-body>
                                <xsl:apply-templates select="//tei:back"/>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
               </xsl:if>

            <!--Content for the End Notes-->
            <xsl:if test="//tei:text//tei:note">
            <fo:page-sequence master-reference="chaps">
                <fo:static-content flow-name="chapsOdd-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:author"/> 
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-before">
                    <fo:block text-align="center">
                        <xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsOdd-region-after">
                    <fo:block text-align="right">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>
                <fo:static-content flow-name="chapsEven-region-after">
                    <fo:block text-align="left">
                        <fo:page-number font-style="normal"/>
                    </fo:block>
                </fo:static-content>

                <fo:flow flow-name="xsl-region-body">
                    <fo:block>
                        <fo:table>

                            <fo:table-body>
            <fo:table-row>

                <fo:table-cell padding-top="5mm" padding-bottom="5mm">
                    <fo:block text-align="center" font-size="12pt" text-indent="0pt" font-weight="bold" keep-with-next="always">
                    <fo:inline>NOTAE</fo:inline>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
                <xsl:apply-templates select="//tei:text//tei:note" mode="make-endnotes"/>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
               </xsl:if>


        </fo:root>
    </xsl:template>


    <!--TEMPLATES MATCH FOR <TEI:SOURCE DESCRIPTION>   -->
    <!--msIdentifier refers to a separate template match   -->
    <xsl:template match="tei:sourceDesc">
        <xsl:variable name="guidelines" select="document('works-general.xml')"/>
        <fo:block text-align="center" font-size="20pt" font-style="normal" font-weight="normal" space-before="5mm">
            <xsl:apply-templates select="//tei:sourceDesc//tei:author"/>
        </fo:block>
        <fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal">
            <xsl:apply-templates select="//tei:sourceDesc//tei:pubPlace"/>
            <fo:inline padding-left="2mm">
            <xsl:apply-templates select="//tei:sourceDesc//tei:date"/></fo:inline>
                (            
            <xsl:apply-templates select="//tei:sourceDesc//tei:publisher"/>)</fo:block>               
        <fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal" space-before="15mm">The School of Salamanca</fo:block>
        <fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal">A Digital Collection of Sources and a Dictionary of its Juridical-Political Language</fo:block>
        <fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal">https://www.salamanca.school</fo:block>
        <fo:block text-align="center" font-size="16pt" space-before="15mm" >
         <fo:inline>Volume <xsl:apply-templates select="//tei:seriesStmt//tei:biblScope/@n"/></fo:inline>   
        </fo:block>
        <fo:block text-align="center" font-size="16pt" space-before="7mm">Directors:</fo:block>
        <fo:block text-align="center" font-size="16pt">
            <xsl:apply-templates select="$guidelines//tei:seriesStmt//tei:editor[@xml:id = 'TD']"/>
        </fo:block>
        <fo:block text-align="center" font-size="16pt">
            <xsl:apply-templates select="$guidelines//tei:seriesStmt//tei:editor[@xml:id = 'MLB']"/>
        </fo:block>
        <fo:block text-align="center" font-size="16pt" space-before="12mm">
            <xsl:apply-templates select="$guidelines//tei:publicationStmt//tei:distributor/tei:orgName"/>
        </fo:block>
        <fo:block text-align="center" font-size="16pt" space-before="12mm">Electronic publication, 
            
            
            <xsl:apply-templates select="//tei:publicationStmt/tei:date[@type = 'digitizedEd']"/></fo:block>
        <fo:block text-align="center" font-size="15pt">Online: 
            
            
            <xsl:apply-templates select="//tei:publicationStmt//tei:idno[@xml:id = 'urlid']"/></fo:block>
    </xsl:template>

    <xsl:template match="tei:orgName">

        <fo:block>
            <xsl:apply-templates/>
        </fo:block>
    
    </xsl:template>



    <xsl:template match="tei:titleStmt/tei:editor">
        <fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="center">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <!--tei:msIdentifier template, where each tei:repository and tei:idno are packed together    -->

    <xsl:template match="tei:sourceDesc//tei:msIdentifier">
        <fo:block space-before="3mm" space-after="3mm"  font-size="14pt" font-style="normal" font-weight="normal" text-align="center">
            <xsl:apply-templates select="./tei:repository"/>
            <xsl:apply-templates select="./tei:idno"/>
        </fo:block>
    </xsl:template>

 <xsl:template match="tei:repository">
        <fo:block ><xsl:apply-templates/></fo:block>
    </xsl:template>

 <xsl:template match="tei:idno">
        <fo:block ><xsl:apply-templates/></fo:block>
    </xsl:template>

    <!--TEMPLATES MATCH FOR DIFFERENT TYPES OF <TEI:P>   -->
    <!-- General template is "match="tei:p"", for <p>  inside of <argument> and <note> separate templates are defined -->
    <xsl:template match="tei:p">
        <fo:block id="{./@xml:id}" text-align="justify" font-size="12pt" text-indent="0em">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="//tei:argument//tei:p">
        <fo:inline padding-left="0.2cm" padding-right="0.2cm" font-size="16pt" font-weight="normal">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="//tei:note//tei:p">
        <fo:inline font-size="10pt" font-weight="normal" text-align="justify">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <!--TEMPLATES MATCH FOR <FRONT>, <BODY> and <BACK>   -->
    <!--Generating two rows for each <div>: 
                1. The first row contains <div n="1">, which is basically a chapter number 
                2. The  second row  refers to <xsl:template match="tei:div">
                Note that the cell dimensions are provided by the first row, and taken over by rows generated below it
-->
    <xsl:template match="//tei:front | //tei:body | //tei:back">
        <xsl:call-template name="process_div"/>
    </xsl:template>

    <xsl:template name="process_div">
        <xsl:for-each select="./tei:div">
        <xsl:variable name="div_id" select="@xml:id"/>
       <!--     <fo:table-row border-style="solid" border-width="0.1mm">-->
            <fo:table-row >
                <fo:table-cell padding-top="5mm" padding-bottom="5mm">
                    <fo:block text-align="center" font-size="12pt" text-indent="0pt" font-weight="bold" keep-with-next="always">
                        <fo:marker marker-class-name="chapNum">
                            <xsl:value-of select="./@n"/>
                        </fo:marker>
                        <xsl:value-of select="./@n"/>
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
            <fo:table-row>
                <fo:table-cell>
                    <xsl:apply-templates select="."/>
                </fo:table-cell>
            </fo:table-row>
        </xsl:for-each>
    
    </xsl:template>

    <!--Templates for "choice" and "g" Elements -->
    <!--"Choice" overwrites "g": abbreviations are expanded and special characters replaced, but not both -->
    <xsl:template match="tei:choice">
        <xsl:choose>
            <xsl:when test="(ancestor::tei:head) or (ancestor::tei:titlePart)">
                <xsl:choose>
                    <xsl:when test="(ancestor::tei:note)">
                        <xsl:apply-templates select="tei:expan | tei:reg | tei:corr" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="tei:expan | tei:reg | tei:corr" mode="bold"/>
                    </xsl:otherwise>                
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="tei:expan | tei:reg | tei:corr" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:g">
        <xsl:variable name="char_id" select="(substring(@ref,2))"/>
        <xsl:variable name="char_itself" select="./text()"/>
        <xsl:variable name="standardized" select="$specialchars/key('chars', $char_id)/tei:mapping[@type='standardized']/text()"/>
        <xsl:variable name="replace" select="replace(current()/text(),$char_itself,$standardized)"/>
        <xsl:choose>
            <xsl:when test="($char_id = 'char017f') or ($char_id = 'char204a') ">
                <xsl:choose>
                <xsl:when test="(ancestor::tei:head) or (ancestor::tei:titlePart)">
                <fo:inline font-weight="bold"><xsl:value-of select="$replace"/></fo:inline>
                </xsl:when>
                <xsl:otherwise>
                <fo:inline font-weight="normal"><xsl:value-of select="$replace"/></fo:inline>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:expan | tei:reg | tei:corr" mode="bold">
        <fo:inline font-weight="bold">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="tei:expan | tei:reg | tei:corr">
        <fo:inline font-weight="normal">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="tei:signed">
        <fo:block font-style="italic" text-align="right">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>    
    <xsl:template match="tei:quote">
        <fo:block font-style="italic" text-align="center">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template> 
    <xsl:template match="tei:lg">
        <fo:block font-style="italic" text-align="center">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template> 
    <xsl:template match="tei:pb[@n and not(@sameAs)]">
        <xsl:variable name="pb_id" select="@xml:id"/>
        <fo:inline font-style="normal" id="{$pb_id}">
            <xsl:choose>
                <xsl:when test="@rendition">-</xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </fo:inline>
        <fo:inline role="{@xml:id}" font-style="normal" font-weight="bold" font-size="10pt">
            <xsl:choose>
                <xsl:when test="@n">[<xsl:value-of select="@n"/>]</xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="tei:cb">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:lb"/>
    <xsl:template match="//tei:docDate">
        <fo:block>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="tei:figure">
        <fo:block font-style="italic" space-before="5mm">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="tei:hi[@rendition eq '#initCaps']">
        <fo:inline font-family="serif" font-size="18pt" space-before="0.1mm" space-after="0.1mm">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="tei:hi[@rendition='#r-center' and not(ancestor::tei:head)]">
        <fo:block text-align="center">
            <xsl:apply-templates/>
        </fo:block>
</xsl:template>
    <xsl:template match="tei:hi[@rendition eq '#sup']">
        <fo:inline baseline-shift="super" font-size="8pt" >
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    <xsl:template match="tei:hi[@rendition eq '#it' and not(parent::tei:ref)]">
        <fo:inline font-style="italic">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>


    <!-- Major div-elements, referenced from <xsl:for-each select="./tei:div"> and <xsl:apply-templates select="."/>-->
    <xsl:template match="tei:div">
    <xsl:variable name="div_id" select="@xml:id"/>
        <fo:block id="{./@xml:id}">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="tei:head">
        <fo:block text-align="justify" font-size="16pt" font-weight="bold" space-before="20pt" text-indent="0em" keep-with-next="always">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="tei:item">
        <fo:block id="{@xml:id}" text-align="justify" start-indent="16pt" space-before="0.2cm" space-after="0.2cm">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="tei:list">
        <fo:block id="{@xml:id}">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    <xsl:template match="tei:figure">
        <fo:block id="{@xml:id}">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>



    <!-- ############################################################'# REF #############################################################-->
    <!-- For now we deactivate the rendering of note-anchors: they are created as consecutive numbers by <tei:note template> (see below).
        This is to standartize the layout of note-achors with non-achored notes, which do not have <ref> element -->

    <xsl:template match="//tei:ref[@type='note-anchor']"/>
<!--  
        <xsl:variable name="ref_id" select="@target"/>
        <xsl:variable name="input" select="translate(@target, '#', '')"/>
        <fo:inline baseline-shift="super" font-size="9pt" font-weight="bold" id="{$ref_id}">
            <fo:basic-link internal-destination="{$input}" font-weight="bold" show-destination="replace">
               <xsl:value-of select="count(preceding::tei:note[@anchored = 'true' and  ancestor::tei:text])+1"/>               
            </fo:basic-link>
        </fo:inline>-->

    <!-- The <ref>s which are parts of lists (table of contents etc.) are rendered  -->

    <xsl:template match="//tei:list//tei:ref[@target]">
        <xsl:variable name="input" select="translate(@target, '#', '')"/>
        <fo:inline space-before="0.2cm" space-after="0.2cm">
            <fo:basic-link internal-destination="{$input}" color="#0a0c75">
                <xsl:apply-templates/>
            </fo:basic-link>
        </fo:inline>
    </xsl:template>



    <!-- other elements -->
    <xsl:template match="tei:persName">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:unclear">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:placeName">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="//tei:text//tei:date">
        <xsl:apply-templates/>
    </xsl:template>
   <xsl:template match="tei:milestone">
        <fo:inline id="{@xml:id}" font-style="normal" font-weight="bold" font-size="10pt">
            [sect. <xsl:value-of select="@n"/>]
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <!--   Creating note-anchores in text body, irrespective of the fact whether anchors exist (<ref> element) or not -->
    <xsl:template match="//tei:note">
        <xsl:variable name="id_anchor" select="concat('#', @xml:id)"/>
        <xsl:variable name="link_note" select="@xml:id"/>
        <xsl:variable name="number" select="@n"/>
        <fo:inline baseline-shift="super" font-size="9pt" font-weight="bold" id="{$id_anchor}"><fo:basic-link color="#0a0c75" internal-destination="{$link_note}"><xsl:value-of select="count(preceding::tei:note[ancestor::tei:text])+1"/></fo:basic-link></fo:inline>
    </xsl:template>

    <xsl:template match="tei:lb[not(@break eq 'no')]">
        <fo:inline>
            <xsl:text xml:space="preserve"> </xsl:text>
        </fo:inline>
    </xsl:template>

    <xsl:template match="//tei:text//tei:note" mode="make-endnotes">
            <fo:table-row>
         <!--   <fo:table-row border-style="solid" border-width="0.1mm">-->
                <fo:table-cell padding-top="1mm" padding-bottom="1mm">
                    <fo:block> 
                        <xsl:for-each select=".">
<!--  Note: this part was intended for special treatment of notes with @anchored = 'true' attribute value. Now no difference is made between  
       anchored and non-anchored notes  -->
         <!--   <fo:table-row border-style="solid" border-width="0.1mm">

                            <xsl:choose>
                                <xsl:when test="@anchored = 'true'">
                                    <xsl:variable name="id_notes" select="@xml:id"/>
                                    <xsl:variable name="n" select="replace(@n, '(\s)(.*)', ' ')"/>
                                    <xsl:variable name="links" select="preceding::tei:ref[1]/@target"/>
                                    <fo:block id="{$id_notes}" space-before="5mm" space-after="5mm" font-size="10pt" text-align="justify">
                                        <fo:basic-link font-weight="bold" color="#0a0c75" internal-destination="{$links}">
                                        <xsl:value-of select="count(preceding::tei:note[@anchored = 'true' and  ancestor::tei:text])+1"/>
                                        <xsl:value-of select="concat(' ', $n)"/>
                                        </fo:basic-link>
                                           <xsl:apply-templates/>
                                    </fo:block>
                                </xsl:when>
                                <xsl:otherwise>
                                </xsl:otherwise>
                            </xsl:choose>
   -->
                                    <xsl:variable name="id_notes" select="@xml:id"/>
                                    <xsl:variable name="link_anchor" select="concat('#', @xml:id)"/>
                                     <xsl:variable name="number" select="@n"/>
                                    <fo:block id="{$id_notes}" space-before="5mm" space-after="5mm" font-size="10pt" text-align="justify">
                                        <fo:basic-link font-weight="bold" color="#0a0c75" internal-destination="{$link_anchor}">
                                            <xsl:value-of select="count(preceding::tei:note[ancestor::tei:text])+1"/>                                      
                                        </fo:basic-link>
                                           <fo:inline><xsl:text xml:space="preserve"> </xsl:text></fo:inline>
                                           <xsl:apply-templates/>
                                    </fo:block>
                        </xsl:for-each>
                    </fo:block>

                </fo:table-cell>
            </fo:table-row>


    </xsl:template>

    <!-- NOT USED -->
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:fileDesc"/>
    <xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:note"/>
    <xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:extent"/>
    <xsl:template match="tei:titleStmt/tei:title[@type = 'main']"/>
    <xsl:template match="tei:sourceDesc//tei:title[@type = 'main']"/>
    <xsl:template match="tei:sourceDesc//tei:title[@type = '245a']"/>
    <xsl:template match="tei:sourceDesc//tei:title[@type = 'short']"/>
    <xsl:template match="tei:notesStmt"/>
    <xsl:template match="tei:revisionDesc"/>
    <xsl:template match="tei:titleStmt"/>



    <!--To identify missing templates
    <xsl:template match="*">  
        <fo:block color="red">
            ******************** ELEMENT
            <xsl:value-of select="name(..)"/>/
            <xsl:value-of select="name()"/> found, with no template.********************
        </fo:block>
    </xsl:template>-->
</xsl:stylesheet>
