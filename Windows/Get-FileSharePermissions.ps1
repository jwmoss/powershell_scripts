#Requires -Module NTFSAccess
Function Get-FileSharePermissions {    
    Param (
        [String]
        $Path,

        [string]
        $Domain
    )
    $rights = Get-NTFSAccess -Path $path

    foreach ($permission in $rights) {
        if ($permission.Account.Accountname -match $Domain -and $null -ne $permission.Account.Accountname) {
            $Group = Get-ADObject -Filter ("objectSid -eq '{0}'" -f $permission.Account.Sid)
            $users = Get-GroupMembership -GroupName $group.Name -Server $Domain
            foreach ($person in $users) {
                if ($person.objectClass -eq "foreignSecurityPrincipal") {
        
                    if ($person.Username -match $Domain) {
                        $user = $person.Username
                    }

                    if ($permission.accessrights -eq "Modify, Synchronize") {
                        $accessrights = "Write"
                    }
                    if ($permission.accessrights -eq "ReadandExecute, Synchronize") {
                        $accessrights = "Read"
                    }
                    
                    [PSCustomObject]@{
                        User        = $user
                        Path        = $permission.Fullname
                        Rights      = $accessrights
                        IsInherited = $permission.IsInherited
                        ADGroup     = $permission.Account.Accountname
                    } 
                }
                else {
                    if ($permission.accessrights -eq "Modify, Synchronize") {
                        $accessrights = "Write"
                    }
                    if ($permission.accessrights -eq "ReadandExecute, Synchronize") {
                        $accessrights = "Read"
                    }
    
                    [PSCustomObject]@{
                        User        = $person.Name
                        Path        = $permission.Fullname
                        Rights      = $accessrights
                        IsInherited = $permission.IsInherited
                        ADGroup     = $permission.Account.Accountname
                    }   
                }
            }
        }
    }
}
