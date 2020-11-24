function Test-SecurityHardening {
    [CmdletBinding()]
    param (
        [switch]
        $Passthru
    )

    process {
        if ($Passthru) {
            Invoke-Pester -Script "$PSScriptRoot\Tests\security.tests.ps1" -PassThru
        }
        else {
            Invoke-Pester -Script "$PSScriptRoot\Tests\security.tests.ps1"
        }

    }
}