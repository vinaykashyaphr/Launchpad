<?xml version="1.0"  encoding="UTF-8" ?>

<!-- 
==============================================
Pre-process the S1000D "PMC" main file to add
pmEntryType attributes if they are missing.
==============================================

00-S1000D-pre-pprocess.xsl

Version: 0.3
Created: October 17, 2018

Version: 0.2
Created: April 12, 2018

Version: 0.1
Created: May 28, 2018
Last Modified: May 28, 2018

Richard Steadman
NewBook Production Inc.
=============================================

Notes:
=====

v.0.3:
=====
	- Added the print variant passed as a parameter from the command line

v.0.2:
=====
	- Added "type" parameter to support different document types such as "mm", "lmm", etc.

v.0.1:
=====
	- Initial version

-->


<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink">


<!-- CV - @indent="yes" produces readable XML,
          but introduces leading space in table entries with bold:
            <entry>
              <b>TEXT</b>
            </entry>
            
        - use @indent="no" for final XML
          -->
<xsl:output method="xml"
            media-type="text/xml"
            encoding="UTF-8"
            indent="no"
            />

<!-- <xsl:strip-space elements="*"/> -->

<!-- RS - parameter passed from command line for the document type, like "mm" or "lmm" -->
<xsl:param name="type">
 <xsl:text>mm</xsl:text>
</xsl:param>

<!-- RS - parameter passed from command line for the print variant, like "std" or "dmc" -->
<xsl:param name="variant">
 <xsl:text>std</xsl:text>
</xsl:param>


<!-- CV - almost everything should just flow through -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Top-level pm element -->
<xsl:template match="pm">
  <xsl:copy>
	<!-- RS: Add the doctype and print-variant attributes -->
	<xsl:attribute name="type">
		<xsl:value-of select="$type"/>
	</xsl:attribute>
 	<xsl:attribute name="print-variant">
		<xsl:value-of select="$variant"/>
	</xsl:attribute>
	<!-- Detect if it's a new 5-level PMC structure, and set the new-pmc attribute to yes if it is. -->
	<xsl:if test="/pm/content/pmEntry/pmEntry/pmEntry/pmEntry/pmEntry">
		<xsl:attribute name="new-pmc" select="'yes'"/>
	</xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- RS: Infer the pmEntryType from the infoCode -->
<!-- RS: Now pmEntryType is required, so disable the inference (adding "xxxx", to leave for possible future reinstatement). -->
<xsl:template match="xxxx_pmEntry[not(@pmEntryType)]">
  <xsl:copy>
	<xsl:choose>
		<!-- Proprietary Information -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='023']">
			<xsl:attribute name="pmEntryType" select="'pmt77'"/>
		</xsl:when>
		<!-- Record of Revisions -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='003']">
			<xsl:attribute name="pmEntryType" select="'pmt53'"/>
		</xsl:when>
		<!-- Service Bulletin List -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='008']">
			<xsl:attribute name="pmEntryType" select="'pmt55'"/>
		</xsl:when>
		<!-- Introduction -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='018']">
			<xsl:attribute name="pmEntryType" select="'pmt58'"/>
		</xsl:when>
		<!-- Description and Operation -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='030']">
			<xsl:attribute name="pmEntryType" select="'pmt59'"/>
		</xsl:when>
		<!-- Fault isolation -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='420']">
			<xsl:attribute name="pmEntryType" select="'pmt60'"/>
		</xsl:when>
		<!-- Servicing -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='800']">
			<xsl:attribute name="pmEntryType" select="'pmt72'"/>
		</xsl:when>
		<!-- Not sure what to pmEntryTypes to use for "Maintenance Practices", "Adjustment and Test".
		For now use pmt76 for "Maintenance Practices" and pmt77 for "Adjustment and Test". -->
		<!-- Maintenance Practices -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='500']">
			<xsl:attribute name="pmEntryType" select="'pmt76'"/>
		</xsl:when>
		<!-- Adjustment and Test -->
		<xsl:when test="dmRef/dmRefIdent/dmCode[@infoCode='300']">
			<xsl:attribute name="pmEntryType" select="'pmt77'"/>
		</xsl:when>
	</xsl:choose>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
