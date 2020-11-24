Function Get-RecentlyLoggedOnUsers {
    [cmdletbinding()]
    param (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $ComputerName
    )   
    
    $output = Invoke-Command -ComputerName $computername -ScriptBlock {
        get-ChildItem -Path "C:\Users\*\AppData\Local\Microsoft\Windows\UsrClass.dat" -Force | Select-Object @{Label = "User"; Expression = {($_.directory).tostring().split("\")[2]}}, LastWriteTime
    }
    
    $output | Sort-Object LastWriteTime -Descending
    
}
