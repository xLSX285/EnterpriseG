# EnterpriseG
Windows Enterprise G Building Script

- Download Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD
- Download Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd
 
- Extract all content of Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD to sxs
- Extract all content of Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd to lp

- Copy install.wim to this directory
- Set Windows Build version in Build.cmd

Run Build.cmd


=================================================================

Examples:

- 22621.1 Install.wim image -> Set %VERSION% to 10.0.22621.1 
- 23516.1000 Install.wim image -> Set %VERSION% to 10.0.23516.1000

=================================================================

Notes:

WimToESD 

- False: Script wont compress Install.wim to Install.esd
- True: Script will compress Install.wim to Install.esd

AdvancedTweaks 

- False: Script wont add additional registry keys to hide Recommended Section, turn off GameDVR etc.
- True: Script will add additional registry keys to hide Recommended Section, turn off GameDVR etc.


=================================================================
