#Requires -Module PoshRSJob
function Get-LocalAdmins {
    
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]
        $ComputerName
    )
    
    Start-RSJob -InputObject $computername -Throttle "20" -ScriptBlock {          
        Invoke-Command -ComputerName $_ -ScriptBlock {
            $members = net localgroup administrators | where {$_ -AND $_ -notmatch "command completed successfully"} | select -skip 4
            New-Object PSObject -Property @{
                Computername = $env:COMPUTERNAME
                Group        = "Administrators"
                Members      = $members
            }
        }
    } | Wait-RSJob -ShowProgress -Timeout 60 | Receive-RSJob   
}