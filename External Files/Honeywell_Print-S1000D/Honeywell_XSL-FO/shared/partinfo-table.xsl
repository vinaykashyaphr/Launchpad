<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">



   <!-- *** This template creates the partinfo table for the title page and beyond. called from the 
               top level of the Manual
  -->
   <xsl:template name="part-info-table">

    <!-- CV - don't use @text-transform="capitalize" to create camel-case title (leave as is in original file)
              e.g. "LHT PROPRIETARY REPAIR MANUAL"
                   shouldn't become
                   "Lht Proprietary Repair Manual"
              -->

      <fo:block margin-left="1in" margin-right="1in" margin-top="0.725in" space-after.optimum=".15in" font-family="Arial" font-size="20pt" font-weight="bold" text-align="center"><!-- text-transform="capitalize" -->
         <xsl:value-of select="$g-doc-full-name"/>
         <fo:block space-before="1in">
            <xsl:apply-templates select="CMPNOM"/>
         </fo:block>
        <fo:block margin-top="0in" text-align="center" text-transform="none">
            <xsl:apply-templates select="/*/PARTINFO[1]/TITLE"/>
         </fo:block>
      </fo:block>
      <fo:block font-size="18pt">
         <fo:table rx:table-omit-initial-header="true">
            <fo:table-column column-width="2.25in"/>
            <fo:table-column column-width="3in"/>
            <fo:table-column column-width="1in"/>
            <fo:table-header border-bottom="black solid 1pt">
               <fo:table-cell>
                  <fo:block>Part Number</fo:block>
               </fo:table-cell>
               <fo:table-cell>
                  <fo:block>Model</fo:block>
               </fo:table-cell>
               <fo:table-cell>
                  <fo:block>CAGE</fo:block>
               </fo:table-cell>
            </fo:table-header>
            <fo:table-body>
               <fo:table-row border-bottom="black solid 1pt">
                  <fo:table-cell>
                     <fo:block>Part Number</fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <fo:block>Model</fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <fo:block>CAGE</fo:block>
                  </fo:table-cell>
               </fo:table-row>
               <xsl:for-each select="PARTINFO">
                  <xsl:apply-templates select="MFRPNR"/>
               </xsl:for-each>
            </fo:table-body>
         </fo:table>
      </fo:block>
   </xsl:template>


   <xsl:template match="PARTINFO">
      <!-- Don't do anything. Handled by the foreach -->
   </xsl:template>


   <xsl:template match="PARTINFO/MFRPNR">
      <fo:table-row>
         <xsl:apply-templates/>
      </fo:table-row>
   </xsl:template>

   <xsl:template match="PARTINFO/MFRPNR/PNR">
      <fo:table-cell padding-top="6pt" padding-right="10pt">
         <fo:block>
            <xsl:value-of select="."/>
         </fo:block>
      </fo:table-cell>
      <!-- The center column is the MODEL attribute on the PARTINFO element -->
      <fo:table-cell padding-top="6pt" padding-right="10pt">
         <fo:block>
            <xsl:value-of select="../../@MODEL"/>
         </fo:block>
      </fo:table-cell>
   </xsl:template>
   <xsl:template match="PARTINFO/MFRPNR/MFR">
      <fo:table-cell padding-top="6pt" padding-right="10pt">
         <fo:block>
            <xsl:value-of select="."/>
         </fo:block>
      </fo:table-cell>
   </xsl:template>

   <!-- *** EXPRCTL *** -->
   <xsl:template match="EXPRTCL">
      <!-- suppress. called explicitly from partinfo table -->
   </xsl:template>

   <!-- *** EXPRCTL/PARA *** -->
   <xsl:template match="EXPRTCL/PARA">
      <fo:block>
         <xsl:if test="0 = count(preceding-sibling::PARA)">
            <xsl:attribute name="id">
               <xsl:value-of select="concat('exprtcl_',generate-id())"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:apply-templates/>
      </fo:block>
   </xsl:template>

   <xsl:template name="OLD-do-export-control">
      <xsl:param name="columns-spanned" select="3"/>
      <xsl:param name="break-row" select="'always'"/>
      <xsl:message>do-export-control called with break-row="<xsl:value-of select="$break-row"/>" and count(//PARTINFO) = <xsl:value-of select="count(//PARTINFO)"/></xsl:message>
      <fo:table-row>
         <fo:table-cell number-columns-spanned="3">
            <fo:block>&#160;</fo:block>
         </fo:table-cell>
      </fo:table-row>
      <fo:table-row page-break-after="{$break-row}">
         <fo:table-cell number-columns-spanned="{$columns-spanned}">
            <fo:block space-before="2pt" padding="3pt" padding-left="5pt" padding-right="5pt" border="solid black 1pt" font-size="9pt" text-align="center" keep-together.within-page="always">
               <xsl:apply-templates select="//EXPRTCL/PARA"/>
            </fo:block>
         </fo:table-cell>
      </fo:table-row>
   </xsl:template>

  <xsl:template name="do-export-control">
      <xsl:param name="columns-spanned" select="3"/>
      <xsl:param name="break-row" select="'always'"/>
    <fo:block-container border="solid black 1pt" margin-top=".25in" margin-bottom=".85in" padding="3pt" padding-left="5pt" padding-right="5pt" font-size="9pt" text-align="center" keep-together.within-page="always">
      <fo:block>
        <xsl:apply-templates select="//EXPRTCL/PARA"/>
      </fo:block>
    </fo:block-container>
   </xsl:template>
</xsl:stylesheet>
