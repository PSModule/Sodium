[CmdletBinding()]
param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'Sodium' {
    Context 'Module' {
        It 'The module should be available' {
            Get-Module -Name 'Sodium' -ListAvailable | Should -Not -BeNullOrEmpty
            Write-Verbose (Get-Module -Name 'Sodium' -ListAvailable | Out-String) -Verbose
        }
        It 'The module should be importable' {
            { Import-Module -Name 'Sodium' -Verbose -RequiredVersion 999.0.0 -Force } | Should -Not -Throw
        }
    }

    Context "Function 'Test-PSModuleTemplate'" {
        It 'Should be able to call the function' {
            Test-PSModuleTemplate -Name 'World' | Should -Be 'Hello, World!'
            Write-Verbose (Test-PSModuleTemplate -Name 'World' | Out-String) -Verbose
        }
    }
}
