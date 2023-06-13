<?xml version="1.0"  encoding="UTF-8" ?>

<!-- 
==============================================
Create collection file for use with
XQuery to find repository items amidst
all of the XML files in the S1000D zip
==============================================

S1000D-collect.xsl

Version: 0.1
Created: June 26, 2013
Last Modified: June 26, 2013

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
	- parse "S1000D-dir.xml" file and use generated "S1000D-collection.xml" as XQuery lookup file
	
                using contains($filename,"DMC-S1000DBIKE-AAA-A3-10-00-00AA-411A-A")
-->


<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink">


<xsl:output method="xml"
            media-type="text/xml"
            encoding="UTF-8"
            indent="yes"
            />

<xsl:template match="/">

 <!-- CV - if it's an XML file, add it to the collection -->
 <collection>
  
  <!-- 1. XML files in root directory of S1000D zip -->
  <xsl:for-each select="directory/file">
   
   <xsl:variable name="filename" select="normalize-space(@name)"/>
   
   <!-- (exclude our generated "S1000D-*.xml" files) -->
   <xsl:if test="not(starts-with($filename,'S1000D-'))">
  
    <xsl:if test="ends-with(translate($filename,'XML','xml'),'.xml')">
     <doc>
      <xsl:attribute name="href">
       <xsl:value-of select="$filename"/>
      </xsl:attribute>
     </doc>
    </xsl:if>
    
   </xsl:if>
  
  </xsl:for-each>
  

  <!-- (NOTE: currently expect all XML to be at root, but will
              also search to one-level of sub-directories, too) -->

  <!-- 2. XML files in sub-directory of S1000D zip -->
  <xsl:for-each select="directory/directory/file">
   
   <xsl:variable name="directoryname" select="normalize-space(parent::directory/@name)"/>
   <xsl:variable name="filename" select="normalize-space(@name)"/>
   
   <!-- (exclude our generated "S1000D-*.xml" files) -->
   <xsl:if test="not(starts-with($filename,'S1000D-'))">
  
    <xsl:if test="ends-with(translate($filename,'XML','xml'),'.xml')">
     <doc>
      <xsl:attribute name="href">
       <xsl:value-of select="$directoryname"/>
       <xsl:text>/</xsl:text>
       <xsl:value-of select="$filename"/>
      </xsl:attribute>
     </doc>
    </xsl:if>
    
   </xsl:if>
  
  </xsl:for-each>


 </collection>
</xsl:template>

</xsl:stylesheet>
