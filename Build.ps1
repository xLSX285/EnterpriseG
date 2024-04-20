if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList " -NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs; exit }
$ScriptVersion = "v2.2.0"
[System.Console]::Title = "Enterprise G Reconstruction $ScriptVersion"
Set-Location -Path $PSScriptRoot

$requiredFiles = @("Microsoft-Windows-EditionSpecific*", "Microsoft-Windows-Client-LanguagePack*", "install.wim")
$missingFiles = $requiredFiles | Where-Object { -not (Test-Path $_) }

if ($missingFiles) { [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new(); $toastTemplate = "<toast><visual><binding template='ToastText02'><text id='1'>Reconstruction failed</text><text id='2'>Required files are missing: $($missingFiles -join ', ')</text></binding></visual></toast>"; $toastXml.LoadXml($toastTemplate); $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Enterprise G Reconstruction $ScriptVersion").Show($toast); Write-Host "Required files are missing: $($missingFiles -join ', ')"; pause; exit }

@("mount", "lp", "sxs", "iso\sources") | ForEach-Object { if (!(Test-Path $_ -PathType Container)) { New-Item -Path $_ -ItemType Directory -Force | Out-Null } }

Move-Item -Path "install.wim" -Destination "iso\sources\install.wim" | Out-Null

$imageInfo = Get-WindowsImage -ImagePath "iso\sources\install.wim" -index:1
$Windows = ($imageInfo.ImageName -split ' ')[1]
$ProIndex = Get-WindowsImage -ImagePath "iso\sources\install.wim" | Where-Object { $_.ImageName -eq "Windows $Windows Pro" } | Select-Object -ExpandProperty ImageIndex; if (-not $ProIndex) { [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new(); $toastTemplate = "<toast><visual><binding template='ToastText02'><text id='1'>Reconstruction failed</text><text id='2'>Install.wim does not appear to contain Pro edition.</text></binding></visual></toast>"; $toastXml.LoadXml($toastTemplate); $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Enterprise G Reconstruction $ScriptVersion").Show($toast); Write-Host "Install.wim does not appear to contain Pro edition."; @("mount", "lp", "sxs", "iso") | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }; pause; exit }
$Build = $imageInfo.Version
if ($imageInfo.SPBuild -notmatch "^(1|1000|1001|5001)$") { [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new(); $toastTemplate = "<toast><visual><binding template='ToastText02'><text id='1'>Reconstruction failed</text><text id='2'>Image contains updates. Updates should be added after reconstruction.</text></binding></visual></toast>"; $toastXml.LoadXml($toastTemplate); $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Enterprise G Reconstruction $ScriptVersion").Show($toast); Write-Host "Image contains updates. Updates should be added after reconstruction." ; @("mount", "lp", "sxs", "iso") | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }; pause ; exit }

$detectedBuild = [int]($Build -replace '1[0-9]\.\d+\.', '')
if ($detectedBuild -lt 19041) {
    $Type = "Legacy"
} elseif ($detectedBuild -lt 25398) {
    $Type = "Normal"
} else {
    $Type = "24H2"
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json
$ActivateWindows = $config.ActivateWindows
$RemoveEdge = $config.RemoveEdge
$yes = (cmd /c "choice <nul 2>nul")[1]
$startTime = Get-Date
Write-Host "Enterprise G Reconstruction $ScriptVersion"
Write-Host ""
Write-Host "- Windows: $Windows"
Write-Host "- Build: $Build"
Write-Host "- Type: $Type"
Write-Host ""
Write-Host "- ActivateWindows: $ActivateWindows"
Write-Host "- RemoveEdge: $RemoveEdge"
Write-Host ""

Write-Host ""
Write-Host "Extracting language pack & edition files"
if ($editionesd = (Get-ChildItem -Filter "Microsoft-Windows-EditionSpecific*.esd").Name) { Write-Host "- $editionesd"; .\files\wimlib-imagex extract .\$editionesd 1 --dest-dir=sxs | Out-Null }
if ($lpesd = (Get-ChildItem -Filter "Microsoft-Windows-Client-LanguagePack*.esd")) { Write-Host "- $($lpesd.Name)"; $lang = [System.IO.Path]::GetFileNameWithoutExtension($lpesd.Name).Substring($lpesd.Name.Length - 9, 5); .\files\wimlib-imagex extract $lpesd.FullName 1 --dest-dir=lp | Out-Null }
Write-Host ""

Write-Host ""
Write-Host "Mounting image"
Set-ItemProperty -Path "iso\sources\install.wim" -Name IsReadOnly -Value $false
dism /Mount-Wim /WimFile:"iso\sources\install.wim" /Index:$ProIndex /MountDir:"mount" | Out-Null
Write-Host "- install.wim"
Write-Host ""

if ($Type -in "Normal", "24H2", "Legacy") {
    Copy-Item -Path "files\sxs\$Type\*.*" -Destination "sxs\" -Force | Out-Null

    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum" -Force | Out-Null
    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.cat" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.cat" -Force | Out-Null

    (Get-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum") -replace '10\.0\.22621\.1', $Build | Set-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum" -Force | Out-Null
    (Get-Content "sxs\1.xml") -replace '10\.0\.22621\.1', $Build | Set-Content "sxs\1.xml" -Force | Out-Null
}

Write-Host ""
Write-Host "Converting edition"
dism /image:mount /apply-unattend:sxs\1.xml
Write-Host ""

Write-Host ""
Write-Host "Adding language pack"
dism /image:mount /add-package:lp
Write-Host ""
Remove-Item -Path mount\Windows\*.xml -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path mount\Windows\servicing\Editions\EnterpriseGEdition.xml -Destination mount\Windows\EnterpriseG.xml -ErrorAction SilentlyContinue | Out-Null

Write-Host ""
Write-Host "Setting edition to Enterprise G"
dism /image:mount /apply-unattend:mount\Windows\EnterpriseG.xml | Out-Null
dism /image:mount /set-productkey:YYVX9-NTFWV-6MDM3-9PT4T-4M68B | Out-Null
dism /image:mount /get-currentedition
Write-Host ""

Write-Host ""
Write-Host "Loading registry hive"
reg load HKLM\zSOFTWARE mount\Windows\System32\config\SOFTWARE | Out-Null
Write-Host "- zSOFTWARE"
reg load HKLM\zSYSTEM mount\Windows\System32\config\SYSTEM | Out-Null
Write-Host "- zSYSTEM"
Write-Host ""

Write-Host ""
Write-Host "Applying registry keys"

# Add Microsoft Account support
reg Add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Accounts" /v "AllowMicrosoftAccountSignInAssistant" /t REG_DWORD /d "1" /f | Out-Null
Write-Host "- Microsoft Account login suppport"
# Add Producer branding
reg add "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionSubManufacturer /t REG_SZ /d "Microsoft Corporation" /f | Out-Null
reg add "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionSubVersion /t REG_SZ /d "$ScriptVersion" /f | Out-Null
Write-Host "- Producer branding"
# Fix Windows Security
reg add "HKLM\zSYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f | Out-Null
Write-Host "- Fix Windows Defender service"
# Turn off Defender Updates
reg add "HKLM\zSOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "UpdateOnStartUp" /t REG_DWORD /d "0" /f | Out-Null
Write-Host "- Disable Defender updates"
Write-Host ""

Write-Host ""
Write-Host "Unloading registry hive"
reg unload HKLM\zSOFTWARE | Out-Null
Write-Host "- zSOFTWARE"
reg unload HKLM\zSYSTEM | Out-Null
Write-Host "- zSYSTEM"
Write-Host ""

Write-Host ""
Write-Host "Adding license"
if ($Type -eq "24H2") {
    takeown /f "mount\Windows\System32\$lang\Licenses\_Default\EnterpriseG\placeholder.rtf" | Out-Null
    icacls "mount\Windows\System32\$lang\Licenses\_Default\EnterpriseG\placeholder.rtf" /grant:r "$($env:USERNAME):(W)" | Out-Null
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\$lang\Licenses\_Default\EnterpriseG\placeholder.rtf" -Force | Out-Null
}
else {
    $licensePath = "mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG"; if (-not (Test-Path -Path $licensePath -PathType Container)) { New-Item -Path $licensePath -ItemType Directory -Force | Out-Null }
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG\license.rtf" -Force | Out-Null
}
Write-Host "- license.rtf"
Write-Host ""

if ($ActivateWindows -eq "True") {
    Write-Host ""
    New-Item -ItemType Directory -Path "mount\Windows\Setup\Scripts" -Force | Out-Null
    Copy-Item -Path "files\Scripts\SetupComplete.cmd" -Destination "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Force | Out-Null
    Write-Host "Adding activation for Windows"
    Copy-Item -Path "files\Scripts\activate_kms38.cmd" -Destination "mount\Windows\Setup\Scripts\activate_kms38.cmd" -Force | Out-Null
    Write-Host "- activate_kms38.cmd"
    Write-Host ""
}

if ($RemoveEdge -eq "True") {
    if ($detectedBuild -ge 22621) {
    Write-Host ""
    Write-Host "Removing Edge"
    reg load HKLM\zSOFTWARE mount\Windows\System32\config\SOFTWARE | Out-Null
    reg load HKLM\zSYSTEM mount\Windows\System32\config\SYSTEM | Out-Null
    if (Test-Path 'mount\Program Files (x86)\Microsoft' -Type Container) { Remove-Item 'mount\Program Files (x86)\Microsoft' -Recurse -Force | Out-Null }
    reg delete "HKLM\zSOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f | Out-Null
    reg delete "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MicrosoftEdgeUpdate.exe" /f | Out-Null
    reg delete "HKLM\zSOFTWARE\Wow6432Node\Microsoft\EdgeUpdate" /f | Out-Null
    reg delete "HKLM\zSOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f | Out-Null
    reg delete "HKLM\zSOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f | Out-Null
    reg delete "HKLM\zSOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView" /f | Out-Null
    reg add "HKLM\zSOFTWARE\Policies\Microsoft\EdgeUpdate" /v CreateDesktopShortcutDefault /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\zSOFTWARE\Policies\Microsoft\EdgeUpdate" /v RemoveDesktopShortcutDefault /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKLM\zSOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "DisableEdgeDesktopShortcutCreation" /t REG_DWORD /d "1" /f | Out-Null
    reg delete "HKLM\zSYSTEM\ControlSet001\Services\edgeupdate" /f | Out-Null
    reg delete "HKLM\zSYSTEM\ControlSet001\Services\edgeupdatem" /f | Out-Null
    reg unload HKLM\zSOFTWARE | Out-Null
    reg unload HKLM\zSYSTEM | Out-Null
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Removing Edge at setup complete"
    if (!(Test-Path "mount\Windows\Setup\Scripts" -Type Container)) {New-Item "mount\Windows\Setup\Scripts" -ItemType Directory -Force | Out-Null}
    if (!(Test-Path "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Type Leaf)) { Copy-Item "files\Scripts\SetupComplete.cmd" -Destination "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Force | Out-Null }
    Copy-Item -Path "files\Scripts\RemoveEdge.cmd" -Destination "mount\Windows\Setup\Scripts\RemoveEdge.cmd" -Force | Out-Null
    Write-Host "- RemoveEdge.cmd"
    Write-Host ""
}
}

Write-Host ""
Write-Host "Unmounting install.wim Image"
dism /unmount-wim /mountdir:mount /commit | Out-Null
Write-Host "- install.wim"
Write-Host ""

Write-Host ""
Write-Host "Optimizing install.wim Image"
& "files\wimlib-imagex" optimize iso\sources\install.wim
Write-Host ""

Write-Host ""
Write-Host "Setting WIM info"
& "files\wimlib-imagex" info iso\sources\install.wim $ProIndex --image-property NAME="Windows $Windows Enterprise G" --image-property DESCRIPTION="Windows $Windows Enterprise G" --image-property FLAGS="EnterpriseG" --image-property DISPLAYNAME="Windows $Windows Enterprise G" --image-property DISPLAYDESCRIPTION="Windows $Windows Enterprise G"
Write-Host ""

if (Test-Path "iso\sources\install.wim") { Move-Item -Path "iso\sources\install.wim" -Destination "install.wim" -Force | Out-Null }

@("mount", "lp", "sxs", "iso") | ForEach-Object { if (Test-Path $_ -ErrorAction SilentlyContinue) { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue | Out-Null } }

$endTime = Get-Date
$elapsedTime = $endTime - $startTime
$elapsedMinutes = [math]::Floor($elapsedTime.TotalMinutes)
$elapsedSeconds = $elapsedTime.Seconds

Write-Host ""
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new(); $toastTemplate = "<toast><visual><binding template='ToastText02'><text id='1'>Reconstruction successful</text><text id='2'>Completed in $($elapsedMinutes) minutes and $($elapsedSeconds) seconds.</text></binding></visual></toast>"; $toastXml.LoadXml($toastTemplate); $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Enterprise G Reconstruction $ScriptVersion").Show($toast)
Write-Host "Reconstruction completed in $($elapsedMinutes) minutes and $($elapsedSeconds) seconds."
Write-Host ""
pause
exit