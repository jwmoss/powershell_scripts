function Get-W10OS {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]
        $ID
    )
    
    begin {
        
    }
    
    process {
        Switch -WildCard ($ID) {
            '*19042*' { "20H2" }
            '*19041*' { "2004" }
            '*18363*' { "1909" }
            '*18362*' { "1903" }
            '*17763*' { "1809" }
            '*17134*' { "1803" }
            '*16299*' { "1709" }
            '*15063*' { "1703" }
            '*14393*' { "1607" }
            '*10586*' { "1511" }
            Default { "Failed" }
        }  # End of Switch 
    }
    
    end {
        
    }
}
