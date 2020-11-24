
Function Convert-SIDToUsername {
    <#  
    .SYNOPSIS  
        This cmdlet takes in SID and translate them to Domain UserID.
    .DESCRIPTION 
        This cmdlet takes in SID and translate them to Domain UserID.
    .NOTES  
        Author:  Teng Yang
    .PARAMETER SIDs
		String object variable that takes in one SID or a group of many SID
    .EXAMPLE
	    Convert-SIDToUsername -SIDs 'S-1-5-21-296299305-573448302-1760960739-35799'
		Convert-SIDToUsername -SIDs '$GroupOfSID'
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [string[]]
        $SIDs
    )
    
    Foreach ($SID in $SIDs) {
        Try {
            $SID = [System.Security.Principal.SecurityIdentifier]$SID
            $userID = $SID.Translate([System.Security.Principal.NTAccount])
            $list = Select-Object -InputObject "" Name, SID
            $list.Name = $userID.value
            $list.SID = $SID.value
            $list
        }
        Catch {
            Write-Warning ("Unable to translate SID: $SID.")
        }
    }
}