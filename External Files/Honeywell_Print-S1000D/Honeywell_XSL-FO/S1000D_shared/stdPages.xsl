<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

	<xsl:variable name="debug-pagesets" select="false()"/>
	
   <!-- stdPages.xsl - Sub-stylesheet containing page definitions                                                -->
   <!--                                                                                                          -->
   <!-- This stylesheet contains master page definitions for EM, EIPC, and CMM  It is included   -->
   <!-- in the master stylesheet.                                                                            -->

   <!-- Named template for page definitions for the EM -->

   <xsl:attribute-set name="odd-page-layout">
      <xsl:attribute name="page-width">8.5in</xsl:attribute>
      <xsl:attribute name="page-height">11in</xsl:attribute>
      <xsl:attribute name="margin-left">1.1in</xsl:attribute>
      <xsl:attribute name="margin-right">.62in</xsl:attribute>
      <xsl:attribute name="margin-top">.21in</xsl:attribute>
      <xsl:attribute name="margin-bottom">.21in</xsl:attribute>
   </xsl:attribute-set>
  
  <xsl:attribute-set name="first-page-layout">
      <xsl:attribute name="page-width">8.5in</xsl:attribute>
      <xsl:attribute name="page-height">11in</xsl:attribute>
      <xsl:attribute name="margin-left">1.1in</xsl:attribute>
      <xsl:attribute name="margin-right">0.62in</xsl:attribute>
      <xsl:attribute name="margin-top">0.21in</xsl:attribute>
      <!-- RS: Was 2.85 bottom margin: space at the bottom of title page for export statement etc. Made bigger -->
      <!-- NOTE: This will need to be more flexible based on the export statement size: needs a proper footer area. -->
<!-- 	  <xsl:attribute name="margin-bottom">3.0in</xsl:attribute> -->
	  <xsl:attribute name="margin-bottom">0.11in</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="even-page-layout">
      <xsl:attribute name="page-width">8.5in</xsl:attribute>
      <xsl:attribute name="page-height">11in</xsl:attribute>
      <xsl:attribute name="margin-left">.62in</xsl:attribute>
      <xsl:attribute name="margin-right">1.1in</xsl:attribute>
      <xsl:attribute name="margin-top">.21in</xsl:attribute>
      <xsl:attribute name="margin-bottom">.21in</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="region-body-attributes">
      <xsl:attribute name="margin-left">0in</xsl:attribute>
      <xsl:attribute name="margin-right">0in</xsl:attribute>
      <xsl:attribute name="margin-top">1.0in</xsl:attribute><!-- 1.0in -->
      <xsl:attribute name="margin-bottom">.75in</xsl:attribute>
   </xsl:attribute-set>
  
    <xsl:attribute-set name="landscape-region-body-attributes">
      <xsl:attribute name="margin-left">0in</xsl:attribute>
      <xsl:attribute name="margin-right">0in</xsl:attribute>
      <xsl:attribute name="margin-top">1.1in</xsl:attribute>
      <xsl:attribute name="margin-bottom">.75in</xsl:attribute>
      <xsl:attribute name="reference-orientation">90</xsl:attribute>   
    </xsl:attribute-set>
  
  <!-- CJM : OCSHONSS-486 : START landscape layouts -->
  <xsl:attribute-set name="cmm-landscape-region-body-attributes">
    <xsl:attribute name="margin-left">0in</xsl:attribute>
    <xsl:attribute name="margin-right">0in</xsl:attribute>
    <xsl:attribute name="margin-top">0in</xsl:attribute><!-- CJM : OCSHONSS-499 : Changed from 1.1in to 0 in -->
    <xsl:attribute name="margin-bottom">0in</xsl:attribute><!-- CJM : OCSHONSS-499 : Changed from 0.75in to 0 in -->
  </xsl:attribute-set>
  
  <xsl:attribute-set name="landscape-odd-page-layout">
    <xsl:attribute name="page-width">11in</xsl:attribute>
    <xsl:attribute name="page-height">8.5in</xsl:attribute>
    <xsl:attribute name="margin-left">.21in</xsl:attribute>
    <xsl:attribute name="margin-right">.21in</xsl:attribute>
    <xsl:attribute name="margin-top">1.1in</xsl:attribute>
    <xsl:attribute name="margin-bottom">.62in</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="landscape-even-page-layout">
    <xsl:attribute name="page-width">11in</xsl:attribute>
    <xsl:attribute name="page-height">8.5in</xsl:attribute>
    <xsl:attribute name="margin-left">.21in</xsl:attribute>
    <xsl:attribute name="margin-right">.21in</xsl:attribute>
    <xsl:attribute name="margin-top">.62in</xsl:attribute>
    <xsl:attribute name="margin-bottom">1.1in</xsl:attribute>
  </xsl:attribute-set>
  <!-- CJM : OCSHONSS-486 : END landscape layouts -->
  
   <xsl:attribute-set name="region.after">
      <xsl:attribute name="extent">.625in</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="region.before">
      <xsl:attribute name="extent">1.125in</xsl:attribute><!-- 1.125in -->
   </xsl:attribute-set>
  
  <!-- CJM : OCSHONSS-481 : Added CMM Title Region After attribute set -->
   <xsl:attribute-set name="cmm.title.region.after">
     <xsl:attribute name="extent">
       <xsl:choose>
         <xsl:when test="count(//EXPRTCL) &gt; 1">5in</xsl:when>
         <xsl:otherwise>2in</xsl:otherwise>
     </xsl:choose>
     </xsl:attribute>
   </xsl:attribute-set>
  
  <xsl:attribute-set name="title.region.after">
    <xsl:attribute name="extent">4in</xsl:attribute><!-- 1.5in -->
  </xsl:attribute-set>

   <xsl:attribute-set name="lep.region.after">
      <xsl:attribute name="extent">1.127in</xsl:attribute><!-- 1.25in -->
   </xsl:attribute-set>

   <xsl:attribute-set name="lep.header.cell">
      <xsl:attribute name="padding-top">8.5pt</xsl:attribute>
      <xsl:attribute name="padding-bottom">8.5pt</xsl:attribute>
      <xsl:attribute name="text-align">center</xsl:attribute>
   </xsl:attribute-set>

   <!-- Spacing and other attributes for the body region of the LEP -->
   <xsl:attribute-set name="lep.region.body.attributes">
      <xsl:attribute name="margin-left">0in</xsl:attribute>
      <xsl:attribute name="margin-right">0in</xsl:attribute>
      <!-- margin top and bottom control where the LEP table sits on the page -->
      <xsl:attribute name="margin-top">1.9in</xsl:attribute>
      <xsl:attribute name="margin-bottom">1.3in</xsl:attribute><!-- 1.5in -->
    <!-- 
      <xsl:attribute name="margin-top">2in</xsl:attribute>
      <xsl:attribute name="margin-bottom">2in</xsl:attribute> -->
      <xsl:attribute name="column-count">2</xsl:attribute>
      <xsl:attribute name="column-gap">24pt</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="watermark.attributes">
      <xsl:attribute name="background-image">
         <xsl:value-of select="$globalRegionbodyWatermark"/>
      </xsl:attribute>
      <xsl:attribute name="background-image">
         <xsl:value-of select="$globalRegionbodyWatermark"/>
      </xsl:attribute>
      <xsl:attribute name="background-repeat">no-repeat</xsl:attribute>
      <xsl:attribute name="background-position-horizontal">center</xsl:attribute>
      <xsl:attribute name="background-position-vertical">center</xsl:attribute>
   </xsl:attribute-set>

   <xsl:template name="define-pagesets">
      <fo:layout-master-set>

         <!-- Cover page -->
         <fo:simple-page-master master-name="First_Page" xsl:use-attribute-sets="first-page-layout">
           <fo:region-body xsl:use-attribute-sets="watermark.attributes" margin-bottom="3.26in">
	           <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">dashed green 4pt</xsl:attribute>
			   </xsl:if>
           </fo:region-body>
           
           <!-- RS: The footer height is based on the location of the start of the legal notice text in Styler -->
           <!-- (also taking into account the 1.1in bottom margin of the FO page master). -->
           <fo:region-after extent="3.26in" region-name="First_Page_regionafter">
	           <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">dashed fuchsia 2pt</xsl:attribute>
			   </xsl:if>
           </fo:region-after>
           
           <!-- [ATA] CJM : OCSHONSS-481 : Added CMM test to apply the correct attribute set -->
           <!-- <xsl:choose>
             <xsl:when test="/CMM">
               <fo:region-after xsl:use-attribute-sets="cmm.title.region.after" region-name="First_Page_regionafter"/>
             </xsl:when>
             <xsl:otherwise>
               <fo:region-after xsl:use-attribute-sets="title.region.after" region-name="First_Page_regionafter"/> 
             </xsl:otherwise>
           </xsl:choose> -->
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Blank_Even_Page" xsl:use-attribute-sets="even-page-layout">
            <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="region-body-attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
            <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-after>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Blank_Odd_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="region-body-attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
            <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-after>
         </fo:simple-page-master>
         
         <fo:simple-page-master master-name="Odd_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Odd_Page_regionbefore"/>
            <fo:region-after xsl:use-attribute-sets="region.after" region-name="Odd_Page_regionafter">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
            </fo:region-after>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Even_Page" xsl:use-attribute-sets="even-page-layout">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Even_Page_regionbefore"/>
            <fo:region-after xsl:use-attribute-sets="region.after" region-name="Even_Page_regionafter">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
            </fo:region-after>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="First_Lep_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body xsl:use-attribute-sets="lep.region.body.attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="First_Lep_Page_regionbefore" extent="1in">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-before>
            <fo:region-after xsl:use-attribute-sets="lep.region.after" region-name="First_Lep_Page_regionafter">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid red 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-after>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Odd_Lep_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body xsl:use-attribute-sets="lep.region.body.attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Odd_Lep_Page_regionbefore" extent="1in">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
			</fo:region-before>
            <fo:region-after xsl:use-attribute-sets="lep.region.after" region-name="Odd_Lep_Page_regionafter">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid green 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-after>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Even_Lep_Page" xsl:use-attribute-sets="even-page-layout">
            <fo:region-body xsl:use-attribute-sets="lep.region.body.attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Even_Lep_Page_regionbefore" extent="1in"><!-- Was 2in, but odd page uses 1in -->
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid blue 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-before>
            <fo:region-after xsl:use-attribute-sets="lep.region.after" region-name="Even_Lep_Page_regionafter">
			    <xsl:if test="$debug-pagesets">
			      <xsl:attribute name="border">solid green 1pt</xsl:attribute>
			    </xsl:if>
		    </fo:region-after>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Foldout_Odd_Page" margin-left="1.1in" margin-right="0.62in" page-width="17in" margin-bottom="0.25in" margin-top="0.25in" page-height="11in">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Odd_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Odd_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Foldout_Even_Page" margin-left="1.1in" margin-right="0.62in" page-width="17in" margin-bottom="0.25in" margin-top="0.25in" page-height="11in">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes">
		    <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">solid black 1pt</xsl:attribute>
		    </xsl:if>
		    </fo:region-body>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Even_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Even_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Foldout_Blank_Even_Page" margin-left="0.62in" margin-right="9.6in" page-width="17in" margin-bottom="0.125in" margin-top="0.25in" page-height="11in">
            <fo:region-body region-name="Foldout-region-body-blank-page" xsl:use-attribute-sets="watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Blank_Even_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Blank_Even_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>
        
        
        <!--Added for landscape tables - START-->
        <xsl:choose>
          <xsl:when test="/CMM">  <!-- CJM : OCSHONSS-486 : if CMM use, landscape layouts and rotate -->
            <!-- CJM : OCSHONSS-499 : Changed Landscape Blank Even Page to mirror a normal Blank Even Page -->
            <fo:simple-page-master master-name="Landscape_Blank_Even_Page" xsl:use-attribute-sets="even-page-layout">
              <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
              <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
              <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after"/>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="Landscape_Blank_Odd_Page" xsl:use-attribute-sets="odd-page-layout">
              <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
              <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
              <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after"/>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="Landscape_Odd_Page" xsl:use-attribute-sets="landscape-odd-page-layout">
              <fo:region-body xsl:use-attribute-sets="cmm-landscape-region-body-attributes watermark.attributes"/>
              <fo:region-end xsl:use-attribute-sets="region.before" region-name="Odd_Page_regionbefore" reference-orientation="-90"/>
              <fo:region-start xsl:use-attribute-sets="region.after" region-name="Odd_Page_regionafter" reference-orientation="-90"/>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="Landscape_Even_Page" xsl:use-attribute-sets="landscape-even-page-layout">
              <fo:region-body xsl:use-attribute-sets="cmm-landscape-region-body-attributes watermark.attributes"/>
              <fo:region-end xsl:use-attribute-sets="region.before" region-name="Even_Page_regionbefore" reference-orientation="-90"/>
              <fo:region-start xsl:use-attribute-sets="region.after" region-name="Even_Page_regionafter" reference-orientation="-90"/>
            </fo:simple-page-master>
          </xsl:when>
          <xsl:otherwise>
            <fo:simple-page-master master-name="Landscape_Blank_Even_Page" xsl:use-attribute-sets="even-page-layout">
              <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="landscape-region-body-attributes watermark.attributes"/>
              <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
              <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after"/>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="Landscape_Odd_Page" xsl:use-attribute-sets="odd-page-layout">
              <fo:region-body xsl:use-attribute-sets="landscape-region-body-attributes watermark.attributes"/>
              <fo:region-before xsl:use-attribute-sets="region.before" region-name="Odd_Page_regionbefore"/>
              <fo:region-after xsl:use-attribute-sets="region.after" region-name="Odd_Page_regionafter"/>
            </fo:simple-page-master>
            
            <fo:simple-page-master master-name="Landscape_Even_Page" xsl:use-attribute-sets="even-page-layout">
              <fo:region-body xsl:use-attribute-sets="landscape-region-body-attributes watermark.attributes"/>
              <fo:region-before xsl:use-attribute-sets="region.before" region-name="Even_Page_regionbefore"/>
              <fo:region-after xsl:use-attribute-sets="region.after" region-name="Even_Page_regionafter"/>
            </fo:simple-page-master>
          </xsl:otherwise>
        </xsl:choose>
        <!--Added for landscape tables - END-->


         <fo:page-sequence-master master-name="Title">
            <fo:single-page-master-reference master-reference="First_Page"/>
            <fo:repeatable-page-master-alternatives>
               <fo:conditional-page-master-reference master-reference="Blank_Even_Page" blank-or-not-blank="blank"/>
               <fo:conditional-page-master-reference master-reference="Odd_Page" odd-or-even="odd"/>
               <fo:conditional-page-master-reference master-reference="Even_Page" odd-or-even="even"/>
            </fo:repeatable-page-master-alternatives>
         </fo:page-sequence-master>


         <fo:page-sequence-master master-name="Body">
            <fo:repeatable-page-master-alternatives>
               <!--<fo:conditional-page-master-reference master-reference="Blank_Even_Page"
            blank-or-not-blank="blank" odd-or-even="even" page-position="last"/>-->
               <fo:conditional-page-master-reference master-reference="Blank_Even_Page" blank-or-not-blank="blank" odd-or-even="even"/>
               <fo:conditional-page-master-reference master-reference="Blank_Odd_Page" blank-or-not-blank="blank" odd-or-even="odd"/>
               <fo:conditional-page-master-reference master-reference="Odd_Page" odd-or-even="odd" blank-or-not-blank="not-blank"/>
               <fo:conditional-page-master-reference master-reference="Even_Page" odd-or-even="even" blank-or-not-blank="not-blank"/>
            </fo:repeatable-page-master-alternatives>
         </fo:page-sequence-master>
        
        <!--Added for landscape tables - START-->
        <fo:page-sequence-master master-name="Landscape-Table">
          <fo:repeatable-page-master-alternatives>
            <fo:conditional-page-master-reference master-reference="Landscape_Blank_Even_Page" blank-or-not-blank="blank" odd-or-even="even"/>
            <fo:conditional-page-master-reference master-reference="Landscape_Odd_Page" odd-or-even="odd" blank-or-not-blank="not-blank"/>
            <fo:conditional-page-master-reference master-reference="Landscape_Even_Page" odd-or-even="even" blank-or-not-blank="not-blank"/>
          </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
        <!--Added for landscape tables - END-->

          <!-- Added page for deleted figures. (mantis 13093) -->
          <fo:page-sequence-master master-name="Body-Figure">
              <fo:repeatable-page-master-alternatives>
                  <fo:conditional-page-master-reference master-reference="Blank_Even_Page" blank-or-not-blank="blank"/>
                  <fo:conditional-page-master-reference master-reference="Odd_Page" odd-or-even="odd"/>
                  <fo:conditional-page-master-reference master-reference="Even_Page" odd-or-even="even"/>
              </fo:repeatable-page-master-alternatives>
          </fo:page-sequence-master>
          

         <fo:page-sequence-master master-name="Body-Figure-Even">
            <fo:repeatable-page-master-alternatives>
               <fo:conditional-page-master-reference master-reference="Blank_Even_Page" blank-or-not-blank="blank"/>
               <fo:conditional-page-master-reference master-reference="Odd_Page" odd-or-even="odd"/>
               <fo:conditional-page-master-reference master-reference="Even_Page" odd-or-even="even"/>
            </fo:repeatable-page-master-alternatives>
         </fo:page-sequence-master>

         <fo:page-sequence-master master-name="Body-Figure-Odd">
            <fo:repeatable-page-master-alternatives>
               <fo:conditional-page-master-reference master-reference="Blank_Odd_Page" blank-or-not-blank="blank"/>
               <fo:conditional-page-master-reference master-reference="Odd_Page" odd-or-even="odd"/>
               <fo:conditional-page-master-reference master-reference="Even_Page" odd-or-even="even"/>
            </fo:repeatable-page-master-alternatives>
         </fo:page-sequence-master>
         
         <fo:page-sequence-master master-name="Lep">
            <fo:single-page-master-reference master-reference="First_Lep_Page"/>
            <fo:repeatable-page-master-alternatives>
               <fo:conditional-page-master-reference master-reference="Blank_Even_Page" blank-or-not-blank="blank"/>
               <fo:conditional-page-master-reference master-reference="Odd_Lep_Page" odd-or-even="odd"/>
               <fo:conditional-page-master-reference master-reference="Even_Lep_Page" odd-or-even="even"/>
            </fo:repeatable-page-master-alternatives>
         </fo:page-sequence-master>



         <fo:page-sequence-master master-name="Foldout">
            <fo:repeatable-page-master-alternatives>
               <fo:conditional-page-master-reference master-reference="Foldout_Blank_Even_Page" odd-or-even="even" blank-or-not-blank="blank"/>
               <fo:conditional-page-master-reference master-reference="Foldout_Odd_Page" odd-or-even="odd"/>
               <fo:conditional-page-master-reference master-reference="Foldout_Even_Page" odd-or-even="even"/>
            </fo:repeatable-page-master-alternatives>
         </fo:page-sequence-master>

      </fo:layout-master-set>
   </xsl:template>

   <!-- Initialize the title page sequence -->
   <xsl:template name="init-title-sequence-static">
      <xsl:param name="page-prefix" select="''"/>
      <fo:static-content flow-name="First_Page_regionafter">
         <xsl:call-template name="title-page-footer">
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Even_Page_regionbefore">
        <xsl:call-template name="evenPageRegionBeforeStaticContent"/>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>

      <fo:static-content flow-name="Even_Page_regionafter">
         <xsl:call-template name="title-section-footer">
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
         </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Odd_Page_regionbefore">
        <xsl:call-template name="oddPageRegionBeforeStaticContent"/>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>
      <fo:static-content flow-name="Odd_Page_regionafter">
         <xsl:call-template name="title-section-footer">
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
         </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Blank_Page_regionbefore">
        <xsl:call-template name="evenPageRegionBeforeStaticContent"> </xsl:call-template>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>
      <!-- 2020-09-02 Update Start -->
      <xsl:variable name="suppressAtacode">
        <xsl:choose>
          <xsl:when test="$documentType ='eipc'">0</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <fo:static-content flow-name="Blank_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="page-prefix" select="'T-'"/>
            <xsl:with-param name="isChapterLep" select="0"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
            <!-- 2020-09-02 Update End -->
            <!-- Don't output effectivity box for blank title pages -->
            <xsl:with-param name="suppressEffectivity" select="true()"/>
            
            <!-- DJH TEST 20090831 -->
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Blank_Page_Body">
         <fo:block text-align="center" font-size="10pt" margin-top="4in">
            <xsl:text>Blank Page</xsl:text>
         </fo:block>
      </fo:static-content>
   </xsl:template>

   <!-- Set up the header and footer for the LEP. If it is the front-matter LEP, parameter isIntroToc will be "1". -->
   <xsl:template name="init-static-content-lep">
      <xsl:param name="suppressAtacode" select="0"/>
      <xsl:param name="isIntroToc" select="0"/>
      <!-- DJH TEST 20090831 -->
      <fo:static-content flow-name="First_Lep_Page_regionbefore">
        <xsl:call-template name="draft-as-of"/>
         <xsl:call-template name="set-lep-header">
            <xsl:with-param name="isFirst">1</xsl:with-param>
         </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="First_Lep_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="'LEP-'"/>
            <xsl:with-param name="writeLepLegend" select="1"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
            <xsl:with-param name="isChapterLep" select="if ($isIntroToc = 1) then 0 else 1"/>
            <!-- DJH TEST 20090831 -->
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Odd_Lep_Page_regionbefore">
        <xsl:call-template name="draft-as-of"/>
         <xsl:call-template name="set-lep-header"> </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Odd_Lep_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="'LEP-'"/>
            <xsl:with-param name="writeLepLegend" select="1"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
            <xsl:with-param name="isChapterLep" select="if ($isIntroToc = 1) then 0 else 1"/>
            <!-- DJH TEST 20090831 -->
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Even_Lep_Page_regionbefore">
        <xsl:call-template name="draft-as-of"/>
        <xsl:call-template name="set-lep-header"> </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Even_Lep_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="'LEP-'"/>
            <xsl:with-param name="isChapterLep" select="if ($isIntroToc = 1) then 0 else 1"/>
            <xsl:with-param name="writeLepLegend" select="1"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
            <!-- DJH TEST 20090831 -->
         </xsl:call-template>
      </fo:static-content>


      <fo:static-content flow-name="Blank_Page_regionbefore">
        <xsl:call-template name="evenPageRegionBeforeStaticContent"> </xsl:call-template>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>

      <fo:static-content flow-name="Blank_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="'LEP-'"/>
            <xsl:with-param name="isChapterLep" select="if ($isIntroToc = 1) then 0 else 1"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
            <!-- DJH TEST 20090831 -->
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Blank_Page_Body">
         <fo:block text-align="center" font-size="10pt" margin-top="4in">
            <xsl:text>Blank Page</xsl:text>
         </fo:block>
      </fo:static-content>

   </xsl:template>

  <xsl:template name="draft-as-of">
    <xsl:if test="/CMM[@OVERLAYFORMATSTYLE='draft']">
      <fo:block-container position="absolute" top="0in" left="5in" font-size="12pt" font-weight="bold">
        <fo:block>Draft as of <xsl:value-of select="$draftDate"/></fo:block>
      </fo:block-container>          
    </xsl:if>
  </xsl:template>

   <xsl:template name="init-static-content">
      <xsl:param name="page-prefix"/>
      <xsl:param name="page-suffix"/>
      <xsl:param name="pgblk-confnbr"/>
      <xsl:param name="pgblk-effect"/>
      <xsl:param name="isChapterToc" select="0"/>
      <xsl:param name="isIntroToc" select="0"/>
      <xsl:param name="isChapterLep" select="0"/>
      <xsl:param name="suppressAtacode" select="0"/>
      <fo:static-content flow-name="Even_Page_regionbefore">
        <xsl:call-template name="evenPageRegionBeforeStaticContent"> </xsl:call-template>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>

      <fo:static-content flow-name="Even_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
            <xsl:with-param name="page-suffix" select="$page-suffix"/>
            <xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr"/>
            <xsl:with-param name="pgblk-effect" select="$pgblk-effect"/>
            <xsl:with-param name="isChapterToc" select="$isChapterToc"/>
            <xsl:with-param name="isChapterLep" select="$isChapterLep"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
         </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Odd_Page_regionbefore">
        <xsl:call-template name="oddPageRegionBeforeStaticContent"> </xsl:call-template>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>
      <fo:static-content flow-name="Odd_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
            <xsl:with-param name="page-suffix" select="$page-suffix"/>
            <xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr"/>
            <xsl:with-param name="pgblk-effect" select="$pgblk-effect"/>
            <xsl:with-param name="isChapterToc" select="$isChapterToc"/>
            <xsl:with-param name="isChapterLep" select="$isChapterLep"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
         </xsl:call-template>
      </fo:static-content>
      <fo:static-content flow-name="Blank_Page_regionbefore">
        <xsl:call-template name="evenPageRegionBeforeStaticContent">
          <xsl:with-param name="page-prefix" select="$page-prefix"/>
          <xsl:with-param name="page-suffix" select="$page-suffix"/>
          <xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr"/>
          <xsl:with-param name="pgblk-effect" select="$pgblk-effect"/>
        </xsl:call-template>
        <xsl:call-template name="draft-as-of"/>
      </fo:static-content>
      <fo:static-content flow-name="Blank_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="isIntroToc" select="$isIntroToc"/>
            <xsl:with-param name="page-prefix" select="$page-prefix"/>
            <xsl:with-param name="page-suffix" select="$page-suffix"/>
            <xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr"/>
            <xsl:with-param name="pgblk-effect" select="$pgblk-effect"/>
            <xsl:with-param name="isChapterToc" select="$isChapterToc"/>
            <xsl:with-param name="isChapterLep" select="$isChapterLep"/>
            <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Blank_Page_Body">
         <fo:block text-align="center" font-size="10pt" margin-top="4in">
            <xsl:text>Blank Page</xsl:text>
         </fo:block>
      </fo:static-content>

   </xsl:template>

   <!-- The header for the LEP contains the columns headings for the table, since they need -->
   <!-- to span two columns -->
   <xsl:template name="set-lep-header">
     <xsl:param name="isFirst" select="0"/>
     <fo:block text-align="center" font-size="10pt">
       <xsl:call-template name="do-spl-logo">
         <xsl:with-param name="cageCode" select="$splLowercase"/>
         <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
       </xsl:call-template>
       <fo:block space-before.optimum="6pt" text-transform="uppercase">
         <xsl:value-of select="$g-doc-abbr-name"/>
       </fo:block>
       <fo:block space-before.optimum="2pt">
	     <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/shortPmTitle"/>
	     <!-- 
         <xsl:choose>
           <xsl:when test="/CMM">
             <xsl:value-of select="/CMM/PARTINFO[1]/@MODEL"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="/*/@MODEL"/>
           </xsl:otherwise>
         </xsl:choose> -->
       </fo:block>
         <fo:table>
            <fo:table-column column-number="1" column-width="14pc"/>
            <fo:table-column column-number="2" column-width="5pc"/>
            <fo:table-column column-number="3" column-width="3pc"/>
            <fo:table-column column-number="4" column-width="14pc"/>
            <fo:table-column column-number="5" column-width="5pc"/>

            <fo:table-body font-size="10pt" font-weight="bold">
               <fo:table-row>
                  <fo:table-cell number-columns-spanned="5" padding-top="8pt" padding-bottom="8pt">
                     <fo:block font-size="12pt" text-align="center"> LIST OF EFFECTIVE PAGES <xsl:if test="0 = number($isFirst)"> (Cont)</xsl:if></fo:block>

                  </fo:table-cell>
               </fo:table-row>
               <fo:table-row border-top="solid black 1pt" border-bottom="solid black 1pt">
                  <fo:table-cell xsl:use-attribute-sets="lep.header.cell">
                     <fo:block>Subheading and Page</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="lep.header.cell">
                     <fo:block>Date</fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <fo:block/>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="lep.header.cell">
                     <fo:block>Subheading and Page</fo:block>
                  </fo:table-cell>
                  <fo:table-cell xsl:use-attribute-sets="lep.header.cell">
                     <fo:block>Date</fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-body>
         </fo:table>
      </fo:block>
   </xsl:template>

   <xsl:template name="set-lep-legend">
      <fo:table>
         <fo:table-column column-number="1" column-width=".5in"/>
         <fo:table-column column-number="2" column-width="6.28in"/>

         <fo:table-body font-size="10pt" font-weight="normal" border-top="solid black 1pt">
            <fo:table-row>
               <fo:table-cell text-align="left" padding-top="4pt" padding-bottom="0pt" padding-left="24pt">
                  <fo:block>*</fo:block>
                  <fo:block>F</fo:block>
                  <!-- RS: No left foldouts for S1000D -->
                  <!-- <xsl:choose>
                    <xsl:when test="/CMM">
                      <fo:block>LF</fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                      <fo:block>L</fo:block>
                    </xsl:otherwise>
                  </xsl:choose> -->
               </fo:table-cell>
               <fo:table-cell text-align="left" padding-top="4pt" padding-bottom="6pt" padding-left="2pt">
                  <!-- RS: Changed text to be the same as in Styler: -->
                  <fo:block>Indicates a changed or added page.</fo:block> <!-- indicates pages changed or added data -->
                  <fo:block>Indicates a foldout page.</fo:block><!-- indicates a right foldout -->
                  <!-- RS: No left foldouts for S1000D -->
                  <!-- <fo:block>indicates a left foldout</fo:block> -->
               </fo:table-cell>
            </fo:table-row>
         </fo:table-body>
      </fo:table>
   </xsl:template>

   <xsl:template name="evenPageRegionBeforeStaticContent">
     <xsl:param name="page-prefix"/>
     <xsl:param name="page-suffix"/>
     <xsl:param name="pgblk-confnbr"/>
     <xsl:param name="pgblk-effect"/>
     <xsl:param name="isFoldout" select="0"/>
     <xsl:param name="isTableFoldout" select="0"/>
        <xsl:if test="number($isFoldout) = 1">
          <xsl:attribute name="margin-left" select="'-9in'"/>
        </xsl:if>
        <fo:block text-align="center" font-size="10pt">
          <xsl:choose>
            <xsl:when test="number($isFoldout) = 1 and ancestor-or-self::FIGURE">
              <xsl:attribute name="margin-left" select="'8in'"/>
            </xsl:when>
            <xsl:when test="number($isFoldout) = 1">
              <xsl:attribute name="margin-left" select="'-9in'"/>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="number($isTableFoldout) = 1">
            <xsl:attribute name="id">ITG_TABLE_FOLDOUT</xsl:attribute>
          </xsl:if>
          <xsl:call-template name="do-spl-logo">
            <xsl:with-param name="cageCode" select="$splLowercase"/>
            <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
          </xsl:call-template>
          <fo:block space-before.optimum="6pt" text-transform="uppercase">
            <xsl:value-of select="$g-doc-abbr-name"/>
          </fo:block>
          <fo:block space-before.optimum="2pt">
	         <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/shortPmTitle"/>
	         <!-- RS: Old ATA version for reference: 
	         <xsl:choose>
	           <xsl:when test="/CMM">
	             <xsl:value-of select="/CMM/PARTINFO[1]/@MODEL"/>
	           </xsl:when>
	           <xsl:otherwise>
	             <xsl:value-of select="/*/@MODEL"/>
	           </xsl:otherwise>
	         </xsl:choose> -->
          </fo:block>
      </fo:block>
   </xsl:template>

   <xsl:template name="oddPageRegionBeforeStaticContent">
     <!--<xsl:param name="right-margin">.62in</xsl:param>-->
     <xsl:param name="isFoldout" select="0"/>
     <xsl:param name="isTableFoldout" select="0"/>
     <fo:block text-align="center" font-size="10pt">
     <xsl:choose>
          <xsl:when test="number($isFoldout) = 1 and ancestor-or-self::FIGURE">
            <xsl:attribute name="margin-left" select="'8in'"/>
          </xsl:when>
          <xsl:when test="number($isFoldout) = 1">
            <!-- Only adjust the foldout header margin for Honeywell format -->
            <xsl:attribute name="margin-left" select="'-9in'"/>
          </xsl:when>
        </xsl:choose>
       <xsl:if test="number($isTableFoldout) = 1">
         <xsl:attribute name="id">ITG_TABLE_FOLDOUT</xsl:attribute>
       </xsl:if>
        <!--<fo:block text-align="center" font-size="10pt">-->
       <xsl:call-template name="do-spl-logo">
         <xsl:with-param name="cageCode" select="$splLowercase"/>
         <xsl:with-param name="splLogo" select="$splLogo_PATH"/>
       </xsl:call-template>
       <fo:block space-before.optimum="6pt" text-transform="uppercase">
         <xsl:value-of select="$g-doc-abbr-name"/>
       </fo:block>
       <fo:block space-before.optimum="2pt">
         <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/shortPmTitle"/>
         <!-- RS: Old ATA version for reference: 
         <xsl:choose>
           <xsl:when test="/CMM">
             <xsl:value-of select="/CMM/PARTINFO[1]/@MODEL"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="/*/@MODEL"/>
           </xsl:otherwise>
         </xsl:choose> -->
       </fo:block>
      </fo:block>
   </xsl:template>

   <!-- Title page footer: outputs the content at the bottom of the cover page:
    publication number, ATA number, date, copyright, etc. -->
    
   <xsl:template name="title-page-footer">
      <xsl:param name="page-prefix" select="''"/>
      
      <!-- Add title page to the LEP -->
      <xsl:call-template name="write-lep-data">
         <xsl:with-param name="page-prefix" select="$page-prefix"/>
      </xsl:call-template>
      
     <!-- Added margin-top for mantis #17460 -->
      <!-- <fo:block text-align="center" border="1pt solid black"> --> <!-- margin-top="1.5in"  -->
        <!-- RS: For now we don't distinguish other document types than CMM, so remove this condition (just keep the 1.5in default margin-top): -->
        <!-- <xsl:if test="/CMM"> -->
          <!-- <xsl:attribute name="margin-top" select="'1in'"/>--><!-- 0.75 -->
            <!--  RS: We don't need to account for more than one export control statement...  -->
            <!-- <xsl:choose>
              <xsl:when test="count(//EXPRTCL) &gt; 1">1.8in</xsl:when>
              <xsl:otherwise>1.25in</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute> -->
        <!-- </xsl:if> -->

		 <!-- Table with a fixed row height for the export control statement. -->        
         <fo:table width="100%" text-align="center">
           <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">1pt solid blue</xsl:attribute>
		   </xsl:if>
            <fo:table-body>

               <fo:table-row height="2.05in">
                  <fo:table-cell display-align="after">
		            <xsl:if test="$debug-pagesets">
				      <xsl:attribute name="border">1pt solid red</xsl:attribute>
				    </xsl:if>
                    <fo:block>
				      <!-- Content of the export-control statement (with border): in partinfo-table.xsl -->
                      <xsl:call-template name="do-export-control"/>
                    </fo:block>
                  </fo:table-cell>
               </fo:table-row>
             </fo:table-body>
         </fo:table>
         
         <fo:table>
            <xsl:if test="$debug-pagesets">
		      <xsl:attribute name="border">1pt solid green</xsl:attribute>
		    </xsl:if>
            <fo:table-column column-number="1" column-width="3.39in"/>
            <fo:table-column column-number="2" column-width="3.39in"/>
            <fo:table-body>

               <fo:table-row>
                  <fo:table-cell border-style="none" display-align="after">
                     <fo:block text-align="left" font-size="10pt" font-family="Arial" margin-top="0mm">
                      <xsl:if test="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='INT']">
					   <xsl:text>Publication Number </xsl:text>
                       <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='INT']"/>
                       <xsl:text>, </xsl:text>
					  </xsl:if>
					  <xsl:text>Revision </xsl:text>
                      <xsl:value-of select="number(/pm/identAndStatusSection/pmAddress/pmIdent/issueInfo/@issueNumber)"/>
                     </fo:block>
                  </fo:table-cell>

                  <fo:table-cell display-align="after">
                    <!-- Output the ATA number on the bottom right of the title page. -->
                    <fo:block text-align="right" font-size="24pt" font-weight="bold">
                      <!-- For EIPC and EM, add a nbsp to take up the space if it has no content -->
                      <xsl:choose>
                        <!-- UPDATE: All EM document types. -->
                        <!-- $documentType=('eipc','em','mm','lmm','hmm','ohm') and  -->
                        <xsl:when test="not(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'])
                      	  or /pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP']=''">
                      		<xsl:message>Outputting NBSP for ATA number on cover.</xsl:message>
                      		<xsl:text>&#xa0;</xsl:text>
                      	</xsl:when>
                      	<xsl:otherwise>
	                      <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP']"/>
                      	</xsl:otherwise>
                      </xsl:choose>
                    </fo:block>
					<!-- If there wasn't an initial date in externalPubCode, output an empty block for spacing -->
					<xsl:if test="not(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='initialDate'])">
						<fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
						  <xsl:text>&#160;</xsl:text>
						</fo:block>
					</xsl:if>
                     <fo:block text-align="right">
                       <xsl:value-of select="'Page T-1'"/>
                     </fo:block>
					  <xsl:choose>
					  
						<!-- If there is an initial date in externalPubCode, output that first, and then the revised date is from the issueDate element -->
						<xsl:when test="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='initialDate']">
						 <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm" space-after="1pt">
						   <!-- Strip leading "0" -->
						   <xsl:text>Initial </xsl:text><xsl:value-of select="replace(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='initialDate'],'^0','')"/>
						 </fo:block>
						 <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
						   <xsl:text>Revised </xsl:text>
						   <!-- RS: convert-date is expecting a date of the form YYYYMMDD. In some cases the issue date in S1000D incorrectly -->
						   <!-- uses a word for the month (like "Mar"). This should be fixed in the source. -->
						   <xsl:call-template name="convert-date">
							 <xsl:with-param name="ata-date" select="concat(/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@year,
								/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@month,
								/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@day)"/>
						   </xsl:call-template>
						 </fo:block>
						</xsl:when>
						
						<xsl:otherwise>
							<!-- No initial date in the externalPubCode, so the issueDate is the initial date, but output an empty block for spacing
							where the first date would be (when there is an initial and a revised date) -->
							 <!--<fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
							   <xsl:text>&#160;</xsl:text>
							 </fo:block>-->
							 <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
							   <xsl:text>Initial </xsl:text>
							   <!-- RS: convert-date is expecting a date of the form YYYYMMDD. In some cases the issue date in S1000D incorrectly -->
							   <!-- uses a word for the month (like "Mar"). This should be fixed in the source. -->
							   <xsl:call-template name="convert-date">
								 <xsl:with-param name="ata-date" select="concat(/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@year,
									/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@month,
									/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@day)"/>
							   </xsl:call-template>
							 </fo:block>
						</xsl:otherwise>
						
					  </xsl:choose>
                  </fo:table-cell>
				 </fo:table-row>
				 
<!--                  <fo:table-cell>
                     <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
                       <xsl:text>Initial </xsl:text>
                       <xsl:call-template name="convert-date">
                         <xsl:with-param name="ata-date" select="concat(/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@year,
                         	/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@month,
                         	/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@day)"/>
                       </xsl:call-template>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>-->

              <!-- RS: In the Styler version, it doesn't look like there is a facility for output of the Revised date at the lower right
              of the title page. So comment this bit out, but leave for future reference. But still make the empty table row for spacing. -->
              <!-- <xsl:if test="not(/*/@TSN = 0)">
                <fo:table-row>
                  <fo:table-cell border-style="none" number-columns-spanned="2">
                    <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
                      <xsl:text>Revised </xsl:text>
                      <fo:inline>
                        <xsl:call-template name="convert-date">
                          <xsl:with-param name="ata-date" select="/*/@REVDATE"/>
                        </xsl:call-template>  
                      </fo:inline>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>
              </xsl:if> -->
                <!--<fo:table-row>
                  <fo:table-cell border-style="none" number-columns-spanned="2">
                    <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
                      <xsl:text>&#160;</xsl:text>
                    </fo:block>
                  </fo:table-cell>
                </fo:table-row>-->
              
               <fo:table-row>
                  <fo:table-cell number-columns-spanned="2" border="none">
                     <fo:block text-align="center" font-size="8pt" font-family="Arial" margin-top="11pt">
                       <!-- <xsl:if test="not(/*/@TSN = 0)">
                         <xsl:attribute name="margin-top">4pt</xsl:attribute>
                       </xsl:if> -->
                        <xsl:value-of select="$copyright-statement"/>
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <fo:block>&#160;</fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-body>
         </fo:table>
      <!-- </fo:block> -->
   </xsl:template>


   <!-- Footer for the balance of the "T-" section (title pages) -->
  <xsl:template name="title-section-footer">
    <xsl:param name="page-prefix"/>
    <xsl:param name="page-suffix"/>
    <xsl:param name="pgblk-confnbr"/>
    <xsl:param name="pgblk-effect"/>
    <xsl:call-template name="write-lep-data">
      <xsl:with-param name="page-prefix" select="'T-'"/>
      </xsl:call-template>
      <fo:block text-align="center" display-align="after" margin-top="7.6pt" padding="0pt"><!-- margin-top="3.6pt" -->
         <fo:table>
            <fo:table-column column-number="1" column-width="2.425in"/>
            <fo:table-column column-number="2" column-width="2.425in"/>
            <fo:table-column column-number="3" column-width="1.93in"/>
            <fo:table-body>
               <fo:table-row>

                  <fo:table-cell border-style="none" number-rows-spanned="1" display-align="before" number-columns-spanned="2" padding-after="0pt">
                     <fo:block text-align="right" padding="0pt" font-weight="bold" font-size="24pt" font-family="Arial">
                        <!-- For EM there are no ata numbers in the title section. (See CMM version if needed) -->
                        <!-- Leave the required space in to maintain the dimensions. -->
                        <!-- 2020-10-30 Update Start -->
                        <xsl:choose>
                            <xsl:when test="$documentType=('eipc') or $documentType=('em')">
                              <xsl:choose>
                                <xsl:when test="not(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'])
                                  or /pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP']=''">
                                  <xsl:text>&#160;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP']"/>
                                </xsl:otherwise>
                              </xsl:choose>
                              <!-- <xsl:value-of select="/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='INT']"/> -->
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- 2020-10-30 Update End -->
                        
                     </fo:block>
                  </fo:table-cell>

                  <fo:table-cell padding="0pt">
                    <!-- ADDED FAA APPROVED FOR MANTIS #13034) -->
                    <!--
                      <xsl:if test="/EM/@DOCNBR = '72-00-52' or /EM/@DOCNBR = '72-00-53' or /EM/@DOCNBR = '72-00-54'">
                      <fo:block text-align="right">
                      <xsl:text>(FAA APPROVED)</xsl:text>
                      </fo:block>
                      </xsl:if>
                    -->
                    <fo:block text-align="right">
                      <xsl:choose>
                        <xsl:when test="$documentType = 'acmm'">
                          <xsl:text>Page&#160;</xsl:text>
                          <fo:page-number/>
                          <xsl:text>&#160;of&#160;</xsl:text>
                          <xsl:value-of select="$front_body_count"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat('Page ','T-')"/>
                          <fo:inline>
                            <fo:page-number/>
                          </fo:inline>
                        </xsl:otherwise>
                      </xsl:choose>
                    </fo:block>
                    <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
                      <xsl:call-template name="convert-date">
						 <xsl:with-param name="ata-date" select="concat(/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@year,
							/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@month,
							/pm/identAndStatusSection/pmAddress/pmAddressItems/issueDate/@day)"/>
                        <!--<xsl:with-param name="ata-date" select="/*/@REVDATE"/>-->
                      </xsl:call-template>
                    </fo:block>
                  </fo:table-cell>
               </fo:table-row>

               <fo:table-row>
                  <fo:table-cell number-columns-spanned="3" border="none" padding-before="3.43pt">
                     <fo:block text-align="center" font-size="8pt" font-family="Arial">
                        <xsl:value-of select="$copyright-statement"/>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>

            </fo:table-body>
         </fo:table>
      </fo:block>
   </xsl:template>

  <!-- NOTE: this is over-ridden in S1000D_EIPC/EM.xsl -->
  <!-- However, it is still used by renderLEP_EM.xsl, so use the same version as in the main module. -->
  <xsl:template name="get-atacode">
    <xsl:param name="suppressAtacode" select="0"/>
    <xsl:param name="isChapterToc" select="0"/>
    <xsl:param name="isChapterLep" select="0"/>
    <!-- <xsl:message>get-atacode: context: <xsl:value-of select="name()"/></xsl:message> -->
    <xsl:choose>
      <!-- Suppress is indicated explicitly -->
      <xsl:when test="1 = number($suppressAtacode)">
        <xsl:message>Suppressing ATA code</xsl:message>
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      
      <!-- For front-matter when there's only a top-level pmEntry-->
      <xsl:when test="count(ancestor-or-self::pmEntry)=1 and ancestor-or-self::pmEntry/@authorityDocument">
      	<!-- <xsl:message>Getting ATA code for front-matter</xsl:message> -->
        <xsl:choose>
        	<xsl:when test="number($isChapterToc) = 1">
        	  <!-- Use only the first two digits of the ATA code (the Chapter part) in case the full number is specified. -->
        	  <xsl:value-of select="substring(ancestor-or-self::pmEntry/@authorityDocument,1,2)"/>
	          <xsl:text>-TOC</xsl:text>
        	</xsl:when>
        	<xsl:when test="number($isChapterLep) = 1">
        	  <xsl:value-of select="substring(ancestor-or-self::pmEntry/@authorityDocument,1,2)"/>
	          <xsl:text>-EFF</xsl:text>
        	</xsl:when>
        	<xsl:otherwise>
        	  <xsl:value-of select="ancestor-or-self::pmEntry/@authorityDocument"/>
        	</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- EIPC regular pages: use first authorityDocument attribute. -->
      <xsl:when test="$documentType='eipc'">
      	<!-- <xsl:message>Getting ATA code for EIPC regular pages</xsl:message> -->
      	<xsl:value-of select="ancestor-or-self::pmEntry[@authorityDocument][1]/@authorityDocument"/>
      </xsl:when>
      <!-- For 5-level EM, use 3rd-level pmEntry authorityDocument -->
      <xsl:when test="$isNewPmc">
      	<!-- <xsl:message>Getting ATA code for 5-level EM; pmEntry ancestor-of-selfs: <xsl:value-of select="count(ancestor-or-self::pmEntry)"/></xsl:message>
      	<xsl:message>ATA code (ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument): <xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument"/></xsl:message> -->
      	<xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument"/>
      </xsl:when>
      <xsl:otherwise>
      	<!-- 3-level: use the 2nd level pmEntry -->
      	<xsl:value-of select="ancestor-or-self::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
<!-- Original ATA version for reference  
  <xsl:template name="get-atacode">
    <xsl:param name="suppressAtacode" select="0"/>
    <xsl:param name="isChapterToc" select="0"/>
    <xsl:message>Wrong get-atacode!</xsl:message>
    <xsl:choose>
      [!++ Suppress is indicated explicitly ++]
      <xsl:when test="1 = number($suppressAtacode)">
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      [!++ Within a page block or unit ++]
      <xsl:when test="ancestor-or-self::PGBLK or ancestor-or-self::UNIT or ancestor-or-self::CMM">
        <xsl:choose>
          <xsl:when test="/CMM">
            <xsl:value-of select="ancestor-or-self::CMM/@CHAPNBR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="ancestor::CHAPTER/@CHAPNBR"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>-</xsl:text>
        [!++ NOW PULLS SECTNBR FROM UNIT INSTEAD OF SECTION (IN EIPC). THIS IS BECAUSE OF MANUALS THAT HAVE UNITS WITH DIFFERENT SECTION NUMBERS THAN THE PARENT SECTION. ++]
        <xsl:choose>
          <xsl:when test="name(/*) = 'EIPC'">
            <xsl:value-of select="ancestor-or-self::UNIT/@SECTNBR"/>
          </xsl:when>
          <xsl:when test="/CMM">
            <xsl:value-of select="ancestor-or-self::CMM/@SECTNBR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="ancestor::SECTION/@SECTNBR"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>-</xsl:text>
        <xsl:choose>
          <xsl:when test="name(/*) = 'EIPC'">
            <xsl:value-of select="ancestor-or-self::UNIT/@UNITNBR"/>
          </xsl:when>
          <xsl:when test="/CMM">
            <xsl:value-of select="ancestor-or-self::CMM/@SUBJNBR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="ancestor-or-self::SUBJECT/@SUBJNBR"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      [!++ Within section ++]
      <xsl:when test="ancestor-or-self::SECTION">
        <xsl:choose>
          <xsl:when test="ancestor::EIPC">
            <xsl:value-of select="self::*/@CHAPNBR"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="self::*/@SECTNBR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>&#160;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      [!++ Within chapter ++]
      <xsl:when test="ancestor-or-self::CHAPTER">
        [!++ DJH 20091204
          <xsl:choose>
          <xsl:when test="ancestor::EIPC">
          <xsl:value-of select="self::*/@CHAPNBR"/>
          <xsl:if test="1=number($isChapterToc)">
          <xsl:text>-TOC</xsl:text>
          </xsl:if>
          <xsl:if test="not(1=number($isChapterToc))">
          <xsl:text>-EFF</xsl:text>
          </xsl:if>
          </xsl:when>
          <xsl:otherwise>
          <xsl:text>&#160;</xsl:text>
          </xsl:otherwise>
          </xsl:choose>
        ++]
        <xsl:value-of select="self::*/@CHAPNBR"/>
        <xsl:if test="1=number($isChapterToc)">
          <xsl:text>-TOC</xsl:text>
        </xsl:if>
        <xsl:if test="not(1=number($isChapterToc))">
          <xsl:text>-EFF</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="/*/@DOCNBR"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->

   <!-- This is the footer for most pages. -->
   <!-- Parameter "isIntroToc" will be "1" if it's for the front-matter LEP. -->
   <xsl:template name="effectivity-footer">
      <!-- If sheet-id is set, then this is a foldout page, and it will get the correct page number -->
      <!-- from the marker on the placeholder page -->
      <xsl:param name="isFoldout" select="0"/>
      <xsl:param name="page-prefix" select="''"/>
      <xsl:param name="page-suffix" select="''"/>
      <xsl:param name="pgblk-confnbr" select="''"/>
      <xsl:param name="pgblk-effect" select="''"/>
      <xsl:param name="effectivity" select="'ALL'"/>
      <xsl:param name="revdate" select="'No Revdate'"/>
      <xsl:param name="isChapterToc" select="0"/>
      <xsl:param name="isIntroToc" select="0"/>
      <xsl:param name="writeLepLegend" select="0"/>
      <xsl:param name="isChapterLep" select="0"/>
      <xsl:param name="suppressAtacode" select="0"/>
      <xsl:param name="suppressEffectivity" select="false()"/>
      <xsl:call-template name="write-lep-data">
         <xsl:with-param name="page-prefix" select="$page-prefix"/>
         <xsl:with-param name="page-suffix" select="$page-suffix"/>
         <xsl:with-param name="pgblk-confnbr" select="$pgblk-confnbr"/>
         <xsl:with-param name="pgblk-effect" select="$pgblk-effect"/>
      </xsl:call-template>

      <xsl:variable name="atacode">
      
      	<!-- <xsl:if test="$isIntroToc=1">
      		<xsl:message>Getting ATA code when $isIntroToc=1; isChapterToc: <xsl:value-of select="$isChapterToc"/>; $isChapterLep: <xsl:value-of select="$isChapterLep"/></xsl:message>
      	</xsl:if>
      	<xsl:if test="$isIntroToc=0">
      		<xsl:message>Getting ATA code when $isIntroToc=0; isChapterToc: <xsl:value-of select="$isChapterToc"/>; $isChapterLep: <xsl:value-of select="$isChapterLep"/>; $suppressAtacode: <xsl:value-of select="$suppressAtacode"/></xsl:message>
      	</xsl:if> -->
        <xsl:choose>
          <xsl:when test="false()"><!-- /CMM/@CHAPNBR = '72' and /CMM/@SECTNBR = '00' and $documentType = 'irm' -->
            <xsl:value-of select="/CMM/@DOCNBR"/>
          </xsl:when>
          <!-- <xsl:when test="$isIntroToc">
          	<xsl:value-of select="ancestor::pmEntry[last()]/@authorityDocument"/>
          	<xsl:text>-EFF</xsl:text>
          </xsl:when> -->
          <xsl:otherwise>
            <!-- <xsl:message>Calling get-atacode</xsl:message> -->
            <xsl:call-template name="get-atacode">
              <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
              <xsl:with-param name="isChapterToc" select="$isChapterToc"/>
              <xsl:with-param name="isChapterLep" select="$isChapterLep"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="1 = number($writeLepLegend)">
         <xsl:call-template name="set-lep-legend"/>
      </xsl:if>

     <!--Re-coded entire table for "configuration" addition. Mantis #17830-->
     <fo:block text-align="center"><!-- display-align="after" margin-top="3.67pt"-->
       <xsl:if test="ancestor-or-self::FIGURE and 1 = number($isFoldout)"><!--Added check for foldout Mantis #22831-->
         <xsl:attribute name="margin-left" select="'8in'"/>
       </xsl:if>
       <!-- <xsl:if test="/EM and ancestor-or-self::CHAPTER[@CHAPNBR = '05'] and ancestor-or-self::SECTION[@SECTNBR = '10']"> -->
       <!-- As in the EM ATA FO, check for chapter 05 and section 10 (from the full ATA number stored at the third-level pmEntry @authorityDocument -->
       <xsl:variable name="airworthinessCheck">
       	<xsl:choose>
       		<xsl:when test="$isNewPmc">
       			<xsl:value-of select="substring(ancestor-or-self::pmEntry[count(ancestor::pmEntry)=2]/@authorityDocument,1,5)"/>
       		</xsl:when>
       		<xsl:otherwise>
       			<!-- The ATA number for 3-level should be at the second-level pmEntry -->
       			<xsl:value-of select="substring(ancestor-or-self::pmEntry[count(ancestor::pmEntry)=1]/@authorityDocument,1,5)"/>
       		</xsl:otherwise>
       	</xsl:choose>
       </xsl:variable>
       <xsl:if test="$airworthinessCheck='05-10' or $airworthinessCheck='05-11'">
         <fo:block font-size="9pt" color="red" font-weight="bold" margin-top="-0.15in">
           <xsl:text>AIRWORTHINESS LIMITATIONS</xsl:text>
         </fo:block>
       </xsl:if>
       <!-- Table for the whole footer area (effectivity block, ATA number, page number, date, etc.) -->
       <fo:table padding="0pt"  border="none"><!-- TESTING: border="red solid 1pt" -->
            <fo:table-column column-number="1" column-width="0.90in"/><!-- 1.00 --><!-- RS: Smaller to fit the EFFECTIVITY text -->
            <fo:table-column column-number="2" column-width="2.35in"/><!-- 2.25 -->
         <xsl:choose><!-- CJM : OCSHONSS-485 : if CMM Foldout, reposition footer -->
           <xsl:when test="1 = number($isFoldout) and /CMM">
             <fo:table-column column-number="3" column-width="2.15in"/>
           </xsl:when>
           <xsl:otherwise>
             <fo:table-column column-number="3" column-width="2.15in"/>
           </xsl:otherwise>
         </xsl:choose>   
            <fo:table-column column-number="4" column-width="1.35in"/>
            <fo:table-body>
              
              <!-- RS: Top row: originally had effectivity text and border, now moved lower -->
              <fo:table-row>
                <!-- <fo:table-cell> -->
                  <!-- <fo:block font-size="10pt" margin-top="-5pt" text-align="left">EFFECTIVITY</fo:block> -->
                <!-- </fo:table-cell> -->
                <!-- <fo:table-cell></fo:table-cell>  -->
                <!--  border-top="black solid 1pt" border-right="black solid 1pt" -->
                <!--<fo:table-cell/>
                <fo:table-cell/>-->
                <!--Added for mantis #20187-->
                <fo:table-cell number-columns-spanned="4">
                  <fo:block text-align="right" margin-left="-0.1pt">
                    <xsl:text>&#xA0;</xsl:text>
                    <!-- Add the section title from the confnbrValue marker -->
                    <fo:retrieve-marker retrieve-class-name="confnbrValue" retrieve-position="first-including-carryover"/>
                    <!-- <xsl:if test="$documentType = 'irm'">
                      <xsl:choose>
                        <xsl:when test="/CMM/@CHAPNBR = '72' and /CMM/@SECTNBR = '00'">
                          <xsl:choose>
                            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR='5000'">
                              <xsl:text>Inspection/Check</xsl:text>
                            </xsl:when>
                            <xsl:when test="ancestor-or-self::PGBLK/@PGBLKNBR='6000'">
                              <xsl:text>Repair</xsl:text>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:choose>
                            <xsl:when test="self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 1000][number(@CONFNBR) &lt; 2000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
                              <xsl:text>Continue-Time Check</xsl:text>
                            </xsl:when>
                            <xsl:when test="self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 2000][number(@CONFNBR) &lt; 3000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
                              <xsl:text>Zero-Time Check</xsl:text>
                            </xsl:when>
                            <xsl:when test="self::PGBLK[@PGBLKNBR='5000'][number(@CONFNBR) &gt;= 3000][number(@CONFNBR) &lt; 4000]/preceding-sibling::PGBLK[1][@PGBLKNBR='5000']">
                              <xsl:text>Check</xsl:text>
                            </xsl:when>
                            <xsl:when test="self::PGBLK[@PGBLKNBR='6000'][number(@CONFNBR) >= 1000]/preceding-sibling::PGBLK[1][@PGBLKNBR='6000']">
                              <xsl:text>Repair</xsl:text>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if> -->
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
              <!-- Effectivity text and border moved here -->
              <fo:table-row>
                <!-- 
                <fo:table-cell number-columns-spanned="2" border-right="blue solid 1pt" text-align="left">
                  <xsl:if test="//EM"><fo:block height="0pt" width="0pt" max-height="0pt" max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">__effectStart__</fo:block></xsl:if>
                  <fo:block font-size="10pt">
                    <fo:retrieve-marker retrieve-class-name="efftextValue" retrieve-position="last-starting-within-page"/>
                  </fo:block>
                  <xsl:if test="//EM"><fo:block height="0pt" width="0pt" max-height="0pt" max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">__effectEnd__</fo:block></xsl:if>
                </fo:table-cell> -->
                <fo:table-cell>
                  <xsl:choose>
                  	<xsl:when test="$suppressEffectivity">
                  	  <fo:block font-size="10pt" margin-top="-5pt" text-align="left">&#xa0;</fo:block>
                  	</xsl:when>
                  	<xsl:otherwise>
	                  <fo:block font-size="10pt" margin-top="-5pt" text-align="left">EFFECTIVITY</fo:block>
                  	</xsl:otherwise>
                  </xsl:choose>
                </fo:table-cell>
                <fo:table-cell>
                	<xsl:if test="not($suppressEffectivity)">
                		<xsl:attribute name="border-top">black solid 1pt</xsl:attribute>
                		<xsl:attribute name="border-right">black solid 1pt</xsl:attribute>
                	</xsl:if>
                </fo:table-cell>

                <!-- This is the docnbr, the ata-code, or blank in 24pt bold -->
                 <fo:table-cell padding="0pt" number-rows-spanned="2">
                   <!--Changed text-align from right to center for CMM.-->
                    <fo:block text-align="center" font-weight="bold" font-size="24pt" font-family="Arial">
                        <xsl:value-of select="$atacode"/>
                    </fo:block>
                    <!--Removed for mantis #20187-->
                    <!--<fo:block text-align="right" font-weight="bold" font-size="8pt" font-family="Arial" padding-top="-6pt">
                      <xsl:text>&#xA0;</xsl:text><fo:retrieve-marker retrieve-class-name="confnbrValue" retrieve-position="first-including-carryover"/>
                    </fo:block>-->
                  </fo:table-cell>

                 <fo:table-cell padding="0pt" text-align="right" font-size="10pt" font-family="Arial" number-rows-spanned="2">
                     <xsl:choose>
                       <xsl:when test="1 = number($isFoldout)">
                         <fo:block margin-left="-0.5in">
                           <xsl:text>Page </xsl:text>
                           <fo:inline>
                             <fo:retrieve-marker retrieve-class-name="foldout-page-string" retrieve-boundary="page"/>  
                           </fo:inline>
                         </fo:block>
                       </xsl:when>
                       <xsl:otherwise>
                         <fo:block>
                           <!-- <xsl:message>Generating page number: prefix: '<xsl:value-of select="$page-prefix"/>'; suffix: '<xsl:value-of select="$page-suffix"/>'; confnbr (section-enum): '<xsl:value-of select="ancestor-or-self::pmEntry/@confnbr"/>'</xsl:message> -->
                           <xsl:value-of select="concat('Page ',$page-prefix)"/>
                           <fo:page-number/>
                           <xsl:value-of select="$page-suffix"/>
                           <!-- Add the section enumeration (the pre-process adds it as an attribute "confnbr", as in ATA FO) -->
                           <!-- <xsl:if test="/EM and not(normalize-space(ancestor-or-self::PGBLK/@CONFNBR) = ('','NA'))"> -->
                           <xsl:if test="ancestor-or-self::pmEntry/@confnbr">
                             <fo:inline>
                               <xsl:value-of select="concat('-',ancestor-or-self::pmEntry/@confnbr)"/>
                             </fo:inline>
                           </xsl:if>
                         </fo:block>
                       </xsl:otherwise>
                     </xsl:choose>
                     <fo:block>
                        <xsl:choose>
                           <xsl:when test="$revdate = 'No Revdate'">
                             <xsl:choose>
                               <xsl:when test="/EM">
                                 <xsl:call-template name="get-revdate">
                                   <xsl:with-param name="asText">1</xsl:with-param>
                                   <xsl:with-param name="intro-toc" select="$isIntroToc"/>
                                 </xsl:call-template>                                 
                               </xsl:when>
                               <xsl:when test="/EIPC">
                                 <xsl:call-template name="get-revdate">
                                   <xsl:with-param name="asText">1</xsl:with-param>
                                   <xsl:with-param name="intro-toc" select="$isIntroToc"/>
                                 </xsl:call-template>                                 
                               </xsl:when>
                               <xsl:otherwise>
                                 <xsl:call-template name="get-revdate">
                                   <xsl:with-param name="asText">1</xsl:with-param>
                                 </xsl:call-template>                                 
                               </xsl:otherwise>
                             </xsl:choose>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="$revdate"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>
               <fo:table-row>
                 <!-- The effectivity has a row to itself (taking up the first two columns). Add a right border for the -->
                 <!-- edge of the effectivity box. -->
                 <fo:table-cell number-columns-spanned="2">
                	<xsl:if test="not($suppressEffectivity)">
                		<xsl:attribute name="border-right">black solid 1pt</xsl:attribute>
                	</xsl:if>
	                  <xsl:choose>
	                  	<xsl:when test="$suppressEffectivity">
	                  	  <fo:block font-size="10pt" margin-top="9pt" text-align="left">&#xa0;</fo:block>
	                  	</xsl:when>
	                  	<xsl:otherwise>
		                  <!-- <fo:block font-size="10pt" margin-top="9pt" text-align="left">ALL</fo:block> -->
		                  <fo:block font-size="10pt" margin-top="9pt" text-align="left">
		                  	<fo:retrieve-marker retrieve-class-name="efftextValue" retrieve-position="first-starting-within-page"/><!-- first-including-carryover last-starting-within-page -->
		                  </fo:block>
	                  	</xsl:otherwise>
	                  </xsl:choose>
                  </fo:table-cell>
               </fo:table-row>
               <fo:table-row>
                 <fo:table-cell number-columns-spanned="4">
                     <fo:block text-align="center" font-size="8pt" font-family="Arial">
                        <xsl:value-of select="$copyright-statement"/>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-body>
         </fo:table>
      </fo:block>
   </xsl:template>
  
   <xsl:template name="write-lep-data">
      <xsl:param name="page-prefix"/>
      <xsl:param name="page-suffix"/>
      <xsl:param name="pgblk-confnbr"/>
      <xsl:param name="pgblk-effect"/>

      <xsl:if test="boolean(number($LEP_PASS))">
         <fo:block-container absolute-position="absolute" top="-10.2in" left="-.001in" color="green">

            <fo:block>
              <xsl:text>__documentType__</xsl:text>
              <!-- <xsl:value-of select="/CMM/@TYPE"/> -->
              <xsl:value-of select="$documentType"/>
            </fo:block>
            
		      <!-- RS: Added a new attribute for a chapter counter, since the ATA code (chapter-section-subject) does not -->
		      <!-- reliably represent how the chapters are divided in 3-level EM. In fact there can be many chapters all -->
		      <!-- with exactly the same ATA number. -->
		      <!-- Added "x" prefix because template "get-value" uses "start-with" rather than exact comparison. -->
            <fo:block>
               <xsl:text>__xchapter-ctr__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerChapterCtr" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__chapter__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerChapter" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__section__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerSection" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__subject__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerSubject" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__unit__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerUnit" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__figure__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerFigure" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__pgblk__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerPgblk" retrieve-position="first-including-carryover"/>
            </fo:block>

            <fo:block>
               <xsl:text>__revdate__</xsl:text>
               <fo:retrieve-marker retrieve-class-name="footerRevdate" retrieve-boundary="page-sequence" retrieve-position="last-starting-within-page"/>
            </fo:block>

            <fo:block>
               <xsl:value-of select="concat('__page__',$page-prefix)"/>
               <fo:page-number/>
            </fo:block>

			<!-- RS: I'm not sure exactly what confnbr was used for in ATA, but it looks like a suffix, so we'll use -->
			<!-- it for page number suffixes for now. -->
			<!-- UPDATE: For EM the confnbr is used for section enumerations (added by the pre-process) -->
           <fo:block>
             <!-- <xsl:value-of select="concat('__confnbr__',ancestor-or-self::PGBLK/@CONFNBR)"/> -->
             <!-- <xsl:value-of select="concat('__confnbr__',$page-suffix)"/> -->
             <xsl:value-of select="concat('__confnbr__',ancestor-or-self::pmEntry/@confnbr)"/>
           </fo:block>

           <fo:block>
             <xsl:text>__effect__</xsl:text>
             <xsl:value-of select="$pgblk-effect"/>
           </fo:block>

         </fo:block-container>
      </xsl:if>
   </xsl:template>
   
</xsl:stylesheet>
