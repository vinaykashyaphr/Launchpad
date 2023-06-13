<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

<!-- This file not currently used for S1000D; keep for reference for now... -->

  <xsl:template name="do-acmm">
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="even">
      <xsl:attribute name="initial-page-number">
        <xsl:value-of select="$initialPageNumber"/>
      </xsl:attribute>
      <xsl:call-template name="init-static-content">
        <xsl:with-param name="page-prefix" select="''"/>
      </xsl:call-template>
      <fo:flow flow-name="xsl-region-body">
        <xsl:apply-templates select="PGBLK" mode="acmm"/>
        <xsl:apply-templates select="IPL" mode="acmm"/>
      </fo:flow>
    </fo:page-sequence>
    <xsl:apply-templates select="IPL/DPLIST"/>
  </xsl:template>

  <xsl:template match="IPL" mode="acmm">
    <xsl:message>
      <xsl:text>IN IPL #</xsl:text>
      <xsl:value-of select="position()"/>
    </xsl:message>
    <fo:block>
      <xsl:call-template name="save-revdate"/>
      <xsl:choose>
        <xsl:when test="EFFECT">
          <fo:block>
            <fo:marker marker-class-name="efftextValue">
              <xsl:value-of select="EFFECT"/>
            </fo:marker>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block>
            <fo:marker marker-class-name="efftextValue">
              <xsl:value-of select="'ALL'"/>
            </fo:marker>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
    <xsl:choose>
      <xsl:when test="ISEMPTY">
        <xsl:message>Suppress ISEMPTY IPL in ACMM</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <fo:block>
          <xsl:attribute name="id">
            <xsl:value-of select="@KEY"/>
          </xsl:attribute>
          <xsl:apply-templates select="IPLINTRO/TASK|EFFECT|CHGDESC|TITLE"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="IPLINTRO/VENDLIST" mode="acmm"/>
  </xsl:template>

  <xsl:template match="PGBLK" mode="acmm">
    <xsl:message>
      <xsl:text>IN PGBLK #</xsl:text>
      <xsl:value-of select="@PGBLKNBR"/>
    </xsl:message>
    <fo:block font-size="0.001pt" color="white">
      <xsl:text>pgblkst</xsl:text>
      <xsl:value-of select="PGBLK/@PGBLKNBR"/>
    </fo:block>
    <xsl:choose>
      <xsl:when test="EFFECT">
        <fo:block>
          <fo:marker marker-class-name="efftextValue">
            <xsl:value-of select="EFFECT"/>
          </fo:marker>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block>
          <fo:marker marker-class-name="efftextValue">
            <xsl:value-of select="'ALL'"/>
          </fo:marker>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
    <fo:block>
      <xsl:attribute name="id">
        <xsl:value-of select="@KEY"/>
      </xsl:attribute>
    <xsl:choose>
      <xsl:when test="ISEMPTY">
        <fo:block text-align="center" font-weight="bold" font-size="12pt" padding-after="6pt" keep-with-next.within-page="always">
          <xsl:call-template name="pgblk-title">
            <xsl:with-param name="pgblknbr" select="@PGBLKNBR"/>
          </xsl:call-template>
        </fo:block>
        <fo:list-block font-size="10pt" provisional-distance-between-starts="24pt" space-before=".1in" space-after=".1in" keep-with-next.within-page="always">
          <xsl:call-template name="save-revdate"/>
          <fo:list-item>
            <fo:list-item-label end-indent="label-end()">
              <fo:block>
                <xsl:number value="1" format="1."/>
              </fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <fo:block>
                <xsl:text>Not Applicable</xsl:text>
              </fo:block>
            </fo:list-item-body>
          </fo:list-item>
        </fo:list-block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block padding-after="12pt">
          <xsl:attribute name="id">
            <xsl:value-of select="@KEY"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
    </fo:block>
  </xsl:template>

  <xsl:template match="VENDLIST" mode="acmm">
    <fo:block>
      <xsl:call-template name="save-revdate"/>
      <xsl:call-template name="check-rev-start"/>
      <!--NUMBERED LIKE A TASK-->
      <fo:list-block font-size="10pt" provisional-distance-between-starts="24pt" space-before=".1in" space-after=".1in" keep-with-next.within-page="always">
        <xsl:attribute name="id">
          <xsl:value-of select="@KEY"/>
        </xsl:attribute>
        <xsl:call-template name="save-revdate"/>
        <fo:list-item>
          <fo:list-item-label end-indent="label-end()" font-size="12pt" font-weight="bold">
            <fo:block>
              <xsl:number value="1 + count(preceding-sibling::TASK)" format="1."/>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body start-indent="body-start()" font-size="12pt">
            <fo:block rx:key="{concat('task_',@KEY)}">
              <fo:inline text-decoration="underline" font-weight="bold">
                <xsl:apply-templates select="TITLE" mode="task-subtask-title"/>
              </fo:inline>
            </fo:block>
          </fo:list-item-body>
        </fo:list-item>
      </fo:list-block>
      <xsl:apply-templates/>
      <!-- RS: Removed from S1000D 
      <xsl:call-template name="vendlist-table"/> -->
      <xsl:call-template name="check-rev-end"/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
