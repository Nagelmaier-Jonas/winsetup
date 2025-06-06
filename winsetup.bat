@echo off
setlocal enabledelayedexpansion

set "BASE_URL=https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/scripts"
set "SCRIPTS=powersettings.bat apps.bat background.ps1"

for %%S in (%SCRIPTS%) do (
    echo Downloading %%S ...
    curl -s -L "%BASE_URL%/%%S" -o "%TEMP%\%%S"
    if exist "%TEMP%\%%S" (
        echo Running %%S ...
        if /I "%%~xS"==".bat" (
            call "%TEMP%\%%S"
        ) else if /I "%%~xS"==".ps1" (
            powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\%%S"
        ) else (
            echo Unknown script type: %%S
        )
    ) else (
        echo Failed to download %%S
    )
)

pause
