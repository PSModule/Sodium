# Sodium

Sodium is a PowerShell module that provides direct bindings to the [`libsodium`](https://github.com/jedisct1/libsodium)
cryptographic library, enabling libsodium-based encryption and decryption directly from PowerShell.

This module was initially created to serve the needs of the [GitHub PowerShell module](https://github.com/PSModule/GitHub).
GitHub's method for creating or updating
[secrets via the REST API](https://docs.github.com/en/rest/guides/encrypting-secrets-for-the-rest-api?apiVersion=2022-11-28#example-encrypting-a-secret-using-c)
requires that secrets be encrypted using libsodium.

## Prerequisites

This module relies on the following:

- The [libsodium](https://github.com/jedisct1/libsodium) library for cryptographic operations.
- Cross-platform PowerShell 7.4 or later (the module ships a net8.0 binary).

On Windows, the module also requires the Microsoft Visual C++ Redistributable for Visual Studio 2015 or later.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-PSResource -Name Sodium
Import-Module -Name Sodium
```

## Usage

### Example: Generate a new key pair

Create a new cryptographic key pair. The keys are returned as an object with `PublicKey` and `PrivateKey`
properties, encoded in base64.

```powershell
New-SodiumKeyPair

PublicKey                                    PrivateKey
---------                                    ----------
9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4= MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g=
```

### Example: Encrypt a message with a public key

Encrypt a message using a recipient's public key with
[sealed boxes](https://doc.libsodium.org/public-key_cryptography/sealed_boxes).

```powershell
$params = @{
    Message   = 'mymessage'
    PublicKey = '9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4='
}
ConvertTo-SodiumSealedBox @params

905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg=
```

### Example: Decrypt a sealed box

Decrypt a sealed box back to the original message. Both the public and private keys are required.

```powershell
$params = @{
    SealedBox  = '905j4S/JyP9XBBmOIdHSOXiDu7fUtZo9TFIMnAfBMESgcVBwttLnEyxJn4xPEX5OMKQ+Bc4P6Hg='
    PublicKey  = '9fv51aqi00MYN4UR7Ew/DLXMS9t1NapLs7yyo+vegz4='
    PrivateKey = 'MiJAFUZxZ1UCbQTwKfH7HY6AhIFYQlnok5fBD2K+y/g=' #gitleaks:allow
}
ConvertFrom-SodiumSealedBox @params

mymessage
```

## Documentation

Documentation is published at [psmodule.io/Sodium](https://psmodule.io/Sodium/).

Use PowerShell help and command discovery for module details:

```powershell
Get-Command -Module Sodium
Get-Help -Name ConvertTo-SodiumSealedBox -Examples
```

## Acknowledgements

This module would not be possible without the following resources:

- **libsodium** | [Docs](https://doc.libsodium.org/) | [GitHub](https://github.com/jedisct1/libsodium)
