# Windows Enterprise G Building Script

<p align="center">
  <a>Prebuilt EnterpriseG ISOs</a>
</p>

<p align="center">
  <a href="https://drive.google.com/file/d/1eKrBLz8A1-M0C4OZ3eb2yRONASiTvx5h/view?usp=sharing">Stable</a> | <a href="https://drive.google.com/file/d/1SNct2pJR2Vc9K4ZqCHeAK2d1XX2zkwZy/view?usp=sharing">Dev</a> | <a href="https://drive.google.com/file/d/1UES5If49Gw678M7sPJtG3Jsf3ByM_3Mp/view?usp=sharing">Canary</a>
</p>

# How to manually reconstruct EnterpriseG

- Extract files `250+` inside `Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD` to `sxs`
- Extract files `10000+` inside `Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd` to `lp`

> You can download both .ESD files through **[UUP Dump](https://uupdump.net)**.

- Copy `install.wim` to the same directory as the `Build.cmd` file
> Make sure your install.wim file contains `NO updates` and `only includes the Pro Edition` You can build a clean ISO containing the install.wim with no updates and Pro only through **[UUP Dump](https://uupdump.net)**. You find the `install.wim` inside the `sources` folder of your ISO.

- Set your settings inside Build.cmd

Run `Build.cmd` and let the magic happen!

# Build.cmd settings

## VERSION

- Specify your Windows Build Number
### ```Examples```
- 22621 **Stable Release** -> 10.0.22621.1 `Default`
- 25931 *Insider Preview** -> 10.0.25931.1000

> All current **Windows 10**, **Windows 1**1 and **Windows vNext** Builds work with this script. `As of 08/19/23`

## vNext

- `True`: Recommended for **Canary** Channel
- `False`: Recommended for **Stable**, **Release Preview**, **Beta** & **Dev** Channel `Default`

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

