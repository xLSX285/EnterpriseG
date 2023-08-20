# Windows Enterprise G Building Script

<p align="center">
  <a>Prebuilt EnterpriseG ISOs</a>
</p>

<p align="center">
  <a href="https://drive.google.com/file/d/1eKrBLz8A1-M0C4OZ3eb2yRONASiTvx5h/view?usp=sharing">Stable</a> | <a href="https://drive.google.com/file/d/1SNct2pJR2Vc9K4ZqCHeAK2d1XX2zkwZy/view?usp=sharing">Dev</a> | <a href="https://drive.google.com/file/d/1UES5If49Gw678M7sPJtG3Jsf3ByM_3Mp/view?usp=sharing">Canary</a>
</p>

# How to reconstruct EnterpriseG

- Extract files `250+` inside `Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD` to `sxs`
- Extract files `10000+` inside `Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd` to `lp`

> You can download both .ESD files through **[UUP Dump](https://uupdump.net)**.

- Copy `install.wim` to the same directory as the `Build.cmd` file
> Make sure your install.wim file contains `NO updates` and `only includes the Pro Edition` You can build a clean ISO containing the install.wim with no updates and Pro only through **[UUP Dump](https://uupdump.net)**. You find the `install.wim` inside the `sources` folder of your ISO.

- Set your settings inside Build.cmd

Run `Build.cmd` and let the magic happen!

# Build.cmd settings

## Version

- Specify the Windows Build Number
> All current **Windows 10**, **Windows 1**1 and **Windows vNext** Builds work with this script. `As of 08/19/23`

## EnterpriseGN (Not recommended)

- `True`: Adjust script to build **EnterpriseGN** instead of EnterpriseG
- `False`: Adjust script to build **EnterpriseG** `Default`

> Please note that this will require `Microsoft-Windows-EditionSpecific-EnterpriseGN-Package.ESD` instead of `Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD` - Be aware that Cumulative Updates cannot be installed and must be reconstructed and installed offline! It's better to stick with EnterpriseG since it can be updated online (with exception being Insider Previews, they can be updated only through inplace upgrades)

## vNext

- `True`: Recommended for **Canary** Channel Builds
- `False`: Recommended for **Stable**, **Release Preview**, **Beta** & **Dev** Channel Builds `Default`

## ActivateWindows

- ```True```: Will copy activation script onto the Image pre-activating Windows upon installation using KMS38
- ```False```: Windows will not be activated ```Default```

## AdvancedTweaks 

- `True`: Script will add additional registry keys to hide Recommended Section, turn off GameDVR etc.
- `False`: Script wont add additional registry keys to hide Recommended Section, turn off GameDVR etc. `Default`

## DisableCompatibilityCheck

- `True`: Disable checks for compatible hardware (TPM, CPU, RAM, Storage, Secure Boot etc.)
- `False`: Windows will check if your PC is compatible with this Version of Windows `Default`

> You can check **[here](https://learn.microsoft.com/en-us/windows/whats-new/windows-11-requirements)** if your PC is compatible with the latest version of Windows. Note that you need to add the boot.wim to the EnterpriseG folder in order to apply properly.

## WimToESD 

- `True`: Script will compress Install.wim to Install.esd - This will require more time and resources.
- `False`: Script wont compress Install.wim to Install.esd `Default`

# Known "issues" with EnterpriseG/GN
- `EnterpriseG` Insider Preview builds cannot be updated through Windows Update, you have to get another EnterpriseG ISO and perform an inplace upgrade. - `Microsoft doesn't officially offer EnterpriseG as Edition. That's why.`
- `EnterpriseGN` cannot install cumulative updates online. You have to manually reconstruct these cumulative updates and install them offline via win10ui for example. - `Actually not sure why lol, online updates work fine for EnterpriseG though.`
- Factory resetting Windows will display an `OOBE_EULA` error during setup. **[How to fix (step 3)](https://www.howto-connect.com/fix-oobeeula-error-something-went-wrong-windows-10-or-11/)**
- Factory resetting Windows will remove the additional registry keys that are responsible for Microsoft Account login support for EnterpriseG and more important components. **[Heres how to add them back super easily.](https://pastebin.com/ye0ZyPcu)**

# TODO
- More script optimizations!
- Setting option to remove all inbox apps (UUP Dump can already do that if you specify an App Level in the config)
- Please feel free to let me you know if you have any ideas.

` Please note that this project requires some basic knowledge. `

