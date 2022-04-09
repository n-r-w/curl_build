echo off
SetLocal EnableDelayedExpansion

rem MSVC env path:
set ms_vars="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

rem Download OpenSSL https://slproweb.com/download/Win64OpenSSL-3_0_2.msi and install to some folder:
set open_ssl_path=C:\tools\OpenSSL\OpenSSL-Win64

rem ZLIB version (from zlib git tags)
set zlib_version=1.2.12

rem CURL version (from curl git tags)
set curl_version=7_82_0

set zlib_bin_path=bin\zlib
set curl_bin_path=bin\curl

rmdir /S /Q zlib
rmdir /S /Q bin
rmdir /S /Q curl
git clone --depth 1 --branch v%zlib_version% https://github.com/madler/zlib.git
git clone --depth 1 --branch curl-%curl_version% https://github.com/curl/curl.git

set current_dir=%CD%

cd zlib
del CMakeCache.txt

call !ms_vars!

cmake -DCMAKE_INSTALL_PREFIX=../%zlib_bin_path%/release -DCMAKE_BUILD_TYPE=Release 
cmake --build . --target ALL_BUILD --config Release
cmake --install . --config Release

cd %current_dir%\zlib
git clean -d -f -x

cmake -DCMAKE_INSTALL_PREFIX=../%zlib_bin_path%/debug -DCMAKE_BUILD_TYPE=Debug
cmake --build . --target ALL_BUILD --config Debug
cmake --install . --config Debug

rename %current_dir%\%zlib_bin_path%\debug\bin\zlibd.dll zlib.dll
rename %current_dir%\%zlib_bin_path%\debug\lib\zlibd.lib zlib.lib
rename %current_dir%\%zlib_bin_path%\debug\lib\zlibstaticd.lib zlibstatic.lib


cd %current_dir%\curl
call buildconf.bat
cd %current_dir%\curl\winbuild

nmake /f Makefile.vc mode=dll MACHINE=x64 WITH_SSL=dll WITH_ZLIB=dll SSL_PATH=%open_ssl_path% ZLIB_PATH=%current_dir%\%zlib_bin_path%\release
cd %current_dir%
md %curl_bin_path%
xcopy /S /E /Y /Q curl\builds\libcurl-vc-x64-release-dll-ssl-dll-zlib-dll-ipv6-sspi\ %curl_bin_path%\release\

cd %current_dir%\curl
git clean -d -f -x

call buildconf.bat
cd %current_dir%\curl\winbuild
nmake /f Makefile.vc mode=dll DEBUG=yes MACHINE=x64 WITH_SSL=dll WITH_ZLIB=dll SSL_PATH=%open_ssl_path% ZLIB_PATH=%current_dir%\%zlib_bin_path%\debug
cd %current_dir%
md %curl_bin_path%
xcopy /S /E /Y /Q curl\builds\libcurl-vc-x64-debug-dll-ssl-dll-zlib-dll-ipv6-sspi\ %curl_bin_path%\debug\

rename %current_dir%\%zlib_bin_path%\debug\bin\zlib.dll zlibd.dll
rename %current_dir%\%zlib_bin_path%\debug\lib\zlib.lib zlibd.lib
rename %current_dir%\%zlib_bin_path%\debug\lib\zlibstatic.lib zlibstaticd.lib

cd %current_dir%

rmdir /S /Q zlib
rmdir /S /Q curl
