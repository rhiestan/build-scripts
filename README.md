# Build-Scripts #

This is a bunch of scripts to build third-party libraries for my projects.

## Required tools ##

- Visual Studio 2015 (any edition should work)
- 7-zip
- MSYS2 installation, including gcc
- Ninja
- JOM
- CMake
- NASM (Netwide Assembler)
- Perl (ActiveState Perl)

## Setup ##

- Please download and install the required tools on your PC.
- Download the newest release of these scripts and extract them in a new folder. Alternatively, you may also use git clone.
- Copy `set_paths_templ.bat` to `set_paths.bat` and open it in your favourite text editor. Adjust all paths. For example, adjust `SB_CMAKE_PATH` to the bin directory of the CMake you installed earlier.
- Run `check_tools.bat`. If any of the tools is not found, repeat the steps above.
- Download the sources of all libraries you wish to compile, and put them to the folder defined in `SB_DOWNLOAD_PATH`.
- Compile each library by double-clicking its batch file. Please do not run multiple batch files simultaneously, only one after another.

I suggest to compile the libraries in the following order:
`zlib bzip2 xz png jpeg tiff webp openjpeg icu boost freetype lcms2 wxwidgets nlopt flann qhull eigen gtest opencv assimp openssl pcl openscenegraph`    

Dependencies:

- png requires zlib
- tiff requires zlib and xz
- webp



## Motivation ##

Why did I make these scripts, why are they so complicated?

I made these scripts to be able to compile easily all the third-party libraries I require for my tools (Regard3D, EncFSMP, ABIC, CalcPi) with Visual Studio 2015. I have scripts for MinGW (which I do not publish) to keep everything up to date, now I also made them for Visual Studio. I publish them for interested developers to work on my projects.

Why are they so complicated? I wish to have all third-party libraries up to date. For example, wxWidgets comes with many third-party libraries, like PNG and JPEG. So does OpenCV, including PNG and JPEG. However, they usually come with two different versions of these libraries, which leads to conflicts. The only good solution is to compile everything yourself, and make sure all libraries use the most recent ones.


## Support ##

Please understand that my spare time is very limited and I can't give support for these scripts. I accept however ideas for improvement, especially in the form of pull requests. For example:

- Enable to switch from 64 bit to 32 bit
- Compile statically to the runtime libraries instead of dynamically (/MT instead of /MD)
- Create shared libraries instead of static ones
- Add scripts for new libraries
- Improved error handling


## Current status ##

The published scripts work on my PC, with my setup. With one exception: GraphicsMagick.


## License ##

This work is published under the [MIT](http://opensource.org/licenses/mit-license.php) license. You may freely use it for commercial or non-commercial projects.
