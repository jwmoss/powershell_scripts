function Get-FVVolume {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0, 
            Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
        ]
        [string[]]
        $Stock,

        [Parameter(
            Position = 1, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)
        ]
        [string[]]
        $URL
    )
    
    Begin {
        $stock_url = "https://finviz.com/quote.ashx"

        Import-Module PowerHTML -ErrorAction Stop
    }

    process {
        foreach ($s in $stock) {
            Write-Verbose "Processing $s"

            try {
                $page = Invoke-WebRequest -Uri ($stock_url + "?t=$s") -ErrorAction "stop"
            }
            catch {
                Write-Warning "Couldnot find $s"
                break
            }

            $rawhtml = ConvertFrom-Html $page.RawContent
        
            $titleData = ((($rawhtml.Descendants()).where{ $_.HasClass("fullview-title") -eq "True" }).InnerText -split "`n")
            $titleData
            $allrows = (($rawhtml.Descendants()).where{ $_.HasClass("table-dark-row") -eq "True" })
        
            $avg_volume = ($allrows[10].InnerText -split "`n")[5] -replace "Avg Volume"
            $rel_volume = ($allrows[9].InnerText -split "`n")[5] -replace "Rel Volume" 
            $volume = ($allrows[11].InnerText -split "`n")[5] -replace "Volume"
            $price = ($allrows[10].InnerText -split "`n")[6] -replace "Price"
            $float = ($allrows[1].InnerText -split "`n")[5] -replace "SHS Float"
            
            if ($rel_volume -match "M") {
                $avg_volume_match = "{0:N}" -f ([int]($avg_volume -replace "M"))
                $avg_volume_final = "{0:N0}" -f ([int]$avg_volume_match * 1000000)
            } 
            else {
                $rel_volume = "{0:N}" -f [int]($rel_volume)
                $rel_volume_final = "{0:N0}" -f ([int]$rel_volume * 1000)
            }
            
            if ($avg_volume -match "M") {
                $avg_volume_match = "{0:N}" -f ([int]($avg_volume -replace "M"))
                $avg_volume_final = "{0:N0}" -f ([int]$avg_volume_match * 1000000)
            }

            if ($avg_volume -match "K") {
                $avg_volume_match = "{0:N}" -f ([int]($avg_volume -replace "K"))
                $avg_volume_final = "{0:N0}" -f ([int]$avg_volume_match * 1000)
            }
        
            if ($float -match "M") {
                $float_volume_match = "{0:N}" -f ([int]($float -replace "M"))
                $float_final = "{0:N0}" -f ([int]$float_volume_match * 1000000)
            }
        
            Write-Host "$volume % $avg_volume_final"
            $rel_volume_final = "{0:P}" -f ($volume / $avg_volume_final)
            
            [PSCustomObject]@{
                Stock        = ($titleData[1] -split " ")[0]
                Company      = $titleData[2]
                Price        = "{0:C}" -f $price
                "Avg Volume" = $avg_volume_final
                "Rel Volume" = $(New-Text $rel_volume_final -fg Cyan)
                Volume       = $volume
                Float        = $float_final
                FinVizURL    = "https://finviz.com/quote.ashx?t={0}&ty=c&ta=1&p=d" -f $s
                RedditURL    = $URL
            }
        }
    } 

    End {

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

    foreach ($p in $ps_dd) {
        $results = $p.title | Select-String $stockpattern -AllMatches
        $url = $p.URL
        $results_value = ($results.Matches.Value)

        if ($results_value -like "*:*" -and $results_value -like "*$*") {
            $ticker = ($results_value -replace ":") -replace "\$"
        }
        elseif ($results_value -like "*$*") {
            $ticker = $results_value -replace "\$"
        }
        elseif ($results_value -like "*$*" -and $results_value -like "*)*") {
            $ticker = ($results_value -replace "\$") -replace ")"
        }
        else {
            $ticker = $results_value
        }

        [PSCustomObject]@{
            Date  = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($p.created))
            Title = $p.title
            Stock = $ticker
            URL   = $url
        }        
    }
}

Function Get-RedditDD {
    [alias("grdd")]
    [CmdletBinding()]
    param (
        [ValidateSet('PS', 'SSB', 'WSB')]
        [string]
        $Reddit
    )



    Begin {

        $stockpattern = [regex]::new("(?<Stock>[a-z]{1,4}|\d{1,3}(?=\.)|\d{4,})")
    
        switch ($Reddit) {
            "PS" {  
                $url = "https://www.reddit.com/r/pennystocks/search/.json?sort=new&restrict_sr=on&q=flair%3ADD"
            }
            "SSB" {
                $url = "https://www.reddit.com/r/smallstreetbets/search/.json?sort=new&restrict_sr=on&q=flair%3AEpic%2BDD%2BAnalysis"
            }
            "WSB" {
                $url = "https://www.reddit.com/r/wallstreetbets/search/.json?sort=new&restrict_sr=on&q=flair%3ADD"
            }
            Default {}
        }
    }

    Process {

        $ps_dd = (Invoke-RestMethod $url).data.children.data |
        Where-Object { $_.Title -match $stockpattern } | Sort-Object -Property Title 

        foreach ($p in $ps_dd) {
            $results = $p.title | Select-String $stockpattern -AllMatches
            $url = $p.URL
            $results_value = ($results.Matches.Value)

            if ($null -eq $results_value) {
                Write-host "Could not find stock ticker in reddit Title $($p.title)"
                Continue
            }

            if ($results_value -like "*:*" -and $results_value -like "*$*") {
                $ticker = ($results_value -replace ":") -replace "\$"
            }
            elseif ($results_value -like "*$*") {
                $ticker = $results_value -replace "\$"
            }
            else {
                $ticker = $results_value
            }

            [PSCustomObject]@{
                Date  = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($p.created))
                Title = $p.title
                Stock = $ticker
                URL   = $url
            }     
        }   
    }
    End {

    }
}

function Start-StonkWatch {
    [CmdletBinding()]
    param (
        [ValidateSet('PS', 'SSB', 'WSB')]
        [string]
        $Reddit
    )
    
    begin {
        
    }
    
    process {

        switch ($Reddit) {
            "PS" { 
                $results = Get-RedditDD -Reddit PS
            }
            "SSB" {
                $results = Get-RedditDD -Reddit SSB
            }
            "WSB" {
                $results = Get-RedditDD -Reddit WSB
            }
            Default {}
        }

        $results | Get-FVVolume | Sort-Object -Property "Rel Volume" -Descending 
    }
    
    end {
        
    }
}

#Start-StonkWatch -Reddit WSB | Format-Table -AutoSize
#Start-StonkWatch -Reddit SSB | Format-Table -AutoSize
#Start-StonkWatch -Reddit PS | Format-Table -AutoSize