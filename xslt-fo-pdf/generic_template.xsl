<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:rx="http://www.renderx.com/XSL/Extensions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:img="img:img">
	<xsl:output method="xml" indent="no" encoding="UTF-8"/>
	<xsl:variable name="images" select="document('')/*/img:images"/>			
	<xsl:variable name="guidelines" select="document('http://files.salamanca.school/works-general.xml') "/>
	<xsl:variable name="specialchars" select="document('http://files.salamanca.school/specialchars.xml') "/>
	<xsl:variable name="work_id" select="tei:TEI/@xml:id"/>
	<xsl:key name="title_image" match="//image" use="@xml:id"/>
	<xsl:key name="chars" match="//tei:char" use="@xml:id"/>
	<xsl:template match="/">
		<fo:root
			xmlns:fo="http://www.w3.org/1999/XSL/Format" font-selection-strategy="character-by-character" font-family="Junicode, Antinoou, SBL Hebrew"
			xmlns:rx="http://www.renderx.com/XSL/Extensions">
			<fo:layout-master-set>
				<!-- "Front matter" layout: no header, no page numbers-->
				<fo:simple-page-master master-name="front_matter" page-height="29.7cm" page-width="21cm" margin-top="1.8cm" margin-bottom="1.8cm" margin-left="1.5cm" margin-right="1.5cm">
					<fo:region-body margin-top="1.5cm" margin-bottom="1.3cm" margin-left="1.5cm" margin-right="1.5cm"/>
					<fo:region-before region-name="front_matter-region-before" extent="1.8cm"/>
					<fo:region-after region-name="front_matter-region-after" extent="0.5cm"/>
					<fo:region-start extent="0cm"/>
					<fo:region-end extent="0cm"/>
				</fo:simple-page-master>
				<!-- "Frontispiece" layout -->
				<fo:simple-page-master master-name="frontispiece" page-height="29.7cm" page-width="21cm" margin-top="1cm" margin-bottom="1cm" margin-left="1cm" margin-right="1cm">
					<fo:region-body margin-top="0cm" margin-bottom="0cm" margin-left="0cm" margin-right="0cm"/>
				</fo:simple-page-master>
				<!-- Odd pages layout-->
				<fo:simple-page-master master-name="body_matter_odd" page-height="29.7cm" page-width="21cm" margin-top="1.8cm" margin-bottom="1.8cm" margin-left="1.5cm" margin-right="1.5cm">
					<fo:region-body margin-top="1.5cm" margin-bottom="1.3cm" margin-left="1.5cm" margin-right="1.5cm"/>
					<fo:region-before region-name="body_matter_odd-region-before" extent="1.8cm"/>
					<fo:region-after region-name="body_matter_odd-region-after" extent="0.5cm"/>
					<fo:region-start extent="0cm"/>
					<fo:region-end extent="0cm"/>
				</fo:simple-page-master>
				<!--  Even pages  layout-->
				<fo:simple-page-master master-name="body_matter_even" page-height="29.7cm" page-width="21cm" margin-top="1.8cm" margin-bottom="1.8cm" margin-left="1.5cm" margin-right="1.5cm">
					<fo:region-body margin-top="1.5cm" margin-bottom="1.3cm" margin-left="1.5cm" margin-right="1.5cm"/>
					<fo:region-before region-name="body_matter_even-region-before" extent="1.8cm"/>
					<fo:region-after region-name="body_matter_even-region-after" extent="0.5cm"/>
					<fo:region-start extent="0cm"/>
					<fo:region-end extent="0cm"/>
				</fo:simple-page-master>
				<!-- Sequencing odd and even pages  -->
				<fo:page-sequence-master master-name="body_matter">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference master-reference="body_matter_odd" odd-or-even="odd"/>
						<fo:conditional-page-master-reference master-reference="body_matter_even" odd-or-even="even"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
			</fo:layout-master-set>
			<!-- Content for book component 1: "Half title" -->
			<fo:page-sequence master-reference="front_matter">
				<fo:flow flow-name="xsl-region-body">
					<fo:block text-align="center" font-size="25pt" font-style="normal" font-weight="bold" space-before="70mm" space-after="70mm">
						<xsl:apply-templates select="//tei:titleStmt//tei:title[@type = 'short']"/>
					</fo:block>
					<fo:block text-align="center" font-size="20pt">
						<xsl:apply-templates select="//tei:titleStmt//tei:author"/>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>
			<!-- Content for book component 2: "Frontispiece" -->
			<fo:page-sequence master-reference="frontispiece">
				<fo:flow flow-name="xsl-region-body">
					<fo:block text-align="center">
						<fo:external-graphic content-width="19cm" content-height="27.7cm">
							<xsl:attribute name="src">
								<xsl:value-of select="$images/key('title_image', $work_id)/source/text()" />
							</xsl:attribute>
						</fo:external-graphic>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>
			<!-- Content for book component 3: "Title page (digital edition)" -->
			<fo:page-sequence master-reference="front_matter">
				<fo:flow flow-name="xsl-region-body">
					<fo:block text-align="center" font-size="25pt" font-style="normal" font-weight="bold">
						<xsl:apply-templates select="//tei:titleStmt//tei:title[@type = 'short']"/>
					</fo:block>
					<xsl:apply-templates select="//tei:sourceDesc"/>
				</fo:flow>
			</fo:page-sequence>
			<!-- Content for book component 4: "Edition notice" -->
			<fo:page-sequence master-reference="front_matter">
				<fo:static-content flow-name="front_matter-region-after">
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
						<fo:inline>
							<xsl:value-of select="$images/key('title_image', $work_id)/@citation" />
						</fo:inline>
						<fo:inline>, in: The School of Salamanca. A Digital Collection of Sources</fo:inline>
					</fo:block>
					<fo:block font-size="14pt" text-align="center">
						<xsl:apply-templates select="//tei:publicationStmt//tei:idno[@xml:id = 'urlid']"/>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>

			<!--Content for book component 5: "Title page (Original)"  -->
			<!--Taken from: "text/front/titlePage"  -->
			<xsl:apply-templates select="//tei:titlePage"/>			
			
			<!--Content for book component 6 "Introduction"-->
			<!--Taken from: "text/front/div"  -->
			<!--Pagination starts with <front> in case it contains <div> -->
			<xsl:choose>
				<xsl:when test="//tei:text/tei:front/tei:div">
					<fo:page-sequence master-reference="body_matter" initial-page-number="1">
						<!-- Defining static content for four regions:  "region-before" (header) on odd pages is filled with work author;
                                                                "region-before" (header) on even pages is filled with short work title;
                                                                "region-after" (footer) on odd pages is filled with page number placed on the right; 
                                                                "region-after" (footer) on even pages is filled with page number placed on the left -->
						<fo:static-content flow-name="body_matter_odd-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="//tei:titleStmt//tei:author"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_even-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_odd-region-after">
							<fo:block text-align="right">
								<fo:page-number font-style="normal"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_even-region-after">
							<fo:block text-align="left">
								<fo:page-number font-style="normal"/>
							</fo:block>
						</fo:static-content>
						<!-- Defining content flow for the body region of "front"-->
						<!-- Creating a table. Originally table design was intended marginal notes (
                    main text in the left column, marginal notes in the right column). Now, as marginal notes are 
                    printed as end notes, we have just one column for the main text. This is useful to control the margins -->
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
					<!--Content for book component 7 "Body matter"-->
					<!--Taken from: "text/body"  -->
					<fo:page-sequence master-reference="body_matter">
						<fo:static-content flow-name="body_matter_odd-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="//tei:titleStmt//tei:author"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_even-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_odd-region-after">
							<fo:block text-align="right">
								<fo:page-number font-style="normal"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_even-region-after">
							<fo:block text-align="left">
								<fo:page-number font-style="normal"/>
							</fo:block>
						</fo:static-content>
						<!-- Defining content flow for the body region of the main part ("body")-->
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
					<fo:page-sequence master-reference="body_matter" initial-page-number="1">
						<fo:static-content flow-name="body_matter_odd-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="//tei:titleStmt//tei:author"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_even-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_odd-region-after">
							<fo:block text-align="right">
								<fo:page-number font-style="normal"/>
							</fo:block>
						</fo:static-content>
						<fo:static-content flow-name="body_matter_even-region-after">
							<fo:block text-align="left">
								<fo:page-number font-style="normal"/>
							</fo:block>
						</fo:static-content>
						<!-- Defining content flow for the body region of the main part ("body")-->
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
			<!--Content for book component 8 "Back matter" -->
			<!--Taken from: "text/back"  -->
			<xsl:if test="//tei:text/tei:back">
				<fo:page-sequence master-reference="body_matter">
					<fo:static-content flow-name="body_matter_odd-region-before">
						<fo:block text-align="center">
							<xsl:value-of select="//tei:titleStmt//tei:author"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_even-region-before">
						<fo:block text-align="center">
							<xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_odd-region-after">
						<fo:block text-align="right">
							<fo:page-number font-style="normal"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_even-region-after">
						<fo:block text-align="left">
							<fo:page-number font-style="normal"/>
						</fo:block>
					</fo:static-content>
					<!-- Defining content flow for the body region of the last part ("back")-->
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
			<!--Content for book component 9 "End Notes"-->
			<xsl:if test="//tei:text//tei:note">
				<fo:page-sequence master-reference="body_matter">
					<fo:static-content flow-name="body_matter_odd-region-before">
						<fo:block text-align="center">
							<xsl:value-of select="//tei:titleStmt//tei:author"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_even-region-before">
						<fo:block text-align="center">
							<xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_odd-region-after">
						<fo:block text-align="right">
							<fo:page-number font-style="normal"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_even-region-after">
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
									<xsl:apply-templates select="//tei:text" mode="make-endnotes"/>
								</fo:table-body>
							</fo:table>
						</fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
		</fo:root>
	</xsl:template>
	<!--TEMPLATES MATCH  -->
	<xsl:template match="tei:sourceDesc">
		<fo:block text-align="center" font-size="20pt" font-style="normal" font-weight="normal" space-before="5mm">
			<xsl:apply-templates select="//tei:sourceDesc//tei:author"/>
		</fo:block>
		<fo:block text-align="center" font-size="20pt" font-style="normal" font-weight="normal">
			<xsl:apply-templates select="//tei:sourceDesc//tei:pubPlace"/>
			<fo:inline padding-left="2mm">
				<xsl:apply-templates select="//tei:sourceDesc//tei:date"/>
			</fo:inline>
		</fo:block>
		<fo:block text-align="center" font-size="20pt" font-style="normal" font-weight="normal">
                (
			<xsl:apply-templates select="//tei:sourceDesc//tei:publisher"/>)
		</fo:block>
		<fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal" space-before="15mm">The School of Salamanca</fo:block>
		<fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal">A Digital Collection of Sources and a Dictionary of its Juridical-Political Language</fo:block>
		<fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal">https://www.salamanca.school</fo:block>
		<fo:block text-align="center" font-size="16pt" space-before="15mm" >
			<fo:inline>Volume 
				<xsl:apply-templates select="//tei:seriesStmt//tei:biblScope/@n"/>
			</fo:inline>
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
			<xsl:apply-templates select="//tei:publicationStmt/tei:date[@type = 'digitizedEd']"/>
		</fo:block>
		<fo:block text-align="center" font-size="15pt">Online: 
			<xsl:apply-templates select="//tei:publicationStmt//tei:idno[@xml:id = 'urlid']"/>
		</fo:block>
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
		<fo:block >
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="tei:idno">
		<fo:block >
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>	
	
	<!--TEMPLATES MATCH FOR DIFFERENT TYPES OF <TEI:P>   -->
	<!-- General template is "match="tei:p"", for <p>  inside of <argument> and <note> separate templates are defined -->
	<xsl:template match="tei:p">
		<fo:block id="{./@xml:id}" text-align="justify" font-size="12pt" text-indent="0em">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="//tei:argument//tei:p">
		<fo:inline padding-left="0.2cm" padding-right="0.2cm" font-size="20pt" font-weight="normal">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="//tei:note//tei:p">
		<fo:inline font-size="12pt" font-weight="normal" text-align="justify">
			<xsl:text xml:space="preserve"></xsl:text>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<!--TEMPLATES MATCH FOR <FRONT>, <BODY> and <BACK>   -->
	<!--Generating two rows for each <div>: 
                1. The first row contains <div n="1">, which is chapter number 
                2. The  second row  refers to <xsl:template match="tei:div">
                Note that the cell dimensions are provided by the first row, and taken over by rows generated below it
-->
	<xsl:template match="tei:front | tei:body | tei:back">
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
	<!--Within "choice" elements "abbr", "orig" and "sic" are ignored, "expan", "reg", "corr" interpreted -->
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
						<fo:inline font-weight="bold">
							<xsl:value-of select="$replace"/>
						</fo:inline>
					</xsl:when>
					<xsl:otherwise>
						<fo:inline font-weight="normal">
							<xsl:value-of select="$replace"/>
						</fo:inline>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
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
		<fo:inline role="{@xml:id}" font-style="normal" font-weight="bold" font-size="12pt">
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
	<!-- The following exception (not parent) is not clear	
	<xsl:template match="tei:hi[@rendition eq '#it' and not(parent::tei:ref)]">-->
		<xsl:template match="tei:hi[@rendition eq '#it']">
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
        This is to standartize the layout of note-achors with non-achored notes, which do not have <ref> element.
	    <xsl:variable name="ref_id" select="@target"/>
	    <xsl:variable name="input" select="translate(@target, '#', '')"/>
	    <fo:inline baseline-shift="super" font-size="9pt" font-weight="bold" id="{$ref_id}">
	    <fo:basic-link internal-destination="{$input}" font-weight="bold" show-destination="replace">
	    <xsl:value-of select="count(preceding::tei:note[@anchored = 'true' and  ancestor::tei:text])+1"/>
	    </fo:basic-link></fo:inline>-->
	<xsl:template match="//tei:ref[@type='note-anchor']"/>

	<!-- The <ref>s which are parts of lists (table of contents etc.) are rendered  -->
	<xsl:template match="//tei:list//tei:ref[@target]">
		<xsl:variable name="input" select="translate(@target, '#', '')"/>
		<fo:inline space-before="0.2cm" space-after="0.2cm">
			<fo:basic-link internal-destination="{$input}" color="#0a0c75">
				<xsl:apply-templates/>
			</fo:basic-link>
			<xsl:text> </xsl:text>			
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
            [sect. 
			<xsl:value-of select="@n"/>]            
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<!--   Creating note-anchores in text body, irrespective of the fact whether anchors exist (<ref> element) or not -->
	<xsl:template match="//tei:note">
		<xsl:variable name="id_anchor" select="concat('#', @xml:id)"/>
		<xsl:variable name="link_note" select="@xml:id"/>
		<xsl:variable name="number" select="@n"/>
		<fo:inline baseline-shift="super" font-size="9pt" font-weight="bold" id="{$id_anchor}">
			<fo:basic-link color="#0a0c75" internal-destination="{$link_note}">
				<xsl:value-of select="count(preceding::tei:note[ancestor::tei:text])+1"/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template>
	<xsl:template match="tei:lb[not(@break eq 'no')]">
		<fo:inline>
			<xsl:text xml:space="preserve"> </xsl:text>
		</fo:inline>
	</xsl:template>
	<xsl:template match="//tei:text" mode="make-endnotes">
		<xsl:for-each select="./tei:front | ./tei:body | ./tei:back">
					<xsl:for-each select="./tei:div">	
						<xsl:if test=".//tei:note">
							<fo:table-row >
								<fo:table-cell padding-top="5mm" padding-bottom="5mm">
									<fo:block text-align="center" font-size="12pt" text-indent="0pt" font-weight="bold" keep-with-next="always">
										<xsl:value-of select="./@n"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row >
								<fo:table-cell>							
					<xsl:for-each select=".//tei:note">
						<!--Note: the following part was intended for special treatment of notes with @anchored = 'true' attribute value. 
							Now no difference is made between  anchored and non-anchored notes  - the anchors are inserved anyway
						  	<fo:table-row border-style="solid" border-width="0.1mm">
								<xsl:choose><xsl:when test="@anchored = 'true'">
								<xsl:variable name="id_notes" select="@xml:id"/>
								<xsl:variable name="n" select="replace(@n, '(\s)(.*)', ' ')"/>
								<xsl:variable name="links" select="preceding::tei:ref[1]/@target"/>
								<fo:block id="{$id_notes}" space-before="5mm" space-after="5mm" font-size="10pt" text-align="justify">
								<fo:basic-link font-weight="bold" color="#0a0c75" internal-destination="{$links}">
								<xsl:value-of select="count(preceding::tei:note[@anchored = 'true' and  ancestor::tei:text])+1"/>
								<xsl:value-of select="concat(' ', $n)"/>
								</fo:basic-link><xsl:apply-templates/></fo:block>
								</xsl:when><xsl:otherwise></xsl:otherwise></xsl:choose>  -->
						<xsl:variable name="id_notes" select="@xml:id"/>
						<xsl:variable name="link_anchor" select="concat('#', @xml:id)"/>
						<xsl:variable name="number" select="@n"/>
						<fo:block id="{$id_notes}" space-before="2mm" space-after="2mm"  text-align="justify">
							<fo:basic-link font-weight="bold" font-size="12pt" color="#0a0c75" internal-destination="{$link_anchor}">
								<xsl:value-of select="count(preceding::tei:note[ancestor::tei:text])+1"/>
								<xsl:text> </xsl:text>								
							</fo:basic-link>
							<xsl:apply-templates/>
						</fo:block>
					</xsl:for-each>				
								</fo:table-cell>
							</fo:table-row>
		</xsl:if>
		</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	<!--   Creating tables -->
	<xsl:template match="tei:table">
		<fo:table id="{./@xml:id}">
			<fo:table-body>
				<xsl:for-each select="./tei:row">
					<fo:table-row >
						<xsl:for-each select="./tei:cell">
							<fo:table-cell padding-top="1mm" padding-bottom="1mm">
								<fo:block text-align="center" font-size="12pt" text-indent="0pt">
									<xsl:apply-templates/>
								</fo:block>
							</fo:table-cell>
						</xsl:for-each>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	<xsl:template match="//tei:titlePage">
				<fo:page-sequence master-reference="front_matter">
					<fo:flow flow-name="xsl-region-body">		
					<fo:block text-align="center" font-size="30pt" font-weight="bold" space-before="10mm">
			<xsl:apply-templates/>
		</fo:block>			
					</fo:flow>
				</fo:page-sequence>
	</xsl:template>
	<xsl:template match="tei:titlePart">
						<fo:block text-align="center" font-size="30pt" font-weight="bold" space-before="10mm">
							<xsl:apply-templates/>
						</fo:block>
	</xsl:template>
	<xsl:template match="tei:byline">
							<fo:block text-align="center" font-size="20pt" font-weight="normal" space-before="5mm">
							<xsl:apply-templates/>
							<xsl:apply-templates select=".//tei:argument"/>
						</fo:block>
	</xsl:template>		
	<xsl:template match="tei:argument">
		<fo:block text-align="center" font-size="20pt" font-weight="normal" space-before="5mm">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>	
	<xsl:template match="tei:docEdition">
						<fo:block text-align="center" font-size="20pt" font-weight="normal" space-before="5mm">						
							<xsl:apply-templates/>
						</fo:block>
	</xsl:template>
	<xsl:template match="tei:docImprint">		
							<fo:block text-align="center" font-size="20pt" font-weight="normal" space-before="5mm">													
						<xsl:apply-templates/>
						</fo:block>
	</xsl:template>
	<xsl:template match="tei:imprimatur">	
							<fo:block text-align="center" font-size="20pt" font-weight="normal" space-before="5mm">																				
							<fo:inline padding-left="0.2cm">
								<xsl:apply-templates/>
							</fo:inline>
						</fo:block>	
	</xsl:template>
	<xsl:template match="tei:docDate">			
							<fo:inline padding-left="0.2cm">
								<xsl:apply-templates/>
							</fo:inline>
	</xsl:template>
	

	<!--    NOT USED -->
	<xsl:template match="tei:teiHeader"/>
	<xsl:template match="tei:fileDesc"/>
	<xsl:template match="tei:figure"/>	
	<xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:note"/>
	<xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:extent"/>
	<xsl:template match="tei:titleStmt/tei:title[@type = 'main']"/>
	<xsl:template match="tei:sourceDesc//tei:title[@type = 'main']"/>
	<xsl:template match="tei:sourceDesc//tei:title[@type = '245a']"/>
	<xsl:template match="tei:sourceDesc//tei:title[@type = 'short']"/>
	<xsl:template match="tei:notesStmt"/>
	<xsl:template match="tei:revisionDesc"/>
	<xsl:template match="tei:titleStmt"/>
	
	
	<img:images>
		<images>
		<image xml:id='W0001_Vol01' citation="Avendaño, Thesaurus Indicus, Vol. 1 (2019 [1668])"><source>https://facs.salamanca.school/W0001/A/W0001-A-0006.jpg</source></image>
		<image xml:id='W0001_Vol02' citation="Avendaño, Thesaurus Indicus, Vol. 2 (2019 [1668])"><source>https://facs.salamanca.school/W0001/B/W0001-B-0004.jpg</source></image>
		<image xml:id='W0001_Vol03' citation="Avendaño, Thesaurus Indicus, Vol. 3 (2020 [1675])"><source>https://facs.salamanca.school/W0001/C/W0001-C-0004.jpg</source></image>
		<image xml:id='W0001_Vol04' citation="Avendaño, Thesaurus Indicus, Vol. 4 (2020 [1675])"><source>https://facs.salamanca.school/W0001/D/W0001-D-0004.jpg</source></image>
		<image xml:id='W0001_Vol05' citation="Avendaño, Thesaurus Indicus, Vol. 5 (2020 [1675])"><source>https://facs.salamanca.school/W0001/E/W0001-E-0004.jpg</source></image>
		<image xml:id='W0001_Vol06' citation="Avendaño, Thesaurus Indicus, Vol. 6 (2021 [1686])"><source>https://facs.salamanca.school/W0001/F/W0001-F-0004.jpg</source></image>
		<image xml:id='W0002' citation="Azpilcueta, Manual de Confessores y Penitentes (2019 [1556])"><source>https://facs.salamanca.school/W0002/W0002-0004.jpg</source></image>
		<image xml:id='W0003' citation="Báñez, De Iure et Iustitia Decisiones (2019 [1594])"><source>https://facs.salamanca.school/W0003/W0003-0004.jpg</source></image>  
		<image xml:id='W0004' citation="Castillo, Tratado de Cuentas (2018 [1522])"><source>https://facs.salamanca.school/W0004/W0004-0005.jpg</source></image>
		<image xml:id='W0006_Vol01' citation="Covarrubias y Leyva, Opera Omnia, Vol. 1 (2021 [1573])"><source>https://facs.salamanca.school/W0006/A/W0006-A-0004.jpg</source></image>
		<image xml:id='W0006_Vol02' citation="Covarrubias y Leyva, Opera Omnia, Vol. 2 (2021 [1573])"><source>https://facs.salamanca.school/W0006/B/W0006-B-0001.jpg</source></image>
		<image xml:id='W0006_Vol03' citation="Covarrubias y Leyva, Opera Omnia, Vol. 3 (2021 [1571])"><source>https://facs.salamanca.school/W0006/C/W0006-C-0001.jpg</source></image>        
		<image xml:id='W0007' citation="Mercado, Tratos y Contratos (2019 [1569])"><source>https://facs.salamanca.school/W0007/W0007-0007.jpg</source></image>
		<image xml:id='W0010' citation="Solórzano Pereira, Politica Indiana (2019 [1648])"><source>https://facs.salamanca.school/W0010/W0010-0001.jpg</source></image>
		<image xml:id='W0011' citation="Soto, De Iustitia et Iure (2020 [1553])"><source>https://facs.salamanca.school/W0011/W0011-0001.jpg</source></image>
		<image xml:id='W0013_Vol01' citation="Vitoria, Relectiones Theologicae XII, Vol. 1 (2018 [1557])"><source>https://facs.salamanca.school/W0013/A/W0013-A-0004.jpg</source></image>
		<image xml:id='W0013_Vol02' citation="Vitoria, Relectiones Theologicae XII, Vol. 2 (2018 [1557])"><source>https://facs.salamanca.school/W0013/B/W0013-B-0492.jpg</source></image>
		<image xml:id='W0014' citation="Vitoria, Summa Sacramentorum (2018 [1561])"><source>https://facs.salamanca.school/W0014/W0014-0006.jpg</source></image>
		<image xml:id='W0015' citation="Vitoria, Confessionario (2018 [1562])"><source>https://facs.salamanca.school/W0015/W0015-0000.jpg</source></image>
		<image xml:id='W0017' citation="Albornoz, Arte de los contractos (2020 [1573])"><source>https://facs.salamanca.school/W0017/W0017-0005.jpg</source></image>
		<image xml:id='W0018' citation="Alcalá, Tractado de los préstamos (2021 [1543])"><source>https://facs.salamanca.school/W0018/W0018-0001.jpg</source></image>
		<image xml:id='W0030' citation="Cano, Relectio de Poenitentia (2019 [1558])"><source>https://facs.salamanca.school/W0030/W0030-0001.jpg</source></image>
		<image xml:id='W0033' citation="Carrasco del Saz, Tractatus de casibus curiae. (2020 [1630])"><source>https://facs.salamanca.school/W0033/W0033-0007.jpg</source></image>
		<image xml:id='W0034' citation="Las Casas, Treinta Proposiciones (2018 [1552])"><source>https://facs.salamanca.school/W0034/W0034-0001.jpg</source></image>
		<image xml:id='W0037_Vol01' citation="Castillo Sotomayor, Opera Omnia, Vol. 1 (2022 [1658])"><source>https://facs.salamanca.school/W0037/A/W0037-A-0000.jpg</source></image>   
		<image xml:id='W0037_Vol02' citation="Castillo Sotomayor, Opera Omnia, Vol. 2 (2022 [1658])"><source>https://facs.salamanca.school/W0037/B/W0037-B-0001.jpg</source></image>     
		<image xml:id='W0041' citation="Díaz de Luco, Practica criminalis canonica (2021 [1554])"><source>https://facs.salamanca.school/W0041/W0041-0001.jpg</source></image>
		<image xml:id='W0043_Vol02' citation="Name, Titel, Datum "><source>https://facs.salamanca.school/W0043/B/W0043-B-0001.jpg</source></image>
		<image xml:id='W0046'  citation="Freitas, De Iusto Imperio Lusitanorum Asiatico (2020 [1625])"><source>https://facs.salamanca.school/W0046/W0046-0005.jpg</source></image>
		<image xml:id='W0061'  citation="León Pinelo, Confirmaciones Reales de Encomiendas (2021 [1630])"><source>https://facs.salamanca.school/W0061/W0061-0005.jpg</source></image>
		<image xml:id='W0078'  citation="Nebrija, Lexicon Iuris Civilis (2020 [1537])"><source>https://facs.salamanca.school/W0078/W0078-0005.jpg</source></image>
		<image xml:id='W0083'  citation="Pedraza, Summa de casos de consciencia (2021 [1568])"><source>https://facs.salamanca.school/W0083/W0083-0002.jpg</source></image>
		<image xml:id='W0095'  citation="Sepúlveda, Apologia pro libro de iustis belli causis (2020 [1550])"><source>https://facs.salamanca.school/W0095/W0095-0001.jpg</source></image>
		<image xml:id='W0096_Vol01'  citation="Solórzano Pereira, De Indiarum Iure, sive de Iusta Indiarum Occidentalium Inquisitione, Acquisitione, et Retentiones Tribus Libris Comprehensum. 2 vols. (2021 [1629])"><source>https://facs.salamanca.school/W0096/A/W0096-A-0007.jpg</source></image>
		<image xml:id='W0103' citation="Vacca, Expositiones locorum obscuriorum et Paratitulorum in Pandectas. (2020 [1554])"><source>https://facs.salamanca.school/W0103/W0103-0001.jpg</source></image>
		<image xml:id='W0106' citation="Menchaca, Controversiarum Libri Tres. (2022 [1572])"><source>https://facs.salamanca.school/W0106/W0106-0005.jpg</source></image>
		<image xml:id='W0113' citation="Villalón, Provechoso tratado de cambios y contrataciones de mercaderes y reprovación de usura (2021 [1541])"><source>https://facs.salamanca.school/W0113/W0113-0005.jpg</source></image>  
		</images>
	</img:images>
</xsl:stylesheet>
