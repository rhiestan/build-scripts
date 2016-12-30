@ECHO OFF
REM
REM build_openssl.bat
REM
REM Compile and install OpenSSL
REM
REM Version 1.0, 30.12.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_OPENSSL_FILENAME% (
	ECHO File %SB_OPENSSL_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_PERL_PATH%;%SB_NASM_PATH%;%SB_7ZIP_PATH%;%SB_JOM_PATH%;%SB_MSYS2_PATH%

REM Convert download path into MSYS path
SET "SB_DOWNLOAD_PATH_FWD=%SB_DOWNLOAD_PATH:\=/%"
SET "SB_DOWNLOAD_PATH_FWD2=%SB_DOWNLOAD_PATH_FWD::=%"
SET SB_DOWNLOAD_PATH_MSYS=/%SB_DOWNLOAD_PATH_FWD2%"

REM Delete source directory
CD %SB_SOURCE_PATH%
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_OPENSSL_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_OPENSSL_FILENAME%

CD %SB_OPENSSL_PATH%

perl Configure VC-WIN64A --prefix=%SB_INSTALL_PATH% --openssldir=%SB_INSTALL_PATH%/ssl no-idea no-mdc2 no-rc5 no-shared

REM A file called "NUL" was created, delete it (can only be deleted with \\?\ syntax
IF EXIST \\?\%SB_SOURCE_PATH%\%SB_OPENSSL_PATH%\NUL (
	DEL \\?\%SB_SOURCE_PATH%\%SB_OPENSSL_PATH%\NUL
)

nmake 2>&1 | tee nmake_output.txt
nmake test 2>&1 | tee nmake_test_output.txt
nmake install 2>&1 | tee nmake_install_output.txt

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

