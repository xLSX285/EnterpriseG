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

`All you need to provide is:`
- Windows 10/11 Pro en-US install.wim image without updates (XXXXX.1)

> [**UUP Dump**](https://uupdump.net/) can create a Windows Pro ISO in en-US without updates (untick the **Include updates (Windows converter only)** box).
>
Supported Builds: 
- [17763](https://uupdump.net/download.php?id=6ce50996-86a2-48fd-9080-4169135a1f51&pack=en-us&edition=professional) (1809), [19041](https://uupdump.net/download.php?id=a80f7cab-84ed-43f4-bc6b-3e1c3a110028&pack=en-us&edition=professional) (2004), [22000](https://uupdump.net/download.php?id=6cc7ea68-b7fb-4de1-bf9b-1f43c6218f6f&pack=en-us&edition=professional) (21H2), [22621](https://uupdump.net/download.php?id=356c1621-04e7-4e66-8928-03a687c3db73&pack=en-us&edition=professional) (22H2 & 23H2) & [26100](https://uupdump.net/download.php?id=3d68645c-e4c6-4d51-8858-6421e46cb0bb&pack=en-us&edition=professional) (24H2)


`How to get started:`
1. Place install.wim in the directory of the script
2. Adjust config.json if necessary
3. Run **Build.ps1** in PowerShell as Administrator

> Run this command in Powershell if Build.ps1 is not starting. **Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass**
> 
After reconstruction has completed, you will find the new install.wim inside the same folder where you also copied the original install.wim to. (**your original install.wim image has been overwritten and cannot be restored at this point!**) You can create a new ISO using AnyBurn or any other software. if you already created a bootable Windows Install USB drive, copy and replace the install.wim, which is located inside the `sources` directory of your windows installation media on your usb drive.
>
<div align="center">
  
# Config.json

</div>

## ActivateWindows

- `True`: Activate Windows via KMS38 `Default`
- `False`: Windows wont be activated

## RemoveEdge

- `True`: Bring your own web browser `Default`
- `False`: Microsoft Edge remains installed

<div align="center">
  
# Known "issues" with Enterprise G reconstruction
</div>

- Inplace upgrade fails on some builds of Windows (e.g 19041 -> 22000/22621.) (looking for a fix)
<div align="center">

# Please note that...
I'm not actively maintaining this project. I'll push some commits here and there to ensure support for future Windows builds and some optimizations, that's it. This project requires some knowledge. Please don't ask me for help.
</div>
