function Get-TLSSetting {
    [CmdletBinding()]
    param (
        [string[]]
        $ComputerName = $ENV:COMPUTERNAME
    )

    ## Get Cipher Suite Values
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {

        ## Check SSL v3
        $ssl3clientenabled = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl3clientdisabledbydefault = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $ssl3serverenabled = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl3serverdisabledbydefault = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
    
        ## Check SSL v2
        $ssl2clientenabled = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl2clientdisabledbydefault = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" -Name "DisabledByDefault" -ErrorAction SilentlyContinue
        $ssl2serverenabled = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name "Enabled" -ErrorAction SilentlyContinue
        $ssl2serverdisabledbydefault = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" -Name "DisabledByDefault" -ErrorAction SilentlyContinue

        ## Check Diffie Hellman
        $DiffieHellman = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman" -Name "Enabled" -ErrorAction SilentlyContinue
        $DiffieHellmanKeyBit = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman" -Name "ServerMinKeyBitLength" -ErrorAction SilentlyContinue

        ## Check Weak Ciphers
        $RC4128 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128" -Name "Enabled" -ErrorAction SilentlyContinue
        $RC456128 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128" -Name "Enabled" -ErrorAction SilentlyContinue
        $RC440128 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" -Name "Enabled" -ErrorAction SilentlyContinue
        $tripledes168 = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168" -Name "Enabled" -ErrorAction SilentlyContinue

        [pscustomobject]@{
            SSL3ClientEnabled         = if ($ssl3clientenabled.Enabled -eq 0 -and $ssl3clientdisabledbydefault.DisabledByDefault -eq 1) { $False } else { $true }
            SSL3ServerEnabled         = if ($ssl3serverenabled.Enabled -eq 0 -and $ssl3serverdisabledbydefault.DisabledByDefault -eq 1) { $False } else { $true }
            SSL2ClientEnabled         = if ($ssl2clientenabled.Enabled -eq 0 -and $ssl2clientdisabledbydefault.DisabledByDefault -eq 1) { $False } else { $true }
            SSL2ServerEnabled         = if ($ssl2serverenabled.Enabled -eq 0 -and $ssl2serverdisabledbydefault.DisabledByDefault -eq 1) { $False } else { $true }
            DiffieHellmanEnabled      = if ($null -eq $DiffieHellman.Enabled) { $True } else { $true }
            DiffieHellmanMinBitLength = if ($DiffieHellmanKeyBit.ServerMinKeyBitLength -match "8264|2048") { "2048" } else { "NA" }
            "RC4 128/128"             = if ($RC4128.Enabled -eq 0) { $False } else { $True }
            "RC4 56/128"              = if ($RC456128.Enabled -eq 0) { $False } else { $True }
            "RC4 40/128"              = if ($RC440128.Enabled -eq 0) { $False } else { $True }
            TripleDES168              = if ($tripledes168.Enabled -eq 0) { $False } else { $True }
            Computer                  = $env:COMPUTERNAME
            OS                        = (Get-WmiObject win32_operatingsystem).Caption
        }
    } -ErrorAction "SilentlyContinue" | Select-Object *SSL*, *Diff*, *RC*, *Triple*, Computer, OS
}