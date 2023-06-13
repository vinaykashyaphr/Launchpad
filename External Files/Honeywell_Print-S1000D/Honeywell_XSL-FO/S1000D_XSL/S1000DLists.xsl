<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:rx="http://www.renderx.com/XSL/Extensions">

<!-- Module to handle levelledPara and proceduralStep numbering and indenting based on original -->
<!-- "newLists.xsl", which handled PRCLIST[N] and LIST[N] for ATA docs. -->

 <xsl:template match="mainProcedure">
    <xsl:call-template name="check-rev-start"/>
    <xsl:apply-templates/>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>

<!-- There is no equivaluent to the PRCITEM[N] wrappers in S1000D, just proceduralSteps within mainProcedure -->
<!--  <xsl:template match="PRCITEM1|PRCITEM2|PRCITEM3|PRCITEM4|PRCITEM5|PRCITEM6|PRCITEM7">
    <xsl:apply-templates />
  </xsl:template>-->

  <xsl:template match="proceduralStep">
    
    <xsl:variable name="currentIndent">
        <xsl:call-template name="calc-proclist-indent"/>
    </xsl:variable>
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
        <xsl:call-template name="get-proclist-decoration"/>  
    </xsl:variable>
    
    <xsl:variable name="childList">
      <!--  Check for child prclist so that we can keep-with on page.  -->
      <xsl:choose>
        <xsl:when test="child::proceduralStep">
          <xsl:value-of select="child::proceduralStep"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'none'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
	<!-- Also add a change bar if an updated para is the first element inside. -->
	<!-- RS: This seems to generate extra change bars, since the contents also generate them... -->
	<!-- 
	<xsl:if test="@changeType='add' or @changeType='modify' or @changeType='delete'
	  or para[count(preceding-sibling::*)=0][@changeType='add' or @changeType='modify' or @changeType='delete']">
		<xsl:call-template name="cbStart" />
		<xsl:comment>Change bar added for childList</xsl:comment>
	</xsl:if>-->
		
    <fo:block>
      <xsl:if test="@id">
        <xsl:attribute name="id" select="@id"/>
      </xsl:if>
      <!-- If the change bar is output here, it might start too early (e.g., if the enclosed list block -->
      <!-- is pushed to a new page, the change bar here will start on the previous page). So I moved the -->
      <!-- change bars to the individual items within the proceduralStep, which are each enclosed in -->
      <!-- a list block. -->
	  <!-- <xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbStart" />
	  </xsl:if> -->
	  
	  <xsl:for-each select="child::*">
        <xsl:call-template name="output-prclist-item">
          <xsl:with-param name="formattedNumber" select="$formattedNumber"/>
          <xsl:with-param name="textDecoration" select="$textDecoration" />
          <xsl:with-param name="currentIndent" select="$currentIndent" />
          <xsl:with-param name="childList" select="$childList"/>
        </xsl:call-template>
      </xsl:for-each>
	  
	  <!-- <xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbEnd" />
	  </xsl:if> -->

    </fo:block>
    
  </xsl:template>

  <xsl:template name="output-prclist-item">
    <xsl:param name="formattedNumber" select="''"/>
    <xsl:param name="textDecoration" select="'none'"/>
    <xsl:param name="currentIndent" select="'0pt'"/>
    <xsl:param name="childList" select="'none'"/>
    <xsl:choose>
    	<!-- Handle nested proceduralSteps separately -->
    	<xsl:when test="name()='proceduralStep'">
    		<xsl:apply-templates select='.'/>
    	</xsl:when>
    	<xsl:otherwise>
    		<xsl:variable name="proceduralStepChange" select="not(parent::proceduralStep/@changeMark='0') and
					  (parent::proceduralStep/@changeType='add' or parent::proceduralStep/@changeType='modify'
					  or parent::proceduralStep/@changeType='delete')"/>
		    <fo:list-block xsl:use-attribute-sets="list.vertical.space"
		      provisional-distance-between-starts="0.5in"><!-- keep-together.within-page="always" provisional-distance-between-starts="24pt"-->
		      <xsl:if test="name() != 'TABLE'">
		        <xsl:attribute name="margin-left">
		          <xsl:value-of select="$currentIndent"/>
		        </xsl:attribute>
		      </xsl:if>
		      
		      <!-- This keep seems a bit odd; I guess it keeps proceduralStep content together with any child proceduralStep. -->
		      <xsl:if test="$childList != 'none' and name() != 'table'">
		        <xsl:attribute name="keep-with-next.within-page">
		          <xsl:value-of select="'always'"/>
		        </xsl:attribute>
		      </xsl:if>
		      
		      <!-- If it's the last proceduralStep, and there are no nested proceduralSteps, keep with previous so that -->
		      <!-- the last item doesn't appear on its own. -->
		      <!-- Exception: if it has multiple nodes (paras, etc.) -->
		      <xsl:if test="not(self::table) and not(self::figure)
		        and count(ancestor-or-self::proceduralStep[1]/following-sibling::*) = 0
		        and count(ancestor-or-self::proceduralStep[1]/descendant::proceduralStep) = 0
		        and count(ancestor-or-self::proceduralStep[1]/*) &lt; 2
		        ">
		        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
		      </xsl:if>
		      
		      <fo:list-item>
					<!-- Don't output change bars for figures; they do that themselves -->		
					<xsl:if test="$proceduralStepChange or (name() != 'figure' and not(@changeMark='0') and
					  (@changeType='add' or @changeType='modify' or @changeType='delete'))">
						<xsl:call-template name="cbStart" />
						<xsl:comment>Change start for output-prclist-item</xsl:comment>
					</xsl:if>
			
		        <fo:list-item-label end-indent="label-end()">
		          <fo:block>
		            <xsl:attribute name="text-decoration">
		              <xsl:value-of select="$textDecoration"/>
		            </xsl:attribute>
					<xsl:if test="name() = 'title'">
		                <xsl:attribute name="font-weight" select="'bold'"/>
					</xsl:if>
			
		            <xsl:choose>
		              <xsl:when test="name() = 'title'">
		                <xsl:value-of select="$formattedNumber"/>
		              </xsl:when>
		              <xsl:when test="name()='para' and count(preceding-sibling::*) = 0"><!-- *[self::para or self::title] -->
		                <xsl:value-of select="$formattedNumber"/>
		              </xsl:when>
		              <xsl:when test="name()='note' and count(preceding-sibling::*) = 0"><!-- *[self::para or self::title] -->
		                <xsl:value-of select="$formattedNumber"/>
		              </xsl:when>
		              <xsl:when test="name()='warning' and count(preceding-sibling::*) = 0">
		                <xsl:value-of select="$formattedNumber"/>
		              </xsl:when>
		              <xsl:otherwise>
		                <xsl:text></xsl:text>
		              </xsl:otherwise>
		            </xsl:choose>
		          </fo:block>
		          
		        </fo:list-item-label>
		        <fo:list-item-body start-indent="body-start()">
		          <fo:block>
		            <xsl:apply-templates select="." />
		          </fo:block>
		        </fo:list-item-body>
					<xsl:if test="$proceduralStepChange or (name() != 'figure' and not(@changeMark='0') and 
					  (@changeType='add' or @changeType='modify' or @changeType='delete'))">
						<xsl:call-template name="cbEnd" />
						<xsl:comment>Change end for output-prclist-item</xsl:comment>
					</xsl:if>
		      </fo:list-item>
		    </fo:list-block>
			<!-- <xsl:if test="@changeType='add' or @changeType='modify' or @changeType='delete'">
				<xsl:call-template name="cbEnd" />
			</xsl:if> -->
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

	<xsl:template match="proceduralStep/title">
		<fo:block font-weight="bold" font-size="10pt" 
			 keep-with-next.within-page="always"> <!-- space-before="{$normalParaSpace}" space-after="{$normalParaSpace}" -->
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>
			<xsl:apply-templates />
			<!-- Add Subtask for 1st-level proceduralStepTitles -->
			<xsl:if test="count(ancestor::proceduralStep)=1">
	            <fo:inline font-weight="normal" text-decoration="none" >
		          <xsl:text>&#xA0;</xsl:text>
	              <xsl:call-template name="get-mtoss"/>
	            </fo:inline>
			</xsl:if>
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>
		</fo:block>
	</xsl:template>

  <!-- Special case for front-matter levelledPara (not in a level 2 pmEntry - from Styler context). -->
  <!-- UPDATE: Add explicit check for being before the introduction, since especially for "Not applicable" -->
  <!-- sections, you can have levelledParas in the top-level pmEntry. -->
  <!-- Just process as normal, and let the nested paras handle any details. -->
  <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
    <!-- 2020-10-28 Update Start -->
  <xsl:template match="levelledPara[ not(count(ancestor::pmEntry) = 2) and 
    (ancestor::pmEntry[last()]/@isFrontmatter='1'
    or ancestor::pmEntry/following-sibling::pmEntry/@pmEntryType='pmt58')
    ]">
    <!--  or ancestor::pmEntry/following-sibling::pmEntry/@pmEntryType='pmt91' -->
  <!-- <xsl:template match="levelledPara[ not(count(ancestor::pmEntry) = 2) and 
    (ancestor::pmEntry[last()]/@isFrontmatter='1')
    ]"> -->
    

    <xsl:choose>
      <xsl:when test="contains(translate((ancestor-or-self::levelledPara/title), $upperCase,$lowerCase), 'honeywell materials license agreement')">

      </xsl:when>

      <xsl:when test="contains(translate((ancestor-or-self::levelledPara/title), $upperCase,$lowerCase), 'confidential')">
        <fo:block>
        <xsl:apply-templates/>
        </fo:block>
        <fo:block>

        <fo:block text-align="center" font-weight="bold" font-size="13pt" space-after="10pt" space-before="6pt" keep-with-next.within-page="always">HONEYWELL MATERIALS LICENSE AGREEMENT</fo:block>
        <fo:block keep-together.within-page="4">This document and the information contained herein (“the Materials”) are the proprietary data of Honeywell. These Materials are provided for the exclusive use of Honeywell-authorized Service Centers; Honeywell-authorized repair facilities; owners of a Honeywell aerospace product that is the subject of these Materials (“Honeywell Product”) that have entered into a written agreement with Honeywell relating to the repair or maintenance of Honeywell Product; and direct recipients of Materials from Honeywell via https://aerospace.honeywell.com/en/learn/about-us/about-myaerospace that own a Honeywell Product. The terms and conditions of this Honeywell Materials License Agreement (“License Agreement”) govern your use of these Materials, except to the extent that any terms and conditions of another applicable agreement with Honeywell regarding the maintenance or repair of a Honeywell Product and that is the subject of the Materials conflict with the terms and conditions of this License Agreement, in which case the terms and conditions of the other agreement will govern. The terms of this License Agreement supersede any other Material License Agreement previously provided with the Materials, regardless of what form the Materials were provided, including without limitation when received in hard copy, downloaded via the MyAerospace portal or CD-ROM. However, this License Agreement will govern in the event of a conflict between these terms and conditions and those of a purchase order or acknowledgement. Your access or use of the Materials represents your acceptance of the terms of this License Agreement.</fo:block>
        <fo:block space-before="10pt">1. License Grant - If you are a party to an applicable written agreement with Honeywell relating to the repair or maintenance of the subject Honeywell Product, subject to your compliance with the terms and conditions of this License Agreement, Honeywell hereby grants you, and you accept, a limited, personal, non-transferrable, non-exclusive license to use these Materials only in accordance with that agreement.</fo:block>
        <fo:block space-before="10pt">If you are a direct recipient of these Materials from Honeywell’s MyAerospace Technical Publication website and are not a party to an agreement related to the maintenance or repair of the subject Honeywell Product, subject to your compliance with the terms and conditions of this License Agreement, Honeywell hereby grants you, and you accept, a limited, personal, non-transferrable, non-exclusive license to use a single copy of these Materials to maintain or repair only the subject Honeywell Product installed or intended to be installed on the aircraft you own and/or operate and only at the facility to which these Materials have been shipped (“the Licensed Facility”). Transfer of the Materials to another facility owned by you is permitted only if the original Licensed Facility retains no copies of the Materials, the transferee accepts all of your obligations and liabilities under this License Agreement, and you provide prior written notice to Honeywell with the name and address of the transferee. You agree not to use these Materials for commercial purposes.</fo:block>
        <fo:block space-before="10pt">2. Restrictions on Use - You may not sell, rent, lease, or (except as authorized under any applicable airworthiness authority regulation) lend the Materials to anyone for any purpose. You may not use the Materials to reverse engineer any Honeywell product, hardware or software, and may not decompile or disassemble software provided under this License Agreement, except and only to the extent that such activity is expressly permitted by applicable law notwithstanding this limitation. You may not create derivative works or modify the Materials in any way. You agree that Materials shall only be used for the purpose of the rights granted herein. The Material furnished hereunder may be subject to U.S. export regulations. You will adhere to all U.S. export regulations as published and released from time to time by the U.S. Government. You may not design or manufacture a Honeywell part or detail of a Honeywell part, to create a repair for a Honeywell part, design or manufacture any part that is similar or identical to a Honeywell part, compare a Honeywell part or design of a Honeywell part to another part design, or apply for FAA PMA or other domestic or foreign governmental approval to manufacture or repair a Honeywell part. Honeywell International Inc. and its affiliates comply fully with all applicable export control laws and regulations of the United States and of all countries where it conducts business. In order to satisfy US export control laws, you confirm that you are not an entity that meets the definition of a military end user in China, Russia, or Venezuela (“Military End User”) or sells items that support or contribute to a Military End Use by a Military End User. Military End User includes any entity that is part of the national armed services (army, navy, marine, air force, or coast guard), as well as the national guard and national police, government intelligence or reconnaissance organizations, or any person or entity whose actions or functions are intended to support “military end uses.” “Military End Uses” includes use of an item to support or contribute to the operation, installation, maintenance, repair, overhaul, refurbishing, development, or production of military items. In addition, you will not divert or in any way utilize or sell Honeywell products, materials, technology, or technical data to any entity that is a Chinese, Russian, or Venezuelan Military End User or for Military End Uses, as stated above. You shall immediately notify Honeywell and cease all activities associated with the transaction in question if it knows or has a reasonable suspicion that the products, materials, technical data, plans, or specifications may be exported, reexported, or transferred in support of a prohibited Military End Use or to a Military End User. Failure to comply with this provision is a material breach of your order and agreement with Honeywell and Honeywell is entitled to immediately seek all remedies available under law and in equity (including without limitation, termination), without any liability to Honeywell.</fo:block>
        <fo:block space-before="10pt">3. Rights In Materials - Honeywell retains all rights in these Materials and in any copies thereof that are not expressly granted to you, including all rights in patents, copyrights, trademarks, and trade secrets. The Materials are licensed and not sold under this License Agreement. No license to use any Honeywell trademarks or patents is granted under this License Agreement.</fo:block>
        <fo:block space-before="10pt">4. Changes - Honeywell reserves the right to change the terms and conditions of this License Agreement at any time, including the right to change or impose charges for continued use of the Materials. Honeywell may add, delete or otherwise modify any portion of the Materials (“Updated Materials”) at any time. You agree to stop using outdated Materials upon issuance of any Updated Materials.</fo:block>
        <fo:block space-before="10pt">5. Confidentiality - You acknowledge that these Materials contain information that is confidential and proprietary to Honeywell. You agree to take all reasonable efforts to maintain the confidentiality of these Materials.</fo:block>
        <fo:block space-before="10pt">6. Assignment and Transfer - This License Agreement may be assigned to a service center approved and formally designated as a service center by Honeywell, provided, however, that you retain no copies of the Materials in whole or in part. However, the recipient of any such assignment or transfer must assume all of your obligations and liabilities under this License Agreement. No assignment or transfer shall relieve any party of any obligation that such party then has hereunder. Otherwise, neither this License Agreement nor any rights, licenses or privileges granted under this License Agreement, nor any of its duties or obligations hereunder, nor any interest or proceeds in and to the Materials shall be assignable or transferable (in insolvency proceedings, by merger, by operation of law, by purchase, by change of control or otherwise) by you without Honeywell’s written consent.</fo:block>
        <fo:block space-before="10pt">7. Copies of Materials - Unless you have the express written permission of Honeywell, you may not make or permit making of copies, digital or printed, of the Materials. You agree to return the Materials and any such copies thereof to Honeywell upon the request of Honeywell.</fo:block>
        <fo:block space-before="10pt">8. Term - This License Agreement is effective until terminated as set forth herein. This License Agreement will terminate immediately, without notice from Honeywell, if you fail to comply with any provision of this License Agreement or will terminate simultaneously with the termination or expiration of your applicable agreement with Honeywell relating to the repair or maintenance of the subject Honeywell Product. Upon termination of this License Agreement, you will return these Materials to Honeywell without retaining any copies, in whole or in part, and will have one of your authorized officers certify that all Materials have been returned with no copies retained.</fo:block>
        <fo:block space-before="10pt">9. Audit Rights - Honeywell, through its authorized representatives, with no less than thirty (30) calendar days notice from Honeywell, has the right during normal business hours during the term of this License Agreement and for three (3) years thereafter to visit you and have access to the inside and outside of your facility for the purpose of inspecting, observing and evaluating your compliance under this License Agreement.</fo:block>
        <fo:block space-before="10pt">10. Remedies - Honeywell reserves the right to pursue all available remedies and damages resulting from a breach of this License Agreement.</fo:block>
        <fo:block space-before="10pt">11. Limitation of Liability - Honeywell makes no representations or warranties regarding the use or sufficiency of the Materials. THERE ARE NO OTHER WARRANTIES, WHETHER WRITTEN OR ORAL, EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO (i) WARRANTIES ARISING FROM COURSE OF PERFORMANCE, DEALING, USAGE, OR TRADE, WHICH ARE HEREBY EXPRESSLY DISCLAIMED, OR (ii) WARRANTIES AGAINST INFRINGEMENT OF INTELLECTUAL PROPERTY RIGHTS OF THIRD PARTIES, EVEN IF HONEYWELL HAS BEEN ADVISED OF ANY SUCH INFRINGEMENT. IN NO EVENT WILL HONEYWELL BE LIABLE FOR ANY INCIDENTAL DAMAGES, CONSEQUENTIAL DAMAGES, SPECIAL DAMAGES, INDIRECT DAMAGES, LOSS OF PROFITS, LOSS OF REVENUES, OR LOSS OF USE, EVEN IF INFORMED OF THE POSSIBILITY OF SUCH DAMAGES. TO THE EXTENT PERMITTED BY APPLICABLE LAW, THESE LIMITATIONS AND EXCLUSIONS WILL APPLY REGARDLESS OF WHETHER LIABILITY ARISES FROM BREACH OF CONTRACT, WARRANTY, INDEMNITY, TORT (INCLUDING BUT NOT LIMITED TO NEGLIGENCE), BY OPERATION OF LAW, OR OTHERWISE.</fo:block>
        <fo:block space-before="10pt">12. Controlling Law - This License Agreement shall be governed and construed in accordance with the laws of the State of New York without regard to the conflict of laws provisions thereof.</fo:block>
        <fo:block space-before="10pt">13. Severability - In the event any provision of this License Agreement is determined to be illegal, invalid, or unenforceable, the validity and enforceability of the remaining provisions of this License Agreement will not be affected and, in lieu of such illegal, invalid, or unenforceable provision, there will be added as part of this License Agreement one or more provisions as similar in terms as may be legal, valid and enforceable under controlling law.</fo:block>
        <fo:block space-before="10pt">14. Integration and Modification - This License Agreement sets forth the entire agreement and understanding between the parties on the subject matter of the License Agreement and merges all prior discussions and negotiations among them.</fo:block>

        </fo:block>

      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
    <!-- 2020-10-28 Update End -->

<!--  <xsl:template match="L1ITEM|L2ITEM|L3ITEM|L4ITEM|L5ITEM|L6ITEM|L7ITEM" name="list-item"> -->
  <xsl:template match="levelledPara">

    <!-- Variables for list position, numbering, indent, and text-decoration -->
    <xsl:variable name="currentIndent">
      <xsl:call-template name="calc-list-indent"/>
    </xsl:variable>

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
      <xsl:call-template name="get-levelledPara-decoration"/>
    </xsl:variable>

<!--    <xsl:if test="false()">
      <xsl:message>
        <xsl:value-of select="concat($listPosition,',',$formatString)"/>
      </xsl:message>
    </xsl:if>-->

    <!-- <xsl:call-template name="check-rev-start"/> -->
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbStart" />
	</xsl:if>

	  <!-- The keep rules are designed for simple levelledParas with a paragraph or two of content. -->
	  <!-- If there are many paras, figures, tables, etc., then we need to loosen the keep rules -->
	  <!-- so the complex content can flow from one page to the next easily. -->
	  <xsl:variable name="hasComplexContent">
	  	<xsl:choose>
	  		<xsl:when test="count(para) &gt; 2">
	  			<xsl:value-of select="true()"/>
	  		</xsl:when>
	  		<xsl:when test="table or figure or sequentialList or randomList or definitionList
	  		  or para/table or para/figure or para/sequentialList or para/randomList or para/definitionList">
	  			<xsl:value-of select="true()"/>
	  		</xsl:when>
	  		<!-- Also levelledParas with a lot of text should be considered "complex". -->
	  		<xsl:when test="string-length(.) &gt; 1000">
	  		</xsl:when>
	  		<xsl:otherwise>
	  			<xsl:value-of select="false()"/>
	  		</xsl:otherwise>
	  	</xsl:choose>
	  </xsl:variable>
	  		  
      <xsl:for-each select="node()"><!-- change * to node() to catch pagebreak PIs -->
        <xsl:choose>
          <xsl:when test="self::levelledPara">
          	<xsl:apply-templates select="self::node()"/>
          </xsl:when>
          
          <!-- Ignore text nodes (whitespace) directly in levelledPara -->
          <xsl:when test="self::text()">
          </xsl:when>
          
          <xsl:when test="self::processing-instruction()">
          	<xsl:apply-templates select="self::node()"/>
          </xsl:when>
          
          <xsl:when test="self::foldout">
          	<xsl:apply-templates select="self::node()"/>
          </xsl:when>
          
          <xsl:otherwise>

		    <fo:block>
	  		  <xsl:if test="self::*[position()=1] and parent::levelledPara/@id"><xsl:attribute name="id" select="parent::levelledPara/@id"/></xsl:if>
	  		  
			  <!-- Keep the list item together in usual cases... may need to refine condition(s) later -->
			  <xsl:if test="not($hasComplexContent)">
				 <xsl:attribute name="keep-together.within-page">4</xsl:attribute>
				</xsl:if>
				
		      <!-- If it's the first levelledPara, and there are no nested levelledParas, keep with previous so that -->
		      <!-- the first item doesn't appear on its own. -->
		      <!-- UPDATE: And if there isn't complex content (many paras, lists, tables, figures, etc.)  -->
		      <xsl:if test="parent::levelledPara[count(preceding-sibling::levelledPara) = 0]
		        and self::*[position()=1]
		        and count(parent::levelledPara/descendant::levelledPara) = 0
		        and not($hasComplexContent)">
		        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
		      </xsl:if>
		      
		      <!-- If it's the last levelledPara, and there are no nested levelledParas, keep with previous so that -->
		      <!-- the last item doesn't appear on its own. -->
		      <xsl:if test="not(self::table) and not(self::figure)
		        and count(ancestor-or-self::levelledPara[1]/following-sibling::*) = 0
		        and count(ancestor-or-self::levelledPara[1]/descendant::levelledPara) = 0
		        and not($hasComplexContent)">
		        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
		      </xsl:if>
		      
		      <!-- If it has nested levelledParas, keep with them. -->
		      <xsl:if test="count(preceding-sibling::*)=0 and not(self::table) and not(self::figure) and count(ancestor-or-self::levelledPara[1]/descendant::levelledPara) &gt; 0">
		        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
		      </xsl:if>
		      
		      <xsl:if test="@id">
		        <xsl:attribute name="id">
		          <xsl:value-of select="@id"/>
		        </xsl:attribute>
		      </xsl:if>
		      
		      <xsl:attribute name="margin-left">
		        <xsl:value-of select="$currentIndent"/>
		      </xsl:attribute>
				
				<!--  debug -->
				<!-- 
		      <xsl:if test="parent::levelledPara[count(preceding-sibling::levelledPara)=1] and position() = 1 and count(descendant::levelledPara) = 0">
		        <xsl:comment>Keep rule first levelledPara (self: <xsl:value-of select="name(.)"/>)</xsl:comment>
		      </xsl:if>
		      <xsl:if test="not(self::table) and not(self::figure)
		        and count(ancestor-or-self::levelledPara[1]/following-sibling::*) = 0
		        and count(descendant::levelledPara) = 0">
		        <xsl:comment>Keep rule last levelledPara (self: <xsl:value-of select="name(.)"/>)</xsl:comment>
		      </xsl:if> -->
		      
          	<xsl:choose>
	          <!-- <xsl:when test="name() = 'NOTE' and (preceding-sibling::LIST2
	            or preceding-sibling::LIST3 or preceding-sibling::LIST4 or 
	            preceding-sibling::LIST5 or preceding-sibling::LIST6 or 
	            preceding-sibling::LIST7)">
	            [!++ This is a note trailing a nested list, don't style here ++]
	          </xsl:when> -->
	          <xsl:when test="false()"/>
	          
	          <!-- Style everything excepted a nested list -->
	          <xsl:when test="self::* and not(name()='levelledPara')">
	            <xsl:call-template name="output-list-item">
	              <xsl:with-param name="formattedNumber" select=" $formattedNumber"/>
	              <xsl:with-param name="textDecoration" select=" $textDecoration"/>
	            </xsl:call-template>
	          </xsl:when>
          	</xsl:choose>
          	</fo:block>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      


    <!-- Style a nested list without creating a nested fo:block -->
    <!-- <xsl:apply-templates select="levelledPara"/> -->
    
    <!-- Pick up a trailing NOTE -->
    <!-- 
    <xsl:for-each select="*[name() = 'NOTE' and (preceding-sibling::LIST2
      or preceding-sibling::LIST3 or preceding-sibling::LIST4 or 
      preceding-sibling::LIST5 or preceding-sibling::LIST6 or 
      preceding-sibling::LIST7)]">
      <fo:block>
        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
        <xsl:attribute name="margin-left">
          <xsl:value-of select="$currentIndent"/>
        </xsl:attribute>
        <xsl:call-template name="output-list-item" />
      </fo:block>
    </xsl:for-each> -->
    
    <!-- <xsl:call-template name="check-rev-end"/> -->
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbEnd" />
	</xsl:if>

  </xsl:template>


  <xsl:template name="output-list-item">
    <xsl:param name="formattedNumber" select="''"/>
    <xsl:param name="textDecoration" select="'none'"/>
    	<!--  The change bar has to go outside the list block because we use an fo:block marker ("__revst__") -->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
	    <fo:list-block xsl:use-attribute-sets="list.vertical.space"
	      provisional-distance-between-starts="0.5in" space-before="6pt">
	      	<xsl:if test="name() = 'title'">
	      		<xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
	      	</xsl:if>
	      <!-- Handle list (levelledPara) numbering -->
	      <fo:list-item>
	        <fo:list-item-label end-indent="label-end()">
	          <fo:block>
	            <xsl:attribute name="text-decoration">
	              <xsl:value-of select="$textDecoration"/>
	            </xsl:attribute>
	            <xsl:choose>
	              <xsl:when test="name() = 'title'">
	                <xsl:attribute name="font-weight" select="'bold'"/>
	                <xsl:value-of select="$formattedNumber"/>
	              </xsl:when>
	              <xsl:when test="name()='para' and count(preceding-sibling::*[self::para or self::title]) = 0">
	                <xsl:value-of select="$formattedNumber"/>
	              </xsl:when>
	              <xsl:otherwise>
	                <xsl:text></xsl:text>
	              </xsl:otherwise>
	            </xsl:choose>
	          </fo:block>
	        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block>
            <xsl:choose>
              <xsl:when test="name() = 'title'">
                <xsl:attribute name="font-weight" select="'bold'"/>
                <xsl:attribute name="space-before" select="$normalParaSpace"/>
                <xsl:apply-templates/>
				<!-- Add Subtask for 1st-level levelledPara titles -->
				<xsl:if test="count(ancestor::levelledPara)=1">
		            <fo:inline font-weight="normal" text-decoration="none" >
			          <xsl:text>&#xA0;</xsl:text>
		              <xsl:call-template name="get-mtoss"/>
		            </fo:inline>
				</xsl:if>
              </xsl:when>
              <xsl:when test="name() = 'table'">
                <xsl:call-template name="table"/>
              </xsl:when>
              <xsl:when test="name() = 'figure'">
                <xsl:apply-templates select="."/>
              </xsl:when>
              <!-- [ATA] 
                <xsl:when test="name() = 'CAUTION'">
                <xsl:call-template name="caution"/>
              </xsl:when>
              <xsl:when test="name() = 'WARNING'">
                <xsl:call-template name="warning"/>
              </xsl:when>
              <xsl:when test="name() = 'NOTE'">
                <xsl:call-template name="note"/>
              </xsl:when> -->
              <xsl:otherwise>
		        <xsl:apply-templates select="." />
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbEnd" />
	</xsl:if>
  </xsl:template>


	<xsl:template match="randomList">
		<xsl:variable name="spaceBefore">
			<xsl:choose>
				<!-- From Styler: no extra space in table entries -->
				<xsl:when test="ancestor::entry">0pt</xsl:when>
				<xsl:otherwise>8pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="spaceAfter">
			<xsl:choose>
				<!-- From Styler: no extra space in table entries -->
				<xsl:when test="ancestor::entry">0pt</xsl:when>
				<xsl:otherwise><!-- From Styler: -->6pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
 	    <!-- <xsl:call-template name="check-rev-start"/>-->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
		
	      <fo:list-block provisional-distance-between-starts="15pt" space-before="{$spaceBefore}" space-after="{$spaceAfter}">
	        <!-- <xsl:attribute name="provisional-distance-between-starts">24pt</xsl:attribute> -->
	        <xsl:attribute name="provisional-label-separation">6pt</xsl:attribute>
	        <!-- <xsl:attribute name="margin-left"><xsl:value-of select="$indent"/></xsl:attribute> -->
	        <xsl:apply-templates/>
	      </fo:list-block>
	    <!-- <xsl:call-template name="check-rev-end"/> -->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
	</xsl:template>

	<xsl:template match="randomList/listItem">
		
		<xsl:variable name="listItemMarker">
			<xsl:choose>
				<xsl:when test="parent::randomList/@listItemPrefix = 'pf01'">
					<!-- nothing -->
				</xsl:when>
				<xsl:when test="parent::randomList/@listItemPrefix = 'pf02'">
					<xsl:choose>
						<xsl:when test="count(ancestor::randomList) mod 2 = 1">
							<xsl:text>- </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>• </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::randomList/@listItemPrefix = 'pf03'">
					<xsl:text>- </xsl:text>
				</xsl:when>
				<xsl:when test="parent::randomList/@listItemPrefix = 'pf07'">
					<xsl:text>• </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count(ancestor::randomList) mod 2 = 1">
							<xsl:text>- </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>• </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
	    <!-- <xsl:call-template name="check-rev-start"/> -->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
		
	    <fo:list-item space-before="6pt" space-after="0pt"><!-- xsl:use-attribute-sets="list.vertical.space" -->
		  
		  <xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
		  
	      <!-- If it's the last listItem, keep with previous so that -->
	      <!-- the last item doesn't appear on its own (as long as it's not the only listItem). -->
	      <xsl:if test="count(following-sibling::*) = 0 and count(preceding-sibling::*) &gt; 0">
	        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
	      </xsl:if>
	      <fo:list-item-label end-indent="label-end()">
	        <fo:block><xsl:value-of select="$listItemMarker"/></fo:block><!-- <xsl:text>– </xsl:text> -->
	      </fo:list-item-label>
	      <fo:list-item-body start-indent="body-start()">
	        <fo:block>
	          <xsl:apply-templates/>
	        </fo:block>
	      </fo:list-item-body>
	    </fo:list-item>
	    <!-- <xsl:call-template name="check-rev-end"/>-->
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
		
	</xsl:template>

	<xsl:template match="listItem/para | attentionListItemPara | attentionRandomListItemPara">
	
		<fo:block space-before="6pt" space-after="0pt">
			<xsl:if test="@id"><xsl:attribute name="id" select="@id"/></xsl:if>
			
			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
				<xsl:call-template name="cbStart" />
			</xsl:if>

			<xsl:apply-templates />

			<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
				<xsl:call-template name="cbEnd" />
			</xsl:if>
		</fo:block>

	</xsl:template>

	<xsl:template match="attentionSequentialList">
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
	    
	    <fo:list-block xsl:use-attribute-sets="list.vertical.space" space-before="4pt">
	        <xsl:attribute name="provisional-label-separation">6pt</xsl:attribute>
	        <xsl:choose>
	        	<!-- If it's after a notePara, need to outdent since we will be in the indent -->
	        	<!-- of the notePara. -->
	        	<!-- UPDATE: It looks better with no indent. -->
	        	<xsl:when test="parent::notePara">
			        <xsl:attribute name="margin-left">0in</xsl:attribute><!-- -0.5in -->
			        <xsl:attribute name="provisional-distance-between-starts">0.3in</xsl:attribute>
	        	</xsl:when>
	        	<!-- attentionSequential list numbering is slightly indented -->
	        	<xsl:otherwise>
			        <xsl:attribute name="margin-left">0.2in</xsl:attribute>
			        <xsl:attribute name="provisional-distance-between-starts">0.3in</xsl:attribute>
	        	</xsl:otherwise>
	        </xsl:choose>
	        <xsl:apply-templates/>
	    </fo:list-block>

		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="attentionSequentialListItem">
	    <xsl:variable name="formatString">
	      <xsl:call-template name="get-numlist-format-string"/>
	    </xsl:variable>
	    
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
	
	    <fo:list-item xsl:use-attribute-sets="list.vertical.space">
	      <fo:list-item-label end-indent="label-end()" font-weight="bold">
	        <fo:block><xsl:number format="{$formatString}"/></fo:block>
	      </fo:list-item-label>
	      <fo:list-item-body start-indent="body-start()">
	        <fo:block>
	          <xsl:apply-templates/>
	        </fo:block>
	      </fo:list-item-body>
	    </fo:list-item>
		
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="attentionRandomList">
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
	    
	    <fo:list-block xsl:use-attribute-sets="list.vertical.space" provisional-distance-between-starts="15pt" space-before="4pt">
	        <xsl:attribute name="provisional-label-separation">6pt</xsl:attribute>
	        <xsl:choose>
	        	<!-- If it's after a notePara, need to outdent since we will be in the indent -->
	        	<!-- of the notePara. -->
	        	<!-- UPDATE: It looks better with no indent. -->
	        	<xsl:when test="parent::notePara">
			        <xsl:attribute name="margin-left">0</xsl:attribute><!-- -0.5in -->
	        	</xsl:when>
	        	<xsl:otherwise>
			        <xsl:attribute name="margin-left">0.3in</xsl:attribute>
	        	</xsl:otherwise>
	        </xsl:choose>
	        <xsl:apply-templates/>
	    </fo:list-block>

		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="attentionRandomListItem">
	    <xsl:variable name="formatString">
	      <xsl:call-template name="get-numlist-format-string"/>
	    </xsl:variable>
	    
		<xsl:variable name="listItemMarker">
			<xsl:choose>
				<xsl:when test="parent::attentionRandomList/@listItemPrefix = 'pf01'">
					<!-- nothing -->
				</xsl:when>
				<xsl:when test="parent::attentionRandomList/@listItemPrefix = 'pf02'">
					<xsl:choose>
						<xsl:when test="count(ancestor::attentionRandomList) mod 2 = 1">
							<xsl:text>- </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>• </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::attentionRandomList/@listItemPrefix = 'pf03'">
					<xsl:text>- </xsl:text>
				</xsl:when>
				<xsl:when test="parent::attentionRandomList/@listItemPrefix = 'pf07'">
					<xsl:text>• </xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count(ancestor::attentionRandomList) mod 2 = 1">
							<xsl:text>- </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>• </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbStart" />
		</xsl:if>
	
	    <fo:list-item xsl:use-attribute-sets="list.vertical.space">
	      <fo:list-item-label end-indent="label-end()">
	        <fo:block><xsl:value-of select="$listItemMarker"/></fo:block><!-- <xsl:text>- </xsl:text> -->
	      </fo:list-item-label>
	      <fo:list-item-body start-indent="body-start()">
	        <fo:block>
	          <xsl:apply-templates/>
	        </fo:block>
	      </fo:list-item-body>
	    </fo:list-item>
		
		<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
			<xsl:call-template name="cbEnd" />
		</xsl:if>
	</xsl:template>

  <!-- Called with LxITEM in context -->
  <!-- These are in reverse order to match the lowest level -->
  <xsl:template name="calc-list-indent">
    <xsl:variable name="level" select="count(ancestor::levelledPara) + 1"/>
    
    <!-- For levelledParas in top-level pmEntries after the Introduction, use different indents (starting at 0) -->
    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
    <xsl:choose>
    	<xsl:when test="count(ancestor::pmEntry) = 1 and
    	  ( ancestor::pmEntry/preceding-sibling::pmEntry/@pmEntryType='pmt58'
    	  or ( not(ancestor::pmEntry[last()]/@isFrontmatter='1')
    	     and ancestor::pmEntry[last()]/preceding-sibling::pmEntry[@isFrontmatter='1'])
    	  )">
    	<!-- <xsl:when test="count(ancestor::pmEntry) = 1 and not(ancestor::pmEntry/@isFrontmatter='1') and not(ancestor::pmEntry/@pmEntryType='pmt58')"> -->
		    <xsl:choose>
		      <xsl:when test="$level = 8">3.5in</xsl:when>
		      <xsl:when test="$level = 7">3in</xsl:when>
		      <xsl:when test="$level = 6">2.5in</xsl:when>
		      <xsl:when test="$level = 5">2in</xsl:when>
		      <xsl:when test="$level = 4">1.5in</xsl:when>
		      <xsl:when test="$level = 3">1in</xsl:when>
		      <xsl:when test="$level = 2">0.5in</xsl:when>
		      <xsl:when test="$level = 1">0in</xsl:when>
		         
		      <xsl:otherwise>0pt</xsl:otherwise>
		    </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:choose>
		      <xsl:when test="$level = 7">3.5in</xsl:when>
		      <xsl:when test="$level = 6">3in</xsl:when>
		      <xsl:when test="$level = 5">2.5in</xsl:when>
		      <xsl:when test="$level = 4">2in</xsl:when>
		      <xsl:when test="$level = 3">1.5in</xsl:when>
		      <xsl:when test="$level = 2">1in</xsl:when>
		      <xsl:when test="$level = 1">0.5in</xsl:when>
		   
		      <xsl:otherwise>0pt</xsl:otherwise>
		    </xsl:choose>
		</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calc-proclist-indent">
    <xsl:variable name="level" select="count(ancestor::proceduralStep) + 1"/>
    <!-- For proceduralSteps in top-level pmEntries after the Introduction, use different indents (starting at 0) -->
    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
    <xsl:choose>
    	<xsl:when test="count(ancestor::pmEntry) = 1 and
    	  ( ancestor::pmEntry/preceding-sibling::pmEntry/@pmEntryType='pmt58'
    	  or ( not(ancestor::pmEntry[last()]/@isFrontmatter='1')
    	     and ancestor::pmEntry[last()]/preceding-sibling::pmEntry[@isFrontmatter='1'])
    	  )">    	 
    	<!-- <xsl:when test="count(ancestor::pmEntry) = 1 and not(ancestor::pmEntry/@isFrontmatter='1') and not(ancestor::pmEntry/@pmEntryType='pmt58')"> -->
		    <xsl:choose>
		      <xsl:when test="$level = 8">3.5in</xsl:when>
		      <xsl:when test="$level = 7">3in</xsl:when>
		      <xsl:when test="$level = 6">2.5in</xsl:when>
		      <xsl:when test="$level = 5">2in</xsl:when>
		      <xsl:when test="$level = 4">1.5in</xsl:when>
		      <xsl:when test="$level = 3">1in</xsl:when>
		      <xsl:when test="$level = 2">0.5in</xsl:when>
		      <xsl:when test="$level = 1">0in</xsl:when>
		         
		      <xsl:otherwise>0pt</xsl:otherwise>
		    </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:choose>
		      <xsl:when test="$level = 7">3.5in</xsl:when>
		      <xsl:when test="$level = 6">3in</xsl:when>
		      <xsl:when test="$level = 5">2.5in</xsl:when>
		      <xsl:when test="$level = 4">2in</xsl:when>
		      <xsl:when test="$level = 3">1.5in</xsl:when>
		      <xsl:when test="$level = 2">1in</xsl:when>
		      <xsl:when test="$level = 1">0.5in</xsl:when>
		         
		      <xsl:otherwise>0pt</xsl:otherwise>
		    </xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <!-- Calculate the numbering for proceduralSteps (which number the proceduralStep should use). -->
  <!-- Called with the applicable proceduralStep in context -->
  <xsl:template name="calc-prclist-position">
    <!--<xsl:value-of select="1 + count(../preceding-sibling::*[PRCITEM/TITLE|PRCITEM/PARA])"/>-->
    <xsl:choose>
    	<!-- When it's a first-level proceduralStep, we need to also count ones in preceding data modules -->
    	<xsl:when test="not(parent::proceduralStep)">
			<xsl:value-of select="count(preceding-sibling::proceduralStep) + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep) 
      + count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara) + 1"/>
    	</xsl:when>
    	<xsl:otherwise>
			<xsl:value-of select="count(preceding-sibling::proceduralStep) + 1"/>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Calculate the numbering format ("1." or "A." etc.) for proceduralSteps. -->
  <!-- Called with the applicable proceduralStep in context -->
  <xsl:template name="get-proclist-format-string">
    <xsl:variable name="level" select="count(ancestor::proceduralStep) + 1"/>
    <!-- For proceduralSteps in top-level pmEntries after the Introduction, use different numbering (starting with "1.") -->
    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
    <xsl:choose>
    	<xsl:when test="count(ancestor::pmEntry) = 1 and
    	  ( ancestor::pmEntry/preceding-sibling::pmEntry/@pmEntryType='pmt58'
    	  or ( not(ancestor::pmEntry[last()]/@isFrontmatter='1')
    	     and ancestor::pmEntry[last()]/preceding-sibling::pmEntry[@isFrontmatter='1'])
    	  )">
    	  <!-- <xsl:when test="count(ancestor::pmEntry) = 1 and not(ancestor::pmEntry/@isFrontmatter='1') and not(ancestor::pmEntry/@pmEntryType='pmt58')"> -->
		    <xsl:choose>
 		      <xsl:when test="$level = 8">(a)</xsl:when><!-- [1] -->
		      <xsl:when test="$level = 7">(1)</xsl:when><!-- (a) -->
		      <xsl:when test="$level = 6">a</xsl:when>
		      <xsl:when test="$level = 5">1</xsl:when>
		      <xsl:when test="$level = 4">(a)</xsl:when>
		      <xsl:when test="$level = 3">(1)</xsl:when>
		      <xsl:when test="$level = 2">A.</xsl:when>
		      <xsl:when test="$level = 1">1.</xsl:when>
		    </xsl:choose>
    	</xsl:when>
    	<xsl:otherwise>
		    <xsl:choose>
		      <xsl:when test="$level = 7">(a)</xsl:when><!-- [1] -->
		      <xsl:when test="$level = 6">(1)</xsl:when><!-- (a) -->
		      <xsl:when test="$level = 5">a</xsl:when>
		      <xsl:when test="$level = 4">1</xsl:when>
		      <xsl:when test="$level = 3">(a)</xsl:when>
		      <xsl:when test="$level = 2">(1)</xsl:when>
		      <xsl:when test="$level = 1">A.</xsl:when>
		    </xsl:choose>
    	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Called with LxITEM in context -->
  <xsl:template name="calc-list-position">
    <xsl:variable name="level" select="count(ancestor::levelledPara) + 1"/>
    <xsl:choose>
      
      <xsl:when test="$level = 1">
	    <!-- From Styler -->
        <xsl:value-of select="count(preceding-sibling::levelledPara)+count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/description/levelledPara)+count(ancestor::dmContent/preceding-sibling::dmContent/dmodule/content/procedure/mainProcedure/proceduralStep)+1"/>
      </xsl:when>
      <xsl:otherwise>
		<xsl:value-of select="1 + count(preceding-sibling::levelledPara)"/>
	  </xsl:otherwise>
    </xsl:choose>
	
  </xsl:template>
  
  <xsl:template name="get-list-format-string">
    <xsl:variable name="level" select="count(ancestor::levelledPara) + count(ancestor::proceduralStep) + 1"/>
    <!-- For levelledParas in top-level pmEntries after the Introduction, use different numbering (starting with "1.") -->
    <!-- (This is most often used just for "Not Applicable" sections, so all the extra levels are probably not necessary). -->
    <!-- UPDATE: Now using pre-process attribute isFrontmatter -->
    <xsl:choose>
    	<xsl:when test="count(ancestor::pmEntry) = 1 and
    	  ( ancestor::pmEntry/preceding-sibling::pmEntry/@pmEntryType='pmt58'
    	  or ( not(ancestor::pmEntry[last()]/@isFrontmatter='1')
    	     and ancestor::pmEntry[last()]/preceding-sibling::pmEntry[@isFrontmatter='1'])
    	  )">
    	  <!-- <xsl:when test="count(ancestor::pmEntry) = 1 and not(ancestor::pmEntry/@isFrontmatter='1') and not(ancestor::pmEntry/@pmEntryType='pmt58')"> -->
		    <xsl:choose>
 		      <xsl:when test="$level = 8">(a)</xsl:when>
		      <xsl:when test="$level = 7">(1)</xsl:when>
		      <xsl:when test="$level = 6">a</xsl:when>
		      <xsl:when test="$level = 5">1</xsl:when>
		      <xsl:when test="$level = 4">(a)</xsl:when>
		      <xsl:when test="$level = 3">(1)</xsl:when>
		      <xsl:when test="$level = 2">A.</xsl:when>
		      <xsl:when test="$level = 1">1.</xsl:when>
		    </xsl:choose>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:choose>
		      <xsl:when test="ancestor::pmEntry[@pmEntryType='pmt77'] and $level = 2">1.</xsl:when>
		      <xsl:when test="$level = 7">(a)</xsl:when>
		      <xsl:when test="$level = 6">(1)</xsl:when>
		      <xsl:when test="$level = 5">a</xsl:when>
		      <xsl:when test="$level = 4">1</xsl:when>
		      <xsl:when test="$level = 3">(a)</xsl:when>
		      <xsl:when test="$level = 2">(1)</xsl:when>
		      <xsl:when test="$level = 1">A.</xsl:when>
		    </xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-levelledPara-decoration">
    <xsl:variable name="level" select="count(ancestor::levelledPara) + 1"/>
    <xsl:choose>
      <xsl:when test="$level = 7">underline</xsl:when>
      <xsl:when test="$level = 6">underline</xsl:when>
      <xsl:when test="$level = 5">underline</xsl:when>
      <xsl:when test="$level = 4">underline</xsl:when>
      <xsl:otherwise>none</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-proclist-decoration">
    <xsl:variable name="level" select="count(ancestor::proceduralStep) + 1"/>
    <xsl:choose>
      <xsl:when test="$level = 7">underline</xsl:when>
      <xsl:when test="$level = 6">underline</xsl:when>
      <xsl:when test="$level = 5">underline</xsl:when>
      <xsl:when test="$level = 4">underline</xsl:when>
      <xsl:otherwise>none</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-text-decoration">
    <xsl:variable name="level" select="count(ancestor::levelledPara) + 1"/>
    <xsl:choose>
      <xsl:when test="parent::LIST6">underline</xsl:when>
      <xsl:when test="parent::LIST5">underline</xsl:when>
      <xsl:when test="parent::LIST4">underline</xsl:when>
      <xsl:when test="parent::LIST3">underline</xsl:when>
     
     
      <xsl:when test="ancestor::PRCLIST7">none</xsl:when>
      <xsl:when test="ancestor::PRCLIST6">underline</xsl:when>
      <xsl:when test="ancestor::PRCLIST5">underline</xsl:when>
      <xsl:when test="ancestor::PRCLIST4">underline</xsl:when>
      <xsl:when test="ancestor::PRCLIST3">underline</xsl:when>
      
      <xsl:otherwise>none</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- Called with LxITEM in context -->
  <!-- These are in reverse order to match the lowest level -->
  <xsl:template name="calc-unlist-numlist-indent">
    <xsl:choose>
      <xsl:when test="ancestor::PRCITEM7 | ancestor::PRCITEM6 | ancestor::PRCITEM5 | ancestor::PRCITEM4 | ancestor::PRCITEM3 | ancestor::PRCITEM2 | ancestor::PRCITEM1">0pt</xsl:when>
      
      <!-- The two hierarchies are independent of each other -->
      
      <xsl:when test="ancestor::LIST7">216pt</xsl:when>
      <xsl:when test="ancestor::LIST6">192pt</xsl:when>
      <xsl:when test="ancestor::LIST5">168pt</xsl:when>
      <xsl:when test="ancestor::LIST4">144pt</xsl:when>
      <xsl:when test="ancestor::LIST3">120pt</xsl:when>
      <xsl:when test="ancestor::LIST2">96pt</xsl:when>
      <xsl:when test="ancestor::LIST1">72pt</xsl:when>
      
      <xsl:otherwise>0pt</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Called with NUMLITEM in context -->
  <!-- RS: Default to "1"; others not applicable for now. -->
  <xsl:template name="get-numlist-format-string">
    <xsl:choose>
      <xsl:when test="not(../@NUMTYPE)">1</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'npp'">1.</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'nnr'">1)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'nns'">1)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'aup'">A.</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'aur'">A)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'rup'">I.</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'rur'">I)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'rlp'">i.</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'rlr'">i)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'nnb'">(1)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'alb'">(a)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'alr'">a)</xsl:when>
      <xsl:when test="lower-case(../@NUMTYPE) = 'alp'">a.</xsl:when>
      <xsl:otherwise>1)</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="sequentialList" name="numlist">
    <xsl:variable name="indent">
      <xsl:choose>
        <xsl:when test="ancestor::note or ancestor::warning or ancestor::caution">
          <xsl:text>0pt</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="calc-unlist-numlist-indent"/>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:variable>
      
    <!-- <xsl:call-template name="check-rev-start"/>-->
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbStart" />
	</xsl:if>
    
      <fo:list-block xsl:use-attribute-sets="list.vertical.space" provisional-distance-between-starts="0.5in" space-before="6pt">
        <!-- <xsl:attribute name="provisional-distance-between-starts">24pt</xsl:attribute> -->
        <xsl:attribute name="provisional-label-separation">6pt</xsl:attribute>
        <xsl:attribute name="margin-left"><xsl:value-of select="$indent"/></xsl:attribute>
        <xsl:apply-templates/>
      </fo:list-block>
    <!--  <xsl:call-template name="check-rev-end"/>-->
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbEnd" />
	</xsl:if>
  </xsl:template>
 
   <xsl:template match="sequentialList/listItem">
    <xsl:variable name="formatString">
      <xsl:call-template name="get-numlist-format-string"/>
    </xsl:variable>
    <!-- <xsl:call-template name="check-rev-start"/>-->
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbStart" />
	</xsl:if>
    
    <fo:list-item xsl:use-attribute-sets="list.vertical.space">
      <fo:list-item-label end-indent="label-end()">
        <fo:block><xsl:number format="{$formatString}"/></fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block>
          <xsl:apply-templates/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
    <!-- <xsl:call-template name="check-rev-end"/>-->
	<xsl:if test="not(@changeMark='0') and (@changeType='add' or @changeType='modify' or @changeType='delete')">
		<xsl:call-template name="cbEnd" />
	</xsl:if>
  </xsl:template>
  

<!-- Old ATA code ... keep for reference for now...

  <xsl:template name="calc-warning-caution-indent">
    <xsl:choose>
      <xsl:when test="parent::SUBTASK">24pt</xsl:when>
      <xsl:when test="parent::L1ITEM">-24pt</xsl:when>
      <xsl:when test="parent::L2ITEM">-24pt</xsl:when>
      <xsl:when test="parent::L3ITEM">-24pt</xsl:when>
      <xsl:when test="parent::L4ITEM">-24pt</xsl:when>
      <xsl:when test="parent::L5ITEM">-24pt</xsl:when>
      <xsl:when test="parent::L6ITEM">-24pt</xsl:when>
      <xsl:when test="parent::L7ITEM">-24pt</xsl:when>
      
      <xsl:when test="parent::PRCITEM">-24pt</xsl:when>


      <xsl:otherwise>
        <xsl:message>No warning/caution indent set</xsl:message>
        <xsl:text>0pt</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-subtask-string">
    <xsl:value-of
      select="concat('(Subtask ', @CHAPNBR, 
      '-', @SECTNBR, 
      '-', @SUBJNBR, 
      '-', @FUNC,
      '-', @SEQ,
      '-',@CONFLTR,@VARNBR,')')"
    />
  </xsl:template>
  <xsl:template name="get-task-string">
    <xsl:value-of
      select="concat('(TASK ', @CHAPNBR, 
      '-', @SECTNBR, 
      '-', @SUBJNBR,
      '-', @FUNC,
      '-',@SEQ,
      '-',@CONFLTR,@VARNBR,')')"
    />
  </xsl:template>
  
  <xsl:template match="TASK">
    <fo:list-block font-size="10pt" provisional-distance-between-starts="24pt"
      space-before=".1in" space-after=".1in" keep-with-next.within-page="always">
      <xsl:attribute name="id">
        <xsl:value-of select="@KEY"/>
      </xsl:attribute>
      <xsl:call-template name="save-revdate"/>
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()" font-size="12pt" font-weight="bold">
          <fo:block >
            <xsl:number value="1 + count(preceding-sibling::TASK)" format="1."/>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()" font-size="12pt">
          <xsl:if test="TITLE[preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']]">
            <xsl:call-template name="cbStart"/>
          </xsl:if>
          <fo:block rx:key="{concat('task_',@KEY)}" >
            <fo:inline text-decoration="underline" font-weight="bold">
              <xsl:apply-templates select="TITLE" mode="task-subtask-title"/>
            </fo:inline>
            <xsl:text>&#xA0;</xsl:text>
            <fo:inline font-weight="normal" text-decoration="none" >
              <xsl:call-template name="get-mtoss"/>
            </fo:inline>
          </fo:block>
          <xsl:if test="TITLE[following-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '/_rev']]">
            <xsl:call-template name="cbEnd"/>
          </xsl:if>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="SUBTASK">
    <fo:list-block margin-left=".33in" font-size="10pt" space-before=".1in"
      space-after=".1in" provisional-distance-between-starts="24pt"
      keep-with-next.within-page="always">
      <xsl:attribute name="id">
        <xsl:value-of select="@KEY"/>
      </xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
      <fo:list-item>
        <xsl:call-template name="save-revdate"/> 
        <fo:list-item-label end-indent="label-end()">
          <fo:block>
            <xsl:number value="1 + count(preceding-sibling::SUBTASK)" format="A."/>
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <xsl:if test="TITLE[preceding-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '_rev']]">
            <xsl:call-template name="cbStart"/>
          </xsl:if>
          <fo:block>
            <fo:inline>
              <xsl:apply-templates select="TITLE" mode="task-subtask-title"/>
            </fo:inline>
            <xsl:text>&#xA0;</xsl:text>
            <fo:inline font-weight="normal" text-decoration="none" >
              <xsl:call-template name="get-mtoss"/>
            </fo:inline>
          </fo:block>
          <xsl:if test="TITLE[following-sibling::node()[not(*)][not(normalize-space(.) = '')][1][. = '/_rev']]">
            <xsl:call-template name="cbEnd"/>
          </xsl:if>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="UNLIST" name="unlist">
    <xsl:variable name="bullType">
      <xsl:choose>
        <xsl:when test="not(@BULLTYPE)">system</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="lower-case(@BULLTYPE)"/>
        </xsl:otherwise>
      </xsl:choose>  
    </xsl:variable>
    <xsl:variable name="indent">
      <xsl:choose>
        <xsl:when test="ancestor::NOTE or ancestor::WARNING or ancestor::CAUTION">
         <xsl:text>0pt</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="calc-unlist-numlist-indent"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="check-rev-start"/>
    <xsl:choose> 
      <xsl:when test="$bullType = 'none'">
        <fo:list-block xsl:use-attribute-sets="list.vertical.space">
          <xsl:attribute name="margin-left">
            <xsl:value-of select="$indent"/>
          </xsl:attribute>
          <xsl:attribute name="provisional-distance-between-starts">24pt</xsl:attribute>
          <xsl:attribute name="provisional-label-separation">0pt</xsl:attribute>
          <xsl:apply-templates/>
        </fo:list-block>
      </xsl:when>
      <xsl:otherwise>
        <fo:list-block xsl:use-attribute-sets="list.vertical.space">
          <xsl:attribute name="margin-left">
            <xsl:value-of select="$indent"/>
          </xsl:attribute>
          <xsl:attribute name="provisional-distance-between-starts">5mm</xsl:attribute>
          <xsl:attribute name="provisional-label-separation">2mm</xsl:attribute>
          <xsl:apply-templates/>
        </fo:list-block>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>

  <xsl:template match="UNLITEM">
    <xsl:variable name="bullType">
      <xsl:choose>
        <xsl:when test="not(../@BULLTYPE)">system</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="lower-case(../@BULLTYPE)"/>
        </xsl:otherwise>
      </xsl:choose>  
    </xsl:variable>
    <xsl:call-template name="check-rev-start"/>
    [!++ These are used for addresses, so try to keep within page ++]
    <fo:list-item xsl:use-attribute-sets="list.vertical.space" keep-together.within-page="always">
      <fo:list-item-label end-indent="label-end()">
        <xsl:choose>
          [!++ The CMM FOSI defaults "system" to the bullet ++]
          <xsl:when test="$bullType = 'system'">
            <fo:block>&#x2022;</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'bullet'">
            <fo:block>&#x2022;</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'mdash'">
            <fo:block>&#x2014;</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'ndash'">
            <fo:block>&#x2013;</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'square'">
            <fo:block>&#x25a1;</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'diamond'">
            <fo:block>&#x2666;</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'asterisk'">
            <fo:block>*</fo:block>
          </xsl:when>
          <xsl:when test="$bullType = 'delta'">
            <fo:block>&#x0394;</fo:block>
          </xsl:when>
          <xsl:otherwise>
            <fo:block></fo:block>
          </xsl:otherwise>
        </xsl:choose>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <fo:block space-before="0pt" space-after="0pt">
          <xsl:apply-templates/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>

  [!++ <xsl:template match="NUMLIST" name="numlist"> ++]
  <xsl:template match="sequentialList" name="numlist">
    <xsl:variable name="indent">
      <xsl:choose>
        <xsl:when test="ancestor::note or ancestor::warning or ancestor::caution">
          <xsl:text>0pt</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="calc-unlist-numlist-indent"/>
        </xsl:otherwise>
      </xsl:choose>
      </xsl:variable>
      
    [!++ <xsl:call-template name="check-rev-start"/>++]
	<xsl:if test="@changeType='add' or @changeType='modify' or @changeType='delete'">
		<xsl:call-template name="cbStart" />
	</xsl:if>
    
      <fo:list-block xsl:use-attribute-sets="list.vertical.space" provisional-distance-between-starts="0.5in" space-before="6pt">
        [!++ <xsl:attribute name="provisional-distance-between-starts">24pt</xsl:attribute> ++]
        <xsl:attribute name="provisional-label-separation">6pt</xsl:attribute>
        <xsl:attribute name="margin-left"><xsl:value-of select="$indent"/></xsl:attribute>
        <xsl:apply-templates/>
      </fo:list-block>
    [!++ <xsl:call-template name="check-rev-end"/>++]
	<xsl:if test="@changeType='add' or @changeType='modify' or @changeType='delete'">
		<xsl:call-template name="cbEnd" />
	</xsl:if>
  </xsl:template>
 
  <xsl:template match="CAUTION" name="caution">
    <xsl:call-template name="check-rev-start"/>
    <fo:list-block provisional-distance-between-starts=".92in" provisional-label-separation=".1in"
      keep-with-next.within-page="always" keep-together.within-page="always">
      <xsl:attribute name="margin-left">
        <xsl:call-template name="calc-warning-caution-indent"/>
      </xsl:attribute>
      <xsl:if test="not(ancestor::PRCITEM)">
        <xsl:attribute name="space-before.minimum">.06in</xsl:attribute>
        <xsl:attribute name="space-before.optimum">.08in</xsl:attribute>
        <xsl:attribute name="space-before.maximum">.10in</xsl:attribute>
        <xsl:attribute name="space-after.minimum">.06in</xsl:attribute>
        <xsl:attribute name="space-after.optimum">.08in</xsl:attribute>
        <xsl:attribute name="space-after.maximum">.10in</xsl:attribute>
      </xsl:if>
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()">
          <fo:block><fo:inline text-decoration="underline">CAUTION</fo:inline>: </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block text-transform="uppercase" orphans="4">
            <xsl:apply-templates/>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>
  
  <xsl:template match="TITLE" mode="task-subtask-title">
    <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="TASK/TITLE|SUBTASK/TITLE">
    [!++ Suppress if not called with explicit mode ++]
  </xsl:template>
  
  <xsl:template match="DEFLIST">
    <xsl:call-template name="check-rev-start"/>
    <fo:table rx:table-omit-initial-header="true" margin-left="0pt">
      <fo:table-column column-width="100%"/>
      <fo:table-header>
        <fo:table-cell>
          <fo:block font-size="10pt" font-weight="bold" text-align="center" space-after="6pt">
            <xsl:text>List of Acronyms and Abbreviations (Cont)</xsl:text>
          </fo:block>
        </fo:table-cell>
      </fo:table-header>
      <fo:table-body>
        <fo:table-row>
          <fo:table-cell>
            <fo:table-and-caption>
              <fo:table-caption text-align="center">
                <fo:block font-size="10pt" font-weight="bold" space-after="6pt">
                  <xsl:text>List of Acronyms and Abbreviations</xsl:text>
                </fo:block>
              </fo:table-caption>
              <fo:table border-bottom-style="solid" border-bottom-width="1pt">
                <fo:table-column column-number="1" column-width="25%"/>
                <fo:table-column column-number="2" column-width="75%"/>
                <fo:table-header font-weight="bold" padding-top="4pt" padding-bottom="4pt"
                  border-top-style="solid" border-top-width="1pt" border-bottom-style="solid"
                  border-bottom-width="1pt" border-after-width.conditionality="retain">
                  <fo:table-cell padding-top="4pt" padding-bottom="4pt">
                    <fo:block>
                      <xsl:text>Term</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                  <fo:table-cell padding-top="4pt" padding-bottom="4pt">
                    <fo:block>
                      <xsl:text>Full Term</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-header>
                <fo:table-body>
                  <xsl:choose>
                    <xsl:when test="ISEMPTY">
                      <fo:table-row>
                        <fo:table-cell/>
                        <fo:table-cell/>
                      </fo:table-row>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="DEFDATA"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </fo:table-body>
              </fo:table>
            </fo:table-and-caption>
          </fo:table-cell>
        </fo:table-row>
      </fo:table-body>
    </fo:table>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>

  <xsl:template match="DEFDATA">
    <fo:table-row>
      <fo:table-cell margin-left="0pt" padding-top="4pt" padding-bottom="2pt">
        <fo:block>
          <xsl:call-template name="check-rev-start"/>
          <xsl:apply-templates select="TERM"/>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell margin-left="0pt" padding-top="4pt" padding-bottom="2pt">
        <fo:block>
          <xsl:apply-templates select="FULLTERM"/>
          <xsl:call-template name="check-rev-end"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>
  
  <xsl:template match="TERM|FULLTERM">
    <xsl:call-template name="check-rev-start"/>
    <xsl:apply-templates/>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>

  <xsl:template match="WARNING" name="warning">
    <xsl:call-template name="check-rev-start"/>
    <fo:list-block provisional-distance-between-starts=".92in" provisional-label-separation=".1in"
      keep-with-next.within-page="always" keep-together.within-page="always">
      <xsl:attribute name="margin-left">
        <xsl:call-template name="calc-warning-caution-indent"/>
      </xsl:attribute>
      <xsl:if test="not(ancestor::PRCITEM)">
        <xsl:attribute name="space-before.minimum">.06in</xsl:attribute>
        <xsl:attribute name="space-before.optimum">.08in</xsl:attribute>
        <xsl:attribute name="space-before.maximum">.10in</xsl:attribute>
        <xsl:attribute name="space-after.minimum">.06in</xsl:attribute>
        <xsl:attribute name="space-after.optimum">.08in</xsl:attribute>
        <xsl:attribute name="space-after.maximum">.10in</xsl:attribute>
      </xsl:if>
      <fo:list-item>
        <fo:list-item-label end-indent="label-end()">
          <fo:block><fo:inline text-decoration="underline" font-weight="bold">WARNING</fo:inline>:
          </fo:block>
        </fo:list-item-label>
        <fo:list-item-body start-indent="body-start()">
          <fo:block text-transform="uppercase" font-weight="bold" orphans="4">
            <xsl:apply-templates/>
          </fo:block>
        </fo:list-item-body>
      </fo:list-item>
    </fo:list-block>
    <xsl:call-template name="check-rev-end"/>
  </xsl:template>
 -->

</xsl:stylesheet>
