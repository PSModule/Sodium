<#
    .SYNOPSIS
    Captures a Profiler (script line) trace of the public Sodium commands.

    .DESCRIPTION
    Uses the Profiler module to trace a representative workload covering key pair generation,
    sealed box encryption/decryption and public key derivation, then prints the top self-duration lines.

    .EXAMPLE
    .\Invoke-ProfilerTrace.ps1 -ModulePath C:\temp\SodiumBench\Sodium\Sodium.psd1
#>
#Requires -Modules Profiler
[CmdletBinding()]
param(
    # Path to the Sodium.psd1 to trace. Defaults to building the module from src into a temp folder.
    [Parameter()]
    [string] $ModulePath,

    # Iterations of the traced workload loop.
    [Parameter()]
    [int] $Iterations = 500,

    # Number of top self-duration lines to print.
    [Parameter()]
    [int] $Top = 20
)
$ErrorActionPreference = 'Stop'

if (-not $ModulePath) {
    $buildScript = Join-Path -Path $PSScriptRoot -ChildPath 'Build-LocalModule.ps1'
    $tempBuildPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'SodiumBench'
    $ModulePath = & $buildScript -OutputPath $tempBuildPath
}

Import-Module Profiler
Import-Module $ModulePath -Force

$kp = New-SodiumKeyPair
$box = ConvertTo-SodiumSealedBox -Message 'Hello world!' -PublicKey $kp.PublicKey
$traceIterations = $Iterations

$trace = Trace-Script {
    for ($i = 0; $i -lt $traceIterations; $i++) {
        $null = New-SodiumKeyPair
        $null = New-SodiumKeyPair -Seed 'DeterministicSeed'
        $null = ConvertTo-SodiumSealedBox -Message 'Hello world!' -PublicKey $kp.PublicKey
        $null = ConvertFrom-SodiumSealedBox -SealedBox $box -PublicKey $kp.PublicKey -PrivateKey $kp.PrivateKey
        $null = ConvertFrom-SodiumSealedBox -SealedBox $box -PrivateKey $kp.PrivateKey
        $null = Get-SodiumPublicKey -PrivateKey $kp.PrivateKey
    }
}

$trace.Top50SelfDuration |
    Select-Object -First $Top SelfPercent, SelfDuration, HitCount, Function, Line, Text |
    Format-Table -AutoSize | Out-String -Width 220 | Write-Output

$trace
