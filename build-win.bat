REM @echo off
setlocal enabledelayedexpansion

REM -----------------------------
REM Configuration
REM -----------------------------
REM set VCPKG_ROOT=C:\vcpkg
set GENERATOR=Ninja

set TRIPLES=x64-windows arm64-windows
set CONFIGS=Release Debug

set MODULES=
for /d %%d in (external\*) do (
    set MODULES=!MODULES! %%~nd
)

set VS_VCVARSALL="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"

echo Initializing Visual Studio environment...
call %VS_VCVARSALL% x64

for %%m in (%MODULES%) do (
    for %%t in (%TRIPLES%) do (
        for %%c in (%CONFIGS%) do (
            set BUILD_DIR=build\%%m-%%t-%%c
            set OUT_DIR=..\..\out\%%m

            echo Building module %%m for triple %%t, config %%c in !BUILD_DIR!
            if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"

            cmake -S "external\%%m" -B "!BUILD_DIR!" -G "%GENERATOR%" ^
                -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
                -DVCPKG_TARGET_TRIPLET=%%t ^
                -DCMAKE_BUILD_TYPE=%%c ^
                -DAG_OUT_DIR=!OUT_DIR! ^
                -DAG_TRIPLE=%%t

            for /f %%p in ('wmic cpu get NumberOfLogicalProcessors ^| findstr /r /v "^$"') do set CORES=%%p
            cmake --build "!BUILD_DIR!" --parallel !CORES!
        )
    )
)

echo Build complete!
endlocal
