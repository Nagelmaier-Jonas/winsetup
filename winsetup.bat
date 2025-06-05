@echo off
setlocal enabledelayedexpansion

:: === Define apps ===
set "apps="
:: Browsers
call :add Google.Chrome
call :add Mozilla.Firefox

:: Communication
call :add Discord.Discord
call :add Microsoft.Teams
call :add Zoom.Zoom

:: Development Tools
call :add Git.Git
call :add JetBrains.Toolbox
call :add JetBrains.IntelliJIDEA.Ultimate
call :add JetBrains.PyCharm
call :add JetBrains.Rider
call :add Microsoft.DotNet.SDK
call :add Oracle.JavaSDK

:: Virtualization & Containers
call :add Docker.DockerDesktop
call :add Oracle.VirtualBox

:: Utilities
call :add WinRAR.WinRAR
call :add Notion.Notion
call :add NordVPN.NordVPN

:: Games
call :add Minecraft.MinecraftLauncher
call :add Valve.Steam

:: System/Hardware
call :add AdvancedMicroDevices.AMDSoftware
call :add Asus.ARMOURYCRATE
call :add Corsair.CUE

:: Productivity
call :add Microsoft.Office
call :add Microsoft.OneDrive



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