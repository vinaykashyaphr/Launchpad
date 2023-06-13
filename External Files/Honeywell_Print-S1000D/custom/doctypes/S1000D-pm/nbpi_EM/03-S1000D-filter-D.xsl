<?xml version="1.0"  encoding="UTF-8" ?>

<!-- 
==============================================
Fix "@internalRefId" that point to suppressed
items and remove repeated <acronym/>
wrappers
==============================================

S1000D-filter-D.xsl

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
	- read lookup file "S1000D-replace-internalRefId.xml"
          and fix the @internalRefId where @id of repeated
          item has been suppressed and must now point
          to the @id of first item of that list
          
        - keep the first instance of an "acronym"

          e.g.
          <acronym acronymType="at01">
          <acronymTerm>DC</acronymTerm>
          <acronymDefinition>dry conditions</acronymDefinition>
          </acronym>
          
          in the "pm" document while all subsequent 
          repeats of same acronym will just be 
          text (e.g. "DC")
          
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
<xsl:variable name="S1000D-replace-internalRefId" select="document('S1000D-replace-internalRefId.xml')"/>

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


<!-- ******************************************************************* -->
<!-- 1. Fix "@internalRefId" pointing to deleted "@id" -->

<!-- CV - remove the temp elements -->
<xsl:template match="TEMP_REPLACE"/>

<xsl:template match="@internalRefId">

  <xsl:variable name="current_internalRefId" select="."/>
 
  <xsl:variable name="TEST" select="count($S1000D-replace-internalRefId/list/TEMP_REPLACE[@suppressed-id = $current_internalRefId])"/>
  
  <xsl:attribute name="internalRefId">
   <xsl:choose>
    <xsl:when test="count($S1000D-replace-internalRefId/list/TEMP_REPLACE[@suppressed-id = $current_internalRefId]) &gt; 0">
     <!-- <xsl:text>CHANGED-</xsl:text> -->
     <xsl:value-of select="$S1000D-replace-internalRefId/list/TEMP_REPLACE[@suppressed-id = $current_internalRefId]/@stable-id"/>
    </xsl:when>
    <xsl:otherwise>
     <!-- <xsl:text>SAME-</xsl:text> -->
     <xsl:value-of select="."/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>

</xsl:template>


<!-- ******************************************************************* -->
<!-- 2. Remove repeated "acronym" wrappers -->

<xsl:template match="acronym">
  
  <xsl:variable name="current_acronymTerm" select="normalize-space(acronymTerm)"/>
  
  <xsl:choose>
   <xsl:when test="not(preceding::acronym/acronymTerm = $current_acronymTerm)">
    <acronym>
     <xsl:apply-templates select="@*"/>
     <xsl:apply-templates/>
    </acronym>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$current_acronymTerm"/>
   </xsl:otherwise>
  </xsl:choose>

</xsl:template>


</xsl:stylesheet>
