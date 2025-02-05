$libPath = Join-Path -Path $PSScriptRoot -ChildPath lib
Get-ChildItem -Path $libPath -Directory -Recurse | ForEach-Object {
    Write-Warning "Deleting $($_.FullName)"
    Remove-Item -Path $_.FullName -Recurse
}
Get-ChildItem -Path $PSScriptRoot -Directory -Recurse | Where-Object { $_.Name -in 'bin', 'obj' } | ForEach-Object {
    Write-Warning "Deleting $($_.FullName)"
    Remove-Item -Path $_.FullName -Recurse
}
