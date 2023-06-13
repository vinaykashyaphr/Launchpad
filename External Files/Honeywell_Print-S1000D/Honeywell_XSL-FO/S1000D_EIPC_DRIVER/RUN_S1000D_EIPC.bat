@echo off

del "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\run.log"

echo Rendering S1000D EIPC XSL-FO...

call DRIVER_S1000D_EIPC.bat >> "%HONEYWELL_PRINT_CLIENT%\Honeywell_XSL-FO\S1000D_EIPC_DRIVER\TEMP\run.log" 2>&1

echo Finished

rem pause
