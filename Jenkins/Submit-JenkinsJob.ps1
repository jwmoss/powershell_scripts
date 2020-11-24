#Requires -Module Jenkins
function Submit-JenkinsJob {
    [CmdletBinding()]
    param (
        [pscredential]
        $Credential,

        [string]
        $Username,

        [string]
        $JenkinsURL,

        [string]
        $Folder,

        [string]
        $Name
    )
    $job = @{
        URI        = $JenkinsURL
        Credential = $Credential
        Folder     = $Folder
        Name       = $Name
        Verbose    = $True
    }

    Invoke-JenkinsJob @job
}