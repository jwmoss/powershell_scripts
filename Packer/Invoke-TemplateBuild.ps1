function Invoke-TemplateBuild {
    param (
        [Parameter(Mandatory = $true)]
        [string]$vCenterServer,
        [Parameter(Mandatory = $true)]
        [string]$TemplateFolder,
        [Parameter(Mandatory = $true)]
        [string]$TemplateName,
        [Parameter(Mandatory = $true)]
        [string]$ConfigurationFile
    )
 
    <#
.SYNOPSIS
    Executes Packer Template Build against a vCenter. This script is designed to run from Jenkins.
.EXAMPLE
    PS C:\> Invoke-TemplateBuild.ps1 -vCenter vcenter.fqdn.com -TemplateFolder TemplateFolder -TemplateName Win2016 -ConfigurationFile Server2016.json
    Executes packer.exe, connects to a vCenter and moves the template to the correct folder.
.NOTES
    v1.0.0 - 7/9/18 - Jonathan Moss
    v1.0.1 - 7/11/18 - Remove existing template prior to deploying new one
    v1.0.2 - 10/22/18 - Added parameters to support targetting multiple vCenters
#>

    Import-Module VMware.PowerCLI | Out-Null

    ## Define Jenkins parameters and pass through credentials stored in Jenkins using Credentials Binding plugin.
    $SecurePassword = $env:vCenterPassword | ConvertTo-SecureString -AsPlainText -Force
    $vCenterCred = New-Object System.Management.Automation.PSCredential -ArgumentList $env:vCenterAdmin, $SecurePassword

    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

    ## Connect to vCenter with stored credentials
    try {
        Connect-VIServer -Server $vCenterServer -Protocol https -Credential $vCenterCred -ErrorAction Stop
        Write-Output "Successfully connected to $vcenterServer! Continuing.."   
    }
    catch {
        Write-Output "Could not connect to $vcenterserver"
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
    }

    try {
        $VMTemplate = Get-Template -Name $TemplateName -ErrorAction STOP
        if ($VMTemplate) {
            try {
                Remove-Template -Template $VMTemplate -Confirm:$false -ErrorAction STOP
            }
            catch {
                ## If template is found, yet can't be removed, exit the script.
                Write-Output "Could not delete, skipping..."
                Write-Output "Manually delete $VMTemplate from $vcenterServer"
                Break
            }
        }   
    }
    catch {
        Write-Host "No template found! Continuing.."
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
    }

    $params = @{
        FilePath         = "$ENV:WORKSPACE\Binaries\packer.exe"
        ArgumentList     = "build -var `"password=$($env:vCenterPassword)`" -var `"winrm_password=$($env:LocalAdminPassword)`" `"$($ENV:WORKSPACE)\ConfigurationFiles\$ConfigurationFile`""
        WorkingDirectory = "$ENV:WORKSPACE\Packer"
    }

    Start-Process @params -NoNewWindow -Wait

    ## Get existing folder where templates are stored

    $TemplateFolder = Get-Folder -Name $TemplateFolder

    ## Move template that was created from script to the destination template folder
    $a = Get-Template -Name $TemplateName
    $b = Get-Folder -Name $TemplateFolder
    Get-Template $a | Move-Template -Destination $b

    ## Disconnect from vCenter
    Disconnect-VIServer $vCenterServer -Confirm:$False
}