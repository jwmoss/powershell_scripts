function Get-2008R2Servers {
    [cmdletbinding()]
    Param (
        [string]
        $Domain
    )

    $filter = 'OperatingSystem -like "{0}"' -f "*2008*"

    $properties = @(
        'Name',
        'Enabled',
        'PasswordLastSet',
        'DNSHostName',
        'Description',
        'CanonicalName',
        'OperatingSystem',
        'ManagedBy'
    )

    $ADComputerSplat = @{
        Filter     = $filter
        Properties = $properties
        Server     = $domain
    }
  
    Get-ADComputer @ADComputerSplat

}