# Base URL for both images (without extension)
$ImageBaseUrl = "https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/src/background"

$ImageDestinationFolder = "C:\temp" # Change to your fitting
# Destination files (will be assigned after download)
$WallpaperDestinationFile = $null
$LockScreenDestinationFile = $null

# Create destination folder if it doesn't exist
if (-not (Test-Path $ImageDestinationFolder)) {
    mkdir $ImageDestinationFolder -Force
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

# Download Wallpaper image dynamically
$WallpaperDestinationFile = Download-ImageByExtensions -BaseUrl $ImageBaseUrl -FileNamePrefix "background" -Extensions $extensions -DestinationFolder $ImageDestinationFolder
if (-not $WallpaperDestinationFile) {
    Write-Error "Failed to download wallpaper image with known extensions."
    exit 1
}

# Download LockScreen image dynamically
$LockScreenDestinationFile = Download-ImageByExtensions -BaseUrl $ImageBaseUrl -FileNamePrefix "lockscreen" -Extensions $extensions -DestinationFolder $ImageDestinationFolder
if (-not $LockScreenDestinationFile) {
    Write-Error "Failed to download lockscreen image with known extensions."
    exit 1
}

# Registry path and property names
$RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP'

$DesktopPath = "DesktopImagePath"
$DesktopStatus = "DesktopImageStatus"
$DesktopUrl = "DesktopImageUrl"
$LockScreenPath = "LockScreenImagePath"
$LockScreenStatus = "LockScreenImageStatus"
$LockScreenUrl = "LockScreenImageUrl"

$StatusValue = 1
$DesktopImageValue = $WallpaperDestinationFile
$LockScreenImageValue = $LockScreenDestinationFile

# Create or update registry keys
if (!(Test-Path $RegKeyPath)) {
    New-Item -Path $RegKeyPath -Force | Out-Null

    New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
}
else {
    New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
}

# Clear errors before exiting
$error.Clear()
