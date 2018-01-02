<#
.SYNOPSIS
  Downloads RSAT and installs for Windows 10 v1709 (Fall Creators Update) or Installs RSAT Powershell Module on Server OS'
.DESCRIPTION
  In order to install Remote Server Administration Tools, this script will download from Microsoft's website, check the OS to see if it's
  running on a Server OS or Windows 10, and if it's running Windows 10, it will try and download the latest version of RSAT. 
  Original script from https://blogs.technet.microsoft.com/drew/2016/12/23/installing-remote-server-admin-tools-rsat-via-powershell/

.NOTES
  Version:        1.0
  Author:         Jonathan Moss
  Creation Date:  1/2/18
  Purpose/Change: Initial script upload
  Requires Run As Administrator
.EXAMPLE
  .\Get-Hardware.ps1
#>

$web = Invoke-WebRequest https://www.microsoft.com/en-us/download/confirmation.aspx?id=45520 -UseBasicParsing

$MachineOS = (Get-WmiObject Win32_OperatingSystem).Name

#Check for Windows Server 2012 R2
IF ($MachineOS -like "*Microsoft Windows Server*") {
    
    Add-WindowsFeature RSAT-AD-PowerShell
    Break
}

IF ($ENV:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    Write-host "x64 Detected" -foregroundcolor yellow
    $Link = ($web.Links.href | Where-Object {$PSitem -like "*RSAT*" -and $PSitem -like "*x64*" -and $PSitem -notlike "*2016*"} | Select-Object -First 1) 
}
ELSE {
    Write-host "x86 Detected" -forgroundcolor yellow
    $Link = ($web.Links.href | Where-Object {$PSitem -like "*RSAT*" -and $PSitem -like "*x86*" -and $PSitem -notlike "*2016*"} | Select-Object -First 1) 
}

$DLPath = ($ENV:TEMP) + ($link.split("/")[8])

## Changed to temp folder
$Temp = ($ENV:TEMP)

Write-Host "Downloading RSAT MSU file" -foregroundcolor yellow
Start-BitsTransfer -Source $Link -Destination $DLPath

$Authenticatefile = Get-AuthenticodeSignature $DLPath

if ($Authenticatefile.status -ne "valid") {write-host "Can't confirm download, exiting"; break}

## Section to install DNS module for RSAT  on Windows 10 v1709 Creators Update

Write-host "Creating temporary folder to configure DNS for Windows 10 v1709" -foregroundcolor yellow

$1ex = New-Item $Temp\ex1 -ItemType Directory

Write-host "Expanding $DLPath" -foregroundcolor yellow

Start-Sleep -Seconds 5

expand.exe -f:* $DLPath $1ex

## Grab the contents of the XML required to install DNS, hosted as a gist 
## on my github from https://support.microsoft.com/en-us/help/4055558/rsat-missing-dns-server-tool-in-windows-10-version-1709

$xmllink = "https://gist.githubusercontent.com/jwmoss/c25f055cc2bc1379deb3e29feb6b53c3/raw/09b20f88c3774c2e18763f9e4253432609418040/unattend_x64.xml"

Write-host "Downloading XML file" -foregroundcolor yellow

Start-BitsTransfer -Source $xmllink -Destination $1ex\unattend_x64.xml

$cabfile = Get-ChildItem -Path $TEMP\$1ex -Filter "WindowsTH-KB2693643-x64.cab"
$xmlfile = Get-ChildItem -Path $TEMP\$1ex -Filter "unattend_x64.xml"

expand.exe -f:* $cabfile.FullName $1ex

Dism.exe /online /apply-unattend="$xmlfile"
Dism.exe /online /Add-Package /PackagePath:"$cabfile"