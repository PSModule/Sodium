function Initialize-Sodium {
    <#
        .SYNOPSIS
        Initializes the Sodium cryptographic library.

        .DESCRIPTION
        Calls the sodium_init() function from the PSModule.Sodium namespace to initialize the Sodium cryptographic library.
        This function must be called before using any other Sodium cryptographic functions.

        .EXAMPLE
        Initialize-Sodium

        Initializes the Sodium cryptographic library for use.

        .NOTES
        Ensure that the PSModule.Sodium module is properly installed and loaded before calling this function.
    #>
    [CmdletBinding()]
    param ()

    $null = [PSModule.Sodium]::sodium_init()
}
