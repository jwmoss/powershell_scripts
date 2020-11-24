Function Get-MigrationStats {
    [CmdletBinding()]
    param (
        [string]
        $MWName,

        [string]
        $UPN
    )
    
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

    Connect-ExchangeOnline -UserPrincipalName $UPN -ShowProgress $true

    ## List Mailbox Move Requests that are not completed
    Get-Moverequest | Where-Object { $psitem.Status -notmatch "completed" } | Get-MoveRequestStatistics | Select-Object -Property $PropertyArray

    Get-PSSession | Remove-PSSession
}
