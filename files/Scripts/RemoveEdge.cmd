@echo off

:: Determine the system drive where Windows is installed
set "SystemDrive=%SystemDrive%"

:: Define the paths to Edge and EdgeWebView uninstallers
set "EdgePath=%SystemDrive%\Program Files (x86)\Microsoft\Edge\Application\1*\Installer"
set "EdgeWebViewPath=%SystemDrive%\Program Files (x86)\Microsoft\EdgeWebView\Application\1*\Installer"

:: Uninstall Microsoft Edge
cd /d "%EdgePath%" 2>nul
if exist setup.exe (
    setup.exe --uninstall --msedge --system-level --verbose-logging --force-uninstall 2>nul
)

:: Uninstall Microsoft Edge WebView
cd /d "%EdgeWebViewPath%" 2>nul
if exist setup.exe (
    setup.exe --uninstall --msedgewebview --system-level --verbose-logging --force-uninstall 2>nul
)

:: Remove the Microsoft directory if it exists
cd /d "%SystemDrive%\Program Files (x86)" 2>nul
if exist Microsoft (
    rd /s /q Microsoft
)