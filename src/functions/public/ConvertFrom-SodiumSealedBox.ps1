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
        [ValidateNotNullOrEmpty()]
        [string] $SealedBox,

        # The base64-encoded public key used for decryption.
        [Parameter()]
        [string] $PublicKey,

        # The base64-encoded private key used for decryption.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PrivateKey
    )

    begin {
        Initialize-Sodium
    }

    process {
        $privateKeyByteArray = $null
        $decryptedBytes = $null
        try {
            $ciphertext = [System.Convert]::FromBase64String($SealedBox)
            if ($ciphertext.Length -lt $script:SodiumSealBytes) {
                throw "Invalid sealed box. Expected at least $script:SodiumSealBytes bytes but got $($ciphertext.Length)."
            }

            $privateKeyByteArray = [System.Convert]::FromBase64String($PrivateKey)
            if ($privateKeyByteArray.Length -ne $script:SodiumPrivateKeyBytes) {
                throw "Invalid private key. Expected $script:SodiumPrivateKeyBytes bytes but got $($privateKeyByteArray.Length)."
            }

            if (-not $PublicKey) {
                $publicKeyByteArray = [byte[]](Get-SodiumPublicKey -PrivateKey $PrivateKey -AsByteArray)
            } else {
                $publicKeyByteArray = [System.Convert]::FromBase64String($PublicKey)
                if ($publicKeyByteArray.Length -ne $script:SodiumPublicKeyBytes) {
                    throw "Invalid public key. Expected $script:SodiumPublicKeyBytes bytes but got $($publicKeyByteArray.Length)."
                }
            }

            $decryptedBytes = [byte[]]::new($ciphertext.Length - $script:SodiumSealBytes)

            $result = [PSModule.Sodium]::crypto_box_seal_open(
                $decryptedBytes, $ciphertext, [UInt64]$ciphertext.Length, $publicKeyByteArray, $privateKeyByteArray
            )

            if ($result -ne 0) {
                throw 'Decryption failed.'
            }

            return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
        } finally {
            if ($null -ne $privateKeyByteArray -and $privateKeyByteArray.Length -gt 0) {
                [array]::Clear($privateKeyByteArray, 0, $privateKeyByteArray.Length)
            }
            if ($null -ne $decryptedBytes -and $decryptedBytes.Length -gt 0) {
                [array]::Clear($decryptedBytes, 0, $decryptedBytes.Length)
            }
        }
    }
}
