<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

  <!-- *** This template creates the partinfo table for the title page and beyond. called from the top level of the Manual -->
  <xsl:template name="part-info-table">
    <fo:block font-size="20pt" font-weight="bold" margin-left="0.5in" margin-right="0.5in" margin-top="0in"
      space-after.optimum="0.35in" font-family="Arial"  text-align="center"><!--  text-transform="capitalize" [RS: this incorrectly changes "APU" to "Apu"] -->
      <xsl:if test="count(//EXPRTCL) &gt; 1">
        <xsl:attribute name="margin-top">0.2in</xsl:attribute>
      </xsl:if>

      <!-- RS: No regular title in S1000D: Use the document name based on the doctype (/pm/@type) set in standardVariables.xsl -->
      <xsl:value-of select="$g-doc-full-name"/>
      <!-- <xsl:if test="/CMM/IPL and not(/CMM/IPL/ISEMPTY)"> -->
      <!-- Test for the pmEntry with type 'pmt75' (Illustrated Parts List) -->
      <!-- UPDATE: Not used for EIPC (they all have IPL) -->
      <!-- UPDATE: Don't output if there is a "variant title" specified. -->
      
      <xsl:if test="/pm/content/pmEntry/@pmEntryType='pmt75' and not($documentType='eipc')
        and not (/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='variantTitle'])">
        <fo:block text-transform="none">
          <xsl:text>with Illustrated Parts List</xsl:text>
        </fo:block>
      </xsl:if>
      <fo:block space-before="0.2in"><!-- 0.8in -->
        <!-- <xsl:if test="count(//EXPRTCL) &gt; 1">
          <xsl:attribute name="space-before">0.2in</xsl:attribute>
        </xsl:if> -->
        <!-- RS: Why is CMPNOM handled twice here? -->
        <!-- <xsl:apply-templates select="CMPNOM"/> -->
        <xsl:apply-templates select="/pm/identAndStatusSection/pmAddress/pmAddressItems/pmTitle"/>
      </fo:block>
      <fo:block margin-top="0in" text-align="center" text-transform="none">
        <xsl:apply-templates select="/CMM/PARTINFO[1]/CMPNOM[1]"/>
      </fo:block>
    </fo:block>
    <fo:block font-size="18pt">
      <fo:table rx:table-omit-initial-header="true" width="6.75in" table-layout="fixed"><!-- border="0.5pt solid black" -->
	    <xsl:call-template name="part-table-columns"/>
        <!--<fo:table-column column-width="5.75in"/>
        <fo:table-column column-width="1.25in" text-align="right"/>-->
		<!-- RS: This is for continued headers (see table-omit-initial-header above). Not clear why it's done like this though. -->
        <fo:table-header border-bottom="black solid 1pt">
			<xsl:call-template name="part-table-headers"/>
          <!--<fo:table-cell>
            <fo:block>Part Number</fo:block>
          </fo:table-cell>
          <fo:table-cell>
            <fo:block>CAGE</fo:block>
          </fo:table-cell>-->
        </fo:table-header>
        <fo:table-body>
          <fo:table-row border-bottom="black solid 1pt">
			<xsl:call-template name="part-table-headers"/>
            <!--<fo:table-cell>
              <fo:block>Part Number</fo:block>
            </fo:table-cell>
            <fo:table-cell>
              <fo:block>CAGE</fo:block>
            </fo:table-cell>-->
          </fo:table-row>
          <!-- RS: In Styler, the part info table on the cover is output by the UFE FrontCoverPage, which uses APP over-rides
          to read the part details from /pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute -->
          <!-- <xsl:for-each select="PARTINFO">
            <xsl:apply-templates select="MFRPNR"/>
          </xsl:for-each> -->
          <!-- Note: Styler applies deduping logic to the products; we may need to add this too -->
          <xsl:for-each select="/pm/crossRefTable/productCrossRefTable/product">
		    <fo:table-row>
              <!--<xsl:apply-templates select="assign"/>-->
			  <!--<xsl:call-template name="part-table-row">
				<xsl:with-param name="product" select="."/>
			  </xsl:call-template>-->
			    <xsl:variable name="product" select="."/>
				<xsl:choose>
					<!-- If the useForPartsList attribute is not used, assume that all of the productAttribute elements will be used for the part list table. -->
					<!-- For each productAttribute in the applicCrossRefTable, output the product's "assign" value matching the applicPropertyIdent ID -->
					<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']) &gt; 0">
					  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']">
						<xsl:variable name="productId" select="@id"/>
						<fo:table-cell padding-top="4pt" padding-right="45pt">
						  <fo:block hyphenate="true"><!--ID: <xsl:value-of select="@id"/>:-->
							<xsl:value-of select="$product/assign[@applicPropertyIdent=current()/@id]/@applicPropertyValue"/>
						  </fo:block>
						</fo:table-cell>
					  </xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
					  <!-- Use all product attributes -->
					  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute">
						<xsl:variable name="productId" select="@id"/>
						<fo:table-cell padding-top="4pt" padding-right="45pt">
						  <fo:block hyphenate="true"><xsl:value-of select="$product/assign[@applicPropertyIdent=current()/@id]/@applicPropertyValue"/></fo:block>
						</fo:table-cell>
					  </xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>

            </fo:table-row>
          </xsl:for-each>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>

  <!-- Output the table columns based on the applicCrossRefTable entries -->
  <xsl:template name="part-table-columns">
    <xsl:choose>
		<!-- If the useForPartsList attribute is not used, assume that all of the productAttribute elements will be used for the part list table. -->
		<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']) &gt; 0">
		  <xsl:choose>
		    <!-- If there are only two columns, use uneven column widths (smaller second column) -->
		  	<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes'])=2">
				<fo:table-column column-width="proportional-column-width(2)"/>
				<fo:table-column column-width="proportional-column-width(1)"/>
		  	</xsl:when>
		    <!-- If there are three columns, use uneven column widths (smaller third column) -->
		  	<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes'])=3">
				<fo:table-column column-width="proportional-column-width(1.5)"/>
				<fo:table-column column-width="proportional-column-width(2)"/>
				<fo:table-column column-width="proportional-column-width(1)"/>
		  	</xsl:when>
		  	<xsl:otherwise>
			  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']">
				<fo:table-column column-width="proportional-column-width(1)"/>
			  </xsl:for-each>
		  	</xsl:otherwise>
		  </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		  <!-- Use all product attributes -->
		  <xsl:choose>
		    <!-- If there are only two columns, use uneven column widths (smaller second column) -->
		  	<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute)=2">
				<fo:table-column column-width="proportional-column-width(2)"/>
				<fo:table-column column-width="proportional-column-width(1)"/>
		  	</xsl:when>
		    <!-- If there are three columns, use uneven column widths (smaller third column) -->
		  	<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute)=3">
				<fo:table-column column-width="proportional-column-width(1.5)"/>
				<fo:table-column column-width="proportional-column-width(2)"/>
				<fo:table-column column-width="proportional-column-width(1)"/>
		  	</xsl:when>
		  	<xsl:otherwise>
			  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute">
				<fo:table-column column-width="proportional-column-width(1)"/>
			  </xsl:for-each>
		  	</xsl:otherwise>
		  </xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <!-- Output the table header cells based on the applicCrossRefTable entries -->
  <xsl:template name="part-table-headers">
    <xsl:choose>
		<!-- If the useForPartsList attribute is not used, assume that all of the productAttribute elements will be used for the part list table. -->
		<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']) &gt; 0">
		  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']">
			<fo:table-cell padding-right="25pt">
			  <fo:block font-weight="bold"><!--  wrap-option="wrap" --><xsl:value-of select="name"/></fo:block>
			</fo:table-cell>
		  </xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
		  <!-- Use all product attributes -->
		  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute">
			<fo:table-cell padding-right="25pt">
			  <fo:block font-weight="bold"><xsl:value-of select="name"/></fo:block>
			</fo:table-cell>
		  </xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <!-- Output the table row for a product based on the applicCrossRefTable entries -->
  <xsl:template name="part-table-row">
	<xsl:param name="product"/>
    <xsl:choose>
		<!-- If the useForPartsList attribute is not used, assume that all of the productAttribute elements will be used for the part list table. -->
		<!-- For each productAttribute in the applicCrossRefTable, output the product's "assign" value matching the applicPropertyIdent ID -->
		<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']) &gt; 0">
		  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']">
			<fo:table-cell padding-top="6pt" padding-right="10pt">
			  <fo:block>IDx: <xsl:value-of select="@id"/>: <xsl:value-of select="$product/assign[@applicPropertyIdent=@id]/@applicPropertyValue"/></fo:block>
			</fo:table-cell>
		  </xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
		  <!-- Use all product attributes -->
		  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute">
			<fo:table-cell padding-top="6pt" padding-right="10pt">
			  <fo:block>IDy: <xsl:value-of select="@id"/>: <xsl:value-of select="$product/assign[@applicPropertyIdent=@id]/@applicPropertyValue"/></fo:block>
			</fo:table-cell>
		  </xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>

  
  
  <xsl:template match="productCrossRefTable/product/assign">
  	<!-- Now get the entries based on the applicCrossRefTable -->
    <xsl:choose>
		<!-- If the useForPartsList attribute is not used, assume that all of the productAttribute elements will be used for the part list table. -->
		<xsl:when test="count(/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']) &gt; 0">
		  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList='yes']">
			<fo:table-cell padding-top="6pt" padding-right="10pt">
			  <fo:block><xsl:value-of select="name"/></fo:block>
			</fo:table-cell>
		  </xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
		  <!-- Use all product attributes -->
		  <xsl:for-each select="/pm/crossRefTable/applicCrossRefTable/productAttributeList/productAttribute">
			<fo:table-cell>
			  <fo:block><xsl:value-of select="name"/></fo:block>
			</fo:table-cell>
		  </xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
	
	<xsl:choose>
  	<xsl:when test="@applicPropertyIdent='PN'">
      <fo:table-cell padding-top="6pt" padding-right="10pt">
        <fo:block>
          <xsl:value-of select="@applicPropertyValue"/>
        </fo:block>
      </fo:table-cell>
  	</xsl:when>
  	<xsl:when test="@applicPropertyIdent='cage'">
      <fo:table-cell padding-top="6pt" padding-right="10pt">
        <fo:block>
          <xsl:value-of select="@applicPropertyValue"/>
        </fo:block>
      </fo:table-cell>
  	</xsl:when>
  	<xsl:otherwise>
      <fo:table-cell padding-top="6pt" padding-right="10pt">
        <fo:block>
          <xsl:text>Unknown</xsl:text>
        </fo:block>
      </fo:table-cell>
  	</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
  
  <xsl:template match="PARTINFO">
    <!-- Don't do anything. Handled by the foreach -->
  </xsl:template>

  <xsl:template match="PARTINFO/MFRPNR">
    <fo:table-row>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="PARTINFO/MFRPNR/PNR">
    <fo:table-cell padding-top="6pt" padding-right="10pt">
      <xsl:if test="count(//EXPRTCL) &gt; 1">
        <xsl:attribute name="padding-top">2pt</xsl:attribute>
      </xsl:if>
      <fo:block>
        <xsl:value-of select="."/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="PARTINFO/MFRPNR/MFR">
    <fo:table-cell padding-top="6pt">
      <xsl:if test="count(//EXPRTCL) &gt; 1">
        <xsl:attribute name="padding-top">2pt</xsl:attribute>
      </xsl:if>
      <fo:block>
        <xsl:value-of select="."/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- *** EXPRCTL *** -->
  <xsl:template match="EXPRTCL"/>

  <!-- *** EXPRCTL/PARA *** -->
  <xsl:template match="EXPRTCL/PARA">
    <fo:block>
      <xsl:if test="0 = count(preceding-sibling::PARA)">
        <xsl:attribute name="id">
          <xsl:value-of select="concat('exprtcl_',generate-id())"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="EXPRTCL/NOTE">
    <fo:list-block provisional-distance-between-starts="0.45in" provisional-label-separation="0.05in">
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
            <xsl:apply-templates/>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
  </xsl:template>
  
  <xsl:template match="EXPRTCL/NOTE/PARA">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="OLD-do-export-control">
    <xsl:param name="columns-spanned" select="3"/>
    <xsl:param name="break-row" select="'always'"/> 
    <fo:block-container position="absolute" top="8in" left="0in">
      <fo:block font-size="10pt" font-weight="bold" text-align="center">Legal Notice</fo:block>
      <fo:block font-size="10pt" font-weight="bold" text-align="left">Export Control</fo:block>
      <fo:block space-before="2pt" padding-top="5pt" padding-bottom="5pt" padding-left="5pt" padding-right="5pt" border="solid black 1pt" font-size="9pt" text-align="center"
        keep-together.within-page="always">
        <xsl:apply-templates select="//EXPRTCL/PARA"/>
      </fo:block>
    </fo:block-container>
  </xsl:template>

  <xsl:template name="do-export-control">
    <xsl:param name="columns-spanned" select="3"/>
    <xsl:param name="break-row" select="'always'"/>
    <fo:block font-size="10pt" font-weight="bold" text-align="center">
      <xsl:attribute name="margin-top">
        <xsl:choose>
          <xsl:when test="count(//EXPRTCL) &gt; 1">2pt</xsl:when>
          <!-- RS: The top "margin" is now controlled using the table height in the cover page's footer (was 50pt). -->
          <xsl:otherwise>0pt</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:text>Legal Notice</xsl:text>
    </fo:block>
    <fo:block font-size="10pt" font-weight="bold" text-align="left" padding-after="0pt">
      <!--<xsl:attribute name="padding-after">
        <xsl:choose>
          <xsl:when test="count(//EXPRTCL) &gt; 1">2pt</xsl:when>
          <xsl:otherwise>8pt</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>-->
      <xsl:text>Export Control</xsl:text>
    </fo:block>
    <fo:block-container margin-bottom=".25in" padding="5pt" font-size="9pt" text-align="center" keep-together.within-page="always">
      <xsl:for-each select="/pm/identAndStatusSection/pmStatus/dataRestrictions/restrictionInstructions/exportControl/exportRegistrationStmt">
        <fo:block border="solid black 1pt" padding-top="2pt" padding-bottom="2pt" padding-left="4pt" padding-right="4pt">
          <xsl:if test="preceding-sibling::EXPRTCL">
            <xsl:attribute name="text-align">left</xsl:attribute>
            <xsl:attribute name="space-before">2pt</xsl:attribute>
          </xsl:if>
          
          <!-- RS: Processing the nested simpleParas (and/or notes) does not seem to work here. Results in all the footer content being lost (TODO) -->
          <xsl:apply-templates select="simplePara|note"/>
          <!-- <fo:block><xsl:text>PLACEHOLDER TEXT</xsl:text></fo:block> -->
        </fo:block>
      </xsl:for-each>
    </fo:block-container>
  </xsl:template>

</xsl:stylesheet>
