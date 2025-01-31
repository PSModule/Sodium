$arch = ([string][System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture).ToLower()

if ($IsWindows) {
    $libPath = Join-Path $PSScriptRoot '\assemblies\libsodium\1.0.19.0\win-x64\native\libsodium.dll'
}
if ($IsLinux) {
    $libPath = Join-Path $PSScriptRoot '\assemblies\libsodium\1.0.19.0\linux-x64\native\libsodium.so'
}
if ($IsMacOS) {
    $libPath = Join-Path $PSScriptRoot '\assemblies\libsodium\1.0.19.0\osx-x64\native\libsodium.dylib'
}
$null = [System.Runtime.InteropServices.NativeLibrary]::Load($libPath)

$corePath = Join-Path $PSScriptRoot '\assemblies\Sodium.Core\1.3.5\Sodium.Core.dll'
$null = [System.Reflection.Assembly]::LoadFile($corePath)
