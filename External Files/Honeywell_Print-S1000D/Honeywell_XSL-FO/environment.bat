rem *** Network Deployment ***

rem *** Honeywell XSL-FO common environment settings ***
rem *** (collecting the original fragmented deployment into consolidated structure,
rem ***  but trying to leave scripts, variable names, etc. as close to original state as possible)

rem *** Required HONEYWELL_PRINT_CLIENT environment variable 
rem *** is set when either:"C:\Honeywell_Print-client\Arbortext-HW_Print-client.bat" is launched
rem *** "C:\Honeywell_Print-client\Arbortext-HW_Print-client.bat"
rem *** - or -
rem *** "C:\Honeywell_Print-S1000D-client\Arbortext-HW_Print-client.bat"
rem *** is launched



rem *** Applications, scripts, stylesheets stored in common network location 
rem *** Processing takes place in local TEMP area

echo ============================
echo *** Environment Settings ***
echo ============================

rem set RenderPath=%cd%\..\..\Honeywell_XSL-FO
rem set WorkPath=%cd%\..\..\Honeywell_XSL-FO


rem *** RenderPath (shared network drive) ***
set RenderPath=%cd%\..\..\Honeywell_XSL-FO

rem *** WorkPath (local C: drive)
rem set WorkPath=%cd%\..\..\Honeywell_XSL-FO

rem *** Network + Client configuration where setting HONEYWELL_PRINT_CLIENT (e.g. "C:\Honeywell_Print-client") 
rem *** is specified in BAT which launches Arbortext
set WorkPath=%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO




rem *** Application files (shared network drive) ***
set xepPath=%cd%\..\..\Honeywell_XSL-FO\applications\XEP
set omnimarkPath=%cd%\..\..\Honeywell_XSL-FO\applications\Omnimark

REM set saxonPath=%cd%\..\..\Honeywell_XSL-FO\applications\Saxon\saxon9he.jar
REM *** Use Saxon from Arbortext ("home" edition doesn't support extensions required for S1000DHelper.jar)
set saxonPath=%cd%\..\..\Honeywell_XSL-FO\applications\Saxon\saxon.jar



echo ==============================
echo *** Paths          ***
echo RenderPath:	%RenderPath%
echo WorkPath:	%WorkPath%
echo xepPath:	%xepPath%
echo saxonPath:	%saxonPath%
echo omnimarkPath:	%omnimarkPath%
echo HONEYWELL_PRINT_CLIENT:	%HONEYWELL_PRINT_CLIENT%
echo ==============================




echo =====================
echo *** Java Settings ***
echo =====================

rem *** Use Arbortext Java
rem *** 32-bit ***
if exist "%ARBORTEXT_HOME%\bin\x86\editor.exe" set javaPath="%ARBORTEXT_HOME%\bin\x86\jre\bin\java.exe"

rem *** 64-bit ***
if exist "%ARBORTEXT_HOME%\bin\x64\editor.exe" set javaPath="%ARBORTEXT_HOME%\bin\x64\jre\bin\java.exe"

rem *** CV - must increase Java memory for large documents like LMM **
rem *** (javaPath already in quotes) ***
rem *** (Note: increased memory setting only works for 64-bit java)

rem set java_command=%javaPath% -Xmx4096m

if exist "%ARBORTEXT_HOME%\bin\x86\editor.exe" set java_command=%javaPath%
rem if exist "%ARBORTEXT_HOME%\bin\x64\editor.exe" set java_command=%javaPath% -Xmx4096m

rem *** (Note: some exceptionally large CMM exceed 100MB in generated FO size after EDI creation, so even larger memory setting required)  
if exist "%ARBORTEXT_HOME%\bin\x64\editor.exe" set java_command=%javaPath% -Xmx14144m

echo java_command:	%java_command%


echo ====================
echo *** XEP Settings ***
echo ====================
set cp="%xepPath%\lib\xep.jar;%saxonPath%;%xepPath%\lib\xt.jar"
set xep_config="%xepPath%\xep.xml"

echo cp:	%cp%
echo xep_config:	%xep_config%


echo =========================
echo *** Omnimark Settings ***
echo =========================
set omnimark="%omnimarkPath%\omnimark.exe"

echo omnimark:	%omnimark%

