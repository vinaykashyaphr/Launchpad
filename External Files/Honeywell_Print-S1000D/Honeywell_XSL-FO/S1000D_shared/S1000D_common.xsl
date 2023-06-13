<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

<!-- Templates taken mostly from the main S1000D XSL module that are shared between the different -->
<!-- document types (CMM, EIPC, EM). -->

	<xsl:template match="addwarning">
		<xsl:variable name="refId" select="@warningRef"/>
		<!-- Warnings and cautions should be referred to through the warningsAndCautionsRef section at the -->
		<!-- beginning of the dmodule, where an identNumber is specified for the warning/caution repositories. -->
		<!-- Previously, we were just using the id directly in the repository; use that still as a fall-back for now -->
		<!-- for backwards compatibility. -->
		<xsl:variable name="warningRef" select="ancestor::content/warningsAndCautionsRef/warningRef[ends-with(@id,$refId)]"/>
		<xsl:variable name="identNumber">
			<!-- ids are made unique in the pre-process by adding a prefix based on the data module, so match on only the last part of the id. -->
			<!-- <xsl:if test="ancestor::content/warningsAndCautionsRef/warningRef[ends-with(@id,$refId)]">
				<xsl:value-of select="ancestor::content/warningsAndCautionsRef/warningRef[ends-with(@id,$refId)]/@warningIdentNumber"/>
			</xsl:if> -->
			<xsl:value-of select="$warningRef/@warningIdentNumber"/>
		</xsl:variable>
		
		<fo:list-block xsl:use-attribute-sets="list.vertical.space"
		      provisional-distance-between-starts="0.82in" keep-together.within-column="always">

			<xsl:if test="not($warningRef/@changeMark='0') and 
			  ($warningRef/@changeType='add' or $warningRef/@changeType='modify' or $warningRef/@changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>

		     <!-- Indent if first thing in mainProcedure -->
		     <!-- UPDATE: It looks like non-first ones need the indent as well. -->
		     <xsl:if test="parent::mainProcedure"><!-- and count(preceding-sibling::proceduralStep)=0 -->
		     	<xsl:attribute name="margin-left">0.5in</xsl:attribute>
		     </xsl:if>
		     <fo:list-item>
		        <fo:list-item-label end-indent="label-end()">
		          <fo:block text-decoration="underline" font-weight="bold">
		          	<xsl:text>WARNING:</xsl:text>
		          </fo:block>
		        </fo:list-item-label>
		        <fo:list-item-body start-indent="body-start()">
		          <fo:block font-weight="bold" text-transform="uppercase">
		            <xsl:choose>
		            	<xsl:when test="$identNumber != ''">
				            <xsl:apply-templates select="/pm/commonRepository/warningRepository/warningSpec/warningAndCautionPara[../warningIdent/@warningIdentNumber=$identNumber]" />
		            	</xsl:when>
		            	<xsl:otherwise>
				          	<!-- From Styler: _ufe:ProceduralStepWarningText -->
				            <xsl:apply-templates select="/pm/commonRepository/warningRepository/warningSpec/warningAndCautionPara[../warningIdent/@id=$refId]" />
		            	</xsl:otherwise>
		            </xsl:choose>
		          </fo:block>
		        </fo:list-item-body>
		      </fo:list-item>

			<xsl:if test="not($warningRef/@changeMark='0') and
			  ($warningRef/@changeType='add' or $warningRef/@changeType='modify' or $warningRef/@changeType='delete')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>

	    </fo:list-block>

	</xsl:template>
	
	<xsl:template match="addcaution">
		<xsl:variable name="refId" select="@cautionRef"/>
		<!-- Warnings and cautions should be referred to through the warningsAndCautionsRef section at the -->
		<!-- beginning of the dmodule, where an identNumber is specified for the warning/caution repositories. -->
		<!-- Previously, we were just using the id directly in the repository; use that still as a fall-back for now -->
		<!-- for backwards compatibility. -->
		<xsl:variable name="cautionRef" select="ancestor::content/warningsAndCautionsRef/cautionRef[ends-with(@id,$refId)]"/>
		<xsl:variable name="identNumber">
			<!-- ids are made unique in the pre-process by adding a prefix based on the data module, so match on only the last part of the id. -->
			<xsl:value-of select="$cautionRef/@cautionIdentNumber"/>
		</xsl:variable>
		
		<fo:list-block xsl:use-attribute-sets="list.vertical.space"
		      provisional-distance-between-starts="0.82in" keep-together.within-column="always">

			<xsl:if test="not($cautionRef/@changeMark='0') and
			  ($cautionRef/@changeType='add' or $cautionRef/@changeType='modify' or $cautionRef/@changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>

		     <!-- Indent if first thing in mainProcedure -->
		     <!-- UPDATE: It looks like non-first ones need the indent as well. -->
		     <xsl:if test="parent::mainProcedure"><!-- and count(preceding-sibling::proceduralStep)=0 -->
		     	<xsl:attribute name="margin-left">0.5in</xsl:attribute>
		     </xsl:if>
		     <fo:list-item>
		        <fo:list-item-label end-indent="label-end()">
		          <fo:block>
		          	<fo:inline text-decoration="underline"><xsl:text>CAUTION</xsl:text></fo:inline><xsl:text>:</xsl:text>
		          </fo:block>
		        </fo:list-item-label>
		        <fo:list-item-body start-indent="body-start()">
		          <fo:block text-transform="uppercase">
		            <xsl:choose>
		            	<xsl:when test="$identNumber != ''">
				            <xsl:apply-templates select="/pm/commonRepository/cautionRepository/cautionSpec/warningAndCautionPara[../cautionIdent/@cautionIdentNumber=$identNumber]" />
		            	</xsl:when>
		            	<xsl:otherwise>
				          	<!-- From Styler: _ufe:ProceduralStepWarningText -->
				            <xsl:apply-templates select="/pm/commonRepository/cautionRepository/cautionSpec/warningAndCautionPara[../cautionIdent/@id=$refId]" />
		            	</xsl:otherwise>
		            </xsl:choose>
		          </fo:block>
		        </fo:list-item-body>
		      </fo:list-item>

			  <xsl:if test="not($cautionRef/@changeMark='0') and
			    ($cautionRef/@changeType='add' or $cautionRef/@changeType='modify' or $cautionRef/@changeType='delete')">
				<xsl:call-template name="cbEnd" />
			  </xsl:if>

	    </fo:list-block>
	</xsl:template>
	
	<xsl:template match="caution | warning">
		<!-- Plain warnings and cautions occur between proceduralSteps and levelledParas, so need to be outdented to -->
		<!-- where the list item number is positioned. -->
		<!-- UPDATE: Except within tables. -->
		<fo:list-block xsl:use-attribute-sets="list.vertical.space"
		      provisional-distance-between-starts="0.82in" keep-together.within-column="always">
		     <xsl:if test="(ancestor::levelledPara or ancestor::proceduralStep) and not(ancestor::table)">
		     	<xsl:attribute name="margin-left">-0.5in</xsl:attribute>
		     	<!-- <xsl:comment>Outdented warning/caution</xsl:comment> -->
		     </xsl:if>
		     <!-- Indent if first thing in mainProcedure -->
		     <xsl:if test="parent::mainProcedure and count(preceding-sibling::proceduralStep)=0">
		     	<xsl:attribute name="margin-left">0.5in</xsl:attribute>
		     </xsl:if>
		     <fo:list-item>
		        <fo:list-item-label end-indent="label-end()">
		          <fo:block>
		            <xsl:choose>
		            	<xsl:when test="self::caution">
				          	<fo:inline text-decoration="underline"><xsl:text>CAUTION</xsl:text></fo:inline>
				          	<xsl:text>:</xsl:text>
		            	</xsl:when>
		            	<xsl:otherwise>
				          	<fo:inline text-decoration="underline" font-weight="bold"><xsl:text>WARNING</xsl:text></fo:inline>
				          	<xsl:text>:</xsl:text>
		            	</xsl:otherwise>
		            </xsl:choose>
		          </fo:block>
		        </fo:list-item-label>
		        <fo:list-item-body start-indent="body-start()">
		          <fo:block text-transform="uppercase">
		            <xsl:if test="self::warning">
		            	<xsl:attribute name="font-weight">bold</xsl:attribute>
		            </xsl:if>
		          	<xsl:apply-templates/>
		          </fo:block>
		        </fo:list-item-body>
		      </fo:list-item>
		</fo:list-block>
	</xsl:template>
	
	<!-- warning: copying styler which adds a newline after warning -->
	<!-- UPDATE: That doesn't look good in the sample, so removing the extra blank line. -->
	<!-- This was for the CMM version... 
	<xsl:template match="warning">
		<fo:block><xsl:apply-templates/></fo:block>
		[!++ <fo:block>&#160;</fo:block> ++]
	</xsl:template>
	 -->
	 
	<xsl:template match="warningAndCautionPara">
		<!-- First one can be inline, then make blocks -->
		<xsl:choose>
			<xsl:when test="not(preceding-sibling::warningAndCautionPara)">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<fo:block><xsl:apply-templates/></fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="note">
		<fo:block space-before="4pt" space-after="0pt" keep-together.within-column="always">
		  <xsl:if test="@id">
		  	<xsl:attribute name="id" select="@id"/>
		  </xsl:if>
		  <xsl:if test="preceding-sibling::*[1]/self::para">
		  	<xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
		  </xsl:if>
		<!-- <xsl:choose>
			[ From Styler: If in top-level procedural step, use 14mm indent ]
			<xsl:when test="parent::proceduralStep[not(ancestor::proceduralStep)]">
				<xsl:attribute name="start-indent" select="'14mm'"/>
			</xsl:when>
			[ Same for levelledPara ]
			<xsl:when test="parent::levelledPara[not(ancestor::levelledPara)]">
				<xsl:attribute name="start-indent" select="'14mm'"/>
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose> -->
		
		<xsl:choose>
			<!-- If the first thing in the note is a list and it has more than one item, use "NOTES:" and don't -->
			<!-- start a list block. -->
			<xsl:when test="(*[1][name()='attentionSequentialList'] and count(attentionSequentialList/attentionSequentialListItem) > 1)
			  or (*[1][name()='attentionRandomList'] and count(attentionRandomList/attentionRandomListItem) > 1) ">
		      <fo:block font-weight="bold" space-before="4pt" keep-with-next.within-page="always">
		      	<xsl:text>NOTES:</xsl:text>
		      </fo:block>
		      <xsl:apply-templates />
			</xsl:when>
			<xsl:when test="*[1][name()='attentionSequentialList']
			  or *[1][name()='attentionRandomList']">
		      <fo:block font-weight="bold" space-before="4pt" keep-with-next.within-page="always">
		      	<xsl:text>NOTE:</xsl:text>
		      </fo:block>
	          <xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block provisional-distance-between-starts="0.72in" keep-together.within-column="always">
				  <fo:list-item>
				    <fo:list-item-label end-indent="label-end()">
				      <fo:block font-weight="bold">
				      	<xsl:text>NOTE:</xsl:text>
				      </fo:block>
				    </fo:list-item-label>
				    <fo:list-item-body start-indent="body-start()">
				      <fo:block>
				        <xsl:apply-templates />
				      </fo:block>
				    </fo:list-item-body>
				  </fo:list-item>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
	  </fo:block>
	</xsl:template>

	<xsl:template match="notePara">
		<xsl:choose>
			<!-- first notePara in note is inline -->
			<xsl:when test="count(preceding-sibling::notePara)=0">
				<fo:inline>
				  <xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<!-- Indent setting from Styler -->
				<fo:block space-before="4pt" space-after="0pt"><!--  start-indent="0.38in" -->
				  <xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
					<xsl:apply-templates />
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="simplePara">
		<xsl:choose>
			<!-- Make the first simplePara in reasonForUpdate inline (for use in the Table of Highlights) -->
			<xsl:when test="parent::reasonForUpdate and not(preceding-sibling::*)">
				<fo:inline>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block space-before="0pt" space-after="0pt">
					<xsl:apply-templates />
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Hide the dmRef it it's in pmEntry or reqCondDm. -->
	<xsl:template match="pmEntry/dmRef">
	</xsl:template>
	<xsl:template match="reqCondDm/dmRef">
	</xsl:template>

	<xsl:template match="acronymTerm">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>


	<xsl:template match="externalPubCode">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	<xsl:template match="externalPubTitle">
		<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
	</xsl:template>
	 
	<xsl:template match="supportEquipDescr">
		<!-- TODO: This outputs a row of the Support Equipment table in Styler -->
		<fo:block>
			<!-- <xsl:text>Support Equipment Table row: TODO</xsl:text> -->
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>

	<xsl:template match="name">
		<xsl:choose>
			<!-- If in preliminaryRqmts or functionalItemSpec, then hide (output from 
				supportEquipDescr row) -->
			<xsl:when
				test="ancestor::preliminaryRqmts or ancestor::functionalItemSpec">
			</xsl:when>
			<xsl:otherwise>
				<fo:inline>
					<xsl:apply-templates />
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="emphasis">
		<xsl:choose>
			<xsl:when test="@emphasisType='em01'">
				<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:when test="@emphasisType='em02'">
				<fo:inline font-style="italic"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:when test="@emphasisType='em03'">
				<fo:inline text-decoration="underline"><xsl:apply-templates/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-weight="bold"><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>




	<xsl:template match="subScript">
		<fo:inline vertical-align="sub" font-size="8pt">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="superScript">
		<fo:inline vertical-align="super" font-size="8pt">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

  <xsl:template match="figure/title" mode="graphic-title">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- RS: This gets the task or subtask number including the type name (TASK/Subtask) and parens. -->
  <!-- Called from cmmToc.xsl with the parent of the title (or pmEntryTitle) in context. -->
  <!-- Called from titles.xsl with pmEntryTitle in context. -->
  <!-- Called from S1000DLists.xsl with the levelledPara title or proceduralStep title in context. -->
  <xsl:template name="get-mtoss">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::levelledPara | ancestor-or-self::proceduralStep">
      
        <xsl:choose>
          <xsl:when test="$documentType = 'orim' or $documentType = 'ohm'">
            <!-- Do not output MTOSS for IRM or ORIM or OHM -->
            <!-- RS: Removed IRM from this list -->
          </xsl:when>
          <xsl:when test="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument">
          	<xsl:text>(Subtask </xsl:text>
          	<xsl:value-of select="(ancestor::dmContent/preceding-sibling::dmRef)[last()]/@authorityDocument"/>
          	<xsl:text>)</xsl:text>
          </xsl:when>
          <!-- <xsl:otherwise>
            <xsl:value-of select="concat('(Subtask ',$chapSectSubj,'-',@FUNC,'-',@SEQ,'-',@CONFLTR,@VARNBR,')')"/>
          </xsl:otherwise> -->
        </xsl:choose>
        
      </xsl:when>
      <!-- <xsl:when test="ancestor-or-self::TASK"> -->
      <!-- Output TASK for 2md-level pmEntryTitles -->
      <xsl:when test="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=1]">
        <xsl:choose>
          <xsl:when test="$documentType = 'orim' or $documentType = 'ohm'">
            <!-- Do not output MTOSS for IRM, ORIM or OHM -->
            <!-- RS: Removed IRM from this list -->
          </xsl:when>
          <xsl:when test="ancestor-or-self::pmEntry[1]/@authorityDocument">
          	<xsl:text>(TASK </xsl:text>
          	<xsl:value-of select="ancestor-or-self::pmEntry[1]/@authorityDocument"/>
          	<xsl:text>)</xsl:text>
          </xsl:when>
          <!-- <xsl:otherwise>
            <xsl:value-of select="concat('(TASK ',$chapSectSubj,'-',@FUNC,'-',@SEQ,'-',@CONFLTR,@VARNBR,')')"/>
          </xsl:otherwise> -->
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

	<xsl:template name="effectivityAll">
		<fo:marker marker-class-name="efftextValue">
			<xsl:value-of select="'ALL'" />
		</fo:marker>
	</xsl:template>
	
  <xsl:template name="whereami">
    <xsl:message>I'm in <xsl:value-of select="name()"/></xsl:message>
  </xsl:template>

  <xsl:template name="node-type">
  	<xsl:param name="node"/>
  	
	<xsl:choose>
	  <xsl:when test="$node/self::*">
	    <xsl:text>Element; name: </xsl:text>
	    <xsl:value-of select="name($node)"/>
	  </xsl:when>
	  <xsl:when test="$node/self::text()">
	    <xsl:text>Text</xsl:text>
	  </xsl:when>
	  <xsl:when test="$node/self::comment()">
	    <xsl:text>Comment</xsl:text>
	  </xsl:when>
	  <xsl:when test="$node/self::processing-instruction()">
	    <xsl:text>PI; name: </xsl:text>
	    <xsl:value-of select="name($node)"/>
	  </xsl:when>
	  <!-- 
	  <xsl:when test="count(.|../@*)=count(../@*)">
	    <xsl:text>Attribute</xsl:text>
	  </xsl:when> -->
	  <xsl:otherwise>
	    <xsl:text>Other</xsl:text>
	  </xsl:otherwise>
	  
	</xsl:choose>
  	
  </xsl:template>
  
</xsl:stylesheet>
