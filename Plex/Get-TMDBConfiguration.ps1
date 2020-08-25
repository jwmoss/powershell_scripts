function Get-TMDBConfiguration {
    [CmdletBinding()]
    param (

    )
    
    begin {
        $IRMParams = @{
            Headers     = @{
                Authorization = ("Bearer {0}") -f $script:tmdbconfig["API"]
            }
            ContentType = "application/json"
        }
    }
    
    process {
        Invoke-RestMethod -URI "https://api.themoviedb.org/3/configuration" @IRMParams | 
        Select-Object -ExpandProperty Images
    }
    
    end {
        
    }
}