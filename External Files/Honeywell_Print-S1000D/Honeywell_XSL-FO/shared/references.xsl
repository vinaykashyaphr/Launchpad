<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions">
   <xsl:template match="REFINT">
      <xsl:variable name="refId" select="@REFID"/>
      <xsl:variable name="debugId" select="generate-id()"/>
      <!-- In SkyDoc we don't necessarily have access to the DTD, so the id() function 
         won't work unless the attribute is named "ID". -->
      <xsl:choose>
         <xsl:when test="id($refId)">
            <xsl:for-each select="id(@REFID)">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="//@KEY = $refId">
            <xsl:for-each select="//*[@KEY = $refId]">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="//@FTNOTEID = $refId">
            <xsl:for-each select="//*[@FTNOTEID = $refId]">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <!-- This should be the same as the first case, but that might be processor specific -->
         <xsl:when test="//@ID = $refId">
            <xsl:for-each select="//*[@ID = $refId]">
               <xsl:call-template name="build-refint-link">
                  <xsl:with-param name="refId" select="$refId"/>
                  <xsl:with-param name="debugId" select="$debugId"/>
               </xsl:call-template>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat('[[[ Unmatched REFINT=',$refId,']]]')"/>
            <xsl:message>
               <xsl:value-of select="concat('[error] [[[ Unmatched REFINT=',$refId,']]]')"/>
            </xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

  <xsl:template match="REFEXT">
    <xsl:apply-templates/>
  </xsl:template>

   <!-- The target node is in context when this template is called -->
   <xsl:template name="build-refint-link">
      <xsl:param name="refId" select="''"/>
      <xsl:param name="debugId" select="''"/>
     <fo:basic-link internal-destination="{$refId}"><!-- color="#0000ff"-->
         <xsl:if test="number($DEBUG) = 1">
            <xsl:attribute name="id">
               <xsl:value-of select="$debugId"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:choose>

<!-- Sonovision update (2019.03.06)
     - sometimes need "refint" to "Dimensional Limits" tables inside "GDESC"
       -->

            <!-- Only tables with titles are counted (formal tables) -->
            <!-- <xsl:when test="name() = 'TABLE' and child::TITLE"> -->
            <xsl:when test="name() = 'TABLE' and child::TITLE and not(parent::GDESC)">
               <xsl:text>Table </xsl:text>
               <xsl:call-template name="calc-table-number"/>
            </xsl:when>

            <xsl:when test="name() = 'TABLE' and child::TITLE and parent::GDESC">
               <xsl:value-of select="TITLE"/>
               <xsl:text> for Figure </xsl:text>
               <xsl:call-template name="calc-figure-number"/>
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

                 <!-- Sonovision update (2019.07.15)
                      - want @CONFNBR to display (e.g. suffix "-0201") when not equal "1"
                      - e.g. "REPAIR-0101"
                        -->
                 <xsl:if test="@CONFNBR and @CONFNBR!='1'">
                   <xsl:value-of select="concat('-',@CONFNBR)"/>
                 </xsl:if>
                 
                 <xsl:text> </xsl:text>
                 <xsl:text> (PGBLK </xsl:text>

                 <!--
                 <xsl:value-of select="concat(@CHAPNBR,
                   '-',@SECTNBR,
                   '-',@SUBJNBR,
                   '-',@PGBLKNBR)"/>
                   -->
                 
                 <!-- Sonovision update (2019.07.15)
                      - want @CONFNBR to display (e.g. suffix "-0201") when not equal "1"
                      - e.g. (PGBLK 73-20-43-6000-0101)
                        -->
                 <xsl:choose>
                  
                  <xsl:when test="@CONFNBR and @CONFNBR!='1'">
                   <xsl:value-of select="concat(@CHAPNBR,
                     '-',@SECTNBR,
                     '-',@SUBJNBR,
                     '-',@PGBLKNBR,
                     '-',@CONFNBR)"/>
                  </xsl:when>
                  
                  <xsl:otherwise>
                   <xsl:value-of select="concat(@CHAPNBR,
                     '-',@SECTNBR,
                     '-',@SUBJNBR,
                     '-',@PGBLKNBR)"/>
                  </xsl:otherwise>
                 
                 </xsl:choose>
                   
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
            <xsl:when test="(name() = 'GRAPHIC') or (name() = 'SHEET') ">
               <xsl:call-template name="grphcref"/>
            </xsl:when>
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
               <fo:inline color="red">[[!!! REFERENCE TO UNHANDLED LOCATION !!!]]</fo:inline>
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
  
   <xsl:template match="PGBLK/TITLE" mode="refint">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="TASK/TITLE" mode="refint">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="SUBTASK/TITLE" mode="refint">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="GRPHCREF" name="grphcref">

      <!-- Sonovision update (2019.02.13)

           - when element is REFINT it seems to be transormed to the target GRAPHIC context
             during XSLT processing in which case @REFID won't be found (but @KEY will)
             
           - since there will never be both @REFID and @KEY on same element, 
             just concatenate and then rest of graphic linking should always work
             (and not result in "Unmatched GRPHCREF" messge)
             -->

      <!-- <xsl:variable name="ref" select="@REFID"/> -->
      <xsl:variable name="ref" select="concat(@REFID,@KEY)"/>

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

</xsl:stylesheet>
