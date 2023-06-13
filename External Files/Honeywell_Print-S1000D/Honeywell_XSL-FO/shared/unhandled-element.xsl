<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">
   <xsl:template match="*">
      <xsl:message>[error] !!! Unhandled element [<xsl:value-of select="name(.)"/>] Context is: <xsl:call-template name="get-context"/></xsl:message>
   </xsl:template>

   <xsl:template name="get-context">
      <xsl:param name="currentPath" select="''"/>
      <xsl:variable name="thisNode">
         <xsl:choose>
            <xsl:when test="$currentPath = ''">
               <xsl:variable name="thisName" select="name()"/>
               <xsl:value-of select="concat(name(),'[',1 + count(preceding-sibling::*[name() = $thisName]),']')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$currentPath"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="parentName" select="../name()"/>
      <xsl:choose>
         <xsl:when test="parent::*">
            <xsl:for-each select="parent::*">
               <xsl:call-template name="get-context">
                  <xsl:with-param name="currentPath">
                     <xsl:value-of select="concat(name(),'[',1 + count(preceding-sibling::*[name() = $parentName]),']','/',$thisNode)"/>
                  </xsl:with-param>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$currentPath"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>



<!-- ********************************************************************* -->
<!-- CV - extended PI support -->

<!-- Currently using OmniMark process to transform Arbortext PIs to generic "pagebreak":

     <?Pub _newpage?>
     <?PubTbl row breakpenalty="-10000"?>
     
     to 
     
     <?pagebreak?>
-->

<xsl:template match="processing-instruction('pagebreak')">
  <fo:block break-after="page"/>
</xsl:template>

<!-- RS: The break before row is now handled in the table module (tbl-caps.xsl).
<xsl:template match="ROW[descendant::processing-instruction('pagebreak')]" priority="1">
  <fo:table-row>
   <xsl:attribute name="page-break-before">always</xsl:attribute>
  </fo:table-row>
</xsl:template>-->


<!-- Sonovision update (2019.01.21) - newline support
     - can't be empty, so just leave a white dot to force the new line break effect
       -->
<xsl:template match="processing-instruction('newline')" priority="1">
 <fo:block color="#FFFFFF">
  <!-- <xsl:text>NEWLINE</xsl:text> -->
  <xsl:text>.</xsl:text>
 </fo:block>
</xsl:template>



<!-- Sonovision update (2019.01.15) 
     - adding cell shading support (initially by SB only)
     - "fix_pi.xom" changes PI to element
       (e.g. <?Pub _cellfont Shading="gray3"?> to <cellfont Shading="gray3"/>)
     - "upperCase.xsl" collects as ENTRY/@SHADING attribute and then strips the "cellfont" element
     - call this named template "ENTRY_SHADING" to apply attribute @background-color to "fo:table-cell"
     
     RGB color codes from Sonovision:
     
     Orange: R255 G192 B151
     Yellow: R255 G255 B192
     Green:  R192 G255 B192
     Grey:   R208 G208 B208
     
     converted to HEX:
     
     Orange: #FFC097
     Yellow: #FFFFC0
     Green:  #C0FFC0
     Grey:   #D0D0D0


     
     
     
     -->
    <xsl:template name="ENTRY_SHADING">

        <xsl:if test="@SHADING">
         <xsl:attribute name="background-color">
          <xsl:choose>

           <!-- If already a HEX code, then use it -->
           <xsl:when test="starts-with(@SHADING,'#')">
            <xsl:value-of select="@SHADING"/>
           </xsl:when>
           
           <!-- If a named color, then try to find a basic match -->
           <xsl:when test="contains(@SHADING,'gray')">
            <!-- <xsl:text>#808080</xsl:text> -->
            <!-- Use "lightgray" instead -->
            <!-- <xsl:text>#D3D3D3</xsl:text> -->
            <xsl:text>#D0D0D0</xsl:text>
           </xsl:when>

           <xsl:when test="contains(@SHADING,'orange')">
            <!-- <xsl:text>#FFA500</xsl:text> -->
            <xsl:text>#FFC097</xsl:text>
           </xsl:when>

           <xsl:when test="contains(@SHADING,'yellow')">
            <!-- <xsl:text>#FFFF00</xsl:text> -->
            <xsl:text>#FFFFC0</xsl:text>
           </xsl:when>

           <xsl:when test="contains(@SHADING,'blue')">
            <xsl:text>#0000FF</xsl:text>
           </xsl:when>

           <xsl:when test="contains(@SHADING,'red')">
            <xsl:text>#FF0000</xsl:text>
           </xsl:when>

           <xsl:when test="contains(@SHADING,'green')">
            <!-- <xsl:text>#008000</xsl:text> -->
            <xsl:text>#C0FFC0</xsl:text>
           </xsl:when>
           
           <!-- CV - default to regular (dark) gray if no other match -->
           <xsl:otherwise>
            <xsl:text>#808080</xsl:text>
           </xsl:otherwise>

          </xsl:choose>
          
         </xsl:attribute>
        </xsl:if>

    </xsl:template>


<!-- ********************************************************************* -->


</xsl:stylesheet>
