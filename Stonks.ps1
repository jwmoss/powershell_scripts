function Get-FVVolume {
    [CmdletBinding()]
    param (
        [string]
        $Stock
    )
    
    $stock_url = "https://finviz.com/quote.ashx"

    Import-Module PowerHTML -ErrorAction Stop

    $page = Invoke-WebRequest -Uri ($stock_url + "?t=$stock")

    $rawhtml = ConvertFrom-Html $page.RawContent

    $titleData = ((($rawhtml.Descendants()).where{$_.HasClass("fullview-title") -eq "True" }).InnerText -split "`n")

    $allrows = (($rawhtml.Descendants()).where{$_.HasClass("table-dark-row") -eq "True"})

    $avg_volume = ($allrows[10].InnerText -split "`n")[5] -replace "Avg Volume"
    $rel_volume = ($allrows[9].InnerText -split "`n")[5] -replace "Rel Volume" 
    $volume = ($allrows[11].InnerText -split "`n")[5] -replace "Volume"
    $price = ($allrows[10].InnerText -split "`n")[6] -replace "Price"
    $float = ($allrows[1].InnerText -split "`n")[5] -replace "SHS Float"

    if ($rel_volume -match "M") {
        $avg_volume_match = "{0:N}" -f ([int]($avg_volume -replace "M"))
        $avg_volume_final = "{0:N0}" -f ([int]$avg_volume_match*1000000)
    }

    if ($avg_volume -match "M") {
        $avg_volume_match = "{0:N}" -f ([int]($avg_volume -replace "M"))
        $avg_volume_final = "{0:N0}" -f ([int]$avg_volume_match*1000000)
    }

    if ($float -match "M") {
        $float_volume_match = "{0:N}" -f ([int]($float -replace "M"))
        $float_final = "{0:N0}" -f ([int]$float_volume_match*1000000)
    }

    $rel_volume_final = "{0:P}" -f ($volume / $avg_volume_final)

    [PSCustomObject]@{
        Company = $titleData[2]
        Price = "{0:C}" -f $price
        "Avg Volume" = $avg_volume_final
        "Rel Volume" = $rel_volume_final
        Volume = $volume
        Float = $float_final
    }

}
Function Get-PennyStockDD {
    [alias("gpsdd")]
    [CmdletBinding()]
    param (

    )

    $ps_dd = (Invoke-RestMethod "https://www.reddit.com/r/pennystocks/search/.json?sort=new&restrict_sr=on&q=flair%3ADD").data.children.data |
    Where-Object { $_.Title -like "*$*" } | Sort-Object -Property Title 
    $stockpattern = [regex]::new('[$][A-Za-z][\S]*')

    $results = foreach ($p in $ps_dd) {
        $results = $p.title | Select-String $stockpattern -AllMatches
        [PSCustomObject]@{
            Date = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($p.created))
            Title = $p.title
            Ticker = $results.Matches.Value
        }        
    }
    $results | Sort-Object -Property Date -Descending
}