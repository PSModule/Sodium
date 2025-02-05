switch ($true) {
    $IsLinux {
        Import-Module "$PSScriptRoot/lib/linux-x64/PSModule.Sodium.dll"
    }
    $IsMacOS {
        if ("$(sysctl -n machdep.cpu.brand_string)" -Like 'Apple*') {
            Import-Module "$PSScriptRoot/lib/osx-arm64/PSModule.Sodium.dll"
        } else {
            Import-Module "$PSScriptRoot/lib/osx-x64/PSModule.Sodium.dll"
        }
    }
    $IsWindows {
        if ([System.Environment]::Is64BitProcess) {
            Import-Module "$PSScriptRoot/lib/win-x64/PSModule.Sodium.dll"
        } else {
            Import-Module "$PSScriptRoot/lib/win-x86/PSModule.Sodium.dll"
        }
    }
    default {
        throw 'Unsupported platform.'
    }
}
