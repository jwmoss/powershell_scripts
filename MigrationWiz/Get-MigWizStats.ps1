Function Get-MigWizStats {
    [CmdletBinding()]
    param (
        [string]
        $MWName,

        [string]
        $UPN
    )

    if (-not (Test-Path 'C:\Program Files (x86)\BitTitan\BitTitan PowerShell\BitTitanPowerShell.dll')) {
        throw "BitTitan Powershell module not installed. Please see https://www.bittitan.com/doc/powershell.html for more info"
    }

    Connect-ExchangeOnline -UserPrincipalName $UPN -ShowProgress $true

    ## List Mailbox Move Requests that are not completed
    $Results = Get-Moverequest | Where-Object { $psitem.Status -notmatch "completed" } | Get-MoveRequestStatistics | Select-Object *

    ## Select just what we want from $results
    $PropertyArray = @(
        "Displayname",
        "Status",
        "StatusDetail",
        "SourceServer",
        "BatchName",
        "OverallDuration",
        "TotalMailboxSize",
        "BytesTransferred",
        "PercentComplete"
    )
    
    $Results | Select-Object -Property $PropertyArray

    # Get Move Request status for Migration batch
    $Name = $MWName
    ## Get MigWiz Project
    $MWproject = Get-MW_MailboxConnector -Ticket $global:mwticket -Name $name -ErrorAction SilentlyContinue
    ## Get the status/stats of it
    $currentmigration = Get-MW_MailboxMigration -Ticket $Global:mwticket -ConnectorId $MWproject.id
    ## Get all of the mailboxes in the project
    $Mailboxes = Get-MW_Mailbox -ConnectorId $MWproject.id -Ticket $global:mwticket -RetrieveAll

    ## Build PS Object Listing Email, ID, and Project ID
    foreach ($mwmailbox in $Mailboxes) {
        ## Get migration status for each mailbox
        $migrationstatus = $currentmigration | Where-Object { $psitem.MailboxID -eq $mwmailbox.ID }

        if (($migrationstatus | Measure-Object).Count -gt 1) {
            $latestresult = $migrationstatus | Sort-Object -Property "StartDate" -Descending | Select-Object -First 1
            [PSCustomObject]@{
                EmailAddress = $mwmailbox.exportemailaddress
                ID           = $mwmailbox.ID
                ConnectorID  = $mwmailbox.ConnectorID
                Status       = $latestresult.Status
            }
        }
        else {
            [PSCustomObject]@{
                EmailAddress = $mwmailbox.exportemailaddress
                ID           = $mwmailbox.ID
                ConnectorID  = $mwmailbox.ConnectorID
                Status       = $migrationstatus.Status
            }
        }
    }

    Get-PSSession | Remove-PSSession
}
