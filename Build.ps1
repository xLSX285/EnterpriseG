if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList " -NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs; exit }
$ScriptVersion = "v2.3.3"
[System.Console]::Title = "Enterprise G Reconstruction $ScriptVersion"
Set-Location -Path $PSScriptRoot

$requiredWIM = @("install.wim")
$missingWIM = $requiredWIM | Where-Object { -not (Test-Path $_) }
if ($missingWIM) { [System.Media.SystemSounds]::Asterisk.Play(); Write-Host "$([char]0x1b)[48;2;255;0;0m=== Install.wim could not be found."; pause; exit }

$imageInfo = Get-WindowsImage -ImagePath "install.wim" -index:1
$Build = $imageInfo.Version
$detectedBuild = [int]($Build -replace '1[0-9]\.\d+\.', '')

function Download-Files {
    param (
        [string]$buildUri,
        [string]$editionUri
    )
    $webClient = New-Object Net.WebClient
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== Downloading Language Pack"
    Write-Host
    $webClient.DownloadFile($buildUri, "$PSScriptRoot\Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd")
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== Downloading Edition Files"
    $webClient.DownloadFile($editionUri, "$PSScriptRoot\Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD")
    cls 
}

switch ($detectedBuild) {
    26100 { Download-Files "https://github.com/xLSX285/EnterpriseG/releases/download/24H2_Windows11/Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd" "https://github.com/xLSX285/EnterpriseG/releases/download/24H2_Windows11/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" }
    22621 { Download-Files "https://github.com/xLSX285/EnterpriseG/releases/download/22H2-23H2_Win11/Microsoft-Windows-Client-LanguagePack-Package_en-us-amd64-en-us.esd" "https://github.com/xLSX285/EnterpriseG/releases/download/22H2-23H2_Win11/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" }
    22000 { Download-Files "https://github.com/xLSX285/EnterpriseG/releases/download/21H2_Win11/Microsoft-Windows-Client-LanguagePack-Package_en-us-amd64-en-us.esd" "https://github.com/xLSX285/EnterpriseG/releases/download/21H2_Win11/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" }
    19041 { Download-Files "https://github.com/xLSX285/EnterpriseG/releases/download/2004-22H2_Win10/Microsoft-Windows-Client-LanguagePack-Package_en-us-amd64-en-us.esd" "https://github.com/xLSX285/EnterpriseG/releases/download/2004-22H2_Win10/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" }
    17763 { Download-Files "https://github.com/xLSX285/EnterpriseG/releases/download/1809_Win10/Microsoft-Windows-Client-LanguagePack-Package_en-US-AMD64-en-us.esd" "https://github.com/xLSX285/EnterpriseG/releases/download/1809_Win10/Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD" }
    default {
        Write-Host "$([char]0x1b)[48;2;255;0;0m=== Add language pack and edition specific ESD files to continue - press any Key when done."
        Write-Host
    }
}

$requiredFiles = @("Microsoft-Windows-EditionSpecific*", "Microsoft-Windows-Client-LanguagePack*")
$missingFiles = $requiredFiles | Where-Object { -not (Test-Path $_) }
if ($missingFiles) { [System.Media.SystemSounds]::Asterisk.Play(); Write-Host "$([char]0x1b)[48;2;255;0;0m=== Required files are missing: $($missingFiles -join ', ')"; pause; exit }

@("mount", "sxs") | ForEach-Object { if (!(Test-Path $_ -PathType Container)) { New-Item -Path $_ -ItemType Directory -Force | Out-Null } }

$Windows = ($imageInfo.ImageName -split ' ')[1]
$ProIndex = Get-WindowsImage -ImagePath "install.wim" | Where-Object { $_.ImageName -eq "Windows $Windows Pro" } | Select-Object -ExpandProperty ImageIndex; if (-not $ProIndex) {  Write-Host "$([char]0x1b)[48;2;255;0;0m=== Install.wim does not contain Windows Pro Edition/SKU."; @("mount", "sxs") | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }; pause; exit }
if ($imageInfo.SPBuild -notmatch "^(1|1000|1001|5001)$") { [System.Media.SystemSounds]::Asterisk.Play(); Write-Host "$([char]0x1b)[48;2;255;0;0m=== Your Install.wim contains updates. You must provide one without." ; @("mount", "sxs") | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }; pause ; exit }

switch ($detectedBuild) {
    { $_ -lt 19041 } { $Type = "Legacy"; break }
    { $_ -lt 25398 } { $Type = "Normal"; break }
    default { $Type = "24H2" }
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json
$ActivateWindows = $config.ActivateWindows
$RemoveEdge = $config.RemoveEdge
$startTime = Get-Date
Write-Host "Enterprise G Reconstruction $ScriptVersion"
Write-Host
Write-Host "- Windows: $Windows"
Write-Host "- Build: $Build"
Write-Host "- Type: $Type"
Write-Host
Write-Host "- ActivateWindows: $ActivateWindows"
Write-Host "- RemoveEdge: $RemoveEdge"
Write-Host

Write-Host
Write-Host "$([char]0x1b)[48;2;20;14;136m=== Preparing Files"
$editionesd = (Get-ChildItem -Filter "Microsoft-Windows-EditionSpecific*.esd").Name
.\files\wimlib-imagex extract .\$editionesd 1 --dest-dir=sxs | Out-Null
Remove-Item -Path .\$editionesd
$lpesd = (Get-ChildItem -Filter "Microsoft-Windows-Client-LanguagePack*.esd")
Move-Item -Path $lpesd.FullName -Destination .\sxs\ | Out-Null

Write-Host
Write-Host "$([char]0x1b)[48;2;20;14;136m=== Mounting Image"
Set-ItemProperty -Path "install.wim" -Name IsReadOnly -Value $false | Out-Null
dism /Mount-Wim /WimFile:"install.wim" /Index:$ProIndex /MountDir:"mount" | Out-Null

if ($Type -in "Normal", "24H2", "Legacy") {
    Copy-Item -Path "files\sxs\$Type\*.*" -Destination "sxs\" -Force

    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum" -Force
    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.cat" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.cat" -Force

    (Get-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum") -replace '10\.0\.22621\.1', $Build | Set-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum" -Force
    (Get-Content "sxs\1.xml") -replace '10\.0\.22621\.1', $Build | Set-Content "sxs\1.xml" -Force
}

Write-Host
Write-Host "$([char]0x1b)[48;2;20;14;136m=== Converting Edition"
dism /image:mount /apply-unattend:sxs\1.xml | Out-Null
Remove-Item -Path mount\Windows\*.xml -ErrorAction SilentlyContinue
Copy-Item -Path mount\Windows\servicing\Editions\EnterpriseGEdition.xml -Destination mount\Windows\EnterpriseG.xml -ErrorAction SilentlyContinue

Write-Host
Write-Host "$([char]0x1b)[48;2;20;14;136m=== Setting SKU to Enterprise G"
dism /image:mount /apply-unattend:mount\Windows\EnterpriseG.xml | Out-Null
if ($Type -eq "24H2") {
    Dism /Image:mount /Set-Edition:EnterpriseG /AcceptEula /ProductKey:FV469-WGNG4-YQP66-2B2HY-KD8YX | Out-Null
} else {
    Dism /Image:mount /Set-Edition:EnterpriseG /AcceptEula /ProductKey:YYVX9-NTFWV-6MDM3-9PT4T-4M68B | Out-Null
}
$currentEdition = (dism /image:mount /get-currentedition | Out-String)

if ($currentEdition -match "Current Edition : EnterpriseG") {
    Write-Host
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== SKU successfully updated to EnterpriseG"
} else {
    Write-Host
    Write-Host "$([char]0x1b)[48;2;255;0;0m=== Reconstruction failed. Undoing changes..."
    Write-Host
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== Unmounting Install.wim"
    dism /unmount-wim /mountdir:mount /discard | Out-Null
    Write-Host
    @("mount", "sxs") | ForEach-Object { if (Test-Path $_ -ErrorAction SilentlyContinue) { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue } }
    pause
    exit
}

Write-Host
Write-Host "$([char]0x1b)[48;2;20;14;136m=== Applying Registry Keys"
reg load HKLM\zSOFTWARE mount\Windows\System32\config\SOFTWARE | Out-Null
reg load HKLM\zSYSTEM mount\Windows\System32\config\SYSTEM | Out-Null
# Microsoft Account support
reg Add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Accounts" /v "AllowMicrosoftAccountSignInAssistant" /t REG_DWORD /d "1" /f | Out-Null
# Producer branding
reg add "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionSubManufacturer /t REG_SZ /d "Microsoft Corporation" /f | Out-Null
reg add "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionSubVersion /t REG_SZ /d "$ScriptVersion" /f | Out-Null
# Fix Windows Security
reg add "HKLM\zSYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f | Out-Null
# Turn off Defender Updates
reg add "HKLM\zSOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "UpdateOnStartUp" /t REG_DWORD /d "0" /f | Out-Null
reg unload HKLM\zSOFTWARE | Out-Null
reg unload HKLM\zSYSTEM | Out-Null

Write-Host
Write-Host "$([char]0x1b)[48;2;20;14;136m=== Adding License"
if ($Type -eq "24H2") {
    takeown /f "mount\Windows\System32\en-US\Licenses\_Default\EnterpriseG\placeholder.rtf" | Out-Null 
    icacls "mount\Windows\System32\en-US\Licenses\_Default\EnterpriseG\placeholder.rtf" /grant:r "$($env:USERNAME):(W)" | Out-Null
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\en-US\Licenses\_Default\EnterpriseG\placeholder.rtf" -Force | Out-Null
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\en-US\Licenses\_Default\EnterpriseG\license.rtf" -Force | Out-Null
    Write-Host
}
else {
    $licensePath = "mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG"; if (-not (Test-Path -Path $licensePath -PathType Container)) { New-Item -Path $licensePath -ItemType Directory -Force }
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG\license.rtf" -Force | Out-Null
Write-Host
}

if ($ActivateWindows -eq "True") {
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== Adding Activation Script for Windows"
    New-Item -ItemType Directory -Path "mount\Windows\Setup\Scripts" -Force | Out-Null
    Copy-Item -Path "files\Scripts\SetupComplete.cmd" -Destination "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Force
    Copy-Item -Path "files\Scripts\activate_kms38.cmd" -Destination "mount\Windows\Setup\Scripts\activate_kms38.cmd" -Force
    Write-Host
}

if ($RemoveEdge -eq "True") {
    if ($detectedBuild -ge 22621) {
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== Removing Microsoft Edge"
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
    Write-Host
} else {
    Write-Host "$([char]0x1b)[48;2;20;14;136m=== Removing Microsoft Edge on Setup Complete"
    if (!(Test-Path "mount\Windows\Setup\Scripts" -Type Container)) {New-Item "mount\Windows\Setup\Scripts" -ItemType Directory -Force | Out-Null }
    if (!(Test-Path "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Type Leaf)) { Copy-Item "files\Scripts\SetupComplete.cmd" -Destination "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Force | Out-Null }
    Copy-Item -Path "files\Scripts\RemoveEdge.cmd" -Destination "mount\Windows\Setup\Scripts\RemoveEdge.cmd" -Force | Out-Null
    Write-Host
}
}

Write-Host "$([char]0x1b)[48;2;20;14;136m=== Resetting Base"
Dism /Image:mount /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
Write-Host

Write-Host "$([char]0x1b)[48;2;20;14;136m=== Unmounting Install.wim"
dism /unmount-wim /mountdir:mount /commit | Out-Null
Write-Host

Write-Host "$([char]0x1b)[48;2;20;14;136m=== Optimizing Install.wim"
& "files\wimlib-imagex" optimize install.wim | Out-Null
Write-Host

Write-Host "$([char]0x1b)[48;2;20;14;136m=== Setting WIM Infos and Flags"
& "files\wimlib-imagex" info install.wim $ProIndex --image-property NAME="Windows $Windows Enterprise G" --image-property DESCRIPTION="Windows $Windows Enterprise G" --image-property FLAGS="EnterpriseG" --image-property DISPLAYNAME="Windows $Windows Enterprise G" --image-property DISPLAYDESCRIPTION="Windows $Windows Enterprise G" | Out-Null
Write-Host

@("mount", "sxs") | ForEach-Object { if (Test-Path $_ -ErrorAction SilentlyContinue) { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue } }
$endTime = Get-Date
$elapsedTime = $endTime - $startTime

[System.Media.SystemSounds]::Asterisk.Play()
Write-Host
Write-Host "$([char]0x1b)[48;2;0;128;0m=== Reconstruction completed in $([math]::Floor($elapsedTime.TotalMinutes)) minutes and $($elapsedTime.Seconds) seconds ==="
Write-Host
pause
exit
