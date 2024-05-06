![LSX presents](https://github.com/xLSX285/EnterpriseG/assets/129116755/4957cf9b-42fe-4e70-9a33-d3450cbc9a52)

<div align="center">

## [Download Latest Version](https://github.com/xLSX285/EnterpriseG/archive/refs/heads/main.zip)
</div>
<div align="center">
  <img src="https://github.com/xLSX285/EnterpriseG/assets/129116755/0eaff5b7-caa8-48e4-898f-cc38254712d6" alt="Image Description">
</div>

<div align="center">
  
# How to reconstruct Enterprise G
</div>

[![EnterpriseG Reconstruction Guide](https://img.youtube.com/vi/)](https://www.youtube.com/watch?v=K69L4DROtlc "EnterpriseG Reconstruction Guide")

`Files required:`
- Install.wim image in en-US language that contains no updates (.1) and image must contain Windows Pro Edition

> The script downloads all required files for you for Build 17763, 19041, 22000, 22621 and 26100. You need to provide an install.wim image, that's it. If you work with other builds, you must obtain Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd and Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD yourself. .esd files are obtainable on [**UUP Dump**](https://uupdump.net/).

`How to get started:`
1. Place install.wim in the directory of the script
2. Adjust the config.json if necessary
3. Run **Build.ps1** in PowerShell

> Make sure you can execute PowerShell scripts. **Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass**
>
<div align="center">
  
# Config.json

</div>

## ActivateWindows

- `True`: Windows will be activated via KMS38 method `Default`
- `False`: Windows wont be activated

## RemoveEdge

- `True`: Microsoft Edge will be removed `Default`
- `False`: Microsoft Edge remains installed

<div align="center">
  
# Known "issues" with Enterprise G
</div>

- Inplace upgrade fails on some builds of Windows (e.g 19041 -> 22000/22621.) fix needed.
- 24H2 (26100) reconstruction has been fixed. Currently working on fixing license at setup [Workaround for now: Install Windows through command prompt](https://gist.github.com/Alee14/e8ce6306a038902df6e7a6d667544ac9)
