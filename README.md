# Sodium

A PowerShell module that provides [`Sodium.Core`](https://github.com/ektrah/libsodium-core) functionality.

This module was initially created to serve the needs of the [GitHub PowerShell module](https://github.com/PSModule/GitHub).
GitHub's method for creating or updating [secrets via the REST API](https://docs.github.com/en/rest/guides/encrypting-secrets-for-the-rest-api?apiVersion=2022-11-28#example-encrypting-a-secret-using-c)
requires that secrets be encrypted using the [libsodium](https://github.com/jedisct1/libsodium) library.

## Prerequisites

This module relies on the following external resources:

- The [PSModule framework](https://github.com/PSModule) for building, testing, and publishing the module.
- The [libsodium](https://github.com/jedisct1/libsodium) library for cryptographic operations.
- The [Sodium.Core](https://github.com/ektrah/libsodium-core) library, which provides .NET bindings.

## Installation

To install the module from the PowerShell Gallery, use the following command:

```powershell
Install-PSResource -Name Sodium
Import-Module -Name Sodium
```

## Examples

### Example 1: Generate a new key pair

The module provides functionality to create a new cryptographic key pair.
The keys are returned as a PowerShell custom object with `PublicKey` and `PrivateKey` properties, encoded in Base64 format.

```powershell
New-SodiumKeyPair

PublicKey                                    PrivateKey
---------                                    ----------
9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4= MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g=
```

### Example 2: Encrypt a secret using a public key

After generating a key pair, a secret can be encrypted using the associated public key.
Below, a secret is encrypted using the public key from the previous example.

```powershell
ConvertTo-SodiumEncryptedString -Secret "mysecret" -PublicKey "9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4="

905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg=
```

### Example 3: Decrypt a Sodium-encrypted string

To decrypt an encrypted string, both the private and public keys are required.

```powershell
$params = @{
    EncryptedSecret = '905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg='
    PublicKey       = '9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4='
    PrivateKey      = 'MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g='
}
ConvertFrom-SodiumEncryptedString @params

mysecret
```

### Finding More Examples

For additional examples, refer to the [examples](examples) folder.

Alternatively, you can use the following command to list all available commands in this module:

```powershell
Get-Command -Module Sodium
```

To view examples for a specific command, use:

```powershell
Get-Help <CommandName> -Examples
```

## Contributing

Coder or not, you can contribute to this project! We welcome all contributions.

### For Users

If you don't code, you still have valuable insights that can improve this project.
If the module behaves unexpectedly, throws errors, or lacks functionality, you can help by submitting bug reports and feature requests.
Please check the [issues](https://github.com/PSModule/Sodium/issues) tab and submit a new issue if needed.

### For Developers

If you are a developer, we welcome your contributions.
Please read the [Contribution Guidelines](CONTRIBUTING.md) for more information.

You can help by picking up an existing issue or submitting a new one if you have an idea for a feature or improvement.

## Acknowledgements

### Module Isolation Logic

- [Resolving PowerShell module assembly dependency conflicts | PowerShell Docs @ Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/resolving-dependency-conflicts?view=powershell-7.4#more-robust-solutions)
- [rjmholt/ModuleDependencyIsolationExample | GitHub Repo](https://github.com/rjmholt/ModuleDependencyIsolationExample)

### Libsodium

- **Sodium.Core** | [GitHub](https://github.com/ektrah/libsodium-core)
- **libsodium** | [Docs](https://doc.libsodium.org/) | [GitHub](https://github.com/jedisct1/libsodium)
