Describe 'Sodium' {
    Context "Function 'ConvertTo-SealedPublicKeyBox'" {
        It 'Encrypts and decrypts a secret correctly using SodiumEncryptedString' {
            # Generate a key pair
            $keyPair = New-SodiumKeyPair
            $publicKey = $keyPair.PublicKey
            $privateKey = $keyPair.PrivateKey

            # Define a secret to test
            $secret = 'Hello world!'

            $encryptedString = ConvertTo-SodiumEncryptedString -Secret $secret -PublicKey $publicKey

            # Decrypt the sealed box using the matching private key
            $params = @{
                EncryptedSecret = $encryptedString
                PublicKey       = $publicKey
                PrivateKey      = $privateKey
            }
            $decryptedString = ConvertFrom-SodiumEncryptedString @params

            # Assert that the decrypted secret matches the original
            $decryptedString | Should -Be $secret
        }
    }
}
