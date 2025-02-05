switch ($true) {
    $IsLinux {
        & "$PSScriptRoot/libs/linux-x64/main.ps1"
    }
    $IsMacOS {
        if ("$(sysctl -n machdep.cpu.brand_string)" -Like 'Apple*') {
            & "$PSScriptRoot/libs/osx-arm64/main.ps1"
        } else {
            & "$PSScriptRoot/libs/osx-x64/main.ps1"
        }
    }
    $IsWindows {
        if ([System.Environment]::Is64BitProcess) {
            & "$PSScriptRoot/libs/win-x64/main.ps1"
        } else {
            & "$PSScriptRoot/libs/win-x86/main.ps1"
        }
    }
    default {
        throw 'Unsupported platform. Please refer to the documentation for more information.'
    }
}

[Sodium]::sodium_init()
