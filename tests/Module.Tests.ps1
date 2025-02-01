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

    # .LINK
    # https://github.com/jborean93/PowerShell-Yayaml/blob/main/module/Yayaml.psm1
    Context 'Isolated Assemblies' {
        $IsolatedAssemblies = @(
            'Sodium.Core'
            'PSModule.Sodium.Isolated'
        )
        $IsolatedTestCases = $IsolatedAssemblies | ForEach-Object {
            @{
                Name = $_
            }
        }
        It 'Should be in the IsolatedAssemblyLoadContext [<Name>]' -ForEach $IsolatedTestCases {
            if ($IsMacOS) {
                codesign -v /Users/runner/work/Sodium/Sodium/outputs/modules/Sodium/modules/PSModule.Sodium/isolated/runtimes/osx-arm64/native/libsodium.dylib
            }

            $assembly = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq $Name }
            [Runtime.Loader.AssemblyLoadContext]::GetLoadContext($assembly).Name | Should -Be 'IsolatedAssemblyLoadContext'
        }
    }
}
