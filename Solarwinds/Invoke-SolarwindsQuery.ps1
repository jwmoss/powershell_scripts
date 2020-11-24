function Invoke-SolarWindsQuery {
    [CmdletBinding()]
    param (
        [hashtable]
        $Body = @{query = "SELECT Caption, IPAddress FROM Orion.Nodes" },

        [PSCredential]
        $Credential,

        [string]
        $URL
    )

    $Headers = @{
        "Content-Type" = "application/json"
    }
    
    $splat = @{
        uri            = "$($URL):17778/Solarwinds/InformationService/v3/Json/Query"
        ContentType    = "application/json"
        Credential     = $Credential
        Body           = $Body | ConvertTo-Json
        Headers        = $Headers
        Authentication = "Basic"
        Method         = "POST"
    }
    
    ((Invoke-WebRequest @splat).Content | ConvertFrom-Json).results
}