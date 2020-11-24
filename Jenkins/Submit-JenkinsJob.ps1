#Requires -Module Jenkins
function Submit-JenkinsJob {
    [CmdletBinding()]
    param (
        [string]
        $Token,

        [string]
        $Username,

        [string]
        $JenkinsURL,

        [string]
        $Folder,

        [string]
        $Name
    )

    $SecurePassword = $token | ConvertTo-SecureString -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
    $job = @{
        URI        = $JenkinsURL
        Credential = $Cred
        Folder     = $Folder
        Name       = $Name
        Verbose    = $True
    }

    Invoke-JenkinsJob @job
}