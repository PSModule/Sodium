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

        Decrypts the given encrypted message using the specified public and private keys and returns the original string.

        .LINK
        https://psmodule.io/Sodium/Functions/ConvertFrom-SodiumSealedBox/

        .LINK
        https://doc.libsodium.org/public-key_cryptography/sealed_boxes
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The base64-encoded encrypted secret string to decrypt.
        [Parameter(Mandatory)]
        [Alias('CipherText')]
        [string] $SealedBox,

        # The base64-encoded public key used for decryption.
        [Parameter(Mandatory)]
        [string] $PublicKey,

        # The base64-encoded private key used for decryption.
        [Parameter(Mandatory)]
        [string] $PrivateKey
    )

    begin {
        $null = [PSModule.Sodium]::sodium_init()
    }

    process {
        try {
            $ciphertext = [Convert]::FromBase64String($SealedBox)
            $publicKeyByteArray = [Convert]::FromBase64String($PublicKey)
            $privateKeyByteArray = [Convert]::FromBase64String($PrivateKey)
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }

        if ($publicKeyByteArray.Length -ne 32) { throw 'Invalid public key.' }
        if ($privateKeyByteArray.Length -ne 32) { throw 'Invalid private key.' }

        $overhead = [PSModule.Sodium]::crypto_box_sealbytes().ToUInt32()
        $decryptedBytes = New-Object byte[] ($ciphertext.Length - $overhead)

        # Attempt to decrypt
        $result = [PSModule.Sodium]::crypto_box_seal_open(
            $decryptedBytes, $ciphertext, [uint64]$ciphertext.Length, $publicKeyByteArray, $privateKeyByteArray
        )

        if ($result -ne 0) {
            throw 'Decryption failed.'
        }

        return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    }
}
