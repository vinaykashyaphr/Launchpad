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


  <xsl:template name="intro-toc">
    
    <fo:page-sequence master-reference="Body" font-family="Arial" font-size="10pt" initial-page-number="1">
    
      <xsl:call-template name="init-static-content">
        <xsl:with-param name="page-prefix">
          <xsl:value-of select="'TC-'"/>
        </xsl:with-param>
        <xsl:with-param name="isChapterToc" select="0"/>
        <xsl:with-param name="isIntroToc" select="1"/>
        <xsl:with-param name="suppressAtacode" select="0"/><!-- RS: was 1, but my sample has an ATA code... --><!-- DJH TEST 20090831 -->
      </xsl:call-template>
      
      <fo:flow flow-name="xsl-region-body">
        <xsl:call-template name="intro-toc-table"/>
      </fo:flow>
    </fo:page-sequence>
    
  </xsl:template>

  <!-- The intro-toc-table is based on the one in chapterToc.xsl from EIPC. It has slightly different -->
  <!-- column widths than the one in cmmToc.xsl. -->
  <xsl:template name="intro-toc-table">
    <fo:block id="intro_toc">
     
      <xsl:call-template name="save-revdate">
        <xsl:with-param name="intro-toc" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="write-toc-header">
        <xsl:with-param name="titleLine1">TABLE OF CONTENTS</xsl:with-param>
        <xsl:with-param name="titleLine2">INTRODUCTION</xsl:with-param>
      </xsl:call-template>
     
        <fo:table rx:table-omit-initial-header="true">
          <fo:table-column column-width="100%"/>
          <fo:table-header>
            <fo:table-cell>
              <xsl:call-template name="write-toc-header">
                <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
                <xsl:with-param name="titleLine2">INTRODUCTION (Cont)</xsl:with-param>
              </xsl:call-template>
            </fo:table-cell>
          </fo:table-header>
          <fo:table-body>
            <fo:table-row>
              <fo:table-cell>
                <fo:table border-width="1pt" padding="6pt">
                
                  <fo:table-column column-number="1" column-width="6.00in"/><!-- 6.20 -->
                  <fo:table-column column-number="2" column-width="0.78in"/><!-- 0.5 -->
                  
                  <fo:table-header display-align="after" 
                    space-after=".5in">
                    <fo:table-row>
                      <fo:table-cell border-bottom="solid black 1pt" 
                        text-align="left" font-weight="bold" padding-after="4pt">
                        <fo:block>Title</fo:block>
                      </fo:table-cell>
                      <fo:table-cell border-bottom="solid black 1pt" padding-after="4pt" 
                        text-align="right" font-weight="bold">
                        <fo:block>Page</fo:block>
                      </fo:table-cell>
                    </fo:table-row>
                    <fo:table-row>
                      <fo:table-cell  number-columns-spanned="2" border-bottom="none" 
                        text-align="left" font-weight="bold" padding="0pt">
                        <fo:block>&#160;</fo:block>
                      </fo:table-cell>
                      
                    </fo:table-row>
                  </fo:table-header>
                  
                  <fo:table-body>
                  
                    <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt58']">
                      <!-- RS: Output heading row for the introduction. -->
                      <xsl:call-template name="pgblk-row-intro"/>
                      <xsl:call-template name="toc-second-level-pmEntry"/>
                    </xsl:for-each>
                    
                  </fo:table-body>
                </fo:table>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
    
      
    </fo:block>
  </xsl:template>
  
  
  <!-- Output the ToC for a Chapter -->
  <!-- The top-level pmEntry is in context. -->
  <xsl:template name="chapter-toc">
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
        <xsl:call-template name="chapter-toc-table"/>
        <!-- No LoT or LoF in EIPC
        <xsl:choose>
          <xsl:when test="$documentType!='irm'">
            <xsl:if test="//figure">
              <xsl:call-template name="list-of-figures-table"/>
            </xsl:if>
            <xsl:if test="//table[not(ancestor-or-self::GDESC)][title]">
              <xsl:call-template name="list-of-tables-table"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            [!++ Don't output LOF or LOT for IRMs ++]
          </xsl:otherwise>
        </xsl:choose>-->
      </fo:flow>
    </fo:page-sequence>
  </xsl:template>

  <!-- Output the ToC table for a Chapter -->
  <!-- The top-level pmEntry is in context. -->
  <xsl:template name="chapter-toc-table">
    <xsl:variable name="chapterNo" select="substring(@authorityDocument,1,2)"/>
    <fo:block id="{concat('chapter_toc_',generate-id())}">
      <xsl:call-template name="save-revdate">
      	<xsl:with-param name="isChapterToC" select="true()"/>
      </xsl:call-template>
      <xsl:call-template name="write-toc-header">
        <xsl:with-param name="titleLine1">TABLE OF CONTENTS</xsl:with-param>
        <xsl:with-param name="titleLine2">
          <xsl:value-of select="concat('CHAPTER - ', $chapterNo)"/>
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
                  <xsl:value-of select="concat('CHAPTER - ', $chapterNo,' (Cont)')"/>
                </xsl:with-param>
              </xsl:call-template>
            </fo:table-cell>
          </fo:table-header>
          <fo:table-body>
            <fo:table-row>
              <fo:table-cell>
                <fo:table border-width="1pt" padding="6pt">
                  <fo:table-column column-number="1" column-width="6.00in"/>
                  <fo:table-column column-number="2" column-width=".78in"/>
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
                    <xsl:call-template name="chapter-row" />
                    <xsl:for-each select="pmEntry">
                      <xsl:call-template name="section-row"/>
                      <!-- It looks like 3-level PMC has only two levels of ToC -->
                      <xsl:if test="$isNewPmc">
	                      <xsl:for-each select="pmEntry">
	                        <xsl:call-template name="unit-row"/>
	                        <xsl:for-each select="pmEntry">
	                          <xsl:call-template name="pgblk-row"/>
	                        </xsl:for-each>
	                      </xsl:for-each>
                      </xsl:if>
                    </xsl:for-each>
                  
                  
                  <!-- Old CMM version for reference:
                    [!++ Don't need for-each; only doing one pmEntry (already in context)
                    <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt58' or preceding-sibling::pmEntry[@pmEntryType='pmt58']]"> ++]
                      [!++ RS: Output heading row for each top-level pmEntry including the introduction and after. ++]
                      <xsl:call-template name="pgblk-row"/>
                      
                      <xsl:choose>
                      	[!++ RS: Not applicable for S1000D ++]
                        [!++ <xsl:when test="ISEMPTY">
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
                        </xsl:when> ++]
                        
                        [!++ In some cases there can be proceduralSteps (and maybe levelledParas) in the first-level pmEntries. ++]
                        [!++ Then there should be no child pmEntries. ++]
                        [!++ But this should not happen in EIPC (?) ++]
                        <xsl:when test="not(pmEntry)">
                          <xsl:for-each select="dmContent/dmodule/content/description/levelledPara[title] | dmContent/dmodule/content/procedure/mainProcedure/proceduralStep[title]">
                            <xsl:call-template name="task-subtask-row">
                              <xsl:with-param name="enumerator">
                              	<xsl:choose>
                              		<xsl:when test="self::levelledPara">
                              			[!++ This count is from Styler levelledPara numbering (includes levelledParas in preceding dmodules)++]
                              			<xsl:number value="count(preceding-sibling::levelledPara) 
                              			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara) + 1"
                              			  format="1."/>
                              		</xsl:when>
                              		<xsl:when test="self::proceduralStep">
                              			<xsl:variable name="procStepCounter" select="count(preceding-sibling::proceduralStep)
                              			  + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep) + 1"/>
                              			[!++ <xsl:message>Outputting ToC entry for proceduralStep <xsl:value-of select="$procStepCounter"/></xsl:message> ++]
                              			[!++ This count is from Styler proceduralStep numbering (includes procedural steps in preceding dmodules)++]
                              			<xsl:number value="$procStepCounter" format="1."/>
                              		</xsl:when>
                              	</xsl:choose>
                              </xsl:with-param>
                              <xsl:with-param name="indent">2pc</xsl:with-param>
                            </xsl:call-template>
                          </xsl:for-each>
                        </xsl:when>
                        
                        <xsl:otherwise>
                          <xsl:call-template name="toc-second-level-pmEntry"/>
                        </xsl:otherwise>
                      </xsl:choose>-->
                    <!-- </xsl:for-each> -->
                  </fo:table-body>
                </fo:table>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template name="chapter-row">
    <xsl:variable name="title"> <!--  select="concat('CHAPTER ', substring(@authorityDocument,1,2), ' - ', upper-case(pmEntryTitle))"/ -->
    	<!-- The 3-level ToC doesn't seem to add the "CHAPTER" prefix -->
    	<xsl:if test="$isNewPmc">
    		<xsl:text>CHAPTER </xsl:text>
    		<xsl:value-of select="substring(@authorityDocument,1,2)"/>
    	</xsl:if>
    	<xsl:if test="not($isNewPmc)">
    		<xsl:value-of select="@authorityDocument"/>
    	</xsl:if>
    	<xsl:if test="normalize-space(pmEntryTitle)!=''">
	    	<xsl:text> - </xsl:text>
	    	<xsl:value-of select="upper-case(pmEntryTitle)"/>
    	</xsl:if>
    </xsl:variable>
    <xsl:call-template name="write-chapter-row">
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="write-chapter-row">
    <xsl:param name="title"/>
    <xsl:param name="indent" select="'0in'"/>
    <fo:table-row>
      <!-- ATA: Top-level rows did not have page numbers added, but in S1000D Styler they do -->
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="{$indent}">
        <fo:block text-align-last="justify">
          <fo:basic-link>
            <xsl:attribute name="internal-destination" select="@id"/>
          	<xsl:value-of select="$title"/>
            <xsl:text>&#160;</xsl:text>
            <fo:leader leader-pattern="dots" leader-length.minimum="1in"/>
            <xsl:text>&#160;</xsl:text>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" text-align="right">
        <fo:block margin-left="-0.475in">
          <fo:basic-link color="blue">
            <xsl:attribute name="internal-destination" select="@id"/>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:value-of select="@id"/>
              </xsl:attribute>
            </fo:page-number-citation>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  
  <xsl:template name="section-row">
  
    <xsl:variable name="title"> <!--  select="concat('Section ', @authorityDocument, ' - ', upper-case(pmEntryTitle))"/  -->
    	<!-- The 3-level ToC doesn't seem to add the "Section" prefix -->
    	<xsl:if test="$isNewPmc">
    		<xsl:text>Section </xsl:text>
    	</xsl:if>
    	<xsl:value-of select="@authorityDocument"/>
    	<xsl:text> - </xsl:text>
    	<xsl:value-of select="upper-case(pmEntryTitle)"/>
    </xsl:variable>
    
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="refid" select="@id"/>
      <xsl:with-param name="indent" select="'0pc'"/>
    </xsl:call-template>
    
  </xsl:template>

  
  <xsl:template name="unit-row">
    <xsl:variable name="title" select="concat('Subject ', @authorityDocument, ' - ', upper-case(pmEntryTitle))"/>
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="indent" select="'2pc'"/>
      <xsl:with-param name="refid" select="@id"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="figure-row">
    <xsl:variable name="figureNo">
      <xsl:call-template name="calc-figure-number"/>
    </xsl:variable>
    <xsl:variable name="title">
      <xsl:value-of select="concat('DPL Figure ', $figureNo,'. ')"/>
      <xsl:apply-templates select="title" mode="graphic-title"/>
    </xsl:variable>
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="indent" select="'4pc'"/>
      <xsl:with-param name="refid">
        <!-- Link to the caption of the first sheet -->
		<xsl:value-of select="concat('figcap_',graphic[1]/@id)"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  
  
  <!-- RS: Output 2nd level pmEntry styled as "1.", then nested content (proceduralSteps, levelledParas) -->
  <!-- Context: the first-level pmEntry. -->
  <xsl:template name="toc-second-level-pmEntry">
         
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
                      + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep) + 1"
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
  </xsl:template>
   
  <xsl:template name="list-of-tables-table">
    <fo:block break-before="page">
      <xsl:call-template name="save-revdate"/>
      <xsl:call-template name="write-toc-header">
        <xsl:with-param name="titleLine1">TABLE OF CONTENTS (Cont)</xsl:with-param>
        <xsl:with-param name="titleLine2">LIST OF TABLES</xsl:with-param>
      </xsl:call-template>
      <fo:table rx:table-omit-initial-header="true" >
      	<xsl:if test="$debug">
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
              <fo:table border-width="1pt" padding="6pt">
		      	<xsl:if test="$debug">
		      		<xsl:attribute name="border" select="'2pt solid green'"/>
		      	</xsl:if>
                <fo:table-column column-number="1" column-width="5pc"/>
                <fo:table-column column-number="2" column-width="30pc"/>
                <fo:table-column column-number="3" column-width="6pc"/>
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
                  <!-- RS: Only count tables from the Introduction on -->
                  <xsl:for-each select="/pm/content/pmEntry[@pmEntryType='pmt58' or preceding-sibling::pmEntry[@pmEntryType='pmt58']]//table[title]">
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
      <fo:table rx:table-omit-initial-header="true">
      	<xsl:if test="$debug">
      		<xsl:attribute name="border" select="'1.5pt solid red'"/>
      	</xsl:if>
        <fo:table-column column-width="100%"/>
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
              <fo:table border-width="1pt" padding="6pt">
      	        <xsl:if test="$debug">
      		      <xsl:attribute name="border" select="'1pt solid blue'"/>
      	        </xsl:if>
                <fo:table-column column-number="1" column-width="5pc"/>
                <fo:table-column column-number="2" column-width="30pc"/>
                <fo:table-column column-number="3" column-width="6pc"/>
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
                  <xsl:for-each select="/pm/content/pmEntry[not(@pmEntryType='pmt75')]//figure">
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
  <!-- Original version for reference:
  <xsl:template name="pgblk-row">
    <xsl:variable name="title">
      [!++ WAR: Changed the way pageblock titles are renderd in TOC ++]
      [!++<xsl:call-template name="pgblk-title">
        <xsl:with-param name="pgblknbr" select="@PGBLKNBR"/>
      </xsl:call-template>++]
      <xsl:choose>
        <xsl:when test="ISEMPTY">
          <xsl:choose>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '0'">
              <xsl:text>INTRODUCTION</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '1'">
              <xsl:text>DESCRIPTION AND OPERATION</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '1000'">
              <xsl:text>TESTING AND FAULT ISOLATION</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '2000'">
              <xsl:text>SCHEMATIC AND WIRING DIAGRAMS</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '3000'">
              <xsl:text>DISASSEMBLY</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '4000'">
              <xsl:text>CLEANING</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '5000'">
              <xsl:text>INSPECTION/CHECK</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '6000'">
              <xsl:text>REPAIR</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '7000'">
              <xsl:text>ASSEMBLY</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '8000'">
              <xsl:text>FITS AND CLEARANCES</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '9000'">
              <xsl:text>SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::IPL/@PGBLKNBR = '10000'">
              <xsl:text>ILLUSTRATED PARTS LIST</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '11000'">
              <xsl:text>SPECIAL PROCEDURES</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '12000'">
              <xsl:text>REMOVAL</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '13000'">
              <xsl:text>INSTALLATION</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '14000'">
              <xsl:text>SERVICING</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '15000'">
              <xsl:text>STORAGE</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = '16000'">
              <xsl:text>REWORK</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>UNKOWN PAGE BLOCK NUMBER</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="upper-case(pmEntryTitle)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$documentType='irm' and number(ancestor-or-self::PGBLK/@CONFNBR) >= 1000 and child::EFFECT">
        <xsl:text>, PN&#160;</xsl:text>
        <xsl:value-of select="child::EFFECT"/>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="indent" select="'0pc'"/>
      <xsl:with-param name="refid" select="@id"/>[!++ @KEY ++]
      <xsl:with-param name="pgblkRow" select="'1'"/>
      <xsl:with-param name="page-number-prefix">
        <xsl:call-template name="page-number-prefix"/>
      </xsl:with-param>
      <xsl:with-param name="page-number-suffix">
        <xsl:call-template name="page-number-suffix"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template> -->

  <!-- In 5-level EM, this is called for the 4th level pmEntry (in context) -->
  <xsl:template name="pgblk-row">
    <xsl:variable name="title">
      <!-- Add the parent pmEntryTitle -->
      <xsl:value-of select="upper-case(../pmEntryTitle)"/>
      <xsl:text> - </xsl:text>
      <xsl:value-of select="upper-case(pmEntryTitle)"/>
      <xsl:if test="ancestor-or-self::pmEntry/@confnbr">
        <fo:inline>
          <xsl:value-of select="concat('-',ancestor-or-self::pmEntry/@confnbr)"/>
        </fo:inline>
      </xsl:if>
    </xsl:variable>
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="indent" select="'4pc'"/>
      <xsl:with-param name="refid" select="@id"/>
      <!-- <xsl:with-param name="pgblkRow" select="'1'"/> -->
      <!-- <xsl:with-param name="page-number-prefix">
        <xsl:call-template name="page-number-prefix"/>
      </xsl:with-param>
      <xsl:with-param name="page-number-suffix">
        <xsl:call-template name="page-number-suffix"/>
      </xsl:with-param> -->
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="pgblk-row-intro">
    <xsl:variable name="title">
      <xsl:value-of select="upper-case(pmEntryTitle)"/>
    </xsl:variable>
    <xsl:call-template name="write-toc-row">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="indent" select="'0pc'"/>
      <xsl:with-param name="refid" select="@id"/>
      <xsl:with-param name="pgblkRow" select="'1'"/>
      <xsl:with-param name="page-number-prefix" select="'INTRO-'"/>
      <!-- <xsl:with-param name="page-number-prefix">
        <xsl:call-template name="page-number-prefix"/>
      </xsl:with-param>
      <xsl:with-param name="page-number-suffix">
        <xsl:call-template name="page-number-suffix"/>
      </xsl:with-param> -->
    </xsl:call-template>
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
          <!-- <fo:basic-link internal-destination="{graphic[1]/@KEY}"> -->
          <fo:basic-link internal-destination="{graphic[1]/@id}">
            <xsl:choose>
              <xsl:when test="parent::figure">
                <xsl:value-of select="parent::figure/@FIGNBR"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="calc-figure-number"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="0pt">
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
            <xsl:text>~TCE~</xsl:text>
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
      	<xsl:if test="$debug">
      		<xsl:attribute name="border" select="'1pt solid blue'"/>
      	</xsl:if>
        <fo:block text-align="left">
          <fo:basic-link internal-destination="{@id}">
            <xsl:call-template name="calc-table-number"/>
          </fo:basic-link>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="0pt">
      	<xsl:if test="$debug">
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
      	<xsl:if test="$debug">
      		<xsl:attribute name="border" select="'1pt solid blue'"/>
      	</xsl:if>
        <fo:block>
          <fo:basic-link internal-destination="{@id}">
            <xsl:text>~TCE~</xsl:text>
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
      <xsl:when test="number(@PGBLKNBR) >= 17000">
        <xsl:call-template name="calculateCMMAppendixNumber"/>
        <xsl:text>-</xsl:text>          
      </xsl:when>
      <!-- END changes for Mantis 18540-->
      <xsl:otherwise>
        <!-- No prefix -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="page-number-suffix">
  	<!-- <xsl:message>Calculating ToC page number suffix.
  		Context: <xsl:value-of select="name()"/>
  		Ancestor authorityName: <xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName"/></xsl:message> -->
    <!-- <xsl:choose> -->
      <!-- For EM, a page number suffix can be specified in the top-level authorityName attribute (but not for the introduction). -->
      <!-- May need to double check how this is used... authorityName looks like it's also used for the section name in the footer. -->
      <!-- Comment out for now until the requirements are clarified... -->
      <!-- 
      <xsl:when test="not(ancestor::pmEntry[@pmEntryType='pmt58']) and ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName">
      	<xsl:text>-</xsl:text><xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=0]/@authorityName"/>
      </xsl:when> -->
      
      <!-- These are from ATA FO; leave for reference... -->
      <!-- <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = 0">
        [!++ No suffix ++]
      </xsl:when>
      <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR = 1">
        [!++ No suffix ++]
      </xsl:when>
      [!++<xsl:when test="ancestor-or-self::PGBLK/@CONFNBR">
        <xsl:text>-</xsl:text>
        <xsl:number value="ancestor-or-self::PGBLK/@CONFNBR" format="0000"/>        
      </xsl:when>++]
      <xsl:when test="$documentType='irm' and number(ancestor-or-self::PGBLK[@PGBLKNBR='5000' or @PGBLKNBR='6000']/@CONFNBR) >= 1000 and ancestor-or-self::PGBLK/EFFECT">
        <xsl:text>-&#8203;</xsl:text>
        <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
      </xsl:when> -->
    <!-- </xsl:choose> -->
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
      <!-- <xsl:call-template name="get-mtoss"/>--><!-- Task or subtask number (in parens) [not for EM] -->
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
      <!-- EM: This should not be necessary. leave for reference for now... -->
      <xsl:when test="$pgblkRow='1'">
        <fo:table-row keep-with-next.within-page="always">
          <fo:table-cell xsl:use-attribute-sets="toc.table.cell" padding-left="{$indent}">
            <!-- For S1000D make top-level ToC entries bold -->
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
              <fo:basic-link color="blue">
                <xsl:attribute name="internal-destination" select="$refid"/>
                <xsl:text>~TCE~</xsl:text><!--Table of Contents Entry--><!--Between the prefix and the number?-->
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
              <fo:basic-link color="blue">
                <xsl:attribute name="internal-destination" select="$refid"/>
                <xsl:text>~TCE~</xsl:text><!--Table of Contents Entry--><!--Between the prefix and the number?-->
                <xsl:value-of select="$page-number-prefix"/>
                <fo:page-number-citation>
                  <xsl:attribute name="ref-id">
                    <xsl:value-of select="$refid"/>
                  </xsl:attribute>
                </fo:page-number-citation>
			      <xsl:if test="ancestor-or-self::pmEntry/@confnbr">
			        <fo:inline>
			          <xsl:value-of select="concat('-',ancestor-or-self::pmEntry/@confnbr)"/>
			        </fo:inline>
			      </xsl:if>

                <xsl:value-of select="$page-number-suffix"/>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Called for the ToC -->
  <xsl:template match="pmEntryTitle" mode="task-subtask-title">
    <xsl:apply-templates />
  </xsl:template>
  
  <!-- Called for the ToC -->
  <xsl:template match="title" mode="task-subtask-title">
    <xsl:apply-templates />
  </xsl:template>


</xsl:stylesheet>
