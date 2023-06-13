rem *** Collect the S1000D "DMC" fragment files referenced by "PMC" file into single consolidated document ***

rem *** This BAT copies required XSLT, XQuery and BAT scripts from $doc_type_dir to $doc_dir

rem *** % 1 = full path to $doc_type_dir (passed by ACL script - already in quotes)
rem *** % 2 = full path to $doc_dir (passed by ACL script - already in quotes)


rem *** CONFIG Files ***
copy %1\nbpi_EM\environment.bat %2
copy %1\nbpi_EM\S1000D-captions.xml %2
copy %1\nbpi_EM\S1000D-common-repository.xml %2

rem *** Processing Scripts ***
copy %1\nbpi_EM\0*.bat %2
copy %1\nbpi_EM\0*.xsl %2
copy %1\nbpi_EM\0*.xqy %2

rem *** "xml-dir-listing" JAR files (easier to set CLASSPATH if relative to other scripts) ***
copy %1\nbpi_EM\xml-dir-listing\lib\*.jar %2
copy %1\S1000DHelper.jar %2

rem *** ISOEntities and Ant replacement scripts ***
REM copy %1\nbpi_EM\entities\* %2
REM copy %1\nbpi_EM\0*.ant %2

copy %1\nbpi_EM\..\*.ent %2
copy %1\nbpi_EM\0*.ant %2


