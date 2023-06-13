<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">

<!-- References for S1000D, based on shared/references.xsl -->

   <xsl:template match="internalRef">
      <xsl:variable name="refId" select="@internalRefId"/>
      <xsl:variable name="specifiedText" select="@authorityName"/>
      <xsl:variable name="debugId" select="generate-id()"/>
      
      <xsl:choose>
         <xsl:when test="id($refId)">
            <xsl:for-each select="id($refId)">
               <xsl:call-template name="build-refint-link">
                  <!-- In S1000D, @authorityName can be used to set the text of the link instead of the default. -->
                  <xsl:with-param name="specifiedText" select="@authorityName"/>
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <!-- RS: Currently in the FO process, the processor doesn't use the schema, so the id() -->
         <!-- function in the first test above doesn't work (TODO: fix this?) -->
         <xsl:when test="/pm/content//@id = $refId">
            <xsl:for-each select="/pm/content//*[@id = $refId]">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="specifiedText" select="$specifiedText"/>
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <!-- 
         <xsl:when test="//@FTNOTEID = $refId">
            <xsl:for-each select="//*[@FTNOTEID = $refId]">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         [!++ This should be the same as the first case, but that might be processor specific ++]
         <xsl:when test="//@ID = $refId">
            <xsl:for-each select="//*[@ID = $refId]">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when> -->
         <xsl:otherwise>
            <fo:inline color="red"><xsl:value-of select="concat('[[[ Unmatched internalRef=',$refId,']]]')"/></fo:inline>
            <xsl:message>
               <xsl:value-of select="concat('[error] [[[ Unmatched internalRef=',$refId,']]]')"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

  <xsl:template match="REFEXT">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- The target node (what the link points to) is in context when this template is called -->
  <xsl:template name="subtaskRef">
    <xsl:param name="specifiedText"/>
    <!-- When the specified text (via the authorityName attribute on dmRef) is "Paragraph ...", -->
    <!-- we should add the subtask number after (if it exists). -->
    <!-- (like "Paragraph 2.D. Clean the Inlet Temperature Sensor (Subtask 75-40-01-100-006-A01)") -->
    <!-- But not for EIPC.-->
    <!-- UPDATE: When the form is "Paragraph 2." then it is a reference to a Task instead -->
    <!-- where you get the task number from the authorityDocument attribute on the pmEntry -->
    <!-- (5th-level). -->

  	<!-- <xsl:message>Making specifiedText link: specifiedText: <xsl:value-of select="$specifiedText"/>; Subtask (authorityDocument): <xsl:value-of select="ancestor::dmContent/preceding-sibling::dmRef[1]/@authorityDocument"/></xsl:message> -->
    <xsl:if test="not($documentType='eipc') and substring($specifiedText,1,9)='Paragraph'">
      <xsl:choose>
      	<xsl:when test="matches($specifiedText, '^Paragraph [0-9A-Z]{1,4}\. ')">
      	  <xsl:if test="ancestor::pmEntry[1]/@authorityDocument">
	      	<xsl:text> (Task </xsl:text>
	      	<xsl:value-of select="ancestor::pmEntry[1]/@authorityDocument"/>
	      	<xsl:text>)</xsl:text>
      	  </xsl:if>
      	</xsl:when>
      	<xsl:when test="ancestor::dmContent/preceding-sibling::dmRef[1]/@authorityDocument">
	      	<xsl:text> (Subtask </xsl:text>
	      	<xsl:value-of select="ancestor::dmContent/preceding-sibling::dmRef[1]/@authorityDocument"/>
	      	<xsl:text>)</xsl:text>
      	</xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

   <!-- The target node (what the link points to) is in context when this template is called -->
   <xsl:template name="build-refint-link">
      <xsl:param name="specifiedText" select="''"/>
      <xsl:param name="refId" select="''"/>
      <xsl:param name="debugId" select="''"/>
      
     <fo:basic-link internal-destination="{$refId}"><!-- color="#0000ff"-->
     	<!--  Links should be blue except for tools and consumables. -->
     	<xsl:if test="not(name()='supportEquipDescr' or name()='supplyDescr')">
     		<xsl:attribute name="color">blue</xsl:attribute>
     	</xsl:if>
         <xsl:if test="number($DEBUG) = 1">
            <xsl:attribute name="id">
               <xsl:value-of select="$debugId"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:choose>
            <xsl:when test="$specifiedText != ''">
               <xsl:value-of select="$specifiedText"/>
               <xsl:call-template name="subtaskRef">
               	<xsl:with-param name="specifiedText" select="$specifiedText"/>
               </xsl:call-template>
            </xsl:when>
            <!-- Only tables with titles are counted (formal tables) -->
            <xsl:when test="name() = 'table' and child::title">
               <xsl:text>Table </xsl:text>
               <xsl:call-template name="calc-table-number"/>
            </xsl:when>
            <xsl:when test="name()='figure'">
               <xsl:call-template name="figureRef">
               	<xsl:with-param name="refId" select="$refId"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="name()='graphic'">
               <xsl:call-template name="figureRef">
               	<xsl:with-param name="refId" select="$refId"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="name()='proceduralStep'">
			    <xsl:variable name="listPosition">
			        <xsl:call-template name="calc-prclist-position"/>
			    </xsl:variable>
			    <xsl:variable name="formatString">
			        <xsl:call-template name="get-proclist-format-string"/>
			    </xsl:variable>
			    <xsl:variable name="textDecoration">
			        <xsl:call-template name="get-proclist-decoration"/>  
			    </xsl:variable>
			    <fo:inline text-decoration="{$textDecoration}">
			      <!-- UPDATE: Remove "Step" prefix, to match Styler behavior. -->
                  <!-- <xsl:text>Step </xsl:text> -->
                  <xsl:number value="$listPosition" format="{$formatString}"/>
                  <!-- <xsl:text> [refId: </xsl:text><xsl:value-of select="$refId"/><xsl:text>]</xsl:text> -->
			    </fo:inline>
            </xsl:when>
            <xsl:when test="name()='supportEquipDescr'">
            	<!-- Check for the ID of the tool table. Later we might want to save its ID in a pre-process -->
            	<!-- to avoid searching here, but we'll wait and see if it is too slow. -->
            	<xsl:variable name="toolTableTitle" select="'Special Tools, Fixtures, and Equipment'"/>
            	<xsl:variable name="toolTableId">
            		<!-- This order of precedence of looking for the Tool table is from the Styler internalRef element's source edit. -->
            		<xsl:choose>
            			<xsl:when test="ancestor::pmEntry[1]/dmContent/dmodule//table[string(title)=$toolTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[1]/dmContent/dmodule//table[string(title)=$toolTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[2]/dmContent/dmodule//table[string(title)=$toolTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[2]/dmContent/dmodule//table[string(title)=$toolTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[2]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$toolTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[2]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$toolTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[3]/dmContent/dmodule//table[string(title)=$toolTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[3]/dmContent/dmodule//table[string(title)=$toolTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[3]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$toolTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[3]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$toolTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:otherwise>
            				<xsl:message>ERROR: Tools table not found for internalRef refId = <xsl:value-of select="$refId"/></xsl:message>
            			</xsl:otherwise>
            		</xsl:choose>
            	</xsl:variable>
			    <xsl:variable name="toolNo" select="/pm/content//supportEquipDescr[@id=$refId]/toolRef/@toolNumber"/>
			    <!-- Change the internal-destination attribute to use the toolTableId instead of the internalRef refId -->
			    <xsl:attribute name="internal-destination" select="$toolTableId"/>
			    <xsl:choose>
			    	<xsl:when test="/pm/commonRepository/toolRepository/toolSpec[toolIdent/@toolNumber=$toolNo]/itemIdentData/shortName">
			    		<xsl:value-of select="/pm/commonRepository/toolRepository/toolSpec[toolIdent/@toolNumber=$toolNo]/itemIdentData/shortName"/>
			    	</xsl:when>
			    	<!--  For "commercially available" tools, the toolSpec matches the id rather than the tool number. -->
			    	<xsl:when test="/pm/commonRepository/toolRepository/toolSpec[toolIdent/@id=$toolNo]/itemIdentData/shortName">
			    		<xsl:value-of select="/pm/commonRepository/toolRepository/toolSpec[toolIdent/@id=$toolNo]/itemIdentData/shortName"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    		<fo:inline color="red"><xsl:value-of select="concat('[[[ Tool short name not found for tool number: ',$toolNo,']]]')"/></fo:inline>
			    	</xsl:otherwise>
			    </xsl:choose>
            </xsl:when>
            <xsl:when test="name()='supplyDescr'">
            	<!-- Check for the ID of the consumables table. Later we might want to save its ID in a pre-process -->
            	<!-- to avoid searching here, but we'll wait and see if it is too slow. -->
            	<xsl:variable name="supplyTableTitle" select="'Consumables'"/>
            	<xsl:variable name="supplyTableId">
            		<!-- This order of precedence of looking for the Consumables table is from the Styler internalRef element's source edit. -->
            		<xsl:choose>
            			<xsl:when test="ancestor::pmEntry[1]/dmContent/dmodule//table[string(title)=$supplyTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[1]/dmContent/dmodule//table[string(title)=$supplyTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[2]/dmContent/dmodule//table[string(title)=$supplyTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[2]/dmContent/dmodule//table[string(title)=$supplyTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[2]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$supplyTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[2]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$supplyTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[3]/dmContent/dmodule//table[string(title)=$supplyTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[3]/dmContent/dmodule//table[string(title)=$supplyTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:when test="ancestor::pmEntry[3]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$supplyTableTitle]">
            				<xsl:value-of select="ancestor::pmEntry[3]/descendant::pmEntry/dmContent/dmodule//table[string(title)=$supplyTableTitle]/@id"/>
            			</xsl:when>
            			<xsl:otherwise>
            				<xsl:message>ERROR: Consumables table not found for internalRef refId = <xsl:value-of select="$refId"/></xsl:message>
            			</xsl:otherwise>
            		</xsl:choose>
            	</xsl:variable>
			    <xsl:variable name="supplyNo" select="/pm/content//supplyDescr[@id=$refId]/supplyRef/@supplyNumber"/>
			    <xsl:if test="not($supplyNo) or $supplyNo=''">
			    	<!-- Use string-join to make sure we're not dealing with multiple refIds -->
			    	<xsl:message>WARNING: Can't get supply number for ID <xsl:value-of select="string-join($refId,',')"/>.</xsl:message>
			    </xsl:if>
			    <!-- Change the internal-destination attribute to use the supplyTableId instead of the internalRef refId -->
			    <xsl:attribute name="internal-destination" select="$supplyTableId"/>
			    <xsl:choose>
			    	<xsl:when test="/pm/commonRepository/supplyRepository/supplySpec[supplyIdent/@supplyNumber=$supplyNo]/shortName">
			    		<xsl:value-of select="/pm/commonRepository/supplyRepository/supplySpec[supplyIdent/@supplyNumber=$supplyNo]/shortName"/>
			    	</xsl:when>
			    	<!-- For "commercially available" supplies, the supplySpec matches the id rather than the supply number. -->
			    	<xsl:when test="/pm/commonRepository/supplyRepository/supplySpec[supplyIdent/@id=$supplyNo]/shortName">
			    		<xsl:value-of select="/pm/commonRepository/supplyRepository/supplySpec[toolIdent/@id=$supplyNo]/shortName"/>
			    	</xsl:when>
			    	<xsl:otherwise>
			    		<fo:inline color="red"><xsl:value-of select="concat('[[[ Supply short name not found for supply number: ',$supplyNo,']]]')"/></fo:inline>
			    	</xsl:otherwise>
			    </xsl:choose>
            </xsl:when>
            <xsl:when test="name() = 'FTNOTE'">
               <!-- DJH
                  <xsl:text>Footnote </xsl:text>
                  -->
               <fo:inline vertical-align="super" font-size="8pt">
                  <xsl:value-of select="1 + count(preceding-sibling::FTNOTE)"/>
               </fo:inline>
            </xsl:when>
           <xsl:when test="name() ='PGBLK'">
             <xsl:choose>
               <xsl:when test="$documentType = 'irm'">
                 <xsl:call-template name="get-irm-pn"/>
               </xsl:when>
               <xsl:when test="$documentType = 'ohm' or $documentType = 'orim'">
                 <xsl:apply-templates select="TITLE" mode="refint"/>
               </xsl:when>
               <xsl:otherwise>
                 <xsl:apply-templates select="TITLE" mode="refint"/>
                 <xsl:text> </xsl:text>
                 <xsl:text> (PGBLK </xsl:text>
                 <xsl:value-of select="concat(@CHAPNBR,
                   '-',@SECTNBR,
                   '-',@SUBJNBR,
                   '-',@PGBLKNBR)"/>
                 <xsl:text>)</xsl:text>
               </xsl:otherwise>
             </xsl:choose>
           </xsl:when>
            <xsl:when test="name()='TASK'">
               <xsl:text>Paragraph </xsl:text>
               <xsl:call-template name="get-task-enumerator"/>
               <xsl:text>. </xsl:text>
              
			  <xsl:if test="not(/CMM and $documentType != 'irm' or $documentType != 'ohm' or $documentType != 'orim')">
                <xsl:apply-templates select="TITLE" mode="refint"/>
              </xsl:if>

              <!-- CV - Sonovision wants "Task and Subtask" to appear for IRM (and likely all other types, too) -->
			  <!-- <xsl:if test="not($documentType != 'irm' or $documentType != 'ohm' or $documentType != 'orim')"> -->

			   <xsl:text> (Task </xsl:text>
               <!--Removed PGBLKNBR. Mantis #18344-->
               <xsl:value-of select="concat(@CHAPNBR,
                    '-',@SECTNBR,
                    '-',@SUBJNBR,
                    '-',@FUNC,
                    '-',@SEQ,
                    '-',@CONFLTR,
                        @VARNBR)"/>
               <xsl:text>)</xsl:text>

		      <!-- </xsl:if> -->

			  </xsl:when>
            <xsl:when test="name() = 'SUBTASK'">
               <xsl:text>Paragraph </xsl:text>
               <xsl:call-template name="get-task-enumerator"/>
               <xsl:text>.</xsl:text>
               <xsl:call-template name="get-subtask-enumerator"/>
               <xsl:text>. </xsl:text>

   		      <xsl:if test="not(/CMM and $documentType != 'irm' or $documentType != 'ohm' or $documentType != 'orim')">
                <xsl:apply-templates select="TITLE" mode="refint"/>
              </xsl:if>
			  
              <!-- CV - Sonovision wants "Task and Subtask" to appear for IRM (and likely all other types, too) -->
              <!--
			  <xsl:choose>
                <xsl:when test="$documentType != 'irm' or $documentType != 'ohm' or $documentType != 'orim'">
                  <!- - Do not output MTOSS for IRM, ORIM, OHM - ->
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text> (Subtask </xsl:text>
                  <!- -Removed PGBLKNBR. Mantis #18344- ->
                  <xsl:value-of select="concat(@CHAPNBR,
                    '-',@SECTNBR,
                    '-',@SUBJNBR,
                    '-',@FUNC,
                    '-',@SEQ,
                    '-',@CONFLTR,
                    @VARNBR)"/>
                  <xsl:text>)</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
			  -->

			   <xsl:text> (Subtask </xsl:text>
               <!--Removed PGBLKNBR. Mantis #18344-->
               <xsl:value-of select="concat(@CHAPNBR,
                    '-',@SECTNBR,
                    '-',@SUBJNBR,
                    '-',@FUNC,
                    '-',@SEQ,
                    '-',@CONFLTR,
                        @VARNBR)"/>
               <xsl:text>)</xsl:text>
			  
            </xsl:when>
            <xsl:when test="name() = 'INTRO'">
               <xsl:text>INTRODUCTION</xsl:text>
            </xsl:when>
            <!-- If this is a REFINT to a graphic or sheet, call the template as if it were -->
            <!-- A GRPHCREF -->
            <!-- <xsl:when test="(name() = 'GRAPHIC') or (name() = 'SHEET') ">
               <xsl:call-template name="grphcref"/>
            </xsl:when> -->
            <xsl:when test="name() = 'SUBJECT'">
                <!-- Link needs to point to the key of the first pgblk. -->
                <xsl:attribute name="internal-destination"><xsl:value-of select="child::PGBLK[1]/@KEY"/></xsl:attribute>
                <xsl:value-of select="@CHAPNBR"/>-<xsl:value-of select="@SECTNBR"/>-<xsl:value-of select="@SUBJNBR"/>
            </xsl:when>
           <xsl:when test="name() = 'IPL'">
             <xsl:attribute name="internal-destination"><xsl:value-of select="@KEY"/></xsl:attribute>
             <xsl:value-of select="TITLE"/>
             <xsl:text> (IPL </xsl:text>
             <xsl:value-of select="concat(@CHAPNBR,
               '-',@SECTNBR,
               '-',@SUBJNBR,
               '-',@PGBLKNBR)"/>
             <xsl:text>)</xsl:text>
           </xsl:when>
           <xsl:when test="name() = 'VENDLIST'">
             <xsl:attribute name="internal-destination"><xsl:value-of select="@KEY"/></xsl:attribute>
             <xsl:value-of select="TITLE"/>
           </xsl:when>
           <xsl:when test="name() = 'FIGURE'">
             <xsl:attribute name="internal-destination"><xsl:value-of select="GRAPHIC[1]/SHEET[1]/@KEY"/></xsl:attribute>
             <xsl:text>IPL Figure </xsl:text><xsl:value-of select="@FIGNBR"/>
           </xsl:when>
           <xsl:otherwise>
               <xsl:message>[error] [[!!! REFERENCE TO UNHANDLED LOCATION !!!]] (REFID: <xsl:value-of select="$refId"/>)</xsl:message>
               <fo:inline color="red">[[!!! REFERENCE TO UNHANDLED LOCATION !!!]]
               	(name: <xsl:value-of select="name()"/>; specifiedText: <xsl:value-of select="$specifiedText"/></fo:inline>
            </xsl:otherwise>
         </xsl:choose>
      </fo:basic-link>
   </xsl:template>

   <!-- figureRef: construct the figure reference (based on ATA template match="GRPHCREF" name="grphcref") -->
   <!-- The figure is the context node. -->
   <xsl:template name="figureRef">
      <xsl:param name="refId"/>
      <!-- Store the referenced element in a variable so we don't need to search for it by ID more than once. -->
      <!-- For some reason this was matching more than one element... use the first match for now, but may need to -->
      <!-- sort out the underlying cause later... -->
      <!-- Ok, it was multiple IDs being passed. -->
      <!-- <xsl:variable name="referencedElement" select="(/pm/content//*[self::graphic or self::figure][@id = $refId])[1]"/> -->
      <xsl:variable name="referencedElement" select="/pm/content//*[self::graphic or self::figure][@id = $refId]"/>
      <!-- <xsl:message>Constructing figure reference for figure id <xsl:value-of select="string-join($refId, ',')"/>. Num matches: <xsl:value-of select="count($referencedElement)"/>; Figure title: <xsl:value-of select="$referencedElement/title"/></xsl:message> -->
      <xsl:variable name="captionRef">
         <xsl:choose>
            <!-- If this links to a graphic, then use the id of the caption -->
            <xsl:when test="name($referencedElement)='graphic'"><!-- //graphic[@id = $refId] -->
               <xsl:value-of select="concat('figcap_',$refId)"/><!-- @REFID -->
            </xsl:when>
            <!-- Otherwise link to the first sheet (here the referenced element must be a figure) -->
            <xsl:otherwise>
               <!-- <xsl:for-each select="//figure[@id = $refId]"> -->
                  <xsl:value-of select="concat('figcap_',$referencedElement/graphic[1]/@id)"/>
               <!-- </xsl:for-each> -->
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
     <fo:basic-link internal-destination="{$captionRef}"><!-- color="#0000ff"-->
         <xsl:if test="number($DEBUG) = 1">
            <xsl:attribute name="id">
               <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
         </xsl:if>
         <!--  <xsl:variable name="figure" select="//figure[@id = $refId][1]"/>
         <xsl:variable name="graphic" select="//graphic[@id = $refId][1]"/>-->
         <xsl:choose>
            <xsl:when test="name($referencedElement)='figure'">
               <xsl:if test="$referencedElement/ancestor::illustratedPartsCatalog">
               	<xsl:text>DPL </xsl:text>
               </xsl:if>
               <xsl:text>Figure </xsl:text>
               
               <!-- <xsl:for-each select="$figure">[!++ Uses for-each to put the figure node in context for calc-figure-number ++]
                  <xsl:call-template name="calc-figure-number"/>
               </xsl:for-each>-->
               
			  	<!-- DEBUG: <xsl:if test="ends-with($refId, 'fig-001')">
			  		<xsl:message>Calling calc-figure-number-param for refId <xsl:value-of select="$refId"/>. Result:
					  	<xsl:call-template name="calc-figure-number-param">
					  		<xsl:with-param name="figure" select="$referencedElement"/>
					  	</xsl:call-template>
			  		</xsl:message>
			  	</xsl:if> -->
			  	
			  	<xsl:call-template name="calc-figure-number-param">
			  		<xsl:with-param name="figure" select="$referencedElement"/>
			  	</xsl:call-template>
			  	               
               <!-- START ADDED PER MANTIS #0012021 -->
               <!-- REMOVED PER UPDATED EM REQUIREMENTS
          <xsl:value-of select="concat(' (GRAPHIC ', //GRAPHIC[@KEY = $ref]/@CHAPNBR, 
            '-', //GRAPHIC[@KEY = $ref]/@SECTNBR, 
            '-', //GRAPHIC[@KEY = $ref]/@SUBJNBR, 
            '-', //GRAPHIC[@KEY = $ref]/@FUNC,
            '-', //GRAPHIC[@KEY = $ref]/@SEQ,
            '-', //GRAPHIC[@KEY = $ref]/@CONFLTR,//GRAPHIC[@KEY = $ref]/@VARNBR,')')"/>
          -->
               <!-- END ADDED PER MANTIS #0012021 -->
            </xsl:when>
            <xsl:when test="name($referencedElement)='graphic'">
               <xsl:if test="$referencedElement/ancestor::illustratedPartsCatalog">
               	<xsl:text>DPL </xsl:text>
               </xsl:if>
               <xsl:text>Figure </xsl:text>
               <!-- <xsl:for-each select="$graphic">
                  <xsl:call-template name="calc-figure-number"/> -->
                  
			  	  <xsl:call-template name="calc-figure-number-param">
			  		<xsl:with-param name="figure" select="$referencedElement"/>
			  	  </xsl:call-template>
			  	  
                  <xsl:text> (Sheet </xsl:text>
                  <xsl:value-of select="1 + count (./preceding-sibling::graphic)"/>
                  <xsl:text> of </xsl:text>
                  <xsl:value-of select="count (./preceding-sibling::graphic) + count (./following-sibling::graphic) + 1"/>
                  <xsl:text>)</xsl:text>
               <!-- </xsl:for-each> -->
            </xsl:when>
            <xsl:otherwise>
               <xsl:message>
                  <xsl:value-of select="concat('!!![[[ Unmatched figure/graphic reference, ID: ',$refId,']]]')"/>
               </xsl:message>
               <fo:inline color="red">
                 <xsl:value-of select="concat('!!![[[  Unmatched figure/graphic reference, ID: ',$refId,']]]')"/>
               </fo:inline>
            </xsl:otherwise>
         </xsl:choose>
      </fo:basic-link>
   </xsl:template>

   <xsl:template name="get-task-enumerator">
      <xsl:number value="1+count(ancestor-or-self::TASK/preceding-sibling::TASK)" format="1"/>
   </xsl:template>

   <xsl:template name="get-subtask-enumerator">
      <xsl:number value="1+ count(ancestor-or-self::SUBTASK/preceding-sibling::SUBTASK)" format="A"/>
   </xsl:template>

  <xsl:template name="get-irm-pn">
    <xsl:choose>
      <xsl:when test="/CMM/@CHAPNBR = '72' and /CMM/@SECTNBR = '00'">
        <xsl:choose>
          <xsl:when test="ancestor-or-self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) >= 1000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
            <!--<xsl:text>INSPECTION/CHECK, </xsl:text>-->
            <xsl:apply-templates select="TITLE" mode="refint"/>
            <xsl:text>, PN&#160;</xsl:text>
            <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
          </xsl:when>
          <xsl:when test="ancestor-or-self::PGBLK[@PGBLKNBR='6000'][number(@CONFNBR) >= 1000]/preceding-sibling::PGBLK[1][@PGBLKNBR='6000']">
            <!--<xsl:text>REPAIR, </xsl:text>-->
            <xsl:apply-templates select="TITLE" mode="refint"/>
            <xsl:text>, PN&#160;</xsl:text>
            <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="TITLE" mode="refint"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="ancestor-or-self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 1000][number(@CONFNBR) &lt; 2000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
            <!--<xsl:text>CONTINUE-TIME CHECK, </xsl:text>-->
            <xsl:apply-templates select="TITLE" mode="refint"/>
            <xsl:text>, PN&#160;</xsl:text>
            <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
          </xsl:when>
          <xsl:when test="ancestor-or-self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 2000][number(@CONFNBR) &lt; 3000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
            <!--<xsl:text>ZERO-TIME CHECK, </xsl:text>-->
            <xsl:apply-templates select="TITLE" mode="refint"/>
            <xsl:text>, PN&#160;</xsl:text>
            <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
          </xsl:when>
          <xsl:when test="ancestor-or-self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 3000][number(@CONFNBR) &lt; 4000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
            <!--<xsl:text>CHECK, </xsl:text>-->
            <xsl:apply-templates select="TITLE" mode="refint"/>
            <xsl:text>, PN&#160;</xsl:text>
            <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
          </xsl:when>
          <xsl:when test="ancestor-or-self::PGBLK[@PGBLKNBR='6000'][number(@CONFNBR) >= 1000]/preceding-sibling::PGBLK[1][@PGBLKNBR='6000']">
            <!--<xsl:text>REPAIR, </xsl:text>-->
            <xsl:apply-templates select="TITLE" mode="refint"/>
            <xsl:text>, PN&#160;</xsl:text>
            <xsl:value-of select="ancestor-or-self::PGBLK/EFFECT"/>
          </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="TITLE" mode="refint"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
   <!-- Several dmRef contexts are suppressed -->
   <xsl:template match="dmRef[ancestor::catalogSeqNumber or parent::pmEntry or parent::reqCondDm]" priority="1">
   </xsl:template>
   
   <!-- Called with the link destination in context. -->
   <xsl:template name="pageblockRef">
   	<xsl:param name="dmodule"/>
   
    <xsl:choose>
    	<xsl:when test="$dmodule">
	     <!-- For dmRefs in non-EIPC documents, need to add the pageblock information (like "(PGBLK 72-10-00-5000)") -->
	     <xsl:variable name="pmEntryType" select="$dmodule/ancestor::pmEntry[@pmEntryType][1]/@pmEntryType"/>
	     
	     <!-- We don't need the page block for references to the Introduction or frontmatter -->
	     <!-- Also only used for the new PMC(?) -->
	     <xsl:if test="$isNewPmc and not($pmEntryType = ('pmt58','pmt52','pmt53','pmt54','pmt55','pmt56'))">
	        <!-- In the new PMC, the ATA Number is defined at the 3rd pmEntry level in the authorityDocument attribute -->
	     	<xsl:variable name="ataNo" select="$dmodule/ancestor::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument"/>
	     	<!-- And the page block is found at the 4th-level pmEntry in the startat attribute (with one added) -->
	     	<xsl:variable name="pageBlock" select="$dmodule/ancestor::pmEntry[count(ancestor::pmEntry)=3]/@startat"/>
	     	<xsl:variable name="pageBlockNormalized">
	     		<xsl:choose>
	     			<xsl:when test="number($pageBlock)">
	     				<xsl:value-of select="number($pageBlock) - 1"/>
	     			</xsl:when>
	     			<xsl:otherwise><!-- Not sure what to do in this case... -->
	     				<xsl:value-of select="$pageBlock"/>
	     			</xsl:otherwise>
	     		</xsl:choose>
	     	</xsl:variable>
	     	<xsl:text> (PGBLK </xsl:text>
	     	<xsl:value-of select="$ataNo"/>
	     	<xsl:text>-</xsl:text>
	     	<xsl:value-of select="$pageBlockNormalized"/>
	     	<xsl:text>)</xsl:text>
	     </xsl:if>
    	</xsl:when>
    	<xsl:otherwise>
    		<xsl:message>WARNING: pageblockRef called with a non-node dmodule parameter.</xsl:message>
    	</xsl:otherwise>
    </xsl:choose>
   </xsl:template>
   
   <xsl:template match="dmRef">
     <xsl:variable name="refId">
       <xsl:call-template name="build-dmCode-refId">
         <xsl:with-param name="dmCode" select="dmRefIdent/dmCode"/>
       </xsl:call-template>
     </xsl:variable>
     
     <xsl:choose>
        <!-- When there is a referredFragment, it is a link to an element within another DM. -->
     	<xsl:when test="@referredFragment">
	      <xsl:variable name="fragId" select="@referredFragment"/>
	      <xsl:variable name="authorityName" select="@authorityName"/>
	      
	      <!-- From Styler (Property set Set_referredFragment): -->
	      
	      <!-- Find the ID of the referredFragment: the PMC processing script that produces a combined -->
	      <!-- file changes the IDs so they are unique across the final document. We need to look for -->
	      <!-- an ID in the appropriate DM that ends with the original ID we're looking for. -->
	      <!-- So construct an XPath to do that search, and return the new ID we should be using. -->
	      
	      <!-- That is, the ID on the object will look like '<figure id="DMC-d1e15594-pgblk101figure101sheet1">', -->
	      <!-- and the last part is the referredFragment attribute. -->
	      
	      <xsl:variable name="finalId" select="/pm/content//dmodule[@id = $refId]//@id[ends-with(., $fragId)]"/>
          <xsl:choose>
	          <xsl:when test="$finalId">
	            <xsl:for-each select="/pm/content//dmodule[@id = $refId]//*[@id = $finalId]">
	               <!-- <xsl:if test="$fragId='fig-001'">
	               	<xsl:message>Building dmRef link for referred fragment 'fig-001' (final ID: <xsl:value-of select="$finalId"/>)</xsl:message>
	               </xsl:if> -->
	               <xsl:call-template name="build-refint-link">
	                  <xsl:with-param name="specifiedText" select="$authorityName"/>
	                  <xsl:with-param name="refId" select="$finalId"/>
	                  <!-- <xsl:with-param name="debugId" select="$debugId"/> -->
	               </xsl:call-template>
	            </xsl:for-each>
	          </xsl:when>
	         <xsl:otherwise>
	            <fo:inline color="red"><xsl:value-of select="concat('[[[ Unmatched dmRef referredFragment=',$fragId,']]]')"/></fo:inline>
	            <xsl:message>
	               <xsl:value-of select="concat('[error] [[[ Unmatched dmRef referredFragment=',$fragId,']]]')"/>
	            </xsl:message>
	         </xsl:otherwise>
          </xsl:choose>
     	</xsl:when>
     	<xsl:otherwise>
		 <!-- Regular dmRef (possibly with authorityName to use as text instead of the dmTitle/infoName) -->     	 
	     <fo:basic-link internal-destination="{$refId}" color="blue">
	       <xsl:variable name="dmodule" select="/pm/content//dmodule[@id=$refId]"/>
	       <xsl:choose>
	         <xsl:when test="@authorityName">
	           <xsl:value-of select="@authorityName"/>
	           <xsl:choose>
	           	<xsl:when test="substring(@authorityName,1,9)='Paragraph'">
	           	  <!-- The target dmodule needs to be in context for template subtaskRef -->
	           	  <!-- <xsl:message>Subtask paragraph reference found: calling subtaskRef</xsl:message> -->
	           	  <xsl:variable name="authorityName" select="@authorityName"/>
	           	  <xsl:for-each select="$dmodule">
	           	   <!-- <xsl:message>Calling subtaskRef with dmodule in context</xsl:message> -->
	               <xsl:call-template name="subtaskRef">
	               	<xsl:with-param name="specifiedText" select="$authorityName"/>
	               </xsl:call-template>
	              </xsl:for-each>
	           	</xsl:when>
	           	<xsl:otherwise>
		           <xsl:call-template name="pageblockRef">
	               	<xsl:with-param name="dmodule" select="$dmodule"/>
	               </xsl:call-template>
	           	</xsl:otherwise>
	           </xsl:choose>
	         </xsl:when>
	         <xsl:otherwise>
	           <xsl:value-of select="$dmodule/identAndStatusSection/dmAddress/dmAddressItems/dmTitle/infoName"/>
	           <xsl:if test="$dmodule/ancestor::pmEntry/@confnbr">
	           	<xsl:text>-</xsl:text>
	           	<xsl:value-of select="$dmodule/ancestor::pmEntry/@confnbr"/>
	           </xsl:if>
	           <xsl:call-template name="pageblockRef">
	           	<xsl:with-param name="dmodule" select="$dmodule"/>
	           </xsl:call-template>
	           <!-- <xsl:text> [refId: </xsl:text><xsl:value-of select="$refId"/><xsl:text>]</xsl:text> -->
	         </xsl:otherwise>
	       </xsl:choose>
	     </fo:basic-link>
     	</xsl:otherwise>
     </xsl:choose>
   </xsl:template>
   
   <!-- Given the dmCode element as a parameter, construct the full module code, like "S1000DBIKE-AAA-A0-10-20-00AA-362B-A" -->
   <xsl:template name="build-dmCode-refId">
     <xsl:param name="dmCode"/>
     
     <xsl:value-of select="$dmCode/@modelIdentCode"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@systemDiffCode"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@systemCode"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@subSystemCode"/>
     <xsl:value-of select="$dmCode/@subSubSystemCode"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@assyCode"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@disassyCode"/>
     <xsl:value-of select="$dmCode/@disassyCodeVariant"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@infoCode"/>
     <xsl:value-of select="$dmCode/@infoCodeVariant"/>
     <xsl:text>-</xsl:text>
     <xsl:value-of select="$dmCode/@itemLocationCode"/>
     
   </xsl:template>
   
   <xsl:template match="GRPHCREF" name="grphcref">
      <xsl:variable name="ref" select="@REFID"/>
      <xsl:variable name="captionRef">
         <xsl:choose>
            <!-- If this links to a sheet, then use the id of the caption -->
            <xsl:when test="//SHEET[@KEY = $ref]">
               <xsl:value-of select="concat('figcap_',@REFID)"/>
            </xsl:when>
            <!-- Other wise link to the first sheet -->
            <xsl:otherwise>
               <xsl:for-each select="//GRAPHIC[@KEY = $ref]">
                  <xsl:value-of select="concat('figcap_',SHEET[1]/@KEY)"/>
               </xsl:for-each>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
     <fo:basic-link internal-destination="{$captionRef}"><!-- color="#0000ff"-->
         <xsl:if test="number($DEBUG) = 1">
            <xsl:attribute name="id">
               <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:choose>
            <xsl:when test="//GRAPHIC[@KEY = $ref]">
               <xsl:text>Figure </xsl:text>
               <xsl:for-each select="//GRAPHIC[@KEY = $ref]">
                  <xsl:call-template name="calc-figure-number"/>
               </xsl:for-each>
               <!-- START ADDED PER MANTIS #0012021 -->
               <!-- REMOVED PER UPDATED EM REQUIREMENTS
          <xsl:value-of select="concat(' (GRAPHIC ', //GRAPHIC[@KEY = $ref]/@CHAPNBR, 
            '-', //GRAPHIC[@KEY = $ref]/@SECTNBR, 
            '-', //GRAPHIC[@KEY = $ref]/@SUBJNBR, 
            '-', //GRAPHIC[@KEY = $ref]/@FUNC,
            '-', //GRAPHIC[@KEY = $ref]/@SEQ,
            '-', //GRAPHIC[@KEY = $ref]/@CONFLTR,//GRAPHIC[@KEY = $ref]/@VARNBR,')')"/>
          -->
               <!-- END ADDED PER MANTIS #0012021 -->
            </xsl:when>
            <xsl:when test="//SHEET[@KEY = $ref]">
               <xsl:text>Figure </xsl:text>
               <xsl:for-each select="//SHEET[@KEY = $ref]">
                  <xsl:call-template name="calc-figure-number"/>
                  <xsl:text> (Sheet </xsl:text>
                  <xsl:value-of select="1 + count (./preceding-sibling::SHEET)"/>
                  <xsl:text> of </xsl:text>
                  <xsl:value-of select="count (./preceding-sibling::SHEET) + count (./following-sibling::SHEET) + 1"/>
                  <xsl:text>)</xsl:text>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message>
                  <xsl:value-of select="concat('!!![[[ Unmatched GRPHCREF=',$ref,']]]')"/>
               </xsl:message>
               <xsl:value-of select="concat('!!![[[ Unmatched GRPHCREF=',$ref,']]]')"/>
            </xsl:otherwise>
         </xsl:choose>
      </fo:basic-link>
   </xsl:template>

   <xsl:template match="PGBLK/TITLE" mode="refint">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="TASK/TITLE" mode="refint">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="SUBTASK/TITLE" mode="refint">
      <xsl:apply-templates/>
   </xsl:template>

</xsl:stylesheet>
