@ECHO OFF
REM
REM build_xz.bat
REM
REM Compile and install xz utils
REM
REM Version 1.0, 16.11.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_XZ_UTILS_FILENAME% (
	ECHO File %SB_XZ_UTILS_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
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
SET SB_DOWNLOAD_PATH_MSYS=/%SB_DOWNLOAD_PATH_FWD2%"
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_INSTALL_PATH_FWD2=%SB_INSTALL_PATH_FWD::=%"
SET SB_INSTALL_PATH_MSYS=/%SB_INSTALL_PATH_FWD2%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD2=%SB_SOURCE_PATH_FWD::=%"
SET SB_SOURCE_PATH_MSYS=/%SB_SOURCE_PATH_FWD2%"

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_XZ_UTILS_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_XZ_UTILS_FILENAME%

CD %SB_XZ_UTILS_PATH%
REM SET CC=cccl
REM SET CXX=cccl
REM SET LD=cccl
REM bash ./configure

ECHO Building...
MSBuild.exe windows\liblzma.vcxproj /p:Configuration=Release /p:Platform=x64

ECHO Installing...
ROBOCOPY src\liblzma\api %SB_INSTALL_PATH%\include lzma.h /NP /NJH /NJS 
ROBOCOPY src\liblzma\api\lzma %SB_INSTALL_PATH%\include\lzma * /NP /NJH /NJS
ROBOCOPY windows\Release\x64\liblzma %SB_INSTALL_PATH%\lib liblzma.lib /NP /NJH /NJS 

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

