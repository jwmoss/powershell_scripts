function Get-DsRegStatus {
    <#
    .Synopsis
    Returns the output of dsregcmd /status as a PSObject.
 
    .Description
    Returns the output of dsregcmd /status as a PSObject. All returned values are accessible by their property name.
 
    .Example
    # Displays a full output of dsregcmd / status.
    Get-DsRegStatus
    #>
    $dsregcmd = dsregcmd /status
    $o = New-Object -TypeName PSObject
    $dsregcmd | Select-String -Pattern " *[A-z]+ : [A-z]+ *" | ForEach-Object {
        Add-Member -InputObject $o -MemberType NoteProperty -Name (([String]$_).Trim() -split " : ")[0] -Value (([String]$_).Trim() -split " : ")[1]
    }
    return $o
}