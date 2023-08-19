# Windows Enterprise G Building Script

- Download & extract all files inside of ```Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD``` to ```sxs```
- Download & extract all files inside of ```Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd``` to ```lp```

> You can acquire both .ESD files through **[UUP Dump](https://uupdump.net)**

- Copy install.wim to this directory
> Make sure your install.wim file contains ```NO updates``` and ```only includes the Pro Edition```. You can get a clean install.wim with no updates and Pro only through **[UUP Dump](https://uupdump.net)**.

- Set your Settings inside Build.cmd

Run Build.cmd and let the magic happen!

## VERSION

- Specify your Windows Build
Examples:
- 22621 -> 10.0.22621.1
- 25931 (Canary Insider) -> 10.0.25931.1000

## vNext

- ```True```: Will use the proper SXS files to Build vNext EnterpriseG. (Canary Channel)
- ```False```: Will use the proper SXS files to Build current Stable EnterpriseG. (Stable Channel and Dev Channel)

## ActivateWindows

- ```True```: Will copy activation script onto the Image pre-activating Windows upon installation using KMS38
- ```False```: Windows will not be activated

## AdvancedTweaks 

- ```True```: Script will add additional registry keys to hide Recommended Section, turn off GameDVR etc.
- ```False```: Script wont add additional registry keys to hide Recommended Section, turn off GameDVR etc.

## WimToESD 

- ```True```: Script will compress Install.wim to Install.esd
- ```False```: Script wont compress Install.wim to Install.esd

