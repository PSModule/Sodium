# $arch = ([string][System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture).ToLower()
# Write-Verbose "OS Architecture: $arch"
# $libSodiumVersion = '1.0.19.2'
# if ($IsWindows) {
#     $libPath = Join-Path $PSScriptRoot "\libs\libsodium\$libSodiumVersion\win-$arch\native\libsodium.dll"
# }
# if ($IsLinux) {
#     $libPath = Join-Path $PSScriptRoot "\libs\libsodium\$libSodiumVersion\linux-$arch\native\libsodium.so"
# }
# if ($IsMacOS) {
#     $libPath = Join-Path $PSScriptRoot "\libs\libsodium\$libSodiumVersion\osx-$arch\native\libsodium.dylib"
# }
# Write-Verbose "Library Path: $libPath"
# $null = [System.Runtime.InteropServices.NativeLibrary]::Load($libPath)

$corePath = Join-Path $PSScriptRoot '\libs\Sodium.Core\1.3.5\Sodium.Core.dll'
$null = [System.Reflection.Assembly]::LoadFile($corePath)
