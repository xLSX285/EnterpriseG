![LSX presents](https://github.com/xLSX285/EnterpriseG/assets/129116755/4957cf9b-42fe-4e70-9a33-d3450cbc9a52)

<div align="center">

## [Download Latest Version](https://github.com/xLSX285/EnterpriseG/archive/refs/heads/main.zip)
</div>
<div align="center">
  <img src="https://github.com/xLSX285/EnterpriseG/assets/129116755/3f1a3925-ea56-408e-89d0-5e717712e6e6" alt="Image Description">
</div>

<div align="center">
  
# How to reconstruct Enterprise G
</div>

`Files required:`
- install.wim (EN-US, no updates, must contain Pro, can be multi-edition. You can build one using UUP Dump for example.)

> The script automatically downloads all required files for Build 17763, 19041, 22000, 22621 and 26100. You just need to provide an install.wim image. If you work with other builds, you must additionally obtain Microsoft-Windows-Client-LanguagePack-Package...esd and Microsoft-Windows-EditionSpecific-EnterpriseG-Package.ESD yourself. .esd files are obtainable through [**UUP Dump**](https://uupdump.net/).

`How to get started:`
1. Place install.wim in the root directory of the script
2. Adjust the config.json if necessary
3. Execute **Build.ps1**

> Make sure your machine can execute PowerShell scripts. **Set-ExecutionPolicy RemoteSigned**
>
<div align="center">
  
# Config.json

</div>

## ActivateWindows

- `True`: Windows will be activated using KMS38 method `Default`
- `False`: Windows wont be activated

## RemoveEdge

- `True`: Microsoft Edge will be removed `Official`
- `False`: Microsoft Edge remains installed

<div align="center">
  
# Known "issues" with Enterprise G
</div>

- Inplace upgrade fails on some builds of Windows (e.g 19041 -> 22000/22621.) fix needed.
- 24H2 (26100) reconstruction currently not working.
