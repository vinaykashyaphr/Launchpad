<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:attribute-set name="lep.table.cell">
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
    <xsl:attribute name="padding-left">4pt</xsl:attribute>
    <xsl:attribute name="padding-right">4pt</xsl:attribute>
    <xsl:attribute name="border-style">none</xsl:attribute>
    <xsl:attribute name="display-align">after</xsl:attribute>
  </xsl:attribute-set>

  <xsl:variable name="manualRevdate" select="/*/@REVDATE"/>


  <xsl:template name="detail-lep">
    <xsl:param name="chapter" select="'??'"/>
    <xsl:param name="frontmatter" select="0"/>
    <xsl:variable name="chapterLineCount" select="count(document($LEP_EXTRACT_FILE)//page[@chapter = $chapter])"/>
    <xsl:variable name="fmLineCount" select="count(document($LEP_EXTRACT_FILE)//page[@chapter = ''])"/>
    <!-- For Debug
    <xsl:message>Manual Revdate: '<xsl:value-of select="$manualRevdate"/>'</xsl:message>
    -->
    <xsl:choose>

      <xsl:when test="$LEP_PASS = 1">
        <!-- Don't look for the file -->
      </xsl:when>

      <!-- Don't process if the extract file does not exist -->
      <xsl:when test="(0 = number($frontmatter) and 0 &lt; $chapterLineCount) 
        or (1 = number($frontmatter) and 0 &lt; $fmLineCount)">
        <fo:page-sequence master-reference="Lep" font-family="Arial" initial-page-number="1" force-page-count="even">
          <xsl:call-template name="init-static-content-lep"/>
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

              <fo:block text-align="left" space-after="12pt">
                <fo:inline/>
              </fo:block>

              <fo:table border="none">
                <fo:table-column column-number="1" column-width="1pc"/>
                <fo:table-column column-number="2" column-width="11pc"/>
                <fo:table-column column-number="3" column-width="1pc"/>
                <fo:table-column column-number="4" column-width="6pc"/>


                <fo:table-body border-style="none" font-size="10pt">
                  <xsl:choose>
                    <xsl:when test="number($frontmatter) = 1">
                      <xsl:call-template name="do-lep-frontmatter">
                        <xsl:with-param name="LEP_EXTRACT_FILE" select="$LEP_EXTRACT_FILE"/>
                        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
                      </xsl:call-template>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:call-template name="do-chapter">
                    <xsl:with-param name="LEP_EXTRACT_FILE" select="$LEP_EXTRACT_FILE"/>
                    <xsl:with-param name="chapter" select="$chapter"/>
                  </xsl:call-template>

                </fo:table-body>
              </fo:table>

            </fo:block>
          </fo:flow>
        </fo:page-sequence>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:value-of select="concat('Cannot find LEP Extract file: ',$LEP_EXTRACT_FILE)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="do-chapter">
    <xsl:param name="LEP_EXTRACT_FILE"/>
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate"/>
    <xsl:for-each select="document($LEP_EXTRACT_FILE)">

      <xsl:variable name="lepPageCount">
        <xsl:call-template name="calculate-lep-pages">
          <xsl:with-param name="chapter" select="$chapter"/>
        </xsl:call-template>
      </xsl:variable>
      <!-- For Debug
      <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (do-chapter) </xsl:message>
      -->
      <xsl:for-each select="//page[@chapter = $chapter]">

        <xsl:if test="count(preceding::page[@chapter = $chapter]) = 0">
          <!-- DJH ADDED 20090820 START -->
          <xsl:call-template name="lep-row">
            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
            <xsl:with-param name="indent" select="'4pt'"/>
          </xsl:call-template>
          <!-- DJH ADDED 20090820 END -->
          <!-- DJH REMOVED 20091124
          <xsl:call-template name="toc-row" />
          -->
        </xsl:if>

        <xsl:if test="$manualName = 'EM'">
          <!-- DJH ADD START 20091124-->
          <xsl:choose>
            <xsl:when test="@number = 'TC-1'">
              <!-- This will output the chapter number
                <xsl:call-template name="section-subject-divider-row"/>
              -->
              <xsl:call-template name="toc-row"/>
            </xsl:when>
            <xsl:when test="@section != preceding-sibling::page[1]/@section and @number != 'TC-1' or @subject != preceding-sibling::page[1]/@subject and @number != 'TC-1'">
              <xsl:call-template name="section-subject-divider-row"/>
              <xsl:if test="@section != preceding-sibling::page[1]/@section and preceding-sibling::page[1]/@chapter != '' or @subject != preceding-sibling::page[1]/@subject and preceding-sibling::page[1]/@chapter != ''">
                <xsl:call-template name="figure-pgblk-divider-row"/>
              </xsl:if>
            </xsl:when>
            <xsl:when test="@pgblk != preceding-sibling::page[1]/@pgblk and @number != 'TC-1'">
              <xsl:call-template name="figure-pgblk-divider-row"/>
            </xsl:when>
          </xsl:choose>
          <!-- DJH ADD END -->

          <!-- DJH REMOVE 20091124
            <xsl:if test="@section != preceding-sibling::page[1]/@section 
              or @subject != preceding-sibling::page[1]/@subject"> 
              <xsl:call-template name="section-subject-divider-row"/>
            </xsl:if>

            <xsl:if test="@pgblk != preceding-sibling::page[1]/@pgblk">
              <xsl:call-template name="figure-pgblk-divider-row"/>
            </xsl:if>
          -->

          <!-- Make sure we skip the "real" foldouts, and the second placeholder page -->
          <xsl:if test="not(@foldout) or (@foldout and 1 = (@number mod 2))">
            <xsl:call-template name="detail-standard-row">
              <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:if>

      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="do-lep-frontmatter">
    <xsl:param name="LEP_EXTRACT_FILE"/>
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate"/>
    <xsl:for-each select="document($LEP_EXTRACT_FILE)">
      <xsl:for-each select="//page[@chapter = '']">
        <xsl:variable name="pagePrefix" select="substring-before(@number,'-')"/>
        <xsl:variable name="pageNumber" select="substring-after(@number,'-')"/>
        <xsl:if test="@number = 'TC-1'">
          <xsl:variable name="lepPageCount">
            <xsl:call-template name="calculate-lep-pages"/>
          </xsl:variable>
          <!-- For Debug
          <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (do-lep-frontmatter - for-each) </xsl:message>
          -->
          <xsl:call-template name="lep-row">
            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
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
              <!-- DJH 20090820
              <xsl:value-of select="concat(@number,'/',following-sibling::page[1]/@number)"/>
              -->
              <xsl:value-of select="concat(@number,'/',sum(@number + 1))"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@number"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:table-cell>

      <!-- Revision indicator -->
      <xsl:call-template name="detail-empty-cell"/>

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
        <fo:block font-size="10pt">
          <!-- DJH START -->
          <xsl:call-template name="lep-asterisk">
            <xsl:with-param name="revDate">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
          <!-- DJH END -->
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
     <fo:table-row keep-with-next.within-column="always" padding-top="4pt" padding-bottom="4pt">
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="12pt">
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
            <xsl:when test="$manualName = 'EM' and (number(@number) = 1) or (1 = number(@number) - number(@pgblk))">
               <!--
               <fo:inline text-transform="capitalize">
               -->
               <xsl:value-of select="replace(./@label,'/','/&#x0200B;')"/>
               <!--
               </fo:inline>
               -->
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
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left">
        <fo:block font-weight="normal">
          <xsl:text>Table of Contents</xsl:text>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="section-subject-divider-row">
    <xsl:if test="((@subject='') and (@unit='') and (preceding-sibling::page[1][@section=''][@chapter!='']))">
      <xsl:variable name="lepPageCount">
        <xsl:call-template name="calculate-lep-pages"/>
      </xsl:variable>
      <!-- For Debug
      <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (section-subject-divider-row) </xsl:message>
      -->
      <xsl:call-template name="lep-row">
        <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
        <xsl:with-param name="indent" select="'4pt'"/>
        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
      </xsl:call-template>
    </xsl:if>
    <fo:table-row keep-with-next.within-column="always">
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left">
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

    <xsl:if test="$lepCallCount = 1">
      <fo:table-row keep-with-next.within-column="always">
        <!-- Foldout Indicator -->
        <xsl:call-template name="detail-empty-cell"/>
        <!-- Title -->
        <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="{$indent}">
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
      <xsl:call-template name="detail-empty-cell"/>

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
          <!-- DJH START -->
          <xsl:call-template name="lep-asterisk">
            <xsl:with-param name="revDate">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
          <!-- DJH END -->
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


  <xsl:template name="lep-asterisk">
    <!-- DJH ADDED -->
    <xsl:param name="revDate" select="0"/>
    <!-- FOR DEBUG
	 <xsl:message>ENTERING ASTERISK RULE (REVDATE = "<xsl:value-of select="$revDate"/>" | MANUAL REVDATE = "<xsl:value-of select="$manualRevdate"/>")</xsl:message>
	 -->
    <xsl:choose>
        <!-- Added for mantis #16245 -->
        <xsl:when test="not(//processing-instruction()[name()='firstXMLrevision'])">
            <xsl:text>&#160;</xsl:text>
        </xsl:when>
        <xsl:when test="$revDate = $manualRevdate">
        <!-- FOR DEBUG
			<xsl:message>OUTPUT '*'</xsl:message>
			-->
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- FOR DEBUG
		  <xsl:message>OUTPUT ' '</xsl:message>
		  -->
        <xsl:text>&#160;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <!-- FOR DEBUG
	<xsl:message>LEAVING ASTERISK RULE</xsl:message>
	-->
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
    <xsl:variable name="entriesPerPage" select="74"/>
    <!-- Each new Pgblk element adds a blank line in the LEP -->
    <xsl:variable name="pgblkCount">
      <xsl:value-of select="count(//page[@chapter = $chapter])"/>
    </xsl:variable>
    <xsl:variable name="rawLepCount">
      <xsl:value-of select="ceiling(($pgblkCount + $lepPages ) div $entriesPerPage)"/>
    </xsl:variable>
    <!-- === Messages for debug === -->
    <!--
    <xsl:message>chapter = '<xsl:value-of select="$chapter"/>'</xsl:message>
    <xsl:message>pgblkCount = '<xsl:value-of select="$pgblkCount"/>'</xsl:message>
    <xsl:message>rawLepCount = '<xsl:value-of select="$rawLepCount"/>'</xsl:message>
    <xsl:message>lepPages = '<xsl:value-of select="$lepPages"/>'</xsl:message>
    -->
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
