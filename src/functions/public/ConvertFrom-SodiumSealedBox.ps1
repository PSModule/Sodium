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

    begin {}

    process {
        try {
            if ($PublicKey) {
                return [PSModule.Sodium]::OpenSealBase64($SealedBox, $PrivateKey, $PublicKey)
            }
            return [PSModule.Sodium]::OpenSealBase64($SealedBox, $PrivateKey)
        } catch [System.Management.Automation.MethodInvocationException] {
            throw $_.Exception.InnerException
        }
    }
}
