#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Sodium' {
    Context 'SealedBox - Encryption and Decryption' {
        It 'Encrypts and decrypts a message correctly using valid keys' {
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey
            $message = 'Hello world!'

            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey
            $decryptedString = ConvertFrom-SodiumSealedBox -SealedBox $encryptedMessage -PublicKey $publicKey -PrivateKey $privateKey

            $decryptedString | Should -Be $message
        }

        It 'Fails decryption when using the wrong private key' {
            $keyPair1 = New-SodiumKeyPair
            $keyPair2 = New-SodiumKeyPair
            $message = 'Test message'

            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair1.PublicKey

            { ConvertFrom-SodiumSealedBox -SealedBox $encryptedMessage -PublicKey $keyPair1.PublicKey -PrivateKey $keyPair2.PrivateKey } |
                Should -Throw 'Decryption failed.'
        }

        It 'ConvertTo-SodiumSealedBox -Throws an error when encrypting with an invalid public key' {
            $message = 'Invalid key test'
            $invalidPublicKey = 'InvalidKey'

            { ConvertTo-SodiumSealedBox -Message $message -PublicKey $invalidPublicKey } | Should -Throw
        }

        It 'Throws an error when decrypting with an invalid public key' {
            $keyPair = New-SodiumKeyPair
            $message = 'Another message'
            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey

            $invalidPublicKey = 'AAA'
            { ConvertFrom-SodiumSealedBox -SealedBox $encryptedMessage -PublicKey $invalidPublicKey -PrivateKey $keyPair.PrivateKey } | Should -Throw
        }

        It 'Throws a clear error when the sealed box is shorter than the Sodium overhead' {
            $keyPair = New-SodiumKeyPair
            $shortSealedBox = [Convert]::ToBase64String([byte[]]::new(16))

            { ConvertFrom-SodiumSealedBox -SealedBox $shortSealedBox -PrivateKey $keyPair.PrivateKey } |
                Should -Throw 'Invalid sealed box. Expected at least 48 bytes but got 16.'
        }

        It 'Encrypts a message correctly when using pipeline input on ConvertTo-SodiumSealedBox' {
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey
            $message = 'Pipeline input encryption test'

            $encryptedMessage = $message | ConvertTo-SodiumSealedBox -PublicKey $publicKey
            $decryptedString = ConvertFrom-SodiumSealedBox -SealedBox $encryptedMessage -PublicKey $publicKey -PrivateKey $privateKey

            $decryptedString | Should -Be $message
        }

        It 'Decrypts a sealed box correctly when using pipeline input on ConvertFrom-SodiumSealedBox' {
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey
            $message = 'Pipeline input decryption test'

            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey
            $decryptedString = $encryptedMessage | ConvertFrom-SodiumSealedBox -PublicKey $publicKey -PrivateKey $privateKey

            $decryptedString | Should -Be $message
        }
    }

    Context 'SealedBox - Decryption without PublicKey' {

        It 'Decrypts a sealed box when only the private key is supplied' {
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey

            $message = 'Hello with secret key only!'
            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey
            $decrypted = ConvertFrom-SodiumSealedBox -SealedBox $encryptedMessage -PrivateKey $privateKey

            $decrypted | Should -Be $message
        }

        It 'Fails when an incorrect private key is supplied (no public key given)' {
            $kpGood = New-SodiumKeyPair
            $kpBad = New-SodiumKeyPair
            $message = 'Mismatch test'
            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $kpGood.PublicKey
            { ConvertFrom-SodiumSealedBox -SealedBox $encryptedMessage -PrivateKey $kpBad.PrivateKey } | Should -Throw
        }

        It 'Accepts pipeline input for the sealed box when no public key is given' {
            $kp = New-SodiumKeyPair
            $message = 'Pipeline test'
            $encryptedMessage = ConvertTo-SodiumSealedBox -Message $message -PublicKey $kp.PublicKey
            $result = $encryptedMessage | ConvertFrom-SodiumSealedBox -PrivateKey $kp.PrivateKey
            $result | Should -Be $message
        }
    }

    Context 'Key Pair Generation' {
        It 'Generates a valid key pair with keys of 32 bytes each' {
            $keyPair = New-SodiumKeyPair
            $publicKeyBytes = [Convert]::FromBase64String($keyPair.PublicKey)
            $privateKeyBytes = [Convert]::FromBase64String($keyPair.PrivateKey)

            $publicKeyBytes.Length | Should -Be 32
            $privateKeyBytes.Length | Should -Be 32
        }

        It 'Generates deterministic keys when a seed is provided' {
            $seed = 'DeterministicSeed'
            $keyPair1 = New-SodiumKeyPair -Seed $seed
            $keyPair2 = New-SodiumKeyPair -Seed $seed

            $keyPair1.PublicKey | Should -Be $keyPair2.PublicKey
            $keyPair1.PrivateKey | Should -Be $keyPair2.PrivateKey
        }

        It 'Generates deterministic keys when a seed is provided - using a pipeline input' {
            $seed = 'DeterministicSeed'
            $keyPair1 = $seed | New-SodiumKeyPair
            $keyPair2 = $seed | New-SodiumKeyPair

            $keyPair1.PublicKey | Should -Be $keyPair2.PublicKey
            $keyPair1.PrivateKey | Should -Be $keyPair2.PrivateKey
        }

        It 'Generates different keys for different seeds' {
            $seed1 = 'SeedOne'
            $seed2 = 'SeedTwo'
            $keyPair1 = New-SodiumKeyPair -Seed $seed1
            $keyPair2 = New-SodiumKeyPair -Seed $seed2

            $keyPair1.PublicKey | Should -Not -Be $keyPair2.PublicKey
            $keyPair1.PrivateKey | Should -Not -Be $keyPair2.PrivateKey
        }

        It 'Allows an empty seed and remains deterministic for compatibility' {
            $keyPair1 = New-SodiumKeyPair -Seed ''
            $keyPair2 = New-SodiumKeyPair -Seed ''

            $keyPair1.PublicKey | Should -Be $keyPair2.PublicKey
            $keyPair1.PrivateKey | Should -Be $keyPair2.PrivateKey
        }
    }

    Context 'Public Key Derivation' {
        It 'Get-SodiumPublicKey - Derives the correct public key from a private key' {
            $keyPair = New-SodiumKeyPair
            $privateKey = $keyPair.PrivateKey
            $expectedPublicKey = $keyPair.PublicKey

            $derivedPublicKey = Get-SodiumPublicKey -PrivateKey $privateKey

            $derivedPublicKey | Should -Be $expectedPublicKey
        }

        It 'Get-SodiumPublicKey - Returns the public key as a byte array' {
            $keyPair = New-SodiumKeyPair
            $derivedPublicKey = Get-SodiumPublicKey -PrivateKey $keyPair.PrivateKey -AsByteArray

            ($derivedPublicKey -is [byte[]]) | Should -BeTrue
            [Convert]::ToBase64String($derivedPublicKey) | Should -Be $keyPair.PublicKey
        }

        It 'Get-SodiumPublicKey - Throws an error when an invalid private key is provided' {
            $invalidPrivateKey = 'InvalidKey'

            { Get-SodiumPublicKey -PrivateKey $invalidPrivateKey } | Should -Throw
        }

        It 'Get-SodiumPublicKey - Throws a clear error when a private key has the wrong length' {
            $shortPrivateKey = [Convert]::ToBase64String([byte[]]::new(16))

            { Get-SodiumPublicKey -PrivateKey $shortPrivateKey } |
                Should -Throw 'Invalid private key. Expected 32 bytes but got 16.'
        }
    }

    Context 'Runtime diagnostics' {
        It 'Assert-VisualCRedistributableInstalled validates the current Windows architecture runtime' -Skip:(-not $IsWindows) {
            InModuleScope Sodium {
                $arch = if ([System.Environment]::Is64BitProcess) { 'X64' } else { 'X86' }
                $result = Assert-VisualCRedistributableInstalled -Version '14.0' -Architecture $arch 3>$null
                $result | Should -BeTrue
            }
        }

        It 'Assert-VisualCRedistributableInstalled reports a missing runtime' {
            InModuleScope Sodium {
                Mock Get-ItemProperty { $null }

                $result = Assert-VisualCRedistributableInstalled -Version '14.0' -Architecture 'X64' 3>$null
                $result | Should -BeFalse
            }
        }

        It 'Assert-VisualCRedistributableInstalled accepts a matching runtime' {
            InModuleScope Sodium {
                Mock Get-ItemProperty {
                    [pscustomobject]@{
                        Installed = 1
                        Version   = 'v14.30.30704.0'
                    }
                }

                Set-Variable -Name IsWindows -Value $true -Scope Script
                try {
                    $result = Assert-VisualCRedistributableInstalled -Version '14.0'
                    $result | Should -BeTrue
                } finally {
                    Remove-Variable -Name IsWindows -Scope Script
                }
            }
        }

        It 'Initialize-Sodium treats repeated initialization as a no-op' {
            InModuleScope Sodium {
                $script:SodiumInitialized | Should -BeTrue
                { Initialize-Sodium } | Should -Not -Throw
            }
        }

        It 'Initialize-Sodium restores cached native buffer sizes' {
            InModuleScope Sodium {
                $script:SodiumInitialized = $false
                $script:SodiumPublicKeyBytes = $null
                $script:SodiumPrivateKeyBytes = $null
                $script:SodiumSealBytes = $null
                $script:SodiumSeedBytes = $null

                Initialize-Sodium

                $script:SodiumInitialized | Should -BeTrue
                $script:SodiumPublicKeyBytes | Should -Be 32
                $script:SodiumPrivateKeyBytes | Should -Be 32
                $script:SodiumSealBytes | Should -Be 48
                $script:SodiumSeedBytes | Should -Be 32
            }
        }

        It 'Initialize-Sodium rejects an unsupported platform' {
            InModuleScope Sodium {
                $script:Supported = $false
                try {
                    { Initialize-Sodium } | Should -Throw 'Sodium is not supported on this platform.'
                } finally {
                    $script:Supported = $true
                }
            }
        }

        It 'Resolve-SodiumRuntimeIdentifier maps every supported runtime' {
            InModuleScope Sodium {
                Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'Arm64' -Linux | Should -Be 'linux-arm64'
                Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'X64' -Linux | Should -Be 'linux-x64'
                Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'Arm64' -MacOS | Should -Be 'osx-arm64'
                Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'X64' -MacOS | Should -Be 'osx-x64'
                Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'X64' -Windows | Should -Be 'win-x64'
                Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'X86' -Windows | Should -Be 'win-x86'
            }
        }

        It 'Resolve-SodiumRuntimeIdentifier rejects unsupported runtimes' {
            InModuleScope Sodium {
                { Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'Arm' -Linux } |
                    Should -Throw 'Unsupported Linux process architecture: Arm.*'
                { Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'Arm' -MacOS } |
                    Should -Throw 'Unsupported macOS process architecture: Arm.*'
                { Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'Arm' -Windows } |
                    Should -Throw 'Unsupported Windows process architecture: Arm.*'
                { Resolve-SodiumRuntimeIdentifier -ProcessArchitecture 'X64' } |
                    Should -Throw 'Unsupported platform.*'
            }
        }
    }

    Context 'Parallel sessions' {
        It 'Loads and completes crypto round trips in parallel runspaces' {
            $modulePath = (Get-Module -Name Sodium -ErrorAction Stop).Path
            Test-Path -Path $modulePath | Should -BeTrue
            $results = 1..4 | ForEach-Object -Parallel {
                Import-Module -Name $using:modulePath -Force
                $keyPair = New-SodiumKeyPair -Seed "Runspace-$_"
                $message = "Parallel runspace $_"
                $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey
                ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PrivateKey $keyPair.PrivateKey
            } -ThrottleLimit 4

            $results | Should -HaveCount 4
            $results | Should -Contain 'Parallel runspace 1'
            $results | Should -Contain 'Parallel runspace 4'
        }

        It 'Loads and completes crypto round trips in parallel processes' {
            $modulePath = (Get-Module -Name Sodium -ErrorAction Stop).Path
            $jobs = 1..4 | ForEach-Object {
                Start-Job -ScriptBlock {
                    $id = $args[0]
                    $modulePath = $args[1]
                    Import-Module -Name $modulePath -Force
                    $keyPair = New-SodiumKeyPair -Seed "Process-$id"
                    $message = "Parallel process $id"
                    $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey
                    ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PrivateKey $keyPair.PrivateKey
                } -ArgumentList $_, $modulePath
            }

            try {
                $results = $jobs | Receive-Job -Wait
                $results | Should -HaveCount 4
                $results | Should -Contain 'Parallel process 1'
                $results | Should -Contain 'Parallel process 4'
            } finally {
                $jobs | Remove-Job -Force
            }
        }
    }
}
