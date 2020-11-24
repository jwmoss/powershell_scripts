#Requires -Modules OSDUpdate,OSDSUS,Invoke-CommandAs
function Install-OfficeUpdates {
    [CmdletBinding()]
    param (
        [string[]]
        $ServerName,

        [Parameter(Mandatory)]
        [ValidateSet(
            "Office2010",
            "Office2013",
            "Office2016"
        )]
        $OfficeVersion,

        [Parameter(Mandatory)]
        [ValidateSet(
            "x86",
            "x64"
        )]
        $OS
    )

    $filepath = "E:\$OfficeVersion" + "_" + "$OS"
    switch ($OfficeVersion) {
        "Office2010" {
                
            if ($OS -eq "x86") {

                ## Create a patch group for newest patches for Office 2010
                New-OSDUpdatePackage -PackageName 'Office 2010 32-Bit' -OfficeProfile Default -PackagePath $filepath -AppendPackageName -RemoveSuperseded
    
                ## Copy the path to the Servers
                $ServerName | ForEach-Object {
                    Copy-Item $filepath -Destination "\\$_\c$\" -Recurse -Force
                }
    
                Invoke-CommandAs -ComputerName $ServerName -ScriptBlock {
                    & "C:\Office2010_x86\Office 2010 32-Bit\Install-OSDUpdatePackage.ps1"
                }
            }
            else {
                ## Create a patch group for newest patches for Office 2010
                New-OSDUpdatePackage -PackageName 'Office 2010 64-Bit' -OfficeProfile Default -PackagePath $filepath -AppendPackageName -RemoveSuperseded
    
                ## Copy the path to the Servers
                $ServerName | ForEach-Object {
                    Copy-Item $filepath -Destination "\\$_\c$\" -Recurse -Force
                }
                    
                Invoke-CommandAs -ComputerName $ServerName -ScriptBlock {
                    & "C:\Office2010_x64\Office 2010 64-Bit\Install-OSDUpdatePackage.ps1"
                }
            }

                
        }
        "Office2013" {
                
            if ($OS -eq "x86") {

                ## Create a patch group for newest patches for Office 2010
                New-OSDUpdatePackage -PackageName 'Office 2013 32-Bit' -OfficeProfile Default -PackagePath $filepath -AppendPackageName -RemoveSuperseded
                
                ## Copy the path to the Servers
                $ServerName | ForEach-Object {
                    Copy-Item $filepath -Destination "\\$_\c$\" -Recurse -Force
                }
    
                Invoke-CommandAs -ComputerName $ServerName -ScriptBlock {
                    & "C:\Office2013_x86\Office 2013 32-Bit\Install-OSDUpdatePackage.ps1"
                }
            }
            else {
                ## Create a patch group for newest patches for Office 2010
                New-OSDUpdatePackage -PackageName 'Office 2013 64-Bit' -OfficeProfile Default -PackagePath $filepath -AppendPackageName -RemoveSuperseded
    
                ## Copy the path to the Servers
                $ServerName | ForEach-Object {
                    Copy-Item $filepath -Destination "\\$_\c$\" -Recurse -Force
                }
                    
                Invoke-CommandAs -ComputerName $ServerName -ScriptBlock {
                    & "C:\Office2013_x64\Office 2013 64-Bit\Install-OSDUpdatePackage.ps1"
                }
            }

        }
        "Office2016" {
            if ($OS -eq "x86") {

                ## Create a patch group for newest patches for Office 2010
                New-OSDUpdatePackage -PackageName 'Office 2016 32-Bit' -OfficeProfile Default -PackagePath $filepath -AppendPackageName -RemoveSuperseded
    
                ## Copy the path to the Servers
                $ServerName | ForEach-Object {
                    Copy-Item $filepath -Destination "\\$_\c$\" -Recurse -Force
                }
    
                Invoke-CommandAs -ComputerName $ServerName -ScriptBlock {
                    & "C:\Office2016_x86\Office 2016 32-Bit\Install-OSDUpdatePackage.ps1"
                }
            }
            else {
                ## Create a patch group for newest patches for Office 2010
                New-OSDUpdatePackage -PackageName 'Office 2016 64-Bit' -OfficeProfile Default -PackagePath $filepath -AppendPackageName -RemoveSuperseded
    
                ## Copy the path to the Servers
                $ServerName | ForEach-Object {
                    Copy-Item $filepath -Destination "\\$_\c$\" -Recurse -Force
                }
                    
                Invoke-CommandAs -ComputerName $ServerName -ScriptBlock {
                    & "C:\Office2016_x64\Office 2016 64-Bit\Install-OSDUpdatePackage.ps1"
                }
            }
        }
        Default {
        }
    }
    
}