:: ========== Set Wallpaper ==========

@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "IMG_DIR=%SCRIPT_DIR%src\background"
if not exist "%IMG_DIR%" mkdir "%IMG_DIR%"

:: Try downloading the image with different extensions
set "IMG_URL_BASE=https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/src/background/background"
setlocal enabledelayedexpansion
set "EXTENSIONS=png jpg jpeg bmp"
set "IMG_PATH="

for %%E in (%EXTENSIONS%) do (
    echo Search: %%E
    curl -s -L "!IMG_URL_BASE!.%%E" -o "%IMG_DIR%\background.%%E"

    if exist "%IMG_DIR%\background.%%E" (
        for %%I in ("%IMG_DIR%\background.%%E") do set "FILESIZE=%%~zI"
        if !FILESIZE! gtr 1000 (
            set "IMG_PATH=%IMG_DIR%\background.%%E"
            echo Found and downloaded: !IMG_PATH!
            goto :found
        ) else (
            echo Not found: background.%%E
            del /f /q "%IMG_DIR%\background.%%E" >nul 2>&1
        )
    )
)

echo Failed to download background image with known extensions.
exit /b 1

:found
echo Set Wallpaper to: %IMG_PATH%
powershell -Command "$imagePath = '%IMG_PATH%'; Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; } '; [Wallpaper]::SystemParametersInfo(20,0,$imagePath,3) | Out-Null"

:: Desktop neu laden - so funktioniert es meist sicherer:
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True >nul 2>&1

echo Wallpaper set.