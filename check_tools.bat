@ECHO OFF
REM
REM check_tools.bat
REM
REM Check whether all tools are available.
REM
REM Version 1.0, 03.01.2017

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat

SET /A "SB_TOOLS_FOUND=0"
SET /A "SB_TOOLS_NOT_FOUND=0"

CALL :CHECK_PROGRAM CMake.exe "%SB_CMAKE_PATH%" "--version"
CALL :CHECK_PROGRAM Ninja.exe "%SB_NINJA_PATH%" "--version"
CALL :CHECK_PROGRAM jom.exe "%SB_JOM_PATH%" "/?"
CALL :CHECK_PROGRAM tar.exe "%SB_MSYS2_PATH%" "--version"
CALL :CHECK_PROGRAM gcc.exe "%SB_MINGW64_PATH%" "--version"
CALL :CHECK_PROGRAM 7z.exe "%SB_7ZIP_PATH%" "-h"
CALL :CHECK_PROGRAM nasm.exe "%SB_NASM_PATH%" "-h"
CALL :CHECK_PROGRAM perl.exe "%SB_PERL_PATH%" "--version"

IF NOT EXIST %SB_VSTUDIO_PATH%\vcvarsall.bat (
	ECHO vcvarsall.bat not found, please adjust path to Visual Studio
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

CALL :CHECK_PROGRAM CL.exe "" "--version"

ECHO Found %SB_TOOLS_FOUND% tools, %SB_TOOLS_NOT_FOUND% not found

pause

EXIT /B



:CHECK_PROGRAM
SET OLDPATH=%PATH%
SET PATH=%PATH%;%2
%1 %3 > NUL: 2>&1
IF ERRORLEVEL 9009 (
	ECHO %1 not found
	SET /A "SB_TOOLS_NOT_FOUND+=1"
) ELSE (
	ECHO %1 found
	SET /A "SB_TOOLS_FOUND+=1"
)
SET PATH=%OLDPATH%
EXIT /B
