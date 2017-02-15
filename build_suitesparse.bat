@ECHO OFF
REM
REM build_suitesparse.bat
REM
REM Compile and install SuiteSparse (CMake version).
REM
REM Version 1.0, 11.01.2017

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_SUITESPARSE_FILENAME% (
	ECHO File %SB_SUITESPARSE_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
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
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_SUITESPARSE_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_SUITESPARSE_FILENAME%

REM Apply patches
CD %SB_SUITESPARSE_PATH%
REM Patch gk_arch.h for Visual Studio 2015
sed -i "61s/#ifdef __MSC__/#if defined(_MSC_VER) \&\& _MSC_VER < 1900/" metis/GKLib/gk_arch.h
REM Patch CMakeLists.txt to use our CMAKE_INSTALL_PREFIX
sed -i '19d' CMakeLists.txt
sed -i '19d' CMakeLists.txt
REM Patch SuiteSparse/CHOLMOD/CMakeLists.txt to define NGPL (use only LGPL parts)
sed -i '3 i\ADD_DEFINITIONS(-DNGPL)\n' SuiteSparse/CHOLMOD/CMakeLists.txt

pause

REM Delete old build directory
CD %SB_BUILD_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat suitesparse_build
IF ERRORLEVEL 1 GOTO error_exit

REM Create build directory
MKDIR suitesparse_build
IF ERRORLEVEL 1 GOTO error_exit
CD suitesparse_build

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

REM Call CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_SUITESPARSE_PATH% 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

REM Call Ninja
ninja all 2>&1 | tee ninja_all_output.txt 
IF ERRORLEVEL 1 GOTO error_exit
ninja install 2>&1 | tee ninja_install_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

