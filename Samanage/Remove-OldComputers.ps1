function Remove-OldComputers {
    
    <#
    .SYNOPSIS
        Removes computers from Samanage that haven't been online in 2 months.
    .EXAMPLE
        PS C:\> Remove-OldComputers -api xxx
        Returns list of all old computers
        PS C:\> Remove-OldComputers -api xxx -delete
        Deletes computers from Samanage that haven't been online in 2 months.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$api,
        [switch]$delete
    )

    begin {
        ## Connect to Samanage
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Accept", 'application/vnd.samanage.v2.1+json')
        $headers.Add("X-Samanage-Authorization", "Bearer $api")
        $contenttype = "application/json"
        $uri = "https://api.samanage.com/hardwares.json"
        $data = Invoke-WebRequest -Uri $Uri -Header $headers -ContentType $contentType -Method Get

        ## Get last page
        $lastpage = $data.headers.'X-Total-Pages'

        (1..($lastpage)) | ForEach-Object {
            $splat = @{
                Uri         = "$uri?page=$_"
                Header      = $headers
                ContentType = $contentType
                Method      = "Get"
            }
            $hardware += Invoke-RestMethod @splat
        }
        $inventory = ForEach ($item in $hardware) {
            [PScustomobject]@{
                ComputerName = $item.name
                Model        = $item.Model
                LastUpdated  = [datetime](Get-Date $($item.Updated_at) -Format "MM/dd/yyyy")
                UserName     = $item.UserName
                OS_Version   = $item.operating_system_version
                ComputerID   = $item.id
            }
        }
        $old_computers = $inventory | Where-Object {$PSItem.LastUpdated -lt (Get-Date).AddMonths(-2)}
    }

    process {
        if ($Delete) {
            ## Delete old computers
            foreach ($id in $old_computers.ComputerID) {
                $deletesplat = @{
                    URI = "$apiRoot/hardwares/$id.json"
                    Headers = $headers
                    ContentType = $contenttype
                    Method = "Delete"
                }
                Invoke-WebRequest @deletesplat
            }
        }
        else {
            return $old_computers
        }
    }
}

