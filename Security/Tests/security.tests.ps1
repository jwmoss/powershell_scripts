#requires -Modules Pester
Describe "TLS and SSL Checks" {

    BeforeAll {    
        $tlsstuff = Get-TLSSetting -ComputerName $ComputerName
    }
    
    Context "SSL and TLS Checks" {

        foreach ($item in $tlsstuff) {
            It "SSL v2 Client $($item.Computer)" {
                $item.SSL2ClientEnabled | Should -Be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "SSL v2 Server $($item.Computer)" {
                $item.SSL2ServerEnabled | Should -Be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "SSL v3 Server $($item.Computer)" {
                $item.SSL3ServerEnabled | Should -Be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "SSL v3 Client $($item.Computer)" {
                $item.SSL3ClientEnabled | Should -Be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "DiffieHellman MinBitKeyLength $($item.Computer)" {
                $item.DiffieHellmanMinBitLength | Should -Be 2048
            }
        }

        foreach ($item in $tlsstuff) {
            It "DiffieHellman Enabled $($item.Computer)" {
                $item.DiffieHellmanEnabled | Should -Be $true
            }
        }

        foreach ($item in $tlsstuff) {
            It "RC4 128/128 $($item.Computer)" {
                $item.'RC4 128/128' | Should -be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "RC4 56/128 $($item.Computer)" {
                $item.'RC4 56/128' | Should -be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "RC4 40/128 $($item.Computer)" {
                $item.'RC4 40/128' | Should -be $False
            }
        }

        foreach ($item in $tlsstuff) {
            It "TripleDES 168 $($item.Computer)" {
                $item.TripleDES168 | Should -be $False
            }
        }

    }
} 