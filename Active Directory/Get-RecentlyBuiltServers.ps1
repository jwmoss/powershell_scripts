function Get-RecentlyBuiltServers {
    [cmdletbinding()]
    Param (
        [string]
        $Domain
    )

    $When = ((Get-Date).AddDays(-31)).Date

    $filter = { whenCreated -ge $When -and OperatingSystem -like "*Server*" }

    $adproperties = @(
        'PasswordLastSet',
        'Description',
        'WhenCreated',
        'OperatingSystem',
        'Managedby'       
    )

    $ComputerSplat = @{
        Filter     = $filter
        Properties = $adproperties
        Server     = $domain
    }
    
    Get-ADComputer @ComputerSplat
    
}