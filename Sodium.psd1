@{
    Author            = 'PSModule'
    CmdletsToExport   = @(
        'ConvertTo-SodiumEncryptedString'
    )
    CompanyName       = 'PSModule'
    Copyright         = '(c) 2025 PSModule. All rights reserved.'
    Description       = 'A wrapper around Sodium.Core.'
    GUID              = 'fd2670fd-85c9-4737-bfc1-ef1af58d56ec'
    ModuleVersion     = '0.1.0'
    PrivateData       = @{
        PSData = @{
            Tags = @(
                'Sodium'
                'PSModule'
            )
        }
    }
    PowerShellVersion = '7.4'
    RootModule        = 'lib/net8.0/PSModule.Sodium.dll'
}
