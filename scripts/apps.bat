@echo off
setlocal enabledelayedexpansion

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
    echo custom
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
