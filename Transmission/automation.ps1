. (Join-Path -Path ($ENV:HOME) -ChildPath "powershell_scripts" -AdditionalChildPath "Transmission", "transmission.ps1")

$token = get-content (Join-Path -Path ($ENV:HOME) -ChildPath "powershell_scripts" -AdditionalChildPath "Transmission", "token.txt")
$securePwd = ConvertTo-SecureString $token -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("jwmoss", $securePwd)

Get-Torrent -Credential $Credential