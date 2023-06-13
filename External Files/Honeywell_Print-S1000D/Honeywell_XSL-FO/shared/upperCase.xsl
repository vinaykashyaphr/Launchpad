<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atict="http://www.ptc.com/" >
    
    <xsl:import href="identity.xsl"/>
    
    <xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/> 
        

    <!-- Sonovision update (2019.06.05)
         - adding variable to detect when SIL document and then suppress certain content
    -->
    <xsl:variable name="hontype">
     <xsl:value-of select="/sb/@hontype"/>
    </xsl:variable>

    <xsl:output indent="no" method="xml"/>
    <xsl:preserve-space elements="*"/>
    



    <xsl:template match="*" >
        <xsl:element name="{translate(local-name(),$lowerCase,$upperCase)}" 
            namespace="{namespace-uri()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{translate(name(),$lowerCase,$upperCase)}">
                 <xsl:call-template name="attribute-value"/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    
    <xsl:template match="atict:*">
        <!-- ignore the arbortext specific element -->
    </xsl:template>

<xsl:template name="attribute-value">
 
     <!-- Leave the case alone on the following attributes -->
        <xsl:choose>
            <xsl:when test="name() =  'overlayformatstyle'">
                <xsl:value-of select="."/>
            </xsl:when>
             <xsl:when test="name() =  'imgarea'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'orient'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'tabstyle'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'chg'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'key'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'id'">
                <xsl:value-of select="."/>
             </xsl:when>
            <xsl:when test="name() =  'refid'">
                <xsl:value-of select="."/>
             </xsl:when>
           <xsl:when test="name() =  'ftnoteid'">
              <xsl:value-of select="."/>
           </xsl:when>
           <xsl:when test="name() =  'type'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'bulltype'">
                <xsl:value-of select="."/>
             </xsl:when>
             <xsl:when test="name() =  'numtype'">
                <xsl:value-of select="."/>
             </xsl:when>
            <!-- Otherwise translate to upper case -->
            <xsl:otherwise>
             <xsl:value-of select="translate(.,$lowerCase,$upperCase)"/>
                </xsl:otherwise>
            </xsl:choose>
</xsl:template>



<!-- CV - items marked for deletion @delitem="1" should just be replaced with content 
          where partnumber is preserved, but keyword changed to "DELETED" and quantity set to "0"
        - (August 2018)
          -->
<!-- Sonovision update (2018.12.06)
     - now getting revised request where they want rev bars and "PN ENTERED IN ERROR" text to appear,
       but still suppress all other items
       -->
    <xsl:template match="itemdata[@delitem = '1']" priority="1">
        <xsl:element name="{translate(local-name(),$lowerCase,$upperCase)}" 
            namespace="{namespace-uri()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{translate(name(),$lowerCase,$upperCase)}">
                 <xsl:choose>
                  <!-- Set @delitem = '0' -->
                  <xsl:when test="name() = 'delitem'">
                   <xsl:text>0</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                   <xsl:call-template name="attribute-value"/>
                  </xsl:otherwise>
                 </xsl:choose>
                </xsl:attribute>
            </xsl:for-each>

            <!-- <xsl:apply-templates select="node()"/> -->
            
            <!-- CV - only need to preserve the "pnr" value -->
            <PNR><xsl:value-of select="child::pnr"/></PNR>
            <IPLNOM>
             <NOM>
              <KWD><xsl:text>DELETED</xsl:text></KWD>
              <ADT></ADT>
             </NOM>
             <xsl:if test="normalize-space(child::iplnom/msc) = 'PN ENTERED IN ERROR'">
              <MSC><xsl:value-of select="child::iplnom/msc"/></MSC>
             </xsl:if>
            </IPLNOM>
            
            <!-- CV - must also preserve "rev" bars (if any) -->
            <xsl:choose>
             <xsl:when test="descendant::processing-instruction('Pub')">
              <xsl:text disable-output-escaping="yes">&lt;?Pub _rev?></xsl:text>
              <UPA><xsl:text>0</xsl:text></UPA>
              <xsl:text disable-output-escaping="yes">&lt;?Pub /_rev?></xsl:text>
             </xsl:when>
             <xsl:otherwise>
              <UPA><xsl:text>0</xsl:text></UPA>
             </xsl:otherwise>
            </xsl:choose>
            
            

        </xsl:element>
    </xsl:template>


<!-- CV - "transltr" missing expected @key attribute and generating empty "" link in final FO 
          for "TRANSMITTAL INFORMATION" links
        - XSLT "transmittal.xsl" generates the target fo:block wrapper with id="transltr",
          so @key="transltr" is the value that should be set in order for links to work in PDF
           -->
    <xsl:template match="transltr[not(@key)]" priority="1">
        <xsl:element name="{translate(local-name(),$lowerCase,$upperCase)}" 
            namespace="{namespace-uri()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{translate(name(),$lowerCase,$upperCase)}">
                 <xsl:call-template name="attribute-value"/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="KEY">
             <xsl:text>transltr</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>



    <!-- Sonovision update (2019.01.15) -->
    <!-- CV - add support for cell shading (Arbortext PI's converted to element in earlier phase) -->
    <xsl:template match="entry[child::cellfont]" priority="1">
        <xsl:element name="{translate(local-name(),$lowerCase,$upperCase)}" 
            namespace="{namespace-uri()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{translate(name(),$lowerCase,$upperCase)}">
                 <xsl:call-template name="attribute-value"/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="SHADING">
             <xsl:value-of select="child::cellfont/@Shading"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
  
    <!-- CV - get rid of the "cellfont" element -->
    <xsl:template match="cellfont" priority="1"/>


    <!-- CV - add support for row height (Arbortext PI's converted to element in earlier phase) -->
    <xsl:template match="row[child::PubTbl_row]" priority="1">
        <xsl:element name="{translate(local-name(),$lowerCase,$upperCase)}" 
            namespace="{namespace-uri()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{translate(name(),$lowerCase,$upperCase)}">
                 <xsl:call-template name="attribute-value"/>
                </xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="HEIGHT">
             <xsl:value-of select="child::PubTbl_row/@rht"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
  
    <!-- CV - get rid of the "PubTbl_row" element -->
    <xsl:template match="PubTbl_row" priority="1"/>



<!-- ********************************************************************************************* -->
<!-- Sonovision update (2019.02.13)
     - processing instructions can get lost to due to string processing of lists
     - protect as text and then fix with "fix_line_break.xom" step
       -->
<xsl:template match="processing-instruction('newline')[ancestor::prcitem]" priority="1">
 <xsl:text>[***NEWLINE***]</xsl:text>
</xsl:template>

<xsl:template match="processing-instruction('pagebreak')[ancestor::prcitem]" priority="1">
 <xsl:text>[***PAGEBREAK***]</xsl:text>
</xsl:template>

<!-- ********************************************************************************************* -->


<!-- ********************************************************************************************* -->
<!-- Sonovision update (2019.06.05)
     - suppress most front matter when SIL (want it to look like a letter)
     - "Revision History" will not be suppressed, but must appear as very last item in the document
       -->

<!-- Sonovision update (2019.08.06)
     - collect "sb/title" and save under "A. Subject" as very first item in the list
     - collect "Summary" and place just before "Revision History"
       -->

<xsl:template match="legalntc[$hontype='sil']" priority="1"/>
<xsl:template match="ts[$hontype='sil']" priority="1"/>


<xsl:template match="//plan[1][$hontype='sil']">



 <PLAN>

  <xsl:for-each select="@*">
   <xsl:attribute name="{translate(name(),$lowerCase,$upperCase)}">
    <xsl:call-template name="attribute-value"/>
   </xsl:attribute>
  </xsl:for-each>


 <!-- Sonovision update (2019.08.09)
      - now want to preserve the "Export Control" content which is being suppressed inside "legalntc"
      - place as first item in PLAN and will appear just before the list items start
      - REVISED: now wanted at end of document
        -->
 <!--
 <xsl:if test="//exprtcl">
 <EXPRTCL>
  <xsl:apply-templates select="//exprtcl/*"/>
 </EXPRTCL>
 </xsl:if>
 -->

  
  <!-- SIL first item in list should be "A. Subject" and text should be "sb/title" -->
  <PLANSECT SECTNAME="OTH" CHG="u" KEY="sb-revision">
   <xsl:attribute name="REVDATE"><xsl:value-of select="/sb/@revdate"/></xsl:attribute>
   <TITLE>Subject</TITLE>
   <PARA>
    <xsl:value-of select="/sb/title"/>
   </PARA>
  </PLANSECT>


  <xsl:apply-templates/>

  <!-- Collect all tssect elements add as last item in list -->
  <xsl:if test="//tssect">
   <xsl:for-each select="//tssect">
     <PLANSECT SECTNAME="OTH" CHG="u" KEY="sb-revision">
      <xsl:attribute name="REVDATE"><xsl:value-of select="/sb/@revdate"/></xsl:attribute>
       <xsl:apply-templates select="node()"/>
     </PLANSECT>
   </xsl:for-each>
  </xsl:if>


 </PLAN>


 <!-- Sonovision update (2019.08.09)
      - SIL: export control box at end of document
        -->

  <xsl:if test="//exprtcl">
  <EXPRTCL>
   <xsl:apply-templates select="//exprtcl/*"/>
  </EXPRTCL>
  </xsl:if>

 
</xsl:template>



<!-- ********************************************************************************************* -->



</xsl:stylesheet>
