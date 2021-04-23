function Get-AADRegistered {
    [CmdletBinding()]
    param (
        [PSObject]
        $Devices
    )
    
    begin {
        
    }
    
    process {
        $Devices |
        Where-Object {$PSItem.DeviceTrustType -eq "Workplace Joined"}
    }
    
    end {
        
    }
}