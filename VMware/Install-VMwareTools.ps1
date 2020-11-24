function Install-VMwareTools {
    [CmdletBinding()]
    param (
      [string[]]
      $ComputerName = $ENV:COMPUTERNAME
    )
      
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
  
      $ErrorActionPreference = 'Stop'
      $url64 = 'https://packages.vmware.com/tools/releases/11.2.0/windows/x64/VMware-tools-11.2.0-16938113-x86_64.exe'
      
      $packageArgs = @{
        url64bit       = $url64
        validExitCodes = @(0)
        silentArgs     = '/S /v /qn REBOOT=R'
        softwareName   = 'VMware Tools'
      }
      
      Invoke-WebRequest -Uri $url64 -OutFile "$env:TEMP\vmwaretools.exe"
      
      Start-Process -FilePath "$env:TEMP\vmwaretools.exe" -ArgumentList $packageArgs.silentArgs -Wait -NoNewWindow
    }
  }
  
  