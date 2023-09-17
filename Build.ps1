$startTime = Get-Date
Set-Location -Path $PSScriptRoot

# Script config
$Windows = "Windows 11"
$Build = "22621.1"
$Type = "Normal"
$WimToESD = "False"
$RemoveApps = "False"
$RemovePackages = "False"
$DisableFeatures = "False"
Write-Host "----------------------------------------------"
Write-Output "Loading configuration"
Write-Output "- Windows: $Windows"
Write-Output "- Build: $Build"
Write-Output "- Type: $Type"
Write-Output "- WimToESD: $WimToESD"
Write-Output "- RemoveApps: $RemoveApps"
Write-Output "- RemovePackages: $RemovePackages"
Write-Output "- DisableFeatures: $DisableFeatures"
Write-Host "- Successfully loaded config.json"
$config = (Get-Content "config.json" -Raw) | ConvertFrom-Json
$unwantedProvisionnedPackages = $config.ProvisionnedPackagesToRemove
$unwantedWindowsPackages = $config.WindowsPackagesToRemove
$unwantedWindowsFeatures = $config.WindowsFeaturesToDisable
Write-Host ""
Write-Output "Creating variables"
$installImageFolder = "mount\"
$SourcePath = "files\sxs\$Type\*.*"
$DestinationPath = "sxs\"
$yes = (cmd /c "choice <nul 2>nul")[1]
Write-Host "- installImageFolder: $InstallImageFolder"
Write-Host "- SourcePath: $SourcePath"
Write-Host "- DestinationPath: $DestinationPath"
Write-Host "----------------------------------------------"
Write-Host ""

if (!(Test-Path -Path "mount" -PathType Container)) {
    New-Item -Path "mount" -ItemType Directory | Out-Null
}

Write-Host "----------------------------------------------"
Write-Host "Mounting Image"
dism /mount-wim /wimfile:install.wim /index:1 /mountdir:mount | Out-Null
Write-Host "- install.wim"
Write-Host "----------------------------------------------"
Write-Host ""

if ($Type -in "Normal", "vNext", "Legacy") {
    Copy-Item -Path $SourcePath -Destination $DestinationPath -Force | Out-Null

    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.mum" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.mum" -Force | Out-Null
    Rename-Item -Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.22621.1.cat" -NewName "Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.cat" -Force | Out-Null

    (Get-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.mum") -replace '22621\.1', $Build | Set-Content "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.mum" -Force | Out-Null
    (Get-Content "sxs\1.xml") -replace '22621\.1', $Build | Set-Content "sxs\1.xml" -Force | Out-Null
}

# Update Packages
Write-Host "----------------------------------------------"
Write-Host "Converting SKU"
dism /image:mount /apply-unattend:sxs\1.xml
Write-Host "----------------------------------------------"
Write-Host ""

# Adding Language Pack
Write-Host "----------------------------------------------"
Write-Host "Adding Language Pack"
dism /image:mount /add-package:lp
Write-Host "----------------------------------------------"
Write-Host ""
Remove-Item -Path mount\Windows\*.xml -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path mount\Windows\servicing\Editions\EnterpriseGEdition.xml -Destination mount\Windows\EnterpriseG.xml -ErrorAction SilentlyContinue | Out-Null

Write-Host "----------------------------------------------"
Write-Host "Setting SKU to EnterpriseG"
dism /image:mount /apply-unattend:mount\Windows\EnterpriseG.xml | Out-Null
dism /image:mount /set-productkey:YYVX9-NTFWV-6MDM3-9PT4T-4M68B | Out-Null
dism /image:mount /get-currentedition
Write-Host "----------------------------------------------"
Write-Host ""

# Load Registry Hive
Write-Host "----------------------------------------------"
Write-Host "Loading Registry Hive"
reg load HKLM\zSOFTWARE mount\Windows\System32\config\SOFTWARE | Out-Null
Write-Host "- zSOFTWARE"
reg load HKLM\zSYSTEM mount\Windows\System32\config\SYSTEM | Out-Null
Write-Host "- zSYSTEM"
Write-Host "----------------------------------------------"
Write-Host ""

# Apply Registry Keys to Registry Hive
Write-Host "----------------------------------------------"
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
Write-Host "----------------------------------------------"
Write-Host ""

# Unload Registry Hive
Write-Host "----------------------------------------------"
Write-Host "Unloading Registry Hive"
reg unload HKLM\zSOFTWARE | Out-Null
Write-Host "- zSOFTWARE"
reg unload HKLM\zSYSTEM | Out-Null
Write-Host "- zSYSTEM"
Write-Host "----------------------------------------------"
Write-Host ""

# Add License to Image
Write-Host "----------------------------------------------"
Write-Host "Adding License/EULA"
mkdir mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG -ErrorAction SilentlyContinue | Out-Null
Write-Host "- New directory mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG"
Copy-Item -Path "files\License\license.rtf" -Destination "mount\Windows\System32\Licenses\neutral\_Default\EnterpriseG\license.rtf" -Force | Out-Null
Write-Host "- license.rtf"
Write-Host "----------------------------------------------"
Write-Host ""

if ($RemoveApps -eq "True") {
    Write-Host "----------------------------------------------"
#Detecting provisionned app packages
	Write-Output "Removing inbox apps"
	$detectedProvisionnedPackages = Get-AppxProvisionedPackage -Path $installImageFolder

	#Removing unwanted provisionned app packages
	foreach ($detectedProvisionnedPackage in $detectedProvisionnedPackages) {
		foreach ($unwantedProvisionnedPackage in $unwantedProvisionnedPackages) {
			if ($detectedProvisionnedPackage.PackageName.Contains($unwantedProvisionnedPackage)) {
				Remove-AppxProvisionedPackage -Path $installImageFolder -PackageName $detectedProvisionnedPackage.PackageName -ErrorAction SilentlyContinue | Out-Null
			}
		}
	}
    Write-Host "----------------------------------------------"
    Write-Host ""
}

if ($RemovePackages -eq "True") {
    Write-Host "----------------------------------------------"
	#Detecting windows packages
	Write-Output "Removing packages"
	$detectedWindowsPackages = Get-WindowsPackage -Path $installImageFolder

	#Removing unwanted windows packages
	foreach ($detectedWindowsPackage in $detectedWindowsPackages) {
		foreach ($unwantedWindowsPackage in $unwantedWindowsPackages) {
			if ($detectedWindowsPackage.PackageName.Contains($unwantedWindowsPackage)) {
				Remove-WindowsPackage -Path $installImageFolder -PackageName $detectedWindowsPackage.PackageName -ErrorAction SilentlyContinue | Out-Null
			}
		}
	}
    Write-Host "----------------------------------------------"
    Write-Host ""
}

if ($DisableFeatures -eq "True") {
    Write-Host "----------------------------------------------"
    #Detecting windows features
	Write-Output "Disabling features"
	$detectedWindowsFeatures = Get-WindowsOptionalFeature -Path $installImageFolder

	#Removing unwanted windows features
	foreach ($detectedWindowsFeature in $detectedWindowsFeatures) {
		foreach ($unwantedWindowsFeature in $unwantedWindowsFeatures) {
			if ($detectedWindowsFeature.FeatureName.Contains($unwantedWindowsFeature)) {
				Disable-WindowsOptionalFeature -Path $installImageFolder -FeatureName $detectedWindowsFeature.FeatureName -ErrorAction SilentlyContinue | Out-Null
			}
		}
	}
    Write-Host "----------------------------------------------"
    Write-Host ""
}

# Save all Changes and unmount Image
Write-Host "----------------------------------------------"
Write-Host "Unmounting Install.wim Image"
dism /unmount-wim /mountdir:mount /commit | Out-Null
Write-Host "- install.wim"
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "----------------------------------------------"
Write-Host ""

# Optimize new Install.wim Image
Write-Host "----------------------------------------------"
Write-Host "Optimizing Install.wim Image"
& "files\wimlib-imagex" optimize install.wim
Write-Host "----------------------------------------------"
Write-Host ""

# Set WIM infos
Write-Host "----------------------------------------------"
Write-Host "Setting WIM Infos"
Write-Host ""
& "files\wimlib-imagex" info install.wim 1 --image-property NAME="$Windows EnterpriseG" --image-property DESCRIPTION="$Windows EnterpriseG" --image-property FLAGS="EnterpriseG" --image-property DISPLAYNAME="$Windows Enterprise G" --image-property DISPLAYDESCRIPTION="$Windows Enterprise G" | Out-Null
Write-Host "Name: $Windows EnterpriseG"
Write-Host "Description: $Windows EnterpriseG"
Write-Host "Flag: EnterpriseG"
Write-Host "Display name: $Windows EnterpriseG"
Write-Host "Display description: $Windows EnterpriseG"
Write-Host "----------------------------------------------"
Write-Host ""

# If set to true, WIM will be compressed to ESD to reduce size
if ($WimToESD -eq "True") {
    Write-Host "----------------------------------------------"
    Write-Host "Converting WIM to ESD"
    dism /Export-Image /SourceImageFile:install.wim /SourceIndex:1 /DestinationImageFile:install.esd /Compress:Recovery | Out-Null
    Write-Host "- Install.wim -> Install.esd"
    if (Test-Path "install.wim") { Remove-Item "install.wim" | Out-Null }
    Write-Host "----------------------------------------------"
    Write-Host ""
}

# Clean-Up - last final touches
if (Test-Path "mount") { Remove-Item "mount" -Recurse -Force | Out-Null }
if (Test-Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.mum") { Remove-Item "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.mum" | Out-Null }
if (Test-Path "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.cat") { Remove-Item "sxs\Microsoft-Windows-EnterpriseGEdition~31bf3856ad364e35~amd64~~10.0.$Build.cat" | Out-Null }
if (Test-Path "sxs\1.xml") { Remove-Item "sxs\1.xml" | Out-Null }
Write-Host ""

# Script end
$endTime = Get-Date
$elapsedTime = $endTime - $startTime
Write-Host "----------------------------------------------"
Write-Host "EnterpriseG completed in $($elapsedTime.TotalSeconds) seconds."
Write-Host "----------------------------------------------"
Write-Host ""