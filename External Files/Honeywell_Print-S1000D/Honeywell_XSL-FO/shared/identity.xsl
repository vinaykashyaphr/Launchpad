<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!-- Indentity template -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!--This doesn't appear to be used anymore. Should remove this and the param from the EIPC driver.-->
  <xsl:template match="/eipc//processing-instruction()[name()='firstXMLrevision'][1]">
    <xsl:result-document href="firstXMLrevision.xml">
      <firstXMLrevision/>
    </xsl:result-document>
    <xsl:copy-of select="."/>
  </xsl:template>

</xsl:stylesheet>
