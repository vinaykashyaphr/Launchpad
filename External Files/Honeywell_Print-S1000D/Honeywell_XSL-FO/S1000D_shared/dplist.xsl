<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:itg="http://www.infotrustgroup.com"
  xmlns:helper="java:com.sonovision.saxonext.S1000DHelper">
  <!-- S1000DHelper is our Saxon extension to handle complex list building (as in RD/RDI values, etc.). -->


  <!-- Path for certain global parameters -->
  <xsl:variable name="graphicsPath">graphics</xsl:variable>
  <xsl:param name="WorkPath">.</xsl:param>

  <!-- Margin (indent) for IPL notes under the description -->
  <xsl:variable name="iplNoteMargin">22pt</xsl:variable>
  
  <!--Issues when using encode-for-uri()??-->
  <xsl:function name="itg:escape-path">
    <xsl:param name="path"/>
    <xsl:variable name="path1">
      <xsl:value-of select="replace($path,'\[','%5B')"/>
    </xsl:variable>
    <xsl:variable name="path2">
      <xsl:value-of select="replace($path1,'\]','%5D')"/>
    </xsl:variable>
    <xsl:variable name="path3">
      <xsl:value-of select="replace($path2,' ','%20')"/>
    </xsl:variable>
    <xsl:variable name="path4">
      <xsl:value-of select="replace($path3,'&amp;','%26')"/>
    </xsl:variable>
    <xsl:variable name="path5">
      <xsl:value-of select="replace($path4,'\\','/')">
      </xsl:value-of>
    </xsl:variable>
    <xsl:value-of select="$path5"/>
  </xsl:function>

  <xsl:template match="DPLIST">
    <!--NUMBERED LIKE A TASK-->
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even">
      <xsl:call-template name="init-static-content"/>
      <fo:flow flow-name="xsl-region-body">
        <xsl:call-template name="check-rev-start"/>
        <fo:list-block id="dplist" font-size="10pt" provisional-distance-between-starts="24pt"
          space-before=".1in" space-after=".1in" page-break-before="always">
          <xsl:call-template name="save-revdate"/>
          <fo:list-item>
            <fo:list-item-label end-indent="label-end()" font-size="13pt" font-weight="bold">
              <fo:block>
                <xsl:number
                  value="1 + count(preceding-sibling::IPLINTRO/TASK) + count(preceding-sibling::IPLINTRO/VENDLIST)"
                  format="1."/>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()" font-size="13pt">
              <fo:block rx:key="{concat('task_',@KEY)}">
                <fo:inline text-decoration="underline" font-weight="bold">
                  <xsl:apply-templates select="TITLE" mode="task-subtask-title"/>
                </fo:inline>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
        <xsl:call-template name="edi"/>
      </fo:flow>
    </fo:page-sequence>
    <xsl:call-template name="build-numerical-index"/>
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even">
      <xsl:call-template name="init-static-content"/>
      <fo:flow flow-name="xsl-region-body">
        <xsl:call-template name="save-revdate"/>
        <xsl:call-template name="check-rev-start"/>
        <xsl:apply-templates/>
      </fo:flow>
    </fo:page-sequence>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>

  <xsl:template name="edi">
    <xsl:variable name="edi_tables">
      <xsl:value-of select="concat(itg:escape-path($WorkPath),'/TEMP/edi_tables.xml')"/>
    </xsl:variable>
    <xsl:message>work path: <xsl:value-of select="$WorkPath"/></xsl:message>
    <xsl:message>edi_tables path: <xsl:value-of select="$edi_tables"/></xsl:message>
    <xsl:choose>
      <!-- <xsl:when test="/CMM/IPL/DPLIST//EQDES"> -->
      <xsl:when test="count(/pm/content//functionalItemRef)>0 or count(/pm/content//genericPartData[@genericPartDataName='rd' or @genericPartDataName='rdi'])>0">
      
        <xsl:value-of select="unparsed-text($edi_tables)" disable-output-escaping="yes"/>
      </xsl:when>
      <xsl:otherwise>
      	<!-- Output "Not Applicable" EDI table -->
        <fo:block>
          <xsl:attribute name="font-size">13pt</xsl:attribute>
          <xsl:attribute name="font-weight">bold</xsl:attribute>
          <xsl:text>Equipment Designator Index</xsl:text>
        </fo:block>
        <fo:table border-bottom="solid 1pt black" border-top="none" border-left="none" border-right="none" page-break-after="always" padding-before="6pt">
          <fo:table-column column-number="1" column-width="1.25in"/>
          <fo:table-column column-number="2" column-width=".33in"/>
          <fo:table-column column-number="3" column-width=".15in"/>
          <fo:table-column column-number="4" column-width=".5in"/>
          <fo:table-column column-number="5" column-width="1.25in"/>
          <fo:table-column column-number="6" column-width="1.25in"/>
          <fo:table-column column-number="7" column-width=".33in"/>
          <fo:table-column column-number="8" column-width=".15in"/>
          <fo:table-column column-number="9" column-width=".5in"/>
          <fo:table-column column-number="10" column-width="1in"/>
          <fo:table-header font-size="10pt" padding-before="2pt" padding-after="2pt">
            <fo:table-row border-top="solid 1pt black" border-bottom="solid 1pt black" border-left="none" border-right="none" padding-top="3pt" padding-bottom="3pt">
              <fo:table-cell text-align="left">
                <fo:block>EQUIPMENT</fo:block>
                <fo:block>DESIGNATOR</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="center" number-columns-spanned="3">
                <fo:block>FIG.</fo:block>
                <fo:block>ITEM</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>GEOGRAPHIC</fo:block>
                <fo:block>LOCATION</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>EQUIPMENT</fo:block>
                <fo:block>DESIGNATOR</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="center" number-columns-spanned="3">
                <fo:block>FIG.</fo:block>
                <fo:block>ITEM</fo:block>
              </fo:table-cell>
              <fo:table-cell text-align="left">
                <fo:block>GEOGRAPHIC</fo:block>
                <fo:block>LOCATION</fo:block>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-header>
          <fo:table-body font-size="10pt" padding-before="6pt">
            <fo:table-row>
              <fo:table-cell>
                <fo:block margin-top=".25in" margin-bottom="7.25in" font-size="10pt">NOT
                  APPLICABLE</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
              <fo:table-cell>
                <fo:block>&#xA0;</fo:block>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--IPL Figures can be handled by the normal graphic/sheet templates.-->
  <!--<xsl:template match="FIGURE">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="FIGURE/GRAPHIC">
    <xsl:if test="not(./DELETED)">
      <fo:block text-align="center" page-break-before="always"><!-\- page-break-after="always"-\->
        <xsl:if test="./@KEY">
          <xsl:attribute name="id">
            <xsl:value-of select="./@KEY"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="*[not(name()='EFFECT')][not(name()='TITLE')]"/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match="FIGURE/GRAPHIC/SHEET">
    <fo:block>
      <xsl:call-template name="save-revdate"/>
    </fo:block>
    <fo:external-graphic text-align="center" scaling="uniform" content-width="scale-to-fit" content-height="scale-to-fit">
      <xsl:attribute name="width">7in</xsl:attribute>
      <xsl:attribute name="height">7in</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:choose>
          <xsl:when test="./@GNBR">url('<xsl:value-of select="concat($GRAPHICS_DIR, '/', ./@GNBR,$GRAPHICS_SUFFIX)"/>')</xsl:when>
          <xsl:otherwise>
            <xsl:message>missing-graphic-reference with gnbr value of <xsl:value-of select="./@GNBR"/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="not(./DELETED)">
        <xsl:if test="./@KEY">
          <xsl:attribute name="id">
            <xsl:value-of select="./@KEY"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
    </fo:external-graphic>
    <fo:wrapper text-align="center" font-weight="bold">
      <fo:block space-before.optimum="10pt" page-break-before="avoid" keep-with-previous.within-page="always">
        <fo:block keep-with-previous.within-page="always">
          <xsl:call-template name="figure-caption-dplist"/>
        </fo:block>
      </fo:block>
    </fo:wrapper>
    <xsl:apply-templates select="*[not(name()='EFFECT')][not(name()='TITLE')]"/>
  </xsl:template>-->

  <!-- <xsl:template match="FIGURE/PRTLIST"> -->
  <xsl:template match="illustratedPartsCatalog">
  
  	<!--  Output the figure first, then the parts list -->
  	<xsl:apply-templates select="figure"/>
  	
    <fo:block text-align="center" page-break-before="always" margin-left="0in" id="{@KEY}">
      <!-- page-break-after="always"-->
      <fo:table border="none" font-size="10pt" margin-bottom=".125in">
        <fo:table-column column-number="1" column-width="0pt"/>
        <fo:table-column column-number="2" column-width="0.68in"/>
        <fo:table-column column-number="3" column-width="1.25in"/>
        <fo:table-column column-number="4" column-width="0.75in"/>
        <fo:table-column column-number="5" column-width="2.75in"/>
        <fo:table-column column-number="6" column-width="0.72in"/>
        <fo:table-column column-number="7" column-width="0.5in"/>
        <fo:table-header>
          <fo:table-row>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="center" border-top="solid 1pt black"
              border-bottom="solid 1pt black" border-left="none" border-right="none"
              display-align="after" padding-left="5pt" padding-right="5pt" padding-top="3pt"
              padding-bottom="3pt">
              <fo:block>FIG.</fo:block>
              <fo:block>ITEM</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="center" border-top="solid 1pt black"
              border-bottom="solid 1pt black" border-left="none" border-right="none"
              display-align="after" padding-left="5pt" padding-right="5pt" padding-top="3pt"
              padding-bottom="3pt">
              <fo:block>PART</fo:block>
              <fo:block>NUMBER</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left" border-top="solid 1pt black"
              border-bottom="solid 1pt black" border-left="none" border-right="none"
              display-align="after" padding-left="5pt" padding-right="5pt" padding-top="3pt"
              padding-bottom="3pt">
              <fo:block>AIRLINE</fo:block>
              <fo:block>STOCK NO.</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left" border-top="solid 1pt black"
              border-bottom="solid 1pt black" border-left="none" border-right="none"
              display-align="after" padding-left="0pt" padding-right="0pt" padding-top="3pt"
              padding-bottom="3pt">
              <fo:block>1234567<fo:inline margin-left="34pt">NOMENCLATURE</fo:inline></fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left" border-top="solid 1pt black"
              border-bottom="solid 1pt black" border-left="none" border-right="none"
              display-align="after" padding-left="10pt" padding-right="0pt" padding-top="3pt"
              padding-bottom="3pt">
              <fo:block>EFFECT</fo:block>
              <fo:block>(USE)</fo:block>
              <fo:block>CODE</fo:block>
            </fo:table-cell>
            <fo:table-cell text-align="left" border-top="solid 1pt black"
              border-bottom="solid 1pt black" border-left="none" border-right="none"
              display-align="after" padding-left="3pt" padding-right="3pt" padding-top="3pt"
              padding-bottom="3pt">
              <fo:block>UNITS</fo:block>
              <fo:block>PER</fo:block>
              <fo:block>ASSY</fo:block>
            </fo:table-cell>
          </fo:table-row>
          <fo:table-row>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell border="none" text-align="left" padding-top="12pt" padding-bottom="5pt">
              <fo:block margin-right="-0.5in">
                <!-- <xsl:value-of select="./parent::FIGURE/@FIGNBR"/> -->
                <!-- Calculate figure number based on pmEntry structure (XPath is from Styler) -->
                <!-- <xsl:value-of select="count((ancestor::pmEntry)[last()]/preceding-sibling::pmEntry)+1"/> -->
                <!-- UPDATE: Same as in calculation of figure number in cmmMiscFunctions.xsl -->
                <xsl:value-of select="count(ancestor::pmEntry[1]/preceding-sibling::pmEntry) + 1"/>
		      	<xsl:variable name="variantNum" select="count(ancestor::dmContent[1]/preceding-sibling::dmContent[dmodule/content/illustratedPartsCatalog/figure])"/>
		      	<xsl:if test="$variantNum &gt; 0">
	      			<!-- TODO: This will need to be updated to skip "I" and "O"; may need to use a Java extension for this... -->
	      			<!-- <xsl:number value="$variantNum" format="A"/> -->
	      			<xsl:value-of select="helper:getVariantCode($variantNum)"/>
		      	</xsl:if>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
            <fo:table-cell border="none">
              <fo:block>&#160;</fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-header>
        <fo:table-footer>
          <!--<fo:table-cell border="none">
            <fo:block>&#160;</fo:block>
          </fo:table-cell>
          <fo:table-cell border="none" number-columns-spanned="6" text-align="left" display-align="after" padding-top="5pt">
            <fo:block>-&#160;ITEM NOT ILLUSTRATED</fo:block>
            </fo:table-cell>-->
          <fo:table-cell number-columns-spanned="7" text-align="left">
            <fo:block-container position="absolute" top="8.7in" left="0in"><!-- top="8.5in" -->
              <fo:block>-&#160;ITEM NOT ILLUSTRATED</fo:block>
            </fo:block-container>
          </fo:table-cell>
        </fo:table-footer>
        <fo:table-body>
          <!-- <xsl:for-each select="./ITEMDATA"> -->
          <xsl:for-each select="catalogSeqNumber/itemSeqNumber">
            <xsl:variable name="descriptionText">
		      <xsl:call-template name="descriptionText"/>
            </xsl:variable>
		  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
		  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
            <xsl:variable name="csnCount" select="count(/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue='$mfrCode'][partIdent/@partNumberValue= '$partNo']/itemIdentData/customerStockNumber)"/>
            <!-- <xsl:if test=".[@ATTACH=1 and preceding-sibling::ITEMDATA[1]/@ATTACH=0]"> -->
            <xsl:if test="attachingPartsStart">
              <fo:table-row keep-together.within-page="always" keep-with-next.within-page="always">
                <fo:table-cell/>
                <fo:table-cell/>
                <fo:table-cell/>
                <fo:table-cell/>
                <fo:table-cell text-align="left" padding-left="20pt">
                  <fo:block>(ATTACHING PARTS)</fo:block>
                </fo:table-cell>
                <fo:table-cell/>
                <fo:table-cell/>
              </fo:table-row>
            </xsl:if>
            
            <fo:table-row keep-together.within-page="always">
              <fo:table-cell text-align="left">
                <!-- TODO: Change mark (seems to use a table border instead of a real change bar) -->
                <!-- <xsl:if test="((./@CHG='R') or (./@CHG='N'))"> -->
                <!-- <xsl:if test="@changeType='add' or @changeType='modify'
	              or parent::catalogSeqNumber/@changeType='add' or parent::catalogSeqNumber/@changeType='modify'">
                  <xsl:attribute name="border-left">solid 6pt black</xsl:attribute>
                </xsl:if> -->
                <!--ITEMDATA DOES NOT HAVE A CHG ATTRIBUTE-->
                <!-- <xsl:if test="not((./@CHG='R') or (./@CHG='N'))">
                  <xsl:attribute name="border">none</xsl:attribute>
                </xsl:if> -->
                <!-- <fo:block/> -->
		        <!-- <xsl:if test="@changeType='add' or @changeType='modify'
		        	or parent::catalogSeqNumber/@changeType='add' or parent::catalogSeqNumber/@changeType='modify'">
				  <xsl:call-template name="cbStart" />
				</xsl:if>-->
                <!-- For changeType='delete', only apply the change bar when changeMark='1' (since it's -->
                <!-- also used to indicate the item's "DELETED" state). -->
		        <xsl:if test="@changeType='add' or @changeType='modify' or (@changeType='delete' and @changeMark='1')
		        	or parent::catalogSeqNumber/@changeType='add' or parent::catalogSeqNumber/@changeType='modify'
		        	or (parent::catalogSeqNumber/@changeType='delete' and parent::catalogSeqNumber/@changeMark='1')">
				  <xsl:call-template name="cbStart">
				    <!-- Applying keeps caused problems in the DPL list, keeping too many things together. -->
				    <!-- [This was from CMM: we may need to implement something similar later...] -->
				  	<!-- <xsl:with-param name="keep">0</xsl:with-param> -->
				  </xsl:call-template>
				</xsl:if>
              </fo:table-cell>
              <fo:table-cell border="none" text-align="left" padding-left="0pt" padding-top="0pt"
                padding-bottom="5pt" padding-right="0pt">
                <!-- <xsl:if test="./@ILLUSIND='1'"> -->
                <xsl:if test="not(partLocationSegment/notIllustrated)">
                  <fo:block>&#160;<fo:inline margin-left="10pt">
                      <!-- <xsl:value-of select="./@ITEMNBR"/> -->
                      <!-- EIPC (in Styler) uses "item", which is trimmed of leading zeroes in the pre-process. -->
                      <xsl:value-of select="ancestor::catalogSeqNumber/@item"/>
                      <!-- Add the itemSeqNumberValue if it's not "00" -->
                      <xsl:if test="@itemSeqNumberValue != '00'">
                        <!-- The substring gets the last character (input "00A"; output "A") -->
                        <!-- UPDATE: need to strip leading zeroes instead, in case of "0AA" etc. -->
                      	<!-- <xsl:value-of select="substring(@itemSeqNumberValue, string-length(@itemSeqNumberValue))"/> -->
                      	<xsl:value-of select="replace(@itemSeqNumberValue, '^0+','')"/>
                      </xsl:if>
                    </fo:inline></fo:block>
                </xsl:if>
                <xsl:if test="partLocationSegment/notIllustrated">
                  <fo:block>-<fo:inline margin-left="10pt">
                      <xsl:value-of select="ancestor::catalogSeqNumber/@item"/>
                      <!-- Add the itemSeqNumberValue if it's not "00" -->
                      <xsl:if test="@itemSeqNumberValue != '00'">
                        <!-- The substring gets the last character (input "00A"; output "A") -->
                        <!-- UPDATE: need to strip leading zeroes instead, in case of "0AA" etc. -->
                      	<!-- <xsl:value-of select="substring(@itemSeqNumberValue, string-length(@itemSeqNumberValue))"/> -->
                      	<xsl:value-of select="replace(@itemSeqNumberValue, '^0+','')"/>
                      </xsl:if>
                    </fo:inline></fo:block>
                </xsl:if>
              </fo:table-cell>
              <fo:table-cell border="none" text-align="left" padding-left="5pt" padding-top="0pt"
                padding-bottom="5pt" padding-right="0pt">
                <fo:block>
                  <xsl:value-of select="partRef/@partNumberValue"/>
                </fo:block>
              </fo:table-cell>
              <fo:table-cell border="none" text-align="left" padding-left="0pt" padding-top="0pt"
                padding-bottom="5pt" padding-right="0pt">
                <fo:block>&#160;</fo:block>
              </fo:table-cell>
              <fo:table-cell border="none" text-align="left" padding-left="0pt" padding-top="0pt"
                padding-bottom="5pt" padding-right="0pt">
                <!-- <xsl:if
                  test="preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev'] or descendant::processing-instruction() = '_rev'">
                  <xsl:call-template name="cbStart"/>
                </xsl:if> -->
                <fo:block keep-together.within-page="always">
                  <!-- <xsl:apply-templates select="IPLNOM/NOM/KWD"/> -->
                  <xsl:call-template name="ipdDescription"/>
                  <!-- ADT seems to be the second part, like "OIL" in "SCREEN - OIL". Don't need this in S1000D. -->
                  <!-- <xsl:if test="IPLNOM/NOM/ADT != ''">
                    <xsl:apply-templates select="IPLNOM/NOM/ADT"/>
                  </xsl:if> -->
                  <!-- Special handling for deleted items (the text will also be set to "DELETED" when @changeType='delete')-->
                  <xsl:choose>
                  	<xsl:when test="string($descriptionText)='DELETED'">
	                  <xsl:call-template name="ipdGenericPartDataForDelete"/>
                  	</xsl:when>
                  	<xsl:otherwise>
	                  <!-- RS: This processes the rest of the contents (with the exceptions indicated) to add the other entries below -->
	                  <!-- the Description. We'll process instead similarly to what's in Styler, calling templates instead of UFEs. -->
	                  <!-- <xsl:apply-templates select="IPLNOM/*[not(NOM)][not(EQDES)][not(RDI)]"/> -->
	                  <xsl:call-template name="ipdShortName"/>
	                  <xsl:call-template name="ipdGenericPartDataDD"/>
	                  <xsl:call-template name="ipdMfrCode"/>
	                  
	                  <!-- Over-length part number (called "OrderPN" in Styler for some reason) -->
	                  <!-- Don't include if there is a Customer Stock Number -->
	                  <xsl:if test="$csnCount=0">
	                  	<xsl:call-template name="ipdOrderPN"/>
	                  </xsl:if>
	                  
	                  <xsl:call-template name="ipdOptionalPart"/>
	                  <xsl:call-template name="ipdChangeAuthorityData"/>
	                  <xsl:call-template name="ipdSelectOrManufacture"/>
	                  
	                  <!-- If there is a CSN, output it. -->
	                  <xsl:if test="$csnCount &gt; 0">
	                  	<xsl:call-template name="ipdSCDNumber"/>
	                  </xsl:if>
	                  
	                  <xsl:call-template name="ipdGenericPartData"/>
	                  <xsl:call-template name="ipdAlternatePart"/>
	                  <xsl:call-template name="ipdReferTo"/>
	                  <xsl:call-template name="ipdGenericPartDataRD"/>
                  	</xsl:otherwise>
                  </xsl:choose>
                </fo:block>
                <!-- <fo:block keep-with-previous.within-page="always" keep-together.within-page="auto">
                  <xsl:apply-templates select="IPLNOM/EQDES"/>
                </fo:block> -->
                <!-- <xsl:if
                  test="preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev'] or descendant::processing-instruction() = '_rev'">
                  <xsl:call-template name="cbEnd"/>
                </xsl:if> -->
		        <xsl:if test="@changeType='add' or @changeType='modify' or (@changeType='delete' and @changeMark='1')
		        	or parent::catalogSeqNumber/@changeType='add' or parent::catalogSeqNumber/@changeType='modify'
		        	or (parent::catalogSeqNumber/@changeType='delete' and parent::catalogSeqNumber/@changeMark='1')">
		          <!-- Make an extra skinny row to anchor the end of the change bar -->
	              <!-- <fo:table-row height="0.1mm"><fo:table-cell><xsl:call-template name="cbEnd" /></fo:table-cell></fo:table-row> -->
	              <xsl:call-template name="cbEnd">
				    <!-- Applying keeps caused problems in the DPL list, keeping too many things together. -->
				    <!-- [This was from CMM: we may need to implement something similar later...] -->
				  	<!-- <xsl:with-param name="keep">0</xsl:with-param> -->
				  </xsl:call-template>
				</xsl:if>
              </fo:table-cell>
              <fo:table-cell border="none" text-align="left" padding-left="16pt" padding-top="0pt"
                padding-bottom="5pt" padding-right="0pt">
                <fo:block>
                  <!-- In S1000D, the Effective Use Codes are output all at once, in one of two elements. -->
                  <!-- Add zero-width spaces after the commas, so the text will break in the table cell if necessary. -->
                  <xsl:choose>
                  	<xsl:when test="applicabilitySegment/usableOnCodeAssy">
                  		<xsl:value-of select="replace(applicabilitySegment/usableOnCodeAssy,',',',&#x0200B;')"/>
                  	</xsl:when>
                  	<xsl:when test="applicabilitySegment/usableOnCodeEquip">
                  		<xsl:value-of select="replace(applicabilitySegment/usableOnCodeEquip,',',',&#x0200B;')"/>
                  	</xsl:when>
                  </xsl:choose>
                  <!-- [Old version for reference:
                    <xsl:for-each select="EFFCODE">
                    <xsl:if test="0 != count(preceding-sibling::EFFCODE)">
                      <xsl:text>,&#x200B;</xsl:text>
                      [!++ x200B is a zero-width-space ++]
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </xsl:for-each> -->
                </fo:block>
              </fo:table-cell>
              <fo:table-cell border="none" text-align="center" padding-left="0pt" padding-top="0pt"
                padding-bottom="5pt" padding-right="0pt">
                <fo:block>
                  <!-- Units Per Assembly -->
                  <xsl:choose>
                  	<xsl:when test="string($descriptionText)='DELETED'">0</xsl:when>
                  	<xsl:otherwise>
	                  <!-- <xsl:value-of select="UPA"/> -->
	                  <xsl:value-of select="quantityPerNextHigherAssy"/>
                  	</xsl:otherwise>
                  </xsl:choose>
                </fo:block>
              </fo:table-cell>
            </fo:table-row>
            
            
            <!-- <xsl:if
              test=".[@ATTACH=1 and (following-sibling::ITEMDATA[1]/@ATTACH=0 or not(following-sibling::ITEMDATA))]"> -->
            <xsl:if test="attachingPartsEnd">
              <!-- 3 dashes * 3 dashes (no spaces) -->
              <fo:table-row keep-together.within-page="always"
                keep-with-previous.within-page="always">
                <fo:table-cell/>
                <fo:table-cell/>
                <fo:table-cell/>
                <fo:table-cell/>
                <fo:table-cell text-align="left" padding-left="56pt">
                  <fo:block>---*---</fo:block>
                </fo:table-cell>
                <fo:table-cell/>
                <fo:table-cell/>
              </fo:table-row>
            </xsl:if>
          </xsl:for-each>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>

  <xsl:template name="block_and_text_indentation">
    <xsl:attribute name="margin-left">22pt</xsl:attribute>
    <xsl:attribute name="text-indent">-22pt</xsl:attribute>
    <xsl:choose>
      <!-- <xsl:when test="./ancestor::ITEMDATA[1]/@INDENT='0'"> </xsl:when>
      <xsl:when test="./ancestor::ITEMDATA[1]/@INDENT='1'"> -->
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='2'">
        <fo:inline font-size="12pt" font-weight="bold">.</fo:inline>
      </xsl:when>
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='3'">
        <fo:inline font-size="12pt" font-weight="bold">..</fo:inline>
      </xsl:when>
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='4'">
        <fo:inline font-size="12pt" font-weight="bold">...</fo:inline>
      </xsl:when>
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='5'">
        <fo:inline font-size="12pt" font-weight="bold">....</fo:inline>
      </xsl:when>
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='6'">
        <fo:inline font-size="12pt" font-weight="bold">.....</fo:inline>
      </xsl:when>
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='7'">
        <fo:inline font-size="12pt" font-weight="bold">......</fo:inline>
      </xsl:when>
      <xsl:when test="ancestor::catalogSeqNumber[1]/@indenture='8'">
        <fo:inline font-size="12pt" font-weight="bold">.......</fo:inline>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="text_indentation">
    <xsl:param name="indentValue"/>
    <xsl:choose>
      <xsl:when test="$indentValue='0'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='1'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='2'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='3'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='4'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='5'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='6'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
      <xsl:when test="$indentValue='7'">
        <xsl:attribute name="margin-left">22pt</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="NOM"/>

  <!-- <xsl:template match="ESDS">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template> -->


  <!-- Output only entries that have the name 'delete' (for deleted items only) Should be called with itemSeqNumber in context. -->
  <xsl:template name="ipdGenericPartDataForDelete">
    <xsl:apply-templates select="genericPartDataGroup/genericPartData[@genericPartDataName='delete']"/>
  </xsl:template>

  <!-- Output the genericPartData value(s) for type "dd" (if they exist). Should be called with itemSeqNumber in context. -->
  <xsl:template name="ipdGenericPartDataDD">
    <xsl:apply-templates select="genericPartDataGroup/genericPartData[@genericPartDataName='dd']"/>
  </xsl:template>
  
  <!-- Output the Reference Designator list. Preference is given to functionalItemRefs as a source if they exist. -->
  <!-- Uses the S1000DHelper Saxon extension to build the lists (using "thru" for consecutive items) -->
  <xsl:template name="ipdGenericPartDataRD">
  	<xsl:choose>
  		<!-- Prefer using functionalItemRefs over genericPartData for the Reference Designator List -->
  		<xsl:when test="partLocationSegment/referTo/functionalItemRef">
		    <fo:block margin-left="22pt">
		      <xsl:value-of select="helper:getRDListFunctionalItemRef(partLocationSegment/referTo/functionalItemRef)"/>
		    </fo:block>
  		</xsl:when>
  		<xsl:when test="genericPartDataGroup/genericPartData[@genericPartDataName='rd'] or genericPartDataGroup/genericPartData[@genericPartDataName='rdi']">
		    <fo:block margin-left="22pt">
		      <xsl:value-of select="helper:getRDList(genericPartDataGroup/genericPartData[@genericPartDataName='rd' or @genericPartDataName='rdi']/genericPartDataValue)"/>
		    </fo:block>
  		</xsl:when>
  		<!-- <xsl:otherwise>
		    <fo:block margin-left="22pt">
		      <xsl:value-of/>
		    </fo:block>
  		</xsl:otherwise> -->
  	</xsl:choose>
  </xsl:template>
  
  <xsl:template match="genericPartData">
  	<xsl:choose>
  		<xsl:when test="placeholder"><!-- TODO: other conditions? -->
  		</xsl:when>
  		<xsl:otherwise>
		    <fo:block margin-left="22pt">
		      <xsl:apply-templates/>
		    </fo:block>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
  
  <xsl:template match="genericPartDataValue">
  	  <!-- From Styler: Add parens if not already provided, except for type 'dd' -->
  	  <xsl:choose>
  	  	<xsl:when test="not(parent::genericPartData/@genericPartDataName='dd') and not(starts-with(normalize-space(.), '('))">
  	  		<xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
  	  	</xsl:when>
  	  	<xsl:otherwise>
	      <xsl:apply-templates/>
  	  	</xsl:otherwise>
  	  </xsl:choose>
  </xsl:template>

  <xsl:template name="ipdMfrCode">
  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
  	<xsl:variable name="pmIssuer" select="/pm/identAndStatusSection/pmAddress/pmIdent/pmCode/@pmIssuer"/>
	<xsl:variable name="manufacturerCodeValue">
		<xsl:choose>
			<xsl:when test="/pm/commonRepository/partRepository/partSpec">
				<xsl:value-of select="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/procurementData/enterpriseRef/@manufacturerCodeValue"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$mfrCode"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  	
	<xsl:if test="$manufacturerCodeValue != $pmIssuer">
		<!-- From Styler: Add parens and a "V" prefix if the mfr code doesn't already have them -->
		<xsl:variable name="codeOnly" select="replace($manufacturerCodeValue, '\(?V?([0-9A-Z]+)\)?', '$1')"/>
	    <fo:block margin-left="22pt">
	      <xsl:text>(V</xsl:text><xsl:value-of select="$codeOnly"/><xsl:text>)</xsl:text>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>
  
  <!-- Over-length part number (called "OrderPN" in Styler for some reason) -->
  <xsl:template name="ipdOrderPN">
  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
  	
	<xsl:if test="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/overLengthPartNumber">
	    <fo:block margin-left="22pt">
	      <!-- NOTE: Styler applies a keep around the part number. (Use this or "keep-together.within-line"?) -->
	      <xsl:text>OVERLENGTH PN: </xsl:text><fo:inline keep-together="always"><xsl:value-of select="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/overLengthPartNumber"/></fo:inline>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>

  
  <xsl:template name="ipdSCDNumber">
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
  	
  	<!-- From Styler: -->
  	<!-- The SCDPartNumber must be the same as the partNo found above (since we're matching on it). So just output -->
	<!-- that instead of checking in the partRepository as usual. -->
    <fo:block margin-left="22pt">
      <xsl:text>SCD: </xsl:text><fo:inline keep-together="always"><xsl:value-of select="$partNo"/></fo:inline>
    </fo:block>
  </xsl:template>

  <xsl:template name="ipdOptionalPart">
  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
  	
	<xsl:if test="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/partRefGroup/optionalPart">
	    <fo:block margin-left="22pt">
	      <xsl:text>OPT TO </xsl:text><xsl:value-of select="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/partRefGroup/optionalPart"/>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>

  <xsl:template name="ipdChangeAuthorityData">
	<xsl:if test="changeAuthorityData">
	    <fo:block margin-left="22pt">
	      <xsl:value-of select="changeAuthorityData/@condValue"/>
	      <xsl:text> </xsl:text>
	      <xsl:value-of select="changeAuthorityData/changeAuthority/@condNumber"/>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>

  <xsl:template name="ipdSelectOrManufacture">
	<xsl:if test="partLocationSegment/selectOrManufactureFromIdent/@selectOrManufactureValue='m'">
	    <fo:block margin-left="22pt">
	      <xsl:text>(MANUFACTURE FROM </xsl:text>
	      <xsl:value-of select="partLocationSegment/selectOrManufactureFromIdent/selectOrManufacture"/>
	      <xsl:text>)</xsl:text>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>

  <xsl:template name="ipdAlternatePart">
	<xsl:if test="@partStatus='pst05'">
	    <fo:block margin-left="22pt">
	      <xsl:text>(ALTN PN)</xsl:text>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>

  <xsl:template name="ipdReferTo">
  	<xsl:apply-templates select="partLocationSegment/referTo"/>
  </xsl:template>

  <!-- IPL referTo element: There are several different referTo types and requirements (see Styler for details). -->
  <!-- This template attempts to duplicate the logic from Styler. -->
  <xsl:template match="partLocationSegment/referTo">
  	
    <fo:block margin-left="22pt">
    
  	<xsl:choose>
  		<!-- Several refTypes have everything in common except the "FOR ..." statement at the end -->
  		<xsl:when test="@refType='rft01' or @refType='rft02' or @refType='rft06' or @refType='rft10' or @refType='rft51' or @refType='rft52' or @refType='rft53' or @refType='rft54'">
  			<xsl:choose>
  				<xsl:when test="refs/externalPubRef/externalPubRefIdent/externalPubCode">
	  				<xsl:text>(SEE ATA </xsl:text>
	  				<xsl:value-of select="refs/externalPubRef/externalPubRefIdent/externalPubCode"/>
	  				<xsl:text> </xsl:text>
	  				<xsl:call-template name="IPD_ReferToTypeText"/>
	  				<xsl:text>)</xsl:text>
  				</xsl:when>
  				<xsl:when test="refs/dmRef">
	  				<xsl:text>(SEE IPL FIG </xsl:text>
	  				<xsl:call-template name="IPD_ReferToFigureDmRef"/>
	  				<xsl:text> </xsl:text>
	  				<xsl:call-template name="IPD_ReferToTypeText"/>
	  				<xsl:text>)</xsl:text>
  				</xsl:when>
  				<xsl:when test="catalogSeqNumberRef/@assyCode=ancestor::catalogSeqNumber/@assyCode
  					and catalogSeqNumberRef/@subSubSystemCode=ancestor::catalogSeqNumber/@subSubSystemCode
  					and catalogSeqNumberRef/@subSystemCode=ancestor::catalogSeqNumber/@subSystemCode
  					and catalogSeqNumberRef/@systemCode=ancestor::catalogSeqNumber/@systemCode">
	  				<xsl:text>(SEE IPL FIG </xsl:text>
	  				<xsl:call-template name="IPD_ReferToFigNums"/>
	  				<xsl:text> </xsl:text>
	  				<xsl:call-template name="IPD_ReferToTypeText"/>
	  				<xsl:text>)</xsl:text>
  				</xsl:when>
  				<xsl:otherwise>
  					<xsl:text>(SEE CMM </xsl:text> 
  					<xsl:value-of select="catalogSeqNumberRef/@systemCode"/>
  					<xsl:text>-</xsl:text> 
  					<xsl:value-of select="catalogSeqNumberRef/@subSystemCode"/>
  					<xsl:value-of select="catalogSeqNumberRef/@subSubSystemCode"/>
  					<xsl:text>-</xsl:text> 
  					<xsl:value-of select="catalogSeqNumberRef/@assyCode"/>
	  				<xsl:text> </xsl:text>
	  				<xsl:call-template name="IPD_ReferToTypeText"/>
  					<xsl:text>)</xsl:text> 
  				</xsl:otherwise>
  			</xsl:choose>
  		</xsl:when>
  		<xsl:when test="@refType='rft03'">
  			<xsl:choose>
  				<xsl:when test="refs/externalPubRef/externalPubRefIdent/externalPubCode">
  					<xsl:text>(SEE ATA </xsl:text> 
  					<xsl:value-of select="refs/externalPubRef/externalPubRefIdent/externalPubCode"/>
  					<xsl:text> FOR OPT MFG PN)</xsl:text> 
  				</xsl:when>
  				<xsl:otherwise>
  					<xsl:text>(SEE IPL FIG </xsl:text> 
	  				<xsl:call-template name="IPD_ReferToFigNums"/>
  					<xsl:text> FOR OPT MFG PN)</xsl:text> 
  				</xsl:otherwise>
  			</xsl:choose>
  		</xsl:when>
  		<xsl:otherwise>
			<xsl:if test="refs/externalPubRef/externalPubRefIdent/externalPubCode">
				<xsl:text>(SEE ATA </xsl:text> 
				<xsl:value-of select="refs/externalPubRef/externalPubRefIdent/externalPubCode"/>
				<xsl:text>)</xsl:text> 
			</xsl:if>
  		</xsl:otherwise>
  	</xsl:choose>
  	
	</fo:block>
  </xsl:template>

  <!-- As in Styler, infer the text for the reference type based on the refType attribute -->
  <xsl:template name="IPD_ReferToTypeText">
  	<xsl:choose>
  		<xsl:when test="@refType='rft01'">
  			<xsl:text>FOR NHA</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft02'">
  			<xsl:text>FOR DETAILS</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft06'">
  			<xsl:text>FOR REMOVAL</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft10'">
  			<xsl:text>FOR BKDN</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft51'">
  			<xsl:text>FOR FIELD MAINT BKDN</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft52'">
  			<xsl:text>FOR INSTALLATION</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft53'">
  			<xsl:text>FOR PLMB INSTL</xsl:text>
  		</xsl:when>
  		<xsl:when test="@refType='rft54'">
  			<xsl:text>FOR FURTHER BKDN</xsl:text>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:text>UNKNOWN refType</xsl:text>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>


  <!-- Based on the Styler UFE of the same name, calculate what figure number to use based on the pmEntry/dmRef structure. -->
  <!-- The referTo element is in context. -->
  <xsl:template name="IPD_ReferToFigureDmRef">
  	<xsl:variable name="dmCodeRef">
  		<xsl:call-template name="build-dmCode-refId">
  			<!-- TODO: Can there be more than one dmRef? It doesn't look like Styler handles that case... -->
  			<xsl:with-param name="dmCode" select="refs/dmRef[1]/dmRefIdent/dmCode"/>
  		</xsl:call-template>
  	</xsl:variable>
  	
  	<xsl:choose>
  		<xsl:when test="/pm/content/pmEntry[@pmEntryType='pmt75']//dmodule[@id=$dmCodeRef]">
			<!-- <fo:inline color="red">FOUND: dmodule with id '<xsl:value-of select="$dmCodeRef"/>'</fo:inline> -->
			<!-- Calculate figure number and variant based on the structure: -->
			<xsl:variable name="figureNumber" select="count(/pm/content/pmEntry[@pmEntryType='pmt75']//dmodule[@id=$dmCodeRef]/ancestor::pmEntry[1]/preceding-sibling::pmEntry) + 1"/>
			<xsl:variable name="variant" select="count(/pm/content/pmEntry[@pmEntryType='pmt75']//dmodule[@id=$dmCodeRef]/ancestor::dmContent[1]/preceding-sibling::dmContent) + 1"/>
			<xsl:variable name="variantStr">
				<!-- The first figure (in the first dmContent) has no variant. The next one starts at "A". -->
				<xsl:if test="$variant &gt; 1">
					<xsl:number format="A" value="$variant - 1"/>
				</xsl:if>
			</xsl:variable>
			<xsl:value-of select="$figureNumber"/><xsl:value-of select="$variantStr"/>
  		</xsl:when>
  		<xsl:otherwise>
			<fo:inline color="red">ERROR: dmodule with id '<xsl:value-of select="$dmCodeRef"/>' not found for referTo/dmRef</fo:inline>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>

  <!-- Based on the Styler UFE of the same name, outputs one or more figure references. -->
  <!-- The referTo element is in context. -->
  <xsl:template name="IPD_ReferToFigNums">
  	<xsl:variable name="numFigs" select="count(catalogSeqNumberRef)"/>
	
	<!-- <fo:block margin-left="{$iplNoteMargin}"> -->
	
  	<xsl:choose>
  		<xsl:when test="$numFigs = 1">
  			<xsl:call-template name="getFigNum">
  				<xsl:with-param name="index">1</xsl:with-param>
  			</xsl:call-template>
  		</xsl:when>
  		<xsl:when test="$numFigs = 2">
  			<xsl:call-template name="getFigNum">
  				<xsl:with-param name="index">1</xsl:with-param>
  			</xsl:call-template>
  			<xsl:text> AND IPL FIG </xsl:text>
  			<xsl:call-template name="getFigNum">
  				<xsl:with-param name="index">2</xsl:with-param>
  			</xsl:call-template>
  		</xsl:when>
  		<xsl:otherwise>
  			<!-- <xsl:text>Multiple figures (TODO)</xsl:text> -->
  			<xsl:value-of select="helper:getFigureRefs(catalogSeqNumberRef)"/>
  		</xsl:otherwise>
  	</xsl:choose>
  	
  	<!-- </fo:block> -->
  </xsl:template>
  
  <!-- The referTo element is in context. -->
  <xsl:template name="getFigNum">
  	<xsl:param name="index"/>
  	<xsl:variable name="figNum" select="catalogSeqNumberRef[number($index)]/@figureNumber"/>
  	<xsl:variable name="figNumVariant" select="catalogSeqNumberRef[number($index)]/@figureNumberVariant"/>
  	<xsl:variable name="fullFigNum">
  		<xsl:value-of select="number($figNum)"/><xsl:value-of select="$figNumVariant"/>
  	</xsl:variable>
  	<xsl:variable name="itemNum" select="catalogSeqNumberRef[number($index)]/@item"/>
  	<xsl:variable name="itemNumVariant" select="catalogSeqNumberRef[number($index)]/@itemVariant"/>
  	<xsl:variable name="fullItemNum">
  		<xsl:value-of select="number($itemNum)"/><xsl:value-of select="$itemNumVariant"/>
  	</xsl:variable>
  	
  	<xsl:choose>
  		<xsl:when test="$itemNum = '000' or $itemNum = '001'">
		  	<xsl:value-of select="$fullFigNum"/>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:value-of select="$fullFigNum"/><xsl:text> ITEM </xsl:text><xsl:value-of select="$fullItemNum"/>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
  
  <xsl:template name="ipdGenericPartData">
  	<!-- Output the genericPartData entries, except those that are output separately or hidden. -->
  	<!-- ('csd', 'geoloc','chgnbr', 'chgtyp', 'chgcond', 'opt', and 'eqdes' are hidden) -->
  	<!-- Now rd and rdi are also hidden; they are output separately. -->
    <xsl:apply-templates select="genericPartDataGroup/genericPartData[@genericPartDataName!='dd'
    	 and @genericPartDataName!='csd'
    	 and @genericPartDataName!='geoloc'
    	 and @genericPartDataName!='chgnbr'
    	 and @genericPartDataName!='chgtyp'
    	 and @genericPartDataName!='chgcond'
    	 and @genericPartDataName!='opt'
    	 and @genericPartDataName!='eqdes'
    	 and @genericPartDataName!='rd'
    	 and @genericPartDataName!='rdi'
    	 ]"/>
  </xsl:template>

  <!-- Output the Short Name (if it exists). Should be called with itemSeqNumber in context. -->
  <xsl:template name="ipdShortName">
  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
	<xsl:variable name="shortName">
		<xsl:choose>
			<xsl:when test="/pm/commonRepository/partRepository/partSpec">
				<xsl:value-of select="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/shortName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="partSegment/itemIdentData/shortName"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$shortName">
	    <fo:block margin-left="22pt">
	      <!-- Looks like it's always 22pt regardless of the "indentation" attribute (ancestor::catalogSeqNumber[1]/@indenture) -->
	      <!-- <xsl:call-template name="text_indentation">
	        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
	      </xsl:call-template> -->
	      <xsl:value-of select="$shortName"/>
	    </fo:block>
	</xsl:if>  	
  </xsl:template>
  
  <!-- Output the Description block (including leading dots if required). Should be called with itemSeqNumber in context. -->
  <xsl:template name="ipdDescription">
  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
  	
    <fo:block text-align-last="justify">
      <xsl:call-template name="block_and_text_indentation"/>
      <xsl:call-template name="descriptionText"/>
      <fo:leader leader-pattern="dots"/>
      <!-- <fo:leader leader-pattern="space"/> -->
    </fo:block>
  </xsl:template>
  
  <!-- Gets the Description text (may include inline fo for red error highlighting). Should be called with itemSeqNumber in context. -->
  <xsl:template name="descriptionText">
  	<xsl:variable name="mfrCode" select="partRef/@manufacturerCodeValue"/>
  	<xsl:variable name="partNo" select="partRef/@partNumberValue"/>
  	
    <xsl:choose>
    	<!-- Force text to "DELETED" for deleted items -->
      	<xsl:when test="@changeType='delete'">DELETED</xsl:when>
      	<!-- If there is a parts repository, get the part description from there. -->
      	<xsl:when test="/pm/commonRepository/partRepository/partSpec">
      		<xsl:choose>
      			<!-- Use the partKeyword if available, otherwise descrForPart -->
      			<xsl:when test="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/partKeyword">
      				<xsl:value-of select="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/partKeyword"/>
      			</xsl:when>
      			<xsl:when test="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/descrForPart">
      				<xsl:value-of select="/pm/commonRepository/partRepository/partSpec[partIdent/@manufacturerCodeValue=$mfrCode][partIdent/@partNumberValue=$partNo]/itemIdentData/descrForPart"/>
      			</xsl:when>
      			<xsl:otherwise>
      				<fo:inline color="red">ERROR: DESCR not found for <xsl:value-of select="$mfrCode"/>/<xsl:value-of select="$partNo"/></fo:inline>
      			</xsl:otherwise>
      		</xsl:choose>
      	</xsl:when>
      	<xsl:otherwise>
      		<xsl:choose>
      			<!-- Use the partKeyword if available, otherwise descrForPart -->
      			<xsl:when test="partSegment/itemIdentData/partKeyword">
      				<xsl:value-of select="partSegment/itemIdentData/partKeyword"/>
      			</xsl:when>
      			<xsl:when test="partSegment/itemIdentData/descrForPart">
      				<xsl:value-of select="partSegment/itemIdentData/descrForPart"/>
      			</xsl:when>
      			<xsl:otherwise>
      				<fo:inline color="red">ERROR: DESCR not found in partSegment</fo:inline>
      			</xsl:otherwise>
      		</xsl:choose>
      	</xsl:otherwise>
    </xsl:choose>
  
  </xsl:template>
  
  <!-- RS: KWD is like the Description Block in Styler. But Styler pulls the description from -->
  <!-- different places depending an whether there is a parts repository. So make a new named template -->
  <!-- for this (see ipdDescription above). Leave this (KWD) for reference for now. -->
  <xsl:template match="KWD">
    <fo:block text-align-last="justify">
      <xsl:call-template name="block_and_text_indentation"/>
      <xsl:apply-templates/>
      <!-- Replaced leader-pattern="dots" with "-" (when there is no adt) and spaces (leader-pattern="space") per Mantis #13639 -->
      <!--
        <fo:leader leader-pattern="dots"/>
      -->
      <xsl:choose>
        <xsl:when test="../following-sibling::* and following-sibling::ADT">
          <!-- Render the hyphen if there is any other nomenclature. -->
          <xsl:text>-</xsl:text>
        </xsl:when>
        <xsl:otherwise><!-- Don't output the hyphen --></xsl:otherwise>
      </xsl:choose>
      <fo:leader leader-pattern="space"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="ADT">
    <!--<fo:block><xsl:apply-templates/></fo:block>-->
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="self::* !=''">
        <xsl:apply-templates/>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="ESDS">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="PRTGRP">
    <xsl:message>[warning] - PRTGRP found in ipl.</xsl:message>
    <xsl:apply-templates select="ALPRTMFR"/>
  </xsl:template>

  <xsl:template match="MFR[parent::IPLNOM]">
    <xsl:if test="self::* !=''">
      <fo:block>
        <xsl:call-template name="text_indentation">
          <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
        </xsl:call-template>
        <xsl:text>(V</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template match="AFP">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="AFPMFR">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="AFP"/>
      <xsl:text> V</xsl:text>
      <xsl:value-of select="MFR"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="ALPRTMFR">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(ALTN PN: </xsl:text>
      <xsl:apply-templates select="ALTPN"/>
      <xsl:value-of select="concat(' V', MFR)"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="ALTPN">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="CSW">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(COMPUTER SW: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="EQDES">
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::EQDES)">
        <fo:block keep-with-previous.within-page="always" keep-together.within-page="auto">
          <xsl:call-template name="text_indentation">
            <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
          </xsl:call-template>
        <xsl:variable name="sortedRDI"><!-- CJM : OCSHONSS-475 : This variable is used to hold the sorted RDI list -->
          <!-- CJM : OCSHONSS-475 : 5 steps out seem to catch everything, but to be safe I set to 13 steps -->
          <xsl:for-each select="following-sibling::EQDES|self::EQDES">
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()-6])" order="ascending" data-type="text"/>
            <xsl:sort select="xs:integer(concat('0', tokenize(concat(RDI, 'A'), '[a-z,A-Z]+')[last()-6]))" order="ascending" data-type="number"/>
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()-5])" order="ascending" data-type="text"/>
            <xsl:sort select="xs:integer(concat('0', tokenize(concat(RDI, 'A'), '[a-z,A-Z]+')[last()-5]))" order="ascending" data-type="number"/>
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()-4])" order="ascending" data-type="text"/>
            <xsl:sort select="xs:integer(concat('0', tokenize(concat(RDI, 'A'), '[a-z,A-Z]+')[last()-4]))" order="ascending" data-type="number"/>
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()-3])" order="ascending" data-type="text"/>
            <xsl:sort select="xs:integer(concat('0', tokenize(concat(RDI, 'A'), '[a-z,A-Z]+')[last()-3]))" order="ascending" data-type="number"/>
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()-2])" order="ascending" data-type="text"/>
            <xsl:sort select="xs:integer(concat('0', tokenize(concat(RDI, 'A'), '[a-z,A-Z]+')[last()-2]))" order="ascending" data-type="number"/>
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()-1])" order="ascending" data-type="text"/>
            <xsl:sort select="xs:integer(concat('0', tokenize(concat(RDI, 'A'), '[a-z,A-Z]+')[last()-1]))" order="ascending" data-type="number"/>
            <xsl:sort select="xs:string(tokenize(concat(RDI, 'A'), '[0-9]+')[last()])" order="ascending" data-type="text"/>
            <RDI><xsl:value-of select="RDI"/></RDI>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$sortedRDI/RDI"><!-- CJM : OCSHONSS-475 : Looping over the sorted RDI list -->
          <xsl:variable name="precedingValue2" as="xs:integer"><!-- CJM : OCSHONSS-475 : This variable holds the numeric value for the node 2 before current -->
              <xsl:choose>
                <xsl:when
                  test="count(ancestor-or-self::RDI/preceding-sibling::RDI) > 1 and tokenize(ancestor-or-self::RDI/preceding-sibling::RDI[2], '[a-z,A-Z]+')[last()] != ''">
                  <xsl:value-of
                    select="xs:integer(tokenize(ancestor-or-self::RDI/preceding-sibling::RDI[2], '[a-z,A-Z]+')[last()])"
                  />
                </xsl:when>
                <xsl:otherwise>-1</xsl:otherwise>
              </xsl:choose>
          </xsl:variable>
          <xsl:variable name="precedingValue" as="xs:integer"><!-- CJM : OCSHONSS-475 : This variable holds the numeric value for the previous node -->
            <xsl:choose>
              <xsl:when
                test="count(ancestor-or-self::RDI/preceding-sibling::RDI) > 0 and tokenize(ancestor-or-self::RDI/preceding-sibling::RDI[1], '[a-z,A-Z]+')[last()] != ''">
                <xsl:value-of
                  select="xs:integer(tokenize(ancestor-or-self::RDI/preceding-sibling::RDI[1], '[a-z,A-Z]+')[last()])"
                />
              </xsl:when>
              <xsl:otherwise>-1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="currentValue" as="xs:integer"><!-- CJM : OCSHONSS-475 : This variable holds the numeric value for the current node-->
            <xsl:choose>
              <xsl:when test="tokenize(., '[a-z,A-Z]')[last()] != ''">
                <xsl:value-of select="xs:integer(tokenize(., '[a-z,A-Z]+')[last()])"/>
              </xsl:when>
              <xsl:otherwise>-1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="nextValue" as="xs:integer"><!-- CJM : OCSHONSS-475 : This variable holds the numeric value for the next node -->
            <xsl:choose>
              <xsl:when
                test="count(ancestor-or-self::RDI/following-sibling::RDI) > 0 and tokenize(ancestor-or-self::RDI/following-sibling::RDI[1], '[a-z,A-Z]+')[last()] != ''">
                <xsl:value-of
                  select="xs:integer(tokenize(ancestor-or-self::RDI/following-sibling::RDI[1], '[a-z,A-Z]+')[last()])"
                />
              </xsl:when>
              <xsl:otherwise>-1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="position() = 1"><!-- CJM : OCSHONSS-475 : If the current RDI is the first in the sorted list, output it -->
              <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:when test="$precedingValue + 1 = $currentValue"><!-- CJM : OCSHONSS-475 : calculating range -->
              <xsl:if test="$nextValue - 1 != $currentValue"><!-- CJM : OCSHONSS-475 : else don't output anything and continue the range -->
                <xsl:choose>
                  <xsl:when test="$precedingValue2 + 2 = $currentValue"><!-- CJM : OCSHONSS-475 : if range is going to end, close the range --><!-- WR: only if the range is larger than two values -->
                    <xsl:apply-templates select="." mode="close-range"/>
                  </xsl:when>
                  <xsl:otherwise><!-- WR: If the range is not larger that two values just list the RDI -->
                    <xsl:apply-templates select="." mode="not-first"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise><!-- CJM : OCSHONSS-475 : start new range, or just list the RDI -->
              <xsl:apply-templates select="." mode="not-first"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- CJM : OCSHONSS-475 : Used for troubleshooting -->
          <!--<xsl:message>### <xsl:value-of select="$precedingValue2"/> - <xsl:value-of
            select="$precedingValue"/> - <xsl:value-of select="$currentValue"/> - <xsl:value-of
              select="$nextValue"/></xsl:message>-->
        </xsl:for-each>
      </fo:block>
      </xsl:when>
      <xsl:otherwise/><!-- CJM : OCSHONSS-475 : Do nothing after first EQDES node found.  All processing is done on first node -->
    </xsl:choose>     
  </xsl:template>

  <xsl:template match="RDI" mode="not-first">
    <xsl:text>,&#x200B;</xsl:text>
    <xsl:apply-templates select="."/>
  </xsl:template>

<!-- CJM : OCSHONSS-475 : Added close-range mode template for when the range needs to be closed -->
  <xsl:template match="RDI" mode="close-range">
    <xsl:text> thru </xsl:text>
    <xsl:apply-templates select="."/>
  </xsl:template>

  <xsl:template match="RDI">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="GEOLOC"/>

  <xsl:template match="MDL">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(MOD </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="MP">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(MATCHED SET WITH ITEM: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="MSC">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="LODMFR">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(MAY BE SUBST: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> V</xsl:text>
      <xsl:value-of select="MFR"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="PSPMFR">
    <!--PSP and MFR are required per the DTD.-->
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(PREF PN: </xsl:text>
      <xsl:value-of select="PSP"/>
      <xsl:text> V</xsl:text>
      <xsl:value-of select="MFR"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="OPN">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(OVERLENGTH PN: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="OPTMFR">
    <!--OPT and MFR are required per the DTD.-->
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(OPT MFR: </xsl:text>
      <xsl:value-of select="OPT"/>
      <xsl:text> V</xsl:text>
      <xsl:value-of select="MFR"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="CSDMFR">
    <!--CSD and MFR are required per the DTD.-->
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(CSD: </xsl:text>
      <xsl:value-of select="CSD"/>
      <xsl:text> V</xsl:text>
      <xsl:value-of select="MFR"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>


  <xsl:template match="OSC">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(OPT SUPPL CODE: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="OVUND">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(OVER/UNDER SIZED PART: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="PCD">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(LEGEND: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="RP[1]">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <!--<xsl:text>(REPLACED BY ITEM </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>-->
      <xsl:if test="count(preceding-sibling::RP) = 0">
        <xsl:text>(REPLACED BY ITEM: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::RP) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::RP">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::RP) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="RP[position()>1]"/>

  <xsl:template match="RPS[1]">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::RPS) = 0">
        <xsl:text>(REPLACES ITEM: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::RPS) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::RPS">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::RPS) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="RPS[position()>1]"/>

  <xsl:template match="REFINT[parent::IPLNOM]">
    <xsl:variable name="refid" select="@REFID"/>
    <xsl:variable name="idref" select="/CMM/IPL/DPLIST/FIGURE[@KEY = $refid]/GRAPHIC/SHEET[1]/@KEY"/>
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <fo:basic-link internal-destination="{$idref}">
        <xsl:text>FIG. </xsl:text>
        <xsl:value-of select="/CMM/IPL/DPLIST/FIGURE[@KEY = $refid]/@FIGNBR"/>
      </fo:basic-link>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="RWD">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(RWK/VAR DWG NO.: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="SD[1]">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::SD) = 0">
        <xsl:text>(SUPERSEDED BY ITEM: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::SD) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::SD">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::SD) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="SD[position()>1]"/>

  <xsl:template match="SDES[1]">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::SDES) = 0">
        <xsl:text>(SUPERSEDES ITEM: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::SDES) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::SDES">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::SDES) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="SDES[position()>1]"/>

  <xsl:template match="SPL">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="SWR">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(SW DWG REF: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="UOA">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(USED ON ASSY: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="SBS[CHGTYP = 'SB'][CHGCOND = 'PRE'][1]">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'PRE']) = 0">
        <xsl:text>(PRE SB </xsl:text>
        <xsl:value-of select="CHGNBR"/>
        <xsl:if test="count(following-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'PRE']) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'PRE']">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="CHGNBR"/>
        <xsl:if test="count(following-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'PRE']) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="SBS[CHGTYP = 'SB'][CHGCOND = 'PRE'][position()>1]"/>

  <xsl:template match="SBS[CHGTYP = 'SB'][CHGCOND = 'POST'][1]">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'POST']) = 0">
        <xsl:text>(POST SB </xsl:text>
        <xsl:value-of select="CHGNBR"/>
        <xsl:if test="count(following-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'POST']) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'POST']">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="CHGNBR"/>
        <xsl:if test="count(following-sibling::SBS[CHGTYP = 'SB'][CHGCOND = 'POST']) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="SBS[CHGTYP = 'SB'][CHGCOND = 'POST'][position()>1]"/>

  <xsl:template match="SBS[CHGTYP != 'SB' or (CHGCOND != 'PRE' and CHGCOND != 'POST')]">
    <!--Any SBS that isn't SB or PRE/POST will not get grouped.-->
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:value-of select="CHGCOND"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="CHGTYP"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="CHGNBR"/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="IPR">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(COMPLETE PN: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="DD">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="UOI">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::UOI) = 0">
        <xsl:text>(USED ON ITEM: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::UOI) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::UOI">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::UOI) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="UOI[position()>1]"/>

  <xsl:template match="UWI">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::UWI) = 0">
        <xsl:text>(USED WITH ITEM: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::UWI) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::UWI">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::UWI) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="UWI[position()>1]"/>

  <xsl:template match="UWP">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:if test="count(preceding-sibling::UWP) = 0">
        <xsl:text>(USED WITH PN: </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::UWP) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:for-each select="following-sibling::UWP">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
        <xsl:if test="count(following-sibling::UWP) = 0">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </fo:block>
  </xsl:template>
  <xsl:template match="UWP[position()>1]"/>

  <xsl:template match="FDS">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(SEE </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> FOR DETAILS)</xsl:text>
    </fo:block>
  </xsl:template>
  

  <xsl:template match="FNHA">
    <fo:block>
      <xsl:call-template name="text_indentation">
        <xsl:with-param name="indentValue" select="./ancestor::ITEMDATA/@INDENT"/>
      </xsl:call-template>
      <xsl:text>(SEE </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> FOR NHA)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template name="figure-caption-dplist">
    <fo:block text-align="center" font-family="Arial" font-weight="bold" page-break-before="avoid">
      <xsl:text>DPL Figure </xsl:text>
      <xsl:value-of select="./ancestor::FIGURE/@FIGNBR"/>
      <xsl:text>. (Sheet </xsl:text>
      <xsl:number format="1" value="position()"/>
      <xsl:text> of </xsl:text>
      <xsl:value-of select="count(./parent::GRAPHIC/SHEET)"/>
      <xsl:text>) </xsl:text>
      <!--<xsl:value-of select="./ancestor::FIGURE[1]/TITLE"/>-->
      <xsl:apply-templates select="./ancestor::FIGURE[1]/TITLE"/>
    </fo:block>
  </xsl:template>

  <xsl:template match="VENDLIST/TITLE"/>
  <xsl:template match="FIGURE/TITLE"/>
  <xsl:template match="DPLIST/TITLE"/>

</xsl:stylesheet>
