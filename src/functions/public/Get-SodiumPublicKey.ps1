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
        WQakMx2mIAQMwLqiZteHUTwmMP6mUdK2FL0WEybWgB8=
        ```

        Derives and returns the public key corresponding to the given base64-encoded private key.

        .EXAMPLE
        Get-SodiumPublicKey -PrivateKey 'ci5/7eZ0IbGXtqQMaNvxhJ2d9qwFxA8Kjx+vivSTXqU=' -AsByteArray

        Output:
        ```powershell
        89
        6
        164
        51
        29
        166
        32
        4
        12
        192
        186
        162
        102
        215
        135
        81
        60
        38
        48
        254
        166
        81
        210
        182
        20
        189
        22
        19
        38
        214
        128
        31
        ```

        .OUTPUTS
        string

        .OUTPUTS
        byte[]

        .LINK
        https://psmodule.io/Sodium/Functions/Get-SodiumPublicKey/
    #>

    [OutputType([string], ParameterSetName = 'Base64')]
    [OutputType([byte[]], ParameterSetName = 'AsByteArray')]
    [CmdletBinding(DefaultParameterSetName = 'Base64')]
    [CmdletBinding()]
    param(
        # The private key to derive the public key from.
        [Parameter(Mandatory)]
        [string] $PrivateKey,

        # Returns the byte array
        [Parameter(Mandatory, ParameterSetName = 'AsByteArray')]
        [switch] $AsByteArray
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
        if ($AsByteArray) {
            return $publicKeyByteArray
        } else {
            return [System.Convert]::ToBase64String($publicKeyByteArray)
        }
    }
}
