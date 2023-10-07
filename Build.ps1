if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { Start-Process powershell.exe -ArgumentList " -NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs; exit }

$startTime = Get-Date
Set-Location -Path $PSScriptRoot

$requiredFiles = @("install.wim", "Microsoft-Windows-EditionSpecific*", "Microsoft-Windows-Client-LanguagePack*")
$missingFiles = $requiredFiles | Where-Object { -not (Test-Path $_) }

if ($missingFiles) {
    Write-Host "Required files are missing: $($missingFiles -join ', ')"
    pause
    exit 1
}

$imageInfo = Get-WindowsImage -ImagePath "install.wim" -Index 1
$Windows = ($imageInfo.ImageName -split ' ')[1]
$Build = $imageInfo.Version
$allowedSPBuilds = @(1, 1000, 1001)
if ($imageInfo.SPBuild -notin $allowedSPBuilds) {
    Write-Host "Mounted image contains updates. Updates should be added after reconstruction."
    pause
    exit 1
}
if ($imageInfo.ImageName -notlike "*Pro*") {
    Write-Host "Mounted image does not appear to be the Pro Edition."
    pause
    exit 1
}
$detectBuildType = [int]($Build -replace '1[0-9]\.\d+\.', '')
if ($detectBuildType -lt 19041) {
    $Type = "Legacy"
} elseif ($detectBuildType -lt 25398) {
    $Type = "Normal"
} else {
    $Type = "vNext"
}

$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json
$ActivateWindows = $config.ActivateWindows
$WimToESD = $config.WimToESD
$RemoveEdge = $config.RemoveEdge
$RemoveApps = $config.RemoveApps
$unwantedProvisionedPackages = $config.ProvisionedPackagesToRemove
$AppCount = $unwantedProvisionedPackages.Count
$RemovePackages = $config.RemovePackages
$unwantedWindowsPackages = $config.WindowsPackagesToRemove
$PackageCount = $unwantedWindowsPackages.Count
$DisableFeatures = $config.DisableFeatures
$unwantedWindowsFeatures = $config.WindowsFeaturesToDisable
$FeatureCount = $unwantedWindowsFeatures.Count
$yes = (cmd /c "choice <nul 2>nul")[1]

Write-Host "Enterprise G Reconstruction v2.0.3"
Write-Host ""
Write-Host "Loading configuration"
Write-Host "- Windows: $Windows"
Write-Host "- Build: $Build"
Write-Host "- Type: $Type"
Write-Host "- ActivateWindows: $ActivateWindows"
Write-Host "- WimToESD: $WimToESD"
Write-Host "- RemoveEdge: $RemoveEdge"
Write-Host "- RemoveApps: $RemoveApps" [$AppCount Apps detected]
Write-Host "- RemovePackages: $RemovePackages" [$PackageCount Packages detected]
Write-Host "- DisableFeatures: $DisableFeatures" [$FeatureCount Features detected]
Write-Host ""

@("mount", "lp", "sxs") | ForEach-Object { if (!(Test-Path $_ -PathType Container)) { New-Item -Path $_ -ItemType Directory | Out-Null } }

Write-Host ""
Write-Host "Extracting language pack & Edition files"
if ($editionesd = (Get-ChildItem -Filter "Microsoft-Windows-EditionSpecific*.esd").Name) { Write-Host "- $editionesd"; .\files\7z.exe x $editionesd -osxs | Out-Null }
if ($lpesd = (Get-ChildItem -Filter "Microsoft-Windows-Client-LanguagePack*.esd").Name) { Write-Host "- $lpesd"; .\files\7z.exe x $lpesd -olp | Out-Null }
Write-Host ""

Write-Host ""
Write-Host "Mounting Image"
dism /mount-wim /wimfile:install.wim /index:1 /mountdir:mount | Out-Null
Write-Host "- install.wim"
Write-Host ""

if ($Type -in "Normal", "vNext", "Legacy") {
    Copy-Item -Path "files\sxs\$Type\*.*" -Destination "sxs\" -Force | Out-Null

    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum" -Force | Out-Null
    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.cat" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.cat" -Force | Out-Null

    (Get-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum") -replace '10\.0\.22621\.1', $Build | Set-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~$Build.mum" -Force | Out-Null
    (Get-Content "sxs\1.xml") -replace '10\.0\.22621\.1', $Build | Set-Content "sxs\1.xml" -Force | Out-Null
}

Write-Host ""
Write-Host "Converting SKU"
dism /image:mount /apply-unattend:sxs\1.xml
Write-Host ""

Write-Host ""
Write-Host "Adding Language Pack"
dism /image:mount /add-package:lp
Write-Host ""
Remove-Item -Path mount\Windows\*.xml -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path mount\Windows\servicing\Editions\EnterpriseGEdition.xml -Destination mount\Windows\EnterpriseG.xml -ErrorAction SilentlyContinue | Out-Null

Write-Host ""
Write-Host "Setting SKU to EnterpriseG"
dism /image:mount /apply-unattend:mount\Windows\EnterpriseG.xml | Out-Null
dism /image:mount /set-productkey:YYVX9-NTFWV-6MDM3-9PT4T-4M68B | Out-Null
dism /image:mount /get-currentedition
Write-Host ""

Write-Host ""
Write-Host "Loading Registry Hive"
reg load HKLM\zSOFTWARE mount\Windows\System32\config\SOFTWARE | Out-Null
Write-Host "- zSOFTWARE"
reg load HKLM\zSYSTEM mount\Windows\System32\config\SYSTEM | Out-Null
Write-Host "- zSYSTEM"
Write-Host ""

Write-Host ""
Write-Host "Applying Registry Keys"

# Add Microsoft Account support
reg Add "HKLM\zSOFTWARE\Microsoft\PolicyManager\current\device\Accounts" /v "AllowMicrosoftAccountSignInAssistant" /t REG_DWORD /d "1" /f | Out-Null
Write-Host "- MSA login suppport"
# Add Producer branding
reg add "HKLM\zSOFTWARE\Microsoft\Windows NT\CurrentVersion" /v EditionSubManufacturer /t REG_SZ /d "Microsoft Corporation" /f | Out-Null
Write-Host "- Producer branding"
# Fix Windows Security
reg add "HKLM\zSYSTEM\ControlSet001\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d 0 /f | Out-Null
Write-Host "- Fix Windows Defender Service"
# Turn off Defender Updates
reg add "HKLM\zSOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f | Out-Null
reg add "HKLM\zSOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "UpdateOnStartUp" /t REG_DWORD /d "0" /f | Out-Null
Write-Host "- Disable Defender Updates"
Write-Host ""

Write-Host ""
Write-Host "Unloading Registry Hive"
reg unload HKLM\zSOFTWARE | Out-Null
Write-Host "- zSOFTWARE"
reg unload HKLM\zSYSTEM | Out-Null
Write-Host "- zSYSTEM"
Write-Host ""

Write-Host ""
Write-Host "Adding License/EULA"
if ($Type -eq "vNext") {
    Write-Host "- Directory mount\Windows\System32\en-US\Licenses\_Default\EnterpriseG"
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\en-US\Licenses\_Default\EnterpriseG\license.rtf" -Force | Out-Null
}
else {
    Write-Host "- Directory mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG"
    Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG\license.rtf" -Force | Out-Null
}
Write-Host "- license.rtf"
Write-Host ""

if ($ActivateWindows -eq "True") {
	Write-Host ""
    Write-Host "Adding activation for Windows using KMS38"
    $null = New-Item -ItemType Directory -Path "mount\Windows\Setup\Scripts" -Force | Out-Null
    Copy-Item -Path "files\Scripts\activate_kms38.cmd" -Destination "mount\Windows\Setup\Scripts\activate_kms38.cmd" -Force | Out-Null
	Write-Host "- activate_kms38.cmd"
    Copy-Item -Path "files\Scripts\SetupComplete.cmd" -Destination "mount\Windows\Setup\Scripts\SetupComplete.cmd" -Force | Out-Null
	Write-Host "- SetupComplete.cmd"
	Write-Host ""
}

if ($RemoveApps -eq "True") {
    Write-Host ""
	Write-Host "Removing inbox apps"
	$detectedProvisionedPackages = Get-AppxProvisionedPackage -Path "mount\"

	foreach ($detectedProvisionedPackage in $detectedProvisionedPackages) {
		foreach ($unwantedProvisionedPackage in $unwantedProvisionedPackages) {
			if ($detectedProvisionedPackage.PackageName.Contains($unwantedProvisionedPackage)) {
				Remove-AppxProvisionedPackage -Path "mount\" -PackageName $detectedProvisionedPackage.PackageName -ErrorAction SilentlyContinue | Out-Null
			}
		}
	}
    Write-Host ""
}

if ($RemovePackages -eq "True") {
    Write-Host ""
	Write-Host "Removing packages"
	$detectedWindowsPackages = Get-WindowsPackage -Path "mount\"

	foreach ($detectedWindowsPackage in $detectedWindowsPackages) {
		foreach ($unwantedWindowsPackage in $unwantedWindowsPackages) {
			if ($detectedWindowsPackage.PackageName.Contains($unwantedWindowsPackage)) {
				Remove-WindowsPackage -Path "mount\" -PackageName $detectedWindowsPackage.PackageName -ErrorAction SilentlyContinue | Out-Null
			}
		}
	}
    Write-Host ""
}

if ($DisableFeatures -eq "True") {
    Write-Host ""
	Write-Host "Disabling features"
	$detectedWindowsFeatures = Get-WindowsOptionalFeature -Path "mount\"

	foreach ($detectedWindowsFeature in $detectedWindowsFeatures) {
		foreach ($unwantedWindowsFeature in $unwantedWindowsFeatures) {
			if ($detectedWindowsFeature.FeatureName.Contains($unwantedWindowsFeature)) {
				Disable-WindowsOptionalFeature -Path "mount\" -FeatureName $detectedWindowsFeature.FeatureName -ErrorAction SilentlyContinue | Out-Null
			}
		}
	}
    Write-Host ""
}

Write-Host ""
Write-Host "Unmounting Install.wim Image"
dism /unmount-wim /mountdir:mount /commit | Out-Null
Write-Host "- install.wim"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host ""

Write-Host ""
Write-Host "Optimizing Install.wim Image"
& "files\wimlib-imagex" optimize install.wim
Write-Host ""

Write-Host ""
Write-Host "Setting WIM Infos"
& "files\wimlib-imagex" info install.wim 1 --image-property NAME="Windows $Windows Enterprise G" --image-property DESCRIPTION="Windows $Windows Enterprise G" --image-property FLAGS="EnterpriseG" --image-property DISPLAYNAME="Windows $Windows Enterprise G" --image-property DISPLAYDESCRIPTION="Windows $Windows Enterprise G"
Write-Host ""

if ($WimToESD -eq "True") {
    Write-Host ""
    Write-Host "Converting WIM to ESD"
    dism /Export-Image /SourceImageFile:install.wim /SourceIndex:1 /DestinationImageFile:install.esd /Compress:Recovery | Out-Null
    Write-Host "- Install.wim -> Install.esd"
    if (Test-Path "install.wim") { Remove-Item "install.wim" | Out-Null }
    Write-Host ""
}

@("mount", "lp", "sxs") | ForEach-Object { if (Test-Path $_) { Remove-Item $_ -Recurse -Force | Out-Null } }

$endTime = Get-Date
$elapsedTime = $endTime - $startTime
$elapsedMinutes = [math]::Floor($elapsedTime.TotalMinutes)
$elapsedSeconds = $elapsedTime.Seconds
Write-Host ""
Write-Host "Enterprise G completed in $($elapsedMinutes) minutes and $($elapsedSeconds) seconds."
Write-Host ""
pause
exit
