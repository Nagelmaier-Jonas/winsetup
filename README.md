# winsetup

**winsetup** is a simple and flexible batch script to automate installing common applications on a freshly installed Windows system.

## 🚀 Features

- Installs apps using **winget** (Windows Package Manager)
- Supports **silent installs**
- Includes optional **interactive mode** (`--custom`) to confirm each app
- Easy to extend with new apps
- Clean and readable code structure

## 🛠️ Requirements

- Windows 10 (1809+) or Windows 11
- [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) must be installed and functional

## 📦 Default Installed Apps

Edit the batch file to customize this list. Example apps:

- Google Chrome
- Discord
- Steam
- Spotify

## 🧑‍💻 Usage (must use PowerShell)


### Run per curl:
```powershell
curl https://raw.githubusercontent.com/Nagelmaier-Jonas/winsetup/main/winsetup.bat -OutFile winsetup.bat; .\winsetup.bat
```
or if local instance
```bat
winsetup.bat
```

## ➕ Add More Apps

To add more apps, just append their [winget IDs](https://winget.run/) to the list in the script:

```bat
call :add VLC.VLC
call :add 7zip.7zip
call :add Notepad++.Notepad++
```
