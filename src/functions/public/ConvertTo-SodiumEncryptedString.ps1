function ConvertTo-SodiumEncryptedString {
    <#
        .SYNOPSIS
        Encrypts a secret using a sealed public key box.

        .DESCRIPTION
        This function encrypts a given secret using a public key with the SealedPublicKeyBox method from the Sodium library.
        The result is a Base64-encoded sealed box that can only be decrypted by the corresponding private key.

        .EXAMPLE
        ConvertTo-SodiumEncryptedString -Secret "mysecret" -PublicKey "BASE64_PUBLIC_KEY"

        Encrypts the secret "mysecret" using the provided Base64-encoded public key and returns a Base64-encoded sealed box.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The secret string to be encrypted.
        [Parameter(Mandatory)]
        [string] $Secret,

        # The Base64-encoded public key used for encryption.
        [Parameter(Mandatory)]
        [string] $PublicKey
    )

    [System.Convert]::ToBase64String(
        [Sodium.SealedPublicKeyBox]::Create(
            [System.Text.Encoding]::UTF8.GetBytes($Secret),
            [System.Convert]::FromBase64String($PublicKey)
        )
    )
}
