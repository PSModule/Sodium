[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Version,

    [Parameter(Mandatory)]
    [string] $Label,

    [Parameter()]
    [int] $Iterations = 1000,

    [Parameter()]
    [int] $Trials = 5,

    [Parameter()]
    [int] $ColdStartIterations = 3,

    [Parameter()]
    [string] $ResultsPath = (Join-Path $PSScriptRoot 'results.jsonl')
)

$ErrorActionPreference = 'Stop'

function Install-IfMissing {
    param([string] $Version)

    $base = ($Version -split '-',2)[0]
    $pre  = if ($Version.Contains('-')) { ($Version -split '-',2)[1] } else { '' }

    $installed = Get-Module -ListAvailable -Name Sodium | Where-Object {
        $_.Version.ToString() -eq $base -and ($_.PrivateData.PSData.Prerelease -as [string]) -eq $pre
    }
    if ($installed) { return }

    $params = @{
        Name            = 'Sodium'
        Repository      = 'PSGallery'
        Version         = $Version
        Scope           = 'CurrentUser'
        TrustRepository = $true
        AcceptLicense   = $true
        Prerelease      = $true
        Reinstall       = $true
    }
    [Console]::Error.WriteLine("Installing Sodium $Version from PSGallery...")
    Install-PSResource @params
}

function Run-WarmTrial {
    param([string] $Version, [int] $Iterations)

    $script = @"
param([string] `$Version, [int] `$Iterations)
`$ErrorActionPreference = 'Stop'
`$base = (`$Version -split '-',2)[0]
Import-Module Sodium -RequiredVersion `$base -Force -ErrorAction Stop

`$keyPair    = New-SodiumKeyPair
`$message    = 'The quick brown fox jumps over the lazy dog.'
`$publicKey  = `$keyPair.PublicKey
`$privateKey = `$keyPair.PrivateKey
`$seed       = 'DeterministicSeed'
`$sealedBox  = ConvertTo-SodiumSealedBox -Message `$message -PublicKey `$publicKey

1..10 | ForEach-Object {
    `$null = New-SodiumKeyPair
    `$null = New-SodiumKeyPair -Seed `$seed
    `$null = Get-SodiumPublicKey -PrivateKey `$privateKey
    `$null = ConvertTo-SodiumSealedBox -Message `$message -PublicKey `$publicKey
    `$null = ConvertFrom-SodiumSealedBox -SealedBox `$sealedBox -PrivateKey `$privateKey
}

function Measure-Loop {
    param([string] `$Name, [scriptblock] `$Body, [int] `$Iterations)
    [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect()
    `$sw = [System.Diagnostics.Stopwatch]::StartNew()
    for (`$i = 0; `$i -lt `$Iterations; `$i++) { `$null = & `$Body }
    `$sw.Stop()
    [pscustomobject]@{
        Benchmark  = `$Name
        Iterations = `$Iterations
        TotalMs    = [math]::Round(`$sw.Elapsed.TotalMilliseconds, 3)
        MeanUs     = [math]::Round((`$sw.Elapsed.TotalMilliseconds * 1000) / `$Iterations, 3)
    }
}

@(
    Measure-Loop 'New-SodiumKeyPair'           { New-SodiumKeyPair }                                              `$Iterations
    Measure-Loop 'New-SodiumKeyPair-Seeded'    { New-SodiumKeyPair -Seed `$seed }                                 `$Iterations
    Measure-Loop 'Get-SodiumPublicKey'         { Get-SodiumPublicKey -PrivateKey `$privateKey }                   `$Iterations
    Measure-Loop 'ConvertTo-SodiumSealedBox'   { ConvertTo-SodiumSealedBox -Message `$message -PublicKey `$publicKey } `$Iterations
    Measure-Loop 'ConvertFrom-SodiumSealedBox' { ConvertFrom-SodiumSealedBox -SealedBox `$sealedBox -PrivateKey `$privateKey } `$Iterations
) | ConvertTo-Json -Depth 4
"@

    $tmp = [System.IO.Path]::GetTempFileName() + '.ps1'
    Set-Content -LiteralPath $tmp -Value $script -Encoding UTF8
    try {
        $output = & pwsh -NoProfile -File $tmp -Version $Version -Iterations $Iterations 2>&1
        if ($LASTEXITCODE -ne 0) { throw ("Child pwsh failed: " + ($output -join "`n")) }
        $json = ($output | Where-Object { $_ -is [string] }) -join "`n"
        return ($json | ConvertFrom-Json)
    } finally {
        Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
    }
}

function Run-ColdStartBenchmark {
    param([string] $Version, [int] $Iterations)

    $base = ($Version -split '-',2)[0]
    $totals = for ($i = 0; $i -lt $Iterations; $i++) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        & pwsh -NoProfile -Command "Import-Module Sodium -RequiredVersion $base -Force; `$null = New-SodiumKeyPair" | Out-Null
        $sw.Stop()
        $sw.Elapsed.TotalMilliseconds
    }
    $sorted = $totals | Sort-Object
    [pscustomobject]@{
        Benchmark  = 'ColdStart-Import+OneKeyPair'
        Iterations = $Iterations
        MinMs      = [math]::Round((($totals | Measure-Object -Minimum).Minimum), 3)
        MedianMs   = [math]::Round($sorted[[math]::Floor($sorted.Count/2)], 3)
        MeanMs     = [math]::Round((($totals | Measure-Object -Average).Average), 3)
    }
}

Install-IfMissing -Version $Version

[Console]::Error.WriteLine("Running $Trials trials of $Iterations iterations for $Version [$Label]...")
$trialResults = [System.Collections.Generic.List[object]]::new()
for ($t = 1; $t -le $Trials; $t++) {
    [Console]::Error.WriteLine("  trial $t/$Trials")
    $trialResults.Add((Run-WarmTrial -Version $Version -Iterations $Iterations))
}

$benchmarkNames = $trialResults[0] | ForEach-Object { $_.Benchmark }
$aggregated = foreach ($name in $benchmarkNames) {
    $samples = foreach ($trial in $trialResults) { ($trial | Where-Object Benchmark -EQ $name).MeanUs }
    $sorted = @($samples | Sort-Object)
    [pscustomobject]@{
        Benchmark  = $name
        Iterations = $Iterations
        Trials     = $Trials
        MinUs      = [math]::Round((($sorted | Measure-Object -Minimum).Minimum), 3)
        MedianUs   = [math]::Round($sorted[[math]::Floor($sorted.Count/2)], 3)
        MeanUs     = [math]::Round((($sorted | Measure-Object -Average).Average), 3)
        Samples    = $samples
    }
}

[Console]::Error.WriteLine("Running cold-start benchmark (iterations=$ColdStartIterations) for $Version [$Label]...")
$cold = Run-ColdStartBenchmark -Version $Version -Iterations $ColdStartIterations

$record = [pscustomobject]@{
    Timestamp  = (Get-Date).ToUniversalTime().ToString('o')
    Label      = $Label
    Version    = $Version
    Benchmarks = @($aggregated) + @($cold)
}

$record.Benchmarks |
    Select-Object Benchmark, Iterations, Trials, MinUs, MedianUs, MeanUs, MinMs, MedianMs, MeanMs |
    Format-Table -AutoSize | Out-String | Write-Host

$json = $record | ConvertTo-Json -Depth 6 -Compress
Add-Content -LiteralPath $ResultsPath -Value $json
[Console]::Error.WriteLine("Appended to $ResultsPath")
