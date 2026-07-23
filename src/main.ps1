$processArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture

$runtimeIdentifier = Resolve-SodiumRuntimeIdentifier -ProcessArchitecture $processArchitecture `
    -Linux:$IsLinux -MacOS:$IsMacOS -Windows:$IsWindows

$assemblyPath = [System.IO.Path]::Combine($PSScriptRoot, 'libs', $runtimeIdentifier, 'PSModule.Sodium.dll')
Import-Module $assemblyPath -ErrorAction Stop

# Optimistically mark supported; Initialize-Sodium runs during module import and checks Windows VC++ runtime only if native init fails.
$script:Supported = $true
$script:ProcessArchitecture = $processArchitecture.ToString()

Initialize-Sodium
