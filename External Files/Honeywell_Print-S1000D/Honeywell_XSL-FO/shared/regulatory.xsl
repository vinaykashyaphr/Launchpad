<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">
  
  <xsl:template match="REGULATORY">
    <xsl:choose>
      <xsl:when test="parent::PGBLK | parent::TASK | parent::SUBTASK">
        
        <fo:list-block font-size="10pt" font-weight="bold" text-align="left" space-before=".1in" space-after=".1in" keep-together.within-page="always" keep-with-next.within-page="always">
          <xsl:for-each select="REGULATION">
            <fo:list-item>
              <fo:list-item-label end-indent="label-end()">
                <fo:block margin-left="-0.3in">
                  <fo:inline padding-right="1pt" padding-left="1pt" margin-left="0.3in" margin-right="-0.75in">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="@REGTYPE"/>
                    <xsl:text>]</xsl:text>
                  </fo:inline>
                </fo:block>
              </fo:list-item-label>
              <fo:list-item-body start-indent="body-start()">
                <xsl:call-template name="check-rev-start"/>
                <fo:block  margin-left="0.35in">
                  <xsl:apply-templates/>
                </fo:block>
                <xsl:call-template name="check-rev-end"/>
              </fo:list-item-body>
            </fo:list-item>
          </xsl:for-each>
        </fo:list-block>
        
      </xsl:when>
      <xsl:when test="parent::PRCITEM">
        <fo:inline font-weight="bold" padding-right="1pt" padding-left="1pt" margin-left="0.3in" margin-right="-0.75in">
          <xsl:text>[</xsl:text>
          <xsl:value-of select="REGULATION/@REGTYPE"/>
          <xsl:text>]</xsl:text>
        </fo:inline>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>
  
  
  
</xsl:stylesheet>

