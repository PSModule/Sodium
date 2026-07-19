function Initialize-Sodium {
    <#
        .SYNOPSIS
        Initializes Sodium for cryptographic operations.

        .DESCRIPTION
        Initializes the native Sodium library once per module session and caches fixed buffer sizes used by the public commands.

        .NOTES
        Requires the platform-specific PSModule.Sodium assembly and native libsodium runtime to be loaded.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param()

    begin {}

    process {
        if (-not $script:Supported) { throw 'Sodium is not supported on this platform.' }
        if ($script:SodiumInitialized) { return }

        try {
            $initializationResult = [PSModule.Sodium]::sodium_init()
        } catch {
            $script:Supported = $false
            Assert-SodiumNativeRuntime
            throw
        }
        if ($initializationResult -lt 0) {
            throw 'Sodium initialization failed.'
        }

        # Fixed crypto_box constants (curve25519xsalsa20poly1305). The C# layer queries and validates the real
        # native values at type initialization; hardcoding here avoids four extra interop call sites at import.
        $script:SodiumPublicKeyBytes = 32u
        $script:SodiumPrivateKeyBytes = 32u
        $script:SodiumSealBytes = 48u
        $script:SodiumSeedBytes = 32u
        $script:SodiumInitialized = $true
    }

    end {}
}
