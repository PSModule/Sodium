$arch = ([string][System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture).ToLower()
4
if ($IsWindows) {
    $libPath = Join-Path $PSScriptRoot "\libs\libsodium\1.0.19.0\win-$arch\native\libsodium.dll"
}
if ($IsLinux) {
    $libPath = Join-Path $PSScriptRoot "\libs\libsodium\1.0.19.0\linux-$arch\native\libsodium.so"
}
if ($IsMacOS) {
    $libPath = Join-Path $PSScriptRoot "\libs\libsodium\1.0.19.0\osx-$arch\native\libsodium.dylib"
}
$null = [System.Runtime.InteropServices.NativeLibrary]::Load($libPath)

$corePath = Join-Path $PSScriptRoot '\libs\Sodium.Core\1.3.5\Sodium.Core.dll'
$null = [System.Reflection.Assembly]::LoadFile($corePath)
