@echo off
setlocal enabledelayedexpansion

REM -----------------------------
REM Configuration
REM -----------------------------
REM set VCPKG_ROOT=C:\vcpkg
set GENERATOR=Ninja

REM set TRIPLES=x64-windows arm64-windows // MS support for ARM64 is beyond evil, please fix 
set TRIPLES=x64-windows
set CONFIGS=Release Debug

set MODULES=
for /d %%d in (extern\*) do (
    set MODULES=!MODULES! %%~nd
)

set VS_VCVARSALL="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"

for /f %%p in ('wmic cpu get NumberOfLogicalProcessors ^| findstr /r /v "^$"') do set CORES=%%p

for %%t in (%TRIPLES%) do (
    if "%%t"=="x64-windows" (
        call %VS_VCVARSALL% x64
    ) else if "%%t"=="arm64-windows" (
        call %VS_VCVARSALL% amd64_arm64
    ) else (
        echo Unsupported triple %%t
        exit /b 1
    )
    for %%m in (%MODULES%) do (
        set BUILD_DIR=build\%%m-%%t
        if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"
        set OUT_DIR=..\..\out\%%m
        if not exist "!OUT_DIR!" mkdir "!OUT_DIR!"
        for %%c in (%CONFIGS%) do (
            echo Building module %%m for triple %%t, config %%c in !BUILD_DIR!

            cmake -S "extern\%%m" -B "!BUILD_DIR!" -G "%GENERATOR%" ^
                -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
                -DVCPKG_TARGET_TRIPLET=%%t ^
                -DCMAKE_BUILD_TYPE=%%c ^
                -DAG_OUT_DIR=!OUT_DIR! ^
                -DAG_TRIPLE=%%t

            cmake --build "!BUILD_DIR!" --parallel !CORES!
        )
    )
)

echo Build complete!
endlocal
