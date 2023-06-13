<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                                              xmlns:fo="http://www.w3.org/1999/XSL/Format" 
                                              xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:attribute-set name="tr.table.header.cell">
    <xsl:attribute name="text-align">center</xsl:attribute>
    <xsl:attribute name="padding">4pt</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
  </xsl:attribute-set>
  

  <xsl:template match="TRLIST[ISEMPTY]">
    <!-- Do nothing for now -->
    <xsl:message>TODO: Empty TRLIST</xsl:message>
  </xsl:template>
  
  <xsl:template match="TRLIST/TITLE">
    <!-- Suppressed. Uses text from style sheet -->
  </xsl:template>
  
  <!-- *** TRLIST *** -->
<xsl:template match="TRLIST">
  <xsl:variable name="page-prefix" select="'RTR-'"/>
  <xsl:variable name="trTitle">RECORD OF TEMPORARY REVISIONS</xsl:variable>
    
  <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even" initial-page-number="1">
    <xsl:call-template name="init-static-content">
      <xsl:with-param name="page-prefix" select="$page-prefix"/>
      <xsl:with-param name="suppressAtacode" select="1"/><!-- DJH TEST 20090831 -->
    </xsl:call-template>
    <fo:flow flow-name="xsl-region-body">
      <xsl:call-template name="save-revdate" />
      <fo:block>
        <xsl:attribute name="id">
          <xsl:value-of select="@KEY"/>
        </xsl:attribute>
        <!-- Added default effectivity marker of 'All' for frontmatter. (Mantis #17829) -->
        <fo:block>
          <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
        </fo:block>        
        <fo:block text-align="center" font-size="12pt" font-weight="bold" space-after="12pt">
           <xsl:value-of select="$trTitle" />
        </fo:block>
        <fo:block text-align="left" space-after="12pt">
          <xsl:text>Instructions on each page of a temporary revision tell you where to put the pages in your manual. Remove the temporary revision pages only when discard instructions are given. For
            each temporary revision, put the applicable data in the record columns on this page.</xsl:text>
        </fo:block>
        <fo:block text-align="left" space-after="12pt">
          <xsl:text>Definition of Status column: A TR may be active, incorporated, or deleted. “Active” is entered by the holder of the manual. “Incorporated” means a TR has been incorporated into
            the manual and includes the revision number of the manual when the TR was incorporated. “Deleted” means a TR has been replaced by another TR, a TR number will not be issued, or a TR has
            been deleted.</xsl:text>
        </fo:block>
        <fo:table rx:table-omit-initial-header="true">
        <fo:table-column column-width="100%"/>
        <fo:table-header>
            <fo:table-cell>
              <fo:block font-size="12pt" font-weight="bold" text-align="center"  space-after="6pt">
                <xsl:value-of select="concat($trTitle,' (Cont)')" />
              </fo:block>
            </fo:table-cell>
        </fo:table-header>
        <fo:table-body>
            <fo:table-row>
                <fo:table-cell>
                    <fo:table>
                        <fo:table-column column-number="1" column-width=".9in"/>
                        <fo:table-column column-number="2" column-width=".9in"/>
                        <fo:table-column column-number="3" column-width="1.59in"/>
                        <fo:table-column column-number="4" column-width=".95in"/>
                        <fo:table-column column-number="5" column-width=".95in"/>
                        <fo:table-column column-number="6" column-width=".4in"/>
                        <fo:table-column column-number="7" column-width=".8in"/>
                        <fo:table-column column-number="8" column-width=".4in"/>
                       
                        <fo:table-header border-after-style="solid" border-after-width="1pt"  
                          border-before-style="solid" border-before-width="1pt" display-align="after"
                          font-weight="bold" padding="3pt">
                            
                          <fo:table-cell xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Temporary Revision Number</fo:inline>
                                    </fo:block>
                             </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Status</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Page Number</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Issue Date</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Date Put In Manual</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">By</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">Date Removed From Manual</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                          <fo:table-cell  xsl:use-attribute-sets="tr.table.header.cell">
                                    <fo:block>
                                        <fo:inline text-align="center">By</fo:inline>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-header>
                        
                        <fo:table-body border-style="solid" border-width="1pt">
                       <xsl:apply-templates/>
                        </fo:table-body>       
                    </fo:table>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-body>
    </fo:table>
      </fo:block>
      <fo:block id="rtr_last" />
    </fo:flow>
  </fo:page-sequence>
</xsl:template>
  
<xsl:template match="TLIST/TITLE">
  <!-- Ignored -->
</xsl:template>
  
  <xsl:template match="TRDATA">
    <fo:table-row>
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <xsl:call-template name="check-rev-start"/>
        <fo:block>
          <fo:inline><xsl:value-of select="./TRNBR"/></fo:inline>
        </fo:block>
      </fo:table-cell>
      
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <fo:inline><xsl:value-of select="./TRSTATUS"/></fo:inline>
        </fo:block>
      </fo:table-cell>
      
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <fo:inline><xsl:value-of select="./TRLOC"/></fo:inline><!-- DJH <fo:inline>&#160;</fo:inline> -->
        </fo:block>
      </fo:table-cell>  
    
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <xsl:choose>
            <xsl:when test="count(TRLOC) &gt; 1">
              <fo:inline><xsl:value-of select="./TRLOC[2]"/></fo:inline>
            </xsl:when>
            <xsl:otherwise>
              <fo:inline>&#160;</fo:inline>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:table-cell>  
      
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <fo:inline>&#160;</fo:inline><!-- DJH <fo:inline><xsl:value-of select="./TRLOC"/></fo:inline>-->
        </fo:block>
      </fo:table-cell>  
      
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <fo:inline>&#160;</fo:inline>
        </fo:block>
      </fo:table-cell>  
      
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <fo:inline>&#160;</fo:inline>
        </fo:block>
      </fo:table-cell>  
      
      <fo:table-cell  xsl:use-attribute-sets="default.table.cell">
        <fo:block>
          <fo:inline>&#160;</fo:inline>
        </fo:block>
        <xsl:call-template name="check-rev-end"/>
     </fo:table-cell>
    </fo:table-row>
    
  </xsl:template>
</xsl:stylesheet>