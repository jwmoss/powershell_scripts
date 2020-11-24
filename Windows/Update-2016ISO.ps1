#Requires -Module OSDBuilder
function Update-2016ISO {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ISOPath
    )

    ## Initialise OSDBuilder and check some config ##
    Get-OSDBuilder -SetHome C:\OSDBuilder
    Get-OSDBuilder -CreatePaths

    if(-not (Test-Path -Path "C:\WindowsISOCache")){
        New-Item -Path "C:\" -ItemType Directory -Name WindowsISOCache
    }

    ## Mount the reference image  
    Mount-DiskImage -ImagePath $ISOPath -Verbose

    ## Import the media, update it and run a OSBuild for each index ## 
    Import-OSMedia -ImageIndex 4 -Update -SkipGrid

    ## Eject the reference image ##
    Dismount-DiskImage -ImagePath $ISOPath -Verbose
    
    ## Copy the new ISOs to a different folder and rename with version. ##
    $folders = Get-ChildItem -Path "C:\OSDBuilder\OSBuilds"
    
    foreach ($item in $folders) {
        
        ## Create ISOs ##
        New-OSBMediaISO -FullName $item.FullName
    
        ## Get the ISO and work out name ##
        $iso = Get-ChildItem -Path "C:\OSDBuilder\OSBuilds\$($item.Name)\ISO"
    
        if (-not (Test-Path -Path "C:\WindowsISOCache\$($item.Name).iso")) {
        
            ## Copy the ISO over if its not already there ##
            Write-Host "## INFO ## ISO for this version not found, copying to the cache"
            Copy-Item -Path $iso.FullName -Destination "C:\WindowsISOCache\$($item.Name).iso" -Verbose
        
        }
        else {
    
            ## Do nothing if it exists ##
            Write-Host "## INFO ## ISO already exists in the cache. Skipping...."
    
        }
    
    }
}