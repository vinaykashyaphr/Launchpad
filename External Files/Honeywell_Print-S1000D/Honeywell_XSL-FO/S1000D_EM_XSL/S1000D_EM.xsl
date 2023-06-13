<?xml version="1.0" encoding="UTF-8"?>

<!-- This is the main stylesheet for S1000D EM. It is based on the S1000D EIPC version, with customization -->
<!-- for EM added from the ATA EM stylesheet (EM.xsl). -->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
	xmlns:xtbl="com.nwalsh.xalan.Table" xmlns:xlink="http://www.w3.org/1999/xlink">

	<!-- Import (allowing over-rides) common stylesheets: some shared for both ATA and S1000D, some just S1000D -->
	<xsl:import href="../S1000D_shared/standardVariables.xsl" />
	<xsl:import href="../shared/unhandled-element.xsl" />
	<xsl:import href="../shared/standardFunctions.xsl" />
	<xsl:import href="../shared/cageInfo.xsl" />
	<!-- <xsl:import href="../shared/rrTable.xsl" /> -->
	<!-- <xsl:import href="../shared/regulatory.xsl" /> -->
	<xsl:import href="../S1000D_shared/stdPages.xsl" />
	<xsl:import href="../S1000D_shared/references.xsl" />
	<xsl:import href="../S1000D_shared/tbl-not-caps.xsl" />
	<xsl:import href="../S1000D_shared/S1000D_common.xsl" />
	
	<!-- Other shared S1000D modules -->
	<xsl:include href="../S1000D_shared/partinfo-table.xsl" />
	<xsl:include href="../S1000D_shared/legend.xsl" />
	<xsl:include href="../S1000D_shared/para.xsl" />
	<xsl:include href="../S1000D_shared/figure.xsl" />
	<xsl:include href="../S1000D_shared/S1000DLists.xsl" />

	<!-- EM-specific modules -->
	<xsl:include href="numIndex.xsl" />
	<xsl:include href="chapterToc.xsl" />
	<xsl:include href="emMiscFunctions.xsl" />
	<!-- <xsl:include href="acmm.xsl" /> -->
	<!-- <xsl:include href="cmm-variables.xsl" /> -->
	<!-- Revised list handling (proceduralSteps, levelledPara) for S1000D -->
	<xsl:include href="pdfBookmarks.xsl" />
	<xsl:include href="lepTable_EM.xsl" />
	<xsl:include href="transmittal.xsl" />
	<xsl:include href="titles.xsl" />
	<!-- Not sure if regular EMs (not EIPC) ever use the DPL functionality, but just in case... -->
	<xsl:include href="dplist.xsl" />
	
	<xsl:include href="pdfMetaData_S1000D.xsl"/>
	
	<xsl:output method="xml" encoding="UTF-8" indent="no" />

	<xsl:template match="/">
	
      <xsl:message>******************************************************************************</xsl:message>
      <xsl:message>Generating XSL-FO</xsl:message>
      <xsl:message>Document type is: [<xsl:value-of select="$documentType"/>]</xsl:message>
      <xsl:message>The image (logos) path is: [<xsl:value-of select="$IMAGES_DIR"/>]</xsl:message>
      <xsl:message>The graphics path is: [<xsl:value-of select="$GRAPHICS_DIR"/>]</xsl:message>
      <xsl:message>The logoDir is: [<xsl:value-of select="$logoDir"/>]</xsl:message>
      <xsl:message>The CAGE code is (spl attr): [<xsl:value-of select="$splLowercase"/>]</xsl:message>
      <xsl:message>The partner CAGE code is (prtnrspl attr): [<xsl:value-of select="$prtnprSplLowercase"/>]</xsl:message>
      <!-- <xsl:message>Parsing <xsl:value-of select="count(//*)"/> elements</xsl:message> -->
      <xsl:message>******************************************************************************</xsl:message>
      
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
		
   			<!-- Sonovision update (2019.07.02)
   			     - PDF metadata now stored in separate module which will be updated during
   			       full build process from CVS to include application version information
   			       in the PDF "subject" field
   			       -->
   			<xsl:call-template name="pdfMetaData"/>
			
			<xsl:call-template name="define-pagesets" />
			<xsl:apply-templates/>
		</fo:root>
	</xsl:template>

	<xsl:template match="pm">
		<xsl:call-template name="do-pdf-bookmarks" />
		<xsl:call-template name="do-frontmatter" />
		<!-- Note: in S1000D, we don't have a clear separation between the front-matter 
			pmEntries and the body pmEntries... -->
		<!-- Process all pmEntries except pmt77 (continuation of title pages) which is output in the do-frontmatter template -->
		<xsl:apply-templates select="content/pmEntry[not(@pmEntryType='pmt77')]" />

		<xsl:call-template name="do-foldouts" />
	</xsl:template>

	<!-- This template handles the frontmatter portion of the CMM. -->
	<!-- The top-level element (pm) is in context. -->
	<xsl:template name="do-frontmatter">
		<!-- RS: EIPC adds force-page-count="even" -->
		<fo:page-sequence master-reference="Title" font-family="Arial" font-size="10pt" force-page-count="even">
			<!-- Assign an id attribute for the page-sequence. -->
			<!-- RS: The key attribute is on various front-matter sections (in ATA), 
				as well as pgblks. But there is no corresponding id attribute on pm in S1000D,
				so just use 'toc'-->
			<xsl:attribute name="id">toc</xsl:attribute>
			
			<!-- Added Check for following Landscape Tables Because of the CDATA hack, 
				it can throw off the page numbers. If a Landscape table is detected as the 
				next node that creates a page-sequence, the no force-page-count will be added 
				For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed -->
			<!-- TODO: Not clear if this logic needs to apply for S1000D -->
			<xsl:choose>
				<xsl:when
					test="not(*[1]/following::*[name()='IPL' or name()='PGBLK' or (name()='TABLE' and (@ORIENT='land' or @TABSTYLE='hl'))][1]/(name()='TABLE' and @ORIENT='land'))">
					<!--<xsl:message>Found no landscape tables coming before next page-sequence</xsl:message>-->
					<xsl:attribute name="force-page-count">even</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Found landscape table coming before next page-sequence</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Output the title page content -->
			<xsl:call-template name="init-title-sequence-static">
				<xsl:with-param name="page-prefix" select="'T-'" />
			</xsl:call-template>
			<fo:flow flow-name="xsl-region-body">
				<fo:block id="title_page">
					<!-- Make sure effectivity defaults to "ALL" -->
					<fo:marker marker-class-name="efftextValue">
						<xsl:value-of select="'ALL'" />
					</fo:marker>
			
				  <!-- RS: draft-as-of adds a "Draft as of..." statement to the title page when /CMM[@OVERLAYFORMATSTYLE='draft'] -->
					<xsl:call-template name="draft-as-of" />
					<xsl:call-template name="selectFirstPageHeader" />
					<xsl:call-template name="part-info-table" />
				</fo:block>
				<!-- RS: The legal notice is in its own pmEntry, so this is not necessary (but might need some work to
				keep the same prefix ("T-") and continue pagination -->
				<fo:block page-break-before="always">
					<xsl:apply-templates select="content/pmEntry[@pmEntryType='pmt77']" />
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
		<!-- MFATR in ATA has the Transmittal Information, Record of Temporary Revisions, and Service Bulletin List. -->
		<!-- In S1000D, these are all in separate pmEntries. So we don't need this here. -->
		<!-- <xsl:apply-templates select="./MFMATR" /> -->
	</xsl:template>

	<!-- Top-level pmEntry. In EM this can be front-matter, introduction, or a "Chapter", with its ATA code (like "72") in @authorityDocument -->
	<xsl:template match="content/pmEntry">

		<!-- Appendix Support [Not needed for EM(?)]-->
		<!-- 
		<xsl:variable name="appendix-prefix">
			<xsl:if test="number(ancestor-or-self::PGBLK/@PGBLKNBR) >= 17000">
				<xsl:call-template name="calculateCMMAppendixNumber" />
				<xsl:text>-</xsl:text>
			</xsl:if>
		</xsl:variable>
		-->
 
		<!-- Page prefixes for front-matter  --> 
		<xsl:variable name="page-prefix">
			<xsl:choose>
			  <xsl:when test="@pmEntryType='pmt77'">
				<!-- Continuation of title page ("Honeywell Confidential", etc.) -->
			  	<xsl:text>T-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt52'">
				<!-- Transmittal information -->
			  	<xsl:text>TI-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt53'">
				<!-- Record of revisions -->
			  	<xsl:text>RR-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt54'">
				<!-- Record of temporary revisions -->
			  	<xsl:text>RTR-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt55'">
				<!-- Service Bulletin List -->
			  	<xsl:text>SBL-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt56'">
			  	<xsl:text>LEP-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt58'">
			  	<xsl:text>INTRO-</xsl:text>
			  </xsl:when>
			  <xsl:when test="@pmEntryType='pmt90'">
			  	<xsl:text>VCL-</xsl:text>
			  </xsl:when>
			  <xsl:otherwise />
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="page-suffix">
			<!-- The page suffix is set in the top-level pmEntry authorityName attribute. -->
			<!-- TODO: This needs to be checked for the 5-level PM. -->
			<!-- UPDATE: I don't think this is true for EM; there is never a page number suffix, and authorityName is -->
			<!-- used for section headings in the page footer. There may be a section-enum, but that is handled separately. -->
			<!--   
			<xsl:choose>
		      <xsl:when test="@authorityName">
		      	<xsl:text>-</xsl:text><xsl:value-of select="@authorityName"/>
		      </xsl:when>
			</xsl:choose> -->
		</xsl:variable>

		<!-- Not sure what this is for (probably not needed for EM): --> 
		<xsl:variable name="pgblk-confnbr">
			<!-- 
			<xsl:choose>
				<xsl:when test="ancestor-or-self::PGBLK/@CONFNBR">
					<xsl:value-of select="ancestor-or-self::PGBLK/@CONFNBR" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose> -->
		</xsl:variable>
		 
		<xsl:variable name="pgblk-effect">
			<!-- 
			<xsl:choose>
				<xsl:when
					test="$documentType='irm' and number(ancestor-or-self::PGBLK[@PGBLKNBR='5000' or @PGBLKNBR='6000']/@CONFNBR) >= 1000">
					<xsl:value-of select="ancestor-or-self::PGBLK/EFFECT" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose> -->
		</xsl:variable>
		
		<xsl:choose>
		
		  <!-- Continuation of title pages: already called in by the front-matter/title page template, -->
		  <!-- so we don't need a new page set here. -->
		  <xsl:when test="@pmEntryType='pmt77'">
        	<xsl:comment>page sequence for top-level pmEntry (@pmEntryType='pmt77'; continuation of title pages)</xsl:comment>
			<xsl:apply-templates />
		  </xsl:when>
		  
		  <!-- RS: If it's the LEP pmEntry, output LEP and and Intro ToC -->
		  <xsl:when test="@pmEntryType='pmt56'">
        	<xsl:comment>top-level pmEntry (LEP: @pmEntryType='pmt56') - output LEP and Intro ToC</xsl:comment>
	  		<xsl:if test="0 = number($LEP_PASS)">
				<xsl:call-template name="detail-lep">
					<xsl:with-param name="frontmatter" select="1" />
					<!-- In EIPC it looks like 'INT' is used for the main ATA number, not 'CMP' as in CMM; though I have see some samples where it is different... need to clarify this -->
					<xsl:with-param name="chapter" select="substring(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='INT'],1,2)" /><!-- /CMM/@CHAPNBR -->
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="intro-toc"/>
		  </xsl:when>
		  
		  <!-- Sometimes there is an empty Diagrams and Schematics section: suppress it. -->
		  <xsl:when test="@pmEntryType='pmt57'">
		  </xsl:when>
		  
		  <!-- If it's an IPD section, then we need to add the section LEP and section ToC. -->
		  <!-- And if it's the first one, we should output the Numerical Index for the whole document. -->
		  <!-- NOTE: This was originally from EIPC. For EM, this doesn't normally occur, but keep here for reference. -->
		  <xsl:when test="@pmEntryType='pmt75'">
		  
        	<xsl:comment>page sequence for top-level pmEntry (IPD section; @pmEntryType='pmt75') - Add the Chapter ToC and LEP for this chapter</xsl:comment>
        	
		  	<!-- If it's the first IPD Section in the document, add the Numerical Index for all the IPD sections. -->
		  	<!-- NOTE: In ATA FO this was added at the end of the front-matter section (after processing <MFMATR>). -->
		  	<xsl:if test="count(preceding-sibling::pmEntry[1][@pmEntryType='pmt75'])=0">
		  		<xsl:call-template name="build-numerical-index"/>
		  	</xsl:if>
		  	
		  	<!-- Add the Chapter ToC and LEP for this chapter. -->
	        <xsl:call-template name="chapter-toc"/>
	        
	  		<xsl:if test="0 = number($LEP_PASS)">
				<xsl:call-template name="detail-lep">
					<xsl:with-param name="frontmatter" select="0" />
					<!-- The chapter number is specified in the authorityDocument attribute -->
					<xsl:with-param name="chapter" select="@authorityDocument" />
				</xsl:call-template>
			</xsl:if>
			
			<!-- There is no title page (or pmEntryTitle output) at the Chapter level -->		  	
		  	<!-- Process contents without a new pageset; the 2nd level pmEntries will add them. -->
			<xsl:apply-templates select="* except (pmEntryTitle)"/>
			
		  </xsl:when>
		  
		  <!-- If after the Introduction, it's a new Chapter - add the Chapter LEP and ToC, -->
		  <!-- but don't start a new page sequence: they are added at the 4th level pmEntry -->
		  <xsl:when test="preceding-sibling::pmEntry[@pmEntryType='pmt58']">
	  		<xsl:if test="number($LEP_PASS) = 0">
	  			<xsl:choose>
	  				<xsl:when test="$isNewPmc">
						<xsl:call-template name="detail-lep">
							<xsl:with-param name="frontmatter" select="0" />
							<!-- The chapter number is specified in the authorityDocument attribute -->
							<xsl:with-param name="chapter" select="@authorityDocument" />
						</xsl:call-template>
	  				</xsl:when>
	  				<xsl:otherwise>
						<xsl:call-template name="detail-lep">
							<xsl:with-param name="frontmatter" select="0" />
							<xsl:with-param name="chapter" select="substring(@authorityDocument,1,2)" />
							<!-- Was using section for 3-level LEPs, but this was inconsistent, so using a new -->
							<!-- attribute "chapterCtr" to specify which chapter to output (just the count of the preceding top-level pmEntries) -->
							<!-- <xsl:with-param name="section" select="substring(@authorityDocument,4,2)" /> -->
							<xsl:with-param name="chapterCtr" select="string(count(ancestor-or-self::pmEntry[last()]/preceding-sibling::pmEntry))" />
						</xsl:call-template>
	  				</xsl:otherwise>
	  			</xsl:choose>

			</xsl:if>
		    <xsl:call-template name="chapter-toc"/>
			<xsl:apply-templates select="* except (pmEntryTitle)"/>
		  </xsl:when>
		  
		  <!-- RS: Otherwise it should be a front-matter section (or Introduction); output the normal front-matter pageset and content -->
		  <xsl:otherwise>
        	<xsl:comment>page sequence for top-level pmEntry (front-matter and Introduction)</xsl:comment>
			<fo:page-sequence master-reference="Body"
				font-family="Arial" font-size="10pt" initial-page-number="1"><!-- Front-matter sections always start at 1 -->
				<!-- Added Check for following Landscape Tables Because of the CDATA hack, 
					it can through off the page numbers. If a Landscape table is detected as 
					the next node that creates a page-sequence, the no force-page-count will 
					be added For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed -->
				<xsl:choose>
					<xsl:when
						test="not(*[1]/following::*[name()='IPL' or name()='PGBLK' or (name()='TABLE' and (@ORIENT='land' or @TABSTYLE='hl'))][1]/(name()='TABLE' and @ORIENT='land'))">
						<!--<xsl:message>Found no landscape tables coming before next page-sequence</xsl:message>-->
						<xsl:attribute name="force-page-count">even</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>Found landscape table coming before next page-sequence</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="init-static-content">
					<xsl:with-param name="page-prefix" select="$page-prefix" />
					<!-- <xsl:with-param name="page-suffix" select="$page-suffix" /> [Should be no suffixes for front-matter or introduction] -->
					<xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr" />
					<xsl:with-param name="pgblk-effect" select="$pgblk-effect" />
				</xsl:call-template>
				<fo:flow flow-name="xsl-region-body">
					<fo:block font-size="0.001pt" color="white">
						<xsl:text>pgblkst</xsl:text>
						<xsl:value-of select="1" />
					</fo:block>
					<xsl:choose>
						<xsl:when test="EFFECT and $documentType !='irm'">
							<fo:block>
								<fo:marker marker-class-name="efftextValue">
									<xsl:value-of select="EFFECT" />
								</fo:marker>
							</fo:block>
						</xsl:when>
						<xsl:otherwise>
							<fo:block>
								<fo:marker marker-class-name="efftextValue">
									<xsl:value-of select="'ALL'" />
								</fo:marker>
							</fo:block>
						</xsl:otherwise>
					</xsl:choose>
					<fo:block id="{@id}">
						<!-- <xsl:attribute name="id">
			            	<xsl:value-of select="@id" />++ @KEY ++
	          			</xsl:attribute> -->
						<!-- RS: Add revdate (and other metadata) for top-level pmEntries (for LEP generation etc.). -->		
						<xsl:call-template name="save-revdate" />
						<xsl:choose>
							<xsl:when test="ISEMPTY"><!-- This is not used in S1000D -->
								<fo:block text-align="center" font-weight="bold"
									font-size="12pt" padding-after="6pt" keep-with-next.within-page="always">
									<!-- RS: This outputs the page block title appropriate for the page block number. Don't think we need to handle ISEMPTY in S1000D -->
									<xsl:call-template name="pgblk-title">
										<xsl:with-param name="pgblknbr" select="@PGBLKNBR" />
									</xsl:call-template>
								</fo:block>
								<fo:list-block font-size="10pt"
									provisional-distance-between-starts="24pt" space-before=".1in"
									space-after=".1in" keep-with-next.within-page="always">
									<xsl:call-template name="save-revdate" />
									<fo:list-item>
										<fo:list-item-label end-indent="label-end()">
											<fo:block>
												<xsl:number value="1" format="1." />
											</fo:block>
										</fo:list-item-label>
										<fo:list-item-body start-indent="body-start()">
											<fo:block>
												<xsl:text>Not Applicable</xsl:text>
											</fo:block>
										</fo:list-item-body>
									</fo:list-item>
								</fo:list-block>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates />
							</xsl:otherwise>
						</xsl:choose>
						<!-- For Transmittal Information, output the Table of Highlights after. -->
						<!-- It's possible for there to be no changes, so make a condition for that here: omit the table altogether. -->
						<!-- Don't count empty ones with no ID -->
						<xsl:if test="@pmEntryType='pmt52'
							and count(//reasonForUpdate[@updateHighlight='0'])!=count(//reasonForUpdate[@id])">
					       <xsl:call-template name="highlights_table"/>
					    </xsl:if>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>
		  </xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Nested pmEntry. May need to separate specific levels later... -->
	<xsl:template match="pmEntry/pmEntry">
		<xsl:choose>
			<!-- 2nd-level pmEntry (In 5-level EM, the "Section", with ATA code in @authorityDocument like "72-00"). -->
			<!-- Or if it's the Introduction, this is the first level of numbered headings ("1.")  -->
			<xsl:when test="count(ancestor::pmEntry)=1">
				<xsl:choose>
					<xsl:when test="ancestor::pmEntry/@pmEntryType='pmt58'">
						<xsl:comment>2nd-level pmEntry in the Introduction</xsl:comment>
						<fo:block id="{@id}">
							<xsl:apply-templates/>
						</fo:block>
					</xsl:when>
					<xsl:when test="$isNewPmc">
						<!-- Styler doesn't do anything for 5-level EM at the second-level pmEntry. The pmEntryTitle is hidden (don't process it) -->
						<xsl:comment>2nd-level pmEntry</xsl:comment>
						<xsl:apply-templates select="* except (pmEntryTitle)"/>
					</xsl:when>
					<xsl:otherwise>
					  <!-- For 3-level PMC, this is where the page set is applied in Styler. -->
					  <xsl:variable name="start-page-number">
						<xsl:choose>
							<xsl:when test="number(@startat)">
								<xsl:value-of select="@startat"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'1'"/>
							</xsl:otherwise>
						</xsl:choose>
					  </xsl:variable>
		
					<xsl:variable name="page-prefix"/>
					<xsl:variable name="page-suffix"/>
			
					<!-- Not sure what this is for (probably not needed for EM): --> 
					<xsl:variable name="pgblk-confnbr">
						<xsl:choose>
							<xsl:when test="ancestor-or-self::PGBLK/@CONFNBR">
								<xsl:value-of select="ancestor-or-self::PGBLK/@CONFNBR" />
							</xsl:when>
							<xsl:otherwise />
						</xsl:choose>
					</xsl:variable>
					 
					<xsl:variable name="pgblk-effect">
						<xsl:choose>
							<xsl:when
								test="$documentType='irm' and number(ancestor-or-self::PGBLK[@PGBLKNBR='5000' or @PGBLKNBR='6000']/@CONFNBR) >= 1000">
								<xsl:value-of select="ancestor-or-self::PGBLK/EFFECT" />
							</xsl:when>
							<xsl:otherwise />
						</xsl:choose>
					</xsl:variable>
					
			          <xsl:comment>Page sequence for 3rd level pmEntry (in 3-level PMC)</xsl:comment>
			        	
					  <fo:page-sequence master-reference="Body"
						font-family="Arial" font-size="10pt" initial-page-number="{$start-page-number}">
						<!-- Added Check for following Landscape Tables Because of the CDATA hack, 
							it can through off the page numbers. If a Landscape table is detected as 
							the next node that creates a page-sequence, the no force-page-count will 
							be added For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed -->
						<xsl:choose>
							<xsl:when
								test="not(*[1]/following::*[name()='IPL' or name()='PGBLK' or (name()='TABLE' and (@ORIENT='land' or @TABSTYLE='hl'))][1]/(name()='TABLE' and @ORIENT='land'))">
								<!--<xsl:message>Found no landscape tables coming before next page-sequence</xsl:message>-->
								<xsl:attribute name="force-page-count">even</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message>Found landscape table coming before next page-sequence</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
						<!-- <xsl:message>init-static-content for 4th-level pmEntry</xsl:message> -->
						<xsl:call-template name="init-static-content">
							<xsl:with-param name="page-prefix" select="$page-prefix" />
							<xsl:with-param name="page-suffix" select="$page-suffix" />
							<xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr" />
							<xsl:with-param name="pgblk-effect" select="$pgblk-effect" />
						</xsl:call-template>
						<fo:flow flow-name="xsl-region-body">
							<fo:block font-size="0.001pt" color="white">
								<xsl:text>pgblkst</xsl:text>
								<xsl:value-of select="$start-page-number" />
							</fo:block>
							<xsl:if test="not(EFFECT)">
							</xsl:if>
							<xsl:choose>
								<xsl:when test="descendant::proceduralStep[1]/descendant::table[@applicRefId]">
									<!-- do nothing -->
								</xsl:when>
								<xsl:when test="EFFECT and $documentType !='irm'">
									<fo:block>
										<fo:marker marker-class-name="efftextValue">
											<xsl:value-of select="EFFECT" />
										</fo:marker>
									</fo:block>
								</xsl:when>
								<xsl:otherwise>
									<fo:block>
										<fo:marker marker-class-name="efftextValue">
											<xsl:value-of select="'ALL'" />
										</fo:marker>
									</fo:block>
								</xsl:otherwise>
							</xsl:choose>
							<!-- Add marker for the section title in the footer (called "confnbrValue" as in the original ATA FO) -->
							<!-- and the section enumerator (from @confnbr added by the pre-process). -->
							<!-- UPDATE: Not applicable for 3-level PMC -->
							<xsl:if test="$isNewPmc">
					            <fo:block>
					              <fo:marker marker-class-name="confnbrValue">
					                <xsl:apply-templates select="pmEntryTitle" mode="pgblkConf"/>
					                <!-- <xsl:if test="@CONFNBR != '' and @CONFNBR != 'NA'"> -->
					                <xsl:if test="ancestor-or-self::pmEntry/@confnbr">
					                  <xsl:value-of select="concat('-',ancestor-or-self::pmEntry/@confnbr)"/>
					                </xsl:if>
					              </fo:marker>
								</fo:block>
							</xsl:if>
							<!-- For 3-level PMC, the section title can be specified in the authorityName attribute on the 2nd level pmEntry. -->
							<xsl:if test="not($isNewPmc)">
								<xsl:if test="@authorityName">
						            <fo:block>
						              <fo:marker marker-class-name="confnbrValue">
						                  <xsl:value-of select="@authorityName"/>
						              </fo:marker>
									</fo:block>
								</xsl:if>
							</xsl:if>
		
							<!-- The block for this pmEntry level (3rd) -->
							<fo:block id="{@id}"><!--  space-before.optimum="6pt" space-after.optimum="6pt" text-align="left"  -->
								<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
								<xsl:call-template name="save-revdate" />
							
								<!-- Add empty blocks for link destinations for the Chapter, Section, and Unit levels -->
								<!-- (If it's the first one in the applicable level) -->
								<!-- NOTE: May want to just make links to the first page-block in a section rather than reproducing the chapter/section ids... -->
								<!-- Only applies to the first 4th level pmEntry -->
								<xsl:if test="not(preceding-sibling::pmEntry)">
								  <!-- Add an ID for the 2nd level if this is the first 3rd-level pmEntry -->
								  <fo:block id="{../@id}"/>
								  
								  <!-- Add an ID for the 1st level if this is also in the first 2nd-level pmEntry -->
								  <xsl:if test="not(parent::pmEntry/preceding-sibling::pmEntry)">
									<fo:block id="{../../@id}"/>
								  </xsl:if>
								</xsl:if>
							
								<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
									<xsl:call-template name="cbStart" />
								</xsl:if>
			
								<xsl:apply-templates />

								<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
									<xsl:call-template name="cbEnd" />
								</xsl:if>
							</fo:block>
						</fo:flow>
					  </fo:page-sequence>
					</xsl:otherwise>
				</xsl:choose>
			  	<!-- Add the Section title page -->
			    <!-- <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt"
			         force-page-count="end-on-even" initial-page-number="1">
			        <xsl:call-template name="init-static-content">
			            <xsl:with-param name="page-prefix" select="''"/>
			            <xsl:with-param name="suppressAtacode" select="0"/>
			        </xsl:call-template>
			        <fo:flow flow-name="xsl-region-body">
			        	<xsl:comment>page sequence for 2nd-level pmEntry</xsl:comment>
			            <fo:block margin-top="3.5in" text-align="center" id="{@id}">
			               <xsl:call-template name="save-revdate"/>
			               <xsl:text>DETAILED PARTS LIST</xsl:text>
			            </fo:block>
		                <fo:block space-before.optimum="12pt" text-transform="uppercase" text-align="center">
		                   <xsl:apply-templates select="pmEntryTitle"/>
		                </fo:block>
			        </fo:flow>
		        </fo:page-sequence> -->
	        
				<!-- 
				<fo:block space-before.optimum="6pt" space-after.optimum="6pt" text-align="left" id="{@id}">
					<xsl:choose>
						[!++ From Styler: For IPL, the 3rd and 4th second-level pmEntries are the vendor code list and detailed parts list, and should start on odd pages ++]
						<xsl:when test="parent::pmEntry/@pmEntryType='pmt75'
							and (count(preceding-sibling::pmEntry)=2 or count(preceding-sibling::pmEntry)=3)">
							<xsl:attribute name="break-before">page</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					[!++ RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). ++]		
					<xsl:call-template name="save-revdate" />
					<xsl:apply-templates />
				</fo:block>
				 -->
			</xsl:when>
			
			<!-- 3rd-level pmEntry: For 5-level EM this is the Unit level. Suppress the pmEntryTitle -->
			<xsl:when test="count(ancestor::pmEntry)=2">
				<xsl:choose>
					<xsl:when test="$isNewPmc">
						<xsl:apply-templates select="* except (pmEntryTitle)"/>
					</xsl:when>
					
					<!-- 3-level: Just process, but add a block to hold the destination ID. -->
					<xsl:otherwise>
						<fo:block id="{@id}"/><!-- I don't think it's necessary to wrap the contents in the block. -->

						<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
							<xsl:call-template name="cbStart" />
							<!-- <xsl:message>Adding change bar for 3rd-level pmEntry</xsl:message> -->
						</xsl:if>

						<!-- For type "em" only, add the task number before if provided: -->
						<xsl:if test="$documentType='em' and @taskNumber">
							<fo:block space-after="10pt"><!-- space-before="10pt" -->
								<xsl:text>TASK </xsl:text><xsl:value-of select="@taskNumber"/>
							</fo:block>
						</xsl:if>
						
						<xsl:apply-templates/>

						<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
							<xsl:call-template name="cbEnd" />
						</xsl:if>

					</xsl:otherwise>
				</xsl:choose>
		        
			</xsl:when>

			<!-- In Styler, the 4th-level pmEntry is where new page sets start for the body of the EM (in the 5-level structure) -->
			<!-- Should never occur in 3-level PMC. -->
			<!-- UPDATE: It does occur. So check for new PMC -->
						
			<xsl:when test="count(ancestor::pmEntry)=3 and not($isNewPmc)">
				<!-- 3-level: Just process, but add a block to hold the destination ID. -->
				<fo:block id="{@id}"/><!-- I don't think it's necessary to wrap the contents in the block. -->

				<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
					<xsl:call-template name="cbStart" />
				</xsl:if>

				<xsl:apply-templates/>

				<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
					<xsl:call-template name="cbEnd" />
				</xsl:if>

			</xsl:when>
			
			<xsl:when test="count(ancestor::pmEntry)=3 and $isNewPmc">
			  <xsl:variable name="start-page-number">
				<xsl:choose>
					<xsl:when test="number(@startat)">
						<xsl:value-of select="@startat"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'1'"/>
					</xsl:otherwise>
				</xsl:choose>
			  </xsl:variable>

				<xsl:variable name="page-prefix"/>
		
				<xsl:variable name="page-suffix">
					  <!-- The page suffix is set in the top-level pmEntry authorityName attribute. -->
					  <!-- TODO: This needs to be checked for the 5-level PM. -->
					  <!-- UPDATE: An MM sample had authorityName "SYSTEM DESCRIPTION" at the 4th pmEntry, so this shouldn't be used -->
					  <!-- for a page suffix. -->
					<!-- <xsl:choose>
				      <xsl:when test="@authorityName">
				      	<xsl:text>-</xsl:text><xsl:value-of select="@authorityName"/>
				      </xsl:when>
					</xsl:choose> -->
				</xsl:variable>
		
				<!-- Not sure what this is for (probably not needed for EM): --> 
				<xsl:variable name="pgblk-confnbr">
					<xsl:choose>
						<xsl:when test="ancestor-or-self::PGBLK/@CONFNBR">
							<xsl:value-of select="ancestor-or-self::PGBLK/@CONFNBR" />
						</xsl:when>
						<xsl:otherwise />
					</xsl:choose>
				</xsl:variable>
				 
				<xsl:variable name="pgblk-effect">
					<xsl:choose>
						<xsl:when
							test="$documentType='irm' and number(ancestor-or-self::PGBLK[@PGBLKNBR='5000' or @PGBLKNBR='6000']/@CONFNBR) >= 1000">
							<xsl:value-of select="ancestor-or-self::PGBLK/EFFECT" />
						</xsl:when>
						<xsl:otherwise />
					</xsl:choose>
				</xsl:variable>
				
		          <xsl:comment>Page sequence for 4th level pmEntry</xsl:comment>
		        	
				  <fo:page-sequence master-reference="Body"
					font-family="Arial" font-size="10pt" initial-page-number="{$start-page-number}">
					<!-- Added Check for following Landscape Tables Because of the CDATA hack, 
						it can through off the page numbers. If a Landscape table is detected as 
						the next node that creates a page-sequence, the no force-page-count will 
						be added For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed -->
					<xsl:choose>
						<xsl:when
							test="not(*[1]/following::*[name()='IPL' or name()='PGBLK' or (name()='TABLE' and (@ORIENT='land' or @TABSTYLE='hl'))][1]/(name()='TABLE' and @ORIENT='land'))">
							<!--<xsl:message>Found no landscape tables coming before next page-sequence</xsl:message>-->
							<xsl:attribute name="force-page-count">even</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>Found landscape table coming before next page-sequence</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
					<!-- <xsl:message>init-static-content for 4th-level pmEntry</xsl:message> -->
					<xsl:call-template name="init-static-content">
						<xsl:with-param name="page-prefix" select="$page-prefix" />
						<xsl:with-param name="page-suffix" select="$page-suffix" />
						<xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr" />
						<xsl:with-param name="pgblk-effect" select="$pgblk-effect" />
					</xsl:call-template>
					<fo:flow flow-name="xsl-region-body">
						<fo:block font-size="0.001pt" color="white">
							<xsl:text>pgblkst</xsl:text>
							<xsl:value-of select="$start-page-number" />
						</fo:block>
						<xsl:if test="not(EFFECT)">
						</xsl:if>
						<xsl:choose>
							<xsl:when test="EFFECT and $documentType !='irm'">
								<fo:block>
									<fo:marker marker-class-name="efftextValue">
										<xsl:value-of select="EFFECT" />
									</fo:marker>
								</fo:block>
							</xsl:when>
							<xsl:otherwise>
								<fo:block>
									<fo:marker marker-class-name="efftextValue">
										<xsl:value-of select="'ALL'" />
									</fo:marker>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>
						<!-- Add marker for the section title in the footer (called "confnbrValue" as in the original ATA FO) -->
						<!-- and the section enumerator (from @confnbr added by the pre-process). -->
			            <fo:block>
			              <fo:marker marker-class-name="confnbrValue">
			                <xsl:apply-templates select="pmEntryTitle" mode="pgblkConf"/>
			                <!-- <xsl:if test="@CONFNBR != '' and @CONFNBR != 'NA'"> -->
			                <xsl:if test="ancestor-or-self::pmEntry/@confnbr">
			                  <xsl:value-of select="concat('-',ancestor-or-self::pmEntry/@confnbr)"/>
			                </xsl:if>
			              </fo:marker>
						</fo:block>
	
						<!-- The block for this level (4th: page-block) -->
						<fo:block id="{@id}"><!--  space-before.optimum="6pt" space-after.optimum="6pt" text-align="left"  -->

							<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
								<xsl:call-template name="cbStart" />
							</xsl:if>

							<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
							<xsl:call-template name="save-revdate" />
						
							<!-- Add empty blocks for link destinations for the Chapter, Section, and Unit levels -->
							<!-- (If it's the first one in the applicable level) -->
							<!-- NOTE: May want to just make links to the first page-block in a section rather than reproducing the chapter/section ids... -->
							<!-- Only applies to the first 4th level pmEntry -->
							<xsl:if test="not(preceding-sibling::pmEntry)">
							  <!-- Add the Unit level (3rd) id if this is the first 4th-level pmEntry -->
							  <fo:block id="{../@id}"/>
							  
							  <!-- Add the Section level (2nd) id if we're also in the first Unit level pmEntry -->
							  <xsl:if test="not(parent::pmEntry/preceding-sibling::pmEntry)">
								<fo:block id="{../../@id}"/>
								
								<!-- Add the Chapter level (1st) id if we're also in the first Chapter level pmEntry -->
								<xsl:if test="not(parent::pmEntry/parent::pmEntry/preceding-sibling::pmEntry)">
								  <fo:block id="{../../../@id}"/>
								</xsl:if>
							  </xsl:if>
							</xsl:if>
						
							<xsl:apply-templates />

							<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
								<xsl:call-template name="cbEnd" />
							</xsl:if>

						</fo:block>
					</fo:flow>
				  </fo:page-sequence>
			</xsl:when>
			
			<xsl:when test="count(ancestor::pmEntry)=4">
	        	<xsl:comment>Block for 5th level pmEntry</xsl:comment>
				<fo:block space-before.optimum="6pt" space-after.optimum="6pt" text-align="left" id="{@id}">
					<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
						<xsl:call-template name="cbStart" />
					</xsl:if>

					<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
					<xsl:call-template name="save-revdate" />
					<xsl:apply-templates />

					<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
						<xsl:call-template name="cbEnd" />
					</xsl:if>

				</fo:block>
			</xsl:when>
			
			<xsl:otherwise>
	        	<xsl:comment>Block for 6th (or later) level pmEntry (but shouldn't happen in 5-level EM structure...)</xsl:comment>
			
				<fo:block space-before.optimum="6pt" space-after.optimum="6pt" text-align="left" id="{@id}">
					<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
					<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
						<xsl:call-template name="cbStart" />
					</xsl:if>

					<xsl:call-template name="save-revdate" />
					<fo:inline color="red">WARNING: 6th level pmEntry found in source XML</fo:inline>
					<xsl:apply-templates />
					
					<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
						<xsl:call-template name="cbEnd" />
					</xsl:if>

				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="pmEntryTitle" mode="pgblkConf">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- dmodule: make a block with an id to link to for dmRefs -->
	<xsl:template match="dmodule">
		<fo:block id="{@id}">
			<!-- Output DM code if print-variant is 'dmc' -->
			<xsl:if test="/pm/@print-variant='dmc'">
				<fo:block font-size="8pt" font-style="italic" space-before="6pt" space-after="5pt" keep-with-next.within-page="always">
					<xsl:call-template name="build-dmCode-refId">
						<xsl:with-param name="dmCode" select="identAndStatusSection/dmAddress/dmIdent/dmCode"/>
					</xsl:call-template>
					<xsl:text> (</xsl:text><xsl:value-of select="identAndStatusSection/dmAddress/dmAddressItems/issueDate/@year"/>
					<xsl:text>-</xsl:text><xsl:value-of select="identAndStatusSection/dmAddress/dmAddressItems/issueDate/@month"/>
					<xsl:text>-</xsl:text><xsl:value-of select="identAndStatusSection/dmAddress/dmAddressItems/issueDate/@day"/>
					<xsl:text>)</xsl:text>
				</fo:block>
			</xsl:if>
			<xsl:apply-templates />
			<!-- Output DM code if print-variant is 'dmc' -->
			<xsl:if test="/pm/@print-variant='dmc'">
				<fo:block font-size="8pt" font-style="italic" space-before="12pt" space-after="18pt">
					<!-- [From Styler] If a landscape table was the last thing in the dmodule, don't keep the EndOfDataModule statement with it (it pulls apart the table). -->
					<xsl:if test="not(content/descendant::*[count(ancestor::dmodule/content/descendant::*)]/ancestor::table[@orient='land'])">
						<xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
					</xsl:if>
					<xsl:text>End of </xsl:text>
					<xsl:call-template name="build-dmCode-refId">
						<xsl:with-param name="dmCode" select="identAndStatusSection/dmAddress/dmIdent/dmCode"/>
					</xsl:call-template>
				</fo:block>
			</xsl:if>
		</fo:block>
	</xsl:template>

	<!-- For now, just process the foldout element. May handle with context of children later, or do something else here... -->
	<xsl:template match="foldout">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- "Containers" needing no specific style themselves, just process contents: -->
	<xsl:template match="dmContent | content | procedure | preliminaryRqmts | description
		  	 | externalPubRef | externalPubRefIdent | supportEquipDescrGroup | pmTitle | inlineSignificantData ">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Other containers sensitive to added whitespace (like a newline between acronymTerm and acronymDefinition), and shouldn't -->
	<!-- have regular text nodes within them. Just acronym for now... probably need to add more later. -->
	<xsl:template match="acronym">
		<xsl:apply-templates select="*"/><!-- Use "*" to skip nested text nodes (avoiding whitespace nodes due to non-schema-aware processing)-->
	</xsl:template>
	
	<!-- Suppress these elements (don't process content) -->
	<xsl:template match="identAndStatusSection | acronymDefinition | reqCondGroup
	 | warningsAndCautionsRef | dmRefIdent | reqSupportEquips | reqSupplies | reqSpares | reqSafety | referencedApplicGroup"/>

	<!-- Subtask is added by the preprocessor for some 3-level documents. It appears before the step in question. -->
	<xsl:template match="subtask">
		<fo:block space-after="10pt" space-before="10pt">
			<xsl:text>SUBTASK </xsl:text><xsl:value-of select="@number"/>
		</fo:block>
	</xsl:template>
	
	<!-- No special IPL element in S1000D (but leave for future reference for now)
	<xsl:template match="IPL">
		<xsl:message>
			<xsl:text>IN IPL #</xsl:text>
			<xsl:value-of select="position()" />
		</xsl:message>
		<xsl:choose>
			<xsl:when
				test="ISEMPTY and ($documentType = 'irm' or $documentType = 'orim' or $documentType = 'ohm')">
				<xsl:message>
					Suppress ISEMPTY IPL in IRM
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<fo:page-sequence master-reference="Body"
					font-family="Arial" font-size="10pt" initial-page-number="10001">
					[!++ Added Check for following Landscape Tables Because of the CDATA 
						hack, it can through off the page numbers. If a Landscape table is detected 
						as the next node that creates a page-sequence, the no force-page-count will 
						be added For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed ++]
					<xsl:choose>
						<xsl:when
							test="not(*[1]/following::*[name()='IPL' or name()='PGBLK' or (name()='TABLE' and (@ORIENT='land' or @TABSTYLE='hl'))][1]/(name()='TABLE' and @ORIENT='land'))">
							<xsl:message>
								Found no landscape tables coming before next page-sequence
							</xsl:message>
							<xsl:attribute name="force-page-count">even</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>
								Found landscape table coming before next page-sequence
							</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:call-template name="init-static-content" />
					<fo:flow flow-name="xsl-region-body">
						<xsl:call-template name="save-revdate" />
						<fo:block font-size="0.001pt" color="white">
							<xsl:text>pgblkst</xsl:text>
							<xsl:value-of select="'10001'" />
						</fo:block>
						<xsl:if test="not(EFFECT)">
							<fo:block>
								<fo:marker marker-class-name="efftextValue">
									<xsl:value-of select="'ALL'" />
								</fo:marker>
							</fo:block>
						</xsl:if>
						<fo:block>
							<xsl:attribute name="id">
                <xsl:value-of select="@KEY" />
              </xsl:attribute>
							<xsl:choose>
								<xsl:when test="ISEMPTY">
									<fo:block text-align="center" font-weight="bold"
										font-size="12pt" padding-after="6pt">
										<xsl:call-template name="pgblk-title">
											<xsl:with-param name="pgblknbr" select="@PGBLKNBR" />
										</xsl:call-template>
									</fo:block>
									<fo:list-block font-size="10pt"
										provisional-distance-between-starts="24pt" space-before=".1in"
										space-after=".1in" keep-with-next.within-page="always">
										<xsl:call-template name="save-revdate" />
										<fo:list-item>
											<fo:list-item-label end-indent="label-end()">
												<fo:block>
													<xsl:number value="1" format="1." />
												</fo:block>
											</fo:list-item-label>
											<fo:list-item-body start-indent="body-start()">
												<fo:block>
													<xsl:text>Not Applicable</xsl:text>
												</fo:block>
											</fo:list-item-body>
										</fo:list-item>
									</fo:list-block>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="IPLINTRO/TASK|EFFECT|CHGDESC|TITLE" />
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:flow>
				</fo:page-sequence>
				<xsl:apply-templates select="IPLINTRO/VENDLIST" />
				<xsl:apply-templates select="DPLIST" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	-->

	<xsl:template match="noConds">
		<xsl:choose>
			<xsl:when test="parent::recCondGroup/parent::closeRqmts">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:text>TODO: Add "No conditions" row</xsl:text>
					<xsl:apply-templates />
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  <!-- Over-ride "get-atacode" from stdPages.xsl to include only EIPC-specific things -->
  <!-- (the original still has mainly old ATA code anyway). -->
  <xsl:template name="get-atacode">
    <xsl:param name="suppressAtacode" select="0"/>
    <xsl:param name="isChapterToc" select="0"/>
    <xsl:param name="isChapterLep" select="0"/>
    <!-- <xsl:message>get-atacode: context: <xsl:value-of select="name()"/></xsl:message> -->
    <xsl:choose>
      <!-- Suppress is indicated explicitly -->
      <xsl:when test="1 = number($suppressAtacode)">
        <xsl:message>Suppressing ATA code</xsl:message>
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      <!-- For front-matter when there's only a top-level pmEntry-->
      <xsl:when test="count(ancestor-or-self::pmEntry)=1 and ancestor-or-self::pmEntry/@authorityDocument">
        <xsl:choose>
        	<xsl:when test="number($isChapterToc) = 1">
        	  <!-- Use only the first two digits of the ATA code (the Chapter part) in case the full number is specified. -->
        	  <xsl:value-of select="substring(ancestor-or-self::pmEntry/@authorityDocument,1,2)"/>
	          <xsl:text>-TOC</xsl:text>
        	</xsl:when>
        	<xsl:when test="number($isChapterLep) = 1">
        	  <xsl:value-of select="substring(ancestor-or-self::pmEntry/@authorityDocument,1,2)"/>
	          <xsl:text>-EFF</xsl:text>
        	</xsl:when>
        	<xsl:otherwise>
        	  <xsl:value-of select="ancestor-or-self::pmEntry/@authorityDocument"/>
        	</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
	  <xsl:when test="count(ancestor-or-self::pmEntry)=1 and not(ancestor-or-self::pmEntry/@authorityDocument)">
	  	<xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP']"/>
	  </xsl:when>
      <!-- For 5-level EM, use 3rd-level pmEntry authorityDocument -->
      <xsl:when test="$isNewPmc">
      	<!-- 
      	<xsl:message>Getting ATA code for 5-level EM; pmEntry ancestor-of-selfs: <xsl:value-of select="count(ancestor-or-self::pmEntry)"/></xsl:message>
      	<xsl:message>ATA code (ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument): <xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument"/></xsl:message> -->
      	<xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument"/>
      </xsl:when>
      <xsl:otherwise>
      	<!-- For 3-level, the ATA code is at the 2nd level -->
      	<xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
	<xsl:template name="get-revdate">
		<xsl:param name="asText">
			0
		</xsl:param>
		<xsl:param name="intro-toc" />
		<xsl:choose>
			<xsl:when test="name() = 'DPLIST' or name() = 'VENDLIST'">
				<!-- The date as yyyymmdd -->
				<xsl:variable name="revdate">
					<xsl:choose>
						<xsl:when test="ancestor::IPL/@REVDATE = ''">
							<xsl:value-of select="'0'" />
						</xsl:when>
						<xsl:when test="ancestor::IPL/@REVDATE != 0">
							<xsl:value-of select="ancestor::IPL/@REVDATE" />
						</xsl:when>
						<xsl:when test="ancestor::node()/@REVDATE">
							<xsl:for-each select="..">
								<xsl:call-template name="get-revdate">
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- Convert to text if caller requests -->
				<xsl:choose>
					<xsl:when test="1 = number($asText)">
						<xsl:call-template name="convert-date">
							<xsl:with-param name="ata-date">
								<xsl:value-of select="$revdate" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$revdate" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name() = 'TRANSLTR'">
				<xsl:variable name="revdate">
					<xsl:value-of select="/CMM/@REVDATE" />
				</xsl:variable>
				<!-- Convert to text if caller requests -->
				<xsl:choose>
					<xsl:when test="1 = number($asText)">
						<xsl:call-template name="convert-date">
							<xsl:with-param name="ata-date">
								<xsl:value-of select="$revdate" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$revdate" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- The date as yyyymmdd -->
				<xsl:variable name="revdate">
					<!-- Revdate should be pulled from PGBLK only. (Partial Revision rule.) -->
					<xsl:choose>
						<xsl:when test="ancestor-or-self::PGBLK">
							<xsl:value-of select="ancestor-or-self::PGBLK/@REVDATE" />
						</xsl:when>
						<xsl:when test="ancestor-or-self::TRLIST">
							<xsl:value-of select="ancestor-or-self::TRLIST/@REVDATE" />
						</xsl:when>
						<xsl:when test="ancestor-or-self::SBLIST">
							<xsl:value-of select="ancestor-or-self::SBLIST/@REVDATE" />
						</xsl:when>
						<xsl:otherwise>
							<!-- <xsl:value-of select="/CMM/@REVDATE" /> -->
							<xsl:value-of select="concat(/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@year,
                         	/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@month,
                         	/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@day)" />
							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- Convert to text if caller requests -->
				<xsl:choose>
					<xsl:when test="1 = number($asText)">
						<xsl:call-template name="convert-date">
							<xsl:with-param name="ata-date">
								<xsl:value-of select="$revdate" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$revdate" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="get-context">
		<xsl:param name="currentPath" select="''" />
		<xsl:variable name="thisNode">
			<xsl:choose>
				<xsl:when test="$currentPath = ''">
					<xsl:variable name="thisName" select="name()" />
					<xsl:value-of
						select="concat(name(),'[',1 + count(preceding-sibling::*[name() = $thisName]),']')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentPath" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="parentName" select="../name()" />
		<xsl:choose>
			<xsl:when test="parent::*">
				<xsl:for-each select="parent::*">
					<xsl:call-template name="get-context">
						<xsl:with-param name="currentPath">
							<xsl:value-of
								select="concat(name(),'[',1 + count(preceding-sibling::*[name() = $parentName]),']','/',$thisNode)" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$currentPath" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="save-revdate">
		<!-- RS: Added possible over-ride for chapter (for Numerical Index which is output from the first -->
		<!-- IPL section, which would otherwise get the section's chapter number below. But it should -->
		<!-- be set to empty since it is part of the front-matter for LEP generation). -->
		<xsl:param name="chapter" select="'??'"/>
		<xsl:param name="intro-toc" select="0"/>
		<xsl:param name="isChapterToC" select="false()"/>
		
		<xsl:choose>
			
			<!-- placeholder condition.... -->
			<xsl:when test="false()"></xsl:when>
			
			<xsl:otherwise>
		      <!-- RS: Added a new attribute for a chapter counter, since the ATA code (chapter-section-subject) does not -->
		      <!-- reliably represent how the chapters are divided in 3-level EM. In fact there can be many chapters all -->
		      <!-- with exactly the same ATA number. -->
			  <!-- Only applies to 3-level PMC (for now) -->
			  <xsl:if test="not($isNewPmc)">
				<fo:marker marker-class-name="footerChapterCtr">
					<xsl:choose>
						<!-- Don't add chapters for pmEntries before (or including for EIPC) the Introduction -->
						<xsl:when test="ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt58']
						   or ancestor-or-self::pmEntry[last()]/@pmEntryType='pmt58'">
							<!-- Empty -->
						</xsl:when>
						<xsl:otherwise>
							<!-- Not necessary to start at "1", just that an increment reflects a change of chapter -->
							<xsl:value-of select="count(ancestor-or-self::pmEntry[last()]/preceding-sibling::pmEntry)"/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
			  </xsl:if>
				<fo:marker marker-class-name="footerChapter">
					<xsl:if test="$debug">
					  <xsl:message>Outputting chapter marker for pmEntry type: <xsl:value-of select="ancestor-or-self::pmEntry/@pmEntryType"/></xsl:message>
					</xsl:if>
					<!-- <xsl:value-of ancestor-or-self::PGBLK/@CHAPNBR" /> -->
					<xsl:choose>
						<!-- Handle new chapter over-ride -->
						<xsl:when test="$chapter != '??'">
							<xsl:value-of select="$chapter" />
						</xsl:when>
						<xsl:when test="$intro-toc = 1">
							<!-- Empty -->
						</xsl:when>
						<!-- Don't add chapters for pmEntries before (or including for EIPC) the Introduction -->
						<xsl:when test="ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt58']
						   or ancestor-or-self::pmEntry[last()]/@pmEntryType='pmt58'">
							<!-- Empty -->
						</xsl:when>
						<!-- LEP pmEntry (where ToC is output). Also for EIPC, the Service Bulletin List (pmt55) and Vendor Code List (pmt90) -->
						<!-- come after the Introduction -->
						<xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt56'
						   or ancestor-or-self::pmEntry/@pmEntryType='pmt55'
						   or ancestor-or-self::pmEntry/@pmEntryType='pmt90'">
							<!-- Empty -->
						</xsl:when>
						<!-- CMM used the same chapter number from the document's @pubCodingScheme='CMP'.
						<xsl:when test="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode/@pubCodingScheme='CMP'">
							<xsl:value-of select="substring(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'],1,2)" />
						</xsl:when> -->
						<!-- 5-level EM uses the attribute authorityDocument on the top-level pmEntry -->
						<xsl:when test="$isNewPmc and ancestor-or-self::pmEntry[not(parent::pmEntry)]/@authorityDocument">
							<xsl:value-of select="ancestor-or-self::pmEntry[not(parent::pmEntry)]/@authorityDocument"/>
						</xsl:when>
						<!-- 3-level EM can use the first two digits of the authorityDocument on the top-level pmEntry -->
						<xsl:when test="ancestor-or-self::pmEntry[not(parent::pmEntry)]/@authorityDocument">
							<xsl:value-of select="substring(ancestor-or-self::pmEntry[not(parent::pmEntry)]/@authorityDocument,1,2)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'00'" /><!-- Use a fake value for now if not specified. -->
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
				<fo:marker marker-class-name="footerSection">
					<xsl:choose>
						<xsl:when test="$isNewPmc">
							<!-- Don't output the section code for Chapter ToCs in 5-level, since it is used as a signal for -->
							<!-- 3-level LEP to use the section numbers in addition to the chapter number for calculating the -->
							<!-- extent the LEP covers. -->
							<xsl:if test="not($isChapterToC)">
								<!-- Use the 2nd part of the ATA code in the third-level pmEntry (for 5-level EM)-->
								<xsl:value-of select="substring(ancestor::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument,4,2)" />
							</xsl:if>
						</xsl:when>
						<!-- Use the 2nd part of the ATA code in the second-level pmEntry (for 3-level EM)-->
						<!-- UPDATE: If there is only one pmEntry (such as is the case for the section ToC pages), -->
						<!-- then use the top-level pmEntry. -->
						<xsl:when test="count(ancestor-or-self::pmEntry)=1">
							<xsl:value-of select="substring(ancestor-or-self::pmEntry/@authorityDocument,4,2)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring(ancestor-or-self::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument,4,2)" />
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
				<fo:marker marker-class-name="footerSubject">
					<xsl:choose>
						<xsl:when test="$isNewPmc">
							<!-- Use the 3rd part of the ATA code in the third-level pmEntry (for 5-level EM)-->
							<xsl:value-of select="substring(ancestor::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument,7,2)" />
						</xsl:when>
						<xsl:otherwise>
							<!-- Use the 3rd part of the ATA code in the second-level pmEntry (for 3-level EM)-->
							<xsl:value-of select="substring(ancestor-or-self::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument,7,2)" />
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
				<fo:marker marker-class-name="footerPgblk">
					<!--<xsl:value-of select="ancestor-or-self::PGBLK/@PGBLKNBR" />-->
					<!-- RS: Set the page block based on the startat attribute -->
					<!-- <xsl:message>startat: <xsl:value-of select="ancestor-or-self::pmEntry[@startat]/@startat"/></xsl:message> -->
					<xsl:choose>
						<!-- Don't add pgblk for special chapter over-rides (may need another parameter if more control of this is required) -->
						<xsl:when test="$chapter != '??'">
							<!-- Empty -->
						</xsl:when>
						<!-- Don't add pgblk for pmEntries before the Introduction -->
						<xsl:when test="ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt58']">
							<!-- Empty -->
						</xsl:when>
						<!-- LEP pmEntry (where ToC is output) -->
						<xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt56'">
							<!-- Empty -->
						</xsl:when>
						<!--  Introduction uses a pgblk of 0 in the original CMM FO -->
						<xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt58'">
							<xsl:value-of select="'0'" />
						</xsl:when>
						<xsl:when test="ancestor-or-self::pmEntry[@startat][1]/@startat='1'">
							<xsl:value-of select="'1'" />
						</xsl:when>
						<xsl:when test="self::pmEntry and not(parent::pmEntry)">
							<xsl:value-of select="'1'" />
						</xsl:when>
						<xsl:when test="number(ancestor-or-self::pmEntry[@startat][1]/@startat) &gt; 1000">
							<xsl:value-of select="ancestor-or-self::pmEntry[@startat][1]/@startat - 1" />
						</xsl:when>
					</xsl:choose>
				</fo:marker>
				<fo:marker marker-class-name="footerRevdate">
					<!-- Go up through the hierarchy until a non-zero revdate is found -->
		            <xsl:call-template name="get-revdate">
		              <xsl:with-param name="intro-toc" select="$intro-toc"/>
		            </xsl:call-template>
				</fo:marker>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="check-rev-start">
		<xsl:if
			test="preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']">
			<xsl:call-template name="cbStart" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="check-rev-end">
		<xsl:if
			test="following-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '/_rev']">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
	</xsl:template>


	<!-- Change bar start -->
	<xsl:template name="cbStart">
		<rx:change-bar-begin change-bar-class="CB"
			change-bar-placement="start" change-bar-style="solid"
			change-bar-color="black" change-bar-width="6pt" change-bar-offset=".33in" />
		<fo:block height="0pt" width="0pt" max-height="0pt"
			max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">
			<xsl:text>__revst__</xsl:text>
		</fo:block>
		<xsl:if test="boolean(number($REVBAR_DEBUG))">
			<xsl:message>
				<xsl:text>cbStart Context: </xsl:text>
				<xsl:call-template name="get-context" />
			</xsl:message>
		</xsl:if>
	</xsl:template>

	<!-- Change bar end -->
	<xsl:template name="cbEnd">
		<fo:block height="0pt" width="0pt" max-height="0pt"
			max-width="0pt" font-size="0pt" line-height="0pt" keep-with-previous="always">
			<xsl:text>__revend__</xsl:text>
		</fo:block>
		<rx:change-bar-end change-bar-class="CB" />
		<xsl:if test="boolean(number($REVBAR_DEBUG))">
			<xsl:message>
				<xsl:text>cbEnd Context:  </xsl:text>
				<xsl:call-template name="get-context" />
			</xsl:message>
		</xsl:if>
	</xsl:template>

	<xsl:template match="processing-instruction()">
		<xsl:variable name="v_pi_name">
			<xsl:value-of select="." />
		</xsl:variable>
		<!-- <xsl:message>Matched PI; name: <xsl:value-of select="name()"/>; value: <xsl:value-of select="."/></xsl:message> -->
		<xsl:choose>
			<!-- Omnimark pre-process changes <?Pub _newpage?> to <?pagebreak?> -->
			<!-- <xsl:when test="name()='Pub' and .='_newpage'"> -->
			<xsl:when test="name()='pagebreak'">
				<!-- <xsl:message>Found pagebreak Processing Instruction</xsl:message> -->
				<fo:block break-before="page"/>
			</xsl:when>
			<!-- Sometimes Omnimark doesn't work... if there is a linebreak in the PI for example... -->
			<!-- UPDATE: Now it should be ok, so this is not needed. -->
			<!-- <xsl:when test="name()='Pub' and string(.)='_newpage'">
				<fo:block break-before="page"/>
			</xsl:when>-->
			<!-- And Omnimark pre-process changes <?Pub _newline?> to <?newline?> -->
			<xsl:when test="name()='newline'">
				<!-- <xsl:message>Found newline Processing Instruction</xsl:message> -->
				<!-- Use Unicode character "line separator" -->
				<!-- <xsl:text>&#x2028;</xsl:text> -->
                  <xsl:choose>
                    <xsl:when test="(parent::pmEntryTitle)">
                    </xsl:when>
                    <xsl:otherwise>
						<fo:block white-space-collapse="false" white-space-treatment="preserve" font-size="0.1pt" line-height="0.1pt">&#xa0;</fo:block>
                    </xsl:otherwise>
                  </xsl:choose>
			</xsl:when>
			<xsl:when test="$v_pi_name='_rev' and ancestor::PARA">
				<rx:change-bar-begin change-bar-class="CB"
					change-bar-placement="start" change-bar-style="solid"
					change-bar-color="black" change-bar-width="6pt" change-bar-offset=".33in" />
				<xsl:if test="boolean(number($REVBAR_DEBUG))">
					<xsl:message>
						<xsl:text>cbStart Context: </xsl:text>
						<xsl:call-template name="get-context" />
					</xsl:message>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$v_pi_name='/_rev' and ancestor::PARA">
				<rx:change-bar-end change-bar-class="CB" />
				<xsl:if test="boolean(number($REVBAR_DEBUG))">
					<xsl:message>
						<xsl:text>cbEnd Context:  </xsl:text>
						<xsl:call-template name="get-context" />
					</xsl:message>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
