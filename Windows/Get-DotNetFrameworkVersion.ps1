function Get-DotNetFrameworkVersion {
    [CmdletBinding()]
    param(
        [string[]]$Computer
    )

    $scriptblock = {
        $NetRegKey = Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
        $Release = $NetRegKey.GetValue("Release")
        Switch ($Release) {
            378389 { $NetFrameworkVersion = "4.5" }
            378675 { $NetFrameworkVersion = "4.5.1" }
            378758 { $NetFrameworkVersion = "4.5.1" }
            379893 { $NetFrameworkVersion = "4.5.2" }
            393295 { $NetFrameworkVersion = "4.6" }
            393297 { $NetFrameworkVersion = "4.6" }
            394254 { $NetFrameworkVersion = "4.6.1" }
            394271 { $NetFrameworkVersion = "4.6.1" }
            394802 { $NetFrameworkVersion = "4.6.2" }
            394806 { $NetFrameworkVersion = "4.6.2" }
            460798 { $NetFrameworkVersion = "4.7" } 
            460805 { $NetFrameworkVersion = "4.7" }
            461308 { $NetFrameworkVersion = "4.7.1" }
            461310 { $NetFrameworkVersion = "4.7.1" }
            461808 { $NetFrameworkVersion = "4.7.2" }
            461814 { $NetFrameworkVersion = "4.7.2" }
            528049 { $NetFrameworkVersion = "4.8" }
            Default { $NetFrameworkVersion = "Net Framework 4.5 or later is not installed." }
        }
        [PSCustomObject]@{
            Computername        = $env:COMPUTERNAME
            NETFrameworkVersion = $NetFrameworkVersion
        }
    }
         
    if ($Computer -eq "localhost") { 
        . $scriptblock
    }
    else {
        $Session = New-PSSession $Computer
        Invoke-Command -Session $Session -ScriptBlock $scriptblock
    }
}