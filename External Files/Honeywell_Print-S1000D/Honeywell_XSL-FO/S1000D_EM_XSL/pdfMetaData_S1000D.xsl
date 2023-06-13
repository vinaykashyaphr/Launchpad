<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:atict="http://www.ptc.com/"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    >
    

<!-- Sonovision update (2019.07.02)
     - PDF metadata now stored in separate module which will be update during
       full build process from CVS to include application version information
       in the PDF "subject" field
       
       e.g. "ATA Desktop v3.2"
       -->

<xsl:template name="pdfMetaData">

	<!-- PDF settings and metadata using XEP PIs and extensions ("rx:" elements) -->
	<xsl:processing-instruction name="xep-pdf-initial-zoom">fit</xsl:processing-instruction>
	<xsl:processing-instruction name="xep-pdf-page-layout">single-page</xsl:processing-instruction>
	<xsl:processing-instruction name="xep-pdf-viewer-preferences">fit-window center-window</xsl:processing-instruction>
	<xsl:processing-instruction name="xep-pdf-logical-page-numbering" select="'false'" />
	<xsl:processing-instruction name="xep-pdf-view-mode">show-none</xsl:processing-instruction>
	<rx:meta-info>

		<!-- RS: This is "Component Maintenance Manual" in ATA. There doesn't 
			seem to be a corresponding element in S1000D -->
		<!--<rx:meta-field name="title" value="{CMM/TITLE}"/> -->
		<rx:meta-field name="title" value="{$g-doc-full-name}" />
		<rx:meta-field name="author">
			<xsl:attribute name="value">
				<xsl:call-template name="splAuthor">
					<!-- In S1000D, the cage code comes from @pmIssuer -->
					<!--<xsl:with-param name="cageCode" select="lower-case(CMM/@SPL)"/>-->
					<xsl:with-param name="cageCode"
						select="lower-case(/pm/identAndStatusSection/pmAddress/pmIdent/pmCode/@pmIssuer)" />
				</xsl:call-template>            
			</xsl:attribute>
		</rx:meta-field>
		
		<!-- <rx:meta-field name="subject" value="{$documentType}" /> -->
        	
        	<rx:meta-field name="subject">
	          <xsl:attribute name="value">
	           <xsl:value-of select="upper-case($documentType)"/>
	           <xsl:text> - </xsl:text>
	           <xsl:text>S1000D Network (EM) v3.13</xsl:text>
	          </xsl:attribute>
	        </rx:meta-field>

		<rx:meta-field name="keywords">
			<xsl:attribute name="value">
				<!-- DOCNBBR is the ATA number like "12-34-56". In S1000D it looks like it is derived from /pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'] -->
			        <!--
		                <xsl:if test="CMM/@DOCNBR != ''">
		                 <xsl:value-of select="concat('Doc No. ',CMM/@DOCNBR,', ')"/>
		                </xsl:if>
				-->
            
		            	<xsl:if test="string(/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP']) != ''">
		            	  <xsl:value-of select="concat('Doc No. ',/pm/identAndStatusSection/pmAddress/pmAddressItems/externalPubCode[@pubCodingScheme='CMP'],', ')" />
		            	</xsl:if>
	    
			    	<!-- Skip these details for now... -->
		            	<!--
		            	<xsl:if test="CMM/@CHAPNBR != '' and CMM/@SECTNBR != '' and CMM/@SUBJNBR != ''">
		            	  <xsl:value-of select="concat('ATA No. ',string-join((CMM/@CHAPNBR,CMM/@SECTNBR,CMM/@SUBJNBR),'-'),', ')"/>
		            	</xsl:if>
		            	<xsl:value-of select="concat('Rev. ',CMM/@TSN)"/>
		            	-->
          	
          		</xsl:attribute>
		</rx:meta-field>
	</rx:meta-info>


</xsl:template>


</xsl:stylesheet>
