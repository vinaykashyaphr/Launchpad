<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:xep="http://www.renderx.com/XEP/xep" exclude-result-prefixes="xep">

   <xsl:import href="unhandled-element.xsl"/>

   <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
   
   <xsl:key name="revisedFoldout" 
      match="xep:page[xep:target[starts-with(@id,'foldout_key_')]][xep:text/@value=('__revst__','__revend__')]" 
      use="xep:target[starts-with(@id,'foldout_key_')]/@id"/>

   <!--new-revdate should only need to be determined once.--> 
   <xsl:variable name="new-revdate">
      <xsl:variable name="text-date">
         <xsl:choose>
            <xsl:when test="string(//xep:page[1]/xep:text[@value='Revised ']/following-sibling::xep:text[1]/@value)">
               <xsl:value-of select="//xep:page[1]/xep:text[@value='Revised ']/following-sibling::xep:text[1]/@value"/>
            </xsl:when>
            <!--
               During local testing, the revdate was not being stored in a single @value. Example:
                  <xep:text value="Revised" x="473450" y="20612" width="36120"/>
                  <xep:text value="13" x="512340" y="20612" width="11120"/>
                  <xep:text value="Jun" x="526230" y="20612" width="16120"/>
                  <xep:text value="2017" x="545120" y="20612" width="22240"/>
            -->
            <xsl:otherwise>
               <xsl:value-of select="//xep:page[1]/xep:text[@value='Revised']/following-sibling::xep:text[position()=(1,2,3)]/@value"/>        
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$text-date"/>
   </xsl:variable>

   <xsl:template match="/">
      <xsl:message>******************************************************************************</xsl:message>
      <xsl:message>Extracting LEP Data from RenderX Intermediate File</xsl:message>
      <xsl:message>******************************************************************************</xsl:message>
      <lepdata>
         <!-- Ignore the second placeholder for the foldouts, and the foldouts themselves, which -->
         <!-- are still located at the end of document  when this extract file is being built    -->
         <xsl:for-each select="//xep:page">
        <xsl:choose>
          <!--**The "skipping page with no contents" rules could be the cause if some pages are dropped unintentionally**-->
          <xsl:when test=".[xep:text[@value='Page' and not(following-sibling::xep:text[1][@value='T-'])]][xep:polygon[1][not(preceding-sibling::xep:text)]][not(xep:target[contains(.,'ITG_FOLDOUT')])][not(xep:text[@value='1234567'])][following-sibling::xep:page[1][xep:text[@value='Page' and not(following-sibling::xep:text[1][@value='T-'])]][xep:text[1]/@value='Blank' and xep:text[2]/@value='Page']]">
            <xsl:message>Skipping page with no contents. (1) (page-id: <xsl:value-of select="@page-id"/>)</xsl:message>
          </xsl:when>
          <xsl:when test=".[xep:text[not(@value='Page' and following-sibling::xep:text[1][@value='T-'])]][xep:text[1]/@value='Blank' and xep:text[2]/@value='Page'][preceding-sibling::xep:page[1][not(xep:text[@value='1234567'])][xep:text[not(@value='Page' and following-sibling::xep:text[1][@value='T-'])]][xep:polygon[1][not(preceding-sibling::xep:text)]]][not(contains(xep:target,'ITG_FOLDOUT'))]">
            <xsl:message>Skipping page with no contents. (2) (page-id: <xsl:value-of select="@page-id"/>)</xsl:message>
          </xsl:when>
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
            <xsl:number/>
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

         <xsl:attribute name="figure">
            <xsl:call-template name="get-value">
               <xsl:with-param name="key" select="'figure'"/>
            </xsl:call-template>
         </xsl:attribute>

        <!--Added for mantis #20187-->
        <xsl:attribute name="confnbr">
          <xsl:call-template name="get-value">
            <xsl:with-param name="key" select="'confnbr'"/>
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
            <xsl:message>numerical-revdate (to get revdate): "<xsl:value-of select="$numerical-revdate"/>"</xsl:message>
            <xsl:message>revdate: "<xsl:value-of select="normalize-space($revdate)"/>"</xsl:message>
            <xsl:message>new-revdate: "<xsl:value-of select="normalize-space($new-revdate)"/>"</xsl:message>
            <xsl:choose>

               <!-- Sonovision update (2019.06.26)
                    - sometimes the revision marker gets forced into uppercase
                      -->
               <!-- <xsl:when test=".//xep:text[@value='__revst__' or @value='__revend__'] and normalize-space($revdate)=normalize-space($new-revdate)"> -->
               <xsl:when test=".//xep:text[@value='__revst__' or @value='__revend__' or @value='__REVST__' or @value='__REVEND__'] and normalize-space($revdate)=normalize-space($new-revdate)">

                  <xsl:text>*</xsl:text>
                  <xsl:message>revised: *</xsl:message>
               </xsl:when>
               <xsl:when test="xep:target[starts-with(@id,'foldout_key_')] and key('revisedFoldout',xep:target[starts-with(@id,'foldout_key_')]/@id)">
                  <xsl:text>*</xsl:text>
                  <xsl:message>revised foldout: *</xsl:message>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>&#160;</xsl:text>
                  <xsl:message>revised: &#160;</xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
         <!-- DJH START -->
         <xsl:variable name="dest-id">
            <xsl:value-of select="./xep:target[1]/@id"/>
         </xsl:variable>
         <xsl:variable name="label">
            <xsl:value-of select="//xep:internal-bookmark[@destination-id = $dest-id]/@label[starts-with(.,'Page Block')]"/>
         </xsl:variable>
         <xsl:if test="$label != ''">
            <xsl:attribute name="label">
               <!-- 
            <xsl:value-of select="substring($label,11)"/>
            -->
               <xsl:value-of select="substring-after($label,' - ')"/>
            </xsl:attribute>
         </xsl:if>

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
