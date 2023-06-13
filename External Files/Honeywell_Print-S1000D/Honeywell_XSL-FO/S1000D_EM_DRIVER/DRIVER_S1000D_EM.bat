@echo off

rem *** S1000D (EM) NETWORK configuration ***

rem *** Path Configuration ***
call ..\environment.bat

echo ==========================
echo *** Parameters Setting ***
echo ==========================
rem set params="IMAGES_DIR=file:///%WorkPath%/images/" "GRAPHICS_DIR=file:///%WorkPath%/S1000D_EM_DRIVER/XML_INPUT/graphics" "WorkPath=file:///%WorkPath%/S1000D_EM_DRIVER"
rem *** S1000D already includes "graphics" path inside combined %WorkPath%\S1000D_EM_DRIVER\TEMP file ***
rem set params="IMAGES_DIR=file:///%WorkPath%/images/" "GRAPHICS_DIR=file:///%WorkPath%/S1000D_EM_DRIVER/XML_INPUT" "WorkPath=file:///%WorkPath%/S1000D_EM_DRIVER"

rem *** NOTE: IMAGES_DIR (logos, etc.) located in network RenderPath location ***
set params="IMAGES_DIR=file:///%RenderPath%/images/" "GRAPHICS_DIR=file:///%WorkPath%/S1000D_EM_DRIVER/XML_INPUT" "WorkPath=file:///%WorkPath%/S1000D_EM_DRIVER"





REM rem *********************************************************************
REM rem *********************************************************************
REM rem *********************************************************************
REM 
REM echo ==========================
REM echo *** CGM Conversion     ***
REM echo ==========================
REM 
REM rem *** Larson "CGM to Vector" command line testing ***
REM rem NOTE: - should be set in "environment.bat" 
REM rem       - not sure if must be installed on user's system, or can reside as generic ".\applications\Larson\*.*"
REM rem       - supports CGM conversion to PDF, EPS, SVG
REM rem         (XEP processing having best results using PDF image)
REM set LARSON_CMD="C:\Program Files (x86)\Larson Software Technology\Larson CGM to Vector\cgm2vector.exe"
REM 
REM rem *** NOTE: this is how to specify path to graphics (DESKTOP BAT file)
REM set CGM_GRAPHICS_DIR=%WorkPath%\S1000D_EM_DRIVER\XML_INPUT\graphics
REM 
REM 
REM %LARSON_CMD% "%CGM_GRAPHICS_DIR%" -out "%CGM_GRAPHICS_DIR%" -o -pdf
REM %LARSON_CMD% "%CGM_GRAPHICS_DIR%" -out "%CGM_GRAPHICS_DIR%" -o -svg
REM %LARSON_CMD% "%CGM_GRAPHICS_DIR%" -out "%CGM_GRAPHICS_DIR%" -o -eps
REM 
REM rem *********************************************************************
REM rem *********************************************************************
REM rem *********************************************************************


echo ====================
echo *** Start Render ***
echo ====================

for %%a in ("%WorkPath%\S1000D_EM_DRIVER\XML_INPUT\*.xml") do (

	echo PROCESSING: "%WorkPath%\S1000D_EM_DRIVER\XML_INPUT\%%~na%%~xa"
	
	echo ===================================
	echo 0   *** Deleting existing files ***
	echo ===================================
	del "%WorkPath%\S1000D_EM_DRIVER\PDF_OUTPUT\%%~na*"
	del "%WorkPath%\S1000D_EM_DRIVER\TEMP\*.*" /F /Q
	copy pm_cmb.xsd "%WorkPath%\S1000D_EM_DRIVER\TEMP\pm_cmb.xsd"
	copy pm_calstblx.mod "%WorkPath%\S1000D_EM_DRIVER\TEMP\pm_calstblx.mod"

	echo =======================
	echo 1   *** Cleanup XML ***
	echo =======================
rem		 Character code check and editor cleanup

	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\XML_INPUT\%%~na%%~xa" -sb "%RenderPath%\omnimark\char_font_fix.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_FIXED_CHAR.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_char_font_fix_pass_1.err"
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_FIXED_CHAR.xml" -sb "%RenderPath%\omnimark\pre_process.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PRE-PROCESSED.xml" -d GsLogFileName "%WorkPath%\S1000D_EM_DRIVER\TEMP\parse1.log" -d GsGen2LogFileName "%WorkPath%\S1000D_EM_DRIVER\TEMP\gen2_shift-f6.txt" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_pre_process.err"

	echo ==========================================
	echo 2   *** Fixing Processing Instructions ***
	echo ==========================================
rem		 Remove arbortext pi, resolve nested rev markup pi, transform style pi to elements.
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PRE-PROCESSED.xml" -sb "%RenderPath%\omnimark\fix_pi.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_FIXED_PI.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_fix_pi.err"

	echo ==========================
	echo 3   *** Updating GNBRs ***
	echo ==========================
rem		 Update graphic attributes to point to graphic files
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_FIXED_PI.xml" -sb "%RenderPath%\omnimark\update_gnbrs.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPDATED_GNBRs.xml" -d GsGraphicsDir "%WorkPath%/S1000D_EM_DRIVER/XML_INPUT/graphics" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_update_gnbrs.err"

	echo ======================
	echo 4   *** Create EDI ***
	echo ======================

rem %omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPDATED_GNBRs.xml" -sb "%RenderPath%\omnimark\create_edi.xom" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_create_edi.err" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\edi_tables.xml"

rem *** Injecting additional wrapper markup into "*UPDATED_GNBRs_S1000D.xml" to be used only for EDI generation
rem     (this is a temp file which does not need to be cleaned up)
%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPDATED_GNBRs.xml" -sb "%RenderPath%\omnimark\prep_edi_S1000D.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPDATED_GNBRs_S1000D.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_prep_edi_S1000D.err"
%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPDATED_GNBRs_S1000D.xml" -sb "%RenderPath%\omnimark\create_edi_S1000D.xom" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_create_edi.err" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\edi_tables.xml" -d GsDebugFileName "%WorkPath%\S1000D_EM_DRIVER\TEMP\create_edi_debug.txt"


	echo =======================
	echo 5   *** Propagating Rev ***
	echo =======================
rem		 Relocate rev markup to simplify transform
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPDATED_GNBRs.xml" -sb "%RenderPath%\omnimark\propagate_rev.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PROPAGATED_REV.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_propagate_rev.err"

	echo ===================================
	echo 6   *** Running Shift-F6 replacment ***
	echo ===================================
rem		 Generate acro/abbr list and tool/consumable tables if necessary
REM	if exist "%WorkPath%\S1000D_EM_DRIVER\TEMP\gen2_shift-f6.txt" (
REM		echo Running GEN-2 replacement
REM		%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PROPAGATED_REV.xml" -sb "%RenderPath%\omnimark\cmm_shift_f6_GEN2.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_sf6.xml" -d GsMainInput "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PROPAGATED_REV.xml" -d GsLogName "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_shift-f6_GEN2_debug.txt" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_shift-f6_GEN2.err"
REM	) else (
REM		echo Running original replacement
REM		%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PROPAGATED_REV.xml" -sb "%RenderPath%\omnimark\cmm_shift_f6.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_sf6.xml" -d GsMainInput "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PROPAGATED_REV.xml" -d GsLogName "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_shift-f6_debug.txt" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_shift-f6.err"
REM	)

	echo ======================
	echo 7   *** Strip Tags ***
	echo ======================
rem		Strip elements used to generate acro/abbr and tool/consumable tables
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_PROPAGATED_REV.xml" -sb "%RenderPath%\omnimark\strip_tags.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_STRIPPED_TAGS.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_strip_tags.err"

	echo ==========================================
	echo 8   *** Populating Required Attributes ***
	echo ==========================================
rem		 Generate attributes to authoring instance if needed
	REM %omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_STRIPPED_TAGS.xml" -sb "%RenderPath%\omnimark\hw_add_xml_attrs.xom" -d GsMainInput "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_STRIPPED_TAGS.xml" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_POP-ATTRS.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_hw_add_xml_attrs.err"

	echo ==============================
	echo 9   *** Creating UPPER.xml ***
	echo ==============================
rem		 Transforms attributes and element names to uppercase [NOT NEEDED FOR S1000D]
	REM %java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_POP-ATTRS.xml" "-xsl:%RenderPath%\shared\upperCase.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPPER%%~xa"
	REM %java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_STRIPPED_TAGS.xml" "-xsl:%RenderPath%\shared\upperCase.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_UPPER%%~xa"

	echo =====================================================
	echo 10   *** XML to FO First Pass to collect LEP Data ***
	echo =====================================================
	%java_command% -cp %cp%;S1000DHelper.jar net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_STRIPPED_TAGS.xml" "-xsl:%RenderPath%\S1000D_EM_XSL\S1000D_EM.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep.fo" %params% "LEP_PASS=1"

	REM Detect errors here to avoid the rest of the processing
	REM echo %errorlevel%
	REM if %errorlevel% neq 0 echo XSLT ERROR - EXITING DRIVER_S1000D.bat && exit /b %errorlevel%
	REM NOTE: errorlevel is always 0 from Java
	if NOT EXIST "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep.fo" echo XSLT ERROR DETECTED - EXITING DRIVER_S1000D.bat && exit

	echo =================================
	echo 10A   *** Strip fo:list-block ***
	echo =================================
rem		Remove elements used to render foldout and landscape tables
	%java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep.fo" "-xsl:%RenderPath%\S1000D_EM_XSL\strip_list-blocks.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep_stripped_list-block.fo"

	echo =====================================================
	echo 11   *** FO to XEP First Pass to collect LEP Data ***
	echo =====================================================
	%java_command% -cp %cp% com.renderx.xep.XSLDriver -DCONFIG=%xep_config% -fo "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep_stripped_list-block.fo" -xep "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep.xep"

	echo ===============================================================================
	echo 12   *** Extract LEP data to XML file from first pagination pass of RenderX ***
	echo ===============================================================================
	%java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep.xep" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract.xml" "-xsl:%RenderPath%\S1000D_EM_XSL\lepExtract_EM.xsl"
	
	echo ====================================================
	echo 13   *** Add Table Foldout Pages to LEP Extract ***
	echo ====================================================
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract.xml" -sb "%RenderPath%\omnimark\lep_foldout_pages.xom" -d GsFilename "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract_foldout-pages.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep_foldout_pages.err"

	echo ======================================
	echo 13A   *** Add Point Pages to LEP Extract ***
	echo ======================================
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract_foldout-pages.xml" -sb "%RenderPath%\omnimark\lep_point_pages.xom" -d GsFilename "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract_point-pages.xml" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lep_point_pages.err"
	
	echo ===============================================================================
	echo 13B   *** First Render of LEP Pages for page count ***
	echo ===============================================================================
	%java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract_point-pages.xml" "-xsl:%RenderPath%\S1000D_EM_XSL\renderLep_EM.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepRender.fo" "LEP_PASS=1"
	%java_command% -cp %cp% com.renderx.xep.XSLDriver -DCONFIG=%xep_config% -fo "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepRender.fo" -xep "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepRender.xep"
	
	echo ===============================================================================
	echo 13C   *** Second Render of LEP Pages for page count ***
	echo ===============================================================================
	%java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepExtract_point-pages.xml" "-xsl:%RenderPath%\S1000D_EM_XSL\renderLep_EM.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepRender_2.fo" "LEP_RENDER_FILE=file:///%WorkPath%/S1000D_EM_DRIVER/TEMP/%%~na_lepRender.xep"
	%java_command% -cp %cp% com.renderx.xep.XSLDriver -DCONFIG=%xep_config% -fo "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepRender_2.fo" -xep "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_lepRender_2.xep"

	echo ======================
	echo 14   *** XML to FO ***
	echo ======================

%java_command% -cp %cp%;S1000DHelper.jar net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_STRIPPED_TAGS.xml" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.fo.ORIG" "-xsl:%RenderPath%\S1000D_EM_XSL\S1000D_EM.xsl" %params% "LEP_EXTRACT_FILE=file:///%WorkPath%/S1000D_EM_DRIVER/TEMP/%%~na_lepExtract_point-pages.xml" "LEP_RENDER_FILE=file:///%WorkPath%/S1000D_EM_DRIVER/TEMP/%%~na_lepRender_2.xep"
%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.fo.ORIG" -sb "%RenderPath%\omnimark\char_font_fix.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.fo" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_char_font_fix_pass_2.err" -d s-images-folder "file:///%RenderPath%/images/"

	echo =================================
	echo 14A   *** Strip fo:list-block ***
	echo =================================
	%java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.fo" "-xsl:%RenderPath%\S1000D_EM_XSL\strip_list-blocks.xsl" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_stripped_list-block.fo"

	echo ======================
	echo 15   *** FO to XEP ***
	echo ======================
	%java_command% -cp %cp% com.renderx.xep.XSLDriver -DCONFIG=%xep_config% -fo "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_stripped_list-block.fo" -xep "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.xep"

	echo ==================================
	echo 16   *** XEP to Re-ordered XEP ***
	echo ==================================
	%java_command% -cp %cp% net.sf.saxon.Transform "-versionmsg:off" "-s:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.xep" "-o:%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2.xep" "-xsl:%RenderPath%\S1000D_EM_XSL\reorderPages_EM.xsl"

	echo ============================
	echo 17   *** Add Point Pages ***
	echo ============================
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2.xep" -sb "%RenderPath%\omnimark\point_pages.xom" -d GsFilename "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_point-pages.xep" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_point_pages.err"

	echo ====================================
	echo 18   *** Add Foldout Table Pages ***
	echo ====================================
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_point-pages.xep" -sb "%RenderPath%\omnimark\foldout_pages.xom" -d GsFilename "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_foldout-pages.xep" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_foldout_pages.err"

	echo ===============================
	echo 19   *** Updating TOC Pages ***
	echo ===============================
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_foldout-pages.xep" -sb "%RenderPath%\omnimark\update_toc.xom" -d GsFilename "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_updated-toc.xep" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_update_toc.err"

	echo =====================================
	echo 20   *** Oversize Image Detection ***
	echo =====================================
	%omnimark% "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_updated-toc.xep" -sb "%RenderPath%\omnimark\oversize-image-check.xom" -of "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na.junk" -d GsLogFileName "%WorkPath%\S1000D_EM_DRIVER\TEMP\oversize-image-check.log" -log "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_oversize_image_check.err"

	echo ==================================
	echo 21   *** Render XEP to PDF ***
	echo ==================================
	%java_command% -cp %cp% com.renderx.xep.XSLDriver -DCONFIG=%xep_config% -xep "%WorkPath%\S1000D_EM_DRIVER\TEMP\%%~na_2_updated-toc.xep" -pdf "%WorkPath%\S1000D_EM_DRIVER\PDF_OUTPUT\%%~na.pdf"


echo ==================
echo Date: %DATE%
echo Time: %TIME%
echo ==================

echo ==================
echo *** End Render ***
echo ==================

	rem *** Save document specific log files ***
	copy "%WorkPath%\S1000D_EM_DRIVER\TEMP\oversize-image-check.log" "%WorkPath%\S1000D_EM_DRIVER\PDF_OUTPUT\%%~na-oversize-image-check.log"
	copy "%WorkPath%\S1000D_EM_DRIVER\TEMP\run.log" "%WorkPath%\S1000D_EM_DRIVER\PDF_OUTPUT\%%~na-run.log"

)