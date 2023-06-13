ECHO OFF
CALL start cmd /k "Redis Server.lnk"
CALL start cmd /k flask_run.bat
CALL start cmd /k flask_run_beat.bat
CALL start cmd /k flask_run_worker1.bat
CALL start cmd /k flask_run_worker2.bat

