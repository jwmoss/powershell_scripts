function Get-X500Error {
    <#
.SYNOPSIS
    Get's all mailboxes with X500 errors.
.EXAMPLE
    PS C:\> Get-X500Errors
.NOTES
    Opens a powershell remoting session to the exchange server, searches message tracking for IMCEAEX errors.
#>

    $servers = (Get-TransportServer).Name

    foreach ($server in $servers) {
        Invoke-Command -scriptblock { Get-MessageTrackinglog -EventID FAIL -Start (Get-Date).AddDays(-7) -ResultSize Unlimited -Server $server | Where-Object { $psitem.Recipients -match "^IMCEAEX*" } } -ArgumentList $server
    }
}