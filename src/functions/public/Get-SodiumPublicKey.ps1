function Get-SodiumPublicKey {
    <#
        .SYNOPSIS
        Derives a Curve25519 public key from a provided private key using the Sodium cryptographic library.

        .DESCRIPTION
        Takes a Base64-encoded Curve25519 private key and returns the corresponding Base64-encoded public key. This is accomplished using the
        Libsodium `crypto_scalarmult_base` function provided by the PSModule.Sodium .NET wrapper. The function ensures compatibility with
        cryptographic operations requiring key exchange mechanisms.

        .EXAMPLE
        Get-SodiumPublicKey -PrivateKey 'ci5/7eZ0IbGXtqQMaNvxhJ2d9qwFxA8Kjx+vivSTXqU='

        Output:
        ```powershell
        WQakMx2mIAQMwLqiZteHUTwmMP6mUdK2FL0WEybWgB8=
        ```

        Derives and returns the public key corresponding to the given Base64-encoded private key.

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
        [string] $PrivateKey
    )

    ([Convert]::ToBase64String(
        [PSModule.Sodium]::crypto_scalarmult_base(
            [Convert]::FromBase64String($PrivateKey))))
}
