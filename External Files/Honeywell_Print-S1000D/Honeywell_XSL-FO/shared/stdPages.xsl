<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">
   <!--<xsl:output method="xml" encoding="UTF-8" indent="yes"/>-->

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
      <xsl:attribute name="margin-right">.62in</xsl:attribute>
      <xsl:attribute name="margin-top">.21in</xsl:attribute>
      <xsl:attribute name="margin-bottom">2.85in</xsl:attribute>
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
      <xsl:attribute name="margin-top">1.1in</xsl:attribute>
      <!-- DJH TEST START -->
      <!--
    <xsl:attribute name="margin-bottom">1.125in</xsl:attribute>
    -->
      <!--
    <xsl:attribute name="margin-bottom">.50in</xsl:attribute>
    -->
      <xsl:attribute name="margin-bottom">.75in</xsl:attribute>
      <!-- DJH TEST END -->
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
      <xsl:attribute name="extent">1.125in</xsl:attribute>
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
    <xsl:attribute name="extent">1.5in</xsl:attribute>
  </xsl:attribute-set>

   <xsl:attribute-set name="lep.region.after">
      <xsl:attribute name="extent">1.25in</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="lep.header.cell">
      <xsl:attribute name="padding-top">8.5pt</xsl:attribute>
      <xsl:attribute name="padding-bottom">8.5pt</xsl:attribute>
      <xsl:attribute name="text-align">center</xsl:attribute>
   </xsl:attribute-set>

   <xsl:attribute-set name="lep.region.body.attributes">
      <xsl:attribute name="margin-left">0in</xsl:attribute>
      <xsl:attribute name="margin-right">0in</xsl:attribute>
      <!-- DJH TEST START -->
      <!--
    <xsl:attribute name="margin-top">1.8in</xsl:attribute>
    <xsl:attribute name="margin-bottom">1.8in</xsl:attribute>
    -->
      <xsl:attribute name="margin-top">2in</xsl:attribute>
      <xsl:attribute name="margin-bottom">2in</xsl:attribute>
      <!-- DJH TEST END -->
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

         <fo:simple-page-master master-name="First_Page" xsl:use-attribute-sets="first-page-layout">
            <fo:region-body xsl:use-attribute-sets="watermark.attributes"> </fo:region-body>
           <xsl:choose><!-- CJM : OCSHONSS-481 : Added CMM test to apply the correct attribute set -->
             <xsl:when test="/CMM">
               <fo:region-after xsl:use-attribute-sets="cmm.title.region.after" region-name="First_Page_regionafter"/>
             </xsl:when>
             <xsl:otherwise>
               <fo:region-after xsl:use-attribute-sets="title.region.after" region-name="First_Page_regionafter"/>    
             </xsl:otherwise>
           </xsl:choose>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Blank_Even_Page" xsl:use-attribute-sets="even-page-layout">
            <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
            <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
            <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Blank_Odd_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body region-name="Blank_Page_Body" xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
            <fo:region-before region-name="Blank_Page_regionbefore" xsl:use-attribute-sets="region.before"/>
            <fo:region-after region-name="Blank_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>
         
         <fo:simple-page-master master-name="Odd_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Odd_Page_regionbefore"/>
            <fo:region-after xsl:use-attribute-sets="region.after" region-name="Odd_Page_regionafter"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Even_Page" xsl:use-attribute-sets="even-page-layout">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Even_Page_regionbefore"/>
            <fo:region-after xsl:use-attribute-sets="region.after" region-name="Even_Page_regionafter"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="First_Lep_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body xsl:use-attribute-sets="lep.region.body.attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="First_Lep_Page_regionbefore" extent="2in"/>
            <fo:region-after xsl:use-attribute-sets="lep.region.after" region-name="First_Lep_Page_regionafter"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Odd_Lep_Page" xsl:use-attribute-sets="odd-page-layout">
            <fo:region-body xsl:use-attribute-sets="lep.region.body.attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Odd_Lep_Page_regionbefore" extent="2in"/>
            <fo:region-after xsl:use-attribute-sets="lep.region.after" region-name="Odd_Lep_Page_regionafter"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Even_Lep_Page" xsl:use-attribute-sets="even-page-layout">
            <fo:region-body xsl:use-attribute-sets="lep.region.body.attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Even_Lep_Page_regionbefore" extent="2in"/>
            <fo:region-after xsl:use-attribute-sets="lep.region.after" region-name="Even_Lep_Page_regionafter"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Foldout_Odd_Page" margin-left="1.1in" margin-right="0.62in" page-width="17in" margin-bottom="0.25in" margin-top="0.25in" page-height="11in">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Odd_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Odd_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Foldout_Even_Page" margin-left="1.1in" margin-right="0.62in" page-width="17in" margin-bottom="0.25in" margin-top="0.25in" page-height="11in">
            <fo:region-body xsl:use-attribute-sets="region-body-attributes watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Even_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Even_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>

         <fo:simple-page-master master-name="Foldout_Blank_Even_Page" margin-left="0.62in" margin-right="9.6in" page-width="17in" margin-bottom="0.125in" margin-top="0.25in" page-height="11in">
            <fo:region-body region-name="Foldout-region-body-blank-page" xsl:use-attribute-sets="watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Blank_Even_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Blank_Even_Page_regionafter" xsl:use-attribute-sets="region.after"/>
         </fo:simple-page-master>
        

         <!-- Sonovision update (2019.02.20)
              - EIPC foldout images must start on "odd" page
                -->
         <fo:simple-page-master master-name="Foldout_Blank_Odd_Page" margin-left="0.62in" margin-right="9.6in" page-width="17in" margin-bottom="0.125in" margin-top="0.25in" page-height="11in">
            <fo:region-body region-name="Foldout-region-body-blank-page" xsl:use-attribute-sets="watermark.attributes"/>
            <fo:region-before xsl:use-attribute-sets="region.before" region-name="Foldout_Blank_Odd_Page_regionbefore"/>
            <fo:region-after region-name="Foldout_Blank_Odd_Page_regionafter" xsl:use-attribute-sets="region.after"/>
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

         <!-- Sonovision update (2019.02.20)
              - EIPC foldout images must start on "odd" page
                -->
         <fo:page-sequence-master master-name="Foldout-EIPC">
            <fo:repeatable-page-master-alternatives>
               <fo:conditional-page-master-reference master-reference="Foldout_Blank_Odd_Page" odd-or-even="odd" blank-or-not-blank="blank"/>
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

      <fo:static-content flow-name="Blank_Page_regionafter">
         <xsl:call-template name="effectivity-footer">
            <xsl:with-param name="page-prefix" select="'T-'"/>
            <xsl:with-param name="isChapterLep" select="0"/>

            <!-- Sonovision update (2019.06.27)
                 - ATA number was not appearing on CMM "T-" blank pages, but was appearing on all other blank pages
                 - set "suppressAtacode" parameter to "0" (default)
                 - this is a shared component which may adversely effect other doctypes, 
                   so may need additional tests when applying this condition
                 - creating new "page-type=BLANK" parameter
                   -->
            <!-- <xsl:with-param name="suppressAtacode" select="1"/> -->
            <xsl:with-param name="suppressAtacode" select="0"/>
            <xsl:with-param name="page-type" select="'BLANK'"/>

            <!-- DJH TEST 20090831 -->
         </xsl:call-template>
      </fo:static-content>

      <fo:static-content flow-name="Blank_Page_Body">
         <fo:block text-align="center" font-size="10pt" margin-top="4in">
            <xsl:text>Blank Page</xsl:text>
         </fo:block>
      </fo:static-content>
   </xsl:template>

   <xsl:template name="init-static-content-lep">
      <xsl:param name="suppressAtacode" select="0"/>
      <xsl:param name="isIntroToc" select="1"/>
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
            <xsl:with-param name="isChapterLep" select="1"/>
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
            <xsl:with-param name="isChapterLep" select="0"/>
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

        <!-- Honeywell request (2019.02.22)
             - suppress "Draft as of ..." from appearing on CMM draft pages
               -->
        <!-- <fo:block>Draft as of <xsl:value-of select="$draftDate"/></fo:block> -->

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
       <fo:block space-before.optimum="6pt">
         <xsl:value-of select="$g-doc-abbr-name"/>
       </fo:block>
       <fo:block space-before.optimum="2pt">
         <xsl:choose>
           <xsl:when test="/CMM">
             <xsl:value-of select="/CMM/PARTINFO[1]/@MODEL"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="/*/@MODEL"/>
           </xsl:otherwise>
         </xsl:choose>
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
               <fo:table-cell text-align="left" padding-top="3pt" padding-bottom="0pt" padding-left="24pt">
                  <fo:block>*</fo:block>
                  <fo:block>F</fo:block>
                  <xsl:choose>
                    <xsl:when test="/CMM">
                      <fo:block>LF</fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                      <fo:block>L</fo:block>
                    </xsl:otherwise>
                  </xsl:choose>
               </fo:table-cell>
               <fo:table-cell text-align="left" padding-top="3pt" padding-bottom="6pt" padding-left="2pt">
                  <fo:block>indicates pages changed or added data</fo:block>
                  <fo:block>indicates a right foldout</fo:block>
                  <fo:block>indicates a left foldout</fo:block>
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

	    <!-- Sonovision update (2019.11.12)
	         - foldout images in CMM//IPL had right-aligned header/footer captions
	         - may be similar issue in other doctype foldouts, but want this fix
	           to specific for CMM only
	           -->
            <xsl:when test="number($isFoldout) = 1 and ancestor-or-self::CMM and ancestor-or-self::IPL">
              <xsl:attribute name="margin-left" select="'-9in'"/>
            </xsl:when>
            
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
          <fo:block space-before.optimum="6pt">
            <xsl:value-of select="$g-doc-abbr-name"/>
          </fo:block>
          <fo:block space-before.optimum="2pt">
            <xsl:choose>
              <xsl:when test="/CMM">
                <xsl:value-of select="/CMM/PARTINFO[1]/@MODEL"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="/*/@MODEL"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
      </fo:block>
   </xsl:template>

   <xsl:template name="oddPageRegionBeforeStaticContent">
     <!--<xsl:param name="right-margin">.62in</xsl:param>-->
     <xsl:param name="isFoldout" select="0"/>
     <xsl:param name="isTableFoldout" select="0"/>
     <fo:block text-align="center" font-size="10pt">
     <xsl:choose>

	    <!-- Sonovision update (2019.11.12)
	         - foldout images in CMM//IPL had right-aligned header/footer captions
	         - may be similar issue in other doctype foldouts, but want this fix
	           to specific for CMM only
	           -->
            <xsl:when test="number($isFoldout) = 1 and ancestor-or-self::CMM and ancestor-or-self::IPL">
              <xsl:attribute name="margin-left" select="'-9in'"/>
            </xsl:when>

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
       <fo:block space-before.optimum="6pt">
         <xsl:value-of select="$g-doc-abbr-name"/>
       </fo:block>
       <fo:block space-before.optimum="2pt">
         <xsl:choose>
           <xsl:when test="/CMM">
             <xsl:value-of select="/CMM/PARTINFO[1]/@MODEL"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="/*/@MODEL"/>
           </xsl:otherwise>
         </xsl:choose>
       </fo:block>
      </fo:block>
   </xsl:template>

   <xsl:template name="title-page-footer">
      <xsl:param name="page-prefix" select="''"/>
      <xsl:call-template name="write-lep-data">
         <xsl:with-param name="page-prefix" select="$page-prefix"/>
      </xsl:call-template>
     <!--Added margin-top for mantis #17460-->
      <fo:block text-align="center" margin-top="1.5in">
        <xsl:if test="/CMM">
          <xsl:attribute name="margin-top">
            <xsl:choose>
              <xsl:when test="count(//EXPRTCL) &gt; 1">1.8in</xsl:when>
              <xsl:otherwise>1.25in</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="do-export-control"/>
         <fo:table>
            <fo:table-column column-number="1" column-width="3.39in"/>
            <fo:table-column column-number="2" column-width="3.39in"/>
            <fo:table-body>
               <fo:table-row>
                  <fo:table-cell number-columns-spanned="2">
                    <xsl:if test="/CMM">
                      <fo:block text-align="right" font-size="24pt" font-weight="bold">
                        <xsl:choose>
                          <xsl:when test="$documentType = 'irm' and /CMM/@CHAPNBR = '72' and /CMM/@SECTNBR = '00'">
                            <xsl:value-of select="/CMM/@DOCNBR"/>
                          </xsl:when>
                          <xsl:otherwise>
                            
                            <!-- Sonovision update (2019.01.16)
                                 - front cover page
                                 - don't generate empty "dash dash" if no values, but must leave an empty character and change to white
                                   to fill out the footer table cell with the 24pt font-size
                                   -->
                            <xsl:choose>
                             <xsl:when test="/CMM/@CHAPNBR != '' and /CMM/@SECTNBR != '' and /CMM/@SUBJNBR != ''">
                              <xsl:value-of select="concat(/CMM/@CHAPNBR,'-',/CMM/@SECTNBR,'-',/CMM/@SUBJNBR)"/>
                             </xsl:when>
                             <xsl:otherwise>
                              <xsl:attribute name="color"><xsl:text>#FFFFFF</xsl:text></xsl:attribute>
                              <xsl:text>.</xsl:text>
                             </xsl:otherwise>
                            </xsl:choose>
                            
                          </xsl:otherwise>
                        </xsl:choose>
                      </fo:block>
                    </xsl:if>
                     <fo:block text-align="right">
                       <xsl:choose>
                         <xsl:when test="$documentType = 'acmm'">
                           <fo:block>
                             <xsl:text>Page&#160;</xsl:text>
                             <fo:page-number/>
                             <xsl:text>&#160;of&#160;</xsl:text>
                             <xsl:value-of select="$front_body_count"/>
                           </fo:block>
                         </xsl:when>
                         <xsl:otherwise>
                           <xsl:value-of select="'Page T-1'"/>
                         </xsl:otherwise>
                       </xsl:choose>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>

               <fo:table-row>
                  <fo:table-cell border-style="none">
                     <fo:block text-align="left" font-size="10pt" font-family="Arial" margin-top="0mm">
                       <xsl:text>Publication Number&#160;</xsl:text><xsl:value-of select="/*/@DOCNBR"/>
                       <xsl:text>, Revision </xsl:text>
                       <xsl:value-of select="/*/@TSN"/>
                     </fo:block>
                  </fo:table-cell>

                  <fo:table-cell>
                     <fo:block text-align="right" font-size="10pt" font-family="Arial" margin-top="0mm">
                       <xsl:text>Initial </xsl:text>
                       <xsl:call-template name="convert-date">
                         <xsl:with-param name="ata-date" select="/*/@OIDATE"/>
                       </xsl:call-template>
                     </fo:block>
                  </fo:table-cell>
               </fo:table-row>
                
                <!--<xsl:if test="/EM">-->
              <xsl:if test="not(/*/@TSN = 0)">
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
              </xsl:if>
              
               <fo:table-row>
                  <fo:table-cell number-columns-spanned="2" border="none">
                     <fo:block text-align="center" font-size="8pt" font-family="Arial" margin-top="11pt">
                       <xsl:if test="not(/*/@TSN = 0)">
                         <xsl:attribute name="margin-top">4pt</xsl:attribute>
                       </xsl:if>
                        <xsl:value-of select="$copyright-statement"/>
                     </fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <fo:block>&#160;</fo:block>
                  </fo:table-cell>
               </fo:table-row>
            </fo:table-body>
         </fo:table>
      </fo:block>
   </xsl:template>


   <!-- Footer for the balance of the "T-" section -->
  <xsl:template name="title-section-footer">
    <xsl:param name="page-prefix"/>
    <xsl:param name="page-suffix"/>
    <xsl:param name="pgblk-confnbr"/>
    <xsl:param name="pgblk-effect"/>
    <xsl:call-template name="write-lep-data">
      <xsl:with-param name="page-prefix" select="'T-'"/>
      </xsl:call-template>
      <fo:block text-align="center" display-align="after" margin-top="3.6pt" padding="0pt">
         <fo:table>
            <fo:table-column column-number="1" column-width="2.425in"/>
            <fo:table-column column-number="2" column-width="2.425in"/>
            <fo:table-column column-number="3" column-width="1.93in"/>
            <fo:table-body>
               <fo:table-row>

                  <fo:table-cell border-style="none" number-rows-spanned="1" display-align="before" number-columns-spanned="2" padding-after="0pt">
                     <fo:block text-align="right" padding="0pt" font-weight="bold" font-size="24pt" font-family="Arial">
                        <!-- They apparently don't want any big ata numbers in the title section -->
                        <!-- Leave the required space in to maintain the dimensions             -->
                        <!--<xsl:value-of select="/*/@DOCNBR"/>-->
                        <!--<xsl:text>&#160;</xsl:text>-->
                       <xsl:if test="/CMM">
                         <xsl:choose>
                           <xsl:when test="/CMM/@CHAPNBR = '72' and /CMM/@SECTNBR = '00' and $documentType = 'irm'">
                             <xsl:value-of select="/CMM/@DOCNBR"/>
                           </xsl:when>
                           <xsl:otherwise>
                             <xsl:call-template name="get-atacode"/>
                           </xsl:otherwise>
                         </xsl:choose>
                       </xsl:if>
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
                        <xsl:with-param name="ata-date" select="/*/@REVDATE"/>
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

  <xsl:template name="get-atacode">
    <xsl:param name="suppressAtacode" select="0"/>
    <xsl:param name="isChapterToc" select="0"/>
    <xsl:choose>
      <!-- Suppress is indicated explicitly -->
      <xsl:when test="1 = number($suppressAtacode)">
        <xsl:text>&#160;</xsl:text>
      </xsl:when>
      <!-- Within a page block or unit -->
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
        <!-- NOW PULLS SECTNBR FROM UNIT INSTEAD OF SECTION (IN EIPC). THIS IS BECAUSE OF MANUALS THAT HAVE UNITS WITH DIFFERENT SECTION NUMBERS THAN THE PARENT SECTION. -->
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
      <!-- Within section -->
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
      <!-- Within chapter -->
      <xsl:when test="ancestor-or-self::CHAPTER">
        <!-- DJH 20091204
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
        -->
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
  </xsl:template>

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

      <xsl:param name="page-type" select="''"/>

      <xsl:call-template name="write-lep-data">
         <xsl:with-param name="page-prefix" select="$page-prefix"/>
         <xsl:with-param name="page-suffix" select="$page-suffix"/>
         <xsl:with-param name="pgblk-confnbr" select="$pgblk-effect"/>
         <xsl:with-param name="pgblk-effect" select="$pgblk-effect"/>
      </xsl:call-template>

      <xsl:variable name="atacode">
        <xsl:choose>
          <xsl:when test="/CMM/@CHAPNBR = '72' and /CMM/@SECTNBR = '00' and $documentType = 'irm'">
            <xsl:value-of select="/CMM/@DOCNBR"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="get-atacode">
              <xsl:with-param name="suppressAtacode" select="$suppressAtacode"/>
              <xsl:with-param name="isChapterToc" select="$isChapterToc"/>
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
       
	    <!-- Sonovision update (2019.11.12)
	         - foldout images in CMM//IPL had right-aligned header/footer captions
	         - may be similar issue in other doctype foldouts, but want this fix
	           to specific for CMM only
	           -->
            <xsl:if test="number($isFoldout) = 1 and ancestor-or-self::CMM and ancestor-or-self::IPL">
              <xsl:attribute name="margin-left" select="''"/>
            </xsl:if>
       
       
       <xsl:if test="/EM and ancestor-or-self::CHAPTER[@CHAPNBR = '05'] and ancestor-or-self::SECTION[@SECTNBR = '10']">
         <fo:block font-size="9pt" color="red" font-weight="bold" margin-top="-0.1in">
           <xsl:text>AIRWORTHINESS LIMITATIONS</xsl:text>
         </fo:block>
       </xsl:if>
       <fo:table border="none" padding="0pt"><!--  border="red solid 1pt"-->
            <fo:table-column column-number="1" column-width="1.00in"/>
            <fo:table-column column-number="2" column-width="2.25in"/>
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
              
              
              <!-- Sonovision update (2018.12.04)
                   - must shift "EFFECTIVITY" a little bit lower in the footer to match FOSI
                   - move EFFECTIVITY to next "table-row" and 
                     change next table-cell border-bottom line a bit further down
                     -->
              <fo:table-row>
                <fo:table-cell>
                  <!-- <fo:block font-size="10pt" margin-top="-5pt" text-align="left">EFFECTIVITY</fo:block> -->
                </fo:table-cell>

                <!-- <fo:table-cell border-top="black solid 1pt" border-right="black solid 1pt"/> -->
                <!-- <fo:table-cell border-bottom="black solid 1pt"/> -->

                  <!-- Sonovision update (2019.07.03)
                       - don't want "EFFECTIVITY" box on "T-" blank pages
                         -->
                  <xsl:choose>
                  
                   <xsl:when test="($page-prefix='T-') and ($page-type='BLANK')">
                    <!-- REMOVE TOP BAR -->
                     <fo:table-cell/>
                   </xsl:when>
                  
                   <xsl:otherwise>
                    <fo:table-cell border-bottom="black solid 1pt"/>
                   </xsl:otherwise>
                  </xsl:choose>


                <!--<fo:table-cell/>
                <fo:table-cell/>-->
                <!--Added for mantis #20187-->
                <fo:table-cell number-columns-spanned="2">
                  <fo:block text-align="right" margin-left="-0.1">
                    <xsl:text>&#xA0;</xsl:text><fo:retrieve-marker retrieve-class-name="confnbrValue" retrieve-position="first-including-carryover"/>
                    <xsl:if test="$documentType = 'irm'">
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
                    </xsl:if>
                  </fo:block>
                </fo:table-cell>
              </fo:table-row>
              
              <fo:table-row>
                
                <!-- <fo:table-cell number-columns-spanned="2" border-right="black solid 1pt" text-align="left"> -->

                  <!-- Sonovision update (2019.07.03)
                       - don't want "EFFECTIVITY" box on "T-" blank pages
                         -->
                  <xsl:choose>
                  
                   <xsl:when test="($page-prefix='T-') and ($page-type='BLANK')">
                    <!-- EMPTY CELL (no "EFFECTIVITY" or right bar)  -->
                    <fo:table-cell number-columns-spanned="2">
                     <xsl:text> </xsl:text>
                    </fo:table-cell>
                   </xsl:when>
                  
                   <xsl:otherwise>
                    <fo:table-cell number-columns-spanned="2" border-right="black solid 1pt" text-align="left">
                     <fo:block font-size="10pt" margin-top="-5pt" text-align="left">EFFECTIVITY</fo:block>
                     <xsl:if test="//EM"><fo:block height="0pt" width="0pt" max-height="0pt" max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">__effectStart__</fo:block></xsl:if>
                      <fo:block font-size="10pt">
                       <fo:retrieve-marker retrieve-class-name="efftextValue" retrieve-position="last-starting-within-page"/>
                      </fo:block>
                     <xsl:if test="//EM"><fo:block height="0pt" width="0pt" max-height="0pt" max-width="0pt" font-size="0pt" line-height="0pt" keep-with-next="always">__effectEnd__</fo:block></xsl:if>
                    </fo:table-cell>
                   </xsl:otherwise>
                  </xsl:choose>

                
                <!-- This is the docnbr, the ata-code, or blank in 24pt bold -->
                 <fo:table-cell padding="0pt">
                   <!--Changed text-align from right to center for CMM.-->
                    <fo:block text-align="center" font-weight="bold" font-size="24pt" font-family="Arial">
                    
                      <!-- Sonovision update (2019.07.03)
                           - don't want "EFFECTIVITY" box on "T-" blank pages
                           - move ATA code up slightly to better match other non-blank "T-" pages
                           -->
                      <xsl:choose>
                  
                      <xsl:when test="($page-prefix='T-') and ($page-type='BLANK')">
                        <!-- NO: - shifting ATA code up also pushes copyright down
                                 - "T-" blank pages are relatively rare occurrence, 
                                   so ATA code appearing slightly lower than other "T-" pages is OK
                                   -->
                        <!-- <fo:inline baseline-shift="super"> -->
                         <xsl:value-of select="$atacode"/>
                        <!-- </fo:inline> -->
                      </xsl:when>
                      
                      <xsl:otherwise>
                       <xsl:value-of select="$atacode"/>
                      </xsl:otherwise>
                     </xsl:choose>
                    </fo:block>

                    <!--Removed for mantis #20187-->
                    <!--<fo:block text-align="right" font-weight="bold" font-size="8pt" font-family="Arial" padding-top="-6pt">
                      <xsl:text>&#xA0;</xsl:text><fo:retrieve-marker retrieve-class-name="confnbrValue" retrieve-position="first-including-carryover"/>
                    </fo:block>-->
                  </fo:table-cell>

                 <fo:table-cell padding="0pt" text-align="right" font-size="10pt" font-family="Arial">
                     <xsl:choose>
                       <xsl:when test="1 = number($isFoldout)">
                         <fo:block margin-left="-0.5in">
                           <xsl:text>Page </xsl:text>
                           <fo:inline>
                             <fo:retrieve-marker retrieve-class-name="foldout-page-string" retrieve-boundary="page"/>  
                           </fo:inline>
                         </fo:block>
                       </xsl:when>
                       <xsl:when test="$documentType ='acmm'">
                         <fo:block>
                           <xsl:text>Page&#160;</xsl:text>
                           <fo:page-number/>
                           <xsl:text>&#160;of&#160;</xsl:text>
                           <xsl:value-of select="$front_body_count"/>
                         </fo:block>
                       </xsl:when>
                       <xsl:otherwise>
                         <fo:block>
                           <xsl:value-of select="concat('Page ',$page-prefix)"/>
                           <fo:page-number/>
                           <xsl:value-of select="$page-suffix"/>
                           <xsl:if test="/EM and not(normalize-space(ancestor-or-self::PGBLK/@CONFNBR) = ('','NA'))">
                             <fo:inline>
                               <xsl:value-of select="concat('-',ancestor-or-self::PGBLK/@CONFNBR)"/>
                             </fo:inline>
                           </xsl:if>
                           
      <!-- Sonovision update (2018.11.08)
           - output the REPAIR number if @confnbr!="1"
             
             e.g.
             <pgblk confnbr="0000" key="cmm12307503651894659" pgblknbr="6000">
	     <title>REPAIR</title>
	     
	     section title should appear as "REPAIR 0000" in PDF
	     -->
      <!-- <xsl:if test="(normalize-space(upper-case(ancestor-or-self::PGBLK/TITLE))='REPAIR') and (ancestor-or-self::PGBLK/@CONFNBR != '1')"> -->
      
      <!-- Sonovision update (2018.11.29)
           - all sections (not just "REPAIR") if @confnbr specified and not equal to "1"
             -->
      <!--
      <xsl:if test="(ancestor-or-self::PGBLK/@CONFNBR) and (ancestor-or-self::PGBLK/@CONFNBR != '1')">
       <xsl:text>-</xsl:text>
       <xsl:value-of select="ancestor-or-self::PGBLK/@CONFNBR"/>
      </xsl:if>
      -->

      <!-- Sonovision update (2018.12.13)
           - exclude $documentType='irm' as it uses "EFFECT"
           - exclude EM $documentType='em | lmm | hmm | emm | eohm | spm | rm' as it has separate handling for appending "@CONFNBR"
           - exclude @CONFNBR='NA'
           
             -->
      <xsl:choose>

       <xsl:when test="$documentType='irm'">
        <!-- IRM - don't need PGBLK/@CONFNBR as already using PGBLK/EFFECT -->
        
        <!-- Sonovision update (2019.01.29)
             - now want @CONFNBR to appear as fallback when EFFECT doesn't exist
               -->
        <xsl:if test="not(ancestor-or-self::PGBLK/EFFECT)">
        
          <xsl:if test="(ancestor-or-self::PGBLK/@CONFNBR) and (ancestor-or-self::PGBLK/@CONFNBR != '1')">
	    <xsl:text>-</xsl:text>
	    <xsl:value-of select="ancestor-or-self::PGBLK/@CONFNBR"/>
	   </xsl:if>

        </xsl:if>
        
       </xsl:when>

       <xsl:when test="$documentType='em' or $documentType='lmm' or $documentType='hmm' or $documentType='emm' or
                       $documentType='eohm' or $documentType='spm' or $documentType='rm'">
        <!-- EM - has it's own handling adding PGBLK/@CONFNBR to page footer-->
       </xsl:when>

       <xsl:when test="ancestor-or-self::PGBLK/@CONFNBR = 'NA'">
        <!-- Don't add "NA" suffix -->
       </xsl:when>

       <xsl:otherwise>
        <xsl:if test="(ancestor-or-self::PGBLK/@CONFNBR) and (ancestor-or-self::PGBLK/@CONFNBR != '1')">
         <xsl:text>-</xsl:text>
         <xsl:value-of select="ancestor-or-self::PGBLK/@CONFNBR"/>
        </xsl:if>
       </xsl:otherwise>
      </xsl:choose> 

                           
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

           <xsl:if test="/CMM">
             <fo:block>
               <xsl:text>__documentType__</xsl:text>
               <xsl:value-of select="/CMM/@TYPE"/>
             </fo:block>
           </xsl:if>

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

           <fo:block>
             <xsl:value-of select="concat('__confnbr__',ancestor-or-self::PGBLK/@CONFNBR)"/>
           </fo:block>

           <fo:block>
             <xsl:text>__effect__</xsl:text>
             <xsl:value-of select="$pgblk-effect"/>
           </fo:block>

         </fo:block-container>
      </xsl:if>
   </xsl:template>


   <!-- Manual LEP testing for new LEP format -->

   <!-- End of testing for new LEP format -->
</xsl:stylesheet>
