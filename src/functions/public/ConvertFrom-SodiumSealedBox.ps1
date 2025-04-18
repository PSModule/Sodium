function ConvertFrom-SodiumSealedBox {
    <#
        .SYNOPSIS
        Decrypts a base64-encoded, Sodium SealedBox-encrypted string.

        .DESCRIPTION
        Converts a base64-encoded, Sodium SealedBox-encrypted string into its original plaintext form.
        Uses the provided public and private keys to decrypt the sealed message.

        .EXAMPLE
        $params = @{
            SealedBox       = $encryptedMessage
            PublicKey       = $publicKey
            PrivateKey      = $privateKey
        }
        ConvertFrom-SodiumSealedBox @params

        Output:
        ```powershell
        Secret message revealed!
        ```

        Decrypts the given encrypted message using the specified public and private keys and returns the original string.

        .EXAMPLE
        $encryptedMessage | ConvertFrom-SodiumSealedBox -PublicKey $publicKey -PrivateKey $privateKey

        Output:
        ```powershell
        Confidential Data
        ```

        Uses pipeline input to decrypt the given encrypted message with the specified keys.

        .OUTPUTS
        System.String

        .NOTES
        Returns the original plaintext string after decryption.
        If decryption fails, an exception is thrown.

        .LINK
        https://psmodule.io/Sodium/Functions/ConvertFrom-SodiumSealedBox/

        .LINK
        https://doc.libsodium.org/public-key_cryptography/sealed_boxes
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The base64-encoded encrypted secret string to decrypt.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('CipherText')]
        [string] $SealedBox,

        # The base64-encoded public key used for decryption.
        [Parameter()]
        [string] $PublicKey,

        # The base64-encoded private key used for decryption.
        [Parameter(Mandatory)]
        [string] $PrivateKey
    )

    begin {
        if (-not $script:Supported) { throw 'Sodium is not supported on this platform.' }
        $null = [PSModule.Sodium]::sodium_init()
    }

    process {
        $ciphertext = [System.Convert]::FromBase64String($SealedBox)

        $privateKeyByteArray = [System.Convert]::FromBase64String($PrivateKey)
        if ($privateKeyByteArray.Length -ne 32) { throw 'Invalid private key.' }

        if ([string]::IsNullOrWhiteSpace($PublicKey)) {
            $publicKeyByteArray = Get-SodiumPublicKey -PrivateKey $PrivateKey
        } else {
            $publicKeyByteArray = [System.Convert]::FromBase64String($PublicKey)
            if ($publicKeyByteArray.Length -ne 32) { throw 'Invalid public key.' }
        }

        $overhead = [PSModule.Sodium]::crypto_box_sealbytes().ToUInt32()
        $decryptedBytes = New-Object byte[] ($ciphertext.Length - $overhead)

        $result = [PSModule.Sodium]::crypto_box_seal_open(
            $decryptedBytes, $ciphertext, [UInt64]$ciphertext.Length, $publicKeyByteArray, $privateKeyByteArray
        )

        if ($result -ne 0) {
            throw 'Decryption failed.'
        }

        return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    }
}
