function Get-MigWizMailboxError {

    <#
    .SYNOPSIS
        Check for any mailbox errors for a migrationwiz project.
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> Get-MigWizMailboxError -Name "ProjectName"
        Retrieves mailbox errors (if there are any) for migrationwiz project called "Projectname"
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name
    )

    Process {
        $MWproject = Get-MW_MailboxConnector -Ticket $global:mwticket -Name $name -ErrorAction Stop
        $items = Get-MW_Mailbox -ticket $global:mwticket -FilterBy_Guid_ConnectorId $MWproject.Id -ErrorAction Stop
        Foreach ($mailbox in $items) {
            $migrationerrors = Get-MW_MailboxError -Ticket $global:mwticket -MailboxId $mailbox.id
            if ($MigrationErrors) {
                @($migrationerrors).ForEach( {
                        [PSCustomObject]@{
                            Mailbox       = $mailbox.ExportEmailAddress
                            HasErrors     = "Yes"
                            ContainerName = $migrationerrors.ContainerName[0]
                            ItemSubject   = $migrationerrors.ItemSubject[0]
                            Message       = $migrationerrors.Message[0]
                            CreateDate    = $migrationerrors.CreateDate[0]
                        }
                    }
                )
            }
            else {
                [PSCustomObject]@{
                    Mailbox       = $mailbox.ExportEmailAddress
                    HasErrors     = "No"
                    ContainerName = $null
                    ItemSubject   = $null
                    Message       = $null
                    CreateDate    = $null
                }
            }
        }
    }

}