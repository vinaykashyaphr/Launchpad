<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

  <xsl:template name="do-pdf-bookmarks">
    <rx:outline>

      <rx:bookmark internal-destination="eipc_title_page" collapse-subtree="false">
        <rx:bookmark-label>
          <xsl:text>Engine Illustrated Parts Catalog</xsl:text>
        </rx:bookmark-label>

      <!--TRANSMITTAL INFORMATION-->
      <rx:bookmark internal-destination="{/pm/content/pmEntry[@pmEntryType='pmt52']/@id}">
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
          <xsl:message>No PDF bookmark for RR in ACMM</xsl:message>
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
          <xsl:message>No PDF bookmark for RTR in ACMM</xsl:message>
        </xsl:when>
        <xsl:otherwise>
<!--           <rx:bookmark internal-destination="{/CMM/MFMATR/TRLIST/@KEY}"> -->
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
      <!-- SB list is usually after the Introduction in EIPC. -->
      <!-- <xsl:choose>
        <xsl:when test="($documentType = 'acmm') and (descendant::ISEMPTY)">
          <xsl:message>No PDF bookmark for empty SBL in ACMM</xsl:message>
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
      </xsl:choose> -->

      <!--LIST OF EFFECTIVE PAGES-->
      <xsl:choose>
        <xsl:when test="$documentType = 'acmm'">
          <xsl:message>No PDF bookmark for LEP in ACMM</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <rx:bookmark internal-destination="lep_frontmatter">
            <rx:bookmark-label>LIST OF EFFECTIVE PAGES</rx:bookmark-label>
          </rx:bookmark>
        </xsl:otherwise>
      </xsl:choose>

      <!--TABLE OF CONTENTS-->
      <rx:bookmark internal-destination="intro_toc">
        <rx:bookmark-label>TABLE OF CONTENTS</rx:bookmark-label>
      </rx:bookmark>

	  <!-- Process top-level pmEntries after and including the Introduction -->
      <xsl:apply-templates select="/pm/content/pmEntry[@pmEntryType='pmt58' or preceding-sibling::pmEntry[@pmEntryType='pmt58']]" mode="pdfBookmark"/>
      </rx:bookmark>
    </rx:outline>
  </xsl:template>

  <!-- Top-level pmEntry bookmarks (Introduction or after)-->
  <xsl:template match="pmEntry" mode="pdfBookmark">
     <!-- Output the top-level PDF bookmarks -->
       <xsl:choose>
        <!-- SB list is after the introduction in EIPC -->
       	<xsl:when test="@pmEntryType='pmt55'">
	     <rx:bookmark internal-destination="{@id}">
	       <rx:bookmark-label>
	         <xsl:value-of select="upper-case(pmEntryTitle)"/>
	       </rx:bookmark-label>
	     </rx:bookmark>
       	</xsl:when>
        <!-- Vendor code list is after the introduction in EIPC -->
       	<xsl:when test="@pmEntryType='pmt90'">
	     <rx:bookmark internal-destination="{@id}">
	       <rx:bookmark-label>
	         <xsl:value-of select="upper-case(pmEntryTitle)"/>
	       </rx:bookmark-label>
	     </rx:bookmark>
       	</xsl:when>
        <!-- For the Introduction, add Task-level entries. -->
        <!-- UPDATE: The EIPC original sample I have did not do this -->
       	<xsl:when test="@pmEntryType='pmt58'">
	     <rx:bookmark internal-destination="{@id}">
	       <rx:bookmark-label>
	         <xsl:value-of select="upper-case(pmEntryTitle)"/>
	       </rx:bookmark-label>
       	   <!-- Process the Introduction 2nd-level pmEntries as "tasks" -->
       	   <!-- <xsl:apply-templates select="pmEntry" mode="pdfBookmarkTask"/> -->
       	 </rx:bookmark>
       	</xsl:when>
       	<!-- Otherwise it should be a top-level pmEntry Chapter -->
       	<xsl:otherwise>
	      <!-- For EIPC add a bookmark for the Numerical Index before the first IPD section -->
	      <xsl:if test="@pmEntryType='pmt75' and count(preceding-sibling::pmEntry[1][@pmEntryType='pmt75'])=0">
			<rx:bookmark>
				<xsl:attribute name="internal-destination">
					<xsl:value-of select="'num_index'"/>
				</xsl:attribute>
				<rx:bookmark-label>
					<xsl:text>NUMERICAL INDEX</xsl:text>
				</rx:bookmark-label>
			</rx:bookmark>
		 </xsl:if>    
		 <!-- EIPC: Use the LEP for a destination -->    
	     <rx:bookmark internal-destination="concat('chapter_lep_',generate-id())"><!-- {@id} -->
	       <rx:bookmark-label>
	         <xsl:text>Chapter </xsl:text>
	         <xsl:value-of select="@authorityDocument"/>
	         <xsl:text> - </xsl:text>
	         <xsl:value-of select="upper-case(pmEntryTitle)"/>
	       </rx:bookmark-label>
	       <rx:bookmark>
	            <xsl:attribute name="internal-destination">
	               <xsl:value-of select="concat('chapter_lep_',generate-id())"/>
	            </xsl:attribute>
	            <rx:bookmark-label>
	               <xsl:text>LIST OF EFFECTIVE PAGES</xsl:text>
	            </rx:bookmark-label>
	       </rx:bookmark>
	       <rx:bookmark>
	            <xsl:attribute name="internal-destination">
	               <xsl:value-of select="concat('chapter_toc_',generate-id())"/>
	            </xsl:attribute>
	            <rx:bookmark-label>
	               <xsl:text>TABLE OF CONTENTS</xsl:text>
	            </rx:bookmark-label>
	       </rx:bookmark>
   	       <xsl:apply-templates select="pmEntry" mode="pdfBookmarkSection"/>
         </rx:bookmark>
       	</xsl:otherwise>
       </xsl:choose>
  </xsl:template>

  <!-- This is called for second-level pmEntries within the main body (should be Sections) -->
  <xsl:template match="pmEntry" mode="pdfBookmarkSection">
    <rx:bookmark internal-destination="{@id}">
      <rx:bookmark-label>
         <xsl:text>Section </xsl:text>
         <!-- <xsl:value-of select="substring(@authorityDocument,4,2)"/>
         <xsl:text> - </xsl:text> -->
         <xsl:value-of select="@authorityDocument"/>
         <!-- In the sample document, Section levels always have "-00" added  -->
         <!-- <xsl:text>-00</xsl:text> -->
         <xsl:text> - </xsl:text>
         <xsl:value-of select="upper-case(pmEntryTitle)"/>
      </rx:bookmark-label>
      <xsl:apply-templates select="pmEntry" mode="pdfBookmarkSubject"/>
    </rx:bookmark>
  </xsl:template>
  
  <!-- This is called for third-level pmEntries within the main body (should be Subjects (sometimes called "Units"?)) -->
  <xsl:template match="pmEntry" mode="pdfBookmarkSubject">
    <rx:bookmark internal-destination="{@id}">
      <rx:bookmark-label>
         <xsl:text>Unit </xsl:text>
         <xsl:value-of select="@authorityDocument"/>
         <xsl:text> - </xsl:text>
         <xsl:value-of select="upper-case(pmEntryTitle)"/>
      </rx:bookmark-label>
      <!-- <xsl:apply-templates select="pmEntry" mode="pdfBookmarkPgblk"/> -->
      <xsl:for-each select="dmContent/dmodule/content/illustratedPartsCatalog/figure">
      	<xsl:call-template name="iplFigureBookmark"/>
      </xsl:for-each>
      
    </rx:bookmark>
  </xsl:template>

  <xsl:template name="iplFigureBookmark">
    <xsl:variable name="title">
      <xsl:text>Figure </xsl:text>
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
  
  
  <!-- This is called for fourth-level pmEntries within the main body (should be page-blocks) -->
  <!-- 
  <xsl:template match="pmEntry" mode="pdfBookmarkPgblk">
    <rx:bookmark internal-destination="{@id}">
      <rx:bookmark-label>
         <xsl:variable name="pageBlock">
         	<xsl:variable name="startat" select="number(@startat)"/>
         	<xsl:choose>
         		[!++ Page blocks that start at one more than a multiple of a thousand are the thousand without the one. ++]
         		<xsl:when test="$startat &gt; 1">
         		  <xsl:value-of select="$startat - 1"/>
         		</xsl:when>
         		<xsl:otherwise>1</xsl:otherwise>
         	</xsl:choose>
         </xsl:variable>
         <xsl:text>Page Block </xsl:text>
         <xsl:value-of select="$pageBlock"/>
         <xsl:text> - </xsl:text>
         <xsl:value-of select="upper-case(../pmEntryTitle)"/>
         <xsl:text> - </xsl:text>
         <xsl:value-of select="upper-case(pmEntryTitle)"/>
  		 <xsl:if test="@confnbr">
  			<xsl:text>-</xsl:text><xsl:value-of select="@confnbr"/>
  		 </xsl:if>
      </rx:bookmark-label>
    </rx:bookmark>
  </xsl:template> -->
  
  <!-- This is called for second-level pmEntries within the Introduction -->
  <!-- 
  <xsl:template match="pmEntry" mode="pdfBookmarkTask">
    <xsl:variable name="title">
      <xsl:apply-templates select="pmEntryTitle" mode="task-subtask-title"/>
    </xsl:variable>
    [!++ No task numbers in Introduction in EM
    <xsl:variable name="mtoss">
      <xsl:call-template name="get-mtoss"/>
    </xsl:variable>++]
    <rx:bookmark internal-destination="{@id}">
      <rx:bookmark-label>
        <xsl:number value="1 + count(preceding-sibling::pmEntry)" format="1."/>
        <xsl:value-of select="concat(' ',$title)"/>
      </rx:bookmark-label>
    </rx:bookmark>
  </xsl:template> -->

</xsl:stylesheet>