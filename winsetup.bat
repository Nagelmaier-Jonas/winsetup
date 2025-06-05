@echo off
setlocal enabledelayedexpansion

:: === Define apps ===
set "apps="
call :add Google.Chrome
call :add Discord.Discord


:: Check for --custom mode
set "CUSTOM_MODE=0"
if /i "%~1"=="--custom" (
    set "CUSTOM_MODE=1"
)

:: === Install apps ===
for %%A in (%apps%) do (
    set "install=1"
    if !CUSTOM_MODE! == 1 (
        set /p "answer=Install %%A? (y/n): "
        if /i "!answer!" NEQ "y" (
            set "install=0"
        )
    )

    if !install! == 1 (
        echo Installing %%A...
        winget install --id=%%A --silent --accept-package-agreements --accept-source-agreements
    ) else (
        echo Skipping %%A.
    )
)

echo.
echo All done!
pause


:: === Helper to add app to list ===
:add
set "apps=!apps! %~1"
goto :eof