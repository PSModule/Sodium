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

    Open-SealedPublicKeyBox -EncryptedSecret $EncryptedSecret -PrivateKey $PrivateKey -PublicKey $PublicKey
}
