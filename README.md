![LSX presents](https://github.com/xLSX285/EnterpriseG/assets/129116755/4957cf9b-42fe-4e70-9a33-d3450cbc9a52)

## Due to current lack in interest, EnterpriseG wont be updated for a while. (24H2 26090 EnterpriseG currently needs to be fixed)
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
- install.wim or ISO (EN-US or ZH-CN, no updates, must contain Pro, supports multi-edition)
- Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
- Microsoft-Windows-Client-LanguagePack-Package... .esd

> .esd files are obtainable through [**UUP Dump**](https://uupdump.net/) or the [**releases**](https://github.com/xLSX285/EnterpriseG/releases) page.

`How to get started:`
1. Place all 3 files in the root directory of the script
2. Adjust the config.json to your likings
3. Run **Build.ps1** and wait for the reconstruction to complete

> Make sure your machine can execute PS scripts. **Set-ExecutionPolicy RemoteSigned**
>
<div align="center">
  
# Config.json

</div>

## ActivateWindows

- `True`: Windows will be activated using KMS38 method `Default`
- `False`: Windows wont be activated

## WimToESD 

- `True`: install.wim image will be compressed to install.esd
- `False`: install.wim image wont be compressed `Default`

## RemoveEdge

- `True`: Microsoft Edge will be removed `Official`
- `False`: Microsoft Edge remains installed

## RemoveApps

- `True`: All specified inbox apps in `ProvisionedPackagesToRemove` will be removed from the image
- `False`: Inbox apps wont be removed `Default`

## RemovePackages

- `True`: All specified packages in `WindowsPackagesToRemove` will be removed from the image
- `False`: Packages wont be removed `Default`
- `You may experience couple error messages when it's removing packages, that's completely fine.`


## DisableFeatures

- `True`: All specified features in `WindowsFeaturesToDisable` will be disabled from the image
- `False`: Features wont be disabled `Default`

<div align="center">
  
# Known "issues" with Enterprise G
</div>

- Inplace upgrade fails on some builds of Windows (e.g 19041 -> 22000/22621.) fix needed.
