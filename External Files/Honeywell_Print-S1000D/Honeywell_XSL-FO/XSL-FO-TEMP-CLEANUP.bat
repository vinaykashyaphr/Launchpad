cls

@echo off

rem *** Cleanup XSL-FO TEMP folders (in particular PDF_OUTPUT) ***

rem *** Note: - this action can be executed from either a "desktop" or "network + client" configuration of "Honeywell_Print"
rem           - keeping simple and just using hardcoded paths to all potential default local paths


REM rem *** (a) Optional "DESKTOP" configuration (used during development) 
REM 
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\CMM_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\CMM_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\CMM_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\EIPC_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\EIPC_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\EIPC_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\EM_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\EM_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\EM_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\SB_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\SB_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\SB_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-DESKTOP\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\*

rem *** (b) Default "DESKTOP" configuration

REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\*

rem *** (c) Default "NETWORK + CLIENT" configuration

REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\CMM_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\CMM_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\CMM_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\EIPC_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\EIPC_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\EIPC_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\EM_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\EM_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\EM_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\SB_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\SB_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\SB_DRIVER\PDF_OUTPUT\*
REM 
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\*
REM del /f/s/q C:\Honeywell_Print-client\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\*

rem *** (d) S1000D "DESKTOP" configuration

del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\*
del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\*
del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\*

del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\*
del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\*
del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\*

del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\*
del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\*
del /f/s/q C:\Honeywell_Print-S1000D\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\*

rem *** (e) S1000D "NETWORK + CLIENT" configuration

del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\*
del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\*
del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\*

del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\*
del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\*
del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\*

del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\*
del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\*
del /f/s/q C:\Honeywell_Print-S1000D-client\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\*

rem *** (f) S1000D "NETWORK + SERVER TEMP" configuration V Drive

del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\* 2>nul
del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\* 2>nul 2>nul
del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\* 2>nul

del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\* 2>nul
del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\* 2>nul
del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\* 2>nul

del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\* 2>nul
del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\* 2>nul
del /f/s/q V:\500\00-Printing-Tools\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\* 2>nul

REM rem *** (g) S1000D "NETWORK + SERVER TEMP" configuration P Drive

REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\* 2>nul
REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\* 2>nul

REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\* 2>nul
REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\* 2>nul

REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\* 2>nul
REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q P:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\* 2>nul

REM rem *** (h) S1000D "NETWORK + SERVER TEMP" configuration N Drive

REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\* 2>nul
REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\* 2>nul

REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\* 2>nul
REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\* 2>nul

REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\* 2>nul
REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q N:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\* 2>nul

REM rem *** (i) S1000D "NETWORK + SERVER TEMP" configuration I Drive

REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\* 2>nul
REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\* 2>nul

REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\* 2>nul
REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\* 2>nul

REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\* 2>nul
REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\* 2>nul
REM del /f/s/q I:\Print_Tools\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\* 2>nul

rem *** (j) S1000D "NETWORK + SERVER TEMP" configuration For testing

del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\TEMP\* 2>nul
del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\XML_INPUT\* 2>nul
del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_DRIVER\PDF_OUTPUT\* 2>nul

del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\* 2>nul
del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\XML_INPUT\* 2>nul
del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\PDF_OUTPUT\* 2>nul

del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\* 2>nul
del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\XML_INPUT\* 2>nul
del /f/s/q V:\500\01-Test-Printing\Honeywell_Print-S1000D\HW-TEMP-PRINT-S1000D\%USERNAME%\Honeywell_XSL-FO\S1000D_EM_DRIVER\PDF_OUTPUT\* 2>nul

cls

echo "*** XSL-FO TEMP files have been deleted ***"

pause