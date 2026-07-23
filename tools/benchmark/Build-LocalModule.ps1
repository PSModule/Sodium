<#
    .SYNOPSIS
    Assembles an importable Sodium module from the src folder for local testing and benchmarking.

    .DESCRIPTION
    Mimics the PSModule build pipeline order (variables -> private functions -> public functions -> main.ps1)
    and produces a Sodium.psd1/Sodium.psm1 pair with the native libs copied alongside.

    .EXAMPLE
    .\Build-LocalModule.ps1 -OutputPath $env:TEMP\SodiumBench
#>
[CmdletBinding()]
param(
    # Path to the module source folder. Defaults to <repo>/src.
    [Parameter()]
    [string] $SourcePath = (Join-Path -Path $PSScriptRoot -ChildPath '..\..\src'),

    # Folder in which the 'Sodium' module folder is created.
    [Parameter(Mandatory)]
    [string] $OutputPath
)
$ErrorActionPreference = 'Stop'

$SourcePath = (Resolve-Path $SourcePath).Path
$moduleDir = Join-Path $OutputPath 'Sodium'
if (Test-Path $moduleDir) {
    try {
        Remove-Item $moduleDir -Recurse -Force
    } catch {
        # Native libs may be locked by a process that imported a previous build; build into a unique folder instead.
        $moduleDir = Join-Path $OutputPath "Sodium-$([Guid]::NewGuid().ToString('N').Substring(0, 8))"
        Write-Verbose "Previous build is locked; building into $moduleDir" -Verbose
    }
}
New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null

$sb = [System.Text.StringBuilder]::new()
$publicFunctions = @()

foreach ($file in (Get-ChildItem (Join-Path -Path $SourcePath -ChildPath 'variables\private') -Filter *.ps1 -ErrorAction SilentlyContinue)) {
    [void]$sb.AppendLine((Get-Content $file.FullName -Raw))
}
foreach ($file in (Get-ChildItem (Join-Path -Path $SourcePath -ChildPath 'functions\private') -Filter *.ps1)) {
    [void]$sb.AppendLine((Get-Content $file.FullName -Raw))
}
foreach ($file in (Get-ChildItem (Join-Path -Path $SourcePath -ChildPath 'functions\public') -Filter *.ps1)) {
    [void]$sb.AppendLine((Get-Content $file.FullName -Raw))
    $publicFunctions += $file.BaseName
}
$mainPath = Join-Path -Path $SourcePath -ChildPath 'main.ps1'
if (Test-Path $mainPath) {
    [void]$sb.AppendLine((Get-Content $mainPath -Raw))
}
[void]$sb.AppendLine("Export-ModuleMember -Function '$($publicFunctions -join "', '")' -Alias '*'")

Set-Content -Path (Join-Path -Path $moduleDir -ChildPath 'Sodium.psm1') -Value $sb.ToString() -Encoding UTF8BOM

Copy-Item -Path (Join-Path -Path $SourcePath -ChildPath 'libs') -Destination $moduleDir -Recurse

New-ModuleManifest -Path (Join-Path -Path $moduleDir -ChildPath 'Sodium.psd1') `
    -RootModule 'Sodium.psm1' `
    -ModuleVersion '999.0.0' `
    -FunctionsToExport $publicFunctions `
    -CmdletsToExport @() -VariablesToExport @() -AliasesToExport @()

Write-Verbose "Built module at $moduleDir" -Verbose
Join-Path -Path $moduleDir -ChildPath 'Sodium.psd1'
