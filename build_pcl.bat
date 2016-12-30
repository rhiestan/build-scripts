@ECHO OFF
REM
REM build_pcl.bat
REM
REM Compile and install pcl
REM
REM Version 1.0, 29.12.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_PCL_FILENAME% (
	ECHO File %SB_PCL_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
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
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_POL_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_PCL_FILENAME%

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

REM Delete old build directory
CD %SB_BUILD_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat pcl_build_rel
IF ERRORLEVEL 1 GOTO error_exit
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat pcl_build_deb
IF ERRORLEVEL 1 GOTO error_exit

REM Create build directory
MKDIR pcl_build_rel
IF ERRORLEVEL 1 GOTO error_exit
CD pcl_build_rel

REM Call CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DPCL_SHARED_LIBS=OFF -DBUILD_apps=OFF -DBUILD_examples=OFF -DBUILD_tools=OFF -DPCL_ENABLE_SSE=OFF -DWITH_VTK=FALSE -DPNG_PNG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DPNG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/libpng16_static.lib -DZLIB_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% -DCMAKE_PREFIX_PATH=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_POL_PATH% 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

REM Call Ninja
ninja all 2>&1 | tee ninja_all_output.txt 
IF ERRORLEVEL 1 GOTO error_exit
ninja install 2>&1 | tee ninja_install_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

CD ..

REM Create build directory
MKDIR pcl_build_deb
IF ERRORLEVEL 1 GOTO error_exit
CD pcl_build_deb

REM Call CMake
cmake -G "Ninja" -DCMAKE_BUILD_TYPE="Debug" -DPCL_SHARED_LIBS=OFF -DBUILD_apps=OFF -DBUILD_examples=OFF -DBUILD_tools=OFF -DPCL_ENABLE_SSE=OFF -DWITH_VTK=FALSE -DPNG_PNG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DPNG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/libpng16_static.lib -DZLIB_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% -DCMAKE_PREFIX_PATH=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_POL_PATH% 2>&1 | tee cmake_output.txt 
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

