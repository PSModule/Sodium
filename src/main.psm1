switch ($true) {
    $IsLinux {
        Import-Module "$PSScriptRoot/libs/linux-x64/main.ps1"
    }
    $IsMacOS {
        if ("$(sysctl -n machdep.cpu.brand_string)" -Like 'Apple*') {
            Import-Module "$PSScriptRoot/libs/osx-arm64/main.ps1"
        } else {
            Import-Module "$PSScriptRoot/libs/osx-x64/main.ps1"
        }

    }
    default {
        if ([System.Environment]::Is64BitProcess) {
            Import-Module "$PSScriptRoot/libs/win-x64/main.ps1"
        } else {
            Import-Module "$PSScriptRoot/libs/win-x86/main.ps1"
        }
    }
}
