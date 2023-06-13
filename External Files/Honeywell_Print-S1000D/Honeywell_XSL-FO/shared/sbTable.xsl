<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:attribute-set name="sblist.header.cell">
    <xsl:attribute name="padding-before">3pt</xsl:attribute>
    <xsl:attribute name="padding-after">3pt</xsl:attribute>
    <xsl:attribute name="padding-start">4pt</xsl:attribute>
    <xsl:attribute name="padding-end">4pt</xsl:attribute>
    <xsl:attribute name="border-before-style">solid</xsl:attribute>
    <xsl:attribute name="border-before-width">1pt</xsl:attribute>
    <xsl:attribute name="border-after-style">solid</xsl:attribute>
    <xsl:attribute name="border-after-width">1pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="sblist.table.cell">
    <xsl:attribute name="padding-before">3pt</xsl:attribute>
    <xsl:attribute name="padding-after">3pt</xsl:attribute>
    <xsl:attribute name="padding-start">4pt</xsl:attribute>
    <xsl:attribute name="padding-end">4pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="sblist.table.border-left">
    <xsl:attribute name="border-left-style">solid</xsl:attribute>
    <xsl:attribute name="border-left-width">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="sblist.table.border-right">
    <xsl:attribute name="border-right-style">solid</xsl:attribute>
    <xsl:attribute name="border-right-width">0pt</xsl:attribute>
  </xsl:attribute-set>

  <!--Added for CMM-->
<!--  <xsl:template match="SBLIST[ISEMPTY]">
    <xsl:message>Empty SBLIST. Skipping.</xsl:message>
  </xsl:template>
-->
  <!-- *** SBLIST Service Bulletin list *** -->
  <xsl:template match="SBLIST[not(child::TABLE)]">
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even" initial-page-number="1">
      <xsl:call-template name="init-static-content">
        <xsl:with-param name="page-prefix" select="'SBL-'"/>
        <xsl:with-param name="suppressAtacode" select="1"/>
        <!-- DJH TEST 20090831 -->
      </xsl:call-template>
      <fo:flow flow-name="xsl-region-body">
        <!-- Added default effectivity marker of 'All' for frontmatter. (Mantis #17829) -->
        <fo:block>
          <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
        </fo:block>
        <fo:block font-size="12pt" font-weight="bold" text-align="center" space-after="6pt" id="{@KEY}">
          <!--<xsl:attribute name="id">
            <xsl:value-of select="concat('sblist_',generate-id())"/>
          </xsl:attribute>-->
          <xsl:call-template name="save-revdate"/>
          <xsl:value-of select="./TITLE"/>
          <xsl:apply-templates select="CHGDESC"/>
        </fo:block>

        <xsl:apply-templates select="*[not(name() = 'SBDATA' or name() = 'TITLE') or name() = 'CHGDESC']"/>

        <fo:block>
          <fo:table rx:table-omit-initial-header="true" space-before=".08in">
            <fo:table-column column-width="100%"/>
            <fo:table-header>
              <fo:table-cell>
                <fo:block font-weight="bold" font-size="12pt" text-align="center" space-after="6pt">
                  <xsl:value-of select="concat(TITLE,' (Cont)')"/>
                </fo:block>
              </fo:table-cell>
            </fo:table-header>
            <fo:table-body>
              <fo:table-row>
                <fo:table-cell>
                  <fo:table border-bottom-style="solid" border-bottom-width="1pt" border-after-width.conditionality="retain">
                    <!-- DJH
                    <fo:table-column column-number="1" column-width="1.78in"/>
                    <fo:table-column column-number="2" column-width="4.0in"/>
                    <fo:table-column column-number="3" column-width="1.0in"/>
                    -->
                    <fo:table-column column-number="1" column-width="20%"/>
                    <fo:table-column column-number="2" column-width="55%"/>
                    <fo:table-column column-number="3" column-width="15%"/>
                    <fo:table-column column-number="4" column-width="10%"/>
                    <fo:table-header font-weight="bold" display-align="after">
                      <fo:table-cell xsl:use-attribute-sets="sblist.header.cell sblist.table.border-left" text-align="left">
                        <fo:block>Service Bulletin/</fo:block>
                        <fo:block>Revision Number</fo:block>
                      </fo:table-cell>
                      <fo:table-cell xsl:use-attribute-sets="sblist.header.cell">
                        <fo:block>
                          <fo:inline text-align="left">Title</fo:inline>
                        </fo:block>
                      </fo:table-cell>
                      <fo:table-cell text-align="left" xsl:use-attribute-sets="sblist.header.cell">
                        <fo:block>Date Put in</fo:block>
                        <fo:block>Manual</fo:block>
                      </fo:table-cell>
                      <fo:table-cell xsl:use-attribute-sets="sblist.header.cell sblist.table.border-right">
                        <fo:block>
                          <fo:inline text-align="left">Status</fo:inline>
                        </fo:block>
                      </fo:table-cell>
                    </fo:table-header>
                    <fo:table-body>
                      <xsl:choose>
                        <xsl:when test="ISEMPTY">
                          <fo:table-row>
                            <fo:table-cell/>
                            <fo:table-cell/>
                            <fo:table-cell/>
                            <fo:table-cell/>
                          </fo:table-row>
                        </xsl:when>
                        <!--Added for EIPC since isempty is not allowed.-->
                        <xsl:when test="not(SBDATA)">
                          <fo:table-row>
                            <fo:table-cell>
                              <fo:block>&#xA0;</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                              <fo:block>&#xA0;</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                              <fo:block>&#xA0;</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                              <fo:block>&#xA0;</fo:block>
                            </fo:table-cell>
                          </fo:table-row>                          
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:apply-templates select="SBDATA"/>
                        </xsl:otherwise>
                      </xsl:choose>                      
                    </fo:table-body>
                  </fo:table>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:block>
        <fo:block id="{concat('sb_',generate-id(),'_last')}"/>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>

  <!-- *** SBLIST Service Bulletin list (TABLE has been authored)  -->
  <xsl:template match="SBLIST[TABLE]">
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even" initial-page-number="1">
      <xsl:call-template name="init-static-content">
        <xsl:with-param name="page-prefix" select="'SBL-'"/>
        <xsl:with-param name="suppressAtacode" select="1"/>
        <!-- DJH TEST 20090831 -->
      </xsl:call-template>
      <fo:flow flow-name="xsl-region-body">
        <fo:block font-weight="bold" text-align="center" space-after="6pt" id="{@KEY}">
          <!--<xsl:attribute name="id">
            <xsl:value-of select="concat('sblist_',generate-id())"/>
          </xsl:attribute>-->
          <xsl:call-template name="save-revdate"/>
          <xsl:value-of select="./TITLE"/>
          <xsl:apply-templates select="CHGDESC"/>
        </fo:block>
        <xsl:apply-templates select="*[not(name()='CHGDESC')]"/>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>


  <xsl:template match="SBLIST/TITLE">
    <!-- Pulled from SBLIST template -->
  </xsl:template>

  <!--Added for CMM's-->
  <xsl:template match="SBLIST/ISEMPTY"/>

  <xsl:template match="SBDATA">
    <fo:table-row keep-together.within-page="always">
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="SBNBR">
    <fo:table-cell xsl:use-attribute-sets="sblist.table.cell sblist.table.border-left">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="SBTITLE|SBDESC">
    <fo:table-cell xsl:use-attribute-sets="sblist.table.cell">
      <fo:block>
        <!-- 
      <xsl:call-template name="check-rev-start"/>
			<xsl:apply-templates/>
			<xsl:call-template name="check-rev-end"/>
			-->
        <xsl:choose>
          <xsl:when test="./parent::SBDATA/preceding-sibling::processing-instruction()[1] = '_rev'">
            <xsl:call-template name="cbStart"/>
            <!--
          <xsl:message>SBDATA HAS _rev BEFORE IT.</xsl:message>
          -->
            <xsl:apply-templates/>
            <xsl:call-template name="cbEnd"/>
          </xsl:when>
          <xsl:when test="./parent::SBDATA/child::processing-instruction() = '_rev'">
            <xsl:call-template name="cbStart"/>
            <!--
          <xsl:message>SBDATA HAS _rev WITHIN IT.</xsl:message>
          -->
            <xsl:apply-templates/>
            <xsl:call-template name="cbEnd"/>
          </xsl:when>
          <xsl:otherwise>
            <!--
          <xsl:message>SBDATA DOES NOT HAVE _rev BEFORE OR WITHIN IT.</xsl:message>
          -->
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="ISSDATE">
    <fo:table-cell xsl:use-attribute-sets="sblist.table.cell">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
    <xsl:if test="count(following-sibling::ICS) = 0">
      <fo:table-cell xsl:use-attribute-sets="sblist.table.cell sblist.table.border-right">
        <fo:block>&#160;</fo:block>
      </fo:table-cell>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ICS">
    <!-- DJH
    <xsl:if test="count(preceding::ICS) = 0">
      <xsl:message>!!!  IGNORING ICS ELEMENTS IN SBDATA</xsl:message>
    </xsl:if>
    -->
    <fo:table-cell xsl:use-attribute-sets="sblist.table.cell sblist.table.border-right">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

</xsl:stylesheet>
