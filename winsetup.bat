@echo off
setlocal enabledelayedexpansion

:: === Set Wallpaper ===
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

:: === Download & Set Lock Screen ===
set "LOCK_URL_BASE=https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/src/background/lockscreen"
set "LOCK_PATH="

echo Looking for lock screen image...
for %%E in (%EXTENSIONS%) do (
    curl -s -L "!LOCK_URL_BASE!.%%E" -o "%IMG_DIR%\lockscreen.%%E"
    if exist "%IMG_DIR%\lockscreen.%%E" (
        for %%I in ("%IMG_DIR%\lockscreen.%%E") do set "FILESIZE=%%~zI"
        if !FILESIZE! gtr 1000 (
            set "LOCK_PATH=%IMG_DIR%\lockscreen.%%E"
            echo Found lock screen image: !LOCK_PATH!
            goto :lock_found
        ) else (
            del /f /q "%IMG_DIR%\lockscreen.%%E" >nul 2>&1
        )
    )
)
echo Lock screen image not found.
exit /b 1

:lock_found
echo Setting lock screen...
powershell -Command ^
"try {
    $img = '%LOCK_PATH%'; ^
    $regPath = 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Personalization'; ^
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }; ^
    Set-ItemProperty -Path $regPath -Name 'LockScreenImage' -Value $img; ^
    Set-ItemProperty -Path $regPath -Name 'NoLockScreen' -Value 0 -Type DWord; ^
    Write-Output 'Lock screen set to: %LOCK_PATH%' ^
} catch { ^
    Write-Output 'Failed to set lock screen. Run as administrator?' ^
}"

echo Lockscreen set.

:: ========== Install Apps ==========

:: === Define apps ===
set "apps="
:: Web Browsers
call :add Google.Chrome.EXE
call :add Mozilla.Firefox.de

:: Productivity & Office
call :add Microsoft.Office
call :add Microsoft.OneDrive
call :add Notion.Notion
call :add StefansTools.SKTimeStamp

:: Development Tools & Runtimes
call :add Git.Git
call :add JetBrains.Toolbox
call :add JetBrains.Rider
call :add JetBrains.PyCharm
call :add JetBrains.IntelliJIDEA.Ultimate
call :add Microsoft.DotNet.DesktopRuntime.9
call :add Microsoft.DotNet.SDK.9
call :add Microsoft.VCRedist.2010.x64
call :add Microsoft.VCRedist.2010.x86
call :add Microsoft.VCRedist.2012.x64
call :add Microsoft.VCRedist.2012.x86
call :add Microsoft.VCRedist.2015+.x64
call :add Microsoft.VCRedist.2015+.x86
call :add Microsoft.VisualStudioCode
call :add Microsoft.XNARedist
call :add Oracle.JavaRuntimeEnvironment
call :add Microsoft.OpenJDK.21

:: Gaming & Entertainment
call :add Overwolf.CurseForge
call :add Ubisoft.Connect
call :add Valve.Steam

:: Utilities & System Tools
call :add Corsair.iCUE.5
call :add Asus.ArmouryCrate
call :add RARLab.WinRAR
call :add Microsoft.AppInstaller
call :add Microsoft.WindowsTerminal
call :add Microsoft.UI.Xaml.2.7
call :add Microsoft.UI.Xaml.2.8
call :add Microsoft.VCLibs.Desktop.14

:: Communication & Collaboration
call :add Discord.Discord
call :add Microsoft.Teams
call :add Zoom.Zoom.EXE

:: Virtualization
call :add Docker.DockerDesktop
call :add Oracle.VirtualBox

:: Security & Networking
call :add NordSecurity.NordVPN

:: Other / Uncategorized

:: Check for --custom mode
set "CUSTOM_MODE=0"
if /i "%~1"=="--custom" (
    set "CUSTOM_MODE=1"
)
:: === Prompt and collect selected apps ===
set "selected="

for %%A in (%apps%) do (
    if !CUSTOM_MODE! == 1 (
        set /p "answer=Install %%A? (y/n): "
        if /i "!answer!"=="y" (
            set "selected=!selected! %%A"
        ) else (
            echo Skipping %%A.
        )
    ) else (
        set "selected=!selected! %%A"
    )
)

:: === Install selected apps ===
echo.
echo Installing selected apps...
echo.

for %%A in (!selected!) do (
    echo Installing %%A...
    winget install --id=%%A --silent --accept-package-agreements --accept-source-agreements
)

echo.
echo All done!
pause

:: === Helper to add app to list ===
:add
set "apps=!apps! %~1"
goto :eof
