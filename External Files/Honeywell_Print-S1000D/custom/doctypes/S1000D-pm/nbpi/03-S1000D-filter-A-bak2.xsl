<?xml version="1.0"  encoding="UTF-8" ?>

<!--
==============================================
Collect various requirements table items from
throughout the document to central locations
==============================================

S1000D-filter-A.xsl

Version: 0.2
Created: April 25, 2013
Last Modified: June 6, 2013

Chris van Mels
NewBook Production Inc.
7045 Edwards Blvd.
Suite 101
Mississauga, Ontario, Canada
L5S 1X2
(905) 670-9997 ext.26
cvanmels@newbook.com
=============================================

Notes:
=====

v.0.2:
=====
	- need improved handling for multiple @warningRef
	  e.g. change:

         <proceduralStep warningRefs="warn-0008 warn-0009">...</proceduralStep>

         to

         <addwarning warningRef="warn-0008"/>
         <addwarning warningRef="warn-0009"/>
         <proceduralStep warningRefs="warn-0008 warn-0009">...</proceduralStep>


	- also do similarly for "proceduralStep/@cautionRefs"

	- other cases (e.g. <levelledPara cautionRefs="caut-0035 caut-0041 caut-0034">)
	  may need to be considered, too


v.0.1:
=====
	- collect "pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts" to
          first "pmEntry/dmContent/dmodule"

          (NOTE: will need separate XSLT phase to filter out duplicate entries)

        - simple swap to make Styler processing easier, change:

          <figure><title/><graphic/></figure>
          to
          <figure><graphic/><title/></figure>
-->


<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink">


<!-- CV - @indent="yes" produces readable XML,
          but introduces leading space in table entries with bold:
            <entry>
              <b>TEXT</b>
            </entry>

        - use @indent="no" for final XML
          -->
<xsl:output method="xml"
            media-type="text/xml"
            encoding="UTF-8"
            indent="no"
            />

<!-- <xsl:strip-space elements="*"/> -->


<!-- CV - almost everything should just flow through -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
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

<!-- ********************************************** -->
<!-- Collect "preliminaryRqmts" into first
     "pmEntry/dmContent/dmodule/content/procedure"
     -->

<!-- Suppress the multiple instances of "preliminaryRqmts" -->
<xsl:template match="pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts"/>

<!-- Construct single instance of "preliminaryRqmts" inside first "pmEntry//procedure" -->
<xsl:template match="pmEntry/dmContent[1]/dmodule/content/procedure">

  <xsl:text>&#xA;</xsl:text>
  <xsl:text>&#xA;</xsl:text>
  <procedure>
    <xsl:apply-templates select="@*"/>

    <xsl:text>&#xA;</xsl:text>
    <preliminaryRqmts>

     <!-- 1. "reqCondGroup" -->
     <xsl:text>&#xA;</xsl:text>
     <reqCondGroup>

      <xsl:for-each select="ancestor::pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts/reqCondGroup">
       <xsl:choose>
        <xsl:when test="noConds">
         <!-- suppress real "noConds" entries (if required, there should only be one)-->
        </xsl:when>
        <xsl:otherwise>
         <xsl:copy-of select="node()"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:for-each>

     <xsl:text>&#xA;</xsl:text>
     </reqCondGroup>


     <!-- 2. "reqSupportEquips/supportEquipDescrGroup" -->
     <xsl:text>&#xA;</xsl:text>
     <reqSupportEquips>
      <xsl:text>&#xA;</xsl:text>
      <supportEquipDescrGroup>

      <xsl:for-each select="ancestor::pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts/reqSupportEquips/supportEquipDescrGroup/supportEquipDescr">
       <xsl:sort select="name"/>
       <supportEquipDescr>
        <xsl:apply-templates select="@*"/>
        <xsl:copy-of select="node()"/>
       </supportEquipDescr>
      </xsl:for-each>

      <xsl:text>&#xA;</xsl:text>
      </supportEquipDescrGroup>
     <xsl:text>&#xA;</xsl:text>
     </reqSupportEquips>

     <!-- 3. "reqSupplies/supplyDescrGroup/supplyDescr" -->
     <xsl:text>&#xA;</xsl:text>
     <reqSupplies>
      <xsl:text>&#xA;</xsl:text>
      <supplyDescrGroup>

      <xsl:for-each select="ancestor::pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts/reqSupplies/supplyDescrGroup/supplyDescr">
       <xsl:sort select="name"/>
       <supplyDescr>
        <xsl:apply-templates select="@*"/>
        <xsl:copy-of select="node()"/>
       </supplyDescr>
      </xsl:for-each>

      <xsl:text>&#xA;</xsl:text>
      </supplyDescrGroup>
     <xsl:text>&#xA;</xsl:text>
     </reqSupplies>

     <!-- 4. "reqSpares/spareDescrGroup/spareDescr" -->
     <xsl:text>&#xA;</xsl:text>
     <reqSpares>
      <xsl:text>&#xA;</xsl:text>
      <spareDescrGroup>

      <xsl:for-each select="ancestor::pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts/reqSpares/spareDescrGroup/spareDescr">
       <spareDescr>
        <xsl:apply-templates select="@*"/>
        <xsl:copy-of select="node()"/>
       </spareDescr>
      </xsl:for-each>

      <xsl:text>&#xA;</xsl:text>
      </spareDescrGroup>
     <xsl:text>&#xA;</xsl:text>
     </reqSpares>

     <!-- 5. "reqSafety" -->
     <xsl:text>&#xA;</xsl:text>
     <reqSafety>

      <xsl:for-each select="ancestor::pmEntry/dmContent/dmodule/content/procedure/preliminaryRqmts/reqSafety">
       <xsl:choose>
        <xsl:when test="noSafety">
         <!-- suppress real "noSafety" entries (if required, there should only be one)-->
        </xsl:when>
        <xsl:otherwise>
         <xsl:copy-of select="node()"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:for-each>

     <xsl:text>&#xA;</xsl:text>
     </reqSafety>


    <xsl:text>&#xA;</xsl:text>
    </preliminaryRqmts>
    <xsl:text>&#xA;</xsl:text>

    <xsl:apply-templates/>

  <xsl:text>&#xA;</xsl:text>
  </procedure>
  <xsl:text>&#xA;</xsl:text>
  <xsl:text>&#xA;</xsl:text>

</xsl:template>

<!-- ********************************************** -->

<!-- ********************************************** -->
<!-- Swap "title" and "graphic" element location
     inside "figure" element

     (NOTE: - this is a little bit dangerous
            - reconstructing the "figure" element,
              does it ever have any children
              other than "title" and "graphic")
     -->
<xsl:template match="figure[(count(title)=1) and (count(graphic) &gt; 0)]">

  <figure>
    <xsl:apply-templates select="@*"/>

    <xsl:copy-of select="graphic"/>

    <xsl:copy-of select="title"/>

  </figure>

</xsl:template>

<!-- ********************************************** -->


<!-- ********************************************** -->
<!-- Breakout @warningRefs and @cautionRefs which
     could contain more than one item

     e.g.
     <proceduralStep warningRefs="warn-0008 warn-0009">...</proceduralStep>

     becomes

     <addwarning warningRef="warn-0008"/>
     <addwarning warningRef="warn-0009"/>
     <proceduralStep warningRefs="warn-0008 warn-0009">...</proceduralStep>


     )
     -->

<!-- RS: Just handle proceduralSteps for now. -->
<!-- <xsl:template match="proceduralStep|levelledPara"> -->
<xsl:template match="proceduralStep">

  <xsl:if test="normalize-space(@warningRefs)">
   <xsl:call-template name="CREATE_addwarning">
    <xsl:with-param name="refs"><xsl:value-of select="normalize-space(@warningRefs)"/></xsl:with-param>
   </xsl:call-template>
  </xsl:if>

  <xsl:if test="normalize-space(@cautionRefs)">
   <xsl:call-template name="CREATE_addcaution">
    <xsl:with-param name="refs"><xsl:value-of select="normalize-space(@cautionRefs)"/></xsl:with-param>
   </xsl:call-template>
  </xsl:if>

  <xsl:element name="{name()}">
   <xsl:apply-templates select="@*"/>
   <xsl:apply-templates/>
  </xsl:element>

<!-- The following version makes the warnings and cautions inside the proceduralStep:
  <xsl:element name="{name()}">
   <xsl:apply-templates select="@*"/>

   <xsl:if test="normalize-space(@warningRefs)">
    <xsl:call-template name="CREATE_addwarning">
     <xsl:with-param name="refs"><xsl:value-of select="normalize-space(@warningRefs)"/></xsl:with-param>
    </xsl:call-template>
   </xsl:if>

   <xsl:if test="normalize-space(@cautionRefs)">
    <xsl:call-template name="CREATE_addcaution">
     <xsl:with-param name="refs"><xsl:value-of select="normalize-space(@cautionRefs)"/></xsl:with-param>
    </xsl:call-template>
   </xsl:if>

   <xsl:apply-templates/>

  </xsl:element>
-->

</xsl:template>


<xsl:template name="CREATE_addwarning">
 <xsl:param name="refs"/>

 <xsl:choose>

  <!-- CV - if no space, then there's only one reference -->
  <xsl:when test="not(contains($refs, ' '))">
    <addwarning warningRef="{$refs}"/>
    <!-- <xsl:comment> *** SINGLE REF *** </xsl:comment> -->
    <xsl:text>&#xA;</xsl:text>
  </xsl:when>

  <xsl:otherwise>
   <xsl:variable name="first_ref" select="substring-before($refs, ' ')"/>
   <xsl:variable name="more_ref" select="substring-after($refs, ' ')"/>
   <addwarning warningRef="{$first_ref}"/>
   <!-- <xsl:comment> *** NEED RECURSION *** </xsl:comment> -->
   <xsl:text>&#xA;</xsl:text>
   <xsl:call-template name="CREATE_addwarning">
    <xsl:with-param name="refs"><xsl:value-of select="$more_ref"/></xsl:with-param>
   </xsl:call-template>
  </xsl:otherwise>

 </xsl:choose>

</xsl:template>


<xsl:template name="CREATE_addcaution">
 <xsl:param name="refs"/>

 <xsl:choose>

  <!-- CV - if no space, then there's only one reference -->
  <xsl:when test="not(contains($refs, ' '))">
    <addcaution cautionRef="{$refs}"/>
    <!-- <xsl:comment> *** SINGLE REF *** </xsl:comment> -->
    <xsl:text>&#xA;</xsl:text>
  </xsl:when>

  <xsl:otherwise>
   <xsl:variable name="first_ref" select="substring-before($refs, ' ')"/>
   <xsl:variable name="more_ref" select="substring-after($refs, ' ')"/>
   <addcaution cautionRef="{$first_ref}"/>
   <!-- <xsl:comment> *** NEED RECURSION *** </xsl:comment> -->
   <xsl:text>&#xA;</xsl:text>
   <xsl:call-template name="CREATE_addcaution">
    <xsl:with-param name="refs"><xsl:value-of select="$more_ref"/></xsl:with-param>
   </xsl:call-template>
  </xsl:otherwise>

 </xsl:choose>

</xsl:template>


<!-- ********************************************** -->






</xsl:stylesheet>
