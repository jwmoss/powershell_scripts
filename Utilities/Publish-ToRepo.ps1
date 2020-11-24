function Publish-ToRepo {
    [CmdletBinding()]
    param (
        [string]
        $Psd1Path,

        [string]
        $RepositoryName,

        [string]
        $Token
    )
    
    $splat = @{
        Name        = $Psd1Path
        Repository  = $RepositoryName
        Verbose     = $true
        NugetAPIKey = $Token
    }
    
    Publish-Module @splat
    
}