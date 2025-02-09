Describe 'Sodium' {
    Context 'SealedBox - Encryption and Decryption' {
        It 'Encrypts and decrypts a message correctly using valid keys' {
            # Generate a key pair
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey

            # Define a message to test
            $message = 'Hello world!'

            # Encrypt the message
            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey

            # Decrypt using the matching private key
            $decryptedString = ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $publicKey -PrivateKey $privateKey

            # Verify that the decrypted string matches the original message
            $decryptedString | Should -Be $message
        }

        It 'Fails decryption when using the wrong private key' {
            $keyPair1 = New-SodiumKeyPair
            $keyPair2 = New-SodiumKeyPair
            $message = 'Test message'

            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair1.PublicKey

            {
                ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $keyPair1.PublicKey -PrivateKey $keyPair2.PrivateKey
            } | Should -Throw 'Decryption failed.'
        }

        It 'Throws an error when encrypting with an invalid public key' {
            $message = 'Invalid key test'
            $invalidPublicKey = 'InvalidKey'  # not 32 bytes when converted

            {
                ConvertTo-SodiumSealedBox -Message $message -PublicKey $invalidPublicKey
            } | Should -Throw
        }

        It 'Throws an error when decrypting with an invalid public key' {
            $keyPair = New-SodiumKeyPair
            $message = 'Another message'
            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey

            # Supply a public key that's clearly too short
            $invalidPublicKey = 'AAA'
            {
                ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $invalidPublicKey -PrivateKey $keyPair.PrivateKey
            } | Should -Throw
        }

        It 'Throws an error when decrypting with an invalid private key' {
            $keyPair = New-SodiumKeyPair
            $message = 'Yet another message'
            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey

            # Supply a private key that's clearly too short
            $invalidPrivateKey = 'BBB'
            {
                ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $keyPair.PublicKey -PrivateKey $invalidPrivateKey
            } | Should -Throw
        }

        It 'Encrypts a message correctly when using pipeline input on ConvertTo-SodiumSealedBox' {
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey
            $message = 'Pipeline input encryption test'

            # Pass the message via pipeline input instead of -Message parameter
            $sealedBox = $message | ConvertTo-SodiumSealedBox -PublicKey $publicKey

            $decryptedString = ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $publicKey -PrivateKey $privateKey

            $decryptedString | Should -Be $message
        }

        It 'Decrypts a sealed box correctly when using pipeline input on ConvertFrom-SodiumSealedBox' {
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey
            $message = 'Pipeline input decryption test'

            # Encrypt using normal parameter binding
            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey

            # Pass the sealed box via pipeline input to the decryption function
            $decryptedString = $sealedBox | ConvertFrom-SodiumSealedBox -PublicKey $publicKey -PrivateKey $privateKey

            $decryptedString | Should -Be $message
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

        It 'Generates different keys for different seeds' {
            $seed1 = 'SeedOne'
            $seed2 = 'SeedTwo'
            $keyPair1 = New-SodiumKeyPair -Seed $seed1
            $keyPair2 = New-SodiumKeyPair -Seed $seed2

            $keyPair1.PublicKey | Should -Not -Be $keyPair2.PublicKey
            $keyPair1.PrivateKey | Should -Not -Be $keyPair2.PrivateKey
        }
    }
}
