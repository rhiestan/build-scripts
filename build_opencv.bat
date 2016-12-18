@ECHO OFF
REM
REM build_opencv.bat
REM
REM Compile and install OpenCV
REM
REM Version 1.0, 01.12.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_OPENCV_FILENAME% (
	ECHO File %SB_OPENCV_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_CMAKE_PATH%;%SB_NINJA_PATH%;%SB_7ZIP_PATH%;%SB_MSYS2_PATH%

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_OPENCV_PATH%
IF ERRORLEVEL 1 GOTO error_exit
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_OPENCV_CONTRIB_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
7z x %SB_DOWNLOAD_PATH%\%SB_OPENCV_FILENAME%
7z x %SB_DOWNLOAD_PATH%\%SB_OPENCV_CONTRIB_FILENAME%
CD %SB_OPENCV_PATH%
sed -i 's,/libpng/,/libpng16/,g' cmake/OpenCVFindLibsGrfmt.cmake
sed -i 's,libpng/,libpng16/,g' modules/imgcodecs/src/grfmt_png.cpp
CD ..


REM Delete old build directory
CD %SB_BUILD_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat opencv_build
IF ERRORLEVEL 1 GOTO error_exit

REM Create build directory
MKDIR opencv_build
IF ERRORLEVEL 1 GOTO error_exit
CD opencv_build

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

REM Call CMake
cmake -Wno-dev -G "Ninja" -DCMAKE_BUILD_TYPE="Release" -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_WITH_STATIC_CRT=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF -DWITH_WIN32UI=OFF -DWITH_QT=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_DSHOW=OFF -DWITH_IPP=OFF -DBUILD_ZLIB=OFF -DBUILD_PNG=OFF -DBUILD_JPEG=OFF -DBUILD_TIFF=OFF -DBUILD_OPENEXR=OFF -DBUILD_opencv_python3=OFF -DBUILD_opencv_bioinspired=OFF -DBUILD_opencv_dpm=OFF -DBUILD_opencv_face=OFF -DWITH_OPENEXR=OFF -DWITH_OPENGL=OFF -DWITH_NVCUVID=OFF -DWITH_CUBLAS=OFF -DWITH_OPENNI=OFF -DWITH_OPENMP=OFF -DEIGEN_INCLUDE_PATH=F:/Projects/libs/libs_vstudio15/src/eigen-3.3.0 -DZLIB_ROOT=%SB_INSTALL_PATH_FWD% -DWITH_TBB=OFF -DPNG_PNG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DPNG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/libpng16_static.lib -DTIFF_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DTIFF_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/tiff.lib -DJPEG_INCLUDE_DIR=%SB_INSTALL_PATH_FWD%/include -DJPEG_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/jpeg.lib -DWEBP_LIBRARY=%SB_INSTALL_PATH_FWD%/lib/webp.lib -DOPENCV_EXTRA_MODULES_PATH=%SB_SOURCE_PATH_FWD%/%SB_OPENCV_CONTRIB_PATH%/modules -DCMAKE_INSTALL_PREFIX=%SB_INSTALL_PATH_FWD% %SB_SOURCE_PATH_FWD%/%SB_OPENCV_PATH% 2>&1 | tee cmake_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

pause

REM Call Ninja
ninja all 2>&1 | tee ninja_all_output.txt 
IF ERRORLEVEL 1 GOTO error_exit
pause
ninja install 2>&1 | tee ninja_install_output.txt 
IF ERRORLEVEL 1 GOTO error_exit

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

