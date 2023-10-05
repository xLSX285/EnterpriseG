# Check if the script is running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# If not running as administrator, restart the script with elevated privileges
if (-Not $isAdmin) {
    Start-Process powershell.exe -ArgumentList " -NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs
    exit
}

# Use Get-WindowsImage to retrieve the Windows version
$imageInfo = Get-WindowsImage -ImagePath "install.wim" -Index 1
$Windows = ($imageInfo.ImageName -split ' ')[1]  # Extract the second word

# Display the extracted Windows version
Write-Host "Windows version: $Windows"

# Rest of your script...


pause