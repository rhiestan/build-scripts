@ECHO OFF
REM
REM build_graphicsmagick.bat
REM
REM Compile and install graphicsmagick
REM
REM Version 1.0, 26.11.2016

REM TODO: toolset configurable
REM TODO: add ICU


REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_GRAPHICSMAGICK_FILENAME% (
	ECHO File %SB_GRAPHICSMAGICK_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_7ZIP_PATH%;%SB_MSYS2_PATH%;%SB_INSTALL_PATH%\bin

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
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_GRAPHICSMAGICK_PATH%
IF ERRORLEVEL 1 GOTO error_exit


REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_GRAPHICSMAGICK_FILENAME%

CD %SB_GRAPHICSMAGICK_PATH%

SET CC=cccl
SET CXX=cccl
SET LD=cccl

SET MSYS2_PATH_TYPE=inherit

bash -c "exit 0" || (echo.No bash found in PATH! & exit /b 1)

GOTO start_bash

ECHO Configuring...
bash configure --prefix=$SB_INSTALL_PATH_MSYS
REM LIB_TTF_BASE=freetype ./configure --prefix=$LIBSDIR/$BUILDTOOLDIR/install --disable-installed --with-quantum-depth=16 --without-modules --disable-shared --disable-openmp CPPFLAGS="-I$LIBSDIR/$BUILDTOOLDIR/install/include -I$LIBSDIR/$BUILDTOOLDIR/install/include/libxml2 -DLIBXML_STATIC -I$LIBSDIR/$BUILDTOOLDIR/install/include/freetype2" LDFLAGS=-L$LIBSDIR/$BUILDTOOLDIR/install/lib LIBS="-llzma -ljbig -ljpeg -liconv -lxml2 -lws2_32"

ECHO Building...


pause
exit

:error_exit
ECHO Error occurred, exiting
pause

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


