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
  <xsl:template match="fo:page-sequence[fo:flow/fo:block//fo:list-block/fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]">
    <!-- <xsl:message>
      <xsl:text> CJ TEST: count of list-blocks in a block that has a "DELETE THIS LIST-BLOCK": </xsl:text>
      <xsl:value-of select="count(fo:flow/fo:block//fo:block[fo:list-block/fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]/fo:list-block)"></xsl:value-of>
    </xsl:message> -->
    <!-- <xsl:choose>
      <xsl:when test="count(fo:flow/fo:block//fo:block[fo:list-block/fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]/fo:list-block)>1">
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
    </xsl:choose> -->
    
    <xsl:choose>
      <!-- Condition to remove the whole page sequence: When there is a block in a list block with "***DELETE THIS LIST-BLOCK***" -->
      <!-- (we know that already from the template match) -->
      <!-- and there are no other blocks than the one containing the -->
      <!-- list block(s) with the deletion text, and if there are no other list blocks with real content. -->
      
      <xsl:when test="count(fo:flow/fo:block//fo:block[fo:list-block]) = 1
        and (count(fo:flow/fo:block//fo:block/fo:list-block) = 1
        or (count(fo:flow/fo:block//fo:block/fo:list-block) = 2        
        and not(fo:flow/fo:block//fo:block/fo:list-block[2]/fo:list-item/fo:list-item-body/fo:block/*)
        and normalize-space(fo:flow/fo:block//fo:block/fo:list-block[2]/fo:list-item/fo:list-item-body/fo:block)=''))">
        <!-- The "or" clause means that if there is a second list block, then its contents are empty. -->
        <!-- If there are more than two, then we should not remove the page sequence. -->
        <xsl:message>
          <xsl:text>Removed page-sequence #</xsl:text>
          <xsl:value-of select="position()"/>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Delete the list block itself that is part of a section with real content. -->  
  <xsl:template match="fo:list-block[fo:list-item/fo:list-item-body/fo:block[normalize-space(.)='***DELETE THIS LIST-BLOCK***']]"/>
      
</xsl:stylesheet>
