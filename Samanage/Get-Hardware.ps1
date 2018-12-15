function Get-Hardware {
  
    <#
.SYNOPSIS
  Connects to Samanage API and outputs hardware information
.DESCRIPTION
  In order to get an accurate view of hardware stored in Samanage, this script will loop through each page via the JSON
  API call and output information regarding the models stored in Samanage.
.NOTES
  Version:        1.0
  Author:         Jonathan Moss
  Creation Date:  12/14/18
  Purpose/Change: More
  Requires Powershell Core
.EXAMPLE
  .\Get-Hardware.ps1
#>

#Requires -Version 6.0

    [CmdletBinding()]
    param (
        [string]$api
    )

    ## Define variables. Fill in the API key in line 21 after Bearer
    $apiRoot = "https://api.samanage.com"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Accept", 'application/vnd.samanage.v2.1+json')
    $headers.Add("X-Samanage-Authorization", "Bearer $api")
    $contentType = "application/json"
    $data = Invoke-WebRequest -Uri "$apiRoot/hardwares.json" -Header $headers -ContentType $contentType -Method Get

    $hardware = @()

    ## Gets the last page of the JSON output since Samanage limits their pages to 100 rows
    $lastpage = $($data.RelationLink.Values | ForEach-Object { $_.Values} | Select-Object -Last 1) -replace '(.*)='

    ## Loops through pages 1 through whatever the last page is and retrives the JSON information for hardware
    (1..($lastpage)) | ForEach-Object {
        $hardware += Invoke-RestMethod -Uri "$apiRoot/hardwares.json?page=$_" -Header $headers -ContentType $contentType -Method Get
    }

    ## Takes the full JSON output and selects certain information
    $hardware
}
