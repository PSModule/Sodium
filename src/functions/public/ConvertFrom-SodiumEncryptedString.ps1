function ConvertFrom-SodiumEncryptedString {
    <#
        .SYNOPSIS
        Decrypts a base64-encoded, Sodium-encrypted string.

        .DESCRIPTION
        Converts a base64-encoded, Sodium-encrypted string into its original plaintext form.
        Uses the provided public and private keys to decrypt the sealed message.

        .EXAMPLE
        $params = @{
            EncryptedSecret = $encryptedSecret
            PublicKey       = $publicKey
            PrivateKey      = $privateKey
        }
        ConvertFrom-SodiumEncryptedString @params

        Decrypts the given encrypted secret using the specified public and private keys and returns the original string.

        .LINK
        https://psmodule.io/Sodium/Functions/ConvertFrom-SodiumEncryptedString/
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The base64-encoded encrypted secret string to decrypt.
        [Parameter(Mandatory)]
        [string] $EncryptedSecret,

        # The base64-encoded public key used for decryption.
        [Parameter(Mandatory)]
        [string] $PublicKey,

        # The base64-encoded private key used for decryption.
        [Parameter(Mandatory)]
        [string] $PrivateKey
    )

    begin {
        Initialize-Sodium
    }

    process {
        $ciphertext = [Convert]::FromBase64String($EncryptedSecret)
        $publicKeyNorm = [Convert]::FromBase64String($PublicKey)
        $privateKeyNorm = [Convert]::FromBase64String($PrivateKey)

        $overhead = [PSModule.Sodium]::crypto_box_sealbytes().ToUInt32()
        $decryptedBytes = New-Object byte[] ($ciphertext.Length - $overhead)

        # Attempt to decrypt
        $result = [PSModule.Sodium]::crypto_box_seal_open($decryptedBytes, $ciphertext, [uint64]$ciphertext.Length, $publicKeyNorm, $privateKeyNorm)

        if ($result -ne 0) {
            throw 'Decryption failed. Invalid key or corrupted ciphertext.'
        }

        return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    }
}
