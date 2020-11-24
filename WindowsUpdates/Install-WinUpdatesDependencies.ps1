function Install-WinUpdatesDependencies {
    [CmdletBinding()]
    param (
        [string[]]
        $Computername
    )
    
    Begin {
        
        $Session = New-PSSession -ComputerName $COMPUTERNAME

        $nugetpath = "\\path\to\nuget\NuGet"

        Invoke-Command -Session $session -ScriptBlock {
            New-Item -Name "NuGet" -ItemType Directory -Path "C:\Program Files\PackageManagement\ProviderAssemblies"
        }
    
        Copy-Item $nugetpath -Destination "C:\Program Files\PackageManagement\ProviderAssemblies" -ToSession $session -Recurse -Force
        
    }

    Process {

        Invoke-Command -Session $session -Scriptblock {
            $PSSplat = @{
                Name               = "nugetreponame"
                SourceLocation     = "https://nugetrepo/repository/powershell-modules/"
                InstallationPolicy = "Trusted"
            }
        
            Register-PSRepository @PSSplat
        
            Install-Module -Name "PSWindowsUpdate", "Invoke-CommandAs" -Repository "nugetreponame"
        }

    }

    End {

    }

}