function Get-LargeMailboxes {
    $Mailboxes = Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics 
    foreach ($mailbox in $Mailboxes) {
        [pscustomobject]@{
            Displayname       = $mailbox.DisplayName
            TotalItemSizeinMB = [math]::Round(($mailbox.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",", "") / 1MB), 0)
            ItemCount = $mailbox.itemCount
        }
    }
}