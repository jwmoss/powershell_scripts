#Requires -Module PSWinReporting
function Get-LDAPSigning {
    [CmdletBinding()]
    param (
        
    )

    (Find-Events -Report LdapBindingsDetails,LdapBindingsSummary -DatesRange Last7days -DetectDC).LdapBindingsDetails | ForEach-Object {
        $user = ($_."Account Name" -split "\\")[1]
        $ADuser = Get-ADUser -Identity $user -Properties *
        [pscustomobject]@{
            User = $user
            Description = $ADuser.Description
            Manager = $ADUser.manager
            Action = $_.Action
            DomainController = $_."Domain Controller"
        }
    }

}