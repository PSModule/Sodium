function Resolve-SodiumRuntimeIdentifier {
    <#
        .SYNOPSIS
        Resolves the native Sodium runtime identifier.

        .DESCRIPTION
        Maps the active operating system and process architecture to the runtime identifier used by the bundled native library.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Runtime.InteropServices.Architecture] $ProcessArchitecture,

        [Parameter()]
        [switch] $Linux,

        [Parameter()]
        [switch] $MacOS,

        [Parameter()]
        [switch] $Windows
    )

    process {
        switch ($true) {
            $Linux {
                switch ($ProcessArchitecture) {
                    'Arm64' { return 'linux-arm64' }
                    'X64' { return 'linux-x64' }
                    default {
                        $message = "Unsupported Linux process architecture: $ProcessArchitecture. " +
                        'Please refer to the documentation for supported architectures.'
                        throw $message
                    }
                }
            }
            $MacOS {
                switch ($ProcessArchitecture) {
                    'Arm64' { return 'osx-arm64' }
                    'X64' { return 'osx-x64' }
                    default {
                        $message = "Unsupported macOS process architecture: $ProcessArchitecture. " +
                        'Please refer to the documentation for supported architectures.'
                        throw $message
                    }
                }
            }
            $Windows {
                switch ($ProcessArchitecture) {
                    'X64' { return 'win-x64' }
                    'X86' { return 'win-x86' }
                    default {
                        $message = "Unsupported Windows process architecture: $ProcessArchitecture. " +
                        'Please refer to the documentation for supported architectures.'
                        throw $message
                    }
                }
            }
            default {
                throw 'Unsupported platform. Please refer to the documentation for more information.'
            }
        }
    }
}
