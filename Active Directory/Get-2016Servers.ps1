function Get-2016Servers {
    [cmdletbinding()]
    Param (
        [string]
        $Domain
    )

    $filter = 'OperatingSystem -like "{0}"' -f "*2016*"

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