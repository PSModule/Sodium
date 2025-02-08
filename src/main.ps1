switch ($true) {
    $IsLinux {
        Import-Module "$PSScriptRoot/libs/linux-x64/PSModule.Sodium.dll"
        $script:Supported = $true
    }
    $IsMacOS {
        if ("$(sysctl -n machdep.cpu.brand_string)" -Like 'Apple*') {
            Import-Module "$PSScriptRoot/libs/osx-arm64/PSModule.Sodium.dll"
        } else {
            Import-Module "$PSScriptRoot/libs/osx-x64/PSModule.Sodium.dll"
        }
        $script:Supported = $true
    }
    $IsWindows {
        if ([System.Environment]::Is64BitProcess) {
            Import-Module "$PSScriptRoot/libs/win-x64/PSModule.Sodium.dll"
        } else {
            Import-Module "$PSScriptRoot/libs/win-x86/PSModule.Sodium.dll"
        }
        $script:Supported = Assert-VisualCRedistributableInstalled -Version '14.29.30037'
    }
    default {
        throw 'Unsupported platform. Please refer to the documentation for more information.'
    }
}
