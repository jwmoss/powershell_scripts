#Requires -Module Invoke-CommandAs,PSWindowsupdate
Function Get-PendingWindowsUpdate {
    [CmdletBinding()]
    param (
        [string[]]
        $Computername,

        [switch]
        $Online
    )

    $Session = New-PSSession -ComputerName $Computername

    if ($Online) {
        Write-host "Checking for windows updates online" -ForegroundColor Cyan
        Invoke-CommandAs -Session $Session -Scriptblock {
            Import-Module PSWindowsupdate
            (Get-WUList -MicrosoftUpdate -Verbose).ForEach({$_ | Select-Object KB,ComputerName,Title})
        } -AsSystem
    }
    else {
    Write-host "Checking for windows updates using WSUS" -ForegroundColor Cyan
        Invoke-CommandAs -Session $Session -Scriptblock {
            Import-Module PSWindowsupdate
            (Get-WUList -Verbose).ForEach({$_ | Select-Object KB,ComputerName,Title})
        } -AsSystem
    }

    Get-PSSession | Remove-PSSession
}