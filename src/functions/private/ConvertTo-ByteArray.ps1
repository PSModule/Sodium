function ConvertTo-ByteArray {
    param (
        [string]$InputString
    )

    # Check if it's a Base64 string first (GitHub API provides keys in Base64)
    try {
        return [Convert]::FromBase64String($InputString)
    } catch {
        # If not Base64, assume it's space-separated decimal values
        return $InputString -split '\s+' | ForEach-Object { [byte]$_ }
    }
}
