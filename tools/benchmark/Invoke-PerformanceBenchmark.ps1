<#
    .SYNOPSIS
    Stopwatch micro-benchmarks for every public Sodium action showcased in the test suite.

    .DESCRIPTION
    Measures per-operation cost (stopwatch) for key pair generation, sealed box encryption/decryption,
    public key derivation, pipeline variants, error paths and a parallel-runspace scenario that mirrors
    the 'Parallel sessions' test context. Results are printed and optionally saved as JSON.

    .EXAMPLE
    .\Invoke-PerformanceBenchmark.ps1 -ModulePath C:\temp\SodiumBench\Sodium\Sodium.psd1 -Label baseline
#>
[CmdletBinding()]
param(
    # Path to the Sodium.psd1 to benchmark. Defaults to building the module from src into a temp folder.
    [Parameter()]
    [string] $ModulePath,

    # Label used in output file name (bench-<Label>.json).
    [Parameter()]
    [string] $Label = 'run',

    # Iterations per benchmark.
    [Parameter()]
    [int] $Iterations = 2000,

    # Folder to write the JSON results to. Defaults to the current directory.
    [Parameter()]
    [string] $OutputPath = (Get-Location).Path
)
$ErrorActionPreference = 'Stop'

if (-not $ModulePath) {
    $ModulePath = & (Join-Path $PSScriptRoot 'Build-LocalModule.ps1') -OutputPath (Join-Path ([System.IO.Path]::GetTempPath()) 'SodiumBench')
}

Import-Module $ModulePath -Force

function Measure-Op {
    param([string]$Name, [scriptblock]$Setup, [scriptblock]$Op, [int]$N = $Iterations)
    $ctx = if ($Setup) { & $Setup } else { $null }
    for ($i = 0; $i -lt 25; $i++) { $null = & $Op $ctx }
    [GC]::Collect(); [GC]::WaitForPendingFinalizers()
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    for ($i = 0; $i -lt $N; $i++) { $null = & $Op $ctx }
    $sw.Stop()
    [pscustomobject]@{
        Name      = $Name
        N         = $N
        TotalMs   = [math]::Round($sw.Elapsed.TotalMilliseconds, 2)
        PerOpUs   = [math]::Round($sw.Elapsed.TotalMilliseconds * 1000 / $N, 2)
        OpsPerSec = [math]::Round($N / $sw.Elapsed.TotalSeconds, 0)
    }
}

$results = @()

$results += Measure-Op -Name 'New-SodiumKeyPair (random)' -Op { New-SodiumKeyPair }

$results += Measure-Op -Name 'New-SodiumKeyPair -Seed' -Op { New-SodiumKeyPair -Seed 'DeterministicSeed' }

$results += Measure-Op -Name 'New-SodiumKeyPair (seed via pipeline)' -Op { 'DeterministicSeed' | New-SodiumKeyPair }

$results += Measure-Op -Name 'ConvertTo-SodiumSealedBox' -Setup {
    (New-SodiumKeyPair)
} -Op { param($kp) ConvertTo-SodiumSealedBox -Message 'Hello world!' -PublicKey $kp.PublicKey }

$results += Measure-Op -Name 'ConvertTo-SodiumSealedBox (pipeline)' -Setup {
    (New-SodiumKeyPair)
} -Op { param($kp) 'Hello world!' | ConvertTo-SodiumSealedBox -PublicKey $kp.PublicKey }

$results += Measure-Op -Name 'ConvertFrom-SodiumSealedBox (pub+priv)' -Setup {
    $kp = New-SodiumKeyPair
    [pscustomobject]@{ KP = $kp; Box = (ConvertTo-SodiumSealedBox -Message 'Hello world!' -PublicKey $kp.PublicKey) }
} -Op { param($c) ConvertFrom-SodiumSealedBox -SealedBox $c.Box -PublicKey $c.KP.PublicKey -PrivateKey $c.KP.PrivateKey }

$results += Measure-Op -Name 'ConvertFrom-SodiumSealedBox (priv only)' -Setup {
    $kp = New-SodiumKeyPair
    [pscustomobject]@{ KP = $kp; Box = (ConvertTo-SodiumSealedBox -Message 'Hello world!' -PublicKey $kp.PublicKey) }
} -Op { param($c) ConvertFrom-SodiumSealedBox -SealedBox $c.Box -PrivateKey $c.KP.PrivateKey }

$results += Measure-Op -Name 'ConvertFrom-SodiumSealedBox (pipeline)' -Setup {
    $kp = New-SodiumKeyPair
    [pscustomobject]@{ KP = $kp; Box = (ConvertTo-SodiumSealedBox -Message 'Hello world!' -PublicKey $kp.PublicKey) }
} -Op { param($c) $c.Box | ConvertFrom-SodiumSealedBox -PublicKey $c.KP.PublicKey -PrivateKey $c.KP.PrivateKey }

$results += Measure-Op -Name 'Get-SodiumPublicKey (base64)' -Setup {
    (New-SodiumKeyPair)
} -Op { param($kp) Get-SodiumPublicKey -PrivateKey $kp.PrivateKey }

$results += Measure-Op -Name 'Get-SodiumPublicKey -AsByteArray' -Setup {
    (New-SodiumKeyPair)
} -Op { param($kp) Get-SodiumPublicKey -PrivateKey $kp.PrivateKey -AsByteArray }

$results += Measure-Op -Name 'Full roundtrip (keypair+seal+open)' -N ([math]::Max(200, [int]($Iterations / 4))) -Op {
    $kp = New-SodiumKeyPair
    $box = ConvertTo-SodiumSealedBox -Message 'Round trip' -PublicKey $kp.PublicKey
    ConvertFrom-SodiumSealedBox -SealedBox $box -PrivateKey $kp.PrivateKey
}

$results += Measure-Op -Name 'ConvertTo-SodiumSealedBox invalid key (throw)' -N 500 -Op {
    try { ConvertTo-SodiumSealedBox -Message 'x' -PublicKey 'InvalidKey' } catch { }
}

$results += Measure-Op -Name 'Get-SodiumPublicKey invalid key (throw)' -N 500 -Op {
    try { Get-SodiumPublicKey -PrivateKey 'InvalidKey' } catch { }
}

# Mirrors the 'Parallel sessions' test context: module import + crypto roundtrip in 4 runspaces.
$modPath = (Get-Module Sodium).Path
$swPar = [System.Diagnostics.Stopwatch]::StartNew()
$parResults = 1..4 | ForEach-Object -Parallel {
    Import-Module -Name $using:modPath -Force
    $kp = New-SodiumKeyPair -Seed "Runspace-$_"
    $box = ConvertTo-SodiumSealedBox -Message "Parallel runspace $_" -PublicKey $kp.PublicKey
    ConvertFrom-SodiumSealedBox -SealedBox $box -PrivateKey $kp.PrivateKey
} -ThrottleLimit 4
$swPar.Stop()
if ($parResults.Count -ne 4) { throw 'Parallel runspace benchmark failed.' }
$results += [pscustomobject]@{
    Name      = 'Parallel runspaces x4 (import+roundtrip)'
    N         = 1
    TotalMs   = [math]::Round($swPar.Elapsed.TotalMilliseconds, 2)
    PerOpUs   = [math]::Round($swPar.Elapsed.TotalMilliseconds * 1000, 2)
    OpsPerSec = [math]::Round(1 / $swPar.Elapsed.TotalSeconds, 2)
}

$results | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
$outFile = Join-Path $OutputPath "bench-$Label.json"
$results | ConvertTo-Json | Set-Content -Path $outFile
Write-Verbose "Saved $outFile" -Verbose
