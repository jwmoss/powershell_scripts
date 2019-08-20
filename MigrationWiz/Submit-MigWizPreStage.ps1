Function Submit-MigWizPreStage {

    <#
    .SYNOPSIS
        Submits a project for pre-staging.
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> Submit-MigWizPreStage -Name "ProjectName"
        Starts pre-staging the migrationwiz project name called ProjectName
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

        Try {
            $MWproject = Get-MW_MailboxConnector -Ticket $global:mwticket -Name $name -ErrorAction Stop
            $items = Get-MW_Mailbox -ticket $global:mwticket -FilterBy_Guid_ConnectorId $MWproject.Id -ErrorAction Stop
            foreach ($item in $items) {
                $PreStageSplat = @{
                    Ticket      = $global:mwticket
                    MailboxID   = $item.Id
                    Type        = "Full"
                    ConnectorID = $MWproject.Id
                    UserID      = $global:mwticket.UserID
                    ItemType    = "Mail"
                    ItemEndDate = ((Get-Date).AddDays(-1))
                    ErrorAction = "Stop"
                }
                $null = Add-MW_MailboxMigration @PreStageSplat
                Write-Verbose "Successfully started MigrationWiz Prestage for $($item.exportemailaddress)!"
            }
        }
        Catch {
            Write-Error "Could not start pre-stage batch migration $name. Start manually!"
        }
    }
}

