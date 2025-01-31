param(
    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration = 'Release'
)
$repoRootPath = (Get-Item -Path $PSScriptRoot).Parent.Parent
$outPath = Join-Path -Path $repoRootPath.FullName -ChildPath lib -AdditionalChildPath 'net8.0'
if (Test-Path $outPath) {
    Remove-Item -Path $outPath -Recurse
}
$isolatedLibPath = Join-Path -Path $outPath -ChildPath isolated
$runtimesLibPath = Join-Path -Path $isolatedLibPath -ChildPath runtimes
New-Item -Path $outPath -ItemType Directory
New-Item -Path $isolatedLibPath -ItemType Directory
New-Item -Path $runtimesLibPath -ItemType Directory

Push-Location "$PSScriptRoot/PSModule.Sodium"
try {
    dotnet publish --configuration $Configuration
}
finally {
    Pop-Location
}

# Copy selected unmanaged runtimes/[selected]/native/* assemblies to the isolated folder
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/net8.0/publish/runtimes" -Directory |
    Where-Object { $_.Name -match "(win-x(64|86))|(linux-(arm|x)64)" } |
    ForEach-Object { Copy-Item -Path $_.FullName -Destination (Join-Path -Path $runtimesLibPath -ChildPath $_.Name) -Recurse }

# Copy Nested Binary Module managed assemblies to lib
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/net8.0/publish" -File |
    Where-Object { $_.BaseName -eq 'PSModule.Sodium' -and $_.Extension -in '.dll' } |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $outPath }

# Copy other managed assemblies to lib/isolated
Get-ChildItem -Path "$PSScriptRoot/PSModule.Sodium/bin/$Configuration/net8.0/publish" -File |
Where-Object { $_.BaseName -ne 'PSModule.Sodium' } |
ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $isolatedLibPath }