# Sodium

A PowerShell module for handling Sodium enchrypted secrets.

## Prerequisites

This uses the following external resources:
- The [PSModule framework](https://github.com/PSModule) for building, testing and publishing the module.

## Installation

To install the module from the PowerShell Gallery, you can use the following command:

```powershell
Install-PSResource -Name Sodium
Import-Module -Name Sodium
```

## Usage

Here is a list of example that are typical use cases for the module.

### Example 1: Convert a string to a Sodium encrypted secret

```powershell
$secret = "123456"
$encryptedSecret = $secret | ConvertTo-SodiumSecret
```

### Example 2: Convert a Sodium encrypted secret to a string

```powershell
$encryptedSecret = "..."
$secret = $encryptedSecret | ConvertFrom-SodiumSecret
Write-Host $secret

123456
```

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

Here is a list of people and projects that helped this project in some way.
