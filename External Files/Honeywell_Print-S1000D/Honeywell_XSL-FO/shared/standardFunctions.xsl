<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

  <!-- Currently only called out in EIPC.xsl -->

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- CALS Table -->
  <xsl:template name="do-CALS-table">
    <xsl:choose>
      <xsl:when test="./ancestor::TABLE">
        <fo:block border-width="1mm" space-before.minimum="1.5mm" space-after.minimum="2mm" text-align="right" hyphenate="false" language="en">
          <xsl:choose>
            <xsl:when test="./@ID">
              <xsl:attribute name="id">
                <xsl:value-of select="./@ID"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="id">
                <xsl:value-of select="concat('table_id_', count(./preceding::TABLE))"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block border-width="1mm" space-before.minimum="1.5mm" space-after.minimum="2mm" text-align="right" hyphenate="false" language="en" start-indent="0pt">
          <xsl:choose>
            <xsl:when test="./@ID">
              <xsl:attribute name="id">
                <xsl:value-of select="./@ID"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="id">
                <xsl:value-of select="concat('table_id_', count(./preceding::TABLE))"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="*[not(name()='FTNOTE')]"/>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- xsl:param name="table.border.thickness" select="'1pt'"/ -->
  <xsl:param name="table.cell.padding.amount" select="'2.5pt'"/>

  <xsl:template name="TGROUP.first">
    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="font-family">Arial</xsl:attribute>
    <xsl:attribute name="margin-left">2pt</xsl:attribute>
    <xsl:attribute name="text-indent">0pt</xsl:attribute>
  </xsl:template>

  <xsl:template name="TGROUP.notfirst">
    <xsl:attribute name="margin-left">5.00pt</xsl:attribute>
    <xsl:attribute name="text-indent">0pt</xsl:attribute>
  </xsl:template>

  <xsl:template name="THEAD"/>
  <xsl:template name="TFOOT"/>
  <xsl:template name="TBODY"/>

  <xsl:template name="ROW">
    <xsl:attribute name="text-align">left</xsl:attribute>
    <!--<xsl:attribute name="keep-together.within-page">always</xsl:attribute>-->
    <xsl:attribute name="page-break-inside">avoid</xsl:attribute>
    <!--<xsl:attribute name="keep-together">always</xsl:attribute>-->
  </xsl:template>


  <xsl:template name="ENTRY">
    <xsl:attribute name="margin-left">0pt - inherited-property-value(start-indent) + 0pt</xsl:attribute>
    <xsl:attribute name="margin-right">0pt - inherited-property-value(end-indent) + 0pt</xsl:attribute>
    <!--<xsl:attribute name="text-align">left</xsl:attribute>-->
    <xsl:attribute name="text-indent">0pt</xsl:attribute>
    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="padding-left">3pt</xsl:attribute>

    <!-- Sonovision update (2019.01.15)
         - adding support for PI _cellfont shading 
           -->
    <xsl:call-template name="ENTRY_SHADING"/>

  </xsl:template>


  <xsl:template name="just-after-table-cell-stag"/>
  <xsl:template name="just-after-table-cell-etag"/>
  <xsl:template name="just-before-table-cell-stag"/>
  <xsl:template name="just-before-table-cell-etag"/>

  <!--Not used in CMM. The CMM has its own template in cmmMiscFunctions.xsl-->
  <xsl:template match="TABLE/FTNOTE[1]">
    <xsl:param name="list-indent">
      <xsl:call-template name="calc-list-indent"/>
    </xsl:param>
    <xsl:param name="base-table-indent">
      <xsl:value-of select="substring-before($list-indent, 'pt')"/>
    </xsl:param>
    <xsl:param name="table-indent">
      <xsl:value-of select="number($base-table-indent + 20)"/>
    </xsl:param>
    <fo:block text-align="left" space-before.optimum="3mm" space-after.optimum="3mm" font-size="9pt">
      <xsl:choose>
        <xsl:when test="ancestor::SHEET">
          <xsl:attribute name="margin-left">5pt</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="margin-left">
            <xsl:value-of select="concat('-', $table-indent, 'pt')"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>NOTES:</xsl:text>
      <fo:block space-after.optimum="3mm" margin-left="0.25in">
        <fo:list-block provisional-distance-between-starts="0.425in">
          <fo:list-item space-before.optimum="1.5mm">
            <xsl:attribute name="id">
              <xsl:value-of select="./@FTNOTEID"/>
            </xsl:attribute>
            <fo:list-item-label end-indent="label-end()">
              <fo:block><xsl:number format="1"/>.</fo:block>
            </fo:list-item-label>
            <fo:list-item-body start-indent="body-start()">
              <xsl:apply-templates/>
            </fo:list-item-body>
          </fo:list-item>
          <xsl:if test="./following-sibling::FTNOTE">
            <xsl:call-template name="regFtNote">
              <xsl:with-param name="ftNoteInstance" select="./following-sibling::FTNOTE[1]"/>
            </xsl:call-template>
          </xsl:if>
        </fo:list-block>
      </fo:block>
      <fo:block text-align-last="justify">
        <fo:leader leader-pattern="rule"/>
      </fo:block>
    </fo:block>
  </xsl:template>

  <xsl:template match="TABLE/FTNOTE[position()>1]"/>

  <xsl:template name="regFtNote">
    <xsl:param name="ftNoteInstance"/>
    <xsl:param name="count" select="2"/>
    <fo:list-item space-before.optimum="1.5mm">
      <xsl:attribute name="id">
        <xsl:value-of select="$ftNoteInstance/@FTNOTEID"/>
      </xsl:attribute>
      <fo:list-item-label end-indent="label-end()">
        <fo:block><xsl:number format="1" value="$count"/>.</fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <xsl:apply-templates select="$ftNoteInstance/*"/>
      </fo:list-item-body>
    </fo:list-item>
    <xsl:if test="$ftNoteInstance/following-sibling::FTNOTE">
      <xsl:call-template name="regFtNote">
        <xsl:with-param name="ftNoteInstance" select="$ftNoteInstance/following-sibling::FTNOTE[1]"/>
        <xsl:with-param name="count" select="$count + 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- End of CALS table -->

  <xsl:template name="calculate-current-indent">
    <xsl:variable name="common-indent" select=".33"/>
    <xsl:variable name="offset"
      select="$common-indent * 
      (
      count(ancestor::SUBTASK) +
      count(ancestor::NOTE) +
      count(ancestor::LIST1) +
      count(ancestor::LIST2) +
      count(ancestor::LIST3) + 
      count(ancestor::LIST4) + 
      count(ancestor::LIST5)  +
      count(ancestor::LIST6)  +
      count(ancestor::PRCLIST1) +
      count(ancestor::PRCLIST2) +
      count(ancestor::PRCLIST3) + 
      count(ancestor::PRCLIST4) + 
      count(ancestor::PRCLIST5) + 
      count(ancestor::PRCLIST6) + 
      count(ancestor::PRCLIST7) + 
      count(ancestor::UNLIST) +
      count(ancestor::NUMLIST) ) "/>
    <!-- For debug -->
    <xsl:if test="false()">
      <xsl:message>
        <xsl:value-of select="concat('Calculated table offset = -',$offset,'in')"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="concat('-',$offset,'in')"/>
  </xsl:template>

  <xsl:template name="calculateAppendixNumber">
    <xsl:param name="context"/>
    <xsl:choose>
      <xsl:when test="count($context/preceding-sibling::APPEND)=0"> A</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=1"> B</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=2"> C</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=3"> D</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=4"> E</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=5"> F</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=6"> G</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=7"> H</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=8"> I</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=9"> J</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=10"> K</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=11"> L</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=12"> M</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=13"> N</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=14"> O</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=15"> P</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=16"> Q</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=17"> R</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=18"> S</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=19"> T</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=20"> U</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=21"> V</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=22"> W</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=23"> X</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=24"> Y</xsl:when>
      <xsl:when test="count($context/preceding-sibling::APPEND)=25"> Z</xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- Output the header for the first (frontmatter) EM page -->
  <xsl:template name="selectFirstPageHeader">
    <xsl:choose>
      <xsl:when test="$splLowercase = '0s4a8'">
        <fo:block border-bottom="black solid 0pt" space-after="6pt">
          <xsl:call-template name="do-spl-logo">
            <xsl:with-param name="cageCode" select="$splLowercase"/>
            <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
          </xsl:call-template>
        </fo:block>
        <fo:block>
          <fo:table>
            <fo:table-column column-width="50%"/>
            <fo:table-column column-width="50%"/>
            <fo:table-body>
              <fo:table-row>
                <fo:table-cell>
                  <fo:block space-after.optimum="15pt">
                    <xsl:call-template name="splInformation">
                      <xsl:with-param name="cageCode" select="$splLowercase"/>
                      <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
                    </xsl:call-template>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
            </fo:table-body>
          </fo:table>
        </fo:block>
      </xsl:when>
  
 <!-- Honeywell update (2020.05.11) to include cage code: 0bfa5 and 94580 -->
 
  <xsl:when test="((($splLowercase='07217') or ($splLowercase='65507')
        or ($splLowercase='1std7') or ($splLowercase='99866')
        or ($splLowercase='22373') or ($splLowercase='55939')
        or ($splLowercase='58960') or ($splLowercase='99193')
        or ($splLowercase='97896') or ($splLowercase='0yfp0')
        or ($splLowercase='27914') or ($splLowercase='56081')
        or ($splLowercase='55284') or ($splLowercase='06848')
        or ($splLowercase='59364') or ($splLowercase='70210')
        or ($splLowercase='64547') or ($splLowercase='72914')
        or ($splLowercase='f9111') or ($splLowercase='1m8l7')
        or ($splLowercase='kf586') or ($splLowercase='0ug66')
        or ($splLowercase='31395') or ($splLowercase='5vwn5')
        or ($splLowercase='56776') or ($splLowercase='38473')
        or ($splLowercase='6pc31') or ($splLowercase='63389')
        or ($splLowercase='6nba7') or ($splLowercase='1y4q3')
        or ($splLowercase='u6578') or ($splLowercase='f0302')
        or ($splLowercase='u1605') or ($splLowercase='0bfa5')
		or ($splLowercase='94580') or ($splLowercase='l4578'))
        and (($prtnprSplLowercase='none') or ($prtnprSplLowercase='')))">
        <fo:block border-bottom="black solid 0pt" space-after="6pt">
          <xsl:choose>
            <xsl:when test="$splLowercase = '99193'">
              <fo:external-graphic src="url({$globalExtObj_logo})"/>
            </xsl:when>
            <xsl:otherwise>
              <fo:external-graphic src="url({$splLogo_PATH})"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
        <fo:block>
          <fo:block space-after.optimum="15pt">
            <xsl:call-template name="splInformation">
              <xsl:with-param name="cageCode" select="$splLowercase"/>
              <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
            </xsl:call-template>
          </fo:block>
        </fo:block>
      </xsl:when>
      <xsl:when test="((($splLowercase = '55939') or ($splLowercase = '58960'))
        and (($prtnprSplLowercase = '19710') or ($prtnprSplLowercase = '1r5y6')
        or ($prtnprSplLowercase = 'f9111') or ($prtnprSplLowercase = '61349')
        or ($prtnprSplLowercase = '2y402')))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:when test="(($splLowercase = '90073') and ($prtnprSplLowercase = '65507'))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:when test="(($splLowercase = '19710') and ($prtnprSplLowercase = '55939'))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:when test="(($splLowercase = '1r5y6') and (($prtnprSplLowercase = '55939') or ($prtnprSplLowercase = '58960')))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:when test="(($splLowercase = 'f9111') and (($prtnprSplLowercase = '55939') or ($prtnprSplLowercase = '58960')))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:when test="(($splLowercase = '61349') and (($prtnprSplLowercase = '55939') or ($prtnprSplLowercase = '58960')))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:when test="(($splLowercase = '2y402') and (($prtnprSplLowercase = '55939') or ($prtnprSplLowercase = '58960')))">
        <xsl:call-template name="firstPageHeaderDisplay"/>
      </xsl:when>
      <xsl:otherwise> </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="firstPageHeaderDisplay">
    <fo:block border-bottom="black solid 0pt" space-after="6pt">
      <xsl:call-template name="do-spl-logo">
        <xsl:with-param name="cageCode" select="$splLowercase"/>
        <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
      </xsl:call-template>
    </fo:block>
    <fo:block>
      <fo:table>
        <fo:table-column column-width="50%"/>
        <fo:table-column column-width="50%"/>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell>
              <fo:block space-after.optimum="15pt">
                <xsl:call-template name="splInformation">
                  <xsl:with-param name="cageCode" select="$splLowercase"/>
                  <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
                </xsl:call-template>
              </fo:block>
            </fo:table-cell>
            <fo:table-cell>
              <fo:block margin-left="0.4in" space-after.optimum="15pt">
                <xsl:call-template name="prtnrsplInformation">
                  <xsl:with-param name="cageCode" select="$prtnprSplLowercase"/>
                  <xsl:with-param name="prtnrsplLogo" select="$prtnrsplLogo_PATH"/>
                </xsl:call-template>
              </fo:block>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>

  <xsl:template name="selectPublicationTypeUpperCase">
    <xsl:choose>
      <xsl:when test="/EM/@TYPE='em'">
        <xsl:value-of select="'ENGINE MANUAL'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='lmm'">
        <xsl:value-of select="'LIGHT MAINTENANCE MANUAL'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='hmm'">
        <xsl:value-of select="'HEAVY MAINTENANCE MANUAL'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='emm'">
        <xsl:value-of select="'ENGINE MAINTENANCE MANUAL'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='rm'">
        <xsl:value-of select="'REPAIR MANUAL'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$g-doc-full-name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="selectPublicationTypeMixedCase">
    <xsl:choose>
      <xsl:when test="/EM/@TYPE='em'">
        <xsl:value-of select="'Engine Manual'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='lmm'">
        <xsl:value-of select="'Light Maintenance Manual'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='hmm'">
        <xsl:value-of select="'Heavy Maintenance Manual'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='emm'">
        <xsl:value-of select="'Engine Maintenance Manual'"/>
      </xsl:when>
      <xsl:when test="/EM/@TYPE='rm'">
        <xsl:value-of select="'Repair Manual'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$g-doc-full-name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="pgblk-title">
    <xsl:param name="pgblknbr"/>
    <xsl:choose>      
      <xsl:when test="number($pgblknbr) = 0">
        <xsl:text>INTRODUCTION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 1">
        <xsl:text>DESCRIPTION AND OPERATION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 1000">
        <xsl:text>TESTING AND FAULT ISOLATION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 2000">
        <xsl:text>SCHEMATIC AND WIRING DIAGRAMS</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 3000">
        <xsl:text>DISASSEMBLY</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 4000">
        <xsl:text>CLEANING</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 5000">
        <xsl:text>INSPECTION/CHECK</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 6000">
        <xsl:text>REPAIR</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 7000">
        <xsl:text>ASSEMBLY</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 8000">
        <xsl:text>FITS AND CLEARANCES</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 9000">
        <xsl:text>SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 10000">
        <xsl:text>ILLUSTRATED PARTS LIST</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 11000">
        <xsl:text>SPECIAL PROCEDURES</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 12000">
        <xsl:text>REMOVAL</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 13000">
        <xsl:text>INSTALLATION</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 14000">
        <xsl:text>SERVICING</xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 15000">
        <xsl:text>STORAGE (INCLUDING TRANSPORTATION)"></xsl:text>
      </xsl:when>
      <xsl:when test="number($pgblknbr) = 16000">
        <xsl:text>REWORK (SERVICE BULLETIN ACCOMPLISHMENT PROCEDURES)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>PAGEBLOCK </xsl:text><xsl:value-of select="$pgblknbr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="convert-date">
    <xsl:param name="ata-date"/>
    <xsl:variable name="month-string">
      <xsl:if test="string(substring(string($ata-date),5,2))='01'"> Jan </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='02'"> Feb </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='03'"> Mar </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='04'"> Apr </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='05'"> May </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='06'"> Jun </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='07'"> Jul </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='08'"> Aug </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='09'"> Sep </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='10'"> Oct </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='11'"> Nov </xsl:if>
      <xsl:if test="string(substring(string($ata-date),5,2))='12'"> Dec </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="substring(string($ata-date),7,1)='0'">
        <xsl:value-of select="string(substring(string($ata-date),8,1))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="string(substring(string($ata-date),7,2))"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="concat($month-string,' ')"/>
    <xsl:value-of select="string(substring(string($ata-date),1,4))"/>
  </xsl:template>


  <xsl:template name="calc-table-number">
    <!-- Tables in PGBLK 0 and 1 are numbered starting with 1 -->
    <!-- Tables inside of PGBLK are numbered start at 1 + @PGBLKNBR -->
    <xsl:variable name="table-number-base">
      <xsl:choose>
        <xsl:when test="ancestor::PGBLK/@PGBLKNBR &gt; 1">
          <xsl:value-of select="ancestor::PGBLK/@PGBLKNBR"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="table-position">
      <xsl:choose>
        <!-- pnwoha 4/10/2012 ocshonss-501.  Tables inside <gdesc> should not be counted -->
        <xsl:when test="ancestor::PGBLK">
          <xsl:value-of select="1 + count(ancestor::PGBLK//TABLE[TITLE][not (ancestor::GDESC)] intersect preceding::TABLE[TITLE][not (ancestor::GDESC)])"/>
        </xsl:when>
        <xsl:when test="ancestor::INTRO">
          <xsl:value-of select="1 + count(ancestor::INTRO//TABLE[TITLE][not (ancestor::GDESC)] intersect preceding::TABLE[TITLE][not (ancestor::GDESC)])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1 + count(preceding::TABLE[TITLE][not (ancestor::GDESC)])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--<xsl:value-of select="number($table-number-base + $table-position)"/>-->
    <!--Changes made by Nathan -->
    <xsl:choose>
      <xsl:when test="./ancestor::TRANSLTR">
        <xsl:value-of select="concat('TI-', number($table-number-base + $table-position))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="number($table-number-base + $table-position)"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- End of changes made by Nathan -->
  </xsl:template>

  <!-- Called in the context of the placeholder "TABLE" element -->
  <!-- Called in the context of the placeholder "TABLE" element -->
  <xsl:template name="consumables-table">
    <fo:block>
      <xsl:attribute name="margin-left">
        <xsl:call-template name="calculateTableOffset"/>
      </xsl:attribute>

      <fo:block font-weight="bold" text-align="center" keep-with-next.within-page="always">
        <xsl:text>Table </xsl:text>
        <xsl:call-template name="calc-table-number"/>
        <xsl:text>. Consumables</xsl:text>
      </fo:block>
      <fo:table rx:table-omit-initial-header="true">
        <xsl:attribute name="id" select="@ID"/>
        <fo:table-column column-width="6.78in"/>
        <fo:table-header text-align="center">
          <fo:table-cell padding="0pt">
            <fo:block space-before="0pt" space-after="2pt" text-align="center" font-family="Arial" font-weight="bold">
              <xsl:text>Table </xsl:text>
              <xsl:call-template name="calc-table-number"/>
              <xsl:text>. Consumables (Cont)</xsl:text>
            </fo:block>
          </fo:table-cell>
        </fo:table-header>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell text-align="left" padding="4pt">

              <fo:table>
                <xsl:attribute name="id">
                  <xsl:value-of select="@KEY"/>
                </xsl:attribute>
                <fo:table-column column-number="1" column-width="2.26in"/>
                <fo:table-column column-number="2" column-width="2.26in"/>
                <fo:table-column column-number="3" column-width="2.26in"/>
                <fo:table-header>
                  <fo:table-cell font-weight="bold" text-align="center" display-align="after" xsl:use-attribute-sets="default.table.cell">
                    <fo:block>
                      <xsl:text>Number</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell font-weight="bold" text-align="center" display-align="after" xsl:use-attribute-sets="default.table.cell">
                    <fo:block>
                      <xsl:text>Description</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell font-weight="bold" text-align="center" display-align="after" xsl:use-attribute-sets="default.table.cell">
                    <fo:block>
                      <xsl:text>Source</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-header>

                <fo:table-body font-weight="normal">

                  <xsl:for-each select="ancestor::PGBLK//CON">
                    <xsl:sort select="normalize-space(CONNBR)"/>
                    <xsl:sort select="normalize-space(CONNAME)"/>
                    <xsl:variable name="thisNum" select="normalize-space(CONNBR)"/>
                    <xsl:variable name="thisName" select="normalize-space(CONNAME)"/>
                    <!-- Count preceding consumables within this PGBLK, and only include for the first one 
                          that is encountered -->
                    <xsl:if test="0 = count((preceding::CON intersect  ancestor::PGBLK/descendant::CON) 
                                                [normalize-space(CONNBR) = $thisNum and 
                                                normalize-space(CONNAME) = $thisName])">

                      <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="default.table.cell">
                          <fo:block>
                            <xsl:value-of select="CONNBR"/>
                          </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="default.table.cell">
                          <fo:block>
                            <xsl:value-of select="CONNAME"/>
                            <xsl:if test="CONDESC and normalize-space(CONDESC) != ''">
                              <xsl:text> (</xsl:text>
                              <xsl:value-of select="CONDESC"/>
                              <xsl:text>)</xsl:text>
                            </xsl:if>
                          </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="default.table.cell">
                          <fo:block>
                            <xsl:value-of select="CONSRC"/>
                          </fo:block>
                        </fo:table-cell>
                      </fo:table-row>
                    </xsl:if>
                  </xsl:for-each>
                </fo:table-body>
              </fo:table>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>


  <!-- Called in the context of the placeholder "TABLE" element -->
  <xsl:template name="spectools-table">
    <fo:block>
      <xsl:attribute name="margin-left">
        <xsl:call-template name="calculateTableOffset"/>
      </xsl:attribute>

      <fo:block font-weight="bold" text-align="center" keep-with-next.within-page="always">
        <xsl:text>Table </xsl:text>
        <xsl:call-template name="calc-table-number"/>
        <xsl:value-of select="concat('. ',$special-tools-title)"/>
      </fo:block>
      <fo:table rx:table-omit-initial-header="true">
        <xsl:attribute name="id" select="@ID"/>
        <fo:table-column column-width="6.78in"/>
        <fo:table-header>
          <fo:table-cell padding="0pt">
            <fo:block space-before=".0in" space-after="5.7pt" text-align="center" font-family="Arial" font-weight="bold">
              <xsl:text>Table </xsl:text>
              <xsl:call-template name="calc-table-number"/>
              <xsl:value-of select="concat('. ',$special-tools-title,' (Cont)')"/>
            </fo:block>
          </fo:table-cell>
        </fo:table-header>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell text-align="left" padding="4pt">
              <fo:table>
                <xsl:attribute name="id">
                  <xsl:value-of select="@KEY"/>
                </xsl:attribute>
                <fo:table-column column-number="1" column-width="2.26in"/>
                <fo:table-column column-number="2" column-width="2.26in"/>
                <fo:table-column column-number="3" column-width="2.26in"/>
                <fo:table-header>
                  <fo:table-cell font-weight="bold" text-align="center" display-align="after" xsl:use-attribute-sets="default.table.cell">
                    <fo:block>
                      <xsl:text>Number</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell font-weight="bold" text-align="center" display-align="after" xsl:use-attribute-sets="default.table.cell">
                    <fo:block>
                      <xsl:text>Description</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell font-weight="bold" text-align="center" display-align="after" xsl:use-attribute-sets="default.table.cell">
                    <fo:block>
                      <xsl:text>Source</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-header>
                <fo:table-body>

                  <xsl:for-each select="ancestor::PGBLK//TED">
                    <xsl:sort select="normalize-space(TOOLNBR)"/>
                    <xsl:sort select="normalize-space(TOOLNAME)"/>
                    <xsl:variable name="thisNum" select="normalize-space(TOOLNBR)"/>
                    <xsl:variable name="thisName" select="normalize-space(TOOLNAME)"/>
                    <!-- Count preceding consumables within this PGBLK, and only include for the first one 
                          that is encountered -->
                    <xsl:if test="0 = count((preceding::TED intersect  ancestor::PGBLK/descendant::TED) 
                                                [normalize-space(TOOLNBR) = $thisNum and 
                                                normalize-space(TOOLNAME) = $thisName])">

                      <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="default.table.cell">
                          <fo:block>
                            <xsl:value-of select="TOOLNBR"/>
                          </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="default.table.cell">
                          <fo:block>
                            <xsl:value-of select="TOOLNAME"/>
                            <xsl:if test="TOOLDESC and normalize-space(TOOLDESC) != ''">
                              <xsl:text> (</xsl:text>
                              <xsl:value-of select="TOOLDESC"/>
                              <xsl:text>)</xsl:text>
                            </xsl:if>
                          </fo:block>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="default.table.cell">
                          <fo:block>
                            <xsl:value-of select="TOOLSRC"/>
                          </fo:block>
                        </fo:table-cell>
                      </fo:table-row>
                    </xsl:if>
                  </xsl:for-each>
                </fo:table-body>
              </fo:table>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>

  <!-- Get the text of the figure caption -->
  <xsl:template name="figure-caption-bookmark">
    <xsl:text>Figure </xsl:text>
    <xsl:call-template name="calc-figure-number"/>
    <xsl:text>. (Sheet </xsl:text>
    <xsl:number format="1" value="1 + count(preceding-sibling::SHEET)"/>
    <xsl:text> of </xsl:text>
    <xsl:value-of select="count(./parent::GRAPHIC/SHEET)"/>
    <xsl:text>) </xsl:text>
    <xsl:if test="./parent::GRAPHIC/TITLE">
      <xsl:apply-templates select="./parent::GRAPHIC/TITLE" mode="graphic-title"/>
    </xsl:if>
  </xsl:template>

  <!-- Expects SHEET as current context -->
  <xsl:template name="figure-caption">
    <xsl:variable name="caption-id">
      <xsl:value-of select="concat('figcap_',@KEY)"/>
    </xsl:variable>

    <xsl:variable name="revised-title">
      <xsl:for-each select="preceding-sibling::TITLE">
        <xsl:choose>
          <xsl:when test="preceding-sibling::node()[1][.='_rev']  and following-sibling::node()[1][.='/_rev']">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <fo:block text-align="center" font-family="Arial" font-weight="bold" page-break-before="avoid" id="{$caption-id}">
      <xsl:if test="$revised-title = 'true'">
        <xsl:call-template name="cbStart"/>
      </xsl:if>
      <xsl:text>Figure </xsl:text>
      <xsl:call-template name="calc-figure-number"/>

      <!-- For DEBUG print the GNBR in the figure caption -->
      <xsl:if test="number($DEBUG) = 1">
        <fo:inline font-weight="bold" color="#00ffff">
          <xsl:value-of select="concat(' [',@GNBR,'] ')"/>
        </fo:inline>
      </xsl:if>


      <xsl:text>. (Sheet </xsl:text>
      <xsl:number format="1" value="1 + count(preceding-sibling::SHEET)"/>
      <xsl:text> of </xsl:text>
      <xsl:value-of select="count(./parent::GRAPHIC/SHEET)"/>
      <xsl:text>) </xsl:text>
      <xsl:if test="./parent::GRAPHIC/TITLE">
        <xsl:apply-templates select="./parent::GRAPHIC/TITLE" mode="graphic-title"/>
      </xsl:if>
      <fo:inline font-weight="bold">
        <!--<xsl:value-of select="TITLE"/>-->
        <xsl:apply-templates select="TITLE"/>
      </fo:inline>
      <fo:inline color="#000000" font-weight="normal">
        <xsl:value-of select="concat('(GRAPHIC ', ../@CHAPNBR, 
                  '-', ../@SECTNBR, 
                  '-', ../@SUBJNBR, 
                  '-', ../@FUNC,
                  '-', ../@SEQ,
                  '-',../@CONFLTR,../@VARNBR,')')"/>
      </fo:inline>
      <xsl:if test="$revised-title = 'true'">
        <xsl:call-template name="cbEnd"/>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template name="calc-figure-number">
    <!-- Tables in PGBLK 0 and 1 are numbered starting with 1 -->
    <!-- Tables inside of PGBLK are numbered start at 1 + @PGBLKNBR -->
    <xsl:variable name="figure-number-base">
      <xsl:choose>
        <xsl:when test="ancestor::PGBLK/@PGBLKNBR &gt; 1">
          <xsl:value-of select="ancestor::PGBLK/@PGBLKNBR"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="figure-position">
      <xsl:choose>
        <xsl:when test="ancestor::PGBLK">
          <xsl:value-of select="1 + count(ancestor::PGBLK//GRAPHIC intersect preceding::GRAPHIC)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1 + count(preceding::GRAPHIC)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="number($figure-number-base + $figure-position)"/>
  </xsl:template>
</xsl:stylesheet>
