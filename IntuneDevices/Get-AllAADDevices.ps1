function Get-AllAADDevices {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Get-AzureADDevice -All $true | 
        Where-Object {$PSItem.deviceOSType -match "Windows"} |
        Select-object *
    }
    
    process {
        
    }
    
    end {
        
    }
}
