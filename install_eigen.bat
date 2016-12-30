@ECHO OFF
REM
REM install_eigen.bat
REM
REM Install Eigen
REM
REM Version 1.0, 28.12.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_EIGEN_FILENAME% (
	ECHO File %SB_EIGEN_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_CMAKE_PATH%;%SB_NINJA_PATH%;%SB_MSYS2_PATH%

REM Convert download path into MSYS path
SET "SB_DOWNLOAD_PATH_FWD=%SB_DOWNLOAD_PATH:\=/%"
SET "SB_DOWNLOAD_PATH_FWD2=%SB_DOWNLOAD_PATH_FWD::=%"
SET SB_DOWNLOAD_PATH_MSYS=/%SB_DOWNLOAD_PATH_FWD2%"

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_EIGEN_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_EIGEN_FILENAME%

CD %SB_EIGEN_PATH%
MKDIR sb_build
IF ERRORLEVEL 1 GOTO error_exit
CD sb_build
IF ERRORLEVEL 1 GOTO error_exit

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

REM Call CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% .. 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

REM Call Ninja
ninja install 2>&1 | tee ninja_install_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

