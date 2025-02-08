function Assert-VisualCRedistributableInstalled {
    <#
        .SYNOPSIS
        Determines if a version of the Visual C++ Redistributable is installed and meets the specified minimum version.

        .DESCRIPTION
        This function checks whether the Visual C++ Redistributable for Visual Studio 2015 or later is installed on
        the system and ensures that the installed version is greater than or equal to the specified minimum version.
        If the required version is not found, a warning is displayed, suggesting where to download the latest
        redistributable package.

        .EXAMPLE
        Assert-VisualCRedistributableInstalled -Version '14.29.30037'

        Output:
        ```powershell
        True
        ```

        Checks if the installed Visual C++ Redistributable version is at least 14.29.30037 and returns `$true`
        if the requirement is met.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        # The minimum required version of the Visual C++ Redistributable.
        [Parameter(Mandatory)]
        [Version] $Version
    )

    process {
        $result = $false
        if ($IsWindows) {
            $key = 'HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64'
            if (Test-Path -Path $key) {
                $installedVersion = (Get-ItemProperty -Path $key).Version
                $result = [Version]($installedVersion.SubString(1, $installedVersion.Length - 1)) -ge $Version
            }
        }
        if (-not $result) {
            Write-Warning 'The Visual C++ Redistributable for Visual Studio 2015 or later is required.'
            Write-Warning 'Download and install the appropriate version from:'
            Write-Warning ' - https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads'
        }
        $result
    }
}
