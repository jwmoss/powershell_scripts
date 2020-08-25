function Set-TMDBApi {
    [CmdletBinding()]
    param (
        [string]
        $API
    )
    
    $script:tmdbconfig = @{ }

    $script:tmdbconfig.add("API", $API)
}