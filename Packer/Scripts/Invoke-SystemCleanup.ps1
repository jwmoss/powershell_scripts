<#
    .SYNOPSIS
    Performs cleanup of aesthetic artifacts on the system.
    
 #>

# Remove icon files from the desktop.
Try {
    Write-Host "Cleaning up icon files."
    Remove-Item "$Env:SystemDrive\Users\admin\Desktop\*" -Force -Recurse
    Remove-Item "$Env:SystemDrive\Users\Public\Desktop\*" -Force -Recurse 
}
Catch {
    Write-Error "Could not delete desktop icon files as part of the cleanup script. Exiting."
    Write-Host $_.Exception | format-list -force
    Exit 1
}

# Remove Run Key Persistence
Try {
    Write-Host "Cleaning up registry keys."
    Remove-ItemProperty 'HKLM:\SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Run' -Name * -Force
    Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name * -Force
    Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name * -Force
}
Catch {
    Write-Error "Could not remove run keys as part of the cleanup script. Exiting."
    Write-Host $_.Exception | format-list -force
    Exit 1
}

# Remove Chocolatey and its settings/dependencies
Try {
    Write-Host "Removing Chocolatey and all packages from image."
    Remove-Item -Recurse -Force "$env:ChocolateyInstall"
    [System.Text.RegularExpressions.Regex]::Replace([Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(), [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | % {[System.Environment]::SetEnvironmentVariable('PATH', $_, 'User')}
    [System.Text.RegularExpressions.Regex]::Replace([Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString(), [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | % {[System.Environment]::SetEnvironmentVariable('PATH', $_, 'Machine')}
}
Catch {
    Write-Error "Could not remove Choclatey as part of the cleanup script. Exiting."
    Write-Host $_.Exception | format-list -force
    Exit 1
}

try {
    if ($env:ChocolateyBinRoot -ne '' -and $env:ChocolateyBinRoot -ne $null) { Remove-Item -Recurse -Force "$env:ChocolateyBinRoot" -WhatIf }
    if ($env:ChocolateyToolsRoot -ne '' -and $env:ChocolateyToolsRoot -ne $null) { Remove-Item -Recurse -Force "$env:ChocolateyToolsRoot" -WhatIf }
    [System.Environment]::SetEnvironmentVariable("ChocolateyBinRoot", $null, 'User')
    [System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $null, 'User')
}
catch {
    Write-Error "Could not remove Choclatey as part of the cleanup script. Exiting."
    Write-Host $_.Exception | format-list -force
    Exit 1
}


# Delete Packer Directory
Try {
    Remove-Item -Path "$Env:SystemDrive\packer\" -Recurse -Force | Out-Null
}
Catch {
    Write-Error "Could not clean up packer folder. Exiting."
    Write-Host $_.Exception | format-list -force
    Exit 1
}