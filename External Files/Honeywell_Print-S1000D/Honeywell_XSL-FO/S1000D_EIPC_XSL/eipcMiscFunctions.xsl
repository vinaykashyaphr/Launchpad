<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table"
  xmlns:xtbl="com.nwalsh.xalan.Table"
  xmlns:helper="java:com.sonovision.saxonext.S1000DHelper">
  <!-- S1000DHelper is our Saxon extension to handle complex list building (as in RD/RDI values, etc.). -->

  <!-- RS: Called with figure as the context node. -->
  <xsl:template name="calc-figure-number">
  	<xsl:call-template name="calc-figure-number-param">
  		<xsl:with-param name="figure" select="."/>
  	</xsl:call-template>
  </xsl:template>
  
  <!-- Overridden to calculate figure in the DPLIST correctly -->
  <!-- RS: New version of the original which lets you supply the figure as a parameter (for use in legends). -->
  <xsl:template name="calc-figure-number-param">
  	<xsl:param name="figure"/>
    <!-- Tables in PGBLK 0 and 1 are numbered starting with 1 -->
    <!-- Tables inside of PGBLK are numbered start at 1 + @PGBLKNBR -->
    <xsl:variable name="figure-number-base">
      <xsl:choose>
        <!-- Appendix Support -->
        <!--<xsl:when test="number($figure/ancestor::PGBLK/@PGBLKNBR) >= 17000">
          <xsl:value-of select="'0'"/>
        </xsl:when>-->
        <xsl:when test="$figure/ancestor::illustratedPartsCatalog">
          <xsl:value-of select="'0'"/>
        </xsl:when>
        <!-- Deal with missing or empty startat values (was causing an XSL error) -->
        <xsl:when test="not($figure/ancestor::pmEntry[@startat]) or $figure/ancestor::pmEntry[@startat][1]/@startat=''">
          <xsl:value-of select="'0'"/>
        </xsl:when>
        <xsl:when test="($figure/ancestor::pmEntry[@startat])[1]/@startat &gt; 1">
          <xsl:value-of select="number(($figure/ancestor::pmEntry[@startat])[1]/@startat) - 1"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="figure-position">
      <xsl:choose>
        <xsl:when test="$figure/ancestor::illustratedPartsCatalog">
          <xsl:value-of select="count($figure/ancestor::pmEntry[1]/preceding-sibling::pmEntry) + 1"/>
          <!-- <xsl:message>Calculating IPL figure position: <xsl:value-of select="count($figure/ancestor::pmEntry[1]/preceding-sibling::pmEntry) + 1"/></xsl:message> -->
        </xsl:when>
        <xsl:when test="ancestor::pmEntry">
          <xsl:value-of select="1 + count($figure/ancestor::pmEntry//figure intersect preceding::figure)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>WARNING: Calculating simple figure number [shouldn't normally happen!]</xsl:message>
          <xsl:value-of select="1 + count($figure/preceding::figure)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="$figure/ancestor-or-self::pmEntry/@pmEntryType='pmt58'">
          <xsl:text>INTRO-</xsl:text>
        </xsl:when>
        <!-- Appendix Support -->
        <!-- 
        <xsl:when test="number($figure/ancestor-or-self::PGBLK/@PGBLKNBR) >= 17000">
          <xsl:call-template name="calculateCMMAppendixNumber"/>
          <xsl:text>-</xsl:text>
        </xsl:when> -->
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="suffix">
      <xsl:choose>
        <xsl:when test="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName">
      	  <xsl:text>-</xsl:text><xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName"/>
        </xsl:when>
        <xsl:when test="$documentType='irm' and number($figure/ancestor-or-self::PGBLK/@CONFNBR) >= 1000">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="$figure/ancestor-or-self::PGBLK/EFFECT"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$documentType = 'acmm'">
        <xsl:value-of select="$figure-position"/>
      </xsl:when>
      <xsl:when test="$figure/ancestor::illustratedPartsCatalog">
      	<xsl:variable name="variantNum" select="count($figure/ancestor::dmContent[1]/preceding-sibling::dmContent[dmodule/content/illustratedPartsCatalog/figure])"/>
      	<xsl:choose>
      		<xsl:when test="$variantNum &gt; 0">
      			<!-- This will needs to to skip "I" and "O"; we use a Java extension for this... -->
      			<xsl:value-of select="$figure-position"/>
      			<!--  <xsl:number value="$variantNum" format="A"/> -->
      			<xsl:value-of select="helper:getVariantCode($variantNum)"/>
      		</xsl:when>
      		<xsl:otherwise>
		        <xsl:value-of select="$figure-position"/>
      		</xsl:otherwise>
      	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($prefix,number($figure-number-base + $figure-position),$suffix)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-table-number">
    <!-- Tables in PGBLK 0 and 1 are numbered starting with 1 -->
    <!-- Tables inside of PGBLK are numbered start at 1 + @PGBLKNBR -->
    <xsl:variable name="table-number-base">
      <xsl:choose>
        <xsl:when test="not(ancestor::pmEntry[last()]/@startat) or ancestor::pmEntry[last()]/@startat=''">
          <xsl:value-of select="'0'"/>
        </xsl:when>
        <xsl:when test="ancestor::pmEntry[last()]/@startat &gt; 1">
          <xsl:value-of select="number(ancestor::pmEntry[last()]/@startat) - 1"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="table-position">
      <xsl:choose>
        <!-- Tables inside <gdesc> should not be counted -->
        <xsl:when test="$documentType = 'acmm'">
          <!-- <xsl:value-of select="1 + count(preceding::TABLE[TITLE][not (ancestor::GDESC)])"/> -->
          <xsl:value-of select="1 + count(preceding::table[title])"/>
        </xsl:when>
        <xsl:when test="ancestor::pmEntry">
          <xsl:value-of select="1 + count(ancestor::pmEntry[last()]//table[title] intersect preceding::table[title])"/>
        </xsl:when>
        <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt58']">
          <xsl:value-of select="1 + count(ancestor::pmEntry[last()]//table[title] intersect preceding::table[title])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1 + count(preceding::table[title])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="table-prefix">
      <xsl:choose>
        <!-- <xsl:when test="./ancestor::TRANSLTR"> -->
        <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt52']">
          <xsl:text>TI-</xsl:text>
        </xsl:when>
        <!-- <xsl:when test="ancestor::PGBLK/@PGBLKNBR = '0'"> -->
        <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt58']">
          <xsl:text>INTRO-</xsl:text>
        </xsl:when>
        <!-- Appendix Support -->
        <xsl:when test="number(ancestor-or-self::PGBLK/@PGBLKNBR) >= 17000">
          <xsl:call-template name="calculateCMMAppendixNumber"/>
          <xsl:text>-</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="table-suffix">
      <xsl:choose>
        <xsl:when test="$documentType='irm' and number(ancestor-or-self::PGBLK/@CONFNBR) >= 1000">
          <xsl:text>-</xsl:text>
          <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- RS: Add section suffix -->
      <xsl:when test="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName">
       <xsl:value-of select="concat($table-prefix,number($table-number-base + $table-position))"/><xsl:text>-</xsl:text><xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName"/>
      </xsl:when>
      <xsl:when test="$documentType = 'acmm'">
        <xsl:value-of select="number($table-position)"/>
      </xsl:when>
        <!-- <xsl:when test="./ancestor::TRANSLTR"> -->
      <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt52']">
        <xsl:value-of select="concat('TI-', number($table-number-base + $table-position))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($table-prefix,number($table-number-base + $table-position),$table-suffix)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calculateCMMAppendixNumber">
    <!-- Appendix Support -->
    <xsl:number value="count(ancestor-or-self::PGBLK/preceding-sibling::PGBLK[@PGBLKNBR >= 17000]) + 1" format="A"/>
  </xsl:template>

  <!-- Expects graphic as current context -->
  <xsl:template name="figure-caption">
    <xsl:param name="graphic-margin-left" select="'0in'"/>
    
    <xsl:variable name="caption-id">
      <xsl:value-of select="concat('figcap_',@id)"/>
    </xsl:variable>

    <xsl:variable name="revised-title">
      <xsl:for-each select="parent::figure/title">
        <xsl:choose>
          <xsl:when test="(not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete'))
			or ( not(parent::figure/@changeMark='0')
			   and (parent::figure/@changeType='add' or parent::figure/@changeType='modify' or parent::figure/@changeType='delete'))">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <!-- [ATA]
          <xsl:when test="ancestor::GRAPHIC[preceding-sibling::processing-instruction()[1] = '_rev']">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:when test="ancestor::SHEET[preceding-sibling::processing-instruction()[1] = '_rev']">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:when test="preceding-sibling::processing-instruction()[1] = '_rev'">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:when test="descendant::processing-instruction() = '_rev'">
            <xsl:text>true</xsl:text>
          </xsl:when> -->
          <xsl:otherwise>
            <xsl:text>false</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <fo:block-container keep-with-previous.within-page="always">
      <xsl:if test="ancestor-or-self::SHEET[translate(@IMGAREA,$upperCase,$lowerCase) = 'ap']">
        <xsl:attribute name="position" select="'absolute'"/>
        <xsl:attribute name="top" select="'8.25in'"/>
        <xsl:attribute name="left" select="'0in'"/>
        <xsl:choose>
          <xsl:when test="ancestor::MFMATR">
            <xsl:attribute name="page-break-after">auto</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="page-break-after">always</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <!-- <xsl:if test="ancestor-or-self::SHEET[translate(@IMGAREA,$upperCase,$lowerCase) = 'hl']"> -->
      <xsl:if test="ancestor-or-self::graphic[@reproductionWidth='355.6 mm']">
        <xsl:attribute name="position" select="'absolute'"/>
        <xsl:attribute name="top" select="'8.25in'"/>
        <xsl:attribute name="left" select="$graphic-margin-left"/>
        <xsl:attribute name="width" select="'7in'"/>
        <xsl:choose>
          <xsl:when test="ancestor::MFMATR">
            <xsl:attribute name="page-break-after">auto</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="page-break-after">always</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <fo:block font-weight="bold" text-align="center" font-family="Arial" id="{$caption-id}" keep-with-previous.within-page="always" padding-before="4pt">
        <!-- Break after figure title in HL graphics with gdesc's. -->
        <xsl:if test="translate(@IMGAREA,$upperCase,$lowerCase) = 'hl' and exists(GDESC)">
          <xsl:message>FOLDOUT HAS A GDESC!!</xsl:message>
          <xsl:attribute name="page-break-after">always</xsl:attribute>
        </xsl:if>
        <xsl:if test="$revised-title = 'true'">
          <xsl:call-template name="cbStart"/>
        </xsl:if>
        <xsl:choose>
          <!-- <xsl:when test="ancestor::FIGURE"> -->
          <xsl:when test="ancestor::illustratedPartsCatalog">
            <xsl:text>DPL Figure </xsl:text>
            <!-- <xsl:value-of select="ancestor::FIGURE/@FIGNBR"/> -->
            <!-- Probably need to change this for a special IPL figure number calculating template: -->
            <xsl:call-template name="calc-figure-number"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Figure </xsl:text>
            <xsl:call-template name="calc-figure-number"/>
          </xsl:otherwise>
        </xsl:choose>
        <!-- For DEBUG print the GNBR in the figure caption -->
        <xsl:if test="number($DEBUG) = 1">
          <fo:inline font-weight="bold" color="#00ffff">
            <xsl:value-of select="concat(' [',@GNBR,'] ')"/>
          </fo:inline>
        </xsl:if>
        <xsl:text>. </xsl:text>
        <xsl:variable name="graphicCount" select="count(parent::figure/graphic)"/>
        <xsl:if test="$graphicCount > 1">
          <xsl:text>(Sheet </xsl:text><xsl:number format="1" value="1 + count(preceding-sibling::graphic)"/>
	      <xsl:text> of </xsl:text>
	      <xsl:value-of select="count(parent::figure/graphic)"/><xsl:text>) </xsl:text>
        </xsl:if>
        <!-- <xsl:if test="./parent::GRAPHIC/TITLE"> -->
        <xsl:if test="parent::figure/title">
          <xsl:apply-templates select="parent::figure/title" mode="graphic-title"/>
        </xsl:if>
        <!-- <fo:inline>
          <xsl:attribute name="font-weight">bold</xsl:attribute>
          <xsl:apply-templates select="title"/>
        </fo:inline> -->
        <!-- 
        <xsl:choose>
          <xsl:when test="not(ancestor::FIGURE) and not($documentType = 'irm') and not($documentType = 'orim') and not($documentType = 'ohm')">
            <fo:inline color="#000000" font-weight="normal">
              <xsl:value-of select="concat(' (GRAPHIC&#xA0;', ../@CHAPNBR, 
                '-', ../@SECTNBR, 
                '-', ../@SUBJNBR, 
                '-', ../@FUNC,
                '-', ../@SEQ,
                '-',../@CONFLTR,../@VARNBR,')')"/>
            </fo:inline>
          </xsl:when>
        </xsl:choose> -->
        <xsl:if test="$revised-title = 'true'">
          <xsl:call-template name="cbEnd"/>
        </xsl:if>
      </fo:block>
    </fo:block-container>
  </xsl:template>

  <!-- THIS WILL OVERRIDE SAME TEMPLATE IN standardFunctions.xsl (as long as this stylesheet is included after standardFunctions.xsl) -->
  <xsl:template name="pgblk-title">
    <xsl:param name="pgblknbr"/>
    <xsl:choose>
      <xsl:when test="number($pgblknbr) = 0">
        <xsl:text>INTRODUCTION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 1">
        <xsl:text>DESCRIPTION AND OPERATION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 1000">
        <xsl:text>TESTING AND FAULT ISOLATION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 2000">
        <xsl:text>SCHEMATIC AND WIRING DIAGRAMS</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 3000">
        <xsl:text>DISASSEMBLY</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 4000">
        <xsl:text>CLEANING</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 5000">
        <xsl:text>INSPECTION/CHECK</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 6000">
        <xsl:text>REPAIR</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 7000">
        <xsl:text>ASSEMBLY</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 8000">
        <xsl:text>FITS AND CLEARANCES</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 9000">
        <xsl:text>SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 10000">
        <xsl:text>ILLUSTRATED PARTS LIST</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 11000">
        <xsl:text>SPECIAL PROCEDURES</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 12000">
        <xsl:text>REMOVAL</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 13000">
        <xsl:text>INSTALLATION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 14000">
        <xsl:text>SERVICING</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 15000">
        <xsl:text>STORAGE (INCLUDING TRANSPORTATION)</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 16000">
        <xsl:text>REWORK (SERVICE BULLETIN ACCOMPLISHMENT PROCEDURES)</xsl:text>
      </xsl:when>
      <!-- Appendix Support-->
      <xsl:when test="number($pgblknbr) >= 17000">
        <xsl:value-of select="./ancestor-or-self::PGBLK/TITLE"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>PAGEBLOCK </xsl:text><xsl:value-of select="$pgblknbr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- THIS WILL OVERRIDE SAME TEMPLATE IN standardFunctions.xsl (as long as this stylesheet is included after standardFunctions.xsl) -->
  <xsl:template match="TABLE/FTNOTE[1]">
    <xsl:param name="list-indent">
      <xsl:call-template name="calc-list-indent"/>
    </xsl:param>
    <xsl:param name="base-table-indent">
      <xsl:value-of select="substring-before($list-indent, 'pt')"/>
    </xsl:param>
    <xsl:param name="table-indent">
      <xsl:value-of select="number($base-table-indent + 20)"/>
    </xsl:param>
    <fo:block margin-left="4pt" text-align="left" space-before.optimum="3mm" space-after.optimum="3mm" font-size="9pt" keep-with-previous="always">
      <xsl:if test="ancestor-or-self::TABLE[@TABSTYLE='hl' or @ORIENT='land']">
        <xsl:attribute name="margin-left">.875in</xsl:attribute>
      </xsl:if>
      <xsl:if test="ancestor-or-self::TABLE/@ORIENT='land'">
        <xsl:attribute name="margin-right">.875in</xsl:attribute>
      </xsl:if>
      <fo:block keep-with-next.within-page="always">
        <fo:inline font-weight="bold">
          <xsl:text>NOTE:</xsl:text>
        </fo:inline>
      </fo:block>
      <fo:block margin-left="0.25in">
        <!-- space-after.optimum="3mm"-->
        <fo:list-block provisional-distance-between-starts="0.425in">
          <fo:list-item space-before.optimum="1.5mm">
            <xsl:attribute name="id">
              <xsl:value-of select="./@FTNOTEID"/>
            </xsl:attribute>
            <fo:list-item-label end-indent="label-end()">
              <fo:block font-weight="bold">
                <xsl:number format="1"/>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <xsl:apply-templates/>
            </fo:list-item-body>
          </fo:list-item>
          <xsl:if test="./following-sibling::FTNOTE">
            <xsl:call-template name="regFtNote">
              <xsl:with-param name="ftNoteInstance" select="./following-sibling::FTNOTE[1]"/>
            </xsl:call-template>
          </xsl:if>
        </fo:list-block>
      </fo:block>
      <fo:block text-align-last="justify">
        <fo:leader leader-pattern="rule"/>
      </fo:block>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
