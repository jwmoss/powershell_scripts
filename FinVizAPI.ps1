## URL
$url = "https://finviz.com/screener.ashx?v=111&f=cap_small,sh_avgvol_u1000,sh_float_u20,sh_price_u3&ar=180"

$stock_url = "https://finviz.com/quote.ashx"
$news_url = "https://finviz.com/news.ashx"
$crypto_url = "https://finviz.com/crypto_performance.ashx"
$stock_page = @{}

$ticker = "IDEX"

if ($PSVersionTable.PSVersion.Major -lt 6) {
    "powershell 5.1"

    $page = iwr -Uri ($stock_url + "?t=$ticker")

    $title = $page.ParsedHtml.body.getElementsByClassName('fullview-title')
}
else {
    Import-Module PowerHTML -ErrorAction Stop

    $page = Invoke-WebRequest -Uri ($stock_url + "?t=$ticker")

    $rawhtml = ConvertFrom-Html $page.RawContent

    $title = ((($rawhtml.Descendants()).where{$_.HasClass("fullview-title") -eq "True" }).InnerText -split "`n")[1]
    $titleData = ((($rawhtml.Descendants()).where{$_.HasClass("fullview-title") -eq "True" }).InnerText -split "`n")

    $title = $titleData[2]
    $Keys = @("Company","Sector","Industry","Country")

    $fields = (($rawhtml.Descendants()).where{$_.HasClass("tab-link") -eq "True"})

    $allrows = (($rawhtml.Descendants()).where{$_.HasClass("table-dark-row") -eq "True"})

    [PSCustomObject]@{
    #    Company = $titleData[2]
    #    Index = ($allrows[0].InnerText -split "`n")[1] -replace "Index"
    #    "P/E" = ($allrows[0].InnerText -split "`n")[2] -replace "P\/E"
    #    "Perf Week" = ($allrows[0].InnerText -split "`n")[6] -replace "Perf Week"
    #    "Perf Month" = ($allrows[1].InnerText -split "`n")[6] -replace "Perf Month"
    #    "Shs Float" = ($allrows[1].InnerText -split "`n")[5] -replace "Shs Float"
    }

}

function Get-FVStock {
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

    [PSCustomObject]@{
        Company = $titleData[2]
        Index = ($allrows[0].InnerText -split "`n")[1] -replace "Index"
        "P/E" = ($allrows[0].InnerText -split "`n")[2] -replace "P\/E"
        "Perf Week" = ($allrows[0].InnerText -split "`n")[6] -replace "Perf Week"
        "Perf Month" = ($allrows[1].InnerText -split "`n")[6] -replace "Perf Month"
        "Shs Float" = ($allrows[1].InnerText -split "`n")[5] -replace "Shs Float"
    }

    [PSCustomObject]@{
    #    Company = $titleData[2]
    #    Sector = $titleData[3].Split("|")[0]
    #    Industry = $titleData[3].Split("|")[1].Trim()
    #    Country = $titleData[3].Split("|")[2].Trim()
    }

}

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

Get-FVVolume -Stock IDEX