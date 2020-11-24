function Get-AutoForwards {
    [CmdletBinding()]
    param (
        
    )

    $UserForwards = Get-Mailbox -Filter { ForwardingAddress -like "*" } | Select-Object *
    
    foreach ($user in $UserForwards) {
        $contactinfo = Get-Recipient -Identity $User.ForwardingAddress | Select-Object *
        if ($contactinfo.RecipientType -eq "UserMailbox") {
            [PSCustomObject]@{
                PrimarySMTPAddress              = $user.PrimarySMTPAddress
                PrimarySMTPAddressMailboxSource = $domain
                ForwardingEmailAddress          = $contactinfo.PrimarySMTPAddress
                ForwardingEmailDomain           = ($contactinfo.PrimarySMTPAddress -split '@')[1]            
                ForwardingEmailRecipientType    = $contactinfo.RecipientType
                ForwardingEmailAddressName      = $contactinfo.Name
            }
        }
    }
}
