<#
.SYNOPSIS
    Get's all mailboxes with auto-forwarding turned on.
.EXAMPLE
    PS C:\> Get-AutoForwards -Domain contoso.com
.NOTES
    Opens a powershell remoting session to the exchange server, exports info to CSV, and sends an email.
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

$UserForwards = Get-Mailbox -Filter {ForwardingAddress -like "*"} | Select-Object *

[System.Collections.ArrayList]$Result = @()

foreach ($user in $UserForwards) {
    $contactinfo = Get-Recipient -Identity $User.ForwardingAddress | Select-Object *
    if ($contactinfo.RecipientType -eq "UserMailbox") {
        $a = [PSCustomObject]@{
            PrimarySMTPAddress              = $user.PrimarySMTPAddress
            PrimarySMTPAddressMailboxSource = $domain
            ForwardingEmailAddress          = $contactinfo.PrimarySMTPAddress
            ForwardingEmailDomain           = ($contactinfo.PrimarySMTPAddress -split '@')[1]            
            ForwardingEmailRecipientType    = $contactinfo.RecipientType
            ForwardingEmailAddressName      = $contactinfo.Name
        }
        $Result.Add($a) | Out-Null
    }
}

$Result | Export-CSV -NoTypeInformation $ENV:Temp\ForwardingAddresses.csv

$MailSplat = @{
    From       = "no_reply@blah.com"
    To         = "blah@blah.com"
    Subject    = "Auto-Forwards in $domain"
    Attachment = "$ENV:Temp\ForwardingAddresses.csv"
    SmtpServer = "mail.$domain"
}

Send-MailMessage @MailSplat

Get-PSSession | Remove-PSSession