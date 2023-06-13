@echo OFF

rem *** Network + Client configuration where setting HONEYWELL_PRINT_CLIENT (e.g. "C:\Honeywell_Print-client") 
rem *** is specified in BAT on client system which launches Arbortext


rem *** S1000D XSL-FO processing ***

rem *** Parameters passed by ACL ***
rem *** % 1 = full path to ".\...\filename.xml.CONSOLIDATED.xml" (current source document - XML or SGML)
rem *** % 2 = full path to ".\...\graphics\*.*" (graphics folder for current document)
rem *** % 3 = final PDF filename "filename.pdf"
rem *** % 4 = full path to source document directory
rem *** % 5 = full path to final PDF copied to source document directory (NETWORK BAT use only)
rem *** % 6 = renamed S1000D PDF to strip out "CONSOLIDATED" filename concatenation (S1000D BAT use only)
rem *** % 7 = full path to renamed S1000D PDF (NETWORK S1000D BAT use only)


rem *** 0. Delete previous "XML_INPUT" (if any)
del /q/s/f %HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\*.*

mkdir %HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\
mkdir %HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\graphics
mkdir %HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\TEMP
mkdir %HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT




rem *** 1. Copy current Arbortext document (XML or SGML) to appropriate Honeywell XSL-FO "XML_INPUT" folder
copy %1 "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT"
copy %2 "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\graphics"

rem *** Delete "filename.xml.CONSOLIDATED.xml" after copy steps complete ***
del %1

rem *** 2. RUN XSL-FO process: "..\..\Honeywell_XSL-FO\S1000D_DRIVER\RUN_S1000D.bat"

rem *** Note: main XSL-FO BAT resides in relative path location on network drive ***
cd "..\..\..\Honeywell_XSL-FO\S1000D_DRIVER"
cls
call RUN_S1000D.bat

rem *** 3. Copy final PDF to original document directory (similar to Arbortext output)
rem *** Rename final PDF (stripping out "CONSOLIDATED" filename concatenation
copy "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\%3" "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\%6"
copy "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\%6" %4

rem *** Delete "*.xml.CONSOLIDATED.pdf"
del "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\%3"


rem *** 4. Show full path to final PDF and launch it
rem ***    NOTE: - DOS window won't close until PDF reader closed
rem              - using ampersand at end of "sh" command from ACL separates the Arborext lock, 
rem                so no longer an issue

echo %7
%7

rem pause