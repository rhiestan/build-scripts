@ECHO OFF

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

SET SB_MAIN_PATH=%SB_SCRIPT_PATH%\..\..

REM Get paths and variables
CALL %SB_MAIN_PATH%\set_paths.bat
CALL %SB_MAIN_PATH%\set_vars.bat

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_CMAKE_PATH%;%SB_NINJA_PATH%

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"

REM echo %SB_INSTALL_PATH_FWD%
REM -DCMAKE_BUILD_TYPE=Debug

REM SET CC=icl
REM SET CXX=icl


REM JPG
SET JPEG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include
SET JPEG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/jpeg.lib

REM PNG
SET PNG_PNG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include
SET PNG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/libpng16_static.lib

REM tiff
SET TIFF_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include
SET TIFF_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/tiff.lib

REM ZLIB
SET ZLIB_ROOT=%SB_INSTALL_PATH_FWD%
SET ZLIB_INCLUDE_DIR=%ZLIB_ROOT%/include
SET ZLIB_LIBRARY=%ZLIB_ROOT%/lib/zlibstatic.lib

mkdir build_vstudio15
cd build_vstudio15
cmake -G "Visual Studio 14 Win64" -DCMAKE_CONFIGURATION_TYPES=Release;RelWithDebInfo;Debug -DwxWidgets_ROOT_DIR=%SB_INSTALL_PATH_FWD% -DwxWidgets_LIB_DIR=%SB_INSTALL_PATH_FWD%/lib -DJPEG_INCLUDE_DIR=%JPEG_INCLUDE_DIR% -DJPEG_LIBRARY=%JPEG_LIBRARY% -DPNG_PNG_INCLUDE_DIR=%PNG_PNG_INCLUDE_DIR% -DPNG_LIBRARY=%PNG_LIBRARY% -DTIFF_INCLUDE_DIR=%TIFF_INCLUDE_DIR% -DTIFF_LIBRARY=%TIFF_LIBRARY% -DZLIB_ROOT=%ZLIB_ROOT% -DZLIB_INCLUDE_DIR=%ZLIB_INCLUDE_DIR% -DZLIB_LIBRARY=%ZLIB_LIBRARY% ../src
pause
