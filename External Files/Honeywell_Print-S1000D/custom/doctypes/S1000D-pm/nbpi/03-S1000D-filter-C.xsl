<?xml version="1.0"  encoding="UTF-8" ?>

<!-- 
==============================================
Create lookup file 
"S1000D-replace-internalRefId.xml"
==============================================

S1000D-filter-C.xsl

Version: 0.1
Created: April 29, 2013
Last Modified: April 29, 2013

Chris van Mels
NewBook Production Inc.
7045 Edwards Blvd.
Suite 101
Mississauga, Ontario, Canada
L5S 1X2
(905) 670-9997 ext.26
cvanmels@newbook.com
=============================================

Notes:
=====

v.0.1:
=====
	- create lookup file "S1000D-replace-internalRefId.xml" containing:

          <TEMP_REPLACE suppressed-id="DMC-d1e4490-seq-0003" stable-id="DMC-d1e4235-seq-0003"/>

          temp elements generated in previous step
          
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


<!-- CV - create XML lookup file with replace values -->
<xsl:variable name="output-file" select="'S1000D-replace-internalRefId.xml'"/>


<!-- CV - almost everything should just flow through -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- CV - put some line breaks around comments -->
<!--
<xsl:template match="comment()" priority="1">
  <xsl:text>&#xA;</xsl:text>
  <xsl:comment>
    <xsl:value-of select="."/>
  </xsl:comment>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>
-->

<!-- <xsl:template match="TEMP_REPLACE"/> -->

<xsl:template match="/">

 
 <xsl:result-document href="{$output-file}">

  <xsl:text>&#xA;</xsl:text>
  <list>

   <xsl:for-each select="//TEMP_REPLACE">
    <xsl:text>&#xA;</xsl:text>
    <TEMP_REPLACE>
     <xsl:attribute name="suppressed-id"><xsl:value-of select="@suppressed-id"/></xsl:attribute>
     <xsl:attribute name="stable-id"><xsl:value-of select="@stable-id"/></xsl:attribute>
    </TEMP_REPLACE>
   </xsl:for-each>

  <xsl:text>&#xA;</xsl:text>
  </list>

 </xsl:result-document>
 
 <xsl:apply-templates/>
  
</xsl:template>


</xsl:stylesheet>
