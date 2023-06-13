<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
	xmlns:xtbl="com.nwalsh.xalan.Table" xmlns:xlink="http://www.w3.org/1999/xlink">

<!-- New module for S1000D that breaks out the figure and graphic logic from the main module. -->

<!-- NOTE: The figure caption and number are generated in cmmMiscFunctions.xsl -->

	<xsl:variable name="debug-figure" select="false()"/>
	
	<!-- symbol: either an inline graphic or centered if it's the only thing in a para. -->
	<xsl:template match="symbol">
		<xsl:choose>
			<!-- From Styler: If there is no text in the parent element (generally a para), then make it block formatted and centred -->
			<!-- <xsl:when test="not(parent::*/text())"> -->
			<xsl:when test="@reproductionWidth='167.64 mm'">
				<fo:block text-align="center" start-indent="0in">
					<fo:external-graphic>
						<xsl:attribute name="src">url('<xsl:value-of
							select="concat($GRAPHICS_DIR, '/', @xlink:href)" />')</xsl:attribute>
					</fo:external-graphic>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>
					<fo:external-graphic>
						<xsl:attribute name="src">url('<xsl:value-of
							select="concat($GRAPHICS_DIR, '/', @xlink:href)" />')</xsl:attribute>
					</fo:external-graphic>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="figure">
		<!-- Variables to test for "ap", "bp", "cp", and "dl" settings based on specific reproduction width and height (for last graphic, to determine whether a page break is necessary) -->
		<xsl:variable name="ap" select="graphic[last()]/@reproductionWidth='167.64 mm' and graphic[last()]/@reproductionHeight='203.2 mm'"/>
		<xsl:variable name="bp" select="graphic[last()]/@reproductionWidth='167.64 mm' and graphic[last()]/@reproductionHeight='97.79 mm'"/>
		<xsl:variable name="cp" select="graphic[last()]/@reproductionWidth='167.64 mm' and graphic[last()]/@reproductionHeight='44.45 mm'"/>
		<xsl:variable name="dl" select="graphic[last()]/@reproductionWidth='190.5 mm' and graphic[last()]/@reproductionHeight='158.75 mm'"/>

		<fo:block id="{@id}">
			<!-- Indent attribute settings based on Styler contexts. Looks like always 0 and centred, but leave contexts here -->
			<!-- for now in case we need refinements. -->
			<xsl:choose>
				<!-- Figures in the Introduction (pmt58). -->
				<xsl:when test="ancestor::pmEntry/@pmEntryType='pmt58'">
					<xsl:attribute name="start-indent" select="'0in'"/>
					<xsl:attribute name="text-align" select="'center'"/>
				</xsl:when>
				<!-- From Styler: "If the width is greater than 150mm, don't use parent indent (avoids full page -->
				<!-- figures being pushed off to the right). May need to add an explicit attribute for this if the -->
				<!-- width setting isn't consistent." -->
				<!-- NOTE: Other contexts also start with 0 indent now anyway. (all of them?) -->
				<!-- <xsl:when test="number(substring(graphic/@reproductionWidth,1,3)) > 150"> NOTE: This causes an error when there's more than one graphic...
					<xsl:attribute name="start-indent" select="'0in'"/>
					<xsl:attribute name="text-align" select="'center'"/>
				</xsl:when> -->
				<!-- Styler "figure everywhere-else" context -->
				<xsl:otherwise>
					<xsl:attribute name="start-indent" select="'0in'"/>
					<xsl:attribute name="text-align" select="'center'"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<!-- From Styler: Figures in the Introduction (pmt58) do not have a whole page for themselves (all others do). -->
				<!-- UPDATE: except if they are "AP" (full page) size. -->
				<xsl:when test="not($ap) and ancestor::pmEntry/@pmEntryType='pmt58'">
					<!-- Nothing for now -->
				</xsl:when>
				<!-- Styler "figure everywhere-else" context: Start a new page -->
				<!-- Also add a page break after. But from Styler there are exceptions for some cases so that two page -->
				<!-- breaks don't occur in a row (e.g., a figure directly follows which adds its own page break). -->
				<!-- Some of these may not be necessary in FO, since having two page breaks in a row may not cause -->
				<!-- problems (e.g., break after this figure, and before a figure directly following). -->
				<!-- No page break after when there's a legend, or in the IPL -->
				<xsl:when test="legend or ancestor::pmEntry[@pmEntryType='pmt75']">
					<!-- <xsl:attribute name="break-before" select="'page'"/> -->
				</xsl:when>
				<xsl:otherwise>
					<!-- debug -->
					<!-- <xsl:if test="contains(title,'Monitor Isometric Drawing')">
						<xsl:message>Checking for page break after; (following::*)[1]/self::pmEntry[count(ancestor::pmEntry) &lt; 3]: <xsl:value-of select="boolean((following::*)[1]/self::pmEntry[count(ancestor::pmEntry) &lt; 3])"/>;  not( (following::*)[1]/self::pmEntry[count(ancestor::pmEntry) = 0] ): <xsl:value-of select="not( (following::*)[1]/self::pmEntry[count(ancestor::pmEntry) = 0] )"/>; ancestor::pmEntry[parent::pmEntry]/following-sibling::*: <xsl:value-of select="boolean(ancestor::pmEntry[parent::pmEntry]/following-sibling::*)"/></xsl:message>
					</xsl:if> -->
					<!-- Conditions from Styler for not adding a page break after: -->
					<!-- "Also don't need a new page if followed by another figure. This was actually incorrectly resetting the page count." -->
					<!-- "Also don't need a new page unless there is following content (another dmRef, or content in parent,
					 grandparent, or great-grandparent). May need to add more ancestors later." -->
					<xsl:if test="not($documentType='acmm') and not($bp or $cp)
					    and not(graphic[last()]/@reproductionWidth='355.6 mm')
					    and not(name(following-sibling::*[1])='figure')
					    and not(name(following-sibling::*[1])='foldout')
						

						and (ancestor::dmContent/following-sibling::*
							or count(following-sibling::*)>0
							or count(../following-sibling::*)>0
							or count(../../following-sibling::*)>0
							or count(../../../following-sibling::*)>0
							or count(../../../../following-sibling::*)>0
							or count(../../../../../following-sibling::*)>0
							or count(../../../../../../following-sibling::*)>0
							or ancestor::pmEntry[parent::pmEntry]/following-sibling::*)">
					  <!-- One more test: if the next following thing is a pmEntry level 1, then it adds a page break, so we don't need to. -->
					  <xsl:if test="not( (following::*)[1]/self::pmEntry[count(ancestor::pmEntry) = 0] )">
					  	<xsl:if test="not( (following::*)[1]/self::table[@orient='land'] )">
							<xsl:attribute name="break-after" select="'page'"/>
						</xsl:if>
					  </xsl:if>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- RS: The graphic breaks the page, so the change bar needs to start at the graphic, not here (which would be the preceding page) -->
			<!-- This might need to be updated, but the page break rules are tricky.
			<xsl:if test="@changeType='add' or @changeType='modify'">
			  <xsl:call-template name="cbStart" />
			</xsl:if>
			-->
			
			<xsl:apply-templates />
			
			<!-- 
			<xsl:if test="@changeType='add' or @changeType='modify'">
			  <xsl:call-template name="cbEnd" />
			</xsl:if>-->
			
			<!-- Turn effectivity back to "ALL" after the figure -->
			<xsl:if test="@applicRefId">
				<fo:block>
					<fo:marker marker-class-name="efftextValue">ALL</fo:marker>
				</fo:block>
			</xsl:if>

		</fo:block>
	</xsl:template>

	<!-- graphic: corresponds to SHEET in ATA -->
	<xsl:template match="graphic">
		<xsl:choose>
			<!-- <xsl:when test="translate(@IMGAREA,$upperCase,$lowerCase) = 'hl'"> -->
			<xsl:when test="@reproductionWidth='355.6 mm'">
				<xsl:call-template name="foldout-sheet" />
			</xsl:when>
			<!-- Landscape figures not used in S1000D; leave for reference -->
			<!-- UPDATE: Now implement landscape figures using specific reproduction width and height -->
			<!-- <xsl:when test="translate(@IMGAREA, $upperCase, $lowerCase) = 'dl'"> -->
			<xsl:when test="@reproductionWidth='190.5 mm' and @reproductionHeight='158.75 mm'">
				<xsl:call-template name="landscape-sheet" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="standard-sheet" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Called with graphic in context -->
	<xsl:template name="getGraphicId">
		<xsl:choose>
			<xsl:when test="@id">
				<xsl:value-of select="@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="parent::figure/@id"/>
				<xsl:text>-</xsl:text>
				<xsl:value-of select="count(preceding-sibling::graphic)+1"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="checkEffectiveText">
		<xsl:if test="ancestor-or-self::*[@applicRefId]">
			<xsl:variable name="applicRefId" select="(ancestor-or-self::*[@applicRefId])[1]/@applicRefId"/>
			<!-- From Styler: I think we can assume the effectivity text will be in the same top-level pmEntry -->
			<xsl:variable name="effectText" select="ancestor::pmEntry[last()]//applic[@id=$applicRefId]/displayText/simplePara"/>
			<xsl:message>Found effective text applicRefId (<xsl:value-of select="$applicRefId"/>); text: <xsl:value-of select="$effectText"/></xsl:message>
			
			<fo:block>
				<fo:marker marker-class-name="efftextValue">
					<xsl:value-of select="$effectText" />
				</fo:marker>
			</fo:block>
		</xsl:if>
	</xsl:template>
	
	<!-- Called with graphic in context -->
	<xsl:template name="standard-sheet">
			<!-- Variables to test for "bp", "cp", and "dl" settings based on specific reproduction width and height -->
			<xsl:variable name="ap" select="@reproductionWidth='167.64 mm' and @reproductionHeight='203.2 mm'"/>
			<xsl:variable name="bp" select="@reproductionWidth='167.64 mm' and @reproductionHeight='97.79 mm'"/>
			<xsl:variable name="cp" select="@reproductionWidth='167.64 mm' and @reproductionHeight='44.45 mm'"/>
			<xsl:variable name="dl" select="@reproductionWidth='190.5 mm' and @reproductionHeight='158.75 mm'"/>
			
			<fo:block text-align="center" padding="0pt" keep-together.within-page="always">
				<xsl:choose>
					<xsl:when test="ancestor::illustratedPartsCatalog and not(preceding-sibling::graphic)">
						<!-- First graphic in an IPL figure: see if we should start on an odd or even page -->
						<xsl:choose>
							<xsl:when test="count(following-sibling::graphic) mod 2 = 0">
								<xsl:attribute name="break-before">even-page</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="break-before">odd-page</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- Exceptions that don't need a page break before, like introduction (pmt58), etc. -->
					<xsl:when test="not($ap) and
						($documentType='acmm' or ancestor::pmEntry/@pmEntryType='pmt58' or $bp or $cp)">
					</xsl:when>
					<!-- Also if following a foldout table, a page break might make an empty page -->
					<xsl:when test="count(preceding-sibling::graphic)=0 and parent::figure/preceding-sibling::*[1][self::foldout[table]]">
					</xsl:when>
					<xsl:when test="count(preceding-sibling::graphic)=0 and parent::figure/preceding-sibling::*[1][name()='table' and @orient='land']">
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="page-break-before">always</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="@id"><!-- @KEY -->
					<xsl:attribute name="id" select="@id"/>
				</xsl:if>
                <!-- UPDATE: If changeMark='0', don't output a change bar -->
				<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')
				  or not(parent::figure/@changeMark='0') and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete')">
					<xsl:call-template name="cbStart" />
					<xsl:comment>Change start for standard-sheet</xsl:comment>
				</xsl:if>
				<!-- RS: Special new marker to handle cases where an ancestor output the change bar, but there's no __revst__ or __revend__ marker -->
				<!-- on this page for the LEP generator to see and assign an asterisk. -->
				<xsl:if test="not(ancestor::proceduralStep/@changeMark='0')
				  and (ancestor::proceduralStep/@changeType='add' or ancestor::proceduralStep/@changeType='modify' or ancestor::proceduralStep/@changeType='delete')">
					<fo:block height="0pt" width="0pt" max-height="0pt"
						max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">
						<xsl:text>__revcont__</xsl:text>
					</fo:block>
				</xsl:if>
				<!-- [ATA]
				<xsl:choose>
					<xsl:when
						test="parent::GRAPHIC[preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']]">
						<xsl:call-template name="cbStart" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="check-rev-start" />
					</xsl:otherwise>
				</xsl:choose> -->
				
				<xsl:call-template name="checkEffectiveText"/>

				<fo:external-graphic>
					<!-- UPDATE: Now adding support for scaling: similar to "AP", "BP", "CP" options in ATA, but -->
					<!-- keyed on specific reproduction width and height settings. -->
					<xsl:choose>
						<!-- Landscape setting (old "DL"): -->
						<xsl:when test="$dl">
							<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
							<xsl:attribute name="content-width">100%</xsl:attribute>
							<xsl:attribute name="height">5.78in</xsl:attribute>
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						<!-- UPADTE: scale only for width for BP and CP -->
						<!-- Half-page setting (old "BP"): -->
						<xsl:when test="$bp">
							<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
							<xsl:attribute name="content-height">100%</xsl:attribute>
							<xsl:attribute name="width">6.78in</xsl:attribute><!-- left margin: 1.1in; right: 0.62in -->
							<!-- <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
							<xsl:attribute name="height">3.85in</xsl:attribute> -->
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						<!-- Quarter page (old "CP") -->
						<xsl:when test="$cp">
							<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
							<xsl:attribute name="content-height">100%</xsl:attribute>
							<xsl:attribute name="width">6.78in</xsl:attribute><!-- left margin: 1.1in; right: 0.62in -->
							<!-- <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
							<xsl:attribute name="height">1.75in</xsl:attribute> -->
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
							<xsl:attribute name="content-height">100%</xsl:attribute>
							<xsl:attribute name="width">6.78in</xsl:attribute><!-- left margin: 1.1in; right: 0.62in -->
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>

					<!-- In S1000D, we have the full name of the graphic 
						file already (like "graphics/img01.tif") <xsl:attribute name="src">url('<xsl:value-of 
						select="concat($GRAPHICS_DIR, '/', ./@GNBR,$GRAPHICS_SUFFIX)" />')</xsl:attribute> -->
					<xsl:attribute name="src">url('<xsl:value-of
						select="concat($GRAPHICS_DIR, '/', @xlink:href)" />')</xsl:attribute>
				</fo:external-graphic>
				
				<xsl:if test="ancestor-or-self::graphic[@applicRefId]">
					<fo:block>
						<fo:marker marker-class-name="efftextValue">ALL</fo:marker>
					</fo:block>
				</xsl:if>

				<!-- CHECK REVEND HERE -->
				<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
					<xsl:call-template name="cbEnd" />
					<xsl:comment>Change end for standard-sheet</xsl:comment>
				</xsl:if>
				
				<!-- Output the figure/graphic title (with sheet number) -->
				<!-- UPDATE: only if the figure has a title. -->
				<xsl:if test="parent::figure/title">
					<xsl:call-template name="figure-caption" />
				</xsl:if>
				
				<!-- For changes to the figure, make the change bar end after the title instead of after the graphic. -->
				<xsl:if test="not(parent::figure/@changeMark='0') and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete')">
					<xsl:call-template name="cbEnd" />
				</xsl:if>
			</fo:block>
			
			<xsl:apply-templates />

		  <!-- Old ATA image scaling for reference:
		  <xsl:if test="@SCALEFIT='1'">
			<fo:block text-align="center" padding="0pt"
				xsl:use-attribute-sets="default.table.cell">
				<xsl:if test="translate(@IMGAREA,$upperCase,$lowerCase) = 'ap'">
					<xsl:attribute name="page-break-before">always</xsl:attribute>
					<xsl:attribute name="page-break-after">always</xsl:attribute>
				</xsl:if>
				<xsl:if test="@id">
					<xsl:attribute name="id">
            <xsl:value-of select="@id" />
          </xsl:attribute>
				</xsl:if>
				<fo:block space-before.optimum="6pt">
					<xsl:text>&#160;</xsl:text>
				</fo:block>
				<xsl:choose>
					<xsl:when
						test="parent::GRAPHIC[preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']]">
						<xsl:call-template name="cbStart" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="check-rev-start" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="parent::GRAPHIC/EFFECT">
						<fo:block>
							<fo:marker marker-class-name="efftextValue">
								<xsl:value-of select="parent::GRAPHIC/EFFECT" />
							</fo:marker>
						</fo:block>
					</xsl:when>
					<xsl:when test="EFFECT">
						<fo:block>
							<fo:marker marker-class-name="efftextValue">
								<xsl:value-of select="EFFECT" />
							</fo:marker>
						</fo:block>
					</xsl:when>
				</xsl:choose>
				<fo:external-graphic text-align="center">
					<xsl:choose>
						[!++ Both are selected, transfer the values, and set scaling non-uniform. 
							Assume that the author knows what they are doing. ++]
						<xsl:when test="@REPROWID and @REPRODEP">
							<xsl:attribute name="content-width">
                <xsl:value-of
								select="translate(./@REPROWID,$upperCase,$lowerCase)" />
              </xsl:attribute>
							<xsl:attribute name="content-height">
                <xsl:value-of
								select="translate(./@REPRODEP,$upperCase,$lowerCase)" />
              </xsl:attribute>
							<xsl:attribute name="scaling">non-uniform</xsl:attribute>
						</xsl:when>
						[!++ width is specified. Scale uniform ++]
						<xsl:when test="@REPROWID">
							<xsl:attribute name="content-width">
                <xsl:value-of
								select="translate(./@REPROWID,$upperCase,$lowerCase)" />
              </xsl:attribute>
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						[!++ depth is specified. Scale uniform ++]
						<xsl:when test="@REPRODEP">
							<xsl:attribute name="content-height">
                <xsl:value-of
								select="translate(./@REPRODEP,$upperCase,$lowerCase)" />
              </xsl:attribute>
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						[!++ Scale based on IMGAREA, if we have made it to here ++]
						<xsl:when test="@IMGAREA = 'ap'">
							<xsl:attribute name="content-height">8in</xsl:attribute>
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						<xsl:when test="@IMGAREA = 'bp'">
							<xsl:attribute name="content-height">3.85in</xsl:attribute>
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
						<xsl:when test="@IMGAREA = 'cp'">
							<xsl:attribute name="content-height">1.75in</xsl:attribute>
							<xsl:attribute name="scaling">uniform</xsl:attribute>
						</xsl:when>
					</xsl:choose>
					<xsl:attribute name="src">
            <xsl:choose>
              <xsl:when test="./@GNBR">url('<xsl:value-of
						select="concat($GRAPHICS_DIR, '/', ./@GNBR,$GRAPHICS_SUFFIX)" />')</xsl:when>
              <xsl:otherwise>
                <xsl:text>Missing-graphic-reference</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
				</fo:external-graphic>
				[!++ CHECK REVEND HERE ++]
				<xsl:choose>
					<xsl:when
						test="parent::GRAPHIC[following-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '/_rev']]">
						<xsl:call-template name="cbEnd" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="check-rev-end" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="figure-caption" />
				<xsl:apply-templates />
			</fo:block>
		</xsl:if> -->
	</xsl:template>

	<!-- This template is called during the normal processing of the instance, 
		and inserts the placeholder pages in the xsl:fo output to maintain correct 
		page numbers -->
	<!-- RS: Called with graphic in context. -->
	<xsl:template name="foldout-sheet">
		<xsl:variable name="graphicId">
			<xsl:call-template name="getGraphicId"/>
		</xsl:variable>
		<!-- The first page of the foldout sequence -->
		<xsl:variable name="replace-page-1" select="concat($graphicId,'-r1')" /><!-- concat(@KEY,'-r1') -->
		<xsl:variable name="replace-page-2" select="concat($graphicId,'-r2')" /><!-- concat(@KEY,'-r2') -->
		<fo:block start-indent="12pt" end-indent="12pt" font-weight="bold" font-size="16pt" border="black solid 2pt"
			padding="12pt" text-align="center">
			<xsl:if test="not(ancestor-or-self::figure/preceding-sibling::*[1]/self::foldout)">
				<xsl:attribute name="break-before">odd-page</xsl:attribute>
			</xsl:if>

			<xsl:attribute name="id">
	        	<xsl:value-of select="$replace-page-1" />
	      	</xsl:attribute>
	      	
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')
			  or not(parent::figure/@changeMark='0') and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>
			 
			<fo:table rx:table-omit-initial-header="true" background="#f0f0f0"
				id="{concat('foldout_key_',$graphicId)}"><!-- {concat('foldout_key_',@KEY)} -->
				<fo:table-column column-width="100%" />
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding-before="2in" padding-after="2in" id="ITG_FOLDOUT">
							<xsl:choose>
								<xsl:when test="exists(GDESC/TABLE)">
									<xsl:attribute name="id">ITG_FOLDOUT_W-GDESC</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="id">ITG_FOLDOUT</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<fo:block>
								<fo:inline>
									1st FOLDOUT FIGURE REPLACEMENT PAGE PLACEHOLDER
									<xsl:value-of select="concat('ID: ',$replace-page-1)" />
								</fo:inline>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			
		</fo:block>

		<!-- CHECK REVEND HERE -->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')
		  or not(parent::figure/@changeMark='0') and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
				
		<!-- The second page used to keep the numbering correct -->
		<fo:block break-before="page"
			start-indent="12pt" end-indent="12pt" font-weight="bold" font-size="16pt"
			border="black solid 2pt" padding="12pt" text-align="center">
			<!-- Don't add a page after if followed by another figure or graphic -->
			<!-- <xsl:message>CHECKING FOLDOUT BREAK AFTER: context: <xsl:value-of select="name(.)"/></xsl:message> -->
			<!-- Conditions from Styler for not adding a page break after: -->
			<!-- "Also don't need a new page if followed by another figure. This was actually incorrectly resetting the page count." -->
			<!-- "Also don't need a new page unless there is following content (another dmRef, or content in parent,
			 grandparent, or great-grandparent). May need to add more ancestors later." -->
			<xsl:if test="not(name(following-sibling::*[1])='graphic')
			  and not(name(parent::figure/following-sibling::*[1])='figure')
			  and not(name(parent::figure/following-sibling::*[1])='foldout')
			  and (ancestor::dmContent/following-sibling::*
			  	 or count(ancestor-or-self::figure/following-sibling::*)>0
			  	 or count(ancestor-or-self::figure/../following-sibling::*)>0
			     or count(ancestor-or-self::figure/../../following-sibling::*)>0
			     or count(ancestor-or-self::figure/../../../following-sibling::*)>0
			     or count(ancestor-or-self::figure/../../../../following-sibling::*)>0
			     or count(ancestor-or-self::figure/../../../../../following-sibling::*)>0
			     or count(ancestor-or-self::figure/../../../../../../following-sibling::*)>0
			     or ancestor::pmEntry[parent::pmEntry]/following-sibling::*)">
				<!-- <xsl:if test="not(*[1]/following-sibling::*[name()='TABLE' and (@ORIENT='land')])"> -->
				<xsl:if test="not( (following::*)[1]/self::table[@orient='land'] )">
					<xsl:attribute name="break-after" select="'page'"/>
				</xsl:if>
			    <!-- <xsl:message>Adding page break after foldout (Figure ID: <xsl:value-of select="ancestor::figure/@id"/>)</xsl:message> -->
			</xsl:if>
			<!-- UPDATE: But for ACMM, we should (almost) always output the break-after this foldout placeholder, since the cases -->
			<!-- that normally make a page break in the following content (figures, new sections, etc.) do not make -->
			<!-- page breaks in ACMM. -->
			<xsl:if test="$documentType='acmm' and
				not(name(parent::figure/following-sibling::*[1])='foldout')">
				<xsl:attribute name="break-after" select="'page'"/>
			</xsl:if>
		  <xsl:attribute name="id">
	        <xsl:value-of select="$replace-page-2" />
	      </xsl:attribute>
			<fo:table rx:table-omit-initial-header="true" background="#f0f0f0">
				<fo:table-column column-width="100%" />
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell padding-before="2in" padding-after="2in"
							id="ITG_NO_COPY">
							<fo:block>
								<fo:inline>
									2nd FOLDOUT FIGURE REPLACEMENT PAGE PLACEHOLDER
									<xsl:value-of select="concat('ID: ',$replace-page-2)" />
								</fo:inline>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
		<!-- <xsl:if test="GDESC/TABLE">
			<fo:block break-after="page">
				<xsl:apply-templates select="GDESC" />
			</fo:block>
		</xsl:if> -->
	</xsl:template>

	<xsl:template name="do-foldouts">
		<xsl:for-each select="//graphic[@reproductionWidth='355.6 mm']"><!-- //SHEET[@IMGAREA ='hl'] -->
			<!-- <xsl:message><xsl:text>Called "do-foldouts" for </xsl:text><xsl:value-of select="name()" /></xsl:message> -->
			<fo:page-sequence master-reference="Foldout"
				font-family="Arial" font-size="10pt" force-page-count="even">
				<fo:static-content flow-name="Foldout_Odd_Page_regionbefore">
					<xsl:call-template name="draft-as-of" />
					<xsl:call-template name="oddPageRegionBeforeStaticContent">
						<xsl:with-param name="isFoldout" select="1" />
					</xsl:call-template>
				</fo:static-content>
				<fo:static-content flow-name="Foldout_Odd_Page_regionafter">
					<xsl:call-template name="effectivity-footer">
						<xsl:with-param name="isFoldout" select="1" />
					</xsl:call-template>
				</fo:static-content>
				<fo:static-content flow-name="Foldout_Even_Page_regionbefore">
					<xsl:call-template name="evenPageRegionBeforeStaticContent">
						<xsl:with-param name="isFoldout" select="1" />
					</xsl:call-template>
					<xsl:call-template name="draft-as-of" />
				</fo:static-content>
				<fo:static-content flow-name="Foldout_Even_Page_regionafter">
					<xsl:call-template name="effectivity-footer">
						<xsl:with-param name="isFoldout" select="1" />
					</xsl:call-template>
					<fo:block />
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<fo:block>
						<xsl:apply-templates select="." mode="foldout" />
					</fo:block>
					<fo:block keep-with-previous.within-page="always"
						id="last-foldout-page" />
				</fo:flow>
			</fo:page-sequence>
		</xsl:for-each>
	</xsl:template>

	<!-- This template is called at the end of the document when foldout sheets 
		are encountered. This is within a page sequence that is 11x17. -->
	<!-- <xsl:template match="SHEET[@IMGAREA ='hl']" mode="foldout"> -->
	<xsl:template match="graphic[@reproductionWidth='355.6 mm']" mode="foldout">
		<xsl:variable name="graphicId">
			<xsl:call-template name="getGraphicId"/>
		</xsl:variable>
	
		<xsl:variable name="foldout-key" select="concat('foldout_key_',$graphicId)" /><!-- concat('foldout_key_',@KEY) -->
		<xsl:variable name="replace-page-1" select="concat($graphicId,'-r1')" /><!-- concat(@KEY,'-r1') -->
		<xsl:variable name="replace-page-2" select="concat($graphicId,'-r2')" /><!-- concat(@KEY,'-r2') -->
		<xsl:variable name="page-number-prefix">
			<xsl:call-template name="page-number-prefix" />
		</xsl:variable>
		<fo:block break-before="odd-page">
			<!-- <xsl:message>Setting marker for foldout page number; prefix: '<xsl:value-of select="$page-number-prefix" />'</xsl:message> -->
			<!-- This marker is used to get the correct page number in the footer -->
			<fo:marker marker-class-name="foldout-page-string">
				<xsl:choose>
					<xsl:when test="$documentType = 'acmm'">
						<fo:inline>
							<fo:page-number-citation ref-id="{$replace-page-1}" />
							<xsl:text>/</xsl:text>
							<fo:page-number-citation ref-id="{$replace-page-2}" />
							<xsl:text>&#160;of&#160;</xsl:text>
							<xsl:value-of select="$front_body_count" />
						</fo:inline>
					</xsl:when>
					<xsl:otherwise>
						<fo:inline>
							<!-- NOTE: Adding the prefix causes the PDF generation to fail with this message: -->
							<!-- ...[22][23][24][59]error: formatting failed: com.renderx.pdflib.PDFWrongElementException: You are already sending stream data -->
							<!-- I think it's in the final Omnimark scripts to rearrange foldout pages that changes the XEP output to be malformed. -->
							<!-- Now fixed in Omnimark -->
							<xsl:value-of select="$page-number-prefix" />
							<!--  test --><!-- <xsl:text>1-</xsl:text> -->
							<fo:page-number-citation ref-id="{$replace-page-1}" />
							<!-- Add section-enum -->
                            <xsl:if test="ancestor-or-self::pmEntry[last()]/@authorityName">
                               <xsl:value-of select="concat('-',ancestor-or-self::pmEntry[last()]/@authorityName)"/>
                            </xsl:if>
							<xsl:text>/</xsl:text>
							<!--  test --><!-- <xsl:text>1-</xsl:text> -->
							<xsl:value-of select="$page-number-prefix" />
							<fo:page-number-citation ref-id="{$replace-page-2}" />
							<!-- Add section-enum -->
                            <xsl:if test="ancestor-or-self::pmEntry[last()]/@authorityName">
                               <xsl:value-of select="concat('-',ancestor-or-self::pmEntry[last()]/@authorityName)"/>
                            </xsl:if>
						</fo:inline>
					</xsl:otherwise>
				</xsl:choose>
			</fo:marker>
			<fo:block keep-together.within-page="always" text-align="left"
				padding="0pt" rx:key="">
				<xsl:if test="ancestor-or-self::FIGURE">
					<xsl:attribute name="text-align" select="'right'" />
					<xsl:attribute name="margin-right" select="'.5in'" />
				</xsl:if>
				<xsl:if test="$graphicId"><!-- @id --><!-- @KEY -->
					<xsl:attribute name="id">
			            <xsl:value-of select="$graphicId" />
			        </xsl:attribute>
				</xsl:if>
				<fo:block space-before.optimum="6pt">
					<xsl:text>&#160;</xsl:text>
				</fo:block>
				
				<!-- CHECK REVST HERE -->
				<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')
				  or not(parent::figure/@changeMark='0') and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete')">
					<xsl:call-template name="cbStart" />
				</xsl:if>
				
				<xsl:choose>
					<xsl:when test="ancestor-or-self::*[@applicRefId]">
						<xsl:call-template name="checkEffectiveText"/>
					</xsl:when>
					<xsl:otherwise>
						<fo:block>
							<!-- Need a default 'All' or the effectivity in the foldout will be 
								blank. -->
							<fo:marker marker-class-name="efftextValue">ALL</fo:marker>
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
				<!-- <fo:external-graphic margin-left="0in">
					<xsl:attribute name="src">url('<xsl:value-of
						select="concat($GRAPHICS_DIR, '/', ./@GNBR,$GRAPHICS_SUFFIX)" />')</xsl:attribute>
				</fo:external-graphic> -->
				<fo:external-graphic margin-left="0in"><!-- In S1000D, we have the full name of the graphic 
						file already (like "graphics/img01.tif")  -->
					<xsl:attribute name="src">url('<xsl:value-of
						select="concat($GRAPHICS_DIR, '/', @xlink:href)" />')</xsl:attribute>
				</fo:external-graphic>
				
				<!-- CHECK REVEND HERE -->
				<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
					<xsl:call-template name="cbEnd" />
				</xsl:if>
				
				<!-- Output the figure/graphic title (with sheet number) -->
				<xsl:choose>
					<xsl:when test="ancestor-or-self::FIGURE">
						<xsl:call-template name="figure-caption">
							<xsl:with-param name="graphic-margin-left" select="'8in'" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="figure-caption">
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:if test="ancestor-or-self::*[@applicRefId]">
					<fo:block>
						<fo:marker marker-class-name="efftextValue">ALL</fo:marker>
					</fo:block>
				</xsl:if>

			</fo:block>
			
			<!-- For changes to the figure, make the change bar end after the title instead of after the graphic. -->
			<xsl:if test="not(parent::figure/@changeMark='0') and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>
				
		</fo:block>
		<fo:block font-size="8pt" margin-top="-.5in"
			margin-left="-.5in" keep-with-previous.within-page="always" id="{$foldout-key}" break-after="page" />
	</xsl:template>

	<xsl:template name="landscape-sheet">
		<fo:block-container break-before="page" reference-orientation="90"><!-- break-after="page" -->
			<xsl:call-template name="standard-sheet" />
		</fo:block-container>
	</xsl:template>

</xsl:stylesheet>
