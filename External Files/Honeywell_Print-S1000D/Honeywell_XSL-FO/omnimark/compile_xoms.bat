@echo off

for %%a in ("*.xom") do (

	echo Processing %%~na%%~xa...
	
	omnic.exe "%%~na%%~xa" -save "%%~na.xvc" -brief

)

pause