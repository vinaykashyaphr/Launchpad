<?xml version="1.0"  encoding="UTF-8" ?>

<!-- 
==============================================
Filter out duplicate entries in requirements
tables
==============================================

S1000D-filter-B.xsl

Version: 0.1
Created: April 26, 2013
Last Modified: April 26, 2013

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
	- filter out duplicate entries from the already sorted and collected
	  "pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts"
	  
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

<!-- ********************************************** -->
<!-- Suppress "preliminaryRqmts" items where "name"
     is duplicated
     (must also adjust all "@internalRefId" to point
      to @id of the item "name" that's not being
      deleted)
      -->

<xsl:template match="supportEquipDescr">
  
  <xsl:variable name="current_name" select="name"/>
  <xsl:variable name="current_id" select="@id"/>
  
  <!-- Get the "id" of first item in list of repeated "name" entries -->
  <xsl:variable name="stable_id" select="parent::supportEquipDescrGroup/supportEquipDescr[name = $current_name][1]/@id"/>
  
  <xsl:choose>

  <!-- Suppress repeated "name" entries -->
  <xsl:when test="not(preceding-sibling::supportEquipDescr/name = $current_name)">
     <supportEquipDescr>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="node()"/>
     </supportEquipDescr>
  </xsl:when>
  
  <!-- Change @internalRefId links throughout the document which point
       to entry being suppressed to instead point to first entry
       -->
  <xsl:otherwise>
   
   <!--
   <xsl:text>&#xA;</xsl:text>
   <xsl:comment> *** STABLE ID: <xsl:value-of select="$stable_id"/> *** </xsl:comment>
   <xsl:text>&#xA;</xsl:text>
   <xsl:comment> *** SUPPRESSED ID: <xsl:value-of select="$current_id"/> *** </xsl:comment>
   <xsl:text>&#xA;</xsl:text>
   -->
   
   <!-- NOTE: - must process the "@internalRefId" normally and look up for a match
              - can't use "apply-templates" or "call-template" from here
                -->
   <!-- CV - export these ids to a temp XML, then use a "-C" process to fix the known bad ids -->
   
   <!-- CV - create temp elements and use "-C" process to collect into single lookup file,
             and "-D" process to use lookup file and remove temp elements
             -->
   <TEMP_REPLACE suppressed-id="{$current_id}" stable-id="{$stable_id}"/>


  </xsl:otherwise>

  </xsl:choose>

</xsl:template>


<xsl:template match="supplyDescr">
  
  <xsl:variable name="current_name" select="name"/>
  
  <xsl:variable name="current_id" select="@id"/>
  
  <!-- Get the "id" of first item in list of repeated "name" entries -->
  <xsl:variable name="stable_id" select="parent::supplyDescrGroup/supplyDescr[name = $current_name][1]/@id"/>

  <xsl:choose>
  <xsl:when test="not(preceding-sibling::supplyDescr/name = $current_name)">

     <supplyDescr>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="node()"/>
     </supplyDescr>
   
  </xsl:when>
  
  <xsl:otherwise>
   <TEMP_REPLACE suppressed-id="{$current_id}" stable-id="{$stable_id}"/>
  </xsl:otherwise>
  
  </xsl:choose>

</xsl:template>


<xsl:template match="spareDescr">
  
  <xsl:variable name="current_name" select="name"/>
  
  <xsl:variable name="current_id" select="@id"/>
  
  <!-- Get the "id" of first item in list of repeated "name" entries -->
  <xsl:variable name="stable_id" select="parent::spareDescrGroup/spareDescr[name = $current_name][1]/@id"/>

  <xsl:choose>
  <xsl:when test="not(preceding-sibling::spareDescr/name = $current_name)">

     <spareDescr>
      <xsl:apply-templates select="@*"/>
      <xsl:copy-of select="node()"/>
     </spareDescr>
   
  </xsl:when>

  <xsl:otherwise>
   <TEMP_REPLACE suppressed-id="{$current_id}" stable-id="{$stable_id}"/>
  </xsl:otherwise>

  </xsl:choose>

</xsl:template>

<!-- ********************************************** -->

</xsl:stylesheet>
