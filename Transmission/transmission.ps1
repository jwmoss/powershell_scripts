function Get-Torrent {
    [CmdletBinding()]
    param (
        [string]
        $URL = (get-content (Join-Path -Path ($ENV:HOME) -ChildPath "powershell_scripts" -AdditionalChildPath "Transmission", "url.txt")),

        [PSCredential]
        $Credential,

        [switch]
        $All
    )
    
    $headers = @{
        #'X-Transmission-Session-Id' = $sessionHeader
    }

    Invoke-WebRequest $url -Headers $headers -errorvariable a -Credential $credential -AllowUnencryptedAuthentication -warningaction SilentlyContinue

    $sessionHeader = ($a.Message -split "\.").split(" ")[-1]

    $headers = @{
        'X-Transmission-Session-Id' = $sessionHeader
    }

    $body = @{
        arguments = @{
            fields = @(
                "id",
                "uploadRatio",
                "downloadDir",
                "name"
                "addedDate",
                "status",
                "trackers",
                "trackerstats",
                "seedRatioLimit",
                "creator"
            )
        }
        method    = "torrent-get"
    }

    $splat = @{
        Method     = "POST"
        URI        = $url
        Headers    = $headers
        Credential = $credential
        Body       = $body | convertto-json
    }

    (Invoke-RestMethod @splat -AllowUnencryptedAuthentication).arguments.torrents
}
