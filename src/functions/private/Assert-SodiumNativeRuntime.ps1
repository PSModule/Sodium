function Assert-SodiumNativeRuntime {
    <#
        .SYNOPSIS
        Provides platform-specific diagnostics after Sodium native initialization fails.

        .DESCRIPTION
        Checks the Windows Visual C++ runtime after a native initialization exception and throws a targeted message when the required
        runtime is unavailable.

        .NOTES
        This function only runs after native library loading fails, which cannot be reproduced safely after the library is loaded in the test process.
    #>
    [System.Diagnostics.CodeAnalysis.ExcludeFromCodeCoverageAttribute()]
    [OutputType([void])]
    [CmdletBinding()]
    param()

    process {
        if ($IsWindows -and $script:ProcessArchitecture -in @('X64', 'X86')) {
            $hasRuntime = Assert-VisualCRedistributableInstalled -Version '14.0' -Architecture $script:ProcessArchitecture
            if (-not $hasRuntime) {
                $message = "Sodium native initialization failed; the Visual C++ Redistributable for " +
                "$($script:ProcessArchitecture) appears to be missing or below the required version."
                throw $message
            }
        }
    }
}
