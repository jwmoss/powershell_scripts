function Get-HybridAADJoinDevices {
    [CmdletBinding()]
    param (
        [PSObject]
        $Devices
    )
    
    begin {
        
    }
    
    process {
        $Devices | 
        Where-Object {($_.DeviceTrustType -eq 'Domain Joined') -and (([string]($_.AlternativeSecurityIds)).StartsWith("X509:"))}
    }
    
    end {
        
    }
}