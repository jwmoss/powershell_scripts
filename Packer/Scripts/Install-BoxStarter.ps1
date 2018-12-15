<#  
	.SYNOPSIS  
	Installs Boxstarter from their website
	.NOTES 
	Performs an installation of the most recent stable version of Boxstarter. 
#>

$PackageName = "boxstarter"

Try {
    . { Invoke-WebRequest -UseBasicParsing https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; get-boxstarter -Force
}
Catch {
    Write-Host "Fatal erorr installing package $PackageName. Exiting."	
    Exit 1
}