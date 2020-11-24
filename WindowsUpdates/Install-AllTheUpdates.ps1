#Requires -Module Invoke-CommandAs,PSWindowsupdate
function Install-AllTheUpdates {
    [CmdletBinding()]
    param (
        [string[]]
        $Computername,

        [string]
        $TitleExclusion,

        [switch]
        $Reboot,

        [switch]
        $FromWSUS
    )
    
    Begin {
        $Session = New-PSSession -ComputerName $Computername
    }

    Process {

        if ($TitleExclusion -and $reboot) {
            Write-host "Installing Windows Updates on $computername using Microsoft Update, excluding $TitleExclusion and rebooting" -ForegroundColor Cyan
            Invoke-CommandAs -Session $Session -Scriptblock {
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Verbose -NotTitle $using:TitleExclusion -AutoReboot
            } -AsSystem
        }

        if ($Reboot) {
            Write-host "Installing Windows Updates on $computername using Microsoft Update and rebooting" -ForegroundColor Cyan
            Invoke-CommandAs -Session $Session -Scriptblock {
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Verbose -AutoReboot
            } -AsSystem
        }

        if ($Reboot -and $FromWSUS) {
            Write-host "Installing Windows Updates on $computername using WSUS and rebooting" -ForegroundColor Cyan
            Invoke-CommandAs -Session $Session -Scriptblock {
                Install-WindowsUpdate -AcceptAll -Verbose -AutoReboot
            } -AsSystem
        }

        if (-not ($Reboot -or $FromWSUS -or $TitleExclusion)) {
            Write-host "Installing Windows Updates on $computername using Microsoft update" -ForegroundColor Cyan
            Invoke-CommandAs -Session $Session -Scriptblock {
                Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Verbose
            } -AsSystem
        }

    }

    End {

    }

}