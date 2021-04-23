function Get-HybridAADJoinDevicesPending {
    [CmdletBinding()]
    param (
        [PSObject]
        $Devices
    )
    
    begin {
        
    }
    
    process {
        $Devices | 
        Where-Object {($null -eq $_.DeviceTrustType)}
    }
    
    end {
        
    }
}