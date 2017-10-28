<#
.SYNOPSIS
  Connects to Samanage API and outputs hardware information
.DESCRIPTION
  In order to get an accurate view of hardware stored in Samanage, this script will loop through each page via the JSON
  API call and output information regarding the models stored in Samanage.
.NOTES
  Version:        1.0
  Author:         Jonathan Moss
  Creation Date:  9/16/17
  Purpose/Change: Initial script development
  Requires Powershell Core
.EXAMPLE
  .\Get-Hardware.ps1
#>

## Define variables. Fill in the API key in line 21 after Bearer
$apiRoot = "https://api.samanage.com"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept", 'application/vnd.samanage.v2.1+json')
$headers.Add("X-Samanage-Authorization", 'Bearer xxxxxxxx')
$contentType = "application/json"
$data = Invoke-WebRequest -Uri "$apiRoot/hardwares.json" -Header $headers -ContentType $contentType -Method Get

## Gets the last page of the JSON output since Samanage limits their pages to 100 rows
$lastpage = $($data.RelationLink | Select-Object Values | ForEach-Object { $_.Values} | Select-Object -Last 1) -replace '(.*)='

## Loops through pages 1 through whatever the last page is and retrives the JSON information for hardware
(1..($lastpage)) | ForEach-Object {
    $data2 += Invoke-RestMethod -Uri "$apiRoot/hardwares.json?page=$_" -Header $headers -ContentType $contentType -Method Get
}

## Takes the full JSON output and selects certain information
$data2 | Select-Object name, username, description, model