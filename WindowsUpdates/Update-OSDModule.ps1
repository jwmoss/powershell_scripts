function Update-OSDModule {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Uninstall-Module -Name OSDSUS -AllVersions -Force
    Install-Module -Name OSDSUS -Force
}