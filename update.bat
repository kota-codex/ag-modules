@echo on
setlocal enabledelayedexpansion

set "BASE_DIR=extern"

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"

for /f "usebackq delims=" %%u in ("repos.txt") do (
    set "url=%%u"
    if not "!url!"=="" (
        for %%i in ("!url!") do set "name=%%~ni"
        set "p=%BASE_DIR%\!name!"
        if exist "!p!\.git" (
            echo fetching !p!...
            pushd "!p!" >nul
            git fetch
            popd >nul
        ) else (
            echo cloning !p!...
            git clone "!url!" "!p!"
        )
        if exist "!p!\update.bat" (
            echo Recursively updating !name!
            pushd "!p!" >nul
            call update.bat
            popd >nul
        )
    )
)

endlocal
