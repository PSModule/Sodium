# This script is only to debug versions locally. It is not used in the module or in the build process.

@(
    [PSCustomObject]@{
        Name            = 'libsodium'
        Path            = "$PSScriptRootlib\libsodium"
        RequiredVersion = '1.0.19'
        Important       = 'runtimes'
    }
    [PSCustomObject]@{
        Name            = 'libsodium'
        Path            = "$PSScriptRootlib\libsodium"
        RequiredVersion = '1.0.19.1'
        Important       = 'runtimes'
    }
    [PSCustomObject]@{
        Name            = 'libsodium'
        Path            = "$PSScriptRootlib\libsodium"
        RequiredVersion = '1.0.19.2'
        Important       = 'runtimes'
    }
    [PSCustomObject]@{
        Name            = 'libsodium'
        Path            = "$PSScriptRootlib\libsodium"
        RequiredVersion = '1.0.20.0'
        Important       = 'runtimes'
    }
    [PSCustomObject]@{
        Name            = 'libsodium'
        Path            = "$PSScriptRootlib\libsodium"
        RequiredVersion = '1.0.20.1'
        Important       = 'runtimes'
    }
    [PSCustomObject]@{
        Name            = 'Sodium.Core'
        Path            = "$PSScriptRootlib\Sodium.Core"
        RequiredVersion = '1.3.5'
        Important       = 'lib'
    }
    # [PSCustomObject]@{
    #     Name            = 'Sodium.Core'
    #     Path            = "$PSScriptRootlib\Sodium.Core"
    #     RequiredVersion = '1.4.0-preview.1'
    #     Important       = 'lib'
    # }
) | ForEach-Object {
    $package = $_
    New-Item -Path $package.Path -ItemType Directory -Force
    Save-Package -Name $package.Name -Path $package.Path -RequiredVersion $package.RequiredVersion
    Get-ChildItem -Path $package.Path -Filter '*.nupkg' | ForEach-Object {
        Remove-Item -Path "$($package.Path)\$($_.BaseName)" -Recurse -Force -ErrorAction SilentlyContinue
        Expand-Archive -Path $_.FullName -DestinationPath "$($package.Path)\$($_.BaseName)"
        Remove-Item -Path $_.FullName -Force
        Get-ChildItem -Path "$($package.Path)\$($_.BaseName)" -Exclude $package.Important | Remove-Item -Recurse -Force
    }
}
