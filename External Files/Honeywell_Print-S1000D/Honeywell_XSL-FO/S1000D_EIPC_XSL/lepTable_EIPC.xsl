<?xml version="1.0" encoding="UTF-8"?>
<!-- 2020-09-08 Update Start -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:xep="http://www.renderx.com/XEP/xep"
  xmlns:itg="http://www.infotrustgroup.com">
<!-- 2020-09-08 Update End -->

  <xsl:variable name="debug-lep-table" select="false()"/>
  
  <xsl:attribute-set name="lep.table.cell">
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
    <xsl:attribute name="padding-left">4pt</xsl:attribute>
    <xsl:attribute name="padding-right">4pt</xsl:attribute>
    <xsl:attribute name="border-style">none</xsl:attribute>
    <xsl:attribute name="display-align">after</xsl:attribute>
  </xsl:attribute-set>

  <xsl:variable name="manualRevdate" select="concat(/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@year,
                         	/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@month,
                         	/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@day)"/>
  <xsl:variable name="manualName" select="'EIPC'"/>

  <!-- Called to construct an LEP for a chapter. If it is the front-matter LEP, parameter "frontmatter" should -->
  <!--  be set to "1", and the chapter will be the first two digits of the ATA number for the manual. -->
  <xsl:template name="detail-lep">
    <xsl:param name="chapter" select="'??'"/>
    <xsl:param name="frontmatter" select="0"/>
    <xsl:variable name="chapterLineCount" select="count(document(itg:escape-path($LEP_EXTRACT_FILE))//page[@chapter = $chapter])"/>
    <xsl:variable name="fmLineCount" select="count(document(itg:escape-path($LEP_EXTRACT_FILE))//page[@chapter = ''])"/>
    <!-- <xsl:variable name="manualRevdate" select="/*/@REVDATE"/> -->

	<xsl:if test="$debug-lep-table">
	    <xsl:message>detail-lep called with chapnbr "<xsl:value-of select="$chapter"/>"; frontmatter: <xsl:value-of select="$frontmatter"/></xsl:message>
	    <xsl:message>Manual Revdate: '<xsl:value-of select="$manualRevdate"/>'</xsl:message>
	</xsl:if>

    <xsl:choose>
      <xsl:when test="$LEP_PASS = 1">
        <!-- Don't look for the file -->
      </xsl:when>
      <!-- Don't process if the extract file does not exist (or there are no entries for the chapter). -->
      <xsl:when test="(number($frontmatter) = 0 and $chapterLineCount &gt; 0) 
        or (number($frontmatter) = 1 and $fmLineCount &gt; 0)">
        <fo:page-sequence master-reference="Lep" font-family="Arial" initial-page-number="1" force-page-count="even">
          <xsl:call-template name="init-static-content-lep">
            <xsl:with-param name="suppressAtacode" select="0"/>
            <xsl:with-param name="isIntroToc" select="number($frontmatter)"/>
          </xsl:call-template>
          <fo:flow flow-name="xsl-region-body">
            <fo:block>
              <xsl:attribute name="id">
                <xsl:choose>
                  <xsl:when test="1 = number($frontmatter)">
                    <xsl:text>lep_frontmatter</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('chapter_lep_',generate-id())"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
			  <xsl:call-template name="effectivityAll"/>
			  
			  <!-- This looks like it doesn't do anything...
              <fo:block text-align="left" space-after="12pt">
                <fo:inline/>
              </fo:block> -->
              <fo:table border="none">
                <fo:table-column column-number="1" column-width="1pc"/>
                <fo:table-column column-number="2" column-width="11pc"/>
                <fo:table-column column-number="3" column-width="1pc"/>
                <fo:table-column column-number="4" column-width="6pc"/>
                <fo:table-body border-style="none" font-size="10pt">
                  <xsl:choose>
                    <xsl:when test="number($frontmatter) = 1">
                      <xsl:call-template name="do-lep-frontmatter">
                        <xsl:with-param name="LEP_EXTRACT_FILE" select="itg:escape-path($LEP_EXTRACT_FILE)"/>
                        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
                        <xsl:with-param name="frontmatter" select="1"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="do-chapter">
                        <xsl:with-param name="LEP_EXTRACT_FILE" select="itg:escape-path($LEP_EXTRACT_FILE)"/>
                        <xsl:with-param name="chapter" select="$chapter"/>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                  <!-- <xsl:call-template name="do-chapter">
                    <xsl:with-param name="LEP_EXTRACT_FILE" select="itg:escape-path($LEP_EXTRACT_FILE)"/>
                    <xsl:with-param name="chapter" select="$chapter"/>
                  </xsl:call-template> -->
                </fo:table-body>
              </fo:table>
            </fo:block>
          </fo:flow>
        </fo:page-sequence>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:value-of select="concat('Cannot find LEP Extract file: ',itg:escape-path($LEP_EXTRACT_FILE))"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="do-chapter">
    <xsl:param name="LEP_EXTRACT_FILE"/>
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate"/>
    <xsl:for-each select="document(itg:escape-path($LEP_EXTRACT_FILE))">
      <xsl:variable name="lepPageCount">
        <xsl:call-template name="calculate-lep-pages">
          <xsl:with-param name="chapter" select="$chapter"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:for-each select="//page[@chapter = $chapter]">
        <xsl:choose>
          <xsl:when test="@number = 'TC-1'">
            <xsl:call-template name="toc-row"/>
          </xsl:when>
          <xsl:when test="@section != preceding-sibling::page[1]/@section or @unit != preceding-sibling::page[1]/@unit">
            <xsl:call-template name="section-subject-divider-row">
              <xsl:with-param name="chapter" select="$chapter"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <!-- Make sure we skip the "real" foldouts, and the second placeholder page -->
        <xsl:if test="not(@foldout) or (@foldout and 1 = (@number mod 2))">
          <xsl:call-template name="detail-standard-row">
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="do-lep-frontmatter">
    <xsl:param name="LEP_EXTRACT_FILE"/>
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate"/>
    <xsl:param name="frontmatter" select="1"/>
    <!-- 2020-09-08 Update Start -->
    <xsl:for-each select="document(itg:escape-path($LEP_EXTRACT_FILE))">

        <xsl:variable name="lepPageCount">
          <xsl:choose>
            <xsl:when test="$LEP_PASS = 0">
              <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
                <xsl:variable name="chapterPageCount" select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text/@value = 'frontmatter'])"/>
                <xsl:value-of select="if ($chapterPageCount mod 2 = 0) then ($chapterPageCount) else ($chapterPageCount + 1)"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="calculate-lep-pages">
                <xsl:with-param name="chapter" select="$chapter"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

      <xsl:for-each select="//page[@chapter = '']">
        <xsl:variable name="pagePrefix" select="substring-before(@number,'-')"/>
        <xsl:variable name="pageNumber" select="substring-after(@number,'-')"/>
        <xsl:if test="@number = 'TC-1'">

          <xsl:variable name="lepPageCount">
            <xsl:choose>
              <xsl:when test="$LEP_PASS = 0">
                <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
                  <xsl:variable name="chapterPageCount" select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text/@value = 'frontmatter'])"/>
                  <xsl:value-of select="if ($chapterPageCount mod 2 = 0) then ($chapterPageCount) else ($chapterPageCount + 1)"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="calculate-lep-pages">
                  <xsl:with-param name="chapter" select="$chapter"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>'</xsl:message>
            <!-- 2020-09-08 Update End -->
          <xsl:call-template name="lep-row">
            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
            <xsl:with-param name="frontmatter" select="$frontmatter"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="number($pageNumber) = 1">
          <xsl:call-template name="figure-pgblk-divider-row"/>
        </xsl:if>
        <xsl:call-template name="detail-standard-row">
          <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="detail-standard-row">
    <xsl:param name="manualRevdate" select="0"/>
    <fo:table-row>
      <!-- Foldout Indicator (only called for odd page) -->
      <xsl:choose>
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
            <xsl:when test="@foldout">
              <xsl:value-of select="concat(@number,'/',following-sibling::page[1]/@number)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@number"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:table-cell>
      <!-- Revision indicator -->
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
    <fo:table-row keep-with-next.within-column="always">
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
            <!-- EM new Pgblk -->
            <xsl:when
              test="$manualName = 'EM' and (number(@number) = 1) or (1 = number(@number) - number(@pgblk))">
              <fo:inline text-transform="capitalize">
                  Page-block&#160;&#x2013;&#160;<xsl:value-of select="@pgblk"/>
              </fo:inline>
            </xsl:when>
            <xsl:when test="$manualName = 'EIPC'"> </xsl:when>
          </xsl:choose>
        </fo:block>
      </fo:table-cell>
      <xsl:choose>
        <xsl:when test="starts-with(@number,'T-')"/>
        <xsl:when test="starts-with(@number,'TC-')"/>
        <xsl:when test="starts-with(@number,'TI-')"/>
        <xsl:when test="starts-with(@number,'RR-')"/>
        <xsl:when test="starts-with(@number,'RTR-')"/>
        <xsl:when test="starts-with(@number,'SBL-')"/>
        <xsl:when test="starts-with(@number,'INTRO-')"/>
        <xsl:when test="starts-with(@number,'VCL-')"/>
        <xsl:when test="$manualName = 'EM' and (number(@number) = 1) or (1 = number(@number) - number(@pgblk))"/>
        <xsl:when test="starts-with(@number,'NI-')"/>
      </xsl:choose>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="toc-row">
    <fo:table-row>
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left"
          padding-top="3pt"
          padding-bottom="3pt"
          number-columns-spanned="3">
        <fo:block font-weight="normal">
          <xsl:text>Table of Contents</xsl:text>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="section-subject-divider-row">
    <xsl:param name="chapter"/>
    <xsl:if test="((@subject='') and (@unit='') and (preceding-sibling::page[1][@section=''][@chapter!='']))">
      <!-- 2020-09-08 Update Start -->
      <xsl:variable name="lepPageCount">
        <xsl:choose>
          <xsl:when test="$LEP_PASS = 0">
            <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
              <xsl:variable name="chapterPageCount" select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text/@value = $chapter])"/>
              <xsl:value-of select="if ($chapterPageCount mod 2 = 0) then ($chapterPageCount) else ($chapterPageCount + 1)"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="calculate-lep-pages">
              <xsl:with-param name="chapter" select="$chapter"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- 2020-09-08 Update End -->
      <!-- For Debug
      <xsl:message>CURRENT CHAPTER: '<xsl:value-of select="$chapter"/>'</xsl:message>
      <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>'</xsl:message>
      -->
      <xsl:call-template name="lep-row">
        <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
        <xsl:with-param name="indent" select="'4pt'"/>
        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
        <xsl:with-param name="frontmatter" select="0"/>
      </xsl:call-template>
    </xsl:if>
    <fo:table-row keep-with-next.within-column="always">
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left"
          padding-top="3pt"
          padding-bottom="3pt"
          number-columns-spanned="3">
        <fo:block font-weight="bold">
          <fo:block>
            <xsl:call-template name="chapter-section-subject"/>
          </fo:block>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

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
    <xsl:param name="frontmatter" select="0"/>
    <xsl:if test="$lepCallCount = 1">
      <fo:table-row keep-with-next.within-column="always">
        <!-- Foldout Indicator -->
        <xsl:call-template name="detail-empty-cell"/>
        <!-- Title -->
        <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="{$indent}"
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
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
        <xsl:call-template name="lep-asterisk"/>
      </fo:table-cell>
      <!-- Revdate -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
        <xsl:variable name="revDate">
          <xsl:choose>
            <xsl:when test="number($frontmatter) = 1">
              <xsl:value-of select="$manualRevdate"/>
            </xsl:when>
            <xsl:when test="((@revdate='') or (@revdate='0'))">
              <xsl:value-of select="$manualRevdate"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Use revdate from the last TOC page for the LEP dates. -->
              <xsl:value-of select="preceding-sibling::page[1]/@revdate"/>
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
        <xsl:with-param name="frontmatter" select="$frontmatter"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lep-asterisk">
    <fo:block>
      <!-- <xsl:value-of select="@revised"/> -->

      <!-- Sonovision update (2018.11.07)
           
           - this part of processing executes against generated "*_lepExtract_point-pages.xml"
           - "*" should only appear if given "page" has a change marker, but FOSI puts
             asterisk for all of the generated Title (T-1,...), Transmittal Information (TI-1,...), 
             List of Effective Pages (LEP-1,...), and Table of Contents (TC-1,...)
             probably under the assumption that they are all changed from previous version
           - force an "*" in LEP table for "T-|TI-|LEP-|TC-" entries
      -->
      <xsl:choose>
       <!-- UPDATE: Styler doesn't do this for S1000D, so remove for now until it is requested. -->
       <!-- <xsl:when test="starts-with(@number,'T-') or starts-with(@number,'TI-') or starts-with(@number,'LEP-') or starts-with(@number,'TC-')"> -->
       <xsl:when test="false()">
        <xsl:text>*</xsl:text>
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="@revised"/>
       </xsl:otherwise>
      </xsl:choose>
      
      
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
    <xsl:variable name="entriesPerPage" select="78"/>
    <!-- Each new Pgblk element adds a blank line in the LEP -->
    <xsl:variable name="pgblkCount">
      <xsl:value-of select="count(//page[@chapter = $chapter])"/>
    </xsl:variable>
    <xsl:variable name="dividerEntries" select="0"/>
    <xsl:variable name="dividerEntries">
       <xsl:for-each select="//page[@chapter = $chapter]">
          <xsl:if test="@section != preceding-sibling::page[1]/@section or @unit != preceding-sibling::page[1]/@unit">
             <xsl:value-of select="$dividerEntries + 1"/>
          </xsl:if>
       </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="dividerEntries" select="string-length($dividerEntries)"/>
    <xsl:variable name="rawLepCount">
       <xsl:value-of select="ceiling(($pgblkCount + $lepPages + $dividerEntries + 3) div $entriesPerPage)"/><!-- The 3 initial dividers are the "Table of Contents + chapter number" text and the "List of Effective Pages" text -->
    </xsl:variable>
    
    <xsl:if test="$debug-lep-table">
	    <xsl:message> </xsl:message>
	    <xsl:message>dividerEntries = '<xsl:value-of select="$dividerEntries"/>'</xsl:message>
	    <xsl:message>chapter = '<xsl:value-of select="$chapter"/>'</xsl:message>
	    <xsl:message>pgblkCount = '<xsl:value-of select="$pgblkCount"/>'</xsl:message>
	    <xsl:message>lepPages = '<xsl:value-of select="$lepPages"/>'</xsl:message>
	    <xsl:message>rawLepCount = '<xsl:value-of select="$rawLepCount"/>'</xsl:message>
	    <xsl:message> </xsl:message>
	</xsl:if>
	
    <xsl:choose>
      <!-- Don't recurse more than once. -->
      <xsl:when test="$lepPages = 0 and $callCount = 0">
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
