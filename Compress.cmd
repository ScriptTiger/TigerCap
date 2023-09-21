@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/TigerCap
rem =====

setlocal ENABLEDELAYEDEXPANSION
if not exist "sessions" (
	echo No sessions exist yet
	pause
	exit /b
)
for /f "tokens=*" %%0 in (
	'dir /b "sessions" ^| findstr /e ".wav"'
) do (
	set filename=%%0
	set filename=!filename:.wav=!
	if not exist "sessions\!filename!.flac" (
		echo Compressing "%%0"...
		call bin\ffmpeg -hide_banner -i "sessions\%%0" -compression_level 12 "sessions\!filename!.flac" 2> nul
	)
)
echo All sessions have been compressed
pause