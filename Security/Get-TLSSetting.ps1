function Get-TLSSetting {
    [CmdletBinding()]
    param (
        [string[]]
        $ComputerName = $ENV:COMPUTERNAME
    )

    ## Get Cipher Suite Values
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {

        $ErrorActionPreference = "SilentlyContinue"

        ## Check SSL v2
        $ssl2clientenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl2clientdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $ssl2serverenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl2serverdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue

        ## Check SSL v3
        $ssl3clientenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl3clientdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $ssl3serverenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl3serverdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue

        ## Check TLS 1.0
        $tls1clientenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls1clientdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $tls1serverenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls1serverdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        
        ## Check TLS 1.1
        $tls11clientenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls11clientdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $tls11serverenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls11serverdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        
        ## Check TLS 1.2
        $tls12clientenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls12clientdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $tls12serverenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls12serverdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue   

        ## Check TLS 1.3
        $tls13clientenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls13clientdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $tls13serverenabled = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $tls13serverdisabledbydefault = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue   

        ## Check Diffie Hellman
        $DiffieHellman = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman" -Name "Enabled" -ErrorAction SilentlyContinue
        $DiffieHellmanKeyBit = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman" -Name "ServerMinKeyBitLength" -ErrorAction SilentlyContinue

        ## Check Weak Ciphers
        $RC4128 = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" -Name "Enabled" -ErrorAction SilentlyContinue
        $RC456128 = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" -Name "Enabled" -ErrorAction SilentlyContinue
        $RC440128 = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" -Name "Enabled" -ErrorAction SilentlyContinue
        $tripledes168 = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -Name "Enabled" -ErrorAction SilentlyContinue
        
        ## SSL v2 Client Stuff
        if ((($ssl2clientenabled -eq 0) -and ($ssl2clientdisabledbydefault -eq 1)) -or ($null -eq $ssl2clientenabled) -and ($null -eq $ssl2clientdisabledbydefault)) {
            $ssl2clientenabled_result = $False
        }
        elseif (($ssl2clientenabled -eq 1) -and ($ssl2clientdisabledbydefault -eq 1)) {
            $ssl2clientenabled_result = "Partial"
        }
        elseif (($ssl2clientenabled -eq 0) -and ($ssl2clientdisabledbydefault -eq 0)) {
            $ssl2clientenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($ssl2clientenabled -eq 0) -and ($ssl2clientdisabledbydefault -eq 0)) {
            $ssl2clientenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($ssl2clientdisabledbydefault -eq 0) -and ($null -eq $ssl2clientenabled)) {
            $ssl2clientenabled_result = "Partial"
        }
        else {
            $ssl2clientenabled_result = $True
        }

        ## SSL v2 Server Stuff
        if ((($ssl2serverenabled -eq 0) -and ($ssl2serverdisabledbydefault -eq 1)) -or ($null -eq $ssl2serverenabled) -and ($null -eq $ssl2serverdisabledbydefault)) {
            $ssl2serverenabled_result = $False
        }
        elseif (($ssl2serverenabled -eq 1) -and ($ssl2serverdisabledbydefault -eq 1)) {
            $ssl2serverenabled_result = "Partial"
        }
        elseif (($ssl2serverenabled -eq 0) -and ($ssl2serverdisabledbydefault -eq 0)) {
            $ssl2serverenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($ssl2serverenabled -eq 0) -and ($ssl2serverdisabledbydefault -eq 0)) {
            $ssl2serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($ssl2serverdisabledbydefault -eq 0) -and ($null -eq $ssl2serverenabled)) {
            $ssl2serverenabled_result = "Partial"
        }
        else {
            $ssl2serverenabled_result = $True
        }

        ## SSL v3 Client Stuff
        if ((($ssl3clientenabled -eq 0) -and ($ssl3clientdisabledbydefault -eq 1)) -or ($null -eq $ssl3clientenabled) -and ($null -eq $ssl3clientdisabledbydefault)) {
            $ssl3clientenabled_result = $False
        }
        elseif (($ssl3clientenabled -eq 1) -and ($ssl3clientdisabledbydefault -eq 1)) {
            $ssl3clientenabled_result = "Partial"
        }
        elseif (($ssl3clientenabled -eq 0) -and ($ssl3clientdisabledbydefault -eq 0)) {
            $ssl3clientenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($ssl3clientenabled -eq 0) -and ($ssl3clientdisabledbydefault -eq 0)) {
            $ssl3clientenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($ssl3clientdisabledbydefault -eq 0) -and ($null -eq $ssl3clientenabled)) {
            $ssl3clientenabled_result = "Partial"
        }
        else {
            $ssl3clientenabled_result = $True
        }

        ## SSL v3 Server Stuff
        if ((($ssl3serverenabled -eq 0) -and ($ssl3serverdisabledbydefault -eq 1)) -or ($null -eq $ssl3serverenabled) -and ($null -eq $ssl3serverdisabledbydefault)) {
            $ssl3serverenabled_result = $False
        }
        elseif (($ssl3serverenabled -eq 1) -and ($ssl3serverdisabledbydefault -eq 1)) {
            $ssl3serverenabled_result = "Partial"
        }
        elseif (($ssl3serverenabled -eq 0) -and ($ssl3serverdisabledbydefault -eq 0)) {
            $ssl3serverenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($ssl3serverenabled -eq 0) -and ($ssl3serverdisabledbydefault -eq 0)) {
            $ssl3serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($ssl3serverdisabledbydefault -eq 0) -and ($null -eq $ssl3serverenabled)) {
            $ssl3serverenabled_result = "Partial"
        }
        else {
            $ssl3serverenabled_result = $True
        }

        ## TLS 1.0 Client Stuff
        if ((($tls1clientenabled -eq 0) -and ($tls1clientdisabledbydefault -eq 1)) -or ($null -eq $tls1clientenabled) -and ($null -eq $tls1clientdisabledbydefault)) {
            $tls1clientenabled_result = $False
        }
        elseif (($tls1clientenabled -eq 1) -and ($tls1clientdisabledbydefault -eq 1)) {
            $tls1clientenabled_result = "Partial"
        }
        elseif (($tls1clientenabled -eq 0) -and ($tls1clientdisabledbydefault -eq 0)) {
            $tls1clientenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($tls1clientenabled -eq 0) -and ($tls1clientdisabledbydefault -eq 0)) {
            $tls1clientenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls1clientdisabledbydefault -eq 0) -and ($null -eq $tls1clientenabled)) {
            $tls1clientenabled_result = "Partial"
        }
        else {
            $tls1clientenabled_result = $True
        }

        ## TLS 1.0 Server Stuff
        if ((($tls1serverenabled -eq 0) -and ($tls1serverdisabledbydefault -eq 1)) -or ($null -eq $tls1serverenabled) -and ($null -eq $tls1serverdisabledbydefault)) {
            $tls1serverenabled_result = $False
        }
        elseif (($tls1serverenabled -eq 1) -and ($tls1serverdisabledbydefault -eq 1)) {
            $tls1serverenabled_result = "Partial"
        }
        elseif (($tls1serverenabled -eq 0) -and ($tls1serverdisabledbydefault -eq 0)) {
            $tls1serverenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($tls1serverenabled -eq 0) -and ($tls1serverdisabledbydefault -eq 0)) {
            $tls1serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls1serverdisabledbydefault -eq 0) -and ($null -eq $tls1serverenabled)) {
            $tls1serverenabled_result = "Partial"
        }
        else {
            $tls1serverenabled_result = $True
        }

        ## TLS 1.1 Client Stuff
        if ((($tls11clientenabled -eq 0) -and ($tls11clientdisabledbydefault -eq 1)) -or ($null -eq $tls11clientenabled) -and ($null -eq $tls11clientdisabledbydefault)) {
            $tls11clientenabled_result = $False
        }
        elseif (($tls11clientenabled -eq 1) -and ($tls11clientdisabledbydefault -eq 1)) {
            $tls11clientenabled_result = "Partial"
        }
        elseif (($tls11clientenabled -eq 0) -and ($tls11clientdisabledbydefault -eq 0)) {
            $tls11clientenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($tls11clientenabled -eq 0) -and ($tls11clientdisabledbydefault -eq 0)) {
            $tls11serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls11clientdisabledbydefault -eq 0) -and ($null -eq $tls11clientenabled)) {
            $tls11serverenabled_result = "Partial"
        }
        else {
            $tls11serverenabled_result = $True
        }
        
        ## TLS 1.1 Server Stuff
        if ((($tls11serverenabled -eq 0) -and ($tls11serverdisabledbydefault -eq 1)) -or ($null -eq $tls11serverenabled) -and ($null -eq $tls11serverdisabledbydefault)) {
            $tls11serverenabled_result = $False
        }
        elseif (($tls11serverenabled -eq 1) -and ($tls11serverdisabledbydefault -eq 1)) {
            $tls11serverenabled_result = "Partial"
        }
        elseif (($tls11serverenabled -eq 0) -and ($tls11serverdisabledbydefault -eq 0)) {
            $tls11serverenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($tls11serverenabled -eq 0) -and ($tls11serverdisabledbydefault -eq 0)) {
            $tls11serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls11serverdisabledbydefault -eq 0) -and ($null -eq $tls11serverenabled)) {
            $tls11serverenabled_result = "Partial"
        }
        else {
            $tls11serverenabled_result = $True
        }

        ## TLS 1.2 Client Stuff
        
        ## If Client enabled is 0 and disabled by default is 1 or the entire client enabled key isn't there at all
        if ((($tls12clientenabled -eq 0) -and ($tls12clientdisabledbydefault -eq 1)) -or ($null -eq $tls12clientenabled) -and ($null -eq $tls12clientdisabledbydefault)) {
            $tls12clientenabled_result = "False"
        }
        ## If Client enabled is 1 but client disabled by default is still 1, then it's partially applied
        elseif (($tls12clientenabled -eq 1) -and ($tls12clientdisabledbydefault -eq 1)) {
            $tls12clientenabled_result = "Partial"
        }
        ## If Client enabled is 0 but client disabled by default is still 0, then it's partially applied
        elseif (($tls12clientenabled -eq 0) -and ($tls12clientdisabledbydefault -eq 0)) {
            $tls12clientenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls12clientdisabledbydefault -eq 0) -and ($null -eq $tls12clientenabled)) {
            $tls12clientenabled_result = "Partial"
        }
        ## If enabled is 1, but disabled by default is missing, then it's partially applied
        elseif (($tls12clientdisabledbydefault -eq 0) -and ($tls12clientenabled -eq 1)) {
            $tls12clientenabled_result = "Partial"
        }
        else {
            $tls12clientenabled_result = $True
        }
        
        ## TLS 1.2 Server Stuff
        if ((($tls12serverenabled -eq 0) -and ($tls12serverdisabledbydefault -eq 1)) -or ($null -eq $tls12serverenabled) -and ($null -eq $tls12serverdisabledbydefault)) {
            $tls12serverenabled_result = $False
        }
        elseif (($tls12serverenabled -eq 1) -and ($tls12serverdisabledbydefault -eq 1)) {
            $tls12serverenabled_result = "Partial"
        }
        elseif (($tls12serverenabled -eq 0) -and ($tls12serverdisabledbydefault -eq 0)) {
            $tls12serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls12serverdisabledbydefault -eq 0) -and ($null -eq $tls12serverenabled)) {
            $tls12serverenabled_result = "Partial"
        }
        ## If enabled is 1, but disabled by default is missing, then it's partially applied
        elseif (($tls12serverdisabledbydefault -eq 0) -and ($tls12serverenabled -eq 1)) {
            $tls12clientenabled_result = "Partial"
        }
        else {
            $tls12serverenabled_result = $True
        }

        ## TLS 1.3 Client Stuff
        if ((($tls13clientenabled -eq 0) -and ($tls13clientdisabledbydefault -eq 1)) -or ($null -eq $tls13clientenabled) -and ($null -eq $tls13clientdisabledbydefault)) {
            $tls13clientenabled_result = $False
        }
        elseif (($tls13clientenabled -eq 1) -and ($tls13clientdisabledbydefault -eq 1)) {
            $tls13clientenabled_result = "Partial"
        }
        elseif (($tls13clientenabled -eq 0) -and ($tls13clientdisabledbydefault -eq 0)) {
            $tls13clientenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls13clientdisabledbydefault -eq 0) -and ($null -eq $tls13clientenabled)) {
            $tls13clientenabled_result = "Partial"
        }
        ## If enabled is 1, but disabled by default is missing, then it's partially applied
        elseif (($tls13clientdisabledbydefault -eq 0) -and ($tls13clientenabled -eq 1)) {
            $tls13clientenabled_result = "Partial"
        }
        else {
            $tls13clientenabled_result = $True
        }
        
        ## TLS 1.3 Server Stuff
        if ((($tls13serverenabled -eq 0) -and ($tls13serverdisabledbydefault -eq 1)) -or ($null -eq $tls13serverenabled) -and ($null -eq $tls13serverdisabledbydefault)) {
            $tls13serverenabled_result = $False
        }
        elseif (($tls13serverenabled -eq 1) -and ($tls13serverdisabledbydefault -eq 1)) {
            $tls13serverenabled_result = "Partial"
        }
        elseif (($tls13serverenabled -eq 0) -and ($tls13serverdisabledbydefault -eq 0)) {
            $tls13serverenabled_result = "Partial"
        }
        ## If disabled by default is 0, but enabled key is missing, then it's partially applied
        elseif (($tls13serverdisabledbydefault -eq 0) -and ($null -eq $tls13serverenabled)) {
            $tls13serverenabled_result = "Partial"
        }
        ## If enabled is 1, but disabled by default is missing, then it's partially applied
        elseif (($tls13serverdisabledbydefault -eq 0) -and ($tls13serverenabled -eq 1)) {
            $tls13serverenabled_result = "Partial"
        }
        else {
            $tls13serverenabled_result = $True
        }

        [PSCustomObject]@{
            SSL2ClientEnabled         = $ssl2clientenabled_result
            SSL2ServerEnabled         = $ssl2serverenabled_result
            SSL3ClientActive          = $ssl3clientenabled_result
            SSL3ServerActive          = $ssl3serverenabled_result
            TLS1ClientEnabled         = $tls1clientenabled_result
            TLS1ServerEnabled         = $tls1serverenabled_result
            TLS11ClientEnabled        = $tls11clientenabled_result
            TLS11ServerEnabled        = $tls11serverenabled_result
            TLS12ClientEnabled        = $tls12clientenabled_result
            TLS12ServerEnabled        = $tls12serverenabled_result
            TLS13ClientEnabled        = $tls13clientenabled_result
            TLS13ServerEnabled        = $tls13serverenabled_result
            DiffieHellmanEnabled      = ""
            DiffieHellmanMinBitLength = ""
            "RC4 128/128"             = ""
            "RC4 56/128"              = ""
            "RC4 40/128"              = ""
            TripleDES168              = ""
            Computer                  = $env:COMPUTERNAME
            OS                        = (Get-WmiObject win32_operatingsystem).Caption
        }
    } -ErrorAction "SilentlyContinue" | Select-Object *SSL*, *Diff*, *RC*, *Triple*, Computer, OS
}