@echo off
rem   This batch file encapsulates a standard XEP call. 

set CP=C:\XEP_personal\lib\xep.jar;C:\XEP_personal\lib\saxon.jar;C:\XEP_personal\lib\xt.jar

if x%OS%==xWindows_NT goto WINNT
"C:\Program Files\Java\jre6\bin\java" -classpath "%CP%" "-Dcom.renderx.xep.CONFIG=C:\XEP_personal\xep.xml" com.renderx.xep.Validator %1 %2 %3 %4 %5 %6 %7 %8 %9
goto END

:WINNT
"C:\Program Files\Java\jre6\bin\java" -classpath "%CP%" "-Dcom.renderx.xep.CONFIG=C:\XEP_personal\xep.xml" com.renderx.xep.Validator %*

:END

set CP=
