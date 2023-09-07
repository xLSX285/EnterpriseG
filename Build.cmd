@echo off
pushd "%~dp0" >nul 2>&1

:: Set Windows Version
set "Windows=Windows 11"

:: Specify the Windows Build (Insider Previews mostly end with .1000 and Stable always with .1)
set "VERSION=10.0.22621.1"

:: Specify whether the Image you are using is a Windows vNext Build (Canary Channel Builds)
set "vNext=False"

:: Compress Image from .WIM to .ESD to reduce size 
set "WimToESD=False"

if not exist mount mkdir mount >nul 2>&1
if not exist temp mkdir temp >nul 2>&1

:: In case any other Build than 22621.1 is defined, it will rename the file names and the strings inside the files.
echo ● Preparing SXS files ●
copy files\sxs\* sxs\ >nul 2>&1
ren "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum" "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum" >nul 2>&1
ren "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.cat" "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.cat" >nul 2>&1
powershell -Command "(Get-Content 'sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum') -replace '10\.0\.22621\.1','%VERSION%' | Set-Content 'sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum'" >nul 2>&1
powershell -Command "(Get-Content 'sxs\1.xml') -replace '10\.0\.22621\.1','%VERSION%' | Set-Content 'sxs\1.xml'" >nul 2>&1

if "%vNext%"=="True" (
    copy files\sxs\vNext\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum sxs\ >nul 2>&1
    ren "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum" "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum" >nul 2>&1
    powershell -Command "(Get-Content 'sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum') -replace '10\.0\.22621\.1','%VERSION%' | Set-Content 'sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum'" >nul 2>&1
)
echo.

:: Mount original install.wim
echo ● Mounting Image ●
dism /mount-wim /wimfile:install.wim /index:1 /mountdir:mount || exit /b 1 >nul 2>&1
echo.

:: Remove Professional Packages and add EnterpriseG Packages
echo ● Converting SKU ● 
dism /scratchdir:"%~dp0temp" /image:mount /apply-unattend:sxs\1.xml || exit /b 1 >nul 2>&1
echo.

:: Adding Language Pack
echo ● Adding Language Pack ● 
dism /scratchdir:"%~dp0temp" /image:mount /add-package:lp || exit /b 1 >nul 2>&1
echo.

del mount\Windows\*.xml >nul 2>&1
copy mount\Windows\servicing\Editions\EnterpriseGEdition.xml mount\Windows\EnterpriseG.xml >nul 2>&1
echo.

echo ● Setting SKU to EnterpriseG ● 
dism /scratchdir:"%~dp0temp" /image:mount /apply-unattend:mount\Windows\EnterpriseG.xml || exit /b 1 >nul 2>&1
dism /scratchdir:"%~dp0temp" /image:mount /set-productkey:YYVX9-NTFWV-6MDM3-9PT4T-4M68B || exit /b 1 >nul 2>&1
dism /scratchdir:"%~dp0temp" /image:mount /get-currentedition || exit /b 1 >nul 2>&1 
echo.

:: Load Registry Hive
echo ● Loading Registry Hive ● 
reg load HKLM\zNTUSER mount\Users\Default\ntuser.dat >nul 2>&1
reg load HKLM\zSOFTWARE mount\Windows\System32\config\SOFTWARE >nul 2>&1
reg load HKLM\zSYSTEM mount\Windows\System32\config\SYSTEM >nul 2>&1
reg load HKLM\zDEFAULT mount\Windows\System32\config\default >nul 2>&1
echo.

:: Apply Registry Keys to Registry Hive
echo ● Applying Registry Keys ● 
:: Add Microsoft Account support
reg Add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Accounts" /v "AllowMicrosoftAccountSignInAssistant" /t REG_DWORD /d "1" /f >nul 2>&1
:: Fix Windows Security
reg add "HKLM\zSYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f >nul 2>&1
:: Add Producer branding
reg add "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionSubManufacturer /t REG_SZ /d "Microsoft Corporation" /f
echo.

:: Unload Registry Hive
echo ● Unloading Registry Hive ● 
reg unload HKLM\zNTUSER >nul 2>&1
reg unload HKLM\zSOFTWARE >nul 2>&1
reg unload HKLM\zSYSTEM >nul 2>&1
reg unload HKLM\zDEFAULT >nul 2>&1
echo.

:: Add License to Image
echo ● Adding License/EULA ● 
mkdir mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG >nul 2>&1
copy files\License\license.rtf mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG\license.rtf >nul 2>&1
echo.

:: Save all Changes and unmount Image
echo ● Saving and unmounting Install.wim Image ● 
dism /unmount-wim /mountdir:mount /commit || exit /b 1 >nul 2>&1
echo.

:: Optimize new Install.wim Image
echo ● Optimizing Install.wim Image ● 
files\wimlib-imagex optimize install.wim >nul 2>&1
echo.

:: Set WIM infos
echo ● Setting WIM Infos ●
files\wimlib-imagex info install.wim 1 --image-property NAME="%Windows% EnterpriseG" --image-property DESCRIPTION="%Windows% EnterpriseG" --image-property FLAGS="EnterpriseG" --image-property DISPLAYNAME="%Windows% Enterprise G" --image-property DISPLAYDESCRIPTION="%Windows% Enterprise G" >nul 2>&1
echo.

:: If set to true, WIM will be compressed to ESD to save storage
if "%WimToESD%"=="True" (
    echo ● Converting WIM to ESD ●
    dism /Export-Image /SourceImageFile:install.wim /SourceIndex:1 /DestinationImageFile:install.esd /Compress:Recovery >nul 2>&1
    if exist install.wim del install.wim >nul 2>&1
)

:: Clean-Up - last final touches
if exist mount rmdir /s /q mount >nul 2>&1
if exist temp rmdir /s /q temp >nul 2>&1
if exist "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum" del "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.mum" >nul 2>&1
if exist "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.cat" del "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~%VERSION%.cat" >nul 2>&1
if exist "sxs\1.xml" del "sxs\1.xml" >nul 2>&1
echo.

:: Script end
echo ● EnterpriseG is ready ● 

pause
exit
