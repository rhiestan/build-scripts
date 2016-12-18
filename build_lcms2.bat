@ECHO OFF
REM
REM build_lcms2.bat
REM
REM Compile and install lcms2
REM
REM Version 1.0, 23.11.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_LCMS2_FILENAME% (
	ECHO File %SB_LCMS2_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
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
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_LCMS2_PATH%
IF ERRORLEVEL 1 GOTO error_exit

REM Extract source
tar -xf %SB_DOWNLOAD_PATH_MSYS%/%SB_LCMS2_FILENAME%

REM Convert paths to cmake (backslashes to forward slashes)
SET "SB_INSTALL_PATH_FWD=%SB_INSTALL_PATH:\=/%"
SET "SB_SOURCE_PATH_FWD=%SB_SOURCE_PATH:\=/%"

CD %SB_LCMS2_PATH%

REM Change /MT to /MD and /MTd to /MDd
sed -i 's/^>MultiThreadedDebug^</^>MultiThreadedDebugDLL^</g' Projects/VC2015/lcms2_static/lcms2_static.vcxproj
sed -i 's/^>MultiThreaded^</^>MultiThreadedDLL^</g' Projects/VC2015/lcms2_static/lcms2_static.vcxproj

REM Call MSBuild
MSBuild.exe Projects\VC2015\lcms2_static\lcms2_static.vcxproj /tv:14.0 /maxcpucount /property:Configuration=Release,Platform=x64,MultiProcessorCompilation=true,PlatformToolset=v140 /nologo

REM Install files
ROBOCOPY Lib\MS %SB_INSTALL_PATH%\lib lcms2_static.lib /NJH /NJS /NP /NC /NS
ROBOCOPY include %SB_INSTALL_PATH%\include *.h /NJH /NJS /NP /NC /NS

pause
exit

:error_exit
ECHO Error occurred, exiting
pause

