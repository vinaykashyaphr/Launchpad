rem *** CVS "Honeywell_Print" is now network version ***

rem *** This BAT creates "DESKTOP" version by restoring legacy "*.bat.DESKTOP" to full version ***


rem *** 1. Delete previous "DESKTOP" output folder (if any) ***
rd /s /q DESKTOP

rem *** 2. Copy "Honeywell_Print" (network) to DESKTOP ***
mkdir DESKTOP
mkdir DESKTOP\Honeywell_Print

xcopy /s /e Honeywell_Print DESKTOP\Honeywell_Print


rem *** 3. Convert from "network" to "desktop" configuration ***

rem *** a) Remove unneeded network files  
rd /s /q DESKTOP\Honeywell_Print\client
del DESKTOP\Honeywell_Print\README-network-deployment.txt


rem *** b) Restore Arbortext launch BAT (desktop version)
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\Arbortext-HW_Print.bat.DESKTOP" "DESKTOP\Honeywell_Print\Arbortext-HW_Print.bat"


rem *** c) Reset the doctype "ACL-run-XSL-FO.bat" files (desktop versions)
ren "DESKTOP\Honeywell_Print\custom\doctypes\cmm\ACL-run-XSL-FO.bat" ACL-run-XSL-FO.bat.NETWORK
copy "DESKTOP\Honeywell_Print\custom\doctypes\cmm\ACL-run-XSL-FO.bat.DESKTOP" "DESKTOP\Honeywell_Print\custom\doctypes\cmm\ACL-run-XSL-FO.bat"

ren "DESKTOP\Honeywell_Print\custom\doctypes\cmm-edit-xml\ACL-run-XSL-FO.bat" ACL-run-XSL-FO.bat.NETWORK
copy "DESKTOP\Honeywell_Print\custom\doctypes\cmm-edit-xml\ACL-run-XSL-FO.bat.DESKTOP" "DESKTOP\Honeywell_Print\custom\doctypes\cmm-edit-xml\ACL-run-XSL-FO.bat"

ren "DESKTOP\Honeywell_Print\custom\doctypes\eipc\ACL-run-XSL-FO.bat" ACL-run-XSL-FO.bat.NETWORK
copy "DESKTOP\Honeywell_Print\custom\doctypes\eipc\ACL-run-XSL-FO.bat.DESKTOP" "DESKTOP\Honeywell_Print\custom\doctypes\eipc\ACL-run-XSL-FO.bat"

ren "DESKTOP\Honeywell_Print\custom\doctypes\em\ACL-run-XSL-FO.bat" ACL-run-XSL-FO.bat.NETWORK
copy "DESKTOP\Honeywell_Print\custom\doctypes\em\ACL-run-XSL-FO.bat.DESKTOP" "DESKTOP\Honeywell_Print\custom\doctypes\em\ACL-run-XSL-FO.bat"

ren "DESKTOP\Honeywell_Print\custom\doctypes\sb\ACL-run-XSL-FO.bat" ACL-run-XSL-FO.bat.NETWORK
copy "DESKTOP\Honeywell_Print\custom\doctypes\sb\ACL-run-XSL-FO.bat.DESKTOP" "DESKTOP\Honeywell_Print\custom\doctypes\sb\ACL-run-XSL-FO.bat"


rem *** c) Restore the XSL-FO BAT files (desktop versions)

ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\environment.bat" environment.bat.NETWORK
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\environment.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\environment.bat"

ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\DRIVER_CMM.bat" DRIVER_CMM.bat.NETWORK
ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\RUN_CMM.bat" RUN_CMM.bat.NETWORK
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\CMM_DRIVER\DRIVER_CMM.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\DRIVER_CMM.bat"
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\CMM_DRIVER\RUN_CMM.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\CMM_DRIVER\RUN_CMM.bat"

ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\DRIVER_EIPC.bat" DRIVER_EIPC.bat.NETWORK
ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\RUN_EIPC.bat" RUN_EIPC.bat.NETWORK
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\EIPC_DRIVER\DRIVER_EIPC.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\DRIVER_EIPC.bat"
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\EIPC_DRIVER\RUN_EIPC.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EIPC_DRIVER\RUN_EIPC.bat"

ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\DRIVER_EM.bat" DRIVER_EM.bat.NETWORK
ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\RUN_EM.bat" RUN_EM.bat.NETWORK
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\EM_DRIVER\DRIVER_EM.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\DRIVER_EM.bat"
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\EM_DRIVER\RUN_EM.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\EM_DRIVER\RUN_EM.bat"

ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\DRIVER_SB.bat" DRIVER_SB.bat.NETWORK
ren "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\RUN_SB.bat" RUN_SB.bat.NETWORK
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\SB_DRIVER\DRIVER_SB.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\DRIVER_SB.bat"
copy "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\temp-DESKTOP\SB_DRIVER\RUN_SB.bat.DESKTOP" "DESKTOP\Honeywell_Print\Honeywell_XSL-FO\SB_DRIVER\RUN_SB.bat"


rem *** d) Modify "menu.acl" with Cygwin GNU "sed" command to display "Desktop" instead of "Network" in version info

ren "DESKTOP\Honeywell_Print\custom\init\menu.acl" menu.acl.NETWORK

sed "s/Honeywell - Print Environment - Network/Honeywell - Print Environment - Desktop/" "DESKTOP\Honeywell_Print\custom\init\menu.acl.NETWORK" > "DESKTOP\Honeywell_Print\custom\init\menu.acl"

pause





