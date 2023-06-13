@echo off
rem   This batch file encapsulates a standard XEP call. 

set CP=C:\XEP\lib\xep.jar;C:\XEP\lib\saxon.jar;C:\XEP\lib\xt.jar

if x%OS%==xWindows_NT goto WINNT
"C:\Program Files\Java\jre6\bin\java" -classpath "%CP%" com.renderx.xep.XSLDriver "-DCONFIG=C:\XEP\xep.xml" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto END

:WINNT
"C:\Program Files\Java\jre6\bin\java" -classpath "%CP%" com.renderx.xep.XSLDriver "-DCONFIG=C:\XEP\xep.xml" %*

:END


set CP=
