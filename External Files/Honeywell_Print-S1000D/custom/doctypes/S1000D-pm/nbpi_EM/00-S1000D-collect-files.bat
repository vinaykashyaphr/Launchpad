rem *** Collect the S1000D "DMC" fragment files referenced by "PMC" file into single consolidated document ***

rem *** NOTE: - configure ACL menus, etc. for use within Arbortext Editor
rem ***       - %ARBORTEXT_HOME% environment variable must be set

rem *** % 1 = $doc_name of current XML file (passed by ACL script)
rem *** % 2 = $type of current XML file (e.g. "mm", "em", etc. - passed by ACL script)
rem *** % 3 = $variant of print output ("std" = Standard Print, "dmc" = Print with Data Module Codes - passed by ACL script)

call environment.bat

REM pause


rem *** 1. Call the Java-based Google Code "xml-dir-listing" app residing in Arbortext "./custom/doctypes/pm/"
rem ***    to get the directory listing in XML format
rem ***    URL: http://code.google.com/p/xml-dir-listing/

rem call xml-dir-listing -o S1000D-dir.xml .
%XML_DIR_LISTING_CMD% -o S1000D-dir.xml .

%SAXON9_CMD% -t -o %1.xm0 %1 00-S1000D-pre-process.xsl type=%2 variant=%3

rem *** 2. Use XSLT to parse "PMC" file and use generated "S1000D-dir.xml" as lookup file
rem ***    NOTE: - must collect "pmEntry/dmRef/dmCode" attributes to assemble expected filename
rem ***            and find match in "S1000D-dir.xml" file
rem ***          - filenames also include version info which isn't included in the attributes
rem ***            so find closest match
rem ***            e.g. "DMC-S1000DBIKE-AAA-00-00-00-00AA-0A3A-D_000-05_sx-US.xml" would be found
rem ***                  using contains($filename,"DMC-S1000DBIKE-AAA-00-00-00-00AA-0A3A-D"


rem *** ISOEntities - set to local (full URL to S1000D site can cause XSLT and XQuery processing slow down during each document() call) ***
call %ANT_CMD% -f "01-S1000D-iso-entities-local.ant" -l 0000-iso-entities-local.log


rem %SAXON9_CMD% -t -o PMC-complete.xmx PMC-S1000DBIKE-U8025-12345-01_000-21_sx-US.XML 01-S1000D-consolidate.xsl
%SAXON9_CMD% -t -o %1.xmx %1.xm0 01-S1000D-consolidate.xsl


rem *** 3. Use XQuery to collect all repositories from multiple 
rem ***    XML in the zip into single lookup file

rem *** (a) Create XML collection file from "S1000D-dir.xml" directory listing
%SAXON9_CMD% -t -o S1000D-collection.xml S1000D-dir.xml 01-S1000D-collection.xsl


rem pause

rem *** (b) XQuery reads collection into memory, finds all repositories and saves 
rem         into single "S1000D-repositories.xml" file
%SAXON9_XQUERY_CMD% -t -o S1000D-repositories.xml 01-S1000D-xquery-collection.xqy 2>consolidate.log

rem *** ISOEntities - reset to full S1000D URL ***
call %ANT_CMD% -f "01-S1000D-iso-entities-reset.ant" -l 0000-iso-entities-reset.log


rem *** 4. Need separate XSLT pass to process the <graphic> references which were inside the copied DMC file fragments
rem ***    - also doing more things like:
rem ***      - unique ids and cross references
rem ***      - looking up values for new "pmEntry" descriptive attributes
rem ***      - creating "commonRepository" section at bottom of document containing all referenced 
rem ***        "caution|warning|parts|supplies|etc."

rem %SAXON9_CMD% -t -o PMC-complete.xmy PMC-complete.xmx 02-S1000D-references.xsl
%SAXON9_CMD% -t -o %1.xmy %1.xmx 02-S1000D-references.xsl

rem *** 5. More XSLT passes to collect "pmEntry/dmContent/dmodule/content/procedure/preliminaryRequirements" to
rem ***    first "pmEntry/dmContent/dmodule" and filter out duplicate entries
rem ***    (NOTE: would have preferred single "03-S1000D-filter.xsl", but filtering out the
rem ***           duplicates will be much easier from an already sorted state, than trying
rem ***           to do it as the nodes are collected)

rem %SAXON9_CMD% -t -o PMC-complete.xmz PMC-complete.xmy 03-S1000D-filter-A.xsl
rem %SAXON9_CMD% -t -o PMC-complete.xma PMC-complete.xmz 03-S1000D-filter-B.xsl
rem %SAXON9_CMD% -t -o PMC-complete.xmb PMC-complete.xma 03-S1000D-filter-C.xsl
rem %SAXON9_CMD% -t -o PMC-complete.xml PMC-complete.xmb 03-S1000D-filter-D.xsl

rem *** RS: Removed consolidation of tables at the beginning of sections, so just
rem *** one filter script is necessary for now:
REM %SAXON9_CMD% -t -o %1-TEMP %1.xmy 03-S1000D-filter-A.xsl

rem *** CV - construct a better TEMP file for DOS copy of final PDF file ***
%SAXON9_CMD% -t -o %1.CONSOLIDATED.xml %1.xmy 03-S1000D-filter-A.xsl


rem %SAXON9_CMD% -t -o %1.xma %1.xmz 03-S1000D-filter-B.xsl
rem %SAXON9_CMD% -t -o %1.xmb %1.xma 03-S1000D-filter-C.xsl
rem %SAXON9_CMD% -t -o %1-TEMP %1.xmb 03-S1000D-filter-D.xsl


