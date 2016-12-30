@ECHO OFF
REM
REM fast_rmdir.bat
REM
REM Recursively delete a directory, fast and safe
REM
REM Version 1.0, 16.11.2016

REM Check for parameter
IF [%1]==[] (
	ECHO fast_rmdir: Parameter is missing
	EXIT /B 1
)

REM Check whether directory exists
IF NOT EXIST %1 EXIT /B

REM Fast recursively delete all files, then all folders
DEL /f/s/q %1 > NUL
RMDIR /s/q %1

REM Check whether folder was deleted
IF EXIST %1 (
	REM Wait for a second
	ping -n 2 127.0.0.1 >nul
	IF EXIST %1 (
		RMDIR /s/q %1
		IF EXIST %1 (
			ECHO Deleting folder %1 failed
			EXIT /B 1
		)
	)
)

EXIT /B 0
