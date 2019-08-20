function Set-MigWizToken {
    
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        I'm lazy and storing the token in the global scope.
    #>

    [CmdletBinding()]
    param (
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )
    
    process {
        Write-Verbose "Setting up session to Migration Wiz"
        $rightnow = (Get-Date).ToUniversalTime()
        if (($null -eq $global:mwticket) -and ($global:mwticket.ExpirationDate -lt $rightnow)) {
            $global:mwticket = Get-MW_Ticket -Credentials $Credential
        }
    }
}