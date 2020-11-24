function Get-2012R2Servers {
    [cmdletbinding()]
    Param (
        [string]
        $Domain
    )

    $filter = 'OperatingSystem -like "{0}"' -f "*2012*"

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