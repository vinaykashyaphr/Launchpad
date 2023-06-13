rem % 1: Job Folder
rem % 2: Doctype

set HONEYWELL_PRINT_CLIENT=%1

cd /D %APTCUSTOM%\Honeywell_XSL-FO\S1000D%2_DRIVER

RUN_S1000D%2.bat
exit