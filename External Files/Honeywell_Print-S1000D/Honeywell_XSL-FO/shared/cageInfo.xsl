<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:stbl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.Table" xmlns:xtbl="com.nwalsh.xalan.Table">

	<!--<xsl:output method="xml" encoding="UTF-8" indent="yes"/>-->

	<xsl:template name="do-spl-logo">
		<xsl:param name="cageCode"/>
		<xsl:param name="splLogo"/>
		<xsl:choose>
			<xsl:when test="$cageCode = '99193'">
				<fo:external-graphic  src="url({$globalExtObj_logo})"/>
			</xsl:when>
			<xsl:otherwise>
			  <fo:external-graphic src="url({$splLogo})"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Honeywell update (2018.05.11) to include cage code: 0bfa5 and 94580 -->

	<xsl:template name="splAuthor">
		<xsl:param name="cageCode"/>
		<xsl:choose>
			<xsl:when test="$cageCode = ('07217')">
				<xsl:text>Honeywell Limited</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('65507','1std7','99866','22373','55939','58960','99193',
				'97896','0yfp0','27914','56081','55284','06848','59364','70210','64547','72914',
				'1m8l7','kf586','0ug66','31395','5vwn5','56776','38473','63389','u1605','0bfa5','94580')">
				<xsl:text>Honeywell International Inc.</xsl:text>
			</xsl:when>

			<!-- (e.g. "99193-CAPU") -->
			<xsl:when test="starts-with($cageCode,'99193')">
				<xsl:text>Honeywell International Inc.</xsl:text>
			</xsl:when>


			<xsl:when test="$cageCode = ('u1605')">
				<xsl:text>Honeywell International Inc.</xsl:text>
			</xsl:when>


			<xsl:when test="$cageCode = ('0s4a8')">
				<xsl:text>CFE Company</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('6nba7')">
				<xsl:text>Flatirons Solutions Inc.</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('6pc31')">
				<xsl:text>BendixKing</xsl:text>
			</xsl:when>

			<xsl:when test="$cageCode = ('f0302')">
				<xsl:text>Hispano-Suiza</xsl:text>
			</xsl:when>

			<xsl:when test="$cageCode = ('19710')">
				<xsl:text>MPC Products Corporation</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('1r5y6')">
				<xsl:text>Aviation Communications and Surveillance Systems Division</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('f9111')">
				<xsl:text>Thales Avionics</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('61349')">
				<xsl:text>Ametek Aerospace and Defense Inc.</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('2y402')">
				<xsl:text>Racal Avionics Inc.</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('90073')">
				<xsl:text>Pelorus Navigation Systems, Inc.</xsl:text>
			</xsl:when>
			<xsl:when test="$cageCode = ('1y4q3')">
				<xsl:text>Shaw Aerox LLC</xsl:text>
			</xsl:when>

		  <xsl:when test="$cageCode = ('u6578')">
		    <xsl:text>Meggitt Control Systems Birmingham</xsl:text>
		  </xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="splInformation">
		<xsl:param name="cageCode"/>
		<xsl:param name="splLogo"/>
		<xsl:choose>
			<xsl:when test="$cageCode = '07217'">
			  <fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell Limited</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">3333 Unity Drive</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Mississauga, Ontario</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Canada L5L 3S6</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 07217</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '65507'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">8840 Evergreen Boulevard</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Minneapolis, Minnesota 55433-6040</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 65507</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			
			<!-- Honeywell update (2020.05.11) added cagecode '0bfa5'-->
			
			<xsl:when test="$cageCode = '0bfa5'">
				<fo:external-graphic src="url({$splLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">13350 US Highway 19 N.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Clearwater, Florida 33764-7226</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 0BFA5</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial" space-after.optimum="10pt">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			
			<!-- Honeywell update (2020.05.11) added cageCode '94580'-->

			<xsl:when test="$cageCode = '94580'">
				<fo:external-graphic src="url({$splLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">2600 Ridgway Parkway</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Minneapolis, Minnesota 55413-1719</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 94580</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial" space-after.optimum="10pt">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			
			<xsl:when test="$cageCode = '1std7'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">23500 W. 105th Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Olathe, Kansas 66061-8425</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 1STD7</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '99866'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">23500 W. 105th Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Olathe, Kansas 66061-8425</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 99866</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '22373'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">23500 W. 105th Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Olathe, Kansas 66061-8425</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 22373</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '55939'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">21111 N. 19th Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85027-2708</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 55939</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '58960'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">21111 N. 19th Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85027-2708</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 58960</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '99193' or starts-with($cageCode,'99193')">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">111 S. 34th Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85034-2802</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 99193</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>


			<xsl:when test="$cageCode = '99193' or starts-with($cageCode,'u1605')">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Bunford Lane</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Yeovil BA20 2YD</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">United Kingdom</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: U1605</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>

			<xsl:when test="$cageCode = '97896'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">15001 N.E. 36 Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Redmond, Washington 98052-5317</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 97896</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '0yfp0'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">15001 N.E. 36 Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Redmond, Washington 98052-5317</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 0YFP0</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '27914'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">15001 N.E. 36 Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Redmond, Washington 98052-5317</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Canada</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 27914</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '56081'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">8323 Lindbergh Court</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Sarasota, Florida 34243-3272</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 56081</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '55284'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">3520 Westmoor Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">South Bend, Indiana 46628-1373</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 55284</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '06848'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
			  <fo:block text-align="left" font-size="10pt" font-family="Arial">3520 Westmoor Street</fo:block>
			  <fo:block text-align="left" font-size="10pt" font-family="Arial">South Bend, Indiana 46628-1373</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 06848</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '59364'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">1300 W. Warner Road</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Tempe, Arizona 85284-4282</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 59364</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '70210'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">2525 West 190th Street</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Torrance, California 90504-6002</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 70210</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '64547'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">11100 N. Oracle Road</fo:block>
				<!-- 2020-09-29 Update Start -->
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Tucson, Arizona 85737-9588</fo:block>
				<!-- 2020-09-29 Update End -->
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 64547</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '72914'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">550 State Route 55</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Urbana, Ohio 43078-1948</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 72914</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '0s4a8'">
			  <fo:block text-align="left" font-size="10pt" font-family="Arial">CFE Company</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">111 S. 34th St.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85034-2802</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 0S4A8</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (U.S.A.)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '1m8l7'"> 
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">13475 Danielson Street, Suite 100</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Poway, California 92064</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 1M8L7</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = 'kf586'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Gren Lane</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Ashchurch, Tewkesbury GL20 8HD</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">United Kingdom</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: KF586</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '0ug66'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">125 Technology Parkway</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Norcross, Georgia 30092</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 0UG66</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '31395'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">660 Engineering Drive</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Norcross, Georgia 30092</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 31395</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '5vwn5'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">660 Engineering Drive</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Norcross, Georgia 30092</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 5VWN5</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '56776'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">121 Whittendale Drive Suite A</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Moorestown, New Jersey 08057</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 56776</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '38473'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">400 Maple Grove Road</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Ottawa, Ontario K2V 1B8</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Canada</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 38473</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
		  <xsl:when test="$cageCode = '63389'">
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">dba Honeywell LORI</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">6930 N Lakewood Ave</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Tulsa, Oklahoma 74117</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 63389</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
		    </fo:block>
		  </xsl:when>
		  <!-- Non HW CAGE Codes -->
		  <xsl:when test="$cageCode = '6nba7'">
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Flatirons Solutions Inc.</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">17671 Cowan Avenue, Suite 200</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Irvine, California 92614-6078</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">U.S.A.</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">CAGE: 6NBA7</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Telephone: 949-474-4200</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('http://www.flatironssolutions.com/')"><fo:inline text-decoration="underline" color="blue">www.flatironssolutions.com</fo:inline></fo:basic-link>
		    </fo:block>
		  </xsl:when>
		  <xsl:when test="$cageCode = '6pc31'">
		  	<!--BendixKing-->
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">9201 B San Mateo Blvd N.E.</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Albuquerque, New Mexico 87113</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 6PC31</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 855-250-7027 (Toll Free U.S.A./Canada)</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 505-903-6148 (International Direct)</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('http://www.bendixking.com')"><fo:inline text-decoration="underline" color="blue">www.bendixking.com</fo:inline></fo:basic-link>
		    </fo:block>
		  </xsl:when>


		  <xsl:when test="$cageCode = 'f0302'">
		  	<!--HISPANO-SUIZA-->
		    <!-- Sonovision update (2018.12.03) - FOSI updated, so must do same for XSL-FO -->
		    <!-- <fo:block text-align="left" font-size="10pt" font-family="Arial">Hispano-Suiza</fo:block> -->
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">SAFRAN ELECTRICAL &amp; POWER</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Reau Center</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Rond-Point Rene Ravaud BP42</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">7551 Moissy-Cramayel Cedex</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">France</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: F0302</fo:block>
		  </xsl:when>


			<xsl:when test="$cageCode = '19710'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">MPC Products Corporation</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">7426 N. Linder Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Skokie, Illinois 60077-3219</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 19710</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '1r5y6'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Aviation Communications and Surveillance Systems Division</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">19810 N. 7th Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85027-4400</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 1R5Y6</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = 'f9111'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Thales Avionics</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">1 Avenue Carnot</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">91883 Massy Cedex</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">France</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: F9111</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '61349'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Ametek Aerospace and Defense Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Power and Data Systems</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">900 E. Clymer Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Sellersville, Pennsylvania 18960-2628</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 61349</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '2y402'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Racal Avionics Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">8851 Mondard Drive</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Silver Spring, Maryland 20910-1816</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 2Y402</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '90073'">
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Pelorus Navigation Systems, Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">5418 11th Street N.E.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Calgary, Alberta Canada T2I 7E9</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 90073</fo:block>
			</xsl:when>
		  <xsl:when test="$cageCode = '1y4q3'">
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Shaw Aerox LLC</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">206 Ossipee Trail, PO Box 482</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Limington, ME 04049</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">CAGE: 1Y4Q3</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Telephone: 800-237-6902</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://www.aerox.com')"><fo:inline text-decoration="underline" color="blue">www.aerox.com</fo:inline></fo:basic-link></fo:block>
		  </xsl:when>
		  <xsl:when test="$cageCode = 'u6578'">
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Meggitt Control Systems Birmingham</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Oscar House</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Wharfdale Road</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Tyseley</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">Birmingham B11 2DG</fo:block>
		    <fo:block text-align="center" font-size="12pt" font-family="Arial">UK</fo:block>
		  </xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prtnrsplInformation">
		<xsl:param name="cageCode"/>
		<xsl:param name="prtnrsplLogo"/>
		<xsl:choose>
		  <xsl:when test="$cageCode = '07217'">
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell Limited</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">3333 Unity Drive</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Mississauga, Ontario</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Canada L5L 3S6</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 07217</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
		  	<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
		    <fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
		    </fo:block>
		  </xsl:when>
			<xsl:when test="$cageCode = '65507'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">8840 Evergreen Boulevard</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Minneapolis, Minnesota 55433-6040</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 65507</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '55939'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">21111 N. 19th Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85027-2708</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 55939</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '58960'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Honeywell International Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">21111 N. 19th Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85027-2708</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 58960</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 800-601-3099 (Toll Free U.S.A./Canada)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Telephone: 602-365-3099 (International Direct)</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Website:&#160;<fo:basic-link external-destination="url('https://aerospace.honeywell.com')"><fo:inline text-decoration="underline" color="blue">https://aerospace.honeywell.com</fo:inline></fo:basic-link>
				</fo:block>
			</xsl:when>
			<!-- Non HW CAGE Codes -->
			<xsl:when test="$cageCode = '19710'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">MPC Products Corporation</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">7426 N. Linder Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Skokie, Illinois 60077-3219</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 19710</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '1r5y6'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Aviation Communications and Surveillance Systems Division</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">19810 N. 7th Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Phoenix, Arizona 85027-4400</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 1R5Y6</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = 'f9111'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Thales Avionics</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">1 Avenue Carnot</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">91883 Massy Cedex</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">France</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: F9111</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '61349'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Ametek Aerospace and Defense Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Power and Data Systems</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">900 E. Clymer Avenue</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Sellersville, Pennsylvania 18960-2628</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 61349</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '2y402'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Racal Avionics Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">8851 Mondard Drive</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Silver Spring, Maryland 20910-1816</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">U.S.A.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 2Y402</fo:block>
			</xsl:when>
			<xsl:when test="$cageCode = '90073'">
				<fo:external-graphic src="url({$prtnrsplLogo})"/>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Pelorus Navigation Systems, Inc.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">5418 11th Street N.E.</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">Calgary, Alberta Canada T2I 7E9</fo:block>
				<fo:block text-align="left" font-size="10pt" font-family="Arial">CAGE: 90073</fo:block>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
