rem *** Collect the S1000D "DMC" fragment files referenced by "PMC" file into single consolidated document ***

rem *** This BAT removes temp files and the copied XSLT, XQuery and BAT scripts from $doc_dir

rem *** % 1 = full path to $doc_dir (passed by ACL script - already in quotes)

rem *** Delete CONFIG files ***
del %1\environment.bat
del %1\S1000D-captions.xml
del %1\S1000D-common-repository.xml

rem *** Delete Processing Scripts ***
del %1\0*.bat
del %1\0*.xsl
del %1\0*.xqy

rem *** Delete "xml-dir-listing" JARs ***
del %1\*.jar

rem *** Delete generated TEMP files ***
del %1\*.xm0
del %1\*.xmx
del %1\*.xmy
del %1\*.xmz
del %1\*.xma
del %1\*.xmb
del %1\S1000D-dir.xml
del %1\S1000D-replace-internalRefId.xml

rem *** Sonovision request to keep "consolidate.log" after cleanup ***
rem del %1\*.log

del %1\S1000D-collection.xml
del %1\S1000D-repositories.xml

rem *** Delete ISOEntities and Ant scripts ***
rem *** Note: sometimes Sonovision copies their own entity files into XML folder (e.g. "inmedISOEntities.ent"),
rem           so only delete "iso*.ent"
del %1\iso*.ent
del %1\*.ant

rem *** Delete 0000-iso-entities-local.log and 0000-iso-entities-reset.log
del %1\0000-iso-entities*.log

rem *** Delete the consolidated XML file
REM *** (Note: must perform this delete from "ACL-run-XSL-FO.bat" to avoid potential file copy conflict on slow systems)
REM del %1\*.xml.CONSOLIDATED.xml

rem *** Delete the main "*.xml-TEMP" file used to generate PDF ***
del %1\*.xml-TEMP


REM pause
