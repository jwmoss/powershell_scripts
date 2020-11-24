function Update-AllModules {
    Get-Module -ListAvailable | 
    Where-Object { $_.Path -like "C:\Program Files\WindowsPowerShell\Modules*" } |
    ForEach-Object {
        $currentVersion = [Version] $_.Version
        $newVersion = [Version] (Find-Module -Name $_.Name -Repository "PSGallery").Version
        if ($newVersion -gt $currentVersion) {
            Write-Host -Object "Updating $_ Module from $currentVersion to $newVersion"
            Update-Module -Name $_.Name -RequiredVersion $newVersion -Force
            Uninstall-Module -Name $_.Name -RequiredVersion $currentVersion -Force
        }
    }
}