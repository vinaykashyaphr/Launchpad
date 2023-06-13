<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:attribute-set name="header.detail">
    <xsl:attribute name="padding-before">4pt</xsl:attribute>
    <xsl:attribute name="padding-after">1pt</xsl:attribute>
    <xsl:attribute name="padding-start">4pt</xsl:attribute>
    <xsl:attribute name="padding-end">4pt</xsl:attribute>
    <xsl:attribute name="border-before-style">solid</xsl:attribute>
    <xsl:attribute name="border-before-width">1.0pt</xsl:attribute>
    <xsl:attribute name="border-after-style">solid</xsl:attribute>
    <xsl:attribute name="border-after-width">1.0pt</xsl:attribute>
    <xsl:attribute name="display-align">after</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="standard.cell">
    <xsl:attribute name="padding-before">0pt</xsl:attribute>
    <xsl:attribute name="padding-after">-1pt</xsl:attribute>
    <xsl:attribute name="padding-start">1pt</xsl:attribute>
    <xsl:attribute name="padding-end">2pt</xsl:attribute>
    <xsl:attribute name="border-style">none</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template name="build-numerical-index">
  	<!-- RS: page sequence not allowed here (for now at least... we're currently in a block context) -->
  	<!-- UPDATE: For EIPC we do need the page sequence; but it will be added in do-index (as in the EIPC numIndex): -->
    <!-- <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even">
      <xsl:call-template name="init-static-content"/>
      <fo:flow flow-name="xsl-region-body"> -->
        <!-- <xsl:call-template name="save-revdate"/>
        <xsl:call-template name="check-rev-start"/> -->
        
        <!-- Gather all the entries for the numerical index -->
        <xsl:variable name="niExtract">
          <xsl:call-template name="create-extract"/>
        </xsl:variable>
        
        <!-- Sort the numerical index -->
        <xsl:variable name="niExtractSorted">
          <xsl:call-template name="sortNiExtract">
          	<xsl:with-param name="niExtract" select="$niExtract"/>
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:if test="$niExtractSorted/numindex/part"> <!-- count($niExtractSorted//part) &gt; 0 -->
            <xsl:call-template name="do-index">
              <xsl:with-param name="niExtractSorted" select="$niExtractSorted"/>
              <xsl:with-param name="tableTitle">
                <xsl:text>Numerical Index</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
      <!-- </fo:flow>
    </fo:page-sequence> -->
  </xsl:template>

  <xsl:template name="do-index">
    <xsl:param name="pagePrefix" select="'NI-'"/>
    <xsl:param name="tableTitle" select="'Numerical Index'"/>
    <xsl:param name="niExtractSorted"/>

    <!-- Start page sequence (as in EIPC numIndex.xsl) -->    
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="end-on-even" initial-page-number="1">
       <xsl:call-template name="init-static-content">
          <xsl:with-param name="page-prefix">
             <xsl:value-of select="'NI-'"/>
          </xsl:with-param>
          <xsl:with-param name="suppressAtacode" select="1"/>
          <!-- DJH TEST 20090831 -->
       </xsl:call-template>
       <fo:flow flow-name="xsl-region-body">
         <fo:block>
            <xsl:attribute name="id" select="'num_index'"/>
            <xsl:call-template name="save-revdate">
            	<!-- Over-ride to use an empty chapter instead of the pmEntry's chapter number, so the Numerical Index -->
            	<!-- will appear in the generated LEP for the Introduction. -->
            	<xsl:with-param name="chapter" select="''"/>
            </xsl:call-template>
         </fo:block>
    
    <fo:table border-style="none" text-align="left">
      <fo:table-column column-number="1" column-width="3in"/>
      <fo:table-column column-number="2" column-width="1.5in"/>
      <fo:table-column column-number="3" column-width=".5in"/>
      <fo:table-column column-number="4" column-width="1in"/>
      <fo:table-column column-number="5" column-width=".5in"/>
      <fo:table-header font-size="10pt">
        <fo:table-row>
          <fo:table-cell number-columns-spanned="5" padding-after="6pt">
            <fo:block text-align="left" font-size="13pt" font-weight="bold">
              <xsl:value-of select="$tableTitle"/>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
        <fo:table-row>
          <fo:table-cell xsl:use-attribute-sets="header.detail">
            <fo:block margin-left="0.05in">PART NUMBER</fo:block>
          </fo:table-cell>
          <fo:table-cell xsl:use-attribute-sets="header.detail">
            <fo:block>AIRLINE</fo:block>
            <fo:block>STOCK NO.</fo:block>
          </fo:table-cell>
          <fo:table-cell xsl:use-attribute-sets="header.detail">
            <fo:block>&#xA0;</fo:block>
          </fo:table-cell>
          <fo:table-cell xsl:use-attribute-sets="header.detail"><!--number-columns-spanned="2" text-align="center"-->
            <fo:block margin-left="-0.2in">FIG.</fo:block>
            <fo:block margin-left="-0.2in">ITEM</fo:block>
          </fo:table-cell>
          <fo:table-cell xsl:use-attribute-sets="header.detail">
            <fo:block>TTL</fo:block>
            <fo:block>REQ.</fo:block>
          </fo:table-cell>
        </fo:table-row>
        <fo:table-row font-size="3pt">
          <fo:table-cell number-columns-spanned="5">
            <fo:block>&#160;</fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-header>
      <fo:table-body font-size="10pt">
          <xsl:for-each select="$niExtractSorted/numindex/part">
            <!-- RS: Translating the numbers makes them sort after letters. -->
			<!-- <xsl:sort select="translate(@pn, '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')"/> -->
			<!-- <xsl:sort select="@pn"/> -->
            <xsl:choose>
              <xsl:when test="(preceding-sibling::part[1]/@pn = ./@pn) and (preceding-sibling::part[1]/@csd = ./@csd)">
                <!-- Don't output duplicate entries for CSD parts. -->
                <xsl:message>Supressing duplicate CSD part: <xsl:value-of select="@pn"/>: <xsl:value-of select="@csd"/></xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <fo:table-row keep-together.within-column="always">
                  <xsl:variable name="thisPn" select="."/>
                  <xsl:choose>
                    <!-- Only write the Part number the first time -->
                    <xsl:when test="(preceding-sibling::*[1]/@pn != @pn) or (not(./preceding-sibling::*[1]/@pn)) or (./@csd) or (preceding-sibling::*[1]/@csd) or (./@deleted = '1')">
                      <fo:table-cell number-columns-spanned="1" xsl:use-attribute-sets="standard.cell">
                        <fo:block margin-left="0.1in">
                          <xsl:value-of select="@pn"/>
                        </fo:block>
                      </fo:table-cell>
                    </xsl:when>
                    <xsl:otherwise>
                      <fo:table-cell number-columns-spanned="1" xsl:use-attribute-sets="standard.cell">
                        <fo:block margin-left="0.1in">
                          <xsl:text>&#160;</xsl:text>
                        </fo:block>
                      </fo:table-cell>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:call-template name="do-rest-of-row"/>
                </fo:table-row>
                <!-- ATA made a new row for DELETED entries; Styler has "DELETED" in the second column (which has been added below) 
                <xsl:if test="@deleted = '1'">
                  <fo:table-row keep-together.within-column="always">
                    <fo:table-cell number-columns-spanned="1" xsl:use-attribute-sets="standard.cell">
                      <fo:block margin-left="0.3in">
                        <xsl:text>(DELETED)</xsl:text>
                      </fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                </xsl:if> -->
              </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
      </fo:table-body>
    </fo:table>
    <fo:block-container position="absolute" top="8.5in" left="0in">
      <fo:block><fo:leader leader-pattern="rule" leader-length="100%"/></fo:block>
    </fo:block-container>

			<!-- End page sequence (from EIPC numIndex.xsl) -->
            <fo:block id="ni_last"/>
         </fo:flow>
      </fo:page-sequence>

  </xsl:template>

  <xsl:template name="do-rest-of-row">
    <xsl:choose>
      <xsl:when test="self::part/@csd">
        <fo:table-cell number-columns-spanned="4" xsl:use-attribute-sets="standard.cell">
          <fo:block margin-left="-1.2in"><xsl:text>SEE&#160;</xsl:text><xsl:value-of select="./@csd"/></fo:block>
        </fo:table-cell>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-cell xsl:use-attribute-sets="standard.cell">
          <xsl:choose>
            <xsl:when test="@deleted='1'">
	          <fo:block margin-left="-1.2in"><xsl:text>(DELETED)</xsl:text></fo:block>
            </xsl:when>
            <xsl:otherwise>
	          <fo:block>
	            <!-- Airline part number -->
	          </fo:block>
            </xsl:otherwise>
          </xsl:choose>
        </fo:table-cell>
	    <fo:table-cell xsl:use-attribute-sets="standard.cell">
	      <fo:block text-align="right"  margin-left="-0.5in">
	        <xsl:choose>
	          <xsl:when test="preceding-sibling::part[1]/@pn = @pn
	              and preceding-sibling::part[1]/@fig = @fig
	              and preceding-sibling::part[1]/@figureNumberVariant = @figureNumberVariant">
	            <xsl:text>&#xA0;</xsl:text>
	          </xsl:when>
	          <xsl:otherwise>
	            <xsl:value-of select="@fig"/><xsl:value-of select="@figureNumberVariant"/>
	          </xsl:otherwise>
	        </xsl:choose>
	        <!--<xsl:value-of select="@fig"/>-->
	      </fo:block>
	    </fo:table-cell>
	    <fo:table-cell xsl:use-attribute-sets="standard.cell">
	      <xsl:attribute name="padding-start">2pt</xsl:attribute>
	      <fo:block>
	        <xsl:choose>
	        	<xsl:when test="@notIllustrated = '1'"><xsl:text>-</xsl:text></xsl:when>
	        	<xsl:otherwise><xsl:text>&#xA0;</xsl:text></xsl:otherwise>
	        </xsl:choose>
	        <xsl:value-of select="@item"/>
	        <xsl:value-of select="@itemSeqNumber"/>
	      </fo:block>
	    </fo:table-cell>
	    <fo:table-cell xsl:use-attribute-sets="standard.cell">
	      <fo:block>
	        <xsl:value-of select="@qty"/>
	      </fo:block>
	    </fo:table-cell>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-chap-sect-unit">
    <xsl:value-of select="@chapter"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@section"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@unit"/>
  </xsl:template>

  <!-- Take the initial numerical index document and create a sorted version. -->
  <!-- Sort by part number, figure number, and item number -->
  <xsl:template name="sortNiExtract">
    <xsl:param name="niExtract"/>
    <xsl:document>
      <numindex>
          <xsl:for-each select="$niExtract/numindex/part">
            <!-- RS: Translating the numbers makes them sort after letters. -->
			<!-- <xsl:sort select="translate(@pn, '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')"/> -->
			<xsl:sort select="@sortPn"/>
			<xsl:sort select="@deleted"/>
			<xsl:sort select="@sortCsd"/><!-- order="ascending" -->
			<xsl:sort select="@fig"/>
			<xsl:sort select="@figureNumberVariant"/>
			<xsl:sort select="@item"/>
			<xsl:sort select="@itemSeqNumber"/>
			<xsl:copy-of select="."/>
      	  </xsl:for-each>
      </numindex>
    </xsl:document>
  </xsl:template>
  
  <!-- Gather all the entries for the numerical index (they will be sorted later). -->
  <!-- Creates a new xsl:document with its own structure. -->
  <xsl:template name="create-extract">
    <!--
    <xsl:variable name="ni-data">
      <xsl:perform-sort select="(//PNR[ancestor::DPLIST] [not (contains(.,'ORDERNHA'))] [not (contains(.,'NONPROC'))]) | (//CSD[ancestor::DPLIST]) | (//OPT[ancestor::DPLIST])">
        <xsl:sort select="translate(., '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')" data-type="text"/>
      </xsl:perform-sort>
    </xsl:variable>
    -->
    <xsl:document>
      <numindex>
        <!-- <xsl:for-each-group select="(//PNR[ancestor::DPLIST] [not (contains(.,'ORDERNHA'))] [not (contains(.,'NONPROC'))]) | (//CSD[ancestor::DPLIST]) | (//OPT[ancestor::DPLIST])" group-by="."> -->
        
        <!-- RS: TODO: We still have to deal with the special added items generated from genericPartsData with particular types (csd and opt) -->
        <!-- These are added as separate elements in the original ATA version (see old "for-each" commented out above) -->
        <!-- <xsl:for-each-group select="/pm/content/pmEntry[@pmEntryType='pmt75']//itemSeqNumber/partRef/@partNumberValue[not(contains(.,'ORDERNHA'))][not(contains(.,'NONPROC'))]" group-by="."> -->
        <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt75']//itemSeqNumber/partRef[not(contains(@partNumberValue,'ORDERNHA')) and not(contains(@partNumberValue,'NONPROC'))]">
          <xsl:variable name="partNumber" select="@partNumberValue"/>
          <xsl:variable name="firstChar" select="substring($partNumber,1,1)"/>
          <!-- This uses the catalogSeqNumber/@figureNumber attribute (as in Styler); may need to be updated to use the calculated -->
          <!-- figure number instead. -->
          <!-- UPDATE: Actually Styler uses a calculated attribute, so we should do the same. -->
          <xsl:variable name="figureNumber" select="number(ancestor::catalogSeqNumber[1]/@figureNumber)"/>
          <xsl:variable name="figureNumberVariant" select="ancestor::catalogSeqNumber[1]/@figureNumberVariant"/>
          
          <!-- EIPC (in Styler) uses "item", which is trimmed of leading zeroes in the pre-process. -->
          <xsl:variable name="itemNumber" select="parent::itemSeqNumber/parent::catalogSeqNumber/@item"/>
          <xsl:variable name="itemSeqNumber">
          	<xsl:if test="not(parent::itemSeqNumber/@itemSeqNumberValue = '00')">
          		<xsl:value-of select="replace(parent::itemSeqNumber/@itemSeqNumberValue, '^0+', '')"/>
          	</xsl:if>
          </xsl:variable> 
          <xsl:variable name="notIllustrated" select="number(boolean(parent::itemSeqNumber/partLocationSegment/notIllustrated))"/>

          
          <!-- Calculate the "sortPn", which will used for sorting the part numbers. When it starts with a number, substitute -->
          <!-- the numbers for higher unicode values so that the part numbers starting with a number sort after the ones -->
          <!-- starting with a letter.  -->
          <xsl:variable name="sortPn">
            <xsl:choose>
            	<!-- Doesn't start with a number, so use the unchanged part number. -->
            	<xsl:when test="string(number($firstChar)) = 'NaN'">
            		<xsl:value-of select="$partNumber"/>
            	</xsl:when>
            	<xsl:otherwise>
            		<xsl:value-of select="translate($partNumber, '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')"/>
            	</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <!-- RS: Translating the numbers makes them sort after letters. -->
          <!-- <xsl:sort select="translate(., '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')"/> -->
          <!-- <xsl:for-each select="current-group()"> -->
            <!--  <xsl:sort select="self::CSD"/>
            <xsl:sort select="ancestor::ITEMDATA/PNR"/>-->
            <!-- <xsl:sort select="@partNumberValue"/> -->
            
              <!--  Add a part number for each "CSD" (genericPartData with name "csd" in the itemSeqNumber) -->
              <xsl:if test="parent::itemSeqNumber/genericPartDataGroup/genericPartData[@genericPartDataName='csd']">
              	<xsl:for-each select="parent::itemSeqNumber/genericPartDataGroup/genericPartData[@genericPartDataName='csd']">
	              <part>
	                  <xsl:attribute name="pn" select="genericPartDataValue"/>
	                  <xsl:attribute name="sortPn">
			            <xsl:choose>
			            	<!-- Doesn't start with a number, so use the unchanged part number. -->
			            	<xsl:when test="string(number(substring(genericPartDataValue,1,1))) = 'NaN'">
			            		<xsl:value-of select="genericPartDataValue"/>
			            	</xsl:when>
			            	<xsl:otherwise>
			            		<xsl:value-of select="translate(genericPartDataValue, '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')"/>
			            	</xsl:otherwise>
			            </xsl:choose>
			          </xsl:attribute>
	                  <!-- Add a csd attribute with the original part number to use in the second column. -->
	                  <xsl:attribute name="csd" select="$partNumber"/>
	                  <xsl:attribute name="sortCsd" select="$sortPn"/>
	                  <!-- <xsl:attribute name="fig" select="number(ancestor::catalogSeqNumber[1]/@figureNumber)"/>
	                  <xsl:attribute name="figureNumberVariant" select="$figureNumberVariant"/>
	                  <xsl:attribute name="item" select="$itemNumber"/>
	                  <xsl:attribute name="itemSeqNumber" select="$itemSeqNumber"/>
	                  <xsl:attribute name="qty" select="ancestor::itemSeqNumber[1]/quantityPerNextHigherAssy"/>
	                  <xsl:attribute name="isalpha">
	                    <xsl:variable name="firstChar" select="substring(genericPartDataValue,1,1)"/>
	                    <xsl:choose>
	                      <xsl:when test="string(number($firstChar)) = 'NaN'">
	                        <xsl:text>1</xsl:text>
	                      </xsl:when>
	                      <xsl:otherwise>
	                        <xsl:text>0</xsl:text>
	                      </xsl:otherwise>
	                    </xsl:choose>
	                  </xsl:attribute>-->
	              </part>
              	</xsl:for-each>
              </xsl:if>
              
              <!--  Add a part number for each "OPT" (genericPartData with name "opt" in the itemSeqNumber) -->
              <!-- [This is based on the Numerical Index implementation in Styler] -->
              <xsl:if test="parent::itemSeqNumber/genericPartDataGroup/genericPartData[@genericPartDataName='opt']">
              	<xsl:for-each select="parent::itemSeqNumber/genericPartDataGroup/genericPartData[@genericPartDataName='opt']">
	              <part>
	                  <xsl:attribute name="pn" select="genericPartDataValue"/>
	                  <xsl:attribute name="sortPn">
			            <xsl:choose>
			            	<!-- Doesn't start with a number, so use the unchanged part number. -->
			            	<xsl:when test="string(number(substring(genericPartDataValue,1,1))) = 'NaN'">
			            		<xsl:value-of select="genericPartDataValue"/>
			            	</xsl:when>
			            	<xsl:otherwise>
			            		<xsl:value-of select="translate(genericPartDataValue, '0123456789', '&#xE000;&#xE001;&#xE002;&#xE003;&#xE004;&#xE005;&#xE006;&#xE007;&#xE008;&#xE009;')"/>
			            	</xsl:otherwise>
			            </xsl:choose>
			          </xsl:attribute>
	                  <xsl:attribute name="fig" select="number(ancestor::catalogSeqNumber[1]/@figureNumber)"/>
	                  <xsl:attribute name="figureNumberVariant" select="$figureNumberVariant"/>
	                  <xsl:attribute name="item" select="$itemNumber"/><!-- ancestor::catalogSeqNumber[1]/@trimmedItem -->
	                  <xsl:attribute name="itemSeqNumber" select="$itemSeqNumber"/>
	                  <xsl:attribute name="qty" select="ancestor::itemSeqNumber[1]/quantityPerNextHigherAssy"/>
                      <xsl:attribute name="notIllustrated" select="$notIllustrated"/>
	                  <!-- <xsl:attribute name="isalpha">
	                    <xsl:variable name="firstChar" select="substring(genericPartDataValue,1,1)"/>
	                    <xsl:choose>
	                      <xsl:when test="string(number($firstChar)) = 'NaN'">
	                        <xsl:text>1</xsl:text>
	                      </xsl:when>
	                      <xsl:otherwise>
	                        <xsl:text>0</xsl:text>
	                      </xsl:otherwise>
	                    </xsl:choose>
	                  </xsl:attribute> -->
	              </part>
              	</xsl:for-each>
              </xsl:if>
             
             <!-- Output a new part for this itemSeqNUmber/partRef --> 
             <part>
                <xsl:attribute name="pn" select="$partNumber"/>
                <xsl:attribute name="sortPn" select="$sortPn"/>
                <xsl:attribute name="fig" select="number(ancestor::catalogSeqNumber[1]/@figureNumber)"/>
	            <xsl:attribute name="figureNumberVariant" select="$figureNumberVariant"/>
                <xsl:attribute name="item" select="$itemNumber"/><!-- ancestor::catalogSeqNumber[1]/@trimmedItem -->
                <xsl:attribute name="itemSeqNumber" select="$itemSeqNumber"/>
                <xsl:attribute name="qty" select="ancestor::itemSeqNumber[1]/quantityPerNextHigherAssy"/>
                <xsl:attribute name="notIllustrated" select="$notIllustrated"/>
                <xsl:choose>
                  <!-- <xsl:when test="ancestor::ITEMDATA/@DELITEM = '1'"> -->
                  <xsl:when test="ancestor::itemSeqNumber[@changeType='delete'] or ancestor::catalogSeqNumber[@changeType='delete']">
                    <xsl:attribute name="deleted" select="'1'"/>
                  </xsl:when>
                  <!-- <xsl:when test="false()"></xsl:when> -->
                  <xsl:otherwise>
                    <xsl:attribute name="deleted" select="'0'"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="ancestor::ITEMDATA/IPLNOM/RP">
                    <xsl:attribute name="replaced" select="ancestor::ITEMDATA/IPLNOM/RP"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- Don't write the attribute -->
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="isalpha">
                  <xsl:choose>
                    <xsl:when test="string(number($firstChar)) = 'NaN'">
                      <xsl:text>1</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>0</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
            </part>
        </xsl:for-each>
      </numindex>
    </xsl:document>
  </xsl:template>

</xsl:stylesheet>
