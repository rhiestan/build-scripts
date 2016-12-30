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

REM Boost
SET BOOST_ROOT=%SB_INSTALL_PATH_FWD%
SET Boost_ADDITIONAL_VERSIONS="1.62"

REM Eigen
REM SET EIGEN3_DIR=%SB_INSTALL_PATH_FWD% -DEIGEN3_DIR=%EIGEN3_DIR%

mkdir build_vstudio
cd build_vstudio
cmake -Wno-dev -G "Visual Studio 14 Win64" -DCMAKE_CONFIGURATION_TYPES=Release;RelWithDebInfo;Debug -DCMAKE_PREFIX_PATH=%SB_INSTALL_PATH_FWD% ../src

cd ..
pause
