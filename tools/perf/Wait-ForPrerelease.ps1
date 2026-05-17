[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $HeadSha,

    [Parameter()]
    [string] $Repo = 'PSModule/Sodium',

    [Parameter()]
    [string] $WorkflowName = 'Process-PSModule',

    [Parameter()]
    [int] $TimeoutSeconds = 1500,

    [Parameter()]
    [int] $PollSeconds = 20,

    [Parameter()]
    [string] $PackageName = 'Sodium'
)

$ErrorActionPreference = 'Stop'

function Write-Progress2 { param([string] $Message) [Console]::Error.WriteLine($Message) }

function Get-LatestRun {
    param([string] $HeadSha)
    $json = gh run list --repo $Repo --branch fix/44-harden-sodium-interop --limit 20 --json status,conclusion,name,headSha,databaseId,createdAt
    if ($LASTEXITCODE -ne 0) { throw "gh run list failed" }
    $runs = $json | ConvertFrom-Json
    $runs | Where-Object { $_.headSha -eq $HeadSha -and $_.name -eq $WorkflowName } | Sort-Object createdAt -Descending | Select-Object -First 1
}

$start = Get-Date
Write-Progress2 "Waiting for workflow run on $HeadSha..."
$run = $null
while ((Get-Date) - $start -lt [TimeSpan]::FromSeconds($TimeoutSeconds)) {
    $run = Get-LatestRun -HeadSha $HeadSha
    if ($run) { break }
    Start-Sleep -Seconds 5
}
if (-not $run) { throw "No workflow run found for $HeadSha within timeout." }

Write-Progress2 "Found run $($run.databaseId), status=$($run.status), conclusion=$($run.conclusion)"

while ($run.status -ne 'completed' -and (Get-Date) - $start -lt [TimeSpan]::FromSeconds($TimeoutSeconds)) {
    Start-Sleep -Seconds $PollSeconds
    $run = Get-LatestRun -HeadSha $HeadSha
    $elapsed = [int]((Get-Date) - $start).TotalSeconds
    Write-Progress2 "[$elapsed s] run $($run.databaseId) status=$($run.status) conclusion=$($run.conclusion)"
}

if ($run.status -ne 'completed') { throw "Workflow did not complete within $TimeoutSeconds seconds." }
if ($run.conclusion -ne 'success') {
    throw "Workflow concluded with conclusion=$($run.conclusion). Inspect with: gh run view $($run.databaseId) --repo $Repo"
}

Write-Progress2 "Workflow succeeded. Polling PSGallery for new prerelease..."

# Poll PSGallery until a new prerelease with a higher counter is visible
$initialMax = (Find-PSResource -Name $PackageName -Repository PSGallery -Prerelease |
    Where-Object { $_.PrereleaseLabel } |
    ForEach-Object { $_.PrereleaseLabel } |
    Where-Object { $_ -match '(\d+)$' } |
    ForEach-Object { [int]($Matches[1]) } |
    Measure-Object -Maximum).Maximum

if (-not $initialMax) { $initialMax = 0 }
Write-Progress2 "Initial max prerelease counter: $initialMax"

$deadline = (Get-Date).AddSeconds(600)
while ((Get-Date) -lt $deadline) {
    Start-Sleep -Seconds 15
    $found = Find-PSResource -Name $PackageName -Repository PSGallery -Prerelease -ErrorAction SilentlyContinue
    $candidates = $found | Where-Object {
        $_.Version.ToString() -like '2.2.3*' -or $_.Prerelease -match '\d+$'
    }
    foreach ($candidate in $candidates) {
        $pre = $candidate.Prerelease
        if (-not $pre -and $candidate.PrereleaseLabel) { $pre = $candidate.PrereleaseLabel }
        if ($pre -match '(\d+)$') {
            $counter = [int]$Matches[1]
            if ($counter -gt $initialMax) {
                $full = "$($candidate.Version)-$pre"
                Write-Progress2 "New prerelease available: $full"
                Write-Output $full
                return
            }
        }
    }
    Write-Progress2 "...still waiting for new prerelease (>$initialMax)"
}

throw "Timed out waiting for new prerelease on PSGallery."
