<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

	<!-- The legend will output the content of the definitionList -->
	<xsl:template match="legend/definitionList">
	</xsl:template>

	<!-- legend: output a table based on the nested definitionList. Note that in ATA the figure legend (key) -->
	<!-- is added in a GDESC element, with a specified CALS table. -->	
	<xsl:template match="legend">
	
		<fo:block break-before="page"><!-- block for whole legend -->
			<xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
			
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
				<xsl:call-template name="cbStart" />
			</xsl:if>
		
			<!-- RS: Special new marker to handle cases where an ancestor output the change bar, but there's no __revst__ or __revend__ marker -->
			<!-- on this page for the LEP generator to see and assign an asterisk. -->
			<xsl:if test="not(ancestor::proceduralStep/@changeMark='0') and 
			  (ancestor::proceduralStep/@changeType='add' or ancestor::proceduralStep/@changeType='modify' or ancestor::proceduralStep/@changeType='delete')">
				<fo:block height="0pt" width="0pt" max-height="0pt"
					max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">
					<xsl:text>__revcont__</xsl:text>
				</fo:block>
			</xsl:if>
			
			<xsl:choose>
				<!-- Make sure effectivity is reset to "ALL" (unless in a block that uses effective text) -->
				<xsl:when test="ancestor-or-self::*[@applicRefId]">
					<xsl:call-template name="checkEffectiveText"/>
				</xsl:when>
				<xsl:otherwise>
					<fo:marker marker-class-name="efftextValue">
						<xsl:value-of select="'ALL'" />
					</fo:marker>
				</xsl:otherwise>
			</xsl:choose>
			
			<fo:block space-after="8pt"><!-- block for title of legend -->
				<xsl:text>Key to Figure </xsl:text>
				<xsl:call-template name="calc-figure-number-param">
					<xsl:with-param name="figure" select="parent::figure"/>
				</xsl:call-template>
			</fo:block>
			
			<!-- Table settings from Styler -->
	        <fo:table border-bottom="solid 1pt black" border-top="none" border-left="none"
	        	border-right="none" padding-before="6pt" width="100%">
	          <fo:table-column column-number="1" column-width="0.60in"/>
	          <fo:table-column column-number="2" column-width="0.10in"/>
	          <fo:table-column column-number="3" column-width="proportional-column-width(1)"/>
	          <fo:table-column column-number="4" column-width="0.60in"/>
	          <fo:table-column column-number="5" column-width="0.10in"/>
	          <fo:table-column column-number="6" column-width="proportional-column-width(1)"/>
	          <fo:table-body>
	            <!-- TEST: <fo:table-row>
	              <fo:table-cell padding-after="6pt"><fo:block>test</fo:block></fo:table-cell><fo:table-cell/><fo:table-cell padding-after="6pt"><fo:block>test</fo:block></fo:table-cell>
	              <fo:table-cell padding-after="6pt"><fo:block>test</fo:block></fo:table-cell><fo:table-cell/><fo:table-cell padding-after="6pt"><fo:block>test</fo:block></fo:table-cell>
	            </fo:table-row> -->
	            <xsl:variable name="numRows" select="ceiling(count(definitionList/*[not(self::title)]) div 2)"/>
	            <!-- <xsl:apply-templates select="definitionList/*[not(self::title)]"/> -->
	            <xsl:call-template name="outputDefinitionListRows">
	            	<xsl:with-param name="definitionList" select="definitionList"/>
	            	<xsl:with-param name="numItems" select="count(definitionList/*[not(self::title)])"/>
	            	<xsl:with-param name="firstColumnItems" select="definitionList/definitionListItem[position() &lt;= $numRows]"/>
	            	<xsl:with-param name="numRows" select="$numRows"/>
	            </xsl:call-template>
	            <!-- <xsl:apply-templates select="definitionList/definitionListItem[position() &lt;= $numRows"/> -->
	          </fo:table-body>
	        </fo:table>
	        
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>
          
		</fo:block>
	</xsl:template>
	
	<!-- Output the definitionListRows. -->
	<!-- The first column's items are a parameter, and the second column's items are calculated based -->
	<!-- on the other parameters (mainly the total number of items). -->
	<xsl:template name="outputDefinitionListRows">
		<xsl:param name="definitionList"/>
		<xsl:param name="numItems"/>
		<xsl:param name="firstColumnItems"/>
		<xsl:param name="numRows"/>
		
		<xsl:for-each select="$firstColumnItems">
			<fo:table-row>
				<!-- Output the first column table cells -->
				<xsl:apply-templates/>
				<!-- Output the second column table cells -->
				<xsl:choose>
					<!-- For the last item, output the (non-empty) second column if the number of entries is even. -->
					<xsl:when test="not(position()=last()) or $numItems mod 2 = 0">
						<xsl:variable name="secondColumnItemNum" select="position() + $numRows"/>
						<!-- <xsl:message>Calculating second column for item (position = <xsl:value-of select="position()"/>): 
							<xsl:value-of select="$secondColumnItemNum"/>
						</xsl:message> -->
						<xsl:apply-templates select="$definitionList/definitionListItem[$secondColumnItemNum]/*"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- Last spot is empty for an odd number of items. -->
						<fo:table-cell/><fo:table-cell/><fo:table-cell/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:table-row>
		</xsl:for-each>
	</xsl:template>

<!-- First version for reference:
	<xsl:template match="legend/definitionList/definitionListItem">
		[!++ Output a row for every second definitionListItem ++]
		<xsl:choose>
			<xsl:when test="count(preceding-sibling::definitionListItem) mod 2 = 0">
				<fo:table-row>
					[!++ Output this and the next definitionListItem in the same row. ++]
					<xsl:apply-templates/>
					<xsl:choose>
						<xsl:when test="following-sibling::definitionListItem">
							<xsl:apply-templates select="following-sibling::definitionListItem[1]/*"/>
						</xsl:when>
						<xsl:otherwise>
							[!++ Last spot is empty ++]
							<fo:table-cell/><fo:table-cell/><fo:table-cell/>
						</xsl:otherwise>
					</xsl:choose>
				</fo:table-row>
			</xsl:when>
			<xsl:otherwise>
				[!++ Do nothing for odd ones ++]
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> -->
	
	<xsl:template match="legend/definitionList/definitionListItem/listItemTerm">
		<fo:table-cell padding-after="3pt" text-align="right"><fo:block><xsl:apply-templates/>.</fo:block></fo:table-cell>
		<fo:table-cell/>
	</xsl:template>
	
	<xsl:template match="legend/definitionList/definitionListItem/listItemDefinition">
		<fo:table-cell padding-after="3pt" text-align="left"><xsl:apply-templates/></fo:table-cell>
	</xsl:template>
	
</xsl:stylesheet>
