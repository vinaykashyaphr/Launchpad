rem *** ARBORTEX_HOME (Arbortext Editor location) ***

rem set ARBORTEXT_HOME=C:\Program Files\PTC\Arbortext Editor 6.0
set ARBORTEXT_HOME=C:\Program Files\PTC\Arbortext Editor


rem *** APTCUSTOM (Honeywell Arbortext custom application location) ***

rem *** Should reside in network location (shared drive letter mapping common to all users)
set APTCUSTOM=V:\500\00-Printing-Tools\Honeywell_Print-S1000D\custom


rem *** HONEYWELL_PRINT_CLIENT (client location) ***
rem *** - location where this BAT resides and all TEMP processing files will be written
rem *** - environment variable HONEYWELL_PRINT_CLIENT will be passed to scripts in network APTCUSTOM location

set HONEYWELL_PRINT_CLIENT=C:\Honeywell_Print-S1000D-client




rem *** Unzip XEP "fonts" (first launch of updated package)
if not exist "%APTCUSTOM%\..\Honeywell_XSL-FO\applications\XEP\fonts\fonts.zip" goto LaunchArbortext
"%APTCUSTOM%\..\Honeywell_XSL-FO\applications\FBZip.exe" -e -p "%APTCUSTOM%\..\Honeywell_XSL-FO\applications\XEP\fonts\fonts.zip" "%APTCUSTOM%\..\Honeywell_XSL-FO\applications\XEP\fonts"
del "%APTCUSTOM%\..\Honeywell_XSL-FO\applications\XEP\fonts\fonts.zip"


:LaunchArbortext

rem *** 32-bit ***
if exist "%ARBORTEXT_HOME%\bin\x86\editor.exe" set ARBORTEXT_CMD="%ARBORTEXT_HOME%\bin\x86\editor.exe"

rem *** 64-bit ***
if exist "%ARBORTEXT_HOME%\bin\x64\editor.exe" set ARBORTEXT_CMD="%ARBORTEXT_HOME%\bin\x64\editor.exe"

rem *** Launch Arbortext Editor ***
rem %ARBORTEXT_CMD% -editor

rem *** Launch Arbortext Styler ***
rem %ARBORTEXT_CMD% -styler

rem *** Launch Arbortext (default state) ***
%ARBORTEXT_CMD%
