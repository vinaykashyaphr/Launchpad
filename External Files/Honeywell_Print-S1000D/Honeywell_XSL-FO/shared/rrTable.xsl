<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                                              xmlns:fo="http://www.w3.org/1999/XSL/Format" 
                                              xmlns:rx="http://www.renderx.com/XSL/Extensions">
  
  <xsl:attribute-set name="rr.table.cell">
    
    <xsl:attribute name="padding-before">1pt</xsl:attribute>
    <xsl:attribute name="padding-after">1pt</xsl:attribute>
    <xsl:attribute name="padding-start">4pt</xsl:attribute>
    <xsl:attribute name="padding-end">4pt</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
  </xsl:attribute-set>
 
 <xsl:attribute-set name="rr.table.header.cell">
   <xsl:attribute name="text-align">center</xsl:attribute>
   <xsl:attribute name="padding">4pt</xsl:attribute>
   <xsl:attribute name="border-style">solid</xsl:attribute>
   <xsl:attribute name="border-width">1pt</xsl:attribute>
 </xsl:attribute-set>
 
  <!-- Note: There is a graphic file availble to use for this if needed -->
   <!--Record of Revisions (this is an empty table)                          -->
<xsl:template name="rrTable">   
  
  <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even" initial-page-number="1">
    <xsl:variable name="suppressAtacode">
      <xsl:choose>
        <xsl:when test="/CMM">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="init-static-content">
      <xsl:with-param name="page-prefix" select="'RR-'"/>
      <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/><!-- DJH TEST 20090831 -->
    </xsl:call-template>
    <fo:flow flow-name="xsl-region-body">
      <!-- Added default effectivity marker of 'All' for frontmatter. (Mantis #17829) -->
      <fo:block>
        <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
      </fo:block>
      <fo:block><xsl:call-template name="save-revdate"/>
        
        <fo:block id="rr_table" text-align="center" font-weight="bold" font-size="12pt" space-after="12pt">RECORD OF REVISIONS</fo:block>
        <fo:block space-after="12pt">For each revision, write the revision number, revision date, date put in the manual, and your initials in the applicable column.</fo:block>
        <fo:block space-after="12pt"><fo:inline text-decoration="underline">NOTE:</fo:inline>&#160;&#160;&#160;Refer to the Revision History in the TRANSMITTAL INFORMATION section for revision data.</fo:block>
      
                    <fo:table border-collapse="collapse">
                      <fo:table-column column-number="1" column-width=".9in"/>
                      <fo:table-column column-number="2" column-width=".9in"/>
                      <fo:table-column column-number="3" column-width=".9in"/>
                      <fo:table-column column-number="4" column-width=".6in"/>
                      <fo:table-column column-number="5" column-width=".185in"/>  
                      <fo:table-column column-number="6" column-width=".9in"/>
                      <fo:table-column column-number="7" column-width=".9in"/>
                      <fo:table-column column-number="8" column-width=".9in"/>
                      <fo:table-column column-number="9" column-width=".6in"/>
                      
                       
                        <fo:table-header border-after-style="solid" border-after-width="1pt"  
                          border-before-style="solid" border-before-width="1pt" display-align="after"
                          font-weight="bold" padding="3pt">
                            
                             <fo:table-cell xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Revision Number</fo:inline>
                                    </fo:block>
                             </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Revision Date</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Date Put In Manual</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">By</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">&#160;</fo:inline>
                                    </fo:block>
                          </fo:table-cell>
                          <fo:table-cell xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Revision Number</fo:inline>
                                    </fo:block>
                             </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Revision Date</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Date Put In Manual</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="rr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">By</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          
                        </fo:table-header>
                        
                      <fo:table-body border-style="solid" border-width="1pt">
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                        <xsl:call-template name="rrNewRow"/>
                      </fo:table-body>       
                    </fo:table>
              
      </fo:block>
      <fo:block id="rr_last" />
    </fo:flow>
  </fo:page-sequence>
</xsl:template>
  
  <xsl:template name="rrNewRow">
    <fo:table-row> 
     <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
        <xsl:call-template name="rrNewCell"/>
    </fo:table-row>
  </xsl:template>
  
  <xsl:template name="rrNewCell">
     <fo:table-cell  xsl:use-attribute-sets="rr.table.cell">
        <fo:block>
          <fo:inline>&#160;</fo:inline>
        </fo:block>
     </fo:table-cell>  
  </xsl:template>
  
</xsl:stylesheet>