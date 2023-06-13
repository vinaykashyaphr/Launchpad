<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

  <xsl:variable name="manualName" select="'CMM'"/>

  <xsl:param name="UNIT_TEST" select="0"/>
  <!--<xsl:variable name="GRAPHICS_SUFFIX" select="'.tif'" />-->
  <xsl:variable name="GRAPHICS_SUFFIX" select="''"/>

  <xsl:variable name="chapSectSubj" select="concat(/*/@CHAPNBR,'-',
      /*/@SECTNBR,'-',/*/@SUBJNBR)"/>



</xsl:stylesheet>
