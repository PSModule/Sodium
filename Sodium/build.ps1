$targetRuntimes = @(
    'linux-x64'
    'win-x64'
    'win-x86'
    'osx-arm64'
    'osx-x64'
)

Push-Location $path
$targetRuntimes | ForEach-Object {
    dotnet publish --runtime $_
    Copy-Item -Recurse -Force -Path "$PSScriptRoot/bin/Release/net8.0/$_/publish" -Destination "$PSScriptRoot/../src/modules/PSModule.Sodium/$_"
}
Pop-Location


# Get-ChildItem -Path $path -Directory -Recurse | Where-Object { $_.Name -in 'bin', 'obj' } | ForEach-Object {
#     Write-Warning "Deleting $($_.FullName)"
#     Remove-Item -Path $_.FullName -Recurse
# }


