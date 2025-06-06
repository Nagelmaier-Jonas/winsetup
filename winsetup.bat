@echo off
setlocal enabledelayedexpansion

set "BASE_URL=https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/scripts"
set "SCRIPTS=powersettings.bat wallpaper.bat apps.bat lockscreen.bat"

for %%S in (%SCRIPTS%) do (
    echo Downloading %%S ...
    curl -s -L "%BASE_URL%/%%S" -o "!TEMP!\%%S"
    if exist "!TEMP!\%%S" (
        echo Running %%S ...
        call "!TEMP!\%%S"
    ) else (
        echo Failed to download %%S
    )
)