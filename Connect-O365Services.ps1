function Connect-O365Services{
    [CmdletBinding()]
    param (
        [string]$TenantDomain
    )
    
    #requires -modules MSonline, SkypeOnlineConnector, Microsoft.Online.Sharepoint.Powershell

    $credential = Get-Credential
    Connect-MsolService -Credential $credential
    Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    Connect-SPOService -Url https://$TenantDomain-admin.sharepoint.com -credential $credential
    Import-Module SkypeOnlineConnector
    $sfboSession = New-CsOnlineSession -Credential $credential
    Import-PSSession $sfboSession
    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
    Import-PSSession $exchangeSession
    $SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication "Basic" -AllowRedirection
    Import-PSSession $SccSession -Prefix cc

}



