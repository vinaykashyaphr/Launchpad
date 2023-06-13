<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xep="http://www.renderx.com/XEP/xep">


  <xsl:import href="../shared/unhandled-element.xsl"/>

  <xsl:template match="/">
    <xsl:message>******************************************************************************</xsl:message>
    <xsl:message>Extracting LEP Data from RenderX Intermediate File</xsl:message>
    <xsl:message>Parsing <xsl:value-of select="count(//*)"/> elements</xsl:message>
    <xsl:message>******************************************************************************</xsl:message>
    <lepdata>
      <!-- Ignore the second placeholder for the foldouts, and the foldouts themselves, which -->
      <!-- are still located at the end of document  when this extract file is being built    -->
      <xsl:attribute name="documentType">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'documentType'"/>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:for-each select="//xep:page">
        <xsl:choose>
          <!--**The "skipping page with no contents" rules could be the cause if some pages are dropped unintentionally**-->
          <!-- RS: Removed this for now: it was dropping some Introduction pages in IRM for some reason.
          <xsl:when test=".[xep:text[@value='Page' and not(following-sibling::xep:text[1][@value='T-'])]][xep:polygon[1][not(preceding-sibling::xep:text)]][not(xep:target[contains(.,'ITG_FOLDOUT')])][not(xep:text[@value='1234567'])][following-sibling::xep:page[1][xep:text[@value='Page' and not(following-sibling::xep:text[1][@value='T-'])]][xep:text[1]/@value='Blank' and xep:text[2]/@value='Page']]">
            <xsl:message>Skipping page with no contents. (1) (page-id: <xsl:value-of select="@page-id"/>)</xsl:message>
          </xsl:when>
          <xsl:when test=".[xep:text[not(@value='Page' and following-sibling::xep:text[1][@value='T-'])]][xep:text[1]/@value='Blank' and xep:text[2]/@value='Page'][preceding-sibling::xep:page[1][not(xep:text[@value='1234567'])][xep:text[not(@value='Page' and following-sibling::xep:text[1][@value='T-'])]][xep:polygon[1][not(preceding-sibling::xep:text)]]][not(contains(xep:target,'ITG_FOLDOUT'))]">
            <xsl:message>Skipping page with no contents. (2) (page-id: <xsl:value-of select="@page-id"/>)</xsl:message>
          </xsl:when> -->
          <xsl:when test="xep:target[contains(@id,'ITG_TABLE_FOLDOUT')]">
            <xsl:call-template name="do-page"/>
            <xsl:message>Calling do-page for "ITG_TABLE_FOLDOUT" page.</xsl:message>
          </xsl:when>
          <xsl:when test=".[xep:target[starts-with(@id,'foldout_table_page')]][preceding-sibling::xep:page[1][xep:target[starts-with(@id,'foldout_table_page')]]]">
            <xsl:call-template name="do-page">
              <xsl:with-param name="FoldoutTable" select="1"/>
            </xsl:call-template>
            <xsl:message>Calling do-page for "foldout_table_page" page.</xsl:message>
          </xsl:when>
          <xsl:when test="xep:target[contains(@id,'ITG_NO_COPY')]">
            <!-- This is the placeholder, skip it -->
            <xsl:message>Skipping the second placeholder</xsl:message>
          </xsl:when>
          <xsl:when test="@width &gt; 792000">
            <!-- This is the real foldout, skip it -->
            <xsl:message>Skipping the real foldout</xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="do-page"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </lepdata>
  </xsl:template>

  <xsl:template name="do-page">
    <xsl:param name="FoldoutTable" select="0"/>
    <page>
      <xsl:attribute name="position">
        <xsl:value-of select="1 + count(preceding-sibling::xep:page)"/>
      </xsl:attribute>

      <xsl:attribute name="number">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'page'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="chapter">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'chapter'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="section">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'section'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="subject">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'subject'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="unit">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'unit'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="pgblk">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'pgblk'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="confnbr">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'confnbr'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="effect">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'effect'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="figure">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'figure'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="revdate">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'revdate'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:attribute name="revised">
        <xsl:variable name="numerical-revdate">
          <xsl:call-template name="get-value">
            <xsl:with-param name="key" select="'revdate'"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="revdate">
          <xsl:call-template name="convert-date">
            <xsl:with-param name="ata-date" select="$numerical-revdate"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="new-revdate">
          <xsl:value-of select="//xep:page[1]/xep:text[@value='Revised ']/following-sibling::xep:text[1]/@value"/>
        </xsl:variable>
        <!-- <xsl:message>revdate: "<xsl:value-of select="$revdate"/>"</xsl:message>
        <xsl:message>numerical-revdate: "<xsl:value-of select="$numerical-revdate"/>"</xsl:message>
        <xsl:message>new-revdate: "<xsl:value-of select="$new-revdate"/>"</xsl:message> -->
        <xsl:choose>
          <!-- RS: The new revdate (from the Revised date on the first page) is empty in out test sample, so this condition always fails.
          May need to revisit if it is not behaving as expected.
          <xsl:when test=".//xep:text[@value='__revst__' or @value='__revend__'] and normalize-space($revdate)=normalize-space($new-revdate)">
           -->
          <xsl:when test=".//xep:text[@value='__revst__' or @value='__revend__' or @value='__revcont__']">
            <xsl:text>*</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>&#160;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <xsl:attribute name="documentType">
        <xsl:call-template name="get-value">
          <xsl:with-param name="key" select="'documentType'"/>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:variable name="target-id">
        <xsl:value-of select="./xep:target[1]/@id"/>
      </xsl:variable>
      <xsl:attribute name="target-id" select="$target-id"/>

      <!-- The label (section name) for the LEP is based on the label used for PDF bookmarks. -->
      <!-- It might be better in the future to use the same technique as most other extracted values -->
      <!-- (a "key" in the text, like "__documentType__" followed by the text), since in some -->
      <!-- cases (such as SPM... see below) the LEP label might differ from the PDF bookmark. -->
      <xsl:attribute name="label">
        <xsl:variable name="doctype">
	        <xsl:call-template name="get-value">
	          <xsl:with-param name="key" select="'documentType'"/>
	        </xsl:call-template>
		</xsl:variable>
		<xsl:variable name="bookmarkLabel" select="(//xep:internal-bookmark[@destination-id = $target-id])[1]/@label"/>
		
		<!-- For the SPM LEP, the section title is different than the PDF bookmark in that it has "SECTION N - " -->
		<!-- removed. For now, just use a regular expression to strip it out. -->
        <xsl:choose>
        	<xsl:when test="$doctype='spm'">
        		<xsl:value-of select="replace($bookmarkLabel, '^SECTION [IVX]+ . ','')"/>
        	</xsl:when>
        	<xsl:otherwise>
        		<xsl:value-of select="$bookmarkLabel"/>
        	</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <!-- This is the foldout marker in the placeholder page -->
      <xsl:if test="child::xep:target[contains(@id,'ITG_FOLDOUT')]">
        <xsl:attribute name="foldout">F</xsl:attribute>
      </xsl:if>
      <xsl:if test="xep:target[contains(@id,'ITG_TABLE_FOLDOUT')]">
        <xsl:attribute name="foldout" select="'F'"/>
      </xsl:if>
      <xsl:if test="$FoldoutTable = 1">
        <xsl:attribute name="foldout" select="'F'"/>
      </xsl:if>

    </page>
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

  <xsl:template name="get-value">
    <xsl:param name="key" select="notset"/>
    <xsl:variable name="marker" select="concat('__',substring($key,1,2))"/>
    <xsl:variable name="fullMarker" select="concat('__',$key,'__')"/>
    <xsl:variable name="fullString">
      <xsl:for-each select="xep:text[starts-with(@value,$marker)]">
        <xsl:call-template name="get-line">
          <xsl:with-param name="y" select="number(@y)"/>
          <xsl:with-param name="work" select="@value"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="substring-after($fullString,$fullMarker)"/>
  </xsl:template>

  <!-- This template appends any following sibling xep:text elements that have the -->
  <!-- same Y value. Stops at the first non-xep:text element                       -->
  <xsl:template name="get-line">
    <xsl:param name="work" select="''"/>
    <xsl:param name="y"/>
    <xsl:choose>
      <xsl:when test="following-sibling::xep:text[1][number(@y) = $y]">
        <xsl:for-each select="following-sibling::xep:text[1]">
          <xsl:call-template name="get-line">
            <xsl:with-param name="work" select="concat($work,@value)"/>
            <xsl:with-param name="y" select="$y"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$work"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
