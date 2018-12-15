<#
.SYNOPSIS
    User profile cleanup
.DESCRIPTION
    Script to get profile permissions. Used to compare profile path permissions.
.EXAMPLE
    PS C:\> .\Get-ProfileSharePermissions.ps1
#>

#Requires -Modules NTFSSecurity

## Paths to user profiles in a domain with multiple profile shares
$userprofilepath = "\\path\to\profile"
$otheruserprofilepath = "\\path\to\otherprofile"

## Creating necessary Array's
$allprofiles = @()
$terminateduserfolder = @()

## Get the profiles and select just folders and exclude the Terminated folder
## Terminated folder exists for user profiles to be deleted after X days
$allprofiles += Get-ChildItem -Path $userprofilepath | Where-Object {$psitem.PSiscontainer -eq $true -and $psitem.Name -ne "Terminated"}
$allprofiles += Get-ChildItem -Path $otheruserprofilepath | Where-Object {$psitem.PSiscontainer -eq $true -and $psitem.Name -ne "Terminated"}

## Loop through each folder and verify that the user exists or doesn't in AD in UGCNT domain
foreach ($user in $allprofiles) {
    try {
        $ADUserInfo = Get-ADUser -Identity $($user.name) -ErrorAction STOP
        Write-Host "$($user.name) exists in AD! Skipping..." -ForegroundColor Green
    } catch {
        Write-Host "$($user.name) doesn't exist in AD or has been deleted" -ForegroundColor Yellow
        $terminateduserfolder += $user
    }
}

## Get NTFS permissions on each folder
$aclpermissions = Get-NTFSAccess -Path $terminateduserfolder.fullname

## Build custom object to modify easily
$a = $aclpermissions | ForEach-Object { 
[pscustomobject]@{
    FolderName = $psitem.FullName
    IsInherited = $psitem.IsInherited
    AccessRights = $psitem.AccessRights
    Account = $psitem.Account
    }
}

## Export CSV of folders where inheritance is false
$a | Where-Object {$psitem.IsInherited -eq $false -and $psitem.Account -notmatch "Administrators|S-1-5-21"} | Export-Csv -nti "\\path\to\Profiles_CustomPermissions.csv"

## Export CSV of folders to be deleted/moved to "\\path\to\profiles\terminated"
$a | Select-Object -Property FolderName -Unique | Export-Csv -nti "\\path\to\Profiles_ToBeDeleted.csv"