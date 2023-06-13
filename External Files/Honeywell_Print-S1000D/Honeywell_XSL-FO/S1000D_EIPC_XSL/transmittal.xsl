<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

  <!-- RS: This Stylesheet is primarily to generate the Table of Highlights. -->
  <!-- In the ATA FO some of the TRANSMITTAL INFORMATION section was generated here as well, but in S1000D it's authored -->
  <!-- as a regular front-matter section. -->
  
  <!-- NOTE: The "title" referred to below, as in "determine-change-title" is the entry in the first column -->
  <!-- of the table. -->
  
  <xsl:template name="highlights_table">
    <!-- The textual introduction may be already in the S1000D XML, but leave this for now. -->
    <fo:block space-before="6pt">
      <xsl:text>The table of highlights tells users what has changed as a result of the revision. The table consists of three columns.</xsl:text>
    </fo:block>
    <fo:block space-before="6pt">
      <xsl:text>The Task/Page column identifies the blocks of changed information, such as a task, subtask, graphic, or parts list, and the page on which that block starts.
        The block of information often includes the MTOSS code. Revision marks, when provided, identify the location of the change within the block.</xsl:text>
    </fo:block>
    <fo:block space-before="6pt">
      <xsl:text>The Description of Change column tells about the change or changes within each block.
        The description of change is often preceded by a paragraph or figure reference that applies to the block of information.</xsl:text>
    </fo:block>
    <fo:block space-before="6pt">
      <xsl:text>The Effectivity column tells the user the part number(s) to which the block of information applies. The default value for this column is "All."
        "All" means that the block applies to all parts.</xsl:text>
    </fo:block>
    <fo:table rx:table-omit-initial-header="true" width="100%">
      <fo:table-column column-number="1" column-width="1.75in"/>
      <fo:table-column column-number="2" column-width="4.25in"/>
      <fo:table-column column-number="3" column-width=".75in"/>
      <fo:table-header>
        <fo:table-row display-align="after" font-weight="bold" padding="3pt" keep-with-next="always" padding-top="0.125in" padding-bottom="0.125in">
          <fo:table-cell number-columns-spanned="3">
            <fo:block padding-top="0.125in" padding-bottom="0.125in" text-align="center">
              <xsl:text>Table of Highlights (Cont)</xsl:text>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
        <fo:table-row border-after-style="solid" border-after-width="1pt" border-before-style="solid" border-before-width="1pt" display-align="after" font-weight="bold" padding="3pt"
          keep-with-next="always" padding-top="0.125in" padding-bottom="0.125in">
          <fo:table-cell padding-top="0.125in" padding-bottom="0.125in" padding-right="0.125in">
            <fo:block>
              <xsl:text>Task/Page</xsl:text>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell padding-right="0.125in" padding-top="0.125in" padding-bottom="0.125in"><!-- padding-left="0.125in"  -->
            <fo:block>
              <xsl:text>Description of Change</xsl:text>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell padding-top="0.125in" padding-bottom="0.125in"><!--  padding-left="0.125in" -->
            <fo:block>
              <xsl:text>Effectivity</xsl:text>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-header>
      <fo:table-body border-bottom-style="solid" border-bottom-width="1pt">
        <fo:table-row display-align="after" font-weight="bold" padding="3pt" keep-with-next="always" padding-top="0.125in" padding-bottom="0.125in">
          <fo:table-cell number-columns-spanned="3">
            <fo:block padding-top="0.125in" padding-bottom="0.125in" text-align="center">
              <xsl:text>Table of Highlights</xsl:text>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
        <fo:table-row border-after-style="solid" border-after-width="1pt" border-before-style="solid" border-before-width="1pt" display-align="after" font-weight="bold" padding="3pt"
          keep-with-next="always" padding-top="0.125in" padding-bottom="0.125in">
          <fo:table-cell padding-top="0.125in" padding-bottom="0.125in" padding-right="0.125in">
            <fo:block>
              <xsl:text>Task/Page</xsl:text>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell padding-top="0.125in" padding-bottom="0.125in" padding-right="0.125in"><!--  padding-left="0.125in" -->
            <fo:block>
              <xsl:text>Description of Change</xsl:text>
            </fo:block>
          </fo:table-cell>
          <fo:table-cell padding-top="0.125in" padding-bottom="0.125in"><!--  padding-left="0.125in" -->
            <fo:block>
              <xsl:text>Effectivity</xsl:text>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
        <!-- <xsl:for-each select="//CHGDESC"> -->
        <!-- Use reasonForUpdate instead of changeType on the specific elements because front-matter -->
        <!-- May only have the reasonForUpdate. The templates invoked can then figure out what context -->
        <!-- they are in. Note that this may need to change if the reasonForUpdates are not in the -->
        <!-- right order. -->
        <xsl:for-each select="//reasonForUpdate">
          <!-- Add a sort according to the order of the references in the document. -->
          <!-- UPDATE: Only use first occurrence of a reference for sorting. -->
          <!-- UPDATE: If the reasonForUpdate is not linked (referred to), then use the reasonForUpdate itself for sorting. -->
          <!-- Use XPath 2.0 if/else for this sorting difference. -->
          <!-- UPDATE: Updates can be added to pmEntries in the PMC module, and their RFUs are in the top-level -->
          <!-- pm indentAndStatusSection. So this needs an additional nested if/else to test. -->
          <!-- (N.B This pmEntry RFU should never be unlinked otherwise you wouldn't know what section -->
          <!-- it applies to). -->
          <xsl:sort select="
            if (ancestor::dmodule//*[@reasonForUpdateRefIds=current()/@id])
            then
              count( (ancestor::dmodule//*[@reasonForUpdateRefIds=current()/@id])[1]/preceding::*[@reasonForUpdateRefIds] )
            else
              if (parent::pmStatus/parent::identAndStatusSection/parent::pm)
              then
                count( ((/pm/content//pmEntry)[@reasonForUpdateRefIds=current()/@id])[1]/preceding::*[@reasonForUpdateRefIds] )
              else
                count(preceding::*[@reasonForUpdateRefIds])"
            data-type="number"/>
          
          <xsl:variable name="reasonForChangeid" select="@id"/>
          <xsl:choose>
            <!-- Only output a row for the reasonForUpdate when there is an element that refers to it. -->
            <!-- UPDATE: Any reasonForUpdate before the Introduction don't need a referring element. -->
		    <!-- UPDATE: Now reasonForUpdate does not need to be linked, so use all of them. -->
          	<!-- <xsl:when test="ancestor::pmEntry[last()]/following-sibling::pmEntry[@pmEntryType='pmt58']
          		or ancestor::dmodule//*[@reasonForUpdateRefIds=$reasonForChangeid]"> -->
          	<xsl:when test="true()">
	          <fo:table-row keep-together.within-page="always">
	            <fo:table-cell padding-top="0.08in" padding-bottom="0.045in" padding-right="0.125in"><!-- padding-top="0.125in" -->
	              <fo:block>
	                <xsl:call-template name="determine-change-title"/>
	              </fo:block>
	            </fo:table-cell>
	            <fo:table-cell padding-top="0.08in" padding-bottom="0.045in" padding-right="0.125in">
	              <fo:block>
	                <!-- Output the paragraph/figure information with a link then the text of the reasonForUpdate -->
	                <xsl:call-template name="determine-paragraph-numbering"/>
	                <xsl:apply-templates/>
	              </fo:block>
	            </fo:table-cell>
	            <fo:table-cell padding-top="0.08in" padding-bottom="0.045in">
	              <xsl:choose>
	                <!-- S1000D doesn't have an EFFECT analogue, but leave for future reference... -->
	                <xsl:when test="false()"><!-- preceding-sibling::EFFECT -->
	                  <fo:block>
	                    <xsl:value-of select="preceding-sibling::EFFECT"/>
	                  </fo:block>
	                </xsl:when>
	                <xsl:otherwise>
	                  <fo:block>
	                    <xsl:text>All</xsl:text>
	                  </fo:block>
	                </xsl:otherwise>
	              </xsl:choose>
	            </fo:table-cell>
	          </fo:table-row>
          	</xsl:when>
          	<xsl:otherwise>
          		<!-- (This currently should never happen) -->
          		<xsl:message>WARNING: reasonForUpdate (id: <xsl:value-of select="@id"/>) does not have a referring element... not adding to the Table of Highlights</xsl:message>
          	</xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <!-- Many changed elements output "TASK" or "Subtask" for the first part of the title (first column of  -->
  <!-- the Table of Highlights) along with its number, depending on the ancestor pmEntry authority document attribute. -->
  <!-- Called with the changed element in context. -->
  <xsl:template name="task-or-subtask">
     <xsl:choose>
     	<xsl:when test="ancestor::dmContent[1]/preceding-sibling::dmRef[1]/@authorityDocument">
     		<xsl:text>Subtask</xsl:text>
     		<fo:block><xsl:value-of select="ancestor::dmContent[1]/preceding-sibling::dmRef[1]/@authorityDocument"/></fo:block>
     	</xsl:when>
     	<xsl:when test="ancestor::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument">
     		<xsl:text>TASK</xsl:text>
     		<fo:block><xsl:value-of select="ancestor::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument"/></fo:block>
     	</xsl:when>
     	<!-- For now when no task or subtask is specified, just use the top-level pmEntryTitle (uppercase) -->
     	<xsl:when test="ancestor::pmEntry[last()]/pmEntryTitle">
     		<fo:block text-transform="uppercase"><xsl:value-of select="ancestor::pmEntry[last()]/pmEntryTitle"/></fo:block>
     	</xsl:when>
     	<xsl:otherwise>
     	  <xsl:message>[ERROR] figure has no task or subtask (pmEntry authorityDocument attribute) ancestor</xsl:message>
     	  <xsl:text>ERROR: No task or subtask for figure</xsl:text>
     	</xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <!-- Called to output the the change title (in the first column of the Table of Highlights) -->
  <!-- for a figure. -->
  <!-- The context node may be either the figure itself, a graphic within it, or its title -->
  <!-- (maybe need to add legend later). -->
  <!-- Also added itemSeqNumber and catalogSeqNumber, which aren't direct descendants of figure. -->
  <xsl:template name="figure-change-title">
    <!-- RS: Not clear if the link destination and the page destination ever needs to be different; leave separate for now...  -->
    <!-- UPDATE: The link destination should be the figure (or first graphic) id itself, whereas the page reference needs -->
    <!-- to be adjusted to the renamed id of the foldout (due to how foldouts are generated separately and then placed -->
    <!-- where they are supposed to go). -->
  	<xsl:variable name="link-destination">
  		<xsl:choose>
  			<xsl:when test="self::figure"><xsl:value-of select="graphic[1]/@id"/></xsl:when>
  			<xsl:when test="self::graphic"><xsl:value-of select="@id"/></xsl:when>
  			<!-- The Key to figure is output as gentext, and the original ID may not be available, so link to the legend itself. -->
  			<xsl:when test="ancestor-or-self::definitionListItem/ancestor::legend"><xsl:value-of select="ancestor::legend/@id"/></xsl:when>
  			<xsl:when test="ancestor-or-self::legend"><xsl:value-of select="@id"/></xsl:when>
  			<!-- <xsl:when test="self::title[parent::figure/graphic[1]/@reproductionWidth='355.6 mm']"><xsl:value-of select="concat(parent::figure/graphic[1]/@id,'-r1')"/></xsl:when> -->
  			<xsl:when test="self::title[parent::figure/graphic[1]/@reproductionWidth='355.6 mm']"><xsl:value-of select="@id"/></xsl:when>
  			<xsl:when test="self::title"><xsl:value-of select="parent::figure/graphic[1]/@id"/></xsl:when>
  			<xsl:when test="self::itemSeqNumber or self::catalogSeqNumber"><xsl:value-of select="ancestor::illustratedPartsCatalog/figure/graphic[1]/@id"/></xsl:when>
  		</xsl:choose>
  	</xsl:variable>
  	<xsl:variable name="page-no-refid">
  		<xsl:choose>
      		<!-- Calculate the ID needed for the page reference; if it's a foldout graphic, we need to use the updated graphic ID ("-r1") -->
  			<xsl:when test="self::figure[graphic[1]/@reproductionWidth='355.6 mm']"><xsl:value-of select="concat(graphic[1]/@id,'-r1')"/></xsl:when>
  			<xsl:when test="self::figure"><xsl:value-of select="graphic[1]/@id"/></xsl:when>
  			<xsl:when test="self::graphic[@reproductionWidth='355.6 mm']"><xsl:value-of select="concat(@id,'-r1')"/></xsl:when>
  			<xsl:when test="self::graphic"><xsl:value-of select="@id"/></xsl:when>
  			<xsl:when test="ancestor-or-self::definitionListItem/ancestor::legend"><xsl:value-of select="ancestor::legend/@id"/></xsl:when>
  			<xsl:when test="ancestor-or-self::legend"><xsl:value-of select="@id"/></xsl:when>
  			<!-- <xsl:when test="self::title[parent::figure/graphic[1]/@reproductionWidth='355.6 mm']"><xsl:value-of select="concat(parent::figure/graphic[1]/@id,'-r1')"/></xsl:when> -->
  			<xsl:when test="self::title[parent::figure/graphic[1]/@reproductionWidth='355.6 mm']"><xsl:value-of select="@id"/></xsl:when>
  			<xsl:when test="self::title"><xsl:value-of select="parent::figure/graphic[1]/@id"/></xsl:when>
  			<xsl:when test="self::itemSeqNumber[ancestor::illustratedPartsCatalog/figure/graphic[1]/@reproductionWidth='355.6 mm'] or self::catalogSeqNumber[ancestor::illustratedPartsCatalog/figure/graphic[1]/@reproductionWidth='355.6 mm']">
  			  <xsl:value-of select="concat(ancestor::illustratedPartsCatalog/figure/graphic[1]/@id,'-r1')"/>
  			</xsl:when>
  			<xsl:when test="self::itemSeqNumber or self::catalogSeqNumber"><xsl:value-of select="ancestor::illustratedPartsCatalog/figure/graphic[1]/@id"/></xsl:when>
  			<xsl:otherwise>
  				<xsl:message>ERROR: No context match for page-no-refid</xsl:message>
  			</xsl:otherwise>
  		</xsl:choose>
  	</xsl:variable>
  	
    <fo:basic-link>
      <!-- Link to first graphic of the figure -->
      <xsl:attribute name="internal-destination">
        <xsl:value-of select="$link-destination"/>
      </xsl:attribute>
      
      <!-- Figures have TASK or Subtask as a type depending on context. -->
      <!-- But DPL Figures are different, outputting like "Detailed Parts List [newline] DPL Figure 1" -->
      <xsl:choose>
      	<xsl:when test="ancestor::illustratedPartsCatalog">
      		<xsl:text>Detailed Parts List</xsl:text>
      		<fo:block><xsl:text>DPL Figure </xsl:text>
     			<!-- <xsl:message>Calling calc-figure-number-param for figure id <xsl:value-of select="ancestor::illustratedPartsCatalog/figure/@id"/>. Current node: <xsl:value-of select="name()"/></xsl:message> -->
	       		<xsl:call-template name="calc-figure-number-param">
	       			<xsl:with-param name="figure" select="ancestor::illustratedPartsCatalog/figure/@id"/>
	       		</xsl:call-template>
			</fo:block>
     	</xsl:when>
     	<xsl:otherwise><!-- Not an IPL Figure -->
      		<!-- This outputs the type and the number below. -->
		    <xsl:call-template name="task-or-subtask"/>
      		<!-- Output the page; if it's a foldout figure, we need to use the updated graphic ID ("-r1") -->
      		<fo:block>
        		<xsl:text>(Page </xsl:text>
		        <xsl:call-template name="page-number-prefix"/>
        		<fo:page-number-citation>
          		  <xsl:attribute name="ref-id" select="$page-no-refid"/>
        	    </fo:page-number-citation>
        	    <xsl:call-template name="page-number-suffix"/>
        	    <xsl:text>)</xsl:text>
           </fo:block>
     	</xsl:otherwise>
     </xsl:choose>
   </fo:basic-link>
  </xsl:template>
  
  <!-- New for S1000D: determine the change title (in the first column of the Table of Highlights) -->
  <!-- from the element that has the matching reasonForUpdateRefIds (the context node here). -->
  <xsl:template name="change-title-from-element">
  	<xsl:choose>
  		<xsl:when test="self::figure or self::graphic or self::legend">
  			<xsl:call-template name="figure-change-title"/>
  		</xsl:when>
  		
  		<xsl:when test="self::table">
	        <fo:basic-link>
	          <xsl:attribute name="internal-destination">
	            <xsl:value-of select="@id"/>
	          </xsl:attribute>
	          
	          <!-- Tables have TASK or Subtask as a type depending on context. -->
	          <xsl:call-template name="task-or-subtask"/>
	          
	          <fo:block>
	            <xsl:text>(Page </xsl:text>
	            <xsl:call-template name="page-number-prefix"/>
	            <fo:page-number-citation>
	              <xsl:attribute name="ref-id" select="@id"/>
	            </fo:page-number-citation>
	            <xsl:call-template name="page-number-suffix"/>
	            <xsl:text>)</xsl:text>
	          </fo:block>
	        </fo:basic-link>
  		</xsl:when>
	    
	    <!-- The itemSeqNumber and catalogSeqNumber changes are output according to the IPL figure they are associated with. -->
	    <xsl:when test="self::itemSeqNumber or self::catalogSeqNumber" >
	    	<xsl:call-template name="figure-change-title"/>
	    </xsl:when>
	    
	    <!-- Now the template "task-or-subtask" should output the pmEntryTitle (like "INTRODUCTION") when no task or subtask
	    can be found, so this exception should not be necessary...
        <xsl:when test="ancestor::pmEntry[last()][@pmEntryType='pmt58'] and ">
          <fo:basic-link>
	          <xsl:attribute name="internal-destination" select="@id"/>
	          
              <xsl:text>INTRODUCTION</xsl:text>
	          
	          <fo:block>
	            <xsl:text>(Page </xsl:text>
	            <xsl:call-template name="page-number-prefix"/>
	            <fo:page-number-citation>
	              <xsl:attribute name="ref-id" select="@id"/>
	            </fo:page-number-citation>
	            <xsl:call-template name="page-number-suffix"/>
	            <xsl:text>)</xsl:text>
	          </fo:block>
	        </fo:basic-link>
          
        </xsl:when> -->

	    <xsl:when test="self::title">
			<xsl:choose>
				<xsl:when test="parent::figure">
					<xsl:call-template name="figure-change-title"/>
				</xsl:when>
				<xsl:when test="parent::table">
			        <fo:basic-link>
			          <xsl:attribute name="internal-destination">
			            <xsl:value-of select="parent::table/@id"/>
			          </xsl:attribute>
			          
			          <!-- Tables have TASK or Subtask as a type depending on context. -->
			          <xsl:call-template name="task-or-subtask"/>
			          
			          <fo:block>
			            <xsl:text>(Page </xsl:text>
			            <xsl:call-template name="page-number-prefix"/>
			            <fo:page-number-citation>
			              <xsl:attribute name="ref-id" select="parent::table/@id"/>
			            </fo:page-number-citation>
			            <xsl:call-template name="page-number-suffix"/>
			            <xsl:text>)</xsl:text>
			          </fo:block>
			        </fo:basic-link>
				</xsl:when>
				<xsl:when test="parent::levelledPara or parent::proceduralStep">
			        <fo:basic-link>
			          <xsl:attribute name="internal-destination">
			            <xsl:value-of select="parent::*/@id"/>
			          </xsl:attribute>
			          
			          <!-- Tables have TASK or Subtask as a type depending on context. -->
			          <xsl:call-template name="task-or-subtask"/>
			          
			          <fo:block>
			            <xsl:text>(Page </xsl:text>
			            <xsl:call-template name="page-number-prefix"/>
			            <fo:page-number-citation>
			              <xsl:attribute name="ref-id" select="parent::*/@id"/>
			            </fo:page-number-citation>
			            <xsl:call-template name="page-number-suffix"/>
			            <xsl:text>)</xsl:text>
			          </fo:block>
			        </fo:basic-link>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:text> Unexpected title parent: </xsl:text>
		          <xsl:value-of select="name(parent::*)"/>
		          <xsl:message>[error] Unexpected title parent: <xsl:value-of select="name(parent::*)"/></xsl:message>
				</xsl:otherwise>
			</xsl:choose>	    
	    </xsl:when>
	    
	    <xsl:when test="self::para">
	    	<xsl:choose>
	    		<!-- Special case if in a legend: use the figure output method -->
	    		<xsl:when test="ancestor::legend">
		  			<xsl:call-template name="figure-change-title"/>
	    		</xsl:when>
	    		<xsl:otherwise>
	    			<xsl:variable name="linkId">
			            <xsl:choose>
			            	<xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
			            	<xsl:when test="ancestor::levelledPara[@id]"><xsl:value-of select="ancestor::levelledPara[@id][1]"/></xsl:when>
			            	<xsl:when test="ancestor::proceduralStep[@id]"><xsl:value-of select="ancestor::proceduralStep[@id][1]"/></xsl:when>
			            	<xsl:otherwise>
			            		<xsl:message>ERROR: Can't get link id for para update (content: <xsl:value-of select="string(.)"/>)</xsl:message>
			            	</xsl:otherwise>
			            </xsl:choose>
	    			</xsl:variable>
			        <fo:basic-link>
			          <xsl:attribute name="internal-destination" select="$linkId"/>
			          
			          <!-- Paras have TASK or Subtask as a type depending on context. -->
			          <xsl:call-template name="task-or-subtask"/>
			          
			          <fo:block>
			            <xsl:text>(Page </xsl:text>
			            <xsl:call-template name="page-number-prefix"/>
			            <fo:page-number-citation>
			              <xsl:attribute name="ref-id" select="$linkId"/>
			            </fo:page-number-citation>
			            <xsl:call-template name="page-number-suffix"/>
			            <xsl:text>)</xsl:text>
			            
			            <!-- debug -->
			            <!-- <xsl:text>[</xsl:text><xsl:value-of select="$linkId"/><xsl:text>]</xsl:text> -->
			            
			          </fo:block>
			        </fo:basic-link>
	    		</xsl:otherwise>
	    	</xsl:choose>
	    </xsl:when>
	    
	    <xsl:when test="self::levelledPara or self::proceduralStep or self::note or self::notePara">
	        <fo:basic-link>
	          <xsl:attribute name="internal-destination" select="@id"/>
	          
	          <!-- Tables have TASK or Subtask as a type depending on context. -->
	          <xsl:call-template name="task-or-subtask"/>
	          
	          <fo:block>
	            <xsl:text>(Page </xsl:text>
	            <xsl:call-template name="page-number-prefix"/>
	            <fo:page-number-citation>
	              <xsl:attribute name="ref-id" select="@id"/>
	            </fo:page-number-citation>
	            <xsl:call-template name="page-number-suffix"/>
	            <xsl:text>)</xsl:text>
	          </fo:block>
	        </fo:basic-link>
	    </xsl:when>
	    
	    <xsl:when test="self::warningRef | self::cautionRef">
	    	<xsl:variable name="refId" select="@id"/>
	    	<!-- Originally just linking to the dmodule, since the warning/caution ref itself was not -->
	    	<!-- inline in the text of the dmodule. Now try to link to the proceduralStep it applies to. -->
	    	<xsl:variable name="proceduralStepId" select="ancestor::dmodule//(addwarning|addcaution)[ends-with($refId, @id)]/following-sibling::proceduralStep[1]/@id"/>
			<xsl:variable name="linkId">
	          <xsl:choose>
	          	<xsl:when test="$proceduralStepId = ''">
		          <xsl:value-of select="ancestor::dmodule/@id"/>
	          	</xsl:when>
	          	<xsl:otherwise>
		          <xsl:value-of select="$proceduralStepId"/>
	          	</xsl:otherwise>
	          </xsl:choose>
			</xsl:variable>

	        <fo:basic-link internal-destination="{$linkId}">
	          <xsl:call-template name="task-or-subtask"/>
	        </fo:basic-link>
	    </xsl:when>

	    <!-- dmodule is used for unlinked reasonForUpdates. Same as a typical levelledPara (etc.) above, but good -->
	    <!-- to separate in case we need special treatment later. -->
	    <xsl:when test="self::dmodule">
	        <fo:basic-link>
	          <xsl:attribute name="internal-destination" select="@id"/>
	          
	          <xsl:call-template name="task-or-subtask"/>
	          
	        </fo:basic-link>
	    </xsl:when>

	    <xsl:when test="self::pmEntry">

	        <fo:basic-link>
	          <xsl:attribute name="internal-destination" select="@id"/>
	          
	    	  <xsl:choose>
	    		
	    		<!-- Top-level pmEntries use the pmEntryTitle in the title column -->
	    		<xsl:when test="not(parent::pmEntry)">
			     	<xsl:if test="@authorityDocument">
			     		<fo:block><xsl:value-of select="@authorityDocument"/></fo:block>
			     	</xsl:if>
	    			<fo:block text-transform="uppercase"><xsl:value-of select="pmEntryTitle"/></fo:block>
	    		</xsl:when>
	    		
	    		<xsl:otherwise>
			       <xsl:call-template name="task-or-subtask"/>
	    		</xsl:otherwise>
	    	  </xsl:choose>
	          
	        </fo:basic-link>
	    </xsl:when>

	    <xsl:when test="self::listItemTerm | self::definitionListItem">
	    	<xsl:choose>
	    		<!-- Special case if in a legend (which is where it occurs most often): use the figure output method -->
	    		<xsl:when test="ancestor::legend">
		  			<xsl:call-template name="figure-change-title"/>
	    		</xsl:when>
	    		<xsl:otherwise>
			        <fo:basic-link>
			          <xsl:attribute name="internal-destination" select="@id"/>
			          
			          <!-- Can have TASK or Subtask as a type depending on context. -->
			          <xsl:call-template name="task-or-subtask"/>
			        </fo:basic-link>
			     </xsl:otherwise>
			</xsl:choose>
	    </xsl:when>

	    <xsl:when test="self::listItem | self::attentionListItemPara">
	        <fo:basic-link>
	          <xsl:attribute name="internal-destination" select="@id"/>
	          
	          <!-- Can have TASK or Subtask as a type depending on context. -->
	          <xsl:call-template name="task-or-subtask"/>
	        </fo:basic-link>
	    </xsl:when>

        <xsl:otherwise>
          <xsl:text> Unexpected Changed Element: </xsl:text>
          <xsl:value-of select="name(.)"/>
          <xsl:message>[error] Unexpected Changed Element: <xsl:value-of select="name(.)"/></xsl:message>
        </xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
  
  <!-- Context: require/assume we're in reasonForUpdate [ATA: CHGDESC] context -->
  <xsl:template name="determine-change-title">
  	<xsl:variable name="reasonForChangeid" select="@id"/>
  	
    <xsl:choose>
    
      <!-- Handle front-matter changes directly here -->
      <xsl:when test="ancestor::pmEntry[last()][@pmEntryType='pmt52']">
        <fo:basic-link>
          <!-- <xsl:attribute name="internal-destination" select="parent::TRANSLTR/@KEY"/> -->
          <xsl:attribute name="internal-destination" select="ancestor::pmEntry[@pmEntryType='pmt52']/@id"/>
          <xsl:text>TRANSMITTAL INFORMATION</xsl:text>
        </fo:basic-link>
      </xsl:when>

      <xsl:when test="ancestor::pmEntry[last()][@pmEntryType='pmt54']">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="ancestor::pmEntry[last()]/@id"/>
          <xsl:text>RECORD OF TEMPORARY REVISIONS</xsl:text>
        </fo:basic-link>
      </xsl:when>

      <xsl:when test="ancestor::pmEntry[last()][@pmEntryType='pmt55']">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="ancestor::pmEntry[last()]/@id"/>
          <xsl:text>SERVICE BULLETIN LIST</xsl:text>
        </fo:basic-link>
      </xsl:when>

	  <!-- In Introduction or later (this may need to be removed)... -->
	  <!-- 
      <xsl:when test="ancestor::pmEntry[last()][@pmEntryType='pmt58' or preceding-sibling::pmEntry[@pmEntryType='pmt58']]">
        <fo:basic-link>
[           <xsl:attribute name="internal-destination" select="parent::PGBLK/@KEY"/> ]
          <xsl:attribute name="internal-destination" select="ancestor::pmEntry[last()]/@id"/>
          <xsl:choose>
            <xsl:when test="$documentType = 'irm'">
              <xsl:call-template name="irm-highlights-page"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="ancestor::pmEntry[last()]/pmEntryTitle"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:basic-link>
      </xsl:when>
 -->
	  
	  <!-- If the reasonForUpdate is in the front-matter, it should be a change on a pmEntry in the PMC. -->
	  <!-- Use the pmEntry as the linking object. -->
	  <xsl:when test="parent::pmStatus/parent::identAndStatusSection/parent::pm">
	  	<!-- Call change-title-from-element with the pmEntry in context -->
	 	<xsl:for-each select="( (/pm/content/pmEntry | /pm/content/pmEntry/pmEntry | /pm/content/pmEntry/pmEntry/pmEntry
	 	  | /pm/content/pmEntry/pmEntry/pmEntry/pmEntry | /pm/content/pmEntry/pmEntry/pmEntry/pmEntry/pmEntry)
	 	  [@reasonForUpdateRefIds=$reasonForChangeid] )[1]">
	 	  <xsl:call-template name="change-title-from-element"/>
	 	</xsl:for-each>
	  </xsl:when>
	  
	  <!-- If the reasonForUpdate is "unlinked", we can use the dmodule as the linking object.  -->
	  <xsl:when test="not(ancestor::dmodule//*[@reasonForUpdateRefIds=$reasonForChangeid])">
	  	<!-- Call change-title-from-element with the dmodule in context -->
	 	  <xsl:for-each select="ancestor::dmodule[1]">
	 	  	<xsl:call-template name="change-title-from-element"/>
	 	  </xsl:for-each>
	  </xsl:when>
	  
      <!-- Otherwise output the title based on the element the reasonForUpdate is referred to from. -->
      <xsl:otherwise>
      	  <!-- Only use the first element that refers to the reasonForUpdate. Otherwise we would -->
      	  <!-- Need to make a new row, and I think this is a reasonable restriction for now. -->
	 	  <xsl:for-each select="(ancestor::dmodule//*[@reasonForUpdateRefIds=$reasonForChangeid])[1]">
	 	  	<xsl:call-template name="change-title-from-element"/>
	 	  </xsl:for-each>
      </xsl:otherwise>
 	  
 	  <!-- [ATA: the CHGDESC was added in a particular spot checked for here... -->
 	  <!-- Keep for reference since template "change-title-from-element" -->
 	  <!-- called above will need to use similar logic. -->
 	  <!-- 
      <xsl:when test="parent::TASK">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="parent::TASK/@KEY"/>
          <xsl:text>Task </xsl:text>
          <fo:block>
            <xsl:choose>
              <xsl:when test="$documentType = 'irm'">
                <xsl:call-template name="irm-highlights-page"/>
              </xsl:when>
              <xsl:when test="$documentType = 'ohm' or $documentType = 'orim'">
                [ Do not output MTOSS for ORIM or OHM ]
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="parent::TASK/@CHAPNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::TASK/@SECTNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::TASK/@SUBJNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::TASK/@FUNC"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::TASK/@SEQ"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::TASK/@CONFLTR"/>
                <xsl:value-of select="parent::TASK/@VARNBR"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
          <fo:block>
            <xsl:text>(Page&#160;</xsl:text>
            <xsl:call-template name="page-number-prefix"/>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:if test="ancestor-or-self::TASK/@KEY">
                  <xsl:value-of select="ancestor-or-self::TASK/@KEY"/>
                </xsl:if>
              </xsl:attribute>
            </fo:page-number-citation>
            <xsl:call-template name="page-number-suffix"/>
            <xsl:text>)</xsl:text>
          </fo:block>
        </fo:basic-link>
      </xsl:when>

      <xsl:when test="parent::SUBTASK">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="parent::SUBTASK/@KEY"/>
          <xsl:text>Subtask </xsl:text>
          <fo:block>
            <xsl:choose>
              <xsl:when test="$documentType = 'irm'">
                <xsl:call-template name="irm-highlights-page"/>
              </xsl:when>
              <xsl:when test="$documentType = 'ohm' or $documentType = 'orim'">
                [ Do not output MTOSS for ORIM or OHM ]
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="parent::SUBTASK/@CHAPNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::SUBTASK/@SECTNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::SUBTASK/@SUBJNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::SUBTASK/@FUNC"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::SUBTASK/@SEQ"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="parent::SUBTASK/@CONFLTR"/>
                <xsl:value-of select="parent::SUBTASK/@VARNBR"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
          <fo:block>
            <xsl:text>(Page </xsl:text>
            <xsl:call-template name="page-number-prefix"/>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:if test="ancestor-or-self::SUBTASK/@KEY">
                  <xsl:value-of select="ancestor-or-self::SUBTASK/@KEY"/>
                </xsl:if>
              </xsl:attribute>
            </fo:page-number-citation>
            <xsl:call-template name="page-number-suffix"/>
            <xsl:text>)</xsl:text>
          </fo:block>
        </fo:basic-link>
      </xsl:when>

      <xsl:when test="ancestor::GRAPHIC">
        <fo:basic-link>
          <xsl:attribute name="internal-destination">
            <xsl:choose>
              <xsl:when test="parent::SHEET">
                <xsl:value-of select="parent::SHEET/@KEY"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="following-sibling::SHEET[1]/@KEY"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:text>Graphic </xsl:text>
          <fo:block>
            <xsl:choose>
              <xsl:when test="$documentType = 'irm'">
                <xsl:call-template name="irm-highlights-page"/>
              </xsl:when>
              <xsl:when test="$documentType = 'ohm' or $documentType = 'orim'">
                [ Do not output MTOSS for ORIM or OHM ]
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="ancestor::GRAPHIC/@CHAPNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="ancestor::GRAPHIC/@SECTNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="ancestor::GRAPHIC/@SUBJNBR"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="ancestor::GRAPHIC/@FUNC"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="ancestor::GRAPHIC/@SEQ"/>
                <xsl:text>-</xsl:text>
                <xsl:value-of select="ancestor::GRAPHIC/@CONFLTR"/>
                <xsl:value-of select="ancestor::GRAPHIC/@VARNBR"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
          <fo:block>
            <xsl:text>(Page </xsl:text>
            <xsl:call-template name="page-number-prefix"/>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:choose>
                  <xsl:when test="ancestor-or-self::SHEET">
                    <xsl:choose>
                      <xsl:when test="ancestor-or-self::SHEET/@IMGAREA='hl'">
                        <xsl:value-of select="concat(ancestor-or-self::SHEET/@KEY,'-r1')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="ancestor-or-self::SHEET/@KEY"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="ancestor-or-self::GRAPHIC/SHEET[1]/@IMGAREA='hl'">
                        <xsl:value-of select="concat(ancestor-or-self::GRAPHIC/SHEET[1]/@KEY,'-r1')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="ancestor-or-self::GRAPHIC/SHEET[1]/@KEY"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </fo:page-number-citation>
            <xsl:call-template name="page-number-suffix"/>
            <xsl:text>)</xsl:text>
          </fo:block>
        </fo:basic-link>
      </xsl:when>

      <xsl:when test="parent::IPL">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="parent::IPL/@KEY"/>
          <xsl:text>ILLUSTRATED PARTS LIST</xsl:text>
        </fo:basic-link>
      </xsl:when>
      <xsl:when test="parent::FIGURE">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="following-sibling::GRAPHIC/SHEET[1]/@KEY"/>
          <xsl:text>IPL&#160;Figure&#160;</xsl:text>
          <xsl:value-of select="parent::FIGURE/@FIGNBR"/>
          <fo:block>
            <xsl:text>(Page&#160;</xsl:text>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:if test="following-sibling::GRAPHIC/SHEET[1]/@KEY">
                  <xsl:choose>
                    <xsl:when test="following-sibling::GRAPHIC/SHEET[1]/@IMGAREA='hl'">
                      <xsl:value-of select="concat(following-sibling::GRAPHIC/SHEET[1]/@KEY,'-r1')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="following-sibling::GRAPHIC/SHEET[1]/@KEY"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:if>
              </xsl:attribute>
            </fo:page-number-citation>
            <xsl:text>)</xsl:text>
          </fo:block>
        </fo:basic-link>
      </xsl:when>

      <xsl:when test="parent::PRTLIST">
        <fo:basic-link>
          <xsl:attribute name="internal-destination" select="parent::PRTLIST/@KEY"/>
          <xsl:text>IPL&#160;Figure&#160;</xsl:text>
          <xsl:value-of select="ancestor::FIGURE/@FIGNBR"/>
          <fo:block>
            <xsl:text>(Page </xsl:text>
            <fo:page-number-citation>
              <xsl:attribute name="ref-id">
                <xsl:if test="ancestor-or-self::PRTLIST/@KEY">
                  <xsl:value-of select="ancestor-or-self::PRTLIST/@KEY"/>
                </xsl:if>
              </xsl:attribute>
            </fo:page-number-citation>
            <xsl:text>)</xsl:text>
          </fo:block>
        </fo:basic-link>
      </xsl:when>

      <xsl:otherwise>
        <xsl:text> Unexpected Changed Element: </xsl:text>
        <xsl:value-of select="name(..)"/>
        <xsl:message>[error] Unexpected Changed Element: <xsl:value-of select="name(..)"/></xsl:message>
      </xsl:otherwise>
      -->
    </xsl:choose>
  </xsl:template>

  <!-- Output "Paragraph" followed by the calculated paragraph number. -->
  <!-- Context: the changed element -->
  <xsl:template name="output-paragraph-number">
    <!-- The task number (the first part of the paragraph number) is from the second-level pmEntry. -->
    <xsl:variable name="taskNumber">
      <xsl:value-of select="count(ancestor::pmEntry[count(ancestor::pmEntry)=1]/preceding-sibling::pmEntry) + 1"/>
    </xsl:variable>
    <xsl:variable name="subtaskNumber">
      <xsl:choose>
      	<xsl:when test="ancestor::levelledPara">
      	  <xsl:for-each select="ancestor::levelledPara[last()]">
      	  	<xsl:call-template name="calc-list-position"/>
      	  </xsl:for-each>
      	</xsl:when>
      	<xsl:when test="ancestor::proceduralStep">
      	  <xsl:for-each select="ancestor::proceduralStep[last()]">
      	  	<xsl:call-template name="calc-prclist-position"/>
      	  </xsl:for-each>
      	</xsl:when>
      </xsl:choose>
    </xsl:variable>
  	<xsl:text>Paragraph </xsl:text>
  	<xsl:number value="$taskNumber" format="1."/>
	<xsl:if test="$subtaskNumber != ''">
	  <xsl:number value="$subtaskNumber" format="A."/>
	</xsl:if>
    <xsl:text> </xsl:text>
    <!-- Now add the Step number, if applicable (when there's more than one ancestor levelledPara or proceduralStep) -->
    <xsl:choose>
      <xsl:when test="count(ancestor::proceduralStep) &gt; 1">
      	<xsl:text>Step </xsl:text>
      	<xsl:for-each select="ancestor::proceduralStep[position() &lt; last()]">
      		<!-- Same numbering as in S1000DLists.xsl -->
		    <xsl:variable name="listPosition">
		        <xsl:call-template name="calc-prclist-position"/>
		    </xsl:variable>
		    <xsl:variable name="formatString">
		        <xsl:call-template name="get-proclist-format-string"/>
		    </xsl:variable>
		    <xsl:variable name="formattedNumber">
		        <xsl:number value="$listPosition" format="{$formatString}"/>
		    </xsl:variable>
		    <xsl:variable name="textDecoration">
		    	<!-- Styler doesn't use the text decoration (underline) in the table of highlights -->
		        <!-- <xsl:call-template name="get-proclist-decoration"/> -->  
		    </xsl:variable>
		    
     		<fo:inline>
	            <xsl:attribute name="text-decoration">
	              <xsl:value-of select="$textDecoration"/>
	            </xsl:attribute>
     			<!-- Add a period after the first two steps (like "Step (2)(c).4") -->
     			<xsl:if test="count(ancestor::proceduralStep)=3">
     				<xsl:text>.</xsl:text>
     			</xsl:if>
	            <xsl:value-of select="$formattedNumber"/>
		    </fo:inline>
		    
      	</xsl:for-each>
    	<xsl:text>. </xsl:text>
      </xsl:when>
      <xsl:when test="count(ancestor::levelledPara) &gt; 1">
      	<xsl:text>Step </xsl:text>
      	<xsl:for-each select="ancestor::levelledPara[position() &lt; last()]">
      		<!-- Same numbering as in S1000DLists.xsl -->
		    <xsl:variable name="listPosition">
		        <xsl:call-template name="calc-list-position"/>
		    </xsl:variable>
		    <xsl:variable name="formatString">
		        <xsl:call-template name="get-list-format-string"/>
		    </xsl:variable>
		    <xsl:variable name="formattedNumber">
		        <xsl:number value="$listPosition" format="{$formatString}"/>
		    </xsl:variable>
		    <xsl:variable name="textDecoration">
		    	<!-- Styler doesn't use the text decoration (underline) in the table of highlights -->
		        <!-- <xsl:call-template name="get-levelledPara-decoration"/> -->
		    </xsl:variable>
		    
     		<fo:inline>
	           <xsl:attribute name="text-decoration">
	             <xsl:value-of select="$textDecoration"/>
	           </xsl:attribute>
     			<!-- Add a period after the first two steps (like "Step (2)(c).4") -->
     			<xsl:if test="count(ancestor::levelledPara)=3">
     				<xsl:text>.</xsl:text>
     			</xsl:if>
     			<!-- <xsl:text>{</xsl:text><xsl:value-of select="count(ancestor::levelledPara)"/><xsl:text>}</xsl:text> -->
               <xsl:value-of select="$formattedNumber"/>
		    </fo:inline>
      	</xsl:for-each>
  	    <xsl:text>. </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- Context: the element with the reasonForUpdateRefId (the changed element) -->
  <xsl:template name="paragraph-numbering-from-element">
  
    <xsl:choose>
    
      <!-- For IPL figures, we don't add any numbering information (it's already in the first column) -->
      <xsl:when test="ancestor-or-self::figure and ancestor::illustratedPartsCatalog">
      	<!-- nothing -->
      </xsl:when>
      
      <!-- Same for itemSeqNumber and catalogSeqNumber -->
      <xsl:when test="self::itemSeqNumber or self::catalogSeqNumber">
      	<!-- nothing -->
      </xsl:when>
      
      <!-- Same for warningRef and cautionRef -->
      <xsl:when test="self::warningRef or self::cautionRef">
      	<!-- nothing -->
      </xsl:when>

      <xsl:when test="ancestor-or-self::legend">
        <!-- Was going to add the figure number, but it looks like no number is required. -->
        <!-- UPDATE: Added back for now... -->
        <xsl:variable name="figNbr">
          <xsl:call-template name="calc-figure-number"/>
        </xsl:variable>
        
        <xsl:text>Figure&#160;</xsl:text>
        <xsl:value-of select="$figNbr"/>
        
        <!--  Add a period after the added numbering text.  -->
        <xsl:text>.&#160;</xsl:text>
      </xsl:when>
      
      <xsl:when test="self::figure or (self::title and parent::figure)">
        <xsl:variable name="figNbr">
          <xsl:call-template name="calc-figure-number"/>
        </xsl:variable>
        
        <xsl:text>Figure&#160;</xsl:text>
        <xsl:value-of select="$figNbr"/>
        
        <!-- Add a period after the added numbering text. -->
        <xsl:text>.&#160;</xsl:text>
      </xsl:when>
      
      <xsl:when test="self::graphic">
        <xsl:variable name="figNbr">
          <xsl:call-template name="calc-figure-number"/>
        </xsl:variable>
        
        <xsl:text>Figure&#160;</xsl:text>
        <xsl:value-of select="$figNbr"/>

        <!-- UPDATE: Don't need the sheet number: 
        <xsl:text>&#160;(Sheet&#160;</xsl:text>
        <xsl:number value="1 + count(preceding-sibling::graphic)"/>
        <xsl:text>)</xsl:text> -->
        
        <!-- Add a period after the added numbering text. -->
        <xsl:text>. </xsl:text>
      </xsl:when>
      
      <!-- For updates in the Introduction, try to get the current paragraph number. -->
      <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt58']">
        <xsl:call-template name="output-paragraph-number"/>
      </xsl:when>
      
      <xsl:when test="self::para or self::proceduralStep">
        <xsl:call-template name="output-paragraph-number"/>
      </xsl:when>
      
      <!-- If it is not a figure/graphic, and there is an authorityDocument on the dmRef or pmEntry, -->
      <!-- then it is a task or subtask, and the appropriate paragraph number should be output. -->
      <xsl:when test="ancestor::dmContent[1]/preceding-sibling::dmRef[1]/@authorityDocument
        or ancestor::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument">
        <xsl:call-template name="output-paragraph-number"/>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:text> Unhandled Changed Element: </xsl:text><xsl:value-of select="name(.)"/>
        <xsl:message>[error] Unhandled Changed Element: <xsl:value-of select="name(.)"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Calculate the paragraph/figure (or other) number to add before the reason for update text in -->
  <!-- the middle column. -->
  <!-- Context: reasonForUpdate -->
  <xsl:template name="determine-paragraph-numbering">
  	<xsl:variable name="reasonForChangeid" select="@id"/>
  	
    <xsl:choose>
      <!-- Front-matter changes don't get any paragraph/figure number added -->
      <xsl:when test="ancestor::pmEntry[last()][@pmEntryType='pmt52']
        or ancestor::pmEntry[last()][@pmEntryType='pmt53']
        or ancestor::pmEntry[last()][@pmEntryType='pmt54']
        or ancestor::pmEntry[last()][@pmEntryType='pmt55']">
        <!-- Nothing -->
      </xsl:when>

      <!-- Otherwise output the title based on the element the reasonForUpdate is referred to from. -->
      <xsl:otherwise>
      	  <!-- Only use the first element that refers to the reasonForUpdate. Otherwise we would -->
      	  <!-- Need to make a new row, and I think this is a reasonable restriction for now. -->
	 	  <xsl:for-each select="(ancestor::dmodule//*[@reasonForUpdateRefIds=$reasonForChangeid])[1]">
	 	  	<xsl:call-template name="paragraph-numbering-from-element"/>
	 	  </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!-- 
  <xsl:template name="OLD-determine-paragraph-numbering">
    <xsl:variable name="context" select="name(..)"/>
      <xsl:choose>
      <xsl:when test="parent::SUBTASK">
        <xsl:text>Paragraph&#160;</xsl:text>
        <xsl:number value="1 + count(../ancestor::TASK/preceding-sibling::TASK)" format="1."/>
        <xsl:number value="1 + count(../preceding-sibling::SUBTASK)" format="A."/>
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      <xsl:when test="parent::TASK">
        <xsl:text>Paragraph&#160;</xsl:text>
        <xsl:number value="1 + count(../preceding-sibling::TASK)" format="1."/>
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor::GRAPHIC">
        <xsl:variable name="figNbr">
          <xsl:choose>
            <xsl:when test="ancestor::FIGURE">
              <xsl:value-of select="ancestor::FIGURE/@FIGNBR"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="calc-figure-number"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="ancestor::FIGURE">
          <xsl:text>IPL&#160;</xsl:text>
        </xsl:if>
        <xsl:text>Figure&#160;</xsl:text>
        <xsl:value-of select="$figNbr"/>
        <xsl:if test="parent::SHEET">
          <xsl:text>&#160;(Sheet&#160;</xsl:text>
          <xsl:number value="1 + count(../preceding-sibling::SHEET)"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:text>.&#160;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template> -->

</xsl:stylesheet>
