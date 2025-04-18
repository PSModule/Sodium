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
    }

    Context 'Public Key Derivation' {
        It 'Get-SodiumPublicKey - Derives the correct public key from a private key' {
            $keyPair = New-SodiumKeyPair
            $privateKey = $keyPair.PrivateKey
            $expectedPublicKey = $keyPair.PublicKey

            $derivedPublicKey = Get-SodiumPublicKey -PrivateKey $privateKey

            $derivedPublicKey | Should -Be $expectedPublicKey
        }

        It 'Get-SodiumPublicKey - Throws an error when an invalid private key is provided' {
            $invalidPrivateKey = 'InvalidKey'

            { Get-SodiumPublicKey -PrivateKey $invalidPrivateKey } | Should -Throw
        }
    }
}
