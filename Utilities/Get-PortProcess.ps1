function Get-PortProcess {
    [CmdletBinding()]
    param (
        [string[]]
        $Computername,

        [string]
        $Port
    )

    Begin {
        $Session = New-PSSession -ComputerName $Computername
    }
    Process {
        Invoke-Command -Session $Session -ScriptBlock {
            Get-Process -Id (Get-NetTCPConnection -LocalPort $using:port).OwningProcess | ForEach-Object {
                [pscustomobject]@{
                    Name           = $_.Name
                    Path           = $_.Path
                    SHA256         = Get-FileHash -Path $_.Path | Select-Object -ExpandProperty Hash
                    Port           = $using:port
                    Company        = $_.Company
                    ProductVersion = $_.ProductVersion
                    Product        = $_.Product
                    Computer       = $env:COMPUTERNAME
                }
            }
        }
    }
    End {

    }
    
}