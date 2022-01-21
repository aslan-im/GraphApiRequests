Function Get-GraphCertToken {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $AppId, 

        [Parameter(Mandatory=$true)]
        [string]        
        $TenantID,
        
        [Parameter(Mandatory=$true)]
        [string]
        $CertificatePath     
    )
    . $PSScriptRoot\..\Private\Get-SignData.ps1

    $Scope = "https://graph.microsoft.com/.default"

    $Certificate = Get-Item $CertificatePath
    $CertificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())

    $StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
    $JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
    $JWTExpiration = [math]::Round($JWTExpirationTimeSpan,0)

    $NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
    $NotBefore = [math]::Round($NotBeforeExpirationTimeSpan,0)

    $JWTHeader = @{
        alg = "RS256"
        typ = "JWT"
        x5t = $CertificateBase64Hash -replace '\+','-' -replace '/','_' -replace '='
    }

    $JWTPayLoad = @{
        aud = "https://login.microsoftonline.com/$TenantID/oauth2/token"
        exp = $JWTExpiration
        iss = $AppId
        jti = [guid]::NewGuid()
        nbf = $NotBefore
        sub = $AppId
    }

    $JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
    $EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)

    $JWTPayLoadToByte =  [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
    $EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)

    $JWT = $EncodedHeader + "." + $EncodedPayload

    $PrivateKey = $Certificate.PrivateKey

    # $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
    # $HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256

    $Signature = Get-SignData -inputObject $PrivateKey -JWT $JWT
    # $Signature = [Convert]::ToBase64String(
    #     $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$HashAlgorithm,$RSAPadding)
    # ) -replace '\+','-' -replace '/','_' -replace '='

    $JWT = $JWT + "." + $Signature

    $Body = @{
        client_id = $AppId
        client_assertion = $JWT
        client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
        scope = $Scope
        grant_type = "client_credentials"

    }

    $Url = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

    $Header = @{
        Authorization = "Bearer $JWT"
    }

    $PostSplat = @{
        ContentType = 'application/x-www-form-urlencoded'
        Method = 'POST'
        Body = $Body
        Uri = $Url
        Headers = $Header
    }

    Invoke-RestMethod @PostSplat
}