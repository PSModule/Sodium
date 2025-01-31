Describe 'Sodium' {
    Context "Function 'ConvertTo-SealedPublicKeyBox'" {
        It 'Encrypts a secret using a sealed public key box' {
            [System.Reflection.Assembly]::Load('Sodium.Core')
            $keys = [Sodium.PublicKeyBox]::GenerateKeyPair()
            Write-Host "Public Key: $($keys.PublicKey)"
            Write-Host "Private Key: $($keys.PrivateKey)"
            $sealedBox = ConvertTo-SealedPublicKeyBox -Secret 'mysecret' -PublicKey $keys.PublicKey
        }
    }
}

Describe 'SealedPublicKeyBox Functions' {

    It 'Encrypts and decrypts a secret correctly using SodiumEncryptedString' {
        # Generate a key pair
        $keyPair = [Sodium.PublicKeyBox]::GenerateKeyPair()
        $publicKeyBase64 = [System.Convert]::ToBase64String($keyPair.PublicKey)
        $privateKeyBase64 = [System.Convert]::ToBase64String($keyPair.PrivateKey)

        # Define a secret to test
        $secret = 'Hello world!'

        $encryptedString = ConvertTo-SodiumEncryptedString -Secret $secret -PublicKey $publicKeyBase64

        # Decrypt the sealed box using the matching private key
        $params = @{
            EncryptedSecret = $encryptedString
            PublicKey       = $publicKeyBase64
            PrivateKey      = $privateKeyBase64
        }
        $decryptedString = ConvertFrom-SodiumEncryptedString @params

        # Assert that the decrypted secret matches the original
        $decryptedString | Should -Be $secret
    }
}
