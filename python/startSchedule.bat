@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
for /L %%i in (1,1,10) do (
	echo times: %%i start
	set var=%%i
	echo ------ !var!
	echo ###### %var%
	start cmd /c ScheduleJob.bat
	timeout /T 60 /NOBREAK
	echo times: %%i end
)
pause>nul