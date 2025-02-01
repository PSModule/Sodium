# 1) You would want to save this as a secret.
$secretName = 'MY_SUPER_SECRET'
$secret = 'Hello world!'

# 2a) You have to request a public key from GitHub.
#     GitHub creates a key pair and stores it.

$GitHubSecretStore = @{}  # The secret store where the secrets are stored.
$GitHubKeyPairStore = @{} # The key pair store would be a separate store to temporarily hold keys until secrets are created.

$keyPair = New-SodiumKeyPair
$id = [guid]::NewGuid().ToString() -replace '-'
$GitHubKeyPairStore[$id] = [pscustomobject]@{
    PrivateKey = $keyPair.PrivateKey
    PublicKey  = $keyPair.PublicKey  # May or may not be stored?
}

# 2b) GitHub sends you the public key and ID.
$userInfo = @{
    PublicKey = $keyPair.PublicKey
    ID        = $id
}

# 3a) You encrypt the secret with the public key.
$encryptedSecret = ConvertTo-SodiumEncryptedString -Secret $secret -PublicKey $userInfo.PublicKey

# 3b) You send the encrypted secret to GitHub with the name of the secret and the ID GitHub sent you.
$secretInfo = @{
    SecretName      = $secretName
    EncryptedSecret = $encryptedSecret
    ID              = $userInfo.ID
}

# 4) GitHub likely stores the encrypted secret using its name as the key.
#    It also stores the private and public key fetched from the KeyPairStore using the ID you provided.
#    They likely also run a quick test to see that they can decrypt the secret using the private key.
$GitHubSecretStore[$secretInfo.SecretName] = [pscustomobject]@{
    Secret     = $secretInfo.EncryptedSecret
    PrivateKey = $GitHubKeyPairStore[$secretInfo.ID].PrivateKey
    PublicKey  = $GitHubKeyPairStore[$secretInfo.ID].PublicKey
}

# 5) When used in GitHub Actions, the GitHub Secret Service likely ONLY trusts the 'GitHub Actions' App,
#    and retrieves the secret by its name.
$actionParams = @{
    EncryptedSecret = $GitHubSecretStore[$secretName].Secret
    PublicKey       = $GitHubSecretStore[$secretName].PublicKey
    PrivateKey      = $GitHubSecretStore[$secretName].PrivateKey
}
$decryptedString = ConvertFrom-SodiumEncryptedString @actionParams

# 6) The decrypted secret is now available for use in the GitHub Action.
Write-Warning $decryptedString
