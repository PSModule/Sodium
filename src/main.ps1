$processArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture

switch ($true) {
    $IsLinux {
        switch ($processArchitecture) {
            'Arm64' { $runtimeIdentifier = 'linux-arm64' }
            'X64' { $runtimeIdentifier = 'linux-x64' }
            default {
                throw "Unsupported Linux process architecture: $processArchitecture. Please refer to the documentation for supported architectures."
            }
        }
    }
    $IsMacOS {
        switch ($processArchitecture) {
            'Arm64' { $runtimeIdentifier = 'osx-arm64' }
            'X64' { $runtimeIdentifier = 'osx-x64' }
            default {
                throw "Unsupported macOS process architecture: $processArchitecture. Please refer to the documentation for supported architectures."
            }
        }
    }
    $IsWindows {
        switch ($processArchitecture) {
            'X64' { $runtimeIdentifier = 'win-x64' }
            'X86' { $runtimeIdentifier = 'win-x86' }
            default {
                throw "Unsupported Windows process architecture: $processArchitecture. Please refer to the documentation for supported architectures."
            }
        }
    }
    default {
        throw 'Unsupported platform. Please refer to the documentation for more information.'
    }
}

$assemblyPath = Join-Path -Path $PSScriptRoot -ChildPath "libs/$runtimeIdentifier/PSModule.Sodium.dll"
Import-Module $assemblyPath -ErrorAction Stop

# Optimistically mark supported; Initialize-Sodium will run the Windows VC++ runtime check lazily only if native init fails.
$script:Supported = $true
$script:ProcessArchitecture = $processArchitecture.ToString()

Initialize-Sodium
