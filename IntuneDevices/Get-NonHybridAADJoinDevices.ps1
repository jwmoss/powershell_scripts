function Get-NonHybridAADJoinDevices {
    [CmdletBinding()]
    param (
        [PSObject]
        $Devices
    )
    
    begin {
        
    }
    
    process {
        $Devices |
        Where-Object {$PSItem.DeviceTrustType -ne "Domain Joined"}
    }
    
    end {
        
    }
}