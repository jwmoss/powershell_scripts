#Requires -Module VcRedist  
function Install-VCRuntime {
    [CmdletBinding()]
    param (
        [string]
        $ComputerName,
        
        [Parameter(Mandatory)]  
        [ValidateSet(
            "2008",
            "2010",
            "2012",
            "2013",
            "2019"
        )]
        [string]
        $Version,

        [Parameter(Mandatory)]
        [ValidateSet(
            "x64",
            "x86"
        )]
        [string]
        $OSType,

        [switch]
        $Local
    )

    $nugetpath = "\\path\to\nuget"

    $session = New-PSSession -ComputerName $ComputerName

    Invoke-Command -Session $session -ScriptBlock {
        New-Item -Name "NuGet" -ItemType Directory -Path "C:\Program Files\PackageManagement\ProviderAssemblies" -ErrorAction SilentlyContinue
    }

    Copy-Item $nugetpath -Destination "C:\Program Files\PackageManagement\ProviderAssemblies" -ToSession $session -Recurse -Force

    if ($Local) {
        
        Copy-Item "C:\Program Files\WindowsPowerShell\Modules\VcRedist" -ToSession $session -Destination "C:\Program Files\WindowsPowerShell\Modules" -Recurse -Force

        Copy-Item "C:\Temp\VcRedist" -ToSession $session -Destination "C:\" -Recurse -Force
        
        Invoke-Command -Session $session -Scriptblock {
            ## store them to a variable
            $VcList = Get-VcList -Release $using:version -Architecture $using:OSType
    
            ## Install it from the local path
            Install-VcRedist -Path C:\VcRedist -VcList $VcList
        } 
    }
    else {

        Invoke-Command -Session $session -Scriptblock {

            ## Set TLS to TLS 1.2
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
            ## trust the psgallery
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    
            ## Install VcRedist module from powershell gallery
            Install-Module -Name VcRedist -Repository "PSGallery"
    
            Import-Module VcRedist -Force
    
            ## store them locally
            New-Item C:\Temp\VcRedist -ItemType Directory -Force
    
            ## save them to c:\temp
            Get-VcList -Release $using:version -Architecture $using:OSType | Save-VcRedist -Path C:\Temp\VcRedist
    
            ## store them to a variable
            $VcList = Get-VcList -Release $using:version -Architecture $using:OSType
    
            ## Install it from the local path
            Install-VcRedist -Path C:\Temp\VcRedist -VcList $VcList
    
            ## Uninstall the module
            Uninstall-Module VcRedist -Force
        }
    }


}