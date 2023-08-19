# Windows Enterprise G Building Script

- Download & extract all files inside of Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD to sxs
- Download & extract all files inside of Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd to lp

- Copy install.wim to this directory
- Set your Settings inside Build.cmd

Run Build.cmd

> You can acquire both files through [UUP Dump](uupdump.net)

## VERSION

- Specify your Windows Build for example 22621 = 10.0.22621.1

## vNext

- True: Will use the proper SXS files to Build vNext EnterpriseG. (Canary Channel)
- False: Will use the proper SXS files to Build current Stable EnterpriseG. (Stable Channel and Dev Channel)

## ActivateWindows

- True: Will copy activation script onto the Image pre-activating Windows upon installation using KMS38
- False: Windows will not be activated

## AdvancedTweaks 

- False: Script wont add additional registry keys to hide Recommended Section, turn off GameDVR etc.
- True: Script will add additional registry keys to hide Recommended Section, turn off GameDVR etc.

## WimToESD 

- False: Script wont compress Install.wim to Install.esd
- True: Script will compress Install.wim to Install.esd

