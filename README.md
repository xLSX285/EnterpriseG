![LSX presents](https://github.com/xLSX285/EnterpriseG/assets/129116755/4957cf9b-42fe-4e70-9a33-d3450cbc9a52)
<div align="center">

## [Download Latest Version](https://github.com/xLSX285/EnterpriseG/archive/refs/heads/main.zip)
</div>
<div align="center">
  <img src="https://github.com/xLSX285/EnterpriseG/assets/129116755/3f1a3925-ea56-408e-89d0-5e717712e6e6" alt="Image Description">
</div>

<div align="center">
  
# How to reconstruct Enterprise G
</div>

`Files required:`
- install.wim or ISO (No updates)
- Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
- Microsoft-Windows-Client-LanguagePack-Package... .esd

> .esd files are obtainable through **UUP Dump** or the [**releases**](https://github.com/xLSX285/EnterpriseG/releases) page.

`How to get started:`
1. Place all 3 files in the root directory of the script
2. Run **Build.ps1** and wait for the reconstruction to complete

> Make sure your machine can execute PS scripts. **Set-ExecutionPolicy RemoteSigned**
>
<div align="center">
  
# Config.json

</div>

## ActivateWindows

- `True`: Windows will be activated using KMS38 method
- `False`: Windows wont be activated `Default`

## WimToESD 

- `True`: install.wim image will be compressed to install.esd
- `False`: install.wim image wont be compressed `Default`

## RemoveEdge

- `True`: Microsoft Edge and WebView2 will be removed at setup complete `Default | Official`
- `False`: Microsoft Edge and WebView2 wont be removed

> I'm looking into removing it at image level in the future

## RemoveApps

- `True`: All specified inbox apps will be removed from the image
- `False`: Inbox apps wont be removed `Default`

## RemovePackages

- `True`: All specified packages will be removed from the image
- `False`: Packages wont be removed `Default`

## DisableFeatures

- `True`: All specified features will be disabled from the image
- `False`: Features wont be disabled `Default`

## ProvisionedPackagesToRemove

- List of inbox apps that will be removed if set to true

## WindowsPackagesToRemove

- List of packages that will be removed if set to true

## WindowsFeaturesToDisable

- List of features that will be removed if set to true
<div align="center">
  
# Known "issues" with Enterprise G
</div>

- Insider Preview builds require an ISO for in-place upgrades; Windows Update can't update them.
- Resetting Windows on older builds than 25398 will display an `OOBEEULA` error during setup. **[Fix](https://www.howto-connect.com/fix-oobeeula-error-something-went-wrong-windows-10-or-11/)**
- Resetting Windows removes registry keys for MS login support and more. **[Fix](https://pastebin.com/GXu8phAT)**
- Inplace upgrade fails on some builds of Windows (e.g 19041 -> 22000/22621.) fix needed.
  
<div align="center">
  
# Todo
</div>

- More script optimizations
- Option to automatically integrate updates
- Remove Edge at image level instead of at setup complete state
