function New-MigWizProject {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [string]$ProjectName
    )

    Begin {
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }

        $btcreds = Import-Clixml "$ENV:LOCALAPPDATA\O365Migration\MWCred.xml"

        $btticket = Get-BT_Ticket -Credentials $btcreds -ServiceType BitTitan

        $customer = Get-BT_Customer -Ticket $btticket -CompanyName "CompanyName"

        $importEndpoint = Get-BT_Endpoint -Ticket $btticket -Name "TenantName O365"
        $exportEndpoint = Get-BT_Endpoint -Ticket $btticket -Name "On-PremSourceName"

        $importConfiguration = New-Object -TypeName MigrationProxy.WebApi.ExchangeConfiguration -Property @{
            "UseAdministrativeCredentials" = $true;
            "ExchangeItemType"             = "Mail";
        }

        $exportConfiguration = New-Object -TypeName MigrationProxy.WebApi.ExchangeConfiguration -Property @{
            "UseAdministrativeCredentials" = $true;
            "ExchangeItemType"             = "Mail";
        }

        [string]$advancedoptions = 'UseEwsImportImpersonation=1', 'Tags=IpLockDown!'

        $connectorsplat = @{
            Ticket                   = $Global:mwticket
            ProjectType              = "Mailbox"
            ExportType               = "ExchangeServer"
            ImportType               = "ExchangeOnline2"
            Name                     = $ProjectName
            UserId                   = $Global:mwticket.UserId
            SelectedExportEndpointID = $exportEndpoint.Id
            SelectedImportEndpointID = $importEndpoint.Id
            ImportConfiguration      = $importConfiguration
            ExportConfiguration      = $exportConfiguration
            OrganizationId           = $customer.OrganizationId
            AdvancedOptions          = $advancedoptions
            Tags                     = "IpLockDown!"
            Flags                    = "LogFailedItemSubjects"
            PurgePeriod              = "180"
            MaxLicensesToConsume     = "1"
            MaximumItemFailures      = "1000"
        }
    }

    Process {
        if ($PSCmdlet.ShouldProcess("New migration wiz project?")) {
            # Create the project
            Add-MW_MailboxConnector @connectorsplat
        }
    }
}
