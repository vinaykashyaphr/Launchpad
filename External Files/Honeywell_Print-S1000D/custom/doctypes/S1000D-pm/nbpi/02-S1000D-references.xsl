<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Process various id and cross reference items, and other pre-processing requirements for S1000D.

S1000D-references.xsl

Originally created: April 15, 2013

Chris van Mels
NewBook Production Inc.

Notes:
=====

v.0.4:
=====
	- config file "S1000D-common-repository.xml" has been DEPRECATED
	
        - no longer need to cross-reference "S1000D-common-repository.xml" lookup file

	- XQuery process now collects all common repository and cross reference table
	  items from the collection of XML files in the S1000D zip and saves
	  into generated file "S1000D-repositories.xml"
	  
	- this XSLT will now get "commonRepository" and "crossRefTable" items
	  from "S1000D-repositories.xml"
	  

v.0.3:
=====
	- creating "commonRepository" section at bottom of document pulling in all
	  of the common "warning|caution|tools|etc." from the appropriate repository
	  documents included in the S1000D zip
	
	- will be cross-referencing expected root-filename values found in 
	  config file "S1000D-common-repository.xml" against the actual filenames
	  found in zip and stored in generated "S1000D-dir.xml" file
	  
	- filtering the "commonRepository" to only include the items actually referenced in
	  the combined XML file will be left to a later development phase
	  
	- similarly, creating a "crossRefTable" section at bottom of file with 
	  "PCT", "CCT", "ACT" and "ACT catalog" cross-reference data pulled in from
	  appropriate root-filename configured in "S1000D-common-repository.xml"
	  

v.0.2:
=====
	- adding unique identifier prefixes to all @id and @internalRefId in the combined document
	  (the "dmContent" fragments would have re-used simple ids)
	
	- adding descriptive attributes to "pmEntry"
	  e.g. 
	      <pmEntry pmEntryType="pmt53">
	      becomes
	      <pmEntry pmEntryType="pmt53" 
	               shortPrefix="DESC"
                       prefix="Description" 
                       section="Technical Descriptions">
              
           where values being found in "S1000D-captions.xml" lookup config file
	   

v.0.1:
=====
	- must first run "S1000D-consolidate.xsl" to collect all DMC fragments into a combined
	  PMC file as the "graphic" processing can't occur duing the "copy-of" process
	
	- parse consolidated "PMC" file and use generated "S1000D-dir.xml" as lookup file

        - filenames in S1000D zip also include version info which isn't include in the attributes,
          so find closest match instead
          e.g. 
          full path to expected image "ICN-S1000DBIKE-AAA-000000-A-U8025-00001-A-01-01.CGM"
          
          <graphic infoEntityIdent="ICN-S1000DBIKE-AAA-000000-A-U8025-00001-A-01">
          
          would be found using:
            
          contains($filename,"ICN-S1000DBIKE-AAA-000000-A-U8025-00001")

-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:sono="java:com.sonovision.arbortext.XslHelper"
  xmlns:helper="java:com.sonovision.saxonext.S1000DHelper">
  <!-- CV - @indent="yes" produces readable XML,
          but introduces leading space in table entries with bold:
            <entry>
              <b>TEXT</b>
            </entry>
            
        - use @indent="no" for final XML
          -->
  <xsl:output method="xml" media-type="text/xml" encoding="UTF-8" indent="no" />
  <!-- <xsl:strip-space elements="*"/> -->
  <!-- CV - XML lookup file with directory listing information of the S1000D zip
          (generated file)
          -->
  <xsl:variable name="S1000D-dir" select="document('S1000D-dir.xml')" />
  <!-- CV - XML lookup file with pmEntry captions 
          (config file)
          -->
  <xsl:variable name="S1000D-captions" select="document('S1000D-captions.xml')" />
  <!-- CV - XML lookup file with commonRepository "root-filename" entries
          (config file)
          -->
  <!-- DEPRECATED -->
  <!--
<xsl:variable name="S1000D-common-repository" select="document('S1000D-common-repository.xml')"/>
-->
  <!-- CV - XML lookup file containing "commonRepository" and "crossRefTable" gathered
          from the collection of S1000D zip XML files
          (generated file)
          -->
  <xsl:variable name="S1000D-repositories" select="document('S1000D-repositories.xml')" />
  <!-- CV - almost everything should just flow through -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>
  <!-- CV - put some line breaks around comments -->
  <!--
<xsl:template match="comment()" priority="1">
  <xsl:text>&#xA;</xsl:text>
  <xsl:comment>
    <xsl:value-of select="."/>
  </xsl:comment>
  <xsl:text>&#xA;</xsl:text>
</xsl:template>
-->
  <!-- ******************************************************************************* -->
  <!-- CV - find graphic match for "@infoEntityIdent" in the 
          "S1000D-dir.xml" lookup file-->
  <xsl:template match="graphic | symbol">
    <xsl:variable name="graphic-filename-root" select="@infoEntityIdent" />
    <!-- Try to find corresponding filename in the "S1000D-dir.xml" lookup file -->
    <xsl:variable name="graphic-filename">
      <!-- **************************
         e.g.
         
         <graphic infoEntityIdent="ICN-S1000DBIKE-AAA-000000-A-U8025-00001-A-01">
         
         and S1000D-dir.xml (lookup file):
         
         <directory>
          ...
          <file name="ICN-S1000DBIKE-AAA-000000-A-U8025-00001-A-01-01.CGM" size="107932" lastModified="1363785938000" date="20130320T092538" absolutePath="C:\data\newbook\Sonovision\2013-S1000D\source\20130411\.\ICN-S1000DBIKE-AAA-000000-A-U8025-00001-A-01-01.CGM"/>
          ...
         </directory>
         ************************** -->
      <!-- @name (relative path) -->
      <!-- <xsl:value-of select="$S1000D-dir/directory/file[contains(@name,$graphic-filename-root)]/@name"/> -->
      <!-- @absolutePath (full path) -->
      <!-- <xsl:value-of select="$S1000D-dir/directory/file[contains(@name,$graphic-filename-root)]/@absolutePath"/> -->
      <!-- CV - images might be in same root folder or in a sub-folder (e.g. "./figures")
            - if there's a sub-folder, then xml-dir-listing adds another nested "directory" wrapper 
            - "relative path" is still preferred option, as it's cleaner looking
              ("full path" would work, though)
              -->
      <xsl:choose>
        <!-- (a) if @infoEntityIdent not specified, then shouldn't generate @xlink:href
              (as it may end up with string that includes every file in the zip, 
               which will crash Arbortext during PDF creation)
              -->
        <xsl:when test="not(@infoEntityIdent)">
          <xsl:text></xsl:text>
        </xsl:when>
        <!-- (b) image in root folder -->
        <xsl:when test="$S1000D-dir/directory/file[contains(@name,$graphic-filename-root)]/@name != ''">
          <xsl:value-of select="$S1000D-dir/directory/file[contains(@name,$graphic-filename-root)]/@name" />
        </xsl:when>
        <!-- (c) image in sub-folder -->
        <xsl:when test="$S1000D-dir/directory/directory/file[contains(@name,$graphic-filename-root)]/@name != ''">
          <xsl:value-of select="$S1000D-dir/directory/directory[file[contains(@name,$graphic-filename-root)]]/@name" />
          <xsl:text>/</xsl:text>

          <!-- CV - if two same named files exist (e.g. "00-sample.cgm" and "00-sample.tif"), then both would appear in
                    the attribute separated by a space and not work when XEP tries to resolve the href
                  - will usually only occur when trying to print TIFF images instead of CGM
                  - only select the first instance and let later processing account for any special handling requirements
                    -->
          <!-- <xsl:value-of select="$S1000D-dir/directory/directory/file[contains(@name,$graphic-filename-root)]/@name" /> -->
          <xsl:value-of select="$S1000D-dir/directory/directory/file[contains(@name,$graphic-filename-root)][1]/@name" />

        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>&#xA;</xsl:text>
    <xsl:element name="{name()}">
      <xsl:if test="not($graphic-filename='')">
        <xsl:attribute name="xlink:href">
          <xsl:value-of select="$graphic-filename" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </xsl:element>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>
  
  
  <!-- ******************************************************************************* -->
  <!-- ******************************************************************************* -->
  <xsl:template match="@id | @internalRefId | @reasonForUpdateRefIds | @applicRefId">
  
    <!-- CV - add unique counters to the IDs and references in the consolidated document -->

    <!-- Generates an ID for the data module and adds it to the XML id and idref attributes -->
    <!-- within the data module to make them unique across the combined document. -->

    <!-- RS: Adding reasonForUpdateRefIds (it also refers to an id attribute). Technically -->
    <!-- they can have more than one ID, but we're only supporting one for now. -->
    <!-- RS: Also adding applicRefId (for effectivity information in the footer) -->

    <xsl:variable name="counter">
      <xsl:choose>
        <xsl:when test="ancestor::dmContent">
          <xsl:text>DMC</xsl:text>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="generate-id(ancestor::dmContent)" />
        </xsl:when>
        <xsl:when test="ancestor::pm">
          <xsl:text>PMC</xsl:text>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="generate-id(ancestor::pm)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>PMC</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="{name()}">
      <xsl:value-of select="$counter" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>
  <!-- ******************************************************************************* -->
  <!-- CV - adding descriptive attributes based on "pmEntry/@pmEntryType" 
          and found in the "S1000D-captions.xml" lookup file
          -->
  <xsl:template match="pmEntry">
    <xsl:variable name="pmEntryType" select="@pmEntryType" />
	<xsl:variable name="sectionNumber">
		<!-- For IM/SDOM/SDIM we have section numbers and can also have "enumerated" sections -->
		<!-- when there is more than one of the same pmEntryType in a row. E.g., the first one -->
		<!-- might be Section 2, and its sibling would be Section 2-1 (then 2-2, etc.) -->
		<xsl:if test="/pm/@type='im' or /pm/@type='sdim' or /pm/@type='sdom'">
			<xsl:variable name="effectivePmEntryType" select="ancestor-or-self::pmEntry/@pmEntryType"/>
			<xsl:choose>
				<!-- Check if it's a Section pmt code (91-99). -->
				<!-- UPDATE: Added 87-90 for sections 10-13. -->
				<xsl:when test="$effectivePmEntryType = 'pmt91' or $effectivePmEntryType = 'pmt92'
					or $effectivePmEntryType = 'pmt93' or $effectivePmEntryType = 'pmt94'
					or $effectivePmEntryType = 'pmt95' or $effectivePmEntryType = 'pmt96'
					or $effectivePmEntryType = 'pmt97' or $effectivePmEntryType = 'pmt98'
					or $effectivePmEntryType = 'pmt99'
					or $effectivePmEntryType = 'pmt87' or $effectivePmEntryType = 'pmt88'
					or $effectivePmEntryType = 'pmt89' or $effectivePmEntryType = 'pmt90'
					">
					<xsl:variable name="shortCode" select="$S1000D-captions/captions/entry[@type = $effectivePmEntryType]/@short"/>
					<xsl:variable name="sectionEnum" select="count(ancestor-or-self::pmEntry[last()]/preceding-sibling::pmEntry[@pmEntryType=$effectivePmEntryType])"/>
					<xsl:choose>
						<xsl:when test="$sectionEnum &gt; 0">
							<xsl:value-of select="$shortCode"/><xsl:text>-</xsl:text><xsl:value-of select="$sectionEnum"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$shortCode"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- For the Appendix, use a letter starting at "A" -->
				<xsl:when test="$effectivePmEntryType = 'pmt85'">
					<xsl:number value="count(ancestor-or-self::pmEntry[last()]/preceding-sibling::pmEntry[@pmEntryType=$effectivePmEntryType]) + 1" format="A"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:variable>
    <xsl:variable name="shortPrefix">
	  <xsl:variable name="topPmEntryType" select="ancestor-or-self::pmEntry[last()]/@pmEntryType"/>
      <xsl:variable name="shortPrefixText">
		<!--<xsl:message>Calculating shortPrefix for pmEntryType: <xsl:value-of select="$topPmEntryType"/></xsl:message>-->
        <xsl:choose>
			<!-- Use the section number for IM/SDOM/SDIM if a value for it was assigned above -->
			<xsl:when test="$sectionNumber != ''">
				<!--<xsl:message>using sectionNumber: <xsl:value-of select="$sectionNumber"/></xsl:message>-->
				<xsl:value-of select="$sectionNumber"/>
			</xsl:when>
			<!-- Assign a letter prefix for appendices (except for SPM/IM/SDOM/SDIM) -->
			<xsl:when test="$topPmEntryType='pmt85'
				and not(/pm/@type='spm' or /pm/@type='im' or /pm/@type='sdom' or /pm/@type='sdim')">
				<!--<xsl:message>Appendix shortPrefix: <xsl:number format="A" value="count(ancestor-or-self::pmEntry[last()]/preceding-sibling::pmEntry[@pmEntryType='pmt85'])+1"/></xsl:message>-->
				<xsl:number format="A" value="count(ancestor-or-self::pmEntry[last()]/preceding-sibling::pmEntry[@pmEntryType='pmt85'])+1"/>
			</xsl:when>
          <!--<xsl:when test="ancestor::pmEntry">
            <xsl:variable name="parentPmEntryType">
              <xsl:value-of select="ancestor::pmEntry/@pmEntryType" />
            </xsl:variable>
            <xsl:value-of select="$S1000D-captions/captions/entry[@type = $parentPmEntryType]/@short" />
          </xsl:when>-->
          <xsl:otherwise>
            <xsl:value-of select="$S1000D-captions/captions/entry[@type = $topPmEntryType]/@short" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- Add a hyphen after to use as part of the prefix for page numbers, figures, etc. -->
      <xsl:if test="$shortPrefixText != ''">
        <xsl:value-of select="$shortPrefixText" />
        <xsl:text>-</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="prefix" select="$S1000D-captions/captions/entry[@type = $pmEntryType]/@prefix" />
    <xsl:variable name="section" select="$S1000D-captions/captions/entry[@type = $pmEntryType]/@section" />
    <pmEntry>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="shortPrefix">
        <xsl:value-of select="$shortPrefix" />
      </xsl:attribute>
      <xsl:attribute name="prefix">
        <xsl:value-of select="$prefix" />
      </xsl:attribute>
      <xsl:attribute name="section">
        <xsl:value-of select="$section" />
      </xsl:attribute>
	  <!-- New for IM/SDIM/SDOM: sectionNumber attribute -->
	  <xsl:if test="$sectionNumber != ''">
		  <xsl:attribute name="sectionNumber">
			<xsl:value-of select="$sectionNumber" />
		  </xsl:attribute>
	  </xsl:if>
      <xsl:if test="not(ancestor::pmEntry)">
        <xsl:attribute name="startat">
          <xsl:value-of select="$S1000D-captions/captions/entry[@type = $pmEntryType]/@startat" />
        </xsl:attribute>
        <!-- Make sure the appendix numbering starts at 1 for IM/SDIM/SDOM (it defaults to 7000 from the captions file) -->
		<!-- UPDATE: Anything but SPM actually... -->
        <!--<xsl:if test="$pmEntryType='pmt85' and (/pm/@type='im' or /pm/@type='sdim' or /pm/@type='sdom')">-->
        <xsl:if test="$pmEntryType='pmt85' and not(/pm/@type='spm')">
        	<xsl:attribute name="startat">1</xsl:attribute>
        </xsl:if>
	    <!-- Add a new attribute to flag front-matter sections, so we don't need to search for pmt codes -->
	    <!-- repeatedly in XSLT. -->
		<xsl:if test="@pmEntryType='pmt51' or @pmEntryType='pmt52' or @pmEntryType='pmt53' or @pmEntryType='pmt54'
		  or @pmEntryType='pmt55' or @pmEntryType='pmt56' or @pmEntryType='pmt57' or @pmEntryType='pmt77'">
		  <xsl:attribute name="isFrontmatter">1</xsl:attribute>
		</xsl:if>
      </xsl:if>
	  
      <xsl:apply-templates />
	  
    </pmEntry>
  </xsl:template>
  <!-- ******************************************************************************* -->
  <!-- CV - move ID "dmContent/@id" to "dmodule/@id", where it can be used with 
          "dmRef" links
          -->
  <xsl:template match="dmContent">
    <dmContent>
      <!-- ("@id" will be moving to child::dmodule, but retain "@xlink:href") -->
      <xsl:attribute name="xlink:href">
        <xsl:value-of select="@xlink:href" />
      </xsl:attribute>
      <xsl:apply-templates />
    </dmContent>
  </xsl:template>
  <xsl:template match="dmodule">
    <dmodule>
      <xsl:attribute name="id">
        <xsl:value-of select="parent::dmContent/@id" />
      </xsl:attribute>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </dmodule>
  </xsl:template>
  <!-- ******************************************************************************* -->
  <!-- CV - adding "commonRepository" and "crossRefTable" sections at end of document 
          containing single entry for every common element referenced
          (e.g. "caution", "warning", "parts", "supplies", etc.)
          -->
  <!-- NOTE: currently we've only seen documents with "pm" as the start element -->
  <xsl:template match="pm">
    <pm>
      <xsl:apply-templates select="@*" />
      <!-- CV - change to the custom "pm_cmb.xsd" schema -->
      <xsl:attribute name="xsi:noNamespaceSchemaLocation" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <xsl:text>http://www.s1000d.org/S1000D_4-1/xml_schema_flat/pm_cmb.xsd</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates />
      <!-- ******************************************************************************************* -->
      <!-- NOTE: filtering to only include referenced items is deferred until later development phase
              (just pull in all "repository" section content from external file)
              -->
      <!-- ******************************************************************************************* -->
      <!-- ******************************************************************************************* -->
      <!-- A. Create "commonRepository" section at bottom of combined XML document -->
      <xsl:text>&#xA;</xsl:text>
      <commonRepository>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 1. "warningRepository" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/warningRepository">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/warningRepository[1]" />
          </xsl:when>
          <xsl:otherwise>
            <warningRepository />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 2. "cautionRepository" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/cautionRepository">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/cautionRepository[1]" />
          </xsl:when>
          <xsl:otherwise>
            <cautionRepository />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 3. "partRepository" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/partRepository">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/partRepository[1]" />
          </xsl:when>
          <xsl:otherwise>
            <partRepository />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 4. "enterpriseRepository" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/enterpriseRepository">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/enterpriseRepository[1]" />
          </xsl:when>
          <xsl:otherwise>
            <enterpriseRepository />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 5. "supplyRepository" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/supplyRepository">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/supplyRepository[1]" />
          </xsl:when>
          <xsl:otherwise>
            <supplyRepository />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 6. "toolRepository" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/toolRepository">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/toolRepository[1]" />
          </xsl:when>
          <xsl:otherwise>
            <toolRepository />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
      </commonRepository>
      <xsl:text>&#xA;</xsl:text>
      <!-- ******************************************************************************************* -->
      <!-- B. Create "crossRefTable" section at bottom of combined XML document -->
      <xsl:text>&#xA;</xsl:text>
      <crossRefTable>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 1. PCT "productCrossRefTable" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/productCrossRefTable">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/productCrossRefTable[1]" />
          </xsl:when>
          <xsl:otherwise>
            <productCrossRefTable />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 2. CCT "condCrossRefTable" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/condCrossRefTable">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/condCrossRefTable[1]" />
          </xsl:when>
          <xsl:otherwise>
            <condCrossRefTable />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 3. ACT "applicCrossRefTable" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/applicCrossRefTable">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/applicCrossRefTable[1]" />
          </xsl:when>
          <xsl:otherwise>
            <applicCrossRefTable />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
        <!-- 4. ACT catalog "applicCrossRefTableCatalog" -->
        <xsl:choose>
          <xsl:when test="$S1000D-repositories/xquery/query/applicCrossRefTableCatalog">
            <xsl:copy-of select="$S1000D-repositories/xquery/query/applicCrossRefTableCatalog[1]" />
          </xsl:when>
          <xsl:otherwise>
            <applicCrossRefTableCatalog />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&#xA;</xsl:text>
        <xsl:text>&#xA;</xsl:text>
      </crossRefTable>
      <xsl:text>&#xA;</xsl:text>
      <xsl:text>&#xA;</xsl:text>
    </pm>
  </xsl:template>
  
  <!-- catalogSeqNumber: add a new attribute for the trimmed item number (no leading zeroes) -->
  <!-- and set the figureNumber and figureNumberVariant attributes based on the PMC structure. -->
  <xsl:template match="catalogSeqNumber">
    <xsl:variable name="figureNum" select="count(ancestor::pmEntry[1]/preceding-sibling::pmEntry) + 1"/>
  	<xsl:variable name="variantNum" select="count(ancestor::dmContent[1]/preceding-sibling::dmContent[dmodule/content/illustratedPartsCatalog/figure])"/>
  	<catalogSeqNumber>
  		<xsl:apply-templates select="@*"/>
		<xsl:attribute name="trimmedItem">
			<xsl:value-of select="number(@item) * 1"/>
		</xsl:attribute>
  		<xsl:attribute name="figureNumber" select="$figureNum"/>
   		<xsl:if test="$variantNum &gt; 0">
   			<xsl:attribute name="figureNumberVariant">
   				<!-- TODO: This will need to be updated to skip "I" and "O"; may need to use a Java extension for this... -->
   				<xsl:value-of select="helper:getVariantCode($variantNum)"/>
   			</xsl:attribute>
   		</xsl:if>
		<xsl:apply-templates/>
  	</catalogSeqNumber>
  </xsl:template>
  
  <xsl:template match="itemSeqNumber">
    <itemSeqNumber>
      <xsl:apply-templates select="@*|node()" />
      <xsl:if test="partLocationSegment/attachStoreShipPart/@attachStoreShipPartCode='1' and not((preceding::itemSeqNumber)[last()]/*[descendant::attachStoreShipPart[@attachStoreShipPartCode='1']])">
        <attachingPartsStart />
      </xsl:if>
      <xsl:if test="partLocationSegment/attachStoreShipPart/@attachStoreShipPartCode='1'
		and ( not(following::itemSeqNumber)
		or following::itemSeqNumber[1][not(descendant::attachStoreShipPart[@attachStoreShipPartCode='1'])] )">
        <attachingPartsEnd />
      </xsl:if>
	  <xsl:if test="count(genericPartDataGroup/genericPartData/genericPartDataValue) > 0 ">
		<genericSequences>
			<xsl:value-of select="sono:getSequence(.)"/>
			<!-- <xsl:for-each select="genericPartDataGroup/genericPartData/genericPartDataValue">
				<xsl:variable name="current" select="substring(.,2)"/>
				<xsl:variable name="prev" select="substring(./preceding::genericPartDataValue[1],2)"/>
				<xsl:variable name="next" select="substring(./following::genericPartDataValue[1],2)"/>
				<xsl:choose>
					<xsl:when test="number($current)!='NaN' and number($prev)!='NaN' and number($next)!='NaN' and number($current)=(number($prev)-1) and number($current)=(number($next)+1)">
						<xsl:text> to </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>
						<xsl:text>, </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:for-each> -->
		</genericSequences>
	  </xsl:if>
    </itemSeqNumber>
  </xsl:template>
  
  <!-- ******************************************-->
  <!-- ***** processing Pub instructions ********-->
  <!-- ******************************************-->
  <xsl:template match="processing-instruction('Pub')">
    <xsl:variable name="prcInsName">
      <xsl:value-of select="." />
    </xsl:variable>
	<xsl:choose>
    <xsl:when test="$prcInsName='Tool' or $prcInsName='ToolAll'">
      <table colsep="1" frame="all" pgwide="1" rowsep="1" id="{generate-id()}">
        <title>Special Tools, Fixtures, and Equipment</title>
        <tgroup cols="3">
          <colspec colname="col1" />
          <colspec colname="col2" />
          <colspec colname="col3" />
          <thead>
            <row>
              <entry>
                <para>Number</para>
              </entry>
              <entry>
                <para>Description</para>
              </entry>
              <entry>
                <para>Source</para>
              </entry>
            </row>
          </thead>
          <tbody>
            <xsl:choose>
              <xsl:when test="$prcInsName='Tool' and count((ancestor::pmEntry)[1]//toolRef) &gt; 0">
				<!-- Use for-each-group to eliminate duplicates -->
                <!--<xsl:for-each select="(ancestor::pmEntry)[1]//toolRef">-->
                <xsl:for-each-group select="(ancestor::pmEntry)[1]//toolRef" group-by="@toolNumber">
					<xsl:sort select="@toolNumber"/>
                  <xsl:call-template name="toolRow">
                    <!--<xsl:with-param name="toolNr" select="@toolNumber" />-->
                    <xsl:with-param name="toolNr" select="current-group()[1]/@toolNumber" />
                  </xsl:call-template>
                </xsl:for-each-group>
              </xsl:when>
              <xsl:when test="$prcInsName='ToolAll' and count(//toolRef) &gt; 0">
                <!--<xsl:for-each select="//toolRef">-->
                <xsl:for-each-group select="//toolRef" group-by="@toolNumber">
					<xsl:sort select="@toolNumber"/>
                  <xsl:call-template name="toolRow">
                    <xsl:with-param name="toolNr" select="current-group()[1]/@toolNumber" />
                  </xsl:call-template>
                </xsl:for-each-group>
              </xsl:when>
              <xsl:otherwise>
                <row>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                </row>
              </xsl:otherwise>
            </xsl:choose>
          </tbody>
        </tgroup>
      </table>
    </xsl:when>
    <xsl:when test="$prcInsName='Supply' or $prcInsName='SupplyAll'">
      <table colsep="1" frame="all" pgwide="1" rowsep="1" id="{generate-id()}">
        <title>Consumables</title>
        <tgroup cols="3">
          <colspec colname="col1" />
          <colspec colname="col2" />
          <colspec colname="col3" />
          <thead>
            <row>
              <entry>
                <para>Number</para>
              </entry>
              <entry>
                <para>Description</para>
              </entry>
              <entry>
                <para>Source</para>
              </entry>
            </row>
          </thead>
          <tbody>
            <xsl:choose>
              <xsl:when test="$prcInsName='Supply' and count((ancestor::pmEntry)[1]//supplyRef) &gt; 0">
				<!-- Use for-each-group to eliminate duplicates -->
                <!--<xsl:for-each select="(ancestor::pmEntry)[1]//supplyRef">-->
                <xsl:for-each-group select="(ancestor::pmEntry)[1]//supplyRef" group-by="@supplyNumber">
					<xsl:sort select="@supplyNumber"/>
                  <xsl:call-template name="supplyRow">
                    <xsl:with-param name="supplyNr" select="current-group()[1]/@supplyNumber" />
                  </xsl:call-template>
                </xsl:for-each-group>
              </xsl:when>
              <xsl:when test="$prcInsName='SupplyAll' and count(//supplyRef) &gt; 0">
                <!--<xsl:for-each select="//supplyRef">-->
                <xsl:for-each-group select="//supplyRef" group-by="@supplyNumber">
					<xsl:sort select="@supplyNumber"/>
                  <xsl:call-template name="supplyRow">
                    <xsl:with-param name="supplyNr" select="current-group()[1]/@supplyNumber" />
                  </xsl:call-template>
                </xsl:for-each-group>
              </xsl:when>
              <xsl:otherwise>
                <row>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                </row>
              </xsl:otherwise>
            </xsl:choose>
          </tbody>
        </tgroup>
      </table>
    </xsl:when>
    <xsl:when test="$prcInsName='Vendor'">
      <table colsep="1" frame="all" pgwide="1" rowsep="1">
        <!-- <title>Vendors</title> -->
        <tgroup cols="2">
          <colspec colname="col1" />
          <colspec colname="col2" />
          <thead>
            <row>
              <entry>
                <para>Code</para>
              </entry>
              <entry>
                <para>Vendor</para>
              </entry>
            </row>
          </thead>
          <tbody>
            <xsl:choose>
              <xsl:when test="count($S1000D-repositories/xquery/query/enterpriseRepository/enterpriseSpec) &gt; 0">
                <xsl:for-each select="$S1000D-repositories/xquery/query/enterpriseRepository/enterpriseSpec">
                  <xsl:call-template name="vendorRow">
                    <xsl:with-param name="code" select="enterpriseIdent/@manufacturerCodeValue" />
                    <xsl:with-param name="vendor">
                      <xsl:value-of select="enterpriseName" />
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="businessUnit/businessUnitAddress/street" />
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="businessUnit/businessUnitAddress/city" />
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="businessUnit/businessUnitAddress/state" />
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="businessUnit/businessUnitAddress/postalZipCode" />
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <row>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                </row>
              </xsl:otherwise>
            </xsl:choose>
          </tbody>
        </tgroup>
      </table>
    </xsl:when>
    <xsl:when test="$prcInsName='Abbreviation' or $prcInsName='Acronym'">
	  <!-- RS: Now just output a custom element and let the stylesheet generate the table. -->
	  <!-- Keep the previous XSLT implementation below for future reference. -->
	  <!-- FO Process: will probably use the original XSLT version below (TODO). Don't output the special acronymTable used for Styler. -->
	  <!--<acronymTable/>-->
      <table colsep="1" frame="all" pgwide="1" rowsep="1">
        <title>List of Acronyms and Abbreviations</title>
        <tgroup cols="2">
          <colspec colname="col1" />
          <colspec colname="col2" />
          <thead>
            <row>
              <entry>
                <para>Term</para>
              </entry>
              <entry>
                <para>Full Term</para>
              </entry>
            </row>
          </thead>
          <tbody>
            <xsl:choose>
              <xsl:when test="count(//acronym[@acronymType='at01']) &gt; 0">
                <xsl:for-each select="//acronym[@acronymType='at01']">
                  <xsl:sort select="acronymTerm" />
                  <xsl:variable name="acrTerm" select="acronymTerm" />
                  <xsl:if test="count(preceding::acronym[acronymTerm=$acrTerm]) = 0">
                    <row>
                      <entry>
                        <para>
                          <xsl:value-of select="translate(acronymTerm,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
                        </para>
                      </entry>
                      <entry>
                        <para>
                          <xsl:value-of select="acronymDefinition" />
                        </para>
                      </entry>
                    </row>
                  </xsl:if>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <row>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                  <entry>
                    <para>Not applicable</para>
                  </entry>
                </row>
              </xsl:otherwise>
            </xsl:choose>
          </tbody>
        </tgroup>
      </table>
    </xsl:when>
	<xsl:when test="$prcInsName='Highlight'">
		<xsl:call-template name='highlightsTable'/>
	</xsl:when>
	<!-- RS: Remove "Dtl" PIs (collapse elements in Editor view) -->
	<xsl:when test="$prcInsName='Dtl'">
	</xsl:when>
	<!-- RS: Copy other PIs (to retain new page and new line PIs, and maybe others) -->
	<xsl:otherwise>
		<xsl:copy/>
	</xsl:otherwise>
	</xsl:choose>
 </xsl:template>
 
  <xsl:template name="toolRow">
    <xsl:param name="toolNr" />
    <xsl:variable name="toolId" select="$S1000D-repositories/xquery/query/toolRepository/toolSpec/toolIdent[@toolNumber=$toolNr]/@id" />
    <xsl:variable name="description" select="$S1000D-repositories/xquery/query/toolRepository/toolSpec/toolIdent[@toolNumber=$toolNr]/following-sibling::itemIdentData/descrForPart" />
    <xsl:variable name="mfrCodeValue" select="$S1000D-repositories/xquery/query/toolRepository/toolSpec[toolIdent/@toolNumber=$toolNr]/procurementData/enterpriseRef/@manufacturerCodeValue" />
    <xsl:variable name="toolMfrCodeValue" select="$S1000D-repositories/xquery/query/toolRepository/toolSpec/toolIdent[@toolNumber=$toolNr]/@manufacturerCodeValue" />
    <xsl:variable name="source">
      <xsl:choose>
        <xsl:when test="count($S1000D-repositories/xquery/query/toolRepository/toolSpec/toolIdent[@id=$toolNr])">
          <xsl:text>Commercially Available</xsl:text>
        </xsl:when>
        <xsl:when test="$mfrCodeValue!=''">
          <xsl:text>CAGE: </xsl:text>
          <xsl:value-of select="$mfrCodeValue" />
        </xsl:when>
        <xsl:when test="$toolMfrCodeValue!=''">
          <xsl:text>CAGE: </xsl:text>
          <xsl:value-of select="$toolMfrCodeValue" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Manufacturer Code not found for tool number: </xsl:text>
          <xsl:value-of select="$toolNr" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <row>
      <entry>
        <para>
          <xsl:if test="$toolNr != $toolId">
            <xsl:value-of select="$toolNr" />
          </xsl:if>
        </para>
      </entry>
      <entry>
        <para>
          <xsl:value-of select="$description" />
        </para>
      </entry>
      <entry>
        <para>
          <xsl:value-of select="$source" />
        </para>
      </entry>
    </row>
  </xsl:template>
  
  <xsl:template name="supplyRow">
    <xsl:param name="supplyNr" />
    <xsl:variable name="toolId" select="$S1000D-repositories/xquery/query/supplyRepository/supplySpec/supplyIdent[@supplyNumber=$supplyNr]/@id" />
    <xsl:variable name="description" select="($S1000D-repositories/xquery/query/supplyRepository/supplySpec/supplyIdent[@supplyNumber=$supplyNr])[1]/../name" />
    <xsl:variable name="mfrCodeValue" select="$S1000D-repositories/xquery/query/supplyRepository/supplySpec[supplyIdent/@supplyNumber=$supplyNr]/procurementData/enterpriseRef/@manufacturerCodeValue" />
    <xsl:variable name="source">
      <xsl:choose>
        <xsl:when test="count($S1000D-repositories/xquery/query/supplyRepository/supplySpec/supplyIdent[@id=$supplyNr])">
          <xsl:text>Commercially Available</xsl:text>
        </xsl:when>
        <xsl:when test="$mfrCodeValue!=''">
          <xsl:text>CAGE: </xsl:text>
          <xsl:value-of select="$mfrCodeValue" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Manufacturer Code not found for tool number: </xsl:text>
          <xsl:value-of select="$supplyNr" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <row>
      <entry>
        <para>
          <xsl:if test="$supplyNr != $toolId">
            <xsl:value-of select="$supplyNr" />
          </xsl:if>
        </para>
      </entry>
      <entry>
        <para>
          <xsl:value-of select="$description" />
        </para>
      </entry>
      <entry>
        <para>
          <xsl:value-of select="$source" />
        </para>
      </entry>
    </row>
  </xsl:template>
   
  <xsl:template name="vendorRow">
    <xsl:param name="code" />
    <xsl:param name="vendor" />
    <row>
      <entry>
        <para>V<xsl:value-of select="$code" /></para>
      </entry>
      <entry>
        <para>
          <xsl:value-of select="$vendor" />
        </para>
      </entry>
    </row>
  </xsl:template>
  
  <!-- The FO process doesn't need the month translation
  <xsl:template match="/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate">
    <xsl:copy>
      <xsl:attribute name="month">
        <xsl:variable name="monthAttr">
          <xsl:value-of select="number(@month)" />
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$monthAttr=1">Jan</xsl:when>
          <xsl:when test="$monthAttr=2">Feb</xsl:when>
          <xsl:when test="$monthAttr=3">Mar</xsl:when>
          <xsl:when test="$monthAttr=4">Apr</xsl:when>
          <xsl:when test="$monthAttr=5">May</xsl:when>
          <xsl:when test="$monthAttr=6">Jun</xsl:when>
          <xsl:when test="$monthAttr=7">Jul</xsl:when>
          <xsl:when test="$monthAttr=8">Aug</xsl:when>
          <xsl:when test="$monthAttr=9">Sep</xsl:when>
          <xsl:when test="$monthAttr=10">Oct</xsl:when>
          <xsl:when test="$monthAttr=11">Nov</xsl:when>
          <xsl:when test="$monthAttr=12">Dec</xsl:when>
          <xsl:otherwise />
        </xsl:choose>
      </xsl:attribute>
      <xsl:copy-of select="@day" />
      <xsl:copy-of select="@year" />
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:template name="highlightsTable">
    <table colsep="1" frame="all" pgwide="1" rowsep="1">
      <title>Table of Highlights</title>
      <tgroup cols="3">
        <colspec colname="col1" />
        <colspec colname="col2" />
        <colspec colname="col3" />
        <thead>
          <row>
            <entry>
              <para>Task/Page</para>
            </entry>
            <entry>
              <para>Description of Change</para>
            </entry>
            <entry>
              <para>Effectivity</para>
            </entry>
          </row>
        </thead>
        <tbody>
          <!-- add rows here-->
          <xsl:choose>
            <xsl:when test="count(//reasonForUpdate) &gt; 0">
              <xsl:for-each select="//reasonForUpdate">
                <xsl:variable name="rfuId" select="@id" />
                <xsl:if test="ancestor::identAndStatusSection/following-sibling::content[descendant::*[@reasonForUpdateRefIds=$rfuId]]">
                  <row>
                    
						<xsl:choose>
							<xsl:when test="count(ancestor::pmEntry) > 1">
								<entry>
									<para>
										<xsl:text>Subtask </xsl:text>
										<xsl:value-of select="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument"/>
										<reasonForUpdatePageNumberRef>
											<xsl:attribute name="reasonForUpdateRefIds">
												<xsl:call-template name="dmCode">
													<xsl:with-param name="DMCode" select="ancestor::identAndStatusSection/dmAddress/dmIdent/dmCode"/>
												</xsl:call-template>
											</xsl:attribute>
										</reasonForUpdatePageNumberRef>
									</para>
								</entry>
								<entry>
									<para>Paragraph 
										<xsl:number count="//pmEntry"  level="single" format="1"/>.
										<xsl:number count="//dmContent" level="single" format="A"/>.
										<xsl:value-of select=".//text()" />
									</para>
								</entry>
							</xsl:when>
							<xsl:otherwise>
								<entry>
									<para>
										<xsl:value-of select="ancestor::pmEntry/pmEntryTitle"/>
									</para>
								</entry>
								<entry>
									<para>
										<xsl:apply-templates />
									</para>
								</entry>
							</xsl:otherwise>
						</xsl:choose>
					 
                    
                    <entry><para>All</para></entry>
                  </row>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <row>
                <entry>
                  <para>Not applicable</para>
                </entry>
                <entry>
                  <para>Not applicable</para>
                </entry>
                <entry>
                  <para>Not applicable</para>
                </entry>
              </row>
            </xsl:otherwise>
          </xsl:choose>
        </tbody>
      </tgroup>
    </table>
  </xsl:template>

<!-- RS: This seems to create a duplicate ID (with the id attribute on dmRef), and I'm adding a template in
03-S10000D-filter-A.xsl to assign unique IDs to levelledPara with reasonForUpdateRefIds for use in the
Table of Highlights (when an id is not already present). So comment this out for now and see if there
are any negative effects from not using this version. -->
<!--
  <xsl:template match="levelledPara[not(ancestor::levelledPara)][descendant::*[@reasonForUpdateRefIds]][1]">
    <levelledPara>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="id">
			<xsl:call-template name="dmCode">
				<xsl:with-param  name="DMCode" select="ancestor::content/preceding-sibling::identAndStatusSection/dmAddress/dmIdent/dmCode"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:apply-templates/>
	</levelledPara>
  </xsl:template>-->

<!-- RS: This seems to create a duplicate ID (with the id attribute on dmRef), and I'm adding a template in
03-S10000D-filter-A.xsl to assign unique IDs to proceduralSteps with reasonForUpdateRefIds for use in the
Table of Highlights (when an id is not already present). So comment this out for now and see if there
are any negative effects from not using this version. -->
<!--
  <xsl:template match="proceduralStep[not(ancestor::proceduralStep)][descendant::*[@reasonForUpdateRefIds]][1]">
    <proceduralStep>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="id">
			<xsl:call-template name="dmCode">
				<xsl:with-param  name="DMCode" select="ancestor::content/preceding-sibling::identAndStatusSection/dmAddress/dmIdent/dmCode"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:apply-templates/>
	</proceduralStep>
  </xsl:template>-->
  
  <xsl:template match="illustratedPartsCatalog[descendant::*[@reasonForUpdateRefIds]]">
    <illustratedPartsCatalog>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="id">
			<xsl:call-template name="dmCode">
				<xsl:with-param  name="DMCode" select="ancestor::content/preceding-sibling::identAndStatusSection/dmAddress/dmIdent/dmCode"/>
			</xsl:call-template>
		</xsl:attribute>
		<xsl:apply-templates/>
	</illustratedPartsCatalog>
  </xsl:template>
  
  <xsl:template name="dmCode">
	<xsl:param name="DMCode"/>
	<xsl:value-of select="$DMCode/@modelIdentCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@systemDiffCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@systemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@subSystemCode"/>
    <xsl:value-of select="$DMCode/@subSubSystemCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@assyCode"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@disassyCode"/>
    <xsl:value-of select="$DMCode/@disassyCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@infoCode"/>
    <xsl:value-of select="$DMCode/@infoCodeVariant"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$DMCode/@itemLocationCode"/>
  </xsl:template>
  
  <xsl:template match="illustratedPartsCatalog/figure">
	<figure>
		<xsl:apply-templates select="@*" />
		<xsl:if test="count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/illustratedPartsCatalog/figure) > 0">
			<xsl:attribute name="figureNumber">
				<xsl:number value="count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/illustratedPartsCatalog/figure)" format="A"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</figure>
  </xsl:template>
  
  <xsl:template match="content/description/levelledPara/title[1]">
	<title>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="titleNumber">
			<xsl:number value="count(parent::*/preceding-sibling::levelledPara)+count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara)+1" format="A"/>
		</xsl:attribute>
		<xsl:if test="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument">
			<xsl:attribute name="authorityText">
				<xsl:text>(Subtask </xsl:text>
				<xsl:value-of select="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument"/>
				<xsl:text>)</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</title>
  </xsl:template>
  
  <xsl:template match="content/procedure/mainProcedure/proceduralStep/title[1]">
	<title>
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="titleNumber">
			<xsl:number value="count(parent::*/preceding-sibling::proceduralStep)+count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep)+1" format="A"/>
		</xsl:attribute>
		<xsl:if test="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument">
			<xsl:attribute name="authorityText">
				<xsl:text>(Subtask </xsl:text>
				<xsl:value-of select="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument"/>
				<xsl:text>)</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</title>
  </xsl:template>
  
  <xsl:template match="pmEntryTitle">
	<pmEntryTitle>
		<xsl:apply-templates select="@*" />
		<xsl:if test="(ancestor::pmEntry)[last()]/@authorityDocument">
			<xsl:attribute name="authorityText">
				<xsl:text>(TASK </xsl:text>
				<xsl:value-of select="(ancestor::pmEntry)[last()]/@authorityDocument"/>
				<xsl:text>)</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates/>
	</pmEntryTitle>
  </xsl:template>
  
  <!-- Strip leading spaces from acronymTerms -->
  <xsl:template match="acronymTerm/text()">
	<xsl:if test="count(preceding-sibling::node())=0">
		<xsl:value-of select="replace(.,'^[ \t\r\n]+','')"/>
	</xsl:if>
  </xsl:template>

  <xsl:template match="row">
	<row>
		<xsl:variable name="parasInFirstEntry" select="count(following-sibling::row[1]/entry[1]/para)"/>
		
		<xsl:if test="$parasInFirstEntry &gt; 15">
			<xsl:variable name="numEntriesWithEqualParas" select="sum(for $entry in following-sibling::row[1]/entry return number( boolean(count($entry/para)=$parasInFirstEntry) ))"/>
			<!-- <xsl:comment>numEntriesWithEqualParas in next row: <xsl:value-of select="$numEntriesWithEqualParas"/></xsl:comment> -->
			<xsl:message>numEntriesWithEqualParas in next row: <xsl:value-of select="$numEntriesWithEqualParas"/></xsl:message>
	
			<xsl:if test="$numEntriesWithEqualParas = count(following-sibling::row[1]/entry)">
				<xsl:attribute name="nextRowIsMultiRow">1</xsl:attribute>
			</xsl:if>
		</xsl:if>
		
		<xsl:apply-templates select="@*|node()"/>
	</row>
  	
  </xsl:template>
  
</xsl:stylesheet>