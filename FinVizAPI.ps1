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
    "powershell 7"

    $page = iwr -Uri ($stock_url + "?t=$ticker")

    $rawhtml = ConvertFrom-Html $page.RawContent

    $title = $rawhtml.where( { $_.HasClass("fullview-title") -eq "True" })

}
