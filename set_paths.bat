REM
REM set_paths.bat
REM
REM Set paths for the SB build system
REM
REM Version 1.0, 16.11.2016

REM CMake bin path
SET SB_CMAKE_PATH=F:\Tools\cmake-3.7.0-win64-x64\bin

REM Visual Studio path
SET SB_VSTUDIO_PATH="F:\Programme\Microsoft Visual Studio 14.0\VC"

REM Ninja path
SET SB_NINJA_PATH=F:\Tools\Ninja

REM Jom path
SET SB_JOM_PATH=F:\Tools\jom

REM MSYS2 path
SET SB_MSYS2_PATH=F:\Tools\MSYS2\usr\bin
SET SB_MINGW64_PATH=F:\Tools\MSYS2\mingw64\bin

REM Path to 7zip
SET SB_7ZIP_PATH=C:\Program Files\7-Zip

REM cccl path
SET SB_CCCL_PATH=F:\Projects\libs\libs_vstudio15\cccl

REM Download path (where to find downloaded source zip/tar files)
SET SB_DOWNLOAD_PATH=F:\Download\Development

REM Source path (where to extract source files)
SET SB_SOURCE_PATH=F:\Projects\libs\libs_vstudio15\src

REM Build path (where to put build directories)
SET SB_BUILD_PATH=F:\Projects\libs\libs_vstudio15\build

REM Install path (where to install compiled binaries and header files)
SET SB_INSTALL_PATH=F:\Projects\libs\libs_vstudio15\install

REM Path for utility scripts
SET SB_UTIL_SCRIPTS_PATH=F:\Projects\libs\libs_vstudio15\utils

REM Path for suport files
SET SB_SUPPORT_FILES_PATH=F:\Projects\libs\libs_vstudio15\support
