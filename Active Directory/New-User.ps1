<#
.SYNOPSIS
  Creates a new user in Active Directory based on an existing user and synchronizes the account to Azure AD.
.DESCRIPTION
  In order to automate the creation of a new user in Active Directory, this script will prompt for information for the user,
  clone the similar users groups into the new user, license them based on an AD group that licenses users in Azure AD using
  Azure AD Group Licensing (https://docs.microsoft.com/en-us/azure/active-directory/active-directory-licensing-group-migration-azure-portal)
  initiate an Azure AD Connect synchronization to synchronize them to Azure AD/Office 365, wait until the mailbox is created,
  and then copies the similar user's "cloud only" distribution group (this script was for a hybrid environment) to the 
  newly created user, and then assigns them a mobile extension that is unused in Active Directory.

  TLDR: simplifies the new user creation process in Active Directory :)
.NOTES
  Version:        2.1
  Author:         Jonathan Moss
  Creation Date:  4/10/17
  Purpose/Change: Initial upload to Github
.EXAMPLE
  .\New-User.ps1
#>

## Imports the necessary modules to create the new user.
Import-Module ActiveDirectory

$first = read-Host "Enter the new user's first name"
$last = read-Host "Enter the new user's last name"
## Gets the users first initial of first name and last name for an smtp alias
$flast = $first.Substring(0, 1) + $last
$Name = $first + ' ' + $last
$Title = read-host "Enter the job title for $Name"
$similaruser = read-Host "Enter Account Similar to $Name, IE 'John Doe'"
$Department = read-Host "Enter the $Name's department"
$Description = read-host "Enter AD Description for $Name"
$Manager1 = read-Host "Enter the name of the person who $Name reports to, IE 'John Doe'"
$Manager = Get-ADUser -Filter {Name -like $Manager1}
$Office = read-Host "Enter the Office location"
$Phone = Read-Host -Prompt "Will $Name need a phone extension? (Yes or No)"
$Company = read-host "Enter the company name"
$un = $first + '.' + $last
$pw = Read-Host -AsSecureString 'Secure Password'
$oupath = Read-Host "Enter $Name's path in Active Directory, I.E 'OU=Users,DC=blah,DC=blah'"
$dc = Read-Host "Enter the domain controller that the user will be created from"
$dc3 = Read-Host "Enter the hostname of the domain controller that the user will be created on"
$dc4 = Read-Host "Enter the hostname of the domain controller that is in the same AD Site as the Azure AD Connect Server"
$aadc = Read-Host "Enter the hostname of the Azure AD Connect Server"

$variables = @{
    
    Enabled              = $True
    AccountPassword      = $pw
    Path                 = $oupath
    Department           = $Department
    Company              = $Company
    Manager              = $Manager
    Description          = $Description
    DisplayName          = $Name
    Office               = $Office
    Server               = $dc
    Title                = $Title
    SamAccountName       = $un
    GivenName            = $first
    Surname              = $last
    OtherAttributes      = @{userprincipalname = "$un@blah.com"; mail = "$un@blah.com"; proxyaddresses = "SMTP:$un@blah.com"}
    Passwordneverexpires = $True
}
    
New-ADUser $Name @variables

## Adds additional proxyaddresses such as the SIP Address for Skype and alias' for email
Set-ADUser -Identity $un -Server $dc -ChangePasswordAtLogon $false -Add @{proxyaddresses = "smtp:$flast@blah.com"}
Set-ADUser -Identity $un -Server $dc -Add @{proxyaddresses = "smtp:$un@blah.mail.onmicrosoft.com"}
Set-ADUser -Identity $un -Server $dc -Add @{proxyaddresses = "smtp:$un@blahold.com"}
Set-ADUser -Identity $un -Server $dc -Add @{proxyaddresses = "SIP:$un@blah.com"}

## Adds newly created user to same AD groups as a similar user
Get-ADUser -Filter {Name -eq $similaruser} -Server $dc -Properties memberof | Select-Object -ExpandProperty memberof | Where-Object {$_ -notlike "*EMS*"} | Add-ADGroupMember -Members $un -Server $dc -PassThru | Select-Object -Property SamAccountName

## Adds Azure EMS E3 Licensing via AD Group
Add-ADGroupMember -Identity "Azure_EMS_E3_Licensing" -Members $un -Server $dc

## Sync object from DC1 to DC3 since the original DC is in another AD site
Sync-ADObject -Object $oupath -Source $dc3 -Destination $dc4

## Wait before Syncing On-prem to AzureAD
Start-Sleep -Seconds 60

## Connects to Azure AD Connect Server and forces a replication to O365
Invoke-Command -Computername $aadc -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Initial -ErrorAction Stop
    #Wait 10 seconds for the sync connector to wake up.
    Start-Sleep -Seconds 10
    #Display a progress indicator and hold up the rest of the script while the sync completes.
    While (Get-ADSyncConnectorRunStatus) {
        Write-Host "." -NoNewline -ForegroundColor White
        Start-Sleep -Seconds 10
    }
}

## Disconnect from Invoked Session
Get-PSSession | Remove-PSSession

## Connects to O365 Using MFA. Thanks to https://github.com/Scine/Powershell for this section.
Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA + "\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName| Where-Object {$_ -notmatch "_none_"}| Select-Object -First 1)
$EXOSession = New-ExoPSSession
Import-PSSession $EXOSession -AllowClobber

## Wait until the new user is synchronized to O365
do {
	  	Write-Host "." -nonewline -ForegroundColor Red
	  	Start-Sleep 5      
} until (Get-Mailbox $un)

## This section copies the cloud distribution lists from the similar user to the new user

$Mailbox = Get-Mailbox $similaruser
$DN = $Mailbox.DistinguishedName
$Filter = "Members -like ""$DN"""
$CloudDistributionLists = (Get-DistributionGroup -ResultSize Unlimited -Filter $Filter | Where-Object {$_.IsDirSynced -eq $False}).Name

ForEach ($CloudDistributionList in $CloudDistributionLists) { 
    Add-DistributionGroupMember -Identity $CloudDistributionList -Member $Name
}

## ipPhone will be configured. If answered 'Yes' will search the 3xx extension scope to autmatically select an extension for the new user
$IPPhone = Get-ADUser -Filter 'ipPhone -like "*"' -Properties ipPhone | Select-Object -ExpandProperty ipPhone

if ($Phone -eq "Yes") {
    foreach ( $Ext in ( 300..399 ) ) {
        if ( $IPPhone -notcontains $Ext ) {
            $Extension = $Ext
            break
        }
    }
    
}
else {
    exit
}

#Assign new user the unused extension number
Set-ADUser -Identity $un -Add @{ipPhone = $Extension}