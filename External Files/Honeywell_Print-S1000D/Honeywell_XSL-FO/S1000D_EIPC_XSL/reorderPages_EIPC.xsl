<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xep="http://www.renderx.com/XEP/xep" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">
<xsl:import href="../shared/identity.xsl"/>
<xsl:output method="xml" encoding="UTF-8" indent="yes"></xsl:output>


  <!-- ======================================================================================== -->
  <!-- This stylesheet converts the AT version of the Service Bulletin, with placeholder pages  -->
  <!-- and foldout pages at the end, into an XEP version of the document, with the placeholder  -->
  <!-- pages replaced by the foldout pages.  All bookmarks and links stay intact.               -->
  <!-- ======================================================================================== -->
  
  <xsl:template match="/">
    <xsl:message>******************************************************************************</xsl:message>
    <xsl:message>Parsing <xsl:value-of select="count(//*)"/> elements...</xsl:message>
    <xsl:message>******************************************************************************</xsl:message>
  	<xsl:apply-templates/>
  </xsl:template>

  <!--<!-\-strip extra blank (header/footer but no content) pages **this could be the cause if some pages are dropped unintentionally**-\->
  <xsl:template match="xep:page[xep:polygon[1][not(preceding-sibling::xep:text)]][not(xep:text[@value='1234567'])][not(contains(xep:target,'ITG_FOLDOUT'))][not(contains(xep:target/@id,'cmm_title_page'))][following-sibling::xep:page[1][xep:text[1]/@value='Blank' and xep:text[2]/@value='Page']]">
    <xsl:message>Stripped page with no contents (1). (page-id: <xsl:value-of select="@page-id"/>)</xsl:message>
  </xsl:template>
  <xsl:template match="xep:page[xep:text[1]/@value='Blank' and xep:text[2]/@value='Page'][preceding-sibling::xep:page[1][not(contains(xep:target/@id,'cmm_title_page'))][not(xep:text[@value='1234567'])][xep:polygon[1][not(preceding-sibling::xep:text)]]][not(contains(xep:target,'ITG_FOLDOUT'))][not(contains(xep:target/@id,'cmm_title_page'))]">
    <xsl:message>Stripped page with no contents (2). (page-id: <xsl:value-of select="@page-id"/>)</xsl:message>
  </xsl:template>-->
  
  <xsl:template match="xep:page">
      <xsl:choose>
        <!-- Page should be replaced -->
        <xsl:when test="xep:target[contains(@id,'ITG_FOLDOUT')]">
          <xsl:variable name="my-link" select=".//xep:target[starts-with(@id,'foldout_key')]" />
          <xsl:variable name="key" select="$my-link/@id"/>
          <xsl:message>reorderPages_CMM.xsl: In "ITG_FOLDOUT"</xsl:message>
          <xsl:message><xsl:value-of select="concat('Key is: ',$key)"/></xsl:message>
           <xsl:choose>
              <xsl:when test="xep:target[contains(@id,'ITG_FOLDOUT_W-GDESC')]">
                <xsl:message>reorderPages_CMM.xsl: In "ITG_FOLDOUT_W-GDESC"</xsl:message>
                <xsl:copy-of select="//xep:page[@width &gt; 792000][xep:target/@id = $key]"/>
            <xsl:copy-of select="//xep:page[@width &gt; 792000][xep:target/@id = $key]/following-sibling::xep:page[1]"/>
              </xsl:when>
              <xsl:otherwise>
                 <!-- The "real" page has the key on it also. We can find by that + the page width -->
                 <xsl:copy-of select="//xep:page[@width &gt; 792000][xep:target/@id = $key]"/>
                 <!-- Copy the next page also which is completely blank -->
                 <xsl:copy-of select="//xep:page[@width &gt; 792000][xep:target/@id = $key]/following-sibling::xep:page[1]"/>                 
              </xsl:otherwise>
           </xsl:choose>
        </xsl:when>
        
        <xsl:when test="xep:target[contains(@id,'ITG_TABLE_FOLDOUT')]">
          <xsl:copy-of select="."/>
        </xsl:when>
        
        <!-- Page should ignored (second page inserted for page count -->
        <xsl:when test="xep:target[contains(@id,'ITG_NO_COPY')]">
          <xsl:message>Ignoring second placeholder page</xsl:message>
          <!-- Do nothing -->
        </xsl:when>
        
        <!-- Page is wide. This template should ignore it -->
        <!-- xep measurements are in 1000th of a point (1/72000 inches -->
        <xsl:when test="@width &gt; 792000">
          <xsl:message>Page is foldout -- Do not copy directly</xsl:message> 
        </xsl:when>
        
        <!-- Regular page -->
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
