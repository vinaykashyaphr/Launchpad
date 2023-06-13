<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:attribute-set name="toc.table.cell">
    <xsl:attribute name="padding-before">2pt</xsl:attribute>
    <xsl:attribute name="padding-after">2pt</xsl:attribute>
    <xsl:attribute name="border-before-style">none</xsl:attribute>
    <xsl:attribute name="border-before-width">1pt</xsl:attribute>
    <xsl:attribute name="border-after-style">none</xsl:attribute>
    <xsl:attribute name="border-after-width">1pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:variable name="toc_debug" select="false()"/>
  
  <xsl:template name="cmm-toc">
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" initial-page-number="1">
      <xsl:call-template name="init-static-content">
        <xsl:with-param name="page-prefix">
          <xsl:value-of select="'TC-'"/>
        </xsl:with-param>
        <xsl:with-param name="isChapterToc">
          <xsl:value-of select="1"/>
        </xsl:with-param>
      </xsl:call-template>
      <fo:flow flow-name="xsl-region-body">
        <xsl:if test="not(EFFECT)">
          <fo:block>
            <fo:marker marker-class-name="efftextValue">
              <xsl:value-of select="'ALL'"/>
            </fo:marker>
            <!-- Added for confnbr support (mantis #17830) -->
          </fo:block>
        </xsl:if>
        <xsl:call-template name="cmm-toc-table"/>
        <xsl:choose>
          <!-- UPDATE: For now, output LoF and LoT for IRM -->
          <xsl:when test="true()"><!-- $documentType!='irm' -->
            <xsl:if test="//figure">
              <xsl:call-template name="list-of-figures-table"/>
            </xsl:if>
            <xsl:if test="//table[title]">
              <xsl:call-template name="list-of-tables-table"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <!-- Don't output LOF or LOT for IRMs -->
          </xsl:otherwise>
        </xsl:choose>
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>

  <xsl:template name="cmm-toc-table">
    <fo:block id="intro_toc">
      <xsl:call-template name="save-revdate"/>
      <xsl:call-template name="write-toc-header">
        <xsl:with-param name="titleLine1">TABLE OF CONTENTS</xsl:with-param>
        <xsl:with-param name="titleLine2">
          <xsl:value-of select="'LIST OF SECTIONS'"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:if test="not(DELETED)">
        <fo:table rx:table-omit-initial-header="true">
          <fo:table-column column-width="100%"/>
          <fo:table-header>
            <fo:table-cell>
              <xsl:call-template name="write-toc-header">
                <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
                <xsl:with-param name="titleLine2">
                  <xsl:value-of select="'LIST OF SECTIONS (Cont)'"/>
                </xsl:with-param>
              </xsl:call-template>
            </fo:table-cell>
          </fo:table-header>
          <fo:table-body>
            <fo:table-row>
              <fo:table-cell>
                <fo:table border-width="1pt" padding="6pt">
                  <fo:table-column column-number="1" column-width="6.00in">
                  	<!-- IRM documents need more room for the page number in the second column. -->
                  	<!-- Eventually, this will need to be more flexible. -->
                  	<xsl:if test="$documentType='irm'">
                  		<xsl:attribute name="column-width">5.78in</xsl:attribute>
                  	</xsl:if>
                  </fo:table-column>
                  <fo:table-column column-number="2" column-width=".78in">
                  	<xsl:if test="$documentType='irm'">
                  		<xsl:attribute name="column-width">1.0in</xsl:attribute>
                  	</xsl:if>
                  </fo:table-column>
                  <fo:table-header display-align="after" space-after=".5in">
                    <fo:table-row>
                      <fo:table-cell border-bottom="solid black 1pt" text-align="left" font-weight="bold" padding-after="4pt">
                        <fo:block>Title</fo:block>
                      </fo:table-cell>
                      <fo:table-cell border-bottom="solid black 1pt" padding-after="4pt" text-align="right" font-weight="bold">
                        <fo:block>Page</fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                      <fo:table-cell number-columns-spanned="2" border-bottom="none" text-align="left" font-weight="bold" padding="0pt">
                        <fo:block>&#160;</fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                  </fo:table-header>
                  <fo:table-body>
                    <!-- Introduction or after; added IM/SDOM/SDIM sections (pmt91 and following) -->
                    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
                    <!-- <xsl:for-each select="/pm/content/pmEntry[
                      @pmEntryType='pmt58'
                      or preceding-sibling::pmEntry[@pmEntryType='pmt58']
                      or @pmEntryType='pmt91'
                      or preceding-sibling::pmEntry[@pmEntryType='pmt91']
                      ]">-->
                    <xsl:for-each select="/pm/content/pmEntry[not(@isFrontmatter='1')]">

                      <!-- RS: Output heading row for each top-level pmEntry including the introduction and after. -->
                      <xsl:call-template name="pgblk-row"/>
                      
                      <xsl:choose>
                      	<!-- RS: Not applicable for S1000D -->
                        <!-- <xsl:when test="ISEMPTY">
                          <xsl:call-template name="write-toc-row">
                            <xsl:with-param name="title" select="'1. Not Applicable'"/>
                            <xsl:with-param name="indent" select="'2pc'"/>
                            <xsl:with-param name="refid" select="@KEY"/>
                            <xsl:with-param name="page-number-prefix">
                              <xsl:call-template name="page-number-prefix"/>
                            </xsl:with-param>
                            <xsl:with-param name="page-number-suffix">
                              <xsl:call-template name="page-number-suffix"/>
                            </xsl:with-param>
                          </xsl:call-template>
                        </xsl:when> -->
                        
                        <!-- In some cases there can be proceduralSteps (and maybe levelledParas) in the first-level pmEntries. -->
                        <!-- Then there should be no child pmEntries. -->
                        <xsl:when test="not(pmEntry)">
                          <xsl:for-each select="dmContent/dmodule/content/description/levelledPara[title] | dmContent/dmodule/content/procedure/mainProcedure/proceduralStep[title]">
                            <xsl:call-template name="task-subtask-row">
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
                                      + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara) 
                                      + 1"/>
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
                          <!-- RS: Output 2nd level pmEntry styled as "1.", then nested content (proceduralSteps, levelledParas) -->
                          <xsl:for-each select="pmEntry">
                          
                          	  <!-- <xsl:message>Outputting ToC entry for 2nd level pmEntry <xsl:value-of select="1 + count(preceding-sibling::pmEntry)"/></xsl:message> -->
                          	  <!-- Don't output if there isn't a pmEntryTitle -->
	                          <xsl:if test="pmEntryTitle">
		                          <xsl:call-template name="task-subtask-row">
		                            <xsl:with-param name="enumerator">
		                              <xsl:number value="1 + count(preceding-sibling::pmEntry)" format="1."/>
		                            </xsl:with-param>
		                          </xsl:call-template>
	                          </xsl:if>
	                          
	                          <xsl:for-each select="dmContent/dmodule/content/description/levelledPara[title] | dmContent/dmodule/content/procedure/mainProcedure/proceduralStep[title]">
	                            <xsl:call-template name="task-subtask-row">
	                              <xsl:with-param name="enumerator">
	                              	<xsl:choose>
	                              		<xsl:when test="self::levelledPara">
	                              			<!-- This count is from Styler levelledPara numbering (includes levelledParas in preceding dmodules)-->
	                              			<xsl:number value="count(preceding-sibling::levelledPara)
	                              			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara)
                                        + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep)
                                        + 1"
	                              			  format="A."/>
	                              		</xsl:when>
	                              		<xsl:when test="self::proceduralStep">
	                              			<xsl:variable name="procStepCounter" select="count(preceding-sibling::proceduralStep)
	                              			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep) +
                                        + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara)
                                        + 1"/>
	                              			<!-- <xsl:message>Outputting ToC entry for proceduralStep <xsl:value-of select="$procStepCounter"/></xsl:message> -->
	                              			<!-- This count is from Styler proceduralStep numbering (includes procedural steps in preceding dmodules)-->
	                              			<xsl:number value="$procStepCounter" format="A."/>
	                              		</xsl:when>
	                              	</xsl:choose>
	                              </xsl:with-param>
	                              <xsl:with-param name="indent">4pc</xsl:with-param>
	                            </xsl:call-template>
	                            <!--
	                            <xsl:for-each select=".//SUBTASK">
	                              <xsl:call-template name="task-subtask-row">
	                                <xsl:with-param name="enumerator">
	                                  [!++ Subtask is trickier because of intervening TOPIC elements ++]
	                                  <xsl:number value="1 + count(preceding::SUBTASK intersect ancestor::TASK//SUBTASK)" format="A."/>
	                                </xsl:with-param>
	                                <xsl:with-param name="indent">4pc</xsl:with-param>
	                              </xsl:call-template>
	                            </xsl:for-each>
	                            -->
	                          </xsl:for-each>
	                       </xsl:for-each>
                        </xsl:otherwise>
                      </xsl:choose>
                      <!-- Render the IPL TOC entries after the last 9000 pageblock in Non-Honeywell CMM format. Render the IPL TOC entries entires after the last pageblock for Honeywell CMM format. -->
                      <!-- 
                      <xsl:if test="not(following-sibling::PGBLK)">
                        <xsl:for-each select="//IPL">
                          <xsl:choose>
                            <xsl:when test="ISEMPTY and ($documentType = 'irm' or $documentType = 'orim' or $documentType = 'ohm')">
                              <xsl:message>No TOC entry for empty IPL in IRM, ORIM, or OHM</xsl:message>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:call-template name="pgblk-row"/>
                            </xsl:otherwise>
                          </xsl:choose>
                          <xsl:choose>
                            <xsl:when test="ISEMPTY and $documentType != 'irm' and $documentType != 'orim' and $documentType != 'ohm'">
                              <xsl:call-template name="write-toc-row">
                                <xsl:with-param name="title" select="'1. Not Applicable'"/>
                                <xsl:with-param name="indent" select="'2pc'"/>
                                <xsl:with-param name="refid" select="@KEY"/>
                                <xsl:with-param name="page-number-prefix">
                                  <xsl:call-template name="page-number-prefix"/>
                                </xsl:with-param>
                                <xsl:with-param name="page-number-suffix">
                                  <xsl:call-template name="page-number-suffix"/>
                                </xsl:with-param>
                              </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:for-each select="TASK|IPLINTRO/TASK|IPLINTRO/VENDLIST|DPLIST">
                                <xsl:call-template name="task-subtask-row">
                                  <xsl:with-param name="enumerator">
                                    <xsl:number value="1 + count(preceding-sibling::TASK) + count(preceding-sibling::VENDLIST) + count(preceding-sibling::DPLIST) + count(preceding-sibling::IPLINTRO/TASK) + count(preceding-sibling::IPLINTRO/VENDLIST)" format="1."/>
                                  </xsl:with-param>
                                </xsl:call-template>
                                <xsl:for-each select=".//SUBTASK">
                                  <xsl:call-template name="task-subtask-row">
                                    <xsl:with-param name="enumerator">
                                      [!++ Subtask is trickier because of intervening TOPIC elements ++]
                                      <xsl:number value="1 + count(preceding::SUBTASK intersect ancestor::TASK//SUBTASK)" format="A."/>
                                    </xsl:with-param>
                                    <xsl:with-param name="indent">4pc</xsl:with-param>
                                  </xsl:call-template>
                                </xsl:for-each>
                              </xsl:for-each>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </xsl:if>-->
                    </xsl:for-each>
                  </fo:table-body>
                </fo:table>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template name="list-of-tables-table">
    <fo:block break-before="page">
      <xsl:call-template name="save-revdate"/>
      <xsl:call-template name="write-toc-header">
        <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
        <xsl:with-param name="titleLine2">LIST OF TABLES</xsl:with-param>
      </xsl:call-template>
      <fo:table rx:table-omit-initial-header="true" width="100%" padding="3pt">
      	<xsl:if test="$toc_debug">
      		<xsl:attribute name="border" select="'1.5pt solid red'"/>
      	</xsl:if>
        <fo:table-column column-width="100%"/>
        <fo:table-header>
          <fo:table-cell>
            <xsl:call-template name="write-toc-header">
              <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
              <xsl:with-param name="titleLine2">LIST OF TABLES (Cont)</xsl:with-param>
            </xsl:call-template>
          </fo:table-cell>
        </fo:table-header>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell>
              <fo:table border-width="1pt" padding="3pt" width="100%"><!-- padding="6pt" -->
		      	<xsl:if test="$toc_debug">
		      		<xsl:attribute name="border" select="'2pt solid green'"/>
		      	</xsl:if>
                
                <fo:table-column column-number="1" column-width="5pc">
	               	<!-- IRM documents need more room for the figure number in the first column. -->
	               	<!-- Eventually, this will need to be more flexible. -->
	               	<xsl:if test="$documentType='irm'">
	               		<xsl:attribute name="column-width">7pc</xsl:attribute>
	               	</xsl:if>
                </fo:table-column>
                <fo:table-column column-number="2" column-width="proportional-column-width(1)"><!-- 30pc -->
	               	<xsl:if test="$documentType='irm'">
	               		<xsl:attribute name="column-width">proportional-column-width(1)</xsl:attribute><!-- 27pc -->
	               	</xsl:if>
                </fo:table-column>
                <fo:table-column column-number="3" column-width="6pc">
	               	<xsl:if test="$documentType='irm'">
	               		<xsl:attribute name="column-width">8pc</xsl:attribute>
	               	</xsl:if>
                </fo:table-column>
                
                <fo:table-header display-align="after" space-after=".5in">
                  <fo:table-row>
                    <fo:table-cell border-bottom="solid black 1pt" text-align="left" font-weight="bold" padding-after="4pt">
                      <fo:block>Table</fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="solid black 1pt" padding-after="4pt" text-align="center" font-weight="bold">
                      <fo:block>Description</fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="solid black 1pt" padding-after="4pt" text-align="right" font-weight="bold">
                      <fo:block>Page</fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                  <fo:table-row>
                    <fo:table-cell number-columns-spanned="2" border-bottom="none" text-align="left" font-weight="bold" padding="0pt">
                      <fo:block>&#160;</fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                </fo:table-header>
                <fo:table-body>
                  <!-- <xsl:for-each select="//table[ancestor::pmEntry and not(ancestor::GDESC)][title]"> -->
                  <!-- RS: Only count tables from the Introduction on (added IM/SDIM/SDOM starting on or after pmt91)-->
                  <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
                  <!-- <xsl:for-each select="/pm/content/pmEntry[
                    @pmEntryType='pmt58'
                    or preceding-sibling::pmEntry[@pmEntryType='pmt58']
                    or @pmEntryType='pmt91'
                    or preceding-sibling::pmEntry[@pmEntryType='pmt91']
                    ]//table[title]"> -->
                  <xsl:for-each select="/pm/content/pmEntry[not(@isFrontmatter='1')]//table[title]">
                    <xsl:call-template name="list-of-tables-row"/>
                  </xsl:for-each>
                </fo:table-body>
              </fo:table>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>

  <xsl:template name="list-of-figures-table">
    <fo:block break-before="page">
      <xsl:call-template name="save-revdate"/>
      <xsl:call-template name="write-toc-header">
        <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
        <xsl:with-param name="titleLine2">LIST OF FIGURES</xsl:with-param>
      </xsl:call-template>
      <fo:table rx:table-omit-initial-header="true" width="100%">
      	<xsl:if test="$toc_debug">
      		<xsl:attribute name="border" select="'1.5pt solid red'"/>
      	</xsl:if>
        <fo:table-column/><!--  column-width="100%" -->
        <fo:table-header>
          <fo:table-cell>
            <xsl:call-template name="write-toc-header">
              <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
              <xsl:with-param name="titleLine2">LIST OF FIGURES (Cont)</xsl:with-param>
            </xsl:call-template>
          </fo:table-cell>
        </fo:table-header>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell>
              <fo:table border-width="1pt" padding="3pt" width="100%">
      	        <xsl:if test="$toc_debug">
      		      <xsl:attribute name="border" select="'1pt solid blue'"/>
      	        </xsl:if>
                <fo:table-column column-number="1" column-width="5pc">
	               	<!-- IRM documents need more room for the figure number in the first column. -->
	               	<!-- Eventually, this will need to be more flexible. -->
	               	<xsl:if test="$documentType='irm'">
	               		<xsl:attribute name="column-width">7pc</xsl:attribute>
	               	</xsl:if>
                </fo:table-column>
                <fo:table-column column-number="2" column-width="proportional-column-width(1)"><!-- 30pc -->
	               	<xsl:if test="$documentType='irm'">
	               		<xsl:attribute name="column-width">proportional-column-width(1)</xsl:attribute><!-- 27pc -->
	               	</xsl:if>
                </fo:table-column>
                <fo:table-column column-number="3" column-width="6pc">
	               	<xsl:if test="$documentType='irm'">
	               		<xsl:attribute name="column-width">8pc</xsl:attribute>
	               	</xsl:if>
                </fo:table-column>

                <fo:table-header display-align="after" space-after=".5in">
                  <fo:table-row>
                    <fo:table-cell border-bottom="solid black 1pt" text-align="left" font-weight="bold" padding-after="4pt">
                      <fo:block>Figure</fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="solid black 1pt" padding-after="4pt" text-align="center" font-weight="bold">
                      <fo:block>Description</fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="solid black 1pt" padding-after="4pt" text-align="right" font-weight="bold">
                      <fo:block>Page</fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                  <fo:table-row>
                    <fo:table-cell number-columns-spanned="2" border-bottom="none" text-align="left" font-weight="bold" padding="0pt">
                      <fo:block>&#160;</fo:block>
                    </fo:table-cell>
                  </fo:table-row>
                </fo:table-header>
                <fo:table-body>
                  <!-- <xsl:for-each select="//figure[not(parent::FIGURE)]"> -->
                  <!-- All figures not in the IPL -->
                  <!-- UPDATE: Only include those with titles. -->
                  <xsl:for-each select="/pm/content/pmEntry[not(@pmEntryType='pmt75')]//figure[title]">
                    <xsl:call-template name="list-of-figures-row"/>
                  </xsl:for-each>
                  <!-- Add the IPL Introduction figures -->
                  <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt75']//figure[not(ancestor::illustratedPartsCatalog)]">
                    <xsl:call-template name="list-of-figures-row"/>
                  </xsl:for-each>
                  <xsl:if test="/pm/content/pmEntry/@pmEntryType='pmt75'">
                    <fo:table-row keep-with-next.within-page="always">
                      <fo:table-cell border-bottom="solid black 1pt" text-align="left" font-weight="bold" padding-after="3pt">
                        <fo:block space-before="8pt" space-before.conditionality="retain">IPL Figure</fo:block>
                      </fo:table-cell>
                      <fo:table-cell border-bottom="solid black 1pt" padding-after="3pt" text-align="center" font-weight="bold">
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell border-bottom="solid black 1pt" padding-after="3pt" text-align="right" font-weight="bold">
                        <fo:block/>
                      </fo:table-cell>
                    </fo:table-row>
                    <!-- Spacing row -->
                    <fo:table-row keep-with-next.within-page="always" height="6pt">
                      <fo:table-cell number-columns-spanned="2" padding="0pt">
                        <fo:block font-size="2pt">&#160;</fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <!-- All figures in the IPL -->
                    <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt75']//illustratedPartsCatalog/figure">
                      <xsl:call-template name="list-of-figures-row"/>
                    </xsl:for-each>
                  </xsl:if>
                </fo:table-body>
              </fo:table>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:block>
  </xsl:template>

  <!-- Called from top-level pmEntries -->
  <xsl:template name="pgblk-row">
    <xsl:variable name="title">
      <xsl:value-of select="upper-case(pmEntryTitle)"/>
      <!-- May need this later for IRM
      <xsl:if test="$documentType='irm' and number(ancestor-or-self::PGBLK/@CONFNBR) >= 1000 and child::EFFECT">
        <xsl:text>, PN&#160;</xsl:text>
        <xsl:value-of select="child::EFFECT"/>
      </xsl:if> -->
    </xsl:variable>
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="indent" select="'0pc'"/>
      <xsl:with-param name="refid" select="@id"/><!-- @KEY -->
      <xsl:with-param name="pgblkRow" select="'1'"/>
      <xsl:with-param name="page-number-prefix">
        <xsl:call-template name="page-number-prefix"/>
      </xsl:with-param>
      <xsl:with-param name="page-number-suffix">
        <xsl:call-template name="page-number-suffix"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="TCE-Text-Marker">
     <!-- This ~TCE~ marker makes Omnimark (update_toc.xom) adjust the offset and width of the page number, -->
     <!-- which doesn't seem to work correctly for pages with prefixes like in IM. So for IM/SDIM/SDOM, don't -->
     <!-- output this, at least until there is a specific reason which we can document and perhaps adjust -->
     <!-- the Omnimark script to work better with page prefixes. -->
     <!-- UDPATE: This is needed to adjust the values of the page numbers due to foldout tables, where -->
     <!-- every page in a pageblock after the foldout table is incremented for each table foldout page. -->
     <!-- So restore this and try to sort out the indent in the Omnimark script. -->
     <!-- <xsl:if test="not($documentType='im' or $documentType='sdim' or $documentType='sdom')"> -->
      <xsl:text>~TCE~</xsl:text>
     <!-- </xsl:if> -->
  </xsl:template>
  
  <xsl:template name="list-of-figures-row">
    <xsl:variable name="page-number-prefix">
      <xsl:call-template name="page-number-prefix"/>
    </xsl:variable>
    <xsl:variable name="page-number-suffix">
      <xsl:call-template name="page-number-suffix"/>
    </xsl:variable>
    <xsl:variable name="fig-title">
      <xsl:apply-templates select="title" mode="graphic-title"/>
    </xsl:variable>
    <fo:table-row>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="0pt">
        <fo:block text-align="left">
          <fo:basic-link internal-destination="{graphic[1]/@id}">
            <xsl:choose>
              <xsl:when test="false()"><!-- Disable this condition: parent::figure -->
                <xsl:value-of select="parent::figure/@FIGNBR"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Get the figure number and add a space after in case it is too long and runs into the title. -->
                <xsl:call-template name="calc-figure-number"/><xsl:text>&#160;</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="0pt">
        <!-- Justify to make the leader dots stretch to the end of the cell. -->
        <fo:block text-align-last="justify">
          <!-- RS: May want to link to the first graphic, but the figure might be sufficient -->
          <!-- <fo:basic-link internal-destination="{graphic[1]/@KEY}"> -->
          <fo:basic-link internal-destination="{graphic[1]/@id}">
            <xsl:value-of select="$fig-title"/>
            <!-- <xsl:value-of select="concat($fig-title,' (GRAPHIC ',@CHAPNBR, 
              '-',@SECTNBR, 
              '-',@SUBJNBR, 
              '-',@FUNC,
              '-',@SEQ,
              '-',@CONFLTR,@VARNBR,')&#xA0;')"/> -->
            <fo:leader leader-pattern="dots" leader-length.minimum="1in"/>
            <xsl:text>&#160;</xsl:text>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right" display-align="after">
        <fo:block>
          <!-- <fo:basic-link internal-destination="{SHEET[1]/@KEY}"> -->
          <fo:basic-link internal-destination="{graphic[1]/@id}">
	        <xsl:call-template name="TCE-Text-Marker"/>
            <xsl:value-of select="$page-number-prefix"/>
            <fo:page-number-citation>
              <xsl:choose>
                <!-- <xsl:when test="SHEET[1][translate(@IMGAREA,$upperCase,$lowerCase) = 'hl']"> -->
                <xsl:when test="graphic[1][@reproductionWidth='355.6 mm']">
                  <xsl:attribute name="ref-id">
                    <xsl:value-of select="concat(graphic[1]/@id,'-r1')"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="ref-id">
                    <!-- <xsl:value-of select="SHEET[1]/@KEY"/> -->
                    <xsl:value-of select="graphic[1]/@id"/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </fo:page-number-citation>
            <xsl:value-of select="$page-number-suffix"/>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="list-of-tables-row">
    <xsl:variable name="page-number-prefix">
      <xsl:call-template name="page-number-prefix"/>
    </xsl:variable>
    <xsl:variable name="page-number-suffix">
      <xsl:call-template name="page-number-suffix"/>
    </xsl:variable>
    <fo:table-row>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="0pt">
      	<xsl:if test="$toc_debug">
      		<xsl:attribute name="border" select="'1pt solid blue'"/>
      		<xsl:message>List of Tables row for table <xsl:call-template name="calc-table-number"/></xsl:message>
      	</xsl:if>
        <fo:block text-align="left">
          <fo:basic-link internal-destination="{@id}">
            <xsl:call-template name="calc-table-number"/>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="0pt">
      	<xsl:if test="$toc_debug">
      		<xsl:attribute name="border" select="'1pt solid blue'"/>
      	</xsl:if>
        <fo:block text-align-last="justify">
          <fo:basic-link internal-destination="{@id}">
            <!-- <xsl:value-of select="title"/> -->
            <xsl:apply-templates select="title" mode="table-title"/>
            <xsl:text>&#160;</xsl:text>
            <fo:leader leader-pattern="dots" leader-length.minimum="1in"/>
            <xsl:text>&#160;</xsl:text>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right" display-align="after">
      	<xsl:if test="$toc_debug">
      		<xsl:attribute name="border" select="'1pt solid blue'"/>
      		<xsl:message>Page number suffix: '<xsl:value-of select="$page-number-suffix"/>'</xsl:message>
      	</xsl:if>
        <fo:block>
	      <xsl:if test="$toc_debug">
	      	<xsl:attribute name="border" select="'1pt dashed red'"/>
	      </xsl:if>
          <fo:basic-link internal-destination="{@id}">
	        <xsl:call-template name="TCE-Text-Marker"/>
            <xsl:choose>
              <xsl:when test="@TABSTYLE='hl'">
                <xsl:value-of select="$page-number-prefix"/>
                <fo:page-number-citation>
                  <xsl:attribute name="ref-id">
                    <xsl:value-of select="@id"/>
                  </xsl:attribute>
                </fo:page-number-citation>
                <xsl:value-of select="$page-number-suffix"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$page-number-prefix"/>
                <fo:page-number-citation>
                  <xsl:attribute name="ref-id">
                    <xsl:value-of select="@id"/>
                  </xsl:attribute>
                </fo:page-number-citation>
                <xsl:value-of select="$page-number-suffix"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="page-number-prefix">
    <xsl:choose>
      <!-- <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = 0 and $documentType != 'acmm'">-->
      <xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt58' and $documentType != 'acmm'">
        <xsl:text>INTRO-</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt52' and $documentType != 'acmm'">
        <xsl:text>TI-</xsl:text>
      </xsl:when>
      <!-- BEGIN changes for Mantis 18540 Appendix Support-->
      <!-- <xsl:when test="number(@PGBLKNBR) >= 17000">
        <xsl:call-template name="calculateCMMAppendixNumber"/>
        <xsl:text>-</xsl:text>          
      </xsl:when> -->
      <!-- END changes for Mantis 18540-->
      <!-- ***** This causes an error at the last step (PDF generation):
        ...[24][59]error: formatting failed: com.renderx.pdflib.PDFWrongElementException: You are already sending stream data  -->
        <!-- This is only when applied to the foldout page numbers (figure.xsl, template match="graphic[@reproductionWidth='355.6 mm']" mode="foldout"), -->
        <!-- so just remove it from there until it's sorted out -->
        <xsl:when test="ancestor-or-self::pmEntry[last()]/@shortPrefix">
        	<xsl:value-of select="ancestor-or-self::pmEntry[last()]/@shortPrefix"/>
        </xsl:when>
        <!-- (debug)
        <xsl:when test="ancestor-or-self::pmEntry[last()]/@shortPrefix">
        	<xsl:message>Applying short prefix: <xsl:value-of select="ancestor-or-self::pmEntry[last()]/@shortPrefix"/></xsl:message>
        </xsl:when> -->
      <xsl:otherwise>
        <!-- No prefix -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="page-number-prefix-toc"><!-- temporary template to work around problems with page-number-prefix above... -->
    <xsl:choose>
      <!-- <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = 0 and $documentType != 'acmm'">-->
      <xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt58' and $documentType != 'acmm'">
        <xsl:text>INTRO-</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor-or-self::pmEntry/@pmEntryType='pmt52' and $documentType != 'acmm'">
        <xsl:text>TI-</xsl:text>
      </xsl:when>
      <!-- BEGIN changes for Mantis 18540 Appendix Support-->
      <!-- <xsl:when test="number(@PGBLKNBR) >= 17000">
        <xsl:call-template name="calculateCMMAppendixNumber"/>
        <xsl:text>-</xsl:text>          
      </xsl:when> -->
      <!-- END changes for Mantis 18540-->
      <!-- ***** This causes an error at the last step (PDF generation):
        ...[24][59]error: formatting failed: com.renderx.pdflib.PDFWrongElementException: You are already sending stream data  -->
        <xsl:when test="ancestor-or-self::pmEntry[last()]/@shortPrefix">
        	<xsl:value-of select="ancestor-or-self::pmEntry[last()]/@shortPrefix"/>
        </xsl:when>
        <xsl:when test="ancestor-or-self::pmEntry[last()]/@shortPrefix">
        	<xsl:message>Applying short prefix (ToC): <xsl:value-of select="ancestor-or-self::pmEntry[last()]/@shortPrefix"/></xsl:message>
        </xsl:when>
      <xsl:otherwise>
        <!-- No prefix -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="page-number-suffix">
  	<!-- <xsl:message>Calculating ToC page number suffix.
  		Context: <xsl:value-of select="name()"/>
  		Ancestor authorityName: <xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName"/></xsl:message> -->
    <xsl:choose>
      <xsl:when test="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName">
      	<xsl:text>-</xsl:text><xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName"/>
      </xsl:when>
      <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = 0">
        <!-- No suffix -->
      </xsl:when>
      <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = 1">
        <!-- No suffix -->
      </xsl:when>
      <!--<xsl:when test="ancestor-or-self::PGBLK/@CONFNBR">
        <xsl:text>-</xsl:text>
        <xsl:number value="ancestor-or-self::PGBLK/@CONFNBR" format="0000"/>        
      </xsl:when>-->
      <xsl:when test="$documentType='irm' and number(ancestor-or-self::PGBLK[@PGBLKNBR='5000' or @PGBLKNBR='6000']/@CONFNBR) >= 1000 and ancestor-or-self::PGBLK/EFFECT">
        <xsl:text>-&#8203;</xsl:text>
        <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- No suffix -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="write-listitem-row">
    <xsl:param name="indent" select="'0pt'"/>
    <xsl:param name="title"/>
    <xsl:param name="list-marker"/>
    <xsl:param name="refid"/>
    <fo:table-row>
      <fo:table-cell>
        <fo:block margin-left="{$indent}">
          <fo:list-block provisional-distance-between-starts="24pt" space-before="4pt" provisional-label-separation=".1in">
            <fo:list-item>
              <fo:list-item-label end-indent="label-end()">
                <fo:block>
                  <xsl:value-of select="$list-marker"/>
                </fo:block>
              </fo:list-item-label>
              <fo:list-item-body start-indent="body-start()">
                <fo:block text-align-last="justify">
                  <xsl:value-of select="$title"/>
                  <fo:leader leader-pattern="dots"/>
                </fo:block>
              </fo:list-item-body>
            </fo:list-item>
          </fo:list-block>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right">
        <fo:block>
          <fo:basic-link>
            <xsl:attribute name="internal-destination" select="$refid"/>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:value-of select="$refid"/>
              </xsl:attribute>
            </fo:page-number-citation>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  
  <xsl:template name="task-subtask-row">
    <xsl:param name="indent" select="'2pc'"/>
    <xsl:param name="enumerator" select="''"/>
    <xsl:variable name="title">
      <xsl:choose>
	      <xsl:when test="pmEntryTitle">
	      	<xsl:apply-templates select="pmEntryTitle" mode="task-subtask-title"/>
	      </xsl:when>
	      <xsl:when test="title">
	      	<xsl:apply-templates select="title" mode="task-subtask-title"/>
	      </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:call-template name="get-mtoss"/><!-- Task or subtask number (in parens) -->
    </xsl:variable>
    <xsl:variable name="key">
      <xsl:choose>
        <xsl:when test="name() = 'DPLIST'">
          <xsl:value-of select="'dplist'"/>
        </xsl:when>
        <xsl:when test="name() = 'VENDLIST'">
          <xsl:value-of select="/CMM/IPL/IPLINTRO/VENDLIST/@KEY"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id"/><!-- @KEY -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="write-toc-row">
      <!--<xsl:with-param name="title" select="concat($enumerator,' ',$title)"/>-->
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="enumerator" select="$enumerator"/>
      <xsl:with-param name="indent" select="$indent"/>
      <xsl:with-param name="refid" select="$key"/>
      <xsl:with-param name="page-number-prefix">
        <xsl:call-template name="page-number-prefix"/>
      </xsl:with-param>
      <xsl:with-param name="page-number-suffix">
        <xsl:call-template name="page-number-suffix"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="write-toc-header">
    <xsl:param name="titleLine1">
      <xsl:text>TABLE OF CONTENTS </xsl:text>
    </xsl:param>
    <xsl:param name="titleLine2"/>
    <fo:block text-align="center" font-size="12pt" font-weight="bold" space-before="6pt" space-after="4pt">
      <xsl:value-of select="$titleLine1"/>
    </fo:block>
    <fo:block text-align="center" font-size="12pt" font-weight="bold" space-before="2pt" space-after="4pt">
      <xsl:value-of select="$titleLine2"/>
    </fo:block>
  </xsl:template>

  <xsl:template name="write-toc-row">
    <xsl:param name="title"/>
    <xsl:param name="indent" select="'0in'"/>
    <xsl:param name="refid"/>
    <xsl:param name="page-number-prefix"/>
    <xsl:param name="page-number-suffix"/>
    <xsl:param name="pgblkRow" select="'0'"/>
    <xsl:param name="enumerator"/>
    <xsl:choose>
      <!-- ATA: Top-level rows did not have page numbers added, but in S1000D Styler they do -->
      <xsl:when test="$pgblkRow='1'">
        <fo:table-row keep-with-next.within-page="always">
          <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="{$indent}">
            <!-- For S1000D make top-level ToC entries bold -->
            
            <!-- If it's IM/SDIM/SDOM, add the section number as a block above the first-level ToC entry (but not for Introduction). -->
			<xsl:if test="($documentType='im' or $documentType='sdim' or $documentType='sdom') and not(@pmEntryType='pmt58')">
			    <fo:block font-weight="bold">
				<xsl:choose>
					<!-- Appendix -->
					<xsl:when test="@pmEntryType='pmt85'">
						<xsl:text>APPENDIX </xsl:text>
						<xsl:value-of select="@sectionNumber"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>SECTION </xsl:text>
						<xsl:value-of select="@sectionNumber"/>
					</xsl:otherwise>
				</xsl:choose>
				</fo:block>
			</xsl:if>

            <fo:block font-weight="bold" text-align-last="justify">
              <fo:basic-link>
                <xsl:attribute name="internal-destination" select="$refid"/>
                <xsl:value-of select="$title"/>
                <xsl:text>&#160;</xsl:text>
                <fo:leader leader-pattern="dots" leader-length.minimum="1in"/>
                <xsl:text>&#160;</xsl:text>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
          <!--
          <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right">
            <fo:block/>
          </fo:table-cell>-->
          <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right" display-align="after">
            <fo:block margin-left="-0.475in" font-weight="bold">
              <fo:basic-link>
                <xsl:attribute name="internal-destination" select="$refid"/>
	        	<!-- TCE marker not needed for top-level rows (for page number updating due to table foldouts and/or point pages) -->
	        	<!-- UPDATE: Might as well keep it so the adjustments are consistent. -->
	        	<xsl:call-template name="TCE-Text-Marker"/>
                <xsl:value-of select="$page-number-prefix"/>
                <fo:page-number-citation>
                  <xsl:attribute name="ref-id">
                    <xsl:value-of select="$refid"/>
                  </xsl:attribute>
                </fo:page-number-citation>
                <xsl:value-of select="$page-number-suffix"/>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
          
        </fo:table-row>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="{$indent}">
            <fo:list-block>
              <fo:list-item>
                <fo:list-item-label end-indent="label-end()">
                  <fo:block>
                    <fo:basic-link>
                      <xsl:attribute name="internal-destination" select="$refid"/>
                      <xsl:value-of select="$enumerator"/>
                    </fo:basic-link>
                  </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="body-start()">
                  <fo:block text-align-last="justify">
                    <fo:basic-link>
                      <xsl:attribute name="internal-destination" select="$refid"/>
                      <xsl:value-of select="$title"/>
                      <xsl:text>&#160;</xsl:text>
                      <fo:leader leader-pattern="dots" leader-length.minimum="1in"/>
                      <xsl:text>&#160;</xsl:text>
                    </fo:basic-link>
                  </fo:block>
                </fo:list-item-body>
              </fo:list-item>
            </fo:list-block>
          </fo:table-cell>
          <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right" display-align="after">
            <fo:block margin-left="-0.475in">
              <fo:basic-link>
                <xsl:attribute name="internal-destination" select="$refid"/>
		        <xsl:call-template name="TCE-Text-Marker"/>
                <xsl:value-of select="$page-number-prefix"/>
                <fo:page-number-citation>
                  <xsl:attribute name="ref-id">
                    <xsl:value-of select="$refid"/>
                  </xsl:attribute>
                </fo:page-number-citation>
                <xsl:value-of select="$page-number-suffix"/>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Called for the ToC and PDF bookmarks -->
  <xsl:template match="pmEntryTitle" mode="task-subtask-title">
    <xsl:apply-templates />
  </xsl:template>
  
  <!-- Called for the ToC and PDF bookmarks  -->
  <xsl:template match="title" mode="task-subtask-title">
    <xsl:apply-templates />
  </xsl:template>


</xsl:stylesheet>
