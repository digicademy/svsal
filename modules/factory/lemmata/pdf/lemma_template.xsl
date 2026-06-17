<xsl:stylesheet xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	
	<xsl:output method="xml" indent="no" encoding="UTF-8"/>
	

	<!-- TEMPLATE MATCHING THE ROOT OF XML DOCUMENT -->
	<xsl:template match="/">
		<fo:root font-selection-strategy="character-by-character" font-family="Cardo, serif, Times, Junicode, Antinoou, SBL Hebrew">
			<!-- DEFINING PAGE LAYOUTS AND THEIR SEQUENCES (PAGE AND SEQUENCE MASTERS)-->
			<fo:layout-master-set>
				<!-- FRONT MATTER layout: no header, no page numbers-->
				<fo:simple-page-master master-name="front_matter" page-height="29.7cm" page-width="21cm" margin-top="1.8cm" margin-bottom="1.8cm" margin-left="1.5cm" margin-right="1.5cm">
					<fo:region-body margin-top="1.5cm" margin-bottom="1.3cm" margin-left="1.5cm" margin-right="1.5cm"/>
					<fo:region-before region-name="front_matter-region-before" extent="1.8cm"/>
					<fo:region-after region-name="front_matter-region-after" extent="0.5cm"/>
					<fo:region-start extent="0cm"/>
					<fo:region-end extent="0cm"/>
				</fo:simple-page-master>
				
				<!-- ODD PAGES layout-->
				<fo:simple-page-master master-name="body_matter_odd" page-height="29.7cm" page-width="21cm" margin-top="1.8cm" margin-bottom="1.8cm" margin-left="1.5cm" margin-right="1.5cm">
					<fo:region-body margin-top="1.5cm" margin-bottom="1.3cm" margin-left="1.5cm" margin-right="1.5cm"/>
					<fo:region-before region-name="body_matter_odd-region-before" extent="1.8cm"/>
					<fo:region-after region-name="body_matter_odd-region-after" extent="0.5cm"/>
					<fo:region-start extent="0cm"/>
					<fo:region-end extent="0cm"/>
				</fo:simple-page-master>
				<!--  EVEN PAGES  layout-->
				<fo:simple-page-master master-name="body_matter_even" page-height="29.7cm" page-width="21cm" margin-top="1.8cm" margin-bottom="1.8cm" margin-left="1.5cm" margin-right="1.5cm">
					<fo:region-body margin-top="1.5cm" margin-bottom="1.3cm" margin-left="1.5cm" margin-right="1.5cm"/>
					<fo:region-before region-name="body_matter_even-region-before" extent="1.8cm"/>
					<fo:region-after region-name="body_matter_even-region-after" extent="0.5cm"/>
					<fo:region-start extent="0cm"/>
					<fo:region-end extent="0cm"/>
				</fo:simple-page-master>
				<!-- SEQUENCING odd and even pages   -->
				<fo:page-sequence-master master-name="body_matter">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference master-reference="body_matter_odd" odd-or-even="odd"/>
						<fo:conditional-page-master-reference master-reference="body_matter_even" odd-or-even="even"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
			</fo:layout-master-set>

			
			<!-- 1. TITLE PAGE OF THE ARTICLE -->
			<fo:page-sequence master-reference="front_matter">
				<fo:flow flow-name="xsl-region-body">
                    <fo:block text-align="center" font-size="40pt" font-style="normal" font-weight="bold" space-before="20mm" space-after="20mm">
						<xsl:apply-templates select="//tei:titleStmt//tei:title[@type = 'short']"/>                        
					</fo:block>
                    <fo:block text-align="center" font-size="20pt">
                    	<fo:inline>
                            <xsl:apply-templates select="//tei:titleStmt//tei:author[1]//tei:forename"/>
                        </fo:inline>
                    	<fo:inline>
                            <xsl:value-of select="' '"/>
                        </fo:inline>
                    	<fo:inline>
                            <xsl:apply-templates select="//tei:titleStmt//tei:author[1]//tei:surname"/>
                        </fo:inline>                        
					</fo:block>
					<fo:block text-align="center" font-size="20pt" space-after="40mm">
						<fo:inline>
                            <xsl:apply-templates select="//tei:titleStmt//tei:author[2]//tei:forename"/>
                        </fo:inline>
						<fo:inline>
                            <xsl:value-of select="' '"/>
                        </fo:inline>
						<fo:inline>
                            <xsl:apply-templates select="//tei:titleStmt//tei:author[2]//tei:surname"/>
                        </fo:inline>                        
					</fo:block>
                    <xsl:apply-templates select="//tei:sourceDesc"/>
                    
				</fo:flow>
			</fo:page-sequence>
			<!-- EDITORS -->
			<fo:page-sequence master-reference="front_matter">
				
				<fo:flow flow-name="xsl-region-body">
					<fo:block font-size="14pt" space-after="10mm">Technical editors:</fo:block>
					<fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="center">
						<xsl:apply-templates select="//tei:editor[1]"/>
					</fo:block>
                    <fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="center">
						<xsl:apply-templates select="//tei:editor[2]"/>
					</fo:block>
                    <fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="center">
						<xsl:apply-templates select="//tei:editor[3]"/>
					</fo:block>
					<fo:block font-size="14pt" space-before="10mm" space-after="10mm">Proposed
						citation: </fo:block>
					<fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="justify">
						<xsl:choose>
							<xsl:when test="//tei:titleStmt//tei:author[2]">
								<fo:inline>
                                    <xsl:apply-templates select="//tei:titleStmt//tei:author[1]//tei:surname"/>
                                </fo:inline>
								<fo:inline>
                                    <xsl:value-of select="', '"/>
                                </fo:inline>
								<fo:inline>
                                    <xsl:apply-templates select="//tei:titleStmt//tei:author[2]//tei:surname"/>
                                </fo:inline>
								<fo:inline>
                                    <xsl:value-of select="': '"/>
                                </fo:inline>
							</xsl:when>
							<xsl:otherwise>
								<fo:inline>
                                    <xsl:apply-templates select="//tei:titleStmt//tei:author[1]//tei:surname"/>
                                </fo:inline>
								<fo:inline>
                                    <xsl:value-of select="': '"/>
                                </fo:inline>
							</xsl:otherwise>
						</xsl:choose>		
                        <fo:inline>
                            <xsl:value-of select="//tei:teiHeader//tei:titleStmt/tei:title[@type eq 'main']"/>,
                        in: The School of Salamanca. A Dictionary of its Juridical-Political Language. DOI: [..]
						</fo:inline>
					</fo:block>
                    <fo:block font-size="14pt" font-style="normal" font-weight="normal" text-align="justify">
                        &lt;<xsl:apply-templates select="//tei:publicationStmt//tei:idno[@xml:id = 'urlid']/replace(., 'texts', 'lemmata')"/>&gt;
                    </fo:block>
				</fo:flow>
			</fo:page-sequence>
			<!-- TABLE OF CONTENTS PAGE -->
			
			<fo:page-sequence master-reference="front_matter">
				<fo:flow flow-name="xsl-region-body">
					<fo:block font-size="16pt" font-weight="bold" space-before="10mm" space-after="10mm">
                        <xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
                    </fo:block>
					<xsl:apply-templates select="//tei:div[@type = 'contents']"/>
				</fo:flow>
			</fo:page-sequence>
            
            <!-- MAIN CONTENT SECTION (BODY), PAGINATION STARTS HERE-->
			<fo:page-sequence master-reference="body_matter" initial-page-number="1">
						<fo:static-content flow-name="body_matter_odd-region-before">
							<fo:block text-align="center">
								<xsl:value-of select="'The School of Salamanca. A Dictionary of its Juridical-Political Language.'"/>
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
							 <xsl:apply-templates select="//tei:body"/>
							</fo:block>
						</fo:flow>
					</fo:page-sequence>
			
			<!-- BACK Literature  -->
			<xsl:if test="//tei:text/tei:back">
				<fo:page-sequence master-reference="body_matter">
					<fo:static-content flow-name="body_matter_odd-region-before">
						<fo:block text-align="center">
							<xsl:value-of select="//tei:titleStmt//tei:title[@type = 'short']"/>
						</fo:block>
					</fo:static-content>
					<fo:static-content flow-name="body_matter_even-region-before">
						<fo:block text-align="center">
							<xsl:value-of select="'The School of Salamanca. A Dictionary of its Juridical-Political Language.'"/>
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
							<xsl:apply-templates select="//tei:back"/>
						</fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
		</fo:root>
	</xsl:template>


	<!-- TEMPLATES FOR "3. TITLE PAGE OF THE PRINT EDITION" -->
	<xsl:template match="tei:sourceDesc">
		<fo:block text-align="center" font-size="20pt" font-style="normal" font-weight="normal" space-before="5mm">
			<xsl:apply-templates select="//tei:sourceDesc//tei:author"/>
		</fo:block>
		<fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal" space-before="15mm">The School of Salamanca</fo:block>
		<fo:block text-align="center" font-size="18pt" font-style="normal" font-weight="normal">A
			Dictionary of its Juridical-Political
			Language</fo:block>
		
		
		<fo:block text-align="center" font-size="14pt" space-before="7mm" space-after="3mm">Editors:</fo:block>
		<fo:block text-align="center" font-size="14pt" space-before="2mm" space-after="2mm">
			<xsl:value-of select="'Duve, Thomas'"/>
		</fo:block>
		<fo:block text-align="center" font-size="14pt" space-before="2mm" space-after="2mm">
			<xsl:value-of select="'Lutz-Bachmann, Matthias'"/>
		</fo:block>
        <fo:block text-align="center" font-size="14pt" space-before="2mm" space-after="2mm">
        	<xsl:value-of select="'Birr, Christiane'"/>
		</fo:block>
        <fo:block text-align="center" font-size="14pt" space-before="2mm" space-after="2mm">
        	<xsl:value-of select="'Schweighöfer, Stefan'"/>
		</fo:block>
		<fo:block text-align="center" font-size="14pt" space-before="12mm">
			<xsl:value-of select="'Akademie der Wissenschaften und der Literatur, Mainz'"/>
		</fo:block>
		<fo:block text-align="center" font-size="14pt">
			<xsl:value-of select="'Max-Planck-Institut für Rechtsgeschichte und Rechtstheorie'"/>
		</fo:block>
		<fo:block text-align="center" font-size="14pt">
			<xsl:value-of select="'Goethe-Universität Frankfurt'"/>
		</fo:block>
		<fo:block text-align="center" font-size="14pt" space-before="12mm">Electronic publication,
				<xsl:apply-templates select="//tei:publicationStmt/tei:date[@type = 'digitizedEd']"/>
		</fo:block>
		<fo:block text-align="center" font-size="14pt">
                <xsl:apply-templates select="//tei:publicationStmt//tei:idno[@xml:id = 'urlid']/replace(., 'texts', 'lemmata')"/>
		</fo:block>
        <fo:block text-align="center" font-size="14pt" font-style="normal" font-weight="normal">https://www.salamanca.school</fo:block>
	</xsl:template>
	
	<xsl:template match="tei:body | tei:back">
		<xsl:call-template name="process_div"/>
	</xsl:template>
	<xsl:template name="process_div">
		<xsl:for-each select="./tei:div">
				<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>

	<!-- TEMPLATES FOR <DIV> ELEMENTS AND THEIR DESCENDANTS -->
	<xsl:template match="tei:div">
		<xsl:variable name="div_id" select="@xml:id"/>
		<fo:block id="{./@xml:id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<xsl:template match="tei:head">
		<fo:block text-align="justify" font-size="14pt" font-weight="bold" space-before="20pt" space-after="0.5cm" text-indent="0em" keep-with-next="always" id="{./@xml:id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="tei:item">
		<fo:block id="{@xml:id}" text-align="justify" start-indent="16pt" space-before="0.2cm" space-after="0.2cm" font-size="12pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="tei:list">
		<fo:block id="{@xml:id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="tei:persName">
		<fo:inline>
            <xsl:apply-templates/>
        </fo:inline>
	</xsl:template>
	
	<xsl:template match="tei:placeName">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="//tei:text//tei:date">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="tei:quote">
			<xsl:apply-templates/>
	</xsl:template>
	
	
    <!--<xsl:template match="tei:body//tei:p">
        
        <fo:block id="{@xml:id}" text-align="justify" font-size="12pt" space-before="1mm" space-after="2mm">
            <fo:inline font-weight="bold" font-size="12pt">             
                    <xsl:value-of select="concat(./@n,'  ')"/>
            </fo:inline>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>-->
    <xsl:template match="tei:body//tei:p">
        <!-- list item - https://www.w3.org/Style/XSL/TestSuite/contrib/FOP/list.pdf-->
        <fo:list-block provisional-distance-between-starts="0.4cm" provisional-label-separation="0.15cm" space-before="1mm" space-after="2mm">
            <fo:list-item>
            <fo:list-item-label end-indent="label-end()" font-weight="bold" font-size="11pt">
                <fo:block font-weight="bold">
                        <xsl:value-of select="./@n"/>
                    </fo:block>
            </fo:list-item-label>
            <!-- list text -->
            <fo:list-item-body start-indent="body-start()">
                <fo:block text-align="justify" text-indent="6pt" space-before="1mm" space-after="2mm">
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
            </fo:list-item>
        </fo:list-block>
        <!-- end list -->
	</xsl:template>
	

	<!-- TEMPLATES FOR DIFFERENT TYPES OF HIGHLIGHTING (<HI>) -->
	<xsl:template match="tei:hi[@rendition eq '#initCaps']">
		<fo:inline font-family="serif" font-size="18pt" space-before="0.1mm" space-after="0.1mm">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="tei:hi[@rendition = '#r-center' and not(ancestor::tei:head)]">
		<fo:block text-align="center">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	<xsl:template match="tei:hi[@rendition eq '#sup']">
		<fo:inline baseline-shift="super" font-size="8pt">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
    <xsl:template match="tei:persName//tei:hi[@rendition eq '#sc']"> <!--Not supported by xsl-fo :(-->
		<fo:inline font-variant="small-caps">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	<xsl:template match="tei:hi[@rendition eq '#it']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
		

	<!-- TEMPLATE FOR <ref>s in table of contents.  -->
	<xsl:template match="tei:div[@type eq 'contents']//tei:list//tei:ref[@target]">
		<xsl:variable name="input" select="translate(@target, '#', '')"/>
		<fo:inline space-before="0.2cm" space-after="0.2cm">
			<fo:basic-link internal-destination="{$input}" color="#0a0c75">
				<xsl:apply-templates/>
			</fo:basic-link>
			<xsl:text> </xsl:text>
		</fo:inline>
	</xsl:template>
    <!--<ref>s in Literature-->
    <xsl:template match="tei:div[@type eq 'sources']//tei:list//tei:ref[@target]">
		<xsl:variable name="input" select="translate(@target, '#', '')"/>
		<fo:inline space-before="0.2cm" space-after="0.2cm">
			<fo:basic-link external-destination="url({$input})" color="#0a0c75">
				<xsl:apply-templates/>
			</fo:basic-link>
			<!--<xsl:text> </xsl:text>-->
		</fo:inline>
	</xsl:template>
<!--	TEMPLATE FOR BIBL/@CORRESP-->
    <xsl:template match="//tei:body//tei:bibl[@corresp]">
		<xsl:variable name="input" select="@corresp"/>
		<fo:inline space-before="0.2cm" space-after="0.2cm">
			<fo:basic-link external-destination="url({$input})" color="#0a0c75">
				<xsl:apply-templates/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template>
	

	<!--  NOT USED -->
	
	<xsl:template match="tei:teiHeader"/>
	<xsl:template match="tei:fileDesc"/>
	<xsl:template match="//tei:fileDesc/tei:sourceDesc/tei:biblStruct/tei:note"/>
	<xsl:template match="tei:titleStmt/tei:title[@type = 'main']"/>
	<xsl:template match="tei:sourceDesc//tei:title[@type = 'main']"/>
	<xsl:template match="tei:sourceDesc//tei:title[@type = 'short']"/>
	<xsl:template match="tei:revisionDesc"/>
	<xsl:template match="tei:titleStmt"/>
	
</xsl:stylesheet>