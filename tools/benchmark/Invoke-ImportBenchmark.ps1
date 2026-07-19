<#
    .SYNOPSIS
    Measures cold module import time in fresh PowerShell processes.

    .DESCRIPTION
    Starts a new pwsh process per sample, imports the module once and reports average/min/max import time.
    This is the dominant cost when the module is started in multiple sessions.

    .EXAMPLE
    .\Invoke-ImportBenchmark.ps1 -ModulePath C:\temp\SodiumBench\Sodium\Sodium.psd1 -Label baseline
#>
[CmdletBinding()]
param(
    # Path to the Sodium.psd1 to benchmark. Defaults to building the module from src into a temp folder.
    [Parameter()]
    [string] $ModulePath,

    # Label used in output file name (import-<Label>.json).
    [Parameter()]
    [string] $Label = 'run',

    # Number of fresh-process samples.
    [Parameter()]
    [int] $Samples = 7,

    # Folder to write the JSON results to. Defaults to the current directory.
    [Parameter()]
    [string] $OutputPath = (Get-Location).Path
)
$ErrorActionPreference = 'Stop'

if (-not $ModulePath) {
    $ModulePath = & (Join-Path -Path $PSScriptRoot -ChildPath 'Build-LocalModule.ps1') -OutputPath (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'SodiumBench')
}

$times = for ($i = 0; $i -lt $Samples; $i++) {
    $out = pwsh -NoProfile -NonInteractive -Command "
        `$sw = [System.Diagnostics.Stopwatch]::StartNew()
        Import-Module '$ModulePath' -ErrorAction Stop
        `$sw.Stop()
        `$sw.Elapsed.TotalMilliseconds
    "
    [double]($out | Select-Object -Last 1)
}
$stats = $times | Measure-Object -Average -Minimum -Maximum
$result = [pscustomobject]@{
    Name    = 'Cold import (new pwsh process)'
    Samples = $Samples
    AvgMs   = [math]::Round($stats.Average, 1)
    MinMs   = [math]::Round($stats.Minimum, 1)
    MaxMs   = [math]::Round($stats.Maximum, 1)
}
$result | Format-Table -AutoSize | Out-String | Write-Output
$outFile = Join-Path -Path $OutputPath -ChildPath "import-$Label.json"
$result | ConvertTo-Json | Set-Content -Path $outFile
Write-Verbose "Saved $outFile" -Verbose
