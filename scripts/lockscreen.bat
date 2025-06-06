@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "IMG_DIR=%SCRIPT_DIR%src\background"
if not exist "%IMG_DIR%" mkdir "%IMG_DIR%"

:: Try downloading the image with different extensions
set "IMG_URL_BASE=https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/src/background/lockscreen"
setlocal enabledelayedexpansion
set "EXTENSIONS=png jpg jpeg bmp"
set "IMG_PATH="

for %%E in (%EXTENSIONS%) do (
    echo Search: %%E
    curl -s -L "!IMG_URL_BASE!.%%E" -o "%IMG_DIR%\lockscreen.%%E"

    if exist "%IMG_DIR%\lockscreen.%%E" (
        for %%I in ("%IMG_DIR%\lockscreen.%%E") do set "FILESIZE=%%~zI"
        if !FILESIZE! gtr 1000 (
            set "IMG_PATH=%IMG_DIR%\lockscreen.%%E"
            echo Found and downloaded: !IMG_PATH!
            goto :found
        ) else (
            echo Not found: lockscreen.%%E
            del /f /q "%IMG_DIR%\lockscreen.%%E" >nul 2>&1
        )
    )
)

echo Failed to download lockscreen image with known extensions.
exit /b 1

:found
echo Set Lockscreen to: %IMG_PATH%

:: Set lock screen via registry (requires Windows Pro/Enterprise and admin)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v LockScreenImage /t REG_SZ /d "%IMG_PATH%" /f

echo Lock screen image has been configured.
echo You may need to sign out or restart for changes to take effect.
pause

