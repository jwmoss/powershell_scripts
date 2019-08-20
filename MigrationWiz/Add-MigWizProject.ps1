Function Add-MigWizProject {

    <#
    .SYNOPSIS
        Creates a new project in MigrationWiz and adds users to it.
    .EXAMPLE
        PS C:\> Set-MigWizToken -Credential (Get-Credential)
        PS C:\> Import-Module 'C:\Program Files (x86)\BitTitan\BitTitan PowerShell\BitTitanPowerShell.dll'
        PS C:\> $emails = @("user@domain.com","user2@domain.com")
        PS C:\> Add-MigWizProject -Name "MigrationProjectName" -Emails $emails 
    .NOTES
        Creates a new project in MigrationWiz and adds users via email addresses to it, and sets the
        upn suffix to @domain.onmicrosoft.com.
        Make sure to run Set-MigWizToken before running this.
    #>

    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name,

        [parameter(Mandatory = $true)]
        [string[]]
        $Emails,

        [parameter(Mandatory = $true)]
        [string[]]
        $Domain
    )

    Process {

        ## Check to make sure the project doesn't exist
        $MWproject = Get-MW_MailboxConnector -Ticket $global:mwticket -Name $name -ErrorAction SilentlyContinue

        if ($null -ne $MWproject) {
            Write-Error -Message "$Name already exists in MigrationWiz!"
        }
        else {
            ## This assumes you already have a project called "Rescheduled". This will place those users into this new project.
            ## Convert @$domain.com emails to @$domain.onmicrosoft.com emails, add to MigWiz Project, and add to group to create cloud mailbox
            $RescheduledProject = Get-MW_MailboxConnector -Ticket $global:mwticket -Name "Rescheduled"

            try {
                $RescheduledMailboxes = Get-MW_Mailbox -ConnectorId $RescheduledProject.Id -Ticket $global:mwticket -RetrieveAll -ErrorAction Stop
            }
            catch {
                Write-Error "Could not retrieve all mailboxes in Rescheduled project." -ForegroundColor Red
                Return
            }

            ## Create a project in Migration Wiz
            $null = New-MigWizProject -ProjectName $Name -Confirm:$false

            ## Get the project
            $MWproject = Get-MW_MailboxConnector -Ticket $global:mwticket -Name $name -ErrorAction SilentlyContinue

            foreach ($user in $emails) {
                ## Create cloud user
                $cloudUser = ($user -split '@')[0] + "@$domain.onmicrosoft.com"
                ## Get rescheduled user in migwiz and move to new project
                if ($null -ne $RescheduledMailboxes) {
                    if ($RescheduledMailboxes.ExportEmailAddress.contains($user)) {
                        $Mailbox = $RescheduledMailboxes | Where-Object { $psitem.ExportemailAddress -eq $user }
                        try {
                            $null = Set-MW_Mailbox -Ticket $global:mwticket -ConnectorId $MWProject.Id -mailbox $mailbox -ErrorAction Stop
                            Write-Verbose "Successfully moved $user to $name Project in MigrationWiz."
                        }
                        catch {
                            Write-Error "Unable to add $user to $name Project in MigrationWiz. Move manually."
                        }
                    }
                    else {
                        try {
                            $null = Add-MW_Mailbox -Ticket $global:mwticket -ConnectorId $MWproject.id -ImportEmailAddress $cloudUser -ExportEmailAddress $user -Flags "3" -ErrorAction Stop | Out-Null
                            Write-Verbose "Added $clouduser to MigrationWiz Project:`t $name"
                        }
                        catch {
                            Write-Error "$cloudUser could not be added to MigrationWiz Project: $name"
                        }
                    }
                }
                else {
                    try {
                        $null = Add-MW_Mailbox -Ticket $global:mwticket -ConnectorId $MWproject.id -ImportEmailAddress $cloudUser -ExportEmailAddress $user -Flags "3" -ErrorAction Stop | Out-Null
                        Write-Verbose "Added $clouduser to MigrationWiz Project: $name"
                    }
                    catch {
                        Write-Error "$cloudUser could not be added to MigrationWiz Project: $name"
                    }
                }
            }
        }
    }
}