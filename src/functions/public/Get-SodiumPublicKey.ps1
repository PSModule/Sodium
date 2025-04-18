function Get-SodiumPublicKey {
    <#
        .SYNOPSIS
        Derives a Curve25519 public key from a provided private key using the Sodium cryptographic library.

        .DESCRIPTION
        Takes a base64-encoded Curve25519 private key and returns the corresponding base64-encoded public key. This is accomplished using the
        Libsodium `crypto_scalarmult_base` function provided by the PSModule.Sodium .NET wrapper. The function ensures compatibility with
        cryptographic operations requiring key exchange mechanisms.

        .EXAMPLE
        Get-SodiumPublicKey -PrivateKey 'ci5/7eZ0IbGXtqQMaNvxhJ2d9qwFxA8Kjx+vivSTXqU='

        Output:
        ```powershell

        ```

        Derives and returns the public key corresponding to the given base64-encoded private key.

        .EXAMPLE
        Get-SodiumPublicKey -PrivateKey 'ci5/7eZ0IbGXtqQMaNvxhJ2d9qwFxA8Kjx+vivSTXqU=' -Base64

        Output:
        ```powershell
        WQakMx2mIAQMwLqiZteHUTwmMP6mUdK2FL0WEybWgB8=
        ```


        .OUTPUTS
        string

        .LINK
        https://psmodule.io/Sodium/Functions/Get-SodiumPublicKey/
    #>

    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The private key to derive the public key from.
        [Parameter(Mandatory)]
        [string] $PrivateKey,

        # Returns the public key in a base64-encoded format.
        [switch] $Base64
    )

    begin {
        if (-not $script:Supported) { throw 'Sodium is not supported on this platform.' }
        $null = [PSModule.Sodium]::sodium_init()
    }

    process {
        $publicKeyByteArray = New-Object byte[] 32
        $privateKeyByteArray = [System.Convert]::FromBase64String($PrivateKey)
        $rc = [PSModule.Sodium]::crypto_scalarmult_base($publicKeyByteArray, $privateKeyByteArray)
        if ($rc -ne 0) { throw 'Unable to derive public key from private key.' }
    }

    end {
        if ($Base64) {
            return [System.Convert]::ToBase64String($publicKeyByteArray)
        } else {
            return $publicKeyByteArray
        }
    }
}
