function New-GHRepositorySecret {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [String]
        $Organization,
        [Parameter()]
        [String]
        $RepositoryName,
        [Parameter()]
        [String]
        $SecretName,
        [Parameter()]
        [String]
        $SecretValue
    )
    try {
        $ghToken = New-GHRepoToken
        if (!$ghToken) {
            throw 'No token retrieved'
        }
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }

    $envpub = @{
        Uri     = "https://api.github.com/repos/$Organization/$RepositoryName/actions/secrets/public-key"
        Method  = 'Get'
        Headers = @{
            Accept                 = 'application/vnd.github+json'
            Authorization          = "Bearer $($ghToken.token)"
            'X-GitHub-Api-Version' = '2022-11-28'
        }
    }

    $publicKey = Invoke-RestMethod @envpub

    $envsecret = @{
        Uri     = "https://api.github.com/repos/$Organization/$RepositoryName/actions/secrets/$SecretName"
        Method  = 'PUT'
        Headers = @{
            Accept                 = 'application/vnd.github+json'
            Authorization          = "Bearer $($ghToken.token)"
            'X-GitHub-Api-Version' = '2022-11-28'
        }
        Body    = @{
            encrypted_value = [Convert]::ToBase64String(
                [Sodium.SealedPublicKeyBox]::Create(
                    $SecretValue,
                    [Convert]::FromBase64String($publicKey.Key)
                )
            )
            key_id          = $publicKey.key_id
        } | ConvertTo-Json
    }
    Invoke-RestMethod @envsecret
}
