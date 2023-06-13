<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xtbl="com.nwalsh.xalan.Table"
  xmlns:stbl="coms.nwalsh.xalan.Table" xmlns:lxslt="coml.nwalsh.xalan.Table"
  xmlns:rx="http://www.renderx.com/XSL/Extensions" exclude-result-prefixes="stbl xtbl lxslt"
  version="1.0">

  <!-- **********************************************************
    tbl.xsl - transforms CALS tables into FOs
    ********************************************************** -->

  <xsl:param name="default.table.width" select="''"/>

  <xsl:param name="table.border.color" select="'black'"/>

  <xsl:param name="table.border.style" select="'solid'"/>

  <xsl:param name="table.border.thickness" select="'1.0pt'"/>



  <!--<xsl:import href="tbl-params.xsl"/>-->


  <xsl:attribute-set name="table.cell.padding">
    <xsl:attribute name="margin-left">2pt</xsl:attribute>
    <xsl:attribute name="margin-right">2pt</xsl:attribute>
    <xsl:attribute name="padding-right">2pt</xsl:attribute>
    <xsl:attribute name="padding-top">.048in</xsl:attribute>
    <xsl:attribute name="padding-bottom">.023in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="default.table.cell">

    <xsl:attribute name="padding-before">4pt</xsl:attribute>
    <xsl:attribute name="padding-after">4pt</xsl:attribute>
    <xsl:attribute name="padding-start">4pt</xsl:attribute>
    <xsl:attribute name="padding-end">4pt</xsl:attribute>
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">1pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:param name="tablecolumns.extension" select="'1'"/>

  <xsl:param name="use.extensions" select="'0'"/>


  <xsl:template name="copy-string">
    <!-- returns 'count' copies of 'string' -->
    <xsl:param name="string"/>
    <xsl:param name="count" select="0"/>
    <xsl:param name="result"/>

    <xsl:choose>
      <xsl:when test="$count&gt;0">
        <xsl:call-template name="copy-string">
          <xsl:with-param name="string" select="$string"/>
          <xsl:with-param name="count" select="$count - 1"/>
          <xsl:with-param name="result">
            <xsl:value-of select="$result"/>
            <xsl:value-of select="$string"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="blank.spans">
    <xsl:param name="COLS" select="1"/>
    <xsl:if test="$COLS &gt; 0">
      <xsl:text>0:</xsl:text>
      <xsl:call-template name="blank.spans">
        <xsl:with-param name="COLS" select="$COLS - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="calculate.following.spans">
    <xsl:param name="COLSPAN" select="1"/>
    <xsl:param name="spans" select="''"/>

    <xsl:choose>
      <xsl:when test="$COLSPAN &gt; 0">
        <xsl:call-template name="calculate.following.spans">
          <xsl:with-param name="COLSPAN" select="$COLSPAN - 1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$spans"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="finaltd">
    <xsl:param name="spans"/>
    <xsl:param name="col" select="0"/>

    <xsl:if test="$spans != ''">
      <xsl:choose>
        <xsl:when test="starts-with($spans,'0:')">
          <xsl:call-template name="empty.table.cell">
            <xsl:with-param name="COLNUM" select="$col"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>

      <xsl:call-template name="finaltd">
        <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        <xsl:with-param name="col" select="$col+1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="sfinaltd">
    <xsl:param name="spans"/>

    <xsl:if test="$spans != ''">
      <xsl:choose>
        <xsl:when test="starts-with($spans,'0:')">0:</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before($spans,':')-1"/>
          <xsl:text>:</xsl:text>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="sfinaltd">
        <xsl:with-param name="spans" select="substring-after($spans,':')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="ENTRY.COLNUM">
    <xsl:param name="ENTRY" select="."/>

    <xsl:choose>
      <xsl:when test="$ENTRY/@SPANNAME">
        <xsl:variable name="SPANNAME" select="$ENTRY/@SPANNAME"/>
        <xsl:variable name="SPANSPEC" select="$ENTRY/ancestor::SPANSPEC[@SPANNAME=$SPANNAME]"/>
        <xsl:variable name="COLSPEC"
          select="$ENTRY/ancestor::TGROUP/COLSPEC[@COLNAME=$SPANSPEC/@NAMEST]"/>
        <xsl:call-template name="COLSPEC.COLNUM">
          <xsl:with-param name="COLSPEC" select="$COLSPEC"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$ENTRY/@COLNAME">
        <xsl:variable name="COLNAME" select="$ENTRY/@COLNAME"/>
        <xsl:variable name="COLSPEC" select="$ENTRY/ancestor::TGROUP/COLSPEC[@COLNAME=$COLNAME]"/>
        <xsl:call-template name="COLSPEC.COLNUM">
          <xsl:with-param name="COLSPEC" select="$COLSPEC"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$ENTRY/@NAMEST">
        <xsl:variable name="NAMEST" select="$ENTRY/@NAMEST"/>
        <xsl:variable name="COLSPEC" select="$ENTRY/ancestor::TGROUP/COLSPEC[@COLNAME=$NAMEST]"/>
        <xsl:call-template name="COLSPEC.COLNUM">
          <xsl:with-param name="COLSPEC" select="$COLSPEC"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no idea, return 0 -->
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="COLSPEC.COLNUM">
    <xsl:param name="COLSPEC" select="."/>
    <xsl:choose>
      <xsl:when test="$COLSPEC/@COLNUM">
        <xsl:value-of select="$COLSPEC/@COLNUM"/>
      </xsl:when>
      <xsl:when test="$COLSPEC/preceding-sibling::COLSPEC">
        <xsl:variable name="prec.COLSPEC.COLNUM">
          <xsl:call-template name="COLSPEC.COLNUM">
            <xsl:with-param name="COLSPEC" select="$COLSPEC/preceding-sibling::COLSPEC[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$prec.COLSPEC.COLNUM + 1"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calculate.COLSPAN">
    <xsl:param name="ENTRY" select="."/>
    <xsl:variable name="SPANNAME" select="$ENTRY/@SPANNAME"/>
    <xsl:variable name="SPANSPEC" select="$ENTRY/ancestor::TGROUP/SPANSPEC[@SPANNAME=$SPANNAME]"/>

    <xsl:variable name="NAMEST">
      <xsl:choose>
        <xsl:when test="@SPANNAME">
          <xsl:value-of select="$SPANSPEC/@NAMEST"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ENTRY/@NAMEST"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="NAMEEND">
      <xsl:choose>
        <xsl:when test="@SPANNAME">
          <xsl:value-of select="$SPANSPEC/@NAMEEND"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ENTRY/@NAMEEND"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="scol">
      <xsl:call-template name="COLSPEC.COLNUM">
        <xsl:with-param name="COLSPEC" select="$ENTRY/ancestor::TGROUP/COLSPEC[@COLNAME=$NAMEST]"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="ecol">
      <xsl:call-template name="COLSPEC.COLNUM">
        <xsl:with-param name="COLSPEC" select="$ENTRY/ancestor::TGROUP/COLSPEC[@COLNAME=$NAMEEND]"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$NAMEST != '' and $NAMEEND != ''">
        <xsl:choose>
          <xsl:when test="$ecol &gt;= $scol">
            <xsl:value-of select="$ecol - $scol + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$scol - $ecol + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calculate.ROWSEP">
    <xsl:param name="ENTRY" select="."/>
    <xsl:param name="COLNUM" select="0"/>

    <xsl:call-template name="inherited.table.attribute">
      <xsl:with-param name="ENTRY" select="$ENTRY"/>
      <xsl:with-param name="COLNUM" select="$COLNUM"/>
      <xsl:with-param name="attribute" select="'ROWSEP'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="calculate.COLSEP">
    <xsl:param name="ENTRY" select="."/>
    <xsl:param name="COLNUM" select="0"/>

    <xsl:call-template name="inherited.table.attribute">
      <xsl:with-param name="ENTRY" select="$ENTRY"/>
      <xsl:with-param name="COLNUM" select="$COLNUM"/>
      <xsl:with-param name="attribute" select="'COLSEP'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="inherited.table.attribute">
    <xsl:param name="ENTRY" select="."/>
    <xsl:param name="ROW" select="$ENTRY/ancestor-or-self::ROW[1]"/>
    <xsl:param name="COLNUM" select="0"/>
    <xsl:param name="attribute" select="'COLSEP'"/>
    <xsl:param name="lastROW" select="0"/>
    <xsl:param name="lastcol" select="0"/>

    <xsl:variable name="TGROUP" select="$ROW/ancestor::TGROUP[1]"/>

    <xsl:variable name="ENTRY.value">
      <xsl:call-template name="get-attribute">
        <xsl:with-param name="element" select="$ENTRY"/>
        <xsl:with-param name="attribute" select="$attribute"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="ROW.value">
      <xsl:call-template name="get-attribute">
        <xsl:with-param name="element" select="$ROW"/>
        <xsl:with-param name="attribute" select="$attribute"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="span.value">
      <xsl:if test="$ENTRY/@SPANNAME">
        <xsl:variable name="SPANNAME" select="$ENTRY/@SPANNAME"/>
        <xsl:variable name="SPANSPEC" select="$TGROUP/SPANSPEC[@SPANNAME=$SPANNAME]"/>
        <xsl:variable name="span.COLSPEC" select="$TGROUP/COLSPEC[@COLNAME=$SPANSPEC/@NAMEST]"/>

        <xsl:variable name="SPANSPEC.value">
          <xsl:call-template name="get-attribute">
            <xsl:with-param name="element" select="$SPANSPEC"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="sCOLSPEC.value">
          <xsl:call-template name="get-attribute">
            <xsl:with-param name="element" select="$span.COLSPEC"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$SPANSPEC.value != ''">
            <xsl:value-of select="$SPANSPEC.value"/>
          </xsl:when>
          <xsl:when test="$sCOLSPEC.value != ''">
            <xsl:value-of select="$sCOLSPEC.value"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="NAMEST.value">
      <xsl:if test="$ENTRY/@NAMEST">
        <xsl:variable name="NAMEST" select="$ENTRY/@NAMEST"/>
        <xsl:variable name="COLSPEC" select="$TGROUP/COLSPEC[@COLNAME=$NAMEST]"/>

        <xsl:variable name="NAMEST.value">
          <xsl:call-template name="get-attribute">
            <xsl:with-param name="element" select="$COLSPEC"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$NAMEST.value">
            <xsl:value-of select="$NAMEST.value"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="TGROUP.value">
      <xsl:call-template name="get-attribute">
        <xsl:with-param name="element" select="$TGROUP"/>
        <xsl:with-param name="attribute" select="$attribute"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="default.value">
      <!-- ROWSEP and COLSEP can have defaults on the "table" wrapper and 
        ultimately on the frame setting for outside rules -->
      <!-- handle those here, for everything else, the default is the TGROUP value -->
      <xsl:choose>
        <xsl:when test="$TGROUP.value != ''">
          <xsl:value-of select="$TGROUP.value"/>
        </xsl:when>
        <xsl:when test="$attribute = 'ROWSEP'">
          <xsl:choose>
            <xsl:when test="$TGROUP/parent::*/@ROWSEP">
              <xsl:value-of select="$TGROUP/parent::*/@ROWSEP"/>
            </xsl:when>
            <xsl:when test="not($TGROUP/parent::*/@FRAME)">
              <!-- default frame is equivalent to 'all' -->
              <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$TGROUP/parent::*/@FRAME = 'ALL'">
              <!-- default frame is equivalent to 'all' -->
              <xsl:value-of select="1"/>
            </xsl:when>
            <!-- this isn't really right yet since other values of
              frame will affect some outermost rules, and no values
              should affect non-outermost rules, but this is our
              current approximation -->
            <xsl:otherwise><!-- empty --></xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$attribute = 'COLSEP'">
          <xsl:choose>
            <xsl:when test="$TGROUP/parent::*/@COLSEP">
              <xsl:value-of select="$TGROUP/parent::*/@COLSEP"/>
            </xsl:when>
            <xsl:when test="not($TGROUP/parent::*/@FRAME)">
              <!-- default frame is equivalent to 'all' -->
              <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$TGROUP/parent::*/@FRAME = 'ALL'">
              <!-- default frame is equivalent to 'all' -->
              <xsl:value-of select="1"/>
            </xsl:when>
            <!-- this isn't really right yet since other values of
              frame will affect some outermost rules, and no values
              should affect non-outermost rules, but this is our
              current approximation -->
            <xsl:otherwise><!-- empty --></xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise><!-- empty --></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$ENTRY.value != ''">
        <xsl:value-of select="$ENTRY.value"/>
      </xsl:when>
      <xsl:when test="$ROW.value != ''">
        <xsl:value-of select="$ROW.value"/>
      </xsl:when>
      <xsl:when test="$span.value != ''">
        <xsl:value-of select="$span.value"/>
      </xsl:when>
      <xsl:when test="$NAMEST.value != ''">
        <xsl:value-of select="$NAMEST.value"/>
      </xsl:when>
      <xsl:when test="$COLNUM &gt; 0">
        <xsl:variable name="calc.colvalue">
          <xsl:call-template name="COLNUM.COLSPEC">
            <xsl:with-param name="COLNUM" select="$COLNUM"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$calc.colvalue != ''">
            <xsl:value-of select="$calc.colvalue"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default.value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default.value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="COLNUM.COLSPEC">
    <xsl:param name="COLNUM" select="0"/>
    <xsl:param name="attribute" select="'COLNAME'"/>
    <xsl:param name="COLSPECs" select="ancestor::TGROUP/COLSPEC"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="not($COLSPECs) or $count &gt; $COLNUM">
        <!-- nop -->
      </xsl:when>
      <xsl:when test="$COLSPECs[1]/@COLNUM">
        <xsl:choose>
          <xsl:when test="$COLSPECs[1]/@COLNUM = $COLNUM">
            <xsl:call-template name="get-attribute">
              <xsl:with-param name="element" select="$COLSPECs[1]"/>
              <xsl:with-param name="attribute" select="$attribute"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="COLNUM.COLSPEC">
              <xsl:with-param name="COLNUM" select="$COLNUM"/>
              <xsl:with-param name="attribute" select="$attribute"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs[position()&gt;1]"/>
              <xsl:with-param name="count" select="$COLSPECs[1]/@COLNUM+1"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$count = $COLNUM">
            <xsl:call-template name="get-attribute">
              <xsl:with-param name="element" select="$COLSPECs[1]"/>
              <xsl:with-param name="attribute" select="$attribute"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="COLNUM.COLSPEC">
              <xsl:with-param name="COLNUM" select="$COLNUM"/>
              <xsl:with-param name="attribute" select="$attribute"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs[position()&gt;1]"/>
              <xsl:with-param name="count" select="$count+1"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-attribute">
    <xsl:param name="element" select="."/>
    <xsl:param name="attribute" select="''"/>

    <xsl:for-each select="$element/@*">
      <xsl:if test="local-name(.) = $attribute">
        <xsl:value-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ==================================================================== -->

  <lxslt:component prefix="xtbl" xmlns:lxslt="http://xml.apache.org/xslt"
    functions="adjustColumnWidths"/>

  <!-- ==================================================================== -->

  <xsl:template name="empty.table.cell">
    <xsl:param name="COLNUM" select="0"/>

    <xsl:variable name="lastROW">
      <xsl:choose>
        <xsl:when test="ancestor::THEAD">0</xsl:when>
        <xsl:when test="ancestor::TFOOT
          and not(ancestor::ROW/following-sibling::ROW)"
          >1</xsl:when>
        <xsl:when test="not(ancestor::TFOOT)
          and ancestor::TGROUP/TFOOT">0</xsl:when>
        <xsl:when
          test="not(ancestor::TFOOT)
          and not(ancestor::TGROUP/TFOOT)
          and not(ancestor::ROW/following-sibling::ROW)"
          >1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="lastcol">
      <xsl:choose>
        <xsl:when test="$COLNUM &lt; ancestor::TGROUP/@COLS">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="ROWSEP">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="NOT-AN-ELEMENT-NAME"/>
        <xsl:with-param name="ROW" select="ancestor-or-self::ROW[1]"/>
        <xsl:with-param name="COLNUM" select="$COLNUM"/>
        <xsl:with-param name="attribute" select="'ROWSEP'"/>
        <xsl:with-param name="lastROW" select="$lastROW"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="COLSEP">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="NOT-AN-ELEMENT-NAME"/>
        <xsl:with-param name="ROW" select="ancestor-or-self::ROW[1]"/>
        <xsl:with-param name="COLNUM" select="$COLNUM"/>
        <xsl:with-param name="attribute" select="'COLSEP'"/>
        <xsl:with-param name="lastROW" select="$lastROW"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:table-cell text-align="center" display-align="center"
      xsl:use-attribute-sets="table.cell.padding">
      <xsl:call-template name="ENTRY"/>

      <xsl:if test="$ROWSEP &gt; 0">
        <xsl:call-template name="border">
          <xsl:with-param name="side" select="'bottom'"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="$COLSEP &gt; 0">
        <xsl:call-template name="border">
          <xsl:with-param name="side" select="'right'"/>
        </xsl:call-template>
      </xsl:if>

      <!-- ***** first added call to handle _cellfont ***** -->
      <xsl:call-template name="just-after-table-cell-stag"/>
      <!-- ***** end added line ***** -->

      <!-- fo:table-cell should not be empty -->
      <fo:block/>

      <!-- ***** second added call to handle _cellfont ***** -->
      <xsl:call-template name="just-before-table-cell-etag"/>
      <!-- ***** end added line ***** -->

    </fo:table-cell>
  </xsl:template>

  <!-- ==================================================================== -->

  <xsl:template name="border">
    <xsl:param name="side" select="'left'"/>

    <!-- Maybe set border thickness from PubTbl PI -->
    <xsl:variable name="border-thickness">
      <xsl:choose>
        <xsl:when
          test="ancestor-or-self::TGROUP[1]/processing-instruction('PubTbl')[starts-with(.,'TGROUP') and contains(.,' rth=')]">
          <xsl:variable name="rth-pi"
            select="ancestor-or-self::TGROUP[1]/processing-instruction('PubTbl')[starts-with(.,'TGROUP') and contains(.,' rth=')]"/>
          <xsl:variable name="rth-pi2" select="substring-after($rth-pi,&quot; rth=&quot;)"/>
          <xsl:value-of select="substring-before(substring($rth-pi2,2),'&quot;')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$table.border.thickness"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:attribute name="border-{$side}-width">
      <xsl:value-of select="$border-thickness"/>
    </xsl:attribute>
    <xsl:attribute name="border-{$side}-style">
      <xsl:value-of select="$table.border.style"/>
    </xsl:attribute>
    <xsl:attribute name="border-{$side}-color">
      <xsl:value-of select="$table.border.color"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="TABLE">
    <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
  </xsl:template>
  
  
  <xsl:template match="TGROUP">
    <!-- HT Outer fo:table is used to handle repeating the table header on subsequent pages -->
    
    <!-- xsl:call-template name="table-data"/ -->
    <xsl:variable name="table-offset">
      <xsl:call-template name="calculateTableOffset"/>
    </xsl:variable>
    
    <xsl:variable name="table-title">
      <xsl:call-template name="get-table-title"/> 
    </xsl:variable>
    
    <xsl:variable name="revised-title">
      <xsl:for-each select="preceding-sibling::TITLE">
        <xsl:choose>
          <xsl:when test="preceding-sibling::node()[1][.='_rev']  and following-sibling::node()[1][.='/_rev']">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <!-- Changes made by Nathan for revbar issue -->
          <xsl:when test="./preceding-sibling::processing-instruction('Pub')[. = '_rev'] and following-sibling::processing-instruction('Pub')[. = '/_rev']">
            <xsl:text>true</xsl:text>>
          </xsl:when>
          <!-- End of changes made by Nathan -->
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
      
    <fo:block space-before.minimum=".1in" space-before.optimum=".2in" space-after.maximum=".3in"
      space-before.conditionality="retain">
      <xsl:attribute name="margin-left">
        <xsl:call-template name="calculateTableOffset"/>
      </xsl:attribute>
      
      <!-- Break before Key for figure and dimensional limits tables in "ap" graphics
      <xsl:if test="ancestor::GDESC and ancestor::SHEET/@IMGAREA='ap'">
        <xsl:attribute name="break-before">page</xsl:attribute>
      </xsl:if>
      -->
       
      <xsl:choose>
      
       
          <xsl:when test="not($table-title = 'NO_TITLE')">
             <fo:block font-weight="bold" text-align="center" 
          space-after="6pt" >
              <xsl:if test="$revised-title = 'true'">
                <xsl:call-template name="cbStart" />
              </xsl:if>

            <!-- CV - this is where table title wss being converted to string value and losing any "sub|super" effects -->
            <!-- <xsl:value-of select="$table-title"/> -->
            <xsl:call-template name="get-table-title"/>

              <xsl:if test="$revised-title = 'true'">
                <xsl:call-template name="cbEnd" />
              </xsl:if>
            </fo:block>
            
            <fo:table rx:table-omit-initial-header="true" keep-with-previous.within-page="always">
              <!--<fo:table-column column-width="100%"/>Changes made by Nathan -->
              <xsl:attribute name="width">100%</xsl:attribute>
              <fo:table-column column-width="proportional-column-width(1)"/>
			 <fo:table-column/>
			 <fo:table-column column-width="proportional-column-width(1)"/>              
              <!-- End of changes made by Nathan -->
              <fo:table-header>
                 <!--Changes made by Nathan -->
                 <fo:table-cell/>
                 <!-- End of changes made by Nathan -->
                 <fo:table-cell padding="0pt">
                  <xsl:if test="$revised-title = 'true'">
                    <xsl:call-template name="cbStart" />
                  </xsl:if>
                  <fo:block font-weight="bold" text-align="center" space-after="5.7pt" space-before=".1in">

                    <!-- CV - this is where table title wss being converted to string value and losing any "sub|super" effects -->
                    <!-- <xsl:value-of select="concat($table-title,' (Cont)')"/> -->
                    <xsl:call-template name="get-table-title"/>
                    <xsl:text> (Cont)</xsl:text>

                  </fo:block>
                  <xsl:if test="$revised-title = 'true'">
                    <xsl:call-template name="cbEnd" />
                  </xsl:if>
                 </fo:table-cell>
                 <!--Changes made by Nathan -->
                 <fo:table-cell/>
                 <!-- End of changes made by Nathan -->
              </fo:table-header>
              <fo:table-body>
                <fo:table-row keep-together.within-page="auto">
                     <!--Changes made by Nathan -->
                     <fo:table-cell/>
                     <!-- End of changes made by Nathan -->
                     <fo:table-cell>
                         <xsl:call-template name="inner-table"/>
                     </fo:table-cell>
                     <!--Changes made by Nathan -->
                     <fo:table-cell/>
                     <!-- End of changes made by Nathan -->
                </fo:table-row>
              </fo:table-body>
            </fo:table>
          </xsl:when>
        
        <xsl:otherwise>
          <xsl:call-template name="inner-table"/>
        </xsl:otherwise>
        
      </xsl:choose>
    </fo:block>
    <xsl:if test="ancestor::INTRO">
      <xsl:apply-templates select="./parent::TABLE/FTNOTE[1]"/>
    </xsl:if>
  </xsl:template>
  
  
  <!-- Call with TGROUP in context -->
  <xsl:template name="get-table-title">
    <xsl:choose>
      <!-- If the table has a TITLE and is in GDESC, it is a "Dimensional Limits" table. -->
      <xsl:when test="((preceding-sibling::TITLE) and (ancestor::GDESC))">
         <xsl:apply-templates select="preceding-sibling::TITLE" mode="table-title"/>
         <xsl:text>  for Figure </xsl:text>
         <xsl:for-each select="ancestor::SHEET">
          <xsl:call-template name="calc-figure-number"/>
        </xsl:for-each>
        <xsl:text> (Sheet </xsl:text>
        <!--
        <xsl:value-of select="1 + count (../../preceding-sibling::SHEET)"/>
        -->
        <xsl:value-of select="1 + count(ancestor::SHEET/preceding-sibling::SHEET)"/>
        <xsl:text> of </xsl:text>
        <xsl:value-of select="count (ancestor::GRAPHIC/SHEET)"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      
      <xsl:when test="preceding-sibling::TITLE">
        <xsl:text>Table </xsl:text>
        <xsl:for-each select="parent::node()">
          <xsl:call-template name="calc-table-number"/>
        </xsl:for-each>
        <xsl:text>. </xsl:text>
          <xsl:apply-templates select="preceding-sibling::TITLE" mode="table-title"/>
      </xsl:when>
      
      <!-- If inside GDESC this is KEY to FIGURE -->
      <xsl:when test="ancestor::GDESC">
        <!--<xsl:text>KEY TO FIGURE </xsl:text>-->
        <xsl:text>Key for Figure </xsl:text>
        <xsl:for-each select="ancestor::SHEET">
          <xsl:call-template name="calc-figure-number"/>
        </xsl:for-each>
        <xsl:text> (Sheet </xsl:text>
        <!-- DJH
        <xsl:value-of select="1 + count (../../preceding-sibling::SHEET)"/>
        -->
        <xsl:value-of select="1 + count (../../../preceding-sibling::SHEET)"/>
        <xsl:text> of </xsl:text>
        <!-- DJH
        <xsl:value-of select="count (ancestor::GRAPHIC[SHEET])"/>
        -->
        <xsl:value-of select="count (ancestor::GRAPHIC/SHEET)"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>NO_TITLE</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template name="inner-table">
    <fo:table table-layout="fixed" border-collapse="collapse"
      border-after-width.conditionality="retain"
      border-before-width.conditionality="retain">
      <xsl:if test="parent::node()/@ID">
        <xsl:attribute name="id">
          <xsl:value-of select="parent::node()/@ID"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(preceding-sibling::TGROUP)=0">
          <xsl:call-template name="TGROUP.first"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="TGROUP.notfirst"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- default the value of frame to all -->
      <xsl:variable name="FRAME">
        <xsl:choose>
          <xsl:when test="../@FRAME">
            <xsl:value-of select="../@FRAME"/>
          </xsl:when>
          <xsl:otherwise>all</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- unless frame='NONE', for now, act as if it were 'all' -->
      <xsl:choose>
        <xsl:when test="$FRAME='TOPBOT'">
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'top'"/>
          </xsl:call-template>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'bottom'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$FRAME!='NONE'">
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'left'"/>
          </xsl:call-template>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'right'"/>
          </xsl:call-template>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'top'"/>
          </xsl:call-template>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'bottom'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$FRAME='NONE'"> 
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="TGROUP-after-table-fo"/>
    </fo:table>
  </xsl:template>

  <xsl:template match="TGROUP" name="TGROUP-after-table-fo" mode="already-emitted-table-fo">
    <xsl:variable name="COLSPECs">
      <xsl:choose>
        <xsl:when test="$use.extensions != 0
          and $tablecolumns.extension != 0">
          <xsl:call-template name="generate.colgroup.raw">
            <xsl:with-param name="COLS" select="@COLS"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="generate.colgroup">
            <xsl:with-param name="COLS" select="@COLS"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$use.extensions != 0
        and $tablecolumns.extension != 0">
        <xsl:choose>
          <xsl:when test="function-available('stbl:adjustColumnWidths')"
            xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table">
            <xsl:copy-of select="stbl:adjustColumnWidths($COLSPECs)"/>
          </xsl:when>
          <xsl:when test="function-available('xtbl:adjustColumnWidths')"
            xmlns:xtbl="com.nwalsh.xalan.Table">
            <xsl:copy-of select="xtbl:adjustColumnWidths($COLSPECs)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>No adjustColumnWidths function available.</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$COLSPECs"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- HT Use header for continuation message -->
    <xsl:if test="false()">
      <fo:table-header start-indent="0pt">
        <fo:table-row>
          <fo:table-cell>
            <fo:block>
              <fo:inline font-style="italic">
                <xsl:text> Table Title (Cont) </xsl:text>
              </fo:inline>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-header>
    </xsl:if>

    <xsl:apply-templates select="THEAD"/>
    <xsl:apply-templates select="TFOOT"/>
    <xsl:apply-templates select="TBODY"/>
  </xsl:template>

  <xsl:template match="COLSPEC"/>

  <xsl:template match="SPANSPEC"/>

  <xsl:template match="THEAD">
    <xsl:variable name="TGROUP" select="parent::*"/>

    <fo:table-header>
      <xsl:call-template name="THEAD"/>
      <xsl:apply-templates select="ROW[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="COLS" select="../@COLS"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>
    </fo:table-header>
  </xsl:template>

  <xsl:template match="TFOOT">
    <xsl:variable name="TGROUP" select="parent::*"/>

    <fo:table-footer>
      <xsl:call-template name="TFOOT"/>
      <xsl:apply-templates select="ROW[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="COLS" select="../@COLS"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>

    </fo:table-footer>
  </xsl:template>

  <xsl:template match="TBODY">
    <xsl:variable name="TGROUP" select="parent::*"/>

    <fo:table-body>
      <xsl:call-template name="TBODY"/>
      <!-- Changes made by Nathan for abbrev -->
      <xsl:if test="contains((./parent::TGROUP/parent::TABLE/TITLE), 'Acronyms and Abbreviations')">
         <xsl:call-template name="accroAbbrevTableRow"/>
      </xsl:if>
      <xsl:if test="not(contains((./parent::TGROUP/parent::TABLE/TITLE), 'Acronyms and Abbreviations'))">
         <xsl:apply-templates select="ROW[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="COLS" select="../@COLS"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>
      </xsl:if>
      <!-- End of changes made by Nathan -->
      <!--<xsl:apply-templates select="ROW[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="COLS" select="../@COLS"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>-->
    </fo:table-body>
  </xsl:template>

  <xsl:template match="ROW">
    <xsl:param name="spans"/>

    <fo:table-row>
      <xsl:call-template name="ROW"/>
      <xsl:apply-templates select="ENTRY[1]">
        <xsl:with-param name="spans" select="$spans"/>
      </xsl:apply-templates>
    </fo:table-row>

    <xsl:if test="following-sibling::ROW">
      <xsl:variable name="nextspans">
        <xsl:apply-templates select="ENTRY[1]" mode="span">
          <xsl:with-param name="spans" select="$spans"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:apply-templates select="following-sibling::ROW[1]">
        <xsl:with-param name="spans" select="$nextspans"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ENTRY" name="ENTRY-template">
    <xsl:param name="col" select="1"/>
    <xsl:param name="spans"/>

    <xsl:variable name="ROW" select="parent::ROW"/>
    <xsl:variable name="group" select="$ROW/parent::*[1]"/>

    <xsl:variable name="empty.cell" select="count(node()) = 0"/>

    <xsl:variable name="named.COLNUM">
      <xsl:call-template name="ENTRY.COLNUM"/>
    </xsl:variable>

    <xsl:variable name="ENTRY.COLNUM">
      <xsl:choose>
        <xsl:when test="$named.COLNUM &gt; 0">
          <xsl:value-of select="$named.COLNUM"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$col"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="ENTRY.COLSPAN">
      <xsl:choose>
        <xsl:when test="@SPANNAME or @NAMEST">
          <xsl:call-template name="calculate.COLSPAN"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="following.spans">
      <xsl:call-template name="calculate.following.spans">
        <xsl:with-param name="COLSPAN" select="$ENTRY.COLSPAN"/>
        <xsl:with-param name="spans" select="$spans"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="lastROW">
      <xsl:choose>
        <xsl:when test="ancestor::THEAD">0</xsl:when>
        <xsl:when test="ancestor::TFOOT
          and not(ancestor::ROW/following-sibling::ROW)"
          >1</xsl:when>
        <xsl:when test="not(ancestor::TFOOT)
          and ancestor::TGROUP/TFOOT">0</xsl:when>
        <xsl:when
          test="not(ancestor::TFOOT)
          and not(ancestor::TGROUP/TFOOT)
          and not(ancestor::ROW/following-sibling::ROW)"
          >1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="lastcol">
      <xsl:choose>
        <xsl:when test="$col &lt; ancestor::TGROUP/@COLS">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="ROWSEP">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="."/>
        <xsl:with-param name="COLNUM" select="$ENTRY.COLNUM"/>
        <xsl:with-param name="attribute" select="'ROWSEP'"/>
        <xsl:with-param name="lastROW" select="$lastROW"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
      <xsl:message><xsl:value-of select="."/>: <xsl:value-of select="$ROWSEP"/></xsl:message>
    -->

    <xsl:variable name="COLSEP">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="."/>
        <xsl:with-param name="COLNUM" select="$ENTRY.COLNUM"/>
        <xsl:with-param name="attribute" select="'COLSEP'"/>
        <xsl:with-param name="lastROW" select="$lastROW"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="VALIGN">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="."/>
        <xsl:with-param name="COLNUM" select="$ENTRY.COLNUM"/>
        <xsl:with-param name="attribute" select="'VALIGN'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="ALIGN">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="."/>
        <xsl:with-param name="COLNUM" select="$ENTRY.COLNUM"/>
        <xsl:with-param name="attribute" select="'ALIGN'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="CHAR">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="."/>
        <xsl:with-param name="COLNUM" select="$ENTRY.COLNUM"/>
        <xsl:with-param name="attribute" select="'CHAR'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="CHAROFF">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="ENTRY" select="."/>
        <xsl:with-param name="COLNUM" select="$ENTRY.COLNUM"/>
        <xsl:with-param name="attribute" select="'CHAROFF'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$spans != '' and not(starts-with($spans,'0:'))">
        <xsl:call-template name="ENTRY-template">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ENTRY.COLNUM &gt; $col">
        <xsl:call-template name="empty.table.cell">
          <xsl:with-param name="COLNUM" select="$col"/>
        </xsl:call-template>
        <xsl:call-template name="ENTRY-template">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="cell.content">
          <fo:block>
            <!-- highlight this ENTRY? -->
            <xsl:if test="ancestor::THEAD">
              <xsl:attribute name="font-weight">bold</xsl:attribute>
            </xsl:if>

            <!-- are we missing any indexterms? -->
            <xsl:if
              test="not(preceding-sibling::ENTRY)
              and not(parent::ROW/preceding-sibling::ROW)">
              <!-- this is the first ENTRY of the first ROW -->
              <xsl:if
                test="ancestor::THEAD or
                (ancestor::TBODY
                and not(ancestor::TBODY/preceding-sibling::THEAD
                or ancestor::TBODY/preceding-sibling::TBODY))">
                <!-- of the THEAD or the first tbody -->
                <xsl:apply-templates select="ancestor::TGROUP/preceding-sibling::INDEXTERM"/>
              </xsl:if>
            </xsl:if>

            <!--
              <xsl:text>(</xsl:text>
              <xsl:value-of select="$ROWSEP"/>
              <xsl:text>,</xsl:text>
              <xsl:value-of select="$COLSEP"/>
              <xsl:text>)</xsl:text>
            -->
            <xsl:choose>
              <xsl:when test="$empty.cell">
                <xsl:text>&#160;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </xsl:variable>

        <fo:table-cell xsl:use-attribute-sets="table.cell.padding">
          <xsl:call-template name="ENTRY"/>

          <xsl:if test="$ROWSEP &gt; 0">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'bottom'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$COLSEP &gt; 0">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'right'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="@MOREROWS">
            <xsl:attribute name="number-rows-spanned">
              <xsl:value-of select="@MOREROWS+1"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$ENTRY.COLSPAN &gt; 1">
            <xsl:attribute name="number-columns-spanned">
              <xsl:value-of select="$ENTRY.COLSPAN"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$VALIGN != ''">
            <xsl:attribute name="display-align">
              <xsl:choose>
                <xsl:when test="translate($VALIGN,$upperCase,$lowerCase) ='top'">before</xsl:when>
                <xsl:when test="translate($VALIGN,$upperCase,$lowerCase) ='middle'"
                  >center</xsl:when>
                <xsl:when test="translate($VALIGN,$upperCase,$lowerCase) ='bottom'">after</xsl:when>
                <xsl:otherwise>
                  <xsl:message>
                    <xsl:text>Unexpected VALIGN value: </xsl:text>
                    <xsl:value-of select="$VALIGN"/>
                    <xsl:text>, center used.</xsl:text>
                  </xsl:message>
                  <xsl:text>center</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$ALIGN != ''">
            <xsl:attribute name="text-align">
              <!-- Changes made by Nathan for ALIGN="CHAR"-->
              <!--<xsl:value-of select="translate(string($ALIGN),$upperCase,$lowerCase)"/>-->
              <xsl:choose>
                <xsl:when test="$ALIGN='CHAR'">left</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="translate(string($ALIGN),$upperCase,$lowerCase)"/>
                </xsl:otherwise>
              </xsl:choose>
              <!-- End of changes made by Nathan -->
            </xsl:attribute>
          </xsl:if>

          <!-- GAP added 6/10/08  Remove white space from the CHAR variable -->
          <xsl:variable name="new-CHAR"
            select="translate(string($CHAR),'&#x20;&#x9;&#xA;&#xD;','')"/>
          <xsl:if test="$new-CHAR != ''">
            <xsl:attribute name="text-align">
              <xsl:value-of select="translate(string($CHAR),$upperCase,$lowerCase)"/>
              <!-- new part -->
            </xsl:attribute>
          </xsl:if>

          <!--
            <xsl:if test="@CHAROFF">
            <xsl:attribute name="CHAROFF">
            <xsl:value-of select="@CHAROFF"/>
            </xsl:attribute>
            </xsl:if>
          -->

          <!-- ***** first added call to handle _cellfont ***** -->
          <xsl:call-template name="just-after-table-cell-stag"/>
          <!-- ***** end added line ***** -->

          <xsl:copy-of select="$cell.content"/>

          <!-- ***** second added call to handle _cellfont ***** -->
          <xsl:call-template name="just-before-table-cell-etag"/>
          <!-- ***** end added line ***** -->

        </fo:table-cell>

        <xsl:choose>
          <xsl:when test="following-sibling::ENTRY">
            <xsl:apply-templates select="following-sibling::ENTRY[1]">
              <xsl:with-param name="col" select="$col+$ENTRY.COLSPAN"/>
              <xsl:with-param name="spans" select="$following.spans"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="finaltd">
              <xsl:with-param name="spans" select="$following.spans"/>
              <xsl:with-param name="col" select="$col+$ENTRY.COLSPAN"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ENTRY" name="sENTRY" mode="span">
    <xsl:param name="col" select="1"/>
    <xsl:param name="spans"/>

    <xsl:variable name="ENTRY.COLNUM">
      <xsl:call-template name="ENTRY.COLNUM"/>
    </xsl:variable>

    <xsl:variable name="ENTRY.COLSPAN">
      <xsl:choose>
        <xsl:when test="@SPANNAME or @NAMEST">
          <xsl:call-template name="calculate.COLSPAN"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="following.spans">
      <xsl:call-template name="calculate.following.spans">
        <xsl:with-param name="COLSPAN" select="$ENTRY.COLSPAN"/>
        <xsl:with-param name="spans" select="$spans"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$spans != '' and not(starts-with($spans,'0:'))">
        <xsl:value-of select="substring-before($spans,':')-1"/>
        <xsl:text>:</xsl:text>
        <xsl:call-template name="sENTRY">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ENTRY.COLNUM &gt; $col">
        <xsl:text>0:</xsl:text>
        <xsl:call-template name="sENTRY">
          <xsl:with-param name="col" select="$col+$ENTRY.COLSPAN"/>
          <xsl:with-param name="spans" select="$following.spans"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="copy-string">
          <xsl:with-param name="count" select="$ENTRY.COLSPAN"/>
          <xsl:with-param name="string">
            <xsl:choose>
              <xsl:when test="@MOREROWS">
                <xsl:value-of select="@MOREROWS"/>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
            <xsl:text>:</xsl:text>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:choose>
          <xsl:when test="following-sibling::ENTRY">
            <xsl:apply-templates select="following-sibling::ENTRY[1]" mode="span">
              <xsl:with-param name="col" select="$col+$ENTRY.COLSPAN"/>
              <xsl:with-param name="spans" select="$following.spans"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="sfinaltd">
              <xsl:with-param name="spans" select="$following.spans"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate.colgroup.raw">
    <xsl:param name="COLS" select="1"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count>$COLS"/>
      <xsl:otherwise>
        <xsl:call-template name="generate.col.raw">
          <xsl:with-param name="countcol" select="$count"/>
        </xsl:call-template>
        <xsl:call-template name="generate.colgroup.raw">
          <xsl:with-param name="COLS" select="$COLS"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate.colgroup">
    <xsl:param name="COLS" select="1"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count>$COLS"/>
      <xsl:otherwise>
        <xsl:call-template name="generate.col">
          <xsl:with-param name="countcol" select="$count"/>
        </xsl:call-template>
        <xsl:call-template name="generate.colgroup">
          <xsl:with-param name="COLS" select="$COLS"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate.col.raw">
    <!-- generate the table-column for column countcol -->
    <xsl:param name="countcol">1</xsl:param>
    <xsl:param name="COLSPECs" select="./COLSPEC"/>
    <xsl:param name="count">1</xsl:param>
    <xsl:param name="COLNUM">1</xsl:param>

    <xsl:choose>
      <xsl:when test="$count>count($COLSPECs)">
        <fo:table-column column-number="{$countcol}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="COLSPEC" select="$COLSPECs[$count=position()]"/>

        <xsl:variable name="COLSPEC.COLNUM">
          <xsl:choose>
            <xsl:when test="$COLSPEC/@COLNUM">
              <xsl:value-of select="$COLSPEC/@COLNUM"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$COLNUM"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="COLSPEC.COLWIDTH">
          <xsl:choose>
            <xsl:when test="$COLSPEC/@COLWIDTH">
              <xsl:value-of select="$COLSPEC/@COLWIDTH"/>
            </xsl:when>
            <xsl:otherwise>1*</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$COLSPEC.COLNUM=$countcol">
            <fo:table-column column-number="{$countcol}">
              <xsl:attribute name="column-width">
                <xsl:value-of select="$COLSPEC.COLWIDTH"/>
              </xsl:attribute>
            </fo:table-column>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="generate.col.raw">
              <xsl:with-param name="countcol" select="$countcol"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs"/>
              <xsl:with-param name="count" select="$count+1"/>
              <xsl:with-param name="COLNUM">
                <xsl:choose>
                  <xsl:when test="$COLSPEC/@COLNUM">
                    <xsl:value-of select="$COLSPEC/@COLNUM + 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$COLNUM + 1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate.col">
    <!-- generate the table-column for column countcol -->
    <xsl:param name="countcol">1</xsl:param>
    <xsl:param name="COLSPECs" select="./COLSPEC"/>
    <xsl:param name="count">1</xsl:param>
    <xsl:param name="COLNUM">1</xsl:param>
    <xsl:choose>
      <xsl:when test="$count>count($COLSPECs)">
        <fo:table-column column-number="{$countcol}">
          <xsl:variable name="COLWIDTH">
            <xsl:call-template name="calc.column.width"/>
          </xsl:variable>
          <xsl:if test="$COLWIDTH != 'proportional-column-width(1)'">
            <xsl:attribute name="column-width">
              <xsl:value-of select="$COLWIDTH"/>
            </xsl:attribute>
          </xsl:if>
        </fo:table-column>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="COLSPEC" select="$COLSPECs[$count=position()]"/>

        <xsl:variable name="COLSPEC.COLNUM">
          <xsl:choose>
            <xsl:when test="$COLSPEC/@COLNUM">
              <xsl:value-of select="$COLSPEC/@COLNUM"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$COLNUM"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="COLSPEC.COLWIDTH">
          <xsl:choose>
            <xsl:when test="$COLSPEC/@COLWIDTH">
              <xsl:value-of select="$COLSPEC/@COLWIDTH"/>
            </xsl:when>
            <xsl:otherwise>1*</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$COLSPEC.COLNUM=$countcol">
            <fo:table-column column-number="{$countcol}">
              <xsl:variable name="COLWIDTH">
                <xsl:call-template name="calc.column.width">
                  <xsl:with-param name="COLWIDTH">
                    <xsl:value-of select="$COLSPEC.COLWIDTH"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:if test="$COLWIDTH != 'proportional-column-width(1)'">
                <xsl:attribute name="column-width">
                  <xsl:value-of select="$COLWIDTH"/>
                </xsl:attribute>
              </xsl:if>
            </fo:table-column>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="generate.col">
              <xsl:with-param name="countcol" select="$countcol"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs"/>
              <xsl:with-param name="count" select="$count+1"/>
              <xsl:with-param name="COLNUM">
                <xsl:choose>
                  <xsl:when test="$COLSPEC/@COLNUM">
                    <xsl:value-of select="$COLSPEC/@COLNUM + 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$COLNUM + 1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc.column.width">
    <xsl:param name="COLWIDTH">1*</xsl:param>



    <!-- Changes made by Nathan -->
    <xsl:param name="tableContext" select="./ancestor-or-self::TABLE"/>
    <xsl:param name="totalColumns" select="count($tableContext/TGROUP[1]/COLSPEC)"/>
    <xsl:param name="widthOfEachColumn" select="7 div $totalColumns"/>
    <!-- End of changes made by Nathan -->

    <!-- Force the column width value to lower case HT -->
    <xsl:variable name="lowercaseColwidth"
      select="translate($COLWIDTH,
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ*0123456789',
      'abcdefghijklmnopqrstuvwxyz*0123456789')"/>

    <!-- Ok, the COLWIDTH could have any one of the following forms: -->
    <!--        1*       = proportional width -->
    <!--     1unit       = 1.0 units wide -->
    <!--         1       = 1pt wide -->
    <!--  1*+1unit       = proportional width + some fixed width -->
    <!--      1*+1       = proportional width + some fixed width -->

    <!-- If it has a proportional width, translate it to XSL -->
    <!-- Changes made by Nathan -->
    <!--<xsl:if test="contains($COLWIDTH, '*')">
      <xsl:text>proportional-column-width(</xsl:text>
      <xsl:value-of select="substring-before($COLWIDTH, '*')"/>
      <xsl:text>)</xsl:text>
      </xsl:if>-->
    <xsl:if test="contains($lowercaseColwidth, '*')">
      <xsl:value-of select="$widthOfEachColumn"/>
      <xsl:text>in</xsl:text>
    </xsl:if>
    <!-- End of changes made by Nathan -->
    <!-- Now grab the non-proportional part of the specification -->
    <xsl:variable name="width-units">
      <xsl:choose>
        <xsl:when test="contains($lowercaseColwidth, '*')">
          <xsl:value-of select="normalize-space(substring-after($lowercaseColwidth, '*'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($lowercaseColwidth)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Ok, now the width-units could have any one of the following forms: -->
    <!--                 = <empty string> -->
    <!--     1unit       = 1.0 units wide -->
    <!--         1       = 1pt wide -->
    <!-- with an optional leading sign -->

    <!-- Grab the width part by blanking out the units part and discarding -->
    <!-- whitespace. It's not pretty, but it works. -->
    <xsl:variable name="width"
      select="normalize-space(translate($width-units,
      '+-0123456789.acdefghijklmnopqrstuvwxyz',
      '+-0123456789.'))"/>

    <!-- Grab the units part by blanking out the width part and discarding -->
    <!-- whitespace. It's not pretty, but it works. -->
    <xsl:variable name="units"
      select="normalize-space(translate($width-units,
      'acdefghijklmnopqrstuvwxyz+-0123456789.',
      'acdefghijklmnopqrstuvwxyz'))"/>

    <!-- Output the width -->
    <xsl:value-of select="$width"/>

    <!-- Output the units, translated appropriately -->
    <xsl:choose>
      <xsl:when test="$units = 'pi'">pc</xsl:when>
      <xsl:when test="$units = '' and $width != ''">pt</xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$units"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="table-data">
    <xsl:variable name="total" select="0"/>
    <xsl:message>table-data function not complete</xsl:message>
  </xsl:template>
  
  
    

  <xsl:template name="calculateTableOffset">
    
    <xsl:variable name="common-indent" select="24"/>
    <xsl:variable name="offset"
      select="$common-indent * 
      (
      count(ancestor::TASK) +
      count(ancestor::SUBTASK) +
      count(ancestor::LIST1) +
      count(ancestor::LIST2) +
      count(ancestor::LIST3) + 
      count(ancestor::LIST4) + 
      count(ancestor::LIST5)  +
      count(ancestor::PRCITEM1)  +
      count(ancestor::PRCITEM2)  +
      count(ancestor::PRCITEM3)  +
      count(ancestor::PRCITEM4)  +
      count(ancestor::PRCITEM5)  +
      count(ancestor::PRCITEM6)  +
      count(ancestor::PRCITEM7)  +     
      count(ancestor::UNLIST) +
      count(ancestor::NUMLIST) ) "/>
    <!-- For debug -->
    <xsl:if test="false() and ancestor::GDESC">
      <xsl:message>Calculated table offset = -<xsl:value-of select="$offset"/>pt (ID="<xsl:value-of select="ancestor::TABLE/@ID"/>")</xsl:message>
    </xsl:if>
    
<xsl:choose>  
  <!--<xsl:when test="not(ancestor::GDESC)">-->
  <xsl:when test="((not(ancestor::GDESC)) and (not(contains(ancestor::TABLE[1]/@ID, 'check_point'))))">
    <xsl:value-of select="concat('-',$offset,'pt')"/>
  </xsl:when>
  <!-- Modified offset for tables in gdesc in mfmatr. Mantis #18789 -->
  <xsl:when test="ancestor::GDESC and ancestor::MFMATR">
    <xsl:message>GDESC in MFMATR - Calculated table offset = -<xsl:value-of select="$offset + 60"/>pt (ID="<xsl:value-of select="ancestor::TABLE/@ID"/>")</xsl:message>
    <xsl:value-of select="concat('-',$offset + 60,'pt')"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="'0pt'"/>
  </xsl:otherwise>
</xsl:choose>
  </xsl:template>
  



</xsl:stylesheet>
