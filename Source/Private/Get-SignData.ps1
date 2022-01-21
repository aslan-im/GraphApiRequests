function Get-SignData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [System.Security.Cryptography.RSACng]
        $InputObject,

        [Parameter(Mandatory=$false)]
        [string]
        $JWT

    )
    $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
    $HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
    
    [Convert]::ToBase64String(
        $InputObject.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$HashAlgorithm,$RSAPadding)
    ) -replace '\+','-' -replace '/','_' -replace '='
}