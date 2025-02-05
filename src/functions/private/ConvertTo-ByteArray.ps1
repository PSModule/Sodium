function ConvertTo-ByteArray {
    <#
        .SYNOPSIS
        Converts a string into a byte array.

        .DESCRIPTION
        This function attempts to convert an input string into a byte array.
        It first checks if the input is a Base64-encoded string and attempts to decode it.
        If the Base64 decoding fails, it assumes the input consists of space-separated decimal values and converts them to bytes.

        .EXAMPLE
        ConvertTo-ByteArray "SGVsbG8gd29ybGQ="

        Converts the Base64-encoded string "SGVsbG8gd29ybGQ=" into a byte array.

        .EXAMPLE
        ConvertTo-ByteArray "72 101 108 108 111"

        Converts the space-separated decimal values into a byte array representing the string "Hello".

        .NOTES
        This function assumes that if the input is not valid Base64, it must be space-separated decimal values.
    #>
    [OutputType([byte[]])]
    [CmdletBinding()]
    param (
        # The input string to be converted into a byte array.
        [Parameter(Mandatory = $true)]
        [string] $InputString
    )

    # Check if it's a Base64 string first (GitHub API provides keys in Base64)
    try {
        return [Convert]::FromBase64String($InputString)
    } catch {
        # If not Base64, assume it's space-separated decimal values
        return $InputString -split '\s+' | ForEach-Object { [byte]$_ }
    }
}
