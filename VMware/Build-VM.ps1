<#
.SYNOPSIS
  Creates a virtual machine in a vCenter environment and adds additional information to Active Directory.
.DESCRIPTION
  In order to automate the creation of virtual machines in a vCenter environment, this script will clone a virtual
  machine from a template in vCenter, join the machine to a domain, update the AD description, create a group designated
  for administrators of the virtual machine, move the virtual machine to its final Organizational Unit, and send an email
  once the job is completed.
.NOTES
  Version:        1.0
  Author:         Jonathan Moss
  Creation Date:  7/10/17
  Purpose/Change: Initial upload to Github
.EXAMPLE
  .\Build-VM.ps1
#>

## Disconnects from any existing vCenter connection
Disconnect-VIServer * -confirm:$false

## Import Modules to support connecting to vCenter and connecting to Active Directory (AD)
Import-Module ActiveDirectory
Import-Module VMware.PowerCLI

## Define variables to be used in creating the Virtual Machine and within AD
$vc = Read-Host "Enter vCenter Server hostname or IP address"
$name = Read-Host "Enter the Server Name"
$ipaddress = Read-Host "Enter IP Address"
$subnet = Read-Host "Enter Subnet, i.e. 255.255.255.0"
$gateway = Read-Host "Enter Gateway"
$dns1 = Read-Host "Enter primary DNS server"
$dns2 = Read-Host "Enter secondary DNS server"
$zonename = Read-Host "Enter Zone name for DNS"
$dnsserver = Read-Host "Enter hostname for DNS Server that will be used to update DNS"
$clustername = Read-Host "Enter the cluster name for $vc"
$template = Read-Host "Enter the template to be used to clone VM from"
$customization = Read-Host "Enter the customization to be used within the template"
$NewDatastore = Read-Host "Enter the datastore to be used in $vc"
$networkname = Read-Host "Enter the network name to be used for the primary virtual nic for $name"
$ADDescription = Read-Host "Enter AD Description of $name"
$targetOU = Read-Host "Enter target OU to move Computer object to, I.E 'OU=Computers,DC=blah,DC=blah' "
Write-Output "Enter AD credentials that allow the Virtual Machine to be joined to the domain"
$mycredential = Get-Credential
$to = Read-Host "Enter the recipients of the new virtual machine email notification"
$from = Read-Host "Enter the sender of the new virtual machine email notification"
$smtpserver = Read-Host "Enter the SMTP Server hostname"

## Create AD Group for AD Administrators for the Virtual Machine
$administrator = "_Administrators"
$group = $name + $administrator
$path = Read-Host "Enter target OU to create the administrator groups for $name, I.E 'OU=Users,DC=blah,DC=blah'"

$adgroupvars = @{
    
    Name          = $group
    GroupScope    = Global
    Description   = "Members with Local Administrator Rights on $name"
    GroupCategory = Security
    Path          = $path
}

New-ADGroup @adgroupvars

## Connect to vCenter
Connect-VIServer $vc

## Remove existing customization spec
Get-OSCustomizationSpec $customization | Get-OSCustomizationNicMapping | Remove-OSCustomizationNicMapping -Confirm:$false

## Configure networking information for the new customization spec
$vmnetwork = @{
    
    OSCustomizationSpec = $customization
    IpMode              = UseStaticIP
    IpAddress           = $ipaddress
    SubnetMask          = $subnet
    DefaultGateway      = $gateway
    DNS                 = $dns1, $dns2
    Position            = 1
}

New-OSCustomizationNicMapping @vmnetwork

## Define the customization spec using domain credentials
Set-OSCustomizationSpec $customization -DomainCredentials $mycredential

## Create the new VM from template

$virtualmachine = @{
    
    Name                = $name
    Template            = $template
    Resourcepool        = $clustername
    Datastore           = $NewDatastore
    OSCustomizationSpec = $customization
    Confirm             = $false
}

New-VM @virtualmachine

## Configures networking for the VM
Get-VM -Name $name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $networkname -Confirm:$false

## Powering on the machine
Start-VM -vm $name -Confirm:$false

## Add DNS Record
Add-DnsServerResourceRecordA -Name $name -IPv4Address $ipaddress -ZoneName $zonename -ComputerName $dnsserver -CreatePtr

## Wait until computer is on the domain, and then move it to the right OU
do {
	  	Write-Host "." -nonewline -ForegroundColor Red
	  	Start-Sleep 5
} until (Get-ADComputer -Filter {Name -eq $name})

Get-ADComputer $name | Move-ADobject -targetpath $targetOU

## Set AD Description
Set-ADComputer -Identity $Name -Description $ADDescription

## Send Completion Email
Send-MailMessage -To $to -From $from -Subject "New VM $name Created" -SmtpServer $smtpserver

## Disconnect from vCenter		
Disconnect-VIServer * -Confirm:$false