<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xep="http://www.renderx.com/XEP/xep" xmlns:itg="http://www.infotrustgroup.com"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">
  
  <xsl:import href="../shared/unhandled-element.xsl"/>
  <xsl:import href="../S1000D_shared/standardVariables.xsl"/>
  
  <xsl:include href="../S1000D_shared/stdPages.xsl"/>
  <xsl:include href="../shared/cageInfo.xsl"/>
  <xsl:include href="../S1000D_shared/partinfo-table.xsl"/>
  
  <xsl:variable name="debug-lep-render" select="false()"/>
  
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
  
  <xsl:template match="/">
    <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
      <xsl:processing-instruction name="xep-pdf-initial-zoom">fit</xsl:processing-instruction>
      <xsl:processing-instruction name="xep-pdf-page-layout">single-page</xsl:processing-instruction>
      <xsl:processing-instruction name="xep-pdf-viewer-preferences">fit-window center-window</xsl:processing-instruction>
      <xsl:processing-instruction name="xep-pdf-logical-page-numbering" select="'false'"/>
      <xsl:processing-instruction name="xep-pdf-view-mode">show-none</xsl:processing-instruction>
      <xsl:call-template name="define-pagesets"/>
      <xsl:apply-templates select="lepdata"/>
    </fo:root>
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
  
  <xsl:template name="get-revdate">
    <xsl:param name="asText"/>
    <xsl:param name="intro-toc"/>
    <xsl:value-of select="'YYYYMMDD'"/>
  </xsl:template>

  <xsl:attribute-set name="lep.table.cell">
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
    <xsl:attribute name="padding-left">4pt</xsl:attribute>
    <xsl:attribute name="padding-right">4pt</xsl:attribute>
    <xsl:attribute name="border-style">none</xsl:attribute>
    <xsl:attribute name="display-align">after</xsl:attribute>
  </xsl:attribute-set>

  <!-- <xsl:variable name="manualRevdate" select="/*/@REVDATE"/> -->
  <xsl:variable name="manualRevdate" select="//page[@revdate != ''][1]/@revdate"/>
  
  <xsl:variable name="LEP_PASS" select="1"/>
  
  <xsl:template match="lepdata">
    <!-- Loop through all the section ToCs (and Intro ToC) -->
    <xsl:for-each select="page[@number = 'TC-1']">
      <xsl:variable name="chapter" select="@chapter"/>
      <xsl:variable name="chapterCtr" select="@chapter-ctr"/>
      <xsl:variable name="section" select="@section"/>
      <!-- If there is no chapter specified, it is the Intro ToC. -->
      <xsl:variable name="frontmatter" select="if (@chapter = '') then '1' else '0'"/>
      
      <!-- Make a new page sequence for each LEP (Chapter and Intro) -->
      
      <xsl:if test="$debug-lep-render">
	      <xsl:message>Render LEP: Making new page sequence for LEP; LEP_PASS '<xsl:value-of select="$LEP_PASS"/>';
	        chapter '<xsl:value-of select="$chapter"/>'; chapterCtr '<xsl:value-of select="$chapterCtr"/>'; section '<xsl:value-of select="$section"/>'; frontmatter '<xsl:value-of select="$frontmatter"/>'</xsl:message>
      </xsl:if>
      
      <fo:page-sequence master-reference="Lep" font-family="Arial" initial-page-number="1" force-page-count="even">
        <xsl:call-template name="init-static-content-lep">
          <xsl:with-param name="isIntroToc" select="number($frontmatter)"/>
        </xsl:call-template>
        <fo:flow flow-name="xsl-region-body">
          <fo:block>
            <xsl:attribute name="id">
              <xsl:choose>
                <xsl:when test="1 = number($frontmatter)">
                  <xsl:text>lep_frontmatter</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('chapter_lep_',$chapter)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            
            <fo:marker marker-class-name="footerChapter">
              <xsl:value-of select="if ($chapter = '') then 'frontmatter' else $chapter"/>
            </fo:marker>
            
            <xsl:if test="not($chapterCtr='')">
	            <fo:marker marker-class-name="footerChapterCtr">
	              <xsl:value-of select="$chapterCtr"/>
	            </fo:marker>
            </xsl:if>
            
            <xsl:if test="not($section = '')">
	            <fo:marker marker-class-name="footerSection">
	              <xsl:value-of select="$section"/>
	            </fo:marker>
            </xsl:if>
            
            <!-- Added default effectivity marker of 'All' for frontmatter. (Mantis #17829) -->
            <fo:block>
              <fo:marker marker-class-name="efftextValue">ALL</fo:marker>
            </fo:block>
            
            <fo:block text-align="left" space-after="12pt">
              <fo:inline/>
            </fo:block>
            
            <fo:table border="none">
              <fo:table-column column-number="1" column-width="1pc"/>
              <fo:table-column column-number="2" column-width="11pc"/>
              <fo:table-column column-number="3" column-width="1pc"/>
              <fo:table-column column-number="4" column-width="6pc"/>
              
              
              <fo:table-body border-style="none" font-size="10pt">
                  <xsl:choose>
                    <xsl:when test="number($frontmatter) = 1">
                      <xsl:call-template name="do-lep-frontmatter">
                        <xsl:with-param name="LEP_EXTRACT_FILE" select="$LEP_EXTRACT_FILE"/><!-- itg:escape-path($LEP_EXTRACT_FILE) -->
                        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
                        <xsl:with-param name="frontmatter" select="1"/>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="do-chapter">
                        <!-- <xsl:with-param name="LEP_EXTRACT_FILE" select="itg:escape-path($LEP_EXTRACT_FILE)"/> -->
                        <xsl:with-param name="chapter" select="$chapter"/>
                        <xsl:with-param name="chapterCtr" select="$chapterCtr"/>
                        <xsl:with-param name="section" select="$section"/>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose>
                <!-- <xsl:if test="number($frontmatter) = 1">
                  <xsl:call-template name="do-lep-frontmatter">
                    <xsl:with-param name="LEP_EXTRACT_FILE" select="$LEP_EXTRACT_FILE"/>
                    <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
                    <xsl:with-param name="frontmatter" select="1"/>
                  </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="do-chapter">
                  <xsl:with-param name="chapter" select="$chapter"/>
                  <xsl:with-param name="section" select="$section"/>
                </xsl:call-template> -->
              </fo:table-body>
            </fo:table>
            
          </fo:block>
        </fo:flow>
      </fo:page-sequence>
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template name="do-page">
  
     <xsl:choose>
       <xsl:when test="@number = 'TC-1'">
         <!-- This will output the chapter number
           <xsl:call-template name="section-subject-divider-row"/>
         -->
         <xsl:call-template name="toc-row"/>
       </xsl:when>
       
       <!-- If the section, subject, or label has changed, output the ATA number for the section. -->
       <!-- <xsl:when test="@section != preceding-sibling::page[1]/@section 
       	or @subject != preceding-sibling::page[1]/@subject
       	or @label != preceding-sibling::page[1]/@label"> -->
       	
       <xsl:when test="@section != preceding-sibling::page[1]/@section
        or @subject != preceding-sibling::page[1]/@subject">
       	<!-- or @label != preceding-sibling::page[1]/@label [label only occurs at the first time it needs to be output] -->
         <xsl:if test="$debug-lep-render">
	         <xsl:message>Section or subject changed. Label: <xsl:value-of select="@label"/></xsl:message>
	     </xsl:if>
       	
         <xsl:call-template name="section-subject-divider-row"/>
         <xsl:if test="@section != preceding-sibling::page[1]/@section
            and preceding-sibling::page[1]/@chapter != ''
         	or @subject != preceding-sibling::page[1]/@subject
         	and preceding-sibling::page[1]/@chapter != ''">
           <xsl:call-template name="figure-pgblk-divider-row"/>
         </xsl:if>
       </xsl:when>
       <!--Changed for mantis #20187-->
       <!--<xsl:when test="@pgblk != preceding-sibling::page[1]/@pgblk and @number != 'TC-1'">-->
       <!-- <xsl:when test="concat(@pgblk,@confnbr) != concat(preceding-sibling::page[1]/@pgblk,preceding-sibling::page[1]/@confnbr) and @number != 'TC-1'"> -->
       <!-- <xsl:when test="concat(@pgblk,@confnbr,@chapter,@section,@subject) !=
         concat(preceding-sibling::page[1]/@pgblk,preceding-sibling::page[1]/@confnbr,
         preceding-sibling::page[1]/@chapter,preceding-sibling::page[1]/@section,
         preceding-sibling::page[1]/@subject) and @number != 'TC-1'">-->
       <!-- RS: Added check for changed label, since sometimes (especially in "em" doctype) everything else is the same. -->
       <!-- UPDATE: But only when the page number is not the next in sequence (i.e., it should be restarting numbering). -->
       <xsl:when test="(@label and @number castable as xs:double and preceding-sibling::page[1]/@number castable as xs:double and not(@number = preceding-sibling::page[1]/@number + 1))
         or concat(@pgblk,@confnbr,@chapter,@section,@subject) !=
         concat(preceding-sibling::page[1]/@pgblk,preceding-sibling::page[1]/@confnbr,
         preceding-sibling::page[1]/@chapter,preceding-sibling::page[1]/@section,
         preceding-sibling::page[1]/@subject)">
         <xsl:if test="$debug-lep-render">
         	<xsl:message>Section change detected. Label: <xsl:value-of select="@label"/></xsl:message>
         </xsl:if>
         
         <!-- In some cases the ATA number doesn't change, but still it is output for every heading. -->
         <!-- For now, I see it mainly in 3-level EM. This may need to be refined later. -->
         <xsl:if test="@chapter-ctr and @documentType='em'">
          <xsl:call-template name="section-subject-divider-row"/>
         </xsl:if>
         <xsl:call-template name="figure-pgblk-divider-row"/>
       </xsl:when>
     </xsl:choose>
     <!-- DJH ADD END -->

     <!-- DJH REMOVE 20091124
       <xsl:if test="@section != preceding-sibling::page[1]/@section 
         or @subject != preceding-sibling::page[1]/@subject"> 
         <xsl:call-template name="section-subject-divider-row"/>
       </xsl:if>

       <xsl:if test="@pgblk != preceding-sibling::page[1]/@pgblk">
         <xsl:call-template name="figure-pgblk-divider-row"/>
       </xsl:if>
     -->

     <!-- Make sure we skip the "real" foldouts, and the second placeholder page -->
     <!--<xsl:if test="not(@foldout) or (@foldout and 1 = (@number mod 2))">-->
       <xsl:call-template name="detail-standard-row">
         <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
       </xsl:call-template>
     <!--</xsl:if>-->
	
  </xsl:template>
    
  <xsl:template name="do-chapter">
    <!--<xsl:param name="LEP_EXTRACT_FILE"/>-->
    <xsl:param name="chapter"/>
    <xsl:param name="chapterCtr"/>
    <xsl:param name="section"/>
    <xsl:param name="manualRevdate"/>
    <!--<xsl:for-each select="document($LEP_EXTRACT_FILE)">-->

    <xsl:if test="$debug-lep-render">
	    <xsl:message>Render Chapter LEP (do-chapter)</xsl:message>
    </xsl:if>
    
      <xsl:variable name="lepPageCount">
        <xsl:choose>
          <xsl:when test="$LEP_PASS = 0">
            <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
              <!-- <xsl:variable name="chapterPageCount" select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text/@value = $chapter])"/> -->
              <xsl:variable name="chapterPageCount">
              	<xsl:choose>
		       		<!-- It looks like MM uses only the first digit of the section code; the second one may change within a chapter -->
		       		<!-- UPDATE: Now using chapterCtr for 3-level EM to specify the chapter. This is just the count of preceding -->
		       		<!-- pmEntries. -->
              		<xsl:when test="not($chapterCtr='')">
					    <xsl:if test="$debug-lep-render">
	              			<xsl:message>Using chapterCtr (<xsl:value-of select="$chapterCtr"/>) to calculate number of LEP pages</xsl:message>
	              		</xsl:if>
		    			<xsl:value-of select="count(//xep:text[@value = '__xchapter-ctr__'][following-sibling::xep:text[1]/@value = $chapterCtr])"/>
              		</xsl:when>
              		<!-- 
		       		<xsl:when test="not($section='') and @documentType='mm'">
				      <xsl:if test="$debug-lep-render">
              			<xsl:message>Using section (one digit) to calculate number of LEP pages (render)</xsl:message>
				      </xsl:if>
		    		  <xsl:value-of select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text[1]/@value = $chapter][following-sibling::xep:text[@value = '__section__'][substring(following-sibling::xep:text[1]/@value,1,1) = substring($section,1,1)]])"/>
		       		</xsl:when>
              		<xsl:when test="not($section='')">
				      <xsl:if test="$debug-lep-render">
              			<xsl:message>Using section (two digits) to calculate number of LEP pages (render)</xsl:message>
				      </xsl:if>
		    		  <xsl:value-of select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text[1]/@value = $chapter][following-sibling::xep:text[@value = '__section__'][substring(following-sibling::xep:text[1]/@value,1,2) = substring($section,1,2)]])"/>
              		</xsl:when> -->
              		<xsl:otherwise>
		    		  <xsl:value-of select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text[1]/@value = $chapter])"/>
				      <xsl:if test="$debug-lep-render">
	              		<xsl:message>Using chapter (<xsl:value-of select="$chapter"/>) to calculate number of LEP pages: <xsl:value-of select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text[1]/@value = $chapter])"/></xsl:message>
				      </xsl:if>
              		</xsl:otherwise>
              	</xsl:choose>
              </xsl:variable>
              <xsl:value-of select="if ($chapterPageCount mod 2 = 0) then ($chapterPageCount) else ($chapterPageCount + 1)"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
		      <xsl:if test="$debug-lep-render">
	            <xsl:message>Estimating LEP pages for chapter <xsl:value-of select="$chapter"/>; chapterCtr: <xsl:value-of select="$chapterCtr"/>; section <xsl:value-of select="$section"/></xsl:message>
		      </xsl:if>
            <xsl:call-template name="calculate-lep-pages">
              <xsl:with-param name="chapter" select="$chapter"/>
              <xsl:with-param name="chapterCtr" select="$chapterCtr"/>
              <xsl:with-param name="section" select="$section"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
	  <xsl:if test="$debug-lep-render">
	      <xsl:message>Calculated or estimated lep pages = '<xsl:value-of select="$lepPageCount"/>' (do-chapter) </xsl:message>
	  </xsl:if>

      <xsl:choose>

   		<!-- It looks like MM uses only the first digit of the section code; the second one may change within a chapter -->
   		<!-- UPDATE: Now using chapterCtr for 3-level EM to specify the chapter. This is just the count of preceding -->
   		<!-- pmEntries. -->
   		
   		<xsl:when test="not($chapterCtr='')">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using chapterCtr ('<xsl:value-of select="$chapterCtr"/>') to select page range</xsl:message>
	      </xsl:if>

	      <xsl:for-each select="//page[@chapter-ctr = $chapterCtr]">
	
	        <!-- Output LEP pages before first section -->
	        <xsl:if test="count(preceding::page[@chapter-ctr = $chapterCtr]) = 0">
	          <xsl:call-template name="lep-row">
	            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
	            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
	            <xsl:with-param name="indent" select="'4pt'"/>
	            <xsl:with-param name="frontmatter" select="0"/>
	          </xsl:call-template>
	        </xsl:if>
	        
			<xsl:call-template name="do-page"/>
			
		  </xsl:for-each>
   		</xsl:when>
   		
   		<!-- Old 3-level logic using section for reference:
   		<xsl:when test="not($section='') and @documentType='mm'">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using section ('<xsl:value-of select="$section"/>') to select page range (one digit)</xsl:message>
	      </xsl:if>

	      <xsl:for-each select="//page[@chapter = $chapter][substring(@section,1,1)=substring($section,1,1)]">
	
	        [!++ Output LEP pages before first section ++]
	        <xsl:if test="count(preceding::page[@chapter = $chapter][substring(@section,1,1)=substring($section,1,1)]) = 0">
	          <xsl:call-template name="lep-row">
	            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
	            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
	            <xsl:with-param name="indent" select="'4pt'"/>
	            <xsl:with-param name="frontmatter" select="0"/>
	          </xsl:call-template>
	        </xsl:if>
	        
			<xsl:call-template name="do-page"/>
			
		  </xsl:for-each>
   		</xsl:when>
   		
      	<xsl:when test="not($section='')">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using section ('<xsl:value-of select="$section"/>') to select page range (two digits)</xsl:message>
	      </xsl:if>
	      
	      <xsl:for-each select="//page[@chapter = $chapter][substring(@section,1,2)=substring($section,1,2)]">
	
	        [!++ Output LEP pages before first section ++]
	        <xsl:if test="count(preceding::page[@chapter = $chapter][substring(@section,1,2)=substring($section,1,2)]) = 0">
	          <xsl:call-template name="lep-row">
	            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
	            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
	            <xsl:with-param name="indent" select="'4pt'"/>
	            <xsl:with-param name="frontmatter" select="0"/>
	          </xsl:call-template>
	        </xsl:if>
	        
			<xsl:call-template name="do-page"/>
				
	      </xsl:for-each>
		</xsl:when>-->

		<xsl:otherwise>
      	  <!-- Not using section code to divide into sections. -->
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using chapter ('<xsl:value-of select="$chapter"/>') to select page range</xsl:message>
	      </xsl:if>
	      
	      <xsl:for-each select="//page[@chapter = $chapter]">
	
	        <xsl:if test="count(preceding::page[@chapter = $chapter]) = 0">
	          <!-- DJH ADDED 20090820 START -->
	          <xsl:call-template name="lep-row">
	            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
	            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
	            <xsl:with-param name="indent" select="'4pt'"/>
	            <xsl:with-param name="frontmatter" select="0"/>
	          </xsl:call-template>
	          <!-- DJH ADDED 20090820 END -->
	          <!-- DJH REMOVED 20091124
	          <xsl:call-template name="toc-row" />
	          -->
	        </xsl:if>
	
	          <xsl:choose>
	            <xsl:when test="@number = 'TC-1'">
	              <!-- This will output the chapter number
	                <xsl:call-template name="section-subject-divider-row"/>
	              -->
	              <xsl:call-template name="toc-row"/>
	            </xsl:when>
	            
	            <!-- If the section, subject, or label has changed, output the ATA number for the section. -->
	            <xsl:when test="@section != preceding-sibling::page[1]/@section 
	            	or @subject != preceding-sibling::page[1]/@subject
	            	or @label != preceding-sibling::page[1]/@label">
	              <xsl:call-template name="section-subject-divider-row"/>
	              <xsl:if test="@section != preceding-sibling::page[1]/@section and preceding-sibling::page[1]/@chapter != ''
	               or @subject != preceding-sibling::page[1]/@subject and preceding-sibling::page[1]/@chapter != ''">
	                <xsl:call-template name="figure-pgblk-divider-row"/>
	              </xsl:if>
	            </xsl:when>
	            
	            <!--Changed for mantis #20187-->
	            <!--<xsl:when test="@pgblk != preceding-sibling::page[1]/@pgblk and @number != 'TC-1'">-->
	            <!-- <xsl:when test="concat(@pgblk,@confnbr) != concat(preceding-sibling::page[1]/@pgblk,preceding-sibling::page[1]/@confnbr)">-->
	            <xsl:when test="concat(@pgblk,@confnbr,@chapter,@section,@subject) !=
	              concat(preceding-sibling::page[1]/@pgblk,preceding-sibling::page[1]/@confnbr,
	              preceding-sibling::page[1]/@chapter,preceding-sibling::page[1]/@section,
	              preceding-sibling::page[1]/@subject) and @number != 'TC-1'">
	              <xsl:call-template name="figure-pgblk-divider-row"/>
	            </xsl:when>
	          </xsl:choose>
	          <!-- DJH ADD END -->
	
	          <!-- DJH REMOVE 20091124
	            <xsl:if test="@section != preceding-sibling::page[1]/@section 
	              or @subject != preceding-sibling::page[1]/@subject"> 
	              <xsl:call-template name="section-subject-divider-row"/>
	            </xsl:if>
	
	            <xsl:if test="@pgblk != preceding-sibling::page[1]/@pgblk">
	              <xsl:call-template name="figure-pgblk-divider-row"/>
	            </xsl:if>
	          -->
	
	          <!-- Make sure we skip the "real" foldouts, and the second placeholder page -->
	          <!--<xsl:if test="not(@foldout) or (@foldout and 1 = (@number mod 2))">-->
	            <xsl:call-template name="detail-standard-row">
	              <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
	            </xsl:call-template>
	          <!--</xsl:if>-->
	
	      </xsl:for-each>
		</xsl:otherwise>
	  </xsl:choose>
	  
    <!--</xsl:for-each>-->
  </xsl:template>

  <xsl:template name="do-lep-frontmatter">
    <xsl:param name="LEP_EXTRACT_FILE"/>
    <xsl:param name="chapter"/>
    <xsl:param name="manualRevdate" select="0"/>
    <xsl:param name="frontmatter" select="1"/>
	<xsl:if test="$debug-lep-render">
    	<xsl:message>Render LEP frontmatter; LEP_EXTRACT_FILE: <xsl:value-of select="$LEP_EXTRACT_FILE"/></xsl:message>
    </xsl:if>
    <xsl:for-each select="document($LEP_EXTRACT_FILE)">
      <xsl:for-each select="//page[@chapter = '']">
        <xsl:variable name="pagePrefix" select="substring-before(@number,'-')"/>
        <xsl:variable name="pageNumber" select="substring-after(@number,'-')"/>
        <xsl:if test="@number = 'TC-1'">
          <xsl:variable name="lepPageCount">
            <xsl:choose>
              <xsl:when test="$LEP_PASS = 0">
                <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
                  <xsl:variable name="chapterPageCount" select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text/@value = 'frontmatter'])"/>
                  <xsl:value-of select="if ($chapterPageCount mod 2 = 0) then ($chapterPageCount) else ($chapterPageCount + 1)"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="calculate-lep-pages">
                  <xsl:with-param name="chapter" select="$chapter"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
	      
	      <xsl:if test="$debug-lep-render">
	          <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (do-lep-frontmatter - for-each) </xsl:message>
	      </xsl:if>
	      
          <xsl:call-template name="lep-row">
            <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
            <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
            <xsl:with-param name="frontmatter" select="$frontmatter"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="number($pageNumber) = 1">
          <xsl:call-template name="figure-pgblk-divider-row"/>
        </xsl:if>
        <xsl:call-template name="detail-standard-row">
          <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="detail-standard-row">
    <xsl:param name="manualRevdate" select="0"/>
    <fo:table-row>
      <!-- Foldout Indicator (only called for odd page) -->
      <xsl:choose>
        <xsl:when test="@foldout">
          <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
            <fo:block font-size="10pt">
              <xsl:text>F</xsl:text>
            </fo:block>
          </fo:table-cell>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="detail-empty-cell"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <!-- Page Number (if foldout then this number/next number) -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="24pt">
        <fo:block font-size="10pt">
          <xsl:value-of select="@number"/>
          <xsl:if test="@confnbr and not(@confnbr='')">
          	<xsl:text>-</xsl:text>
          	<xsl:value-of select="@confnbr"/>
          </xsl:if>
        </fo:block>
      </fo:table-cell>
      
      <!-- Revision indicator -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
        <xsl:call-template name="lep-asterisk"/>
      </fo:table-cell>
      
      <!-- Date -->
      <xsl:variable name="revDate">
        <xsl:choose>
          <xsl:when test="((@revdate='') or (@revdate='0'))">
            <xsl:value-of select="$manualRevdate"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@revdate"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
        <fo:block font-size="10pt" white-space-treatment="preserve" white-space-collapse="false">
          <xsl:call-template name="convert-date">
            <xsl:with-param name="ata-date">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="figure-pgblk-divider-row">
     <fo:table-row keep-with-next.within-column="always">
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="12pt"
          padding-top="3pt"
          padding-bottom="3pt"
          number-columns-spanned="3">

        <fo:block font-size="10pt">
          <xsl:choose>
            <xsl:when test="starts-with(@number,'T-')">
              <xsl:text>Title</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'TC-')">
              <xsl:text>Table of Contents</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'TI-')">
              <xsl:text>Transmittal Information</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'RR-')">
              <xsl:text>Record of Revisions</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'RTR-')">
              <xsl:text>Record of Temporary Revisions</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'SBL-')">
              <xsl:text>Service Bulletin List</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'INTRO-')">
              <xsl:text>Introduction</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'VCL-')">
              <xsl:text>Vendor Code List</xsl:text>
            </xsl:when>
            <xsl:when test="starts-with(@number,'NI-')">
              <xsl:text>Numerical Index</xsl:text>
            </xsl:when>

            <!-- EM new Pgblk -->
            <!-- RS: Added @label as a test -->
            <xsl:when test="@label or (number(@number) = 1) or (1 = number(@number) - number(@pgblk))"><!-- $manualName = 'EM' and -->
               <!-- <fo:inline text-transform="capitalize"> -->
               <fo:inline text-transform="uppercase">
                 <!-- Add zero-width spaces after slashes for line breaking. -->
                <xsl:value-of select="replace(./@label,'/','/&#x0200B;')"/>
               </fo:inline>
            </xsl:when>

          </xsl:choose>
        </fo:block>
      </fo:table-cell>
      
      <!-- RS: What is this for?
      <xsl:choose>
        <xsl:when test="starts-with(@number,'T-')"/>
        <xsl:when test="starts-with(@number,'TC-')"/>
        <xsl:when test="starts-with(@number,'TI-')"/>
        <xsl:when test="starts-with(@number,'RR-')"/>
        <xsl:when test="starts-with(@number,'RTR-')"/>
        <xsl:when test="starts-with(@number,'SBL-')"/>
        <xsl:when test="starts-with(@number,'INTRO-')"/>
        <xsl:when test="starts-with(@number,'VCL-')"/>
        <xsl:when test="(number(@number) = 1) or (1 = number(@number) - number(@pgblk))"/>
        <xsl:when test="starts-with(@number,'NI-')"/>
      </xsl:choose>-->

    </fo:table-row>
  </xsl:template>

  <xsl:template name="toc-row">
    <fo:table-row>
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left"
          padding-top="3pt"
          padding-bottom="3pt"
          number-columns-spanned="3">
        <fo:block font-weight="normal">
          <xsl:text>Table of Contents</xsl:text>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="section-subject-divider-row">
    <xsl:variable name="chapter" select="@chapter"/>
    <xsl:if test="((@subject='') and (@unit='') and (preceding-sibling::page[1][@section=''][@chapter!='']))">
      <xsl:variable name="lepPageCount">
        <xsl:choose>
          <xsl:when test="$LEP_PASS = 0">
            <xsl:for-each select="document(itg:escape-path($LEP_RENDER_FILE))">
              <xsl:variable name="chapterPageCount" select="count(//xep:text[@value = '__chapter__'][following-sibling::xep:text/@value = $chapter])"/>
              <xsl:value-of select="if ($chapterPageCount mod 2 = 0) then ($chapterPageCount) else ($chapterPageCount + 1)"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="calculate-lep-pages">
              <xsl:with-param name="chapter" select="$chapter"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- For Debug
      <xsl:message>calculated lep pages = '<xsl:value-of select="$lepPageCount"/>' (section-subject-divider-row) </xsl:message>
      -->
      <xsl:call-template name="lep-row">
        <xsl:with-param name="lepTotalPages" select="$lepPageCount"/>
        <xsl:with-param name="indent" select="'4pt'"/>
        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
        <xsl:with-param name="frontmatter" select="0"/>
      </xsl:call-template>
    </xsl:if>
    <fo:table-row keep-with-next.within-column="always">
      <!-- Foldout Indicator -->
      <xsl:call-template name="detail-empty-cell"/>
      <!-- Title -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left"
          padding-top="3pt"
          number-columns-spanned="3"><!-- padding-bottom="3pt" -->
        <fo:block font-weight="bold">
          <fo:block>
            <xsl:call-template name="chapter-section-subject"/>
          </fo:block>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="chapter-section-subject">
    <xsl:value-of select="@chapter"/>
    <xsl:if test="@section != ''">
      <xsl:value-of select="concat('-',@section)"/>
    </xsl:if>
    <xsl:if test="@subject != ''">
      <xsl:value-of select="concat('-',@subject)"/>
    </xsl:if>
    <xsl:if test="@unit != ''">
      <xsl:value-of select="concat('-',@unit)"/>
    </xsl:if>
  </xsl:template>

  <!-- A row representing the LEP, calls itself to put in a row for each LEP page -->
  <!-- Uses the top level revdate -->
  <xsl:template name="lep-row">
    <xsl:param name="lepTotalPages" select="0"/>
    <xsl:param name="lepCallCount" select="1"/>
    <xsl:param name="manualRevdate" select="0"/>
    <xsl:param name="indent" select="'12pt'"/>
    <xsl:param name="frontmatter" select="0"/>

    <xsl:if test="$lepCallCount = 1">
      <fo:table-row keep-with-next.within-column="always">
        <!-- Foldout Indicator -->
        <xsl:call-template name="detail-empty-cell"/>
        <!-- Title -->
        <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="{$indent}"
          padding-top="3pt"
          padding-bottom="3pt"
          number-columns-spanned="3">
          <fo:block font-size="10pt">
            <xsl:text>List of Effective Pages</xsl:text>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </xsl:if>

    <fo:table-row>
      <!-- Foldout indicator -->
      <xsl:call-template name="detail-empty-cell"/>

      <!-- Page -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="left" padding-left="24pt">
        <fo:block font-size="10pt">
          <xsl:value-of select="concat('LEP-',$lepCallCount)"/>
        </fo:block>
      </fo:table-cell>

      <!-- Revision indicator -->
      <!--<xsl:call-template name="detail-empty-cell"/>-->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
        <xsl:call-template name="lep-asterisk"/>
      </fo:table-cell>

      <!-- Revdate -->
      <fo:table-cell xsl:use-attribute-sets="lep.table.cell" text-align="right">
        <xsl:variable name="revDate">
          <xsl:choose>
            <xsl:when test="number($frontmatter) = 1">
              <xsl:value-of select="$manualRevdate"/>
            </xsl:when>
            <xsl:when test="((@revdate='') or (@revdate='0'))">
              <xsl:value-of select="$manualRevdate"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@revdate"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <fo:block font-size="10pt">
          <!-- DJH START -->
          <!--
          <xsl:call-template name="lep-asterisk">
            <xsl:with-param name="revDate">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
          -->
          <!-- DJH END -->
          <xsl:call-template name="convert-date">
            <xsl:with-param name="ata-date">
              <xsl:value-of select="$revDate"/>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:table-cell>

    </fo:table-row>

    <xsl:if test="$lepCallCount &lt; $lepTotalPages">
      <xsl:call-template name="lep-row">
        <xsl:with-param name="lepCallCount" select="$lepCallCount + 1"/>
        <xsl:with-param name="lepTotalPages" select="$lepTotalPages"/>
        <xsl:with-param name="manualRevdate" select="$manualRevdate"/>
        <xsl:with-param name="frontmatter" select="$frontmatter"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="lep-asterisk">
    <fo:block>
      <xsl:value-of select="@revised"/>
    </fo:block>
  </xsl:template>

  <!-- An empty row, which separates groups (like pgblk changes) in the listing -->
  <xsl:template name="detail-blank-row">
    <fo:table-row>
      <xsl:call-template name="detail-empty-cell"/>
      <xsl:call-template name="detail-empty-cell"/>
      <xsl:call-template name="detail-empty-cell"/>
      <xsl:call-template name="detail-empty-cell"/>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="detail-empty-cell">
    <fo:table-cell xsl:use-attribute-sets="lep.table.cell">
      <fo:block>
        <xsl:text>&#160;</xsl:text>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template name="calculate-lep-pages">
    <xsl:param name="chapter" select="''"/>
    <xsl:param name="chapterCtr"/>
    <xsl:param name="section" select="''"/>
    <xsl:param name="lepPages" select="0"/>
    <xsl:param name="callCount" select="0"/>
    <!-- =========================================================================================== -->
    <!-- Calculate the number of pages the LEP will use, and round to an even number                 -->
    <!-- Need to insert that number of entries in the table, so the template is called a second time -->
    <!-- to recalculate number of pages. For example if there were exactly two pages of entries      -->
    <!-- then adding the lep lines would push it 4 pages. -->
    <!-- =========================================================================================== -->
    <!-- Approximate number of lep entries in a page -->
    <xsl:variable name="entriesPerPage" select="84"/>
    <!-- CJM : OCSHONSS-422 : Changed entriesPerPage value from 74 to 78 [RS: Now 84] -->
    <!-- Each new Pgblk element adds a blank line in the LEP -->
    <xsl:variable name="pgblkCount">
      <!-- <xsl:value-of select="count(//page[@chapter = $chapter])"/> -->
      <xsl:choose>
   		<!-- It looks like MM uses only the first digit of the section code; the second one may change within a chapter -->
   		<!-- UPDATE: Now using chapterCtr -->
      	<xsl:when test="not($chapterCtr='')">
	      <xsl:value-of select="count(//page[@chapter-ctr = $chapterCtr])"/>
      	</xsl:when>
   		<!-- 
   		<xsl:when test="not($section='') and @documentType='mm'">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using section to estimate LEP pages (one digit)</xsl:message>
	      </xsl:if>
	      <xsl:value-of select="count(//page[@chapter = $chapter][substring(@section,1,1)=substring($section,1,1)])"/>
   		</xsl:when>
      	<xsl:when test="not($section='')">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using section to estimate LEP pages (two digits)</xsl:message>
	      </xsl:if>
	      <xsl:value-of select="count(//page[@chapter = $chapter][substring(@section,1,2)=substring($section,1,2)])"/>
      	</xsl:when>-->
      	<xsl:otherwise>
	      <xsl:value-of select="count(//page[@chapter = $chapter])"/>
      	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Added labelCount for Mantis #17198 -->
    <!-- Modified labelCount to count the characters in the @label attributes. It divides that number by 14 (the average number of characters in a lable line (title) in the LEP. -->
    <xsl:variable name="labelCount">
      <!--<xsl:value-of select="count(//page[@chapter = $chapter][@label]) * xs:float(2.5)"/>-->
      <!--<xsl:value-of select="count(//page[@chapter = $chapter][@label]) * xs:float(3)"/>-->
      <!-- <xsl:value-of select="round(sum(//page[@chapter = $chapter]/@label/string-length()) div 14)"/> -->
      
      <xsl:choose>
      	<xsl:when test="not($chapterCtr='')">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using chapterCtr to estimate number of label lines</xsl:message>
	      </xsl:if>
	      <xsl:value-of select="round(sum(//page[@chapter-ctr = $chapterCtr]/@label/string-length()) div 14)"/>
      	</xsl:when>
      	<!-- 
   		<xsl:when test="not($section='') and @documentType='mm'">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using section to estimate number of label lines (one digit)</xsl:message>
	      </xsl:if>
	      <xsl:value-of select="round(sum(//page[@chapter = $chapter][substring(@section,1,1)=substring($section,1,1)]/@label/string-length()) div 14)"/>
   		</xsl:when>
      	<xsl:when test="not($section='')">
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Using section to estimate number of label lines (two digits)</xsl:message>
	      </xsl:if>
	      <xsl:value-of select="round(sum(//page[@chapter = $chapter][substring(@section,1,2)=substring($section,1,2)]/@label/string-length()) div 14)"/>
      	</xsl:when> -->
      	<xsl:otherwise>
	      <xsl:if test="$debug-lep-render">
	      	  <xsl:message>Not using section to estimate LEP pages (calculation) (render)</xsl:message>
	      </xsl:if>
	      <xsl:value-of select="round(sum(//page[@chapter = $chapter]/@label/string-length()) div 14)"/>
      	</xsl:otherwise>
      </xsl:choose>
      
    </xsl:variable>
    <xsl:variable name="rawLepCount">
      <!--
      <xsl:value-of select="ceiling(($pgblkCount + $lepPages ) div $entriesPerPage)"/>
      -->
      <xsl:value-of select="ceiling(($pgblkCount + $labelCount + $lepPages ) div $entriesPerPage)"/>
    </xsl:variable>
    
    <xsl:if test="$debug-lep-render">
	    <xsl:message>&#xA;chapter = '<xsl:value-of select="$chapter"/>'</xsl:message>
	    <xsl:message>chapterCtr = '<xsl:value-of select="$chapterCtr"/>'</xsl:message>
	    <xsl:message>section = '<xsl:value-of select="$section"/>'</xsl:message>
	    <xsl:message>lepPages (parameter) = '<xsl:value-of select="$lepPages"/>'</xsl:message>
	    <xsl:message>pgblkCount (# pages in section) = '<xsl:value-of select="$pgblkCount"/>'</xsl:message>
	    <xsl:message>labelCount = '<xsl:value-of select="$labelCount"/>'</xsl:message>
	    <xsl:message>rawLepCount = '<xsl:value-of select="$rawLepCount"/>'</xsl:message>
    </xsl:if>

    <!-- ========================== -->
    <xsl:choose>
      <!-- Don't recurse more than once. -->
      <xsl:when test="$lepPages = 0 and $callCount = 0">
        <!-- For Debug
        <xsl:message>Calling calculate-lep-pages from inside calculate-lep-pages.</xsl:message>
        -->
        <xsl:call-template name="calculate-lep-pages">
          <xsl:with-param name="lepPages" select="$rawLepCount"/>
          <xsl:with-param name="callCount" select="1"/>
          <xsl:with-param name="chapter" select="$chapter"/>
          <xsl:with-param name="chapterCtr" select="$chapterCtr"/>
          <xsl:with-param name="section" select="$section"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Return value is number of pages rounded to even pages. -->
      <xsl:otherwise>
        <xsl:value-of select="$rawLepCount + ($rawLepCount mod 2)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
