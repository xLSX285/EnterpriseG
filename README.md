# Windows Enterprise G Building Script

# How to reconstruct EnterpriseG

- Extract files `250+` inside `Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD` to `sxs`
- Extract files `10000+` inside `Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd` to `lp`

> You can download both .ESD files through **UUP Dump**.

- Copy `install.wim` to the same directory as the `Build.ps1` file
> Make sure your install.wim file contains `NO updates` and `only includes the Pro Edition` You can build a clean ISO containing the install.wim with no updates and Pro only through **[UUP Dump](https://uupdump.net)**. You find the `install.wim` inside the `sources` folder of your ISO.

- Set your settings inside `Build.ps1` and `config.json`

Run `Build.ps1` and let the magic happen!

# Build.ps1 settings

## Build

- Specify the Windows Build Number
> All current **Windows 10**, **Windows 11** and **Windows vNext** Builds work with this script. `As of 10/5/23`

## Type

- `Normal`: Recommended to build EnterpriseG for 19041 - 23xxx `Default`
- `vNext`: Recommended to build EnterpriseG for 25xxx+
- `Legacy` Recommended to build EnterpriseG for 17736 and older

## WimToESD 

- `True`: Script will compress Install.wim to Install.esd - This will require more time and resources.
- `False`: Script wont compress Install.wim to Install.esd `Default`

## RemoveApps

- `True`: All inbox apps will be removed from the mounted image
- `False`: All inbox apps will remain installed `Default`

## RemovePackages

- `True`: All safe to remove packages will be removed from the mounted image
- `False`: All other packages will remain installed `Default`

## DisableFeatures

- `True`: All features will be disabled from the mounted image
- `False`: All features will remain enabled `Default`

## ActivateWindows

- `True`: Windows will be activated using KMS38 method
- `False`: Windows wont be activated `Default`

# Config.json settings

## ProvisionedPackagesToRemove

- List of Inbox apps that will be removed if set to true in build.ps1

## WindowsPackagesToRemove

- List of Windows packages that will be removed if set to true in build.ps1

## WindowsFeaturesToDisable

- List of features that will be removed if set to true in build.ps1

# Known "issues" with EnterpriseG
- `EnterpriseG` Insider Preview builds cannot be updated through Windows Update, you have to get another ISO and perform an inplace upgrade.
- Factory resetting Windows will display an `OOBE_EULA` error during setup. **[How to fix (step 3)](https://www.howto-connect.com/fix-oobeeula-error-something-went-wrong-windows-10-or-11/)**
- Factory resetting Windows will remove the additional registry keys that are responsible for Microsoft Account login support for EnterpriseG etc. **[Heres how to add them back super easily.](https://pastebin.com/ye0ZyPcu)**
- Inplace upgrade fails on some versions of Windows 11 (especially inplace upgrade from 19041 -> 22000/22621.) fix needed.

# TODO
- More script optimizations!
- Please feel free to let me you know if you have any ideas.

` Please note that this project requires some basic knowledge. If you can't run the script, try: Set-ExecutionPolicy RemoteSigned `

