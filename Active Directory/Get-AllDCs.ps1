
Function Get-AllDCs {
    Get-ADDomainController -filter * | Select-Object Name, Operatingsystem, Domain, Site | ForEach-Object {
        $ipaddress = resolve-dnsname $_.Name -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Name   = $_.Name
            IP     = $ipaddress.IPAddress
            OS     = $_.OperatingSystem
            Domain = $_.Domain
            Site   = $_.Site
        }
    }
}