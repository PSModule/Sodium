function ConvertTo-SodiumSealedBox {
    <#
        .SYNOPSIS
        Encrypts a message using a sealed public key box.

        .DESCRIPTION
        This function encrypts a given message using a public key with the SealedPublicKeyBox method from the Sodium library.
        The result is a base64-encoded sealed box that can only be decrypted by the corresponding private key.

        .EXAMPLE
        ConvertTo-SodiumSealedBox -Message "Hello world!" -PublicKey $publicKey

        Output:
        ```powershell
        hhCon4PO1X0TIPeh1i4GM6Wg9HSF5ge/x4L7p1vNd3lIdiJqNmBfswkcHipyM4HUr9wDLebjARVp5tsB
        ```

        Encrypts the message "Hello world!" using the provided base64-encoded public key and returns a base64-encoded sealed box.

        .EXAMPLE
        "Sensitive Data" | ConvertTo-SodiumSealedBox -PublicKey $publicKey

        Output:
        ```powershell
        p3PGL162uLCvrsCRLUDrc/Kfc5biGVzxRDg25ZdJoR9Y6ABZUKo8pvDoOGdchv0iBYQO2LP0Q6BkVbIDBUw=
        ```

        Uses pipeline input to encrypt the provided message using the specified public key.

        .OUTPUTS
        System.String

        .NOTES
        The function returns a base64-encoded sealed box string that can only be decrypted by the corresponding private key.

        .LINK
        https://psmodule.io/Sodium/Functions/ConvertTo-SodiumSealedBox/

        .LINK
        https://doc.libsodium.org/public-key_cryptography/sealed_boxes
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The message string to be encrypted.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Message,

        # The base64-encoded public key used for encryption.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PublicKey
    )
    begin {}

    process {
        $messageBytes = $null
        try {
            $publicKeyByteArray = [Convert]::FromBase64String($PublicKey)
            if ($publicKeyByteArray.Length -ne $script:SodiumPublicKeyBytes) {
                throw "Invalid public key. Expected $script:SodiumPublicKeyBytes bytes but got $($publicKeyByteArray.Length)."
            }

            $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)
            $cipherLength = $messageBytes.Length + $script:SodiumSealBytes
            $ciphertext = [byte[]]::new($cipherLength)

            $result = [PSModule.Sodium]::crypto_box_seal($ciphertext, $messageBytes, [uint64]$messageBytes.Length, $publicKeyByteArray)

            if ($result -ne 0) {
                throw 'Encryption failed.'
            }

            return [Convert]::ToBase64String($ciphertext)
        } finally {
            if ($null -ne $messageBytes -and $messageBytes.Length -gt 0) {
                [array]::Clear($messageBytes, 0, $messageBytes.Length)
            }
        }
    }
}
