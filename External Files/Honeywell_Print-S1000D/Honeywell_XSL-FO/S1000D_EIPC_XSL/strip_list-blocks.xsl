<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:output indent="no"/>
  <!-- <xsl:strip-space elements="*"/> -->

<!--
  This transform strips out the list-block that is added to keep the fo: well-formed when using CDATA to open/close
  page-sequence's (for landscape tables). (tbl-caps.xsl)
-->
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- CJM : OCSHONSS-499 : Added match for finding empty page-sequences between adjacent Landscape or Foldout pages. -->
  <xsl:template match="fo:page-sequence[fo:flow/fo:block/fo:list-block/fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]">
    <!--<xsl:message>
      <xsl:text> CJ TEST : </xsl:text>
      <xsl:value-of select="count(fo:flow/fo:block[fo:list-block/fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]/fo:list-block)"></xsl:value-of>
    </xsl:message>-->
    <xsl:choose>
      <xsl:when test="count(fo:flow/fo:block[fo:list-block/fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]/fo:list-block)>2">
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Removed page-sequence #</xsl:text>
          <xsl:value-of select="position()"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="fo:list-block[fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]"/>
  
  
      
</xsl:stylesheet>
