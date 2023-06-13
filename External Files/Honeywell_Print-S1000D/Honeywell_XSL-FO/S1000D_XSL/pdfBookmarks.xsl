<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:template name="do-pdf-bookmarks">
    <rx:outline>

      <rx:bookmark internal-destination="cmm_title_page">
        <rx:bookmark-label>
          <xsl:text>TITLE</xsl:text>
        </rx:bookmark-label>
      </rx:bookmark>

      <!--TRANSMITTAL INFORMATION-->
      <rx:bookmark internal-destination="{/pm/content/pmEntry[@pmEntryType='pmt52']/@id}"><!-- transltr  -->
        <rx:bookmark-label>
          <xsl:choose>
            <!-- <xsl:when test="/CMM/MFMATR/TRANSLTR/TITLE">
              <xsl:value-of select="/CMM/MFMATR/TRANSLTR/TITLE"/> -->
            <xsl:when test="/pm/content/pmEntry[@pmEntryType='pmt52']/pmEntryTitle">
              <xsl:value-of select="/pm/content/pmEntry[@pmEntryType='pmt52']/pmEntryTitle"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>TRANSMITTAL INFORMATION</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </rx:bookmark-label>
      </rx:bookmark>

      <!--RECORD OF REVISIONS-->
      <xsl:choose>
        <xsl:when test="$documentType = 'acmm'">
          <!-- <xsl:message>No PDF bookmark for RR in ACMM</xsl:message> -->
        </xsl:when>
        <xsl:otherwise>
          <rx:bookmark internal-destination="{/pm/content/pmEntry[@pmEntryType='pmt53']/@id}">
            <rx:bookmark-label>
              <xsl:text>RECORD OF REVISIONS</xsl:text>
            </rx:bookmark-label>
          </rx:bookmark>
        </xsl:otherwise>
      </xsl:choose>

      <!--RECORD OF TEMPORARY REVISIONS-->
      <xsl:choose>
        <xsl:when test="$documentType = 'acmm'">
          <!-- <xsl:message>No PDF bookmark for RTR in ACMM</xsl:message> -->
        </xsl:when>
        <xsl:otherwise>
          <rx:bookmark internal-destination="{/pm/content/pmEntry[@pmEntryType='pmt54']/@id}">
            <rx:bookmark-label>
              <xsl:choose>
                <xsl:when test="/pm/content/pmEntry[@pmEntryType='pmt54']/pmEntryTitle">
                  <xsl:value-of select="/pm/content/pmEntry[@pmEntryType='pmt54']/pmEntryTitle"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>TEMPORARY REVISION LIST</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </rx:bookmark-label>
          </rx:bookmark>
        </xsl:otherwise>
      </xsl:choose>

      <!--SERVICE BULLETIN LIST-->
      <xsl:choose>
        <xsl:when test="($documentType = 'acmm') and (descendant::ISEMPTY)">
          <!-- <xsl:message>No PDF bookmark for empty SBL in ACMM</xsl:message> -->
        </xsl:when>
        <xsl:otherwise>
          <rx:bookmark internal-destination="{/pm/content/pmEntry[@pmEntryType='pmt55']/@id}">
            <xsl:variable name="title">
              <xsl:choose>
                <xsl:when test="/CMM/MFMATR/SBLIST/TITLE">
                  <xsl:value-of select="/CMM/MFMATR/SBLIST/TITLE"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>SERVICE BULLETIN LIST</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <rx:bookmark-label>
              <xsl:value-of select="$title"/>
            </rx:bookmark-label>
          </rx:bookmark>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="$documentType = 'acmm'">
          <!-- <xsl:message>No PDF bookmark for LEP in ACMM</xsl:message> -->
        </xsl:when>
        <xsl:otherwise>
          <rx:bookmark internal-destination="lep_frontmatter">
            <rx:bookmark-label>LIST OF EFFECTIVE PAGES</rx:bookmark-label>
          </rx:bookmark>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="$documentType = 'acmm'">
          <!-- <xsl:message>No PDF bookmark for TOC in ACMM</xsl:message> -->
        </xsl:when>
        <xsl:otherwise>
          <rx:bookmark internal-destination="intro_toc">
            <rx:bookmark-label>TABLE OF CONTENTS</rx:bookmark-label>
          </rx:bookmark>
        </xsl:otherwise>
      </xsl:choose>

      <!-- "Pageblocks" (top-level pmEntries after and including the Introduction, or first IM/SDIM/SDOM section). -->
      <!-- Added pmt91 as first section in IM/SDIM/SDOM -->
      <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
      <!-- <xsl:apply-templates select="/pm/content/pmEntry[@pmEntryType='pmt58'
        or preceding-sibling::pmEntry[@pmEntryType='pmt58']
        or @pmEntryType='pmt91'
        or preceding-sibling::pmEntry[@pmEntryType='pmt91']]" mode="pdfBookmark"/> -->
      <xsl:apply-templates select="/pm/content/pmEntry[not(@isFrontmatter='1')]" mode="pdfBookmark"/>

    </rx:outline>
  </xsl:template>

  <xsl:template match="pmEntry" mode="pdfBookmark">
    <xsl:choose>
      <!-- The following may not be applicable for S1000D.... leave for reference -->
      <!-- UPDATE: Now need to apply the special IRM bookmark nesting (see sample "518321_IRM_bookmarks"). --> 
      <!-- For example, for pmt80 ("CONTINUE-TIME INSPECTION/CHECK"), create a parent "CONTINUE-TIME CHECK" bookmark to house all -->
      <!-- pmt80 pgblks that have an authorityName. -->
      
      <!-- Handle all IRM special sections with authorityName differently (need bookmark "wrappers"): -->
      <!-- <xsl:when test="$documentType = 'irm' and (@PGBLKNBR = '5000' or @PGBLKNBR = '6000') and (number(@CONFNBR) &gt;= 1000)"> -->
      <xsl:when test="$documentType = 'irm' and (@authorityName and not(@authorityName = ''))
        and (@pmEntryType='pmt80' or @pmEntryType='pmt81' or @pmEntryType='pmt79' or @pmEntryType='pmt83')">
        
        <xsl:choose>
	      <!-- Apply special IRM bookmark wrappers only for the first instance of each special type. -->
          <xsl:when test="@pmEntryType='pmt80'
            and not(preceding-sibling::pmEntry[1][@pmEntryType='pmt80' and (@authorityName and not(@authorityName = ''))])">
            <!-- Apply the bookmark wrapper and process all the appropriate pmEntries. -->
            <xsl:call-template name="irmSpecialSection">
              <xsl:with-param name="sectionName" select="'CONTINUE-TIME CHECK'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="@pmEntryType='pmt81' and not(preceding-sibling::pmEntry[1][@pmEntryType='pmt81'
            and (@authorityName and not(@authorityName = ''))])">
            <xsl:call-template name="irmSpecialSection">
              <xsl:with-param name="sectionName" select="'ZERO-TIME CHECK'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="@pmEntryType='pmt79' and not(preceding-sibling::pmEntry[1][@pmEntryType='pmt79'
            and (@authorityName and not(@authorityName = ''))])">
            <xsl:call-template name="irmSpecialSection">
              <xsl:with-param name="sectionName" select="'INSPECTION/CHECK'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="@pmEntryType='pmt83'
            and not(preceding-sibling::pmEntry[1][@pmEntryType='pmt83' and (@authorityName and not(@authorityName = ''))])">
            <xsl:call-template name="irmSpecialSection">
              <xsl:with-param name="sectionName" select="'REPAIR'"/>
            </xsl:call-template>
          </xsl:when>
          <!-- <xsl:when test="self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 1000][number(@CONFNBR) &lt; 2000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000'][number(@CONFNBR) &lt; 1000]">
          <xsl:call-template name="irmBookmarks">
            <xsl:with-param name="section" select="'inspectionCheck'"/>
          </xsl:call-template>
        </xsl:when>
          <xsl:when test="self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 2000][number(@CONFNBR) &lt; 3000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000'][number(@CONFNBR) &lt; 2000]">
          <xsl:call-template name="irmBookmarks">
            <xsl:with-param name="section" select="'cpRepair'"/>
          </xsl:call-template>
        </xsl:when>
          <xsl:when test="self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 3000][number(@CONFNBR) &lt; 4000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000'][number(@CONFNBR) &lt; 3000]">
          <xsl:call-template name="irmBookmarks">
            <xsl:with-param name="section" select="'periodicInspection'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="self::PGBLK[@PGBLKNBR='6000'][number(@CONFNBR) >= 1000]/preceding-sibling::PGBLK[1][@PGBLKNBR='6000'][number(@CONFNBR) &lt; 1000]">
          <xsl:call-template name="irmBookmarks">
            <xsl:with-param name="section" select="'repair'"/>
          </xsl:call-template>
        </xsl:when> -->
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- Process the pmEntry regularly. -->
        <rx:bookmark internal-destination="{@id}">
          <rx:bookmark-label>
            <xsl:choose>
              <xsl:when test="ISEMPTY">
                <xsl:call-template name="pgblk-title">
                  <xsl:with-param name="pgblknbr" select="@PGBLKNBR"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <!-- RS: Exceptions for CMM Bookmarks (also used for LEP section headings): -->
                <!-- UPDATE: Don't apply these over-rides for now (it was incorrectly changing headings in an OHM sample -->
                <!-- 
                <xsl:choose>
                	<xsl:when test="@pmEntryType='pmt64'">
                		<xsl:text>INSPECTION/CHECK</xsl:text>
                	</xsl:when>
                	<xsl:when test="@pmEntryType='pmt65'">
                		<xsl:text>REPAIR</xsl:text>
                		<xsl:if test="@authorityName">
                			<xsl:text> </xsl:text><xsl:value-of select="@authorityName"/>
                		</xsl:if>
                	</xsl:when>
                	<xsl:when test="@pmEntryType='pmt66'">
                		<xsl:text>ASSEMBLY</xsl:text>
                	</xsl:when>
                	<xsl:otherwise>
		                <xsl:value-of select="upper-case(pmEntryTitle)"/>
                	</xsl:otherwise>
                </xsl:choose>-->
                
                <!-- UPDATE: Exceptions for SPM (using specialSectionName attribute added by pre-process). -->
                <!-- UPDATE: Now using the full pmEntryTitle for SPM so we keep the "Section N" prefix, which -->
                <!-- will be stripped out for the LEP (which is why this was added in the first place). -->
                <!-- Later might need to add IRM exceptions too, so leave this as a placeholder and example. -->
                <xsl:choose>
                	<!-- <xsl:when test="$documentType='spm' and @specialSectionName">
                		<xsl:value-of select="upper-case(@specialSectionName)"/>
                	</xsl:when> -->
                	<xsl:when test="$documentType='im' or $documentType='sdim' or $documentType='sdom' and not(@pmEntryType='pmt58')">
							<xsl:choose>
								<!-- Appendix -->
								<xsl:when test="@pmEntryType='pmt85'">
									<xsl:text>APPENDIX </xsl:text>
									<xsl:value-of select="@sectionNumber"/>
									<xsl:text> &#x2013; </xsl:text><!-- ndash -->
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>SECTION </xsl:text>
									<xsl:value-of select="@sectionNumber"/>
									<xsl:text> &#x2013; </xsl:text><!-- ndash -->
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="upper-case(pmEntryTitle)"/>
                	</xsl:when>
                	<xsl:otherwise>
		                <xsl:value-of select="upper-case(pmEntryTitle)"/>
                	</xsl:otherwise>
                </xsl:choose>
                
              </xsl:otherwise>
            </xsl:choose>
          </rx:bookmark-label>
          <xsl:choose>
             <!-- Logic from cmmToc.xsl: -->
             <!-- In some cases there can be proceduralSteps (and maybe levelledParas) in the first-level pmEntries. -->
             <!-- Then there should be no child pmEntries. -->
             <xsl:when test="not(pmEntry)">
               <xsl:for-each select="dmContent/dmodule/content/description/levelledPara[title] | dmContent/dmodule/content/procedure/mainProcedure/proceduralStep[title]">
                 <xsl:call-template name="subtaskBookmark">
                   <xsl:with-param name="enumerator">
                   	<xsl:choose>
                   		<xsl:when test="self::levelledPara">
                   			<!-- This count is from Styler levelledPara numbering (includes levelledParas in preceding dmodules)-->
                   			<xsl:number value="count(preceding-sibling::levelledPara) 
                   			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara)
                          + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep) + 1"
                   			  format="1."/>
                   		</xsl:when>
                   		<xsl:when test="self::proceduralStep">
                   			<xsl:variable name="procStepCounter" select="count(preceding-sibling::proceduralStep)
                   			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep)
                          + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara) + 1"/>
                   			<!-- <xsl:message>Outputting ToC entry for proceduralStep <xsl:value-of select="$procStepCounter"/></xsl:message> -->
                   			<!-- This count is from Styler proceduralStep numbering (includes procedural steps in preceding dmodules)-->
                   			<xsl:number value="$procStepCounter" format="1."/>
                   		</xsl:when>
                   	</xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="indent">2pc</xsl:with-param>
                 </xsl:call-template>
               </xsl:for-each>
             </xsl:when>
             <xsl:otherwise>
                <!-- Process the normal 2nd-level pmEntries as "tasks" -->
                <!-- UPDATE: Only provide a bookmark for those with titles. -->
          		<xsl:apply-templates select="pmEntry[pmEntryTitle]" mode="pdfBookmarkTask"/>
             </xsl:otherwise>
          </xsl:choose>
        </rx:bookmark>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This is called for second-level pmEntries within the main body sections (including introduction) -->
  <xsl:template match="pmEntry" mode="pdfBookmarkTask">
    <xsl:variable name="title">
      <xsl:apply-templates select="pmEntryTitle" mode="task-subtask-title"/>
    </xsl:variable>
    <xsl:variable name="mtoss">
      <xsl:call-template name="get-mtoss"/>
    </xsl:variable>
    <rx:bookmark internal-destination="{@id}">
      <rx:bookmark-label>
	    <!-- UPDATE: Only count pmEntries with titles. This is also how Styler works. -->
        <xsl:number value="1 + count(preceding-sibling::pmEntry[pmEntryTitle])" format="1."/>
        <xsl:value-of select="concat(' ',$title,' ',$mtoss)"/>
      </rx:bookmark-label>
      
      <!-- <xsl:apply-templates select=".//SUBTASK" mode="pdfBookmark"/> -->
      <!-- Logic borrowed from cmmToc.xsl: -->
      <xsl:for-each select="dmContent/dmodule/content/description/levelledPara[title] | dmContent/dmodule/content/procedure/mainProcedure/proceduralStep[title]">
         <xsl:call-template name="subtaskBookmark">
           <xsl:with-param name="enumerator">
           	<xsl:choose>
           		<xsl:when test="self::levelledPara">
           			<!-- This count is from Styler levelledPara numbering (includes levelledParas in preceding dmodules)-->
           			<xsl:number value="count(preceding-sibling::levelledPara) 
           			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara)
                  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep)  + 1"
           			  format="A."/>
           		</xsl:when>
           		<xsl:when test="self::proceduralStep">
           			<xsl:variable name="procStepCounter" select="count(preceding-sibling::proceduralStep)
           			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep)
                  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara) + 1"/>
           			<!-- <xsl:message>Outputting ToC entry for proceduralStep <xsl:value-of select="$procStepCounter"/></xsl:message> -->
           			<!-- This count is from Styler proceduralStep numbering (includes procedural steps in preceding dmodules)-->
           			<xsl:number value="$procStepCounter" format="A."/>
           		</xsl:when>
           	</xsl:choose>
           </xsl:with-param>
         </xsl:call-template>
      </xsl:for-each>
      
      <xsl:for-each select="pmEntry/dmContent/dmodule/content/illustratedPartsCatalog/figure">
      	<xsl:call-template name="iplFigureBookmark"/>
      </xsl:for-each>
      
    </rx:bookmark>
  </xsl:template>

  <!-- proceduralStep or levellledPara with a title is in context. -->
  <xsl:template name="subtaskBookmark">
  	<xsl:param name="enumerator"/>
    <xsl:variable name="title">
      <xsl:apply-templates select="title" mode="task-subtask-title"/>
    </xsl:variable>
    <xsl:variable name="mtoss">
      <xsl:call-template name="get-mtoss"/>
    </xsl:variable>
    <rx:bookmark internal-destination="{@id}">
      <rx:bookmark-label>
        <!-- <xsl:number value="$enumerator" format="A."/> -->
        <xsl:value-of select="concat($enumerator,' ',$title,' ',$mtoss)"/>
      </rx:bookmark-label>
    </rx:bookmark>
  </xsl:template>

  <xsl:template name="iplFigureBookmark">
    <xsl:variable name="title">
      <xsl:text>DPL Figure </xsl:text>
      <xsl:call-template name="calc-figure-number"/>
      <xsl:text> - </xsl:text>
      <!-- <xsl:apply-templates select="title" mode="task-subtask-title"/> -->
      <xsl:apply-templates select="title" mode="graphic-title"/>
    </xsl:variable>
    <rx:bookmark internal-destination="{graphic[1]/@id}">
      <rx:bookmark-label>
        <xsl:value-of select="$title"/>
      </rx:bookmark-label>
    </rx:bookmark>
  </xsl:template>
  
  <xsl:template match="FIGURE" mode="pdfBookmark">
    <xsl:variable name="title">
      <xsl:text>DPL Figure </xsl:text>
      <xsl:value-of select="@FIGNBR"/>
      <xsl:text> - </xsl:text>
      <xsl:apply-templates select="TITLE" mode="task-subtask-title"/>
    </xsl:variable>
    <rx:bookmark internal-destination="{GRAPHIC/SHEET[1]/@KEY}">
      <rx:bookmark-label>
        <xsl:value-of select="$title"/>
      </rx:bookmark-label>
    </rx:bookmark>
  </xsl:template>

  <!-- Called with the first top-level IRM special section pmEntry in context -->
  <xsl:template name="irmSpecialSection">
	<xsl:param name="sectionName" select="'[[ERROR: NO SECTION NAME SUPPLIED]]'"/>
	<xsl:variable name="pmEntryType" select="@pmEntryType"/>

      <rx:bookmark internal-destination="{@id}">
        <rx:bookmark-label>
          <xsl:value-of select="$sectionName"/>
        </rx:bookmark-label>
        <!-- <xsl:for-each select="//PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 1000 and 2000 >number(@CONFNBR)]"> -->
        <xsl:for-each select="/pm/content/pmEntry[@pmEntryType=$pmEntryType and @authorityName and not(@authorityName = '')]">
          <rx:bookmark internal-destination="{@id}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="@authorityName"/>
              <xsl:text> - </xsl:text>
              <!-- A little hard to read: get the substring after " - " and before ", PN ", from a title like: -->
              <!-- CONTINUE-TIME INSPECTION/CHECK - BALL ANNULAR BEARING, PN 58238 -->
              <!-- resulting in "BALL ANNULAR BEARING" -->
              <xsl:value-of select="substring-before(substring-after(normalize-space(pmEntryTitle), ' - '), ', PN ')"/>
            </rx:bookmark-label>
            <!-- <xsl:apply-templates select="TASK" mode="pdfBookmark"/> -->
            <xsl:apply-templates select="pmEntry[pmEntryTitle]" mode="pdfBookmarkTask"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
	
  </xsl:template>

<!-- Called with top-level pmEntry in context -->
<!-- Now not used (only irmSpecialSection above). But keep for reference modified slightly form the -->
<!-- original ATA version. -->
<xsl:template name="irmBookmarks">
  <xsl:param name="section" select="''"/>
  <xsl:choose>
    <xsl:when test="$section = 'continueTime'">
      <rx:bookmark internal-destination="{@id}">
        <rx:bookmark-label>
          <xsl:text>CONTINUE-TIME CHECK</xsl:text>
        </rx:bookmark-label>
        <!-- <xsl:for-each select="//PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 1000 and 2000 >number(@CONFNBR)]"> -->
        <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt80' and @authorityName and not(@authorityName = '')]">
          <rx:bookmark internal-destination="{@id}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="@authorityName"/>
              <xsl:text> - </xsl:text>
              <!-- A little hard to read: get the substring after " - " and before ", PN " -->
              <xsl:value-of select="substring-before(substring-after(upper-case(pmEntryTitle),' - '), ', PN ')"/>
            </rx:bookmark-label>
            <!-- <xsl:apply-templates select="TASK" mode="pdfBookmark"/> -->
            <xsl:apply-templates select="pmEntry[pmEntryTitle]" mode="pdfBookmarkTask"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:when test="$section = 'zeroTime'">
      <rx:bookmark internal-destination="{@id}">
        <rx:bookmark-label>
          <xsl:text>ZERO-TIME CHECK</xsl:text>
        </rx:bookmark-label>
        <!-- <xsl:for-each select="//PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 1000 and 2000 >number(@CONFNBR)]"> -->
        <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt81' and @authorityName and not(@authorityName = '')]">
          <xsl:call-template name="irmSpecialSection"/>
          <rx:bookmark internal-destination="{@id}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="@authorityName"/>
              <xsl:text> - </xsl:text>
              <!-- A little hard to read: get the substring after " - " and before ", PN " -->
              <xsl:value-of select="substring-before(substring-after(upper-case(pmEntryTitle),' - '), ', PN ')"/>
            </rx:bookmark-label>
            <!-- <xsl:apply-templates select="TASK" mode="pdfBookmark"/> -->
            <xsl:apply-templates select="pmEntry[pmEntryTitle]" mode="pdfBookmarkTask"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:when test="$section = 'inspectionCheck'">
      <rx:bookmark internal-destination="{@KEY}">
        <rx:bookmark-label>
          <xsl:text>INSPECTION/CHECK</xsl:text>
        </rx:bookmark-label>
        <xsl:for-each select="//PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 1000]">
          <rx:bookmark internal-destination="{@KEY}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="EFFECT"/>
              <xsl:text> - </xsl:text>
              <xsl:value-of select="TITLE"/>
            </rx:bookmark-label>
            <xsl:apply-templates select="TASK" mode="pdfBookmark"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:when test="$section = 'cpRepair'">
      <rx:bookmark internal-destination="{@KEY}">
        <rx:bookmark-label>
          <xsl:text>REPAIR</xsl:text>
        </rx:bookmark-label>
        <xsl:for-each select="//PGBLK[@PGBLKNBR='6000'][number(@CONFNBR) >= 1000]">
          <rx:bookmark internal-destination="{@KEY}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="EFFECT"/>
              <xsl:text> - </xsl:text>
              <xsl:value-of select="TITLE"/>
            </rx:bookmark-label>
            <xsl:apply-templates select="TASK" mode="pdfBookmark"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:when test="$section = 'zeroTime'">
      <rx:bookmark internal-destination="{@KEY}">
        <rx:bookmark-label>
          <xsl:text>ZERO-TIME CHECK</xsl:text>
        </rx:bookmark-label>
        <xsl:for-each select="//PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 2000 and 3000 >number(@CONFNBR)]">
          <rx:bookmark internal-destination="{@KEY}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="EFFECT"/>
              <xsl:text> - </xsl:text>
              <xsl:value-of select="substring-after(TITLE,' - ')"/>
            </rx:bookmark-label>
            <xsl:apply-templates select="TASK" mode="pdfBookmark"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:when test="$section = 'periodicInspection'">
      <rx:bookmark internal-destination="{@KEY}">
        <rx:bookmark-label>
          <xsl:text>PERIODIC INSPECTION</xsl:text>
        </rx:bookmark-label>
        <xsl:for-each select="//PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 3000 and 4000 >number(@CONFNBR)]">
          <rx:bookmark internal-destination="{@KEY}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="EFFECT"/>
              <xsl:text> - </xsl:text>
              <xsl:value-of select="substring-after(TITLE,' - ')"/>
            </rx:bookmark-label>
            <xsl:apply-templates select="TASK" mode="pdfBookmark"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:when test="$section = 'repair'">
      <rx:bookmark internal-destination="{@KEY}">
        <rx:bookmark-label>
          <xsl:text>REPAIR</xsl:text>
        </rx:bookmark-label>
        <xsl:for-each select="//PGBLK[@PGBLKNBR='6000'][number(@CONFNBR) >= 1000]">
          <rx:bookmark internal-destination="{@KEY}">
            <rx:bookmark-label>
              <xsl:text>PN </xsl:text>
              <xsl:value-of select="EFFECT"/>
              <xsl:text> - </xsl:text>
              <xsl:value-of select="substring-after(TITLE,' - ')"/>
            </rx:bookmark-label>
            <xsl:apply-templates select="TASK" mode="pdfBookmark"/>
          </rx:bookmark>
        </xsl:for-each>
      </rx:bookmark>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>
        <xsl:text>error - FOUND AN UNMATCHED IRM BOOKMARK! - </xsl:text>
        <xsl:value-of select="@KEY"/>
      </xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
</xsl:stylesheet>