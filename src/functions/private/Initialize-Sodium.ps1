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

        $initializationResult = [PSModule.Sodium]::sodium_init()
        if ($initializationResult -lt 0) {
            throw 'Sodium initialization failed.'
        }

        $script:SodiumPublicKeyBytes = [PSModule.Sodium]::crypto_box_publickeybytes().ToUInt32()
        $script:SodiumPrivateKeyBytes = [PSModule.Sodium]::crypto_box_secretkeybytes().ToUInt32()
        $script:SodiumSealBytes = [PSModule.Sodium]::crypto_box_sealbytes().ToUInt32()
        $script:SodiumInitialized = $true
    }

    end {}
}
