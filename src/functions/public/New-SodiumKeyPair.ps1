function New-SodiumKeyPair {
    <#
        .SYNOPSIS
        Generates a new Sodium key pair.

        .DESCRIPTION
        This function creates a new cryptographic key pair using Sodium's PublicKeyBox.
        The keys are returned as a PowerShell custom object, with both the public and private keys
        encoded in base64 format.

        If a seed is provided, the key pair is deterministically generated using a SHA-256 derived seed.
        This ensures that the same input seed will always produce the same key pair.

        .EXAMPLE
        New-SodiumKeyPair

        Output:
        ```powershell
        PublicKey                                    PrivateKey
        ---------                                    ----------
        Ac0wdsq6lqLGktckJrasPcTbVRuUCU+OKzVpMno+v0g= PVXI64v00+aT2b2O6Q4l+SfMBUY2R/Nogsl2mp/hXAs=
        ```

        Generates a new key pair and returns a custom object containing the base64-encoded
        public and private keys.

        .EXAMPLE
        New-SodiumKeyPair -Seed "MySecureSeed"

        Output:
        ```powershell
        PublicKey                                    PrivateKey
        ---------                                    ----------
        WQakMx2mIAQMwLqiZteHUTwmMP6mUdK2FL0WEybWgB8= ci5/7eZ0IbGXtqQMaNvxhJ2d9qwFxA8Kjx+vivSTXqU=
        ```

        Generates a deterministic key pair using the given seed string. The same seed will produce
        the same key pair every time.

        .OUTPUTS
        pscustomobject. Returns a PowerShell custom object with the following properties:
        - **PublicKey**:  The base64-encoded public key.
        - **PrivateKey**: The base64-encoded private key.
        If key generation fails, an exception is thrown.

        .LINK
        https://psmodule.io/Sodium/Functions/New-SodiumKeyPair/

        .LINK
        https://doc.libsodium.org/public-key_cryptography/public-key_signatures
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = 'NewKeyPair')]
    param(
        # A seed value to use for key generation.
        [Parameter(Mandatory, ParameterSetName = 'SeededKeyPair')]
        [string] $Seed
    )

    begin {
        if (-not $script:Supported) { throw 'Sodium is not supported on this platform.' }
        $null = [PSModule.Sodium]::sodium_init()
    }

    process {
        $pkSize = [PSModule.Sodium]::crypto_box_publickeybytes().ToUInt32()
        $skSize = [PSModule.Sodium]::crypto_box_secretkeybytes().ToUInt32()
        $publicKey = New-Object byte[] $pkSize
        $privateKey = New-Object byte[] $skSize

        switch ($PSCmdlet.ParameterSetName) {
            'SeededKeyPair' {
                # Derive a 32-byte seed from the provided string seed (using SHA-256)
                $seedBytes = [System.Text.Encoding]::UTF8.GetBytes($Seed)
                $derivedSeed = [System.Security.Cryptography.SHA256]::Create().ComputeHash($seedBytes)
                $result = [PSModule.Sodium]::crypto_box_seed_keypair($publicKey, $privateKey, $derivedSeed)
                break
            }
            default {
                $result = [PSModule.Sodium]::crypto_box_keypair($publicKey, $privateKey)
            }
        }

        if ($result -ne 0) {
            throw 'Key pair generation failed.'
        }

        return [pscustomobject]@{
            PublicKey  = [Convert]::ToBase64String($publicKey)
            PrivateKey = [Convert]::ToBase64String($privateKey)
        }
    }
}
