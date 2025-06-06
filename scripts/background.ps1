# Base URL for images (without extension)
$ImageBaseUrl = "https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/src/background"

$ImageDestinationFolder = "C:\temp" # Change as needed

# Create destination folder if missing
if (-not (Test-Path $ImageDestinationFolder)) {
    New-Item -Path $ImageDestinationFolder -ItemType Directory -Force | Out-Null
}

# Function to download image by trying multiple extensions
function Download-ImageByExtensions {
    param(
        [string]$BaseUrl,
        [string]$FileNamePrefix,
        [string[]]$Extensions,
        [string]$DestinationFolder
    )

    foreach ($ext in $Extensions) {
        $url = "$BaseUrl/$FileNamePrefix.$ext"
        $destFile = Join-Path $DestinationFolder "$FileNamePrefix.$ext"

        try {
            Write-Host "Trying to download $url ..."
            Start-BitsTransfer -Source $url -Destination $destFile -ErrorAction Stop

            $fileSize = (Get-Item $destFile).Length
            if ($fileSize -gt 1000) {
                Write-Host "Downloaded valid file: $destFile"
                return $destFile
            } else {
                Write-Host "File too small or invalid, deleting $destFile"
                Remove-Item $destFile -Force
            }
        } catch {
            Write-Host "Failed to download $url"
        }
    }
    return $null
}

# Extensions to try
$extensions = @("png", "jpg", "jpeg", "bmp")

# Download wallpaper image dynamically
$WallpaperPath = Download-ImageByExtensions -BaseUrl $ImageBaseUrl -FileNamePrefix "background" -Extensions $extensions -DestinationFolder $ImageDestinationFolder
if (-not $WallpaperPath) {
    Write-Error "Failed to download wallpaper image with known extensions."
    exit 1
}

# Download lockscreen image dynamically
$LockScreenPath = Download-ImageByExtensions -BaseUrl $ImageBaseUrl -FileNamePrefix "lockscreen" -Extensions $extensions -DestinationFolder $ImageDestinationFolder
if (-not $LockScreenPath) {
    Write-Error "Failed to download lockscreen image with known extensions."
    exit 1
}

# --- Set Wallpaper for current user via Windows API ---

Add-Type @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# SPI_SETDESKWALLPAPER = 20, update INI file = 1, send change event = 2; combined = 3
[Wallpaper]::SystemParametersInfo(20, 0, $WallpaperPath, 3) | Out-Null

Write-Host "Wallpaper set to $WallpaperPath"

# --- Set Lock Screen image via registry (this locks the lockscreen) ---

$RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

$LockScreenStatusName = "LockScreenImageStatus"
$LockScreenPathName = "LockScreenImagePath"
$LockScreenUrlName = "LockScreenImageUrl"
$StatusValue = 1

if (!(Test-Path $RegKeyPath)) {
    New-Item -Path $RegKeyPath -Force | Out-Null
}

# Set the lockscreen registry keys
New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatusName -Value $StatusValue -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenPathName -Value $LockScreenPath -PropertyType STRING -Force | Out-Null
New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrlName -Value $LockScreenPath -PropertyType STRING -Force | Out-Null

Write-Host "Lock screen image set to $LockScreenPath (may prevent manual changes)"

Remove-Item -Path $RegKeyPath -Recurse -Force -ErrorAction SilentlyContinue

# Clear any errors before exiting
$error.Clear()
