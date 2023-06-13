<?xml version="1.0"  encoding="UTF-8" ?>

<!-- 
==============================================
Collect all "DMC" fragment files referenced
by S1000D "PMC" main file into single
consolidated document
==============================================

S1000D-consolidate.xsl

Version: 0.3
Created: October 17, 2018

Version: 0.2
Created: April 12, 2018
Last Modified: June 19, 2018

Chris van Mels
Richard Steadman
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

v.0.3:
=====

	- Add the print variant passed as a parameter from the command line

v.0.2:
=====

	- Add the document type passed as a parameter from the command line

v.0.1:
=====
	- parse "PMC" file and use generated "S1000D-dir.xml" as lookup file
	
	- must collect "pmEntry/dmRef/dmCode" attributes to assemble expected filename
          and find match in "S1000D-dir.xml" file

        - filenames in S1000D zip also include version info which isn't include in the attributes,
          so find closest match instead
          e.g. "DMC-S1000DBIKE-AAA-A3-10-00-00AA-411A-A_000-10_sx-US.xml" would be found
                using contains($filename,"DMC-S1000DBIKE-AAA-A3-10-00-00AA-411A-A")

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

<!-- RS - paramater passed from command line for the document type, like "cmm" or "ohm" -->
<xsl:param name="type">
 <xsl:text>mm</xsl:text>
</xsl:param>

<!-- RS - paramater passed from command line for the print variant, like "std" or "dmc" -->
<xsl:param name="variant">
 <xsl:text>std</xsl:text>
</xsl:param>


<!-- CV - XML lookup file with directory listing information of the S1000D zip
          (generated file)
          -->
<xsl:variable name="S1000D-dir" select="document('S1000D-dir.xml')"/>


<!-- CV - almost everything should just flow through -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- RS: Add the doctype attribute -->
<xsl:template match="pm">
  <xsl:copy>
	<xsl:attribute name="type">
		<xsl:value-of select="$type"/>
	</xsl:attribute>
 	<xsl:attribute name="print-variant">
		<xsl:value-of select="$variant"/>
	</xsl:attribute>
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

<!-- ******************************************************************************* -->
<!-- CV - call in "dmRef" file fragment place inside custom element "dmContent" -->

<xsl:template match="pmEntry/dmRef">

  <!-- Construct root of expected filename -->
  <xsl:variable name="dmRef-filename-root">

    <!-- **************************
         e.g.
         DMC-S1000DBIKE-AAA-A3-10-00-00AA-411A-A_000-10_sx-US.xml

         <dmRef>
          <dmRefIdent>
          <dmCode [6]  assyCode="00" 
                  [7]  disassyCode="00"
                  [8]  disassyCodeVariant="AA" 
                  [9]  infoCode="411" 
                  [10] infoCodeVariant="A"
                  [11] itemLocationCode="A" 
                  [1]  modelIdentCode="S1000DBIKE"
                  [5]  subSubSystemCode="0"
                  [4]  subSystemCode="1" 
                  [3]  systemCode="A3" 
                  [2]  systemDiffCode="AAA"/>
          </dmRefIdent>
          </dmRef>
          ************************** -->


    <!-- Is "DMC" always first part of string (not a variable) -->
    <!-- (not really necessary, as we're using a contains() argument to 
          find the real filename match)
          -->
    <!--
    <xsl:text>DMC</xsl:text> 
    <xsl:text>-</xsl:text>
    -->
    
    <xsl:value-of select="dmRefIdent/dmCode/@modelIdentCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@systemDiffCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@systemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@subSystemCode"/>
    <xsl:value-of select="dmRefIdent/dmCode/@subSubSystemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@assyCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@disassyCode"/>
    <xsl:value-of select="dmRefIdent/dmCode/@disassyCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@infoCode"/>
    <xsl:value-of select="dmRefIdent/dmCode/@infoCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="dmRefIdent/dmCode/@itemLocationCode"/>
      
  </xsl:variable>
  
  <!-- Try to find corresponding filename in the "S1000D-dir.xml" lookup file -->
  <xsl:variable name="dmRef-filename">
  
    <!-- **************************
         e.g.
         S1000D-dir.xml (lookup file):
         
         <directory>
          ...
          <file name="DMC-S1000DBIKE-AAA-A3-10-00-00AA-411A-A_000-10_sx-US.xml" size="6576" lastModified="1365691698000" date="20130411T104818" absolutePath="C:\data\newbook\Sonovision\2013-S1000D\source\20130411\.\DMC-S1000DBIKE-AAA-A3-10-00-00AA-411A-A_000-10_sx-US.xml"/>
          ...
         </directory>
         ************************** -->

    <!-- CV - pulling in content from external file needs to use relative path -->
    <!-- @name (relative path) -->
    <xsl:value-of select="$S1000D-dir/directory/file[contains(@name,$dmRef-filename-root)]/@name"/>

    <!-- @absolutePath (full path) -->
    <!-- <xsl:value-of select="$S1000D-dir/directory/file[contains(@name,$dmRef-filename-root)]/@absolutePath"/> -->
  
  </xsl:variable>

  <xsl:text>&#xA;</xsl:text>
  <dmRef>
   <xsl:attribute name="xlink:href">
    <xsl:text>URN:S1000D:</xsl:text>
    <xsl:value-of select="$dmRef-filename-root"/>
   </xsl:attribute>
   <xsl:if test="@authorityDocument">
	   <xsl:attribute name="authorityDocument">
		<xsl:value-of select="@authorityDocument"/>
	   </xsl:attribute>
   </xsl:if>
   <xsl:apply-templates/>
  </dmRef>
  <xsl:text>&#xA;</xsl:text>

  <xsl:text>&#xA;</xsl:text>
  <dmContent>

   <!-- CV - for use with "dmRef" links in final XML, put "@id" on "dmContent" 
             and then move to "child::dmodule" in next phase of processing
             -->
   <xsl:attribute name="id" select="$dmRef-filename-root"/>

   <xsl:attribute name="xlink:href">
    <xsl:choose>
     <xsl:when test="not($dmRef-filename='')">
      <xsl:text>URN:S1000D:</xsl:text>
      <xsl:value-of select="$dmRef-filename"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>FILE-NOT-FOUND:</xsl:text>
      <xsl:value-of select="$dmRef-filename-root"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>


   <!-- Copy in the contents of "$dmRef-filename" -->
   <xsl:if test="not($dmRef-filename='')">
    <xsl:text>&#xA;</xsl:text>
    <xsl:copy-of select="document($dmRef-filename)"/>
   </xsl:if>

  </dmContent>
  <xsl:text>&#xA;</xsl:text>

</xsl:template>
<!-- ******************************************************************************* -->


</xsl:stylesheet>
