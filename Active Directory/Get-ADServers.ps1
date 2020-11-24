function Get-ADServers {
    [CmdletBinding()]
    param (
        [string]
        $Domain
    )
    
    Get-ADComputer -Filter { OperatingSystem -like "*Windows Server*" } -Properties OperatingSystem -Server $domain | ForEach-Object {
        [pscustomobject]@{
            DNS = $_.DNSHostName
            OS  = $_.OperatingSystem
            OU  = ([regex]::match($_.distinguishedName, '(?=OU)(.*\n?)(?<=.)').Value)
        }
    }

}