@echo off

rem =====
rem For more information on ScriptTiger and more ScriptTiger scripts visit the following URL:
rem https://scripttiger.github.io/
rem Or visit the following URL for the latest information on this ScriptTiger script:
rem https://github.com/ScriptTiger/TigerCap
rem =====

setlocal ENABLEDELAYEDEXPANSION

:init
echo Initializing...
set devtxt=dev\all.txt
set preftxt=dev\pref.txt
set devnum=0

:filename
echo If session name left blank, time-date stamp will be used
set /p filename=Session name: 
if not "%filename%"=="" (
	if exist "sessions\%filename%.wav" (
		echo A session by that name already exists
		choice /m "Would you like to overwrite it?"
		if !errorlevel!==1 (
			del "sessions\%filename%.wav"
			if exist "sessions\%filename%.flac" del "sessions\%filename%.flac"
		) else goto filename
	)
	goto pref
)
set filename=%date%-%time%
for %%0 in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z " ") do (
	set filename=!filename:%%~0=!
)
for %%0 in (/ : .) do (
	set filename=!filename:%%0=-!
)

:pref
if exist "%preftxt%" (
	set /p pref=<"%preftxt%"
	for /f "tokens=*" %%0 in ('more +1 "%preftxt%"') do set opt=%%0
	goto cap
)

:detect
echo Detecting devices...
if exist "dev\*.txt" del dev\*.txt
if not exist "dev" md "dev"
call bin\ffmpeg -hide_banner -list_devices true -f dshow -i "" 2> "%devtxt%"
for /f tokens^=^2^ delims^=^" %%0 in (
	'findstr /v "Alternative name" "%devtxt%" ^| findstr /e audio.$ '
) do (
	call bin\ffmpeg -hide_banner -f dshow -i audio="%%0" 2>"dev\!devnum!.txt"
	set /a devnum=!devnum!+1
)
echo Please select the input device you would like to use

:pref
for /f tokens^=^2^ delims^=^" %%0 in (
	'findstr /v "Alternative name" "%devtxt%" ^| findstr /e audio.$ '
) do (
	choice /m "%%0"
	if !errorlevel!==1 (
		echo %%0>"%preftxt%"
		set pref=%%0
		goto mode
	)
)
if "%pref%"=="" goto pref

:mode
echo Please select capture mode
echo 1.] Raw stream copy
echo 2.] Force single channel
choice /c 12 /n

if %errorlevel%==1 (set opt=-c:a copy
) else set opt=-ac 1
echo !opt!>>"%preftxt%"

:cap
if not exist "sessions" md "sessions"
echo Capturing from "%pref%"...
call bin\ffmpeg -hide_banner -f dshow -i audio="%pref%" %opt% "sessions\%filename%.wav" 2> nul
pause