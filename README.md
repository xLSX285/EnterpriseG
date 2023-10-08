# Windows Enterprise G Reconstruction Script

## [Download latest script version](https://github.com/xLSX285/EnterpriseG/archive/refs/heads/main.zip)
![hero](https://github.com/xLSX285/EnterpriseG/assets/129116755/3f1a3925-ea56-408e-89d0-5e717712e6e6)


# How to reconstruct Enterprise G

`Files required:`
- install.wim (No updates, Pro only)
- Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
- Microsoft-Windows-Client-LanguagePack-Package... .esd

> .esd files are obtainable through **UUP Dump**.

`How to get started:`
1. Place all 3 files in the root directory of the script
2. Run **Build.ps1** and wait for the opration to complete

> Make sure your machine can execute PS scripts. **Set-ExecutionPolicy RemoteSigned**
> 
# Settings (config.json)

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

# Known "issues" with Enterprise G
- Enterprise G Insider Preview builds cannot be updated through Windows Update, you have to get another ISO and perform an inplace upgrade.
- Factory resetting Windows will display an `OOBE_EULA` error during setup. **[How to fix (step 3)](https://www.howto-connect.com/fix-oobeeula-error-something-went-wrong-windows-10-or-11/)**
- Factory resetting Windows will remove the additional registry keys that are responsible for Microsoft Account login support for Enterprise G etc. **[Heres how to add them back super easily.](https://pastebin.com/ye0ZyPcu)**
- Inplace upgrade fails on some versions of Windows 11 (especially inplace upgrade from 19041 -> 22000/22621.) fix needed.

# Todo
- More script optimizations
- Option to automatically integrate updates
- Remove Edge at image level instead of at setup complete state
