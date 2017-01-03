@ECHO OFF
REM
REM build_gtest.bat
REM
REM Compile and install Google Test
REM
REM Version 1.0, 01.01.2017

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_GTEST_FILENAME% (
	ECHO File %SB_GTEST_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
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
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_GTEST_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_GTEST_FILENAME%

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

REM Delete old build directory
CD %SB_BUILD_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat gtest_rel
IF ERRORLEVEL 1 GOTO error_exit
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat gtest_deb
IF ERRORLEVEL 1 GOTO error_exit

REM Create build directory
MKDIR gtest_rel
IF ERRORLEVEL 1 GOTO error_exit
CD gtest_rel

REM Call CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DBUILD_SHARED_LIBS=TRUE -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_GTEST_PATH%/googletest 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

REM Call Ninja
ninja all 2>&1 | tee ninja_all_output.txt 
IF ERRORLEVEL 1 GOTO error_exit
CD ..

REM Create build directory
MKDIR gtest_deb
IF ERRORLEVEL 1 GOTO error_exit
CD gtest_deb

REM Call CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE="Debug" -DBUILD_SHARED_LIBS=TRUE -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_GTEST_PATH%/googletest 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

REM Call Ninja
ninja all 2>&1 | tee ninja_all_output.txt 
IF ERRORLEVEL 1 GOTO error_exit
CD ..

ECHO Install header files
ROBOCOPY %SB_SOURCE_PATH%\%SB_GTEST_PATH%\googletest\include\gtest %SB_INSTALL_PATH%\include\gtest *.* /E /NJH /NJS /NFL

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

