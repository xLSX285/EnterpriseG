# Windows Enterprise G Reconstruction Script

## [Download latest script version](https://github.com/xLSX285/EnterpriseG/archive/refs/heads/main.zip)
![hero](https://github.com/xLSX285/EnterpriseG/assets/129116755/3f1a3925-ea56-408e-89d0-5e717712e6e6)


# How to reconstruct Enterprise G

- Copy `install.wim`, `Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD` and `Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd` to the same directory as the `Build.ps1` file
> Make sure your install.wim file contains `NO updates` and `only includes the Pro Edition` You can build a clean ISO containing the install.wim with no updates and Pro only through **UUP Dump**. You find the `install.wim` inside the `sources` folder of your ISO.
> You can download both .ESD files through **UUP Dump**.

- If necessary, adjust the settings inside `config.json`.

Run `Build.ps1` and let the magic happen!

# Settings

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

# TODO
- More script optimizations!
- Option to automatically integrate updates
- Please feel free to let me you know if you have any ideas.

` Please note that this project requires some basic knowledge. If you can't run the script, try: Set-ExecutionPolicy RemoteSigned `

