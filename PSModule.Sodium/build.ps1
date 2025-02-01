<#
    .SYNOPSIS
    Build script for the PSModule.Sodium binary module.

    .DESCRIPTION
    This script builds the PSModule.Sodium binary module. It uses the .NET CLI to build the module and then copies the
    output to the appropriate location in the repository.
    The built module is copied to the src\modules\PSModule.Sodium folder in the repository, which becomes a nested module
    in the main module. The script also copies the unmanaged runtime assemblies to the isolated folder in the module.

    The user functions will rely on the managed assemblies in the lib folder, while the internal functions will rely on
    the unmanaged runtime assemblies in the isolated folder.

    .LINK
    https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/resolving-dependency-conflicts?view=powershell-7.4#more-robust-solutions
#>

param(
    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration = 'Release'
)
$repoRootPath = (Get-Item -Path $PSScriptRoot).Parent
Write-Verbose "Repo Root Path: $repoRootPath"
$outPath = Join-Path -Path $repoRootPath.FullName 'src\modules\PSModule.Sodium'
Write-Verbose "Out Path:       $outPath"
if (Test-Path $outPath) {
    $outPath | Get-ChildItem -Exclude *.psd1 -Force -Recurse | Remove-Item -Force -Recurse
}
$isolatedLibPath = Join-Path -Path $outPath -ChildPath isolated
$runtimesLibPath = Join-Path -Path $isolatedLibPath -ChildPath runtimes

Push-Location "$PSScriptRoot/PSModule.Sodium"
try {
    dotnet publish --configuration $Configuration
} finally {
    Pop-Location
}

# Copy selected unmanaged runtimes/[selected]/native/* assemblies to the isolated folder
New-Item -Path $runtimesLibPath -ItemType Directory -Force
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/net8.0/publish/runtimes" -Directory |
    Where-Object { $_.Name -match '(win-x(64|86))|(linux-(arm|x)64)|(osx-(arm|x)64)' } |
    ForEach-Object { Copy-Item -Path $_.FullName -Destination (Join-Path -Path $runtimesLibPath -ChildPath $_.Name) -Recurse }

# Copy Nested Binary Module managed assemblies to lib
New-Item -Path $outPath -ItemType Directory -Force
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/net8.0/publish" -File |
    Where-Object { $_.BaseName -eq 'PSModule.Sodium' -and $_.Extension -in '.dll' } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $outPath }

# Copy other managed assemblies to lib/isolated
New-Item -Path $isolatedLibPath -ItemType Directory -Force
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/net8.0/publish" -File |
    Where-Object { $_.BaseName -ne 'PSModule.Sodium' } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $isolatedLibPath }
