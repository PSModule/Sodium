# Sodium

A PowerShell module that provides direct bindings to the [`libsodium`](https://github.com/jedisct1/libsodium) cryptographic library.

This module was initially created to serve the needs of the [GitHub PowerShell module](https://github.com/PSModule/GitHub).
GitHub's method for creating or updating [secrets via the REST API](https://docs.github.com/en/rest/guides/encrypting-secrets-for-the-rest-api?apiVersion=2022-11-28#example-encrypting-a-secret-using-c)
requires that secrets be encrypted using the [libsodium](https://github.com/jedisct1/libsodium) library.

## Prerequisites

This module relies on the following external resources:

- The [PSModule framework](https://github.com/PSModule) for building, testing, and publishing the module.
- The [libsodium](https://github.com/jedisct1/libsodium) library for cryptographic operations.

## Installation

To install the module from the PowerShell Gallery, use the following command:

```powershell
Install-PSResource -Name Sodium
Import-Module -Name Sodium
```

## Examples

### Example 1: Generate a new key pair

The module provides functionality to create a new cryptographic key pair.
The keys are returned as a PowerShell custom object with `PublicKey` and `PrivateKey` properties, encoded in base64 format.
For more info on the key pair generation, refer to the [Public-key signatures documentation](https://doc.libsodium.org/public-key_cryptography/public-key_signatures).

```powershell
New-SodiumKeyPair

PublicKey                                    PrivateKey
---------                                    ----------
9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4= MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g=
```

## Example 2: Encrypt a message using a public key (Sealed Boxes encryption)

After generating a key pair, a message can be encrypted using the associated public key with [Sealed Boxes encryption](https://doc.libsodium.org/public-key_cryptography/sealed_boxes).
Below, a message is encrypted using the public key from the previous example.

```powershell
$params = @{
    Message   = "mymessage"
    PublicKey = "9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4="
}
ConvertTo-SodiumSealedBox @params

905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg=
```

## Example 3: Decrypt a Sodium-encrypted sealed box string

To decrypt a string that was encrypted using [Sealed Boxes encryption](https://doc.libsodium.org/public-key_cryptography/sealed_boxes), both the private and public keys are required.

```powershell
$params = @{
    SealedBox  = '905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg='
    PublicKey  = '9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4='
    PrivateKey = 'MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g='
}
ConvertFrom-SodiumSealedBox @params

mymessage
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

This module would not be possible without the following resources:

- **libsodium** | [Docs](https://doc.libsodium.org/) | [GitHub](https://github.com/jedisct1/libsodium)
