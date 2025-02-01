# Sodium

A PowerShell module that provides [`Sodium.Core`](https://github.com/ektrah/libsodium-core) functionality.

This module was initially created to serve the need of the [GitHub PowerShell module](https://github.com/PSModule/GitHub).
GitHub's way of creating or updating [secrets via the REST API](https://docs.github.com/en/rest/guides/encrypting-secrets-for-the-rest-api?apiVersion=2022-11-28#example-encrypting-a-secret-using-c),
requires that the secret is encrypted using the [libsodium](https://github.com/jedisct1/libsodium) library.

## Prerequisites

This uses the following external resources:
- The [PSModule framework](https://github.com/PSModule) for building, testing and publishing the module.
- The [libsodium](https://github.com/jedisct1/libsodium) library for the cryptographic operations.
- The [Sodium.Core](https://github.com/ektrah/libsodium-core) library providing bindings to .NET.

## Installation

To install the module from the PowerShell Gallery, you can use the following command:

```powershell
Install-PSResource -Name Sodium
Import-Module -Name Sodium
```

## Examples

### Example 1: Generates a new key pair

The module provides functionality to create a new cryptographic key pair.
The keys are returned as a PowerShell custom object with the keys `PublicKey` and `PrivateKey` properties encoded in base64 format.

```powershell
New-SodiumKeyPair

PublicKey                                    PrivateKey
---------                                    ----------
9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4= MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g=
```

### Example 2: Encrypts a secret using a public key

After a key pair is created, a secret can be encrypted using the public key from the key pair.
Below you see a secret being encrypted using the secret from the previous example.

```powershell
ConvertTo-SodiumEncryptedString -Secret "mysecret" -PublicKey "9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4="

905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg=
```

### Example 3: Decrypts a Sodium-encrypted string

To decrypt the encrypted string, we need both the private and public key.

```powershell
$params = @{
    EncryptedSecret = '905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg='
    PublicKey       = '9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4='
    PrivateKey      = 'MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g='
}
ConvertFrom-SodiumEncryptedString @params

mysecret
```

### Find more examples

To find more examples of how to use the module, please refer to the [examples](examples) folder.

Alternatively, you can use the Get-Command -Module 'This module' to find more commands that are available in the module.
To find examples of each of the commands you can use Get-Help -Examples 'CommandName'.

## Contributing

Coder or not, you can contribute to the project! We welcome all contributions.

### For Users

If you don't code, you still sit on valuable information that can make this project even better. If you experience that the
product does unexpected things, throw errors or is missing functionality, you can help by submitting bugs and feature requests.
Please see the issues tab on this project and submit a new issue that matches your needs.

### For Developers

If you do code, we'd love to have your contributions. Please read the [Contribution guidelines](CONTRIBUTING.md) for more information.
You can either help by picking up an existing issue or submit a new one if you have an idea for a new feature or improvement.

## Acknowledgements

Module isolation logic:

- [Resolving PowerShell module assembly dependency conflicts | PowerShell Docs @ Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/resolving-dependency-conflicts?view=powershell-7.4#more-robust-solutions)
- [https://github.com/rjmholt/ModuleDependencyIsolationExample](https://github.com/rjmholt/ModuleDependencyIsolationExample)

Libsodium:

- Sodium.Core | [GitHub](https://github.com/ektrah/libsodium-core)
- libsodium | [Docs](https://doc.libsodium.org/) | [GitHub](https://github.com/jedisct1/libsodium)
