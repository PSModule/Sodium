$arch = ([string][System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture).ToLower()
$os = ([string][System.Runtime.InteropServices.RuntimeInformation]::OSDescription)
Write-Verbose "OS:               $os"
Write-Verbose "OS Architecture:  $arch"
if ($IsWindows) {
    $libPath = Join-Path $PSScriptRoot "runtimes\win-$arch\native\libsodium.dll"
}
if ($IsLinux) {
    $libPath = Join-Path $PSScriptRoot "runtimes\linux-$arch\native\libsodium.so"
}
if ($IsMacOS) {
    $libPath = Join-Path $PSScriptRoot "runtimes\osx-$arch\native\libsodium.dylib"
}
Write-Verbose "libsodium Path:   $libPath"
$null = [System.Runtime.InteropServices.NativeLibrary]::Load($libPath)

$corePath = Join-Path $PSScriptRoot '\libs\Sodium.Core\1.3.5\Sodium.Core.dll'
Write-Verbose "Sodium.Core Path: $corePath"
$null = [System.Reflection.Assembly]::LoadFile($corePath)

[Sodium.SodiumCore]::Init()
