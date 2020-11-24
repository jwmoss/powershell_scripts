function Get-GroupMembership {
    [CmdletBinding()] 
    param (
        [Parameter (Mandatory = $true)]
        [string]$Server,
        [string]$GroupName,
        [bool]$Recursive
    )

    if (!($script:Out)) { $script:Out = @() }

    $Members = (get-adgroup -server $Server $GroupName -Properties Members).members | ForEach-Object { get-adobject $_ -server $Server -Properties DisplayName, Name, SAMAccountName | Select @{e = { $_.SAMAccountName }; l = "Username" }, Name, ObjectClass, DisplayName }
    foreach ($Member in $Members) {

        if ($Recursive) {
            if ($Member.objectClass -eq "group") {
                $RecursiveResults = Get-GroupMembership -GroupName $Member.Name -Server $Server -Recursive $true
                $script:Out += $RecursiveResults
            }

            else { $script:Out += $Member }
        }

        if ($Member.ObjectClass -eq "foreignSecurityPrincipal") {
            $FSPUsername = (New-Object System.Security.Principal.SecurityIdentifier($Member.Name)).Translate([System.Security.Principal.NTAccount])
            $script:Out += New-Object psobject -Property @{
                Username    = $FSPUsername
                ObjectClass = $Member.ObjectClass
                DisplayName = ""
            }
        }

        else { $script:Out += $Member }
    }
 
    $script:Out | Select-Object -Unique * | Sort-Object objectclass, username

    $script:Out = $null

}