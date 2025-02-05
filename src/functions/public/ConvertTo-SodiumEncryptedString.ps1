function ConvertTo-SodiumEncryptedString {
    <#
        .SYNOPSIS
        Encrypts a secret using a sealed public key box.

        .DESCRIPTION
        This function encrypts a given secret using a public key with the SealedPublicKeyBox method from the Sodium library.
        The result is a base64-encoded sealed box that can only be decrypted by the corresponding private key.

        .EXAMPLE
        ConvertTo-SodiumEncryptedString -Secret "mysecret" -PublicKey "BASE64_PUBLIC_KEY"

        Encrypts the secret "mysecret" using the provided base64-encoded public key and returns a base64-encoded sealed box.

        .LINK
        https://psmodule.io/Sodium/Functions/ConvertTo-SodiumEncryptedString/
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The secret string to be encrypted.
        [Parameter(Mandatory)]
        [string] $Secret,

        # The base64-encoded public key used for encryption.
        [Parameter(Mandatory)]
        [string] $PublicKey
    )

    $publicKey = [Convert]::FromBase64String($PublicKey)
    $secretBytes = [System.Text.Encoding]::UTF8.GetBytes($Secret)

    $overhead = [Sodium]::crypto_box_sealbytes().ToUInt32()
    $cipherLength = $secretBytes.Length + $overhead
    $ciphertext = New-Object byte[] $cipherLength

    # Encrypt message
    $result = [Sodium]::crypto_box_seal($ciphertext, $secretBytes, [uint64]$secretBytes.Length, $publicKey)

    if ($result -ne 0) {
        throw 'Encryption failed.'
    }

    return [Convert]::ToBase64String($ciphertext)
}
