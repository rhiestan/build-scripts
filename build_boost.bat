@ECHO OFF
REM
REM build_boost.bat
REM
REM Compile and install boost
REM
REM Version 1.0, 16.11.2016

REM TODO: toolset configurable


REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_BOOST_FILENAME% (
	ECHO File %SB_BOOST_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_7ZIP_PATH%;%SB_MSYS2_PATH%;%SB_INSTALL_PATH%\bin

REM Delete and recreate boost_build
CD %SB_BUILD_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat boost_build
IF ERRORLEVEL 1 GOTO error_exit
MKDIR boost_build
IF ERRORLEVEL 1 GOTO error_exit


REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_BOOST_PATH%
IF ERRORLEVEL 1 GOTO error_exit


REM Extract source
7z x %SB_DOWNLOAD_PATH%/%SB_BOOST_FILENAME%

CD %SB_BOOST_PATH%

ECHO Building...

CALL bootstrap.bat

REM Adjust library names for ICU (don't look for debug versions)
sed -i 's/icuind/icuin/g' libs/locale/build/Jamfile.v2
sed -i 's/icuucd/icuuc/g' libs/locale/build/Jamfile.v2
sed -i 's/icuind/icuin/g' libs/regex/build/Jamfile.v2
sed -i 's/icuucd/icuuc/g' libs/regex/build/Jamfile.v2

.\b2 --build-dir=%SB_BUILD_PATH%\boost_build toolset=msvc-14.0 variant=debug,release runtime-link=shared link=static threading=multi architecture=x86 address-model=64 linkflags=/LIBPATH:%SB_INSTALL_PATH%\lib --prefix=%SB_INSTALL_PATH% --without-mpi --without-python --without-context -s BZIP2_BINARY=libbz2 -s BZIP2_INCLUDE=%SB_INSTALL_PATH%\include -s BZIP2_LIBPATH=%SB_INSTALL_PATH%\lib -s ZLIB_BINARY=zlibstatic -s ZLIB_INCLUDE=%SB_INSTALL_PATH%\include -s ZLIB_LIBPATH=%SB_INSTALL_PATH%\lib -sICU_PATH=%SB_INSTALL_PATH% -j4 stage 2>&1 | tee b2_build_output.log
.\b2 --build-dir=%SB_BUILD_PATH%\boost_build toolset=msvc-14.0 variant=debug,release runtime-link=shared link=static threading=multi architecture=x86 address-model=64 linkflags=/LIBPATH:%SB_INSTALL_PATH%\lib --prefix=%SB_INSTALL_PATH% --without-mpi --without-python --without-context -s BZIP2_BINARY=libbz2 -s BZIP2_INCLUDE=%SB_INSTALL_PATH%\include -s BZIP2_LIBPATH=%SB_INSTALL_PATH%\lib -s ZLIB_BINARY=zlibstatic -s ZLIB_INCLUDE=%SB_INSTALL_PATH%\include -s ZLIB_LIBPATH=%SB_INSTALL_PATH%\lib -sICU_PATH=%SB_INSTALL_PATH% install 2>&1 | tee b2_install_output.log

pause
exit

:error_exit
ECHO Error occurred, exiting
pause
