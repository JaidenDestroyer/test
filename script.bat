@rem TEMP CODE
@echo off

set "REMOTEFILE=https://raw.githubusercontent.com/JaidenDestroyer/test/master/start_server.bat"
set "LOCALFILE=%cd%temp.bat"

call :downloadUpdateManifest %REMOTEFILE% %LOCALFILE%
exit /b 0

:downloadUpdateManifest
	setlocal
	for /f %%G in ('bitsadmin /rawreturn /create "UpdateManifestDownload"') do set "guid=%%G"
	bitsadmin /rawreturn /addfile %guid% "%~1" "%~2" > nul
	bitsadmin /rawreturn /setnotifycmdline %guid% "cmd.exe" "/c waitfor /si UpdateManifestDownloadComplete" > nul
	bitsadmin /rawreturn /resume %guid% > nul & waitfor /t 10 "UpdateManifestDownloadComplete" > nul
	for /f %%G in ('bitsadmin /rawreturn /getstate %guid%') do if "%%G"=="TRANSFERRED" echo File transferred to %~2
	bitsadmin /rawreturn /complete %guid% > nul
	endlocal
exit /b
