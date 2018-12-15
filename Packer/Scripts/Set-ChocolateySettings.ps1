Try 
{
	# Set Default Chocolatey Settings

	# Set global confirmation
	choco feature enable -n allowGlobalConfirmation

	# Allow empty checksums for HTTPS
	choco feature enable -n allowemptychecksumsecure

	# Disable package exit codes
	choco feature disable -n usePackageExitCodes

	# Disable animated download progress bar
	choco feature disable -n showDownloadProgress

}
Catch
{
	Write-Host "Error occurred. Exiting."
	Write-Host $_.Exception | format-list -force
	Exit 1
}
