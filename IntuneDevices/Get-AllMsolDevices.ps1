function Get-AllMsolDevices {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        Get-MsolDevice -All -IncludeSystemManagedDevices | Where-Object {$PSItem.DeviceOsType -match "Windows"}
    }
    
    end {
        
    }
}
