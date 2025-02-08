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
            } | Should -Throw 'Invalid public key'
        }

        It 'Throws an error when decrypting with an invalid public key' {
            $keyPair = New-SodiumKeyPair
            $message = 'Another message'
            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey

            # Supply a public key that's clearly too short
            $invalidPublicKey = 'AAA'
            {
                ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $invalidPublicKey -PrivateKey $keyPair.PrivateKey
            } | Should -Throw 'Invalid public key.'
        }

        It 'Throws an error when decrypting with an invalid private key' {
            $keyPair = New-SodiumKeyPair
            $message = 'Yet another message'
            $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $keyPair.PublicKey

            # Supply a private key that's clearly too short
            $invalidPrivateKey = 'BBB'
            {
                ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PublicKey $keyPair.PublicKey -PrivateKey $invalidPrivateKey
            } | Should -Throw 'Invalid private key.'
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
    }
}
