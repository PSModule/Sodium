#Requires -Module GitHub

$response = Invoke-GitHubAPI -ApiEndpoint '/orgs/PSModule/actions/secrets/public-key' | Select-Object -ExpandProperty response
$sealedPublicKeyBox = ConvertTo-SodiumSealedBox -Secret 'mysecret' -PublicKey $response.key
Invoke-GitHubAPI -ApiEndpoint '/orgs/PSModule/actions/secrets/mysecret' -Method PUT -Body @{
    encrypted_value = $sealedPublicKeyBox
    key_id          = $response.key_id
    visibility      = 'all'
}
