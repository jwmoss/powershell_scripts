function Get-LargeMailboxes {
    #requires -Modules MSOnline

    [System.Collections.ArrayList]$results = @()

    $Credential = Get-Credential

    $SessionSplat = @{
        ConfigurationName = "Microsoft.Exchange"
        ConnectionURI     = "https://outlook.office365.com/powershell-liveid/"
        Credential        = $Credential
        Authentication    = "Basic"
        AllowRedirection  = $True
    }
    Import-PSSession $SessionSplat

    $Mailboxes = Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics 
    
    foreach ($mailbox in $Mailboxes) {
    $a = [pscustomobject]@{
        Displayname = $mailbox.DisplayName
        TotalItemSizeinMB = [math]::Round(($mailbox.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",", "") / 1MB), 0)}
        ItemCount = $mailbox.itemcount
    }
    $Results.Add($a)

    $Results
}