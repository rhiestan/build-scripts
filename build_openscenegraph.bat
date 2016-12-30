@ECHO OFF
REM
REM build_openscenegraph.bat
REM
REM Compile and install OpenSceneGraph
REM
REM Version 1.0, 29.12.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_OSG_FILENAME% (
	ECHO File %SB_OSG_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_CMAKE_PATH%;%SB_NINJA_PATH%;%SB_7ZIP_PATH%;%SB_MSYS2_PATH%

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_OSG_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
7z x %SB_DOWNLOAD_PATH%\%SB_OSG_FILENAME%

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

REM Apply patches
sed -i '24 i\IF(MSVC)\n	SET(FREETYPE_LIBRARY ${FREETYPE_LIBRARY} $ENV{SB_INSTALL_PATH_FWD}/lib/libpng16_static.lib $ENV{SB_INSTALL_PATH_FWD}/lib/jpeg.lib $ENV{SB_INSTALL_PATH_FWD}/lib/liblzma.lib $ENV{SB_INSTALL_PATH_FWD}/lib/libbz2.lib )\nENDIF(MSVC)\n\n' %SB_OSG_PATH%/src/osgPlugins/freetype/CMakeLists.txt
sed -i '7 i\IF(MSVC)\n	SET(FREETYPE_LIBRARY ${FREETYPE_LIBRARY} $ENV{SB_INSTALL_PATH_FWD}/lib/jpeg.lib $ENV{SB_INSTALL_PATH_FWD}/lib/liblzma.lib $ENV{SB_INSTALL_PATH_FWD}/lib/libbz2.lib )\nENDIF(MSVC)\n\n' %SB_OSG_PATH%/src/osgPlugins/tiff/CMakeLists.txt
pause

REM Delete old build directories
CD %SB_BUILD_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat openscenegraph_build_rel
IF ERRORLEVEL 1 GOTO error_exit
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat openscenegraph_build_deb
IF ERRORLEVEL 1 GOTO error_exit

REM Create build directory
MKDIR openscenegraph_build_rel
IF ERRORLEVEL 1 GOTO error_exit
CD openscenegraph_build_rel

REM Call CMake
cmake -Wno-dev -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DDYNAMIC_OPENSCENEGRAPH=OFF -DDYNAMIC_OPENTHREADS=OFF -DBUILD_OSG_EXAMPLES=YES -DOSG_MSVC_VERSIONED_DLL=OFF -DCMAKE_PREFIX_PATH=%SB_INSTALL_PATH_FWD% -DZLIB_ROOT=%SB_INSTALL_PATH_FWD% -DPNG_PNG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DPNG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/libpng16_static.lib -DTIFF_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DTIFF_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/tiff.lib -DJPEG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DJPEG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/jpeg.lib -DZLIB_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_OSG_PATH% 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

pause

REM Call Ninja
ninja all 2>&1 | tee ninja_all_output.txt 
IF ERRORLEVEL 1 GOTO error_exit
ninja install 2>&1 | tee ninja_install_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

CD %SB_BUILD_PATH%

REM Create build directory
MKDIR openscenegraph_build_deb
IF ERRORLEVEL 1 GOTO error_exit
CD openscenegraph_build_deb

REM Call CMake
cmake -Wno-dev -G "Ninja" -DCMAKE_BUILD_TYPE="Debug" -DDYNAMIC_OPENSCENEGRAPH=OFF -DDYNAMIC_OPENTHREADS=OFF -DBUILD_OSG_EXAMPLES=YES -DOSG_MSVC_VERSIONED_DLL=OFF -DCMAKE_PREFIX_PATH=%SB_INSTALL_PATH_FWD% -DZLIB_ROOT=%SB_INSTALL_PATH_FWD% -DPNG_PNG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DPNG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/libpng16_static.lib -DTIFF_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DTIFF_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/tiff.lib -DJPEG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DJPEG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/jpeg.lib -DZLIB_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_OSG_PATH% 2>&1 | tee cmake_output.txt 
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

