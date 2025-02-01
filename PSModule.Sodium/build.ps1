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

    .LINK
    https://github.com/rjmholt/ModuleDependencyIsolationExample
#>

param(
    # The configuration to build the module in. Defaults to 'Release'.
    [ValidateSet('Debug', 'Release')]
    [string] $Configuration = 'Release',

    # The target framework to build the module for. Defaults to 'net8.0'.
    [string] $TargetFramework = 'net8.0'
)

$repoRootPath = (Get-Item -Path $PSScriptRoot).Parent
Write-Verbose "Repo Root Path: $repoRootPath"

Write-Verbose 'Building PSModule.Sodium'
Push-Location "$PSScriptRoot/PSModule.Sodium"
try {
    dotnet publish --configuration $Configuration
    if ([int]$LASTEXISTCODE -ne 0) {
        Write-Warning "[$LASTEXITCODE]"
        throw "Failed to build PSModule.Sodium"
    }
} finally {
    Pop-Location
}

Write-Verbose "Creating lib and isolated folders in the 'PSModule.Sodium' nested module"
Write-Verbose 'Copy nested binary module to:'
$outPath = Join-Path -Path $repoRootPath.FullName 'src\modules\PSModule.Sodium'
Write-Verbose "-> [$outPath]"
$outPath | Get-ChildItem | Remove-Item -Force -Recurse
$out = New-Item -Path $outPath -ItemType Directory -Force
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/$TargetFramework/publish" -File |
    Where-Object { $_.BaseName -eq 'PSModule.Sodium' -and $_.Extension -in '.dll' } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $out }

Write-Verbose 'Copy other managed assemblies to:'
$isolatedLibPath = Join-Path -Path $outPath -ChildPath 'isolated'
Write-Verbose "-> [$isolatedLibPath]"
$isolatedLib = New-Item -Path $isolatedLibPath -ItemType Directory -Force
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/$TargetFramework/publish" -File |
    Where-Object { $_.BaseName -ne 'PSModule.Sodium' } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $isolatedLib }

Write-Verbose 'Copy unmanaged runtime assemblies to:'
$runtimesLibPath = Join-Path -Path $isolatedLibPath -ChildPath 'runtimes'
Write-Verbose "-> [$runtimesLibPath]"
$runtimesLib = New-Item -Path $runtimesLibPath -ItemType Directory -Force
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/$TargetFramework/publish/runtimes" -Directory |
    Where-Object { $_.Name -match '(win-x(64|86))|(linux-(arm|x)64)|(osx-(arm|x)64)' } |
    ForEach-Object {
        $destination = Join-Path -Path $runtimesLib -ChildPath $_.Name
        Copy-Item -Path $_.FullName -Destination $destination -Recurse
    }
