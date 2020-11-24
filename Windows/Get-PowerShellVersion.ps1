function Get-PowerShellVersion {
    [CmdletBinding()]
    param (
        [string[]]
        $ComputerName
    )
    
    begin {
        $Session = New-PSSession -ComputerName $ComputerName
    }
    
    process {
        Invoke-Command -Session $Session -ScriptBlock {
            $PSVersionTable.PSVersion
        }
    }
    
    end {
        Get-PSSession | Remove-PSSession
    }
}