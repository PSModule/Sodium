function New-SodiumKeyPair {
    <#
        .SYNOPSIS
        Generates a new Sodium key pair.

        .DESCRIPTION
        This function creates a new cryptographic key pair using Sodium's PublicKeyBox.
        The keys are returned as a PowerShell custom object, with both the public and private keys
        encoded in base64 format.

        .EXAMPLE
        New-SodiumKeyPair

        Generates a new key pair and returns a custom object containing the base64-encoded
        public and private keys.

        .LINK
        https://psmodule.io/Sodium/Functions/New-SodiumKeyPair/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Scope = 'Function',
        Justification = 'Does not change state'
    )]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    New-PublicKeyBoxKeyPair
}
