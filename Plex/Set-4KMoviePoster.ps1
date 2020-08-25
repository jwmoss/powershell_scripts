function Set-4KMoviePoster {
    [CmdletBinding()]
    param (
        [string]
        $PlexToken,

        [string]
        $TMDBToken,

        [string]
        $PlexURL,

        [string]
        $4KLibraryName,

        [switch]
        $SkipSSL
    )
    
    begin {
        Set-TMDBAPI -API $TMDBToken
    }
    
    process {
        ## Plex Libraries
        $libraries = Invoke-RestMethod -Uri ($plexURL + "/library/sections?X-Plex-Token=$plextoken") -Method Get

        ## If the get request is null, stop the script
        if ($null -eq $libraries) {
            Write-Warning "Unable to find Plex Library. Make sure your plex token is accurate!"
            break
        }

        ## If the 4K movie library is null, stop the script
        $4K_PlexLibrary = $libraries.MediaContainer.Directory | Where-object { $psitem.Title -eq $4KLibraryName }
        if ($null -eq $4K_PlexLibrary) {
            Write-Warning "Unable to find $4KLibraryName. Is the name of your 4K library really named $4KLibraryName"
            break
        }

        $4K_PlexLibrary_url = ($PlexURL + "/library/sections/$($4K_PlexLibrary.key)/all?X-Plex-Token=$plextoken") 

        ## Return all of the 4K movies
        if ($SkipSSL) {
            $4K_PlexLibrary_results = (Invoke-RestMethod -uri $4K_PlexLibrary_url -SkipCertificateCheck).MediaContainer.Video
        }
        else {
            $4K_PlexLibrary_results = Invoke-RestMethod -uri $4K_PlexLibrary_url
        }

    }
    
    end {
        
    }
}