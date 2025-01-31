function ConvertFrom-SodiumEncryptedString {
    <#
        .SYNOPSIS
        Decrypts a Base64-encoded, Sodium-encrypted string.

        .DESCRIPTION
        Converts a Base64-encoded, Sodium-encrypted string into its original plaintext form.
        Uses the provided public and private keys to decrypt the sealed message.

        .EXAMPLE
        $params = @{
            EncryptedSecret = $encryptedSecret
            PublicKey       = $publicKey
            PrivateKey      = $privateKey
        }
        ConvertFrom-SodiumEncryptedString @params

        Decrypts the given encrypted secret using the specified public and private keys and returns the original string.

        .NOTES
        Uses the Sodium library for encryption and decryption.
        Ensure the provided keys are correctly formatted in Base64.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The Base64-encoded encrypted secret string to decrypt.
        [Parameter(Mandatory)]
        [string] $EncryptedSecret,

        # The Base64-encoded public key used for decryption.
        [Parameter(Mandatory)]
        [string] $PublicKey,

        # The Base64-encoded private key used for decryption.
        [Parameter(Mandatory)]
        [string] $PrivateKey
    )

    try {
        # Convert from Base64 to raw bytes
        $sealedBoxBytes = [System.Convert]::FromBase64String($EncryptedSecret)
        $publicKeyBytes = [System.Convert]::FromBase64String($PublicKey)
        $privateKeyBytes = [System.Convert]::FromBase64String($PrivateKey)

        # Decrypt using the SealedPublicKeyBox class from Sodium
        $decryptedBytes = [Sodium.SealedPublicKeyBox]::Open(
            $sealedBoxBytes,
            $privateKeyBytes,
            $publicKeyBytes
        )

        # Convert decrypted bytes back to a string
        $decryptedString = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)

        return $decryptedString
    } catch {
        Write-Error "Failed to decrypt the sealed message."
        throw $_
    }
}
