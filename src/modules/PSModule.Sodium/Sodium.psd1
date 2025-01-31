@{
    RootModule      = 'PSModule.Sodium.dll'
    CmdletsToExport = @(
        'ConvertTo-SodiumEncryptedString'
    )
    PrivateData     = @{
        PSData = @{
            Tags = @(
                'Sodium'
                'PSModule'
            )
        }
    }
}
