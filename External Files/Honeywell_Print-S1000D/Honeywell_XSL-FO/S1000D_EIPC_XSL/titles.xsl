<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">

	<!-- Different title contexts (some others in other modules, such as S1000DLists.xsl) -->
	<!-- Figure and Table titles (at least the numbering) are in cmmMiscFunctions.xsl. -->

	<!-- Special content for after-title page section (settings from Styler) -->
	<xsl:template match="levelledPara/title[ancestor::pmEntry[@pmEntryType='pmt77']]">
		<xsl:choose>
			<xsl:when test="normalize-space(.)='Copyright - notice' or normalize-space(.)='Copyright - Notice'">
				<fo:block break-before="page" text-align="center" font-weight="bold" font-size="13pt"
					space-after="13pt" space-before="10pt" keep-with-next.within-page="always">
					<xsl:apply-templates />
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<!-- Less space above first one -->
					<xsl:when test="not(parent::levelledPara/preceding-sibling::levelledPara)">
						<fo:block text-align="center" font-weight="bold" font-size="13pt"
							space-after="10pt" space-before="6pt" keep-with-next.within-page="always">
							<xsl:apply-templates />
						</fo:block>
					</xsl:when>
					<xsl:otherwise>
						<fo:block text-align="center" font-weight="bold" font-size="13pt"
							space-after="10pt" space-before="10pt" keep-with-next.within-page="always">
							<xsl:apply-templates />
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="levelledPara/title[not(ancestor::pmEntry[@pmEntryType='pmt77'])]">
		<fo:block font-weight="bold" font-size="10pt" space-before="10pt"
			 keep-with-next.within-page="always"> <!-- space-before="{$normalParaSpace}" space-after="{$normalParaSpace}" -->
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
				<xsl:call-template name="cbStart" />
			</xsl:if>
			<xsl:apply-templates />
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>
		</fo:block>
	</xsl:template>

	<!-- RS: This is not used, since levelledPara processes titles by itself -->
	<!-- 
	<xsl:template match="levelledPara/title[not(ancestor::pmEntry[@pmEntryType='pmt77'])]">
		[!++ from FULLSTMT/TITLE below (for front-matter: centered) ++]
		<fo:block text-align="center" font-weight="bold" font-size="11pt"
			space-after="11pt" keep-with-next.within-page="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template> -->

	<!-- Table titles handled in tbl-not-caps.xsl (do nothing) -->
	<xsl:template match="table/title"/>
	<!--<xsl:template match="table/title">
		<fo:block text-align="center" font-weight="bold" font-size="10pt"
			space-before="10pt" space-after="0pt" keep-with-next.within-page="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>-->


	<!-- Figure titles handled separately (see cmmMiscFunctions.xsl) (do nothing) -->
	<xsl:template match="figure/title"/>
	<!-- <xsl:template match="figure/title">
		<fo:block text-align="center" font-weight="bold" font-size="10pt"
			space-before="10pt" space-after="0pt" keep-with-previous.within-page="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template> -->

	<xsl:template match="commonInfoDescrPara/title">
		<!-- TODO: Need add pmEntry short prefix after (see Styler) -->
		<fo:block text-align="center" font-weight="bold" font-size="14pt"
			space-before="12pt" space-after="1em" keep-with-next.within-page="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<!-- Front matter sections: large font, bold, centred (other top-level pmEntryTitles are suppressed)-->
	<xsl:template match="pmEntry/pmEntryTitle[count(ancestor::pmEntry)=1]">
		<xsl:choose>
			<!-- Special case for Proprietary Information title (outdented) -->
			<xsl:when test="parent::pmEntry/@pmEntryType='pmt77'">
				<fo:block font-size="10pt" font-weight="bold" margin-left="-0.25in"><!--  text-transform="uppercase"  space-after="10pt" -->
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="node()">
					<fo:block text-align="center" padding-after="6pt"
						keep-with-next.within-page="always" text-transform="uppercase">
						<xsl:attribute name="font-size">14pt</xsl:attribute>
						<xsl:attribute name="font-weight">bold</xsl:attribute>
						<xsl:apply-templates />
						<!-- S1000D: this is N/A.
						 <xsl:if test="$documentType='irm' and number(ancestor::PGBLK/@CONFNBR) 
							>= 1000 and preceding-sibling::EFFECT"> <xsl:text>, PN&#160;</xsl:text> <xsl:value-of 
							select="preceding-sibling::EFFECT"/> </xsl:if> -->
					</fo:block>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<!-- Second-level pmEntry titles (in EIPC this is the Section title), except in the Introduction. -->
	<xsl:template match="pmEntry/pmEntryTitle[count(ancestor::pmEntry)=2]">
	
	  <xsl:choose>
		<!-- For EIPC, (if not Introduction) they are displayed on the Section title page, centred. But the formatting is controlled by the block -->
		<!-- added in the Section pmEntry. -->
	  	<xsl:when test="not(ancestor::pmEntry[@pmEntryType='pmt58'])">
	  		<xsl:apply-templates/>
	  	</xsl:when>
	  	
	  	<!-- Introduction 2nd-level pmEntryTitle. -->
	  	<xsl:otherwise>
		  <!-- Second-level pmEntry titles are numbered with "1." and the TASK is added (if available) -->
		  <xsl:variable name="pmEntryPosition" select="count(parent::pmEntry/preceding-sibling::pmEntry) + 1"/>
	      <fo:list-block xsl:use-attribute-sets="list.vertical.space"
	        provisional-distance-between-starts="0.5in" space-before="4pt" space-after="8pt" margin-left="0pt"
	         keep-with-next.within-page="always" font-weight="bold">
	        <fo:list-item>
	          <fo:list-item-label end-indent="label-end()">
	            <fo:block>
				  <xsl:number value="$pmEntryPosition" format="1."/>
	            </fo:block>
	          </fo:list-item-label>
	          <fo:list-item-body start-indent="body-start()">
	            <fo:block text-decoration="underline">
					<xsl:apply-templates/>
					<!-- Add the TASK number [Not for 2nd-level pmEntries in EIPC] -->
		            <!-- <fo:inline font-weight="normal" text-decoration="none" >
			          <xsl:text>&#xA0;</xsl:text>
		              <xsl:call-template name="get-mtoss"/>
		            </fo:inline> -->
	            </fo:block>
	          </fo:list-item-body>
	        </fo:list-item>
	      </fo:list-block>
	  	</xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	<!-- Third-level pmEntry titles (in EIPC this is the Unit title). -->
	<xsl:template match="pmEntry/pmEntryTitle[count(ancestor::pmEntry)=3]">
	  <xsl:choose>
		<!-- For EIPC, they are displayed on the Unit title page, centred. But the formatting is controlled by the block -->
		<!-- added in the Unit pmEntry. -->
	  	<xsl:when test="$documentType='eipc'">
	  		<xsl:apply-templates/>
	  	</xsl:when>
	  </xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>
