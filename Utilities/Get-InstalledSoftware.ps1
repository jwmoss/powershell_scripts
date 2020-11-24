function Get-InstalledSoftware {
    <#
    .SYNOPSIS
        Get all installed from the Uninstall keys in the registry.
    .DESCRIPTION
        Read a list of installed software from each Uninstall key.

        This function provides an alternative to using Win32_Product.
    .EXAMPLE
        Get-InstalledSoftware

        Get the list of installed applications from the local computer.
    .EXAMPLE
        Get-InstalledSoftware -IncludeLoadedUserHives

        Get the list of installed applications from the local computer, including each loaded user hive.
    .EXAMPLE
        Get-InstalledSoftware -ComputerName None -DebugConnection

        Display all error messages thrown when attempting to audit the specified computer.
    .EXAMPLE
        Get-InstalledSoftware -IncludeBlankNames

        Display all results, including those with very limited information.
    #>

    [CmdletBinding()]
    [OutputType([PSObject])]
    param (
        # The computer to execute against. By default, Get-InstalledSoftware reads registry keys on the local computer.
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$ComputerName = $env:COMPUTERNAME,

        # Attempt to start the remote registry service if it is not already running. This parameter will only take effect if the service is not disabled.
        [Switch]$StartRemoteRegistry,

        # Some software packages, such as DropBox install into a users profile rather than into shared areas. Get-InstalledSoftware can increase the search to include each loaded user hive.
        #
        # If a registry hive is not loaded it cannot be searched, this is a limitation of this search style.
        [Switch]$IncludeLoadedUserHives,

        # By default Get-InstalledSoftware will suppress the display of entries with minimal information. If no DisplayName is set it will be hidden from view. This behaviour may be changed using this parameter.
        [Switch]$IncludeBlankNames
    )

    $keys = 'Software\Microsoft\Windows\CurrentVersion\Uninstall',
    'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'

    # If the remote registry service is stopped before this script runs it will be stopped again afterwards.
    if ($StartRemoteRegistry) {
        $shouldStop = $false
        $service = Get-Service RemoteRegistry -Computer $ComputerName

        if ($service.Status -eq 'Stopped' -and $service.StartType -ne 'Disabled') {
            $shouldStop = $true
            $service | Start-Service
        }
    }

    $baseKeys = [System.Collections.Generic.List[Microsoft.Win32.RegistryKey]]::new()

    $baseKeys.Add([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName, 'Registry64'))
    if ($IncludeLoadedUserHives) {
        try {
            $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('Users', $ComputerName, 'Registry64')
            foreach ($name in $baseKey.GetSubKeyNames()) {
                if (-not $name.EndsWith('_Classes')) {
                    Write-Debug ('Opening {0}' -f $name)

                    try {
                        $baseKeys.Add($baseKey.OpenSubKey($name, $false))
                    }
                    catch {
                        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                            $_.Exception.GetType()::new(
                                ('Unable to access sub key {0} ({1})' -f $name, $_.Exception.InnerException.Message.Trim()),
                                $_.Exception
                            ),
                            'SubkeyAccessError',
                            'InvalidOperation',
                            $name
                        )
                        Write-Error -ErrorRecord $errorRecord
                    }
                }
            }
        }
        catch [Exception] {
            Write-Error -ErrorRecord $_
        }
    }

    foreach ($baseKey in $baseKeys) {
        Write-Verbose ('Reading {0}' -f $baseKey.Name)

        if ($basekey.Name -eq 'HKEY_LOCAL_MACHINE') {
            $username = 'LocalMachine'
        }
        else {
            # Attempt to resolve a SID
            try {
                [System.Security.Principal.SecurityIdentifier]$sid = Split-Path $baseKey.Name -Leaf
                $username = $sid.Translate([System.Security.Principal.NTAccount]).Value
            }
            catch {
                $username = Split-Path $baseKey.Name -Leaf
            }
        }

        foreach ($key in $keys) {
            try {
                $uninstallKey = $baseKey.OpenSubKey($key, $false)

                if ($uninstallKey) {
                    $is64Bit = $true
                    if ($key -match 'Wow6432Node') {
                        $is64Bit = $false
                    }

                    foreach ($name in $uninstallKey.GetSubKeyNames()) {
                        $packageKey = $uninstallKey.OpenSubKey($name)

                        $installDate = Get-Date
                        $dateString = $packageKey.GetValue('InstallDate')
                        if (-not $dateString -or -not [DateTime]::TryParseExact($dateString, 'yyyyMMdd', (Get-Culture), 'None', [Ref]$installDate)) {
                            $installDate = $null
                        }

                        [PSCustomObject]@{
                            Name            = $name
                            DisplayName     = $packageKey.GetValue('DisplayName')
                            DisplayVersion  = $packageKey.GetValue('DisplayVersion')
                            InstallDate     = $installDate
                            InstallLocation = $packageKey.GetValue('InstallLocation')
                            HelpLink        = $packageKey.GetValue('HelpLink')
                            Publisher       = $packageKey.GetValue('Publisher')
                            UninstallString = $packageKey.GetValue('UninstallString')
                            URLInfoAbout    = $packageKey.GetValue('URLInfoAbout')
                            Is64Bit         = $is64Bit
                            Hive            = $baseKey.Name
                            Path            = Join-Path $key $name
                            Username        = $username
                            ComputerName    = $ComputerName
                        }
                    }
                }
            }
            catch {
                Write-Error -ErrorRecord $_
            }
        }
    }

    # Stop the remote registry service if required
    if ($StartRemoteRegistry -and $shouldStop) {
        $service | Stop-Service
    }
}
