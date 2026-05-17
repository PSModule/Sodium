[CmdletBinding()]
param(
    [int] $Iterations = 1000,
    [switch] $Child,
    [string] $Version,
    [switch] $Prerelease
)

$ErrorActionPreference = 'Stop'

function Ensure-SodiumVersionInstalled {
    param(
        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [bool] $Prerelease
    )

    $installed = Get-Module -ListAvailable -Name Sodium |
        Where-Object { $_.Version.ToString() -eq $Version }

    if ($installed) {
        return
    }

    $installParameters = @{
        Name                = 'Sodium'
        Repository          = 'PSGallery'
        Scope               = 'CurrentUser'
        TrustRepository     = $true
        AcceptLicense       = $true
        SkipDependencyCheck = $true
        Quiet               = $true
    }

    if ($Prerelease) {
        $installParameters.Prerelease = $true
    } else {
        $installParameters.Version = $Version
    }

    Install-PSResource @installParameters
}

function Invoke-SodiumBenchmarks {
    param(
        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [int] $Iterations
    )

    Import-Module Sodium -RequiredVersion $Version -Force -ErrorAction Stop

    $keyPair = New-SodiumKeyPair
    $message = 'The quick brown fox jumps over the lazy dog.'
    $publicKey = $keyPair.PublicKey
    $privateKey = $keyPair.PrivateKey
    $seed = 'DeterministicSeed'
    $sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey

    $warmup = @(
        { New-SodiumKeyPair | Out-Null },
        { New-SodiumKeyPair -Seed $seed | Out-Null },
        { Get-SodiumPublicKey -PrivateKey $privateKey | Out-Null },
        { ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey | Out-Null },
        { ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PrivateKey $privateKey | Out-Null }
    )

    foreach ($step in $warmup) {
        & $step
    }

    function Measure-Loop {
        param(
            [Parameter(Mandatory)]
            [string] $Name,

            [Parameter(Mandatory)]
            [scriptblock] $Body
        )

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        for ($index = 0; $index -lt $Iterations; $index++) {
            & $Body | Out-Null
        }
        $stopwatch.Stop()

        [pscustomobject]@{
            Version           = $Version
            Benchmark         = $Name
            Iterations        = $Iterations
            TotalMilliseconds  = [math]::Round($stopwatch.Elapsed.TotalMilliseconds, 3)
            MeanMicroseconds   = [math]::Round(($stopwatch.Elapsed.TotalMilliseconds * 1000) / $Iterations, 3)
        }
    }

    @(
        Measure-Loop -Name 'New-SodiumKeyPair' -Body { New-SodiumKeyPair }
        Measure-Loop -Name 'New-SodiumKeyPair-Seeded' -Body { New-SodiumKeyPair -Seed $seed }
        Measure-Loop -Name 'Get-SodiumPublicKey' -Body { Get-SodiumPublicKey -PrivateKey $privateKey }
        Measure-Loop -Name 'ConvertTo-SodiumSealedBox' -Body { ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey }
        Measure-Loop -Name 'ConvertFrom-SodiumSealedBox' -Body { ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PrivateKey $privateKey }
    )
}

function Invoke-SodiumColdStartBenchmarks {
    param(
        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [int] $Iterations
    )

    $childScript = @'
param(
    [Parameter(Mandatory)]
    [string] $Version
)

$ErrorActionPreference = ''Stop''
Import-Module Sodium -RequiredVersion $Version -Force -ErrorAction Stop

$keyPair = New-SodiumKeyPair
$message = ''The quick brown fox jumps over the lazy dog.''
$publicKey = $keyPair.PublicKey
$privateKey = $keyPair.PrivateKey
$seed = ''DeterministicSeed''
$sealedBox = ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey

New-SodiumKeyPair | Out-Null
New-SodiumKeyPair -Seed $seed | Out-Null
Get-SodiumPublicKey -PrivateKey $privateKey | Out-Null
ConvertTo-SodiumSealedBox -Message $message -PublicKey $publicKey | Out-Null
ConvertFrom-SodiumSealedBox -SealedBox $sealedBox -PrivateKey $privateKey | Out-Null
'@

    $results = for ($index = 0; $index -lt $Iterations; $index++) {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        & pwsh -NoProfile -Command $childScript -Version $Version | Out-Null
        $stopwatch.Stop()

        [pscustomobject]@{
            Version            = $Version
            Benchmark          = 'ColdStart-Import-CommandSuite'
            Iterations         = 1
            TotalMilliseconds  = [math]::Round($stopwatch.Elapsed.TotalMilliseconds, 3)
            MeanMicroseconds    = [math]::Round($stopwatch.Elapsed.TotalMilliseconds * 1000, 3)
        }
    }

    $results
}

if ($Child) {
    Invoke-SodiumBenchmarks -Version $Version -Iterations $Iterations | ConvertTo-Json -Depth 4
    return
}

$targets = @(
    [pscustomobject]@{
        Label      = 'stable'
        Version    = '2.2.2'
        Prerelease = $false
    }
    [pscustomobject]@{
        Label      = 'preview'
        Version    = '2.2.3'
        Prerelease = $true
    }
)

foreach ($target in $targets) {
    Ensure-SodiumVersionInstalled -Version $target.Version -Prerelease $target.Prerelease
}

$results = foreach ($target in $targets) {
    $childOutput = & pwsh -NoProfile -File $PSCommandPath -Child -Version $target.Version -Iterations $Iterations
    $childOutput | ConvertFrom-Json
}

$coldStartResults = foreach ($target in $targets) {
    Invoke-SodiumColdStartBenchmarks -Version $target.Version -Iterations $Iterations
}

$results |
    Sort-Object Benchmark, Version |
    Select-Object Version, Benchmark, Iterations, TotalMilliseconds, MeanMicroseconds |
    Format-Table -AutoSize

$coldStartResults |
    Group-Object Version |
    ForEach-Object {
        $groupAverage = [math]::Round(($_.Group | Measure-Object -Property TotalMilliseconds -Average).Average, 3)
        [pscustomobject]@{
            Version = $_.Name
            Benchmark = 'ColdStart-Import-CommandSuite'
            Iterations = $_.Count
            AverageMilliseconds = $groupAverage
            AverageMicroseconds = [math]::Round($groupAverage * 1000, 3)
        }
    } |
    Sort-Object Version |
    Format-Table -AutoSize

$comparison = $results |
    Group-Object Benchmark |
    ForEach-Object {
        $stable = $_.Group | Where-Object { $_.Version -eq '2.2.2' }
        $preview = $_.Group | Where-Object { $_.Version -eq '2.2.3' }

        [pscustomobject]@{
            Benchmark = $_.Name
            StableMs  = $stable.TotalMilliseconds
            PreviewMs = $preview.TotalMilliseconds
            DeltaMs   = [math]::Round(($stable.TotalMilliseconds - $preview.TotalMilliseconds), 3)
            Percent   = [math]::Round((($stable.TotalMilliseconds - $preview.TotalMilliseconds) / $stable.TotalMilliseconds) * 100, 2)
        }
    }

$comparison | Sort-Object Benchmark | Format-Table -AutoSize

$coldComparison = $coldStartResults |
    Group-Object Version |
    ForEach-Object {
        [pscustomobject]@{
            Version = $_.Name
            AverageMilliseconds = [math]::Round(($_.Group | Measure-Object -Property TotalMilliseconds -Average).Average, 3)
        }
    }

$coldComparison | Sort-Object Version | Format-Table -AutoSize