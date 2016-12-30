: <<TRAMPOLINE
@ECHO OFF
REM
REM build_wxwidgets.bat
REM
REM Compile and install wxWidgets
REM
REM Version 1.0, 07.12.2016

REM Save path to this script
SET SB_SCRIPT_PATH=%~dp0

REM Get paths and variables
CALL set_paths.bat
CALL set_vars.bat
CALL libs_versions.bat

REM Check distributable file is present
IF NOT EXIST %SB_DOWNLOAD_PATH%\%SB_WXWIDGETS_FILENAME% (
	ECHO File %SB_WXWIDGETS_FILENAME% not found. Please download it and put it into the download folder %SB_DOWNLOAD_PATH%.
	pause
	EXIT /B 1
)

REM Set Visual Studio environment
CALL %SB_VSTUDIO_PATH%\vcvarsall.bat %SB_VSTUDIO_ARCHITECTURE%

REM Set path
SET PATH=%PATH%;%SB_CMAKE_PATH%;%SB_7ZIP_PATH%;%SB_MSYS2_PATH%;%SB_CCCL_PATH%;%SB_MINGW64_PATH%

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
CALL %SB_UTIL_SCRIPTS_PATH%\fast_rmdir.bat %SB_WXWIDGETS_PATH%
IF ERRORLEVEL 1 GOTO error_exit

MKDIR %SB_WXWIDGETS_PATH%
IF ERRORLEVEL 1 GOTO error_exit
CD %SB_WXWIDGETS_PATH%

REM Extract source
7z x %SB_DOWNLOAD_PATH%/%SB_WXWIDGETS_FILENAME%

GOTO bash_build

:error_exit
ECHO Error occurred, exiting
pause
EXIT /B 1


:bash_build
SET MSYS2_PATH_TYPE=inherit
bash -l "%~f0" "%*"
pause
goto :EOF
TRAMPOLINE
#####################
#!/bin/bash

echo $PATH
export PATH=$PATH:$SB_CCCL_PATH_MSYS
cd $SB_SOURCE_PATH_MSYS/$SB_WXWIDGETS_PATH

echo Building release version
mkdir build-release
cd build-release

export CCCL_OPTIONS="/MD --cccl-verbose /EHsc /Os /DNOMINMAX"
CC=cccl-wx CXX=cccl-wx LD=cccl-wx LIBS=" -llibpng16 -lliblzma -llibjpeg -lzlibstatic -luser32 -lole32 -loleaut32" ../configure --build=x86_64-pc-mingw32 --disable-debug --disable-shared --disable-compat28 --with-opengl --with-libjpeg=sys --with-libpng=sys --with-libtiff=sys --enable-ole --enable-dataobj --enable-mediactrl --disable-webview --prefix=$SB_INSTALL_PATH_MSYS CPPFLAGS="-I$SB_INSTALL_PATH_MSYS/include" LDFLAGS="-L$SB_INSTALL_PATH_MSYS/lib"

sed -i 's/#define __GNUWIN32__ 1/#undef __GNUWIN32__/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define wxUSE_OLE[ \t]*0/#define wxUSE_OLE 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define wxUSE_OLE_AUTOMATION[ \t]*0/#define wxUSE_OLE_AUTOMATION 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define wxUSE_ACTIVEX[ \t]*0/#define wxUSE_ACTIVEX 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#[ \t]*define[ \t]*wxUSE_GRAPHICS_CONTEXT[ \t]*0/#define wxUSE_GRAPHICS_CONTEXT 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define mode_t int/\/\/#define mode_t int/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h

make -j4

# This is required as library names are not appropriate, small hack for wxrc
cd lib
cp -p libwx_baseu-3.1.a wx_baseu-3.1.lib
cp -p libwx_baseu_xml-3.1.a wx_baseu_xml-3.1.lib
cp -p libwxregexu-3.1.a wxregexu-3.1.lib
cp -p libwxexpat-3.1.a wxexpat-3.1.lib
cd ..
make

echo Installing release version
cd lib

for file in libwx_msw* ; do cp -p "$file" "$SB_INSTALL_PATH_MSYS/lib/`echo $file | sed 's/^libwx_mswu_/wxmsw31u_/' | sed 's/-3\.1//' | sed 's/\.a$/\.lib/'`"; done
for file in libwx_base* ; do cp -p "$file" "$SB_INSTALL_PATH_MSYS/lib/`echo $file | sed 's/^libwx_baseu/wxbase31u/' | sed 's/-3\.1//' | sed 's/\.a$/\.lib/'`"; done
cp -p libwxexpat-3.1.lib $SB_INSTALL_PATH_MSYS/lib/wxexpat.lib
cp -p libwxregexu-3.1.lib $SB_INSTALL_PATH_MSYS/lib/wxregexu.lib
cp -p libwxscintilla-3.1.lib $SB_INSTALL_PATH_MSYS/lib/wxscintilla.lib
cp -rp wx/include/msw-unicode-static-3.1 $SB_INSTALL_PATH_MSYS/lib/mswu

cd ..
cp -p utils/wxrc/wxrc.exe $SB_INSTALL_PATH_MSYS/bin

cd ..
cp -rp include/wx $SB_INSTALL_PATH_MSYS/include

echo Building debug version
mkdir build-debug
cd build-debug

export CCCL_OPTIONS="/MDd --cccl-verbose /EHsc /Od /DNOMINMAX /D_ITERATOR_DEBUG_LEVEL=2"
CC=cccl-wx CXX=cccl-wx LD=cccl-wx LIBS=" -llibpng16 -lliblzma -llibjpeg -lzlibstatic -luser32 -lole32 -loleaut32" ../configure --build=x86_64-pc-mingw32 --enable-debug --disable-shared --disable-compat28 --with-opengl --with-libjpeg=sys --with-libpng=sys --with-libtiff=sys --enable-ole --enable-dataobj --enable-mediactrl --disable-webview --prefix=$SB_INSTALL_PATH_MSYS CPPFLAGS="-I$SB_INSTALL_PATH_MSYS/include" LDFLAGS="-L$SB_INSTALL_PATH_MSYS/lib"

sed -i 's/#define __GNUWIN32__ 1/#undef __GNUWIN32__/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define wxUSE_OLE[ \t]*0/#define wxUSE_OLE 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define wxUSE_OLE_AUTOMATION[ \t]*0/#define wxUSE_OLE_AUTOMATION 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define wxUSE_ACTIVEX[ \t]*0/#define wxUSE_ACTIVEX 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#[ \t]*define[ \t]*wxUSE_GRAPHICS_CONTEXT[ \t]*0/#define wxUSE_GRAPHICS_CONTEXT 1/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h
sed -i 's/#define mode_t int/\/\/#define mode_t int/g' lib/wx/include/msw-unicode-static-3.1/wx/setup.h

# -j4 does not work because of the pdb files
make

echo Installing debug libraries
cd lib

for file in libwx_msw* ; do cp -p "$file" "$SB_INSTALL_PATH_MSYS/lib/`echo $file | sed 's/^libwx_mswu_/wxmsw31ud_/' | sed 's/-3\.1//' | sed 's/\.a$/\.lib/'`"; done
for file in libwx_base* ; do cp -p "$file" "$SB_INSTALL_PATH_MSYS/lib/`echo $file | sed 's/^libwx_baseu/wxbase31ud/' | sed 's/-3\.1//' | sed 's/\.a$/\.lib/'`"; done
cp -p libwxexpat-3.1.a $SB_INSTALL_PATH_MSYS/lib/wxexpatd.lib
cp -p libwxregexu-3.1.a $SB_INSTALL_PATH_MSYS/lib/wxregexud.lib
cp -p libwxscintilla-3.1.a $SB_INSTALL_PATH_MSYS/lib/wxscintillad.lib
cp -rp wx/include/msw-unicode-static-3.1 $SB_INSTALL_PATH_MSYS/lib/mswud


# for samples:
# -luser32 -lole32 -loleaut32
