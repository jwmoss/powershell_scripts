<#
.SYNOPSIS
    Get's all mailboxes with X500 errors.
.EXAMPLE
    PS C:\> Get-X500Errors.ps1
.NOTES
    Opens a powershell remoting session to the exchange server, searches message tracking for IMCEAEX errors,
    exports info to CSV, and sends an email.
#>

function Get-RemoteExchSession ($domain = "contoso.com") {
    Write-Host "Beginning to setup remoting session to Exchange server" -ForegroundColor Gray 
    $ExchangeParams = @{
        ConfigurationName = "Microsoft.Exchange"
        ConnectionURI     = "http://mail.$domain/powershell"
        Name              = "Exchange"
    }
    $ExchangeSession = New-PSSession @ExchangeParams -AllowRedirection
    return $ExchangeSession
}

$session = Get-RemoteExchSession

Import-PSSession $session

$servers = (Get-TransportServer).Name

[array]$result = foreach ($server in $servers) {
    Write-Host "Getting log information for $server.." -ForegroundColor Cyan
    Invoke-Command -scriptblock {Get-MessageTrackinglog -EventID FAIL -Start (Get-Date).AddDays(-7) -ResultSize Unlimited -Server $server | Where-Object {$psitem.Recipients -match "^IMCEAEX*"}} -ArgumentList $server
}

$Result | Export-CSV -NoTypeInformation $ENV:Temp\X500_Errors.csv

$MailSplat = @{
    From       = "no_reply@blah.com"
    To         = "blah@blah.com"
    Subject    = "X500s in $domain"
    Attachment = "$ENV:Temp\X500_Errors.csv"
    SmtpServer = "mail.$domain"
}

Send-MailMessage @MailSplat

Get-PSSession | Remove-PSSession