function Get-TMDBMovie {
    [CmdletBinding()]
    param (
        [string]
        $ID,

        [string]
        $Name,

        [string]
        $IMDBID
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
        switch ($PSBoundParameters.Keys) {
            'ID' {
                $URI = "https://api.themoviedb.org/3/movie/{0}" -f $ID
                Invoke-RestMethod -Uri $URI @IRMParams
            }
            'Name' {
                $URI = "https://api.themoviedb.org/3/search/movie?query={0}" -f [uri]::EscapeDataString($name)
                (Invoke-RestMethod -Uri $URI @IRMParams).Results
            }
            'IMDBID' {
                $URI = "https://api.themoviedb.org/3/find/{0}?api_key={1}&external_source=imdb_id" -f $IMDBID,$script:tmdbconfig["API"]
                (Invoke-RestMethod -Uri $URI).movie_results
            }
            Default {
                if ($ID -and $Name) {
                    Write-Warning "Choose either ID or Movie name, not both."
                }
            }
        }
    }
    
    end {
        
    }
}