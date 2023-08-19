# Windows Enterprise G Building Script

- Download & extract files (250+) inside of ```Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD``` to ```sxs```
- Download & extract files (10000+) inside of ```Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd``` to ```lp```

> You can acquire both .ESD files through **[UUP Dump](https://uupdump.net)**

- Copy ```install.wim``` to the same directory as the ```Build.cmd``` file
> Make sure your install.wim file contains ```NO updates``` and ```only includes the Pro Edition```. You can build a clean ISO containing the install.wim with no updates and Pro only through **[UUP Dump](https://uupdump.net)**. You find the ```install.wim``` inside the ```sources``` folder of your ISO.

- Set your settings inside Build.cmd

Run ```Build.cmd``` and let the magic happen!

## VERSION

- Specify your Windows Build Number
### ```Examples```
- 22621 ```Stable Release``` -> 10.0.22621.1
- 25931 ```Insider Preview``` -> 10.0.25931.1000

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

