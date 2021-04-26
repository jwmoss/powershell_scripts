function Get-PercentChange {
    [Alias("gpc")]
    [CmdletBinding()]
    param (
        [string]
        $Begin = 6.92,

        [string]
        $End = 8.60,

        [string]
        $Investment = 725.10
    )

    [PSCustomObject]@{
        Percentage = [int32](($End - $Begin) / $Begin * 100)
        Profit = (([int32](($End - $Begin) / $Begin * 100)) / 100) * $Investment
    }

}
