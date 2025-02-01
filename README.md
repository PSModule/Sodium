# Sodium

A PowerShell module that provides `Sodium.Core` and `libsodium` functionality.


## Prerequisites

This uses the following external resources:
- The [PSModule framework](https://github.com/PSModule) for building, testing and publishing the module.

## Installation

To install the module from the PowerShell Gallery, you can use the following command:

```powershell
Install-PSResource -Name YourModuleName
Import-Module -Name YourModuleName
```

## Usage

Here is a list of example that are typical use cases for the module.

### Example 1: Greet an entity

Provide examples for typical commands that a user would like to do with the module.

```powershell
Greet-Entity -Name 'World'
Hello, World!
```

### Example 2

Provide examples for typical commands that a user would like to do with the module.

```powershell
Import-Module -Name PSModuleTemplate
```

### Find more examples

To find more examples of how to use the module, please refer to the [examples](examples) folder.

Alternatively, you can use the Get-Command -Module 'This module' to find more commands that are available in the module.
To find examples of each of the commands you can use Get-Help -Examples 'CommandName'.

## Documentation

Link to further documentation if available, or describe where in the repository users can find more detailed documentation about
the module's functions and features.

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

- [Resolving PowerShell module assembly dependency conflicts | PowerShell Docs @ Microsoft Learn]https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/resolving-dependency-conflicts?view=powershell-7.4#more-robust-solutions
- [https://github.com/rjmholt/ModuleDependencyIsolationExample](https://github.com/rjmholt/ModuleDependencyIsolationExample)

Libsodium:

- Sodium.Core | [](https://github.com/ektrah/libsodium-core)
- libsodium | [Docs](https://doc.libsodium.org/) | [GitHub](https://github.com/jedisct1/libsodium)
