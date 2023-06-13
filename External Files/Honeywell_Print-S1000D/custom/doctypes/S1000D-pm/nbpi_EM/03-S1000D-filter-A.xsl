<?xml version="1.0"  encoding="UTF-8" ?>

<!--
==============================================
Collect various requirements table items from
throughout the document to central locations
==============================================

S1000D-filter-A.xsl

Created: April 25, 2013

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

v.0.3:
=====
	- use <xsl:strip-space elements="entry"/> to remove white space that would sometimes occur
	  due to line breaks before "para" elements
	  
	 e.g.
         
         <entry>
         <para>Ambient Temperature Range</para>
         </entry>
         
         would become:
         <entry> <para>Ambient Temperature Range</para> </entry>
         
         and now it will be:
         <entry><para>Ambient Temperature Range</para></entry>
         
	- all "figure" should have an @id
	  (generate a unique id if doesn't exist)
	

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


<xsl:strip-space elements="entry"/>

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
<!-- Swap "title" and "graphic" element location
     inside "figure" element

     (NOTE: - this is a little bit dangerous
            - reconstructing the "figure" element,
              does it ever have any children
              other than "title" and "graphic")
     UPDATE (RS): Yes: it also has legend (that is all). Now added after title.
     -->

<xsl:template match="figure[(count(title)=1) and (count(graphic) &gt; 0)]">
	<xsl:variable name="id">  
	   <xsl:choose>
		<xsl:when test="@id">
		 <xsl:value-of select="@id"/>
		</xsl:when>
		<xsl:otherwise>
		 <xsl:text>DMC-MISSING-ID-</xsl:text>
		 <xsl:value-of select="generate-id()"/>
		</xsl:otherwise>
	   </xsl:choose>
	</xsl:variable>
  <figure>
    <xsl:apply-templates select="@*"/>
	<xsl:attribute name="id">
		<xsl:value-of select="$id"/>
	</xsl:attribute>
    <xsl:apply-templates select="graphic"/>
    <!--<xsl:copy-of select="graphic"/>-->

    <!--<xsl:copy-of select="title"/>-->
    <xsl:apply-templates select="title"/>

    <xsl:apply-templates select="legend"/>
    <!--<xsl:copy-of select="legend"/>-->
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

<xsl:template match="proceduralStep | levelledPara">

  <!-- UPDATE: Also add subtask number based on authorityDocument attribute (hard for Styler -->
  <!-- to place before warnings and cautions otherwise, and avoids complicating the conditionals in proceduralStep) -->
  <xsl:if test="@authorityDocument">
    <subtask number="{@authorityDocument}"/>
  </xsl:if>

  <!-- RS: Now also move warning/caution tags out of the procedure step to place before addwarnings and addcautions -->
  <!-- (since they can't be formatted before the procedure step number by the stylesheet) -->
  <xsl:copy-of select="warning|caution"/>
  
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
   <!-- Also add a unique id for proceduralSteps that contain reasonForUpdateRefIds, so -->
   <!-- they can be referred to in the Table of Highlights. -->
   <!-- For S1000D we need an ID for all of them, since they are linked from the ToC as well -->
   <!-- Output the id attribute if it already exists, or add one when the proceduralStep contains reasonForUpdateRefIds. -->
   <xsl:choose>
    <xsl:when test="@id">
     <xsl:attribute name="id">
      <xsl:value-of select="@id"/>
     </xsl:attribute>
    </xsl:when>
    <!--<xsl:when test="descendant-or-self::*[@reasonForUpdateRefIds]">
     <xsl:attribute name="id">
      <xsl:text>ps-</xsl:text>
      <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
    </xsl:when>-->
    <xsl:otherwise>
      <xsl:attribute name="id">
        <xsl:text>ps-</xsl:text>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
    </xsl:otherwise>
   </xsl:choose>
   
   <!-- Output the rest of the attributes -->
   <xsl:apply-templates select="@*[name()!='id']"/>
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

<!-- Create an id for paras, notes, noteParas, listItems, and titles that have a reasonForUpdateRefIds -->
<xsl:template match="para | notePara | note | title | definitionListItem | listItem | listItemTerm | attentionListItemPara">
  <xsl:element name="{name()}">
  <xsl:choose>
    <xsl:when test="@id">
     <xsl:attribute name="id">
      <xsl:value-of select="@id"/>
     </xsl:attribute>
    </xsl:when>
    <xsl:when test="@reasonForUpdateRefIds">
     <xsl:attribute name="id">
      <xsl:text>gen-</xsl:text>
      <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
    </xsl:when>
   </xsl:choose>
   
   <!-- Output the rest of the attributes -->
   <xsl:apply-templates select="@*[name()!='id']"/>
   <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- Create an id for legends that have a reasonForUpdateRefIds within it (for something to link to from the table of highlights) -->
<xsl:template match="legend">
  <xsl:element name="legend">
   <xsl:choose>
    <xsl:when test="@id">
     <xsl:attribute name="id">
      <xsl:value-of select="@id"/>
     </xsl:attribute>
    </xsl:when>
    <xsl:when test="descendant-or-self::*[@reasonForUpdateRefIds]">
     <xsl:attribute name="id">
      <xsl:text>legend-</xsl:text>
      <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
    </xsl:when>
   </xsl:choose>
   
   <!-- Output the rest of the attributes -->
   <xsl:apply-templates select="@*[name()!='id']"/>
   <xsl:apply-templates/>
  </xsl:element>
</xsl:template>


<!-- RS: Remove warnings/cautions from proceduralSteps (added before the proceduralStep above) -->
<xsl:template match="proceduralStep/warning|proceduralStep/caution"/>

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

<!-- ******************************************************************* -->
<!-- RS: Remove any empty closing requirement blocks (they should have -->
<!-- a "noConds" element instead of content OR be empty). -->
<xsl:template match="closeRqmts[recCondGroup/noConds]"/>
<xsl:template match="closeRqmts[count(recCondGroup/*)=0]"/>


<!-- ******************************************************************* -->
<!-- RS: Added removing "noConds", "noSafety", "noSpares", "noSupplies", -->
<!-- and "noSupportEquips" entries in preliminary requirement tables. -->

<xsl:template match="noConds"/>
<xsl:template match="noSafety"/>
<xsl:template match="noSpares"/>
<xsl:template match="noSupplies"/>
<xsl:template match="noSupportEquips"/>


<!-- ******************************************************************* -->
<!-- [RS: Copied from old 03-S1000D-filter-D.xsl] -->
<!-- Remove repeated "acronym" wrappers -->

<xsl:template match="acronym">
  
  <xsl:variable name="current_acronymTerm" select="normalize-space(acronymTerm)"/>
  
  <xsl:choose>
   <xsl:when test="not(preceding::acronym/acronymTerm = $current_acronymTerm)">
    <acronym>
     <xsl:apply-templates select="@*"/>
     <xsl:apply-templates/>
    </acronym>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$current_acronymTerm"/>
   </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<!-- ******************************************************************* -->
<!-- Unique id for figures, graphics, legends, and tables if they doesn't exist -->
<!-- (to make sure there's an ID we can link to for table of highlights, xrefs, etc.) -->

<xsl:template match="figure | graphic | table | legend">
  
  <xsl:variable name="id">  
   <xsl:choose>
    <xsl:when test="@id">
     <xsl:value-of select="@id"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>gen-</xsl:text>
     <xsl:value-of select="generate-id()"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:element name="{name()}">
   <xsl:attribute name="id">
    <xsl:value-of select="$id"/>
   </xsl:attribute>
   <!-- Output the rest of the attributes -->
   <xsl:apply-templates select="@*[name()!='id']"/>
   <xsl:apply-templates/>
  </xsl:element>

</xsl:template>


<!-- And a unique ID for pmEntry -->
<xsl:template match="pmEntry">
  <pmEntry>
    <xsl:attribute name="id">
      <xsl:text>pme-</xsl:text>
      <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
    <!-- Output the rest of the attributes -->
    <xsl:apply-templates select="@*[name()!='id']"/>
    <xsl:apply-templates/>
  </pmEntry>
</xsl:template>



</xsl:stylesheet>
