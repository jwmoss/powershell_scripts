function Set-4KMoviePoster {
    [CmdletBinding()]
    param (
        [string]
        $PlexToken,

        [string]
        $TMDBToken,

        [System.IO.FileInfo]
        $4KLogoPath,

        [System.IO.FileInfo]
        $PosterPath,

        [string]
        $PlexURL,

        [string]
        $4KLibraryName,

        [switch]
        $SkipSSL
    )
    
    process {

        ## Plex Libraries
        $libraries = Invoke-RestMethod -Uri ($plexURL + "/library/sections?X-Plex-Token=$plextoken") -Method Get

        ## If the get request is null, stop the script
        if ($null -eq $libraries) {
            throw "Unable to find Plex Library. Make sure your plex token is accurate!"
        }

        ## If the 4K movie library is null, stop the script
        $4K_PlexLibrary = $libraries.MediaContainer.Directory | Where-object { $psitem.Title -eq $4KLibraryName }
        if ($null -eq $4K_PlexLibrary) {
            throw "Unable to find $4KLibraryName. Is the name of your 4K library really named $4KLibraryName"
        }

        $4K_PlexLibrary_url = ($PlexURL + "/library/sections/$($4K_PlexLibrary.key)/all?X-Plex-Token=$plextoken") 

        ## Return all of the 4K movies
        if ($SkipSSL) {
            $4K_PlexLibrary_results = (Invoke-RestMethod -uri $4K_PlexLibrary_url -SkipCertificateCheck).MediaContainer.Video
        }
        else {
            $4K_PlexLibrary_results = (Invoke-RestMethod -uri $4K_PlexLibrary_url).MediaContainer.Video
        }

        foreach ($m in $4K_PlexLibrary_results) {
            ## get the IMDB Id by extracing the numbers from the GUID of the movie result
            $imdbid_plex = "tt" + ($m.guid -replace "[^0-9]" , '')
                
            ## Get the movie from TMDB
            $tmdb = Get-TMDBMovie -ImdbID $imdbid_plex -API $TMDBToken

            ## Create the folder where we'll store the posters
            $Scriptblock = {
                Param(
                    [PSObject]
                    $Movie,

                    [PSObject]
                    $TMDB,

                    [string]
                    $PP,

                    [string]
                    $logopath,

                    [string]
                    $PlexURI,

                    [string]
                    $PlexToken,

                    [string]
                    $PlexFolderPath
                )

                if (-not (Test-Path (Join-Path $PP "PlexMoviePosters" $($tmdb.Id)))) {
                    
                    Write-Verbose ("Creating folder - ($(Join-Path $pp "PlexMoviePosters" $($tmdb.Id)))")

                    ## create the folder for the movie poster
                    $null = New-Item -Path (Join-Path $PP "PlexMoviePosters") -Name $tmdb.Id -ItemType Directory
                    
                    Write-Verbose "Downloading the $($movie.title)"

                    ## Picture path 
                    $picture = (Join-Path $PP "PlexMoviePosters" $($tmdb.Id) "poster.jpg")
                    
                    ## Download the poster
                    Invoke-WebRequest -Uri "https://image.tmdb.org/t/p/original$($tmdb.poster_path)" -OutFile $picture

                    Write-Verbose "Processing $($movie.title) - $($tmdb.Id) with magick" 
                    ## set the 4K picture path
                    $4k_poster = Join-Path $pp "PlexMoviePosters" $($tmdb.Id) "4kposter.jpg"

                    ## using magick, apply the 4K banner to the downloaded poster
                    magick $picture $logopath -resize x"%[fx:t?u.h*0.1:u.h]" -background black -gravity north -extent "%[fx:u.w]x%[fx:s.h]" -composite $4k_poster
                
                    $metadata_4k_url = $PlexURI + "/library/metadata/$($movie.ratingkey)/posters?includeExternalMedia=1&X-Plex-Token=$plextoken"

                    $plexparams = @{
                        URI    = $metadata_4k_url
                        Method = "POST"
                        InFile = $4k_poster
                    }

                    Write-Verbose "Setting 4K poster for $($movie.Title)"

                    Invoke-RestMethod @plexparams
                }
            
            }
        
            Invoke-Command -ScriptBlock $Scriptblock -ArgumentList $m,$tmdb,$PosterPath,$4KLogoPath,$PlexURL,$PlexToken,$PosterPath
        }

    }
    
}
function Get-TMDBMovie {
    [CmdletBinding()]
    param (
        [string]
        $ID,

        [string]
        $Name,

        [string]
        $IMDBID,

        [string]
        $API
    )
    
    begin {
        $IRMParams = @{
            Headers     = @{
                Authorization = ("Bearer {0}") -f $API
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
                $URI = "https://api.themoviedb.org/3/find/{0}?api_key={1}&external_source=imdb_id" -f $IMDBID,$API    
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

Export-ModuleMember -Function *