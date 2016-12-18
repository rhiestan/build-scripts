@ECHO OFF
REM
REM build_icu.bat
REM
REM Compile and install ICU
REM
REM Version 1.0, 16.11.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_ICU_FILENAME% (
	ECHO File %SB_ICU_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_MSYS2_PATH%;%SB_7ZIP_PATH%

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

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_ICU_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
7z x %SB_DOWNLOAD_PATH%/%SB_ICU_FILENAME%

CD %SB_ICU_PATH%\source
SET PATH=%PATH%;%SB_SOURCE_PATH%\%SB_ICU_PATH%\bin

REM SET MSYS2_PATH_TYPE=inherit

REM Update config.guess, cheat config
curl -o config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
curl -o config.sub 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
cp config/mh-msys-msvc config/mh-unknown

bash -c "exit 0" || (echo.No bash found in PATH! & exit /b 1)

bash ./runConfigureICU MSYS/MSVC --prefix=%SB_INSTALL_PATH_MSYS%
make -j4
REM make check
make install

REM Copy all *.dll from install/lib to install/bin
ROBOCOPY %SB_INSTALL_PATH%\lib %SB_INSTALL_PATH%\bin *.dll /NP /NJH /NJS /LEV:0

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

