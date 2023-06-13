<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
	xmlns:xtbl="com.nwalsh.xalan.Table" xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:import href="../shared/unhandled-element.xsl" />
	<xsl:import href="../shared/standardFunctions.xsl" />
	<!-- RS: Use a local customized version of standardVariables -->
	<xsl:import href="standardVariables.xsl" />

	<xsl:include href="../shared/cageInfo.xsl"/>
	<xsl:include href="../shared/rrTable.xsl" />
	<xsl:include href="../shared/regulatory.xsl" />

	<!-- RS: Use a local customized version of stdPages and references (was in ../shared)-->
	<xsl:include href="stdPages.xsl" />
	<xsl:include href="tbl-not-caps.xsl" />
	<xsl:include href="references.xsl" />
	<xsl:include href="cmmToc.xsl" />
	<xsl:include href="cmmMiscFunctions.xsl" />
	<xsl:include href="acmm.xsl" />
	<xsl:include href="cmm-variables.xsl" />
	<xsl:include href="dplist.xsl" />
	<!-- Revised list handling (proceduralSteps, levelledPara) for S1000D -->
	<xsl:include href="S1000DLists.xsl" />
	<xsl:include href="pdfBookmarks.xsl" />
	<xsl:include href="partinfo-table.xsl" />
	<xsl:include href="numIndex.xsl" />
	<xsl:include href="lepTable_CMM.xsl" />
	<xsl:include href="transmittal.xsl" />
	<xsl:include href="para.xsl" />
	<xsl:include href="legend.xsl" />
	<xsl:include href="titles.xsl" />
	<xsl:include href="figure.xsl" />

    <xsl:include href="pdfMetaData_S1000D.xsl"/>

	<xsl:output method="xml" encoding="UTF-8" indent="no" />

	<!-- Set debug to true() to output extra borders and messages for troubleshooting. -->
	<xsl:variable name="debug" select="false()"/>

	<xsl:template match="/">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"><!-- letter-spacing="0.1pt" -->


   			<!-- Sonovision update (2019.07.02)
   			     - PDF metadata now stored in separate module which will be updated during
   			       full build process from CVS to include application version information
   			       in the PDF "subject" field
   			       -->
   			<xsl:call-template name="pdfMetaData"/>
	
			<xsl:call-template name="define-pagesets" />
			<xsl:choose>
				<xsl:when test="boolean(number($UNIT_TEST))">
					<xsl:call-template name="unit-test" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates />
				</xsl:otherwise>
			</xsl:choose>
		</fo:root>
	</xsl:template>

	<xsl:template match="pm">
		<xsl:call-template name="do-pdf-bookmarks" />
		<xsl:call-template name="do-frontmatter" />
		
		<xsl:choose>
			
			<!-- Different pageset handling for ACMM (no breaks between sections, except for IPL). -->
			<xsl:when test="$documentType='acmm'">
				<!-- acmmBody will make a pageset and process all pmEntries except IPL -->
				<xsl:call-template name="acmmBody"/>
				
				<!-- Handle IPL pmEntries the same as regular documents -->
				<xsl:apply-templates select="content/pmEntry[@pmEntryType='pmt75']"/>
			</xsl:when>
			
			<xsl:otherwise>
				<!-- Process all pmEntries except pmt77 (continuation of title pages) which is output in the do-frontmatter template -->
				<xsl:apply-templates select="content/pmEntry[not(@pmEntryType='pmt77')]" />
			</xsl:otherwise>

		</xsl:choose>

		<!-- Special handling for foldout pages (added at the end then placed in post-processing). -->
		<xsl:call-template name="do-foldouts" />
		
	</xsl:template>

	<!-- This template handles the frontmatter portion of the CMM. -->
	<!-- UPDATE: This just outputs the title page(s) and proprietary information (pmEntry pmt77) in its own page sequence. -->
	<xsl:template name="do-frontmatter">
	
		<fo:page-sequence master-reference="Title" font-family="Arial" font-size="10pt" id="toc">
		
			<xsl:if test="not($documentType='acmm')">
				<xsl:attribute name="force-page-count">even</xsl:attribute>
			</xsl:if>
			
			<!-- Output the title page content -->
			<xsl:call-template name="init-title-sequence-static">
				<xsl:with-param name="page-prefix" select="'T-'" />
			</xsl:call-template>
			<fo:flow flow-name="xsl-region-body">
				<fo:block id="cmm_title_page">
					<!-- RS: draft-as-of adds a "Draft as of..." statement to the title page when /CMM[@OVERLAYFORMATSTYLE='draft'] -->
					<!-- Not applicable for S1000D for now, but leave in case we need it later... -->
					<xsl:call-template name="draft-as-of" />
					<xsl:call-template name="selectFirstPageHeader" />
					<xsl:call-template name="part-info-table" />
				</fo:block>
				
				<!-- RS: The legal notice is in its own pmEntry, process it here as part of the title pages -->
				<fo:block page-break-before="always">
					<xsl:apply-templates select="content/pmEntry[@pmEntryType='pmt77']" />
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
		
	</xsl:template>

	<!-- ACMM Needs only one page-sequence for all the "body" sections (before the IPL), since -->
	<!-- there are no page breaks between sections. -->
	<xsl:template name="acmmBody">
		<fo:page-sequence master-reference="Body"
			font-family="Arial" font-size="10pt" initial-page-number="auto">

			<!-- Added Check for following Landscape Tables Because of the CDATA hack, 
				it can through off the page numbers. If a Landscape table is detected as 
				the next node that creates a page-sequence, the no force-page-count will 
				be added For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed -->
			<xsl:choose>
				<xsl:when test="not(comtent/pmEntry[@pmEntryType='pmt75']) and not(.//table[@orient='land']) and not(.//foldout/table)">
					<!--<xsl:message>Found no landscape tables coming before next page-sequence</xsl:message>-->
					<xsl:attribute name="force-page-count">end-on-even</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- <xsl:message>Found landscape table coming before next page-sequence</xsl:message> -->
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="init-static-content">
				<!-- <xsl:with-param name="page-prefix" select="$page-prefix" />
				<xsl:with-param name="page-suffix" select="$page-suffix" />
				<xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr" />
				<xsl:with-param name="pgblk-effect" select="$pgblk-effect" /> -->
			</xsl:call-template>
			
			<fo:flow flow-name="xsl-region-body">
			
				<fo:block font-size="0.001pt" color="white">
					<xsl:text>pgblkst</xsl:text>
					<xsl:value-of select="1" /><!-- This won't be accurate (or needed?) for ACMM... -->
				</fo:block>
				
				<!-- Process all pmEntries within this page-secquence except for transmittal information and IPL. -->
				<xsl:apply-templates select="content/pmEntry[not(@pmEntryType='pmt77' or @pmEntryType='pmt75')]" />
				
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	
	<!-- Top-level pmEntries -->
	<xsl:template match="content/pmEntry">

		<xsl:variable name="start-page-number">
			<xsl:choose>
				<!-- Special case for appendixes: start at 1 -->
				<xsl:when test="@pmEntryType='pmt85'
					and not($documentType='spm' or $documentType='im' or $documentType='sdom' or $documentType='sdim')">
					<xsl:value-of select="'1'"/>
				</xsl:when>
				<xsl:when test="number(@startat)">
					<xsl:value-of select="@startat"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'1'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Appendix Support [not needed in S1000D (for now)]-->
		<xsl:variable name="appendix-prefix">
			<!-- <xsl:if test="number(ancestor-or-self::PGBLK/@PGBLKNBR) >= 17000">
				<xsl:call-template name="calculateCMMAppendixNumber" />
				<xsl:text>-</xsl:text>
			</xsl:if> -->
		</xsl:variable>

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
			  <!-- Special case for appendixes: use 'A', 'B', etc. -->
			  <xsl:when test="@pmEntryType='pmt85'
				and not($documentType='spm' or $documentType='im' or $documentType='sdom' or $documentType='sdim')">
				<xsl:number format="A-" value="count(preceding-sibling::pmEntry[@pmEntryType='pmt85'])+1"/>
			  </xsl:when>
			  <xsl:otherwise>
			  	<xsl:if test="@shortPrefix">
			  		<xsl:value-of select="@shortPrefix"/>
			  	</xsl:if>
			  </xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="page-suffix">
			<xsl:choose>
			  <!-- The page suffix is set in the top-level pmEntry authorityName attribute. -->
		      <xsl:when test="@authorityName">
		      	<xsl:text>-</xsl:text><xsl:value-of select="@authorityName"/>
		      </xsl:when>
				<xsl:when
					test="$documentType='irm' and number(ancestor-or-self::PGBLK[@PGBLKNBR='5000' or @PGBLKNBR='6000']/@CONFNBR) >= 1000 and ancestor-or-self::PGBLK/EFFECT">
					<xsl:text>-</xsl:text>
					<xsl:value-of select="ancestor-or-self::PGBLK/EFFECT" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose>
		</xsl:variable>

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
		
		<xsl:choose>
		
		  <!-- Continuation of title pages: already called in by the front-matter/title page template, so we don't need a new page set here. -->
		  <xsl:when test="@pmEntryType='pmt77'">
			<xsl:apply-templates />
		  </xsl:when>
		  
		  <!-- RS: If it's the LEP pmEntry, output LEP and ToC (from ATA match="MFMATTR") -->
		  <!-- UPDATE: Except for ACMM: these are not output -->
		  <xsl:when test="@pmEntryType='pmt56'">
		  	
		  	<xsl:if test="not($documentType='acmm')">
		  		
		  		<!-- The first pass does not do the LEP (only when LEP_PASS = 0, i.e., "1") -->
		  		<xsl:if test="number($LEP_PASS) = 0">
		  		
		  			<!-- If an ATA code is not specified in the identAndStatusSection, use a fake chapter, as is done  -->
		  			<!-- for the chapter marker in template "save-revdate" below, which adds the markers the LEP data is -->
		  			<!-- generated from. -->
		  			<xsl:variable name="chapter">
			  			<xsl:choose>
							<xsl:when test="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode/@pubCodingScheme='CMP'">
								<xsl:value-of select="substring(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'],1,2)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'00'"/><!-- Use a fake value for now if not specified. -->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:call-template name="detail-lep">
						<xsl:with-param name="frontmatter" select="1" />
						<xsl:with-param name="chapter" select="$chapter"/> <!-- substring(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'],1,2)" -->
					</xsl:call-template>
				</xsl:if>
				
				<!-- Output the Table of contents (and lists of figures and tables) -->
				<xsl:call-template name="cmm-toc" />

			</xsl:if>
		  </xsl:when>
		  
		  <!-- Sometimes there is an empty Diagrams and Schematics section: suppress it. -->
		  <xsl:when test="@pmEntryType='pmt57'">
		  	<!-- do nothing -->
		  </xsl:when>
		  
		  <!-- For ACMM, the Record of Revisions, Service Bulletin List, and Record of Temporary Revisions are not output -->
		  <xsl:when test="$documentType='acmm'
		  	and (@pmEntryType='pmt53' or @pmEntryType='pmt54' or @pmEntryType='pmt55')">
		  	<!-- do nothing -->
		  </xsl:when>
		  
		  <!-- For ACMM, we don't need a new pageset for each section (except for IPL)-->
		  <xsl:when test="$documentType='acmm' and not(@pmEntryType='pmt75')">
		  	<xsl:call-template name="pageBlockBody"/>
		  </xsl:when>
		  
		  <!-- RS: Otherwise output normal page-sequence and content -->
		  <xsl:otherwise>
			<fo:page-sequence master-reference="Body"
				font-family="Arial" font-size="10pt" initial-page-number="{$start-page-number}">
				<xsl:if test="$documentType='acmm'">
					<xsl:attribute name="initial-page-number">auto</xsl:attribute>
				</xsl:if>
				<!-- Added Check for following Landscape Tables Because of the CDATA hack, 
					it can through off the page numbers. If a Landscape table is detected as 
					the next node that creates a page-sequence, the no force-page-count will 
					be added For IPL, PGBLK, or Foldout Tables, force-page-count="even" is needed -->
				<xsl:choose>
					<!-- <xsl:when test="not(*[1]/following::*[name()='IPL' or name()='PGBLK' or (name()='TABLE' and (@ORIENT='land' or @TABSTYLE='hl'))][1]/(name()='TABLE' and @ORIENT='land'))"> -->
					<xsl:when test="@pmEntryType='pmt75'
						or ( not($documentType='acmm') and not(.//table[@orient='land']) and not(.//foldout/table) )">
						<!--<xsl:message>Found no landscape tables coming before next page-sequence</xsl:message>-->
						<xsl:attribute name="force-page-count">end-on-even</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<!-- <xsl:message>Found landscape table coming before next page-sequence</xsl:message> -->
					</xsl:otherwise>
				</xsl:choose>
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
					
			  		<xsl:call-template name="pageBlockBody"/>
			  		
				</fo:flow>
			</fo:page-sequence>
		  </xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Factored out the "body" of the pageset for top-level pmEntries so that ACMM and regular documents use the same -->
	<!-- logic, but ACMM doesn't need a new pageset for each one. -->
	<!-- Top-level pmEntry is in context. -->
	<xsl:template name="pageBlockBody">
	
		<xsl:choose>
			<!-- Will be adding markers for effectivity later (as in EM) -->
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
			<!-- For ACMM, add a page break before the Introduction -->
			<xsl:if test="$documentType='acmm' and @pmEntryType='pmt58'">
				<xsl:attribute name="break-before">page</xsl:attribute>
			</xsl:if>
			
			<!-- RS: Add revdate (and other metadata) for top-level pmEntries (for LEP generation etc.). -->		
			<xsl:call-template name="save-revdate" />
			
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>
			
			<xsl:apply-templates/>
			
			<!-- For Transmittal Information, output the Table of Highlights after. -->
			<!-- It's possible for there to be no changes, so make a condition for that here: omit the table altogether. -->
			<xsl:if test="@pmEntryType='pmt52'
				and count(//reasonForUpdate[@updateHighlight='0'])!=count(//reasonForUpdate)">
		       <xsl:call-template name="highlights_table"/>
		    </xsl:if>

			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>
		    
		</fo:block>

	</xsl:template>
	
	<!-- Nested pmEntry. May need to separate specific levels later... -->
	<xsl:template match="pmEntry/pmEntry">
		<xsl:choose>
			<!-- 3rd-level pmEntry -->
			<xsl:when test="count(ancestor::pmEntry)=2">
				<!-- If it's the first 3rd level pmEntry with an illustratedPartsCatalog, then output the EDI. -->
				<xsl:choose>
					<!-- These tests are from Styler: there is a descendant illustratedPartsCatalog, and there is not one in the preceding pmEntry -->
					<xsl:when test="count(descendant::dmContent/dmodule/content/illustratedPartsCatalog)>0
					  and count(preceding-sibling::pmEntry/dmContent/dmodule/content/illustratedPartsCatalog)=0">
						<xsl:call-template name="edi"/>
						<!-- Start a new page for the Numerical Index -->
					    <fo:block break-before="page" id="{@id}">
							<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
							<xsl:call-template name="save-revdate" />
					    	<xsl:call-template name="build-numerical-index"/>
						</fo:block>
					    <xsl:apply-templates select="descendant::dmContent/dmodule/content/illustratedPartsCatalog"/>
					</xsl:when>
					<xsl:when test="count(descendant::dmContent/dmodule/content/illustratedPartsCatalog)>0">
					    <xsl:apply-templates select="descendant::dmContent/dmodule/content/illustratedPartsCatalog"/>
					</xsl:when>
					<xsl:otherwise>
						<fo:block space-before.optimum="6pt" space-after.optimum="6pt" text-align="left" id="{@id}">
							<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
							<xsl:call-template name="save-revdate" />
							<xsl:apply-templates />
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- 2nd-level pmEntry -->
			<xsl:when test="count(ancestor::pmEntry)=1">
				<fo:block space-before.optimum="6pt" space-after.optimum="6pt" text-align="left" id="{@id}">
					<xsl:choose>
						<!-- From Styler: For IPL, the 3rd and 4th second-level pmEntries are the vendor code list and detailed parts list, and should start on odd pages -->
						<xsl:when test="parent::pmEntry/@pmEntryType='pmt75'
							and (count(preceding-sibling::pmEntry)=2 or count(preceding-sibling::pmEntry)=3)">
							<xsl:attribute name="break-before">page</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
					<xsl:call-template name="save-revdate" />
					
					<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
						<xsl:call-template name="cbStart" />
					</xsl:if>
			
					<xsl:apply-templates />

					<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
						<xsl:call-template name="cbEnd" />
					</xsl:if>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block space-before.optimum="6pt" space-after.optimum="6pt" text-align="left" id="{@id}">
					<!-- RS: Add revdate (and other metadata) for pmEntries (for LEP generation etc.). -->		
					<xsl:call-template name="save-revdate" />
					<xsl:apply-templates />
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
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
		  	 | externalPubRef | externalPubRefIdent | supportEquipDescrGroup | pmTitle | inlineSignificantData">
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Other containers sensitive to added whitespace (like a newline between acronymTerm and acronymDefinition), and shouldn't -->
	<!--  have regular text nodes within them. Just acronym for now... probably need to add more later. -->
	<xsl:template match="acronym">
		<xsl:apply-templates select="*"/><!-- Use "*" to skip nested text nodes (avoiding whitespace nodes due to non-schema-aware processing)-->
	</xsl:template>
	
	<!-- Suppress these elements (don't process content) -->
	<!-- NOTE: "cellfont" is added by Omnimark "fix_pi.xom", and handled in tbl-not-caps.xsl. -->
	<xsl:template match="identAndStatusSection | acronymDefinition | reqCondGroup
	 | warningsAndCautionsRef | dmRefIdent | reqSupportEquips | reqSupplies | reqSpares | reqSafety | cellfont">
	</xsl:template>

	<!-- Hide the dmRef it it's in pmEntry or reqCondDm. -->
	<xsl:template match="pmEntry/dmRef">
	</xsl:template>
	<xsl:template match="reqCondDm/dmRef">
	</xsl:template>

	<xsl:template match="acronymTerm">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>


	<xsl:template match="externalPubCode">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="externalPubTitle">
		<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
	</xsl:template>
	 
	<xsl:template match="addwarning">
		<xsl:variable name="refId" select="@warningRef"/>
		<!-- Warnings and cautions should be referred to through the warningsAndCautionsRef section at the -->
		<!-- beginning of the dmodule, where an identNumber is specified for the warning/caution repositories. -->
		<!-- Previously, we were just using the id directly in the repository; use that still as a fall-back for now -->
		<!-- for backwards compatibility. -->
		<xsl:variable name="warningRef" select="ancestor::content/warningsAndCautionsRef/warningRef[ends-with(@id,$refId)]"/>
		<xsl:variable name="identNumber">
			<!-- ids are made unique in the pre-process by adding a prefix based on the data module, so match on only the last part of the id. -->
			<!-- <xsl:if test="ancestor::content/warningsAndCautionsRef/warningRef[ends-with(@id,$refId)]">
				<xsl:value-of select="ancestor::content/warningsAndCautionsRef/warningRef[ends-with(@id,$refId)]/@warningIdentNumber"/>
			</xsl:if> -->
			<xsl:value-of select="$warningRef/@warningIdentNumber"/>
		</xsl:variable>
		<fo:list-block xsl:use-attribute-sets="list.vertical.space"
		      provisional-distance-between-starts="0.82in" keep-with-next.within-page="1" keep-together.within-page="1">
		     
			<xsl:if test="not($warningRef/@changeMark='0') and 
			  ($warningRef/@changeType='add' or $warningRef/@changeType='modify' or $warningRef/@changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>

		     <!-- Indent if first thing in mainProcedure -->
		     <!-- UPDATE: For CMM at least, it looks like non-first ones need the indent as well. -->
		     <xsl:if test="parent::mainProcedure"><!-- and count(preceding-sibling::proceduralStep)=0 -->
		     	<xsl:attribute name="margin-left">0.5in</xsl:attribute>
		     </xsl:if>
		     <fo:list-item>
		        <fo:list-item-label end-indent="label-end()">
		          <fo:block text-decoration="underline" font-weight="bold">
		          	<xsl:text>WARNING:</xsl:text>
		          </fo:block>
		        </fo:list-item-label>
		        <fo:list-item-body start-indent="body-start()">
		          <fo:block font-weight="bold" text-transform="uppercase">
		            <xsl:choose>
		            	<xsl:when test="$identNumber != ''">
				            <xsl:apply-templates select="/pm/commonRepository/warningRepository/warningSpec/warningAndCautionPara[../warningIdent/@warningIdentNumber=$identNumber]" />
		            	</xsl:when>
		            	<xsl:otherwise>
				          	<!-- From Styler: _ufe:ProceduralStepWarningText -->
				            <xsl:apply-templates select="/pm/commonRepository/warningRepository/warningSpec/warningAndCautionPara[../warningIdent/@id=$refId]" />
		            	</xsl:otherwise>
		            </xsl:choose>
		          </fo:block>
		        </fo:list-item-body>
		      </fo:list-item>
			<xsl:if test="not($warningRef/@changeMark='0') and
			  ($warningRef/@changeType='add' or $warningRef/@changeType='modify' or $warningRef/@changeType='delete')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>

		    </fo:list-block>
	</xsl:template>
	
	<xsl:template match="addcaution">
		<xsl:variable name="refId" select="@cautionRef"/>
		<!-- Warnings and cautions should be referred to through the warningsAndCautionsRef section at the -->
		<!-- beginning of the dmodule, where an identNumber is specified for the warning/caution repositories. -->
		<!-- Previously, we were just using the id directly in the repository; use that still as a fall-back for now -->
		<!-- for backwards compatibility. -->
		<xsl:variable name="cautionRef" select="ancestor::content/warningsAndCautionsRef/cautionRef[ends-with(@id,$refId)]"/>
		<xsl:variable name="identNumber">
			<!-- ids are made unique in the pre-process by adding a prefix based on the data module, so match on only the last part of the id. -->
			<xsl:value-of select="$cautionRef/@cautionIdentNumber"/>
		</xsl:variable>
		
		<fo:list-block xsl:use-attribute-sets="list.vertical.space"
		      provisional-distance-between-starts="0.82in" keep-with-next.within-page="1" keep-together.within-page="1">
		      
			<xsl:if test="not($cautionRef/@changeMark='0') and
			  ($cautionRef/@changeType='add' or $cautionRef/@changeType='modify' or $cautionRef/@changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>

		     <!-- Indent if first thing in mainProcedure -->
		     <!-- UPDATE: For CMM at least, it looks like non-first ones need the indent as well. -->
		     <xsl:if test="parent::mainProcedure"><!-- and count(preceding-sibling::proceduralStep)=0 -->
		     	<xsl:attribute name="margin-left">0.5in</xsl:attribute>
		     </xsl:if>
		     <fo:list-item>
		        <fo:list-item-label end-indent="label-end()">
		          <fo:block>
		          	<fo:inline text-decoration="underline"><xsl:text>CAUTION</xsl:text></fo:inline><xsl:text>:</xsl:text>
		          </fo:block>
		        </fo:list-item-label>
		        <fo:list-item-body start-indent="body-start()">
		          <fo:block text-transform="uppercase">
		            <xsl:choose>
		            	<xsl:when test="$identNumber != ''">
				            <xsl:apply-templates select="/pm/commonRepository/cautionRepository/cautionSpec/warningAndCautionPara[../cautionIdent/@cautionIdentNumber=$identNumber]" />
		            	</xsl:when>
		            	<xsl:otherwise>
				          	<!-- From Styler: _ufe:ProceduralStepWarningText -->
				            <xsl:apply-templates select="/pm/commonRepository/cautionRepository/cautionSpec/warningAndCautionPara[../cautionIdent/@id=$refId]" />
		            	</xsl:otherwise>
		            </xsl:choose>
		          </fo:block>
		        </fo:list-item-body>
		      </fo:list-item>
		      
			  <xsl:if test="not($cautionRef/@changeMark='0') and
			    ($cautionRef/@changeType='add' or $cautionRef/@changeType='modify' or $cautionRef/@changeType='delete')">
				<xsl:call-template name="cbEnd" />
			  </xsl:if>

		    </fo:list-block>
	</xsl:template>
	
	<xsl:template match="warningAndCautionPara">
		<!-- First one can be inline, then make blocks -->
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::warningAndCautionPara)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<fo:block space-before="6pt"><xsl:apply-templates/></fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- warning: copying styler which adds a newline after warning -->
	<!-- UPDATE: That doesn't look good in the sample, so removing the extra blank line. -->
	<!-- NOTE: in EM in S1000D_common.xsl, there is a more detailed implementation for warning/caution. -->
	<xsl:template match="warning | caution">
		<fo:block><xsl:apply-templates/></fo:block>
		<!-- <fo:block>&#160;</fo:block> -->
	</xsl:template>
	
	<xsl:template match="note">
		<fo:block space-before="4pt" space-after="0pt">
		  <xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
		  <xsl:if test="not(.//attentionSequentialList)">
		  	<xsl:attribute name="keep-together.within-page">4</xsl:attribute>
		  </xsl:if>
		  <xsl:if test="parent::proceduralStep and count(preceding-sibling::*) &gt; 0">
			<xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
		  </xsl:if>
		<!-- <xsl:choose>
			[ From Styler: If in top-level procedural step, use 14mm indent ]
			<xsl:when test="parent::proceduralStep[not(ancestor::proceduralStep)]">
				<xsl:attribute name="start-indent" select="'14mm'"/>
			</xsl:when>
			[ Same for levelledPara ]
			<xsl:when test="parent::levelledPara[not(ancestor::levelledPara)]">
				<xsl:attribute name="start-indent" select="'14mm'"/>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose> -->
		
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart"/>
		</xsl:if>

		<xsl:choose>
			<!-- If the first thing in the note is a list and it has more than one item, use "NOTES:" and don't -->
			<!-- start a list block. -->
			<xsl:when test="(*[1][name()='attentionSequentialList'] and count(attentionSequentialList/attentionSequentialListItem) > 1)
			  or (*[1][name()='attentionRandomList'] and count(attentionRandomList/attentionRandomListItem) > 1) ">
		      <fo:block font-weight="bold" space-before="4pt" keep-with-next.within-page="always">
		      	<xsl:text>NOTES:</xsl:text>
		      </fo:block>
		      <xsl:apply-templates />
			</xsl:when>
			<xsl:when test="*[1][name()='attentionSequentialList']
			  or *[1][name()='attentionRandomList']">
		      <fo:block font-weight="bold" space-before="4pt" keep-with-next.within-page="always">
		      	<xsl:text>NOTE:</xsl:text>
		      </fo:block>
	          <xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-distance-between-starts="0.72in">
				  <fo:list-item>
				    <fo:list-item-label end-indent="label-end()">
				      <fo:block font-weight="bold">
				      	<xsl:text>NOTE:</xsl:text>
				      </fo:block>
				    </fo:list-item-label>
				    <fo:list-item-body start-indent="body-start()">
				      <fo:block>
				        <xsl:apply-templates />
				      </fo:block>
				    </fo:list-item-body>
				  </fo:list-item>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd"/>
		</xsl:if>

	  </fo:block>
	</xsl:template>

	<xsl:template match="notePara">
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart"/>
		</xsl:if>
		<xsl:choose>
			<!-- first notePara in note is inline -->
			<xsl:when test="count(preceding-sibling::notePara)=0">
				<fo:inline>
				  <xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<!-- Indent setting from Styler -->
				<fo:block space-before="4pt" space-after="0pt"><!--  start-indent="0.38in" -->
				  <xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<xsl:apply-templates />
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="simplePara">
		<xsl:choose>
			<!-- Make the first simplePara in reasonForUpdate inline (for use in the Table of Highlights) -->
			<xsl:when test="parent::reasonForUpdate and not(preceding-sibling::*)">
				<fo:inline>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block space-before="0pt" space-after="0pt">
					<xsl:apply-templates />
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="supportEquipDescr">
		<!-- TODO: This outputs a row of the Support Equipment table in Styler -->
		<fo:block>
			<!-- <xsl:text>Support Equipment Table row: TODO</xsl:text> -->
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="name">
		<xsl:choose>
			<!-- If in preliminaryRqmts or functionalItemSpec, then hide (output from 
				supportEquipDescr row) -->
			<xsl:when
				test="ancestor::preliminaryRqmts or ancestor::functionalItemSpec">
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- footnoteRef has no functionality yet. -->
	<xsl:template match="footnoteRef">
		<xsl:message>WARNING: No functionality for footnoteRef implemented yet.</xsl:message>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="emphasis">
		<xsl:choose>
			<xsl:when test="@emphasisType='em01'">
				<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:when test="@emphasisType='em02'">
				<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:when test="@emphasisType='em03'">
				<fo:inline text-decoration="underline"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:when test="@emphasisType='em04'">
				<fo:inline text-decoration="overline"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

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
		<xsl:choose>
			<!--  This is not applicable for S1000D, but leave for reference for now: -->
			<xsl:when
				test="name() = 'IPL' or name() = 'DPLIST' or name() = 'VENDLIST'">
				<fo:marker marker-class-name="footerChapter">
					<xsl:value-of select="ancestor-or-self::IPL/@CHAPNBR" />
				</fo:marker>
				<fo:marker marker-class-name="footerSection">
					<xsl:value-of select="ancestor-or-self::IPL/@SECTNBR" />
				</fo:marker>
				<fo:marker marker-class-name="footerSubject">
					<xsl:value-of select="ancestor-or-self::IPL/@SUBJNBR" />
				</fo:marker>
				<fo:marker marker-class-name="footerPgblk">
					<xsl:value-of select="ancestor-or-self::IPL/@PGBLKNBR" />
				</fo:marker>
				<fo:marker marker-class-name="footerRevdate">
					<!-- Go up through the hierarchy until a non-zero revdate is found -->
					<xsl:call-template name="get-revdate" />
				</fo:marker>
			</xsl:when>
			<xsl:otherwise>
				<fo:marker marker-class-name="footerChapter">
					<xsl:if test="$debug">
					  <xsl:message>Outputting chapter marker for pmEntry type: <xsl:value-of select="ancestor-or-self::pmEntry/@pmEntryType"/></xsl:message>
					</xsl:if>
					<!-- <xsl:value-of ancestor-or-self::PGBLK/@CHAPNBR" /> -->
					<xsl:choose>
						<!-- Don't add chapters for pmEntries before the Introduction (or for IM/SDIM/SDOM, the first section, pmt91) -->
					    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
						<xsl:when test="ancestor-or-self::pmEntry[last()][@isFrontmatter='1']
						  or ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt58']
						  ">
						<!-- or ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt91'] -->
							<!-- Empty -->
						</xsl:when>
						<!-- LEP pmEntry (where ToC is output) -->
						<xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt56'">
							<!-- Empty -->
						</xsl:when>
						<xsl:when test="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode/@pubCodingScheme='CMP'">
							<xsl:value-of select="substring(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'],1,2)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'00'" /><!-- Use a fake value for now if not specified. -->
						</xsl:otherwise>
					</xsl:choose>
				</fo:marker>
				<fo:marker marker-class-name="footerSection">
					<xsl:value-of select="ancestor-or-self::PGBLK/@SECTNBR" />
				</fo:marker>
				<fo:marker marker-class-name="footerSubject">
					<xsl:value-of select="ancestor-or-self::PGBLK/@SUBJNBR" />
				</fo:marker>
				<fo:marker marker-class-name="footerPgblk">
					<!--<xsl:value-of select="ancestor-or-self::PGBLK/@PGBLKNBR" />-->
					<!-- RS: Set the page block based on the startat attribute -->
					<!-- <xsl:message>startat: <xsl:value-of select="ancestor-or-self::pmEntry[@startat]/@startat"/></xsl:message> -->
					<xsl:choose>
						<!-- Don't add pgblk for pmEntries before the Introduction -->
					    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
						<xsl:when test="ancestor-or-self::pmEntry[last()][@isFrontmatter='1']
						  or ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt58']
						  ">
						<!-- or ancestor-or-self::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt91'] -->
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
						<xsl:when test="ancestor-or-self::pmEntry[@startat]/@startat='1'">
							<xsl:value-of select="'1'" />
						</xsl:when>
						<xsl:when test="number(ancestor-or-self::pmEntry[@startat]/@startat) &gt; 1000">
							<xsl:value-of select="ancestor-or-self::pmEntry[@startat]/@startat - 1" />
						</xsl:when>
					</xsl:choose>
				</fo:marker>
				<fo:marker marker-class-name="footerRevdate">
					<!-- Go up through the hierarchy until a non-zero revdate is found -->
					<xsl:call-template name="get-revdate" />
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
		<!-- Applying keeps caused problems in the DPL list, keeping too many things together. -->
		<!-- Set "keep" to 0 to disable the keep for the DPL. -->
		<xsl:param name="keep" select="1"/>
		<xsl:variable name="offset" select="if (ancestor-or-self::table[@orient='land']) then '0.09in' else '0.33in'"/>
		<rx:change-bar-begin change-bar-class="CB"
			change-bar-placement="start" change-bar-style="solid"
			change-bar-color="black" change-bar-width="6pt" change-bar-offset="{$offset}" />
		<fo:block height="0pt" width="0pt" max-height="0pt"
			max-width="0pt" font-size="0pt" line-height="0pt"><!--  keep-with-next="always" -->
			<xsl:if test="$keep=1">
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
			</xsl:if>
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
		<xsl:param name="keep" select="1"/>
		<fo:block height="0pt" width="0pt" max-height="0pt"
			max-width="0pt" font-size="0pt" line-height="0pt"><!--  keep-with-previous="always" -->
			<xsl:if test="$keep=1">
				<xsl:attribute name="keep-with-previous">always</xsl:attribute>
			</xsl:if>
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
			<!-- <xsl:when test="name()='Pub' and string(.)='_newpage'">
				<fo:block break-before="page"/>
			</xsl:when> -->
			<!-- And Omnimark pre-process changes <?Pub _newline?> to <?newline?> -->
			<xsl:when test="name()='newline'">
				<!-- <xsl:message>Found newline Processing Instruction</xsl:message> -->
				<!-- Use Unicode character "line separator" -->
				<!-- <xsl:text>&#x2028;</xsl:text> -->
				<fo:block white-space-collapse="false" white-space-treatment="preserve" font-size="0.1pt" line-height="0.1pt">&#xa0;</fo:block>
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

	<xsl:template match="subScript">
		<fo:inline vertical-align="sub" font-size="8pt">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="superScript">
		<fo:inline vertical-align="super" font-size="8pt">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>



<!-- Old ATA elements for reference... remove when mostly finished -->

<!-- 
	<xsl:template match="ABBR">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="ABBRNAME">
		[!++ Suppress expanded abbreviation name ++]
	</xsl:template>

	<xsl:template match="ABBRTERM">
		<xsl:value-of select="." />
	</xsl:template>

	<xsl:template match="ACRO">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="ACRONAME">
		[!++ Omit expanded accronym name ++]
	</xsl:template>

	<xsl:template match="ACROTERM">
		<xsl:value-of select="." />
	</xsl:template>

	<xsl:template match="CHGDESC">
		[!++ Suppressed ++]
	</xsl:template>

	<xsl:template match="CMPNOM">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="CON|STD|TED">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="CONNBR|STDNBR|TOOLNBR">
		<xsl:if test="node()">
			<xsl:apply-templates />
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="CONNAME|STDNAME|TOOLNAME">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="CONDESC|STDDESC|TOOLDESC|CONSRC|STDSRC|TOOLSRC" />

	<xsl:template match="CPYRGHT">
		<fo:block space-before="{$normalParaSpace}" space-after="8pt" text-align="center"
			keep-together.within-page="always">
			<xsl:attribute name="id">
        <xsl:value-of select="concat('cpyrght_',generate-id())" />
      </xsl:attribute>
			<fo:block font-weight="bold" font-size="12pt" space-after="8pt">
				<xsl:value-of select="$g-copyright-title" />
			</fo:block>
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="EQU">
		<fo:block font-weight="bold" text-align="center">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="EFFECT" />

	<xsl:template match="FULLSTMT/TITLE">
		<xsl:if test="ancestor::PROPTARY[not(preceding-sibling::PROPTARY)]">
			<fo:block text-align="left" font-weight="bold" font-size="10pt"
				space-after="11pt" keep-with-next.within-page="always">
				<xsl:text>Proprietary Information</xsl:text>
			</fo:block>
		</xsl:if>
		<fo:block text-align="center" font-weight="bold" font-size="11pt"
			space-after="11pt" keep-with-next.within-page="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="FULLSTMT">
		<fo:block space-before="10pt" space-after="8pt" font-size="10pt">
			<xsl:attribute name="id">
        <xsl:value-of select="concat('fullstmt_',generate-id())" />
      </xsl:attribute>
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="HOLDER">
		[!++ Do nothing ++]
	</xsl:template>

	<xsl:template match="NOTE" name="note">
		<fo:list-block provisional-distance-between-starts=".68in"
			provisional-label-separation=".1in" xsl:use-attribute-sets="list.vertical.space">
			<xsl:attribute name="margin-left">
        <xsl:call-template name="calc-note-indent" />
      </xsl:attribute>
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<fo:inline text-decoration="underline">
							<xsl:text>NOTE</xsl:text>
						</fo:inline>
						<xsl:text>: </xsl:text>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>
						<xsl:apply-templates />
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template>

	<xsl:template match="IPL/ISEMPTY" />

	<xsl:template match="IPL/TITLE">
		<fo:block text-align="center" font-weight="bold" font-size="12pt"
			padding-after="6pt" keep-with-next.within-page="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="IPLINTRO">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="LEGALNTC">
		<xsl:call-template name="whereami" />
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="PARTINFO">
		[!++ Data is pulled from part-info-table template call ++]
	</xsl:template>

	<xsl:template match="PROPTARY">
		<xsl:call-template name="whereami" />
		<fo:block space-before="10pt" space-after="8pt">
			[!++ Commented out if statement that adds page-break. This is causing 
				blank pages in the intro that messes up the LEP. If these page breaks/blank 
				pages are needed, than the LEP calculation will need to be fixed. ++]
			[!++<xsl:if test="not(preceding-sibling::PROPTARY)"> <xsl:attribute name="break-before" 
				select="'even-page'"/> </xsl:if> ++]
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="TABLE/TITLE" mode="table-title">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="TOPIC">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="GENINFO">
		<fo:block space-before="10pt" space-after="8pt">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="GDESC">
		<fo:block space-before.optimum="4mm" space-after.optimum="4mm"
			text-align="left">
			<xsl:apply-templates select="*[not(name()='EFFECT')]" />
		</fo:block>
	</xsl:template>

	<xsl:template match="TXTGRPHC">
		<fo:block padding-before="6pt" padding-after="6pt"
			margin-left=".25in">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="TXTLINE">
		<fo:block>
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
 -->
 
	<xsl:template name="unit-test">
		<!-- Use this if the test requires a page sequence -->
		<xsl:if test="true()">
			<fo:page-sequence master-reference="Body"
				font-family="Arial" font-size="10pt" force-page-count="even"
				initial-page-number="1">
				<xsl:call-template name="init-static-content">
					<xsl:with-param name="page-prefix" select="TEST-" />
				</xsl:call-template>
				<fo:flow flow-name="xsl-region-body">
					<fo:block>
						<xsl:apply-templates select="//table[count(descendant::row) &gt; 1000]" />
					</fo:block>
				</fo:flow>
			</fo:page-sequence>
		</xsl:if>
		<!-- TODO -->
		<xsl:if test="true()">
			<xsl:apply-templates select="/CMM/IPL" />
		</xsl:if>
		<xsl:if test="false()">
			<xsl:call-template name="do-frontmatter" />
			<xsl:apply-templates select="//MFMATR" />
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
