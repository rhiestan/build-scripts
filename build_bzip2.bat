: <<TRAMPOLINE
@ECHO OFF
REM
REM build_bzip2.bat
REM
REM Compile and install bzip2
REM
REM Version 1.0, 16.11.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_BZIP2_FILENAME% (
	ECHO File %SB_BZIP2_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_CMAKE_PATH%;%SB_NINJA_PATH%;%SB_MSYS2_PATH%;%SB_CCCL_PATH%

REM Convert paths into MSYS path
SET "SB_DOWNLOAD_PATH_FWD=%SB_DOWNLOAD_PATH:\=/%"
SET "SB_DOWNLOAD_PATH_FWD2=%SB_DOWNLOAD_PATH_FWD::=%"
SET SB_DOWNLOAD_PATH_MSYS=/%SB_DOWNLOAD_PATH_FWD2%
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_INSTALL_PATH_FWD2=%SB_INSTALL_PATH_FWD::=%"
SET SB_INSTALL_PATH_MSYS=/%SB_INSTALL_PATH_FWD2%
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD2=%SB_SOURCE_PATH_FWD::=%"
SET SB_SOURCE_PATH_MSYS=/%SB_SOURCE_PATH_FWD2%
SET "SB_CCCL_PATH_FWD=%SB_CCCL_PATH:\=/%"
SET "SB_CCCL_PATH_FWD2=%SB_CCCL_PATH_FWD::=%"
SET SB_CCCL_PATH_MSYS=/%SB_CCCL_PATH_FWD2%

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_BZIP2_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_BZIP2_FILENAME%

CD %SB_BZIP2_PATH%

ECHO Building...
nmake -f makefile.msc

ECHO Installing...
ROBOCOPY . %SB_INSTALL_PATH%\include bzlib.h /NP /NJH /NJS
ROBOCOPY . %SB_INSTALL_PATH%\lib libbz2.lib /NP /NJH /NJS
ROBOCOPY . %SB_INSTALL_PATH%\bin *.exe /NP /NJH /NJS

pause
EXIT /B 0








SET CC=cccl
SET CXX=cccl
SET LD=cccl

pause

SET MSYS2_PATH_TYPE=inherit

bash -c "exit 0" || (echo.No bash found in PATH! & exit /b 1)

GOTO start_bash

:error_exit
ECHO Error occurred, exiting
pause
EXIT /B 1

:start_bash
bash -l "%~f0" "%*"
pause
goto :EOF
TRAMPOLINE
#####################
#!/bin/bash

echo $PATH
export PATH=$PATH:$SB_CCCL_PATH_MSYS
cd $SB_SOURCE_PATH_MSYS/$SB_BZIP2_PATH
pwd
make
make install PREFIX=$SB_INSTALL_PATH_MSYS


