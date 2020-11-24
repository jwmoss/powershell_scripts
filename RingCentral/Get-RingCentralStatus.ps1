Function Get-RingCentralStatus {

    <#
.SYNOPSIS
    Retrives Ring Central status from their website
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> Get-RingCentralStatus -ShowOutput
    Gets the status and outputs a message
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $ShowOutput
    )

    Begin {

        $URL = "https://status.ringcentral.com/status.json" 
    }
    Process {
        $RingCentralServices = Invoke-RestMethod -Method Get -Uri $URL

        $RingCentral = $RingCentralServices | Where-Object {$psitem.region -eq "Americas" -and $psitem.Service -match "Calling|Meetings"}

    }
    End {
        if ($PSBoundParameters.ContainsKey('ShowOutput')) {
            foreach ($monitor in $RingCentral) {
                Write-Output "$($monitor.Service) - $($monitor.level)"
            }
        }
        else {
            $RingCentral
        }

    }
}