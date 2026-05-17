$ErrorActionPreference = 'Stop'

Remove-Item -Path "$PSScriptRoot/../src/libs" -Recurse -Force -ErrorAction SilentlyContinue

$targetRuntimes = @(
    'linux-x64'
    'linux-arm64'
    'win-x64'
    'win-x86'
    'osx-arm64'
    'osx-x64'
)

Push-Location $PSScriptRoot
try {
    $targetRuntimes | ForEach-Object {
        dotnet publish -c Release -r $_
        if ($LASTEXITCODE -ne 0) {
            throw "dotnet publish failed for runtime '$_'."
        }

        $source = "$PSScriptRoot/bin/Release/net10.0/$_/publish"
        $destination = "$PSScriptRoot/../src/libs/$_"
        Copy-Item -Path $source -Destination $destination -Recurse -Force
    }
} finally {
    Pop-Location
}

Get-ChildItem -Path $PSScriptRoot -Directory -Recurse | Where-Object { $_.Name -in 'bin', 'obj' } | ForEach-Object {
    Write-Warning "Deleting $($_.FullName)"
    Remove-Item -Path $_.FullName -Recurse -Force
}
