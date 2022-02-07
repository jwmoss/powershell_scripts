function Get-DotNetCoreVersion {
    [CmdletBinding()]
    param (
        [String[]]
        $ComputerName = $ENV:ComputerName
    )
    
    process {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
          $d = dotnet --info
            [PSCustomobject]@{
              ComputerName = $ENV:COMPUTERNAME
              DotNetVersion = $d[2].Trim()
              AspNetCore = $d[9].Trim()
              Netcore = $d[10].Trim()
            }
        }
    }
}
