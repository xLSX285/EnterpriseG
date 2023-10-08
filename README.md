<div align="center">

# Windows Enterprise G Reconstruction Script

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
2. Run **Build.ps1** and wait for the opration to complete

> Make sure your machine can execute PS scripts. **Set-ExecutionPolicy RemoteSigned**
>
<div align="center">
  
# Settings (config.json)

</div>

## ActivateWindows

- `True`: Windows will be activated using KMS38 method
- `False`: Windows wont be activated `Default`

## WimToESD 

- `True`: Script will compress Install.wim to Install.esd - This will require more time and resources.
- `False`: Script wont compress Install.wim to Install.esd `Default`

## RemoveEdge

- `True`: Microsoft Edge and WebView2 will be removed at setup complete `Default`
- `False`: Microsoft Edge and WebView2 will remain installed

> I'm looking into removing it at image level in the future

## RemoveApps

- `True`: All inbox apps will be removed from the mounted image
- `False`: All inbox apps will remain installed `Default`

## RemovePackages

- `True`: All safe to remove packages will be removed from the mounted image
- `False`: All other packages will remain installed `Default`

## DisableFeatures

- `True`: All features will be disabled from the mounted image
- `False`: All features will remain enabled `Default`

## ProvisionedPackagesToRemove

- List of Inbox apps that will be removed if set to true in build.ps1

## WindowsPackagesToRemove

- List of Windows packages that will be removed if set to true in build.ps1

## WindowsFeaturesToDisable

- List of features that will be removed if set to true in build.ps1
<div align="center">
  
# Known "issues" with Enterprise G
</div>

- Enterprise G Insider Preview builds require an ISO for in-place upgrades; Windows Update won't update them.
- Factory resetting Windows on older builds than 25398 will display an `OOBEEULA` error during setup. **[How to fix (step 3)](https://www.howto-connect.com/fix-oobeeula-error-something-went-wrong-windows-10-or-11/)**
- Factory resetting Windows removes essential registry keys for Microsoft Account login support in Enterprise G, etc. **[Add back super easily.](https://pastebin.com/ye0ZyPcu)**
- Inplace upgrade fails on some versions of Windows 11 (e.g 19041 -> 22000/22621.) fix needed.
  
<div align="center">
  
# Todo
</div>

- More script optimizations
- Option to automatically integrate updates
- Remove Edge at image level instead of at setup complete state
