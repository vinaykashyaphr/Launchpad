<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table"
                              xmlns:itg="http://www.infotrustgroup.com">

  <xsl:output method="xml" encoding="UTF-8" indent="yes"></xsl:output>

  <xsl:function name="itg:escape-path">
    <xsl:param name="path"/>
    <xsl:variable name="path1">
      <xsl:value-of select="replace($path,'\[','%5B')"/>
    </xsl:variable>
    <xsl:variable name="path2">
      <xsl:value-of select="replace($path1,'\]','%5D')"/>
    </xsl:variable>
    <xsl:variable name="path3">
      <xsl:value-of select="replace($path2,' ','%20')"/>
    </xsl:variable>
    <xsl:variable name="path4">
      <xsl:value-of select="replace($path3,'&amp;','%26')"/>
    </xsl:variable>
    <xsl:variable name="path5">
      <xsl:value-of select="replace($path4,'\\','/')">
      </xsl:value-of>
    </xsl:variable>
    <xsl:value-of select="$path5"/>
  </xsl:function>


  <!-- This template contains global variables used by the EM set of stylesheets -->
  
  <!-- Path for parameters passed into the processor -->
  <xsl:param name="GRAPHICS_DIR">file:///C:/Format_Work/XSL_EM_Baseline1/graphics</xsl:param>
  <xsl:param name="IMAGES_DIR">file:///C:/Format_Work/XSL_EM_Baseline1/images</xsl:param>
  
  <xsl:param name="DEBUG">0</xsl:param>
  
  <!-- Prints messages with start and stop XPath locations when revars are processed -->
  <xsl:param name="REVBAR_DEBUG">0</xsl:param>
  
  <!-- Controls whether the data necessary for building the list of effective pages 
is styled into the intermediate file -->
  
  <xsl:param name="LEP_PASS">0</xsl:param>
  
  <!-- CV - must set an arbitrary place holder path value, otherwise itg:escape-path() will cause errors
            when this XSLT script included when not passing LEP_EXTRACT_FILE parameter
            -->
  <xsl:param name="LEP_EXTRACT_FILE">file:///C:/Honeywell_Print/Honeywell_XSL-FO/shared/place-holder.xml</xsl:param>
  <xsl:param name="LEP_RENDER_FILE"/>

  <xsl:param name="SUMMARY_LEP" select="1" />
  
  <xsl:variable name="documentType" select="lower-case(/*/@TYPE)"/>

  <xsl:variable name="initialPageNumber">
    <xsl:choose>
      <xsl:when test="$documentType = 'acmm'">
        <xsl:value-of select="'auto'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'1'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="forcePageCount">
    <xsl:choose>
      <xsl:when test="$documentType = 'acmm'">
        <xsl:value-of select="'no-force'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'even'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:param name="graphicSuffix">tif</xsl:param>
  <xsl:variable name="logoDir" select="$IMAGES_DIR" />

  <xsl:variable name="front_body_count" >
    <xsl:choose>
      <xsl:when test="$documentType = 'acmm'">
        <xsl:value-of select="count(document(itg:escape-path($LEP_EXTRACT_FILE))//page[string-length(@position) &gt; 0]) + count(document(itg:escape-path($LEP_EXTRACT_FILE))//page[@foldout = 'F'])"/>

      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(document(itg:escape-path($LEP_EXTRACT_FILE))//page[string-length(@position) &gt; 0])"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="draftDate">
    <xsl:variable name="month">
      <xsl:variable name="numericMonth" select="tokenize(string(current-date()),'-')[2]"/>
      <xsl:choose>
        <xsl:when test="$numericMonth='01'">Jan</xsl:when>
        <xsl:when test="$numericMonth='02'">Feb</xsl:when>
        <xsl:when test="$numericMonth='03'">Mar</xsl:when>
        <xsl:when test="$numericMonth='04'">Apr</xsl:when>
        <xsl:when test="$numericMonth='05'">May</xsl:when>
        <xsl:when test="$numericMonth='06'">Jun</xsl:when>
        <xsl:when test="$numericMonth='07'">Jul</xsl:when>
        <xsl:when test="$numericMonth='08'">Aug</xsl:when>
        <xsl:when test="$numericMonth='09'">Sep</xsl:when>
        <xsl:when test="$numericMonth='10'">Oct</xsl:when>
        <xsl:when test="$numericMonth='11'">Nov</xsl:when>
        <xsl:when test="$numericMonth='12'">Dec</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="day" select="tokenize(string(current-date()),'-')[3]"/>
    <xsl:variable name="year" select="tokenize(string(current-date()),'-')[1]"/>
    <xsl:value-of select="concat($day,' ',$month,' ',$year)"/>
  </xsl:variable>
  
  
  <!-- Variables for filling in document-level fields -->
  <xsl:variable name="g-doc-full-name">
    <xsl:choose>

      <!-- Sonovision update (2018.12.14)
           - as per Honeywell request: adding support for @type="mm"
             -->
      <xsl:when test="lower-case(/CMM/@TYPE) = 'mm'">MAINTENANCE MANUAL</xsl:when>

      <xsl:when test="(lower-case(/CMM/@TYPE) = 'cmm') and 
                      (normalize-space(upper-case(/CMM/TITLE[1])) = 'MAINTENANCE MANUAL')">MAINTENANCE MANUAL</xsl:when>

      <xsl:when test="lower-case(/EM/@TYPE) = 'lmm'">LIGHT MAINTENANCE MANUAL</xsl:when>
      <xsl:when test="lower-case(/EM/@TYPE) = 'hmm'">HEAVY MAINTENANCE MANUAL</xsl:when>
      <xsl:when test="lower-case(/EM/@TYPE) = 'em'">ENGINE MANUAL</xsl:when>
      <xsl:when test="lower-case(/EM/@TYPE) = 'emm'">ENGINE MAINTENANCE MANUAL</xsl:when>
      <xsl:when test="lower-case(/EM/@TYPE) = 'rm'">REPAIR MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'acmm'">ABBREVIATED COMPONENT MAINTENANCE MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'cmm'">COMPONENT MAINTENANCE MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'irm'">INSPECTION/REPAIR MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'gem'">GROUND EQUIPMENT MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'rm'">REPAIR MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'orim'">OVERHAUL REPAIR INSTRUCTION MANUAL</xsl:when>
      <xsl:when test="lower-case(/CMM/@TYPE) = 'ohm'">OVERHAUL MANUAL</xsl:when>


      <xsl:otherwise>Manual Type Not Set</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- We do not seem to be making a distinction at the moment -->
  <xsl:variable name="g-doc-abbr-name">
    <xsl:value-of select="$g-doc-full-name"/>
  </xsl:variable>
  
  <xsl:variable name="g-lower-case" select="'abcdefghijklmnopqrstuvwxyz'"/>
  <xsl:variable name="g-upper-case" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
  
  <xsl:variable name="special-tools-key">Special Tools, Fixtures, and Equipment</xsl:variable>
  <xsl:variable name="special-tools-title">Special Tools, Fixtures, and Equipment</xsl:variable>
  <xsl:variable name="consumables-key">Consumables</xsl:variable>
  <xsl:variable name="consumables-title">Consumables</xsl:variable>

  <xsl:variable name="g-copyright-title" select="'Copyright - Notice'"/>
  <xsl:variable name="copyright-statement">
    <xsl:choose>
      <xsl:when test="/*/@SPL = '6NBA7'">
        <xsl:value-of select="'&#x00A9;&#160;Flatirons Solutions, Inc.  All Rights Reserved.'"/>
      </xsl:when>
      <xsl:when test="/*/@SPL = '1Y4Q3'">
        <xsl:value-of select="'&#x00A9;&#160;Shaw Aerox LLC.  All Rights Reserved.'"/>
      </xsl:when>
      <xsl:when test="/*/@SPL = 'U6578'">
        <xsl:value-of select="'&#x00A9;&#160;Meggitt Control Systems Birmingham.  All Rights Reserved.'"/>
      </xsl:when>
      <xsl:when test="/*/@SPL = '07217'">
        <xsl:value-of select="'&#x00A9;&#160;Honeywell Limited.  Do not copy without express permission of Honeywell.'"/>
      </xsl:when>
      <xsl:when test="/*/@SPL = '0s4a8'">
        <xsl:value-of select="'&#x00A9;&#160;CFE Company. Do not copy without express permission of the CFE Company.'"/>
      </xsl:when>
      <xsl:when test="/*/@SPL = 'L4578'">
        <xsl:value-of select="'&#x00A9;&#160;Sonovision Canada Inc. Do not copy without express permission of Sonovision Canada Inc.'"/>
      </xsl:when>										 																		 
      <xsl:otherwise>
        <xsl:value-of select="'&#x00A9;&#160;Honeywell International Inc.  Do not copy without express permission of Honeywell.'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="g-chap-sect-subj" select="concat(/*/@CHAPNBR,'-',/*/@SECTNBR,'-',/*/@SUBJNBR)"/>
  <xsl:variable name="g-toc-title" select="'TABLE OF CONTENTS'"/>
  <xsl:variable name="g-toc-sect-subtitle" select="'LIST OF SECTIONS'"/>
  <xsl:variable name="g-toc-fig-subtitle" select="'LIST OF FIGURES'"/>
  <xsl:variable name="g-toc-table-subtitle" select="'LIST OF TABLES'"/>
  <xsl:variable name="g-cont-suffix" select="' (Cont)'"/>
  
  
  <xsl:variable name="lowerCase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="upperCase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  
  
  <xsl:variable name="globalExtObj_logo">
    <xsl:value-of select="concat($logoDir, './hwell.tif')"/>
  </xsl:variable>
  
  <xsl:variable name="globalExtObj_Cfelogo">
    <xsl:value-of select="concat($logoDir, '/hwell.tif')"/>
  </xsl:variable>
  
  <xsl:variable name="overlayFormatStyle" 
    select="translate(/*/@OVERLAYFORMATSTYLE, $upperCase,$lowerCase)" />
  
  <xsl:variable name="splLowercase"><xsl:value-of select="translate((/*/@SPL), $upperCase,$lowerCase)"/></xsl:variable>
  <xsl:variable name="prtnprSplLowercase"><xsl:value-of select="translate((/*/@PRTNRSPL), $upperCase,$lowerCase)"/></xsl:variable>
  <xsl:variable name="globalRegionbodyWatermark">
    <xsl:choose>
      <xsl:when test="$overlayFormatStyle = 'draft'">url('<xsl:value-of select="concat($logoDir, '/Draft_overlay.jpg')"/>')</xsl:when>
      <xsl:when test="$overlayFormatStyle = 'preliminary'">url('<xsl:value-of select="concat($logoDir, '/preliminary.jpg')"/>')</xsl:when>
      <xsl:when test="$overlayFormatStyle = 'validation'">url('<xsl:value-of select="concat($logoDir, '/validation.jpg')"/>')</xsl:when>
      <xsl:otherwise>none</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
   
  <!-- Sonovision update (2018.12.03) to include cage code: f0302 -->
  <!-- Honeywell update (2020.05.11) to include cage code: 0bfa5 and 94580 -->
  <xsl:param name="splLogo_PATH">'
    <xsl:choose>
      <xsl:when test="$splLowercase = '6nba7'"><xsl:value-of select="concat($logoDir, '/fsi.png')"/></xsl:when>
      <xsl:when test="$splLowercase = '1y4q3'"><xsl:value-of select="concat($logoDir, '/aeroxLogo.png')"/></xsl:when>
      <xsl:when test="$splLowercase = 'u6578'"><xsl:value-of select="concat($logoDir, '/meggittlogo.png')"/></xsl:when>
      <xsl:when test="$splLowercase = '0s4a8'"><xsl:value-of select="concat($logoDir, '/cfe_Logo.png')"/></xsl:when>
      <xsl:when test="$splLowercase = '6pc31'"><xsl:value-of select="concat($logoDir, '/BendixKing.jpg')"/></xsl:when>
      <xsl:when test="$splLowercase = 'f0302'"><xsl:value-of select="concat($logoDir, '/hispano.jpg')"/></xsl:when>
      <xsl:when test="(($splLowercase='07217') or ($splLowercase='65507') or ($splLowercase='1std7') or ($splLowercase='99866') or ($splLowercase='22373') or ($splLowercase='55939') or ($splLowercase='58960') or ($splLowercase='63389') or ($splLowercase='99193') or ($splLowercase='97896') or ($splLowercase='0yfp0') or ($splLowercase='27914') or ($splLowercase='56081') or ($splLowercase='55284') or ($splLowercase='06848') or ($splLowercase='59364') or ($splLowercase='70210') or ($splLowercase='64547') or ($splLowercase='72914') or ($splLowercase='1m8l7') or ($splLowercase='kf586') or ($splLowercase='0ug66') or ($splLowercase='31395') or ($splLowercase='5vwn5') or ($splLowercase='56776') or ($splLowercase='38473') or ($splLowercase='u1605') or ($splLowercase='0bfa5') or ($splLowercase='94580'))">
        <xsl:value-of select="concat($logoDir, '/hwell.tif')"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>'
  </xsl:param>
  
  <xsl:param name="prtnrsplLogo_PATH">
    <xsl:choose>
      <xsl:when test="(($prtnprSplLowercase = '65507') or ($prtnprSplLowercase = '55939') or ($prtnprSplLowercase = '58960'))">
        <xsl:value-of select="concat($logoDir, '/hwell.tif')"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <!-- End of global variables and parameters -->
  
  <!-- Shared attribute sets -->
  
  <xsl:attribute-set name="list.block.attributes">
    <xsl:attribute name="space-before">.01in</xsl:attribute>
    <xsl:attribute name="space-after.optimum">.01in</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="list.listblock.attributes">
    <xsl:attribute name="provisional-distance-between-starts">.33in</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">.1in</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="list.vertical.space">
    <xsl:attribute name="space-before.minimum">.06in</xsl:attribute>
    <xsl:attribute name="space-before.optimum">.08in</xsl:attribute>
    <xsl:attribute name="space-before.maximum">.10in</xsl:attribute>
    <xsl:attribute name="space-after.minimum">.06in</xsl:attribute>
    <xsl:attribute name="space-after.optimum">.08in</xsl:attribute>
    <xsl:attribute name="space-after.maximum">.10in</xsl:attribute> 
  </xsl:attribute-set>

</xsl:stylesheet>
