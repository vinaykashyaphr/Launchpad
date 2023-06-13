<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xep="http://www.renderx.com/XEP/xep" xmlns:itg="http://www.infotrustgroup.com"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">
  
  <xsl:import href="../shared/unhandled-element.xsl"/>
  <xsl:import href="standardVariables.xsl"/><!-- ../shared/ -->
  
  <xsl:include href="stdPages.xsl"/><!-- ../shared/ -->
  <xsl:include href="../shared/cageInfo.xsl"/>
  <xsl:include href="partinfo-table.xsl"/>
  
  <xsl:variable name="debug" select="false()"/>
  
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
  
  <xsl:template match="/">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <xsl:processing-instruction name="xep-pdf-initial-zoom">fit</xsl:processing-instruction>
      <xsl:processing-instruction name="xep-pdf-page-layout">single-page</xsl:processing-instruction>
      <xsl:processing-instruction name="xep-pdf-viewer-preferences">fit-window center-window</xsl:processing-instruction>
      <xsl:processing-instruction name="xep-pdf-logical-page-numbering" select="'false'"/>
      <xsl:processing-instruction name="xep-pdf-view-mode">show-none</xsl:processing-instruction>
      <xsl:call-template name="define-pagesets"/>
      <xsl:apply-templates select="lepdata"/>
    </fo:root>
  </xsl:template>
  
  <xsl:template name="convert-date">
    <xsl:param name="ata-date"/>
    <xsl:variable name="month-string">
      <xsl:if test="string(substring(string($ata-date),5,2))='01'"> Jan </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='02'"> Feb </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='03'"> Mar </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='04'"> Apr </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='05'"> May </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='06'"> Jun </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='07'"> Jul </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='08'"> Aug </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='09'"> Sep </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='10'"> Oct </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='11'"> Nov </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='12'"> Dec </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="substring(string($ata-date),7,1)='0'">
        <xsl:value-of select="string(substring(string($ata-date),8,1))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string(substring(string($ata-date),7,2))"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat($month-string,' ')"/>
    <xsl:value-of select="string(substring(string($ata-date),1,4))"/>
  </xsl:template>
  
  <xsl:template name="get-revdate">
    <xsl:param name="asText"/>
    <xsl:param name="intro-toc"/>
    <xsl:value-of select="'YYYYMMDD'"/>
  </xsl:template>

  <xsl:attribute-set name="lep.table.cell">
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
    <xsl:attribute name="padding-left">4pt</xsl:attribute>
    <xsl:attribute name="padding-right">4pt</xsl:attribute>
    <xsl:attribute name="border-style">none</xsl:attribute>
    <xsl:attribute name="display-align">after</xsl:attribute>
  </xsl:attribute-set>

  <xsl:variable name="manualRevdate" select="//page[@revdate != ''][1]/@revdate"/>
  <xsl:variable name="chapter" select="//page[@chapter != ''][1]/@revdate"/>
  
  <xsl:template match="lepdata">
    <fo:page-sequence master-reference="Lep" font-family="Arial" initial-page-number="1" force-page-count="even">
      <xsl:call-template name="init-static-content-lep"/>
      <fo:flow flow-name="xsl-region-body">
        <fo:block>
          <xsl:attribute name="id">
            <!--<xsl:choose>
              <xsl:when test="1 = number($frontmatter)">-->
                <xsl:text>lep_frontmatter</xsl:text>
              <!--</xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('chapter_lep_',generate-id())"/>
              </xsl:otherwise>
            </xsl:choose>-->
            
          </xsl:attribute>
          
          <!-- Added default effectivity marker of 'All' for frontmatter. (Mantis #17829) -->
          <fo:block>
            <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
          </fo:block>
          
          <fo:table border="none">
            <fo:table-column column-number="1" column-width="1.5pc"/>
            <fo:table-column column-number="2" column-width="10.5pc"/>
            <fo:table-column column-number="3" column-width="1pc"/>
            <fo:table-column column-number="4" column-width="6pc"/>
            
            <fo:table-body border-style="none" font-size="10pt">
              <!--<xsl:choose>
                <xsl:when test="number($frontmatter) = 1">-->
                  <xsl:call-template name="do-lep-frontmatter">
                    <!--<xsl:with-param name="LEP_EXTRACT_FILE" select="itg:escape-path($LEP_EXTRACT_FILE)"/>-->
                    <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
                  </xsl:call-template>
                  <!--Added "do-chapter"-->
                  <xsl:call-template name="do-chapter">
                    <!--<xsl:with-param name="LEP_EXTRACT_FILE" select="itg:escape-path($LEP_EXTRACT_FILE)"/>-->
                    <xsl:with-param name="chapter" select="$chapter"/>
                  </xsl:call-template>
                <!--</xsl:when>
              </xsl:choose>-->
              <!--<xsl:call-template name="do-chapter">
                    <xsl:with-param name="LEP_EXTRACT_FILE" select="$LEP_EXTRACT_FILE"/>
                    <xsl:with-param name="chapter" select="$chapter"/>
                  </xsl:call-template>-->
              
            </fo:table-body>
          </fo:table>
          
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>
  
  <!-- RS: do-chapter: for CMM this outputs the whole contents of the LEP after the front-matter. -->
  <!-- The chapter is the first two digits of the ATA number -->
  <xsl:template name="do-chapter">
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate"/>
      
      <xsl:for-each select="//page[@chapter != '']">

        <!-- Get the page number (stripping any prefix). -->
        <xsl:variable name="pageNumber" select="replace(@number,'^.*?([0-9]+)$','$1')"/>

        <!-- RS: This determines whether an entry is a chapter heading: the pgblk number changes or the confnbr -->
        <!-- changes. -->
        <!-- UPDATE: Added @label test for IM/SDIM/SDOM, as in EM LEPs. -->
        <!-- UPDATE: Occasionally a lower-level pmEntryTitle generates a label (only seen so far when directly after -->
        <!-- a _newpage PI). So add a restriction to the @label test to check that the page number starts with "1". -->
        <!-- <xsl:if test="@pgblk != preceding-sibling::page[1]/@pgblk or @confnbr != preceding-sibling::page[1]/@confnbr"> --><!-- and @number != 'TC-1'-->
        <xsl:if test="@pgblk != preceding-sibling::page[1]/@pgblk
           or (@confnbr != '' and @confnbr != preceding-sibling::page[1]/@confnbr)
           or ( not(@label = '') and $pageNumber='1' )">
          <xsl:if test="$debug">
            <xsl:message>Section change detected. Label: <xsl:value-of select="@label"/></xsl:message>
          </xsl:if>
          <xsl:call-template name="figure-pgblk-divider-row"/>
        </xsl:if>
                  
          <xsl:call-template name="detail-standard-row">
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
          </xsl:call-template>
          
      </xsl:for-each>
  </xsl:template>

  <xsl:template name="do-lep-frontmatter">
    <!--<xsl:param name="LEP_EXTRACT_FILE"/>-->
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate"/>
    
    <xsl:for-each select="//page[@chapter = '']">
        <xsl:variable name="pagePrefix" select="substring-before(@number,'-')"/>
        <xsl:variable name="pageNumber" select="substring-after(@number,'-')"/>
        <xsl:if test="@number = 'TC-1'">
          <xsl:variable name="lepPageCount">
            <xsl:choose>
              <xsl:when test="$LEP_PASS = 0">
                <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
                  <xsl:value-of select="count(//xep:page)"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="calculate-lep-pages">
                  <xsl:with-param name="chapter" select="$chapter"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          
          <!-- For Debug -->
          <!--<xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (do-lep-frontmatter - for-each) </xsl:message>-->
          <xsl:message>LEP Page count: <xsl:value-of select="$lepPageCount"/></xsl:message>
          <xsl:variable name="chapter" select="//page[@chapter != ''][1]/@chapter"/>
          <xsl:message>Calling lep-row</xsl:message>
          <xsl:call-template name="lep-row">
            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
            <xsl:with-param name="indent" select="'4pt'"/>
          </xsl:call-template>
          <!--<xsl:call-template name="do-chapter">
            <xsl:with-param name="LEP_EXTRACT_FILE" select="$LEP_EXTRACT_FILE"/>
            <xsl:with-param name="chapter" select="$chapter"/>
          </xsl:call-template>-->
        </xsl:if>
        <xsl:if test="number($pageNumber) = 1">
          <xsl:call-template name="figure-pgblk-divider-row"/>
        </xsl:if>
        <xsl:call-template name="detail-standard-row">
          <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
        </xsl:call-template>
      </xsl:for-each>
    
  </xsl:template>


  <xsl:template name="detail-standard-row">
    <xsl:param name="manualRevdate" select="0"/>
    <fo:table-row hyphenate="true">
      <!-- Foldout Indicator (only called for odd page) -->
      <xsl:choose>
        <!-- RS: S1000D doesn't use left foldouts -->
        <!-- <xsl:when test="@foldout and @pgblk = '10000'">
          <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
            <fo:block font-size="10pt">
              <xsl:text>LF</xsl:text>
            </fo:block>
          </fo:table-cell>
        </xsl:when> -->
        <xsl:when test="@foldout">
          <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
            <fo:block font-size="10pt">
              <xsl:text>F</xsl:text>
            </fo:block>
          </fo:table-cell>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="detail-empty-cell"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Page Number (if foldout then this number/next number) -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="24pt">
        <fo:block font-size="10pt">
          <xsl:choose>
            <xsl:when test="@documentType = 'irm' and (@pgblk='5000' or @pgblk='6000') and number(@confnbr) >= 1000">
	          <xsl:value-of select="@number"/>
              <xsl:if test="@effect and not(@effect='')">
                <xsl:text>-</xsl:text>
				<!-- Add zero-width spaces after commas in the IRM page numbers, so the text will break in the table cell if necessary. -->
                <xsl:value-of select="replace(@effect,',',',&#x0200B;')"/>                
              </xsl:if>
            </xsl:when>
            <xsl:when test="@confnbr != ''">
            	<!-- If it's a foldout page with a slash, add the confnbr before the slash too. -->
            	<xsl:value-of select="replace(@number, '/', concat(@confnbr, '/'))"/>
	          	<xsl:value-of select="@confnbr"/>
            </xsl:when>
            <xsl:otherwise>
            	<xsl:value-of select="@number"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:table-cell>

      <!-- Revision indicator -->
      <!--<xsl:call-template name="detail-empty-cell"/>-->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
        <xsl:call-template name="lep-asterisk"/>
      </fo:table-cell>
      
      <!-- Date -->
      <xsl:variable name="revDate">
        <xsl:choose>
          <xsl:when test="((@revdate='') or (@revdate='0'))">
            <xsl:value-of select="$manualRevdate"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@revdate"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:variable>
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
        <fo:block font-size="10pt" white-space-treatment="preserve" white-space-collapse="false">
          <xsl:call-template name="convert-date">
            <xsl:with-param name="ata-date">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="figure-pgblk-divider-row">
     <!-- <xsl:message>LEP: Outputting LEP divider (header) row</xsl:message> -->
     <!-- Get the page number (stripping any prefix). -->
     <xsl:variable name="pageNumber" select="replace(@number,'^.*?([0-9]+)$','$1')"/>
     <fo:table-row keep-with-next.within-column="always" keep-together.within-page="always">
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="12pt" 
        padding-top="3pt"
        padding-bottom="3pt"
        number-columns-spanned="3">
        <fo:block font-size="10pt">
          <xsl:choose>
            <xsl:when test="starts-with(@number,'T-')">
              <xsl:attribute name="padding-top" select="'-3pt'"/>
              <xsl:text>Title</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'TC-')">
              <xsl:text>Table of Contents</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'TI-')">
              <xsl:text>Transmittal Information</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'RR-')">
              <xsl:text>Record of Revisions</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'RTR-')">
              <xsl:text>Record of Temporary Revisions</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'SBL-')">
              <xsl:text>Service Bulletin List</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'INTRO-')">
              <xsl:text>Introduction</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'VCL-')">
              <xsl:text>Vendor Code List</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'NI-')">
              <xsl:text>Numerical Index</xsl:text>
            </xsl:when>

            <xsl:when test="@documentType = 'irm' and @pgblk='5000'
               and number(@confnbr) >= 1000 and 2000 >number(@confnbr)
               and (not(@effect) or @effect='')">
              <fo:inline>
                <xsl:text>Continue-Time&#160;Check</xsl:text>
              </fo:inline>
            </xsl:when>

            <xsl:when test="@documentType = 'irm' and @pgblk='5000' and number(@confnbr) >= 1000 and 2000 >number(@confnbr)">
              <fo:inline>
                <xsl:text>Continue-Time&#160;Check,&#160;PN&#160;</xsl:text>
				<!-- Add zero-width spaces after commas in the IRM PNs, so the text will break in the table cell if necessary. -->
                <xsl:value-of select="replace(@effect,',',',&#x0200B;')"/>                
              </fo:inline>
            </xsl:when>
            
            <xsl:when test="@documentType = 'irm' and @pgblk='5000'
               and number(@confnbr) >= 2000 and 3000 >number(@confnbr)
               and (not(@effect) or @effect='')">
              <fo:inline>
                <xsl:text>Zero-Time&#160;Check</xsl:text>
              </fo:inline>
            </xsl:when>
            
            <xsl:when test="@documentType = 'irm' and @pgblk='5000' and number(@confnbr) >= 2000 and 3000 >number(@confnbr)">
              <fo:inline>
                <xsl:text>Zero-Time&#160;Check,&#160;PN&#160;</xsl:text>
				<!-- Add zero-width spaces after commas in the IRM PNs, so the text will break in the table cell if necessary. -->
                <xsl:value-of select="replace(@effect,',',',&#x0200B;')"/>
              </fo:inline>
            </xsl:when>

            <xsl:when test="@documentType = 'irm' and @pgblk='5000' and number(@confnbr) >= 3000 and 4000 >number(@confnbr)">
              <fo:inline>
                <xsl:text>Periodic&#160;Inspection,&#160;PN&#160;</xsl:text>
				<!-- Add zero-width spaces after commas in the IRM PNs, so the text will break in the table cell if necessary. -->
                <xsl:value-of select="replace(@effect,',',',&#x0200B;')"/>                
              </fo:inline>
            </xsl:when>


            <xsl:when test="@documentType = 'irm' and @pgblk='6000'
               and number(@confnbr) >= 1000
               and (not(@effect) or @effect='')">
              <fo:inline>
                <xsl:text>Repair</xsl:text>
              </fo:inline>
            </xsl:when>

            <xsl:when test="@documentType = 'irm' and @pgblk='6000' and number(@confnbr) >= 1000">
              <fo:inline>
                <xsl:text>Repair,&#160;PN&#160;</xsl:text>
				<!-- Add zero-width spaces after commas in the IRM PNs, so the text will break in the table cell if necessary. -->
                <xsl:value-of select="replace(@effect,',',',&#x0200B;')"/>                
              </fo:inline>
            </xsl:when>

	        <!-- Only output the label for the first page in the pageblock(?); this test won't work for IM/SDIM/SDOM which -->
            <!-- uses page prefixes, so make an exception for them. -->
            <!-- <xsl:when test="(number(@number) = 1) or (1 = number(@number) - number(@pgblk)) or number(@pgblk) >= 17000 or @confnbr != ''"> --> <!-- number(@confnbr) > 1 -->
            <xsl:when test="$pageNumber = '1' or (1 = number(@number) - number(@pgblk)) or number(@pgblk) >= 17000 or @confnbr != ''
              or @documentType='im' or @documentType='sdom' or @documentType='sdim'">
		      <!-- <xsl:message>LEP: Outputting section header: <xsl:value-of select="@label"/></xsl:message> -->
              <xsl:choose>
              	<!-- For IM/SDIM/SDOM, the section prefix is formatted on a different line. For now, just use a regex to -->
              	<!-- parse it, later might need to add a new attribute to the LEP export to separate the parts.  -->
              	<!-- If looks like "Section 1 – General Information" or "Appendix A – Osd Menu Reference". -->
              	<xsl:when test="@documentType='im' or @documentType='sdom' or @documentType='sdim'">
              		<fo:block>
              			<xsl:value-of select="replace(@label,'^(Section|Appendix) ([0-9A-Z-]*) . .+','$1 $2')"/>
              		</fo:block>
              		<fo:block>
              		  <fo:inline text-transform="uppercase">
              			<xsl:value-of select="replace(@label,'^.+ – (.+)','$1')"/>
              		  </fo:inline>
              		</fo:block>
              	</xsl:when>
              	<xsl:otherwise>
	              <fo:inline><!-- text-transform="capitalize"-->
	                <xsl:value-of select="replace(./@label,'/','/&#x0200B;')"/>
	              </fo:inline>
              	</xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            
          </xsl:choose>
        </fo:block>
      </fo:table-cell>

    </fo:table-row>
  </xsl:template>

  <!--<xsl:template name="toc-row">
    <fo:table-row>
      <!-\- Foldout Indicator -\->
      <xsl:call-template name="detail-empty-cell"/>
      <!-\- Title -\->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left">
        <fo:block font-weight="normal">
          <xsl:text>Table of Contents</xsl:text>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>-->

  <!--<xsl:template name="section-subject-divider-row">
    <xsl:if test="((@subject='') and (@unit='') and (preceding-sibling::page[1][@section=''][@chapter!='']))">
      <xsl:variable name="lepPageCount">
        <xsl:call-template name="calculate-lep-pages"/>
      </xsl:variable>
      <!-\- For Debug
      <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (section-subject-divider-row) </xsl:message>
      -\->
      <xsl:call-template name="lep-row">
        <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
        <xsl:with-param name="indent" select="'4pt'"/>
        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
      </xsl:call-template>
    </xsl:if>
    <fo:table-row keep-with-next.within-column="always">
      <!-\- Foldout Indicator -\->
      <xsl:call-template name="detail-empty-cell"/>
      <!-\- Title -\->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left">
        <fo:block font-weight="bold">
          <fo:block>
            <xsl:call-template name="chapter-section-subject"/>
          </fo:block>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>-->

  <xsl:template name="chapter-section-subject">
    <xsl:value-of select="@chapter"/>
    <xsl:if test="@section != ''">
      <xsl:value-of select="concat('-',@section)"/>
    </xsl:if>
    <xsl:if test="@subject != ''">
      <xsl:value-of select="concat('-',@subject)"/>
    </xsl:if>
    <xsl:if test="@unit != ''">
      <xsl:value-of select="concat('-',@unit)"/>
    </xsl:if>
  </xsl:template>

  <!-- A row reprsenting the LEP, calls itself to put in a row for each LEP page -->
  <!-- Uses the top level revdate -->
  <xsl:template name="lep-row">
    <xsl:param name="lepTotalPages" select="0"/>
    <xsl:param name="lepCallCount" select="1"/>
    <xsl:param name="manualRevdate" select="0"/>
    <xsl:param name="indent" select="'12pt'"/>

    <xsl:if test="$lepCallCount = 1">
      <fo:table-row keep-with-next.within-column="always">
        <!-- Foldout Indicator -->
        <xsl:call-template name="detail-empty-cell"/>
        <!-- Title -->
        <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="12pt" 
          padding-top="3pt"
          padding-bottom="3pt"
          number-columns-spanned="3">
          <fo:block font-size="10pt">
            <xsl:text>List of Effective Pages</xsl:text>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </xsl:if>

    <fo:table-row>
      <!-- Foldout indicator -->
      <xsl:call-template name="detail-empty-cell"/>

      <!-- Page -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="24pt">
        <fo:block font-size="10pt">
          <xsl:value-of select="concat('LEP-',$lepCallCount)"/>
        </fo:block>
      </fo:table-cell>

      <!-- Revision indicator -->
      <!--<xsl:call-template name="detail-empty-cell"/>-->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
        <xsl:call-template name="lep-asterisk"/>        
      </fo:table-cell>
      

      <!-- Revdate -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
        <xsl:variable name="revDate">
          <xsl:choose>
            <xsl:when test="((@revdate='') or (@revdate='0'))">
              <xsl:value-of select="$manualRevdate"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@revdate"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <fo:block font-size="10pt">
          <xsl:call-template name="convert-date">
            <xsl:with-param name="ata-date">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:table-cell>

    </fo:table-row>

    <xsl:if test="$lepCallCount &lt; $lepTotalPages">
      <xsl:call-template name="lep-row">
        <xsl:with-param name="lepCallCount" select="$lepCallCount + 1"/>
        <xsl:with-param name="lepTotalPages" select="$lepTotalPages"/>
        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!--<xsl:template name="lep-asterisk">
    <!-\- DJH ADDED -\->
    <xsl:param name="revDate" select="'0'"/>
    <!-\- FOR DEBUG	 -\->
	 <!-\-<xsl:message>ENTERING ASTERISK RULE (REVDATE = "<xsl:value-of select="$revDate"/>" | MANUAL REVDATE = "<xsl:value-of select="$manualRevdate"/>")</xsl:message>-\->
    <xsl:choose>
      <!-\- Added for mantis #16245 -\->
      <!-\-<xsl:when test="not(//processing-instruction()[name()='firstXMLrevision'])">
        <!-\-<xsl:message>OUTPUT ' ' (not(//processing-instruction()[name()='firstXMLrevision']))</xsl:message>-\->
        <xsl:text>&#160;</xsl:text>
      </xsl:when>-\->
      <xsl:when test="$revDate = $manualRevdate">
        <!-\-<xsl:message>OUTPUT '*'</xsl:message>-\->
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-\-<xsl:message>OUTPUT ' '</xsl:message>-\->
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <!-\- FOR DEBUG	-\->
    <!-\-<xsl:message>LEAVING ASTERISK RULE</xsl:message>-\->
    </xsl:template>-->
  
  <xsl:template name="lep-asterisk">
    <fo:block>
      <xsl:value-of select="@revised"/>
    </fo:block>
  </xsl:template>

  <!-- An empty row, which separates groups (like pgblk changes) in the listing -->
  <xsl:template name="detail-blank-row">
    <fo:table-row>
      <xsl:call-template name="detail-empty-cell"/>
      <xsl:call-template name="detail-empty-cell"/>
      <xsl:call-template name="detail-empty-cell"/>
      <xsl:call-template name="detail-empty-cell"/>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="detail-empty-cell">
    <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
      <fo:block>
        <xsl:text>&#160;</xsl:text>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template name="calculate-lep-pages">
    <xsl:param name="chapter" select="''"/>
    <xsl:param name="lepPages" select="0"/>
    <xsl:param name="callCount" select="0"/>
    <!-- =========================================================================================== -->
    <!-- Calculate the number of pages the LEP will use, and round to an even number                 -->
    <!-- Need to insert that number of entries in the table, so the template is called a second time -->
    <!-- to recalculate number of pages. For example if there were exactly two pages of entries      -->
    <!-- then adding the lep lines would push it 4 pages. -->
    <!-- =========================================================================================== -->
    <!-- Approximate number of lep entries in a page -->
    <xsl:variable name="entriesPerPage" select="78"/><!--54--><!--Changed from 78-->
    <!-- Each new Pgblk element adds a blank line in the LEP -->
    <xsl:variable name="pgblkCount">
      <xsl:value-of select="count(//page)"/>
    </xsl:variable>
    <xsl:variable name="fmLabelLineCount"><!--frontmatter label line count. these all fit on one line-->
      <xsl:value-of select="count(//page[@pgblk=''][@label!='']/string-length(@label)) + 2"/>
    </xsl:variable>
    <xsl:variable name="labelLineSpacing">
      <xsl:value-of select="count(//page[@pgblk != ''][./@pgblk != preceding-sibling::page[1]/@pgblk])"/>
    </xsl:variable>
    <!-- Modified labelCount to count the characters in the @label attributes. It divides that number by 40 (the number of characters allowed in a lable line (title) in the LEP. -->
    <xsl:variable name="labelCount">
      <xsl:value-of select="round(sum(//page[@pgblk != ''][./@pgblk != preceding-sibling::page[1]/@pgblk]/string-length(@label))) + $fmLabelLineCount"/>
    </xsl:variable>
    <xsl:variable name="rawLepCount">
      <xsl:value-of select="ceiling(($pgblkCount + $fmLabelLineCount + $labelLineSpacing + $labelCount + $lepPages ) div $entriesPerPage)"/>
    </xsl:variable>

    <xsl:if test="$debug">
	    <xsl:message>&#xA;chapter = '<xsl:value-of select="$chapter"/>'</xsl:message>
	    <xsl:message>pgblkCount = '<xsl:value-of select="$pgblkCount"/>'</xsl:message>
	    <xsl:message>fmLabelLineCount = '<xsl:value-of select="$fmLabelLineCount"/>'</xsl:message>
	    <xsl:message>labelLineSpacing = '<xsl:value-of select="$labelLineSpacing"/>'</xsl:message>
	    <xsl:message>labelCount = '<xsl:value-of select="$labelCount"/>'</xsl:message>
	    <xsl:message>rawLepCount = '<xsl:value-of select="$rawLepCount"/>'</xsl:message>
	    <xsl:message>lepPages = '<xsl:value-of select="$lepPages"/>'</xsl:message>
	</xsl:if>
	    
    <!-- ========================== -->
    <xsl:choose>
      <!-- Don't recurse more than once. -->
      <xsl:when test="$lepPages = 0 and $callCount = 0">
        <!-- For Debug
        <xsl:message>Calling calculate-lep-pages from inside calculate-lep-pages.</xsl:message>
        -->
        <xsl:call-template name="calculate-lep-pages">
          <xsl:with-param name="lepPages" select="$rawLepCount"/>
          <xsl:with-param name="callCount" select="1"/>
          <xsl:with-param name="chapter" select="$chapter"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Return value is number of pages rounded to even pages. -->
      <xsl:otherwise>
        <xsl:value-of select="$rawLepCount + ($rawLepCount mod 2)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
