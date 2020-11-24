function Install-dotnet35 {
    [CmdletBinding()]
    param (
        [string]
        $ComputerName,

        [string]
        $ISOPATH,

        [string]
        $ISOName
    )
    
    process {
        
        $copysplat = @{
            Path        = $ISOPATH
            Destination = "\\$computername\c$"
            Force       = $true
        }

        Copy-Item @copysplat -Verbose

        ## Install .NET 3.5
        Invoke-Command -ComputerName $Computername -ScriptBlock {
            try {
                $Mountiso = Mount-DiskImage -ImagePath "C:\$ISOName" -ErrorAction Stop -PassThru
            }
            catch {
                Write-Warning "Unable to mount"
                return
            }
        
            $volume = (Get-Volume -DiskImage $Mountiso).DriveLettter
        
            Install-WindowsFeature -Name Net-Framework-Core -Source "$volume`:\sources\sxs"
        
            Dismount-DiskImage $Mountiso.ImagePath

            Get-ChildItem -Path "C:\$ISONAME" | Remove-Item -Force
        }

    }

}