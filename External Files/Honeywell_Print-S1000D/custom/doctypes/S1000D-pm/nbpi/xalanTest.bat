@echo OFF

rem *** "Sonovision S1000D" Environment Variables ***


rem =================================================================
rem *** 1. Paths to home directories ***

rem *** (MODIFY AS NEEDED) ***

rem *** NOTE: ARBORTEXT_HOME should set as environment variable
rem ***       (location where Arbortext Editor 6.0 installed to)
set ARBORTEXT_HOME=C:\Program Files (x86)\PTC\Arbortext Editor




rem =================================================================
rem *** 2. Determine 32/64-bit version ***

rem *** (DO NOT TOUCH) ***

REM *** CV - would prefer conditional code to automatically determine if 32/64 bit
rem set JAVA_HOME=%ARBORTEXT_HOME%\bin\x64\jre
rem set JAVA_HOME=%ARBORTEXT_HOME%\bin\x86\jre

rem *** 32-bit ***
if exist "%ARBORTEXT_HOME%\bin\jre\bin\java.exe" set JAVA_HOME=%ARBORTEXT_HOME%\bin\jre
if exist "%ARBORTEXT_HOME%\bin\x86\jre\bin\java.exe" set JAVA_HOME=%ARBORTEXT_HOME%\bin\x86\jre

rem *** 64-bit ***
if exist "%ARBORTEXT_HOME%\bin\x64\jre\bin\java.exe" set JAVA_HOME=%ARBORTEXT_HOME%\bin\x64\jre


rem =================================================================
rem *** 3. Set commands for main applications ***

rem *** (DO NOT TOUCH) ***

set JAVA_CMD=%JAVA_HOME%\bin\java.exe
set XML_DIR_LISTING_HOME=.

set XALAN_HOME=h:\Projects\NEXTER\sonovision-helper.jar;h:\Projects\NEXTER\xalan.jar;h:\Projects\NEXTER\xercesImpl.jar;h:\Projects\NEXTER\xml-apis.jar;h:\Projects\NEXTER\serializer.jar
set XALAN_CMD="%JAVA_CMD%" -Xms200M -Xmx200M -cp "%XALAN_HOME%" org.apache.xalan.xslt.Process

set SAXON9_HOME=%ARBORTEXT_HOME%\lib\classes\saxon.jar
set SAXON9_CMD="%JAVA_CMD%" -Xms200M -Xmx200M -cp "%SAXON9_HOME%" net.sf.saxon.Transform

set SAXON9_XQUERY_CMD="%JAVA_HOME%"\bin\java -Xms200M -Xmx200M -cp "%SAXON9_HOME%" net.sf.saxon.Query

set ANT_HOME=%ARBORTEXT_HOME%
set ANT_OPTS=-Xms128M -Xmx512M
set ANT_CMD="%JAVA_CMD%" %ANT_OPTS% -classpath "%ANT_HOME%\lib\classes\ant-launcher.jar" "-Dant.home=%ANT_HOME%" org.apache.tools.ant.launch.Launcher

rem *** From Google Code: "xml-dir-listing" ***
rem *** (% 1 - $doc_type_dir passed by ACL script)
rem *** NOTE: - too many problems trying to create CLASSPATH when coming from location with spaces 
rem ***         (e.g. "C:\Program Files\Arbotext\custom\...")
rem ***       - just copying the JARs to zip directory and using a relative path 
rem ***         (with "environment.bat" which has also been copied to zip directory)

rem set XML_DIR_LISTING_HOME=%1\xml-dir-listing
rem set XML_DIR_LISTING_CLASSPATH=%XML_DIR_LISTING_HOME%\lib\xercesImpl.jar;%XML_DIR_LISTING_HOME%\lib\xml-dir-listing.0.2.jar;%XML_DIR_LISTING_HOME%\lib\commons-cli-1.1.jar;%XML_DIR_LISTING_HOME%\lib\jakarta-regexp-1.5.jar;%XML_DIR_LISTING_HOME%\lib\log4j-1.2.14.jar
rem set XML_DIR_LISTING_CMD="%JAVA_CMD%" -classpath "%XML_DIR_LISTING_CLASSPATH%" net.matthaynes.xml.dirlist.DirectoryListing


set XML_DIR_LISTING_CLASSPATH=%XML_DIR_LISTING_HOME%\xercesImpl.jar;%XML_DIR_LISTING_HOME%\xml-dir-listing.0.2.jar;%XML_DIR_LISTING_HOME%\commons-cli-1.1.jar;%XML_DIR_LISTING_HOME%\jakarta-regexp-1.5.jar;%XML_DIR_LISTING_HOME%\log4j-1.2.14.jar
set XML_DIR_LISTING_CMD="%JAVA_CMD%" -classpath "%XML_DIR_LISTING_CLASSPATH%" net.matthaynes.xml.dirlist.DirectoryListing


rem =================================================================
rem *** 4. Display the settings ***
rem @echo ON
echo ANT_HOME = %ANT_HOME%
echo JAVA_HOME = %JAVA_HOME%
echo SAXON_HOME = %SAXON_HOME%
echo SAXON9_HOME = %SAXON9_HOME%
echo XML_DIR_LISTING_HOME = %XML_DIR_LISTING_HOME%

%XALAN_CMD% -in "h:\Projects\NEXTER\DMC-HON97896-A-34-41-71-01A-941A-C_001-00_sx-US.xml" -xsl "h:\Projects\NEXTER\02-S1000D-references.xsl" -out "h:\Projects\NEXTER\exportTest.xml"

pause