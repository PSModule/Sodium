$libPath = Join-Path -Path $PSScriptRoot -ChildPath lib
if (Test-Path $libPath) {
    Write-Warning "Deleting $($libPath)"
    Remove-Item -Path $libPath -Recurse
}
Get-ChildItem -Path "$PSScriptRoot" -Directory -Recurse | Where-Object { $_.Name -in 'bin', 'obj' } | ForEach-Object {
    Write-Warning "Deleting $($_.FullName)"
    Remove-Item -Path $_.FullName -Recurse
}
