@echo off

del "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\run.log"

echo Rendering S1000D EM XSL-FO...

call DRIVER_S1000D_EM.bat >> "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_EM_DRIVER\TEMP\run.log" 2>&1

echo Finished

rem pause
