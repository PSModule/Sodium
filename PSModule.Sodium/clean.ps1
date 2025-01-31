$libPath = Join-Path -Path $PSScriptRoot -ChildPath lib
if (Test-Path $libPath) {
    Write-Host -ForegroundColor Red -Object "Deleting $($libPath)"
    Remove-Item -Path $libPath -Recurse
}
Get-ChildItem -Path "$PSScriptRoot" -Directory -Recurse | Where-Object { $_.Name -in 'bin','obj' } | ForEach-Object {
    Write-Host -ForegroundColor Red -Object "Deleting $($_.FullName)"
    Remove-Item -Path $_.FullName -Recurse
}