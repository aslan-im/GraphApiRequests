function New-GraphCertificate {
    <#
    .SYNOPSIS
        Function for generating new self signed Graph API auth certificate
    .DESCRIPTION
        After the creation, certificate can be used for authentication in Graph API
    .NOTES
        For running this function you require to provide TenantName (not an ID).
    .EXAMPLE
        New-GraphCertificate -TenantName 'Contoso' -StoreLocation 'Cert:\CurrentUser\Computer'
        Generate new certificate and save in Cert:\CurrentUser\Computer
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $TenantName,

        [Parameter(Mandatory=$false)]
        [string]
        $StoreLocation = 'Cert:\CurrentUser\My',

        [Parameter(Mandatory=$False)]
        [string]
        $CertificateOutputPath = "C:\Temp",

        [Parameter(Mandatory=$false)]
        [DateTime][ValidateScript({$_ -ge (Get-Date)})]
        $ExpirationDate = (Get-Date).AddYears(1),

        [Parameter(Mandatory=$false)]
        [string]
        $FriendlyName = "GraphCert"
    )
    
    $CreateCertSplat = @{
        FriendlyName = $FriendlyName
        DnsName = $TenantName
        CertStoreLocation = $StoreLocation
        NotAfter = $ExpirationDate
        KeyExportPolicy = "Exportable"
        KeySpec = "Signature"
        Provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        HashAlgorithm = "SHA256"
        ErrorAction = "Stop"
    }
   
    $Certificate = New-SelfSignedCertificate @CreateCertSplat

    $CertificatePath = Join-Path -Path $StoreLocation -ChildPath $Certificate.Thumbprint

    If (!(Test-Path -Path $CertificateOutputPath)){
        New-Item -ItemType Folder -Path $CertificateOutputPath
    }
    
    $CerOutPath = "$CertificateOutputPath\$FriendlyName.cer"
    Export-Certificate -Cert $CertificatePath -FilePath $CerOutPath
}