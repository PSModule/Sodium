switch ($true) {
    $IsLinux {
        Import-Module "$PSScriptRoot/libs/linux-x64/PSModule.Sodium.dll"
    }
    $IsMacOS {
        if ("$(sysctl -n machdep.cpu.brand_string)" -Like 'Apple*') {
            Import-Module "$PSScriptRoot/libs/osx-arm64/PSModule.Sodium.dll"
        } else {
            Import-Module "$PSScriptRoot/libs/osx-x64/PSModule.Sodium.dll"
        }
    }
    $IsWindows {
        if ([System.Environment]::Is64BitProcess) {
            Import-Module "$PSScriptRoot/libs/win-x64/PSModule.Sodium.dll"
        } else {
            Import-Module "$PSScriptRoot/libs/win-x86/PSModule.Sodium.dll"
        }
    }
    default {
        throw 'Unsupported platform.'
    }
}
