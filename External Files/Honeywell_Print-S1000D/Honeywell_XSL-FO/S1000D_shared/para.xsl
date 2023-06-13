<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

<!-- Because paras are one of the more complex elements (with lots of different contexts),
use a separate XSLT module. -->

<!-- NOTE: listItem/para is handled in S1000DLists.xsl -->

	<xsl:template match="para">
	
		<!-- Handle change bars -->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
		
		  <!-- Exception for first para in proceduralStep: the change bar is started by the parent procstep. -->
		  <!-- Use a choose structure so we can add other exceptions later. -->
		  <xsl:choose>
		  	<xsl:when test="parent::proceduralStep and count(preceding-sibling::*)=0">
		  		<!--  do nothing -->
		  	</xsl:when>
			<!-- 2020-08-19 Update Start   -->
			<xsl:when test="parent::levelledPara and count(preceding-sibling::*)=0">
			</xsl:when>
			<!-- 2020-08-19 Update End   -->
		  	<xsl:otherwise>
				<xsl:call-template name="cbStart" />
		  	</xsl:otherwise>
		  </xsl:choose>
		</xsl:if>
		
		<!-- [ATA] Now looks for descendent _rev PI's. The blocks used on cbStart/cbEnd 
			introduce breaks in the text.
		<xsl:if test="preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']">
			<xsl:call-template name="cbStart" />
		</xsl:if> -->
		<!-- [ATA] Handle change bars
		<xsl:if test="descendant::processing-instruction() = '_rev'">
			<fo:block height="0pt" width="0pt" max-height="0pt"
				max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">
				<xsl:text>__revst__</xsl:text>
			</fo:block>
		</xsl:if> -->
		<!-- Change bars added above with cbStart template
		  <xsl:if test="@changeType='add' or @changeType='modify'">
			<fo:block height="0pt" width="0pt" max-height="0pt"
				max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">
				<xsl:text>__revst__</xsl:text>
			</fo:block>
		</xsl:if> -->
		
		<xsl:choose>
			<!-- If the para is the only thing in a cell, and it is empty, output a space to make the row have regular height. -->
			<xsl:when test="parent::entry and count(parent::entry/*)=1 and count(*)=0 and not(text())">
				<fo:block><xsl:text>&#160;</xsl:text></fo:block>
			</xsl:when>
			
			<!-- Some contexts treat paras as inline: -->
			<!-- First para in entry -->
			<xsl:when test="parent::entry and count(preceding-sibling::*)=0">
				<fo:inline>
					<xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			
			<!-- First para in footnote -->
			<xsl:when test="parent::footnote and count(preceding-sibling::*)=0">
				<fo:inline>
					<xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			
			<xsl:otherwise>
				<!-- Block formatting -->
				<fo:block> <!--  keep-together.within-page="4"> -->
					<xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<!-- Spacing -->
					<xsl:if test="string-length(.) &lt; 1000
						and not(parent::levelledPara)
						and not(sequentialList or randomList or definitionList)">
						<xsl:attribute name="keep-together.within-page">4</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<!-- para in entry in thead (not first - handled inline above): no space -->
						<xsl:when test="parent::entry/ancestor::thead">
							<xsl:attribute name="space-before">0pt</xsl:attribute>
							<xsl:attribute name="space-after">0pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="parent::entry">
							<!-- 3pt above (from Styler) for not first para in entry (not first handled above) -->
							<xsl:attribute name="space-before">3pt</xsl:attribute>
							<xsl:attribute name="space-after">0pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="parent::listItemDefinition">
							<xsl:attribute name="space-before">0pt</xsl:attribute>
							<xsl:attribute name="space-after">3pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="preceding-sibling::para and ancestor::para">
							<xsl:attribute name="space-before">2pt</xsl:attribute>
						</xsl:when>
						<xsl:when test="preceding-sibling::para">
							<xsl:attribute name="space-before" select="$normalParaSpace"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="space-before" select="$normalParaSpace"/>
						</xsl:otherwise>
					</xsl:choose>
					<!-- For paras directly in description (but not in front-matter), add 0.5in indent. -->
					<xsl:if test="parent::description and not(ancestor::pmEntry[@pmEntryType='pmt52' or @pmEntryType='pmt77' or @pmEntryType='pmt53' or @pmEntryType='pmt54' or @pmEntryType='pmt55'])">
						<xsl:attribute name="space-before" select="$normalParaSpace"/>
						<xsl:attribute name="margin-left">0.5in</xsl:attribute>
					</xsl:if>
					<xsl:if test="ancestor::table[@tabstyle='hl']">
						<xsl:attribute name="id">
							<xsl:value-of select="concat('foldout_table_page_',ancestor::table/@id)" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="ancestor::pmEntry[@pmEntryType='pmt77']">
						<xsl:if test="normalize-space(ancestor::levelledPara/title)='Copyright - notice' or normalize-space(ancestor::levelledPara/title)='Copyright - Notice'">
							<xsl:attribute name="text-align">center</xsl:attribute>
						</xsl:if>
					    <!-- 2nd level levelled paras have simple numbering -->
					    <xsl:if test="parent::levelledPara/parent::levelledPara and not(preceding-sibling::*)">
					      <xsl:number value="count(parent::levelledPara/preceding-sibling::levelledPara)+1" format="1."/><xsl:text> </xsl:text>
					    </xsl:if>
					</xsl:if>
					<!-- Add an nbsp if the para is empty -->
					<!-- RS: Removed to match styler behavior -->
					<!-- <xsl:choose>
						<xsl:when test="not(node())">
							<xsl:text>&#xA0;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates />
						</xsl:otherwise>
					</xsl:choose> -->
					<!-- RS: If there is only a single space in the para, change it to an nbsp to make sure it makes a real block -->
					<xsl:choose>
						<xsl:when test="not(*) and text()=' '">
							<xsl:text>&#xA0;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
		
		
		<!-- [ATA]
		  <xsl:if test="descendant::processing-instruction() = '/_rev'">
			<fo:block height="0pt" width="0pt" max-height="0pt"
				max-width="0pt" font-size="0pt" line-height="0pt"
				keep-with-previous="always">
				<xsl:text>__revend__</xsl:text>
			</fo:block>
		</xsl:if> -->
		<!-- Change bars added below with cbEnd template
		  <xsl:if test="@changeType='add' or @changeType='modify'">
			<fo:block height="0pt" width="0pt" max-height="0pt"
				max-width="0pt" font-size="0pt" line-height="0pt"
				keep-with-previous="always">
				<xsl:text>__revend__</xsl:text>
			</fo:block>
		</xsl:if> -->
		<!-- [ATA]
		  <xsl:if
			test="preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']">
			<xsl:call-template name="cbEnd" />
		</xsl:if> -->
		
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>

	</xsl:template>

</xsl:stylesheet>
