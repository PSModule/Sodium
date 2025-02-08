function ConvertTo-SodiumSealedBox {
    <#
        .SYNOPSIS
        Encrypts a message using a sealed public key box.

        .DESCRIPTION
        This function encrypts a given message using a public key with the SealedPublicKeyBox method from the Sodium library.
        The result is a base64-encoded sealed box that can only be decrypted by the corresponding private key.

        .EXAMPLE
        ConvertTo-SodiumSealedBox -Message "Hello world!" -PublicKey "BASE64_PUBLIC_KEY"

        Encrypts the message "Hello world!" using the provided base64-encoded public key and returns a base64-encoded sealed box.

        .LINK
        https://psmodule.io/Sodium/Functions/ConvertTo-SodiumSealedBox/

        .LINK
        https://doc.libsodium.org/public-key_cryptography/sealed_boxes
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The message string to be encrypted.
        [Parameter(Mandatory)]
        [string] $Message,

        # The base64-encoded public key used for encryption.
        [Parameter(Mandatory)]
        [string] $PublicKey
    )
    begin {
        $null = [PSModule.Sodium]::sodium_init()
    }

    process {
        # Convert public key from Base64 or space-separated string
        $publicKeyByteArray = [Convert]::FromBase64String($PublicKey)
        if ($publicKeyByteArray.Length -ne 32) {
            throw "Invalid public key. Expected 32 bytes but got $($publicKeyByteArray.Length)."
        }

        $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
        $overhead = [PSModule.Sodium]::crypto_box_sealbytes().ToUInt32()
        $cipherLength = $messageBytes.Length + $overhead
        $ciphertext = New-Object byte[] $cipherLength

        # Encrypt message
        $result = [PSModule.Sodium]::crypto_box_seal($ciphertext, $messageBytes, [uint64]$messageBytes.Length, $publicKeyByteArray)

        if ($result -ne 0) {
            throw 'Encryption failed.'
        }

        return [Convert]::ToBase64String($ciphertext)
    }
}
