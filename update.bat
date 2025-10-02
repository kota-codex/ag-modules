@echo off
setlocal enabledelayedexpansion

set BASE_DIR=extern

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"

for /f "usebackq tokens=*" %%u in (repos.txt) do (
    set "url=%%u"
    if not "!url!"=="" (
        for %%i in ("!url!") do set "name=%%~ni"
        set "path=%BASE_DIR%\!name!"

        if exist "!path!\.git" (
            echo Fetching !name!...
            pushd "!path!"
            git fetch
            popd
        ) else (
            echo Cloning !url! -> !path!
            git clone "!url!" "!path!"
        )
        if exist "!path!\update.bat" (
            echo Recursively updating !name!
            pushd "!path!"
            call update.bat
            popd
        )
    )
)

endlocal
