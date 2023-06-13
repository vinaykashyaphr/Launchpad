<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xtbl="com.nwalsh.xalan.Table"
  xmlns:stbl="coms.nwalsh.xalan.Table" xmlns:lxslt="coml.nwalsh.xalan.Table"
  xmlns:rx="http://www.renderx.com/XSL/Extensions" exclude-result-prefixes="stbl xtbl lxslt"
  version="1.0">

  <!-- tbl-not-caps.xsl - transforms CALS tables into FOs. Called "tbl-not-caps" because the original ATA -->
  <!-- version made elements all caps (SGML-style). -->

  <xsl:param name="default.table.width" select="''"/>

  <xsl:param name="table.border.color" select="'black'"/>

  <xsl:param name="table.border.style" select="'solid'"/>

  <xsl:param name="table.border.thickness" select="'1.0pt'"/>


  <xsl:attribute-set name="table.cell.padding">
  	<!-- RS: Margins have no effect in table cells -->
    <!-- <xsl:attribute name="margin-left">2pt</xsl:attribute>
    <xsl:attribute name="margin-right">2pt</xsl:attribute> -->
    <xsl:attribute name="padding-left">4pt</xsl:attribute><!-- RS: Made padding left and right 4pt (from 2pt and none) -->
    <xsl:attribute name="padding-right">4pt</xsl:attribute>
    <xsl:attribute name="padding-top">.048in</xsl:attribute>
    <xsl:attribute name="padding-bottom">.023in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="default.table.cell"><!-- RS: not used -->

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
    <xsl:param name="cols" select="1"/>
    <xsl:if test="$cols &gt; 0">
      <xsl:text>0:</xsl:text>
      <xsl:call-template name="blank.spans">
        <xsl:with-param name="cols" select="$cols - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="calculate.following.spans">
    <xsl:param name="colspan" select="1"/>
    <xsl:param name="spans" select="''"/>

    <xsl:choose>
      <xsl:when test="$colspan &gt; 0">
        <xsl:call-template name="calculate.following.spans">
          <xsl:with-param name="colspan" select="$colspan - 1"/>
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
            <xsl:with-param name="colnum" select="$col"/>
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

  <xsl:template name="entry.colnum">
    <xsl:param name="entry" select="."/>

    <xsl:choose>
      <xsl:when test="$entry/@spanname">
        <xsl:variable name="spanname" select="$entry/@spanname"/>
        <xsl:variable name="spanspec" select="$entry/ancestor::spanspec[@spanname=$spanname]"/>
        <xsl:variable name="colspec"
          select="$entry/ancestor::tgroup/colspec[@colname=$spanspec/@namest]"/>
        <xsl:call-template name="colspec.colnum">
          <xsl:with-param name="colspec" select="$colspec"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/@colname">
        <xsl:variable name="colname" select="$entry/@colname"/>
        <xsl:variable name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$colname]"/>
        <xsl:call-template name="colspec.colnum">
          <xsl:with-param name="colspec" select="$colspec"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$entry/@namest">
        <xsl:variable name="namest" select="$entry/@namest"/>
        <xsl:variable name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$namest]"/>
        <xsl:call-template name="colspec.colnum">
          <xsl:with-param name="colspec" select="$colspec"/>
        </xsl:call-template>
      </xsl:when>
      <!-- no idea, return 0 -->
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="colspec.colnum">
    <xsl:param name="colspec" select="."/>
    <xsl:choose>
      <xsl:when test="$colspec/@colnum">
        <xsl:value-of select="$colspec/@colnum"/>
      </xsl:when>
      <xsl:when test="$colspec/preceding-sibling::colspec">
        <xsl:variable name="prec.colspec.colnum">
          <xsl:call-template name="colspec.colnum">
            <xsl:with-param name="colspec" select="$colspec/preceding-sibling::colspec[1]"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$prec.colspec.colnum + 1"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calculate.colspan">
    <xsl:param name="entry" select="."/>
    <xsl:variable name="spanname" select="$entry/@spanname"/>
    <xsl:variable name="spanspec" select="$entry/ancestor::tgroup/spanspec[@spanname=$spanname]"/>

    <xsl:variable name="namest">
      <xsl:choose>
        <xsl:when test="@spanname">
          <xsl:value-of select="$spanspec/@namest"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$entry/@namest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="nameend">
      <xsl:choose>
        <xsl:when test="@spanname">
          <xsl:value-of select="$spanspec/@nameend"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$entry/@nameend"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="scol">
      <xsl:call-template name="colspec.colnum">
        <xsl:with-param name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$namest]"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="ecol">
      <xsl:call-template name="colspec.colnum">
        <xsl:with-param name="colspec" select="$entry/ancestor::tgroup/colspec[@colname=$nameend]"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$namest != '' and $nameend != ''">
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

  <xsl:template name="calculate.rowsep">
    <xsl:param name="entry" select="."/>
    <xsl:param name="colnum" select="0"/>

    <xsl:call-template name="inherited.table.attribute">
      <xsl:with-param name="entry" select="$entry"/>
      <xsl:with-param name="colnum" select="$colnum"/>
      <xsl:with-param name="attribute" select="'rowsep'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="calculate.colsep">
    <xsl:param name="entry" select="."/>
    <xsl:param name="colnum" select="0"/>

    <xsl:call-template name="inherited.table.attribute">
      <xsl:with-param name="entry" select="$entry"/>
      <xsl:with-param name="colnum" select="$colnum"/>
      <xsl:with-param name="attribute" select="'colsep'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="inherited.table.attribute">
    <xsl:param name="entry" select="."/>
    <xsl:param name="row" select="$entry/ancestor-or-self::row[1]"/>
    <xsl:param name="colnum" select="0"/>
    <xsl:param name="attribute" select="'colsep'"/>
    <xsl:param name="lastrow" select="0"/>
    <xsl:param name="lastcol" select="0"/>

    <xsl:variable name="tgroup" select="$row/ancestor::tgroup[1]"/>

    <xsl:variable name="entry.value">
      <xsl:call-template name="get-attribute">
        <xsl:with-param name="element" select="$entry"/>
        <xsl:with-param name="attribute" select="$attribute"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="row.value">
      <xsl:call-template name="get-attribute">
        <xsl:with-param name="element" select="$row"/>
        <xsl:with-param name="attribute" select="$attribute"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="span.value">
      <xsl:if test="$entry/@spanname">
        <xsl:variable name="spanname" select="$entry/@spanname"/>
        <xsl:variable name="spanspec" select="$tgroup/spanspec[@spanname=$spanname]"/>
        <xsl:variable name="span.colspec" select="$tgroup/colspec[@colname=$spanspec/@namest]"/>

        <xsl:variable name="spanspec.value">
          <xsl:call-template name="get-attribute">
            <xsl:with-param name="element" select="$spanspec"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="sCOLSPEC.value">
          <xsl:call-template name="get-attribute">
            <xsl:with-param name="element" select="$span.colspec"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$spanspec.value != ''">
            <xsl:value-of select="$spanspec.value"/>
          </xsl:when>
          <xsl:when test="$sCOLSPEC.value != ''">
            <xsl:value-of select="$sCOLSPEC.value"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="namest.value">
      <xsl:if test="$entry/@namest">
        <xsl:variable name="namest" select="$entry/@namest"/>
        <xsl:variable name="colspec" select="$tgroup/colspec[@colname=$namest]"/>

        <xsl:variable name="namest.value">
          <xsl:call-template name="get-attribute">
            <xsl:with-param name="element" select="$colspec"/>
            <xsl:with-param name="attribute" select="$attribute"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$namest.value">
            <xsl:value-of select="$namest.value"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="tgroup.value">
      <xsl:call-template name="get-attribute">
        <xsl:with-param name="element" select="$tgroup"/>
        <xsl:with-param name="attribute" select="$attribute"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="default.value">
      <!-- rowsep and colsep can have defaults on the "table" wrapper and 
        ultimately on the frame setting for outside rules -->
      <!-- handle those here, for everything else, the default is the tgroup value -->
      <xsl:choose>
        <xsl:when test="$tgroup.value != ''">
          <xsl:value-of select="$tgroup.value"/>
        </xsl:when>
        <xsl:when test="$attribute = 'rowsep'">
          <xsl:choose>
            <xsl:when test="$tgroup/parent::*/@rowsep">
              <xsl:value-of select="$tgroup/parent::*/@rowsep"/>
            </xsl:when>
            <!-- RS: When no frame specified on table, the default is to add a rowsep, except for the Record of Temporary Revisions (pmt54) and Service Bulletin (pmt55) -->
            <xsl:when test="not($tgroup/parent::*/@frame) and not(ancestor::pmEntry[@pmEntryType='pmt54'] or ancestor::pmEntry[@pmEntryType='pmt55'])">
              <!-- default frame is equivalent to 'all' -->
              <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$tgroup/parent::*/@frame = 'all'">
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
        <xsl:when test="$attribute = 'colsep'">
          <xsl:choose>
            <xsl:when test="$tgroup/parent::*/@colsep">
              <xsl:value-of select="$tgroup/parent::*/@colsep"/>
            </xsl:when>
            <!-- RS: When no frame specified on table, the default is to add a colsep, except for the Record of Temporary Revisions (pmt54) and Service Bulletin (pmt55) -->
            <xsl:when test="not($tgroup/parent::*/@frame) and not(ancestor::pmEntry[@pmEntryType='pmt54'] or ancestor::pmEntry[@pmEntryType='pmt55'])">
              <!-- default frame is equivalent to 'all' -->
              <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$tgroup/parent::*/@frame = 'all'">
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
      <xsl:when test="$entry.value != ''">
        <xsl:value-of select="$entry.value"/>
      </xsl:when>
      <xsl:when test="$row.value != ''">
        <xsl:value-of select="$row.value"/>
      </xsl:when>
      <xsl:when test="$span.value != ''">
        <xsl:value-of select="$span.value"/>
      </xsl:when>
      <xsl:when test="$namest.value != ''">
        <xsl:value-of select="$namest.value"/>
      </xsl:when>
      <xsl:when test="$colnum &gt; 0">
        <xsl:variable name="calc.colvalue">
          <xsl:call-template name="colnum.colspec">
            <xsl:with-param name="colnum" select="$colnum"/>
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

  <xsl:template name="colnum.colspec">
    <xsl:param name="colnum" select="0"/>
    <xsl:param name="attribute" select="'colname'"/>
    <xsl:param name="COLSPECs" select="ancestor::tgroup/colspec"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="not($COLSPECs) or $count &gt; $colnum">
        <!-- nop -->
      </xsl:when>
      <xsl:when test="$COLSPECs[1]/@colnum">
        <xsl:choose>
          <xsl:when test="$COLSPECs[1]/@colnum = $colnum">
            <xsl:call-template name="get-attribute">
              <xsl:with-param name="element" select="$COLSPECs[1]"/>
              <xsl:with-param name="attribute" select="$attribute"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="colnum.colspec">
              <xsl:with-param name="colnum" select="$colnum"/>
              <xsl:with-param name="attribute" select="$attribute"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs[position()&gt;1]"/>
              <xsl:with-param name="count" select="$COLSPECs[1]/@colnum+1"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$count = $colnum">
            <xsl:call-template name="get-attribute">
              <xsl:with-param name="element" select="$COLSPECs[1]"/>
              <xsl:with-param name="attribute" select="$attribute"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="colnum.colspec">
              <xsl:with-param name="colnum" select="$colnum"/>
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
    <xsl:param name="colnum" select="0"/>

    <xsl:variable name="lastrow">
      <xsl:choose>
        <xsl:when test="ancestor::thead">0</xsl:when>
        <xsl:when test="ancestor::tfoot
          and not(ancestor::row/following-sibling::row)"
          >1</xsl:when>
        <xsl:when test="not(ancestor::tfoot)
          and ancestor::tgroup/tfoot">0</xsl:when>
        <xsl:when
          test="not(ancestor::tfoot)
          and not(ancestor::tgroup/tfoot)
          and not(ancestor::row/following-sibling::row)"
          >1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="lastcol">
      <xsl:choose>
        <xsl:when test="$colnum &lt; ancestor::tgroup/@cols">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rowsep">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="NOT-AN-ELEMENT-NAME"/>
        <xsl:with-param name="row" select="ancestor-or-self::row[1]"/>
        <xsl:with-param name="colnum" select="$colnum"/>
        <xsl:with-param name="attribute" select="'rowsep'"/>
        <xsl:with-param name="lastrow" select="$lastrow"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="colsep">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="NOT-AN-ELEMENT-NAME"/>
        <xsl:with-param name="row" select="ancestor-or-self::row[1]"/>
        <xsl:with-param name="colnum" select="$colnum"/>
        <xsl:with-param name="attribute" select="'colsep'"/>
        <xsl:with-param name="lastrow" select="$lastrow"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <fo:table-cell text-align="center" display-align="center"
      xsl:use-attribute-sets="table.cell.padding">
      <!-- <xsl:call-template name="ENTRY"/> --> <!-- RS: This was in shared/standardVariables.xsl. It over-rides the cell-padding, so removed for now -->

      <xsl:if test="$rowsep &gt; 0">
        <xsl:call-template name="border">
          <xsl:with-param name="side" select="'bottom'"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="$colsep &gt; 0">
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
    <xsl:param name="style"/>

    <!-- Maybe set border thickness from PubTbl PI -->
    <xsl:variable name="border-thickness">
      <xsl:choose>
        <xsl:when
          test="ancestor-or-self::tgroup[1]/processing-instruction('PubTbl')[starts-with(.,'tgroup') and contains(.,' rth=')]">
          <xsl:variable name="rth-pi"
            select="ancestor-or-self::tgroup[1]/processing-instruction('PubTbl')[starts-with(.,'tgroup') and contains(.,' rth=')]"/>
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
    <xsl:choose>
    	<xsl:when test="$style">
		    <xsl:attribute name="border-{$side}-style">
		      <xsl:value-of select="$style"/>
		    </xsl:attribute>
    	</xsl:when>
    	<xsl:otherwise>
		    <xsl:attribute name="border-{$side}-style">
		      <xsl:value-of select="$table.border.style"/>
		    </xsl:attribute>
    	</xsl:otherwise>
    </xsl:choose>
    
    <xsl:attribute name="border-{$side}-color">
      <xsl:value-of select="$table.border.color"/>
    </xsl:attribute>
  </xsl:template>


  <xsl:template name="foldout-table">
    <!--CLOSE ORIGINAL PAGE SEQUENCE-->
    <xsl:variable name="page-prefix">
      <xsl:choose>
        <xsl:when test="number(ancestor-or-self::PGBLK/@PGBLKNBR) = 0">
          <xsl:text>INTRO-</xsl:text>
        </xsl:when>
        <xsl:when test="number(ancestor-or-self::PGBLK/@PGBLKNBR) >= 17000">
          <xsl:call-template name="calculateCMMAppendixNumber"/>
          <xsl:text>-</xsl:text>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:message>FOLDOUT TABLE IN <xsl:value-of select="name(parent::*)"/> (in <xsl:value-of
        select="name(parent::*/parent::*)"/>)!!</xsl:message>
    <!--CLOSE ORIGINAL PAGE SEQUENCE-->
    <xsl:choose>
      <!-- <xsl:when test="ancestor::PRCITEM1">
        <xsl:text disable-output-escaping="yes">
              <![CDATA[
                          </fo:block>
                        </fo:list-item-body>
                      </fo:list-item>
                    </fo:list-block>
                  </fo:block>
                </fo:flow>
              </fo:page-sequence>]]>              
            </xsl:text>
      </xsl:when>-->
      <xsl:when test="ancestor::levelledPara"><!-- [count(ancestor::levelledPara)=1] -->
        <xsl:text disable-output-escaping="yes">
              <![CDATA[
                          </fo:block>
                        </fo:list-item-body>
                      </fo:list-item>
                    </fo:list-block>
                  </fo:block>
                  </fo:block></fo:block></fo:block>
                </fo:flow>
              </fo:page-sequence>]]>              
            </xsl:text>
      </xsl:when>
      <!-- <xsl:when test="ancestor::levelledPara[count(ancestor::levelledPara)=3]">
        <xsl:text disable-output-escaping="yes">
              <![CDATA[
                          </fo:block>
                        </fo:list-item-body>
                      </fo:list-item>
                    </fo:list-block>
                  </fo:block>
                  </fo:block></fo:block></fo:block>
                </fo:flow>
              </fo:page-sequence>]]>              
            </xsl:text>
      </xsl:when> -->
      <xsl:when test="ancestor::proceduralStep[count(ancestor::proceduralStep)=2]">
        <xsl:text disable-output-escaping="yes">
              <![CDATA[
                          </fo:block>
                        </fo:list-item-body>
                      </fo:list-item>
                    </fo:list-block>
                  </fo:block>
                  </fo:block></fo:block></fo:block></fo:block></fo:block><!-- added for the extra proceduralStep levels -->
                </fo:flow>
              </fo:page-sequence>]]>              
            </xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::proceduralStep[count(ancestor::proceduralStep)=1]">
        <xsl:text disable-output-escaping="yes">
              <![CDATA[
                          </fo:block>
                        </fo:list-item-body>
                      </fo:list-item>
                    </fo:list-block>
                  </fo:block>
                  </fo:block></fo:block></fo:block></fo:block><!-- added for the extra proceduralStep levels -->
                </fo:flow>
              </fo:page-sequence>]]>              
            </xsl:text>
      </xsl:when>
    </xsl:choose>
    <!--OPEN/CLOSE NEW PAGE SEQUENCE WITH APPLY-TEMPLATES OUTPUT INSIDE-->
    <!--<xsl:processing-instruction name="ITG">START OF FOLDOUT TABLE PAGE-SEQUENCE</xsl:processing-instruction>-->
    <fo:page-sequence master-reference="Foldout" font-family="Arial" font-size="10pt"
      force-page-count="even" initial-page-number="auto-odd">
      <fo:static-content flow-name="Foldout_Odd_Page_regionbefore">
        <xsl:call-template name="draft-as-of"/>
        <xsl:call-template name="oddPageRegionBeforeStaticContent">
          <!--<xsl:with-param name="right-margin" select="'8.5in'"/>-->
          <xsl:with-param name="isFoldout" select="1"/>
          <xsl:with-param name="isTableFoldout" select="1"/>
        </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Foldout_Odd_Page_regionafter">
        <xsl:call-template name="effectivity-footer">
          <xsl:with-param name="page-prefix" select="$page-prefix"/>
          <xsl:with-param name="isFoldout" select="1"/>
        </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Foldout_Even_Page_regionbefore">
        <xsl:call-template name="evenPageRegionBeforeStaticContent">
          <xsl:with-param name="isFoldout" select="1"/>
          <xsl:with-param name="isTableFoldout" select="1"/>
        </xsl:call-template>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>
      <fo:static-content flow-name="Foldout_Even_Page_regionafter">
        <xsl:call-template name="effectivity-footer">
          <xsl:with-param name="page-prefix" select="$page-prefix"/>
          <xsl:with-param name="isFoldout" select="1"/>
        </xsl:call-template>
        <fo:block/>
      </fo:static-content>
      <fo:flow flow-name="xsl-region-body">
		<!-- Add marker for the section title in the footer (called "confnbrValue" as in the original ATA FO) -->
		<!-- and the section enumerator (from @confnbr added by the pre-process). -->
		<!-- UPDATE: Not for EIPC. -->
		<!-- UPDATE: Not applicable for 3-level PMC -->
		<xsl:if test="not($documentType='eipc') and $isNewPmc">
            <fo:block>
              <fo:marker marker-class-name="confnbrValue">
                <xsl:message>Adding confnbrValue for foldout figure: "<xsl:value-of select="ancestor::pmEntry[count(ancestor::pmEntry)=3]/pmEntryTitle"/>"</xsl:message>
                <xsl:apply-templates select="ancestor::pmEntry[count(ancestor::pmEntry)=3]/pmEntryTitle" mode="pgblkConf"/>
                <xsl:if test="ancestor::pmEntry/@confnbr">
                  <xsl:value-of select="concat('-',ancestor::pmEntry/@confnbr)"/>
                </xsl:if>
              </fo:marker>
			</fo:block>
		</xsl:if>
        <fo:block margin-left="-.875in">
          <xsl:call-template name="save-revdate"/>
          <!-- This marker is used to get the correct page number in the footer -->
          <fo:marker marker-class-name="foldout-page-string">
            <xsl:value-of select="$page-prefix"/>
            <fo:page-number/>
            <xsl:text>/TFP</xsl:text>
          </fo:marker>
          <fo:block id="{concat(ancestor-or-self::table/@ID,'ITG_TABLE_FOLDOUT')}"><!-- keep-together.within-page="always" -->
            <xsl:choose>
              <xsl:when
                test="ancestor-or-self::table[preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']]">
                <xsl:call-template name="cbStart"/>
              </xsl:when>
			  <xsl:when test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
				<xsl:call-template name="cbStart" />
			  </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="check-rev-start"/>
              </xsl:otherwise>
            </xsl:choose>
            <!-- Added effectivity markers. (Mantis #17829) -->
            <xsl:choose>
              <xsl:when test="parent::GRAPHIC/EFFECT">
                <fo:block>
                  <fo:marker marker-class-name="efftextValue">
                    <xsl:value-of select="parent::GRAPHIC/EFFECT"/>
                  </fo:marker>
                </fo:block>
              </xsl:when>
              <xsl:when test="EFFECT">
                <fo:block>
                  <fo:marker marker-class-name="efftextValue">
                    <xsl:value-of select="EFFECT"/>
                  </fo:marker>
                </fo:block>
              </xsl:when>
              <xsl:otherwise>
                <fo:block>
                  <!-- Need a default 'All' or the effectivity in the foldout will be blank. -->
                  <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
                </fo:block>
              </xsl:otherwise>
            </xsl:choose>
            <!--<xsl:processing-instruction name="ITG">START OF FOLDOUT TABLE</xsl:processing-instruction>-->
            <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
            <!--<xsl:processing-instruction name="ITG">END OF FOLDOUT TABLE</xsl:processing-instruction>-->
            <!-- CHECK REVEND HERE -->
            <xsl:choose>
              <xsl:when
                test="ancestor-or-self::table[following-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '/_rev']]">
                <xsl:call-template name="cbEnd"/>
              </xsl:when>
			  <xsl:when test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
				<xsl:call-template name="cbEnd" />
			  </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="check-rev-end"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </fo:block>
      </fo:flow>
    </fo:page-sequence>
    <!--<xsl:processing-instruction name="ITG">END OF FOLDOUT TABLE PAGE-SEQUENCE</xsl:processing-instruction>-->
    <!--REOPEN THE ORIGINAL PAGE SEQUENCE-->
    <xsl:choose>
      <!--  <xsl:when test="ancestor::PRCITEM1"> -->
      <xsl:when test="ancestor::proceduralStep or ancestor::levelledPara">
      
<!--        <xsl:message>
              <xsl:text>CJ TEST next page-sequence is because of </xsl:text>
              <xsl:value-of select="following::*[name()='PGBLK' or (name()='TABLE' and (@orient='land' or @tabstyle='hl'))][1]/name()"/>
            </xsl:message>-->
        <!-- CJM : OCSHONSS-499 : Added Check for following Landscape Tables
      Because of the CDATA hack, it can throw off the page numbers.
      If a Landscape table is detected as the next node that creates a page-sequence, then no force-page-count will be added
      For IPL, PGBLK, or Foldout Tables, force-page-count="end-on-even" is needed -->
        <xsl:choose>
          <xsl:when test="not(following::*[name()='IPL' or name()='PGBLK' or (name()='table' and (@orient='land' or @tabstyle='hl'))][1]/(name()='table' and @orient='land'))">
            <xsl:message><xsl:text>Next page-sequence IS NOT a landscape table</xsl:text></xsl:message>
            <xsl:text disable-output-escaping="yes">
              <![CDATA[<fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="end-on-even">]]>
            </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message><xsl:text>Next page-sequence IS a landscape table</xsl:text></xsl:message>
            <xsl:text disable-output-escaping="yes">
              <![CDATA[<fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt">]]>
            </xsl:text>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="init-static-content">
          <xsl:with-param name="page-prefix" select="$page-prefix"/>
          <!--<xsl:with-param name="page-suffix" select="$page-suffix" />-->
        </xsl:call-template>
        <xsl:text disable-output-escaping="yes">
              <![CDATA[
              <fo:flow flow-name="xsl-region-body">
              ]]>
            </xsl:text>
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
        <!-- CJM : OCSHONSS-482 : Added block for save-revdate and ftnote (This might need to be revisited...) -->
        <fo:block>
          <xsl:call-template name="save-revdate"/>
          <!--<xsl:apply-templates select="*[not(name()='FTNOTE')]"/>-->
          <!-- CJM : OCSHONSS-482 : This line was causing the next page to show the table as well -->
        </fo:block>
        <!-- <xsl:text disable-output-escaping="yes">
              <![CDATA[
                <fo:block>
                  <fo:list-block>
                    <fo:list-item>
                      <fo:list-item-label end-indent="label-end()">
                        <fo:block/>
                      </fo:list-item-label>
                      <fo:list-item-body start-indent="body-start()">
                        <fo:block>***DELETE THIS LIST-BLOCK***
              ]]>
            </xsl:text> -->
        <xsl:choose>
        
        	<xsl:when test="ancestor::levelledPara"><!-- count(ancestor::levelledPara)=4 -->
		        <xsl:text disable-output-escaping="yes">
		              <![CDATA[
		                <fo:block>
		                  <fo:block><fo:block><fo:block>
		                  <fo:list-block>
		                    <fo:list-item>
		                      <fo:list-item-label end-indent="label-end()">
		                        <fo:block/>
		                      </fo:list-item-label>
		                      <fo:list-item-body start-indent="body-start()">
		                        <fo:block>***DELETE THIS LIST-BLOCK***
		              ]]>
		        </xsl:text>
        	</xsl:when>
        	<!-- <xsl:when test="count(ancestor::levelledPara)=2">
		        <xsl:text disable-output-escaping="yes">
		              <![CDATA[
		                <fo:block>
		                  <fo:block><fo:block><fo:block>
		                  <fo:list-block>
		                    <fo:list-item>
		                      <fo:list-item-label end-indent="label-end()">
		                        <fo:block/>
		                      </fo:list-item-label>
		                      <fo:list-item-body start-indent="body-start()">
		                        <fo:block>***DELETE THIS LIST-BLOCK***
		              ]]>
		        </xsl:text>
        	</xsl:when> -->
        	<xsl:when test="count(ancestor::proceduralStep)=3">
		        <xsl:text disable-output-escaping="yes">
		              <![CDATA[
		                <fo:block>
		                  <fo:block><fo:block><fo:block><fo:block><fo:block>
		                  <fo:list-block>
		                    <fo:list-item>
		                      <fo:list-item-label end-indent="label-end()">
		                        <fo:block/>
		                      </fo:list-item-label>
		                      <fo:list-item-body start-indent="body-start()">
		                        <fo:block>***DELETE THIS LIST-BLOCK***
		              ]]>
		        </xsl:text>
        	</xsl:when>
        	<xsl:when test="count(ancestor::proceduralStep)=2">
		        <xsl:text disable-output-escaping="yes">
		              <![CDATA[
		                <fo:block>
		                  <fo:block><fo:block><fo:block><fo:block>
		                  <fo:list-block>
		                    <fo:list-item>
		                      <fo:list-item-label end-indent="label-end()">
		                        <fo:block/>
		                      </fo:list-item-label>
		                      <fo:list-item-body start-indent="body-start()">
		                        <fo:block>***DELETE THIS LIST-BLOCK***
		              ]]>
		        </xsl:text>
        	</xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- This template is called during the normal processing of the instance, and  -->
  <!-- inserts the placeholder pages in the xsl:fo output to maintain correct page numbers -->
  <!--NEEDED TO ADD REVBARS SO ASTERISKS IN LEP WOULD WORK-->
  <xsl:template name="foldout-table-orig">
    <!-- The first page of the foldout sequence -->
    <xsl:variable name="replace-page-1" select="concat(@ID,'-r1')"/>
    <xsl:variable name="replace-page-2" select="concat(@ID,'-r2')"/>
    <fo:block break-before="odd-page" start-indent="12pt" end-indent="12pt" font-weight="bold"
      font-size="16pt" border="black solid 2pt" padding="12pt" text-align="center">
      <xsl:attribute name="id">
        <xsl:value-of select="$replace-page-1"/>
      </xsl:attribute>
      <xsl:call-template name="check-rev-start"/>
      <fo:table rx:table-omit-initial-header="true" background="#f0f0f0"
        id="{concat('foldout_key_',@ID)}">
        <fo:table-column column-width="100%"/>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell padding-before="2in" padding-after="2in" id="ITG_TABLE_FOLDOUT">
              <fo:block>
                <fo:inline>1st REPLACEMENT PAGE PLACEHOLDER <xsl:value-of
                    select="concat('ID: ',$replace-page-1)"/></fo:inline>
              </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
      <xsl:call-template name="check-rev-end"/>
    </fo:block>
    <!-- The second page used to keep the numbering correct -->
    <fo:block break-before="even-page" start-indent="12pt" end-indent="12pt" font-weight="bold"
      font-size="16pt" border="black solid 2pt" padding="12pt" text-align="center">
      <xsl:attribute name="id">
        <xsl:value-of select="$replace-page-2"/>
      </xsl:attribute>
      <fo:table rx:table-omit-initial-header="true" background="#f0f0f0">
        <fo:table-column column-width="100%"/>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell padding-before="2in" padding-after="2in" id="ITG_NO_COPY">
              <fo:block>
                <fo:inline>2nd REPLACEMENT PAGE PLACEHOLDER <xsl:value-of
                    select="concat('ID: ',$replace-page-2)"/></fo:inline>
              </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="table" name="table">
    <!-- <xsl:message>Processing table; id: <xsl:value-of select="@id"/></xsl:message> -->
    <xsl:choose>
      <!-- ATA FO used @tabstyle='hl' for table foldouts. We'll ignore that for now and just use the -->
      <!-- parent foldout element to trigger table foldouts. -->
      <xsl:when test="parent::foldout"><!-- or @tabstyle='hl' -->
        <!--<fo:block break-after="even-page"/>-->
        <xsl:call-template name="foldout-table"/>
      </xsl:when>
      <xsl:when test="@orient='land'">
        <xsl:variable name="page-prefix">
          <xsl:choose>
            <xsl:when test="number(ancestor-or-self::PGBLK/@PGBLKNBR) = 0">
              <xsl:text>INTRO-</xsl:text>
            </xsl:when>
            <xsl:when test="number(ancestor-or-self::PGBLK/@PGBLKNBR) >= 17000">
              <xsl:call-template name="calculateCMMAppendixNumber"/>
              <xsl:text>-</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:variable>
        <!-- CJM : OCSHONSS-499 : Re-added CDATA Hack for Landscape Tables -->
        <xsl:message>LANDSCAPE TABLE IN <xsl:value-of select="name(parent::*)"/> (in <xsl:value-of select="name(parent::*/parent::*)"/>)!!</xsl:message>
        <!--CLOSE ORIGINAL PAGE SEQUENCE-->
        <xsl:choose>
	      <xsl:when test="ancestor::proceduralStep[count(ancestor::proceduralStep)=2]">
	        <xsl:text disable-output-escaping="yes">
	              <![CDATA[
	                          </fo:block>
	                        </fo:list-item-body>
	                      </fo:list-item>
	                    </fo:list-block>
	                  </fo:block>
	                  </fo:block></fo:block></fo:block></fo:block></fo:block><!-- added for the extra proceduralStep levels -->
	                </fo:flow>
	              </fo:page-sequence>]]>              
	            </xsl:text>
	      </xsl:when>
	      <xsl:when test="ancestor::proceduralStep[count(ancestor::proceduralStep)=1]">
	        <xsl:text disable-output-escaping="yes">
	              <![CDATA[
	                          </fo:block>
	                        </fo:list-item-body>
	                      </fo:list-item>
	                    </fo:list-block>
	                  </fo:block>
	                  </fo:block></fo:block></fo:block></fo:block><!-- added for the extra proceduralStep levels -->
	                </fo:flow>
	              </fo:page-sequence>]]>              
	            </xsl:text>
	      </xsl:when>
        </xsl:choose>
        <!--OPEN/CLOSE NEW PAGE SEQUENCE WITH APPLY-TEMPLATES OUTPUT INSIDE-->
        <fo:page-sequence master-reference="Landscape-Table" font-family="Arial" font-size="10pt"><!-- CJM : OCSHONSS-359 : Removed 'force-page-count="even"' -->
          <xsl:call-template name="init-static-content">
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
            <!--<xsl:with-param name="page-suffix" select="$page-suffix" />-->
          </xsl:call-template>
          <!--<xsl:processing-instruction name="ITG">START OF LANDSCAPE TABLE</xsl:processing-instruction>-->
          <fo:flow flow-name="xsl-region-body">
            <xsl:choose>
              <xsl:when test="EFFECT">
                <fo:block>
                  <fo:marker marker-class-name="efftextValue"><xsl:value-of select="EFFECT"/></fo:marker>
                </fo:block>
              </xsl:when>
              <xsl:otherwise>
                <fo:block>
                  <fo:marker marker-class-name="efftextValue"><xsl:value-of select="'ALL'"/></fo:marker>
                </fo:block>
              </xsl:otherwise>
            </xsl:choose>
            <fo:block>
              <xsl:call-template name="save-revdate"/>
              <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
            </fo:block>            
          </fo:flow>
          <!--<xsl:processing-instruction name="ITG">END OF LANDSCAPE TABLE</xsl:processing-instruction>-->
        </fo:page-sequence>  
        <!--REOPEN THE ORIGINAL PAGE SEQUENCE-->
        <xsl:choose>
          <!-- <xsl:when test="ancestor::PRCITEM1"> -->
          <xsl:when test="ancestor::proceduralStep or ancestor::levelledPara">
          	<!-- TODO: Add support for levelledPara context... -->
            <!--<xsl:message>
              <xsl:text>CJ TEST next page-sequence is because of </xsl:text>
              <xsl:value-of select="following::*[name()='PGBLK' or (name()='TABLE' and (@orient='land' or @tabstyle='hl'))][1]/name()"/>
            </xsl:message>-->
            <!-- CJM : OCSHONSS-499 : Added Check for following Landscape Tables
      Because of the CDATA hack, it can throw off the page numbers.
      If a Landscape table is detected as the next node that creates a page-sequence, the no force-page-count will be added
      For IPL, PGBLK, or Foldout Tables, force-page-count="end-on-even" is needed -->
            <xsl:choose>
              <xsl:when test="not(following::*[name()='IPL' or name()='PGBLK' or (name()='table' and (@orient='land' or @tabstyle='hl'))][1]/(name()='table' and @orient='land'))">
                <xsl:message><xsl:text>Next page-sequence IS NOT a landscape table</xsl:text></xsl:message>
                <xsl:text disable-output-escaping="yes">
                  <![CDATA[<fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" force-page-count="end-on-even">]]>
                </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message><xsl:text>Next page-sequence IS a landscape table</xsl:text></xsl:message>
                <xsl:text disable-output-escaping="yes">
                  <![CDATA[<fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt">]]>
                </xsl:text>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="init-static-content">
              <xsl:with-param name="page-prefix" select="$page-prefix"/>
              <!--<xsl:with-param name="page-suffix" select="$page-suffix" />-->
            </xsl:call-template>            
            <xsl:text disable-output-escaping="yes">
              <![CDATA[
              <fo:flow flow-name="xsl-region-body">
              ]]>
            </xsl:text>
            <xsl:choose>
              <xsl:when test="EFFECT">
                <fo:block>
                  <fo:marker marker-class-name="efftextValue"><xsl:value-of select="EFFECT"/></fo:marker>
                </fo:block>
              </xsl:when>
              <xsl:otherwise>
                <fo:block>
                  <fo:marker marker-class-name="efftextValue"><xsl:value-of select="'ALL'"/></fo:marker>
                </fo:block>
              </xsl:otherwise>
            </xsl:choose>
            <!-- CJM : OCSHONSS-482 : Added block for save-revdate and ftnote (This might need to be revisited...) -->
            <fo:block>
              <xsl:call-template name="save-revdate"/>
              <!--<xsl:apply-templates select="*[not(name()='FTNOTE')]"/>--><!-- CJM : OCSHONSS-482 : This line was causing the next page to show the table as well -->
            </fo:block>    
            <!-- <xsl:text disable-output-escaping="yes">
              <![CDATA[
                <fo:block>
                  <fo:list-block>
                    <fo:list-item>
                      <fo:list-item-label end-indent="label-end()">
                        <fo:block/>
                      </fo:list-item-label>
                      <fo:list-item-body start-indent="body-start()">
                        <fo:block>***DELETE THIS LIST-BLOCK***
              ]]>
            </xsl:text> -->
	        <xsl:choose>
	        	<xsl:when test="count(ancestor::proceduralStep)=3">
			        <xsl:text disable-output-escaping="yes">
			              <![CDATA[
			                <fo:block>
			                  <fo:block><fo:block><fo:block><fo:block><fo:block>
			                  <fo:list-block>
			                    <fo:list-item>
			                      <fo:list-item-label end-indent="label-end()">
			                        <fo:block/>
			                      </fo:list-item-label>
			                      <fo:list-item-body start-indent="body-start()">
			                        <fo:block>***DELETE THIS LIST-BLOCK***
			              ]]>
			        </xsl:text>
	        	</xsl:when>
	        	<xsl:when test="count(ancestor::proceduralStep)=2">
			        <xsl:text disable-output-escaping="yes">
			              <![CDATA[
			                <fo:block>
			                  <fo:block><fo:block><fo:block><fo:block>
			                  <fo:list-block>
			                    <fo:list-item>
			                      <fo:list-item-label end-indent="label-end()">
			                        <fo:block/>
			                      </fo:list-item-label>
			                      <fo:list-item-body start-indent="body-start()">
			                        <fo:block>***DELETE THIS LIST-BLOCK***
			              ]]>
			        </xsl:text>
	        	</xsl:when>
	        </xsl:choose>
            
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table" mode="foldout">
    <xsl:message>Matched table mode "foldout".</xsl:message>
    <xsl:variable name="foldout-key" select="concat('foldout_key_',@ID)"/>
    <xsl:variable name="replace-page-1" select="concat(@ID,'-r1')"/>
    <xsl:variable name="replace-page-2" select="concat(@ID,'-r2')"/>
    <fo:block break-before="odd-page" id="{$foldout-key}" margin-left="-.875in">
      <!-- margin-left="-3.33in" Margin left?? Remove or add negative margin-right?? Tables are in different prcitems!! (C15... file and converted_D2011... file)-->
      <!-- This marker is used to get the correct page number in the footer -->
      <fo:marker marker-class-name="foldout-page-string">
        <fo:inline>
          <!--<fo:page-number-citation ref-id="{$replace-page-1}"/>
             <xsl:text>/</xsl:text>
             <fo:page-number-citation ref-id="{$replace-page-2}"/>-->
          <xsl:text>TFP/TFP</xsl:text>
        </fo:inline>
      </fo:marker>
      <fo:block keep-together.within-page="always">
        <!-- text-align="center" padding="0pt" rx:key=""-->
        <xsl:if test="./@ID">
          <xsl:attribute name="id">
            <xsl:value-of select="./@ID"/>
          </xsl:attribute>
        </xsl:if>
        <!--<fo:block space-before.optimum="6pt">&#160;</fo:block>-->
        <!-- CHECK REVST HERE -->
        <xsl:choose>
          <xsl:when
            test="ancestor-or-self::table[preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']]">
            <xsl:call-template name="cbStart"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="check-rev-start"/>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Added effectivity markers. (Mantis #17829) -->
        <xsl:choose>
          <xsl:when test="parent::GRAPHIC/EFFECT">
            <fo:block>
              <fo:marker marker-class-name="efftextValue">
                <xsl:value-of select="parent::GRAPHIC/EFFECT"/>
              </fo:marker>
            </fo:block>
          </xsl:when>
          <xsl:when test="EFFECT">
            <fo:block>
              <fo:marker marker-class-name="efftextValue">
                <xsl:value-of select="EFFECT"/>
              </fo:marker>
            </fo:block>
          </xsl:when>
          <xsl:otherwise>
            <fo:block>
              <!-- Need a default 'All' or the effectivity in the foldout will be blank. -->
              <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
            </fo:block>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
        <!-- CHECK REVEND HERE -->
        <xsl:choose>
          <xsl:when
            test="ancestor-or-self::table[following-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '/_rev']]">
            <xsl:call-template name="cbEnd"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="check-rev-end"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:block>
    <!--<fo:block font-size="8pt" break-after="page" margin-top="-.5in" margin-left="-.5in" keep-with-previous.within-page="always" id="{$foldout-key}"/>-->
  </xsl:template>

  <xsl:template match="tgroup">
    <!-- HT Outer fo:table is used to handle repeating the table header on subsequent pages -->

    <!-- xsl:call-template name="table-data"/ -->
    <xsl:variable name="table-offset">
      <xsl:call-template name="calculateTableOffset"/>
    </xsl:variable>

    <xsl:variable name="table-title">
      <xsl:call-template name="get-table-title"/>
    </xsl:variable>

    <xsl:variable name="revised-title">
      <xsl:for-each select="preceding-sibling::title">
        <xsl:choose>
		  <xsl:when test="not(@changeMark='0') and (@changeType='add' or @changeType='modify')">
            <xsl:text>true</xsl:text>
		  </xsl:when>
		  
		  <!-- [ATA]
          <xsl:when test="preceding-sibling::node()[1][.='_rev']  and following-sibling::node()[1][.='/_rev']">
            <xsl:text>true</xsl:text>
          </xsl:when>
          
          [ Changes made by Nathan for revbar issue ]
          <xsl:when test="./preceding-sibling::processing-instruction('Pub')[. = '_rev'] and following-sibling::processing-instruction('Pub')[. = '/_rev']">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:when test="descendant::processing-instruction() = '_rev'">
            <xsl:text>true</xsl:text>
          </xsl:when> -->
          <!-- End of changes made by Nathan -->
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <!-- CJM : OCSHONSS-488 : added 'space-after.minimum=".1in"' -->
	<!-- RS: Added start-indent="0in" for S1000D -->
    <!-- <fo:block space-after.minimum=".1in" space-before.optimum="8pt" start-indent="0in">-->
    <fo:block><!-- start-indent="0in" space-before="{$normalParaSpace}" space-after="{$normalParaSpace}" -->
      <xsl:if test="not(parent::table/@tabstyle='follow-indent' or parent::table/@pgwide='0')">
      	<xsl:attribute name="start-indent">0in</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="space-before">
      	<xsl:choose>
      		<xsl:when test="count(preceding-sibling::tgroup) = 0"><xsl:value-of select="$normalParaSpace"/></xsl:when>
      		<xsl:otherwise>0pt</xsl:otherwise>
      	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="space-after">
      	<xsl:choose>
      		<xsl:when test="count(following-sibling::tgroup) = 0"><xsl:value-of select="$normalParaSpace"/></xsl:when>
      		<xsl:otherwise>0pt</xsl:otherwise>
      	</xsl:choose>
      </xsl:attribute>
      <!--space-before.minimum=".1in" space-before.optimum=".2in" space-after.maximum=".3in" space-before.conditionality="retain"-->
      
      <xsl:if test="not(parent::table/@tabstyle='follow-indent' or parent::table/@pgwide='0')">
	      <xsl:attribute name="margin-left">
	        <xsl:call-template name="calculateTableOffset"/>
	      </xsl:attribute>
      </xsl:if>
      <!-- If we're following the current indent, we need to outdent slightly to compensate for the small margin given -->
      <!-- to all tables. -->
      <xsl:if test="parent::table/@tabstyle='follow-indent' or parent::table/@pgwide='0'">
      	<xsl:attribute name="margin-left">-0.16in</xsl:attribute>
      </xsl:if>
      
      <!-- <xsl:if test="ancestor::TRANSLTR">
        <xsl:attribute name="space-before" select="'.2in'"/>
      </xsl:if> -->
      
      <!-- Break before Key for figure and dimensional limits tables in "ap" graphics or "revref" tables-->
      <!-- Not applicable for S1000D; ;left for reference for now...
      <xsl:choose>
        <xsl:when test="ancestor::GDESC and ancestor::table[count(preceding-sibling::table)=0] and (ancestor::SHEET/@IMGAREA='ap' or ancestor::SHEET/@IMGAREA='hl')">
          <xsl:attribute name="break-before">page</xsl:attribute>
        </xsl:when>
        <xsl:when test="ancestor::table[@tabstyle='revref']">
          [!++ Only add page break before revref tables if not preceded by ap or hl sheets ++]
          <xsl:choose>
            <xsl:when test="ancestor::PRCITEM1/preceding-sibling::PRCITEM1[1]/descendant::SHEET[last()]/@IMGAREA='ap'"/>
            <xsl:when test="ancestor::PRCITEM1/preceding-sibling::PRCITEM1[1]/descendant::SHEET[last()]/@IMGAREA='hl'"/>
            <xsl:otherwise>
              <xsl:attribute name="break-before">even-page</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          [!++ Add page break after revref tables if followed by bp or cp sheets ++]
          <xsl:choose>
            <xsl:when test="ancestor::PRCITEM/following-sibling::GRAPHIC[1]/SHEET[1]/@IMGAREA='bp'">
              <xsl:attribute name="break-after">page</xsl:attribute>
            </xsl:when>
            <xsl:when test="ancestor::PRCITEM/following-sibling::GRAPHIC[1]/SHEET[1]/@IMGAREA='cp'">
              <xsl:attribute name="break-after">page</xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose> -->
      
      <!-- RS: Output the change bar in the outer block of the table -->
	  <xsl:if test="not(ancestor::table/@changeMark='0') and (ancestor::table/@changeType='add' or ancestor::table/@changeType='modify')">
	    <xsl:call-template name="cbStart" />
	  </xsl:if>

		<xsl:if test="ancestor::table[@applicRefId]">
			<xsl:variable name="applicRefId" select="(ancestor::table[@applicRefId])[1]/@applicRefId"/>
			<!-- From Styler: I think we can assume the effectivity text will be in the same top-level pmEntry -->
			<xsl:variable name="effectText" select="ancestor::pmEntry[last()]//applic[@id=$applicRefId]/displayText/simplePara"/>
			<xsl:message>Found effective text applicRefId for table (<xsl:value-of select="$applicRefId"/>); text: <xsl:value-of select="$effectText"/></xsl:message>
			
			<fo:block>
				<fo:marker marker-class-name="efftextValue">
					<xsl:value-of select="$effectText" />
				</fo:marker>
			</fo:block>
		</xsl:if>
		
      <xsl:choose>
        <!-- Don't output the table title for tgroups after the first, and for the special marker "NO_TITLE" -->
        <xsl:when test="count(preceding-sibling::tgroup) = 0 and not($table-title = 'NO_TITLE')">
        
	      <!-- Output the table title: spacing specified here -->
          <fo:block font-weight="bold" text-align="center" space-after="{$normalParaSpace}"
              space-before="{$normalParaSpace}" keep-with-next.within-page="always">
            <xsl:if test="$revised-title = 'true'">
              <xsl:call-template name="cbStart"/>
            </xsl:if>
            <xsl:value-of select="$table-title"/>
            <xsl:if test="$revised-title = 'true'">
              <xsl:call-template name="cbEnd"/>
            </xsl:if>
          </fo:block>

          <fo:table rx:table-omit-initial-header="true" keep-with-previous.within-page="always">
            <!--Changes made by Nathan -->
            <!-- RS: Changed back to a single column width=100%, since this was making the tables too narrow (UPDATE: reverted below; keep for reference) -->
            <xsl:attribute name="width">100%</xsl:attribute>
            <!-- <fo:table-column column-width="100%"/> -->
            <!-- <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-column/>
            <fo:table-column column-width="proportional-column-width(1)"/> -->
            <!-- End of changes made by Nathan -->
            <!-- RS: Not sure why an artificial margin was added for tables, but keep it with revised widths; switch back to full width if it becomes a problem... -->
            <fo:table-column column-width="1mm"/>
            <fo:table-column column-width="proportional-column-width(1)"/>
            <fo:table-column column-width="1mm"/>
            <fo:table-header>
              <!--Changes made by Nathan -->
              <!-- <fo:table-cell/> -->
              <fo:table-cell/>
              <!-- End of changes made by Nathan -->
              <fo:table-cell padding="0pt">
                <xsl:if test="$revised-title = 'true'">
                  <xsl:call-template name="cbStart"/>
                </xsl:if>
                <fo:block font-weight="bold" text-align="center" space-after="{$normalParaSpace}"> <!-- space-after="5.7pt" space-before=".1in" -->
                  <xsl:value-of select="concat($table-title,' (Cont)')"/>
                </fo:block>
                <xsl:if test="$revised-title = 'true'">
                  <xsl:call-template name="cbEnd"/>
                </xsl:if>
              </fo:table-cell>
              <!--Changes made by Nathan -->
              <!-- <fo:table-cell/> -->
              <fo:table-cell/>
              <!-- End of changes made by Nathan -->
            </fo:table-header>
            <fo:table-body>
              <fo:table-row keep-together.within-page="auto"><!-- auto is default; no keep created -->
                <!--Changes made by Nathan -->
                <!-- <fo:table-cell/> -->
                <fo:table-cell/>
                <!-- End of changes made by Nathan -->
                <fo:table-cell>
                  <xsl:call-template name="inner-table"/>
                </fo:table-cell>
                <!--Changes made by Nathan -->
                <!-- <fo:table-cell/> -->
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
      
		<xsl:if test="ancestor::table[@applicRefId]">
			<fo:block>
				<fo:marker marker-class-name="efftextValue">
					<xsl:value-of select="'ALL'" />
				</fo:marker>
			</fo:block>
		</xsl:if>
		
      <!-- RS: Output the change bar inside the outer block of the table -->
	  <xsl:if test="not(ancestor::table/@changeMark='0') and (ancestor::table/@changeType='add' or ancestor::table/@changeType='modify')">
		<xsl:call-template name="cbEnd" />
	  </xsl:if>
    </fo:block>
    
    <!--MODIFIED FOR CMM-->
    <!--<xsl:if test="ancestor::INTRO">
      <xsl:apply-templates select="./parent::table/FTNOTE[1]"/>
      </xsl:if>-->
    <!-- This is not in S1000D
    <xsl:apply-templates select="./parent::table/FTNOTE[1]"/> -->
  </xsl:template>

  <!-- Call with tgroup in context -->
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

      <xsl:when test="preceding-sibling::title">
        <xsl:text>Table </xsl:text>
        <xsl:for-each select="parent::node()">
          <xsl:call-template name="calc-table-number"/>
        </xsl:for-each>
        <xsl:text>. </xsl:text>
        <xsl:apply-templates select="preceding-sibling::title" mode="table-title"/>
      </xsl:when>

      <!-- If inside GDESC this is KEY to FIGURE -->
      <xsl:when test="ancestor::GDESC">
        <xsl:text>Key for Figure </xsl:text>
        <xsl:for-each select="ancestor::SHEET">
          <xsl:call-template name="calc-figure-number"/>
        </xsl:for-each>
        <xsl:text> (Sheet </xsl:text>
        <xsl:value-of select="count(ancestor::SHEET/preceding-sibling::SHEET) + 1"/>
        <xsl:text> of </xsl:text>
        <xsl:value-of select="count(ancestor::GRAPHIC/SHEET)"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>NO_TITLE</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="title" mode="table-title">
  	<xsl:apply-templates/>
  </xsl:template>

  <!-- tgroup is in context -->
  <xsl:template name="inner-table">
    <fo:table table-layout="fixed" border-collapse="collapse"
      border-after-width.conditionality="retain" border-before-width.conditionality="retain">
      <xsl:if test="parent::node()/@id">
        <xsl:attribute name="id">
          <xsl:value-of select="parent::node()/@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="ancestor::table/@pgwide='1' or contains(ancestor-or-self::tgroup/colspec/@colwidth, '*')
      	or not(ancestor-or-self::tgroup/colspec/@colwidth)">
        <xsl:attribute name="width">100%</xsl:attribute>
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(preceding-sibling::tgroup)=0">
          <xsl:call-template name="TGROUP.first"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="TGROUP.notfirst"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- default the value of frame to all -->
      <xsl:variable name="frame">
        <xsl:choose>
          <!-- Use the frame attribute if specified. -->
          <xsl:when test="../@frame">
            <xsl:value-of select="../@frame"/>
          </xsl:when>
		  <!-- The default table style is to leave full table rules, except for the Record of Temporary Revisions -->
		  <!-- which has top and bottom rules, and Service Bulletin which only has top -->
          <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt54']">topbot</xsl:when>
          <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt55']">top</xsl:when>
          <!-- As in Styler, default to all, and let the table cells control the borders -->
          <xsl:otherwise>all</xsl:otherwise><!-- topbot -->
        </xsl:choose>
      </xsl:variable>
      <!-- unless frame='NONE', for now, act as if it were 'all' -->
      <!-- <xsl:message>Frame: <xsl:value-of select="$frame"/></xsl:message> -->
      <xsl:choose>
        <xsl:when test="$frame='topbot' or $frame=''">
          <!-- Don't output a top border for non-first tgroups -->
          <xsl:if test="count(preceding-sibling::tgroup) = 0">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'top'"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'bottom'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$frame='bottom'">
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'bottom'"/>
          </xsl:call-template>
          <!-- Styler puts a top rule even when the frame is specified as "bottom". -->
          <!-- <xsl:call-template name="border">
            <xsl:with-param name="side" select="'top'"/>
          </xsl:call-template> -->
        </xsl:when>
        <xsl:when test="$frame='top'">
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'top'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$frame!='none'">
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'left'"/>
          </xsl:call-template>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'right'"/>
          </xsl:call-template>
          <!-- Don't output a top border for non-first tgroups -->
          <xsl:if test="count(preceding-sibling::tgroup) = 0">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'top'"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="border">
            <xsl:with-param name="side" select="'bottom'"/>
          </xsl:call-template>
        </xsl:when>
        <!-- This does nothing: <xsl:when test="$frame='none'"> </xsl:when> -->
      </xsl:choose>
      <xsl:call-template name="tgroup-after-table-fo"/>
    </fo:table>
  </xsl:template>

  <xsl:template match="tgroup" name="tgroup-after-table-fo" mode="already-emitted-table-fo">
    <xsl:variable name="COLSPECs">
      <xsl:choose>
        <xsl:when test="$use.extensions != 0
          and $tablecolumns.extension != 0">
          <xsl:call-template name="generate.colgroup.raw">
            <xsl:with-param name="cols" select="@cols"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="generate.colgroup">
            <xsl:with-param name="cols" select="@cols"/>
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

    <xsl:apply-templates select="thead"/>
    <xsl:apply-templates select="tfoot"/>
    <xsl:apply-templates select="tbody"/>
  </xsl:template>

  <xsl:template match="colspec"/>

  <xsl:template match="spanspec"/>

  <xsl:template match="thead">
    <xsl:variable name="tgroup" select="parent::*"/>

    <fo:table-header>
      <xsl:call-template name="THEAD"/>
      <xsl:apply-templates select="row[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="cols" select="../@cols"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>
    </fo:table-header>
  </xsl:template>

  <xsl:template match="tfoot">
    <xsl:variable name="tgroup" select="parent::*"/>

    <fo:table-footer>
      <xsl:call-template name="TFOOT"/>
      <xsl:apply-templates select="row[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="cols" select="../@cols"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>

    </fo:table-footer>
  </xsl:template>

  <xsl:template match="tbody">
    <xsl:variable name="tgroup" select="parent::*"/>

    <fo:table-body>
      <xsl:call-template name="TBODY"/>
      <!-- Changes made by Nathan for abbrev -->
      <!-- <xsl:if test="contains((./parent::tgroup/parent::table/title), 'Acronyms and Abbreviations')">
        <xsl:call-template name="accroAbbrevTableRow"/>
      </xsl:if>
      <xsl:if
        test="not(contains((./parent::tgroup/parent::table/title), 'Acronyms and Abbreviations'))">
        <xsl:apply-templates select="row[1]">
          <xsl:with-param name="spans">
            <xsl:call-template name="blank.spans">
              <xsl:with-param name="cols" select="../@cols"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:if>-->
      <!-- End of changes made by Nathan -->
      <xsl:apply-templates select="row[1]">
        <xsl:with-param name="spans">
          <xsl:call-template name="blank.spans">
            <xsl:with-param name="cols" select="../@cols"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:apply-templates>
    </fo:table-body>
  </xsl:template>

  <xsl:template match="row">
    <xsl:param name="spans"/>

	<!-- Tried different settings on row to try to let large rows break if necessary without adding -->
	<!-- a lot of whitespace in the table. But it seems like it was all-or-nothing; if allowed, rows -->
	<!-- would break too much. And adding a special keep-with-next for some cases did not make the -->
	<!-- large row stick with the previous row. -->
	<!-- page-break-inside="auto" keep-together.within-page="1"  keep-together.within-column="1" -->
	<!--  -->
	<!-- UPDATE: Generally, don't allow hyphenation. May try to make some exceptions at the entry level -->
    <fo:table-row hyphenate="false"><!-- hyphenate="true" hyphenation-push-character-count="4" hyphenation-remain-character-count="4" -->
      <xsl:choose>
        <xsl:when test=".//sequentialList and (count(following-sibling::row)=0)"> 
          <xsl:attribute name="page-break-inside">auto</xsl:attribute>
      	</xsl:when>

      	<xsl:otherwise>
          <xsl:attribute name="page-break-inside">avoid</xsl:attribute>
      	</xsl:otherwise>
      </xsl:choose>
      <!--
       hyphenate="true" 
                  hyphenation-character=" " 
                  hyphenation-push-character-count="0" 
                  hyphenation-remain-character-count="0" 
                  hyphenation-keep="auto" 
                  hyphenation-ladder-count="no-limit"-->
      <!-- Keep the second last row together with the last (not allowing an orphan single row on a page) -->
      <xsl:if test="count(following-sibling::row)=1">
      	<xsl:attribute name="keep-with-next.within-page">1</xsl:attribute><!-- always -->
      </xsl:if>
      
      <!-- <xsl:call-template name="ROW"/> --><!-- in "shared" folder: a couple attributes (including page-break-inside="avoid")-->
      <xsl:apply-templates select="entry[1]">
        <xsl:with-param name="spans" select="$spans"/>
      </xsl:apply-templates>
    </fo:table-row>

    <xsl:if test="following-sibling::row">
      <xsl:variable name="nextspans">
        <xsl:apply-templates select="entry[1]" mode="span">
          <xsl:with-param name="spans" select="$spans"/>
        </xsl:apply-templates>
      </xsl:variable>

      <xsl:apply-templates select="following-sibling::row[1]">
        <xsl:with-param name="spans" select="$nextspans"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="entry" name="entry-template">
    <xsl:param name="col" select="1"/>
    <xsl:param name="spans"/>

    <xsl:variable name="row" select="parent::row"/>
    <xsl:variable name="group" select="$row/parent::*[1]"/>

    <xsl:variable name="empty.cell" select="count(node()) = 0"/>

    <xsl:variable name="named.colnum">
      <xsl:call-template name="entry.colnum"/>
    </xsl:variable>

    <xsl:variable name="entry.colnum">
      <xsl:choose>
        <xsl:when test="$named.colnum &gt; 0">
          <xsl:value-of select="$named.colnum"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$col"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="entry.colspan">
      <xsl:choose>
        <xsl:when test="@spanname or @namest">
          <xsl:call-template name="calculate.colspan"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="following.spans">
      <xsl:call-template name="calculate.following.spans">
        <xsl:with-param name="colspan" select="$entry.colspan"/>
        <xsl:with-param name="spans" select="$spans"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="lastrow">
      <xsl:choose>
        <xsl:when test="ancestor::thead">0</xsl:when>
        <xsl:when test="ancestor::tfoot
          and not(ancestor::row/following-sibling::row)"
          >1</xsl:when>
        <xsl:when test="not(ancestor::tfoot)
          and ancestor::tgroup/tfoot">0</xsl:when>
        <xsl:when
          test="not(ancestor::tfoot)
          and not(ancestor::tgroup/tfoot)
          and not(ancestor::row/following-sibling::row)"
          >1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="lastcol">
      <xsl:choose>
        <xsl:when test="$col &lt; ancestor::tgroup/@cols">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rowsep">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'rowsep'"/>
        <xsl:with-param name="lastrow" select="$lastrow"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
      <xsl:message><xsl:value-of select="."/>: <xsl:value-of select="$rowsep"/></xsl:message>
    -->

    <xsl:variable name="colsep">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'colsep'"/>
        <xsl:with-param name="lastrow" select="$lastrow"/>
        <xsl:with-param name="lastcol" select="$lastcol"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="valign">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'valign'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="align">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'align'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="CHAR">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'CHAR'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="charoff">
      <xsl:call-template name="inherited.table.attribute">
        <xsl:with-param name="entry" select="."/>
        <xsl:with-param name="colnum" select="$entry.colnum"/>
        <xsl:with-param name="attribute" select="'charoff'"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$spans != '' and not(starts-with($spans,'0:'))">
        <xsl:call-template name="entry-template">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$entry.colnum &gt; $col">
        <xsl:call-template name="empty.table.cell">
          <xsl:with-param name="colnum" select="$col"/>
        </xsl:call-template>
        <xsl:call-template name="entry-template">
          <xsl:with-param name="col" select="$col+1"/>
          <xsl:with-param name="spans" select="substring-after($spans,':')"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="cell.content">
          <fo:block>
            <!-- highlight this entry? -->
            <xsl:if test="ancestor::thead">
              <xsl:attribute name="font-weight">bold</xsl:attribute>
            </xsl:if>

            <!-- are we missing any indexterms? -->
            <xsl:if
              test="not(preceding-sibling::entry)
              and not(parent::row/preceding-sibling::row)">
              <!-- this is the first entry of the first row -->
              <xsl:if
                test="ancestor::thead or
                (ancestor::tbody
                and not(ancestor::tbody/preceding-sibling::thead
                or ancestor::tbody/preceding-sibling::tbody))">
                <!-- of the thead or the first tbody -->
                <xsl:apply-templates select="ancestor::tgroup/preceding-sibling::INDEXTERM"/>
              </xsl:if>
            </xsl:if>

            <!--
              <xsl:text>(</xsl:text>
              <xsl:value-of select="$rowsep"/>
              <xsl:text>,</xsl:text>
              <xsl:value-of select="$colsep"/>
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
	      <!-- <xsl:call-template name="ENTRY"/> --> <!-- RS: This was in shared/standardVariables.xsl. It over-rides the cell-padding, so removed for now -->

          <!-- Also, Styler seems to add a bottom border when the table frame="bottom". So do this for -->
          <!-- now as well to be consistent (though I think it's incorrect). -->
          <xsl:if test="ancestor::table/@frame='bottom'">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'bottom'"/>
            </xsl:call-template>
          </xsl:if>

          <!-- Add bottom border if rowsep is greater than 0, or if it's the last row in the thead -->
          <xsl:if test="$rowsep &gt; 0 or (ancestor::thead and count(ancestor::row/following-sibling::row)=0)">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'bottom'"/>
            </xsl:call-template>
          </xsl:if>

          <xsl:if test="$colsep &gt; 0">
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'right'"/>
            </xsl:call-template>
          </xsl:if>

	      <xsl:if test="processing-instruction('PubTbl')[contains(.,'border-left-style=&quot;none&quot;')]">
	      	<!-- <xsl:message>Found PI PubTbl with cell border-left-style=&quot;none&quot;</xsl:message> -->
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'left'"/>
              <xsl:with-param name="style" select="'hidden'"/><!-- hidden will make table frame border go away too -->
            </xsl:call-template>
	      </xsl:if>
        
	      <xsl:if test="processing-instruction('PubTbl')[contains(.,'border-right-style=&quot;none&quot;')]">
	      	<!-- <xsl:message>Found PI PubTbl with cell border-right-style=&quot;none&quot;</xsl:message> -->
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'right'"/>
              <xsl:with-param name="style" select="'hidden'"/><!-- hidden will make table frame border go away too -->
            </xsl:call-template>
	      </xsl:if>
        
	      <xsl:if test="processing-instruction('PubTbl')[contains(.,'border-top-style=&quot;none&quot;')]">
	      	<!-- <xsl:message>Found PI PubTbl with cell border-top-style=&quot;none&quot;</xsl:message> -->
            <xsl:call-template name="border">
              <xsl:with-param name="side" select="'top'"/>
              <xsl:with-param name="style" select="'hidden'"/><!-- hidden will make table frame border go away too -->
            </xsl:call-template>
	      </xsl:if>
        
	      <xsl:if test="processing-instruction('PubTbl')[contains(.,'border-bottom-style=&quot;none&quot;')]">
	      	<!-- <xsl:message>Found PI PubTbl with cell border-top-style=&quot;none&quot;</xsl:message> -->
	      	<!-- Setting the border to "hidden" will make table frame border go away too (and bottom rule on continued tables), so we can't do this. -->
	      	<!-- UPDATE: Allow this for the processing instruction only for second tgroup, since often it shouldn't -->
	      	<!-- have a bottom frame rule... -->
	      	<!-- UPDATE: Allow to over-ride the bottom rule after all, but only for the processing instruction, not the rowsep. -->
            <!-- <xsl:if test="count(ancestor::tgroup/preceding-sibling::tgroup) &gt; 0"> -->
              <xsl:call-template name="border">
                <xsl:with-param name="side" select="'bottom'"/>
                <xsl:with-param name="style" select="'hidden'"/> 
              </xsl:call-template>
            <!-- </xsl:if> -->
	      </xsl:if>
          
          <!-- Also remove the bottom border if rowsep is '0', but make an exception for the last row (controlled by the table frame)-->
          <!-- http://www.datypic.com/sc/cals/a-nons_rowsep.html: -->
          <!--    If rowsep is non-zero, display the internal row rules below each entry; if zero, do not display the rules. -->
          <!--    Ignored for the last row of the table (i.e., the last row of the last tgroup in this table), where the frame value applies.  -->
          
	      <xsl:if test="$rowsep='0' and ancestor::row/following-sibling::row">
	      	<!-- Another exception when "morerows" is specified -->
	      	<xsl:if test="not(@morerows &gt; 0 and count(ancestor::row/following-sibling::row)=@morerows)">
	            <!-- <xsl:call-template name="border">
	              <xsl:with-param name="side" select="'bottom'"/>
	              <xsl:with-param name="style" select="'hidden'"/>[!++ hidden will make table frame border go away too (and bottom rule on continued tables), so we can't do this.  ++]
	            </xsl:call-template>-->
	      	</xsl:if>
	      </xsl:if>
        
          <xsl:if test="@morerows">
            <xsl:attribute name="number-rows-spanned">
              <xsl:value-of select="@morerows+1"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$entry.colspan &gt; 1">
            <xsl:attribute name="number-columns-spanned">
              <xsl:value-of select="$entry.colspan"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:if test="$valign != ''">
            <xsl:attribute name="display-align">
              <xsl:choose>
                <xsl:when test="translate($valign,$upperCase,$lowerCase) ='top'">before</xsl:when>
                <xsl:when test="translate($valign,$upperCase,$lowerCase) ='middle'"
                  >center</xsl:when>
                <xsl:when test="translate($valign,$upperCase,$lowerCase) ='bottom'">after</xsl:when>
                <xsl:otherwise>
                  <xsl:message>
                    <xsl:text>Unexpected valign value: </xsl:text>
                    <xsl:value-of select="$valign"/>
                    <xsl:text>, center used.</xsl:text>
                  </xsl:message>
                  <xsl:text>center</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          
          <!-- RS: Default to bottom alignment for thead (as in Styler) -->
          <xsl:if test="$valign = '' and ancestor::thead">
          	<xsl:attribute name="display-align" select="'after'"/>
          </xsl:if>
          
          <xsl:if test="$align != ''">
            <xsl:attribute name="text-align">
              <!-- Changes made by Nathan for align="CHAR"-->
              <!--<xsl:value-of select="translate(string($align),$upperCase,$lowerCase)"/>-->
              <xsl:choose>
                <xsl:when test="$align='char'">left</xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="translate(string($align),$upperCase,$lowerCase)"/>
                </xsl:otherwise>
              </xsl:choose>
              <!-- End of changes made by Nathan -->
            </xsl:attribute>
          </xsl:if>

          <!-- GAP added 6/10/08  Remove white space from the CHAR variable -->
          <xsl:variable name="new-CHAR" select="translate(string($CHAR),'&#x20;&#x9;&#xA;&#xD;','')"/>
          <xsl:if test="$new-CHAR != ''">
            <xsl:attribute name="text-align">
              <xsl:value-of select="translate(string($CHAR),$upperCase,$lowerCase)"/>
              <!-- new part -->
            </xsl:attribute>
          </xsl:if>

          <!-- Allow hyphenation if there are no spaces in the entry -->
          <xsl:if test="not( contains(normalize-space(.), ' ') )">
          	<xsl:attribute name="hyphenate">true</xsl:attribute>
          </xsl:if>

          <!--
            <xsl:if test="@charoff">
            <xsl:attribute name="charoff">
            <xsl:value-of select="@charoff"/>
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
          <xsl:when test="following-sibling::entry">
            <xsl:apply-templates select="following-sibling::entry[1]">
              <xsl:with-param name="col" select="$col+$entry.colspan"/>
              <xsl:with-param name="spans" select="$following.spans"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="finaltd">
              <xsl:with-param name="spans" select="$following.spans"/>
              <xsl:with-param name="col" select="$col+$entry.colspan"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="entry" name="sENTRY" mode="span">
    <xsl:param name="col" select="1"/>
    <xsl:param name="spans"/>

    <xsl:variable name="entry.colnum">
      <xsl:call-template name="entry.colnum"/>
    </xsl:variable>

    <xsl:variable name="entry.colspan">
      <xsl:choose>
        <xsl:when test="@spanname or @namest">
          <xsl:call-template name="calculate.colspan"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="following.spans">
      <xsl:call-template name="calculate.following.spans">
        <xsl:with-param name="colspan" select="$entry.colspan"/>
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

      <xsl:when test="$entry.colnum &gt; $col">
        <xsl:text>0:</xsl:text>
        <xsl:call-template name="sENTRY">
          <xsl:with-param name="col" select="$col+$entry.colspan"/>
          <xsl:with-param name="spans" select="$following.spans"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="copy-string">
          <xsl:with-param name="count" select="$entry.colspan"/>
          <xsl:with-param name="string">
            <xsl:choose>
              <xsl:when test="@morerows">
                <xsl:value-of select="@morerows"/>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
            <xsl:text>:</xsl:text>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:choose>
          <xsl:when test="following-sibling::entry">
            <xsl:apply-templates select="following-sibling::entry[1]" mode="span">
              <xsl:with-param name="col" select="$col+$entry.colspan"/>
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
    <xsl:param name="cols" select="1"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count>$cols"/>
      <xsl:otherwise>
        <xsl:call-template name="generate.col.raw">
          <xsl:with-param name="countcol" select="$count"/>
        </xsl:call-template>
        <xsl:call-template name="generate.colgroup.raw">
          <xsl:with-param name="cols" select="$cols"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate.colgroup">
    <xsl:param name="cols" select="1"/>
    <xsl:param name="count" select="1"/>

    <xsl:choose>
      <xsl:when test="$count>$cols"/>
      <xsl:otherwise>
        <xsl:call-template name="generate.col">
          <xsl:with-param name="countcol" select="$count"/>
        </xsl:call-template>
        <xsl:call-template name="generate.colgroup">
          <xsl:with-param name="cols" select="$cols"/>
          <xsl:with-param name="count" select="$count+1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate.col.raw">
    <!-- generate the table-column for column countcol -->
    <xsl:param name="countcol">1</xsl:param>
    <xsl:param name="COLSPECs" select="./colspec"/>
    <xsl:param name="count">1</xsl:param>
    <xsl:param name="colnum">1</xsl:param>

    <xsl:choose>
      <xsl:when test="$count>count($COLSPECs)">
        <fo:table-column column-number="{$countcol}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="colspec" select="$COLSPECs[$count=position()]"/>

        <xsl:variable name="colspec.colnum">
          <xsl:choose>
            <xsl:when test="$colspec/@colnum">
              <xsl:value-of select="$colspec/@colnum"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$colnum"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="colspec.colwidth">
          <xsl:choose>
            <xsl:when test="$colspec/@colwidth">
              <xsl:value-of select="$colspec/@colwidth"/>
            </xsl:when>
            <xsl:otherwise>1*</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$colspec.colnum=$countcol">
            <fo:table-column column-number="{$countcol}">
              <xsl:attribute name="column-width">
                <xsl:value-of select="$colspec.colwidth"/>
              </xsl:attribute>
            </fo:table-column>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="generate.col.raw">
              <xsl:with-param name="countcol" select="$countcol"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs"/>
              <xsl:with-param name="count" select="$count+1"/>
              <xsl:with-param name="colnum">
                <xsl:choose>
                  <xsl:when test="$colspec/@colnum">
                    <xsl:value-of select="$colspec/@colnum + 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$colnum + 1"/>
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
    <xsl:param name="COLSPECs" select="./colspec"/>
    <xsl:param name="count">1</xsl:param>
    <xsl:param name="colnum">1</xsl:param>
    <xsl:choose>
      <xsl:when test="$count>count($COLSPECs)">
        <fo:table-column column-number="{$countcol}">
          <xsl:variable name="colwidth">
            <xsl:call-template name="calc.column.width"/>
          </xsl:variable>
          <xsl:if test="$colwidth != 'proportional-column-width(1)'">
            <xsl:attribute name="column-width">
              <xsl:value-of select="$colwidth"/>
            </xsl:attribute>
          </xsl:if>
        </fo:table-column>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="colspec" select="$COLSPECs[$count=position()]"/>

        <xsl:variable name="colspec.colnum">
          <xsl:choose>
            <xsl:when test="$colspec/@colnum">
              <xsl:value-of select="$colspec/@colnum"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$colnum"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="colspec.colwidth">
          <xsl:choose>
            <xsl:when test="$colspec/@colwidth">
              <xsl:value-of select="$colspec/@colwidth"/>
            </xsl:when>
            <xsl:otherwise>1*</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$colspec.colnum=$countcol">
            <fo:table-column column-number="{$countcol}">
              <xsl:variable name="colwidth">
                <xsl:call-template name="calc.column.width">
                  <xsl:with-param name="colwidth">
                    <xsl:value-of select="$colspec.colwidth"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:if test="$colwidth != 'proportional-column-width(1)'">
                <xsl:attribute name="column-width">
                  <xsl:value-of select="$colwidth"/>
                </xsl:attribute>
              </xsl:if>
            </fo:table-column>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="generate.col">
              <xsl:with-param name="countcol" select="$countcol"/>
              <xsl:with-param name="COLSPECs" select="$COLSPECs"/>
              <xsl:with-param name="count" select="$count+1"/>
              <xsl:with-param name="colnum">
                <xsl:choose>
                  <xsl:when test="$colspec/@colnum">
                    <xsl:value-of select="$colspec/@colnum + 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$colnum + 1"/>
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
    <xsl:param name="colwidth">1*</xsl:param>



    <!-- Changes made by Nathan -->
    <xsl:param name="tableContext" select="./ancestor-or-self::table"/>
    <xsl:param name="totalColumns" select="count($tableContext/tgroup[1]/colspec)"/>
    <xsl:param name="widthOfEachColumn" select="7 div $totalColumns"/>
    <!-- End of changes made by Nathan -->

    <!-- Force the column width value to lower case HT -->
    <xsl:variable name="lowercaseColwidth"
      select="translate($colwidth,
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ*0123456789',
      'abcdefghijklmnopqrstuvwxyz*0123456789')"/>

    <!-- Ok, the colwidth could have any one of the following forms: -->
    <!--        1*       = proportional width -->
    <!--     1unit       = 1.0 units wide -->
    <!--         1       = 1pt wide -->
    <!--  1*+1unit       = proportional width + some fixed width -->
    <!--      1*+1       = proportional width + some fixed width -->

    <!-- If it has a proportional width, translate it to XSL -->
    <!-- Changes made by Nathan -->
    <!-- RS: Changed this back to use proportional widths. If a case comes up where it doesn't -->
    <!-- work well, we can look at making exceptions and use equal column widths ($widthOfEachColumn) -->
    <!-- as Nathan implemented below. -->
    <xsl:if test="contains($colwidth, '*')">
      <xsl:text>proportional-column-width(</xsl:text>
      <xsl:value-of select="substring-before($colwidth, '*')"/>
      <xsl:text>)</xsl:text>
      </xsl:if>
    <!-- <xsl:if test="contains($lowercaseColwidth, '*')">
      <xsl:value-of select="$widthOfEachColumn"/>
      <xsl:text>in</xsl:text>
    </xsl:if>-->
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
    <!--<xsl:variable name="offset"
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
      count(ancestor::NUMLIST) ) "/>-->
    <!--<xsl:variable name="offset"
      select="($common-indent * 
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
      count(ancestor::NUMLIST))) - 48"/>-->
    <xsl:variable name="offset" select="'0'"/>
    <xsl:if test="$debug and ancestor::GDESC">
      <xsl:message>Calculated table offset = -<xsl:value-of select="$offset"/>pt (ID="<xsl:value-of
          select="ancestor::table/@id"/>")</xsl:message>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="parent::TRANSLTR">
        <xsl:value-of select="'0pt'"/>
      </xsl:when>
      <!--<xsl:when test="not(ancestor::GDESC)">-->
      <xsl:when
        test="((not(ancestor::GDESC)) and (not(contains(ancestor::table[1]/@ID, 'check_point'))))">
        <xsl:value-of select="concat('-',$offset,'pt')"/>
      </xsl:when>
      <!-- Modified offset for tables in gdesc in mfmatr. Mantis #18789 -->
      <xsl:when test="ancestor::GDESC and ancestor::MFMATR">
        <xsl:message>GDESC in MFMATR - Calculated table offset = -<xsl:value-of
            select="$offset + 60"/>pt (ID="<xsl:value-of select="ancestor::table/@ID"
          />")</xsl:message>
        <xsl:value-of select="concat('-',$offset + 60,'pt')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0pt'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()[ancestor::table]">
    <xsl:value-of
      select="replace(replace(replace(.,'/',concat('/','&#x200B;')),'-',concat('-','&#x200B;')),'_',concat('&#x200B;','_'))"
    />
  </xsl:template>

</xsl:stylesheet>
