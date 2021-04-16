function Install-PSWindowsupdate {
    [CmdletBinding()]
    param (
        [string[]]
        $Computername
    )
    
    begin {
        
    }
    
    process {
        Invoke-Command -ComputerName $Computername -ScriptBlock {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            if (-not (Get-Module PSWindowsUpdate)) {
                Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                Set-ExecutionPolicy Unrestricted
                Install-Module -Name PSWindowsUpdate
            }
        }       
    }
    
    end {
        
    }
}
