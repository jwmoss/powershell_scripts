function Set-TMDDApi {
    [CmdletBinding()]
    param (
        [string]
        $API
    )
    
    $script:tmdbconfig = @{ }

    $script:tmdbconfig.add("API", $API)
}